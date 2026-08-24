import '../models/certificate.dart';

abstract class CertificateProvider {
  Future<Certificate> generateCertificate({
    required String courseId,
    required String userId,
    required String userName,
    required String courseTitle,
  });

  Future<List<Certificate>> getCertificates(String userId);
}

class LocalCertificateProvider implements CertificateProvider {
  final Map<String, Certificate> _storage = {
    'c_web_dev': Certificate(
      id: 'cert_web_001',
      userId: 'user_nifras',
      userName: 'Nifras',
      courseId: 'c_web_dev',
      courseTitle: 'Web Development Basics',
      issueDate: DateTime(2026, 8, 20),
      certificateCode: 'TP-WEB-000123',
    ),
  };

  @override
  Future<Certificate> generateCertificate({
    required String courseId,
    required String userId,
    required String userName,
    required String courseTitle,
  }) async {
    if (_storage.containsKey(courseId)) {
      return _storage[courseId]!;
    }

    final code = 'TP-${courseId.toUpperCase().replaceAll('C_', '')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final cert = Certificate(
      id: 'cert_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      courseId: courseId,
      courseTitle: courseTitle,
      issueDate: DateTime.now(),
      certificateCode: code,
    );
    _storage[courseId] = cert;
    return cert;
  }

  @override
  Future<List<Certificate>> getCertificates(String userId) async {
    return _storage.values.toList();
  }
}

class CertificateService {
  final CertificateProvider _provider;

  CertificateService(this._provider);

  Future<Certificate> issueCertificate({
    required String courseId,
    required String userId,
    required String userName,
    required String courseTitle,
  }) {
    return _provider.generateCertificate(
      courseId: courseId,
      userId: userId,
      userName: userName,
      courseTitle: courseTitle,
    );
  }

  Future<List<Certificate>> fetchUserCertificates(String userId) {
    return _provider.getCertificates(userId);
  }
}
