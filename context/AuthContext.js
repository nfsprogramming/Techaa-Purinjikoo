
"use client";
import React, { createContext, useContext, useEffect, useState } from "react";
import { onAuthStateChanged, signInWithPopup, signInWithRedirect, getRedirectResult, signOut, GoogleAuthProvider } from "firebase/auth";
import { auth, googleProvider, db } from "@/lib/firebase";
import { doc, getDoc, setDoc } from "firebase/firestore";

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Safety timeout: If auth hasn't resolved in 4s, stop loading to keep site usable
    const timer = setTimeout(() => {
      console.warn("Auth timeout reached. Forcing loading false.");
      setLoading(false);
    }, 4000);

    // Handle redirect result
    getRedirectResult(auth)
      .then((result) => {
        if (result) {
          console.log("Redirect Login Success:", result.user.displayName);
        }
      })
      .catch((error) => {
        console.error("Redirect Error:", error);
      });

    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      console.log("Auth State Changed. User:", user?.email || "No User");
      clearTimeout(timer); // Auth resolved, clear safety timer

      if (user) {
        setUser(user);
        setLoading(false); // Set loading false IMMEDIATELY to unblock UI
        
        // Background Firestore check
        const syncUserDoc = async () => {
          try {
            const userDocRef = doc(db, "users", user.uid);
            const userDoc = await getDoc(userDocRef);
            
            if (!userDoc.exists()) {
              await setDoc(userDocRef, {
                name: user.displayName,
                email: user.email,
                photoURL: user.photoURL,
                role: "user",
                createdAt: new Date().toISOString(),
                progress: { // Default progress structure
                  completedTopics: [],
                  xp: 0,
                  streak: 0,
                  lastLogin: null,
                  unlockedBadges: [],
                  level: 1
                }
              });
            }
          } catch (dbError) {
            console.warn("Firestore background sync issue:", dbError.message);
          }
        };
        syncUserDoc();
      } else {
        setUser(null);
        setLoading(false);
      }
    });

    return () => {
      unsubscribe();
      clearTimeout(timer);
    };
  }, []);

  const loginWithGoogle = async () => {
    try {
      setLoading(true);
      console.log("Attempting Google Popup Login...");
      const result = await signInWithPopup(auth, googleProvider);
      console.log("Popup Login Success:", result.user.displayName);
    } catch (error) {
      console.error("Login Error:", error.code, error.message);
      
      // Fallback to redirect if popup is blocked
      if (error.code === 'auth/popup-blocked') {
        console.log("Popup blocked, falling back to redirect...");
        try {
          await signInWithRedirect(auth, googleProvider);
        } catch (redirectError) {
          console.error("Redirect Fallback failed:", redirectError);
          alert("Login failed! Please check if Third-Party Cookies are enabled.");
        }
      } else {
        alert(`Login failed: ${error.message}`);
      }
    } finally {
      // Don't set loading false here because onAuthStateChanged will handle it
      // or the redirect will take over
    }
  };

  const logout = async () => {
    try {
      await signOut(auth);
    } catch (error) {
      console.error("Logout failed", error);
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, loginWithGoogle, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
