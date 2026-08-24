package services

import (
	"context"
	"database/sql"
	"time"

	"techaa-backend/internal/database"
	"techaa-backend/internal/gamification"
	"techaa-backend/internal/models"
)

type StreakService struct {
	db        *database.DB
	xpService *XPService
}

func NewStreakService(db *database.DB, xpService *XPService) *StreakService {
	return &StreakService{db: db, xpService: xpService}
}

func (s *StreakService) RecordActivity(ctx context.Context, tx *sql.Tx, userID string) (*models.UserStreak, error) {
	today := time.Now().UTC().Truncate(24 * time.Hour)

	query := `SELECT current_streak, longest_streak, last_activity_date, frozen_days_remaining FROM user_streaks WHERE user_id = $1`
	var streak models.UserStreak
	var lastDateNull sql.NullTime

	var err error
	if tx != nil {
		err = tx.QueryRowContext(ctx, query, userID).Scan(&streak.CurrentStreak, &streak.LongestStreak, &lastDateNull, &streak.FrozenDaysRemaining)
	} else {
		err = s.db.QueryRowContext(ctx, query, userID).Scan(&streak.CurrentStreak, &streak.LongestStreak, &lastDateNull, &streak.FrozenDaysRemaining)
	}

	if err != nil && err != sql.ErrNoRows {
		return nil, err
	}

	if err == sql.ErrNoRows {
		streak.UserID = userID
		streak.CurrentStreak = 1
		streak.LongestStreak = 1
		streak.LastActivityDate = &today

		insert := `INSERT INTO user_streaks (user_id, current_streak, longest_streak, last_activity_date, updated_at) VALUES ($1, 1, 1, $2, $3)`
		if tx != nil {
			_, _ = tx.ExecContext(ctx, insert, userID, today, time.Now().UTC())
		} else {
			_, _ = s.db.ExecContext(ctx, insert, userID, today, time.Now().UTC())
		}
		return &streak, nil
	}

	if lastDateNull.Valid {
		lastDate := lastDateNull.Time.Truncate(24 * time.Hour)
		streak.LastActivityDate = &lastDate

		if lastDate.Equal(today) {
			// Already active today
			return &streak, nil
		} else if lastDate.Equal(today.AddDate(0, 0, -1)) {
			// Consecutive day
			streak.CurrentStreak++
			if streak.CurrentStreak > streak.LongestStreak {
				streak.LongestStreak = streak.CurrentStreak
			}
			streak.LastActivityDate = &today

			// Award daily streak XP
			_, _, _, _ = s.xpService.AwardXP(ctx, tx, userID, "daily_streak", today.Format("2006-01-02"), gamification.XPAwards["DAILY_LOGIN"])
		} else {
			// Missed days
			streak.CurrentStreak = 1
			streak.LastActivityDate = &today
		}
	} else {
		streak.CurrentStreak = 1
		streak.LongestStreak = 1
		streak.LastActivityDate = &today
	}

	now := time.Now().UTC()
	update := `
		UPDATE user_streaks
		SET current_streak = $1, longest_streak = $2, last_activity_date = $3, updated_at = $4
		WHERE user_id = $5
	`
	if tx != nil {
		_, _ = tx.ExecContext(ctx, update, streak.CurrentStreak, streak.LongestStreak, today, now, userID)
		updateProf := `UPDATE profiles SET current_streak = $1, longest_streak = $2, last_activity_date = $3, updated_at = $4 WHERE user_id = $5`
		_, _ = tx.ExecContext(ctx, updateProf, streak.CurrentStreak, streak.LongestStreak, today, now, userID)
	} else {
		_, _ = s.db.ExecContext(ctx, update, streak.CurrentStreak, streak.LongestStreak, today, now, userID)
		updateProf := `UPDATE profiles SET current_streak = $1, longest_streak = $2, last_activity_date = $3, updated_at = $4 WHERE user_id = $5`
		_, _ = s.db.ExecContext(ctx, updateProf, streak.CurrentStreak, streak.LongestStreak, today, now, userID)
	}

	return &streak, nil
}
