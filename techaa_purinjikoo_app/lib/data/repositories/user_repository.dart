import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_logger.dart';
import '../models/user_profile.dart';
import '../models/badge_item.dart';
import '../datasources/initial_content.dart';
import '../services/achievement_service.dart';
import 'auth_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

class UserRepository extends Notifier<UserProfile> {
  SharedPreferences? get _prefs => ref.read(sharedPreferencesProvider);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _firestoreSub;

  @override
  UserProfile build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final authSession = ref.watch(authRepositoryProvider);

    final nameFromAuth = authSession?.displayName;
    final defaultName = (nameFromAuth != null && nameFromAuth.isNotEmpty)
        ? nameFromAuth
        : 'Tech Scholar';
    final defaultEmail = authSession?.email ?? '';
    final defaultAvatar = authSession?.photoUrl ?? '';

    // Cancel any previous Firestore listener on auth changes
    ref.onDispose(() {
      _firestoreSub?.cancel();
    });

    // Start real-time Firestore sync if user is authenticated
    if (authSession != null && authSession.id.isNotEmpty) {
      _setupFirestoreSync(authSession.id);
    }

    if (prefs == null) {
      return UserProfile(
        name: defaultName,
        email: defaultEmail,
        avatarUrl: defaultAvatar,
        xp: 0,
        level: 1,
        levelTitle: 'Beginner',
        streakDays: 1,
        rank: 1,
        completedTopicIds: const [],
        unlockedBadgeIds: const [],
        completedCourseIds: const [],
        isDailyChallengeDone: false,
      );
    }

    final xp = prefs.getInt(AppConstants.keyUserXp) ?? 0;
    final level = prefs.getInt(AppConstants.keyUserLevel) ?? 1;
    final streak = prefs.getInt(AppConstants.keyUserStreak) ?? 1;
    final completedTopics = prefs.getStringList(AppConstants.keyCompletedTopics) ?? [];
    final unlockedBadges = prefs.getStringList(AppConstants.keyUnlockedBadges) ?? [];
    final completedCourses = prefs.getStringList(AppConstants.keyCompletedCourses) ?? [];
    final isDailyDone = prefs.getBool(AppConstants.keyDailyChallengeDone) ?? false;

    return UserProfile(
      name: defaultName,
      email: defaultEmail,
      avatarUrl: defaultAvatar,
      xp: xp,
      level: level,
      levelTitle: _getLevelTitle(level),
      streakDays: streak,
      rank: 1,
      completedTopicIds: completedTopics,
      unlockedBadgeIds: unlockedBadges,
      completedCourseIds: completedCourses,
      isDailyChallengeDone: isDailyDone,
    );
  }

  void _setupFirestoreSync(String uid) {
    _firestoreSub?.cancel();
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

      _firestoreSub = docRef.snapshots().listen((snapshot) {
        if (!snapshot.exists) {
          // Document does not exist yet, push initial state to Firestore
          _pushToFirestore(uid, state);
          return;
        }

        final data = snapshot.data();
        if (data == null) return;

        _mergeCloudData(data);
      }, onError: (err) {
        AppLogger.w('Firestore sync listener notice: $err');
      });
    } catch (e) {
      AppLogger.w('Could not initialize Firestore sync: $e');
    }
  }

  void _mergeCloudData(Map<String, dynamic> data) {
    try {
      final progressMap = data['progress'] is Map<String, dynamic>
          ? data['progress'] as Map<String, dynamic>
          : null;

      final cloudTopicsRaw = (progressMap?['completedTopics'] ?? data['completedTopics']) as List<dynamic>?;
      final cloudBadgesRaw = (progressMap?['unlockedBadges'] ?? data['unlockedBadges']) as List<dynamic>?;

      final cloudTopics = cloudTopicsRaw != null
          ? cloudTopicsRaw.map((e) => e.toString()).toList()
          : <String>[];
      final cloudBadges = cloudBadgesRaw != null
          ? cloudBadgesRaw.map((e) => e.toString()).toList()
          : <String>[];

      final cloudXp = (progressMap?['xp'] ?? data['xp'] ?? 0) as num;
      final cloudStreak = (progressMap?['streak'] ?? data['streak'] ?? 1) as num;
      final cloudLevel = (progressMap?['level'] ?? data['level'] ?? 1) as num;

      // Merge local with cloud (taking super-set of completed topics and max XP)
      final mergedTopics = <String>{...state.completedTopicIds, ...cloudTopics}.toList();
      final mergedBadges = <String>{...state.unlockedBadgeIds, ...cloudBadges}.toList();
      final mergedXp = (state.xp > cloudXp.toInt()) ? state.xp : cloudXp.toInt();
      final mergedLevel = (state.level > cloudLevel.toInt()) ? state.level : cloudLevel.toInt();
      final mergedStreak = (state.streakDays > cloudStreak.toInt()) ? state.streakDays : cloudStreak.toInt();

      final updatedProfile = state.copyWith(
        xp: mergedXp,
        level: mergedLevel,
        levelTitle: _getLevelTitle(mergedLevel),
        streakDays: mergedStreak,
        completedTopicIds: mergedTopics,
        unlockedBadgeIds: mergedBadges,
      );

      state = updatedProfile;

      // Persist merged data to local cache
      if (_prefs != null) {
        _prefs!.setInt(AppConstants.keyUserXp, mergedXp);
        _prefs!.setInt(AppConstants.keyUserLevel, mergedLevel);
        _prefs!.setInt(AppConstants.keyUserStreak, mergedStreak);
        _prefs!.setStringList(AppConstants.keyCompletedTopics, mergedTopics);
        _prefs!.setStringList(AppConstants.keyUnlockedBadges, mergedBadges);
      }
    } catch (e) {
      AppLogger.w('Error merging cloud data: $e');
    }
  }

  Future<void> _pushToFirestore(String uid, UserProfile profile) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final payload = {
        'progress': {
          'completedTopics': profile.completedTopicIds,
          'unlockedBadges': profile.unlockedBadgeIds,
          'xp': profile.xp,
          'level': profile.level,
          'streak': profile.streakDays,
          'lastLogin': DateTime.now().toIso8601String().split('T').first,
        },
        'completedTopics': profile.completedTopicIds,
        'unlockedBadges': profile.unlockedBadgeIds,
        'xp': profile.xp,
        'level': profile.level,
        'streak': profile.streakDays,
        'displayName': profile.name,
        'email': profile.email,
        'photoURL': profile.avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(payload, SetOptions(merge: true));
    } catch (e) {
      AppLogger.w('Could not push progress to Firestore: $e');
    }
  }

  String _getLevelTitle(int level) {
    if (level >= 5) return 'Tech Architect';
    if (level >= 4) return 'Tech Explorer';
    if (level >= 2) return 'Curious Coder';
    return 'Beginner';
  }

  Future<void> addXp(int gainedXp) async {
    final newXp = state.xp + gainedXp;
    final newLevel = (newXp / 500).floor() + 1;
    final newTitle = _getLevelTitle(newLevel);

    state = state.copyWith(
      xp: newXp,
      level: newLevel,
      levelTitle: newTitle,
    );

    if (_prefs != null) {
      await _prefs!.setInt(AppConstants.keyUserXp, newXp);
      await _prefs!.setInt(AppConstants.keyUserLevel, newLevel);
    }

    final authSession = ref.read(authRepositoryProvider);
    if (authSession != null && authSession.id.isNotEmpty) {
      _pushToFirestore(authSession.id, state);
    }

    _evaluateBadges();
  }

  Future<void> completeTopic(String topicId, int xpReward) async {
    if (state.completedTopicIds.contains(topicId)) return;

    final updatedTopics = [...state.completedTopicIds, topicId];
    await addXp(xpReward);

    state = state.copyWith(completedTopicIds: updatedTopics);
    if (_prefs != null) {
      await _prefs!.setStringList(AppConstants.keyCompletedTopics, updatedTopics);
    }

    final authSession = ref.read(authRepositoryProvider);
    if (authSession != null && authSession.id.isNotEmpty) {
      _pushToFirestore(authSession.id, state);
    }

    _evaluateBadges();
  }

  Future<void> toggleTopicCompletion(String topicId, {int xpReward = 50}) async {
    if (state.completedTopicIds.contains(topicId)) {
      final updatedTopics = state.completedTopicIds.where((id) => id != topicId).toList();
      state = state.copyWith(completedTopicIds: updatedTopics);
      if (_prefs != null) {
        await _prefs!.setStringList(AppConstants.keyCompletedTopics, updatedTopics);
      }
      final authSession = ref.read(authRepositoryProvider);
      if (authSession != null && authSession.id.isNotEmpty) {
        _pushToFirestore(authSession.id, state);
      }
    } else {
      await completeTopic(topicId, xpReward);
    }
  }

  void _evaluateBadges() {
    final allBadges = InitialContent.getBadges();
    final result = AchievementService.evaluateAchievements(
      profile: state,
      allBadges: allBadges,
    );

    if (result.newlyUnlockedBadges.isNotEmpty) {
      final updatedBadgeIds = [
        ...state.unlockedBadgeIds,
        ...result.newlyUnlockedBadges.map((b) => b.id),
      ];
      state = state.copyWith(
        unlockedBadgeIds: updatedBadgeIds,
        xp: state.xp + result.bonusXp,
      );
      if (_prefs != null) {
        _prefs!.setStringList(AppConstants.keyUnlockedBadges, updatedBadgeIds);
        _prefs!.setInt(AppConstants.keyUserXp, state.xp);
      }

      final authSession = ref.read(authRepositoryProvider);
      if (authSession != null && authSession.id.isNotEmpty) {
        _pushToFirestore(authSession.id, state);
      }
    }
  }

  Future<void> resetProgress() async {
    if (_prefs != null) {
      await _prefs!.remove(AppConstants.keyUserXp);
      await _prefs!.remove(AppConstants.keyUserLevel);
      await _prefs!.remove(AppConstants.keyUserStreak);
      await _prefs!.remove(AppConstants.keyCompletedTopics);
      await _prefs!.remove(AppConstants.keyUnlockedBadges);
      await _prefs!.remove(AppConstants.keyCompletedCourses);
    }
    state = const UserProfile();

    final authSession = ref.read(authRepositoryProvider);
    if (authSession != null && authSession.id.isNotEmpty) {
      _pushToFirestore(authSession.id, state);
    }
  }
}

final userProfileProvider = NotifierProvider<UserRepository, UserProfile>(UserRepository.new);

final badgesListProvider = Provider<List<BadgeItem>>((ref) {
  final allBadges = InitialContent.getBadges();
  final unlockedIds = ref.watch(userProfileProvider).unlockedBadgeIds;

  return allBadges.map((badge) {
    return badge.copyWith(unlocked: unlockedIds.contains(badge.id));
  }).toList();
});
