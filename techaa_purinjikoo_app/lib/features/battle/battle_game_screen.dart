import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/quiz_question.dart';
import '../../data/repositories/user_repository.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/shake_widget.dart';
import '../../shared/widgets/animated_counter.dart';
import '../../shared/widgets/celebration_dialogs.dart';

class BattleGameScreen extends ConsumerStatefulWidget {
  const BattleGameScreen({super.key});

  @override
  ConsumerState<BattleGameScreen> createState() => _BattleGameScreenState();
}

class _BattleGameScreenState extends ConsumerState<BattleGameScreen> {
  final List<QuizQuestion> questions = const [
    QuizQuestion(
      id: 'bq1',
      question: 'Which HTTP status code signifies "Not Found"?',
      options: ['200 OK', '404 Not Found', '500 Server Error', '301 Moved'],
      correctIndex: 1,
      explanation: '404 is the client error response code indicating the server cannot find the requested resource.',
    ),
    QuizQuestion(
      id: 'bq2',
      question: 'In Git, which command creates and switches to a new branch?',
      options: ['git branch new', 'git checkout -b <name>', 'git push origin', 'git switch -d'],
      correctIndex: 1,
      explanation: 'git checkout -b creates a new branch and checks it out immediately.',
    ),
    QuizQuestion(
      id: 'bq3',
      question: 'What is the default port for HTTP traffic?',
      options: ['22', '80', '443', '8080'],
      correctIndex: 1,
      explanation: 'HTTP default port is 80 (HTTPS is 443).',
    ),
    QuizQuestion(
      id: 'bq4',
      question: 'Which data structure does a JavaScript Object most resemble?',
      options: ['Stack', 'Key-Value Hash Map', 'Binary Tree', 'Queue'],
      correctIndex: 1,
      explanation: 'JS Objects are key-value pairs stored like hash maps.',
    ),
    QuizQuestion(
      id: 'bq5',
      question: 'What does CSS stand for?',
      options: ['Cascading Style Sheets', 'Creative Style Software', 'Computer Screen Styling', 'Control System Styles'],
      correctIndex: 0,
      explanation: 'CSS stands for Cascading Style Sheets.',
    ),
  ];

  int currentQuestionIndex = 0;
  int score = 0;
  int streak = 0;
  int secondsRemaining = 45;
  Timer? _timer;
  int? selectedOption;
  bool isGameOver = false;
  bool shouldShakeWrongAnswer = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    final earnedXp = score * 10 + 20;
    final oldLevel = ref.read(userProfileProvider).level;
    ref.read(userProfileProvider.notifier).addXp(earnedXp).then((_) {
      final newLevel = ref.read(userProfileProvider).level;
      if (newLevel > oldLevel && mounted) {
        CelebrationDialogs.showLevelUp(
          context,
          newLevel: newLevel,
          newTitle: ref.read(userProfileProvider).levelTitle,
        );
      }
    });
    setState(() => isGameOver = true);
  }

  void _answerQuestion(int index) {
    if (selectedOption != null || isGameOver) return;

    final currentQ = questions[currentQuestionIndex];
    final isCorrect = index == currentQ.correctIndex;

    setState(() {
      selectedOption = index;
      shouldShakeWrongAnswer = !isCorrect;
    });

    if (isCorrect) {
      score++;
      streak++;
    } else {
      streak = 0;
    }

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedOption = null;
          shouldShakeWrongAnswer = false;
        });
      } else {
        _endGame();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isGameOver) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  'Battle Complete!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Score: ', style: TextStyle(fontSize: 18, color: AppColors.onSurfaceVariant)),
                    AnimatedCounter(
                      count: score,
                      suffix: ' / ${questions.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomCard(
                  hasGlow: true,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('XP Earned', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                          const SizedBox(height: 4),
                          AnimatedCounter(
                            count: score * 10 + 20,
                            prefix: '+',
                            suffix: ' XP',
                            style: const TextStyle(
                              color: AppColors.xpViolet,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 40, color: AppColors.borderMuted),
                      Column(
                        children: [
                          const Text('Accuracy', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                          const SizedBox(height: 4),
                          AnimatedCounter(
                            count: ((score / questions.length) * 100).toInt(),
                            suffix: '%',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.pop(),
                    child: const Text('Back to Battles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQ = questions[currentQuestionIndex];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Stats Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: secondsRemaining <= 10 ? Colors.redAccent : AppColors.borderMuted,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 18,
                          color: secondsRemaining <= 10 ? Colors.redAccent : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${secondsRemaining}s',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: secondsRemaining <= 10 ? Colors.redAccent : AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress indicator
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Question ${currentQuestionIndex + 1} / ${questions.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 24),

              // Question Card with Shake
              Expanded(
                child: ShakeWidget(
                  shake: shouldShakeWrongAnswer,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomCard(
                        padding: const EdgeInsets.all(22),
                        child: Text(
                          currentQ.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(currentQ.options.length, (idx) {
                        final option = currentQ.options[idx];
                        final isSelected = selectedOption == idx;
                        final isCorrect = idx == currentQ.correctIndex;

                        Color btnColor = AppColors.surfaceContainerLow;
                        Color borderColor = AppColors.borderMuted;

                        if (selectedOption != null) {
                          if (isCorrect) {
                            btnColor = AppColors.success.withValues(alpha: 0.2);
                            borderColor = AppColors.success;
                          } else if (isSelected) {
                            btnColor = Colors.redAccent.withValues(alpha: 0.2);
                            borderColor = Colors.redAccent;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () => _answerQuestion(idx),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: btnColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor, width: 1.2),
                              ),
                              child: Text(
                                option,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
