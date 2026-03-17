
"use client";
import { useUserProgress } from "@/context/UserProgressContext";
import Navbar from "@/components/Navbar";
import { topics } from "@/data/topics";
import Link from "next/link";
import { useState, useEffect } from "react";
import { useAuth } from "@/context/AuthContext";
import { motion } from "framer-motion";

export default function ProfilePage() {
  const { xp, level, streak, completedTopics, unlockedBadges, XP_LEVELS, BADGES, getLevelProgress, loading, xpHistory, resetProgress, avatarStyle, updateAvatarStyle } = useUserProgress();
  const { user } = useAuth();

  const AVATAR_SHOP = {
    borders: [
      { id: "plain", label: "Default", level: 1, style: { border: "4px solid #070711" } },
      { id: "neon", label: "Neon Purple", level: 5, style: { border: "4px solid #8b5cf6", boxShadow: "0 0 15px #8b5cf6" } },
      { id: "glow", label: "Cyan Glow", level: 10, style: { border: "4px solid #06b6d4", boxShadow: "0 0 20px #06b6d4" } },
      { id: "gold", label: "Royal Gold", level: 15, style: { border: "4px solid #fbbf24", boxShadow: "0 0 25px #fbbf24" } },
    ],
    emojis: [
      { id: "none", label: "None", level: 1, emoji: "" },
      { id: "verified", label: "Verified", level: 3, emoji: "✅" },
      { id: "pro", label: "Pro Learner", level: 8, emoji: "🛡️" },
      { id: "fire", label: "On Fire", level: 12, emoji: "🔥" },
      { id: "crown", label: "King/Queen", level: 20, emoji: "👑" },
    ]
  };

  const [leaderboard, setLeaderboard] = useState([]);
  const [loadingLeaderboard, setLoadingLeaderboard] = useState(true);

  useEffect(() => {
    const fetchLeaderboard = async () => {
      try {
        const { collection, getDocs, limit, query, orderBy } = await import('firebase/firestore');
        const { db } = await import('@/lib/firebase');
        
        // Use a proper query if possible, but fallback to manual if rules are tricky
        const q = query(collection(db, "users"), limit(50));
        const querySnapshot = await getDocs(q);
        
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

        // Always ensure the current user is visible for them, even if not in the top 50 yet
        if (user && !users.find(u => u.id === user.uid)) {
          users.push({
            id: user.uid,
            name: user.displayName || "Me",
            avatar: user.photoURL,
            xp: xp
          });
        }

        const sorted = users.sort((a, b) => b.xp - a.xp);
        setLeaderboard(sorted.slice(0, 20));
      } catch (err) {
        console.error("Leaderboard error:", err);
        // Fallback to just showing the current user if fetch fails (permissions)
        if (user) {
          setLeaderboard([{
            id: user.uid,
            name: user.displayName || "Me",
            avatar: user.photoURL,
            xp: xp
          }]);
        }
      } finally {
        setLoadingLeaderboard(false);
      }
    };
    if (!loading && user) fetchLeaderboard();
  }, [loading, user, xp]);

  const handleReset = async () => {
    if (confirm("Nijamave account reset panna poringala bro? Unnoda XP, Badges, topics progress ellam delete aayidum! ⚠️")) {
      await resetProgress();
      window.location.reload();
    }
  };

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

      <div style={{ maxWidth: "1000px", margin: "0 auto", padding: "80px 16px 60px" }}>
        
        {/* Back Button */}
        <motion.div initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }}>
          <Link href="/" style={{ display: "inline-flex", alignItems: "center", gap: "8px", color: "#64748b", textDecoration: "none", fontSize: "0.85rem", fontWeight: 700, marginBottom: "24px", padding: "8px 16px", background: "rgba(255,255,255,0.03)", border: "1px solid rgba(255,255,255,0.06)", borderRadius: "12px", transition: "0.2s" }}>
            <span>←</span> Home
          </Link>
        </motion.div>

        <style>{`
          .profile-grid-main { display: grid; grid-template-columns: 1fr; gap: 32px; }
          @media (min-width: 900px) { .profile-grid-main { grid-template-columns: 1.5fr 1fr; } }
          
          .stats-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; margin-bottom: 32px; }
          @media (min-width: 600px) { .stats-grid { grid-template-columns: repeat(4, 1fr); gap: 16px; } }

          .badges-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 12px; }
          @media (min-width: 600px) { .badges-grid { grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); } }
          
          .profile-header { display: flex; flex-direction: column; align-items: center; text-align: center; gap: 20px; background: rgba(255,255,255,0.02); padding: 32px 20px; borderRadius: 32px; border: 1px solid rgba(255,255,255,0.05); margin-bottom: 32px; position: relative; }
          @media (min-width: 600px) { .profile-header { flex-direction: row; text-align: left; padding: 40px; } }
          
          .reset-btn { position: absolute; top: 20px; right: 20px; background: rgba(255,75,75,0.05); border: 1px solid rgba(255,75,75,0.1); color: #ff4b4b; padding: 6px 14px; borderRadius: 100px; fontSize: "0.65rem"; fontWeight: 800; cursor: pointer; transition: 0.2s; z-index: 10; }
          .reset-btn:hover { background: rgba(255,75,75,0.15); scale: 1.05; }

          .shop-item { cursor: pointer; transition: 0.2s; position: relative; overflow: hidden; }
          .shop-item.locked { cursor: not-allowed; opacity: 0.5; }
          .shop-item.selected { border: 2px solid #8b5cf6 !important; background: rgba(139,92,246,0.1) !important; }
        `}</style>

        {/* Profile Header */}
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="profile-header">
          {/* Reset Button */}
          <button onClick={handleReset} className="reset-btn">Reset Panriya Bro 🧹</button>

          <div style={{ position: "relative", flexShrink: 0 }}>
            <div style={{ 
              width: "100px", height: "100px", borderRadius: "50%", 
              background: "linear-gradient(135deg, #8b5cf6, #06b6d4)", 
              display: "flex", alignItems: "center", justifyContent: "center", fontSize: "3rem", 
              overflow: "hidden", border: "4px solid #070711", 
              ...(AVATAR_SHOP.borders.find(b => b.id === avatarStyle?.border)?.style || {})
            }}>
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
            {avatarStyle?.emoji && avatarStyle.emoji !== "none" && (
              <div style={{ position: "absolute", bottom: -5, right: -5, background: "#070711", width: "32px", height: "32px", borderRadius: "50%", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "1.2rem", border: "2px solid rgba(255,255,255,0.1)" }}>
                {AVATAR_SHOP.emojis.find(e => e.id === avatarStyle.emoji)?.emoji}
              </div>
            )}
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
          <div style={{ display: "flex", flexDirection: "column", gap: "40px" }}>
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

            <section>
              <h2 style={{ fontSize: "1.3rem", fontWeight: 900, marginBottom: "20px", display: "flex", alignItems: "center", gap: "10px" }}>🎨 Customization Shop</h2>
              <div style={{ background: "rgba(255,255,255,0.02)", borderRadius: "24px", padding: "20px", border: "1px solid rgba(255,255,255,0.05)" }}>
                <p style={{ fontSize: "0.8rem", color: "#64748b", marginBottom: "16px", fontWeight: 700 }}>Borders (Unlock patterns as you level up!)</p>
                <div style={{ display: "grid", gridTemplateColumns: "repeat(2, 1fr)", gap: "8px", marginBottom: "24px" }}>
                  {AVATAR_SHOP.borders.map(b => {
                    const isLocked = level < b.level;
                    const isSelected = avatarStyle?.border === b.id;
                    return (
                      <div 
                        key={b.id} 
                        onClick={() => !isLocked && updateAvatarStyle({ border: b.id })}
                        className={`shop-item ${isLocked ? 'locked' : ''} ${isSelected ? 'selected' : ''}`}
                        style={{ padding: "12px", background: "rgba(255,255,255,0.03)", borderRadius: "12px", border: "1px solid rgba(255,255,255,0.05)", textAlign: "center" }}
                      >
                        <div style={{ fontSize: "0.85rem", fontWeight: 800 }}>{b.label}</div>
                        <div style={{ fontSize: "0.65rem", color: isLocked ? "#f87171" : "#8b5cf6" }}>{isLocked ? `LVL ${b.level} 🔒` : 'Unlocked ✨'}</div>
                      </div>
                    );
                  })}
                </div>

                <p style={{ fontSize: "0.8rem", color: "#64748b", marginBottom: "16px", fontWeight: 700 }}>Exclusive Emojis</p>
                <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(80px, 1fr))", gap: "8px" }}>
                  {AVATAR_SHOP.emojis.map(e => {
                    const isLocked = level < e.level;
                    const isSelected = avatarStyle?.emoji === e.id;
                    return (
                      <div 
                        key={e.id} 
                        onClick={() => !isLocked && updateAvatarStyle({ emoji: e.id })}
                        className={`shop-item ${isLocked ? 'locked' : ''} ${isSelected ? 'selected' : ''}`}
                        style={{ padding: "10px", background: "rgba(255,255,255,0.03)", borderRadius: "12px", border: "1px solid rgba(255,255,255,0.05)", textAlign: "center" }}
                      >
                        <div style={{ fontSize: "1.2rem", marginBottom: "4px" }}>{e.emoji || '❌'}</div>
                        <div style={{ fontSize: "0.6rem", color: isLocked ? "#f87171" : "#8b5cf6", fontWeight: 800 }}>{isLocked ? `L${e.level}` : 'Use'}</div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </section>

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

          <div style={{ display: "flex", flexDirection: "column", gap: "40px" }}>
            <section>
              <h2 style={{ fontSize: "1.3rem", fontWeight: 900, marginBottom: "20px" }}>🔥 Top Learners</h2>
              <div style={{ background: "rgba(255,255,255,0.02)", borderRadius: "24px", padding: "16px", border: "1px solid rgba(255,255,255,0.05)" }}>
                {loadingLeaderboard ? (
                  <div style={{ textAlign: "center", padding: "20px", fontSize: "0.8rem", color: "#64748b" }}>Loading learners...</div>
                ) : leaderboard.length === 0 ? (
                  <div style={{ textAlign: "center", padding: "20px", fontSize: "0.8rem", color: "#64748b" }}>
                    No other learners yet. Share the app to start the competition! 🚀
                  </div>
                ) : (
                  leaderboard.slice(0, 5).map((u, i) => (
                    <div key={u.id} style={{ display: "flex", alignItems: "center", gap: "12px", padding: "12px", borderRadius: "12px", background: user?.uid === u.id ? "rgba(139,92,246,0.1)" : "transparent", marginBottom: "4px", border: user?.uid === u.id ? "1px solid rgba(139,92,246,0.2)" : "1px solid transparent" }}>
                      <div style={{ fontSize: "0.9rem", fontWeight: 900, width: "24px", color: i < 3 ? "#fbbf24" : "#64748b" }}>#{i + 1}</div>
                      <img 
                        src={u.avatar || `https://ui-avatars.com/api/?name=${u.name}&background=8b5cf6&color=fff`} 
                        style={{ width: "32px", height: "32px", borderRadius: "50%", border: "2px solid rgba(255,255,255,0.05)" }} 
                        referrerPolicy="no-referrer"
                        onError={(e) => { e.target.src = `https://ui-avatars.com/api/?name=${u.name || 'User'}&background=8b5cf6&color=fff`; }}
                      />
                      <div style={{ flex: 1, fontWeight: 700, fontSize: "0.9rem", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{u.id === user?.uid ? "You (Nee thaan!)" : u.name}</div>
                      <div style={{ fontWeight: 900, color: "#8b5cf6", fontSize: "0.85rem" }}>{u.xp} XP</div>
                    </div>
                  ))
                )}
              </div>
            </section>

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
