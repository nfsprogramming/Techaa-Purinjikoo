import 'api_client.dart';
import '../../models/user_profile.dart';
import '../../../core/utils/app_logger.dart';

class UserRemoteDataSource {
  final ApiClient _apiClient;

  UserRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<UserProfile?> fetchProfile(String token) async {
    final res = await _apiClient.get('/profile', token: token);
    if (res == null) return null;

    try {
      return UserProfile(
        name: res['display_name'] ?? 'Tech Learner',
        levelTitle: res['level_title'] ?? 'Tech Explorer',
        xp: res['total_xp'] ?? 0,
        level: res['level'] ?? 1,
        streakDays: res['current_streak'] ?? 1,
      );
    } catch (e) {
      AppLogger.d('Failed to parse remote profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> completeTopic(String topicId, String token) async {
    return await _apiClient.post('/progress/topics/$topicId/complete', token: token);
  }

  Future<Map<String, dynamic>?> syncOfflineProgress({
    required List<String> topicIds,
    required String token,
  }) async {
    final payload = {
      'completed_topics': topicIds.map((id) => {'topic_id': id}).toList(),
      'bookmarks': [],
      'client_timestamp': DateTime.now().toIso8601String(),
    };
    return await _apiClient.post('/sync', body: payload, token: token);
  }
}
