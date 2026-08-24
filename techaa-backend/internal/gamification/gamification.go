package gamification

import "math"

type XPLevel struct {
	Level int    `json:"level"`
	Title string `json:"title"`
	MinXP int    `json:"min_xp"`
	MaxXP int    `json:"max_xp"`
}

type BadgeDef struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	IconEmoji   string `json:"icon_emoji"`
	Requirement string `json:"requirement"`
	XPReward    int    `json:"xp_reward"`
}

var (
	XPAwards = map[string]int{
		"READ_TOPIC":       10,
		"QUIZ_CORRECT":     20,
		"DAILY_LOGIN":      5,
		"SHARE_TOPIC":      15,
		"COURSE_COMPLETED": 100,
	}

	XPLevels = []XPLevel{
		{Level: 1, Title: "Curious Beginner", MinXP: 0, MaxXP: 199},
		{Level: 2, Title: "Tech Explorer", MinXP: 200, MaxXP: 499},
		{Level: 3, Title: "Developer", MinXP: 500, MaxXP: 999},
		{Level: 4, Title: "Tech Pro", MinXP: 1000, MaxXP: 2499},
		{Level: 5, Title: "Tech Architect", MinXP: 2500, MaxXP: 4999},
		{Level: 6, Title: "CTO Level", MinXP: 5000, MaxXP: 9999},
		{Level: 7, Title: "Tech Legend", MinXP: 10000, MaxXP: 999999},
	}

	Badges = []BadgeDef{
		{
			ID:          "badge_first_step",
			Title:       "First Step",
			Description: "Completed your very first tech topic!",
			IconEmoji:   "🚀",
			Requirement: "Complete 1 topic",
			XPReward:    20,
		},
		{
			ID:          "badge_quiz_warrior",
			Title:       "Quiz Warrior",
			Description: "Scored 100% on a battle quiz.",
			IconEmoji:   "⚔️",
			Requirement: "Score 100% in a quiz",
			XPReward:    30,
		},
		{
			ID:          "badge_streak_master",
			Title:       "Streak Master",
			Description: "Maintained a 7-day learning streak!",
			IconEmoji:   "🔥",
			Requirement: "Reach 7 days streak",
			XPReward:    50,
		},
		{
			ID:          "badge_web_explorer",
			Title:       "Web Explorer",
			Description: "Completed foundational Web topics.",
			IconEmoji:   "🌐",
			Requirement: "Complete Web topics",
			XPReward:    40,
		},
		{
			ID:          "badge_cloud_ninja",
			Title:       "Cloud Ninja",
			Description: "Mastered Docker, DevOps, and Cloud deployment.",
			IconEmoji:   "☁️",
			Requirement: "Complete Cloud course",
			XPReward:    60,
		},
		{
			ID:          "badge_ai_pioneer",
			Title:       "AI Pioneer",
			Description: "Explored Large Language Models and prompt engineering.",
			IconEmoji:   "🤖",
			Requirement: "Complete AI topics",
			XPReward:    80,
		},
	}
)

type LevelInfo struct {
	Level          int     `json:"level"`
	Title          string  `json:"title"`
	TotalXP        int     `json:"total_xp"`
	MinXP          int     `json:"min_xp"`
	MaxXP          int     `json:"max_xp"`
	LevelProgress  float64 `json:"level_progress"`
	XPToNextLevel  int     `json:"xp_to_next_level"`
}

func CalculateLevel(totalXP int) LevelInfo {
	cur := XPLevels[0]
	var next *XPLevel

	for i := range XPLevels {
		if totalXP >= XPLevels[i].MinXP {
			cur = XPLevels[i]
			if i+1 < len(XPLevels) {
				next = &XPLevels[i+1]
			} else {
				next = nil
			}
		}
	}

	progress := 1.0
	xpToNext := 0

	if next != nil {
		xpInLevel := totalXP - cur.MinXP
		xpSpan := next.MinXP - cur.MinXP
		if xpSpan > 0 {
			progress = math.Min(1.0, math.Max(0.0, float64(xpInLevel)/float64(xpSpan)))
		}
		xpToNext = int(math.Max(0, float64(next.MinXP-totalXP)))
	}

	return LevelInfo{
		Level:         cur.Level,
		Title:         cur.Title,
		TotalXP:       totalXP,
		MinXP:         cur.MinXP,
		MaxXP:         cur.MaxXP,
		LevelProgress: math.Round(progress*1000) / 1000,
		XPToNextLevel: xpToNext,
	}
}
