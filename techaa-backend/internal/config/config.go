package config

import (
	"bufio"
	"os"
	"strconv"
	"strings"
)

type Config struct {
	Port                 string
	Env                  string
	AppName              string
	DatabaseURL          string
	FirebaseProjectID    string
	FirebaseCredentials  string
	AllowedOrigins       string
	RateLimitPerMinute   int
	CertificateVerifyURL string
	SMTPHost             string
	SMTPPort             string
	SMTPUser             string
	SMTPPass             string
	SMTPFrom             string
	SMTPSenderName       string
}

func loadDotEnv() {
	file, err := os.Open(".env")
	if err != nil {
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 {
			k := strings.TrimSpace(parts[0])
			v := strings.TrimSpace(parts[1])
			if os.Getenv(k) == "" {
				_ = os.Setenv(k, v)
			}
		}
	}
}

func Load() *Config {
	loadDotEnv()

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	env := os.Getenv("ENV")
	if env == "" {
		env = "development"
	}

	appName := os.Getenv("APP_NAME")
	if appName == "" {
		appName = "Techaa-Purinjikoo-Backend"
	}

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://postgres:postgres@localhost:5432/techaa_purinjikoo?sslmode=disable"
	}

	rateLimitStr := os.Getenv("RATE_LIMIT_PER_MINUTE")
	rateLimit := 120
	if val, err := strconv.Atoi(rateLimitStr); err == nil && val > 0 {
		rateLimit = val
	}

	allowedOrigins := os.Getenv("ALLOWED_ORIGINS")
	if allowedOrigins == "" {
		allowedOrigins = "*"
	}

	certVerifyURL := os.Getenv("CERTIFICATE_VERIFY_URL")
	if certVerifyURL == "" {
		certVerifyURL = "https://techaa-purinjikoo.vercel.app/verify"
	}

	smtpFrom := os.Getenv("SMTP_FROM")
	if smtpFrom == "" {
		smtpFrom = "no-reply@techaapurinjikoo.dev"
	}

	smtpSenderName := os.Getenv("SMTP_SENDER_NAME")
	if smtpSenderName == "" {
		smtpSenderName = "Techaa Purinjikoo"
	}

	return &Config{
		Port:                 port,
		Env:                  env,
		AppName:              appName,
		DatabaseURL:          dbURL,
		FirebaseProjectID:    os.Getenv("FIREBASE_PROJECT_ID"),
		FirebaseCredentials:  os.Getenv("FIREBASE_CREDENTIALS_FILE"),
		AllowedOrigins:       allowedOrigins,
		RateLimitPerMinute:   rateLimit,
		CertificateVerifyURL: certVerifyURL,
		SMTPHost:             os.Getenv("SMTP_HOST"),
		SMTPPort:             os.Getenv("SMTP_PORT"),
		SMTPUser:             os.Getenv("SMTP_USER"),
		SMTPPass:             os.Getenv("SMTP_PASS"),
		SMTPFrom:             smtpFrom,
		SMTPSenderName:       smtpSenderName,
	}
}
