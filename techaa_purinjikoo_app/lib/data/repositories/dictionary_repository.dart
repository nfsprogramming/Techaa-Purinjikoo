import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dictionary_term.dart';
import '../datasources/initial_content.dart';

class DictionarySearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final dictionarySearchProvider = NotifierProvider<DictionarySearchNotifier, String>(DictionarySearchNotifier.new);

final dictionaryListProvider = Provider<List<DictionaryTerm>>((ref) {
  final allTerms = InitialContent.getDictionary();
  final query = ref.watch(dictionarySearchProvider).toLowerCase();

  if (query.isEmpty) return allTerms;

  return allTerms.where((term) {
    return term.term.toLowerCase().contains(query) ||
        term.definition.toLowerCase().contains(query) ||
        term.simpleAnalogy.toLowerCase().contains(query) ||
        term.category.toLowerCase().contains(query);
  }).toList();
});
