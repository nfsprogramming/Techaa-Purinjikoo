import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NavDestinationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String semanticsLabel;

  const NavDestinationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    String? semanticsLabel,
  }) : semanticsLabel = semanticsLabel ?? label;
}

class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavDestinationItem> items;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    const double horizontalMargin = 4.0; // Reduced margin to widen the nav bar without hitting screen edges
    const double barHeight = 60.0; // Reduced height to solve the mathematical square problem!
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent, // Completely transparent outer wrapper per requirements
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalMargin, 
          0, 
          horizontalMargin, 
          bottomPadding > 0 ? bottomPadding + 8 : 16,
        ),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 32,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0x751E1E28), // Frosted top highlight
                      const Color(0x900C0C12), // Deep obsidian glass body
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double tabWidth = constraints.maxWidth / items.length;
                    
                    return Stack(
                      children: [
                        // The liquid glass morphing pill
                        _LiquidMorphPill(
                          selectedIndex: currentIndex,
                          tabWidth: tabWidth,
                          totalWidth: constraints.maxWidth,
                        ),
                        // The navigation items
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(items.length, (index) {
                            return Expanded(
                              child: _buildNavItem(index, items[index]),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, NavDestinationItem item) {
    final bool isActive = currentIndex == index;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isActive ? 1.06 : 0.95,
            duration: const Duration(milliseconds: 450),
            curve: _LiquidMorphPill.softSpring,
            child: Icon(
              isActive ? (item.activeIcon ?? item.icon) : item.icon,
              color: isActive ? Colors.white : const Color(0xFF71717A),
              size: 24,
            ),
          ),
          const SizedBox(height: 2), // Slightly reduced gap for the new 60px height
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            style: TextStyle(
              fontSize: 9.5, // Reduced slightly to ensure 'Flashcards' fits beautifully
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF71717A),
              fontFamily: 'Inter',
              letterSpacing: 0.1,
            ),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidMorphPill extends StatefulWidget {
  final int selectedIndex;
  final double tabWidth;
  final double totalWidth;
  
  static const Curve softSpring = Cubic(0.34, 1.3, 0.64, 1.0);

  const _LiquidMorphPill({
    required this.selectedIndex,
    required this.tabWidth,
    required this.totalWidth,
  });

  @override
  State<_LiquidMorphPill> createState() => _LiquidMorphPillState();
}

class _LiquidMorphPillState extends State<_LiquidMorphPill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _prevIndex = 0;
  double _targetIndex = 0;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.selectedIndex.toDouble();
    _targetIndex = widget.selectedIndex.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void didUpdateWidget(_LiquidMorphPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _prevIndex = _targetIndex;
      _targetIndex = widget.selectedIndex.toDouble();
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.isAnimating
            ? _LiquidMorphPill.softSpring.transform(_controller.value)
            : 1.0;

        final currentIndex = _prevIndex + (_targetIndex - _prevIndex) * t;

        // Dynamic stretch derived from velocity
        final distance = (_targetIndex - _prevIndex).abs();
        final stretch = distance * math.sin(t * math.pi) * 14.0;

        final isMovingRight = _targetIndex > _prevIndex;

        // Calculate desired dynamic bounds with stretch
        final desiredLeft = isMovingRight
            ? (currentIndex * widget.tabWidth) + 4.0
            : (currentIndex * widget.tabWidth) + 4.0 - stretch;

        final desiredWidth = widget.tabWidth + stretch - 8.0;
        final desiredRight = desiredLeft + desiredWidth;

        // Strict clamp to prevent spilling outside capsule margins [4.0, totalWidth - 4.0]
        final actualLeft = desiredLeft.clamp(4.0, widget.totalWidth - 4.0);
        final actualRight = desiredRight.clamp(4.0, widget.totalWidth - 4.0);
        final actualWidth = (actualRight - actualLeft).clamp(0.0, widget.totalWidth);

        final verticalInset = 4.0 + (stretch * 0.12);

        return Positioned(
          left: actualLeft,
          top: verticalInset,
          bottom: verticalInset,
          child: Container(
            width: actualWidth,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26), // 30 - 4 = exactly 26 for perfect concentricity!
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.35),
                    AppColors.primaryAccent.withValues(alpha: 0.14),
                  ],
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.55),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.18),
                    blurRadius: 8,
                    spreadRadius: -1,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
