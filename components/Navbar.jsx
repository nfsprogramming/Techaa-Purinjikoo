
"use client";
import Link from "next/link";
import { useState, useEffect } from "react";
import { useUserProgress } from "@/context/UserProgressContext";
import { useAuth } from "@/context/AuthContext";
import { motion, AnimatePresence } from "framer-motion";

const NAV_LINKS = [
  { href: "/", label: "Home" },
  { href: "/battle", label: "Battle ⚔️" },
  { href: "/flashcards", label: "Flashcards ⚡" },
  { href: "/dictionary", label: "Dictionary 📖" },
  { href: "https://nfs-learning-hub.vercel.app/", label: "Courses 🎓" },
];

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [showXpHistory, setShowXpHistory] = useState(false);
  const { xp, level, streak, XP_LEVELS, xpHistory, avatarStyle } = useUserProgress();
  const { user, loading, loginWithGoogle, logout } = useAuth();
  
  const BORDERS = {
    plain: { border: "2px solid #8b5cf6" },
    neon: { border: "2px solid #8b5cf6", boxShadow: "0 0 8px #8b5cf6" },
    glow: { border: "2px solid #06b6d4", boxShadow: "0 0 10px #06b6d4" },
    gold: { border: "2px solid #fbbf24", boxShadow: "0 0 12px #fbbf24" }
  };

  const EMOJIS = {
    verified: "✅",
    pro: "🛡️",
    fire: "🔥",
    crown: "👑"
  };
  
  useEffect(() => {
    const handleResize = () => { if (window.innerWidth > 768) setOpen(false); };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return (
    <>
    <style>{`
      .nav-container { 
        max-width: 1200px; 
        margin: 0 auto; 
        height: 100%; 
        padding: 0 10px; 
        display: flex; 
        align-items: center; 
        justify-content: space-between;
        gap: 6px;
      }
      .nav-brand {
        display: flex;
        align-items: center;
        gap: 6px;
        text-decoration: none;
        color: inherit;
        flex-shrink: 1;
        min-width: 0;
      }
      .nav-brand-text {
        font-weight: 950;
        font-size: 1rem;
        letter-spacing: -0.5px;
        white-space: nowrap;
        line-height: 1;
      }
      .nav-brand-purinjiko {
        color: #8b5cf6;
      }
      .nav-brand-sub {
        font-size: 0.45rem;
        color: #64748b;
        font-weight: 800;
        letter-spacing: 0.5px;
        margin-top: 1px;
      }
      .nav-desktop-only { display: flex; align-items: center; gap: 20px; }
      .nav-mobile-only { display: flex; align-items: center; gap: 6px; }
      
      @media (max-width: 768px) {
        .nav-desktop-only { display: none !important; }
        .nav-brand-text { font-size: 0.9rem; }
        .nav-brand-sub { display: none !important; }
      }
      @media (min-width: 769px) {
        .nav-mobile-only { display: none !important; }
      }
      @media (max-width: 360px) {
        .nav-brand-text { font-size: 0.75rem; }
        .nav-container { padding: 0 4px; }
        .nav-mobile-only { gap: 4px; }
      }
    `}</style>

    <nav
      style={{
        position: "fixed", top: 0, left: 0, right: 0, zIndex: 1000,
        background: "rgba(7, 7, 17, 0.92)", backdropFilter: "blur(12px)",
        borderBottom: "1px solid rgba(255,255,255,0.08)", height: "64px"
      }}
    >
      <div className="nav-container">
        
        {/* Brand Section */}
        <Link href="/" className="nav-brand">
          <motion.img 
            whileHover={{ rotate: 15, scale: 1.1 }}
            src="/favicon.png" 
            alt="Logo" 
            style={{ width: "22px", height: "22px", flexShrink: 0 }} 
          />
          <div style={{ display: "flex", flexDirection: "column", minWidth: 0 }}>
            <span className="nav-brand-text">
              Techaa <span className="nav-brand-purinjiko">Purinjikoo</span>
            </span>
            <span className="nav-brand-sub">NFS MASTERCLASS</span>
          </div>
        </Link>

        {/* Desktop Links & Stats */}
        <div className="nav-desktop-only">
           <motion.div 
             initial={{ opacity: 0, y: -10 }}
             animate={{ opacity: 1, y: 0 }}
             style={{ display: "flex", gap: "16px", background: "rgba(255,255,255,0.03)", padding: "4px 16px", borderRadius: "100px", border: "1px solid rgba(255,255,255,0.08)", fontSize: "0.85rem", fontWeight: 900 }}
           >
             <span title="Streak">🔥 {streak}</span>
             <motion.span 
               whileHover={{ scale: 1.1 }}
               onClick={() => setShowXpHistory(true)} 
               style={{ color: "#8b5cf6", cursor: "pointer" }}
             >
               {xp} XP
             </motion.span>
             <span style={{ color: "#06b6d4" }}>LVL {level}</span>
           </motion.div>
           
           <div style={{ display: "flex", gap: "20px" }}>
             {NAV_LINKS.map((l, i) => (
               <motion.div
                 key={l.href}
                 initial={{ opacity: 0 }}
                 animate={{ opacity: 1 }}
                 transition={{ delay: i * 0.1 }}
               >
                 <Link href={l.href} style={{ fontSize: "0.85rem", fontWeight: 700, color: "#94a3b8", textDecoration: "none" }}>
                    <motion.span whileHover={{ color: "#fff" }}>{l.label}</motion.span>
                 </Link>
               </motion.div>
             ))}
           </div>
        </div>

        {/* Right Section */}
        <div style={{ display: "flex", alignItems: "center", gap: "8px", flexShrink: 0 }}>
          
          {/* Mobile Stats Pill */}
          {!loading && user && (
            <motion.div 
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              whileTap={{ scale: 0.9 }}
              onClick={() => setShowXpHistory(true)} 
              className="nav-mobile-only" 
              style={{ background: "rgba(139,92,246,0.1)", border: "1px solid rgba(139,92,246,0.2)", padding: "4px 8px", borderRadius: "100px" }}
            >
               <span style={{ fontWeight: 900, fontSize: "0.75rem", color: "#a78bfa" }}>{xp} XP</span>
            </motion.div>
          )}

          {user ? (
            <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
              <motion.div whileHover={{ scale: 1.1 }} whileTap={{ scale: 0.9 }}>
                <Link href="/profile" style={{ display: "flex", alignItems: "center", position: "relative" }}>
                  <img 
                    src={user.photoURL || `https://ui-avatars.com/api/?name=${user.displayName || 'User'}&background=8b5cf6&color=fff`} 
                    style={{ 
                      width: "28px", height: "28px", borderRadius: "50%", 
                      ...(BORDERS[avatarStyle?.border] || BORDERS.plain)
                    }} 
                    alt="Avatar"
                    referrerPolicy="no-referrer"
                    onError={(e) => { e.target.src = `https://ui-avatars.com/api/?name=${user.displayName || 'User'}&background=8b5cf6&color=fff`; }}
                  />
                  {avatarStyle?.emoji && avatarStyle.emoji !== "none" && EMOJIS[avatarStyle.emoji] && (
                    <span style={{ position: "absolute", bottom: -4, right: -4, fontSize: "0.6rem", background: "#070711", borderRadius: "50%", width: "12px", height: "12px", display: "flex", alignItems: "center", justifyContent: "center" }}>
                      {EMOJIS[avatarStyle.emoji]}
                    </span>
                  )}
                </Link>
              </motion.div>
              
              {/* Desktop Logout Button */}
              <motion.button
                whileHover={{ scale: 1.05, color: "#ff4b4b" }}
                whileTap={{ scale: 0.95 }}
                onClick={logout}
                className="nav-desktop-only"
                style={{ background: "rgba(255,75,75,0.05)", border: "1px solid rgba(255,75,75,0.1)", color: "#94a3b8", padding: "6px 12px", borderRadius: "8px", fontSize: "0.75rem", fontWeight: 800, cursor: "pointer", transition: "0.2s" }}
              >
                Logout 🚪
              </motion.button>
            </div>
          ) : (
            <motion.button 
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={loginWithGoogle} 
              style={{ background: "#8b5cf6", color: "#fff", border: "none", padding: "6px 12px", borderRadius: "8px", fontWeight: 800, fontSize: "0.75rem", cursor: "pointer" }}
            >
              Join
            </motion.button>
          )}

          {/* Menu Toggle */}
          <motion.button 
            whileTap={{ scale: 0.8 }}
            onClick={() => setOpen(!open)} 
            className="nav-mobile-only" 
            style={{ background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.1)", color: "#fff", width: "32px", height: "32px", borderRadius: "8px", cursor: "pointer", fontSize: "1rem", display: "flex", alignItems: "center", justifyContent: "center" }}
          >
            {open ? "✕" : "☰"}
          </motion.button>
        </div>
      </div>

      {/* Mobile Drawer */}
      <AnimatePresence>
        {open && (
          <motion.div 
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            style={{ position: "absolute", top: "64px", left: 0, right: 0, background: "#070711", borderBottom: "1px solid rgba(255,255,255,0.1)", padding: "10px", display: "flex", flexDirection: "column", gap: "6px", overflow: "hidden" }}
          >
            {NAV_LINKS.map(l => (
              <motion.div key={l.href} whileTap={{ x: 5 }}>
                <Link href={l.href} onClick={() => setOpen(false)} style={{ display: "block", padding: "12px 16px", borderRadius: "10px", background: "rgba(255,255,255,0.02)", color: "#fff", textDecoration: "none", fontWeight: 700, fontSize: "0.9rem" }}>{l.label}</Link>
              </motion.div>
            ))}
            <motion.div whileTap={{ x: 5 }}>
              <Link href="/profile" onClick={() => setOpen(false)} style={{ display: "block", padding: "12px 16px", borderRadius: "10px", background: "rgba(139,92,246,0.1)", color: "#a78bfa", textDecoration: "none", fontWeight: 700, fontSize: "0.9rem" }}>My Profile 🏆</Link>
            </motion.div>
            {user && (
              <motion.button 
                whileTap={{ x: 5 }}
                onClick={() => { logout(); setOpen(false); }} 
                style={{ padding: "12px 16px", borderRadius: "10px", background: "rgba(255,49,49,0.05)", border: "none", color: "#ff4b4b", fontWeight: 800, textAlign: "left" }}
              >
                Logout 🚪
              </motion.button>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      {/* XP Modal */}
      <AnimatePresence>
        {showXpHistory && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setShowXpHistory(false)} 
            style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.85)", backdropFilter: "blur(10px)", zIndex: 2000, display: "flex", alignItems: "center", justifyContent: "center", padding: "20px" }}
          >
            <motion.div 
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.9, y: 20 }}
              onClick={e => e.stopPropagation()} 
              style={{ background: "#0d0d1a", border: "1px solid #1e1e3f", borderRadius: "24px", width: "100%", maxWidth: "450px", maxHeight: "80vh", display: "flex", flexDirection: "column", overflow: "hidden" }}
            >
               <div style={{ padding: "18px", borderBottom: "1px solid rgba(255,255,255,0.05)", display: "flex", justifyContent: "space-between" }}>
                 <h3 style={{ margin: 0 }}>XP History</h3>
                 <button onClick={() => setShowXpHistory(false)} style={{ background: "none", border: "none", color: "#fff", cursor: "pointer", fontSize: "1.2rem" }}>✕</button>
               </div>
               <div style={{ padding: "18px", overflowY: "auto", flex: 1, display: "flex", flexDirection: "column", gap: "8px" }}>
                 {xpHistory && xpHistory.length > 0 ? xpHistory.map((h, i) => (
                   <motion.div 
                    initial={{ opacity: 0, x: -10 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: i * 0.05 }}
                    key={i} 
                    style={{ display: "flex", justifyContent: "space-between", padding: "10px", background: "rgba(255,255,255,0.02)", borderRadius: "10px" }}
                   >
                     <span style={{ fontSize: "0.9rem" }}>{h.reason}</span>
                     <span style={{ color: "#8b5cf6", fontWeight: 900 }}>+{h.amount}</span>
                   </motion.div>
                 )) : <p style={{ textAlign: "center", color: "#94a3b8" }}>No history yet!</p>}
               </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </nav>
    </>
  );
}
