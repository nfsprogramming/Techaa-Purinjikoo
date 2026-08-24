import '../utils/app_logger.dart';

abstract class AnalyticsProvider {
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]);
  Future<void> setUserId(String? userId);
}

class ConsoleAnalyticsProvider implements AnalyticsProvider {
  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    AppLogger.i('📊 Analytics Event: $name ${parameters ?? ''}');
  }

  @override
  Future<void> setUserId(String? userId) async {
    AppLogger.i('📊 Set User ID: $userId');
  }
}

class AppAnalytics {
  static AnalyticsProvider _provider = ConsoleAnalyticsProvider();

  static void setProvider(AnalyticsProvider provider) {
    _provider = provider;
  }

  static void logEvent(String name, [Map<String, dynamic>? parameters]) {
    _provider.logEvent(name, parameters);
  }

  static void logTopicCompleted(String topicId, int xp) {
    logEvent('topic_completed', {'topic_id': topicId, 'xp_earned': xp});
  }

  static void logQuizCompleted(String quizId, bool isCorrect) {
    logEvent('quiz_completed', {'quiz_id': quizId, 'is_correct': isCorrect});
  }

  static void logBadgeUnlocked(String badgeId) {
    logEvent('badge_unlocked', {'badge_id': badgeId});
  }

  static void logCourseCompleted(String courseId) {
    logEvent('course_completed', {'course_id': courseId});
  }

  static void logCertificateViewed(String courseId) {
    logEvent('certificate_viewed', {'course_id': courseId});
  }
}
