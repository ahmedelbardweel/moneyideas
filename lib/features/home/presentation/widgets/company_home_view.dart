import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';
import 'package:moneyideas/features/company/presentation/widgets/company_verification_badge.dart';

/// Screen for Company / Provider role home view.
/// Displays company identity, real-time performance KPIs, active offers, inbound leads, and quick franchise management.
class CompanyHomeView extends ConsumerWidget {
  const CompanyHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyAsync = ref.watch(myCompanyProvider);
    final offersAsync = ref.watch(companyOffersProvider);
    final leadsAsync = ref.watch(companyLeadsProvider);
    final stats = ref.watch(companyStatsProvider);

    return companyAsync.when(
      data: (company) {
        if (company == null) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.domain_add_rounded,
                      size: 64,
                      color: context.colors.primary,
                    ),
                  ),
                  const Gap.lg(),
                  Text(
                    'ابدأ بنشر عروض شركتك المعتمدة',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap.sm(),
                  Text(
                    'سجّل حساب شركتك التجارية لتوثيق رخصتك ونشر عروض الخدمات والشراكات للآلاف من الباحثين عن فرص استثمارية.',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap.xl(),
                  AppButton(
                    text: 'تسجيل شركة جديدة الآن',
                    onPressed: () => unawaited(context.push('/company/create')),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myCompanyProvider);
            ref.invalidate(companyOffersProvider);
            ref.invalidate(companyLeadsProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Company Identity Header
                _CompanyHeaderCard(company: company),
                const Gap.md(),

                // Verification Warning Banner if not verified
                if (company.verificationStatus != CompanyVerificationStatus.verified) ...[
                  _VerificationBanner(company: company),
                  const Gap.md(),
                ],

                // Performance Metrics Grid
                _CompanyMetricsGrid(stats: stats),
                const Gap.lg(),

                // Fast Action Shortcuts
                Text(
                  'إجراءات سريعة للشركة',
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap.sm(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _QuickActionChip(
                        icon: Icons.add_circle_rounded,
                        label: 'إضافة عرض جديد',
                        isPrimary: true,
                        onTap: () => unawaited(context.push(AppRoutes.companyCreateOffer)),
                      ),
                      const Gap.sm(),
                      _QuickActionChip(
                        icon: Icons.assignment_ind_rounded,
                        label: 'طلبات العملاء Leads',
                        onTap: () =>
                            ref.read(roleNavIndexProvider.notifier).setIndex(2),
                      ),
                      const Gap.sm(),
                      _QuickActionChip(
                        icon: Icons.list_alt_rounded,
                        label: 'إدارة العروض',
                        onTap: () =>
                            ref.read(roleNavIndexProvider.notifier).setIndex(1),
                      ),
                      const Gap.sm(),
                      _QuickActionChip(
                        icon: Icons.campaign_rounded,
                        label: 'الحملات الترويجية',
                        onTap: () =>
                            ref.read(roleNavIndexProvider.notifier).setIndex(3),
                      ),
                      const Gap.sm(),
                      _QuickActionChip(
                        icon: Icons.verified_user_rounded,
                        label: 'توثيق الشركة',
                        onTap: () => unawaited(context.push(AppRoutes.companyVerify)),
                      ),
                    ],
                  ),
                ),
                const Gap.xl(),

                // Section: Active Commercial Offers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'عروض الشركة المنشورة',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(roleNavIndexProvider.notifier).setIndex(1),
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
                const Gap.xs(),
                offersAsync.when(
                  data: (offers) {
                    if (offers.isEmpty) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: context.colors.outlineVariant),
                          borderRadius: AppRadius.mediumAll,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.storefront_outlined,
                                    size: 40, color: context.colors.outline),
                                const Gap.sm(),
                                const Text('لا توجد عروض منشورة حتى الآن'),
                                const Gap.xs(),
                                TextButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('إنشاء أول عرض تجاري'),
                                  onPressed: () => unawaited(
                                    context.push(AppRoutes.companyCreateOffer),
                                  ),
                                ),
                              ],
                            ),
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            title: Text(
                              offer.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${offer.price?.toStringAsFixed(0) ?? 'حسب الاتفاق'} ${offer.priceCurrency} • ${offer.viewsCount} مشاهدة • ${offer.detailsOpenedCount} تفاعل',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                            trailing: _OfferStatusPill(status: offer.status),
                            onTap: () => unawaited(
                              context.push('/company/offer/${offer.id}'),
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
                  error: (err, _) => Text('خطأ في تحميل العروض: $err'),
                ),
                const Gap.lg(),

                // Section: Inbound Leads
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أحدث طلبات التواصل والامتياز',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(roleNavIndexProvider.notifier).setIndex(2),
                      child: const Text('إدارة الطلبات'),
                    ),
                  ],
                ),
                const Gap.xs(),
                leadsAsync.when(
                  data: (leads) {
                    if (leads.isEmpty) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: context.colors.outlineVariant),
                          borderRadius: AppRadius.mediumAll,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.people_outline_rounded,
                                    size: 40, color: context.colors.outline),
                                const Gap.sm(),
                                const Text(
                                  'ستظهر هنا طلبات المستثمرين والرواد الراغبين في التعاقد مع شركتك',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: leads.take(3).map((lead) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: context.colors.outlineVariant),
                            borderRadius: AppRadius.mediumAll,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: context.colors.primaryContainer,
                              child: Text(
                                lead.userName?.isNotEmpty == true
                                    ? lead.userName![0]
                                    : '؟',
                                style: TextStyle(
                                  color: context.colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              lead.userName ?? 'طلب مهتم جديد',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              lead.userPhone ?? lead.userEmail ?? 'معلومات التواصل محفوظة',
                              style: context.textStyles.bodySmall,
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'جديد',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () => ref
                                .read(roleNavIndexProvider.notifier)
                                .setIndex(2),
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('خطأ: $err')),
    );
  }
}

class _CompanyHeaderCard extends StatelessWidget {
  const _CompanyHeaderCard({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withValues(alpha: 0.08),
            context.colors.primaryContainer.withValues(alpha: 0.25),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: AppRadius.largeAll,
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: context.colors.primary,
            child: Text(
              company.tradeName.isNotEmpty
                  ? company.tradeName[0]
                  : (company.legalName.isNotEmpty ? company.legalName[0] : 'ش'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.colors.onPrimary,
              ),
            ),
          ),
          const Gap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        company.tradeName.isNotEmpty
                            ? company.tradeName
                            : company.legalName,
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap.xs(),
                    CompanyVerificationBadge(status: company.verificationStatus),
                  ],
                ),
                const Gap.xxs(),
                Text(
                  'رخصة: ${company.tradeLicenseNumber} • ${company.businessType}',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'إعدادات الشركة',
            onPressed: () => unawaited(context.push('/company/settings')),
          ),
        ],
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  const _VerificationBanner({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.errorContainer.withValues(alpha: 0.35),
        borderRadius: AppRadius.mediumAll,
        border: Border.all(
          color: context.colors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: context.colors.error),
          const Gap.sm(),
          Expanded(
            child: Text(
              'حساب الشركة بانتظار استكمال التوثيق التجاري لزيادة مصداقية العروض.',
              style: context.textStyles.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () => unawaited(context.push(AppRoutes.companyVerify)),
            child: const Text('توثيق الآن'),
          ),
        ],
      ),
    );
  }
}

class _CompanyMetricsGrid extends StatelessWidget {
  const _CompanyMetricsGrid({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'إجمالي المشاهدات',
            value: '${stats['total_views'] ?? 0}',
            icon: Icons.visibility_rounded,
            color: context.colors.primary,
          ),
        ),
        const Gap.xs(),
        Expanded(
          child: _MetricCard(
            label: 'طلبات الامتياز Leads',
            value: '${stats['total_leads'] ?? 0}',
            icon: Icons.group_add_rounded,
            color: context.colors.tertiary,
          ),
        ),
        const Gap.xs(),
        Expanded(
          child: _MetricCard(
            label: 'العروض النشطة',
            value: '${stats['active_offers'] ?? 0}',
            icon: Icons.verified_outlined,
            color: context.colors.secondary,
          ),
        ),
        const Gap.xs(),
        Expanded(
          child: _MetricCard(
            label: 'معدل التحويل',
            value: '${stats['conversion_rate'] ?? '0.0'}%',
            icon: Icons.trending_up_rounded,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onTap,
      );
    }

    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _OfferStatusPill extends StatelessWidget {
  const _OfferStatusPill({required this.status});

  final OfferStatus status;

  @override
  Widget build(BuildContext context) {
    final col = switch (status) {
      OfferStatus.approved => Colors.green.shade700,
      OfferStatus.inReview => Colors.orange.shade800,
      OfferStatus.needsChanges => Colors.amber.shade900,
      OfferStatus.rejected => context.colors.error,
      OfferStatus.paused => Colors.blueGrey,
      OfferStatus.expired || OfferStatus.archived || OfferStatus.draft =>
        context.colors.outline,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: col.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.labelAr,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: col,
        ),
      ),
    );
  }
}
