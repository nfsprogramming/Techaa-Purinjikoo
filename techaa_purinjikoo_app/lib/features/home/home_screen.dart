import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/topic_repository.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/streak_badge.dart';
import '../../shared/widgets/animated_counter.dart';
import 'widgets/daily_tech_bite_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final authSession = ref.watch(authRepositoryProvider);
    final courses = ref.watch(coursesProvider);
    final activeCourse = courses.isNotEmpty ? courses.first : null;

    final nameFromAuth = authSession?.displayName;
    final displayName = (nameFromAuth != null && nameFromAuth.isNotEmpty)
        ? nameFromAuth.split(' ')[0]
        : (user.name.isNotEmpty ? user.name.split(' ')[0] : 'Techie');
    final photoUrl = authSession?.photoUrl ?? user.avatarUrl;

    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: photoUrl.isNotEmpty
                                ? Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildAvatarInitial(displayName),
                                  )
                                : _buildAvatarInitial(displayName),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$greeting, $displayName 👋',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onBackground,
                                ),
                              ),
                              Text(
                                'Ready to learn today?',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Share.share('Dei, college tech roadmaps, free AI tools, and interview hacks ellam ore app-la Tanglish-la irukku! Install Techaa Purinjikoo 🚀 https://github.com/nfsprogramming');
                    },
                    tooltip: 'Invite a Junior',
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    tooltip: 'Notifications',
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderRed,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          Positioned(
                            top: 8,
                            right: 9,
                            child: CircleAvatar(
                              radius: 3.5,
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Progress Card with Animated Counter
              CustomCard(
                hasGlow: true,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LEVEL ${user.level}'.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.levelTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        StreakBadge(streakDays: user.streakDays),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedCounter(
                          count: user.xp,
                          suffix: ' XP',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${(user.levelProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.centerLeft,
                        widthFactor: user.levelProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.xpGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Daily 60-Second Tech Bite Card (Tanglish)
              const DailyTechBiteCard(),
              const SizedBox(height: 24),

              // Today's Tech Bite Card
              CustomCard(
                onTap: () {
                  final allTopics = ref.read(topicsProvider);
                  if (allTopics.isEmpty) return;
                  final nextTopic = allTopics.firstWhere(
                    (t) => !user.completedTopicIds.contains(t.id),
                    orElse: () => allTopics.first,
                  );
                  context.push('/topic/${nextTopic.id}');
                },
                padding: const EdgeInsets.all(20),
                child: Builder(
                  builder: (context) {
                    final allTopics = ref.watch(topicsProvider);
                    if (allTopics.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final nextTopic = allTopics.firstWhere(
                      (t) => !user.completedTopicIds.contains(t.id),
                      orElse: () => allTopics.first,
                    );
                    final title = '${nextTopic.emoji} ${nextTopic.title}';
                    final desc = nextTopic.shortDesc.isNotEmpty ? nextTopic.shortDesc : nextTopic.subtitle;
                    final diff = nextTopic.difficulty.isNotEmpty ? nextTopic.difficulty : 'Beginner';
                    final readTime = nextTopic.readTime.isNotEmpty ? nextTopic.readTime : '2 min read';
                    final topicId = nextTopic.id;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                diff,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 15, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  readTime,
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => context.push('/topic/$topicId'),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start Learning',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Continue Learning
              const Text(
                'CONTINUE LEARNING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (activeCourse != null)
                CustomCard(
                  onTap: () => context.push('/courses'),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderMuted),
                        ),
                        child: Center(
                          child: Text(activeCourse.iconEmoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeCourse.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Topic ${activeCourse.completedTopics.toString().padLeft(2, '0')} / ${activeCourse.totalTopics.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${(activeCourse.progress * 100).toInt()}% progress',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 80,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.centerLeft,
                              widthFactor: activeCourse.progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Quick Actions Grid
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildQuickActionButton(
                    icon: Icons.bolt_rounded,
                    iconColor: AppColors.primary,
                    title: 'Quick Learn',
                    onTap: () => context.go('/learn'),
                  ),
                  _buildQuickActionButton(
                    icon: Icons.style_rounded,
                    iconColor: AppColors.tertiaryContainer,
                    title: 'Flashcards',
                    onTap: () => context.go('/cards'),
                  ),
                  _buildQuickActionButton(
                    icon: Icons.sports_kabaddi_rounded,
                    iconColor: AppColors.streakOrange,
                    title: 'Battle',
                    onTap: () => context.go('/battle'),
                  ),
                  _buildQuickActionButton(
                    icon: Icons.menu_book_rounded,
                    iconColor: AppColors.xpViolet,
                    title: 'Dictionary',
                    onTap: () => context.push('/dictionary'),
                  ),
                  _buildQuickActionButton(
                    icon: Icons.map_rounded,
                    iconColor: AppColors.success,
                    title: 'Roadmap',
                    onTap: () => context.push('/roadmap'),
                  ),
                  _buildQuickActionButton(
                    icon: Icons.school_rounded,
                    iconColor: AppColors.primary,
                    title: 'Courses',
                    onTap: () => context.push('/courses'),
                  ),
                ],
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInitial(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '☕';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
