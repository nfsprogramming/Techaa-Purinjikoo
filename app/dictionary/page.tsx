"use client";
import { dictionary } from "@/data/topics";
import { useState } from "react";
import Link from "next/link";

export default function DictionaryPage() {
  const [search, setSearch] = useState("");
  const filtered = dictionary.filter(
    d => d.term.toLowerCase().includes(search.toLowerCase()) || d.definition.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div style={{ minHeight: "100vh", background: "#070711", position: "relative", overflow: "hidden" }}>
      <div style={{ position: "fixed", top: -150, left: -100, width: 400, height: 400, borderRadius: "50%", background: "#8b5cf6", filter: "blur(140px)", opacity: 0.08, pointerEvents: "none" }} />

      <div style={{ maxWidth: 860, margin: "0 auto", padding: "60px 24px 100px", position: "relative", zIndex: 1 }}>

        {/* Back */}
        <Link href="/" style={{ display: "inline-flex", alignItems: "center", gap: 6, color: "#7b7b9a", textDecoration: "none", fontSize: "0.82rem", marginBottom: 32, padding: "6px 14px", background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 8 }}>
          ← Home
        </Link>

        {/* Header */}
        <div style={{ textAlign: "center", marginBottom: 48 }}>
          <div style={{ display: "inline-block", background: "rgba(251,191,36,0.1)", border: "1px solid rgba(251,191,36,0.25)", borderRadius: 100, padding: "5px 16px", marginBottom: 16, fontSize: "0.75rem", color: "#fde68a", fontWeight: 600, letterSpacing: "1px", textTransform: "uppercase" }}>
            📖 Reference
          </div>
          <h1 style={{ fontSize: "clamp(2rem,6vw,3rem)", fontWeight: 900, color: "#fff", letterSpacing: "-2px", marginBottom: 10 }}>
            Tech <span style={{ background: "linear-gradient(135deg,#fbbf24,#f59e0b)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", backgroundClip: "text" }}>Dictionary</span>
          </h1>
          <p style={{ color: "#7b7b9a", fontSize: "0.93rem", maxWidth: 480, margin: "0 auto" }}>
            Complex words, simple ah explain panrom. Kadavul sapathum! 🙏
          </p>
        </div>

        {/* Search */}
        <div style={{ marginBottom: 36, position: "relative" }}>
          <span style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "#555577", fontSize: "1.1rem" }}>🔍</span>
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search terms... (API, Deployment, etc.)"
            style={{
              width: "100%", background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.1)",
              borderRadius: 12, padding: "13px 16px 13px 44px", color: "#fff", fontSize: "0.93rem",
              outline: "none", boxSizing: "border-box", transition: "border-color 0.2s",
            }}
            onFocus={e => (e.target.style.borderColor = "#8b5cf688")}
            onBlur={e => (e.target.style.borderColor = "rgba(255,255,255,0.1)")}
          />
        </div>

        {/* Count */}
        <div style={{ fontSize: "0.78rem", color: "#7b7b9a", marginBottom: 20 }}>
          {filtered.length} terms found
        </div>

        {/* Dictionary grid */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 14 }}>
          {filtered.map((item, i) => (
            <div
              key={item.term}
              style={{
                background: "rgba(255,255,255,0.025)",
                border: "1px solid rgba(255,255,255,0.07)",
                borderRadius: 12, padding: "18px 20px",
                transition: "all 0.25s",
                animationDelay: `${i * 0.04}s`,
              }}
              onMouseEnter={e => {
                (e.currentTarget as HTMLDivElement).style.background = "rgba(255,255,255,0.05)";
                (e.currentTarget as HTMLDivElement).style.transform = "translateY(-3px)";
                (e.currentTarget as HTMLDivElement).style.borderColor = "rgba(139,92,246,0.35)";
              }}
              onMouseLeave={e => {
                (e.currentTarget as HTMLDivElement).style.background = "rgba(255,255,255,0.025)";
                (e.currentTarget as HTMLDivElement).style.transform = "translateY(0)";
                (e.currentTarget as HTMLDivElement).style.borderColor = "rgba(255,255,255,0.07)";
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 10 }}>
                <span style={{ fontSize: "1.6rem" }}>{item.emoji}</span>
                <span style={{ fontWeight: 800, fontSize: "1rem", color: "#fff", letterSpacing: "-0.3px" }}>{item.term}</span>
              </div>
              <p style={{ fontSize: "0.86rem", color: "#9a9ab8", lineHeight: 1.65 }}>{item.definition}</p>
            </div>
          ))}
        </div>

        {filtered.length === 0 && (
          <div style={{ textAlign: "center", padding: "60px 0", color: "#555577" }}>
            <div style={{ fontSize: "2.5rem", marginBottom: 12 }}>🤔</div>
            <p>No terms found for "{search}". Avlo specific term illai! 😅</p>
          </div>
        )}

        {/* Suggest */}
        <div style={{ marginTop: 56, textAlign: "center", background: "rgba(139,92,246,0.04)", border: "1px solid rgba(139,92,246,0.15)", borderRadius: 16, padding: "28px" }}>
          <div style={{ fontSize: "1.5rem", marginBottom: 10 }}>💬</div>
          <p style={{ color: "#9a9ab8", fontSize: "0.9rem", marginBottom: 16 }}>
            New term add pannanum ah? Topics page la doubt submit pannunga — we'll add it!
          </p>
          <Link href="/#topics" style={{ display: "inline-block", background: "linear-gradient(135deg,#8b5cf6,#7c3aed)", color: "#fff", padding: "10px 24px", borderRadius: 10, textDecoration: "none", fontSize: "0.86rem", fontWeight: 700 }}>
            Go to Topics →
          </Link>
        </div>
      </div>
    </div>
  );
}
