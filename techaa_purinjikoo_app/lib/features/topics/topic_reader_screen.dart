import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/topic.dart';
import '../../data/repositories/topic_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../shared/widgets/interactive_pressable.dart';
import '../../shared/widgets/floating_xp_indicator.dart';
import '../../shared/widgets/celebration_dialogs.dart';

class TopicReaderScreen extends ConsumerStatefulWidget {
  final String topicId;

  const TopicReaderScreen({
    super.key,
    required this.topicId,
  });

  @override
  ConsumerState<TopicReaderScreen> createState() => _TopicReaderScreenState();
}

class _TopicReaderScreenState extends ConsumerState<TopicReaderScreen> with SingleTickerProviderStateMixin {
  String _activeTab = 'learn'; // 'learn', 'quiz', 'mistakes'
  int? _selectedOptionIndex;
  bool _isQuizSubmitted = false;
  bool _isCorrect = false;
  int? _floatingXpAmount;

  @override
  void didUpdateWidget(covariant TopicReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicId != widget.topicId) {
      setState(() {
        _activeTab = 'learn';
        _selectedOptionIndex = null;
        _isQuizSubmitted = false;
        _isCorrect = false;
      });
    }
  }

  void _triggerFloatingXp(int amount) {
    setState(() => _floatingXpAmount = amount);
  }

  void _submitQuizAnswer(int index, int correctIndex, int xpReward) {
    if (_isQuizSubmitted) return;

    final correct = index == correctIndex;
    setState(() {
      _selectedOptionIndex = index;
      _isQuizSubmitted = true;
      _isCorrect = correct;
    });

    if (correct) {
      _triggerFloatingXp(xpReward);
      final oldLevel = ref.read(userProfileProvider).level;
      ref.read(userProfileProvider.notifier).addXp(xpReward).then((_) {
        if (mounted) {
          final newLevel = ref.read(userProfileProvider).level;
          if (newLevel > oldLevel) {
            CelebrationDialogs.showLevelUp(
              context,
              newLevel: newLevel,
              newTitle: ref.read(userProfileProvider).levelTitle,
            );
          }
        }
      });
    }
  }

  Color _parseAccentColor(String? colorStr, {Color fallback = const Color(0xFF3B82F6)}) {
    if (colorStr == null || colorStr.isEmpty) return fallback;
    try {
      final hex = colorStr.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  void _handleShare(Topic topic) {
    Clipboard.setData(ClipboardData(
      text: 'Did you know? ${topic.title}: ${topic.shortDesc.isNotEmpty ? topic.shortDesc : topic.subtitle} Learn more on Techaa Purinjikoo!',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
            SizedBox(width: 10),
            Text('Copied Tech Card to Clipboard! 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTopics = ref.watch(topicsProvider);
    final topic = allTopics.firstWhere(
      (t) => t.id == widget.topicId,
      orElse: () => allTopics.isNotEmpty
          ? allTopics.first
          : const Topic(
              id: 'unknown',
              title: 'Topic Not Found',
              subtitle: '',
              category: '',
              difficulty: '',
              estimatedMinutes: 2,
              xpReward: 25,
              emoji: '❓',
              conversation: [],
              realWorldUseCases: [],
              quickSummary: '',
              quiz: [],
            ),
    );

    final currentIndex = allTopics.indexWhere((t) => t.id == widget.topicId);
    final prevTopic = currentIndex > 0 ? allTopics[currentIndex - 1] : null;
    final nextTopic = (currentIndex >= 0 && currentIndex < allTopics.length - 1) ? allTopics[currentIndex + 1] : null;

    final accentColor = _parseAccentColor(topic.accentColor);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/learn');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF94A3B8), size: 20),
            onPressed: () => _handleShare(topic),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background ambient soft light
          Positioned(
            top: -40,
            left: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Emoji Hero Badge
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1424),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.25),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      topic.emoji,
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Bold Title
                Text(
                  topic.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // 3. Uppercase Accent Tagline
                if (topic.tagline.isNotEmpty || topic.subtitle.isNotEmpty)
                  Text(
                    (topic.tagline.isNotEmpty ? topic.tagline : topic.subtitle).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                const SizedBox(height: 24),

                // 4. Navigation Segmented Tabs [ Learn | Quiz | Mistakes ]
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1526),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(
                        id: 'learn',
                        label: '📖 Learn',
                        isSelected: _activeTab == 'learn',
                      ),
                      _buildTabButton(
                        id: 'quiz',
                        label: '⏳ Quiz',
                        isSelected: _activeTab == 'quiz',
                      ),
                      _buildTabButton(
                        id: 'mistakes',
                        label: '🤫 Mistakes',
                        isSelected: _activeTab == 'mistakes',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Active Tab Content
                if (_activeTab == 'learn') _buildLearnTab(topic, accentColor),
                if (_activeTab == 'quiz') _buildQuizTab(topic),
                if (_activeTab == 'mistakes') _buildMistakesTab(topic),

                const SizedBox(height: 36),

                // 6. Next & Previous Navigation Row
                _buildNavigationRow(prevTopic, nextTopic),

                const SizedBox(height: 20),

                // 7. Footer Actions (All Topics & Share as Tech Card)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InteractivePressable(
                      onTap: () => context.go('/learn'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🗺️', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 6),
                            Text(
                              'All Topics',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InteractivePressable(
                      onTap: () => _handleShare(topic),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B4B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('📱', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 6),
                            Text(
                              'Share as a Tech Card',
                              style: TextStyle(
                                color: Color(0xFFC4B5FD),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Floating XP Indicator
          if (_floatingXpAmount != null)
            Positioned(
              top: 100,
              right: 30,
              child: FloatingXpIndicator(
                xp: _floatingXpAmount!,
                onComplete: () => setState(() => _floatingXpAmount = null),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String id,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B5CF6).withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3))
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? const Color(0xFFA78BFA) : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLearnTab(Topic topic, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Simple Ah Solluvom Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1322),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('⚡', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Simple Ah Solluvom',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                topic.quickSummary.isNotEmpty
                    ? topic.quickSummary
                    : (topic.shortDesc.isNotEmpty ? topic.shortDesc : topic.subtitle),
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.65,
                  color: Color(0xFFCBD5E1),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Real Life Analogy Card
        if (topic.analogy != null) ...[
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E1B4B).withValues(alpha: 0.3),
                  const Color(0xFF083344).withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🎭', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Real Life Analogy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  topic.analogy!.description,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.65,
                    color: Color(0xFFF1F5F9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (topic.analogy!.visualNodes.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070B14).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: topic.analogy!.visualNodes.map((v) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(v.icon, style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 6),
                            Text(
                              v.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],

        // 3. Developer Conversation (Terminal Window Style)
        if (topic.conversation.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF080D1A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // macOS Traffic Lights Header
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 16),

                // Conversation dialogue items
                ...topic.conversation.map((msg) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.avatarEmoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 13.5, height: 1.5),
                              children: [
                                TextSpan(
                                  text: '${msg.speakerName}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFA78BFA),
                                  ),
                                ),
                                TextSpan(
                                  text: msg.text,
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuizTab(Topic topic) {
    if (topic.quiz.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1322),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: const Center(
          child: Text(
            'Intha topic-ku quiz innum upload panla bro! 😅',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
          ),
        ),
      );
    }

    final quizQuestion = topic.quiz.first;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1322),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Concept Purinjithaa nu check pannuvom!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            quizQuestion.question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE2E8F0),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Options List
          ...quizQuestion.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final optionText = entry.value;
            final isSelected = _selectedOptionIndex == idx;
            final isCorrectOption = idx == quizQuestion.correctIndex;

            Color backgroundColor = const Color(0xFF080D1A);
            Color borderColor = Colors.white.withValues(alpha: 0.08);

            if (_isQuizSubmitted) {
              if (isCorrectOption) {
                backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.15);
                borderColor = const Color(0xFF10B981);
              } else if (isSelected) {
                backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
                borderColor = const Color(0xFFEF4444);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InteractivePressable(
                onTap: _isQuizSubmitted ? null : () => _submitQuizAnswer(idx, quizQuestion.correctIndex, topic.xpReward),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? (_isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                              : Colors.white.withValues(alpha: 0.05),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + idx),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          optionText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Feedback Banner
          if (_isQuizSubmitted) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                    : const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCorrect
                      ? const Color(0xFF10B981).withValues(alpha: 0.4)
                      : const Color(0xFFEF4444).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: _isCorrect ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isCorrect
                          ? 'Semma! Correct-ah sollita 🔥 (+${topic.xpReward} XP)'
                          : 'Illa bro, oru vaati munaadi poi marubadiyum padi! 😅',
                      style: TextStyle(
                        color: _isCorrect ? const Color(0xFF34D399) : const Color(0xFFFCA5A5),
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMistakesTab(Topic topic) {
    final confession = topic.devConfession;
    if (confession == null || (confession.mistake.isEmpty && confession.lesson.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1322),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: const Center(
          child: Text(
            'No confessions for this topic yet!',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Developer Mistake Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🛑', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Developer Mistake',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF87171),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '"${confession.mistake}"',
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: Color(0xFFFCA5A5),
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Lesson Learned Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Lesson Learned',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4ADE80),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                confession.lesson,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: Color(0xFF86EFAC),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationRow(Topic? prevTopic, Topic? nextTopic) {
    return Column(
      children: [
        if (prevTopic != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InteractivePressable(
              onTap: () => context.go('/topic/${prevTopic.id}'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1322),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '← PREVIOUS TOPIC',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${prevTopic.emoji} ${prevTopic.title}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (nextTopic != null)
          InteractivePressable(
            onTap: () => context.go('/topic/${nextTopic.id}'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'NEXT TOPIC →',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFC4B5FD),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${nextTopic.title} ${nextTopic.emoji}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
