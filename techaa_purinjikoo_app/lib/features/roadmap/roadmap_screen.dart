import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/datasources/career_roadmap_content.dart';
import '../../data/models/career_roadmap_stage.dart';
import '../../data/repositories/user_repository.dart';
import '../../shared/widgets/interactive_pressable.dart';
import 'roadmap_topic_detail_sheet.dart';
import 'widgets/career_passport_modal.dart';
import 'widgets/ctc_calculator_sheet.dart';
import 'widgets/interview_simulator_sheet.dart';

class RoadmapScreen extends ConsumerStatefulWidget {
  const RoadmapScreen({super.key});

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = [
    '🟢 1st Year',
    '🔵 2nd Year',
    '🟣 3rd Year',
    '🟠 4th Year',
    '🚀 Career Paths',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yearStages = CareerRoadmapContent.getYearStages();
    final careerTracks = CareerRoadmapContent.getCareerTracks();
    final user = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          '🎓 Career Roadmap',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFFBBF24), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${user.xp} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Quick Tools
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131826),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: '🔍 Search concepts (e.g. Docker, JWT, CTC, Kafka, RAM)...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Colors.white70, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3 Quick Action Interactive Tool Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickToolButton(
                          title: '💰 CTC Calculator',
                          color: const Color(0xFF10B981),
                          onTap: () => CtcCalculatorSheet.show(context),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildQuickToolButton(
                          title: '🎭 Interview Sim',
                          color: const Color(0xFFA855F7),
                          onTap: () => InterviewSimulatorSheet.show(context),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildQuickToolButton(
                          title: '🪪 Passport',
                          color: const Color(0xFF38BDF8),
                          onTap: () => CareerPassportModal.show(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_searchQuery.isEmpty) ...[
              // Stage Selection Chips
              Container(
                height: 44,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedTabIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InteractivePressable(
                        onTap: () => setState(() => _selectedTabIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFF131826),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.08),
                              width: 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const Divider(color: Color(0x1AFFFFFF), height: 1),

            // Main Content Area
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResultsView(yearStages, user.completedTopicIds)
                  : (_selectedTabIndex < 4
                      ? _buildYearStageView(yearStages[_selectedTabIndex], user.completedTopicIds)
                      : _buildCareerTracksView(careerTracks, user.completedTopicIds)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickToolButton({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsView(List<RoadmapYearStage> stages, List<String> completedTopicIds) {
    final List<Map<String, dynamic>> results = [];

    for (var stage in stages) {
      for (var module in stage.modules) {
        for (var topic in module.topics) {
          if (topic.title.toLowerCase().contains(_searchQuery) ||
              topic.subtitle.toLowerCase().contains(_searchQuery) ||
              topic.realWorldExample.toLowerCase().contains(_searchQuery) ||
              topic.devExperience.toLowerCase().contains(_searchQuery)) {
            results.add({
              'stage': stage.title,
              'module': module.title,
              'topic': topic,
            });
          }
        }
      }
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text(
              'No topics found matching "$_searchQuery"',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try searching "Docker", "JWT", "SQL", "RAM", or "LeetCode"',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final topic = item['topic'] as RoadmapTopicItem;
        final isCompleted = completedTopicIds.contains(topic.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF131826),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: isCompleted ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
              child: Text(topic.iconEmoji, style: const TextStyle(fontSize: 18)),
            ),
            title: Text(
              topic.title,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  topic.subtitle,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['stage']} • ${item['module']}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8)),
                ),
              ],
            ),
            trailing: isCompleted
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                : const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF64748B), size: 14),
            onTap: () => RoadmapTopicDetailSheet.show(context, topic),
          ),
        );
      },
    );
  }

  Widget _buildYearStageView(RoadmapYearStage stage, List<String> completedTopicIds) {
    int totalTopics = 0;
    int completedCount = 0;

    for (var m in stage.modules) {
      totalTopics += m.topics.length;
      for (var t in m.topics) {
        if (completedTopicIds.contains(t.id)) completedCount++;
      }
    }

    final progress = totalTopics > 0 ? (completedCount / totalTopics) : 0.0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      children: [
        // Year Motto & Mission Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E070F), Color(0xFF0F1423)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      stage.badgeText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ),
                  Text(
                    '$completedCount / $totalTopics Learned',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                stage.motto,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${stage.yearMissionTitle}: ${stage.yearMissionDesc}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFFCBD5E1),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),

        // Year 1 Skill Breakdown Score Card
        if (stage.stageType == RoadmapStageType.firstYear) ...[
          const SizedBox(height: 16),
          _buildYearOneSkillScoreCard(completedCount, totalTopics),
        ],

        // Year 2 Builder Breakdown Score Card
        if (stage.stageType == RoadmapStageType.secondYear) ...[
          const SizedBox(height: 16),
          _buildYearTwoSkillScoreCard(completedCount, totalTopics),
        ],

        // Year 3 Career Specialization Score Card
        if (stage.stageType == RoadmapStageType.thirdYear) ...[
          const SizedBox(height: 16),
          _buildYearThreeSkillScoreCard(completedCount, totalTopics),
        ],

        // Year 4 Job Ready Score Card
        if (stage.stageType == RoadmapStageType.fourthYear) ...[
          const SizedBox(height: 16),
          _buildYearFourSkillScoreCard(completedCount, totalTopics),
        ],

        const SizedBox(height: 20),

        // Modules
        ...stage.modules.map((module) => _buildModuleCard(module, completedTopicIds)),
      ],
    );
  }

  Widget _buildModuleCard(RoadmapModule module, List<String> completedTopicIds) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1424),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(module.iconEmoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${module.moduleNumber} • ${module.title}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      module.tagline,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Topics List
          ...module.topics.map((topic) {
            final isDone = completedTopicIds.contains(topic.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InteractivePressable(
                onTap: () => RoadmapTopicDetailSheet.show(context, topic),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF065F46).withValues(alpha: 0.2)
                        : const Color(0xFF141A2D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(topic.iconEmoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDone ? const Color(0xFF34D399) : Colors.white,
                              ),
                            ),
                            Text(
                              topic.subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isDone ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                        color: isDone ? const Color(0xFF10B981) : const Color(0xFF64748B),
                        size: isDone ? 18 : 12,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Module Build Mission
          if (module.buildMissionTitle != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1325),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.rocket_launch_rounded, color: Color(0xFFA855F7), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.buildMissionTitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE9D5FF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          module.buildMissionDesc!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFD8B4FE),
                            height: 1.35,
                          ),
                        ),
                      ],
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

  Widget _buildCareerTracksView(List<CareerTrack> tracks, List<String> completedTopicIds) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      children: [
        // Track Header Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F1A2E), Color(0xFF1C091E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🚀 Specialized Career Paths',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Pick your dream specialization and master the practical Tanglish topics needed for high-paying roles.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Career Tracks Cards
        ...tracks.map((track) => _buildCareerTrackCard(track, completedTopicIds)),
      ],
    );
  }

  Widget _buildCareerTrackCard(CareerTrack track, List<String> completedTopicIds) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1424),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(track.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      track.tagline,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Steps Breadcrumb / Flow
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: track.steps.map((step) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF172033),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Text(
                  step,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Featured Interactive Topic
          ...track.topics.map((topic) {
            final isDone = completedTopicIds.contains(topic.id);
            return InteractivePressable(
              onTap: () => RoadmapTopicDetailSheet.show(context, topic),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFF065F46).withValues(alpha: 0.25)
                      : const Color(0xFF14192B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone
                        ? const Color(0xFF10B981).withValues(alpha: 0.45)
                        : AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_outline_rounded, color: AppColors.primaryAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            topic.subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF64748B), size: 12),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildYearOneSkillScoreCard(int completedCount, int totalTopics) {
    final pct = totalTopics > 0 ? ((completedCount / totalTopics) * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_rounded, color: Color(0xFF38BDF8), size: 18),
                  SizedBox(width: 8),
                  Text(
                    '📊 YOUR YEAR-1 TECHAA SCORE',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pct%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF38BDF8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildSkillBar('💻 Programming', completedCount >= 2 ? 0.9 : 0.35, const Color(0xFFE11D48)),
          _buildSkillBar('🧠 Problem Solving', completedCount >= 3 ? 0.8 : 0.25, const Color(0xFFF59E0B)),
          _buildSkillBar('🐙 Git & GitHub', completedCount >= 4 ? 0.95 : 0.4, const Color(0xFFA855F7)),
          _buildSkillBar('🌐 Web & Networking', completedCount >= 2 ? 0.75 : 0.3, const Color(0xFF06B6D4)),
          _buildSkillBar('🗄️ Database & APIs', completedCount >= 3 ? 0.7 : 0.2, const Color(0xFF10B981)),
          _buildSkillBar('🗣️ Communication & Quality', 0.65, const Color(0xFFEC4899)),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.flag_rounded, color: Color(0xFFFBBF24), size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Next Goal → Build & deploy your first project to GitHub!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearTwoSkillScoreCard(int completedCount, int totalTopics) {
    final pct = totalTopics > 0 ? ((completedCount / totalTopics) * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.layers_rounded, color: Color(0xFF38BDF8), size: 18),
                  SizedBox(width: 8),
                  Text(
                    '📊 YOUR YEAR-2 BUILDER SCORE',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pct%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF38BDF8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildSkillBar('🎨 Frontend & React', completedCount >= 2 ? 0.9 : 0.35, const Color(0xFF38BDF8)),
          _buildSkillBar('⚙️ Backend & APIs', completedCount >= 3 ? 0.85 : 0.4, const Color(0xFF10B981)),
          _buildSkillBar('🔑 Auth & JWT Security', completedCount >= 4 ? 0.9 : 0.3, const Color(0xFFF59E0B)),
          _buildSkillBar('🗄️ Relational DB & SQL', completedCount >= 2 ? 0.85 : 0.35, const Color(0xFFA855F7)),
          _buildSkillBar('⚡ Redis In-Memory Cache', completedCount >= 3 ? 0.75 : 0.2, const Color(0xFFE11D48)),
          _buildSkillBar('🐳 Docker & Cloud Deploy', completedCount >= 4 ? 0.95 : 0.25, const Color(0xFF06B6D4)),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.rocket_launch_rounded, color: Color(0xFF38BDF8), size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Next Goal → Deploy Full Stack App with Docker + PostgreSQL to Render/Vercel!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearThreeSkillScoreCard(int completedCount, int totalTopics) {
    final pct = totalTopics > 0 ? ((completedCount / totalTopics) * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF190D2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Color(0xFFA855F7), size: 18),
                  SizedBox(width: 8),
                  Text(
                    '📊 YOUR YEAR-3 CAREER SCORE',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pct%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFA855F7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildSkillBar('🧭 Domain Specialization', completedCount >= 2 ? 0.95 : 0.4, const Color(0xFFA855F7)),
          _buildSkillBar('🏛️ System Architecture', completedCount >= 3 ? 0.85 : 0.35, const Color(0xFF38BDF8)),
          _buildSkillBar('🔄 Agile & PR Workflow', completedCount >= 4 ? 0.9 : 0.3, const Color(0xFF10B981)),
          _buildSkillBar('🧠 LeetCode DSA Patterns', completedCount >= 2 ? 0.8 : 0.25, const Color(0xFFF59E0B)),
          _buildSkillBar('🔍 Sentry Observability', completedCount >= 3 ? 0.85 : 0.2, const Color(0xFFEC4899)),
          _buildSkillBar('📄 ATS Resume & Portfolio', completedCount >= 4 ? 0.95 : 0.3, const Color(0xFF06B6D4)),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.stars_rounded, color: Color(0xFFA855F7), size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Next Goal → Showcase 2 production-grade apps on your custom domain portfolio!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFourSkillScoreCard(int completedCount, int totalTopics) {
    final pct = totalTopics > 0 ? ((completedCount / totalTopics) * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF221105),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFFF97316), size: 18),
                  SizedBox(width: 8),
                  Text(
                    '📊 YOUR YEAR-4 PLACEMENT SCORE',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pct%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF97316),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildSkillBar('🎯 CTC & Job Market IQ', completedCount >= 2 ? 0.95 : 0.4, const Color(0xFFF97316)),
          _buildSkillBar('📄 ATS Resume Score', completedCount >= 3 ? 0.9 : 0.35, const Color(0xFF38BDF8)),
          _buildSkillBar('🐙 GitHub Proof-of-Work', completedCount >= 4 ? 0.95 : 0.3, const Color(0xFFA855F7)),
          _buildSkillBar('🎤 STAR Interview Pitch', completedCount >= 2 ? 0.85 : 0.25, const Color(0xFF10B981)),
          _buildSkillBar('💼 Cold Outreach & PPO', completedCount >= 3 ? 0.8 : 0.2, const Color(0xFFF59E0B)),
          _buildSkillBar('🎓 Techaa Career Passport', completedCount >= 4 ? 1.0 : 0.3, const Color(0xFFE11D48)),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.school_rounded, color: Color(0xFFF97316), size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Next Goal → Claim your Techaa Career Ready Passport & crack top offers!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
