import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import '../datasources/initial_content.dart';
import 'user_repository.dart';

final coursesProvider = Provider<List<Course>>((ref) {
  final user = ref.watch(userProfileProvider);
  final courses = InitialContent.getCourses();

  return courses.map((c) {
    int completedCount = 0;
    for (final tId in c.topicIds) {
      if (user.completedTopicIds.contains(tId)) {
        completedCount++;
      }
    }
    return c.copyWith(completedTopics: completedCount);
  }).toList();
});
