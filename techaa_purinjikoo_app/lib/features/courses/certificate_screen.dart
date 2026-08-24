import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/certificate_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../shared/widgets/custom_card.dart';

class CertificateScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CertificateScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  bool isDownloading = false;

  void _downloadPdf() {
    setState(() => isDownloading = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('✓ Certificate PDF saved to Downloads folder!'),
          ),
        );
      }
    });
  }

  void _shareAchievement(String courseTitle, String certCode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.borderMuted),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Share Achievement Card',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              const SizedBox(height: 16),
              // Compact Achievement Card
              CustomCard(
                hasGlow: true,
                padding: const EdgeInsets.all(20),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1.5),
                child: Column(
                  children: [
                    const Text('TECHAA PURINJIKOO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    const Text('🎓 Course Completed!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    const SizedBox(height: 6),
                    Text(
                      courseTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 12),
                    Text('Certificate ID: $certCode', style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: Colors.amber)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Share to LinkedIn / WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.success,
                        content: Text('🎉 Achievement text & certificate link copied to clipboard!'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final cert = ref.watch(certificateByIdProvider(widget.courseId));

    final courseTitle = cert.courseTitle;
    final certCode = cert.certificateCode;
    final dateStr = cert.formattedDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verified Certificate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            children: [
              // Certificate Preview Container
              CustomCard(
                hasGlow: true,
                padding: const EdgeInsets.all(24),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.65), width: 2),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 1.5),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 36),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'TECHAA PURINJIKOO',
                      style: TextStyle(
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'CERTIFICATE OF COMPLETION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const Divider(color: AppColors.borderMuted, height: 32),
                    const Text(
                      'This is proudly presented to',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'for successfully mastering all core practical concepts in',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      courseTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tertiary,
                      ),
                    ),
                    const Divider(color: AppColors.borderMuted, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DATE ISSUED', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('CERTIFICATE ID', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 2),
                            Text(
                              certCode,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono', color: Colors.amber),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        side: const BorderSide(color: AppColors.borderMuted),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: isDownloading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Icon(Icons.download_rounded, size: 20),
                      label: Text(
                        isDownloading ? 'Downloading...' : 'Download PDF',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: isDownloading ? null : _downloadPdf,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 20),
                      label: const Text('Share Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      onPressed: () => _shareAchievement(courseTitle, certCode),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
