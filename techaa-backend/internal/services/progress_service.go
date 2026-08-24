package services

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"techaa-backend/internal/database"
	"techaa-backend/internal/gamification"
	"techaa-backend/internal/models"
)

type ProgressService struct {
	db                 *database.DB
	xpService          *XPService
	achievementService *AchievementService
	streakService      *StreakService
	authService        *AuthService
}

func NewProgressService(
	db *database.DB,
	xpService *XPService,
	achievementService *AchievementService,
	streakService *StreakService,
	authService *AuthService,
) *ProgressService {
	return &ProgressService{
		db:                 db,
		xpService:          xpService,
		achievementService: achievementService,
		streakService:      streakService,
		authService:        authService,
	}
}

type TopicCompleteResult struct {
	TopicID            string          `json:"topic_id"`
	Completed          bool            `json:"completed"`
	IsFirstCompletion  bool            `json:"is_first_completion"`
	XPAwarded          int             `json:"xp_awarded"`
	TotalXP            int             `json:"total_xp"`
	Level              int             `json:"level"`
	UnlockedBadges     []string        `json:"unlocked_badges"`
	UpdatedProfile     *models.Profile `json:"updated_profile"`
}

func (s *ProgressService) CompleteTopic(ctx context.Context, userID, topicID string) (*TopicCompleteResult, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()

	now := time.Now().UTC()
	var completed bool
	checkQuery := `SELECT completed FROM user_progress WHERE user_id = $1 AND topic_id = $2`
	err = tx.QueryRowContext(ctx, checkQuery, userID, topicID).Scan(&completed)

	isFirst := false
	if err == sql.ErrNoRows {
		progID := uuid.New().String()
		insert := `
			INSERT INTO user_progress (id, user_id, topic_id, completed, progress_percent, completed_at, last_opened_at, updated_at)
			VALUES ($1, $2, $3, TRUE, 1.0, $4, $4, $4)
		`
		if _, err := tx.ExecContext(ctx, insert, progID, userID, topicID, now); err != nil {
			return nil, err
		}
		isFirst = true
	} else if err != nil {
		return nil, err
	} else if !completed {
		update := `
			UPDATE user_progress
			SET completed = TRUE, progress_percent = 1.0, completed_at = $1, last_opened_at = $1, updated_at = $1
			WHERE user_id = $2 AND topic_id = $3
		`
		if _, err := tx.ExecContext(ctx, update, now, userID, topicID); err != nil {
			return nil, err
		}
		isFirst = true
	}

	xpAwarded := 0
	if isFirst {
		awarded, amt, _, err := s.xpService.AwardXP(ctx, tx, userID, "topic_completed", topicID, gamification.XPAwards["READ_TOPIC"])
		if err != nil {
			return nil, err
		}
		if awarded {
			xpAwarded = amt
		}
	}

	// Record streak
	_, _ = s.streakService.RecordActivity(ctx, tx, userID)

	// Evaluate badges
	unlockedBadges, _ := s.achievementService.EvaluateAchievements(ctx, tx, userID)

	if err := tx.Commit(); err != nil {
		return nil, err
	}

	profile, err := s.authService.GetProfile(ctx, userID)
	if err != nil {
		return nil, err
	}

	return &TopicCompleteResult{
		TopicID:           topicID,
		Completed:         true,
		IsFirstCompletion: isFirst,
		XPAwarded:         xpAwarded,
		TotalXP:           profile.TotalXP,
		Level:             profile.Level,
		UnlockedBadges:    unlockedBadges,
		UpdatedProfile:    profile,
	}, nil
}
