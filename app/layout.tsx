
import React from "react";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
// @ts-ignore – JSX components, types resolved at runtime
import Navbar from "@/components/Navbar";

const geistSans = Geist({ variable: "--font-geist-sans", subsets: ["latin"] });
const geistMono = Geist_Mono({ variable: "--font-geist-mono", subsets: ["latin"] });
// @ts-ignore
import { AuthProvider } from "@/context/AuthContext";
// @ts-ignore
import { UserProgressProvider } from "@/context/UserProgressContext";

export const metadata = {
  title: "Techaa Purinjikoo ☕ — Learning Portal for All",
  description: "Tech topics explained in friendly Tanglish conversation style. Micro learning, analogies, real use cases — bayam illama kathukalam!",
  keywords: "tech learning, Tamil, Tanglish, vercel, github, APIs, AI, deployment, beginners",
  icons: {
    icon: '/favicon.png',
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ta">
      <body className={`${geistSans.variable} ${geistMono.variable} antialiased`}>
        <AuthProvider>
          <UserProgressProvider>
            <Navbar />
            <main style={{ paddingTop: "64px", minHeight: "100vh" }}>
              {children}
            </main>
          </UserProgressProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
