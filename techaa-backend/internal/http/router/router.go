package router

import (
	"net/http"
	"strings"
	"time"

	"techaa-backend/internal/config"
	"techaa-backend/internal/http/handlers"
	"techaa-backend/internal/http/middleware"
	"techaa-backend/internal/services"
)

func New(cfg *config.Config, h *handlers.Handlers, authService *services.AuthService) http.Handler {
	mux := http.NewServeMux()

	authMW := middleware.Auth(authService)
	rateLimiter := middleware.NewRateLimiter(cfg.RateLimitPerMinute, time.Minute)

	// Public Routes
	mux.HandleFunc("GET /", h.Root)
	mux.HandleFunc("GET /health", h.Health)
	mux.HandleFunc("GET /health/ready", h.HealthReady)
	mux.HandleFunc("GET /api/v1/certificates/verify/", h.VerifyCertificatePublic)
	mux.HandleFunc("POST /api/v1/reports", h.SubmitReport)
	mux.HandleFunc("POST /api/v1/analytics/events", h.RecordAnalyticsEvent)
	mux.HandleFunc("POST /api/v1/auth/otp/send", h.SendOTP)
	mux.HandleFunc("POST /api/v1/auth/otp/verify", h.VerifyOTP)

	// Protected Routes (Wrapped with Auth Middleware)
	mux.Handle("GET /api/v1/auth/me", authMW(http.HandlerFunc(h.GetMe)))
	mux.Handle("GET /api/v1/profile", authMW(http.HandlerFunc(h.GetProfile)))
	mux.Handle("PATCH /api/v1/profile", authMW(http.HandlerFunc(h.UpdateProfile)))

	mux.Handle("GET /api/v1/progress", authMW(http.HandlerFunc(h.GetProgressSummary)))
	mux.Handle("POST /api/v1/progress/topics/", authMW(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasSuffix(r.URL.Path, "/complete") {
			h.CompleteTopic(w, r)
		} else {
			http.NotFound(w, r)
		}
	})))

	mux.Handle("GET /api/v1/xp/summary", authMW(http.HandlerFunc(h.GetXPSummary)))
	mux.Handle("GET /api/v1/badges", authMW(http.HandlerFunc(h.GetBadges)))
	mux.Handle("GET /api/v1/streak", authMW(http.HandlerFunc(h.GetStreak)))

	mux.Handle("GET /api/v1/courses/progress", authMW(http.HandlerFunc(h.GetCoursesProgress)))
	mux.Handle("POST /api/v1/courses/", authMW(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasSuffix(r.URL.Path, "/claim-certificate") {
			h.ClaimCourseCertificate(w, r)
		} else {
			http.NotFound(w, r)
		}
	})))

	mux.Handle("GET /api/v1/bookmarks", authMW(http.HandlerFunc(h.GetBookmarks)))
	mux.Handle("POST /api/v1/bookmarks", authMW(http.HandlerFunc(h.AddBookmark)))
	mux.Handle("DELETE /api/v1/bookmarks/", authMW(http.HandlerFunc(h.RemoveBookmark)))

	mux.Handle("POST /api/v1/quizzes/", authMW(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasSuffix(r.URL.Path, "/complete") {
			h.SubmitQuizAttempt(w, r)
		} else {
			http.NotFound(w, r)
		}
	})))

	mux.Handle("GET /api/v1/certificates", authMW(http.HandlerFunc(h.GetMyCertificates)))
	mux.Handle("POST /api/v1/sync", authMW(http.HandlerFunc(h.Sync)))

	// Global Middleware Chain: RequestID -> Logger -> CORS -> RateLimiter -> Mux
	var handler http.Handler = mux
	handler = rateLimiter.Middleware(handler)
	handler = middleware.CORS(cfg.AllowedOrigins)(handler)
	handler = middleware.Logger(handler)
	handler = middleware.RequestID(handler)

	return handler
}
