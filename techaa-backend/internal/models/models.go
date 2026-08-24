package models

import (
	"time"
)

type User struct {
	ID             string    `json:"id"`
	AuthProviderID string    `json:"auth_provider_id"`
	Email          *string   `json:"email,omitempty"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type Profile struct {
	UserID           string     `json:"user_id"`
	DisplayName      string     `json:"display_name"`
	Username         *string    `json:"username,omitempty"`
	AvatarURL        *string    `json:"avatar_url,omitempty"`
	TotalXP          int        `json:"total_xp"`
	Level            int        `json:"level"`
	LevelTitle       string     `json:"level_title"`
	LevelProgress    float64    `json:"level_progress"`
	XPToNextLevel    int        `json:"xp_to_next_level"`
	CurrentStreak    int        `json:"current_streak"`
	LongestStreak    int        `json:"longest_streak"`
	LastActivityDate *time.Time `json:"last_activity_date,omitempty"`
	Timezone         string     `json:"timezone"`
	CreatedAt        time.Time  `json:"created_at"`
	UpdatedAt        time.Time  `json:"updated_at"`
}

type UserProgress struct {
	ID              string     `json:"id"`
	UserID          string     `json:"user_id"`
	TopicID         string     `json:"topic_id"`
	Completed       bool       `json:"completed"`
	ProgressPercent float64    `json:"progress_percent"`
	CompletedAt     *time.Time `json:"completed_at,omitempty"`
	LastOpenedAt    time.Time  `json:"last_opened_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}

type XPTransaction struct {
	ID          string    `json:"id"`
	UserID      string    `json:"user_id"`
	EventType   string    `json:"event_type"`
	ReferenceID string    `json:"reference_id"`
	XPAmount    int       `json:"xp_amount"`
	CreatedAt   time.Time `json:"created_at"`
}

type UserStreak struct {
	UserID              string     `json:"user_id"`
	CurrentStreak       int        `json:"current_streak"`
	LongestStreak       int        `json:"longest_streak"`
	LastActivityDate    *time.Time `json:"last_activity_date,omitempty"`
	FrozenDaysRemaining int        `json:"frozen_days_remaining"`
	UpdatedAt           time.Time  `json:"updated_at"`
}

type UserBadge struct {
	ID          string    `json:"id"`
	UserID      string    `json:"user_id"`
	BadgeID     string    `json:"badge_id"`
	UnlockedAt  time.Time `json:"unlocked_at"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	IconEmoji   string    `json:"icon_emoji"`
	Requirement string    `json:"requirement"`
	XPReward    int       `json:"xp_reward"`
	Unlocked    bool      `json:"unlocked"`
}

type CourseProgress struct {
	ID                  string     `json:"id"`
	UserID              string     `json:"user_id"`
	CourseID            string     `json:"course_id"`
	CompletedTopicCount int        `json:"completed_topic_count"`
	TotalTopicCount     int        `json:"total_topic_count"`
	ProgressPercent     float64    `json:"progress_percent"`
	Completed           bool       `json:"completed"`
	CompletedAt         *time.Time `json:"completed_at,omitempty"`
	CertificateID       *string    `json:"certificate_id,omitempty"`
}

type Bookmark struct {
	ID          string    `json:"id"`
	UserID      string    `json:"user_id"`
	ContentType string    `json:"content_type"`
	ContentID   string    `json:"content_id"`
	CreatedAt   time.Time `json:"created_at"`
}

type QuizAttempt struct {
	ID             string    `json:"id"`
	UserID         string    `json:"user_id"`
	TopicID        string    `json:"topic_id"`
	Score          int       `json:"score"`
	TotalQuestions int       `json:"total_questions"`
	CorrectAnswers int       `json:"correct_answers"`
	XPAwarded      int       `json:"xp_awarded"`
	CompletedAt    time.Time `json:"completed_at"`
}

type Certificate struct {
	ID                string     `json:"id"`
	CertificateID     string     `json:"certificate_id"`
	UserID            string     `json:"user_id"`
	CourseID          string     `json:"course_id"`
	RecipientName     string     `json:"recipient_name"`
	CourseName        string     `json:"course_name"`
	IssuedAt          time.Time  `json:"issued_at"`
	VerificationToken string     `json:"verification_token"`
	PDFURL            *string    `json:"pdf_url,omitempty"`
	Status            string     `json:"status"`
	CreatedAt         time.Time  `json:"created_at"`
	VerificationURL   string     `json:"verification_url,omitempty"`
}

type ContentReport struct {
	ID          string    `json:"id"`
	UserID      *string   `json:"user_id,omitempty"`
	ContentID   string    `json:"content_id"`
	ContentType string    `json:"content_type"`
	Reason      string    `json:"reason"`
	Description *string   `json:"description,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}

// Request and Response transfer payloads
type ProfileUpdateRequest struct {
	DisplayName *string `json:"display_name,omitempty"`
	Username    *string `json:"username,omitempty"`
	AvatarURL   *string `json:"avatar_url,omitempty"`
}

type BookmarkCreateRequest struct {
	ContentType string `json:"content_type"`
	ContentID   string `json:"content_id"`
}

type QuizSubmitRequest struct {
	Score          int `json:"score"`
	TotalQuestions int `json:"total_questions"`
	CorrectAnswers int `json:"correct_answers"`
}

type CertificateClaimRequest struct {
	RecipientName *string `json:"recipient_name,omitempty"`
}

type SyncTopicItem struct {
	TopicID     string     `json:"topic_id"`
	CompletedAt *time.Time `json:"completed_at,omitempty"`
}

type SyncBookmarkItem struct {
	ContentType string `json:"content_type"`
	ContentID   string `json:"content_id"`
}

type SyncPayload struct {
	CompletedTopics []SyncTopicItem    `json:"completed_topics"`
	Bookmarks       []SyncBookmarkItem `json:"bookmarks"`
	ClientTimestamp time.Time          `json:"client_timestamp"`
}

type SyncResponse struct {
	Status               string   `json:"status"`
	SyncedTopicsCount    int      `json:"synced_topics_count"`
	SyncedBookmarksCount int      `json:"synced_bookmarks_count"`
	NewXPAwarded         int      `json:"new_xp_awarded"`
	Profile              Profile  `json:"profile"`
	UnlockedBadges       []string `json:"unlocked_badges"`
}

type AnalyticsEventRequest struct {
	EventType string                 `json:"event_type"`
	Payload   map[string]interface{} `json:"payload,omitempty"`
}

type APIError struct {
	Error struct {
		Code    string `json:"code"`
		Message string `json:"message"`
	} `json:"error"`
}
