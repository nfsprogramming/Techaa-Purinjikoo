package services

import (
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"
	"sync"
	"time"

	"techaa-backend/internal/logger"
)

type otpEntry struct {
	Code      string
	Purpose   string
	CreatedAt time.Time
	ExpiresAt time.Time
	Attempts  int
}

type OTPService struct {
	emailService *EmailService
	mu           sync.RWMutex
	store        map[string]*otpEntry
}

func NewOTPService(emailService *EmailService) *OTPService {
	s := &OTPService{
		emailService: emailService,
		store:        make(map[string]*otpEntry),
	}
	go s.cleanupExpiredLoop()
	return s
}

func (s *OTPService) cleanupExpiredLoop() {
	ticker := time.NewTicker(2 * time.Minute)
	for range ticker.C {
		s.mu.Lock()
		now := time.Now()
		for key, entry := range s.store {
			if now.After(entry.ExpiresAt) {
				delete(s.store, key)
			}
		}
		s.mu.Unlock()
	}
}

// Generate6DigitCode generates a cryptographically secure 6-digit random number
func generate6DigitCode() (string, error) {
	nBig, err := rand.Int(rand.Reader, big.NewInt(900000))
	if err != nil {
		return "", err
	}
	code := nBig.Int64() + 100000
	return fmt.Sprintf("%06d", code), nil
}

func (s *OTPService) SendOTP(email string, purpose string) (string, error) {
	if email == "" {
		return "", errors.New("email is required")
	}

	key := fmt.Sprintf("%s:%s", email, purpose)

	s.mu.Lock()
	existing, exists := s.store[key]
	if exists && time.Since(existing.CreatedAt) < 45*time.Second {
		s.mu.Unlock()
		return "", errors.New("please wait 45 seconds before requesting another code")
	}

	code, err := generate6DigitCode()
	if err != nil {
		s.mu.Unlock()
		return "", fmt.Errorf("failed to generate secure code: %w", err)
	}

	now := time.Now()
	s.store[key] = &otpEntry{
		Code:      code,
		Purpose:   purpose,
		CreatedAt: now,
		ExpiresAt: now.Add(5 * time.Minute),
		Attempts:  0,
	}
	s.mu.Unlock()

	// Send branded HTML email via EmailService
	err = s.emailService.SendOTPEmail(email, code, purpose)
	if err != nil {
		logger.Log.Error("Failed to dispatch OTP email", "email", email, "error", err)
		return "", fmt.Errorf("failed to dispatch email: %w", err)
	}

	return code, nil
}

func (s *OTPService) VerifyOTP(email string, code string, purpose string) (bool, error) {
	if email == "" || code == "" {
		return false, errors.New("email and code are required")
	}

	key := fmt.Sprintf("%s:%s", email, purpose)

	s.mu.Lock()
	defer s.mu.Unlock()

	entry, exists := s.store[key]
	if !exists {
		return false, errors.New("no active verification code found for this email. please request a new one")
	}

	if time.Now().After(entry.ExpiresAt) {
		delete(s.store, key)
		return false, errors.New("verification code has expired. please request a new one")
	}

	if entry.Attempts >= 5 {
		delete(s.store, key)
		return false, errors.New("too many failed attempts. please request a new code")
	}

	entry.Attempts++

	if entry.Code != code {
		remaining := 5 - entry.Attempts
		return false, fmt.Errorf("invalid code. %d attempts remaining", remaining)
	}

	// Code is valid! Delete consumed OTP
	delete(s.store, key)
	logger.Log.Info("OTP successfully verified", "email", email, "purpose", purpose)
	return true, nil
}
