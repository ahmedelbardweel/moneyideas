import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/features/profile_setup/presentation/controllers/profile_setup_controller.dart';

/// Screen 14: Risk Tolerance and Liquidity Horizon Selection with educational guide.
class StepRiskWidget extends ConsumerWidget {
  const StepRiskWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final setupData = ref.watch(profileSetupProvider);
    final controller = ref.read(profileSetupProvider.notifier);

    final risks = [
      ('low', l10n.riskLow),
      ('medium', l10n.riskMedium),
      ('high', l10n.riskHigh),
    ];

    final liquidities = [
      ('short_term', l10n.liquidityShort),
      ('medium_term', l10n.liquidityMedium),
      ('long_term', l10n.liquidityLong),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.setupStepRisk,
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          l10n.setupStepRiskDesc,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.lg(),

        // Educational Guidance Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: AppRadius.mediumAll,
            border: Border.all(
              color: context.colors.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.info,
                color: context.colors.primary,
                size: AppSizes.iconMedium,
              ),
              const Gap.md(),
              Expanded(
                child: Text(
                  l10n.setupRiskHelp,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap.xl(),

        // Risk Tolerance Section
        Text(
          l10n.setupRiskTolerance,
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.sm(),
        Column(
          children: risks.map((r) {
            final isSelected = setupData.riskTolerance == r.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Card(
                elevation: isSelected ? 1 : 0,
                color: isSelected
                    ? context.colors.primaryContainer.withValues(alpha: 0.35)
                    : context.colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mediumAll,
                  side: BorderSide(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.outlineVariant,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: AppRadius.mediumAll,
                  onTap: () {
                    controller.updateRisk(
                      tolerance: r.$1,
                      liquidity: setupData.liquidityNeed,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                          size: AppSizes.iconMedium,
                        ),
                        const Gap.md(),
                        Expanded(
                          child: Text(
                            r.$2,
                            style: context.textStyles.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const Gap.xl(),

        // Liquidity Horizon Section
        Text(
          l10n.setupLiquidity,
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.sm(),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: liquidities.map((liq) {
            final isSelected = setupData.liquidityNeed == liq.$1;
            return ChoiceChip(
              label: Text(liq.$2),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  controller.updateRisk(
                    tolerance: setupData.riskTolerance,
                    liquidity: liq.$1,
                  );
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
