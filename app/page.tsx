"use client";
import { topics } from "@/data/topics";
import { useState } from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import TopicCard from "@/components/TopicCard";

const ROADMAP_LEVELS = [
  { id: 1, name: "Internet Basics", icon: "🌐", topics: "1-15", desc: "Digital world-oda base-ah purinjiko." },
  { id: 2, name: "Web Development", icon: "💻", topics: "16-30", desc: "App build panna enna venum?" },
  { id: 3, name: "Databases", icon: "🗄️", topics: "31-45", desc: "Data storage magic." },
  { id: 4, name: "Cloud & Deploy", icon: "☁️", topics: "46-60", desc: "Go live on internet." },
  { id: 5, name: "Dev Tools", icon: "🧑‍💻", topics: "61-75", desc: "Pro developer-ah maaru." },
  { id: 6, name: "Security", icon: "🔐", topics: "76-85", desc: "Safe ah irukkalam." },
  { id: 7, name: "AI & Modern Tech", icon: "🤖", topics: "86-100", desc: "Future is here." },
];

const CONFUSIONS = [
  { p1: "Frontend", p2: "Backend", emoji: "🎨 vs ⚙️", link: "/topics/frontend-vs-backend" },
  { p1: "Library", p2: "Framework", emoji: "🛠️ vs 🏗️", link: "/topics/library-vs-framework" },
  { p1: "Domain", p2: "Hosting", emoji: "📛 vs 🏗️", link: "/topics/domain-vs-hosting" },
];

import { useUserProgress } from "@/context/UserProgressContext";
import { useAuth } from "@/context/AuthContext";

export default function Home() {
  const [activeLevel, setActiveLevel] = useState(1);
  const { getLevelProgress } = useUserProgress();
  const { user, loginWithGoogle } = useAuth();

  const filteredTopics = topics.filter(t => t.level === activeLevel || (!t.level && activeLevel === 1));

  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff" }}>

      {/* Hero Section */}
      <section style={{ padding: "120px 24px 60px", textAlign: "center", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", top: -100, left: "50%", transform: "translateX(-50%)", width: "80%", height: 300, background: "radial-gradient(circle, rgba(139,92,246,0.15) 0%, transparent 70%)", filter: "blur(60px)", pointerEvents: "none" }} />

        <div style={{ position: "relative", zIndex: 1 }}>
          <h1 style={{ fontSize: "clamp(2.5rem, 8vw, 4.5rem)", fontWeight: 900, letterSpacing: "-3px", marginBottom: "16px" }}>
            Techaa <span style={{ background: "linear-gradient(135deg, #8b5cf6, #06b6d4)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>Purinjikoo</span>
          </h1>
          <p style={{ color: "#94a3b8", fontSize: "1.1rem", maxWidth: "600px", margin: "0 auto 32px" }}>
            Beginner-la irundhu Pro-ah aaga structured roadmap. Tech-ah friend solra maari purinjikalam! ☕
            <br /><span style={{ fontSize: "0.85rem", color: "#8b5cf6", fontWeight: 600 }}>✨ Topics free-ah read pannalam, progress save panna login pannunga!</span>
          </p>

          <div style={{ display: "flex", gap: "12px", justifyContent: "center", flexWrap: "wrap" }}>
            {!user ? (
              <button
                onClick={loginWithGoogle}
                style={{ background: "#8b5cf6", color: "#fff", padding: "12px 28px", borderRadius: "12px", border: "none", fontWeight: 700, cursor: "pointer", boxShadow: "0 10px 20px rgba(139,92,246,0.3)" }}
              >
                Login with Google to Track Progress 🚀
              </button>
            ) : (
              <Link href="/profile" style={{ background: "#8b5cf6", color: "#fff", padding: "12px 28px", borderRadius: "12px", fontWeight: 700, textDecoration: "none", boxShadow: "0 10px 20px rgba(139,92,246,0.3)" }}>Check My Progress 🏆</Link>
            )}
            <Link href="#roadmap" style={{ background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", color: "#fff", padding: "12px 28px", borderRadius: "12px", fontWeight: 700, textDecoration: "none" }}>Explore Topics 📖</Link>
          </div>
        </div>
      </section>

      {/* Beginner Confusion Section */}
      <section style={{ maxWidth: "1000px", margin: "0 auto 80px", padding: "0 24px" }}>
        <div style={{ background: "rgba(139,92,246,0.05)", border: "1px solid rgba(139,92,246,0.15)", borderRadius: "24px", padding: "32px" }}>
          <h3 style={{ fontSize: "1.4rem", fontWeight: 800, marginBottom: "20px", textAlign: "center" }}>🤯 Enna Confusion? Check pannu!</h3>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))", gap: "16px" }}>
            {CONFUSIONS.map((c, i) => (
              <div key={i} style={{ background: "rgba(0,0,0,0.2)", border: "1px solid rgba(255,255,255,0.05)", borderRadius: "16px", padding: "20px", textAlign: "center" }}>
                <div style={{ fontSize: "1.5rem", marginBottom: "8px" }}>{c.emoji}</div>
                <div style={{ fontWeight: 700, fontSize: "1rem", marginBottom: "12px" }}>{c.p1} vs {c.p2}</div>
                <Link href={c.link} style={{ fontSize: "0.85rem", color: "#8b5cf6", textDecoration: "none", fontWeight: 600 }}>Difference Paaru →</Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Roadmap Section */}
      <section id="roadmap" style={{ maxWidth: "1100px", margin: "0 auto 100px", padding: "0 24px" }}>
        <h2 style={{ fontSize: "2rem", fontWeight: 900, textAlign: "center", marginBottom: "40px" }}>🗺️ Tech Learning Roadmap</h2>

        <div style={{ display: "flex", gap: "12px", overflowX: "auto", paddingBottom: "20px", marginBottom: "40px", scrollbarWidth: "none" }} className="no-scrollbar">
          {ROADMAP_LEVEL_DATA().map((lvl) => {
            const progress = getLevelProgress(lvl.id);
            return (
              <button
                key={lvl.id}
                onClick={() => setActiveLevel(lvl.id)}
                style={{
                  flexShrink: 0,
                  background: activeLevel === lvl.id ? "#8b5cf6" : "rgba(255,255,255,0.03)",
                  border: "1px solid rgba(255,255,255,0.1)",
                  padding: "16px 24px",
                  borderRadius: "20px",
                  color: "#fff",
                  cursor: "pointer",
                  textAlign: "left",
                  minWidth: "200px",
                  transition: "all 0.3s ease",
                  transform: activeLevel === lvl.id ? "translateY(-5px)" : "none",
                  boxShadow: activeLevel === lvl.id ? "0 10px 20px rgba(139,92,246,0.3)" : "none",
                  position: "relative",
                  overflow: "hidden"
                }}
              >
                <div style={{ fontSize: "1.5rem", marginBottom: "8px" }}>{lvl.icon}</div>
                <div style={{ fontSize: "0.75rem", color: activeLevel === lvl.id ? "rgba(255,255,255,0.8)" : "#94a3b8", fontWeight: 600 }}>LEVEL {lvl.id}</div>
                <div style={{ fontWeight: 800, fontSize: "1rem", marginBottom: "12px" }}>{lvl.name}</div>

                {/* Mini progress bar */}
                <div style={{ height: "4px", background: activeLevel === lvl.id ? "rgba(255,255,255,0.2)" : "rgba(255,255,255,0.05)", borderRadius: "100px", marginTop: "auto" }}>
                  <div style={{ width: `${progress}%`, height: "100%", background: progress === 100 ? "#4ade80" : (activeLevel === lvl.id ? "#fff" : "#8b5cf6"), transition: "width 0.5s ease" }} />
                </div>
              </button>
            );
          })}
        </div>

        <div style={{ minHeight: "400px" }}>
          <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "32px" }}>
            <span style={{ fontSize: "2rem" }}>{ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.icon}</span>
            <div>
              <h3 style={{ fontSize: "1.5rem", fontWeight: 800 }}>{ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.name}</h3>
              <p style={{ color: "#94a3b8", fontSize: "0.95rem" }}>{ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.desc}</p>
            </div>
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(320px, 1fr))", gap: "20px" }}>
            {filteredTopics.map((topic, index) => (
              <TopicCard key={topic.id} topic={topic} index={index} />
            ))}
            {filteredTopics.length === 0 && (
              <div style={{ gridColumn: "1/-1", textAlign: "center", padding: "60px", background: "rgba(255,255,255,0.02)", borderRadius: "24px", border: "1px dashed rgba(255,255,255,0.1)" }}>
                <p style={{ color: "#94a3b8" }}>Intha level-ku innum topics add panla bro. Oru 5 mins wait pannu, load aanalum aagum! 😅</p>
              </div>
            )}
          </div>
        </div>
      </section>

    </div>
  );
}

function ROADMAP_LEVEL_DATA() {
  return [
    { id: 1, name: "Internet Basics", icon: "🌐", desc: "Internet network basics, browsers, and URLs." },
    { id: 2, name: "Web Development", icon: "💻", desc: "Building UI, backend logic, and APIs." },
    { id: 3, name: "Databases", icon: "🗄️", desc: "SQL vs NoSQL, storage concepts." },
    { id: 4, name: "Cloud & Deploy", icon: "☁️", desc: "Vercel, Render, and cloud platforms." },
    { id: 5, name: "Dev Tools", icon: "🧑‍💻", desc: "Git, GitHub, and workspace tools." },
    { id: 6, name: "Security", icon: "🔐", desc: "Auth, Encryption, and safe coding." },
    { id: 7, name: "AI & Modern Tech", icon: "🤖", desc: "ChatGPT, LLMs, and prompt engineering." },
  ];
}
