import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/assistant/presentation/controllers/assistant_controller.dart';

class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(assistantControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navAssistant),
      ),
      body: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.assistant,
                size: AppSizes.iconXLarge * 1.5,
                color: context.colors.onPrimaryContainer,
              ),
            ),
            const Gap.xl(),
            Text(
              'المستشار الذكي لأفكار المال',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap.sm(),
            Text(
              'نظام يعتمد على بيانات موثقة وقواعد واضحة لمطابقة إمكاناتك وخبرتك مع أفضل الفرص المناسبة دون ادعاءات غير حقيقية.',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap.xxl(),
            AppButton(
              text: 'بدء تحليل جديد',
              icon: AppIcons.assistant,
              isFullWidth: true,
              onPressed: () {
                ref.read(assistantControllerProvider.notifier).startNewSession();
                unawaited(context.push(AppRoutes.assistantChat));
              },
            ),
            if (state.results.isNotEmpty) ...[
              const Gap.md(),
              AppButton(
                text: 'عرض آخر نتائج المطابقة (${state.results.length})',
                variant: AppButtonVariant.outlined,
                isFullWidth: true,
                onPressed: () =>
                    unawaited(context.push(AppRoutes.assistantResults)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
