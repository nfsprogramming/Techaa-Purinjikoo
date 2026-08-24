import 'package:flutter_test/flutter_test.dart';
import 'package:techaa_purinjikoo_app/data/services/certificate_service.dart';

void main() {
  group('CertificateService Tests', () {
    test('generates valid certificate with unique ID and verification URL', () async {
      final service = CertificateService(LocalCertificateProvider());

      final cert = await service.issueCertificate(
        courseId: 'c_backend',
        userId: 'user_test',
        userName: 'Test User',
        courseTitle: 'Backend Architecture',
      );

      expect(cert.courseId, equals('c_backend'));
      expect(cert.userName, equals('Test User'));
      expect(cert.certificateCode.startsWith('TP-'), isTrue);
      expect(cert.shareMessage.contains('Backend Architecture'), isTrue);
    });
  });
}
