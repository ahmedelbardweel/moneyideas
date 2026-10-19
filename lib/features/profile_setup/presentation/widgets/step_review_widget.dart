import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/profile_setup/presentation/controllers/profile_setup_controller.dart';

/// Screen 15: Analytical Profile Review, completeness score, and final confirmation.
class StepReviewWidget extends ConsumerWidget {
  const StepReviewWidget({
    required this.onEditStep,
    required this.onSubmit,
    this.isSubmitting = false,
    super.key,
  });

  final void Function(int stepIndex) onEditStep;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final setupData = ref.watch(profileSetupProvider);
    final percentage = setupData.completenessPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.setupStepReview,
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          l10n.setupStepReviewDesc,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.lg(),

        // Completeness Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.3),
            borderRadius: AppRadius.largeAll,
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.setupCompletionScore,
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Gap.sm(),
              ClipRRect(
                borderRadius: AppRadius.fullAll,
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(context.colors.primary),
                ),
              ),
            ],
          ),
        ),
        const Gap.lg(),

        // Summary Cards
        _SummaryTile(
          title: l10n.setupStepRole,
          value: '${setupData.selectedRoles.length} أدوار محددة',
          icon: AppIcons.person,
          onEdit: () => onEditStep(0),
        ),
        _SummaryTile(
          title: l10n.setupStepGoal,
          value: '${setupData.selectedGoals.length} أهداف محددة',
          icon: AppIcons.assistant,
          onEdit: () => onEditStep(1),
        ),
        _SummaryTile(
          title: l10n.setupStepLocation,
          value: '${setupData.city} (${setupData.country}) - ${setupData.currency}',
          icon: AppIcons.location,
          onEdit: () => onEditStep(2),
        ),
        _SummaryTile(
          title: l10n.setupStepBudget,
          value: setupData.hasNoCapital
              ? l10n.setupNoCapital
              : '${setupData.budgetAmount.toStringAsFixed(0)} ${setupData.currency}',
          icon: AppIcons.budget,
          onEdit: () => onEditStep(3),
        ),
        _SummaryTile(
          title: l10n.setupStepExperience,
          value: '${setupData.experienceLevel} • ${setupData.weeklyHours} س/أسبوع',
          icon: AppIcons.filter,
          onEdit: () => onEditStep(4),
        ),
        _SummaryTile(
          title: l10n.setupStepRisk,
          value: 'المخاطرة: ${setupData.riskTolerance} • ${setupData.liquidityNeed}',
          icon: AppIcons.verified,
          onEdit: () => onEditStep(5),
        ),

        const Gap.xl(),
        AppButton(
          text: l10n.setupShowOptions,
          icon: AppIcons.forward,
          isFullWidth: true,
          isLoading: isSubmitting,
          onPressed: isSubmitting ? null : onSubmit,
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onEdit,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mediumAll,
        side: BorderSide(color: context.colors.outlineVariant),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: context.colors.primary,
          size: AppSizes.iconSmall,
        ),
        title: Text(
          title,
          style: context.textStyles.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          value,
          style: context.textStyles.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(AppIcons.edit, size: AppSizes.iconSmall),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
