enum AssistantSender { bot, user }

enum AssistantQuestionStep {
  welcome,
  budget,
  weeklyHours,
  experience,
  riskTolerance,
  city,
  completed,
}

class AssistantChatMessage {
  const AssistantChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.options = const [],
    this.step = AssistantQuestionStep.welcome,
    this.timestamp,
  });

  final String id;
  final AssistantSender sender;
  final String text;
  final List<String> options;
  final AssistantQuestionStep step;
  final DateTime? timestamp;
}
