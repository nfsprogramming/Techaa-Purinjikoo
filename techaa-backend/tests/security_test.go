package tests

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"techaa-backend/internal/http/middleware"
	"techaa-backend/internal/models"
)

func TestRateLimiter(t *testing.T) {
	limiter := middleware.NewRateLimiter(5, time.Second)
	testHandler := limiter.Middleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok"))
	}))

	for i := 0; i < 5; i++ {
		req := httptest.NewRequest("GET", "/test", nil)
		req.RemoteAddr = "192.168.1.1:1234"
		rr := httptest.NewRecorder()
		testHandler.ServeHTTP(rr, req)

		if rr.Code != http.StatusOK {
			t.Fatalf("Request %d expected 200, got %d", i+1, rr.Code)
		}
	}

	// 6th request should hit rate limit (429)
	req := httptest.NewRequest("GET", "/test", nil)
	req.RemoteAddr = "192.168.1.1:1234"
	rr := httptest.NewRecorder()
	testHandler.ServeHTTP(rr, req)

	if rr.Code != http.StatusTooManyRequests {
		t.Fatalf("Expected 429 Too Many Requests, got %d", rr.Code)
	}

	var apiErr models.APIError
	if err := json.NewDecoder(rr.Body).Decode(&apiErr); err != nil {
		t.Fatalf("Failed to parse API error response: %v", err)
	}

	if apiErr.Error.Code != "RATE_LIMIT_EXCEEDED" {
		t.Errorf("Expected error code RATE_LIMIT_EXCEEDED, got %s", apiErr.Error.Code)
	}
}

func TestCORSHeaders(t *testing.T) {
	corsHandler := middleware.CORS("*")(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	req := httptest.NewRequest("OPTIONS", "/api/v1/progress", nil)
	rr := httptest.NewRecorder()
	corsHandler.ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("Expected 200 on OPTIONS preflight, got %d", rr.Code)
	}
	if origin := rr.Header().Get("Access-Control-Allow-Origin"); origin != "*" {
		t.Errorf("Expected Access-Control-Allow-Origin *, got %s", origin)
	}
}
