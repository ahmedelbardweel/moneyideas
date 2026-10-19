import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/features/profile_setup/presentation/controllers/profile_setup_controller.dart';

/// Screen 10: Goals Selection Step (Multi-goal supported).
class StepGoalsWidget extends ConsumerWidget {
  const StepGoalsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final setupData = ref.watch(profileSetupProvider);
    final controller = ref.read(profileSetupProvider.notifier);

    final goals = [
      ('invest_money', l10n.goalInvest, AppIcons.budget),
      ('discover_idea', l10n.goalDiscover, AppIcons.idea),
      ('develop_project', l10n.goalDevelop, AppIcons.projectOwner),
      ('find_partner_investor', l10n.goalPartner, AppIcons.partnerships),
      ('find_service', l10n.goalService, AppIcons.services),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.setupStepGoal,
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          l10n.setupStepGoalDesc,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.lg(),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: goals.map((goal) {
            final isSelected = setupData.selectedGoals.contains(goal.$1);
            return FilterChip(
              avatar: Icon(
                goal.$3,
                size: AppSizes.iconSmall,
                color: isSelected
                    ? context.colors.onSecondaryContainer
                    : context.colors.onSurfaceVariant,
              ),
              label: Text(goal.$2),
              selected: isSelected,
              onSelected: (_) => controller.toggleGoal(goal.$1),
            );
          }).toList(),
        ),
      ],
    );
  }
}
