import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic.dart';
import '../datasources/initial_content.dart';
import 'user_repository.dart';

class TopicRepository extends Notifier<List<Topic>> {
  @override
  List<Topic> build() {
    return InitialContent.getTopics();
  }

  void toggleTopicCompleted(String id) {
    state = [
      for (final topic in state)
        if (topic.id == id)
          topic.copyWith(isCompleted: !topic.isCompleted)
        else
          topic,
    ];
  }
}

final topicsProvider = NotifierProvider<TopicRepository, List<Topic>>(TopicRepository.new);

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setCategory(String category) => state = category;
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String>(SelectedCategoryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final filteredTopicsProvider = Provider<List<Topic>>((ref) {
  final topics = ref.watch(topicsProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final user = ref.watch(userProfileProvider);

  return topics.where((topic) {
    final matchesCategory = category == 'All' || topic.category.toLowerCase() == category.toLowerCase();
    final matchesQuery = query.isEmpty ||
        topic.title.toLowerCase().contains(query) ||
        topic.subtitle.toLowerCase().contains(query) ||
        topic.category.toLowerCase().contains(query);
    return matchesCategory && matchesQuery;
  }).map((t) {
    final isDone = user.completedTopicIds.contains(t.id);
    return t.copyWith(isCompleted: isDone);
  }).toList();
});

final topicByIdProvider = Provider.family<Topic?, String>((ref, id) {
  final topics = ref.watch(filteredTopicsProvider);
  try {
    return topics.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
});
