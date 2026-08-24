import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/roadmap_node.dart';
import '../datasources/initial_content.dart';
import 'user_repository.dart';

final roadmapProvider = Provider<List<RoadmapNode>>((ref) {
  final user = ref.watch(userProfileProvider);
  final nodes = InitialContent.getRoadmap();

  return nodes.map((node) {
    if (node.topicId != null && user.completedTopicIds.contains(node.topicId)) {
      return node.copyWith(status: NodeStatus.completed);
    }
    // If previous step is completed, mark current as current
    if (node.stepNumber == 1 && !user.completedTopicIds.contains(node.topicId)) {
      return node.copyWith(status: NodeStatus.current);
    }
    return node;
  }).toList();
});
