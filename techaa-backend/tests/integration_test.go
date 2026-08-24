package tests

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"techaa-backend/internal/config"
	"techaa-backend/internal/gamification"
	"techaa-backend/internal/http/handlers"
	"techaa-backend/internal/http/router"
	"techaa-backend/internal/logger"
	"techaa-backend/internal/services"
)

func TestGamificationRules(t *testing.T) {
	// 1. Verify Level bounds
	lvl1 := gamification.CalculateLevel(0)
	if lvl1.Level != 1 || lvl1.Title != "Curious Beginner" {
		t.Fatalf("Expected Level 1 Curious Beginner, got Level %d %s", lvl1.Level, lvl1.Title)
	}

	lvl7 := gamification.CalculateLevel(15000)
	if lvl7.Level != 7 || lvl7.Title != "Tech Legend" {
		t.Fatalf("Expected Level 7 Tech Legend, got Level %d %s", lvl7.Level, lvl7.Title)
	}

	// 2. Verify XP values
	if gamification.XPAwards["READ_TOPIC"] != 10 {
		t.Fatalf("Expected READ_TOPIC XP to be 10, got %d", gamification.XPAwards["READ_TOPIC"])
	}
	if gamification.XPAwards["QUIZ_CORRECT"] != 20 {
		t.Fatalf("Expected QUIZ_CORRECT XP to be 20, got %d", gamification.XPAwards["QUIZ_CORRECT"])
	}
	if gamification.XPAwards["COURSE_COMPLETED"] != 100 {
		t.Fatalf("Expected COURSE_COMPLETED XP to be 100, got %d", gamification.XPAwards["COURSE_COMPLETED"])
	}
}

func TestCourseDefinitions(t *testing.T) {
	if len(services.CourseDefinitions) != 3 {
		t.Fatalf("Expected 3 course definitions, got %d", len(services.CourseDefinitions))
	}

	for id, c := range services.CourseDefinitions {
		if id == "" || c.Name == "" || len(c.RequiredTopics) == 0 {
			t.Fatalf("Invalid course definition for %s: %+v", id, c)
		}
	}
}

func TestPublicHealthAndRootEndpoints(t *testing.T) {
	logger.Init("test")
	cfg := &config.Config{
		Port:               "8080",
		Env:                "test",
		RateLimitPerMinute: 1000,
		AllowedOrigins:     "*",
	}

	h := handlers.NewHandlers(nil, nil, nil, nil, nil, nil, nil, nil, nil)
	r := router.New(cfg, h, nil)

	// Test GET /
	reqRoot := httptest.NewRequest("GET", "/", nil)
	recRoot := httptest.NewRecorder()
	r.ServeHTTP(recRoot, reqRoot)

	if recRoot.Code != http.StatusOK {
		t.Fatalf("Expected GET / to return 200, got %d", recRoot.Code)
	}

	var rootResp map[string]interface{}
	if err := json.NewDecoder(recRoot.Body).Decode(&rootResp); err != nil {
		t.Fatalf("Failed to parse root response: %v", err)
	}
	if rootResp["status"] != "operational" {
		t.Fatalf("Expected status operational, got %v", rootResp["status"])
	}

	// Test GET /health
	reqHealth := httptest.NewRequest("GET", "/health", nil)
	recHealth := httptest.NewRecorder()
	r.ServeHTTP(recHealth, reqHealth)

	if recHealth.Code != http.StatusOK {
		t.Fatalf("Expected GET /health to return 200, got %d", recHealth.Code)
	}
}

func TestAuthProtectionOnSecuredRoutes(t *testing.T) {
	logger.Init("test")
	cfg := &config.Config{
		Port:               "8080",
		Env:                "production",
		RateLimitPerMinute: 1000,
		AllowedOrigins:     "*",
	}

	h := handlers.NewHandlers(nil, nil, nil, nil, nil, nil, nil, nil, nil)
	r := router.New(cfg, h, nil)

	type routeTest struct {
		method string
		path   string
	}

	securedRoutes := []routeTest{
		{"GET", "/api/v1/auth/me"},
		{"GET", "/api/v1/profile"},
		{"PATCH", "/api/v1/profile"},
		{"GET", "/api/v1/progress"},
		{"POST", "/api/v1/progress/topics/topic_html/complete"},
		{"GET", "/api/v1/xp/summary"},
		{"GET", "/api/v1/badges"},
		{"GET", "/api/v1/streak"},
		{"GET", "/api/v1/courses/progress"},
		{"POST", "/api/v1/courses/c_web_dev/claim-certificate"},
		{"GET", "/api/v1/bookmarks"},
		{"POST", "/api/v1/bookmarks"},
		{"POST", "/api/v1/quizzes/topic_html/complete"},
		{"GET", "/api/v1/certificates"},
		{"POST", "/api/v1/sync"},
	}

	for _, rt := range securedRoutes {
		req := httptest.NewRequest(rt.method, rt.path, nil)
		rec := httptest.NewRecorder()
		r.ServeHTTP(rec, req)

		if rec.Code != http.StatusUnauthorized {
			t.Errorf("Path [%s %s] expected 401 Unauthorized without token, got %d", rt.method, rt.path, rec.Code)
		}
	}
}
