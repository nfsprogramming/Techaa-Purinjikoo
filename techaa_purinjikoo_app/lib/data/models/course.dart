class Course {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int totalTopics;
  final int completedTopics;
  final int estimatedHours;
  final String iconEmoji;
  final List<String> topicIds;
  final bool hasCertificate;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.totalTopics,
    this.completedTopics = 0,
    required this.estimatedHours,
    required this.iconEmoji,
    required this.topicIds,
    this.hasCertificate = true,
  });

  double get progress => totalTopics > 0 ? completedTopics / totalTopics : 0.0;
  bool get isCompleted => totalTopics > 0 && completedTopics >= totalTopics;

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    int? totalTopics,
    int? completedTopics,
    int? estimatedHours,
    String? iconEmoji,
    List<String>? topicIds,
    bool? hasCertificate,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      totalTopics: totalTopics ?? this.totalTopics,
      completedTopics: completedTopics ?? this.completedTopics,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      topicIds: topicIds ?? this.topicIds,
      hasCertificate: hasCertificate ?? this.hasCertificate,
    );
  }
}
