
"use client";
import React, { createContext, useContext, useState, useEffect, useRef } from 'react';
import { XP_LEVELS, BADGES, XP_AWARDS } from '@/data/gamification';
import { topics } from '@/data/topics';
import { useAuth } from './AuthContext';
import { db } from '@/lib/firebase';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

const UserProgressContext = createContext();

const DEFAULT_PROGRESS = {
  completedTopics: [],
  completedQuizzes: [],
  completedReadings: [],
  viewedMistakes: [],
  xp: 0,
  streak: 0,
  lastLogin: null,
  unlockedBadges: [],
  level: 1,
  xpHistory: [],
  avatarStyle: {
    border: "plain", // plain, glow, neon, gold
    emoji: "" // optional overlay emoji
  }
};

export function UserProgressProvider({ children }) {
  const { user } = useAuth();
  const [progress, setProgress] = useState(DEFAULT_PROGRESS);
  const [initialized, setInitialized] = useState(false);
  const skipSync = useRef(false);

  // 1. Initial Load: LocalStorage Fallback + Reset on User Change
  useEffect(() => {
    if (!user) {
      setProgress(DEFAULT_PROGRESS);
      setInitialized(true);
      return;
    }

    const saved = localStorage.getItem(`techaa_progress_${user.uid}`);
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        setProgress(parsed);
      } catch (e) {
        console.error("Failed to parse local progress", e);
      }
    }
    
    const fetchFirestoreProgress = async () => {
      try {
        const docRef = doc(db, "users", user.uid);
        const docSnap = await getDoc(docRef);
        
        if (docSnap.exists() && docSnap.data().progress) {
          const firestoreProgress = docSnap.data().progress;
          // Merge with defaults to handle new fields
          const mergedProgress = { ...DEFAULT_PROGRESS, ...firestoreProgress };
          setProgress(mergedProgress);
          localStorage.setItem(`techaa_progress_${user.uid}`, JSON.stringify(mergedProgress));
        }
      } catch (err) {
        console.error("Firestore loading error:", err);
      } finally {
        setInitialized(true);
      }
    };

    fetchFirestoreProgress();
  }, [user]);

  // 2. Save Progress: Firestore & LocalStorage
  useEffect(() => {
    if (!initialized || !user || skipSync.current) {
      skipSync.current = false;
      return;
    }

    localStorage.setItem(`techaa_progress_${user.uid}`, JSON.stringify(progress));

    const syncToFirestore = async () => {
      try {
        const docRef = doc(db, "users", user.uid);
        await setDoc(docRef, { 
          progress: progress,
          lastUpdated: Date.now(),
          email: user.email,
          name: user.displayName
        }, { merge: true });
      } catch (err) {
        console.error("Error syncing to Firestore:", err);
      }
    };

    const timer = setTimeout(syncToFirestore, 1000);
    return () => clearTimeout(timer);
  }, [progress, user, initialized]);

  // 3. Daily Login Streak logic
  useEffect(() => {
    if (!initialized || !user) return;

    const getLocalYYYYMMDD = (date) => {
      const yyyy = date.getFullYear();
      const mm = String(date.getMonth() + 1).padStart(2, '0');
      const dd = String(date.getDate()).padStart(2, '0');
      return `${yyyy}-${mm}-${dd}`;
    };

    const now = new Date();
    const todayStr = getLocalYYYYMMDD(now);
    
    setProgress(prev => {
      if (prev.lastLogin === todayStr) return prev;

      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = getLocalYYYYMMDD(yesterday);

      let newStreak = 1;
      if (prev.lastLogin === yesterdayStr) {
        newStreak = (prev.streak || 0) + 1;
      }

      const dailyXP = XP_AWARDS.DAILY_LOGIN;
      const historyEntry = { 
        amount: dailyXP, 
        reason: "Daily Streak 🔥", 
        timestamp: Date.now() 
      };
      
      const newXP = (prev.xp || 0) + dailyXP;
      const newLevel = XP_LEVELS.findLast(l => newXP >= l.minXP)?.level || 1;
      
      return {
        ...prev,
        lastLogin: todayStr,
        streak: newStreak,
        xp: newXP,
        level: newLevel,
        xpHistory: [historyEntry, ...(prev.xpHistory || [])].slice(0, 30)
      };
    });
  }, [initialized, user]);

  const addXP = (amount, reason = "Bonus Points") => {
    setProgress(prev => {
      const newXP = (prev.xp || 0) + amount;
      const newLevel = XP_LEVELS.findLast(l => newXP >= l.minXP)?.level || 1;
      const historyEntry = { amount, reason, timestamp: Date.now() };
      return { 
        ...prev, 
        xp: newXP, 
        level: newLevel,
        xpHistory: [historyEntry, ...(prev.xpHistory || [])].slice(0, 30)
      };
    });
  };

  const markRead = (topicId) => {
    setProgress(prev => {
      if ((prev.completedReadings || []).includes(topicId)) return prev;
      return {
        ...prev,
        completedReadings: [...(prev.completedReadings || []), topicId]
      };
    });
  };

  const markMistakeSeen = (topicId) => {
    setProgress(prev => {
      if ((prev.viewedMistakes || []).includes(topicId)) return prev;
      return {
        ...prev,
        viewedMistakes: [...(prev.viewedMistakes || []), topicId]
      };
    });
  };

  const completeQuiz = (topicId) => {
    setProgress(prev => {
      if ((prev.completedQuizzes || []).includes(topicId)) return prev;
      
      const topic = topics.find(t => t.id === topicId);
      const xpGain = XP_AWARDS.QUIZ_CORRECT;
      const newXP = (prev.xp || 0) + xpGain;
      const newLevel = XP_LEVELS.findLast(l => newXP >= l.minXP)?.level || 1;
      const historyEntry = { 
        amount: xpGain, 
        reason: "Quiz Correct 🔥", 
        timestamp: Date.now() 
      };

      return {
        ...prev,
        completedQuizzes: [...(prev.completedQuizzes || []), topicId],
        xp: newXP,
        level: newLevel,
        xpHistory: [historyEntry, ...(prev.xpHistory || [])].slice(0, 30)
      };
    });
  };

  const completeTopic = (topicId) => {
    if (progress.completedTopics.includes(topicId)) return;
    const topic = topics.find(t => t.id === topicId);

    setProgress(prev => {
      const newCompleted = [...prev.completedTopics, topicId];
      const xpGain = XP_AWARDS.READ_TOPIC;
      const newXP = (prev.xp || 0) + xpGain;
      const newLevel = XP_LEVELS.findLast(l => l.minXP <= newXP)?.level || 1;
      
      const historyEntry = { amount: xpGain, reason: `Completed: ${topic?.title || topicId}`, timestamp: Date.now() };

      const newlyUnlocked = [];
      BADGES.forEach(badge => {
        if (prev.unlockedBadges.includes(badge.id)) return;

        let meetsRequirement = false;
        if (badge.requirement.type === 'count') {
          meetsRequirement = newCompleted.length >= badge.requirement.value;
        } else if (badge.requirement.type === 'levels') {
          const levelTopics = topics.filter(t => badge.requirement.value.includes(t.level));
          meetsRequirement = levelTopics.length > 0 && levelTopics.every(t => newCompleted.includes(t.id));
        } else if (badge.requirement.type === 'ids') {
          meetsRequirement = badge.requirement.value.every(id => newCompleted.includes(id));
        }

        if (meetsRequirement) {
          newlyUnlocked.push(badge.id);
        }
      });

      return {
        ...prev,
        completedTopics: newCompleted,
        xp: newXP,
        level: newLevel,
        unlockedBadges: [...prev.unlockedBadges, ...newlyUnlocked],
        xpHistory: [historyEntry, ...(prev.xpHistory || [])].slice(0, 30)
      };
    });
  };

  const resetProgress = async () => {
    if (!user) return;
    
    // Opting for a silent reset since the user explicitly asked to start from scratch
    setProgress(DEFAULT_PROGRESS);
    localStorage.removeItem(`techaa_progress_${user.uid}`);
    
    try {
      const docRef = doc(db, "users", user.uid);
      await updateDoc(docRef, { progress: DEFAULT_PROGRESS });
      return true;
    } catch (err) {
      console.error("Reset error:", err);
      return false;
    }
  };

  const isTopicLocked = (topicId) => {
    if (!user) return false; // Allowed to explore for guests! 🔓
    
    const topicIndex = topics.findIndex(t => t.id === topicId);
    if (topicIndex === -1) return true;
    if (topicIndex === 0) return false;
    
    const previousTopic = topics[topicIndex - 1];
    return !progress.completedTopics.includes(previousTopic.id) && !progress.completedTopics.includes(topicId);
  };

  const getLevelProgress = (levelId) => {
    const levelTopics = topics.filter(t => t.level === levelId);
    if (levelTopics.length === 0) return 0;
    const completedInLevel = levelTopics.filter(t => progress.completedTopics.includes(t.id));
    return Math.round((completedInLevel.length / levelTopics.length) * 100);
  };

  const updateAvatarStyle = (newStyle) => {
    setProgress(prev => ({
      ...prev,
      avatarStyle: { ...prev.avatarStyle, ...newStyle }
    }));
  };

  return (
    <UserProgressContext.Provider value={{ 
      ...progress, 
      completeTopic, 
      completeQuiz,
      markRead,
      markMistakeSeen,
      addXP, 
      updateAvatarStyle,
      resetProgress,
      getLevelProgress,
      isTopicLocked,
      XP_LEVELS,
      BADGES,
      loading: !initialized
    }}>
      {children}
    </UserProgressContext.Provider>
  );
}

export const useUserProgress = () => useContext(UserProgressContext);
