"use client";
import Link from "next/link";

export default function Footer() {
  return (
    <footer style={{ borderTop: "1px solid rgba(255,255,255,0.07)", padding: "40px 24px", textAlign: "center", background: "rgba(255,255,255,0.01)" }}>
      <div className="max-w-6xl mx-auto">
        <div style={{ fontSize: "1.4rem", fontWeight: 800, marginBottom: 8, background: "linear-gradient(135deg, #8b5cf6, #06b6d4)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", backgroundClip: "text" }}>
          ☕ Techaa Purinjikoo
        </div>
        <p style={{ color: "#7b7b9a", fontSize: "0.88rem", marginBottom: 24 }}>Tech bayam illama purinjikalam 😎</p>
        <div style={{ display: "flex", gap: 20, justifyContent: "center", marginBottom: 28, flexWrap: "wrap" }}>
          {[
            { label: "Home", href: "/" },
            { label: "Topics", href: "/#topics" },
            { label: "Dictionary 📖", href: "/dictionary" },
            { label: "Admin", href: "/admin" },
          ].map(link => (
            <Link key={link.href} href={link.href} style={{ color: "#7b7b9a", textDecoration: "none", fontSize: "0.82rem", transition: "color 0.2s" }}
            >
              {link.label}
            </Link>
          ))}
        </div>
        <div style={{ fontSize: "0.82rem", color: "#94a3b8", fontWeight: 600 }}>
          Made with ❤️ by <span style={{ color: "#8b5cf6" }}>NFS Programming</span> 🔥
        </div>
        <div style={{ fontSize: "0.74rem", color: "#4a4a6a", marginTop: "8px" }}>
          Empowering students to learn tech without fear.
        </div>
      </div>
    </footer>
  );
}
