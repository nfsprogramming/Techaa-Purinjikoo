import React from "react";
import Link from "next/link";

export default function TermsPage() {
  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff", padding: "100px 24px 60px" }}>
      <div style={{ maxWidth: "800px", margin: "0 auto" }}>
        <div style={{ marginBottom: "32px" }}>
          <Link href="/" style={{ color: "#8b5cf6", textDecoration: "none", fontWeight: 700 }}>← Back to Home</Link>
        </div>
        <h1 style={{ fontSize: "2.5rem", fontWeight: 900, marginBottom: "16px" }}>Terms of Service</h1>
        <p style={{ color: "#94a3b8", marginBottom: "32px", fontSize: "0.95rem" }}>Last updated: August 2026</p>

        <div style={{ color: "#cbd5e1", lineHeight: 1.8, display: "flex", flexDirection: "column", gap: "24px" }}>
          <section>
            <h2 style={{ color: "#fff", fontSize: "1.3rem", fontWeight: 800, marginBottom: "8px" }}>1. Acceptance of Terms</h2>
            <p>By accessing or using Techaa Purinjikoo, you agree to be bound by these Terms of Service. If you disagree, please do not use the service.</p>
          </section>
          <section>
            <h2 style={{ color: "#fff", fontSize: "1.3rem", fontWeight: 800, marginBottom: "8px" }}>2. Educational Content</h2>
            <p>All tech explanations, analogies, and quizzes are provided for educational purposes in Tanglish. Certificates issued reflect course and topic completion on the platform.</p>
          </section>
        </div>
      </div>
    </div>
  );
}
