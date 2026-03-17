
"use client";
import { useAuth } from "@/context/AuthContext";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { db } from "@/lib/firebase";
import { collection, getDocs } from "firebase/firestore";
import { motion } from "framer-motion";

export default function AdminPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [users, setUsers] = useState([]);
  const [stats, setStats] = useState({ totalUsers: 0, completions: 0 });

  // Simple admin check - replace with your own email or role logic
  const isAdmin = user?.email === "admin@example.com" || user?.email === "your-email@gmail.com"; 

  useEffect(() => {
    if (!loading && !isAdmin) {
      // router.push("/"); // Uncomment to protect route
    }

    if (isAdmin) {
      fetchUsers();
    }
  }, [user, loading]);

  const fetchUsers = async () => {
    const querySnapshot = await getDocs(collection(db, "users"));
    const userData = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    setUsers(userData);
    setStats({ totalUsers: userData.length, completions: 0 });
  };

  if (loading) return <div style={{ color: "#fff", padding: "100px", textAlign: "center" }}>Loading Admin Bro... ☕</div>;

  return (
    <div style={{ background: "#070711", minHeight: "100vh", color: "#fff", padding: "100px 24px" }}>
      <div style={{ maxWidth: "1200px", margin: "0 auto" }}>
        
        {/* Back Button */}
        <motion.div initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }}>
          <Link href="/" style={{ display: "inline-flex", alignItems: "center", gap: "8px", color: "#64748b", textDecoration: "none", fontSize: "0.9rem", fontWeight: 700, marginBottom: "32px", padding: "8px 16px", background: "rgba(255,255,255,0.03)", border: "1px solid rgba(255,255,255,0.06)", borderRadius: "12px", transition: "0.2s" }}>
            <span>←</span> Back to Home
          </Link>
        </motion.div>

        <h1 style={{ fontSize: "2.5rem", fontWeight: 900, marginBottom: "40px" }}>
          Admin <span style={{ color: "#8b5cf6" }}>Control Center</span> 🛠️
        </h1>

        <div style={{ gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))", display: "grid", gap: "24px", marginBottom: "60px" }}>
          <div style={{ background: "rgba(255,255,255,0.03)", padding: "32px", borderRadius: "24px", border: "1px solid rgba(255,255,255,0.05)" }}>
            <div style={{ fontSize: "0.9rem", color: "#94a3b8", fontWeight: 700, textTransform: "uppercase" }}>Total Learners</div>
            <div style={{ fontSize: "3rem", fontWeight: 900 }}>{stats.totalUsers}</div>
          </div>
          <div style={{ background: "rgba(255,255,255,0.03)", padding: "32px", borderRadius: "24px", border: "1px solid rgba(255,255,255,0.05)" }}>
            <div style={{ fontSize: "0.9rem", color: "#94a3b8", fontWeight: 700, textTransform: "uppercase" }}>Active Sessions</div>
            <div style={{ fontSize: "3rem", fontWeight: 900 }}>{users.length > 0 ? "Live" : "Idle"}</div>
          </div>
        </div>

        <h2 style={{ fontSize: "1.5rem", fontWeight: 800, marginBottom: "20px" }}>User Management</h2>
        <div style={{ overflowX: "auto", background: "rgba(255,255,255,0.03)", borderRadius: "16px", border: "1px solid rgba(255,255,255,0.05)" }}>
          <table style={{ width: "100%", borderCollapse: "collapse", textAlign: "left" }}>
            <thead>
              <tr style={{ borderBottom: "1px solid rgba(255,255,255,0.1)" }}>
                <th style={{ padding: "20px" }}>User</th>
                <th style={{ padding: "20px" }}>Email</th>
                <th style={{ padding: "20px" }}>Joined</th>
                <th style={{ padding: "20px" }}>Role</th>
              </tr>
            </thead>
            <tbody>
              {users.map(u => (
                <tr key={u.id} style={{ borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
                  <td style={{ padding: "20px", display: "flex", alignItems: "center", gap: "12px" }}>
                    <img 
                      src={u.photoURL || `https://ui-avatars.com/api/?name=${u.name}&background=8b5cf6&color=fff`} 
                      style={{ width: "32px", height: "32px", borderRadius: "50%" }} 
                      referrerPolicy="no-referrer"
                      onError={(e) => { e.target.src = `https://ui-avatars.com/api/?name=${u.name || 'User'}&background=8b5cf6&color=fff`; }}
                    />
                    <span style={{ fontWeight: 600 }}>{u.name}</span>
                  </td>
                  <td style={{ padding: "20px", color: "#94a3b8" }}>{u.email}</td>
                  <td style={{ padding: "20px", color: "#94a3b8" }}>{u.createdAt?.split('T')[0]}</td>
                  <td style={{ padding: "20px" }}>
                    <span style={{ background: "rgba(139,92,246,0.1)", color: "#8b5cf6", padding: "4px 12px", borderRadius: "100px", fontSize: "0.8rem", fontWeight: 700 }}>{u.role}</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
