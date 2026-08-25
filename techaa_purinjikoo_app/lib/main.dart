import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'data/repositories/user_repository.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  final notifService = NotificationService();
  await notifService.init();
  await notifService.requestPermissions();
  await notifService.scheduleDailyGuiltTripNotification();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  try {
    await Supabase.initialize(
      url: 'https://ztjzwplikwhdnwmvrnej.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0anp3cGxpa3doZG53bXZybmVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc1NzYzNTUsImV4cCI6MjEwMzE1MjM1NX0.9ksmSqJLzd8rARz5r0SPfi5Vxigh6999r889MJTZNOk',
    );
  } catch (e) {
    debugPrint('Supabase initialization notice: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const TechaaPurinjikooApp(),
    ),
  );
}

class TechaaPurinjikooApp extends ConsumerWidget {
  const TechaaPurinjikooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final bool isCyberpunk = user.xp > 1000;

    return MaterialApp.router(
      title: 'Techaa Purinjikoo',
      debugShowCheckedModeBanner: false,
      theme: isCyberpunk ? AppTheme.cyberpunkTheme : AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
