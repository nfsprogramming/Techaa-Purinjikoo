
"use client";
import { useParams } from "next/navigation";
import { useUserProgress } from "@/context/UserProgressContext";
import { useAuth } from "@/context/AuthContext";
import Navbar from "@/components/Navbar";
import { useEffect, useState } from "react";

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
  const levelId = parseInt(params.levelId);
  const progress = getLevelProgress(levelId);
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(true);
  }, []);

  if (!isClient) return null;

  if (progress < 100) {
    return (
      <div style={{ background: "#070711", minHeight: "100vh", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", flexDirection: "column" }}>
        <h2>Level Not Complete Bro! 😅</h2>
        <p>Complete all topics in this level to earn your certificate.</p>
      </div>
    );
  }

  const certificateName = LEVEL_NAMES[levelId] || "Technical Excellence";

  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff" }}>
      <style>{`
        @media print {
          @page {
            size: landscape;
            margin: 0;
          }

          /* 1. Global Reset */
          html, body {
            height: 100vh !important;
            width: 100vw !important;
            margin: 0 !important;
            padding: 0 !important;
            overflow: hidden !important;
            background: #0a0a0a !important;
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
          }

          /* 2. Target Isolation Strategy */
          /* Hide EVERYTHING in the DOM tree */
          body * {
            visibility: hidden !important;
          }

          /* Specifically restore visibility only for the certificate path */
          #certificate-wrapper-parent,
          #certificate-wrapper-parent *,
          #certificate,
          #certificate * {
            visibility: visible !important;
          }

          /* 3. Position the certificate to take over the print page */
          #certificate-wrapper-parent {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100vw !important;
            height: 100vh !important;
            background: #0a0a0a !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            margin: 0 !important;
            padding: 0 !important;
            z-index: 9999999 !important;
          }

          #certificate {
            width: 92vw !important;
            height: 88vh !important;
            border: 15px double #ff3131 !important;
            background: #0a0a0a !important;
            padding: 30px !important;
            box-sizing: border-box !important;
            display: flex !important;
            flex-direction: column !important;
            justify-content: space-around !important;
            align-items: center !important;
            color: #fff !important;
            box-shadow: none !important;
            border-radius: 0 !important;
            page-break-inside: avoid !important;
          }

          /* 4. Polish Typography */
          h1 { font-size: 3rem !important; margin: 5px 0 !important; color: #fff !important; line-height: 1 !important; }
          h2 { font-size: 1.8rem !important; color: #ff3131 !important; -webkit-text-fill-color: #ff3131 !important; }
          h4 { font-size: 1rem !important; color: #64748b !important; }
          p { font-size: 0.95rem !important; color: #cbd5e1 !important; }
          img { width: 90px !important; filter: none !important; }
          
          .sig-row-print { width: 95% !important; display: flex !important; justify-content: space-around !important; align-items: flex-end !important; }
          .seal-circle-print { width: 90px !important; height: 90px !important; }

          /* Final cleanup */
          button, .no-print, nav, footer { display: none !important; }
        }
      `}</style>

      <div id="certificate-wrapper-parent">
        <div id="certificate-wrapper" style={{ maxWidth: "1000px", margin: "0 auto", padding: "120px 24px 60px" }}>
        {/* Certificate Container */}
        <div id="certificate" style={{ 
          background: "#0a0a0a", 
          color: "#fff", 
          padding: "60px", 
          borderRadius: "8px", 
          position: "relative",
          boxShadow: "0 40px 100px rgba(0,0,0,0.8), 0 0 0 20px rgba(255,49,49,0.05)",
          border: "10px double #ff3131",
          textAlign: "center",
          overflow: "hidden"
        }}>
          {/* Decorative Corner */}
          <div style={{ position: "absolute", top: 20, left: 20, borderTop: "2px solid #ff3131", borderLeft: "2px solid #ff3131", width: 40, height: 40 }} />
          <div style={{ position: "absolute", top: 20, right: 20, borderTop: "2px solid #ff3131", borderRight: "2px solid #ff3131", width: 40, height: 40 }} />
          <div style={{ position: "absolute", bottom: 20, left: 20, borderBottom: "2px solid #ff3131", borderLeft: "2px solid #ff3131", width: 40, height: 40 }} />
          <div style={{ position: "absolute", bottom: 20, right: 20, borderBottom: "2px solid #ff3131", borderRight: "2px solid #ff3131", width: 40, height: 40 }} />

          <div style={{ marginBottom: "20px", display: "flex", justifyContent: "center" }}>
            <img 
              src="/favicon.png" 
              alt="NFS Logo" 
              style={{ width: "80px", height: "auto", filter: "drop-shadow(0 0 15px rgba(139,92,246,0.4))" }} 
            />
          </div>
          
          <h4 style={{ textTransform: "uppercase", letterSpacing: "4px", color: "#64748b", fontWeight: 800, marginBottom: "10px", fontSize: "0.9rem" }}>Certificate of Completion</h4>
          <p style={{ fontStyle: "italic", marginBottom: "20px", color: "#94a3b8" }}>This is to certify that</p>
          
          <h1 style={{ fontSize: "4.5rem", fontWeight: 950, color: "#fff", marginBottom: "5px", letterSpacing: "-2px", textTransform: "capitalize" }}>
            {user?.displayName || "NFS Student"}
          </h1>
          
          <p style={{ color: "#94a3b8", marginBottom: "20px" }}>has successfully mastered the concepts of</p>
          

          <div style={{ padding: "10px 30px", background: "rgba(255,49,49,0.05)", border: "1px solid rgba(255,49,49,0.2)", borderRadius: "100px", display: "inline-block", marginBottom: "40px" }}>
            <h2 style={{ fontSize: "2rem", fontWeight: 800, background: "linear-gradient(135deg, #ff3131, #8b5cf6)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", margin: 0 }}>
              {certificateName}
            </h2>
          </div>

          <p style={{ maxWidth: "650px", margin: "0 auto 40px", lineHeight: 1.6, color: "#cbd5e1", fontSize: "1rem" }}>
            By completing 100% of the structured learning roadmap on <strong style={{color: "#ff3131"}}>Techaa Purinjikoo</strong>, demonstrating deep understanding of modern tech architectures, tools, and developer workflows.
          </p>

          <div className="sig-row-print" style={{ display: "flex", justifyContent: "space-around", alignItems: "flex-end", width: "100%" }}>
            <div style={{ textAlign: "center" }}>
              <div style={{ borderBottom: "1px solid rgba(255,255,255,0.1)", width: "150px", marginBottom: "10px" }} />
              <div style={{ fontSize: "0.8rem", fontWeight: 700, color: "#94a3b8" }}>Date: {new Date().toLocaleDateString()}</div>
            </div>

            {/* Seal */}
            <div className="seal-circle-print" style={{ width: "100px", height: "100px", borderRadius: "50%", background: "#ff3131", display: "flex", alignItems: "center", justifyContent: "center", border: "4px solid #0a0a0a", boxShadow: "0 0 0 2px #ff3131, 0 10px 20px rgba(255,49,49,0.3)", flexShrink: 0 }}>
              <span style={{ color: "#fff", fontWeight: 900, fontSize: "0.9rem", textAlign: "center" }}>NFS<br/>TECH</span>
            </div>
 
            <div style={{ textAlign: "center" }}>
              <div style={{ fontWeight: 900, fontSize: "1.2rem", color: "#fff", marginBottom: "10px", letterSpacing: "1px" }}>TECHAA PURINJIKOO</div>
              <div style={{ fontSize: "0.8rem", fontWeight: 700, color: "#94a3b8" }}>Verification ID: NFS-L{levelId}X{user?.uid?.substring(0, 5).toUpperCase() || "TECH"}</div>
            </div>
          </div>
        </div>

        <div style={{ marginTop: "40px", textAlign: "center" }}>
          <button 
            onClick={() => window.print()}
            style={{ background: "#ff3131", color: "#fff", border: "none", padding: "14px 32px", borderRadius: "12px", fontWeight: 800, cursor: "pointer", boxShadow: "0 10px 20px rgba(255,49,49,0.2)" }}
          >
            🖨️ Print / Save as PDF
          </button>
        </div>
        </div>
      </div>
    </div>
  );
}
