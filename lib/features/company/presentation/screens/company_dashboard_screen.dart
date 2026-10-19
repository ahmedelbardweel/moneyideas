import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/auth/presentation/controllers/auth_controller.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';
import 'package:moneyideas/features/company/presentation/widgets/company_verification_badge.dart';
import 'package:moneyideas/features/company/presentation/widgets/offer_card.dart';

class CompanyDashboardScreen extends ConsumerWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyAsync = ref.watch(myCompanyProvider);
    final offersAsync = ref.watch(companyOffersProvider);
    final stats = ref.watch(companyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الشركة والعروض'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'إعدادات الشركة والفريق',
            onPressed: () => unawaited(context.push('/company/settings')),
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: context.colors.error),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text(
                    'هل أنت متأكد من تسجيل الخروج من لوحة حساب الشركة؟',
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
      body: companyAsync.when(
        data: (company) {
          if (company == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer.withOpacity(0.3),
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
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Company Identity Header
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colors.primary.withOpacity(0.08),
                          context.colors.primaryContainer.withOpacity(0.2),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: AppRadius.xlAll,
                      border: Border.all(
                        color: context.colors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: context.colors.primary,
                              child: Text(
                                company.tradeName.isNotEmpty
                                    ? company.tradeName.characters.first
                                    : 'C',
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
                                  Text(
                                    company.tradeName,
                                    style: context.textStyles.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap.xxs(),
                                  Text(
                                    '${company.businessType} • ${company.city}',
                                    style: context.textStyles.bodySmall?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap.md(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CompanyVerificationBadge(
                              status: company.verificationStatus,
                            ),
                            if (!company.isVerified)
                              TextButton.icon(
                                icon: const Icon(Icons.upload_file_rounded, size: 16),
                                label: const Text('رفع مستندات التوثيق'),
                                onPressed: () =>
                                    unawaited(context.push('/company/verify')),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // KPI Performance Metrics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مؤشرات الأداء السريع',
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap.sm(),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'إجمالي المشاهدات',
                                value: '${stats['total_views']}',
                                icon: Icons.visibility_outlined,
                                color: context.colors.primary,
                              ),
                            ),
                            const Gap.sm(),
                            Expanded(
                              child: _MetricCard(
                                title: 'قراءات التفاصيل',
                                value: '${stats['total_opens']}',
                                icon: Icons.chrome_reader_mode_outlined,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const Gap.sm(),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'العملاء المهتمين',
                                value: '${stats['total_leads']}',
                                icon: Icons.people_alt_outlined,
                                color: const Color(0xFF1565C0),
                                onTap: () => unawaited(context.push('/company/leads')),
                              ),
                            ),
                            const Gap.sm(),
                            Expanded(
                              child: _MetricCard(
                                title: 'معدل التحويل',
                                value: '${stats['conversion_rate']}%',
                                icon: Icons.trending_up_rounded,
                                color: const Color(0xFFE65100),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap.lg(),

                  // Quick Action Hub
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.mdAll,
                              ),
                            ),
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            label: const Text('إنشاء عرض جديد'),
                            onPressed: () =>
                                unawaited(context.push('/company/offers/new')),
                          ),
                        ),
                        const Gap.sm(),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.mdAll,
                            ),
                          ),
                          icon: const Icon(Icons.mail_outline_rounded),
                          label: const Text('الطلبات'),
                          onPressed: () =>
                              unawaited(context.push('/company/leads')),
                        ),
                      ],
                    ),
                  ),
                  const Gap.xl(),

                  // Navigation Shortcut Tiles
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.lgAll,
                        side: BorderSide(
                          color: context.colors.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.local_offer_outlined),
                            title: const Text('إدارة جميع العروض التجارية'),
                            subtitle: Text(
                              '${stats['active_offers']} عروض نشطة ومنشورة',
                            ),
                            trailing: const Icon(Icons.chevron_left_rounded),
                            onTap: () => unawaited(context.push('/company/offers')),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.analytics_outlined),
                            title: const Text('التحليلات التفصيلية وسلوك الزوار'),
                            trailing: const Icon(Icons.chevron_left_rounded),
                            onTap: () => unawaited(context.push('/company/stats')),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.campaign_outlined),
                            title: const Text('الحملات الإعلانية الممولة'),
                            subtitle: const Text('زيادة ظهور عروضك في المنصة'),
                            trailing: const Icon(Icons.chevron_left_rounded),
                            onTap: () =>
                                unawaited(context.push('/company/campaigns')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap.xl(),

                  // Recent Offers Preview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'أحدث العروض التجارية',
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              unawaited(context.push('/company/offers')),
                          child: const Text('عرض الكل'),
                        ),
                      ],
                    ),
                  ),

                  offersAsync.when(
                    data: (offers) {
                      if (offers.isEmpty) {
                        return Container(
                          margin: const EdgeInsets.all(AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerLowest,
                            borderRadius: AppRadius.lgAll,
                            border: Border.all(
                              color: context.colors.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 48,
                                color: context.colors.outline,
                              ),
                              const Gap.sm(),
                              const Text('لا توجد عروض منشورة حتى الآن'),
                              const Gap.sm(),
                              TextButton(
                                onPressed: () => unawaited(
                                  context.push('/company/offers/new'),
                                ),
                                child: const Text('أضف أول عرض تجاري لشركتك'),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: offers.take(3).map((offer) {
                          return OfferCard(
                            offer: offer,
                            isOwner: true,
                            onTap: () => unawaited(
                              context.push('/offer/${offer.id}'),
                            ),
                            onDuplicate: () async {
                              final res = await ref
                                  .read(companyOffersProvider.notifier)
                                  .duplicateOffer(offer.id);
                              if (context.mounted && res.isSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم نسخ العرض كمسودة جديدة بنجاح'),
                                  ),
                                );
                              }
                            },
                            onTogglePause: () async {
                              final newStatus =
                                  offer.status == OfferStatus.paused
                                      ? OfferStatus.approved
                                      : OfferStatus.paused;
                              await ref
                                  .read(companyOffersProvider.notifier)
                                  .updateStatus(offer.id, newStatus);
                            },
                            onViewReview: () => unawaited(
                              context.push('/company/offers/${offer.id}/review'),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text('خطأ في تحميل العروض: $e'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('تعذر تحميل اللوحة: $err')),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(
          color: context.colors.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 20),
                  if (onTap != null)
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ],
              ),
              const Gap.xs(),
              Text(
                value,
                style: context.textStyles.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Gap.xxs(),
              Text(
                title,
                style: context.textStyles.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
