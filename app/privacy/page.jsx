import React from "react";
import Link from "next/link";

export default function PrivacyPage() {
  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff", padding: "100px 24px 60px" }}>
      <div style={{ maxWidth: "800px", margin: "0 auto" }}>
        <div style={{ marginBottom: "32px" }}>
          <Link href="/" style={{ color: "#8b5cf6", textDecoration: "none", fontWeight: 700 }}>← Back to Home</Link>
        </div>
        <h1 style={{ fontSize: "2.5rem", fontWeight: 900, marginBottom: "16px" }}>Privacy Policy</h1>
        <p style={{ color: "#94a3b8", marginBottom: "32px", fontSize: "0.95rem" }}>Last updated: August 2026</p>

        <div style={{ color: "#cbd5e1", lineHeight: 1.8, display: "flex", flexDirection: "column", gap: "24px" }}>
          <section>
            <h2 style={{ color: "#fff", fontSize: "1.3rem", fontWeight: 800, marginBottom: "8px" }}>1. Information We Collect</h2>
            <p>We collect basic profile information when you sign in with Google or Email (such as your name, email address, and profile photo) solely to save your learning progress, streak, badges, and certificates.</p>
          </section>
          <section>
            <h2 style={{ color: "#fff", fontSize: "1.3rem", fontWeight: 800, marginBottom: "8px" }}>2. How We Use Information</h2>
            <p>Your data is used to provide gamification features, personalize your roadmap, track completed topics, and generate verifiable certificates.</p>
          </section>
          <section>
            <h2 style={{ color: "#fff", fontSize: "1.3rem", fontWeight: 800, marginBottom: "8px" }}>3. Data Security</h2>
            <p>We secure your credentials and progress using Google Firebase Authentication and Cloud Firestore security standards.</p>
          </section>
        </div>
      </div>
    </div>
  );
}
