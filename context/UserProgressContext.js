"use client";
import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { XP_LEVELS, BADGES, XP_AWARDS } from '@/data/gamification';
import { topics } from '@/data/topics';
import { useAuth } from '@/context/AuthContext';
import { db } from '@/lib/firebase';
import { doc, getDoc, setDoc, onSnapshot } from 'firebase/firestore';

const UserProgressContext = createContext();

export function UserProgressProvider({ children }) {
  const { user } = useAuth();
  const [progress, setProgress] = useState({
    completedTopics: [],
    xp: 0,
    streak: 0,
    lastLogin: null,
    unlockedBadges: [],
    level: 1
  });

  const [initialized, setInitialized] = useState(false);
  const [isSyncing, setIsSyncing] = useState(false);
  const [syncStatusMessage, setSyncStatusMessage] = useState(null);

  // 1. Load initial cache from localStorage
  useEffect(() => {
    try {
      const saved = localStorage.getItem('techaa_progress');
      if (saved) {
        const parsed = JSON.parse(saved);
        setProgress(parsed);
      }
    } catch (e) {
      console.error("Failed to parse local progress", e);
    }
    setInitialized(true);
  }, []);

  // 2. Save to localStorage whenever progress state updates
  useEffect(() => {
    if (initialized) {
      localStorage.setItem('techaa_progress', JSON.stringify(progress));
    }
  }, [progress, initialized]);

  // 3. Manual / Automatic Sync function targeting /users/{userId}
  const syncNow = useCallback(async () => {
    if (!user || !db) return;
    setIsSyncing(true);

    try {
      // Use the standard authorized /users/{uid} document
      const docRef = doc(db, 'users', user.uid);
      const snap = await getDoc(docRef);
      const localSaved = JSON.parse(localStorage.getItem('techaa_progress') || '{}');
      
      let cloudProgress = {};
      if (snap.exists()) {
        const data = snap.data();
        cloudProgress = data.progress || (data.xp !== undefined ? data : {});
      }

      // Merge local and cloud progress (union of completed topics and badges, max xp)
      const mergedCompleted = Array.from(
        new Set([
          ...(localSaved.completedTopics || []),
          ...(progress.completedTopics || []),
          ...(cloudProgress.completedTopics || [])
        ])
      );
      const mergedBadges = Array.from(
        new Set([
          ...(localSaved.unlockedBadges || []),
          ...(progress.unlockedBadges || []),
          ...(cloudProgress.unlockedBadges || [])
        ])
      );
      const mergedXP = Math.max(
        Number(localSaved.xp) || 0,
        Number(progress.xp) || 0,
        Number(cloudProgress.xp) || 0
      );
      const mergedStreak = Math.max(
        Number(localSaved.streak) || 0,
        Number(progress.streak) || 0,
        Number(cloudProgress.streak) || 0,
        1
      );
      const mergedLevel = XP_LEVELS.findLast(l => mergedXP >= l.minXP)?.level || 1;

      const merged = {
        completedTopics: mergedCompleted,
        unlockedBadges: mergedBadges,
        xp: mergedXP,
        streak: mergedStreak,
        lastLogin: cloudProgress.lastLogin || localSaved.lastLogin || new Date().toISOString().split('T')[0],
        level: mergedLevel,
        updatedAt: new Date().toISOString()
      };

      // Save merged progress inside users/{uid} document
      await setDoc(docRef, { progress: merged }, { merge: true });

      setProgress(merged);
      localStorage.setItem('techaa_progress', JSON.stringify(merged));
      setSyncStatusMessage(`Synced ${mergedXP} XP & Level ${mergedLevel} to Cloud! 🚀`);
      setTimeout(() => setSyncStatusMessage(null), 4000);
      return merged;
    } catch (err) {
      console.warn('Sync error in users document:', err);
      setSyncStatusMessage(`Sync notice: ${err.message || 'Connecting...'}`);
      setTimeout(() => setSyncStatusMessage(null), 4000);
    } finally {
      setIsSyncing(false);
    }
  }, [user?.uid, progress]);

  // 4. Real-time Cloud Sync with Firestore /users/{uid}
  useEffect(() => {
    if (!user || !db) return;

    const docRef = doc(db, 'users', user.uid);

    // Initial immediate sync on login
    syncNow();

    // Listen for real-time Firestore updates across tabs / deployments
    const unsubscribe = onSnapshot(docRef, (docSnap) => {
      if (docSnap.exists()) {
        const data = docSnap.data();
        const cloudData = data.progress || (data.xp !== undefined ? data : null);
        if (!cloudData) return;

        setProgress(prev => {
          const mergedCompleted = Array.from(
            new Set([...(prev.completedTopics || []), ...(cloudData.completedTopics || [])])
          );
          const mergedBadges = Array.from(
            new Set([...(prev.unlockedBadges || []), ...(cloudData.unlockedBadges || [])])
          );
          const mergedXP = Math.max(Number(prev.xp) || 0, Number(cloudData.xp) || 0);
          const mergedStreak = Math.max(Number(prev.streak) || 0, Number(cloudData.streak) || 0);
          const mergedLevel = XP_LEVELS.findLast(l => mergedXP >= l.minXP)?.level || 1;

          const updated = {
            completedTopics: mergedCompleted,
            unlockedBadges: mergedBadges,
            xp: mergedXP,
            streak: mergedStreak,
            lastLogin: cloudData.lastLogin || prev.lastLogin || new Date().toISOString().split('T')[0],
            level: mergedLevel
          };
          localStorage.setItem('techaa_progress', JSON.stringify(updated));
          return updated;
        });
      }
    }, (error) => {
      console.warn('Firestore snapshot listener note:', error.message);
    });

    return () => unsubscribe();
  }, [user?.uid]);

  // 5. Save to Firestore whenever progress updates (debounced)
  useEffect(() => {
    if (!initialized || !user || !db) return;

    const timeoutId = setTimeout(() => {
      try {
        const docRef = doc(db, 'users', user.uid);
        setDoc(docRef, { progress: progress }, { merge: true }).catch((err) => {
          console.warn('Could not sync progress to users doc:', err);
        });
      } catch (_) {}
    }, 600);

    return () => clearTimeout(timeoutId);
  }, [progress, initialized, user?.uid]);

  // 6. Daily Login Streak logic
  useEffect(() => {
    if (!initialized) return;

    const today = new Date().toISOString().split('T')[0];
    if (progress.lastLogin !== today) {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split('T')[0];

      let newStreak = 1;
      if (progress.lastLogin === yesterdayStr) {
        newStreak = progress.streak + 1;
      }

      const dailyXP = XP_AWARDS.DAILY_LOGIN;
      
      setProgress(prev => {
        const newXP = prev.xp + dailyXP;
        const newLevel = XP_LEVELS.findLast(l => newXP >= l.minXP)?.level || 1;
        return {
          ...prev,
          lastLogin: today,
          streak: newStreak,
          xp: newXP,
          level: newLevel
        };
      });
    }
  }, [initialized]);

  const addXP = (amount) => {
    setProgress(prev => {
      const newXP = prev.xp + amount;
      const newLevel = XP_LEVELS.findLast(l => newXP >= l.minXP)?.level || 1;
      return { ...prev, xp: newXP, level: newLevel };
    });
  };

  const completeTopic = (topicId) => {
    if (progress.completedTopics.includes(topicId)) return;

    setProgress(prev => {
      const newCompleted = [...prev.completedTopics, topicId];
      const xpGain = XP_AWARDS.READ_TOPIC;
      const newXP = prev.xp + xpGain;
      const newLevel = XP_LEVELS.findLast(l => l.minXP <= newXP)?.level || 1;
      
      // Badge logic
      const newlyUnlocked = [];
      BADGES.forEach(badge => {
        if (prev.unlockedBadges.includes(badge.id)) return;

        let meetsRequirement = false;
        if (badge.requirement.type === 'count') {
          meetsRequirement = newCompleted.length >= badge.requirement.value;
        } else if (badge.requirement.type === 'levels') {
          const levelTopics = topics.filter(t => badge.requirement.value.includes(t.level));
          meetsRequirement = levelTopics.every(t => newCompleted.includes(t.id));
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
        unlockedBadges: [...prev.unlockedBadges, ...newlyUnlocked]
      };
    });
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
      syncNow,
      isSyncing,
      syncStatusMessage,
      XP_LEVELS,
      BADGES
    }}>
      {children}
    </UserProgressContext.Provider>
  );
}

export const useUserProgress = () => useContext(UserProgressContext);
