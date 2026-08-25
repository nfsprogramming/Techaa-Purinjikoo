import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/interview_scenarios_data.dart';
import '../../../data/repositories/user_repository.dart';

class InterviewSimulatorSheet extends ConsumerStatefulWidget {
  const InterviewSimulatorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InterviewSimulatorSheet(),
    );
  }

  @override
  ConsumerState<InterviewSimulatorSheet> createState() => _InterviewSimulatorSheetState();
}

class _InterviewSimulatorSheetState extends ConsumerState<InterviewSimulatorSheet> {
  final List<InterviewScenario> _scenarios = InterviewScenariosData.getScenarios();
  int _currentIndex = 0;
  int? _selectedChoiceIndex;
  bool _answered = false;
  int _score = 0;

  void _selectChoice(int index) {
    if (_answered) return;
    final scenario = _scenarios[_currentIndex];
    final choice = scenario.choices[index];

    setState(() {
      _selectedChoiceIndex = index;
      _answered = true;
      if (choice.isCorrect) {
        _score++;
        ref.read(userProfileProvider.notifier).addXp(scenario.xpReward);
      }
    });
  }

  void _nextScenario() {
    if (_currentIndex < _scenarios.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedChoiceIndex = null;
        _answered = false;
      });
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          content: Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '🎉 Interview Simulation Complete! Score: $_score/${_scenarios.length}. Gained ${_score * 30} XP!',
                  style: const TextStyle(fontWeight: FontWeight.w700),
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
    final scenario = _scenarios[_currentIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0F1423),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.record_voice_over_rounded, color: Color(0xFFA855F7), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎭 Tech Interview Simulator',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Scenario ${_currentIndex + 1} of ${_scenarios.length} • +30 XP per win',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0x1AFFFFFF), height: 20),

          // Question Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    scenario.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF38BDF8),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Question Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFFA855F7),
                            child: Text('👨‍💼', style: TextStyle(fontSize: 14)),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Interviewer asks:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        scenario.question,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '💡 Why: ${scenario.interviewerNote}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                const Text(
                  '👉 Select your best response:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                const SizedBox(height: 12),

                // Choices
                ...List.generate(scenario.choices.length, (index) {
                  final choice = scenario.choices[index];
                  final isSelected = _selectedChoiceIndex == index;

                  Color borderColor = const Color(0x1AFFFFFF);
                  Color bgColor = const Color(0xFF1E293B).withValues(alpha: 0.5);

                  if (_answered) {
                    if (choice.isCorrect) {
                      borderColor = const Color(0xFF10B981);
                      bgColor = const Color(0xFF10B981).withValues(alpha: 0.15);
                    } else if (isSelected) {
                      borderColor = const Color(0xFFEF4444);
                      bgColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _selectChoice(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    choice.label,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (_answered && choice.isCorrect)
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                                if (_answered && isSelected && !choice.isCorrect)
                                  const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              choice.text,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                            if (_answered && (isSelected || choice.isCorrect)) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(choice.isCorrect ? '🚀 ' : '⚠️ ', style: const TextStyle(fontSize: 12)),
                                    Expanded(
                                      child: Text(
                                        choice.feedback,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: choice.isCorrect ? const Color(0xFF34D399) : const Color(0xFFFCA5A5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom Action
          if (_answered)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1220),
                border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _nextScenario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex < _scenarios.length - 1 ? 'Next Scenario ➡️' : 'Finish & Claim Results 🎉',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
