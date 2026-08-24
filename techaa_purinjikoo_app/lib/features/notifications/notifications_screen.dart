import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'icon': '🔥',
        'title': 'Streak Milestone!',
        'body': 'You\'ve maintained a 7-day learning streak! Keep the flame burning.',
        'time': '2 hours ago',
        'isNew': true,
      },
      {
        'icon': '⚔️',
        'title': 'Daily Tech Battle Ready',
        'body': 'Today\'s 60-second challenge is live. Earn +50 bonus XP!',
        'time': '5 hours ago',
        'isNew': true,
      },
      {
        'icon': '💡',
        'title': 'New Topic: Docker & Containers',
        'body': 'Learn how shipping containers for software revolutionized deployment.',
        'time': 'Yesterday',
        'isNew': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final item = notifications[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['icon'] as String, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                              if (item['isNew'] == true)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['body'] as String,
                            style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['time'] as String,
                            style: const TextStyle(fontSize: 11, color: AppColors.outlineVariant),
                          ),
                        ],
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
