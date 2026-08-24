import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/badge_item.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/course_repository.dart';
import '../../shared/widgets/streak_badge.dart';
import '../../shared/widgets/animated_counter.dart';
import '../../shared/widgets/interactive_pressable.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final authSession = ref.watch(authRepositoryProvider);
    final badges = ref.watch(badgesListProvider);
    final courses = ref.watch(coursesProvider);

    final nameFromAuth = authSession?.displayName;
    final displayName = (nameFromAuth != null && nameFromAuth.isNotEmpty)
        ? nameFromAuth
        : user.name;
    final photoUrl = authSession?.photoUrl ?? user.avatarUrl;
    final email = authSession?.email ?? user.email;

    final unlockedCount = badges.where((b) => b.unlocked).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            // Header with settings icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.settings_outlined, color: Color(0xFFA1A1AA)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Profile Card (Modern Red & AMOLED Black)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderRed),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with Crimson Ambient Glow
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(39),
                      child: photoUrl.isNotEmpty
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildAvatarFallback(displayName),
                            )
                          : _buildAvatarFallback(displayName),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Display Name
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Email if available
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA1A1AA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),

                  // Level Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      'Level ${user.level} • ${user.levelTitle}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Streak Badge
                  StreakBadge(streakDays: user.streakDays),
                  const SizedBox(height: 20),

                  // XP Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedCounter(
                        count: user.xp,
                        suffix: ' Total XP',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA1A1AA),
                        ),
                      ),
                      Text(
                        '${(user.levelProgress * 100).toInt()}% to Level ${user.level + 1}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryAccent,
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
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: user.levelProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.xpGradient,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4-Card Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Topics', '${user.completedTopicIds.length}', '📚', AppColors.primaryAccent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatItem('Streak', '${user.streakDays} Days', '🔥', const Color(0xFFFF8A00)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Total XP', '${user.xp}', '✨', const Color(0xFFFFD166)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatItem('Badges', '$unlockedCount / ${badges.length}', '🏆', AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Achievements & Badges Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Achievements & Badges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$unlockedCount Unlocked',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA1A1AA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Badges Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeCard(badge);
              },
            ),
            const SizedBox(height: 28),

            // Roadmap Certificates Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Roadmap Certificates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${courses.length} Tracks',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA1A1AA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Certificates List
            ...courses.map((course) {
              final isCourseCompleted = user.completedCourseIds.contains(course.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InteractivePressable(
                  onTap: () => context.push('/certificate/${course.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCourseCompleted
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isCourseCompleted
                                ? AppColors.primary.withValues(alpha: 0.18)
                                : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              isCourseCompleted ? '📜' : '🔒',
                              style: const TextStyle(fontSize: 24),
                            ),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCourseCompleted ? 'Completed & Verified Certificate' : 'Complete roadmap modules to unlock',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCourseCompleted ? AppColors.primaryAccent : const Color(0xFF71717A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF71717A)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '☕';
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA1A1AA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BadgeItem badge) {
    final isUnlocked = badge.unlocked;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isUnlocked ? 1.0 : 0.35,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isUnlocked ? badge.iconEmoji : '🔒',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isUnlocked ? Colors.white : const Color(0xFF71717A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isUnlocked ? 'Unlocked' : 'Locked',
            style: TextStyle(
              fontSize: 9.5,
              color: isUnlocked ? AppColors.primaryAccent : const Color(0xFF52525B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
