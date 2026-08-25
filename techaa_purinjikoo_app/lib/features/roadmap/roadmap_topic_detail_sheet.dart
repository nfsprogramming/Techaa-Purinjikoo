import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/career_roadmap_stage.dart';
import '../../data/repositories/user_repository.dart';

class RoadmapTopicDetailSheet extends ConsumerStatefulWidget {
  final RoadmapTopicItem topic;

  const RoadmapTopicDetailSheet({
    super.key,
    required this.topic,
  });

  static Future<void> show(BuildContext context, RoadmapTopicItem topic) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoadmapTopicDetailSheet(topic: topic),
    );
  }

  @override
  ConsumerState<RoadmapTopicDetailSheet> createState() => _RoadmapTopicDetailSheetState();
}

class _RoadmapTopicDetailSheetState extends ConsumerState<RoadmapTopicDetailSheet> {
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider);
    _isCompleted = user.completedTopicIds.contains(widget.topic.id);
  }

  void _toggleComplete() {
    ref.read(userProfileProvider.notifier).toggleTopicCompletion(widget.topic.id);
    setState(() => _isCompleted = !_isCompleted);

    if (_isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF065F46),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          content: Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFFBBF24), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '+${widget.topic.xpReward} XP earned! Marked as Learned 🎉',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.topic;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.only(top: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF090D16).withValues(alpha: 0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 36,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle Pill
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row with Title & Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                    ),
                    child: Center(
                      child: Text(t.iconEmoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.subtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Divider(color: Color(0x1FFFFFFF), height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                children: [
                  // 1. 🎭 Conversational Dialogue Box
                  _buildSectionHeader('🎭 Fun Tanglish Conversation', 'Idhu ethuku da?'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1423),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: t.dialogue.map((line) => _buildDialogueBubble(line)).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. 👀 Real World Analogy
                  _buildSectionHeader('👀 Real-World In Action', 'Everyday Relatable Example'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13182C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.visibility_rounded, color: Color(0xFF38BDF8), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.realWorldExample,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFE2E8F0),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. 🛠️ My Dev Experience
                  _buildSectionHeader('🛠️ My Dev Experience', 'Practical Developer Story'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1425),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.psychology_rounded, color: Color(0xFFA855F7), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.devExperience,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFE2E8F0),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. 🎯 Career Relevance
                  _buildSectionHeader('🎯 Career Relevance', 'Why Interviewers Ask This'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.careerRelevance,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFEF3C7),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. 🧪 Mini Mission Challenge
                  _buildSectionHeader('🧪 Try It / Mini Mission', 'Actionable Step'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF220710), Color(0xFF150409)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.flag_rounded, color: AppColors.primaryAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.missionPrompt,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF070A12),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _toggleComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCompleted ? const Color(0xFF065F46) : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(
                    _isCompleted ? Icons.check_circle_rounded : Icons.school_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    _isCompleted ? 'Completed (+${t.xpReward} XP)' : 'Mark as Learned (+${t.xpReward} XP)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '• $subtitle',
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogueBubble(DialogueLine line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: line.isTechaa ? AppColors.primary.withValues(alpha: 0.2) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: line.isTechaa ? AppColors.primary.withValues(alpha: 0.4) : Colors.transparent,
              ),
            ),
            child: Text(line.avatarEmoji, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: line.isTechaa
                    ? AppColors.primary.withValues(alpha: 0.14)
                    : const Color(0xFF141929),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: line.isTechaa
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.speaker,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: line.isTechaa ? AppColors.primaryAccent : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    line.text,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFF1F5F9),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
