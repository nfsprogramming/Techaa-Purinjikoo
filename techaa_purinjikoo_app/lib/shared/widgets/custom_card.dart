import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'interactive_pressable.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;
  final bool hasGlow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.border,
    this.onTap,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: border ??
            Border.all(
              color: hasGlow ? AppColors.borderRed : AppColors.borderSubtle,
              width: 1.2,
            ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InteractivePressable(
        onTap: onTap,
        scaleFactor: 0.975,
        borderRadius: BorderRadius.circular(18),
        child: content,
      );
    }

    return content;
  }
}
