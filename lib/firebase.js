
import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth, GoogleAuthProvider } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY || "AIzaSyBV5jD4JfI-SM4CmrzyjLa9XQqn97Uj9dk",
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN || "techaa-purinjikoo.firebaseapp.com",
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || "techaa-purinjikoo",
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET || "techaa-purinjikoo.firebasestorage.app",
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID || "414743824161",
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID || "1:414743824161:web:c090fa89d0887b05ec2060",
};

// Initialize Firebase with fallback support for all environments
let app, auth, db, googleProvider;

try {
  if (firebaseConfig.apiKey) {
    app = getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);
    auth = getAuth(app);
    db = getFirestore(app);
    googleProvider = new GoogleAuthProvider();
  } else {
    throw new Error("Missing Firebase API Key");
  }
} catch (error) {
  console.warn("⚠️ Firebase Initialization Warning:", error.message);
  console.warn("Please add your actual Firebase credentials down in `.env.local` to use authentication features.");
  
  // Provide null so components know Firebase isn't correctly initialized
  auth = null;
  db = null;
  googleProvider = null;
}

export { auth, db, googleProvider };
