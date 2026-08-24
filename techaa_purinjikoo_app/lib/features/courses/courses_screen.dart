import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/certificate_repository.dart';
import '../../shared/widgets/custom_card.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Paths', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CustomCard(
                onTap: () async {
                  if (course.isCompleted) {
                    await ref.read(certificatesProvider.notifier).unlockCourseCertificate(
                          courseId: course.id,
                          courseTitle: course.title,
                        );
                    if (context.mounted) {
                      context.push('/certificate/${course.id}');
                    }
                  } else {
                    context.push('/topic/${course.topicIds.first}');
                  }
                },
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderMuted),
                          ),
                          child: Center(
                            child: Text(course.iconEmoji, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      course.difficulty,
                                      style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${course.estimatedHours} Hours',
                                    style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      course.description,
                      style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${course.completedTopics} of ${course.totalTopics} Topics Completed',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${(course.progress * 100).toInt()}%',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: course.isCompleted ? AppColors.success : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.centerLeft,
                        widthFactor: course.progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: course.isCompleted ? AppColors.success : AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    if (course.isCompleted) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Certificate Unlocked',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'View Certificate →',
                            style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 14),
                      const Row(
                        children: [
                          Icon(Icons.lock_clock_rounded, color: AppColors.outlineVariant, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Complete all topics to unlock Certificate',
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
