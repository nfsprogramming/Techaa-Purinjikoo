
import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth, GoogleAuthProvider } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyBV5jD4JfI-SM4CmrzyjLa9XQqn97Uj9dk",
  authDomain: "techaa-purinjikoo.firebaseapp.com",
  projectId: "techaa-purinjikoo",
  storageBucket: "techaa-purinjikoo.firebasestorage.app",
  messagingSenderId: "414743824161",
  appId: "1:414743824161:web:c090fa89d0887b05ec2060"
};

// Initialize Firebase
const app = getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const googleProvider = new GoogleAuthProvider();

export { auth, db, googleProvider };
