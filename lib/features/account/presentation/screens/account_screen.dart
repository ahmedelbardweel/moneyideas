import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/auth/presentation/controllers/auth_controller.dart';

/// Screen 70: Account Hub displaying live user profile, roles, preferences, and system settings.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navAccount),
        actions: [
          IconButton(
            tooltip: 'تعديل الملف',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => unawaited(context.push('/account/edit')),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          final name = profile?.fullName.isNotEmpty == true
              ? profile!.fullName
              : 'مستخدم أفكار المال';
          final email = profile?.email ?? '';
          final roles = profile?.roles ?? ['individual'];
          final completion = profile?.completionPercentage ?? 20;

          return ListView(
            padding: AppSpacing.page,
            children: [
              // Profile Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: context.colors.outlineVariant),
                  borderRadius: AppRadius.mediumAll,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: context.colors.primaryContainer,
                            child: Text(
                              name.isNotEmpty ? name[0] : 'U',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: context.colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const Gap.md(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style:
                                      context.textStyles.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (email.isNotEmpty) ...[
                                  const Gap.xxs(),
                                  Text(
                                    email,
                                    style:
                                        context.textStyles.bodySmall?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                const Gap.xs(),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  children: roles.map((r) {
                                    final label = switch (r) {
                                      'investor' => 'مستثمر',
                                      'project_owner' => 'رائد أعمال',
                                      'company' => 'شركة',
                                      _ => 'باحث عن فرصة',
                                    };
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colors.secondaryContainer,
                                        borderRadius: AppRadius.fullAll,
                                      ),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: context
                                              .colors.onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap.md(),
                      const Divider(),
                      const Gap.xs(),

                      // Completion Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'اكتمال الملف الاستثماري',
                            style: context.textStyles.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '$completion%',
                            style: context.textStyles.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Gap.xs(),
                      LinearProgressIndicator(
                        value: completion / 100,
                        backgroundColor: context.colors.surfaceContainerHighest,
                        color: context.colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const Gap.lg(),

              // Super Admin Portal Tile
              if (roles.contains('admin')) ...[
                Card(
                  color: context.colors.errorContainer.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: context.colors.error.withValues(alpha: 0.4),
                    ),
                    borderRadius: AppRadius.mediumAll,
                  ),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: context.colors.error,
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text(
                      'لوحة تحكم الإدارة العليا (Admin Portal)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'تدقيق الشركات، اعتماد العروض، إدارة المستخدمين والبلاغات',
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => unawaited(context.push(AppRoutes.admin)),
                  ),
                ),
                const Gap.md(),
              ],

              // Quick Actions
              ListTile(
                leading: const Icon(Icons.edit_note_rounded),
                title: const Text('تعديل الملف الشخصي'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => unawaited(context.push('/account/edit')),
              ),
              ListTile(
                leading: const Icon(AppIcons.roles),
                title: const Text('إدارة الأدوار المتعددة'),
                subtitle: Text(
                  roles.map((r) {
                    switch (r) {
                      case 'admin':
                        return 'مدير النظام';
                      case 'company':
                        return 'شركة / مزود خدمة';
                      case 'project_owner':
                        return 'صاحب مشروع';
                      case 'investor':
                        return 'مستثمر';
                      default:
                        return 'باحث عن فرصة';
                    }
                  }).join('، '),
                ),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => unawaited(context.push('/account/roles')),
              ),
              ListTile(
                leading: const Icon(Icons.tune_rounded),
                title: const Text('تفضيلات الاستثمار والميزانية'),
                subtitle: Text(
                  profile?.hasNoCapital == true
                      ? 'بدون رأس مال • ${profile?.weeklyHours ?? 5} س/أسبوع'
                      : '${profile?.budgetAmount.toStringAsFixed(0) ?? 0} درهم • ${profile?.weeklyHours ?? 5} س/أسبوع',
                ),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => unawaited(context.push('/account/preferences')),
              ),
              if (roles.contains('company') || roles.contains('admin')) ...[
                ListTile(
                  leading: const Icon(Icons.business_rounded),
                  title: const Text('لوحة حساب الشركة والعروض'),
                  subtitle: const Text('إدارة عروض شركتك، التوثيق، وطلبات العملاء'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => unawaited(context.push(AppRoutes.companyDashboard)),
                ),
              ],
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: const Text('المحادثات المباشرة'),
                subtitle: const Text('التواصل الفوري مع المستثمرين والشركاء'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => unawaited(context.push(AppRoutes.chatList)),
              ),
              if (roles.contains('investor') ||
                  roles.contains('project_owner') ||
                  roles.contains('admin')) ...[
                ListTile(
                  leading: const Icon(Icons.handshake_outlined),
                  title: const Text('الصفقات والتمويل الاستثماري'),
                  subtitle: const Text('جداول المعالم، العقود الرقمية، وحساب الضمان'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => unawaited(context.push(AppRoutes.deals)),
                ),
              ],
              const Divider(),

              ListTile(
                leading: const Icon(AppIcons.save),
                title: const Text('الفرص والمشاريع المحفوظة'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => unawaited(context.push(AppRoutes.saved)),
              ),
              ListTile(
                leading: const Icon(AppIcons.steps),
                title: const Text('خطة خطواتي التالية'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => unawaited(context.push(AppRoutes.nextSteps)),
              ),
              ListTile(
                leading: const Icon(Icons.workspace_premium_rounded),
                title: const Text('الباقات والاشتراكات'),
                subtitle: const Text('الباقة الحالية ومزايا الترقية'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => unawaited(context.push('/account/subscription')),
              ),
              const Divider(),

              ListTile(
                leading: const Icon(AppIcons.privacy),
                title: const Text('الخصوصية والأمان وتصدير البيانات'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => unawaited(context.push('/account/privacy')),
              ),
              ListTile(
                leading: const Icon(AppIcons.help),
                title: const Text('المساعدة والأسئلة الشائعة'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => unawaited(context.push('/account/support')),
              ),
              const Gap.lg(),

              // Logout Button with Confirmation Dialog
              ListTile(
                leading: Icon(Icons.logout_rounded, color: context.colors.error),
                title: Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: context.colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content: const Text(
                        'هل أنت متأكد من رغبتك في تسجيل الخروج من هذا الحساب؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(false),
                          child: const Text('إلغاء'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.error,
                          ),
                          onPressed: () => Navigator.of(dialogCtx).pop(true),
                          child: const Text('تسجيل الخروج'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true && context.mounted) {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go(AppRoutes.welcome);
                    }
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('تعذر تحميل بيانات الملف: $err'),
        ),
      ),
    );
  }
}
