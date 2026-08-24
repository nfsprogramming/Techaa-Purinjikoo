import 'package:flutter_test/flutter_test.dart';
import 'package:techaa_purinjikoo_app/data/models/user_profile.dart';
import 'package:techaa_purinjikoo_app/data/datasources/initial_content.dart';
import 'package:techaa_purinjikoo_app/data/services/achievement_service.dart';

void main() {
  group('AchievementService Tests', () {
    test('unlocks first step badge when completedTopicIds is not empty', () {
      final allBadges = InitialContent.getBadges();
      const profile = UserProfile(
        completedTopicIds: ['topic_api'],
        unlockedBadgeIds: [],
      );

      final result = AchievementService.evaluateAchievements(
        profile: profile,
        allBadges: allBadges,
      );

      expect(result.newlyUnlockedBadges.any((b) => b.id == 'badge_first_step'), isTrue);
      expect(result.bonusXp, greaterThanOrEqualTo(50));
    });

    test('does not re-unlock already unlocked badges', () {
      final allBadges = InitialContent.getBadges();
      const profile = UserProfile(
        completedTopicIds: ['topic_api'],
        unlockedBadgeIds: ['badge_first_step', 'badge_quiz_warrior'],
      );

      final result = AchievementService.evaluateAchievements(
        profile: profile,
        allBadges: allBadges,
      );

      expect(result.newlyUnlockedBadges.any((b) => b.id == 'badge_first_step'), isFalse);
    });
  });
}
