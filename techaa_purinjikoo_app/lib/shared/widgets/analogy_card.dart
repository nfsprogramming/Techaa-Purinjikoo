import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/analogy_data.dart';
import 'custom_card.dart';

class AnalogyCard extends StatelessWidget {
  final AnalogyData analogy;

  const AnalogyCard({
    super.key,
    required this.analogy,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  analogy.title.isNotEmpty ? analogy.title : 'Real-world Analogy',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (analogy.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              analogy.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 20),
          // 3-Node Visual representation
          if (analogy.visualNodes.isNotEmpty)
            Row(
              children: List.generate(analogy.visualNodes.length, (idx) {
                final node = analogy.visualNodes[idx];
                final isLast = idx == analogy.visualNodes.length - 1;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildVisualNode(
                          iconEmoji: node.icon,
                          label: node.label,
                          isHighlighted: idx == 1,
                        ),
                      ),
                      if (!isLast)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.0),
                          child: Icon(Icons.arrow_forward_rounded, color: AppColors.outlineVariant, size: 16),
                        ),
                    ],
                  ),
                );
              }),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildNode(
                    role: analogy.userRole,
                    label: analogy.userLabel,
                    icon: Icons.smartphone_rounded,
                    color: AppColors.tertiary,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(Icons.arrow_forward_rounded, color: AppColors.outlineVariant, size: 20),
                ),
                Expanded(
                  child: _buildNode(
                    role: analogy.connectorRole,
                    label: analogy.connectorLabel,
                    icon: Icons.sync_alt_rounded,
                    color: AppColors.primary,
                    isHighlighted: true,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(Icons.arrow_forward_rounded, color: AppColors.outlineVariant, size: 20),
                ),
                Expanded(
                  child: _buildNode(
                    role: analogy.targetRole,
                    label: analogy.targetLabel,
                    icon: Icons.dns_rounded,
                    color: AppColors.tertiaryContainer,
                  ),
                ),
              ],
            ),
          if (analogy.takeaway.isNotEmpty && analogy.takeaway != analogy.description) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderMuted, width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('👉', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      analogy.takeaway,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisualNode({
    required String iconEmoji,
    required String label,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlighted ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderMuted,
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(iconEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: isHighlighted ? AppColors.primary : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode({
    required String role,
    required String label,
    required IconData icon,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withValues(alpha: 0.12) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlighted ? color.withValues(alpha: 0.5) : AppColors.borderMuted,
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            role,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
