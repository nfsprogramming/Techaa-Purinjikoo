"use client";

export default function UseCaseCard({ useCase, accentColor }) {
  return (
    <div
      className="usecase-card glass-card"
      style={{
        borderRadius: "12px",
        padding: "20px",
        display: "flex",
        gap: "16px",
        alignItems: "flex-start",
      }}
    >
      <div
        style={{
          width: "42px",
          height: "42px",
          borderRadius: "10px",
          background: `${accentColor}18`,
          border: `1px solid ${accentColor}33`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: "1.3rem",
          flexShrink: 0,
        }}
      >
        {useCase.icon}
      </div>
      <div>
        <h4
          style={{
            fontWeight: 700,
            fontSize: "0.92rem",
            color: "#fff",
            marginBottom: "5px",
          }}
        >
          {useCase.title}
        </h4>
        <p style={{ fontSize: "0.84rem", color: "#7b7b9a", lineHeight: 1.6 }}>
          {useCase.desc}
        </p>
      </div>
    </div>
  );
}
