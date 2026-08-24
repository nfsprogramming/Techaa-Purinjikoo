import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class XpBadge extends StatelessWidget {
  final int xp;
  final double fontSize;

  const XpBadge({
    super.key,
    required this.xp,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.stars_rounded, color: AppColors.xpViolet, size: fontSize + 3),
        const SizedBox(width: 4),
        Text(
          '+$xp XP',
          style: TextStyle(
            color: AppColors.xpViolet,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
