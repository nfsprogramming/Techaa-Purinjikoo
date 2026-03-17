
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
  xp: 0,
  streak: 0,
  lastLogin: null,
  unlockedBadges: [],
  level: 1,
  xpHistory: []
};

export function UserProgressProvider({ children }) {
  const { user } = useAuth();
  const [progress, setProgress] = useState(DEFAULT_PROGRESS);
  const [initialized, setInitialized] = useState(false);
  const skipSync = useRef(false);

  // 1. Initial Load: LocalStorage Fallback + Reset on User Change
  useEffect(() => {
    if (!user) {
      // If no user, reset to default (prevents cross-account data leaks)
      setProgress(DEFAULT_PROGRESS);
      setInitialized(true);
      return;
    }

    // Try to load user-specific progress from localStorage for quick UI update
    const saved = localStorage.getItem(`techaa_progress_${user.uid}`);
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        setProgress(parsed);
      } catch (e) {
        console.error("Failed to parse local progress", e);
      }
    }
    
    // Fetch fresh data from Firestore
    const fetchFirestoreProgress = async () => {
      try {
        const docRef = doc(db, "users", user.uid);
        const docSnap = await getDoc(docRef);
        
        if (docSnap.exists() && docSnap.data().progress) {
          const firestoreProgress = docSnap.data().progress;
          // Only update if firestore has more xp or different topics (merging logic could be more complex, but this is a start)
          setProgress(firestoreProgress);
          localStorage.setItem(`techaa_progress_${user.uid}`, JSON.stringify(firestoreProgress));
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

    // Save locally for speed
    localStorage.setItem(`techaa_progress_${user.uid}`, JSON.stringify(progress));

    // Save to Firestore (Debounced or Async)
    const syncToFirestore = async () => {
      try {
        const docRef = doc(db, "users", user.uid);
        await updateDoc(docRef, { progress: progress });
      } catch (err) {
        console.error("Error syncing to Firestore:", err);
        // If document doesn't exist yet, AuthContext might still be creating it
      }
    };

    const timer = setTimeout(syncToFirestore, 1000); // 1s debounce to avoid hitting quotas
    return () => clearTimeout(timer);
  }, [progress, user, initialized]);

  // 3. Daily Login Streak logic
  useEffect(() => {
    if (!initialized || !user) return;

    const today = new Date().toISOString().split('T')[0];
    
    setProgress(prev => {
      // Prevents multiple calls on the same day if state updates haven't flushed
      if (prev.lastLogin === today) return prev;

      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split('T')[0];

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
        lastLogin: today,
        streak: newStreak,
        xp: newXP,
        level: newLevel,
        xpHistory: [historyEntry, ...(prev.xpHistory || [])].slice(0, 30)
      };
    });
  }, [initialized, user]); // Dependency today was removed because it is defined inside the effect body

  const addXP = (amount, reason = "Bonus Points") => {
    setProgress(prev => {
      const newXP = (prev.xp || 0) + amount;
      const newLevel = XP_LEVELS.findLast(l => newXP >= l.minXP)?.level || 1;
      const historyEntry = { amount, reason, timestamp: Date.now() };
      return { 
        ...prev, 
        xp: newXP, 
        level: newLevel,
        xpHistory: [historyEntry, ...(prev.xpHistory || [])].slice(0, 30) // Keep last 30 entries
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

      // Badge logic
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

  const isTopicLocked = (topicId) => {
    const topicIndex = topics.findIndex(t => t.id === topicId);
    if (topicIndex === -1) return true;
    if (topicIndex === 0) return false; // First topic always unlocked
    
    // Unlocked if previous topic is completed OR it's already completed
    const previousTopic = topics[topicIndex - 1];
    return !progress.completedTopics.includes(previousTopic.id) && !progress.completedTopics.includes(topicId);
  };

  const getLevelProgress = (levelId) => {
    const levelTopics = topics.filter(t => t.level === levelId);
    if (levelTopics.length === 0) return 0;
    const completedInLevel = levelTopics.filter(t => progress.completedTopics.includes(t.id));
    return Math.round((completedInLevel.length / levelTopics.length) * 100);
  };

  return (
    <UserProgressContext.Provider value={{ 
      ...progress, 
      completeTopic, 
      addXP, 
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
