import 'chat_message.dart';
import 'quiz_question.dart';
import 'analogy_data.dart';

class DevConfession {
  final String mistake;
  final String lesson;

  const DevConfession({required this.mistake, required this.lesson});

  factory DevConfession.fromJson(Map<String, dynamic> json) {
    return DevConfession(
      mistake: json['mistake'] ?? '',
      lesson: json['lesson'] ?? '',
    );
  }
}

class Topic {
  final String id;
  final String title;
  final String subtitle;
  final String shortDesc;
  final String questionCard;
  final String accentColor;
  final String tagline;
  final int level;
  final String readTime;
  final String category;
  final String difficulty;
  final int estimatedMinutes;
  final int xpReward;
  final String emoji;
  final List<ChatMessage> conversation;
  final AnalogyData? analogy;
  final List<String> realWorldUseCases;
  final String quickSummary;
  final List<QuizQuestion> quiz;
  final DevConfession? devConfession;
  final String funFact;
  final bool isCompleted;

  const Topic({
    required this.id,
    required this.title,
    required this.subtitle,
    this.shortDesc = '',
    this.questionCard = '',
    this.accentColor = '#3b82f6',
    this.tagline = '',
    this.level = 1,
    this.readTime = '2 min',
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.emoji,
    required this.conversation,
    this.analogy,
    required this.realWorldUseCases,
    required this.quickSummary,
    required this.quiz,
    this.devConfession,
    this.funFact = '',
    this.isCompleted = false,
  });

  static String getCategoryForLevel(int level) {
    switch (level) {
      case 1:
        return 'Internet Basics';
      case 2:
        return 'Web Development';
      case 3:
        return 'Database Systems';
      case 4:
        return 'Cloud Architecture';
      case 5:
        return 'Modern DevTools';
      case 6:
        return 'Cyber Security';
      case 7:
        return 'AI & Innovation';
      default:
        return 'Technology';
    }
  }

  static String getDifficultyForLevel(int level) {
    if (level <= 2) return 'Beginner';
    if (level <= 5) return 'Intermediate';
    return 'Advanced';
  }

  factory Topic.fromJson(Map<String, dynamic> json) {
    final topicId = json['id'] ?? '';
    final level = json['level'] ?? 1;
    final category = json['category'] ?? getCategoryForLevel(level);
    final difficulty = json['difficulty'] ?? getDifficultyForLevel(level);

    final convJson = json['conversation'] as List<dynamic>? ?? [];
    final conv = <ChatMessage>[];
    for (int i = 0; i < convJson.length; i++) {
      conv.add(ChatMessage.fromJson(convJson[i] as Map<String, dynamic>, i));
    }

    AnalogyData? analogy;
    if (json['analogy'] != null) {
      analogy = AnalogyData.fromJson(json['analogy'] as Map<String, dynamic>);
    }

    final quizList = <QuizQuestion>[];
    if (json['quiz'] != null) {
      if (json['quiz'] is Map<String, dynamic>) {
        quizList.add(QuizQuestion.fromJson(json['quiz'] as Map<String, dynamic>, topicId));
      } else if (json['quiz'] is List<dynamic>) {
        for (final q in json['quiz'] as List<dynamic>) {
          quizList.add(QuizQuestion.fromJson(q as Map<String, dynamic>, topicId));
        }
      }
    }

    final whenToUse = (json['whenToUse'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    DevConfession? confession;
    if (json['devConfession'] != null) {
      confession = DevConfession.fromJson(json['devConfession'] as Map<String, dynamic>);
    }

    final minutes = int.tryParse((json['readTime'] ?? '2 min').toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 3;

    return Topic(
      id: topicId,
      title: json['title'] ?? '',
      subtitle: json['shortDesc'] ?? json['questionCard'] ?? '',
      shortDesc: json['shortDesc'] ?? '',
      questionCard: json['questionCard'] ?? '',
      accentColor: json['accentColor'] ?? '#3b82f6',
      tagline: json['tagline'] ?? '',
      level: level,
      readTime: json['readTime'] ?? '$minutes min',
      category: category,
      difficulty: difficulty,
      estimatedMinutes: minutes,
      xpReward: json['xpReward'] ?? 10,
      emoji: json['emoji'] ?? '💡',
      conversation: conv,
      analogy: analogy,
      realWorldUseCases: whenToUse,
      quickSummary: json['quickSummary'] ?? '',
      quiz: quizList,
      devConfession: confession,
      funFact: json['funFact'] ?? '',
      isCompleted: false,
    );
  }

  Topic copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? shortDesc,
    String? questionCard,
    String? accentColor,
    String? tagline,
    int? level,
    String? readTime,
    String? category,
    String? difficulty,
    int? estimatedMinutes,
    int? xpReward,
    String? emoji,
    List<ChatMessage>? conversation,
    AnalogyData? analogy,
    List<String>? realWorldUseCases,
    String? quickSummary,
    List<QuizQuestion>? quiz,
    DevConfession? devConfession,
    String? funFact,
    bool? isCompleted,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      shortDesc: shortDesc ?? this.shortDesc,
      questionCard: questionCard ?? this.questionCard,
      accentColor: accentColor ?? this.accentColor,
      tagline: tagline ?? this.tagline,
      level: level ?? this.level,
      readTime: readTime ?? this.readTime,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      xpReward: xpReward ?? this.xpReward,
      emoji: emoji ?? this.emoji,
      conversation: conversation ?? this.conversation,
      analogy: analogy ?? this.analogy,
      realWorldUseCases: realWorldUseCases ?? this.realWorldUseCases,
      quickSummary: quickSummary ?? this.quickSummary,
      quiz: quiz ?? this.quiz,
      devConfession: devConfession ?? this.devConfession,
      funFact: funFact ?? this.funFact,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
