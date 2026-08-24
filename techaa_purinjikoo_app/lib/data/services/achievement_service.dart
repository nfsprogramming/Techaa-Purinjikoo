import '../models/user_profile.dart';
import '../models/badge_item.dart';
import '../../core/analytics/app_analytics.dart';

class AchievementEvaluationResult {
  final List<BadgeItem> newlyUnlockedBadges;
  final int bonusXp;

  const AchievementEvaluationResult({
    required this.newlyUnlockedBadges,
    required this.bonusXp,
  });
}

class AchievementService {
  static AchievementEvaluationResult evaluateAchievements({
    required UserProfile profile,
    required List<BadgeItem> allBadges,
  }) {
    final List<BadgeItem> newlyUnlocked = [];
    int bonusXp = 0;

    for (final badge in allBadges) {
      if (profile.unlockedBadgeIds.contains(badge.id)) {
        continue; // Already unlocked
      }

      bool shouldUnlock = false;

      switch (badge.id) {
        case 'badge_first_step':
          shouldUnlock = profile.completedTopicIds.isNotEmpty;
          break;
        case 'badge_quiz_warrior':
          shouldUnlock = profile.completedTopicIds.length >= 2;
          break;
        case 'badge_streak_master':
          shouldUnlock = profile.streakDays >= 7;
          break;
        case 'badge_web_explorer':
          shouldUnlock = profile.completedTopicIds.any((t) => t.contains('web') || t.contains('api'));
          break;
        case 'badge_cloud_ninja':
          shouldUnlock = profile.completedTopicIds.contains('topic_docker');
          break;
        case 'badge_ai_pioneer':
          shouldUnlock = profile.completedTopicIds.contains('topic_ai_llm');
          break;
        default:
          shouldUnlock = false;
      }

      if (shouldUnlock) {
        newlyUnlocked.add(badge.copyWith(unlocked: true));
        bonusXp += 50;
        AppAnalytics.logBadgeUnlocked(badge.id);
      }
    }

    return AchievementEvaluationResult(
      newlyUnlockedBadges: newlyUnlocked,
      bonusXp: bonusXp,
    );
  }
}
