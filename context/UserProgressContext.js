
"use client";
import React, { createContext, useContext, useState, useEffect } from 'react';
import { XP_LEVELS, BADGES, XP_AWARDS } from '@/data/gamification';
import { topics } from '@/data/topics';

const UserProgressContext = createContext();

export function UserProgressProvider({ children }) {
  const [progress, setProgress] = useState({
    completedTopics: [],
    xp: 0,
    streak: 0,
    lastLogin: null,
    unlockedBadges: [],
    level: 1
  });

  const [initialized, setInitialized] = useState(false);

  // Load from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('techaa_progress');
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        setProgress(parsed);
      } catch (e) {
        console.error("Failed to parse progress", e);
      }
    }
    setInitialized(true);
  }, []);

  // Save to localStorage
  useEffect(() => {
    if (initialized) {
      localStorage.setItem('techaa_progress', JSON.stringify(progress));
    }
  }, [progress, initialized]);

  // Daily Login Streak logic
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
        // Night owl etc could be added here on event

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
      XP_LEVELS,
      BADGES
    }}>
      {children}
    </UserProgressContext.Provider>
  );
}

export const useUserProgress = () => useContext(UserProgressContext);
