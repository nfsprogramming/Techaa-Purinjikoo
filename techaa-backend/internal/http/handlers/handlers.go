package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"techaa-backend/internal/database"
	"techaa-backend/internal/gamification"
	"techaa-backend/internal/http/middleware"
	"techaa-backend/internal/models"
	"techaa-backend/internal/services"
)

type Handlers struct {
	db                  *database.DB
	authService         *services.AuthService
	progressService     *services.ProgressService
	xpService           *services.XPService
	achievementService  *services.AchievementService
	streakService       *services.StreakService
	certificateService  *services.CertificateService
	syncService         *services.SyncService
	otpService          *services.OTPService
}

func NewHandlers(
	db *database.DB,
	authService *services.AuthService,
	progressService *services.ProgressService,
	xpService *services.XPService,
	achievementService *services.AchievementService,
	streakService *services.StreakService,
	certificateService *services.CertificateService,
	syncService *services.SyncService,
	otpService *services.OTPService,
) *Handlers {
	return &Handlers{
		db:                 db,
		authService:        authService,
		progressService:    progressService,
		xpService:          xpService,
		achievementService: achievementService,
		streakService:      streakService,
		certificateService: certificateService,
		syncService:        syncService,
		otpService:         otpService,
	}
}

func respondJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}

func respondError(w http.ResponseWriter, status int, code, message string) {
	respondJSON(w, status, models.APIError{
		Error: struct {
			Code    string `json:"code"`
			Message string `json:"message"`
		}{
			Code:    code,
			Message: message,
		},
	})
}

func getUserFromContext(r *http.Request) *models.User {
	u, _ := r.Context().Value(middleware.UserKey).(*models.User)
	return u
}

// Root & Health Handlers
func (h *Handlers) Root(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	respondJSON(w, http.StatusOK, map[string]interface{}{
		"service":     "Techaa Purinjikoo Backend V1",
		"status":      "operational",
		"version":     "1.0.0",
		"description": "Ultra-lightweight Go REST API for Techaa Purinjikoo",
		"endpoints": map[string]string{
			"health": "/health",
			"ready":  "/health/ready",
			"api":    "/api/v1",
		},
	})
}

func (h *Handlers) Health(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, map[string]string{"status": "ok", "service": "techaa-backend-v1"})
}

func (h *Handlers) HealthReady(w http.ResponseWriter, r *http.Request) {
	err := h.db.PingContext(r.Context())
	if err != nil {
		respondJSON(w, http.StatusServiceUnavailable, map[string]string{"status": "database_unavailable", "error": err.Error()})
		return
	}
	respondJSON(w, http.StatusOK, map[string]string{"status": "ready", "database": "connected"})
}

// Auth / Profile Handlers
func (h *Handlers) GetMe(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	profile, err := h.authService.GetProfile(r.Context(), user.ID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "PROFILE_ERROR", "Failed to retrieve user profile")
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"id":               user.ID,
		"auth_provider_id": user.AuthProviderID,
		"email":            user.Email,
		"profile":          profile,
		"created_at":       user.CreatedAt,
	})
}

func (h *Handlers) GetProfile(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	profile, err := h.authService.GetProfile(r.Context(), user.ID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "PROFILE_ERROR", "Failed to retrieve profile")
		return
	}
	respondJSON(w, http.StatusOK, profile)
}

func (h *Handlers) UpdateProfile(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	var req models.ProfileUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "INVALID_PAYLOAD", "Malformed request body")
		return
	}

	now := time.Now().UTC()
	query := `UPDATE profiles SET display_name = COALESCE($1, display_name), username = COALESCE($2, username), avatar_url = COALESCE($3, avatar_url), updated_at = $4 WHERE user_id = $5`
	_, err := h.db.ExecContext(r.Context(), query, req.DisplayName, req.Username, req.AvatarURL, now, user.ID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "UPDATE_FAILED", "Failed to update profile")
		return
	}

	profile, _ := h.authService.GetProfile(r.Context(), user.ID)
	respondJSON(w, http.StatusOK, profile)
}

// Progress Handlers
func (h *Handlers) GetProgressSummary(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	query := `SELECT topic_id FROM user_progress WHERE user_id = $1 AND completed = TRUE`
	rows, err := h.db.QueryContext(r.Context(), query, user.ID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "DB_ERROR", "Failed to fetch progress")
		return
	}
	defer rows.Close()

	var topicIDs []string
	for rows.Next() {
		var t string
		if err := rows.Scan(&t); err == nil {
			topicIDs = append(topicIDs, t)
		}
	}

	profile, _ := h.authService.GetProfile(r.Context(), user.ID)
	respondJSON(w, http.StatusOK, map[string]interface{}{
		"completed_topic_ids": topicIDs,
		"total_completed":     len(topicIDs),
		"total_xp":            profile.TotalXP,
		"level":               profile.Level,
		"level_title":         profile.LevelTitle,
	})
}

func (h *Handlers) CompleteTopic(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	path := r.URL.Path
	// Expecting /api/v1/progress/topics/{topic_id}/complete
	parts := strings.Split(strings.Trim(path, "/"), "/")
	if len(parts) < 4 {
		respondError(w, http.StatusBadRequest, "INVALID_PATH", "Topic ID missing")
		return
	}
	topicID := parts[3]

	res, err := h.progressService.CompleteTopic(r.Context(), user.ID, topicID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "COMPLETION_ERROR", err.Error())
		return
	}

	respondJSON(w, http.StatusOK, res)
}

// XP Handlers
func (h *Handlers) GetXPSummary(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	profile, _ := h.authService.GetProfile(r.Context(), user.ID)

	query := `SELECT id, user_id, event_type, reference_id, xp_amount, created_at FROM xp_transactions WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50`
	rows, err := h.db.QueryContext(r.Context(), query, user.ID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "DB_ERROR", "Failed to fetch XP transactions")
		return
	}
	defer rows.Close()

	var txs []models.XPTransaction
	for rows.Next() {
		var tx models.XPTransaction
		if err := rows.Scan(&tx.ID, &tx.UserID, &tx.EventType, &tx.ReferenceID, &tx.XPAmount, &tx.CreatedAt); err == nil {
			txs = append(txs, tx)
		}
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"total_xp":       profile.TotalXP,
		"level":          profile.Level,
		"level_title":    profile.LevelTitle,
		"level_progress": profile.LevelProgress,
		"transactions":   txs,
	})
}

// Badges Handler
func (h *Handlers) GetBadges(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	query := `SELECT badge_id, unlocked_at FROM user_badges WHERE user_id = $1`
	rows, err := h.db.QueryContext(r.Context(), query, user.ID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "DB_ERROR", "Failed to fetch badges")
		return
	}
	defer rows.Close()

	unlocked := make(map[string]time.Time)
	for rows.Next() {
		var b string
		var t time.Time
		if err := rows.Scan(&b, &t); err == nil {
			unlocked[b] = t
		}
	}

	var res []map[string]interface{}
	for _, b := range gamification.Badges {
		unlockedAt, isUnlocked := unlocked[b.ID]
		item := map[string]interface{}{
			"id":          b.ID,
			"title":       b.Title,
			"description": b.Description,
			"icon_emoji":  b.IconEmoji,
			"requirement": b.Requirement,
			"xp_reward":   b.XPReward,
			"unlocked":    isUnlocked,
		}
		if isUnlocked {
			item["unlocked_at"] = unlockedAt
		}
		res = append(res, item)
	}

	respondJSON(w, http.StatusOK, res)
}

// Streak Handler
func (h *Handlers) GetStreak(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	streak, err := h.streakService.RecordActivity(r.Context(), nil, user.ID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "DB_ERROR", "Failed to get streak")
		return
	}

	today := time.Now().UTC().Truncate(24 * time.Hour)
	isActiveToday := streak.LastActivityDate != nil && streak.LastActivityDate.Equal(today)

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"current_streak":     streak.CurrentStreak,
		"longest_streak":     streak.LongestStreak,
		"last_activity_date": streak.LastActivityDate,
		"is_active_today":    isActiveToday,
	})
}

// Courses Handler
func (h *Handlers) GetCoursesProgress(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	progressQuery := `SELECT topic_id FROM user_progress WHERE user_id = $1 AND completed = TRUE`
	rows, err := h.db.QueryContext(r.Context(), progressQuery, user.ID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "DB_ERROR", "Failed to fetch course progress")
		return
	}
	defer rows.Close()

	completedTopics := make(map[string]bool)
	for rows.Next() {
		var t string
		if err := rows.Scan(&t); err == nil {
			completedTopics[t] = true
		}
	}

	certQuery := `SELECT course_id, certificate_id FROM certificates WHERE user_id = $1`
	certRows, _ := h.db.QueryContext(r.Context(), certQuery, user.ID)
	certMap := make(map[string]string)
	if certRows != nil {
		defer certRows.Close()
		for certRows.Next() {
			var cID, certID string
			if err := certRows.Scan(&cID, &certID); err == nil {
				certMap[cID] = certID
			}
		}
	}

	var res []models.CourseProgress
	for cID, def := range services.CourseDefinitions {
		compCount := 0
		for _, req := range def.RequiredTopics {
			if completedTopics[req] {
				compCount++
			}
		}
		total := len(def.RequiredTopics)
		pct := 0.0
		if total > 0 {
			pct = float64(compCount) / float64(total)
		}
		isDone := compCount >= total

		item := models.CourseProgress{
			UserID:              user.ID,
			CourseID:            cID,
			CompletedTopicCount: compCount,
			TotalTopicCount:     total,
			ProgressPercent:     pct,
			Completed:           isDone,
		}
		if certID, ok := certMap[cID]; ok {
			item.CertificateID = &certID
		}
		res = append(res, item)
	}

	respondJSON(w, http.StatusOK, res)
}

func (h *Handlers) ClaimCourseCertificate(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	path := r.URL.Path
	// Expecting /api/v1/courses/{course_id}/claim-certificate
	parts := strings.Split(strings.Trim(path, "/"), "/")
	if len(parts) < 4 {
		respondError(w, http.StatusBadRequest, "INVALID_PATH", "Course ID missing")
		return
	}
	courseID := parts[3]

	var req models.CertificateClaimRequest
	_ = json.NewDecoder(r.Body).Decode(&req)

	cert, err := h.certificateService.ClaimCertificate(r.Context(), user.ID, courseID, req.RecipientName)
	if err != nil {
		respondError(w, http.StatusBadRequest, "COURSE_INCOMPLETE", err.Error())
		return
	}

	respondJSON(w, http.StatusOK, cert)
}

// Bookmarks Handlers
func (h *Handlers) GetBookmarks(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	query := `SELECT id, user_id, content_type, content_id, created_at FROM bookmarks WHERE user_id = $1`
	rows, err := h.db.QueryContext(r.Context(), query, user.ID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "DB_ERROR", "Failed to fetch bookmarks")
		return
	}
	defer rows.Close()

	var bList []models.Bookmark
	for rows.Next() {
		var b models.Bookmark
		if err := rows.Scan(&b.ID, &b.UserID, &b.ContentType, &b.ContentID, &b.CreatedAt); err == nil {
			bList = append(bList, b)
		}
	}
	respondJSON(w, http.StatusOK, bList)
}

func (h *Handlers) AddBookmark(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	var req models.BookmarkCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "INVALID_PAYLOAD", "Malformed request body")
		return
	}

	now := time.Now().UTC()
	bID := uuid.New().String()
	insert := `
		INSERT INTO bookmarks (id, user_id, content_type, content_id, created_at)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (user_id, content_type, content_id) DO NOTHING
	`
	_, err := h.db.ExecContext(r.Context(), insert, bID, user.ID, req.ContentType, req.ContentID, now)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "DB_ERROR", "Failed to add bookmark")
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"id":           bID,
		"content_type": req.ContentType,
		"content_id":   req.ContentID,
		"created_at":   now,
	})
}

func (h *Handlers) RemoveBookmark(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	path := r.URL.Path
	parts := strings.Split(strings.Trim(path, "/"), "/")
	if len(parts) < 4 {
		respondError(w, http.StatusBadRequest, "INVALID_PATH", "Content ID missing")
		return
	}
	contentID := parts[3]

	query := `DELETE FROM bookmarks WHERE user_id = $1 AND content_id = $2`
	_, _ = h.db.ExecContext(r.Context(), query, user.ID, contentID)

	respondJSON(w, http.StatusOK, map[string]string{"status": "success", "removed_content_id": contentID})
}

// Quiz Attempt Handler
func (h *Handlers) SubmitQuizAttempt(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	path := r.URL.Path
	parts := strings.Split(strings.Trim(path, "/"), "/")
	if len(parts) < 4 {
		respondError(w, http.StatusBadRequest, "INVALID_PATH", "Topic ID missing")
		return
	}
	topicID := parts[3]

	var req models.QuizSubmitRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "INVALID_PAYLOAD", "Malformed request body")
		return
	}

	xpToAward := 0
	if req.CorrectAnswers > 0 {
		xpToAward = gamification.XPAwards["QUIZ_CORRECT"]
	}

	awarded, actualXP, _, _ := h.xpService.AwardXP(r.Context(), nil, user.ID, "quiz_completed", "quiz_"+topicID, xpToAward)
	if !awarded {
		actualXP = 0
	}

	attemptID := uuid.New().String()
	now := time.Now().UTC()
	insert := `
		INSERT INTO quiz_attempts (id, user_id, topic_id, score, total_questions, correct_answers, xp_awarded, completed_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`
	_, _ = h.db.ExecContext(r.Context(), insert, attemptID, user.ID, topicID, req.Score, req.TotalQuestions, req.CorrectAnswers, actualXP, now)

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"id":          attemptID,
		"topic_id":    topicID,
		"score":       req.Score,
		"xp_awarded":  actualXP,
		"completed_at": now,
	})
}

// Certificates Handlers
func (h *Handlers) GetMyCertificates(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	query := `
		SELECT id, certificate_id, user_id, course_id, recipient_name, course_name, issued_at, verification_token, pdf_url, status, created_at
		FROM certificates WHERE user_id = $1
	`
	rows, err := h.db.QueryContext(r.Context(), query, user.ID)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "DB_ERROR", "Failed to fetch certificates")
		return
	}
	defer rows.Close()

	var list []models.Certificate
	for rows.Next() {
		var c models.Certificate
		var pdfNull sql.NullString
		if err := rows.Scan(&c.ID, &c.CertificateID, &c.UserID, &c.CourseID, &c.RecipientName, &c.CourseName, &c.IssuedAt, &c.VerificationToken, &pdfNull, &c.Status, &c.CreatedAt); err == nil {
			if pdfNull.Valid {
				c.PDFURL = &pdfNull.String
			}
			list = append(list, c)
		}
	}
	respondJSON(w, http.StatusOK, list)
}

func (h *Handlers) VerifyCertificatePublic(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path
	parts := strings.Split(strings.Trim(path, "/"), "/")
	if len(parts) < 5 {
		respondError(w, http.StatusBadRequest, "INVALID_PATH", "Certificate ID missing")
		return
	}
	certID := parts[4]

	cert, err := h.certificateService.VerifyCertificatePublic(r.Context(), certID)
	if err != nil {
		respondError(w, http.StatusNotFound, "INVALID_CERTIFICATE", "Certificate does not exist or has been revoked")
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"valid":          true,
		"certificate_id": cert.CertificateID,
		"recipient_name": cert.RecipientName,
		"course_name":    cert.CourseName,
		"issued_at":      cert.IssuedAt,
		"status":         cert.Status,
	})
}

// Sync Handler
func (h *Handlers) Sync(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	var payload models.SyncPayload
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		respondError(w, http.StatusBadRequest, "INVALID_PAYLOAD", "Malformed sync payload")
		return
	}

	res, err := h.syncService.ProcessSync(r.Context(), user.ID, payload)
	if err != nil {
		respondError(w, http.StatusInternalServerError, "SYNC_ERROR", err.Error())
		return
	}

	respondJSON(w, http.StatusOK, res)
}

// Content Reporting Handler
func (h *Handlers) SubmitReport(w http.ResponseWriter, r *http.Request) {
	user := getUserFromContext(r)
	var userID *string
	if user != nil {
		userID = &user.ID
	}

	var req models.ContentReport
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "INVALID_PAYLOAD", "Malformed request body")
		return
	}

	now := time.Now().UTC()
	repID := uuid.New().String()
	insert := `
		INSERT INTO content_reports (id, user_id, content_id, content_type, reason, description, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`
	_, _ = h.db.ExecContext(r.Context(), insert, repID, userID, req.ContentID, req.ContentType, req.Reason, req.Description, now)

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"id":         repID,
		"status":     "received",
		"created_at": now,
	})
}

// Analytics Handler
func (h *Handlers) RecordAnalyticsEvent(w http.ResponseWriter, r *http.Request) {
	// Lightweight event sink
	respondJSON(w, http.StatusOK, map[string]string{"status": "recorded"})
}

type sendOTPRequest struct {
	Email   string `json:"email"`
	Purpose string `json:"purpose"`
}

func (h *Handlers) SendOTP(w http.ResponseWriter, r *http.Request) {
	var req sendOTPRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "INVALID_PAYLOAD", "Malformed request body")
		return
	}

	req.Email = strings.TrimSpace(req.Email)
	if req.Email == "" {
		respondError(w, http.StatusBadRequest, "INVALID_EMAIL", "Email is required")
		return
	}

	if req.Purpose == "" {
		req.Purpose = "verification"
	}

	if h.otpService == nil {
		respondError(w, http.StatusInternalServerError, "SERVICE_UNAVAILABLE", "OTP Service not configured")
		return
	}

	_, err := h.otpService.SendOTP(req.Email, req.Purpose)
	if err != nil {
		respondError(w, http.StatusTooManyRequests, "OTP_ERROR", err.Error())
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"message": "Verification code dispatched successfully",
		"email":   req.Email,
	})
}

type verifyOTPRequest struct {
	Email   string `json:"email"`
	Code    string `json:"code"`
	Purpose string `json:"purpose"`
}

func (h *Handlers) VerifyOTP(w http.ResponseWriter, r *http.Request) {
	var req verifyOTPRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		respondError(w, http.StatusBadRequest, "INVALID_PAYLOAD", "Malformed request body")
		return
	}

	req.Email = strings.TrimSpace(req.Email)
	req.Code = strings.TrimSpace(req.Code)
	if req.Email == "" || req.Code == "" {
		respondError(w, http.StatusBadRequest, "INVALID_INPUT", "Email and code are required")
		return
	}

	if req.Purpose == "" {
		req.Purpose = "verification"
	}

	if h.otpService == nil {
		respondError(w, http.StatusInternalServerError, "SERVICE_UNAVAILABLE", "OTP Service not configured")
		return
	}

	ok, err := h.otpService.VerifyOTP(req.Email, req.Code, req.Purpose)
	if !ok || err != nil {
		errMsg := "Invalid verification code"
		if err != nil {
			errMsg = err.Error()
		}
		respondError(w, http.StatusUnauthorized, "INVALID_OTP", errMsg)
		return
	}

	respondJSON(w, http.StatusOK, map[string]interface{}{
		"success":  true,
		"verified": true,
		"email":    req.Email,
		"message":  "Verification successful",
	})
}
