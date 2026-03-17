"use client";

export default function FunFact({ text }) {
  return (
    <div
      className="fun-fact-card glass-card"
      style={{
        borderRadius: "14px",
        padding: "24px 28px",
        border: "1px solid rgba(251, 191, 36, 0.2)",
        background: "rgba(251, 191, 36, 0.04)",
        display: "flex",
        gap: "16px",
        alignItems: "flex-start",
      }}
    >
      <div style={{ fontSize: "1.8rem", flexShrink: 0 }}>💡</div>
      <div>
        <div
          style={{
            fontSize: "0.72rem",
            fontWeight: 700,
            letterSpacing: "1.5px",
            textTransform: "uppercase",
            color: "#fbbf24",
            marginBottom: "8px",
          }}
        >
          Fun Fact
        </div>
        <p style={{ fontSize: "0.95rem", color: "#d1d1e8", lineHeight: 1.7 }}>
          {text}
        </p>
      </div>
    </div>
  );
}
