
"use client";
import Link from "next/link";
import { useUserProgress } from "@/context/UserProgressContext";
import { motion } from "framer-motion";

export default function TopicCard({ topic, index }) {
  const { completedTopics, isTopicLocked } = useUserProgress();
  const isCompleted = completedTopics.includes(topic.id);
  const isLocked = isTopicLocked(topic.id);

  const cardContent = (
    <motion.div
      whileHover={!isLocked ? { 
        y: -8, 
        scale: 1.02,
        boxShadow: `0 20px 40px rgba(0,0,0,0.3), 0 0 20px ${topic.accentColor}22` 
      } : {}}
      whileTap={!isLocked ? { scale: 0.98 } : {}}
      style={{
        borderRadius: "16px",
        padding: "28px 24px",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        gap: "16px",
        background: isLocked ? "rgba(255,255,255,0.01)" : "rgba(255,255,255,0.03)",
        backdropFilter: "blur(12px)",
        border: isLocked ? "1px solid rgba(255,255,255,0.02)" : (isCompleted ? "1px solid rgba(34,197,94,0.3)" : "1px solid rgba(255,255,255,0.05)"),
        position: "relative",
        transition: "all 0.3s ease",
        opacity: isLocked ? 0.6 : 1,
        cursor: isLocked ? "not-allowed" : "pointer"
      }}
    >
      {isLocked && (
        <div style={{ position: "absolute", top: "12px", right: "12px", background: "rgba(0,0,0,0.5)", width: "32px", height: "32px", borderRadius: "50%", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 2 }}>
          <span style={{ fontSize: "1.2rem" }}>🔒</span>
        </div>
      )}

      {isCompleted && (
          <motion.div 
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            style={{ position: "absolute", top: "12px", right: "12px", background: "#22c55e", color: "#fff", width: "22px", height: "22px", borderRadius: "50%", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "0.75rem", boxShadow: "0 4px 10px rgba(34,197,94,0.4)", zIndex: 1 }}
          >
            ✓
          </motion.div>
        )}
        
      {/* Glow effect */}
        <div style={{ position: "absolute", top: 0, left: 0, right: 0, bottom: 0, background: `radial-gradient(circle at 50% 0%, ${topic.accentColor}11, transparent 70%)`, pointerEvents: "none", borderRadius: "16px" }} />

        {/* Emoji */}
        <motion.div 
          whileHover={!isLocked ? { rotate: [0, -10, 10, 0], transition: { duration: 0.3 } } : {}}
          style={{ fontSize: "2.8rem", lineHeight: 1 }}
        >
          {topic.emoji}
        </motion.div>

        {/* Title */}
        <div>
          <h3
            style={{
              fontSize: "1.25rem",
              fontWeight: 800,
              color: isLocked ? "#64748b" : "#fff",
              marginBottom: "8px",
              letterSpacing: "-0.5px",
            }}
          >
            {topic.title}
          </h3>
          <p
            style={{
              fontSize: "0.9rem",
              color: isLocked ? "#475569" : "#94a3b8",
              lineHeight: 1.6,
            }}
          >
            {isLocked ? "Complete previous topics to unlock! 🔒" : topic.shortDesc}
          </p>
        </div>

        {/* CTA */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            marginTop: "auto",
            paddingTop: "12px"
          }}
        >
          <span
            style={{
              fontSize: "0.85rem",
              fontWeight: 800,
              color: isLocked ? "#475569" : topic.accentColor,
            }}
          >
            {isLocked ? "Locked" : "Purinjiko →"}
          </span>
          <motion.div
            whileHover={!isLocked ? { x: 3 } : {}}
            style={{
              width: "32px",
              height: "32px",
              borderRadius: "50%",
              background: "rgba(255,255,255,0.05)",
              border: "1px solid rgba(255,255,255,0.1)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: "0.9rem",
            }}
          >
            {isLocked ? "🔒" : "→"}
          </motion.div>
        </div>
    </motion.div>
  );

  if (isLocked) {
    return cardContent;
  }

  return (
    <Link href={`/topics/${topic.id}`} style={{ textDecoration: "none" }}>
      {cardContent}
    </Link>
  );
}
