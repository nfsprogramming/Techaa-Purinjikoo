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

type SyncService struct {
	db                 *database.DB
	xpService          *XPService
	achievementService *AchievementService
	streakService      *StreakService
	authService        *AuthService
}

func NewSyncService(
	db *database.DB,
	xpService *XPService,
	achievementService *AchievementService,
	streakService *StreakService,
	authService *AuthService,
) *SyncService {
	return &SyncService{
		db:                 db,
		xpService:          xpService,
		achievementService: achievementService,
		streakService:      streakService,
		authService:        authService,
	}
}

func (s *SyncService) ProcessSync(ctx context.Context, userID string, payload models.SyncPayload) (*models.SyncResponse, error) {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()

	syncedTopics := 0
	syncedBookmarks := 0
	totalNewXP := 0
	now := time.Now().UTC()

	// 1. Process completed topics
	for _, item := range payload.CompletedTopics {
		var exists bool
		check := `SELECT completed FROM user_progress WHERE user_id = $1 AND topic_id = $2`
		err := tx.QueryRowContext(ctx, check, userID, item.TopicID).Scan(&exists)

		isNew := false
		compTime := now
		if item.CompletedAt != nil {
			compTime = *item.CompletedAt
		}

		if err == sql.ErrNoRows {
			progID := uuid.New().String()
			insert := `
				INSERT INTO user_progress (id, user_id, topic_id, completed, progress_percent, completed_at, last_opened_at, updated_at)
				VALUES ($1, $2, $3, TRUE, 1.0, $4, $4, $4)
			`
			if _, err := tx.ExecContext(ctx, insert, progID, userID, item.TopicID, compTime); err == nil {
				isNew = true
				syncedTopics++
			}
		} else if err == nil && !exists {
			update := `UPDATE user_progress SET completed = TRUE, progress_percent = 1.0, completed_at = $1, updated_at = $2 WHERE user_id = $3 AND topic_id = $4`
			if _, err := tx.ExecContext(ctx, update, compTime, now, userID, item.TopicID); err == nil {
				isNew = true
				syncedTopics++
			}
		}

		if isNew {
			awarded, amt, _, _ := s.xpService.AwardXP(ctx, tx, userID, "topic_completed", item.TopicID, gamification.XPAwards["READ_TOPIC"])
			if awarded {
				totalNewXP += amt
			}
		}
	}

	// 2. Process bookmarks
	for _, b := range payload.Bookmarks {
		insertBookmark := `
			INSERT INTO bookmarks (id, user_id, content_type, content_id, created_at)
			VALUES ($1, $2, $3, $4, $5)
			ON CONFLICT (user_id, content_type, content_id) DO NOTHING
		`
		bID := uuid.New().String()
		res, err := tx.ExecContext(ctx, insertBookmark, bID, userID, b.ContentType, b.ContentID, now)
		if err == nil {
			if rows, _ := res.RowsAffected(); rows > 0 {
				syncedBookmarks++
			}
		}
	}

	// Record sync event
	eventID := uuid.New().String()
	insertEvent := `
		INSERT INTO sync_events (id, user_id, client_timestamp, processed_operations, created_at)
		VALUES ($1, $2, $3, $4, $5)
	`
	clientTime := payload.ClientTimestamp
	if clientTime.IsZero() {
		clientTime = now
	}
	_, _ = tx.ExecContext(ctx, insertEvent, eventID, userID, clientTime, syncedTopics+syncedBookmarks, now)

	// Streak and Achievements
	_, _ = s.streakService.RecordActivity(ctx, tx, userID)
	unlockedBadges, _ := s.achievementService.EvaluateAchievements(ctx, tx, userID)

	if err := tx.Commit(); err != nil {
		return nil, err
	}

	profile, err := s.authService.GetProfile(ctx, userID)
	if err != nil {
		return nil, err
	}

	return &models.SyncResponse{
		Status:               "success",
		SyncedTopicsCount:    syncedTopics,
		SyncedBookmarksCount: syncedBookmarks,
		NewXPAwarded:         totalNewXP,
		Profile:              *profile,
		UnlockedBadges:       unlockedBadges,
	}, nil
}
