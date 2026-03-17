"use client";
import React, { useState, useEffect } from "react";
import { useAuth } from "@/context/AuthContext";
import { useUserProgress } from "@/context/UserProgressContext";
import { db } from "@/lib/firebase";
import { collection, addDoc, query, where, getDocs, orderBy, limit } from "firebase/firestore";
import { getRandomBattleQuestions } from "@/data/battleUtils";
import Navbar from "@/components/Navbar";
import Link from "next/link";
import { motion } from "framer-motion";

export default function BattlePage() {
  const { user } = useAuth();
  const { xp, level, streak, XP_LEVELS, xpHistory, completedTopics, addXP } = useUserProgress();
  const [battles, setBattles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);

  useEffect(() => {
    if (!user) return;
    const fetchBattles = async () => {
      try {
        const q = query(
          collection(db, "battles"),
          where("participants", "array-contains", user.uid),
          limit(20)
        );
        const snap = await getDocs(q);
        const fetchedBattles = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        // Sort client-side to avoid manual index creation requirement
        const sorted = fetchedBattles.sort((a, b) => (b.createdAt || 0) - (a.createdAt || 0));
        setBattles(sorted);
      } catch (err) {
        console.error("Fetch battles error:", err);
      } finally {
        setLoading(false);
      }
    };
    fetchBattles();
  }, [user]);

  const createBattle = async () => {
    if (!user) return alert("Login panna thaan battle start panna mudiyum bro! ⚔️");
    if (completedTopics.length === 0) {
      return alert("Innum oru topic kooda cover pannala bro! 📚 Roadmap poyi oru topic mudinga, appo thaan challenge panna mudiyum! 😉");
    }
    setCreating(true);
    const questions = getRandomBattleQuestions(5, completedTopics);
    try {
      const docRef = await addDoc(collection(db, "battles"), {
        creatorId: user.uid,
        creatorName: user.displayName,
        creatorPhoto: user.photoURL,
        questions: questions,
        participants: [user.uid],
        status: "waiting", // waiting for someone to join
        results: {
          [user.uid]: null // to be filled when creator plays
        },
        createdAt: Date.now()
      });
      window.location.href = `/battle/${docRef.id}`;
    } catch (err) {
      console.error("Create battle error:", err);
      alert("Something went wrong bro! Try again.");
    } finally {
      setCreating(false);
    }
  };

  return (
    <div style={{ minHeight: "100vh", background: "#070711", color: "#fff" }}>
      <Navbar />
      <div style={{ maxWidth: "800px", margin: "0 auto", padding: "clamp(80px, 12vh, 100px) 20px 60px" }}>
        
        <div style={{ textAlign: "center", marginBottom: "40px" }}>
          <h1 style={{ fontSize: "clamp(2rem, 8vw, 2.8rem)", fontWeight: 950, marginBottom: "16px", letterSpacing: "-1.5px", lineHeight: 1.1 }}>
            ⚔️ Quiz <span style={{ color: "#8b5cf6" }}>Battles</span>
          </h1>
          <p style={{ color: "#94a3b8", fontSize: "clamp(0.95rem, 4vw, 1.1rem)", maxWidth: "500px", margin: "0 auto" }}>Friends-ah challenge pannunga, XP-ah win pannunga! 🔥</p>
          
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            disabled={creating}
            onClick={createBattle}
            style={{ marginTop: "32px", background: "linear-gradient(135deg, #8b5cf6, #7c3aed)", color: "#fff", padding: "clamp(14px, 4vw, 18px) clamp(24px, 6vw, 36px)", borderRadius: "16px", border: "none", fontWeight: 900, fontSize: "clamp(1rem, 4vw, 1.2rem)", cursor: "pointer", boxShadow: "0 10px 30px rgba(139,92,246,0.3)", width: "100%", maxWidth: "400px" }}
          >
            {creating ? "STARTING BATTLE..." : "CREATE NEW CHALLENGE ⚔️"}
          </motion.button>
        </div>

        <section>
          <h2 style={{ fontSize: "1.1rem", fontWeight: 900, marginBottom: "20px", opacity: 0.8 }}>Recent Battles</h2>
          {loading ? (
            <p style={{ color: "#64748b" }}>Loading battles...</p>
          ) : battles.length === 0 ? (
            <div style={{ textAlign: "center", padding: "40px 20px", background: "rgba(255,255,255,0.02)", borderRadius: "32px", border: "1px solid rgba(255,255,255,0.05)" }}>
              <p style={{ color: "#94a3b8", fontWeight: 700, fontSize: "0.9rem" }}>Innum yaaraiyum challenge pannala bro! Challenge a friend now! 🚀</p>
            </div>
          ) : (
            <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
              {battles.map(b => (
                <Link key={b.id} href={`/battle/${b.id}`} style={{ textDecoration: "none" }}>
                  <motion.div 
                    whileHover={{ x: 5, background: "rgba(255,255,255,0.04)" }}
                    style={{ padding: "16px", background: "rgba(255,255,255,0.02)", borderRadius: "16px", border: "1px solid rgba(255,255,255,0.05)", display: "flex", alignItems: "center", justifyContent: "space-between", gap: "10px" }}
                  >
                    <div style={{ display: "flex", alignItems: "center", gap: "12px", minWidth: 0 }}>
                       <img src={b.creatorPhoto} style={{ width: "36px", height: "36px", borderRadius: "50%", border: "2px solid #8b5cf6", flexShrink: 0 }} />
                       <div style={{ minWidth: 0 }}>
                         <div style={{ fontWeight: 800, color: "#fff", fontSize: "0.9rem", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{b.creatorName}'s Challenge</div>
                         <div style={{ fontSize: "0.7rem", color: "#64748b" }}>{new Date(b.createdAt).toLocaleDateString()}</div>
                       </div>
                    </div>
                    <div style={{ background: b.status === 'completed' ? '#4ade8022' : '#fbbf2422', padding: "4px 10px", borderRadius: "100px", color: b.status === 'completed' ? '#4ade80' : '#fbbf24', fontSize: "0.65rem", fontWeight: 900, textTransform: "uppercase", flexShrink: 0 }}>
                      {b.status === 'completed' ? 'Finished ✅' : 'Waiting... ⏳'}
                    </div>
                  </motion.div>
                </Link>
              ))}
            </div>
          )}
        </section>
      </div>
    </div>
  );
}
