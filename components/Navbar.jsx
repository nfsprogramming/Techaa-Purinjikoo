"use client";
import Link from "next/link";
import { useState } from "react";

const NAV_LINKS = [
  { href: "/", label: "Home" },
  { href: "/#roadmap", label: "Roadmap" },
  { href: "/dictionary", label: "Dictionary 📖" },
];

const MOBILE_LINKS = [
  { href: "/", label: "Home" },
  { href: "/#topics", label: "Topics" },
  { href: "/dictionary", label: "Dictionary 📖" },
  { href: "/#about", label: "About" },
];

import { useUserProgress } from "@/context/UserProgressContext";
import { useAuth } from "@/context/AuthContext";

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const { xp, level, streak, XP_LEVELS } = useUserProgress();
  const { user, loading, loginWithGoogle, logout } = useAuth();
  
  const currentLevelName = XP_LEVELS.find(l => l.level === level)?.name || "Beginner";

  return (
    <nav
      className="fixed top-0 left-0 right-0 z-50"
      style={{
        background: "rgba(7, 7, 17, 0.8)",
        backdropFilter: "blur(16px)",
        WebkitBackdropFilter: "blur(16px)",
        borderBottom: "1px solid rgba(255,255,255,0.07)",
      }}
    >
      {/* Premium Top Loading Bar */}
      {loading && (
        <div style={{ 
          position: "fixed", 
          top: 0, 
          left: 0, 
          width: "100%", 
          zIndex: 1000, 
          background: "rgba(139, 92, 246, 0.1)", 
          backdropFilter: "blur(10px)",
          borderBottom: "1px solid rgba(139, 92, 246, 0.2)",
          height: "4px"
        }}>
          <div className="auth-progress-fill" style={{ 
            height: "100%", 
            background: "linear-gradient(90deg, #8b5cf6, #06b6d4, #8b5cf6)", 
            backgroundSize: "200% 100%",
            width: "100%" 
          }} />
          <style>{`
            @keyframes shimmer {
              0% { background-position: 200% 0; }
              100% { background-position: -200% 0; }
            }
            .auth-progress-fill { animation: shimmer 2s infinite linear; }
          `}</style>
        </div>
      )}
      <div className="max-w-6xl mx-auto px-6" style={{ display: "flex", alignItems: "center", height: "64px", justifyContent: "space-between" }}>
        {/* Logo */}
        <Link href="/" style={{ textDecoration: "none", flexShrink: 0 }}>
          <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
            <span style={{ fontSize: "1.3rem", filter: "none", color: "initial", WebkitTextFillColor: "initial" }}>☕</span>
            <div style={{ display: "flex", flexDirection: "column", lineHeight: 1 }}>
              <span style={{ fontWeight: 800, fontSize: "1rem", background: "linear-gradient(135deg, #8b5cf6, #06b6d4)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", backgroundClip: "text", letterSpacing: "-0.3px" }}>
                Techaa Purinjikoo
              </span>
              <span style={{ fontSize: "0.6rem", color: "#94a3b8", fontWeight: 700, letterSpacing: "0.5px", marginTop: "2px" }}>BY NFS PROGRAMMING</span>
            </div>
          </div>
        </Link>

        {/* Desktop stats */}
        <div style={{ display: "flex", alignItems: "center", gap: "20px" }} className="hidden md:flex">
          <div style={{ display: "flex", alignItems: "center", gap: "12px", background: "rgba(255,255,255,0.03)", padding: "4px 12px", borderRadius: "100px", border: "1px solid rgba(255,255,255,0.05)" }}>
            <div title="Learning Streak" style={{ display: "flex", alignItems: "center", gap: "4px" }}>
              <span style={{ fontSize: "0.9rem" }}>🔥</span>
              <span style={{ fontWeight: 800, fontSize: "0.85rem", color: "#f59e0b" }}>{streak}</span>
            </div>
            <div style={{ height: "12px", width: "1px", background: "rgba(255,255,255,0.1)" }} />
            <div title="XP Points" style={{ display: "flex", alignItems: "center", gap: "4px" }}>
              <span style={{ fontWeight: 800, fontSize: "0.85rem", color: "#8b5cf6" }}>{xp}</span>
              <span style={{ fontSize: "0.7rem", fontWeight: 700, color: "rgba(255,255,255,0.4)" }}>XP</span>
            </div>
            <div style={{ height: "12px", width: "1px", background: "rgba(255,255,255,0.1)" }} />
            <div title="Level" style={{ display: "flex", alignItems: "center", gap: "4px" }}>
              <span style={{ fontSize: "0.7rem", fontWeight: 700, color: "rgba(255,255,255,0.4)" }}>LVL</span>
              <span style={{ fontWeight: 800, fontSize: "0.85rem", color: "#06b6d4" }}>{level}</span>
            </div>
          </div>
          
          <div style={{ display: "flex", gap: "24px", alignItems: "center" }}>
            {NAV_LINKS.map(l => (
              <Link key={l.href} href={l.href} className="nav-link" style={{ fontSize: "0.85rem", fontWeight: 600, color: "#94a3b8", textDecoration: "none" }}>{l.label}</Link>
            ))}
          </div>
        </div>

        {/* Auth Actions */}
        <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
          {loading ? (
             <div style={{ background: "rgba(139, 92, 246, 0.1)", color: "#8b5cf6", padding: "6px 14px", borderRadius: "8px", fontSize: "0.75rem", fontWeight: 800, display: "flex", alignItems: "center", gap: "6px", border: "1px solid rgba(139, 92, 246, 0.2)" }}>
               <div style={{ width: "12px", height: "12px", border: "2px solid #8b5cf6", borderTopColor: "transparent", borderRadius: "50%", animation: "spin 1s linear infinite" }} />
               AUTHENTICATING
               <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
             </div>
          ) : user ? (
            <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
               <Link href="/profile" style={{ display: "flex", gap: "10px", alignItems: "center", textDecoration: "none" }}>
                <div style={{ position: "relative", width: "32px", height: "32px" }}>
                  <img 
                    src={user.photoURL || `https://ui-avatars.com/api/?name=${user.displayName}&background=8b5cf6&color=fff`} 
                    alt="User" 
                    referrerPolicy="no-referrer"
                    crossOrigin="anonymous"
                    onError={(e) => { 
                      console.log("Image failed, using fallback");
                      e.target.src = `https://ui-avatars.com/api/?name=${user.displayName}&background=8b5cf6&color=fff`; 
                    }}
                    style={{ width: "32px", height: "32px", borderRadius: "50%", border: "2px solid #8b5cf6", objectFit: "cover" }} 
                  />
                </div>
                <span className="hidden lg:block" style={{ color: "#fff", fontWeight: 700, fontSize: "0.85rem" }}>{user.displayName.split(' ')[0]}</span>
               </Link>
               <button onClick={logout} className="hidden md:block" style={{ color: "#94a3b8", fontSize: "0.75rem", fontWeight: 700, background: "none", border: "none", cursor: "pointer" }}>Logout</button>
            </div>
          ) : (
            <button onClick={loginWithGoogle} style={{ background: "linear-gradient(135deg, #8b5cf6, #7c3aed)", color: "#fff", padding: "8px 18px", borderRadius: "8px", fontSize: "0.82rem", fontWeight: 700, textDecoration: "none", border: "none", cursor: "pointer" }}>
              Login with Google 🚀
            </button>
          )}

          {/* Mobile hamburger */}
          <button onClick={() => setOpen(!open)} className="md:hidden" style={{ background: "none", border: "none", color: "#fff", cursor: "pointer", fontSize: "1.4rem" }}>
            {open ? "✕" : "☰"}
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      {open && (
        <div style={{ background: "rgba(7, 7, 17, 0.98)", padding: "20px 24px", display: "flex", flexDirection: "column", gap: "16px", borderTop: "1px solid rgba(255,255,255,0.07)" }}>
          {MOBILE_LINKS.map(l => (
            <Link key={l.href} href={l.href} className="nav-link" onClick={() => setOpen(false)}>{l.label}</Link>
          ))}
        </div>
      )}
    </nav>
  );
}
