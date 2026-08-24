package services

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"techaa-backend/internal/database"
	"techaa-backend/internal/gamification"
	"techaa-backend/internal/logger"
	"techaa-backend/internal/models"
)

type XPService struct {
	db *database.DB
}

func NewXPService(db *database.DB) *XPService {
	return &XPService{db: db}
}

func (s *XPService) AwardXP(ctx context.Context, tx *sql.Tx, userID, eventType, referenceID string, amount int) (bool, int, *models.Profile, error) {
	// 1. Check if an XP transaction already exists for this (user, event, reference)
	checkQuery := `SELECT id FROM xp_transactions WHERE user_id = $1 AND event_type = $2 AND reference_id = $3`
	var existingID string

	var err error
	if tx != nil {
		err = tx.QueryRowContext(ctx, checkQuery, userID, eventType, referenceID).Scan(&existingID)
	} else {
		err = s.db.QueryRowContext(ctx, checkQuery, userID, eventType, referenceID).Scan(&existingID)
	}

	if err == nil && existingID != "" {
		// Duplicate event: return 0 XP safely
		logger.Log.Info("Duplicate XP skipped", "user_id", userID, "event", eventType, "ref", referenceID)
		return false, 0, nil, nil
	}

	// 2. Insert ledger transaction
	txID := uuid.New().String()
	now := time.Now().UTC()
	insertQuery := `
		INSERT INTO xp_transactions (id, user_id, event_type, reference_id, xp_amount, created_at)
		VALUES ($1, $2, $3, $4, $5, $6)
	`
	if tx != nil {
		if _, err := tx.ExecContext(ctx, insertQuery, txID, userID, eventType, referenceID, amount, now); err != nil {
			return false, 0, nil, err
		}
	} else {
		if _, err := s.db.ExecContext(ctx, insertQuery, txID, userID, eventType, referenceID, amount, now); err != nil {
			return false, 0, nil, err
		}
	}

	// 3. Update profile total XP
	updateProfile := `
		UPDATE profiles
		SET total_xp = total_xp + $1, updated_at = $2
		WHERE user_id = $3
		RETURNING total_xp
	`
	var newTotalXP int
	if tx != nil {
		err = tx.QueryRowContext(ctx, updateProfile, amount, now, userID).Scan(&newTotalXP)
	} else {
		err = s.db.QueryRowContext(ctx, updateProfile, amount, now, userID).Scan(&newTotalXP)
	}
	if err != nil {
		return false, 0, nil, err
	}

	// 4. Update level if needed
	lvlInfo := gamification.CalculateLevel(newTotalXP)
	updateLevel := `UPDATE profiles SET level = $1 WHERE user_id = $2`
	if tx != nil {
		_, _ = tx.ExecContext(ctx, updateLevel, lvlInfo.Level, userID)
	} else {
		_, _ = s.db.ExecContext(ctx, updateLevel, lvlInfo.Level, userID)
	}

	return true, amount, nil, nil
}
