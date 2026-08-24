"use client";
import React, { useState, useEffect } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";

const LEVEL_NAMES = {
  1: "Internet Fundamentals",
  2: "Web Development Basics",
  3: "Database Management",
  4: "Cloud & Deployment",
  5: "Developer Toolkits",
  6: "Web Security",
  7: "AI & Modern Technology"
};

export default function VerifySpecificCertificatePage() {
  const params = useParams();
  const certId = (params?.id || "").toUpperCase();

  let levelNumber = 1;
  const match = certId.match(/L([1-7])/i) || certId.match(/LEVEL-?([1-7])/i);
  if (match) {
    levelNumber = parseInt(match[1], 10);
  }

  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff", padding: "100px 20px 60px" }}>
      <div style={{ maxWidth: "800px", margin: "0 auto" }}>
        
        {/* Breadcrumb */}
        <div style={{ marginBottom: "24px" }}>
          <Link href="/verify" style={{ color: "#8b5cf6", textDecoration: "none", fontWeight: 700, fontSize: "0.9rem" }}>
            ← All Certificate Verifications
          </Link>
        </div>

        {/* Verified Result Card */}
        <div style={{ background: "linear-gradient(180deg, rgba(16,185,129,0.08) 0%, rgba(8,12,20,0.95) 100%)", border: "1px solid rgba(16,185,129,0.3)", borderRadius: "24px", padding: "40px", boxShadow: "0 30px 60px rgba(0,0,0,0.6)" }}>
          
          {/* Status Badge */}
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "12px", borderBottom: "1px solid rgba(255,255,255,0.08)", paddingBottom: "24px", marginBottom: "28px" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
              <div style={{ width: "48px", height: "48px", borderRadius: "50%", background: "rgba(16,185,129,0.2)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "1.5rem" }}>
                ✅
              </div>
              <div>
                <div style={{ color: "#34d399", fontWeight: 900, fontSize: "1.2rem", letterSpacing: "0.5px" }}>
                  AUTHENTIC CERTIFICATE
                </div>
                <div style={{ color: "#94a3b8", fontSize: "0.85rem" }}>
                  Verified by Techaa Purinjikoo Certification Registry
                </div>
              </div>
            </div>

            <div style={{ background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", padding: "6px 14px", borderRadius: "8px", fontFamily: "monospace", fontSize: "0.95rem", color: "#cbd5e1" }}>
              ID: {certId}
            </div>
          </div>

          {/* Certificate Details Grid */}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: "24px", marginBottom: "32px" }}>
            <div>
              <div style={{ color: "#64748b", fontSize: "0.8rem", textTransform: "uppercase", fontWeight: 700, letterSpacing: "1px", marginBottom: "4px" }}>
                Track Completed
              </div>
              <div style={{ color: "#fff", fontSize: "1.3rem", fontWeight: 800 }}>
                {LEVEL_NAMES[levelNumber] || "Full Stack Engineering Track"}
              </div>
              <div style={{ color: "#8b5cf6", fontSize: "0.85rem", fontWeight: 600 }}>
                Level {levelNumber} Certification
              </div>
            </div>

            <div>
              <div style={{ color: "#64748b", fontSize: "0.8rem", textTransform: "uppercase", fontWeight: 700, letterSpacing: "1px", marginBottom: "4px" }}>
                Issuing Institution
              </div>
              <div style={{ color: "#fff", fontSize: "1.1rem", fontWeight: 700 }}>
                Techaa Purinjikoo Academy
              </div>
            </div>
          </div>

          {/* Actions */}
          <div style={{ display: "flex", gap: "12px", flexWrap: "wrap", borderTop: "1px solid rgba(255,255,255,0.08)", paddingTop: "24px" }}>
            <Link 
              href={`/profile/certificate/${levelNumber}`}
              style={{
                background: "linear-gradient(135deg, #8b5cf6, #2563eb)",
                color: "#fff",
                padding: "12px 20px",
                borderRadius: "10px",
                textDecoration: "none",
                fontWeight: 700,
                fontSize: "0.9rem",
              }}
            >
              📜 View Certificate
            </Link>
            <Link 
              href="/"
              style={{
                background: "rgba(255,255,255,0.05)",
                color: "#94a3b8",
                padding: "12px 20px",
                borderRadius: "10px",
                textDecoration: "none",
                fontWeight: 600,
                fontSize: "0.9rem",
              }}
            >
              Learn on Techaa Purinjikoo
            </Link>
          </div>
        </div>

      </div>
    </div>
  );
}
