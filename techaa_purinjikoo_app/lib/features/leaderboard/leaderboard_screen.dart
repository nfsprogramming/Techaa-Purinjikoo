import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/user_repository.dart';
import '../../shared/widgets/custom_card.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);

    final topAchievers = [
      {'rank': '1', 'name': 'CodeNinja99', 'xp': '1,840 XP', 'streak': '18 days', 'avatar': '🥇'},
      {'rank': '2', 'name': 'KarthikDev', 'xp': '1,620 XP', 'streak': '14 days', 'avatar': '🥈'},
      {'rank': '3', 'name': 'PriyaTech', 'xp': '1,490 XP', 'streak': '12 days', 'avatar': '🥉'},
      {'rank': '4', 'name': 'Arun_Cloud', 'xp': '1,380 XP', 'streak': '9 days', 'avatar': '👨‍💻'},
      {'rank': '5', 'name': 'DeepaCodes', 'xp': '1,310 XP', 'streak': '8 days', 'avatar': '👩‍💻'},
      {'rank': '42', 'name': '${user.name} (You)', 'xp': '${user.xp} XP', 'streak': '${user.streakDays} days', 'avatar': '😎', 'isMe': true},
      {'rank': '43', 'name': 'VijayDev', 'xp': '1,200 XP', 'streak': '5 days', 'avatar': '🚀'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Achievers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          itemCount: topAchievers.length,
          itemBuilder: (context, index) {
            final item = topAchievers[index];
            final isMe = item['isMe'] == true;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CustomCard(
                hasGlow: isMe,
                border: isMe ? Border.all(color: AppColors.primary, width: 1.5) : null,
                backgroundColor: isMe ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        item['rank'] as String,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isMe ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(item['avatar'] as String, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isMe ? AppColors.primary : AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '🔥 ${item['streak']}',
                            style: const TextStyle(fontSize: 11, color: AppColors.streakOrange),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item['xp'] as String,
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
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
