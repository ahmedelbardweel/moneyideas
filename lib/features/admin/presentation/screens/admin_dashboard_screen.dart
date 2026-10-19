import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/admin/presentation/controllers/admin_controller.dart';
import 'package:moneyideas/features/auth/presentation/controllers/auth_controller.dart';

/// Screen 83: Super Admin Command Center & Platform Governance Dashboard.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(adminKpisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة العليا'),
        actions: [
          IconButton(
            tooltip: 'تحديث البيانات',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminKpisProvider),
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: Icon(Icons.logout_rounded, color: context.colors.error),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text(
                    'هل أنت متأكد من تسجيل الخروج من لوحة الإدارة؟',
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
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(adminKpisProvider.future),
          child: ListView(
            padding: AppSpacing.page,
            children: [
              // Admin Header Banner
              Card(
                color: context.colors.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mediumAll,
                ),
                elevation: 0,
                child: Padding(
                  padding: AppSpacing.card,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: context.colors.primary,
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: context.colors.onPrimary,
                          size: 32,
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
                                  'مركز الإدارة والرقابة',
                                  style: context.textStyles.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.onPrimaryContainer,
                                  ),
                                ),
                                const Gap.xs(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Super Admin',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap.xxs(),
                            Text(
                              'إدارة وتدقيق جميع العمليات والمستخدمين والشركات وقاعدة البيانات في سوبابيز بالكامل وبدون قيود.',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: context.colors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap.lg(),

              // Live KPIs Grid
              Text(
                'مؤشرات المنصة الحية',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap.sm(),

              kpisAsync.when(
                data: (kpis) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _KpiMetricCard(
                            title: 'شركات بانتظار التوثيق',
                            count: kpis.pendingCompaniesCount,
                            icon: Icons.domain_verification_rounded,
                            color: kpis.pendingCompaniesCount > 0
                                ? context.colors.error
                                : context.colors.primary,
                            onTap: () => context.push(AppRoutes.adminCompanies),
                          ),
                        ),
                        const Gap.sm(),
                        Expanded(
                          child: _KpiMetricCard(
                            title: 'عروض بانتظار التدقيق',
                            count: kpis.pendingOffersCount,
                            icon: Icons.rate_review_rounded,
                            color: kpis.pendingOffersCount > 0
                                ? Colors.orange.shade700
                                : context.colors.primary,
                            onTap: () => context.push(AppRoutes.adminOffers),
                          ),
                        ),
                      ],
                    ),
                    const Gap.sm(),
                    Row(
                      children: [
                        Expanded(
                          child: _KpiMetricCard(
                            title: 'بلاغات تحتاج إجراء',
                            count: kpis.pendingReportsCount,
                            icon: Icons.report_problem_rounded,
                            color: kpis.pendingReportsCount > 0
                                ? context.colors.error
                                : Colors.teal,
                            onTap: () => context.push(AppRoutes.adminReports),
                          ),
                        ),
                        const Gap.sm(),
                        Expanded(
                          child: _KpiMetricCard(
                            title: 'إجمالي المستخدمين',
                            count: kpis.totalUsersCount,
                            icon: Icons.people_alt_rounded,
                            color: Colors.blue.shade700,
                            onTap: () => context.push(AppRoutes.adminUsers),
                          ),
                        ),
                      ],
                    ),
                    const Gap.sm(),
                    Row(
                      children: [
                        Expanded(
                          child: _KpiMetricCard(
                            title: 'شركات موثقة نشطة',
                            count: kpis.activeCompaniesCount,
                            icon: Icons.verified_rounded,
                            color: Colors.green.shade700,
                            onTap: () => context.push(AppRoutes.adminCompanies),
                          ),
                        ),
                        const Gap.sm(),
                        Expanded(
                          child: _KpiMetricCard(
                            title: 'عروض معتمدة منشورة',
                            count: kpis.activeOffersCount,
                            icon: Icons.local_offer_rounded,
                            color: Colors.purple.shade700,
                            onTap: () => context.push(AppRoutes.adminOffers),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Center(
                  child: Text('خطأ في تحميل الإحصائيات: $e'),
                ),
              ),

              const Gap.xl(),
              Text(
                'أقسام الإدارة والتحكم الكامل',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap.sm(),

              // Sections
              _AdminActionTile(
                icon: Icons.verified_user_rounded,
                title: 'تدقيق وتوثيق الشركات (Commercial Verification)',
                subtitle: 'فحص الرخص التجارية DED واعتماد أو رفض توثيق الشركات',
                color: Colors.indigo,
                onTap: () => context.push(AppRoutes.adminCompanies),
              ),
              _AdminActionTile(
                icon: Icons.assignment_turned_in_rounded,
                title: 'مراجعة وتدقيق العروض التجارية (Offers Audit)',
                subtitle: 'فحص عروض الخدمات والأسعار، بنود الشفافية، والموافقة أو الرفض',
                color: Colors.teal,
                onTap: () => context.push(AppRoutes.adminOffers),
              ),
              _AdminActionTile(
                icon: Icons.manage_accounts_rounded,
                title: 'إدارة المستخدمين والأدوار (Users & Roles Governance)',
                subtitle: 'البحث عن المستخدمين، حظر الحسابات، وتعيين صلاحيات الأدمن والشركات',
                color: Colors.blue,
                onTap: () => context.push(AppRoutes.adminUsers),
              ),
              _AdminActionTile(
                icon: Icons.shield_rounded,
                title: 'البلاغات والنزاهة وحماية المنصة (Reports & Moderation)',
                subtitle: 'التحقيق في شكاوى المستخدمين وعروض الاحتيال واتخاذ القرارات',
                color: Colors.redAccent,
                onTap: () => context.push(AppRoutes.adminReports),
              ),

              const Gap.xl(),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiMetricCard extends StatelessWidget {
  const _KpiMetricCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.colors.outlineVariant),
        borderRadius: AppRadius.mediumAll,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mediumAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Text(
                    '$count',
                    style: context.textStyles.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const Gap.sm(),
              Text(
                title,
                style: context.textStyles.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  const _AdminActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.colors.outlineVariant),
        borderRadius: AppRadius.mediumAll,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.sm),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
