
"use client";
import { topics } from "@/data/topics";
import { useState } from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import TopicCard from "@/components/TopicCard";
import { motion, AnimatePresence } from "framer-motion";

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
      <motion.section 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
        style={{ padding: "120px 24px 60px", textAlign: "center", position: "relative", overflow: "hidden" }}
      >
        <div style={{ position: "absolute", top: -100, left: "50%", transform: "translateX(-50%)", width: "80%", height: 300, background: "radial-gradient(circle, rgba(139,92,246,0.15) 0%, transparent 70%)", filter: "blur(60px)", pointerEvents: "none" }} />

        <div style={{ position: "relative", zIndex: 1 }}>
          <motion.h1 
            initial={{ scale: 0.9 }}
            animate={{ scale: 1 }}
            transition={{ duration: 0.5 }}
            style={{ fontSize: "clamp(2.5rem, 8vw, 4.5rem)", fontWeight: 900, letterSpacing: "-3px", marginBottom: "16px" }}
          >
            Techaa <span className="animate-float" style={{ display: "inline-block", background: "linear-gradient(135deg, #8b5cf6, #06b6d4)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>Purinjikoo</span>
          </motion.h1>
          <motion.p 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            style={{ color: "#94a3b8", fontSize: "1.1rem", maxWidth: "600px", margin: "0 auto 32px" }}
          >
            Beginner-la irundhu Pro-ah aaga structured roadmap. Tech-ah friend solra maari purinjikalam! ☕
            <br /><span style={{ fontSize: "0.85rem", color: "#8b5cf6", fontWeight: 600 }}>✨ Topics free-ah read pannalam, progress save panna login pannunga!</span>
          </motion.p>

          <div style={{ display: "flex", gap: "12px", justifyContent: "center", flexWrap: "wrap" }}>
            {!user ? (
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={loginWithGoogle}
                style={{ background: "#8b5cf6", color: "#fff", padding: "12px 28px", borderRadius: "12px", border: "none", fontWeight: 700, cursor: "pointer", boxShadow: "0 10px 20px rgba(139,92,246,0.3)" }}
              >
                Login with Google to Track Progress 🚀
              </motion.button>
            ) : (
              <motion.div whileHover={{ scale: 1.05 }}>
                <Link href="/profile" style={{ display: "inline-block", background: "#8b5cf6", color: "#fff", padding: "12px 28px", borderRadius: "12px", fontWeight: 700, textDecoration: "none", boxShadow: "0 10px 20px rgba(139,92,246,0.3)" }}>Check My Progress 🏆</Link>
              </motion.div>
            )}
            <motion.div whileHover={{ scale: 1.05 }}>
              <Link href="#roadmap" style={{ display: "inline-block", background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", color: "#fff", padding: "12px 28px", borderRadius: "12px", fontWeight: 700, textDecoration: "none" }}>Explore Topics 📖</Link>
            </motion.div>
          </div>
        </div>
      </motion.section>

      {/* Beginner Confusion Section */}
      <motion.section 
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true }}
        style={{ maxWidth: "1000px", margin: "0 auto 80px", padding: "0 24px" }}
      >
        <div style={{ background: "rgba(139,92,246,0.05)", border: "1px solid rgba(139,92,246,0.15)", borderRadius: "24px", padding: "32px" }}>
          <h3 style={{ fontSize: "1.4rem", fontWeight: 800, marginBottom: "20px", textAlign: "center" }}>🤯 Enna Confusion? Check pannu!</h3>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))", gap: "16px" }}>
            {CONFUSIONS.map((c, i) => (
              <motion.div 
                key={i} 
                whileHover={{ y: -5, background: "rgba(139,92,246,0.1)" }}
                style={{ background: "rgba(0,0,0,0.2)", border: "1px solid rgba(255,255,255,0.05)", borderRadius: "16px", padding: "20px", textAlign: "center", transition: "background 0.3s ease" }}
              >
                <div style={{ fontSize: "1.5rem", marginBottom: "8px" }}>{c.emoji}</div>
                <div style={{ fontWeight: 700, fontSize: "1rem", marginBottom: "12px" }}>{c.p1} vs {c.p2}</div>
                <Link href={c.link} style={{ fontSize: "0.85rem", color: "#8b5cf6", textDecoration: "none", fontWeight: 600 }}>Difference Paaru →</Link>
              </motion.div>
            ))}
          </div>
        </div>
      </motion.section>

      {/* Roadmap Section */}
      <section id="roadmap" style={{ maxWidth: "1100px", margin: "0 auto 100px", padding: "0 24px" }}>
        <motion.h2 
          initial={{ opacity: 0, x: -20 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          style={{ fontSize: "2rem", fontWeight: 900, textAlign: "center", marginBottom: "40px" }}
        >
          🗺️ Tech Learning Roadmap
        </motion.h2>

        <div style={{ display: "flex", gap: "12px", overflowX: "auto", paddingTop: "10px", paddingBottom: "20px", marginBottom: "40px", scrollbarWidth: "none" }} className="no-scrollbar">
          {ROADMAP_LEVEL_DATA().map((lvl) => {
            const progress = getLevelProgress(lvl.id);
            return (
              <motion.button
                key={lvl.id}
                whileHover={{ y: -5 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setActiveLevel(lvl.id)}
                style={{
                  flexShrink: 0,
                  background: activeLevel === lvl.id ? "#8b5cf6" : "rgba(255,255,255,0.03)",
                  border: activeLevel === lvl.id ? "1px solid rgba(255,255,255,0.3)" : "1px solid rgba(255,255,255,0.1)",
                  padding: "16px 24px",
                  borderRadius: "20px",
                  color: "#fff",
                  cursor: "pointer",
                  textAlign: "left",
                  minWidth: "200px",
                  transition: "all 0.3s ease",
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
                  <motion.div 
                    initial={{ width: 0 }}
                    animate={{ width: `${progress}%` }}
                    style={{ height: "100%", background: progress === 100 ? "#4ade80" : (activeLevel === lvl.id ? "#fff" : "#8b5cf6") }} 
                  />
                </div>
              </motion.button>
            );
          })}
        </div>

        <motion.div 
          key={activeLevel}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          style={{ minHeight: "400px" }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "32px" }}>
            <span style={{ fontSize: "2rem" }}>{ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.icon}</span>
            <div>
              <h3 style={{ fontSize: "1.5rem", fontWeight: 800 }}>{ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.name}</h3>
              <p style={{ color: "#94a3b8", fontSize: "0.95rem" }}>{ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.desc}</p>
            </div>
          </div>

          <motion.div 
            layout
            style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(320px, 1fr))", gap: "20px" }}
          >
            <AnimatePresence mode="popLayout">
              {filteredTopics.map((topic, index) => (
                <motion.div
                  key={topic.id}
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.9 }}
                  transition={{ delay: index * 0.05 }}
                >
                  <TopicCard topic={topic} index={index} />
                </motion.div>
              ))}
            </AnimatePresence>
            {filteredTopics.length === 0 && (
              <div style={{ gridColumn: "1/-1", textAlign: "center", padding: "60px", background: "rgba(255,255,255,0.02)", borderRadius: "24px", border: "1px dashed rgba(255,255,255,0.1)" }}>
                <p style={{ color: "#94a3b8" }}>Intha level-ku innum topics add panla bro. Oru 5 mins wait pannu, load aanalum aagum! 😅</p>
              </div>
            )}
          </motion.div>
        </motion.div>
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
