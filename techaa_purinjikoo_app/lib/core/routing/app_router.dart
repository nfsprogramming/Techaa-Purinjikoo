import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/navigation/scaffold_with_nav_bar.dart';
import '../../features/home/home_screen.dart';
import '../../features/learn/learn_screen.dart';
import '../../features/topics/topic_reader_screen.dart';
import '../../features/battle/battle_screen.dart';
import '../../features/battle/battle_game_screen.dart';
import '../../features/flashcards/flashcards_screen.dart';
import '../../features/roadmap/roadmap_screen.dart';
import '../../features/courses/courses_screen.dart';
import '../../features/courses/certificate_screen.dart';
import '../../features/dictionary/dictionary_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _buildSmoothPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Splash Route
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => _buildSmoothPage(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),

    // Onboarding Route
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _buildSmoothPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),

    // Auth route
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildSmoothPage(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),

    // Stateful Nested Shell Route for Bottom Nav Tabs (Preserves state for all tabs!)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 2: Learn
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/learn',
              builder: (context, state) => const LearnScreen(),
            ),
          ],
        ),
        // Tab 3: Battle
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/battle',
              builder: (context, state) => const BattleScreen(),
            ),
          ],
        ),
        // Tab 4: Flashcards
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cards',
              builder: (context, state) => const FlashcardsScreen(),
            ),
          ],
        ),
        // Tab 5: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Pushed Routes (Full-screen with silky smooth transition)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/topic/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? 'topic_api';
        return _buildSmoothPage(
          key: state.pageKey,
          child: TopicReaderScreen(topicId: id),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/battle/play',
      pageBuilder: (context, state) => _buildSmoothPage(
        key: state.pageKey,
        child: const BattleGameScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/roadmap',
      pageBuilder: (context, state) => _buildSmoothPage(
        key: state.pageKey,
        child: const RoadmapScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/courses',
      pageBuilder: (context, state) => _buildSmoothPage(
        key: state.pageKey,
        child: const CoursesScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/certificate/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? 'c_web_dev';
        return _buildSmoothPage(
          key: state.pageKey,
          child: CertificateScreen(courseId: id),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/dictionary',
      pageBuilder: (context, state) => _buildSmoothPage(
        key: state.pageKey,
        child: const DictionaryScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/leaderboard',
      pageBuilder: (context, state) => _buildSmoothPage(
        key: state.pageKey,
        child: const LeaderboardScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/notifications',
      pageBuilder: (context, state) => _buildSmoothPage(
        key: state.pageKey,
        child: const NotificationsScreen(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      pageBuilder: (context, state) => _buildSmoothPage(
        key: state.pageKey,
        child: const SettingsScreen(),
      ),
    ),
  ],
);
