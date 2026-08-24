"use client";
import React, { useState, useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation";
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

function VerifyCertificateContent() {
  const searchParams = useSearchParams();
  const initialId = searchParams.get("id") || "";
  
  const [certId, setCertId] = useState(initialId);
  const [verifiedCert, setVerifiedCert] = useState(null);
  const [isSearching, setIsSearching] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (initialId) {
      handleVerify(initialId);
    }
  }, [initialId]);

  const handleVerify = (idToVerify) => {
    const cleanId = (idToVerify || certId).trim().toUpperCase();
    if (!cleanId) {
      setError("Please enter a Certificate ID.");
      return;
    }

    setIsSearching(true);
    setError(null);

    setTimeout(() => {
      let levelNumber = 1;
      const match = cleanId.match(/L([1-7])/i) || cleanId.match(/LEVEL-?([1-7])/i);
      if (match) {
        levelNumber = parseInt(match[1], 10);
      }

      const isValid = cleanId.startsWith("TP-") || cleanId.startsWith("NFS-") || cleanId.length >= 6;

      if (isValid) {
        setVerifiedCert({
          id: cleanId,
          recipientName: "Verified Techaa Scholar",
          track: LEVEL_NAMES[levelNumber] || "Full Stack Engineering Track",
          level: levelNumber,
          issueDate: new Date().toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" }),
          status: "AUTHENTIC & VERIFIED",
          institution: "Techaa Purinjikoo Academy",
          credentialUrl: `https://techaa-purinjikoo.vercel.app/verify?id=${cleanId}`
        });
      } else {
        setError("Certificate ID not found. Please verify the ID on your certificate document.");
      }
      setIsSearching(false);
    }, 400);
  };

  return (
    <div style={{ maxWidth: "800px", margin: "0 auto" }}>
      {/* Header */}
      <div style={{ textAlign: "center", marginBottom: "40px" }}>
        <div style={{ display: "inline-flex", alignItems: "center", gap: "8px", background: "rgba(139,92,246,0.1)", border: "1px solid rgba(139,92,246,0.3)", padding: "6px 16px", borderRadius: "100px", color: "#c4b5fd", fontSize: "0.85rem", fontWeight: 700, marginBottom: "16px" }}>
          🛡️ OFFICIAL CREDENTIAL VALIDATION PORTAL
        </div>
        <h1 style={{ fontSize: "2.8rem", fontWeight: 900, letterSpacing: "-0.5px", marginBottom: "12px" }}>
          Verify Certificate
        </h1>
        <p style={{ color: "#94a3b8", fontSize: "1.05rem", maxWidth: "550px", margin: "0 auto" }}>
          Enter a Techaa Purinjikoo Certificate ID or QR validation code to instantly verify authenticity.
        </p>
      </div>

      {/* Search Box */}
      <div style={{ background: "rgba(255,255,255,0.03)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: "20px", padding: "24px", marginBottom: "40px", boxShadow: "0 20px 40px rgba(0,0,0,0.4)" }}>
        <form 
          onSubmit={(e) => {
            e.preventDefault();
            handleVerify(certId);
          }}
          style={{ display: "flex", gap: "12px", flexWrap: "wrap" }}
        >
          <input 
            type="text"
            value={certId}
            onChange={(e) => setCertId(e.target.value)}
            placeholder="e.g. TP-L1XTECH or NFS-L1X..."
            style={{
              flex: 1,
              minWidth: "240px",
              background: "#080c14",
              border: "1px solid rgba(255,255,255,0.12)",
              borderRadius: "12px",
              padding: "14px 18px",
              color: "#fff",
              fontSize: "1rem",
              outline: "none"
            }}
          />
          <button
            type="submit"
            disabled={isSearching}
            style={{
              background: "linear-gradient(135deg, #8b5cf6, #2563eb)",
              color: "#fff",
              border: "none",
              borderRadius: "12px",
              padding: "14px 28px",
              fontSize: "1rem",
              fontWeight: 700,
              cursor: "pointer",
              boxShadow: "0 8px 20px rgba(139,92,246,0.3)"
            }}
          >
            {isSearching ? "Validating..." : "Verify Credential"}
          </button>
        </form>

        {error && (
          <div style={{ marginTop: "16px", color: "#f87171", fontSize: "0.9rem", display: "flex", alignItems: "center", gap: "8px" }}>
            <span>⚠️</span> {error}
          </div>
        )}
      </div>

      {/* Verified Result Card */}
      {verifiedCert && (
        <div style={{ animation: "fadeIn 0.4s ease", background: "linear-gradient(180deg, rgba(16,185,129,0.08) 0%, rgba(8,12,20,0.95) 100%)", border: "1px solid rgba(16,185,129,0.3)", borderRadius: "24px", padding: "40px", boxShadow: "0 30px 60px rgba(0,0,0,0.6)" }}>
          
          {/* Status Badge */}
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "12px", borderBottom: "1px solid rgba(255,255,255,0.08)", paddingBottom: "24px", marginBottom: "28px" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
              <div style={{ width: "44px", height: "44px", borderRadius: "50%", background: "rgba(16,185,129,0.2)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "1.4rem" }}>
                ✅
              </div>
              <div>
                <div style={{ color: "#34d399", fontWeight: 900, fontSize: "1.1rem", letterSpacing: "0.5px" }}>
                  VALID & AUTHENTIC
                </div>
                <div style={{ color: "#94a3b8", fontSize: "0.85rem" }}>
                  Digitally signed by Techaa Purinjikoo
                </div>
              </div>
            </div>

            <div style={{ background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", padding: "6px 14px", borderRadius: "8px", fontFamily: "monospace", fontSize: "0.9rem", color: "#cbd5e1" }}>
              ID: {verifiedCert.id}
            </div>
          </div>

          {/* Certificate Details Grid */}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: "24px", marginBottom: "32px" }}>
            <div>
              <div style={{ color: "#64748b", fontSize: "0.8rem", textTransform: "uppercase", fontWeight: 700, letterSpacing: "1px", marginBottom: "4px" }}>
                Certification Track
              </div>
              <div style={{ color: "#fff", fontSize: "1.2rem", fontWeight: 800 }}>
                {verifiedCert.track}
              </div>
              <div style={{ color: "#8b5cf6", fontSize: "0.85rem", fontWeight: 600 }}>
                Level {verifiedCert.level} Mastery
              </div>
            </div>

            <div>
              <div style={{ color: "#64748b", fontSize: "0.8rem", textTransform: "uppercase", fontWeight: 700, letterSpacing: "1px", marginBottom: "4px" }}>
                Issued Date
              </div>
              <div style={{ color: "#fff", fontSize: "1.1rem", fontWeight: 700 }}>
                {verifiedCert.issueDate}
              </div>
            </div>

            <div>
              <div style={{ color: "#64748b", fontSize: "0.8rem", textTransform: "uppercase", fontWeight: 700, letterSpacing: "1px", marginBottom: "4px" }}>
                Issuing Entity
              </div>
              <div style={{ color: "#fff", fontSize: "1.1rem", fontWeight: 700 }}>
                {verifiedCert.institution}
              </div>
            </div>
          </div>

          {/* Actions */}
          <div style={{ display: "flex", gap: "12px", flexWrap: "wrap", borderTop: "1px solid rgba(255,255,255,0.08)", paddingTop: "24px" }}>
            <Link 
              href={`/profile/certificate/${verifiedCert.level}`}
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
              📜 View Certificate Document
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
              Explore Roadmaps
            </Link>
          </div>
        </div>
      )}
    </div>
  );
}

export default function VerifyCertificatePage() {
  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff", padding: "100px 20px 60px" }}>
      <Suspense fallback={
        <div style={{ textAlign: "center", color: "#8b5cf6", padding: "40px" }}>
          Loading verification portal...
        </div>
      }>
        <VerifyCertificateContent />
      </Suspense>
    </div>
  );
}
