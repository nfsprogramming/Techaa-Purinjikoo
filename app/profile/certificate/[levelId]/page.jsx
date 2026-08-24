"use client";
import { useParams } from "next/navigation";
import { useUserProgress } from "@/context/UserProgressContext";
import { useAuth } from "@/context/AuthContext";
import Link from "next/link";
import { useEffect, useState, useRef } from "react";
import html2canvas from "html2canvas";
import { jsPDF } from "jspdf";

const LEVEL_NAMES = {
  1: "Internet Fundamentals",
  2: "Web Development Basics",
  3: "Database Management",
  4: "Cloud & Deployment",
  5: "Developer Toolkits",
  6: "Web Security",
  7: "AI & Modern Technology"
};

export default function CertificatePage() {
  const params = useParams();
  const { getLevelProgress } = useUserProgress();
  const { user } = useAuth();
  const levelId = parseInt(params?.levelId || "1", 10) || 1;
  const progress = getLevelProgress ? getLevelProgress(levelId) : 0;
  const [isClient, setIsClient] = useState(false);
  const [previewUnlocked, setPreviewUnlocked] = useState(false);
  const certificateRef = useRef(null);

  useEffect(() => {
    setIsClient(true);
  }, []);

  if (!isClient) return null;

  const certificateName = LEVEL_NAMES[levelId] || "Technical Excellence";
  const isCompleted = progress >= 100 || previewUnlocked;

  const downloadCertificate = async () => {
    if (!certificateRef.current) return;
    
    try {
      const canvas = await html2canvas(certificateRef.current, {
        scale: 2, 
        backgroundColor: "#0a0a0a",
        useCORS: true 
      });
      
      const imgData = canvas.toDataURL("image/png");
      
      const pdf = new jsPDF({
        orientation: "landscape",
        unit: "mm",
        format: "a4"
      });
      
      const pdfWidth = pdf.internal.pageSize.getWidth();
      const pdfHeight = pdf.internal.pageSize.getHeight();
      
      pdf.addImage(imgData, "PNG", 0, 0, pdfWidth, pdfHeight);
      pdf.save(`Techaa_Purinjikoo_Certificate_Level_${levelId}.pdf`);
    } catch (error) {
      console.error("Failed to generate certificate", error);
      alert("Something went wrong generating the certificate.");
    }
  };

  if (!isCompleted) {
    return (
      <div style={{ background: "#070711", minHeight: "100vh", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", padding: "40px 20px" }}>
        <div style={{ maxWidth: "500px", width: "100%", background: "rgba(255,255,255,0.03)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: "24px", padding: "40px", textAlign: "center" }}>
          <div style={{ fontSize: "3.5rem", marginBottom: "16px" }}>🔒</div>
          <h2 style={{ fontSize: "1.8rem", fontWeight: 900, marginBottom: "8px" }}>Level {levelId} In Progress</h2>
          <p style={{ color: "#8b5cf6", fontWeight: 700, marginBottom: "20px" }}>{certificateName}</p>
          <p style={{ color: "#94a3b8", fontSize: "0.95rem", lineHeight: 1.6, marginBottom: "24px" }}>
            Complete all topics in Level {levelId} to unlock and claim your official certificate!
          </p>

          <div style={{ marginBottom: "24px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.85rem", color: "#94a3b8", marginBottom: "8px" }}>
              <span>Progress</span>
              <span style={{ color: "#8b5cf6", fontWeight: 800 }}>{progress}%</span>
            </div>
            <div style={{ height: "8px", background: "rgba(255,255,255,0.05)", borderRadius: "100px", overflow: "hidden" }}>
              <div style={{ width: `${progress}%`, height: "100%", background: "linear-gradient(90deg, #8b5cf6, #06b6d4)", transition: "width 0.5s ease" }} />
            </div>
          </div>

          <div style={{ display: "flex", gap: "12px", justifyContent: "center", flexWrap: "wrap" }}>
            <Link
              href="/"
              style={{
                background: "linear-gradient(135deg, #8b5cf6, #2563eb)",
                color: "#fff",
                padding: "12px 24px",
                borderRadius: "12px",
                fontWeight: 700,
                textDecoration: "none",
                fontSize: "0.9rem",
              }}
            >
              🚀 Continue Learning
            </Link>
            <button
              onClick={() => setPreviewUnlocked(true)}
              style={{
                background: "rgba(255,255,255,0.05)",
                color: "#94a3b8",
                border: "1px solid rgba(255,255,255,0.1)",
                padding: "12px 20px",
                borderRadius: "12px",
                fontWeight: 600,
                cursor: "pointer",
                fontSize: "0.9rem",
              }}
            >
              👁️ Preview Certificate
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff" }}>
      <div id="certificate-wrapper-parent">
        <div id="certificate-wrapper" style={{ maxWidth: "1000px", margin: "0 auto", padding: "60px 24px" }}>
          
          <div style={{ marginBottom: "24px", display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "12px" }}>
            <Link href="/profile" style={{ color: "#8b5cf6", textDecoration: "none", fontWeight: 700, display: "flex", alignItems: "center", gap: "6px" }}>
              ← Back to Profile
            </Link>
            {previewUnlocked && progress < 100 && (
              <span style={{ background: "rgba(245,158,11,0.15)", border: "1px solid rgba(245,158,11,0.3)", color: "#fbbf24", padding: "4px 12px", borderRadius: "100px", fontSize: "0.75rem", fontWeight: 700 }}>
                ⚡ PREVIEW MODE ({progress}% Complete)
              </span>
            )}
          </div>

          {/* Certificate Container */}
          <div 
            id="certificate" 
            ref={certificateRef}
            style={{ 
              background: "#080c14", 
              color: "#fff", 
              padding: "50px 40px", 
              borderRadius: "16px", 
              position: "relative",
              boxShadow: "0 30px 80px rgba(0,0,0,0.8), 0 0 0 1px rgba(139,92,246,0.2)",
              border: "4px double rgba(139,92,246,0.6)",
              textAlign: "center",
              overflow: "hidden"
            }}
          >
            {/* Decorative Corner Accents */}
            <div style={{ position: "absolute", top: 16, left: 16, borderTop: "2px solid #8b5cf6", borderLeft: "2px solid #8b5cf6", width: 32, height: 32 }} />
            <div style={{ position: "absolute", top: 16, right: 16, borderTop: "2px solid #8b5cf6", borderRight: "2px solid #8b5cf6", width: 32, height: 32 }} />
            <div style={{ position: "absolute", bottom: 16, left: 16, borderBottom: "2px solid #8b5cf6", borderLeft: "2px solid #8b5cf6", width: 32, height: 32 }} />
            <div style={{ position: "absolute", bottom: 16, right: 16, borderBottom: "2px solid #8b5cf6", borderRight: "2px solid #8b5cf6", width: 32, height: 32 }} />

            <div style={{ marginBottom: "16px", display: "flex", justifyContent: "center" }}>
              <img 
                src="/logo.png" 
                alt="Techaa Purinjikoo Logo" 
                style={{ width: "72px", height: "72px", objectFit: "contain", borderRadius: "50%", border: "2px solid rgba(139,92,246,0.5)", filter: "drop-shadow(0 0 16px rgba(139,92,246,0.4))" }} 
              />
            </div>
            
            <h4 style={{ textTransform: "uppercase", letterSpacing: "4px", color: "#8b5cf6", fontWeight: 800, marginBottom: "8px", fontSize: "0.85rem" }}>
              Certificate of Completion
            </h4>
            <p style={{ fontStyle: "italic", marginBottom: "16px", color: "#94a3b8", fontSize: "0.95rem" }}>
              This is to certify that
            </p>
            
            <h1 style={{ fontSize: "3.2rem", fontWeight: 900, color: "#fff", marginBottom: "6px", letterSpacing: "-1px", textTransform: "capitalize" }}>
              {user?.displayName || "Techaa Explorer"}
            </h1>
            
            <p style={{ color: "#94a3b8", marginBottom: "16px", fontSize: "0.95rem" }}>
              has successfully mastered the concepts of
            </p>

            <div style={{ padding: "8px 24px", background: "rgba(139,92,246,0.1)", border: "1px solid rgba(139,92,246,0.3)", borderRadius: "100px", display: "inline-block", marginBottom: "28px" }}>
              <h2 style={{ fontSize: "1.6rem", fontWeight: 800, background: "linear-gradient(135deg, #a78bfa, #38bdf8)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", margin: 0 }}>
                {certificateName}
              </h2>
            </div>

            <p style={{ maxWidth: "600px", margin: "0 auto 32px", lineHeight: 1.6, color: "#cbd5e1", fontSize: "0.95rem" }}>
              Demonstrated deep understanding of technology architectures, tools, and developer workflows through structured micro-learning on <strong style={{ color: "#a78bfa" }}>Techaa Purinjikoo</strong>.
            </p>

            <div style={{ display: "flex", justifyContent: "space-around", alignItems: "flex-end", width: "100%", flexWrap: "wrap", gap: "20px" }}>
              <div style={{ textAlign: "center" }}>
                <div style={{ borderBottom: "1px solid rgba(255,255,255,0.15)", width: "140px", marginBottom: "8px" }} />
                <div style={{ fontSize: "0.75rem", fontWeight: 700, color: "#94a3b8" }}>Date: {new Date().toLocaleDateString()}</div>
              </div>

              {/* Verified Seal */}
              <div style={{ width: "80px", height: "80px", borderRadius: "50%", background: "linear-gradient(135deg, #8b5cf6, #2563eb)", display: "flex", alignItems: "center", justifyContent: "center", border: "3px solid #080c14", boxShadow: "0 0 0 2px rgba(139,92,246,0.6), 0 8px 20px rgba(139,92,246,0.4)", flexShrink: 0 }}>
                <span style={{ color: "#fff", fontWeight: 900, fontSize: "0.75rem", textAlign: "center", lineHeight: 1.2 }}>
                  VERIFIED<br/>TECHAA
                </span>
              </div>
   
              <div style={{ textAlign: "center" }}>
                <div style={{ fontWeight: 800, fontSize: "1rem", color: "#fff", marginBottom: "6px", letterSpacing: "0.5px" }}>TECHAA PURINJIKOO</div>
                <div style={{ fontSize: "0.75rem", fontWeight: 700, color: "#94a3b8" }}>Verification ID: TP-L{levelId}X{user?.uid?.substring(0, 5).toUpperCase() || "TECH"}</div>
              </div>
            </div>
          </div>

          <div style={{ marginTop: "32px", textAlign: "center", display: "flex", gap: "12px", justifyContent: "center" }}>
            <button 
              onClick={downloadCertificate}
              style={{ background: "linear-gradient(135deg, #8b5cf6, #2563eb)", color: "#fff", border: "none", padding: "14px 28px", borderRadius: "12px", fontWeight: 800, cursor: "pointer", boxShadow: "0 10px 24px rgba(139,92,246,0.3)" }}
            >
              📥 Download Certificate (PDF)
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
