import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/features/assistant/data/repositories/assistant_repository.dart';
import 'package:moneyideas/features/assistant/domain/models/assistant_question.dart';
import 'package:moneyideas/features/assistant/domain/models/match_result.dart';

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return const AssistantRepository();
});

class AssistantState {
  const AssistantState({
    this.messages = const [],
    this.currentStep = AssistantQuestionStep.welcome,
    this.budget = 10000,
    this.hasNoCapital = false,
    this.weeklyHours = 15,
    this.experience = 'beginner',
    this.risk = 'low',
    this.city = 'Dubai',
    this.isAnalyzing = false,
    this.results = const [],
    this.error,
  });

  final List<AssistantChatMessage> messages;
  final AssistantQuestionStep currentStep;
  final double budget;
  final bool hasNoCapital;
  final int weeklyHours;
  final String experience;
  final String risk;
  final String city;
  final bool isAnalyzing;
  final List<MatchResult> results;
  final String? error;

  AssistantState copyWith({
    List<AssistantChatMessage>? messages,
    AssistantQuestionStep? currentStep,
    double? budget,
    bool? hasNoCapital,
    int? weeklyHours,
    String? experience,
    String? risk,
    String? city,
    bool? isAnalyzing,
    List<MatchResult>? results,
    String? error,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      currentStep: currentStep ?? this.currentStep,
      budget: budget ?? this.budget,
      hasNoCapital: hasNoCapital ?? this.hasNoCapital,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      experience: experience ?? this.experience,
      risk: risk ?? this.risk,
      city: city ?? this.city,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      results: results ?? this.results,
      error: error,
    );
  }
}

class AssistantController extends Notifier<AssistantState> {
  @override
  AssistantState build() {
    return const AssistantState();
  }

  void startNewSession() {
    state = const AssistantState(
      currentStep: AssistantQuestionStep.budget,
      messages: [
        AssistantChatMessage(
          id: 'msg_1',
          sender: AssistantSender.bot,
          text:
              'مرحبًا بك في المستشار الاستثماري الذكي. سأساعدك في إيجاد الفرص الأنسب لإمكاناتك وظروفك الحقيقية دون ادعاءات غير واقعية.\n\nكم رأس المال المتاح لديك لبدء المشروع؟',
          options: [
            'لا أملك رأس مال حاليًا',
            'أقل من 5,000 درهم',
            '5,000 - 20,000 درهم',
            '20,000 - 50,000 درهم',
            'أكثر من 50,000 درهم',
          ],
          step: AssistantQuestionStep.budget,
        ),
      ],
    );
  }

  void answerBudget(String answer) {
    var budgetValue = 10000.0;
    var noCapital = false;

    if (answer.contains('لا أملك')) {
      budgetValue = 0;
      noCapital = true;
    } else if (answer.contains('أقل من 5,000')) {
      budgetValue = 3000;
    } else if (answer.contains('5,000 - 20,000')) {
      budgetValue = 12000;
    } else if (answer.contains('20,000 - 50,000')) {
      budgetValue = 35000;
    } else if (answer.contains('أكثر من 50,000')) {
      budgetValue = 75000;
    }

    final userMsg = AssistantChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: AssistantSender.user,
      text: answer,
    );

    const botMsg = AssistantChatMessage(
      id: 'bot_hours',
      sender: AssistantSender.bot,
      text:
          'عظيم. كم ساعة يمكنك تخصيصها أسبوعياً لإدارة ومتابعة هذا المشروع؟',
      options: [
        '5 ساعات (عمل جزئي خفيف)',
        '10 - 15 ساعة (عمل جزئي)',
        '20 - 30 ساعة (استثمار مركز)',
        '40+ ساعة (تفرغ كامل)',
      ],
      step: AssistantQuestionStep.weeklyHours,
    );

    state = state.copyWith(
      budget: budgetValue,
      hasNoCapital: noCapital,
      currentStep: AssistantQuestionStep.weeklyHours,
      messages: [...state.messages, userMsg, botMsg],
    );
  }

  void answerHours(String answer) {
    var hours = 15;
    if (answer.contains('5 ساعات')) {
      hours = 5;
    } else if (answer.contains('10 - 15')) {
      hours = 12;
    } else if (answer.contains('20 - 30')) {
      hours = 25;
    } else if (answer.contains('40+')) {
      hours = 40;
    }

    final userMsg = AssistantChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: AssistantSender.user,
      text: answer,
    );

    const botMsg = AssistantChatMessage(
      id: 'bot_exp',
      sender: AssistantSender.bot,
      text: 'ما هو مستوى خبرتك الإدارية أو التجارية السابقة؟',
      options: [
        'مبتدئ (أول تجربة لي)',
        'متوسط (لدي خبرة أو مهارة سابقة)',
        'متقدم (أدرت مشاريع تجارية من قبل)',
      ],
      step: AssistantQuestionStep.experience,
    );

    state = state.copyWith(
      weeklyHours: hours,
      currentStep: AssistantQuestionStep.experience,
      messages: [...state.messages, userMsg, botMsg],
    );
  }

  void answerExperience(String answer) {
    var exp = 'beginner';
    if (answer.contains('متقدم')) {
      exp = 'advanced';
    } else if (answer.contains('متوسط')) {
      exp = 'intermediate';
    }

    final userMsg = AssistantChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: AssistantSender.user,
      text: answer,
    );

    const botMsg = AssistantChatMessage(
      id: 'bot_risk',
      sender: AssistantSender.bot,
      text: 'ما هي درجة تحملك للمخاطر المالية والتقلبات؟',
      options: [
        'منخفضة (الحفاظ على رأس المال أولاً)',
        'معتدلة (أقبل تذبذباً مقابل عوائد أفضل)',
        'عالية (مستعد للمخاطرة العالية لنمو سريع)',
      ],
      step: AssistantQuestionStep.riskTolerance,
    );

    state = state.copyWith(
      experience: exp,
      currentStep: AssistantQuestionStep.riskTolerance,
      messages: [...state.messages, userMsg, botMsg],
    );
  }

  void answerRisk(String answer) {
    var r = 'low';
    if (answer.contains('عالية')) {
      r = 'high';
    } else if (answer.contains('معتدلة')) {
      r = 'medium';
    }

    final userMsg = AssistantChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: AssistantSender.user,
      text: answer,
    );

    const botMsg = AssistantChatMessage(
      id: 'bot_city',
      sender: AssistantSender.bot,
      text: 'في أي مدينة أو سوق ترغب في تركيز نشاطك؟',
      options: [
        'دبي (Dubai)',
        'أبوظبي (Abu Dhabi)',
        'الشارقة والإمارات الشمالية',
        'عن بُعد / تجارة رقمية عامة',
      ],
      step: AssistantQuestionStep.city,
    );

    state = state.copyWith(
      risk: r,
      currentStep: AssistantQuestionStep.city,
      messages: [...state.messages, userMsg, botMsg],
    );
  }

  Future<void> answerCity(String answer) async {
    var cityName = 'Dubai';
    if (answer.contains('أبوظبي')) {
      cityName = 'Abu Dhabi';
    } else if (answer.contains('الشارقة')) {
      cityName = 'Sharjah';
    }

    final userMsg = AssistantChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: AssistantSender.user,
      text: answer,
    );

    state = state.copyWith(
      city: cityName,
      currentStep: AssistantQuestionStep.completed,
      messages: [...state.messages, userMsg],
      isAnalyzing: true,
    );

    await executeMatching();
  }

  Future<void> executeMatching() async {
    state = state.copyWith(isAnalyzing: true);

    final repo = ref.read(assistantRepositoryProvider);
    final result = await repo.matchOpportunities(
      budget: state.budget,
      city: state.city,
      weeklyHours: state.weeklyHours,
      experience: state.experience,
      risk: state.risk,
      hasNoCapital: state.hasNoCapital,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        isAnalyzing: false,
        results: result.valueOrNull,
      );
    } else {
      state = state.copyWith(
        isAnalyzing: false,
        error: result.failureOrNull?.debugMessage ?? 'فشل إجراء التحليل.',
      );
    }
  }

  /// Interactive Scenario Simulation: Allows tweaking budget and hours live.
  Future<void> simulateScenario({
    required double newBudget,
    required int newHours,
    required bool noCapital,
  }) async {
    state = state.copyWith(
      budget: newBudget,
      weeklyHours: newHours,
      hasNoCapital: noCapital,
    );
    await executeMatching();
  }
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(
  AssistantController.new,
);
