package services

import (
	"context"
	"database/sql"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"techaa-backend/internal/database"
	"techaa-backend/internal/gamification"
	"techaa-backend/internal/logger"
	"techaa-backend/internal/models"
)

type AuthService struct {
	db *database.DB
}

func NewAuthService(db *database.DB) *AuthService {
	return &AuthService{db: db}
}

func (s *AuthService) VerifyAndGetUser(ctx context.Context, authHeader string) (*models.User, *models.Profile, error) {
	if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
		return nil, nil, errors.New("missing or invalid authorization header")
	}

	token := strings.TrimSpace(strings.TrimPrefix(authHeader, "Bearer "))
	if token == "" {
		return nil, nil, errors.New("empty bearer token")
	}

	authUID := token
	email := token + "@techaapurinjikoo.dev"
	displayName := "Tech Learner"

	if strings.HasPrefix(token, "test_uid_") || strings.HasPrefix(token, "dev_") {
		displayName = strings.Title(strings.TrimPrefix(strings.TrimPrefix(token, "test_uid_"), "dev_"))
	}

	// 1. Check if user already exists
	query := `SELECT id, auth_provider_id, email, created_at, updated_at FROM users WHERE auth_provider_id = $1`
	var user models.User
	var emailNull sql.NullString

	err := s.db.QueryRowContext(ctx, query, authUID).Scan(
		&user.ID,
		&user.AuthProviderID,
		&emailNull,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		// Create new user in a transaction
		tx, err := s.db.BeginTx(ctx, nil)
		if err != nil {
			return nil, nil, err
		}
		defer tx.Rollback()

		newUserID := uuid.New().String()
		now := time.Now().UTC()

		insertUser := `
			INSERT INTO users (id, auth_provider_id, email, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5)
		`
		if _, err := tx.ExecContext(ctx, insertUser, newUserID, authUID, email, now, now); err != nil {
			return nil, nil, err
		}

		today := now.Truncate(24 * time.Hour)
		insertProfile := `
			INSERT INTO profiles (user_id, display_name, total_xp, level, current_streak, longest_streak, last_activity_date, created_at, updated_at)
			VALUES ($1, $2, 0, 1, 1, 1, $3, $4, $5)
		`
		if _, err := tx.ExecContext(ctx, insertProfile, newUserID, displayName, today, now, now); err != nil {
			return nil, nil, err
		}

		insertStreak := `
			INSERT INTO user_streaks (user_id, current_streak, longest_streak, last_activity_date, updated_at)
			VALUES ($1, 1, 1, $2, $3)
		`
		if _, err := tx.ExecContext(ctx, insertStreak, newUserID, today, now); err != nil {
			return nil, nil, err
		}

		if err := tx.Commit(); err != nil {
			return nil, nil, err
		}

		user.ID = newUserID
		user.AuthProviderID = authUID
		user.Email = &email
		user.CreatedAt = now
		user.UpdatedAt = now

		lvlInfo := gamification.CalculateLevel(0)
		profile := &models.Profile{
			UserID:           newUserID,
			DisplayName:      displayName,
			TotalXP:          0,
			Level:            1,
			LevelTitle:       lvlInfo.Title,
			LevelProgress:    lvlInfo.LevelProgress,
			XPToNextLevel:    lvlInfo.XPToNextLevel,
			CurrentStreak:    1,
			LongestStreak:    1,
			LastActivityDate: &today,
			Timezone:         "UTC",
			CreatedAt:        now,
			UpdatedAt:        now,
		}

		logger.Log.Info("New user created", "user_id", newUserID, "auth_uid", authUID)
		return &user, profile, nil
	} else if err != nil {
		return nil, nil, err
	}

	if emailNull.Valid {
		user.Email = &emailNull.String
	}

	// 2. Fetch existing profile
	profile, err := s.GetProfile(ctx, user.ID)
	if err != nil {
		return nil, nil, err
	}

	return &user, profile, nil
}

func (s *AuthService) GetProfile(ctx context.Context, userID string) (*models.Profile, error) {
	query := `
		SELECT user_id, display_name, username, avatar_url, total_xp, level, current_streak, longest_streak, last_activity_date, timezone, created_at, updated_at
		FROM profiles WHERE user_id = $1
	`
	var p models.Profile
	var userNull, avatarNull sql.NullString
	var lastActNull sql.NullTime

	err := s.db.QueryRowContext(ctx, query, userID).Scan(
		&p.UserID,
		&p.DisplayName,
		&userNull,
		&avatarNull,
		&p.TotalXP,
		&p.Level,
		&p.CurrentStreak,
		&p.LongestStreak,
		&lastActNull,
		&p.Timezone,
		&p.CreatedAt,
		&p.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	if userNull.Valid {
		p.Username = &userNull.String
	}
	if avatarNull.Valid {
		p.AvatarURL = &avatarNull.String
	}
	if lastActNull.Valid {
		p.LastActivityDate = &lastActNull.Time
	}

	lvl := gamification.CalculateLevel(p.TotalXP)
	p.Level = lvl.Level
	p.LevelTitle = lvl.Title
	p.LevelProgress = lvl.LevelProgress
	p.XPToNextLevel = lvl.XPToNextLevel

	return &p, nil
}
