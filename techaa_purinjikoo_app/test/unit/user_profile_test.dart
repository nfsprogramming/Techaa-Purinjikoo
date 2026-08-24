import 'package:flutter_test/flutter_test.dart';
import 'package:techaa_purinjikoo_app/data/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('calculates levelProgress correctly for Level 1 user with 250 XP', () {
      const profile = UserProfile(level: 1, xp: 250);
      expect(profile.levelProgress, closeTo(0.5, 0.01));
    });

    test('determines correct level titles', () {
      const p1 = UserProfile(level: 1, levelTitle: 'Curious Coder');
      const p4 = UserProfile(level: 4, levelTitle: 'Tech Explorer');
      const p5 = UserProfile(level: 5, levelTitle: 'Tech Architect');

      expect(p1.levelTitle, equals('Curious Coder'));
      expect(p4.levelTitle, equals('Tech Explorer'));
      expect(p5.levelTitle, equals('Tech Architect'));
    });
  });
}
