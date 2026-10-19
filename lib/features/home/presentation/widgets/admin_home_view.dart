import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/admin/domain/models/admin_models.dart';
import 'package:moneyideas/features/admin/presentation/controllers/admin_controller.dart';

/// Screen for Super Admin role home view.
/// Platform command center with governance KPIs, pending verification queues, and audit tools.
class AdminHomeView extends ConsumerWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(adminKpisProvider);
    final pendingOffersAsync = ref.watch(adminOffersProvider('in_review'));
    final pendingCompaniesAsync =
        ref.watch(adminCompaniesProvider('pending_review'));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminKpisProvider);
        ref.invalidate(adminOffersProvider('in_review'));
        ref.invalidate(adminCompaniesProvider('pending_review'));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin Command Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.error.withValues(alpha: 0.1),
                    context.colors.errorContainer.withValues(alpha: 0.35),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: AppRadius.largeAll,
                border: Border.all(
                  color: context.colors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: context.colors.error,
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: context.colors.onError,
                      size: 28,
                    ),
                  ),
                  const Gap.md(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'مركز القيادة والرقابة العليا',
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap.xs(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.error,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Super Admin',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onError,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap.xxs(),
                        Text(
                          'نظام الرقابة والحوكمة: متصل ونشط',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'تحديث المؤشرات',
                    onPressed: () => ref.invalidate(adminKpisProvider),
                  ),
                ],
              ),
            ),
            const Gap.md(),

            // 6 KPIs Grid
            kpisAsync.when(
              data: (kpis) => _AdminKpisGrid(kpis: kpis),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text('خطأ في تحميل مؤشرات الإدارة: $err'),
            ),
            const Gap.lg(),

            // Fast Governance Action Shortcuts
            Text(
              'أدوات الحوكمة والإدارة',
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.rule_folder_rounded),
                    label: const Text('تدقيق واعتماد العروض'),
                    onPressed: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(1),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.verified_user_rounded),
                    label: const Text('توثيق الشركات'),
                    onPressed: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(2),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.manage_accounts_rounded),
                    label: const Text('إدارة المستخدمين'),
                    onPressed: () => unawaited(context.push(AppRoutes.adminUsers)),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.shield_rounded),
                    label: const Text('مراجعة صفقات الضمان'),
                    onPressed: () => unawaited(context.push(AppRoutes.deals)),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.report_problem_rounded),
                    label: const Text('بلاغات المحتوى'),
                    onPressed: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(3),
                  ),
                ],
              ),
            ),
            const Gap.xl(),

            // Urgent Queue 1: Pending Offers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عروض تجارية بانتظار الاعتماد',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(roleNavIndexProvider.notifier).setIndex(1),
                  child: const Text('فحص الكل'),
                ),
              ],
            ),
            const Gap.xs(),
            pendingOffersAsync.when(
              data: (offers) {
                if (offers.isEmpty) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: context.colors.outlineVariant),
                      borderRadius: AppRadius.mediumAll,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green),
                          Gap.md(),
                          Text('لا توجد عروض معلقة بانتظار المراجعة'),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: offers.take(3).map((offer) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: context.colors.outlineVariant),
                        borderRadius: AppRadius.mediumAll,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Icon(Icons.pending_actions,
                              color: Colors.orange.shade800),
                        ),
                        title: Text(
                          offer.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'المبلغ: ${offer.price?.toStringAsFixed(0) ?? 'حسب الاتفاق'} ${offer.priceCurrency}',
                          style: context.textStyles.bodySmall,
                        ),
                        trailing: FilledButton.tonal(
                          onPressed: () => unawaited(
                            context.push('/company/offer/${offer.id}'),
                          ),
                          child: const Text('تدقيق'),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text('خطأ: $err'),
            ),
            const Gap.lg(),

            // Urgent Queue 2: Pending Company Verifications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'شركات بانتظار تدقيق السجل التجاري',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(roleNavIndexProvider.notifier).setIndex(2),
                  child: const Text('فحص الشركات'),
                ),
              ],
            ),
            const Gap.xs(),
            pendingCompaniesAsync.when(
              data: (companies) {
                if (companies.isEmpty) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: context.colors.outlineVariant),
                      borderRadius: AppRadius.mediumAll,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green),
                          Gap.md(),
                          Text('لا توجد طلبات توثيق شركات معلقة'),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: companies.take(3).map((comp) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: context.colors.outlineVariant),
                        borderRadius: AppRadius.mediumAll,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              context.colors.primaryContainer.withValues(alpha: 0.5),
                          child: Text(
                            comp.tradeName.isNotEmpty
                                ? comp.tradeName[0]
                                : (comp.legalName.isNotEmpty
                                    ? comp.legalName[0]
                                    : 'ش'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          comp.tradeName.isNotEmpty
                              ? comp.tradeName
                              : comp.legalName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'رخصة: ${comp.tradeLicenseNumber} • ${comp.businessType}',
                          style: context.textStyles.bodySmall,
                        ),
                        trailing: FilledButton.tonal(
                          onPressed: () => unawaited(
                            context.push(AppRoutes.adminCompanies),
                          ),
                          child: const Text('مراجعة'),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, _) => const SizedBox.shrink(),
            ),
            const Gap.xxl(),
          ],
        ),
      ),
    );
  }
}

class _AdminKpisGrid extends StatelessWidget {
  const _AdminKpisGrid({required this.kpis});

  final AdminKpiStats kpis;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AdminKpiTile(
                label: 'إجمالي المستخدمين',
                value: '${kpis.totalUsersCount}',
                icon: Icons.people_alt_rounded,
                color: context.colors.primary,
              ),
            ),
            const Gap.xs(),
            Expanded(
              child: _AdminKpiTile(
                label: 'الشركات النشطة',
                value: '${kpis.activeCompaniesCount}',
                icon: Icons.verified_rounded,
                color: Colors.green.shade700,
              ),
            ),
            const Gap.xs(),
            Expanded(
              child: _AdminKpiTile(
                label: 'عروض قيد التدقيق',
                value: '${kpis.pendingOffersCount}',
                icon: Icons.hourglass_top_rounded,
                color: Colors.orange.shade800,
              ),
            ),
          ],
        ),
        const Gap.xs(),
        Row(
          children: [
            Expanded(
              child: _AdminKpiTile(
                label: 'شركات قيد التوثيق',
                value: '${kpis.pendingCompaniesCount}',
                icon: Icons.domain_verification_rounded,
                color: context.colors.secondary,
              ),
            ),
            const Gap.xs(),
            Expanded(
              child: _AdminKpiTile(
                label: 'مشاريع قيد المراجعة',
                value: '${kpis.pendingProjectsCount}',
                icon: Icons.rocket_launch_rounded,
                color: context.colors.tertiary,
              ),
            ),
            const Gap.xs(),
            Expanded(
              child: _AdminKpiTile(
                label: 'بلاغات مفتوحة',
                value: '${kpis.pendingReportsCount}',
                icon: Icons.report_problem_rounded,
                color: context.colors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminKpiTile extends StatelessWidget {
  const _AdminKpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.mediumAll,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const Gap.xxs(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              fontSize: 9,
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
