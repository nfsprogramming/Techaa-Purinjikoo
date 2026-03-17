"use client";
import React, { useState, useEffect } from "react";
import { useParams, useRouter } from "next/navigation";
import { useAuth } from "@/context/AuthContext";
import { useUserProgress } from "@/context/UserProgressContext";
import { db } from "@/lib/firebase";
import { doc, getDoc, updateDoc, onSnapshot } from "firebase/firestore";
import Navbar from "@/components/Navbar";
import { motion, AnimatePresence } from "framer-motion";

export default function BattleDetail() {
  const { id } = useParams();
  const router = useRouter();
  const { user } = useAuth();
  const { addXP } = useUserProgress();
  
  const [battle, setBattle] = useState(null);
  const [loading, setLoading] = useState(true);
  const [gameState, setGameState] = useState("intro"); // intro, playing, finished
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [score, setScore] = useState(0);
  const [showResult, setShowResult] = useState(null);
  const [selectedAnswer, setSelectedAnswer] = useState(null);
  const [sharing, setSharing] = useState(false);

  useEffect(() => {
    if (!id) return;
    const unsub = onSnapshot(doc(db, "battles", id), (docSnap) => {
      if (docSnap.exists()) {
        setBattle({ id: docSnap.id, ...docSnap.data() });
      }
      setLoading(false);
    });
    return () => unsub();
  }, [id]);

  const handleAnswer = (index) => {
    const isCorrect = index === battle.questions[currentQuestionIndex].answer;
    setSelectedAnswer(index);
    setShowResult(isCorrect);
    
    let currentScore = score;
    if (isCorrect) {
      currentScore += 1;
      setScore(currentScore);
    }

    setTimeout(() => {
      if (currentQuestionIndex < battle.questions.length - 1) {
        setShowResult(null);
        setSelectedAnswer(null);
        setCurrentQuestionIndex(prev => prev + 1);
      } else {
        finishGame(currentScore);
      }
    }, 1000);
  };

  const finishGame = async (finalScore) => {
    setGameState("finished");
    
    // Update Firestore
    try {
      const docRef = doc(db, "battles", id);
      const newResults = { ...battle.results, [user.uid]: finalScore };
      const newParticipants = Array.from(new Set([...battle.participants, user.uid]));
      
      const updateData = {
        results: newResults,
        participants: newParticipants
      };

      if (Object.keys(newResults).length >= 2) {
        updateData.status = "completed";
      }

      await updateDoc(docRef, updateData);
      
      // Award XP for participating
      addXP(20, "Participated in Battle ⚔️");
      
      // If won, extra XP (checked only when both finished)
      // This is simplified, real async logic would check winner and award once
    } catch (err) {
      console.error("Finish game error:", err);
    }
  };

  const shareBattle = () => {
    setSharing(true);
    const text = `Techaa Purinjikoo Quiz Battle! Challenge accepted-ah bro? ⚔️ Join here: ${window.location.href}`;
    navigator.clipboard.writeText(text);
    setTimeout(() => setSharing(false), 2000);
  };

  if (loading) return <div>Loading...</div>;
  if (!battle) return <div>Battle not found!</div>;

  const userResult = battle.results[user?.uid];
  const isOpponent = user && user.uid !== battle.creatorId;
  const isWaitingForOpponent = battle.status === "waiting" && userResult !== undefined;
  const hasOpponentPlayed = Object.keys(battle.results).length >= 2;

  // Render Logic
  return (
    <div style={{ minHeight: "100vh", background: "#070711", color: "#fff" }}>
      <Navbar />
      <div style={{ maxWidth: "600px", margin: "0 auto", padding: "clamp(80px, 12vh, 100px) 20px 60px" }}>
        
        {gameState === "intro" && (
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} style={{ textAlign: "center" }}>
            <div style={{ fontSize: "clamp(3rem, 15vw, 5rem)", marginBottom: "20px" }}>⚔️</div>
            <h1 style={{ fontSize: "clamp(1.5rem, 6vw, 2rem)", fontWeight: 900, marginBottom: "16px", lineHeight: 1.2 }}>
              {isOpponent ? `${battle.creatorName} Challenges You!` : "Your Challenge is Ready!"}
            </h1>
            <p style={{ color: "#94a3b8", marginBottom: "32px", lineHeight: 1.6, fontSize: "clamp(0.9rem, 4vw, 1rem)" }}>
                 5 Questions, 1 Ultimate Winner. Correct updates XP increase panna help pannum! 🚀
            </p>

            {typeof userResult !== 'number' ? (
              <button 
                onClick={() => setGameState("playing")}
                style={{ background: "#8b5cf6", color: "#fff", padding: "clamp(14px, 4vw, 18px) clamp(24px, 8vw, 40px)", borderRadius: "16px", border: "none", fontWeight: 900, fontSize: "clamp(1rem, 4vw, 1.2rem)", cursor: "pointer", width: "100%" }}
              >
                {userResult === null ? "START BATTLE! 🚀" : "JOIN BATTLE! ⚔️"}
              </button>
            ) : (
              <div style={{ background: "rgba(139,92,246,0.1)", padding: "clamp(20px, 5vw, 30px)", borderRadius: "24px", border: "1px solid rgba(139,92,246,0.2)" }}>
                 <h3 style={{ margin: 0, fontSize: "clamp(1.1rem, 5vw, 1.3rem)" }}>You scored {userResult}/5</h3>
                 <p style={{ color: "#a78bfa", fontWeight: 800, marginTop: "10px", fontSize: "0.9rem" }}>
                    {battle.status === "completed" ? "Battle Finished! Check results below." : "Waiting for opponent to finish... ⏳"}
                 </p>
                 <button 
                    onClick={shareBattle}
                    style={{ marginTop: "20px", background: "rgba(255,255,255,0.05)", color: "#fff", border: "1px solid rgba(255,255,255,0.1)", padding: "12px 24px", borderRadius: "12px", cursor: "pointer", fontWeight: 800, width: "100%", fontSize: "0.9rem" }}
                 >
                    {sharing ? "✅ Link Copied!" : "📤 Share Link With Friend"}
                 </button>
              </div>
            )}

            {hasOpponentPlayed && (
              <div style={{ marginTop: "40px", textAlign: "left" }}>
                <h2 style={{ fontSize: "1.2rem", fontWeight: 900, marginBottom: "16px" }}>Results 🏆</h2>
                <div style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
                   {Object.entries(battle.results).map(([uid, score]) => (
                     <div key={uid} style={{ background: "rgba(255,255,255,0.02)", padding: "16px", borderRadius: "16px", display: "flex", justifyContent: "space-between", border: "1px solid rgba(255,255,255,0.05)" }}>
                        <span style={{ fontWeight: 800 }}>{uid === user?.uid ? "You" : "Opponent"}</span>
                        <span style={{ color: "#8b5cf6", fontWeight: 900 }}>{score}/5</span>
                     </div>
                   ))}
                </div>
                {/* Simplified winner logic */}
                <div style={{ marginTop: "24px", padding: "20px", borderRadius: "16px", background: "rgba(34,197,94,0.1)", border: "1px solid #22c55e", textAlign: "center", color: "#4ade80", fontWeight: 900 }}>
                   {Object.values(battle.results)[0] > Object.values(battle.results)[1] ? "Game On! Semma performance 🚀" : "Ultimate Battle Finished! 🔥"}
                </div>
              </div>
            )}
          </motion.div>
        )}

        {gameState === "playing" && (
          <div className="glass-card" style={{ padding: "clamp(20px, 6vw, 40px)", borderRadius: "24px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "32px" }}>
               <span style={{ fontWeight: 900, color: "#8b5cf6", fontSize: "0.85rem" }}>Question {currentQuestionIndex + 1}/5</span>
               <span style={{ fontWeight: 900, color: "#a78bfa", fontSize: "0.85rem" }}>Score: {score}</span>
            </div>
            <h3 style={{ fontSize: "clamp(1.2rem, 5vw, 1.4rem)", fontWeight: 900, marginBottom: "32px", lineHeight: 1.5 }}>
                 {battle.questions[currentQuestionIndex].question}
            </h3>
            <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
              {battle.questions[currentQuestionIndex].options.map((opt, i) => {
                const isCorrect = i === battle.questions[currentQuestionIndex].answer;
                const isSelected = selectedAnswer === i;
                const showFeedback = selectedAnswer !== null;

                return (
                  <button
                    key={i}
                    disabled={showFeedback}
                    onClick={() => handleAnswer(i)}
                    style={{
                      padding: "clamp(14px, 4vw, 20px)", borderRadius: "16px", textAlign: "left", fontSize: "clamp(0.95rem, 4vw, 1.1rem)", fontWeight: 700, cursor: "pointer", border: "1px solid rgba(255,255,255,0.1)", transition: "0.2s", width: "100%",
                      background: 
                        showFeedback && isCorrect ? "rgba(34,197,94,0.1)" : 
                        isSelected && !isCorrect ? "rgba(239,68,68,0.1)" : 
                        "rgba(255,255,255,0.02)",
                      borderColor: 
                        showFeedback && isCorrect ? "#22c55e" : 
                        isSelected && !isCorrect ? "#ef4444" : 
                        "rgba(255,255,255,0.1)"
                    }}
                  >
                    {opt}
                  </button>
                );
              })}
            </div>
          </div>
        )}

        {gameState === "finished" && (
          <motion.div initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} style={{ textAlign: "center" }}>
            <div style={{ fontSize: "5rem", marginBottom: "20px" }}>🏁</div>
            <h1 style={{ fontSize: "2.5rem", fontWeight: 950 }}>Battle Finished!</h1>
            <p style={{ fontSize: "1.5rem", color: "#8b5cf6", fontWeight: 900, marginTop: "16px" }}>Final Score: {score}/5</p>
            <p style={{ color: "#94a3b8", marginTop: "24px" }}>Results sync panrom... wait pannunga!</p>
            <button 
              onClick={() => setGameState("intro")}
              style={{ marginTop: "40px", background: "#fff", color: "#000", padding: "16px 32px", borderRadius: "14px", border: "none", fontWeight: 900, fontSize: "1.1rem", cursor: "pointer" }}
            >
              GO TO RESULTS 🏆
            </button>
          </motion.div>
        )}
      </div>
    </div>
  );
}
