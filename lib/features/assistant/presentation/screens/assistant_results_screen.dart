import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/core/widgets/states/empty_state.dart';
import 'package:moneyideas/features/assistant/presentation/controllers/assistant_controller.dart';
import 'package:moneyideas/features/assistant/presentation/widgets/scenario_simulator_sheet.dart';
import 'package:moneyideas/features/assistant/presentation/widgets/why_matched_sheet.dart';

/// Screen 36 & 39: Matched Opportunities Results & Explainability Screen.
class AssistantResultsScreen extends ConsumerWidget {
  const AssistantResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assistantControllerProvider);
    final results = state.results;

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتائج المطابقة الذكية'),
        actions: [
          IconButton(
            tooltip: 'تغيير السيناريو',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => ScenarioSimulatorSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: results.isEmpty
            ? EmptyState(
                title: 'لم نجد فرصاً تطابق كل هذه الشروط بدقة',
                message:
                    'يمكنك تجربة زيادة ساعات العمل المتاحة أو تعديل الميزانية لاكتشاف المزيد من الفرص المناسبة.',
                actionLabel: 'تغيير السيناريو 🔄',
                onAction: () => ScenarioSimulatorSheet.show(context),
              )
            : ListView(
                padding: AppSpacing.page,
                children: [
                  // Scenario Summary Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: AppRadius.mediumAll,
                      border: Border.all(
                        color: context.colors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'السيناريو النشط حالياً',
                                style: context.textStyles.labelMedium?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap.xxs(),
                              Text(
                                state.hasNoCapital
                                    ? 'بدون رأس مال • ${state.weeklyHours} س/أسبوع • ${state.city}'
                                    : '${state.budget.toStringAsFixed(0)} درهم • ${state.weeklyHours} س/أسبوع • ${state.city}',
                                style: context.textStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.tune_rounded, size: 16),
                          label: const Text('تعديل'),
                          onPressed: () => ScenarioSimulatorSheet.show(context),
                        ),
                      ],
                    ),
                  ),
                  const Gap.md(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الفرص المقترحة (${results.length})',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'مرتبة حسب تطابق المعايير',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Gap.sm(),

                  ...results.map((match) {
                    final isFull = match.isFullMatch;

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isFull
                              ? context.appColors.success.color.withValues(alpha: 0.6)
                              : context.colors.outlineVariant,
                          width: isFull ? 1.5 : 1,
                        ),
                        borderRadius: AppRadius.mediumAll,
                      ),
                      child: InkWell(
                        borderRadius: AppRadius.mediumAll,
                        onTap: () {
                          unawaited(
                            context.push('/opportunity/${match.opportunityId}'),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Criteria badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isFull
                                          ? context.appColors.success.color
                                              .withValues(alpha: 0.15)
                                          : context.appColors.warning.color
                                              .withValues(alpha: 0.15),
                                      borderRadius: AppRadius.fullAll,
                                    ),
                                    child: Text(
                                      '${match.criteriaMetCount}/${match.totalCriteriaCount} معايير',
                                      style: TextStyle(
                                        color: isFull
                                            ? context.appColors.success.color
                                            : context.appColors.warning.color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${match.minBudget.toStringAsFixed(0)} ${match.currency}',
                                    style: context.textStyles.labelMedium?.copyWith(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap.sm(),

                              Text(
                                match.titleAr,
                                style: context.textStyles.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap.xs(),

                              Text(
                                match.summaryAr,
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap.md(),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.help_outline_rounded,
                                      size: 16,
                                    ),
                                    label: const Text('لماذا ظهرت؟'),
                                    onPressed: () =>
                                        WhyMatchedSheet.show(context, match),
                                  ),
                                  Text(
                                    'عرض التفاصيل ⬅',
                                    style: context.textStyles.labelSmall?.copyWith(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AppButton(
          text: 'بدء تحليل جديد',
          variant: AppButtonVariant.outlined,
          isFullWidth: true,
          onPressed: () {
            ref.read(assistantControllerProvider.notifier).startNewSession();
            context.go(AppRoutes.assistantChat);
          },
        ),
      ),
    );
  }
}
