import 'certificate_service.dart';
import '../models/certificate.dart';
import '../datasources/remote/api_client.dart';
import '../../core/utils/app_logger.dart';

class BackendCertificateProvider implements CertificateProvider {
  final ApiClient _apiClient;
  final LocalCertificateProvider _fallbackProvider;
  final String? _authToken;

  BackendCertificateProvider({
    ApiClient? apiClient,
    LocalCertificateProvider? fallbackProvider,
    String? authToken,
  })  : _apiClient = apiClient ?? ApiClient(),
        _fallbackProvider = fallbackProvider ?? LocalCertificateProvider(),
        _authToken = authToken;

  @override
  Future<Certificate> generateCertificate({
    required String courseId,
    required String userId,
    required String userName,
    required String courseTitle,
  }) async {
    if (_authToken == null || _authToken.isEmpty) {
      // In Guest/Offline mode, use Local provider
      return _fallbackProvider.generateCertificate(
        courseId: courseId,
        userId: userId,
        userName: userName,
        courseTitle: courseTitle,
      );
    }

    try {
      final res = await _apiClient.post(
        '/courses/$courseId/claim-certificate',
        body: {'recipient_name': userName},
        token: _authToken,
      );

      if (res != null) {
        return Certificate(
          id: res['id'] ?? 'cert_${res['certificate_id']}',
          userId: userId,
          userName: res['recipient_name'] ?? userName,
          courseId: courseId,
          courseTitle: res['course_name'] ?? courseTitle,
          issueDate: res['issued_at'] != null ? DateTime.parse(res['issued_at']) : DateTime.now(),
          certificateCode: res['certificate_id'] ?? 'TP-CERT',
        );
      }
    } catch (e) {
      AppLogger.d('Backend certificate claim fallback to local: $e');
    }

    return _fallbackProvider.generateCertificate(
      courseId: courseId,
      userId: userId,
      userName: userName,
      courseTitle: courseTitle,
    );
  }

  @override
  Future<List<Certificate>> getCertificates(String userId) async {
    if (_authToken != null && _authToken.isNotEmpty) {
      try {
        final res = await _apiClient.get('/certificates', token: _authToken);
        if (res != null && res is List) {
          return (res as List).map((item) {
            return Certificate(
              id: item['id'] ?? 'cert_${item['certificate_id']}',
              userId: userId,
              userName: item['recipient_name'] ?? 'Learner',
              courseId: item['course_id'] ?? '',
              courseTitle: item['course_name'] ?? '',
              issueDate: item['issued_at'] != null ? DateTime.parse(item['issued_at']) : DateTime.now(),
              certificateCode: item['certificate_id'] ?? '',
            );
          }).toList();
        }
      } catch (e) {
        AppLogger.d('Backend certificate list fallback to local: $e');
      }
    }

    return _fallbackProvider.getCertificates(userId);
  }
}
