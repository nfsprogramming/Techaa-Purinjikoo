
"use client";
import { useParams, useRouter } from "next/navigation";
import { topics } from "@/data/topics";
import { useState, useEffect } from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { useUserProgress } from "@/context/UserProgressContext";
import { XP_AWARDS } from "@/data/gamification";
import { motion, AnimatePresence } from "framer-motion";

export default function TopicPage() {
  const params = useParams();
  const router = useRouter();
  const topic = topics.find((t) => t.id === params.id);
  const { completeTopic, addXP, unlockedBadges, BADGES, completedTopics, isTopicLocked, loading } = useUserProgress();
  const [activeTab, setActiveTab] = useState("learn"); // learn, quiz, mistakes
  
  const isLocked = isTopicLocked(params.id);

  useEffect(() => {
    if (isLocked && topic) {
      // Allow access if they just completed it (state might be updating)
      // Actually isTopicLocked handles completion check
    }
  }, [isLocked, topic]);

  const [correctAnswer, setCorrectAnswer] = useState(null);
  const [showShareModal, setShowShareModal] = useState(false);
  const [lastUnlockedBadge, setLastUnlockedBadge] = useState(null);
  const [hasAwardedQuizXP, setHasAwardedQuizXP] = useState(false);
  const [xpToast, setXpToast] = useState(null);

  const [isCompleting, setIsCompleting] = useState(false);
  const [readingCompleted, setReadingCompleted] = useState(false);
  const isAlreadyCompleted = completedTopics?.includes(topic?.id);

  // Find next topic
  const currentIdx = topics.findIndex(t => t.id === topic?.id);
  const nextTopic = topics[currentIdx + 1];

  const initialBadgeCount = useRef(null);

  // Show badge unlock notification
  useEffect(() => {
    if (loading) return; // Wait for data to load

    // Only initialize the count on the first render of this component instance
    if (initialBadgeCount.current === null) {
      initialBadgeCount.current = unlockedBadges.length;
      return;
    }

    // Only show notification if the length has increased since we last checked
    if (unlockedBadges.length > initialBadgeCount.current) {
      const latestBadgeId = unlockedBadges[unlockedBadges.length - 1];
      const badge = BADGES.find(b => b.id === latestBadgeId);
      if (badge) {
        setLastUnlockedBadge(badge);
        const timer = setTimeout(() => setLastUnlockedBadge(null), 5000);
        initialBadgeCount.current = unlockedBadges.length;
        return () => clearTimeout(timer);
      }
    }
  }, [unlockedBadges.length, BADGES, loading]);

  const handleQuizAnswer = (isCorrect) => {
    setCorrectAnswer(isCorrect);
    if (isCorrect && !hasAwardedQuizXP) {
      addXP(XP_AWARDS.QUIZ_CORRECT);
      setHasAwardedQuizXP(true);
      setXpToast(`+${XP_AWARDS.QUIZ_CORRECT} XP for correct answer! 🔥`);
      setTimeout(() => setXpToast(null), 3000);
    }
  };

  const handleMarkAsCompleted = async () => {
    if (!correctAnswer && !isAlreadyCompleted) {
      setActiveTab("quiz");
      alert("First quiz answer pannu bro! Then only progress save aakum. 🎯");
      return;
    }

    setIsCompleting(true);
    
    // Simulate some "rotation" or processing
    await new Promise(resolve => setTimeout(resolve, 1500));

    if (!isAlreadyCompleted) {
      completeTopic(topic.id);
      setReadingCompleted(true);
      setXpToast(`+${XP_AWARDS.READ_TOPIC} XP ✨ Topic Completed!`);
    }
    
    setIsCompleting(false);
    setReadingCompleted(true);
  };

  if (!topic) {
    return (
      <div style={{ background: "#070711", minHeight: "100vh", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", flexDirection: "column" }}>
        <h2>Topic Not Found Bro! 😅</h2>
        <Link href="/" style={{ color: "#8b5cf6", marginTop: "20px" }}>Go Home</Link>
      </div>
    );
  }

  if (isLocked) {
    const prevTopic = topics[topics.findIndex(t => t.id === topic.id) - 1];
    return (
      <div style={{ background: "#070711", minHeight: "100vh", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", padding: "24px" }}>
        <motion.div 
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          style={{ maxWidth: "500px", width: "100%", textAlign: "center", background: "rgba(255,255,255,0.02)", border: "1px solid rgba(255,255,255,0.05)", padding: "60px 40px", borderRadius: "32px", backdropFilter: "blur(20px)" }}
        >
          <div style={{ fontSize: "5rem", marginBottom: "24px", opacity: 0.5 }}>🔒</div>
          <h2 style={{ fontSize: "2rem", fontWeight: 900, marginBottom: "16px" }}>This Topic is Locked!</h2>
          <p style={{ color: "#94a3b8", fontSize: "1.1rem", lineHeight: 1.6, marginBottom: "32px" }}>
            Pazhaya topics-ah mudicha thaan idhu open aagum bro. One by one-ah learn panni master aagu! 🚀
          </p>
          {prevTopic && (
            <Link href={`/topics/${prevTopic.id}`} style={{ display: "block", background: "#8b5cf6", color: "#fff", padding: "16px", borderRadius: "16px", textDecoration: "none", fontWeight: 800, marginBottom: "16px" }}>
              Complete: {prevTopic.title}
            </Link>
          )}
          <Link href="/" style={{ color: "#94a3b8", textDecoration: "none", fontSize: "0.9rem", fontWeight: 600 }}>Back to Roadmap</Link>
        </motion.div>
      </div>
    );
  }

  const handleShare = () => {
    setShowShareModal(true);
    setTimeout(() => setShowShareModal(false), 2000);
    const shareText = `Did you know? ${topic.title}: ${topic.shortDesc} Learn more at Techaa Purinjikoo!`;
    navigator.clipboard.writeText(shareText);
  };

  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff" }}>
      <Navbar />

      <div style={{ maxWidth: "800px", margin: "0 auto", padding: "100px 24px 60px" }}>
        
        {/* Header Section */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          style={{ textAlign: "center", marginBottom: "40px" }}
        >
          <div style={{ fontSize: "5rem", marginBottom: "16px", filter: "drop-shadow(0 0 20px rgba(139,92,246,0.3))" }}>{topic.emoji}</div>
          <h1 style={{ fontSize: "2.8rem", fontWeight: 900, marginBottom: "8px", background: "linear-gradient(to right, #fff, #94a3b8)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>{topic.title}</h1>
          <p style={{ color: topic.accentColor, fontWeight: 800, letterSpacing: "2px", textTransform: "uppercase", fontSize: "0.9rem" }}>{topic.tagline}</p>
        </motion.div>

        {/* Navigation Tabs */}
        <div style={{ display: "flex", gap: "8px", background: "rgba(255,255,255,0.03)", padding: "6px", borderRadius: "16px", marginBottom: "32px", border: "1px solid rgba(255,255,255,0.05)" }}>
          <button onClick={() => setActiveTab("learn")} style={{ flex: 1, padding: "14px", borderRadius: "12px", border: "none", background: activeTab === "learn" ? "rgba(139,92,246,0.15)" : "transparent", color: activeTab === "learn" ? "#a78bfa" : "#64748b", fontWeight: 800, cursor: "pointer", transition: "0.3s" }}>📖 Read</button>
          <button onClick={() => setActiveTab("quiz")} style={{ flex: 1, padding: "14px", borderRadius: "12px", border: "none", background: activeTab === "quiz" ? "rgba(139,92,246,0.15)" : "transparent", color: activeTab === "quiz" ? "#a78bfa" : "#64748b", fontWeight: 800, cursor: "pointer", transition: "0.3s" }}>🎯 Quiz</button>
          <button onClick={() => setActiveTab("mistakes")} style={{ flex: 1, padding: "14px", borderRadius: "12px", border: "none", background: activeTab === "mistakes" ? "rgba(139,92,246,0.15)" : "transparent", color: activeTab === "mistakes" ? "#a78bfa" : "#64748b", fontWeight: 800, cursor: "pointer", transition: "0.3s" }}>🤫 Mistake</button>
        </div>

        <AnimatePresence mode="wait">
          {activeTab === "learn" && (
            <motion.div 
              key="learn"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
            >
              {/* Quick Summary */}
              <div className="glass-card" style={{ borderRadius: "24px", padding: "32px", marginBottom: "24px" }}>
                <h3 style={{ fontSize: "1.3rem", fontWeight: 900, marginBottom: "20px", color: topic.accentColor }}>⚡ Simple Ah Solluvom</h3>
                <p style={{ color: "#cbd5e1", lineHeight: 1.8, fontSize: "1.1rem" }}>{topic.quickSummary}</p>
              </div>

              {/* Analogy */}
              <div style={{ background: `linear-gradient(135deg, ${topic.accentColor}11, #070711)`, borderRadius: "24px", padding: "32px", marginBottom: "24px", border: `1px solid ${topic.accentColor}22` }}>
                <h3 style={{ fontSize: "1.3rem", fontWeight: 900, marginBottom: "20px" }}>🎭 Real Life Analogy</h3>
                <p style={{ color: "#fff", marginBottom: "24px", fontSize: "1.1rem", fontStyle: "italic" }}>{topic.analogy?.description}</p>
                <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: "24px", background: "rgba(0,0,0,0.3)", padding: "32px", borderRadius: "20px" }}>
                  {topic.analogy?.visual?.map((v, i) => (
                    <div key={i} style={{ textAlign: "center" }}>
                      <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 2, delay: i * 0.3 }} style={{ fontSize: "2rem" }}>{v.icon}</motion.div>
                      <div style={{ fontSize: "0.75rem", color: "#94a3b8", fontWeight: 700, marginTop: "8px", textTransform: "uppercase" }}>{v.label}</div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Conversation */}
              <div style={{ background: "#0a0a1a", border: "1px solid #1e1e3f", borderRadius: "20px", padding: "24px", marginBottom: "24px", boxShadow: "inset 0 0 20px rgba(0,0,0,0.5)" }}>
                <div style={{ display: "flex", gap: "8px", marginBottom: "20px" }}>
                  <div style={{ width: "12px", height: "12px", borderRadius: "50%", background: "#ff5f56" }} />
                  <div style={{ width: "12px", height: "12px", borderRadius: "50%", background: "#ffbd2e" }} />
                  <div style={{ width: "12px", height: "12px", borderRadius: "50%", background: "#27c93f" }} />
                </div>
                <div style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
                  {topic.conversation?.map((msg, i) => (
                    <motion.div initial={{ opacity: 0, y: 10 }} whileInView={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.1 }} key={i} style={{ display: "flex", gap: "16px" }}>
                      <span style={{ fontSize: "1.5rem" }}>{msg.avatar}</span>
                      <div style={{ flex: 1 }}>
                        <span style={{ color: "#8b5cf6", fontWeight: 800, fontSize: "0.9rem" }}>{msg.speaker}: </span>
                        <span style={{ color: "#94a3b8", lineHeight: 1.6, fontSize: "1.05rem" }}>{msg.message}</span>
                      </div>
                    </motion.div>
                  ))}
                </div>
              </div>
            </motion.div>
          )}

          {activeTab === "quiz" && (
            <motion.div 
              key="quiz"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="glass-card" 
              style={{ padding: "40px", borderRadius: "24px" }}
            >
              <h3 style={{ fontSize: "1.6rem", fontWeight: 900, marginBottom: "24px" }}>🎯 Concept Purinjithaa?</h3>
              <p style={{ fontSize: "1.2rem", color: "#f1f5f9", marginBottom: "32px", lineHeight: 1.6 }}>{topic.quiz?.question}</p>
              
              <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
                {topic.quiz?.options.map((opt, i) => (
                  <motion.button
                    key={i}
                    whileHover={{ x: 10, background: "rgba(139,92,246,0.1)" }}
                    whileTap={{ scale: 0.98 }}
                    onClick={() => handleQuizAnswer(i === topic.quiz.answer)}
                    style={{
                      padding: "20px",
                      borderRadius: "16px",
                      border: "1px solid rgba(255,255,255,0.08)",
                      background: correctAnswer !== null && i === topic.quiz.answer ? "rgba(34,197,94,0.1)" : "rgba(255,255,255,0.02)",
                      color: "#fff",
                      textAlign: "left",
                      cursor: "pointer",
                      fontSize: "1.05rem",
                      fontWeight: 600,
                      transition: "0.3s",
                      borderColor: correctAnswer !== null && i === topic.quiz.answer ? "#22c55e" : "rgba(255,255,255,0.08)"
                    }}
                  >
                    {opt}
                  </motion.button>
                ))}
              </div>

              {correctAnswer !== null && (
                <motion.div 
                  initial={{ opacity: 0, scale: 0.9 }} 
                  animate={{ opacity: 1, scale: 1 }}
                  style={{ marginTop: "32px", padding: "20px", borderRadius: "16px", background: correctAnswer ? "rgba(34,197,94,0.1)" : "rgba(239,68,68,0.1)", color: correctAnswer ? "#4ade80" : "#f87171", textAlign: "center", fontWeight: 800, border: "1px solid", borderColor: correctAnswer ? "rgba(34,197,94,0.2)" : "rgba(239,68,68,0.2)" }}
                >
                  {correctAnswer ? "Semma! Correct answer bro 🔥" : "Illa bro, knowledge check pannunga! 😅"}
                </motion.div>
              )}
            </motion.div>
          )}

          {activeTab === "mistakes" && (
            <motion.div 
              key="mistakes"
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              style={{ display: "flex", flexDirection: "column", gap: "24px" }}
            >
              <div style={{ background: "rgba(239,68,68,0.03)", border: "1px solid rgba(239,68,68,0.15)", borderRadius: "24px", padding: "32px" }}>
                <h3 style={{ fontSize: "1.3rem", fontWeight: 900, color: "#f87171", marginBottom: "16px", display: "flex", alignItems: "center", gap: "10px" }}>🛑 Developer Mistake</h3>
                <p style={{ color: "#fca5a5", fontSize: "1.1rem", lineHeight: 1.6 }}>"{topic.devConfession?.mistake}"</p>
              </div>
              <div style={{ background: "rgba(34,197,94,0.03)", border: "1px solid rgba(34,197,94,0.15)", borderRadius: "24px", padding: "32px" }}>
                <h3 style={{ fontSize: "1.3rem", fontWeight: 900, color: "#4ade80", marginBottom: "16px", display: "flex", alignItems: "center", gap: "10px" }}>💡 Lesson Learned</h3>
                <p style={{ color: "#86efac", fontSize: "1.1rem", lineHeight: 1.6 }}>{topic.devConfession?.lesson}</p>
              </div>

              {/* MARK AS COMPLETED / NEXT BUTTON */}
              <div style={{ marginTop: "32px", textAlign: "center" }}>
                {!readingCompleted ? (
                   <motion.button
                    disabled={isCompleting}
                    onClick={handleMarkAsCompleted}
                    animate={isCompleting ? { rotate: 360 } : {}}
                    transition={isCompleting ? { repeat: Infinity, duration: 1, ease: "linear" } : {}}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    style={{
                      background: "linear-gradient(135deg, #8b5cf6, #7c3aed)",
                      color: "#fff",
                      padding: "18px 36px",
                      borderRadius: "16px",
                      border: "none",
                      fontWeight: 800,
                      fontSize: "1.1rem",
                      cursor: "pointer",
                      boxShadow: "0 10px 25px rgba(139,92,246,0.4)"
                    }}
                  >
                    {isCompleting ? "SAVING..." : "MARK AS COMPLETED ✅"}
                  </motion.button>
                ) : (
                  <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}>
                    <p style={{ fontWeight: 800, color: "#22c55e", marginBottom: "16px" }}>Topic Completed! Semma bro! 🎉</p>
                    <button
                      onClick={() => nextTopic ? router.push(`/topics/${nextTopic.id}`) : router.push('/')}
                      style={{
                        background: "#fff",
                        color: "#070711",
                        padding: "18px 36px",
                        borderRadius: "16px",
                        border: "none",
                        fontWeight: 900,
                        fontSize: "1.2rem",
                        cursor: "pointer",
                        boxShadow: "0 10px 30px rgba(255,255,255,0.2)"
                      }}
                    >
                      {nextTopic ? "NEXT POLAMA? 🚀" : "FINISH CHALLENGE 🏆"}
                    </button>
                  </motion.div>
                )}
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Share Section */}
        <div style={{ marginTop: "60px", textAlign: "center", borderTop: "1px solid rgba(255,255,255,0.05)", paddingTop: "40px" }}>
          <button onClick={handleShare} style={{ background: "rgba(255,255,255,0.02)", color: "#94a3b8", border: "1px solid rgba(255,255,255,0.1)", padding: "12px 24px", borderRadius: "12px", fontWeight: 700, cursor: "pointer", display: "flex", alignItems: "center", gap: "8px", margin: "0 auto", transition: "0.3s" }}>
            {showShareModal ? "✅ Copied!" : "📱 Share Card"}
          </button>
        </div>
      </div>

      <Footer />
      
      {/* Badge Notification */}
      {lastUnlockedBadge && (
        <div style={{ position: "fixed", top: "80px", right: "24px", background: "#1e1b4b", border: "2px solid #8b5cf6", borderRadius: "20px", padding: "20px", boxShadow: "0 25px 50px rgba(0,0,0,0.5)", display: "flex", alignItems: "center", gap: "20px", zIndex: 1000 }}>
          <div style={{ fontSize: "3rem" }}>{lastUnlockedBadge.emoji}</div>
          <div>
            <div style={{ fontSize: "0.75rem", fontWeight: 900, color: "#8b5cf6", textTransform: "uppercase", letterSpacing: "1.5px" }}>NEW ACHIEVEMENT!</div>
            <div style={{ fontSize: "1.2rem", fontWeight: 900, color: "#fff" }}>{lastUnlockedBadge.title}</div>
            <div style={{ fontSize: "0.85rem", color: "#94a3b8" }}>{lastUnlockedBadge.desc}</div>
          </div>
        </div>
      )}

      {/* XP Toast */}
      {xpToast && (
        <motion.div 
          initial={{ y: 50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          style={{ position: "fixed", bottom: "40px", left: "50%", transform: "translateX(-50%)", background: "#8b5cf6", color: "#fff", padding: "14px 32px", borderRadius: "100px", fontWeight: 900, fontSize: "1.1rem", boxShadow: "0 10px 40px rgba(139,92,246,0.6)", zIndex: 1000 }}
        >
          {xpToast}
        </motion.div>
      )}
    </div>
  );
}
