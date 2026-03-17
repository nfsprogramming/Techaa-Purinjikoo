
"use client";
import { useUserProgress } from "@/context/UserProgressContext";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { topics } from "@/data/topics";
import Link from "next/link";

export default function ProfilePage() {
  const { xp, level, streak, completedTopics, unlockedBadges, XP_LEVELS, BADGES, getLevelProgress } = useUserProgress();

  const nextLevel = XP_LEVELS.find(l => l.level === level + 1);
  const currentLevel = XP_LEVELS.find(l => l.level === level);
  const xpInCurrentLevel = xp - (currentLevel?.minXP || 0);
  const xpForNextLevel = (nextLevel?.minXP || xp) - (currentLevel?.minXP || 0);
  const levelPercentage = Math.min(100, Math.round((xpInCurrentLevel / (xpForNextLevel || 1)) * 100));

  const stats = [
    { label: "Topics Learned", value: completedTopics.length, icon: "📚", color: "#8b5cf6" },
    { label: "Current Streak", value: `${streak} Days`, icon: "🔥", color: "#f59e0b" },
    { label: "Total XP", value: xp, icon: "✨", color: "#06b6d4" },
    { label: "Badges Earned", value: unlockedBadges.length, icon: "🏆", color: "#10b981" },
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

      <div style={{ maxWidth: "1000px", margin: "0 auto", padding: "100px 24px 60px" }}>
        {/* Profile Header */}
        <div style={{ display: "flex", flexWrap: "wrap", gap: "32px", alignItems: "center", marginBottom: "48px", background: "rgba(255,255,255,0.02)", padding: "40px", borderRadius: "32px", border: "1px solid rgba(255,255,255,0.05)" }}>
          <div style={{ width: "100px", height: "100px", borderRadius: "50%", background: "linear-gradient(135deg, #8b5cf6, #06b6d4)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "3rem", boxShadow: "0 0 30px rgba(139,92,246,0.3)" }}>
            ☕
          </div>
          <div style={{ flex: 1, minWidth: "250px" }}>
            <div style={{ fontSize: "0.85rem", fontWeight: 800, color: "#8b5cf6", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "4px" }}>LEVEL {level}</div>
            <h1 style={{ fontSize: "2.5rem", fontWeight: 900, marginBottom: "8px" }}>{currentLevel?.name || "Beginner"}</h1>
            
            {/* XP Bar */}
            <div style={{ marginTop: "16px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.85rem", color: "#94a3b8", marginBottom: "8px" }}>
                <span>{xpInCurrentLevel} / {xpForNextLevel} XP to next level</span>
                <span>{levelPercentage}%</span>
              </div>
              <div style={{ height: "10px", background: "rgba(255,255,255,0.05)", borderRadius: "100px", overflow: "hidden" }}>
                <div style={{ width: `${levelPercentage}%`, height: "100%", background: "linear-gradient(90deg, #8b5cf6, #06b6d4)", transition: "width 0.5s ease" }} />
              </div>
            </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: "20px", marginBottom: "48px" }}>
          {stats.map((s, i) => (
            <div key={i} style={{ background: "rgba(255,255,255,0.03)", padding: "24px", borderRadius: "24px", border: "1px solid rgba(255,255,255,0.05)", textAlign: "center" }}>
              <div style={{ fontSize: "2rem", marginBottom: "12px" }}>{s.icon}</div>
              <div style={{ fontSize: "1.5rem", fontWeight: 900, color: s.color }}>{s.value}</div>
              <div style={{ fontSize: "0.85rem", color: "#94a3b8", fontWeight: 600 }}>{s.label}</div>
            </div>
          ))}
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(400px, 1fr))", gap: "32px" }}>
          {/* Badges Section */}
          <section>
            <h2 style={{ fontSize: "1.5rem", fontWeight: 800, marginBottom: "24px", display: "flex", alignItems: "center", gap: "12px" }}>
              🏆 Achievements
              <span style={{ fontSize: "0.9rem", color: "#94a3b8", fontWeight: 500 }}>({unlockedBadges.length} unlocked)</span>
            </h2>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(140px, 1fr))", gap: "16px" }}>
              {BADGES.map((badge) => {
                const isUnlocked = unlockedBadges.includes(badge.id);
                return (
                  <div 
                    key={badge.id} 
                    title={badge.desc}
                    style={{ 
                      background: isUnlocked ? "rgba(139,92,246,0.1)" : "rgba(255,255,255,0.02)", 
                      border: "1px solid", 
                      borderColor: isUnlocked ? "rgba(139,92,246,0.3)" : "rgba(255,255,255,0.05)",
                      padding: "20px 12px", 
                      borderRadius: "20px", 
                      textAlign: "center",
                      opacity: isUnlocked ? 1 : 0.4,
                      filter: isUnlocked ? "none" : "grayscale(100%)",
                      transition: "0.3s"
                    }}
                  >
                    <div style={{ fontSize: "2.5rem", marginBottom: "8px" }}>{badge.emoji}</div>
                    <div style={{ fontSize: "0.8rem", fontWeight: 800, color: isUnlocked ? "#fff" : "#94a3b8" }}>{badge.title}</div>
                  </div>
                );
              })}
            </div>
          </section>

          {/* Roadmap Progress Section */}
          <section>
            <h2 style={{ fontSize: "1.5rem", fontWeight: 800, marginBottom: "24px", display: "flex", alignItems: "center", gap: "12px" }}>
              🗺️ Roadmap Progress
            </h2>
            <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
              {ROADMAP_LEVELS.map((lvl) => {
                const progress = getLevelProgress(lvl.id);
                return (
                  <div key={lvl.id} style={{ background: "rgba(255,255,255,0.03)", padding: "20px", borderRadius: "16px", border: "1px solid rgba(255,255,255,0.05)" }}>
                    <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "12px" }}>
                      <span style={{ fontSize: "1.2rem" }}>{lvl.icon}</span>
                      <div style={{ flex: 1 }}>
                        <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.9rem", fontWeight: 700 }}>
                          <span>{lvl.name}</span>
                          <span style={{ color: progress === 100 ? "#4ade80" : "#8b5cf6" }}>{progress}%</span>
                        </div>
                      </div>
                    </div>
                    <div style={{ height: "6px", background: "rgba(255,255,255,0.05)", borderRadius: "100px", overflow: "hidden" }}>
                      <div style={{ width: `${progress}%`, height: "100%", background: progress === 100 ? "#4ade80" : "#8b5cf6", transition: "width 0.5s ease" }} />
                    </div>
                    {progress === 100 && (
                      <div style={{ marginTop: "12px", textAlign: "right" }}>
                        <Link href={`/profile/certificate/${lvl.id}`} style={{ fontSize: "0.75rem", background: "#4ade8022", color: "#4ade80", padding: "4px 8px", borderRadius: "6px", textDecoration: "none", fontWeight: 700 }}>🎓 Get Certificate</Link>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </section>
        </div>

        {/* Mock Leaderboard */}
        <section style={{ marginTop: "60px" }}>
          <h2 style={{ fontSize: "1.5rem", fontWeight: 800, marginBottom: "24px", display: "flex", alignItems: "center", gap: "12px" }}>
            🏆 Top Learners This Week
          </h2>
          <div style={{ background: "rgba(255,255,255,0.02)", borderRadius: "24px", padding: "24px", border: "1px solid rgba(255,255,255,0.05)" }}>
            {[
              { name: "Arun", xp: 1250, avatar: "🔥", current: false },
              { name: "Sarah", xp: 1120, avatar: "⚡", current: false },
              { name: "You", xp: xp, avatar: "☕", current: true },
              { name: "Raj", xp: 950, avatar: "🚀", current: false },
              { name: "Priya", xp: 820, avatar: "💻", current: false },
            ].sort((a, b) => b.xp - a.xp).map((user, i) => (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: "16px", padding: "16px", background: user.current ? "rgba(139,92,246,0.15)" : "transparent", borderRadius: "16px", border: user.current ? "1px solid #8b5cf6" : "1px solid transparent", marginBottom: "8px" }}>
                <div style={{ fontSize: "1.2rem", fontWeight: 900, width: "30px", color: i < 3 ? "#f59e0b" : "#94a3b8" }}>#{i + 1}</div>
                <div style={{ width: "40px", height: "40px", borderRadius: "50%", background: "rgba(255,255,255,0.05)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "1.2rem" }}>{user.avatar}</div>
                <div style={{ flex: 1, fontWeight: 700, fontSize: "1.1rem" }}>{user.name} {user.current && <span style={{ fontSize: "0.6rem", background: "#8b5cf6", padding: "2px 6px", borderRadius: "100px", marginLeft: "8px" }}>YOU</span>}</div>
                <div style={{ fontWeight: 800, color: "#8b5cf6" }}>{user.xp} <span style={{ fontSize: "0.7rem", color: "#94a3b8" }}>XP</span></div>
              </div>
            ))}
          </div>
        </section>
      </div>

    </div>
  );
}
