"use client";
import React, { useState, useEffect, useRef } from "react";
import { useParams, useRouter } from "next/navigation";
import { topics } from "@/data/topics";
import { useUserProgress } from "@/context/UserProgressContext";
import { XP_AWARDS } from "@/data/gamification";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import Navbar from "@/components/Navbar";
import TopicDiscussion from "@/components/TopicDiscussion";

export default function TopicPage() {
  const params = useParams();
  const router = useRouter();
  const topic = topics.find((t) => t.id === params.id);
  const { 
    completeTopic, 
    completeQuiz, 
    completedQuizzes, 
    markRead, 
    markMistakeSeen,
    completedReadings,
    viewedMistakes,
    unlockedBadges, 
    BADGES, 
    completedTopics, 
    isTopicLocked, 
    loading 
  } = useUserProgress();
  
  const [activeTab, setActiveTab] = useState("learn"); // learn, quiz, mistakes
  const [quizIndex, setQuizIndex] = useState(0);
  const [correctAnswersCount, setCorrectAnswersCount] = useState(0);
  
  const isLocked = isTopicLocked(params.id);

  // Initialize tracking
  useEffect(() => {
    if (activeTab === "learn") markRead(params.id);
    if (activeTab === "mistakes") markMistakeSeen(params.id);
  }, [activeTab, params.id]);

  const [correctAnswer, setCorrectAnswer] = useState(null);
  const [showShareModal, setShowShareModal] = useState(false);
  const [lastUnlockedBadge, setLastUnlockedBadge] = useState(null);
  const [xpToast, setXpToast] = useState(null);

  const [isCompleting, setIsCompleting] = useState(false);
  const [readingCompleted, setReadingCompleted] = useState(false);
  
  const isAlreadyCompleted = completedTopics?.includes(topic?.id);
  const isQuizAlreadyDone = completedQuizzes?.includes(topic?.id);
  const hasRead = completedReadings?.includes(topic?.id);
  const hasSeenMistake = viewedMistakes?.includes(topic?.id);

  // Find next topic
  const currentIdx = topics.findIndex(t => t.id === topic?.id);
  const nextTopic = topics[currentIdx + 1];

  const initialBadgeCount = useRef(null);

  // Support for multiple quizzes
  const quizList = topic?.quizzes || (topic?.quiz ? [topic.quiz] : []);
  const currentQuiz = quizList[quizIndex];

  // Show badge unlock notification
  useEffect(() => {
    if (loading) return; 

    if (initialBadgeCount.current === null) {
      initialBadgeCount.current = unlockedBadges.length;
      return;
    }

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
    
    if (isCorrect) {
      setCorrectAnswersCount(prev => prev + 1);
      
      // If last question or only one question
      if (quizIndex === quizList.length - 1) {
        if (!isQuizAlreadyDone) {
          completeQuiz(topic.id);
          setXpToast(`+${XP_AWARDS.QUIZ_CORRECT} XP! Focus logic super 🚀`);
          setTimeout(() => setXpToast(null), 3000);
        }
      } else {
        // Move to next question after delay
        setTimeout(() => {
          setQuizIndex(prev => prev + 1);
          setCorrectAnswer(null);
        }, 1500);
      }
    }
  };

  const handleMarkAsCompleted = async () => {
    if (!isQuizAlreadyDone && !isAlreadyCompleted) {
      setActiveTab("quiz");
      alert("Mothama ella quiz-um answer panna thaan progress save aakum bro! 🎯");
      return;
    }

    setIsCompleting(true);
    await new Promise(resolve => setTimeout(resolve, 1500));

    if (!isAlreadyCompleted) {
      completeTopic(topic.id);
      setReadingCompleted(true);
      setXpToast(`+${XP_AWARDS.READ_TOPIC} XP ✨ Mastery Unlocked!`);
    }
    
    setIsCompleting(false);
    setReadingCompleted(true);
  };

  const handleShare = () => {
    setShowShareModal(true);
    const shareText = `I just completed "${topic.title}" on Techaa Purinjikoo! 🚀 It was so easy to understand. Check it out: https://techaa-purinjikoo.vercel.app/topics/${topic.id}`;
    
    if (navigator.share) {
      navigator.share({
        title: 'Techaa Purinjikoo',
        text: shareText,
        url: window.location.href,
      }).catch(console.error);
    } else {
      navigator.clipboard.writeText(shareText);
      setTimeout(() => setShowShareModal(false), 2000);
    }
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

  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff" }}>
      <Navbar />
      <div style={{ maxWidth: "800px", margin: "0 auto", padding: "clamp(80px, 12vh, 100px) 20px 60px" }}>
        
        {/* Back Button */}
        <motion.div initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }}>
          <Link href="/" style={{ display: "inline-flex", alignItems: "center", gap: "8px", color: "#64748b", textDecoration: "none", fontSize: "0.9rem", fontWeight: 700, marginBottom: "32px", padding: "8px 16px", background: "rgba(255,255,255,0.03)", border: "1px solid rgba(255,255,255,0.06)", borderRadius: "12px", transition: "0.2s" }}>
            <span>←</span> Back to Roadmap
          </Link>
        </motion.div>

        {/* Header Section */}
        <motion.div 
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          style={{ textAlign: "center", marginBottom: "32px" }}
        >
          <div style={{ fontSize: "clamp(3.5rem, 15vw, 5rem)", marginBottom: "12px", filter: "drop-shadow(0 0 20px rgba(139,92,246,0.3))" }}>{topic.emoji}</div>
          <h1 style={{ fontSize: "clamp(1.8rem, 8vw, 2.8rem)", fontWeight: 900, marginBottom: "8px", background: "linear-gradient(to right, #fff, #94a3b8)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", lineHeight: 1.2 }}>{topic.title}</h1>
          <p style={{ color: topic.accentColor, fontWeight: 800, letterSpacing: "1.5px", textTransform: "uppercase", fontSize: "0.8rem" }}>{topic.tagline}</p>
        </motion.div>

        {/* Navigation Tabs with Progress Indicators */}
        <div style={{ display: "flex", gap: "8px", background: "rgba(255,255,255,0.03)", padding: "6px", borderRadius: "16px", marginBottom: "32px", border: "1px solid rgba(255,255,255,0.05)" }}>
          <button onClick={() => setActiveTab("learn")} style={{ flex: 1, padding: "14px", borderRadius: "12px", border: "none", background: activeTab === "learn" ? "rgba(139,92,246,0.15)" : "transparent", color: activeTab === "learn" ? "#a78bfa" : "#64748b", fontWeight: 800, cursor: "pointer", transition: "0.3s", position: "relative" }}>
            📖 Read {hasRead && <span style={{ color: "#22c55e", position: "absolute", top: "5px", right: "10px", fontSize: "0.8rem" }}>✓</span>}
          </button>
          <button onClick={() => setActiveTab("quiz")} style={{ flex: 1, padding: "14px", borderRadius: "12px", border: "none", background: activeTab === "quiz" ? "rgba(139,92,246,0.15)" : "transparent", color: activeTab === "quiz" ? "#a78bfa" : "#64748b", fontWeight: 800, cursor: "pointer", transition: "0.3s", position: "relative" }}>
            🎯 Quiz {isQuizAlreadyDone && <span style={{ color: "#22c55e", position: "absolute", top: "5px", right: "10px", fontSize: "0.8rem" }}>✓</span>}
          </button>
          <button onClick={() => setActiveTab("mistakes")} style={{ flex: 1, padding: "14px", borderRadius: "12px", border: "none", background: activeTab === "mistakes" ? "rgba(139,92,246,0.15)" : "transparent", color: activeTab === "mistakes" ? "#a78bfa" : "#64748b", fontWeight: 800, cursor: "pointer", transition: "0.3s", position: "relative" }}>
            🤫 Mistake {hasSeenMistake && <span style={{ color: "#22c55e", position: "absolute", top: "5px", right: "10px", fontSize: "0.8rem" }}>✓</span>}
          </button>
        </div>

        <AnimatePresence mode="wait">
          {activeTab === "learn" && (
            <motion.div 
              key="learn"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
            >
              <div className="glass-card" style={{ borderRadius: "24px", padding: "32px", marginBottom: "24px" }}>
                <h3 style={{ fontSize: "1.3rem", fontWeight: 900, marginBottom: "20px", color: topic.accentColor }}>⚡ Simple Ah Solluvom</h3>
                <p style={{ color: "#cbd5e1", lineHeight: 1.8, fontSize: "1.1rem" }}>{topic.quickSummary}</p>
              </div>

              <div style={{ background: `linear-gradient(135deg, ${topic.accentColor}11, #070711)`, borderRadius: "24px", padding: "clamp(20px, 5vw, 32px)", marginBottom: "24px", border: `1px solid ${topic.accentColor}22` }}>
                <h3 style={{ fontSize: "1.2rem", fontWeight: 900, marginBottom: "16px" }}>🎭 Real Life Analogy</h3>
                <p style={{ color: "#fff", marginBottom: "24px", fontSize: "1rem", fontStyle: "italic", lineHeight: 1.6 }}>{topic.analogy?.description}</p>
                <div style={{ display: "flex", flexWrap: "wrap", alignItems: "center", justifyContent: "center", gap: "16px", background: "rgba(0,0,0,0.3)", padding: "24px", borderRadius: "16px" }}>
                  {topic.analogy?.visual?.map((v, i) => (
                    <div key={i} style={{ textAlign: "center", minWidth: "60px" }}>
                      <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 2, delay: i * 0.3 }} style={{ fontSize: "1.8rem" }}>{v.icon}</motion.div>
                      <div style={{ fontSize: "0.65rem", color: "#64748b", fontWeight: 700, marginTop: "6px", textTransform: "uppercase" }}>{v.label}</div>
                    </div>
                  ))}
                </div>
              </div>

              <div style={{ background: "#0a0a1a", border: "1px solid #1e1e3f", borderRadius: "20px", padding: "24px", marginBottom: "24px", boxShadow: "inset 0 0 20px rgba(0,0,0,0.5)" }}>
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
              style={{ padding: "clamp(20px, 6vw, 40px)", borderRadius: "24px" }}
            >
              <div style={{ display: "flex", flexDirection: "column", gap: "12px", marginBottom: "24px" }}>
                <h3 style={{ fontSize: "clamp(1.3rem, 5vw, 1.6rem)", fontWeight: 950, margin: 0 }}>🎯 Concept Purinjithaa?</h3>
                <div style={{ alignSelf: "flex-start", background: "rgba(139,92,246,0.1)", padding: "4px 12px", borderRadius: "100px", color: "#a78bfa", fontSize: "0.75rem", fontWeight: 900 }}>
                  Question {quizIndex + 1} of {quizList.length}
                </div>
              </div>

              {currentQuiz ? (
                <>
                  <p style={{ fontSize: "1.2rem", color: "#f1f5f9", marginBottom: "32px", lineHeight: 1.6 }}>{currentQuiz.question}</p>
                  
                  <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
                    {currentQuiz.options.map((opt, i) => (
                      <motion.button
                        key={`${quizIndex}-${i}`}
                        whileHover={{ x: 10, background: "rgba(139,92,246,0.1)" }}
                        whileTap={{ scale: 0.98 }}
                        onClick={() => handleQuizAnswer(i === currentQuiz.answer)}
                        style={{
                          padding: "20px",
                          borderRadius: "16px",
                          border: "1px solid rgba(255,255,255,0.08)",
                          background: correctAnswer !== null && i === currentQuiz.answer ? "rgba(34,197,94,0.1)" : "rgba(255,255,255,0.02)",
                          color: "#fff",
                          textAlign: "left",
                          cursor: "pointer",
                          fontSize: "1.05rem",
                          fontWeight: 600,
                          transition: "0.3s",
                          borderColor: correctAnswer !== null && i === currentQuiz.answer ? "#22c55e" : "rgba(255,255,255,0.08)"
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
                </>
              ) : (
                <div style={{ textAlign: "center", padding: "40px" }}>
                  <div style={{ fontSize: "3rem", marginBottom: "20px" }}>🏆</div>
                  <h4 style={{ fontWeight: 900, marginBottom: "10px" }}>Mothama mudichitae bro!</h4>
                  <p style={{ color: "#94a3b8" }}>Quiz completed successfully. Now move to Lesson check!</p>
                </div>
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
                      boxShadow: "0 10px 25px rgba(139,92,246,0.4)",
                      opacity: isCompleting ? 0.7 : 1
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

        {/* Community Discussion Panel */}
        <section style={{ borderTop: "1px solid rgba(255,255,255,0.05)", marginTop: "60px", paddingTop: "40px" }}>
           <TopicDiscussion topicId={params.id} />
        </section>

        {/* Share Section */}
        <div style={{ marginTop: "60px", textAlign: "center", borderTop: "1px solid rgba(255,255,255,0.05)", paddingTop: "40px" }}>
          <p style={{ color: "#64748b", marginBottom: "16px", fontWeight: 700 }}>Friends-ku idhai share pannalaam! 📲</p>
          <button onClick={handleShare} style={{ background: "rgba(139,92,246,0.1)", color: "#a78bfa", border: "1px solid rgba(139,92,246,0.2)", padding: "14px 28px", borderRadius: "16px", fontWeight: 800, cursor: "pointer", display: "flex", alignItems: "center", gap: "10px", margin: "0 auto", transition: "0.3s" }}>
            {showShareModal ? "✅ Link Copied!" : (
               <><span style={{ fontSize: "1.2rem" }}>📤</span> Share Progress Card</>
            )}
          </button>
        </div>
      </div>
      
      {/* Badge Notification */}
      {lastUnlockedBadge && (
        <motion.div 
          initial={{ y: -50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          style={{ position: "fixed", top: "75px", left: "20px", right: "20px", margin: "0 auto", maxWidth: "400px", background: "#1e1b4b", border: "2px solid #8b5cf6", borderRadius: "20px", padding: "16px", boxShadow: "0 25px 50px rgba(0,0,0,0.5)", display: "flex", alignItems: "center", gap: "16px", zIndex: 1000 }}
        >
          <div style={{ fontSize: "2.5rem" }}>{lastUnlockedBadge.emoji}</div>
          <div>
            <div style={{ fontSize: "0.7rem", fontWeight: 900, color: "#8b5cf6", textTransform: "uppercase", letterSpacing: "1px" }}>NEW ACHIEVEMENT!</div>
            <div style={{ fontSize: "1.1rem", fontWeight: 900, color: "#fff" }}>{lastUnlockedBadge.title}</div>
            <div style={{ fontSize: "0.8rem", color: "#94a3b8" }}>{lastUnlockedBadge.desc}</div>
          </div>
        </motion.div>
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
