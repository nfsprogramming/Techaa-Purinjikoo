
"use client";
import React, { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { collection, addDoc, query, where, orderBy, onSnapshot, serverTimestamp } from 'firebase/firestore';
import { useAuth } from '@/context/AuthContext';
import { motion, AnimatePresence } from 'framer-motion';

export default function TopicDiscussion({ topicId }) {
  const { user } = useAuth();
  const [comments, setComments] = useState([]);
  const [newComment, setNewComment] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!topicId) return;

    const q = query(
      collection(db, "discussions"),
      where("topicId", "==", topicId)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const docs = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      // Client-side sort to bypass index requirement
      const sortedDocs = docs.sort((a, b) => {
        const timeA = a.createdAt?.toMillis() || 0;
        const timeB = b.createdAt?.toMillis() || 0;
        return timeB - timeA;
      });

      setComments(sortedDocs);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [topicId]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!user) {
      alert("Login panna thaan discuss panna mudiyum bro! 😊");
      return;
    }
    if (!newComment.trim()) return;

    try {
      await addDoc(collection(db, "discussions"), {
        topicId,
        userId: user.uid,
        userName: user.displayName,
        userPhoto: user.photoURL,
        text: newComment,
        createdAt: serverTimestamp()
      });
      setNewComment("");
    } catch (err) {
      console.error("Comment error:", err);
    }
  };

  return (
    <div style={{ marginTop: "40px" }}>
      <h3 style={{ fontSize: "1.5rem", fontWeight: 900, marginBottom: "24px" }}>💬 Community Discussion</h3>

      <form onSubmit={handleSubmit} style={{ marginBottom: "32px" }}>
        <textarea
          value={newComment}
          onChange={(e) => setNewComment(e.target.value)}
          placeholder={user ? "Indha topic pathi doubts kekalam, discuss panalone more toaam... ☕" : "Login panni unga doubts kelunga!"}
          style={{
            width: "100%",
            background: "rgba(255,255,255,0.03)",
            border: "1px solid rgba(255,255,255,0.1)",
            padding: "16px",
            borderRadius: "16px",
            color: "#fff",
            minHeight: "100px",
            fontSize: "0.95rem",
            marginBottom: "12px",
            resize: "vertical"
          }}
          disabled={!user}
        />
        <div style={{ display: "flex", justifyContent: "flex-end" }}>
          <button
            type="submit"
            disabled={!user || !newComment.trim()}
            style={{
              background: "#8b5cf6",
              color: "#fff",
              padding: "12px 24px",
              borderRadius: "12px",
              border: "none",
              fontWeight: 800,
              cursor: user ? "pointer" : "not-allowed",
              opacity: user ? 1 : 0.5
            }}
          >
            Post Doubt 🚀
          </button>
        </div>
      </form>

      <div style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
        {loading ? (
          <p style={{ color: "#64748b" }}>Loading discussions...</p>
        ) : comments.length === 0 ? (
          <p style={{ color: "#64748b", textAlign: "center", padding: "40px", background: "rgba(255,255,255,0.02)", borderRadius: "20px" }}>
            No questions yet. Be the first to ask! 🙋‍♂️
          </p>
        ) : (
          <AnimatePresence>
            {comments.map((c, i) => (
              <motion.div
                key={c.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                style={{
                  background: "rgba(255,255,255,0.02)",
                  padding: "clamp(12px, 4vw, 20px)",
                  borderRadius: "16px",
                  border: "1px solid rgba(255,255,255,0.05)",
                  display: "flex",
                  gap: "12px"
                }}
              >
                <img
                  src={c.userPhoto || `https://ui-avatars.com/api/?name=${c.userName}&background=random`}
                  style={{ width: "40px", height: "40px", borderRadius: "50%" }}
                  referrerPolicy="no-referrer"
                  onError={(e) => { e.target.src = `https://ui-avatars.com/api/?name=${c.userName}&background=random`; }}
                />
                <div>
                  <div style={{ fontSize: "0.9rem", fontWeight: 800, color: "#8b5cf6", marginBottom: "4px" }}>{c.userName}</div>
                  <p style={{ color: "#d1d5db", lineHeight: 1.5, margin: 0 }}>{c.text}</p>
                  <div style={{ fontSize: "0.75rem", color: "#64748b", marginTop: "8px" }}>
                    {c.createdAt?.toDate().toLocaleDateString()} at {c.createdAt?.toDate().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </div>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        )}
      </div>
    </div>
  );
}
