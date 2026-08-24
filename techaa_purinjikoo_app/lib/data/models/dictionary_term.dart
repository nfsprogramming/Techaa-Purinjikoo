class DictionaryTerm {
  final String id;
  final String term;
  final String definition;
  final String emoji;
  final String simpleAnalogy;
  final String category;
  final String? relatedTopicId;

  const DictionaryTerm({
    required this.id,
    required this.term,
    required this.definition,
    this.emoji = '📖',
    this.simpleAnalogy = '',
    this.category = 'General',
    this.relatedTopicId,
  });

  factory DictionaryTerm.fromJson(Map<String, dynamic> json, [int index = 0]) {
    return DictionaryTerm(
      id: json['id'] ?? 'term_${json['term']?.toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_') ?? index}',
      term: json['term'] ?? '',
      definition: json['definition'] ?? '',
      emoji: json['emoji'] ?? '📖',
      simpleAnalogy: json['simpleAnalogy'] ?? '',
      category: json['category'] ?? 'General',
      relatedTopicId: json['relatedTopicId'],
    );
  }
}
