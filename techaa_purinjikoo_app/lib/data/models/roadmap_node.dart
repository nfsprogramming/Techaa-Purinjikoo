enum NodeStatus { completed, current, locked }

class RoadmapNode {
  final String id;
  final String title;
  final String category;
  final String description;
  final String iconEmoji;
  final NodeStatus status;
  final String? topicId;
  final int stepNumber;

  const RoadmapNode({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.iconEmoji,
    required this.status,
    this.topicId,
    required this.stepNumber,
  });

  RoadmapNode copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? iconEmoji,
    NodeStatus? status,
    String? topicId,
    int? stepNumber,
  }) {
    return RoadmapNode(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      status: status ?? this.status,
      topicId: topicId ?? this.topicId,
      stepNumber: stepNumber ?? this.stepNumber,
    );
  }
}
