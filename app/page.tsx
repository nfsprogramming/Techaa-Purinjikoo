
"use client";
import React, { useRef, useState, useEffect } from "react";
import { topics } from "@/data/topics";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import TopicCard from "@/components/TopicCard";
import { motion, AnimatePresence, useScroll, useTransform } from "framer-motion";
import { useUserProgress } from "@/context/UserProgressContext";
import { useAuth } from "@/context/AuthContext";
import FlipFadeText from "@/components/ui/liquid-text";

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
  const [searchQuery, setSearchQuery] = useState("");
  const { getLevelProgress } = useUserProgress();
  const { user, loginWithGoogle } = useAuth();

  // Persist active level so back button doesn't reset it
  useEffect(() => {
    const saved = localStorage.getItem("techaa_active_level");
    if (saved) setActiveLevel(parseInt(saved));
  }, []);

  const handleLevelChange = (levelId: number) => {
    setActiveLevel(levelId);
    localStorage.setItem("techaa_active_level", levelId.toString());
  };

  const heroRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: heroRef,
    offset: ["start start", "end start"]
  });

  const heroY = useTransform(scrollYProgress, [0, 1], [0, 150]);
  const heroOpacity = useTransform(scrollYProgress, [0, 1], [1, 0]);

  const filteredTopics = searchQuery.trim() === ""
    ? topics.filter(t => t.level === activeLevel || (!t.level && activeLevel === 1))
    : topics.filter(t =>
      t.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      t.shortDesc.toLowerCase().includes(searchQuery.toLowerCase())
    );

  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff" }}>
      <style dangerouslySetInnerHTML={{__html: `
        @keyframes shimmer {
          0% { background-position: -200% center; }
          100% { background-position: 200% center; }
        }
        .text-shimmer {
          background: linear-gradient(90deg, #8b5cf6 0%, #aa8bf5 30%, #06b6d4 50%, #aa8bf5 70%, #8b5cf6 100%);
          background-size: 200% auto;
          color: transparent;
          -webkit-background-clip: text;
          background-clip: text;
          animation: shimmer 4s linear infinite;
        }
        .custom-scrollbar::-webkit-scrollbar {
          height: 8px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
          background: rgba(255,255,255,0.02);
          border-radius: 10px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
          background: rgba(255,255,255,0.1);
          border-radius: 10px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
          background: rgba(139,92,246,0.3);
        }
      `}} />

      {/* Hero Section */}
      <section ref={heroRef} style={{ height: "auto", minHeight: "80vh", display: "flex", alignItems: "center", justifyContent: "center", position: "relative", overflow: "hidden" }}>
        {/* ... (previous code) ... */}
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
          style={{ position: "relative", zIndex: 1, padding: "clamp(80px, 15vh, 120px) 24px 60px", textAlign: "center", width: "100%" }}
        >
          <motion.h1
            variants={itemVariants}
            style={{ 
              fontSize: "clamp(2.2rem, 10vw, 4.5rem)", 
              fontWeight: 900, 
              letterSpacing: "-2px", 
              marginBottom: "16px", 
              lineHeight: 1.1,
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              flexWrap: "wrap",
              gap: "12px"
            }}
          >
            Techaa 
            <FlipFadeText 
              words={["Purinjikoo", "Developer", "Engineer", "Programmer", "Creator"]}
              className="min-h-0 h-auto"
              textClassName="!text-[#06b6d4] m-0 normal-case tracking-tight !text-[1em]" 
            />
          </motion.h1>
          <motion.p
            variants={itemVariants}
            style={{ color: "#94a3b8", fontSize: "clamp(1rem, 4vw, 1.1rem)", maxWidth: "600px", margin: "0 auto 32px" }}
          >
            Beginner-la irundhu Pro-ah aaga structured roadmap. Tech-ah friend solra maathiri purinjikalam! ☕
            <br /><span style={{ fontSize: "0.8rem", color: "#8b5cf6", fontWeight: 600 }}>✨ Topics free-ah read pannalam, progress save panna login pannunga!</span>
          </motion.p>

          <motion.div variants={itemVariants} style={{ display: "flex", gap: "10px", justifyContent: "center", flexWrap: "wrap" }}>
            {!user ? (
              <motion.button
                whileHover={{ scale: 1.05, boxShadow: "0 10px 30px rgba(139,92,246,0.5)" }}
                whileTap={{ scale: 0.95 }}
                onClick={loginWithGoogle}
                style={{ background: "#8b5cf6", color: "#fff", padding: "12px 28px", borderRadius: "14px", border: "none", fontWeight: 800, cursor: "pointer", transition: "0.2s", fontSize: "0.95rem" }}
              >
                Login with Google 🚀
              </motion.button>
            ) : (
              <motion.div whileHover={{ scale: 1.05 }}>
                <Link href="/profile" style={{ display: "inline-block", background: "#8b5cf6", color: "#fff", padding: "12px 28px", borderRadius: "14px", fontWeight: 800, textDecoration: "none", transition: "0.2s", fontSize: "0.95rem" }}>Go to Profile 🏆</Link>
              </motion.div>
            )}
            <motion.div whileHover={{ scale: 1.05 }}>
              <Link href="#roadmap" style={{ display: "inline-block", background: "rgba(255,255,245,0.05)", border: "1px solid rgba(255,255,255,0.1)", color: "#fff", padding: "12px 28px", borderRadius: "14px", fontWeight: 800, textDecoration: "none", transition: "0.2s", fontSize: "0.95rem" }}>Explore Path 📖</Link>
            </motion.div>
          </motion.div>
        </motion.div>
      </section>

      {/* Quick Actions */}
      <section style={{ maxWidth: "1200px", margin: "-30px auto 60px", padding: "0 24px", position: "relative", zIndex: 10 }}>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))", gap: "16px" }}>
          <Link href="/battle" style={{ textDecoration: "none" }}>
            <motion.div
              whileHover={{ y: -10, boxShadow: "0 20px 40px rgba(139,92,246,0.15)" }}
              style={{ background: "rgba(139,92,246,0.05)", border: "1px solid rgba(139,92,246,0.2)", padding: "24px", borderRadius: "24px", display: "flex", alignItems: "center", gap: "20px", cursor: "pointer", backdropFilter: "blur(10px)" }}
            >
              <div style={{ fontSize: "2.5rem", background: "#8b5cf61a", width: "70px", height: "70px", borderRadius: "18px", display: "flex", alignItems: "center", justifyContent: "center" }}>⚔️</div>
              <div>
                <h3 style={{ margin: 0, fontSize: "1.2rem", fontWeight: 900, color: "#fff" }}>Quiz Battles</h3>
                <p style={{ margin: "4px 0 0", color: "#a78bfa", fontSize: "0.85rem", fontWeight: 700 }}>Friends-ah challenge panni XP win pannunga! 🔥</p>
              </div>
            </motion.div>
          </Link>

          <Link href="/flashcards" style={{ textDecoration: "none" }}>
            <motion.div
              whileHover={{ y: -10, boxShadow: "0 20px 40px rgba(6,182,212,0.15)" }}
              style={{ background: "rgba(6,182,212,0.05)", border: "1px solid rgba(6,182,212,0.2)", padding: "24px", borderRadius: "24px", display: "flex", alignItems: "center", gap: "20px", cursor: "pointer", backdropFilter: "blur(10px)" }}
            >
              <div style={{ fontSize: "2.5rem", background: "#06b6d41a", width: "70px", height: "70px", borderRadius: "18px", display: "flex", alignItems: "center", justifyContent: "center" }}>⚡</div>
              <div>
                <h3 style={{ margin: 0, fontSize: "1.2rem", fontWeight: 900, color: "#fff" }}>Flashcards</h3>
                <p style={{ margin: "4px 0 0", color: "#67e8f9", fontSize: "0.85rem", fontWeight: 700 }}>Quick revision for bored developers! 🧠</p>
              </div>
            </motion.div>
          </Link>
        </div>
      </section>

      {/* Roadmap Section */}
      <section id="roadmap" style={{ maxWidth: "1200px", margin: "0 auto 100px", padding: "0 24px" }}>

        <div style={{ display: "flex", gap: "16px", alignItems: "center", flexWrap: "wrap", marginBottom: "40px" }}>
          <motion.h2
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
            style={{ fontSize: "clamp(1.8rem, 6vw, 2.5rem)", fontWeight: 950, textAlign: "left", letterSpacing: "-1px", margin: 0 }}
          >
            🗺️ Master Roadmap
          </motion.h2>

          {/* Search Bar */}
          <div style={{ flex: 1, minWidth: "280px", position: "relative" }}>
            <input
              type="text"
              placeholder="Topic search pannunga..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{
                width: "100%",
                background: "rgba(255,255,255,0.03)",
                border: "1px solid rgba(255,255,255,0.07)",
                padding: "14px 16px 14px 45px",
                borderRadius: "16px",
                color: "#fff",
                fontSize: "0.95rem",
                outline: "none",
                transition: "0.3s",
                borderBottom: searchQuery ? "2px solid #8b5cf6" : "1px solid rgba(255,255,255,0.1)"
              }}
            />
            <span style={{ position: "absolute", left: "16px", top: "50%", transform: "translateY(-50%)", fontSize: "1.1rem", opacity: 0.5 }}>🔍</span>
          </div>
        </div>

        {searchQuery.trim() === "" ? (
          <div
            style={{
              position: "relative",
              overflow: "hidden",
              marginBottom: "50px",
              padding: "10px 0 40px"
            }}
          >
            {/* Hint for swiping */}
            <div style={{ position: "absolute", top: -20, right: 0, fontSize: "0.8rem", color: "#64748b", fontWeight: 700, display: "flex", alignItems: "center", gap: "8px" }}>
              <span>Swipe panni matha modules paarunga</span>
              <motion.span animate={{ x: [0, 5, 0] }} transition={{ repeat: Infinity, duration: 1.5 }}>➜</motion.span>
            </div>

            <div
              className="custom-scrollbar"
              style={{
                display: "flex",
                gap: "16px",
                paddingRight: "50px", // Extra space to show there is more
                paddingBottom: "16px", // Space for scrollbar
                overflowX: "auto",
                scrollBehavior: "smooth",
                WebkitOverflowScrolling: "touch"
              }}
            >
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
                    onClick={() => handleLevelChange(lvl.id)}
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
          </div>
        ) : (
          <div style={{ marginBottom: "32px", padding: "12px 24px", background: "rgba(139,92,246,0.1)", borderRadius: "12px", display: "inline-block" }}>
            <p style={{ margin: 0, fontWeight: 800, color: "#a78bfa" }}>Found {filteredTopics.length} topics for "{searchQuery}"</p>
          </div>
        )}

        <motion.div
          key={searchQuery ? "search" : activeLevel}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5 }}
          style={{ minHeight: "500px" }}
        >
          {searchQuery.trim() === "" && (
            <div style={{ display: "flex", flexWrap: "wrap", alignItems: "center", gap: "20px", marginBottom: "40px", padding: "clamp(20px, 5vw, 30px)", background: "rgba(255,255,255,0.02)", borderRadius: "24px", border: "1px solid rgba(255,255,255,0.05)" }}>
              <motion.div
                animate={{ rotate: [0, 10, -10, 0] }}
                transition={{ duration: 5, repeat: Infinity }}
                style={{ fontSize: "clamp(2.5rem, 8vw, 3.5rem)" }}
              >
                {ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.icon}
              </motion.div>
              <div style={{ flex: 1, minWidth: "200px" }}>
                <h3 style={{ fontSize: "clamp(1.4rem, 5vw, 2rem)", fontWeight: 950, marginBottom: "4px", letterSpacing: "-0.5px" }}>{ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.name}</h3>
                <p style={{ color: "#94a3b8", fontSize: "clamp(0.9rem, 4vw, 1rem)", lineHeight: 1.5 }}>{ROADMAP_LEVEL_DATA().find(l => l.id === activeLevel)?.desc}</p>
              </div>
            </div>
          )}

          <motion.div
            layout
            style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: "20px" }}
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
                <p style={{ color: "#94a3b8", fontSize: "1.2rem", fontWeight: 700 }}>Intha mathiri topics edhum illaye bro! 😅</p>
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
