import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/features/profile_setup/presentation/controllers/profile_setup_controller.dart';

/// Screen 09: Role Selection Step (Multi-role supported).
class StepRolesWidget extends ConsumerWidget {
  const StepRolesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final setupData = ref.watch(profileSetupProvider);
    final controller = ref.read(profileSetupProvider.notifier);

    final roles = [
      (
        'individual',
        l10n.roleIndividual,
        l10n.roleIndividualDesc,
        AppIcons.individual,
      ),
      (
        'investor',
        l10n.roleInvestor,
        l10n.roleInvestorDesc,
        AppIcons.investor,
      ),
      (
        'project_owner',
        l10n.roleProjectOwner,
        l10n.roleProjectOwnerDesc,
        AppIcons.projectOwner,
      ),
      (
        'company',
        l10n.roleCompany,
        l10n.roleCompanyDesc,
        AppIcons.company,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.setupStepRole,
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          l10n.setupStepRoleDesc,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.lg(),
        ...roles.map((role) {
          final isSelected = setupData.selectedRoles.contains(role.$1);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Card(
              color: isSelected
                  ? context.colors.primaryContainer.withValues(alpha: 0.35)
                  : context.colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mediumAll,
                side: BorderSide(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? context.colors.primary
                      : context.colors.surfaceContainerHigh,
                  child: Icon(
                    role.$4,
                    color: isSelected
                        ? context.colors.onPrimary
                        : context.colors.onSurfaceVariant,
                    size: AppSizes.iconMedium,
                  ),
                ),
                title: Text(
                  role.$2,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                subtitle: Text(role.$3),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (_) => controller.toggleRole(role.$1),
                ),
                onTap: () => controller.toggleRole(role.$1),
              ),
            ),
          );
        }),
      ],
    );
  }
}
