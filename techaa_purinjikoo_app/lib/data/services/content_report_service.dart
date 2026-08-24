import '../../core/utils/app_logger.dart';

enum ReportReason {
  incorrectExplanation,
  wrongQuizAnswer,
  typoOrSpelling,
  brokenAnalogy,
  other,
}

class ContentReport {
  final String id;
  final String topicId;
  final ReportReason reason;
  final String comments;
  final DateTime timestamp;

  const ContentReport({
    required this.id,
    required this.topicId,
    required this.reason,
    required this.comments,
    required this.timestamp,
  });
}

class ContentReportService {
  static final List<ContentReport> _localReports = [];

  static Future<bool> submitReport({
    required String topicId,
    required ReportReason reason,
    required String comments,
  }) async {
    try {
      final report = ContentReport(
        id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
        topicId: topicId,
        reason: reason,
        comments: comments,
        timestamp: DateTime.now(),
      );
      _localReports.add(report);
      AppLogger.i('📝 Topic Report submitted for $topicId: ${reason.name}');
      return true;
    } catch (e) {
      AppLogger.e('Failed to submit report', e);
      return false;
    }
  }
}
