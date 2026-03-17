
"use client";
import { useUserProgress } from "@/context/UserProgressContext";
import Navbar from "@/components/Navbar";
import { topics } from "@/data/topics";
import Link from "next/link";
import { useState, useEffect } from "react";
import { useAuth } from "@/context/AuthContext";
import { motion } from "framer-motion";

export default function ProfilePage() {
  const { xp, level, streak, completedTopics, unlockedBadges, XP_LEVELS, BADGES, getLevelProgress, loading, xpHistory } = useUserProgress();
  const { user } = useAuth();
  
  const [leaderboard, setLeaderboard] = useState([]);
  const [loadingLeaderboard, setLoadingLeaderboard] = useState(true);

  useEffect(() => {
    const fetchLeaderboard = async () => {
      try {
        const { collection, getDocs } = await import('firebase/firestore');
        const { db } = await import('@/lib/firebase');
        const querySnapshot = await getDocs(collection(db, "users"));
        const users = [];
        querySnapshot.forEach((doc) => {
          const data = doc.data();
          if (data.progress) {
            users.push({
              id: doc.id,
              name: data.name || "Anonymous Learner",
              avatar: data.photoURL || null,
              xp: data.progress.xp || 0
            });
          }
        });
        setLeaderboard(users.sort((a, b) => b.xp - a.xp).slice(0, 20));
      } catch (err) {
        console.error("Leaderboard error:", err);
      } finally {
        setLoadingLeaderboard(false);
      }
    };
    if (!loading) fetchLeaderboard();
  }, [loading]);

  if (loading) {
    return (
      <div style={{ background: "#070711", minHeight: "100vh", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", flexDirection: "column", gap: "20px" }}>
        <div style={{ width: "40px", height: "40px", border: "3px solid rgba(139,92,246,0.3)", borderTopColor: "#8b5cf6", borderRadius: "50%", animation: "spin 1s linear infinite" }} />
        <p style={{ fontWeight: 800, color: "#8b5cf6", letterSpacing: "1px" }}>LOADING PROGRESS...</p>
        <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
      </div>
    );
  }

  const nextLevel = XP_LEVELS.find(l => l.level === level + 1);
  const currentLevel = XP_LEVELS.find(l => l.level === level);
  const xpInCurrentLevel = xp - (currentLevel?.minXP || 0);
  const xpForNextLevel = (nextLevel?.minXP || xp) - (currentLevel?.minXP || 0);
  const levelPercentage = Math.min(100, Math.round((xpInCurrentLevel / (xpForNextLevel || 1)) * 100));

  const stats = [
    { label: "Topics", value: completedTopics.length, icon: "📚", color: "#8b5cf6" },
    { label: "Streak", value: streak, icon: "🔥", color: "#f59e0b" },
    { label: "Total XP", value: xp, icon: "✨", color: "#06b6d4" },
    { label: "Badges", value: unlockedBadges.length, icon: "🏆", color: "#10b981" },
  ];

  const ROADMAP_LEVELS = [
    { id: 1, name: "Internet Basics", icon: "🌐" },
    { id: 2, name: "Web Development", icon: "💻" },
    { id: 3, name: "Databases", icon: "🗄️" },
    { id: 4, name: "Cloud & Deploy", icon: "☁️" },
    { id: 5, name: "Dev Tools", icon: "🧑‍💻" },
    { id: 6, name: "Security", icon: "🔐" },
    { id: 7, name: "AI & Modern Tech", icon: "🤖" },
  ];

  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff" }}>
      <Navbar />
      
      {/* Container with responsive padding */}
      <div style={{ maxWidth: "1000px", margin: "0 auto", padding: "80px 16px 60px" }}>
        
        <style>{`
          .profile-grid-main { display: grid; grid-template-columns: 1fr; gap: 32px; }
          @media (min-width: 900px) { .profile-grid-main { grid-template-columns: 1.5fr 1fr; } }
          
          .stats-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; margin-bottom: 32px; }
          @media (min-width: 600px) { .stats-grid { grid-template-columns: repeat(4, 1fr); gap: 16px; } }

          .badges-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 12px; }
          @media (min-width: 600px) { .badges-grid { grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); } }
          
          .profile-header { display: flex; flex-direction: column; align-items: center; text-align: center; gap: 20px; background: rgba(255,255,255,0.02); padding: 32px 20px; borderRadius: 32px; border: 1px solid rgba(255,255,255,0.05); margin-bottom: 32px; }
          @media (min-width: 600px) { .profile-header { flex-direction: row; text-align: left; padding: 40px; } }
        `}</style>

        {/* Profile Header */}
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="profile-header">
          <div style={{ width: "100px", height: "100px", borderRadius: "50%", background: "linear-gradient(135deg, #8b5cf6, #06b6d4)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "3rem", boxShadow: "0 0 30px rgba(139,92,246,0.2)", overflow: "hidden", border: "4px solid #070711", flexShrink: 0 }}>
            {user?.photoURL ? (
              <img 
                src={user.photoURL} 
                alt="Me" 
                referrerPolicy="no-referrer" 
                style={{ width: "100%", height: "100%", objectFit: "cover" }}
                onError={(e) => { e.target.src = `https://ui-avatars.com/api/?name=${user.displayName || 'User'}&background=8b5cf6&color=fff`; }}
              />
            ) : <span style={{ fontSize: "2.5rem" }}>👤</span>}
          </div>
          <div style={{ flex: 1, width: "100%" }}>
            <div style={{ fontSize: "0.7rem", fontWeight: 900, color: "#8b5cf6", textTransform: "uppercase", letterSpacing: "2px", marginBottom: "4px" }}>LEVEL {level}</div>
            <h1 style={{ fontSize: "1.7rem", fontWeight: 950, marginBottom: "8px", letterSpacing: "-0.5px" }}>{user?.displayName || "Learner"}</h1>
            
            <div style={{ background: "rgba(255,255,255,0.03)", padding: "16px", borderRadius: "16px", border: "1px solid rgba(255,255,255,0.05)" }}>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.8rem", fontWeight: 800, color: "#94a3b8", marginBottom: "8px" }}>
                <span>{xpInCurrentLevel} / {xpForNextLevel} XP</span>
                <span style={{ color: "#8b5cf6" }}>{levelPercentage}%</span>
              </div>
              <div style={{ height: "8px", background: "rgba(255,255,255,0.05)", borderRadius: "100px", overflow: "hidden" }}>
                <motion.div initial={{ width: 0 }} animate={{ width: `${levelPercentage}%` }} transition={{ duration: 1 }} style={{ height: "100%", background: "linear-gradient(90deg, #8b5cf6, #06b6d4)" }} />
              </div>
            </div>
          </div>
        </motion.div>

        {/* Stats Grid */}
        <div className="stats-grid">
          {stats.map((s, i) => (
            <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: i * 0.1 }} key={i} style={{ background: "rgba(255,255,255,0.03)", padding: "20px 10px", borderRadius: "20px", border: "1px solid rgba(255,255,255,0.05)", textAlign: "center" }}>
              <div style={{ fontSize: "1.5rem", marginBottom: "8px" }}>{s.icon}</div>
              <div style={{ fontSize: "1.2rem", fontWeight: 950, color: s.color }}>{s.value}</div>
              <div style={{ fontSize: "0.7rem", color: "#64748b", fontWeight: 800, textTransform: "uppercase" }}>{s.label}</div>
            </motion.div>
          ))}
        </div>

        <div className="profile-grid-main">
          {/* Main Content Area */}
          <div style={{ display: "flex", flexDirection: "column", gap: "40px" }}>
            
            {/* Roadmap Progress */}
            <section>
              <h2 style={{ fontSize: "1.3rem", fontWeight: 900, marginBottom: "20px", display: "flex", alignItems: "center", gap: "12px" }}>🗺️ Roadmap Progress</h2>
              <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
                {ROADMAP_LEVELS.map((lvl) => {
                  const progress = getLevelProgress(lvl.id);
                  return (
                    <div key={lvl.id} style={{ background: "rgba(255,255,255,0.02)", padding: "16px", borderRadius: "16px", border: "1px solid rgba(255,255,255,0.05)" }}>
                      <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "10px" }}>
                        <span style={{ fontSize: "1.1rem" }}>{lvl.icon}</span>
                        <div style={{ flex: 1, display: "flex", justifyContent: "space-between", fontSize: "0.85rem", fontWeight: 800 }}>
                          <span style={{ color: "#cbd5e1" }}>{lvl.name}</span>
                          <span style={{ color: progress === 100 ? "#4ade80" : "#8b5cf6" }}>{progress}%</span>
                        </div>
                      </div>
                      <div style={{ height: "4px", background: "rgba(255,255,255,0.03)", borderRadius: "100px", overflow: "hidden" }}>
                        <div style={{ width: `${progress}%`, height: "100%", background: progress === 100 ? "#4ade80" : "#8b5cf6" }} />
                      </div>
                      {progress === 100 && (
                        <div style={{ marginTop: "12px", textAlign: "right" }}>
                          <Link href={`/profile/certificate/${lvl.id}`} style={{ fontSize: "0.65rem", background: "#4ade8011", border: "1px solid #4ade8033", color: "#4ade80", padding: "4px 10px", borderRadius: "8px", textDecoration: "none", fontWeight: 800 }}>🎓 CERTIFICATE</Link>
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </section>

            {/* Badges */}
            <section>
              <h2 style={{ fontSize: "1.3rem", fontWeight: 900, marginBottom: "20px" }}>🏆 Achievements <span style={{ fontSize: "0.8rem", color: "#64748b", fontWeight: 500 }}>({unlockedBadges.length}/{BADGES.length})</span></h2>
              <div className="badges-grid">
                {BADGES.map((badge) => {
                    const isUnlocked = unlockedBadges.includes(badge.id);
                    return (
                        <div key={badge.id} style={{ opacity: isUnlocked ? 1 : 0.2, filter: isUnlocked ? "none" : "grayscale(1)", background: "rgba(255,255,255,0.02)", padding: "16px 8px", borderRadius: "16px", border: "1px solid rgba(255,255,255,0.05)", textAlign: "center" }}>
                            <div style={{ fontSize: "2rem", marginBottom: "4px" }}>{badge.emoji}</div>
                            <div style={{ fontSize: "0.65rem", fontWeight: 900 }}>{badge.title}</div>
                        </div>
                    );
                })}
              </div>
            </section>
          </div>

          {/* Sidebar Area (Leaderboard & Activity) */}
          <div style={{ display: "flex", flexDirection: "column", gap: "40px" }}>
            
            {/* Leaderboard */}
            <section>
              <h2 style={{ fontSize: "1.3rem", fontWeight: 900, marginBottom: "20px" }}>🔥 Top Learners</h2>
              <div style={{ background: "rgba(255,255,255,0.02)", borderRadius: "24px", padding: "16px", border: "1px solid rgba(255,255,255,0.05)" }}>
                {loadingLeaderboard ? <div style={{ textAlign: "center", padding: "20px", fontSize: "0.8rem", color: "#64748b" }}>Loading...</div> : leaderboard.slice(0, 5).map((u, i) => (
                  <div key={u.id} style={{ display: "flex", alignItems: "center", gap: "12px", padding: "12px", borderRadius: "12px", background: user?.uid === u.id ? "rgba(139,92,246,0.1)" : "transparent", marginBottom: "4px" }}>
                    <div style={{ fontSize: "0.9rem", fontWeight: 900, width: "24px", color: i < 3 ? "#fbbf24" : "#64748b" }}>#{i + 1}</div>
                    <img src={u.avatar || `https://ui-avatars.com/api/?name=${u.name}&background=8b5cf6&color=fff`} style={{ width: "32px", height: "32px", borderRadius: "50%" }} />
                    <div style={{ flex: 1, fontWeight: 700, fontSize: "0.9rem", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{u.name}</div>
                    <div style={{ fontWeight: 900, color: "#8b5cf6", fontSize: "0.85rem" }}>{u.xp} XP</div>
                  </div>
                ))}
              </div>
            </section>

            {/* Recent Activity */}
            <section>
              <h2 style={{ fontSize: "1.3rem", fontWeight: 900, marginBottom: "20px" }}>✨ Recent Activity</h2>
              <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                 {xpHistory && xpHistory.slice(0, 5).map((h, i) => (
                    <div key={i} style={{ padding: "12px", background: "rgba(255,255,255,0.02)", borderRadius: "12px", border: "1px solid rgba(255,255,255,0.05)", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        <div>
                            <div style={{ fontSize: "0.85rem", fontWeight: 800 }}>{h.reason}</div>
                            <div style={{ fontSize: "0.6rem", color: "#64748b" }}>{new Date(h.timestamp).toLocaleDateString()}</div>
                        </div>
                        <div style={{ fontWeight: 900, color: "#8b5cf6", fontSize: "0.85rem" }}>+{h.amount}</div>
                    </div>
                 ))}
              </div>
            </section>
          </div>
        </div>
      </div>
    </div>
  );
}
