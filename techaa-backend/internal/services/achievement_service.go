package services

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"techaa-backend/internal/database"
	"techaa-backend/internal/gamification"
	"techaa-backend/internal/logger"
)

type AchievementService struct {
	db        *database.DB
	xpService *XPService
}

func NewAchievementService(db *database.DB, xpService *XPService) *AchievementService {
	return &AchievementService{db: db, xpService: xpService}
}

func (s *AchievementService) EvaluateAchievements(ctx context.Context, tx *sql.Tx, userID string) ([]string, error) {
	// 1. Get unlocked badges
	badgeQuery := `SELECT badge_id FROM user_badges WHERE user_id = $1`
	var rows *sql.Rows
	var err error
	if tx != nil {
		rows, err = tx.QueryContext(ctx, badgeQuery, userID)
	} else {
		rows, err = s.db.QueryContext(ctx, badgeQuery, userID)
	}
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	unlockedMap := make(map[string]bool)
	for rows.Next() {
		var bID string
		if err := rows.Scan(&bID); err == nil {
			unlockedMap[bID] = true
		}
	}

	// 2. Count completed topics
	var completedTopics int
	countTopics := `SELECT COUNT(*) FROM user_progress WHERE user_id = $1 AND completed = TRUE`
	if tx != nil {
		_ = tx.QueryRowContext(ctx, countTopics, userID).Scan(&completedTopics)
	} else {
		_ = s.db.QueryRowContext(ctx, countTopics, userID).Scan(&completedTopics)
	}

	// 3. Get profile stats
	var totalXP, currentStreak int
	profileQuery := `SELECT total_xp, current_streak FROM profiles WHERE user_id = $1`
	if tx != nil {
		_ = tx.QueryRowContext(ctx, profileQuery, userID).Scan(&totalXP, &currentStreak)
	} else {
		_ = s.db.QueryRowContext(ctx, profileQuery, userID).Scan(&totalXP, &currentStreak)
	}

	var newlyUnlocked []string
	now := time.Now().UTC()

	rules := map[string]bool{
		"badge_first_step":    completedTopics >= 1,
		"badge_quiz_warrior":  totalXP >= 40,
		"badge_streak_master": currentStreak >= 7,
		"badge_web_explorer":  completedTopics >= 13,
		"badge_cloud_ninja":   completedTopics >= 30,
		"badge_ai_pioneer":    completedTopics >= 50 || totalXP >= 1000,
	}

	for _, badge := range gamification.Badges {
		bID := badge.ID
		if !unlockedMap[bID] && rules[bID] {
			badgeID := uuid.New().String()
			insertBadge := `INSERT INTO user_badges (id, user_id, badge_id, unlocked_at) VALUES ($1, $2, $3, $4)`
			if tx != nil {
				_, _ = tx.ExecContext(ctx, insertBadge, badgeID, userID, bID, now)
			} else {
				_, _ = s.db.ExecContext(ctx, insertBadge, badgeID, userID, bID, now)
			}

			// Award badge XP
			_, _, _, _ = s.xpService.AwardXP(ctx, tx, userID, "badge_unlocked", bID, badge.XPReward)
			newlyUnlocked = append(newlyUnlocked, bID)
			logger.Log.Info("🏆 Badge unlocked", "badge", bID, "user_id", userID)
		}
	}

	return newlyUnlocked, nil
}
