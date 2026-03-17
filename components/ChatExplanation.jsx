"use client";

const avatarColors = {
  "👨‍💻": "#8b5cf6",
  "🧑‍🚀": "#06b6d4",
  "👩‍💻": "#ec4899",
  "🧑‍💻": "#10b981",
  "👨‍🔬": "#f59e0b",
  "🧑‍🎓": "#06b6d4",
  "👩‍🎓": "#ec4899",
};

export default function ChatExplanation({ messages, accentColor }) {
  return (
    <div
      style={{
        background: "rgba(255,255,255,0.02)",
        border: "1px solid rgba(255,255,255,0.07)",
        borderRadius: "16px",
        padding: "8px 0",
        overflow: "hidden",
      }}
    >
      {/* Chat header */}
      <div
        style={{
          padding: "12px 24px",
          borderBottom: "1px solid rgba(255,255,255,0.06)",
          display: "flex",
          alignItems: "center",
          gap: "10px",
        }}
      >
        <div
          style={{
            width: "8px",
            height: "8px",
            borderRadius: "50%",
            background: accentColor,
            boxShadow: `0 0 8px ${accentColor}`,
          }}
        />
        <span style={{ fontSize: "0.8rem", color: "#7b7b9a", fontWeight: 500 }}>
          Friend Conversation — Real talk la purinjikalam 😎
        </span>
      </div>

      {/* Messages */}
      <div style={{ padding: "8px 24px" }}>
        {messages.map((msg, i) => {
          const color = avatarColors[msg.avatar] || accentColor;
          return (
            <div
              key={i}
              className="chat-line"
              style={{
                display: "flex",
                gap: "14px",
                alignItems: "flex-start",
                padding: "14px 8px",
              }}
            >
              {/* Avatar */}
              <div
                style={{
                  minWidth: "36px",
                  height: "36px",
                  borderRadius: "50%",
                  background: `${color}22`,
                  border: `1.5px solid ${color}55`,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontSize: "1.1rem",
                  flexShrink: 0,
                  marginTop: "2px",
                }}
              >
                {msg.avatar}
              </div>

              {/* Content */}
              <div style={{ flex: 1 }}>
                <span
                  style={{
                    fontWeight: 700,
                    fontSize: "0.82rem",
                    color: color,
                    marginRight: "10px",
                    letterSpacing: "0.3px",
                  }}
                >
                  {msg.speaker}
                </span>
                <p
                  style={{
                    marginTop: "5px",
                    fontSize: "0.95rem",
                    color: "#d1d1e8",
                    lineHeight: 1.7,
                  }}
                >
                  {msg.message}
                </p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
