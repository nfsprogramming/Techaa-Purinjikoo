"use client";
import { useParams, useRouter } from "next/navigation";
import { topics } from "@/data/topics";
import { useState, useEffect } from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { useUserProgress } from "@/context/UserProgressContext";
import { XP_AWARDS } from "@/data/gamification";

export default function TopicPage() {
  const params = useParams();
  const router = useRouter();
  const topic = topics.find((t) => t.id === params.id);
  const { completeTopic, addXP, unlockedBadges, BADGES, completedTopics } = useUserProgress();
  const [activeTab, setActiveTab] = useState("learn"); // learn, quiz, mistakes
  const [correctAnswer, setCorrectAnswer] = useState(null);
  const [showShareModal, setShowShareModal] = useState(false);
  const [lastUnlockedBadge, setLastUnlockedBadge] = useState(null);
  const [hasAwardedQuizXP, setHasAwardedQuizXP] = useState(false);
  const [xpToast, setXpToast] = useState(null);

  const [timeOnPage, setTimeOnPage] = useState(0);
  const [readingCompleted, setReadingCompleted] = useState(false);
  const isAlreadyCompleted = completedTopics?.includes(topic?.id);

  // Timer for time-based completion (1 min threshold)
  useEffect(() => {
    if (!topic || isAlreadyCompleted || readingCompleted) return;

    const timer = setInterval(() => {
      setTimeOnPage(prev => {
        const nextTime = prev + 1;
        if (nextTime >= 60 && !readingCompleted) {
          // Award XP for reading after 1 minute
          completeTopic(topic.id);
          setReadingCompleted(true);
          setXpToast(`+${XP_AWARDS.READ_TOPIC} XP ✨ Badge Earned!`);
          setTimeout(() => setXpToast(null), 3000);
          clearInterval(timer);
        }
        return nextTime;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [topic?.id, isAlreadyCompleted, readingCompleted]);

  // Show badge unlock notification
  useEffect(() => {
    if (unlockedBadges.length > 0) {
      const latestBadgeId = unlockedBadges[unlockedBadges.length - 1];
      const badge = BADGES.find(b => b.id === latestBadgeId);
      if (badge) {
        setLastUnlockedBadge(badge);
        const timer = setTimeout(() => setLastUnlockedBadge(null), 5000);
        return () => clearTimeout(timer);
      }
    }
  }, [unlockedBadges.length]);

  const handleQuizAnswer = (isCorrect) => {
    setCorrectAnswer(isCorrect);
    if (isCorrect && !hasAwardedQuizXP) {
      addXP(XP_AWARDS.QUIZ_CORRECT);
      setHasAwardedQuizXP(true);
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

  const handleShare = () => {
    setShowShareModal(true);
    setTimeout(() => setShowShareModal(false), 2000);
    navigator.clipboard.writeText(`Did you know? ${topic.title}: ${topic.shortDesc} Learn more at http://localhost:3000/topics/${topic.id}`);
  };

  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff" }}>

      <div style={{ maxWidth: "800px", margin: "0 auto", padding: "100px 24px 60px" }}>
        {/* Header Section */}
        <div style={{ textAlign: "center", marginBottom: "40px" }}>
          {!isAlreadyCompleted && !readingCompleted && (
            <div style={{ width: "100%", height: "4px", background: "rgba(255,255,255,0.05)", borderRadius: "2px", marginBottom: "20px", overflow: "hidden" }}>
              <div style={{ width: `${(timeOnPage / 60) * 100}%`, height: "100%", background: "#8b5cf6", transition: "width 1s linear" }} />
              <div style={{ fontSize: "0.6rem", color: "#64748b", marginTop: "4px", textAlign: "right", letterSpacing: "1px" }}>READING PROGRESS: {Math.round((timeOnPage / 60) * 100)}%</div>
            </div>
          )}
          <div style={{ fontSize: "4rem", marginBottom: "16px" }}>{topic.emoji}</div>
          <h1 style={{ fontSize: "2.5rem", fontWeight: 900, marginBottom: "8px" }}>{topic.title}</h1>
          <p style={{ color: topic.accentColor, fontWeight: 700, letterSpacing: "1px", textTransform: "uppercase", fontSize: "0.8rem" }}>{topic.tagline}</p>
        </div>

        {/* Navigation Tabs */}
        <div style={{ display: "flex", gap: "8px", background: "rgba(255,255,255,0.03)", padding: "4px", borderRadius: "12px", marginBottom: "32px" }}>
          <button onClick={() => setActiveTab("learn")} style={{ flex: 1, padding: "12px", borderRadius: "8px", border: "none", background: activeTab === "learn" ? "rgba(139,92,246,0.15)" : "transparent", color: activeTab === "learn" ? "#8b5cf6" : "#94a3b8", fontWeight: 700, cursor: "pointer" }}>📖 Learn</button>
          <button onClick={() => setActiveTab("quiz")} style={{ flex: 1, padding: "12px", borderRadius: "8px", border: "none", background: activeTab === "quiz" ? "rgba(139,92,246,0.15)" : "transparent", color: activeTab === "quiz" ? "#8b5cf6" : "#94a3b8", fontWeight: 700, cursor: "pointer" }}>⏳ Quiz</button>
          <button onClick={() => setActiveTab("mistakes")} style={{ flex: 1, padding: "12px", borderRadius: "8px", border: "none", background: activeTab === "mistakes" ? "rgba(139,92,246,0.15)" : "transparent", color: activeTab === "mistakes" ? "#8b5cf6" : "#94a3b8", fontWeight: 700, cursor: "pointer" }}>🤫 Mistakes</button>
        </div>

        {activeTab === "learn" && (
          <div style={{ animation: "fadeIn 0.5s ease" }}>
            {/* Quick Summary */}
            <div style={{ background: "rgba(255,255,255,0.03)", borderRadius: "24px", padding: "32px", marginBottom: "24px", border: "1px solid rgba(255,255,255,0.05)" }}>
              <h3 style={{ fontSize: "1.2rem", fontWeight: 800, marginBottom: "16px", display: "flex", alignItems: "center", gap: "8px" }}>⚡ Simple Ah Solluvom</h3>
              <p style={{ color: "#cbd5e1", lineHeight: 1.7, fontSize: "1.1rem" }}>{topic.quickSummary}</p>
            </div>

            {/* Analogy */}
            <div style={{ background: "linear-gradient(135deg, rgba(139,92,246,0.1), rgba(6,182,212,0.1))", borderRadius: "24px", padding: "32px", marginBottom: "24px", border: "1px solid rgba(255,255,255,0.05)" }}>
              <h3 style={{ fontSize: "1.2rem", fontWeight: 800, marginBottom: "16px" }}>🎭 Real Life Analogy</h3>
              <p style={{ color: "#fff", marginBottom: "24px", fontSize: "1.05rem" }}>{topic.analogy?.description}</p>
              <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: "12px", background: "rgba(0,0,0,0.2)", padding: "24px", borderRadius: "16px" }}>
                {topic.analogy?.visual?.map((v, i) => (
                  <div key={i} style={{ textAlign: "center" }}>
                    <div style={{ fontSize: "1.5rem" }}>{v.icon}</div>
                    <div style={{ fontSize: "0.7rem", color: "#94a3b8", marginTop: "4px" }}>{v.label}</div>
                  </div>
                ))}
              </div>
            </div>

            {/* Conversation */}
            <div style={{ background: "#0a0a1a", border: "1px solid #1e1e3f", borderRadius: "16px", padding: "20px", marginBottom: "24px", fontFamily: "monospace" }}>
              <div style={{ display: "flex", gap: "6px", marginBottom: "16px" }}>
                <div style={{ width: "12px", height: "12px", borderRadius: "50%", background: "#ff5f56" }} />
                <div style={{ width: "12px", height: "12px", borderRadius: "50%", background: "#ffbd2e" }} />
                <div style={{ width: "12px", height: "12px", borderRadius: "50%", background: "#27c93f" }} />
              </div>
              <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                {topic.conversation?.map((msg, i) => (
                  <div key={i} style={{ display: "flex", gap: "12px" }}>
                    <span style={{ fontSize: "1.2rem" }}>{msg.avatar}</span>
                    <div>
                      <span style={{ color: "#8b5cf6", fontWeight: "bold" }}>{msg.speaker}: </span>
                      <span style={{ color: "#d1d5db" }}>{msg.message}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {activeTab === "quiz" && (
          <div style={{ background: "rgba(255,255,255,0.03)", padding: "32px", borderRadius: "24px", animation: "fadeIn 0.5s ease" }}>
            <h3 style={{ fontSize: "1.4rem", fontWeight: 800, marginBottom: "24px" }}>🎯 Concept Purinjithaa nu check pannuvom!</h3>
            <p style={{ fontSize: "1.1rem", marginBottom: "24px" }}>{topic.quiz?.question || "Intha topic-ku quiz innum upload panla bro! 😅"}</p>
            {topic.quiz && (
              <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
                {topic.quiz.options.map((opt, i) => (
                  <button
                    key={i}
                    onClick={() => handleQuizAnswer(i === topic.quiz.answer)}
                    style={{
                      padding: "16px",
                      borderRadius: "12px",
                      border: "1px solid rgba(255,255,255,0.1)",
                      background: "rgba(255,255,255,0.05)",
                      color: "#fff",
                      textAlign: "left",
                      cursor: "pointer",
                      fontSize: "1rem",
                      transition: "0.2s"
                    }}
                  >
                    {opt}
                  </button>
                ))}
              </div>
            )}
            {correctAnswer !== null && (
              <div style={{ marginTop: "24px", padding: "16px", borderRadius: "12px", background: correctAnswer ? "rgba(34,197,94,0.1)" : "rgba(239,68,68,0.1)", color: correctAnswer ? "#4ade80" : "#f87171", textAlign: "center", fontWeight: 700 }}>
                {correctAnswer ? "Semma! Correct-ah sollita 🔥" : "Illa bro, oru vaati munaadi poi marubadiyum padi! 😅"}
              </div>
            )}
          </div>
        )}

        {activeTab === "mistakes" && (
          <div style={{ animation: "fadeIn 0.5s ease" }}>
            <div style={{ background: "rgba(239,68,68,0.05)", border: "1px solid rgba(239,68,68,0.2)", borderRadius: "24px", padding: "32px", marginBottom: "24px" }}>
              <h3 style={{ fontSize: "1.2rem", fontWeight: 800, color: "#f87171", marginBottom: "16px" }}>🛑 Developer Mistake</h3>
              <p style={{ color: "#fca5a5", fontSize: "1.1rem" }}>"{topic.devConfession?.mistake}"</p>
            </div>
            <div style={{ background: "rgba(34,197,94,0.05)", border: "1px solid rgba(34,197,94,0.2)", borderRadius: "24px", padding: "32px" }}>
              <h3 style={{ fontSize: "1.2rem", fontWeight: 800, color: "#4ade80", marginBottom: "16px" }}>💡 Lesson Learned</h3>
              <p style={{ color: "#86efac", fontSize: "1.1rem" }}>{topic.devConfession?.lesson}</p>
            </div>
          </div>
        )}

        {/* Share Section */}
        <div style={{ marginTop: "60px", textAlign: "center", borderTop: "1px solid rgba(255,255,255,0.05)", paddingTop: "40px" }}>
          <button 
            onClick={handleShare}
            style={{ 
              background: "rgba(139,92,246,0.1)", 
              color: "#8b5cf6", 
              border: "1px solid rgba(139,92,246,0.3)", 
              padding: "12px 24px", 
              borderRadius: "12px", 
              fontWeight: 700, 
              cursor: "pointer",
              display: "flex",
              alignItems: "center",
              gap: "8px",
              margin: "0 auto"
            }}
          >
            {showShareModal ? "✅ Copied to Clipboard!" : "📱 Share as a Tech Card"}
          </button>
        </div>
        
        {/* Badge Notification */}
        {lastUnlockedBadge && (
          <div style={{ position: "fixed", top: "80px", right: "24px", background: "linear-gradient(135deg, #1e1b4b, #312e81)", border: "1px solid #8b5cf6", borderRadius: "16px", padding: "16px 20px", boxShadow: "0 20px 40px rgba(0,0,0,0.4)", display: "flex", alignItems: "center", gap: "16px", zIndex: 1000, animation: "slideIn 0.5s cubic-bezier(0.16, 1, 0.3, 1)" }}>
            <div style={{ fontSize: "2.5rem" }}>{lastUnlockedBadge.emoji}</div>
            <div>
              <div style={{ fontSize: "0.7rem", fontWeight: 800, color: "#8b5cf6", textTransform: "uppercase", letterSpacing: "1px" }}>Badge Unlocked!</div>
              <div style={{ fontSize: "1.1rem", fontWeight: 800, color: "#fff" }}>{lastUnlockedBadge.title}</div>
              <div style={{ fontSize: "0.8rem", color: "#94a3b8" }}>{lastUnlockedBadge.desc}</div>
            </div>
          </div>
        )}
      </div>

      {/* XP Toast */}
      {xpToast && (
        <div style={{ position: "fixed", bottom: "40px", left: "50%", transform: "translateX(-50%)", background: "#8b5cf6", color: "#fff", padding: "12px 24px", borderRadius: "100px", fontWeight: 800, fontSize: "1.2rem", boxShadow: "0 10px 30px rgba(139,92,246,0.5)", zIndex: 1000, animation: "bounceUp 0.3s ease-out" }}>
          {xpToast} ✨
        </div>
      )}
    </div>
  );
}
