import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/glass_bottom_nav_bar.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    final navItems = const [
      NavDestinationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        semanticsLabel: 'Home Navigation Tab',
      ),
      NavDestinationItem(
        icon: Icons.school_outlined,
        activeIcon: Icons.school_rounded,
        label: 'Learn',
        semanticsLabel: 'Learn Topics Tab',
      ),
      NavDestinationItem(
        icon: Icons.sports_kabaddi_outlined,
        activeIcon: Icons.sports_kabaddi_rounded,
        label: 'Battle',
        semanticsLabel: 'Tech Battle Tab',
      ),
      NavDestinationItem(
        icon: Icons.style_outlined,
        activeIcon: Icons.style_rounded,
        label: 'Flashcards',
        semanticsLabel: 'Flashcards Practice Tab',
      ),
      NavDestinationItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
        semanticsLabel: 'User Profile and Stats Tab',
      ),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent, // Ensures the scaffold itself doesn't obscure inner scaffolds
      body: Stack(
        children: [
          // 1. Page Content extends fully
          navigationShell,

          // 2. Floating Glass Nav Bar perfectly positioned above content
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) => _onTap(context, index),
              items: navItems,
            ),
          ),
        ],
      ),
    );
  }
}
