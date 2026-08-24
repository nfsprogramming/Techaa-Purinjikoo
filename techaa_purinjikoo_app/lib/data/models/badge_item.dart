class BadgeItem {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final String requirement;
  final bool unlocked;
  final DateTime? unlockedAt;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.requirement,
    this.unlocked = false,
    this.unlockedAt,
  });

  BadgeItem copyWith({
    String? id,
    String? title,
    String? description,
    String? iconEmoji,
    String? requirement,
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return BadgeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      requirement: requirement ?? this.requirement,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
