
"use client";
import React, { useRef } from "react";
import { topics } from "@/data/topics";
import { useState } from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import TopicCard from "@/components/TopicCard";
import { motion, AnimatePresence, useScroll, useTransform } from "framer-motion";
import { useUserProgress } from "@/context/UserProgressContext";
import { useAuth } from "@/context/AuthContext";

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1
    }
  }
};

const itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: { y: 0, opacity: 1 }
};

export default function Home() {
  const [activeLevel, setActiveLevel] = useState(1);
  const { getLevelProgress } = useUserProgress();
  const { user, loginWithGoogle } = useAuth();
  
  const heroRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: heroRef,
    offset: ["start start", "end start"]
  });

  const heroY = useTransform(scrollYProgress, [0, 1], [0, 150]);
  const heroOpacity = useTransform(scrollYProgress, [0, 1], [1, 0]);

  const filteredTopics = topics.filter(t => t.level === activeLevel || (!t.level && activeLevel === 1));
  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff" }}>
      
      {/* Hero Section */}
      <section ref={heroRef} style={{ height: "auto", minHeight: "80vh", display: "flex", alignItems: "center", justifyContent: "center", position: "relative", overflow: "hidden" }}>
        <motion.div 
            style={{ 
                position: "absolute", top: -100, left: "50%", transform: "translateX(-50%)", 
                width: "80%", height: 300, 
                background: "radial-gradient(circle, rgba(139,92,246,0.15) 0%, transparent 70%)", 
                filter: "blur(60px)", pointerEvents: "none",
                y: heroY,
                opacity: heroOpacity
            }} 
        />

        <motion.div 
            initial="hidden"
            animate="visible"
            variants={containerVariants}
            style={{ position: "relative", zIndex: 1, padding: "120px 24px 80px", textAlign: "center", width: "100%" }}
        >
          <motion.h1 
            variants={itemVariants}
            style={{ fontSize: "clamp(2.5rem, 8vw, 4.5rem)", fontWeight: 900, letterSpacing: "-3px", marginBottom: "16px" }}
          >
            Techaa <span className="animate-float" style={{ display: "inline-block", background: "linear-gradient(135deg, #8b5cf6, #06b6d4)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>Purinjikoo</span>
          </motion.h1>
          <motion.p 
            variants={itemVariants}
            style={{ color: "#94a3b8", fontSize: "1.1rem", maxWidth: "600px", margin: "0 auto 32px" }}
          >
            Beginner-la irundhu Pro-ah aaga structured roadmap. Tech-ah friend solra maari purinjikalam! ☕
            <br /><span style={{ fontSize: "0.85rem", color: "#8b5cf6", fontWeight: 600 }}>✨ Topics free-ah read pannalam, progress save panna login pannunga!</span>
          </motion.p>

          <motion.div variants={itemVariants} style={{ display: "flex", gap: "12px", justifyContent: "center", flexWrap: "wrap" }}>
            {!user ? (
              <motion.button
                whileHover={{ scale: 1.05, boxShadow: "0 10px 30px rgba(139,92,246,0.5)" }}
                whileTap={{ scale: 0.95 }}
                onClick={loginWithGoogle}
                style={{ background: "#8b5cf6", color: "#fff", padding: "14px 32px", borderRadius: "14px", border: "none", fontWeight: 800, cursor: "pointer", transition: "0.2s" }}
              >
                Login with Google 🚀
              </motion.button>
            ) : (
              <motion.div whileHover={{ scale: 1.05 }}>
                <Link href="/profile" style={{ display: "inline-block", background: "#8b5cf6", color: "#fff", padding: "14px 32px", borderRadius: "14px", fontWeight: 800, textDecoration: "none", transition: "0.2s" }}>Go to Profile 🏆</Link>
              </motion.div>
            )}
            <motion.div whileHover={{ scale: 1.05 }}>
              <Link href="#roadmap" style={{ display: "inline-block", background: "rgba(255,255,245,0.05)", border: "1px solid rgba(255,255,255,0.1)", color: "#fff", padding: "14px 32px", borderRadius: "14px", fontWeight: 800, textDecoration: "none", transition: "0.2s" }}>Explore Path 📖</Link>
            </motion.div>
          </motion.div>
        </motion.div>
      </section>

      {/* Roadmap Section */}
      <section id="roadmap" style={{ maxWidth: "1200px", margin: "0 auto 100px", padding: "0 24px" }}>
        <motion.h2 
          initial={{ opacity: 0, x: -30 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          style={{ fontSize: "2.5rem", fontWeight: 950, textAlign: "left", marginBottom: "50px", letterSpacing: "-1.5px" }}
        >
          🗺️ Master Roadmap
        </motion.h2>

        <div style={{ display: "flex", gap: "16px", overflowX: "auto", paddingTop: "10px", paddingBottom: "40px", marginBottom: "50px", scrollbarWidth: "none" }} className="no-scrollbar">
          {ROADMAP_LEVEL_DATA().map((lvl, idx) => {
            const progress = getLevelProgress(lvl.id);
            const isActive = activeLevel === lvl.id;
            
            return (
              <motion.button
                key={lvl.id}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: idx * 0.05 }}
                whileHover={{ y: -5, scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => setActiveLevel(lvl.id)}
                style={{
                  flexShrink: 0,
                  background: isActive ? "linear-gradient(135deg, #8b5cf6, #7c3aed)" : "rgba(255,255,255,0.03)",
                  border: isActive ? "1px solid rgba(255,255,255,0.4)" : "1px solid rgba(255,255,255,0.08)",
                  padding: "24px",
                  borderRadius: "28px",
                  color: "#fff",
                  cursor: "pointer",
                  textAlign: "left",
                  minWidth: "240px",
                  transition: "0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275)",
                  boxShadow: isActive ? "0 20px 40px rgba(139,92,246,0.3)" : "none",
                  position: "relative",
                  zIndex: isActive ? 5 : 1
                }}
              >
                <div style={{ fontSize: "2.2rem", marginBottom: "16px" }}>{lvl.icon}</div>
                <div style={{ fontSize: "0.7rem", color: isActive ? "rgba(255,255,255,0.9)" : "#64748b", fontWeight: 900, textTransform: "uppercase", letterSpacing: "1.5px", marginBottom: "4px" }}>Module 0{lvl.id}</div>
                <div style={{ fontWeight: 950, fontSize: "1.25rem", marginBottom: "20px", letterSpacing: "-0.3px", height: "1.4em", overflow: "hidden" }}>{lvl.name}</div>

                <div style={{ height: "6px", background: isActive ? "rgba(255,255,255,0.2)" : "rgba(255,255,255,0.05)", borderRadius: "100px", width: "100%", overflow: "hidden" }}>
                  <motion.div 
                    initial={{ width: 0 }}
                    animate={{ width: `${progress}%` }}
                    style={{ height: "100%", background: progress === 100 ? "#4ade80" : (isActive ? "#fff" : "#8b5cf6") }} 
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
          transition={{ duration: 0.5 }}
          style={{ minHeight: "500px" }}
        >
          <div style={{ display: "flex", flexWrap: "wrap", alignItems: "center", gap: "24px", marginBottom: "50px", padding: "30px", background: "rgba(255,255,255,0.02)", borderRadius: "32px", border: "1px solid rgba(255,255,255,0.05)" }}>
            <motion.div 
                animate={{ rotate: [0, 10, -10, 0] }}
                transition={{ duration: 5, repeat: Infinity }}
                style={{ fontSize: "3.5rem" }}
            >
                {ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.icon}
            </motion.div>
            <div style={{ flex: 1 }}>
              <h3 style={{ fontSize: "2rem", fontWeight: 950, marginBottom: "8px", letterSpacing: "-1px" }}>{ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.name}</h3>
              <p style={{ color: "#94a3b8", fontSize: "1.1rem", lineHeight: 1.6 }}>{ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.desc}</p>
            </div>
          </div>

          <motion.div 
            layout
            style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(320px, 1fr))", gap: "24px" }}
          >
            <AnimatePresence mode="popLayout">
              {filteredTopics.map((topic, index) => (
                <motion.div
                  key={topic.id}
                  initial={{ opacity: 0, y: 30, scale: 0.9 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.9 }}
                  transition={{ delay: index * 0.08, type: "spring", stiffness: 100 }}
                >
                  <TopicCard topic={topic} index={index} />
                </motion.div>
              ))}
            </AnimatePresence>
            {filteredTopics.length === 0 && (
              <motion.div 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                style={{ gridColumn: "1/-1", textAlign: "center", padding: "100px", background: "rgba(255,255,255,0.02)", borderRadius: "40px", border: "2px dashed rgba(255,255,255,0.05)" }}
              >
                <div style={{ fontSize: "3rem", marginBottom: "20px" }}>🚧</div>
                <p style={{ color: "#94a3b8", fontSize: "1.2rem", fontWeight: 700 }}>Intha level topics ready aagitu iruku bro! ☕ Stay tuned.</p>
              </motion.div>
            )}
          </motion.div>
        </motion.div>
      </section>
    </div>
  );
}

function ROADMAP_LEVEL_DATA() {
  return [
    { id: 1, name: "Internet Basics", icon: "🌐", desc: "Browsers epdi work aagum, what is URL, and internet basics." },
    { id: 2, name: "Web Development", icon: "💻", desc: "The art of building interfaces and server-side logic." },
    { id: 3, name: "Database Systems", icon: "🗄️", desc: "Where all your app data goes — SQL vs NoSQL." },
    { id: 4, name: "Cloud Architecture", icon: "☁️", desc: "Deploying and scaling your apps globally." },
    { id: 5, name: "Modern DevTools", icon: "🧑‍💻", desc: "Essential tools like Git, GitHub and CI/CD." },
    { id: 6, name: "Cyber Security", icon: "🔐", desc: "Keeping your apps safe from bad actors." },
    { id: 7, name: "AI & Innovation", icon: "🤖", desc: "Leveraging LLMs and future tech in your stack." },
  ];
}
