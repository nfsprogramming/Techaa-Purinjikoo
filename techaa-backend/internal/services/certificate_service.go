package services

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"techaa-backend/internal/database"
	"techaa-backend/internal/gamification"
	"techaa-backend/internal/models"
)

type CourseDef struct {
	Name           string
	RequiredTopics []string
}

var CourseDefinitions = map[string]CourseDef{
	"c_internet_basics": {
		Name:           "Internet & Web Fundamentals",
		RequiredTopics: []string{"internet", "http-vs-https", "cookies-cache"},
	},
	"c_web_dev": {
		Name:           "Full Stack Web Architecture",
		RequiredTopics: []string{"frontend-vs-backend", "framework-vs-library"},
	},
	"c_cloud_devops": {
		Name:           "Cloud & Modern DevTools",
		RequiredTopics: []string{"deployment-explained", "git-basics"},
	},
}

type CertificateService struct {
	db          *database.DB
	xpService   *XPService
	authService *AuthService
	verifyURL   string
}

func NewCertificateService(db *database.DB, xpService *XPService, authService *AuthService, verifyURL string) *CertificateService {
	return &CertificateService{
		db:          db,
		xpService:   xpService,
		authService: authService,
		verifyURL:   verifyURL,
	}
}

func (s *CertificateService) ClaimCertificate(ctx context.Context, userID, courseID string, customRecipientName *string) (*models.Certificate, error) {
	// 1. Check if already issued
	checkQuery := `
		SELECT id, certificate_id, user_id, course_id, recipient_name, course_name, issued_at, verification_token, pdf_url, status, created_at
		FROM certificates WHERE user_id = $1 AND course_id = $2
	`
	var c models.Certificate
	var pdfNull sql.NullString

	err := s.db.QueryRowContext(ctx, checkQuery, userID, courseID).Scan(
		&c.ID,
		&c.CertificateID,
		&c.UserID,
		&c.CourseID,
		&c.RecipientName,
		&c.CourseName,
		&c.IssuedAt,
		&c.VerificationToken,
		&pdfNull,
		&c.Status,
		&c.CreatedAt,
	)

	if err == nil {
		if pdfNull.Valid {
			c.PDFURL = &pdfNull.String
		}
		c.VerificationURL = fmt.Sprintf("%s/%s", s.verifyURL, c.CertificateID)
		return &c, nil
	} else if err != sql.ErrNoRows {
		return nil, err
	}

	// 2. Validate course requirements
	courseDef, exists := CourseDefinitions[courseID]
	if !exists {
		return nil, fmt.Errorf("invalid course ID: %s", courseID)
	}

	progressQuery := `SELECT topic_id FROM user_progress WHERE user_id = $1 AND completed = TRUE`
	rows, err := s.db.QueryContext(ctx, progressQuery, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	completedSet := make(map[string]bool)
	for rows.Next() {
		var tID string
		if err := rows.Scan(&tID); err == nil {
			completedSet[tID] = true
		}
	}

	for _, req := range courseDef.RequiredTopics {
		if !completedSet[req] {
			return nil, fmt.Errorf("course incomplete: topic %s is required", req)
		}
	}

	// 3. Issue certificate in transaction
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()

	profile, err := s.authService.GetProfile(ctx, userID)
	if err != nil {
		return nil, err
	}

	recipient := profile.DisplayName
	if customRecipientName != nil && strings.TrimSpace(*customRecipientName) != "" {
		recipient = strings.TrimSpace(*customRecipientName)
	}

	// Generate secure unique ID: TP-<COURSE>-<RANDOM>
	randBytes := make([]byte, 3)
	_, _ = rand.Read(randBytes)
	suffix := strings.ToUpper(hex.EncodeToString(randBytes))
	cleanCourse := strings.ToUpper(strings.TrimPrefix(courseID, "c_"))
	certID := fmt.Sprintf("TP-%s-%s", cleanCourse, suffix)

	tokenBytes := make([]byte, 16)
	_, _ = rand.Read(tokenBytes)
	vToken := hex.EncodeToString(tokenBytes)

	now := time.Now().UTC()
	rowID := uuid.New().String()

	insertCert := `
		INSERT INTO certificates (id, certificate_id, user_id, course_id, recipient_name, course_name, issued_at, verification_token, status, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'issued', $9)
	`
	if _, err := tx.ExecContext(ctx, insertCert, rowID, certID, userID, courseID, recipient, courseDef.Name, now, vToken, now); err != nil {
		return nil, err
	}

	// Award course completion XP
	_, _, _, _ = s.xpService.AwardXP(ctx, tx, userID, "course_completed", courseID, gamification.XPAwards["COURSE_COMPLETED"])

	if err := tx.Commit(); err != nil {
		return nil, err
	}

	c = models.Certificate{
		ID:                rowID,
		CertificateID:     certID,
		UserID:            userID,
		CourseID:          courseID,
		RecipientName:     recipient,
		CourseName:        courseDef.Name,
		IssuedAt:          now,
		VerificationToken: vToken,
		Status:            "issued",
		CreatedAt:         now,
		VerificationURL:   fmt.Sprintf("%s/%s", s.verifyURL, certID),
	}

	return &c, nil
}

func (s *CertificateService) VerifyCertificatePublic(ctx context.Context, certID string) (*models.Certificate, error) {
	query := `
		SELECT certificate_id, recipient_name, course_name, issued_at, status
		FROM certificates WHERE certificate_id = $1
	`
	var c models.Certificate
	err := s.db.QueryRowContext(ctx, query, certID).Scan(
		&c.CertificateID,
		&c.RecipientName,
		&c.CourseName,
		&c.IssuedAt,
		&c.Status,
	)
	if err == sql.ErrNoRows {
		return nil, errors.New("certificate not found")
	} else if err != nil {
		return nil, err
	}

	return &c, nil
}
