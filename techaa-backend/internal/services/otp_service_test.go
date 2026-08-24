package services

import (
	"testing"
	"time"

	"techaa-backend/internal/config"
)

func TestOTPServiceSendAndVerify(t *testing.T) {
	cfg := &config.Config{
		Env:            "test",
		SMTPFrom:       "test@techaapurinjikoo.dev",
		SMTPSenderName: "Techaa Test",
	}
	emailService := NewEmailService(cfg)
	otpService := NewOTPService(emailService)

	email := "testuser@example.com"
	purpose := "verification"

	// 1. Generate and send OTP
	code, err := otpService.SendOTP(email, purpose)
	if err != nil {
		t.Fatalf("SendOTP failed: %v", err)
	}
	if len(code) != 6 {
		t.Fatalf("Expected 6-digit code, got %s", code)
	}

	// 2. Fail with wrong code
	ok, err := otpService.VerifyOTP(email, "000000", purpose)
	if ok || err == nil {
		t.Fatalf("Expected verification to fail with wrong code")
	}

	// 3. Succeed with correct code
	ok, err = otpService.VerifyOTP(email, code, purpose)
	if !ok || err != nil {
		t.Fatalf("Expected verification to succeed with correct code: %v", err)
	}

	// 4. Once verified, code should be consumed
	ok, err = otpService.VerifyOTP(email, code, purpose)
	if ok || err == nil {
		t.Fatalf("Expected second verification with same code to fail (single use)")
	}
}

func TestOTPServiceRateLimit(t *testing.T) {
	cfg := &config.Config{Env: "test"}
	emailService := NewEmailService(cfg)
	otpService := NewOTPService(emailService)

	email := "ratelimit@example.com"
	purpose := "reset_password"

	_, err := otpService.SendOTP(email, purpose)
	if err != nil {
		t.Fatalf("First SendOTP failed: %v", err)
	}

	// Immediate second call should hit rate limit
	_, err = otpService.SendOTP(email, purpose)
	if err == nil {
		t.Fatalf("Expected rate limit error on immediate second request")
	}
}

func TestOTPServiceExpiration(t *testing.T) {
	cfg := &config.Config{Env: "test"}
	emailService := NewEmailService(cfg)
	otpService := NewOTPService(emailService)

	email := "expired@example.com"
	purpose := "verification"

	code, err := otpService.SendOTP(email, purpose)
	if err != nil {
		t.Fatalf("SendOTP failed: %v", err)
	}

	// Artificially expire the token
	otpService.mu.Lock()
	key := email + ":" + purpose
	otpService.store[key].ExpiresAt = time.Now().Add(-1 * time.Minute)
	otpService.mu.Unlock()

	ok, err := otpService.VerifyOTP(email, code, purpose)
	if ok || err == nil {
		t.Fatalf("Expected verification to fail for expired code")
	}
}
