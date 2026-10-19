import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/features/profile_setup/presentation/controllers/profile_setup_controller.dart';

/// Screen 13: Experience Level, Weekly Available Hours, and Management Preference.
class StepExperienceWidget extends ConsumerWidget {
  const StepExperienceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final setupData = ref.watch(profileSetupProvider);
    final controller = ref.read(profileSetupProvider.notifier);

    final levels = [
      ('beginner', l10n.expBeginner),
      ('intermediate', l10n.expIntermediate),
      ('advanced', l10n.expAdvanced),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.setupStepExperience,
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          l10n.setupStepExperienceDesc,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.xl(),

        // Experience Level
        Text(
          l10n.setupExperienceLevel,
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.sm(),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: levels.map((lvl) {
            final isSelected = setupData.experienceLevel == lvl.$1;
            return ChoiceChip(
              label: Text(lvl.$2),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  controller.updateExperience(
                    level: lvl.$1,
                    hours: setupData.weeklyHours,
                    activeManagement: setupData.wantsActiveManagement,
                  );
                }
              },
            );
          }).toList(),
        ),
        const Gap.xl(),

        // Weekly Hours Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.setupWeeklyHours,
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${setupData.weeklyHours} ساعة / أسبوعياً',
              style: context.textStyles.labelLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: setupData.weeklyHours.toDouble(),
          min: 1,
          max: 40,
          divisions: 39,
          label: '${setupData.weeklyHours} ساعة',
          onChanged: (val) {
            controller.updateExperience(
              level: setupData.experienceLevel,
              hours: val.round(),
              activeManagement: setupData.wantsActiveManagement,
            );
          },
        ),
        const Gap.xl(),

        // Management Style
        Text(
          l10n.setupManagementPref,
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.sm(),
        _ManagementCard(
          title: l10n.managementActive,
          isSelected: setupData.wantsActiveManagement,
          onTap: () {
            controller.updateExperience(
              level: setupData.experienceLevel,
              hours: setupData.weeklyHours,
              activeManagement: true,
            );
          },
        ),
        const Gap.xs(),
        _ManagementCard(
          title: l10n.managementPassive,
          isSelected: !setupData.wantsActiveManagement,
          onTap: () {
            controller.updateExperience(
              level: setupData.experienceLevel,
              hours: setupData.weeklyHours,
              activeManagement: false,
            );
          },
        ),
      ],
    );
  }
}

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
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
        onTap: onTap,
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
                  title,
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
