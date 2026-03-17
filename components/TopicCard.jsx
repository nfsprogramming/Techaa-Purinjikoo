"use client";
import Link from "next/link";
import { useUserProgress } from "@/context/UserProgressContext";

export default function TopicCard({ topic, index }) {
  const { completedTopics } = useUserProgress();
  const isCompleted = completedTopics.includes(topic.id);

  return (
    <Link href={`/topics/${topic.id}`} style={{ textDecoration: "none" }}>
      <div
        className="topic-card glass-card glow-on-hover"
        style={{
          borderRadius: "16px",
          padding: "28px 24px",
          animationDelay: `${index * 0.08}s`,
          height: "100%",
          display: "flex",
          flexDirection: "column",
          gap: "16px",
          border: isCompleted ? "1px solid rgba(34,197,94,0.3)" : "1px solid rgba(255,255,255,0.05)",
          position: "relative"
        }}
      >
        {isCompleted && (
          <div style={{ position: "absolute", top: "12px", right: "12px", background: "#22c55e", color: "#fff", width: "20px", height: "20px", borderRadius: "50%", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "0.7rem", boxShadow: "0 4px 10px rgba(34,197,94,0.3)" }}>
            ✓
          </div>
        )}
        {/* Gradient top bar */}
        <div
          style={{
            height: "3px",
            borderRadius: "2px",
            background: `linear-gradient(90deg, ${topic.accentColor}, transparent)`,
            marginBottom: "4px",
          }}
        />

        {/* Emoji */}
        <div style={{ fontSize: "2.6rem", lineHeight: 1 }}>{topic.emoji}</div>

        {/* Title */}
        <div>
          <h3
            style={{
              fontSize: "1.2rem",
              fontWeight: 700,
              color: "#fff",
              marginBottom: "6px",
              letterSpacing: "-0.3px",
            }}
          >
            {topic.title}
          </h3>
          <p
            style={{
              fontSize: "0.88rem",
              color: "#7b7b9a",
              lineHeight: 1.6,
            }}
          >
            {topic.shortDesc}
          </p>
        </div>

        {/* Tagline */}
        <div
          style={{
            fontSize: "0.78rem",
            color: topic.accentColor,
            fontStyle: "italic",
            marginTop: "auto",
          }}
        >
          {topic.tagline}
        </div>

        {/* CTA */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            marginTop: "4px",
          }}
        >
          <span
            style={{
              fontSize: "0.82rem",
              fontWeight: 600,
              color: topic.accentColor,
            }}
          >
            Purinjiko →
          </span>
          <div
            style={{
              width: "28px",
              height: "28px",
              borderRadius: "50%",
              background: "rgba(255,255,255,0.06)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: "0.85rem",
            }}
          >
            →
          </div>
        </div>
      </div>
    </Link>
  );
}
