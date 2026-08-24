import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/roadmap_node.dart';
import '../../data/repositories/roadmap_repository.dart';
import '../../shared/widgets/custom_card.dart';

class RoadmapScreen extends ConsumerWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = ref.watch(roadmapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech Roadmap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          itemCount: nodes.length,
          itemBuilder: (context, index) {
            final node = nodes[index];
            final isLast = index == nodes.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline column
                  Column(
                    children: [
                      _buildNodeIndicator(node),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: node.status == NodeStatus.completed
                                ? AppColors.success
                                : AppColors.borderMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Node Content Card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: CustomCard(
                        hasGlow: node.status == NodeStatus.current,
                        border: Border.all(
                          color: node.status == NodeStatus.current
                              ? AppColors.primary
                              : AppColors.borderMuted,
                          width: node.status == NodeStatus.current ? 1.5 : 1.0,
                        ),
                        onTap: node.status != NodeStatus.locked && node.topicId != null
                            ? () => context.push('/topic/${node.topicId}')
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    node.category,
                                    style: const TextStyle(fontSize: 10, color: AppColors.tertiary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  'Step ${node.stepNumber}',
                                  style: const TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(node.iconEmoji, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    node.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: node.status == NodeStatus.locked
                                          ? AppColors.onSurfaceVariant
                                          : AppColors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              node.description,
                              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.3),
                            ),
                            if (node.status == NodeStatus.current && node.topicId != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    'Start Step',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 16),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNodeIndicator(RoadmapNode node) {
    if (node.status == NodeStatus.completed) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
      );
    } else if (node.status == NodeStatus.current) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderMuted),
        ),
        child: const Icon(Icons.lock_rounded, color: AppColors.outlineVariant, size: 16),
      );
    }
  }
}
