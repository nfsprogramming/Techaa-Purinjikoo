package tests

import (
	"testing"
	"techaa-backend/internal/gamification"
)

func TestGamificationLevelCalculations(t *testing.T) {
	tests := []struct {
		xp            int
		expectedLevel int
		expectedTitle string
	}{
		{0, 1, "Curious Beginner"},
		{150, 1, "Curious Beginner"},
		{200, 2, "Tech Explorer"},
		{499, 2, "Tech Explorer"},
		{500, 3, "Developer"},
		{1000, 4, "Tech Pro"},
		{2500, 5, "Tech Architect"},
		{5000, 6, "CTO Level"},
		{10000, 7, "Tech Legend"},
		{25000, 7, "Tech Legend"},
	}

	for _, tt := range tests {
		info := gamification.CalculateLevel(tt.xp)
		if info.Level != tt.expectedLevel {
			t.Errorf("For XP %d, expected level %d, got %d", tt.xp, tt.expectedLevel, info.Level)
		}
		if info.Title != tt.expectedTitle {
			t.Errorf("For XP %d, expected title %s, got %s", tt.xp, tt.expectedTitle, info.Title)
		}
		if info.LevelProgress < 0.0 || info.LevelProgress > 1.0 {
			t.Errorf("For XP %d, progress %f is out of bounds [0, 1]", tt.xp, info.LevelProgress)
		}
	}
}

func TestBadgesDefinitions(t *testing.T) {
	if len(gamification.Badges) != 6 {
		t.Fatalf("Expected 6 standard badges, got %d", len(gamification.Badges))
	}

	for _, b := range gamification.Badges {
		if b.ID == "" || b.Title == "" || b.XPReward <= 0 {
			t.Errorf("Badge %+v is missing required fields", b)
		}
	}
}
