import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';

class CompanyStatsScreen extends ConsumerWidget {
  const CompanyStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(companyStatsProvider);
    final offersAsync = ref.watch(companyOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات وتحليلات الأداء'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KPI Grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'إجمالي المشاهدات',
                    value: '${stats['total_views']}',
                    subtitle: 'زيارة لصفحات العروض',
                    icon: Icons.visibility_outlined,
                    color: context.colors.primary,
                  ),
                ),
                const Gap.md(),
                Expanded(
                  child: _StatCard(
                    title: 'طلبات العملاء',
                    value: '${stats['total_leads']}',
                    subtitle: 'استفسارات مباشرة',
                    icon: Icons.mark_email_read_outlined,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            const Gap.md(),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'معدل التحويل',
                    value: '${stats['conversion_rate']}%',
                    subtitle: 'من مشاهدة إلى طلب',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const Gap.md(),
                Expanded(
                  child: _StatCard(
                    title: 'العروض النشطة',
                    value: '${stats['active_offers']}',
                    subtitle: 'عروض معتمدة من الإدارة',
                    icon: Icons.verified_outlined,
                    color: const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            const Gap.xl(),

            // Top Performing Offers
            Text(
              'أداء العروض التجارية',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),

            offersAsync.when(
              data: (offers) {
                if (offers.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text('لا توجد عروض كافية لحساب الإحصائيات'),
                    ),
                  );
                }

                return Column(
                  children: offers.map((offer) {
                    final conversion = offer.viewsCount > 0
                        ? ((offer.leadsCount / offer.viewsCount) * 100)
                            .toStringAsFixed(1)
                        : '0.0';

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                        side: BorderSide(
                          color: context.colors.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.title,
                              style: context.textStyles.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap.xs(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المشاهدات: ${offer.viewsCount}',
                                  style: context.textStyles.bodySmall,
                                ),
                                Text(
                                  'الطلبات: ${offer.leadsCount}',
                                  style: context.textStyles.bodySmall,
                                ),
                                Text(
                                  'التحويل: $conversion%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Gap.xs(),
                            LinearProgressIndicator(
                              value: (offer.viewsCount > 0)
                                  ? (offer.leadsCount / offer.viewsCount)
                                      .clamp(0.0, 1.0)
                                  : 0,
                              color: context.colors.primary,
                              backgroundColor:
                                  context.colors.surfaceContainerHighest,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('خطأ: $err')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(
          color: context.colors.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Gap.sm(),
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
              style: context.textStyles.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: context.textStyles.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
