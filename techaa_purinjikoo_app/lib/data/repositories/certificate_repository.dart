import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/certificate.dart';
import '../services/certificate_service.dart';
import 'user_repository.dart';

final certificateServiceProvider = Provider<CertificateService>((ref) {
  return CertificateService(LocalCertificateProvider());
});

class CertificateRepository extends Notifier<List<Certificate>> {
  @override
  List<Certificate> build() {
    // Start clean with no mock certificates; issued when courses/modules are completed
    return const [];
  }

  Future<Certificate> unlockCourseCertificate({
    required String courseId,
    required String courseTitle,
  }) async {
    final user = ref.read(userProfileProvider);
    final service = ref.read(certificateServiceProvider);

    final cert = await service.issueCertificate(
      courseId: courseId,
      userId: 'user_live',
      userName: user.name,
      courseTitle: courseTitle,
    );

    if (!state.any((c) => c.courseId == courseId)) {
      state = [...state, cert];
    }
    return cert;
  }
}

final certificatesProvider = NotifierProvider<CertificateRepository, List<Certificate>>(CertificateRepository.new);

final certificateByIdProvider = Provider.family<Certificate, String>((ref, courseId) {
  final list = ref.watch(certificatesProvider);
  final user = ref.watch(userProfileProvider);

  try {
    return list.firstWhere((c) => c.courseId == courseId);
  } catch (_) {
    return Certificate(
      id: 'cert_$courseId',
      userId: 'user_live',
      userName: user.name,
      courseId: courseId,
      courseTitle: 'Full Stack Engineering Track',
      issueDate: DateTime.now(),
      certificateCode: 'TP-CERT-${courseId.toUpperCase()}',
    );
  }
});
