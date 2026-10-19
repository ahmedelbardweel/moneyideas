import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';

/// Interactive role badge pill shown in the Home AppBar.
/// Shows current active role and allows seamless switching if the user holds multiple roles.
class HomeRoleBadge extends ConsumerWidget {
  const HomeRoleBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).asData?.value;
    final roles = profile?.roles ?? const ['individual'];
    final activeRole = ref.watch(activeRoleProvider);
    final colors = context.colors;

    final (label, icon, bg, textCol) = _getRoleDisplay(activeRole, colors);

    return InkWell(
      borderRadius: AppRadius.fullAll,
      onTap: () => _showRoleSwitchSheet(context, ref, roles, activeRole),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.fullAll,
          border: Border.all(
            color: textCol.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textCol),
            const Gap.xxs(),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textCol,
              ),
            ),
            if (roles.length > 1) ...[
              const Gap.xxs(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: textCol.withValues(alpha: 0.18),
                  borderRadius: AppRadius.fullAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+${roles.length - 1}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: textCol,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 12),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static (String, IconData, Color, Color) _getRoleDisplay(
    String role,
    ColorScheme colors,
  ) {
    return switch (role) {
      'admin' => (
          'مدير النظام',
          Icons.admin_panel_settings_rounded,
          colors.errorContainer.withValues(alpha: 0.5),
          colors.error,
        ),
      'company' => (
          'شركة ومزود',
          Icons.business_rounded,
          colors.tertiaryContainer.withValues(alpha: 0.5),
          colors.onTertiaryContainer,
        ),
      'project_owner' => (
          'صاحب مشروع',
          Icons.rocket_launch_rounded,
          colors.secondaryContainer.withValues(alpha: 0.5),
          colors.onSecondaryContainer,
        ),
      'investor' => (
          'مستثمر',
          Icons.trending_up_rounded,
          colors.primaryContainer.withValues(alpha: 0.5),
          colors.onPrimaryContainer,
        ),
      _ => (
          'باحث عن فرصة',
          Icons.person_rounded,
          colors.surfaceContainerHighest.withValues(alpha: 0.6),
          colors.onSurfaceVariant,
        ),
    };
  }

  void _showRoleSwitchSheet(
    BuildContext context,
    WidgetRef ref,
    List<String> roles,
    String currentRole,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final colors = sheetCtx.colors;
        final allOptions = roles.contains('admin')
            ? ['admin', 'company', 'project_owner', 'investor', 'individual']
            : roles;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap.md(),
                Text(
                  'تبديل واجهة العرض حسب الدور',
                  style: sheetCtx.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap.xs(),
                Text(
                  'اختر الدور الذي ترغب في استعراض لوحة التحكم الخاصة به',
                  style: sheetCtx.textStyles.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap.md(),
                ...allOptions.map((role) {
                  final isSelected = role == currentRole;
                  final (title, icon, _, textCol) =
                      _getRoleDisplay(role, colors);

                  return ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mediumAll,
                    ),
                    tileColor: isSelected
                        ? colors.primaryContainer.withValues(alpha: 0.3)
                        : null,
                    leading: CircleAvatar(
                      backgroundColor: textCol.withValues(alpha: 0.15),
                      child: Icon(icon, color: textCol, size: 20),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: colors.primary)
                        : null,
                    onTap: () {
                      ref.read(activeRoleProvider.notifier).setRole(role);
                      Navigator.of(sheetCtx).pop();
                    },
                  );
                }),
                const Gap.sm(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('إدارة الأدوار وصلاحيات الحساب'),
                  onPressed: () {
                    Navigator.of(sheetCtx).pop();
                    unawaited(context.push(AppRoutes.accountRoles));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
