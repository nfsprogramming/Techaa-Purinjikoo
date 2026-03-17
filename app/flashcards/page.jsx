"use client";
import React, { useState, useEffect } from "react";
import { dictionary } from "@/data/topics";
import { motion, AnimatePresence } from "framer-motion";
import Link from "next/link";
import Navbar from "@/components/Navbar";

export default function FlashcardsPage() {
  const [cards, setCards] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isFlipped, setIsFlipped] = useState(false);
  const [direction, setDirection] = useState(0);

  useEffect(() => {
    // Shuffle cards on entry
    const shuffled = [...dictionary].sort(() => Math.random() - 0.5);
    setCards(shuffled);
  }, []);

  const handleNext = () => {
    setDirection(1);
    setIsFlipped(false);
    setTimeout(() => {
      setCurrentIndex((prev) => (prev + 1) % cards.length);
    }, 50);
  };

  const handlePrev = () => {
    setDirection(-1);
    setIsFlipped(false);
    setTimeout(() => {
      setCurrentIndex((prev) => (prev - 1 + cards.length) % cards.length);
    }, 50);
  };

  const handleShuffle = () => {
    const shuffled = [...cards].sort(() => Math.random() - 0.5);
    setCards(shuffled);
    setCurrentIndex(0);
    setIsFlipped(false);
  };

  if (cards.length === 0) return null;

  const currentCard = cards[currentIndex];

  return (
    <div style={{ minHeight: "100vh", background: "#070711", color: "#fff" }}>
      <Navbar />

      <div style={{ maxWidth: "600px", margin: "0 auto", padding: "clamp(80px, 12vh, 100px) 20px 60px", display: "flex", flexDirection: "column", alignItems: "center" }}>

        <div style={{ textAlign: "center", marginBottom: "40px" }}>
          <h1 style={{ fontSize: "clamp(2rem, 8vw, 2.5rem)", fontWeight: 950, marginBottom: "8px", letterSpacing: "-1px" }}>
            ⚡ Flash<span style={{ color: "#8b5cf6" }}>cards</span>
          </h1>
          <p style={{ color: "#94a3b8", fontWeight: 700, fontSize: "clamp(0.9rem, 4vw, 1rem)" }}>Bored? Revisit tech terms in seconds! ☕</p>
        </div>

        {/* Card Container */}
        <div style={{ perspective: "1000px", width: "100%", height: "350px", position: "relative", marginBottom: "40px" }}>
          <AnimatePresence mode="wait">
            <motion.div
              key={currentIndex}
              initial={{ x: direction * 100, opacity: 0, rotateY: 0 }}
              animate={{ x: 0, opacity: 1 }}
              exit={{ x: -direction * 100, opacity: 0 }}
              transition={{ type: "spring", stiffness: 300, damping: 30 }}
              onClick={() => setIsFlipped(!isFlipped)}
              style={{
                width: "100%",
                height: "100%",
                position: "absolute",
                cursor: "pointer",
                transformStyle: "preserve-3d",
              }}
            >
              <motion.div
                animate={{ rotateY: isFlipped ? 180 : 0 }}
                transition={{ duration: 0.6, type: "spring", stiffness: 260, damping: 20 }}
                style={{
                  width: "100%",
                  height: "100%",
                  position: "relative",
                  transformStyle: "preserve-3d",
                }}
              >
                {/* Front Side */}
                <div
                  style={{
                    position: "absolute",
                    inset: 0,
                    backfaceVisibility: "hidden",
                    background: "rgba(255,255,255,0.03)",
                    border: "2px solid rgba(139,92,246,0.3)",
                    borderRadius: "32px",
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    justifyContent: "center",
                    padding: "clamp(20px, 6vw, 40px)",
                    backdropFilter: "blur(20px)",
                    boxShadow: "0 20px 50px rgba(0,0,0,0.5), inset 0 0 20px rgba(139,92,246,0.1)",
                  }}
                >
                  <div style={{ fontSize: "clamp(3.5rem, 12vw, 5rem)", marginBottom: "20px" }}>{currentCard.emoji}</div>
                  <h2 style={{ fontSize: "clamp(1.8rem, 6vw, 2.5rem)", fontWeight: 950, textAlign: "center", margin: 0, lineHeight: 1.1 }}>{currentCard.term}</h2>
                  <p style={{ marginTop: "20px", color: "#64748b", fontWeight: 800, textTransform: "uppercase", fontSize: "0.75rem", letterSpacing: "2px" }}>
                    Click me.. 👆
                  </p>
                </div>

                {/* Back Side */}
                <div
                  style={{
                    position: "absolute",
                    inset: 0,
                    backfaceVisibility: "hidden",
                    background: "linear-gradient(135deg, rgba(139,92,246,0.2), rgba(7,7,17,0.5))",
                    border: "2px solid #8b5cf6",
                    borderRadius: "32px",
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    justifyContent: "center",
                    padding: "clamp(20px, 6vw, 40px)",
                    transform: "rotateY(180deg)",
                    backdropFilter: "blur(20px)",
                  }}
                >
                  <h3 style={{ fontSize: "clamp(0.9rem, 4vw, 1.2rem)", color: "#a78bfa", fontWeight: 900, marginBottom: "16px", textTransform: "uppercase" }}>Definition</h3>
                  <p style={{ fontSize: "clamp(1.1rem, 5vw, 1.4rem)", fontWeight: 600, textAlign: "center", lineHeight: 1.5, color: "#fff" }}>
                    {currentCard.definition}
                  </p>
                </div>
              </motion.div>
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Controls */}
        <div style={{ display: "flex", alignItems: "center", gap: "12px", width: "100%" }}>
          <button
            onClick={handlePrev}
            style={{ flex: 1, padding: "clamp(12px, 3vh, 16px)", borderRadius: "16px", border: "1px solid rgba(255,255,255,0.1)", background: "rgba(255,255,255,0.02)", color: "#fff", fontWeight: 800, cursor: "pointer", fontSize: "clamp(0.85rem, 3vw, 1rem)" }}
          >
            ← Back
          </button>

          <button
            onClick={handleShuffle}
            style={{ width: "clamp(45px, 12vw, 50px)", height: "clamp(45px, 12vw, 50px)", borderRadius: "50%", border: "none", background: "#1e1e3f", color: "#fff", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "1.2rem", flexShrink: 0 }}
            title="Shuffle"
          >
            🔀
          </button>

          <button
            onClick={handleNext}
            style={{ flex: 2, padding: "clamp(12px, 3vh, 16px)", borderRadius: "16px", border: "none", background: "#8b5cf6", color: "#fff", fontWeight: 800, cursor: "pointer", fontSize: "clamp(0.95rem, 4vw, 1.1rem)" }}
          >
            Next One 🚀
          </button>
        </div>

        <div style={{ marginTop: "32px", color: "#64748b", fontSize: "0.85rem", fontWeight: 700 }}>
          {currentIndex + 1} / {cards.length} Cards Viewed
        </div>

        <Link href="/dictionary" style={{ marginTop: "40px", color: "#8b5cf6", textDecoration: "none", fontWeight: 700, fontSize: "0.9rem" }}>
          Go to Full Dictionary 📖
        </Link>
      </div>
    </div>
  );
}
