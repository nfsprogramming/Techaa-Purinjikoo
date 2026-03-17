
"use client";
import Link from "next/link";
import { useUserProgress } from "@/context/UserProgressContext";
import { motion } from "framer-motion";

export default function TopicCard({ topic, index }) {
  const { completedTopics } = useUserProgress();
  const isCompleted = completedTopics.includes(topic.id);

  return (
    <Link href={`/topics/${topic.id}`} style={{ textDecoration: "none" }}>
      <motion.div
        whileHover={{ 
          y: -8, 
          scale: 1.02,
          boxShadow: `0 20px 40px rgba(0,0,0,0.3), 0 0 20px ${topic.accentColor}22` 
        }}
        whileTap={{ scale: 0.98 }}
        style={{
          borderRadius: "16px",
          padding: "28px 24px",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          gap: "16px",
          background: "rgba(255,255,255,0.03)",
          backdropFilter: "blur(12px)",
          border: isCompleted ? "1px solid rgba(34,197,94,0.3)" : "1px solid rgba(255,255,255,0.05)",
          position: "relative",
          transition: "border 0.3s ease"
        }}
      >
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
          whileHover={{ rotate: [0, -10, 10, 0], transition: { duration: 0.3 } }}
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
              color: "#fff",
              marginBottom: "8px",
              letterSpacing: "-0.5px",
            }}
          >
            {topic.title}
          </h3>
          <p
            style={{
              fontSize: "0.9rem",
              color: "#94a3b8",
              lineHeight: 1.6,
            }}
          >
            {topic.shortDesc}
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
              color: topic.accentColor,
            }}
          >
            Purinjiko →
          </span>
          <motion.div
            whileHover={{ x: 3 }}
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
            →
          </motion.div>
        </div>
      </motion.div>
    </Link>
  );
}
