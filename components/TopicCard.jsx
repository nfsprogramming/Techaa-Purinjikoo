
"use client";
import Link from "next/link";
import { useUserProgress } from "@/context/UserProgressContext";
import { motion } from "framer-motion";

export default function TopicCard({ topic, index }) {
  const { completedTopics, isTopicLocked, completedReadings, completedQuizzes, viewedMistakes } = useUserProgress();
  const isCompleted = completedTopics.includes(topic.id);
  const isLocked = isTopicLocked(topic.id);

  // Granular progress
  const hasRead = (completedReadings || []).includes(topic.id) || isCompleted;
  const hasQuiz = (completedQuizzes || []).includes(topic.id) || isCompleted;
  const hasMistake = (viewedMistakes || []).includes(topic.id) || isCompleted;

  const cardContent = (
    <motion.div
      whileHover={!isLocked ? { 
        y: -10, 
        scale: 1.02,
        boxShadow: `0 20px 40px rgba(0,0,0,0.4), 0 0 20px ${topic.accentColor}22` 
      } : {}}
      whileTap={!isLocked ? { scale: 0.98 } : {}}
      style={{
        borderRadius: "24px",
        padding: "24px 20px",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        gap: "12px",
        background: isLocked ? "rgba(255,255,255,0.01)" : "rgba(255,255,255,0.03)",
        backdropFilter: "blur(20px)",
        border: isLocked ? "1px solid rgba(255,255,255,0.02)" : (isCompleted ? "1px solid #22c55e" : "1px solid rgba(255,255,255,0.07)"),
        position: "relative",
        transition: "all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)",
        opacity: isLocked ? 0.5 : 1,
        cursor: isLocked ? "not-allowed" : "pointer",
        overflow: "hidden"
      }}
    >
      {/* Status Indicators */}
      {isCompleted && (
        <motion.div 
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          style={{ position: "absolute", top: "16px", right: "16px", background: "#22c55e", color: "#fff", width: "24px", height: "24px", borderRadius: "50%", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "0.8rem", boxShadow: "0 0 15px rgba(34,197,94,0.5)", zIndex: 5 }}
        >
          ✓
        </motion.div>
      )}

      {/* Decorative Glow */}
      <div style={{ position: "absolute", top: -50, left: -50, width: 200, height: 200, background: `radial-gradient(circle, ${topic.accentColor}11 0%, transparent 70%)`, pointerEvents: "none", zIndex: 0 }} />

      {/* Emoji Area */}
      <motion.div 
        animate={isLocked ? {} : { y: [0, -5, 0] }}
        transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
        style={{ fontSize: "3.5rem", lineHeight: 1, zIndex: 1, filter: isLocked ? "grayscale(100%) blur(1px)" : "none" }}
      >
        {topic.emoji}
      </motion.div>

      {/* Content Area */}
      <div style={{ zIndex: 1 }}>
        <h3 style={{ fontSize: "1.4rem", fontWeight: 900, color: isLocked ? "#4b5563" : "#fff", marginBottom: "4px", letterSpacing: "-0.5px" }}>
          {topic.title}
        </h3>
        <p style={{ fontSize: "0.85rem", color: isLocked ? "#374151" : "#94a3b8", lineHeight: 1.5, marginBottom: "12px", display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden" }}>
          {isLocked ? "Complete previous topics to unlock!" : topic.shortDesc}
        </p>

        {/* Granular Progress Bar */}
        {!isLocked && (
          <div style={{ display: "flex", flexWrap: "wrap", gap: "10px", marginBottom: "8px" }}>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: "0.6rem", color: "#64748b", fontWeight: 900, textTransform: "uppercase", marginBottom: "4px" }}>Progress</div>
              <div style={{ display: "flex", gap: "4px", height: "6px" }}>
                <div style={{ flex: 1, background: hasRead ? topic.accentColor : "rgba(255,255,255,0.05)", borderRadius: "2px", transition: "0.3s" }} title="Read" />
                <div style={{ flex: 1, background: hasQuiz ? topic.accentColor : "rgba(255,255,255,0.05)", borderRadius: "2px", transition: "0.3s" }} title="Quiz" />
                <div style={{ flex: 1, background: hasMistake ? topic.accentColor : "rgba(255,255,255,0.05)", borderRadius: "2px", transition: "0.3s" }} title="Mistake" />
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Bottom Action Area */}
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: "auto", paddingTop: "12px", zIndex: 1, borderTop: "1px solid rgba(255,255,255,0.05)" }}>
        <span style={{ fontSize: "0.85rem", fontWeight: 800, color: isLocked ? "#374151" : topic.accentColor, textTransform: "uppercase", letterSpacing: "1px" }}>
          {isLocked ? "Locked" : "Purinjiko"}
        </span>
        
        <div style={{ width: "32px", height: "32px", borderRadius: "50%", background: isLocked ? "rgba(255,255,255,0.02)" : "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "1rem" }}>
          {isLocked ? "🔒" : "→"}
        </div>
      </div>

    </motion.div>
  );

  if (isLocked) return cardContent;

  return (
    <Link href={`/topics/${topic.id}`} style={{ textDecoration: "none", display: "block", height: "100%" }}>
      {cardContent}
    </Link>
  );
}
