enum MasteryLevel { none, again, hard, good, easy }

class Flashcard {
  final String id;
  final String term;
  final String category;
  final String explanation;
  final String analogy;
  final MasteryLevel mastery;

  const Flashcard({
    required this.id,
    required this.term,
    required this.category,
    required this.explanation,
    required this.analogy,
    this.mastery = MasteryLevel.none,
  });

  String get definition => explanation;

  Flashcard copyWith({
    String? id,
    String? term,
    String? category,
    String? explanation,
    String? analogy,
    MasteryLevel? mastery,
  }) {
    return Flashcard(
      id: id ?? this.id,
      term: term ?? this.term,
      category: category ?? this.category,
      explanation: explanation ?? this.explanation,
      analogy: analogy ?? this.analogy,
      mastery: mastery ?? this.mastery,
    );
  }
}
