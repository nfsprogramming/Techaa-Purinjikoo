class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;
  final int level;
  final String levelTitle;
  final int xp;
  final int streakDays;
  final int rank;
  final List<String> completedTopicIds;
  final List<String> completedCourseIds;
  final List<String> unlockedBadgeIds;
  final int dailyChallengeDate; // e.g. YYYYMMDD
  final bool isDailyChallengeDone;

  const UserProfile({
    this.name = 'Scholar',
    this.email = '',
    this.avatarUrl = '',
    this.level = 1,
    this.levelTitle = 'Beginner',
    this.xp = 0,
    this.streakDays = 1,
    this.rank = 1,
    this.completedTopicIds = const [],
    this.completedCourseIds = const [],
    this.unlockedBadgeIds = const [],
    this.dailyChallengeDate = 20260824,
    this.isDailyChallengeDone = false,
  });

  // Calculate level progress (each level is 500 XP)
  int get currentLevelBaseXp => (level - 1) * 500;
  int get nextLevelXp => level * 500;
  int get xpInCurrentLevel => (xp - currentLevelBaseXp).clamp(0, 500);
  double get levelProgress => (xpInCurrentLevel / 500.0).clamp(0.0, 1.0);

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? level,
    String? levelTitle,
    int? xp,
    int? streakDays,
    int? rank,
    List<String>? completedTopicIds,
    List<String>? completedCourseIds,
    List<String>? unlockedBadgeIds,
    int? dailyChallengeDate,
    bool? isDailyChallengeDone,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      rank: rank ?? this.rank,
      completedTopicIds: completedTopicIds ?? this.completedTopicIds,
      completedCourseIds: completedCourseIds ?? this.completedCourseIds,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      dailyChallengeDate: dailyChallengeDate ?? this.dailyChallengeDate,
      isDailyChallengeDone: isDailyChallengeDone ?? this.isDailyChallengeDone,
    );
  }
}
