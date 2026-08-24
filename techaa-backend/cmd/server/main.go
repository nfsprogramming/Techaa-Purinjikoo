package main

import (
	"context"
	"errors"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"techaa-backend/internal/config"
	"techaa-backend/internal/database"
	"techaa-backend/internal/http/handlers"
	"techaa-backend/internal/http/router"
	"techaa-backend/internal/logger"
	"techaa-backend/internal/services"
)

func main() {
	cfg := config.Load()
	logger.Init(cfg.Env)

	logger.Log.Info("Starting Techaa Purinjikoo Backend V1",
		"env", cfg.Env,
		"port", cfg.Port,
		"rate_limit", cfg.RateLimitPerMinute,
	)

	// 1. Connect to PostgreSQL
	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		logger.Log.Error("Fatal database connection failure", "error", err)
		os.Exit(1)
	}
	defer db.Close()

	// 2. Run schema migrations automatically on startup
	if err := db.RunMigrations(database.SchemaSQL); err != nil {
		logger.Log.Warn("Migration execution notice", "details", err)
	}

	// 3. Initialize services
	xpService := services.NewXPService(db)
	achievementService := services.NewAchievementService(db, xpService)
	streakService := services.NewStreakService(db, xpService)
	authService := services.NewAuthService(db)
	progressService := services.NewProgressService(db, xpService, achievementService, streakService, authService)
	certificateService := services.NewCertificateService(db, xpService, authService, cfg.CertificateVerifyURL)
	syncService := services.NewSyncService(db, xpService, achievementService, streakService, authService)
	emailService := services.NewEmailService(cfg)
	otpService := services.NewOTPService(emailService)

	// 4. Initialize HTTP handlers and router
	h := handlers.NewHandlers(
		db,
		authService,
		progressService,
		xpService,
		achievementService,
		streakService,
		certificateService,
		syncService,
		otpService,
	)

	r := router.New(cfg, h, authService)

	// 5. Start Server with graceful shutdown
	server := &http.Server{
		Addr:         "0.0.0.0:" + cfg.Port,
		Handler:      r,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	go func() {
		logger.Log.Info("HTTP server listening", "addr", server.Addr)
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Log.Error("Server error", "error", err)
			os.Exit(1)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Log.Info("Shutting down server gracefully...")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		logger.Log.Error("Server forced shutdown", "error", err)
	}
	logger.Log.Info("Server stopped")
}
