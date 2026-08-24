class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int xpReward;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.xpReward = 10,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json, [String topicId = '']) {
    final opts = (json['options'] as List<dynamic>?)
            ?.map((o) => o.toString())
            .toList() ??
        const [];

    int ans = json['answer'] ?? json['correctIndex'] ?? 0;
    // If answer is 1-indexed in some data, adjust if it's out of 0-based range
    if (ans >= opts.length && ans > 0) {
      ans = ans - 1;
    }

    return QuizQuestion(
      id: json['id'] ?? 'quiz_$topicId',
      question: json['question'] ?? 'What did you understand from this topic?',
      options: opts,
      correctIndex: ans.clamp(0, opts.isNotEmpty ? opts.length - 1 : 0),
      explanation: json['explanation'] ?? 'Great job understanding the core practical concept!',
      xpReward: json['xpReward'] ?? 10,
    );
  }
}
