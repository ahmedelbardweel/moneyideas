import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/assistant/domain/models/assistant_question.dart';
import 'package:moneyideas/features/assistant/presentation/controllers/assistant_controller.dart';

/// Screen 33 & 34: Conversational Assistant Chat interface with quick-reply questionnaire tree.
class AssistantChatScreen extends ConsumerStatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  ConsumerState<AssistantChatScreen> createState() =>
      _AssistantChatScreenState();
}

class _AssistantChatScreenState extends ConsumerState<AssistantChatScreen> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        unawaited(
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  void _handleOption(String option, AssistantQuestionStep step) {
    final notifier = ref.read(assistantControllerProvider.notifier);
    switch (step) {
      case AssistantQuestionStep.budget:
        notifier.answerBudget(option);
      case AssistantQuestionStep.weeklyHours:
        notifier.answerHours(option);
      case AssistantQuestionStep.experience:
        notifier.answerExperience(option);
      case AssistantQuestionStep.riskTolerance:
        notifier.answerRisk(option);
      case AssistantQuestionStep.city:
        unawaited(notifier.answerCity(option));
        context.pushReplacement(AppRoutes.assistantAnalyzing);
      case AssistantQuestionStep.welcome:
      case AssistantQuestionStep.completed:
        break;
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantControllerProvider);
    final messages = state.messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المستشار الذكي'),
        actions: [
          IconButton(
            tooltip: 'إعادة البدء',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(assistantControllerProvider.notifier).startNewSession();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isBot = msg.sender == AssistantSender.bot;
                  final isLatest = index == messages.length - 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: isBot
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: isBot
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isBot) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: context.colors.primaryContainer,
                                child: Icon(
                                  AppIcons.assistant,
                                  size: 18,
                                  color: context.colors.onPrimaryContainer,
                                ),
                              ),
                              const Gap.xs(),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: isBot
                                      ? context.colors.surfaceContainerHighest
                                      : context.colors.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(
                                      AppRadius.medium,
                                    ),
                                    topRight: const Radius.circular(
                                      AppRadius.medium,
                                    ),
                                    bottomLeft: Radius.circular(
                                      isBot ? 4 : AppRadius.medium,
                                    ),
                                    bottomRight: Radius.circular(
                                      isBot ? AppRadius.medium : 4,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  msg.text,
                                  style: context.textStyles.bodyMedium?.copyWith(
                                    color: isBot
                                        ? context.colors.onSurface
                                        : context.colors.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Options chips for the latest bot message
                        if (isBot && isLatest && msg.options.isNotEmpty) ...[
                          const Gap.sm(),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              ...msg.options.map(
                                (opt) => ActionChip(
                                  label: Text(opt),
                                  onPressed: () =>
                                      _handleOption(opt, msg.step),
                                ),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.help_outline, size: 16),
                                label: const Text('لا أعرف / اقترح لي'),
                                onPressed: () => _handleOption(
                                  msg.options.first,
                                  msg.step,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
