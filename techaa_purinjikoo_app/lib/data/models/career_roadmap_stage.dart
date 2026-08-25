enum RoadmapStageType {
  firstYear,
  secondYear,
  thirdYear,
  fourthYear,
  careerPaths,
}

class DialogueLine {
  final String speaker;
  final String avatarEmoji;
  final String text;
  final bool isTechaa;

  const DialogueLine({
    required this.speaker,
    required this.avatarEmoji,
    required this.text,
    this.isTechaa = false,
  });
}

class RoadmapTopicItem {
  final String id;
  final String title;
  final String subtitle;
  final String iconEmoji;
  final List<DialogueLine> dialogue;
  final String realWorldExample;
  final String devExperience;
  final String careerRelevance;
  final String missionPrompt;
  final int xpReward;

  const RoadmapTopicItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.dialogue,
    required this.realWorldExample,
    required this.devExperience,
    required this.careerRelevance,
    required this.missionPrompt,
    this.xpReward = 50,
  });
}

class RoadmapModule {
  final String id;
  final String moduleNumber;
  final String title;
  final String tagline;
  final String iconEmoji;
  final List<RoadmapTopicItem> topics;
  final String? buildMissionTitle;
  final String? buildMissionDesc;

  const RoadmapModule({
    required this.id,
    required this.moduleNumber,
    required this.title,
    required this.tagline,
    required this.iconEmoji,
    required this.topics,
    this.buildMissionTitle,
    this.buildMissionDesc,
  });
}

class RoadmapYearStage {
  final RoadmapStageType stageType;
  final String title;
  final String badgeText;
  final String motto;
  final String yearMissionTitle;
  final String yearMissionDesc;
  final List<RoadmapModule> modules;

  const RoadmapYearStage({
    required this.stageType,
    required this.title,
    required this.badgeText,
    required this.motto,
    required this.yearMissionTitle,
    required this.yearMissionDesc,
    required this.modules,
  });
}

class CareerTrack {
  final String id;
  final String title;
  final String iconEmoji;
  final String tagline;
  final List<String> steps;
  final String featuredTopic;
  final List<RoadmapTopicItem> topics;

  const CareerTrack({
    required this.id,
    required this.title,
    required this.iconEmoji,
    required this.tagline,
    required this.steps,
    required this.featuredTopic,
    required this.topics,
  });
}
