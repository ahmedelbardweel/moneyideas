import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/deals/domain/models/deal_models.dart';
import 'package:moneyideas/features/deals/presentation/controllers/deals_controller.dart';
import 'package:moneyideas/features/network/domain/models/network_models.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';

/// Screen for Investor role home view.
/// Focuses on investment criteria, deal flow discovery, startup pitch evaluation, portfolio watchlist, and escrow contracts.
class InvestorHomeView extends ConsumerWidget {
  const InvestorHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorProfileAsync = ref.watch(myInvestorProfileProvider);
    final watchlistAsync = ref.watch(investorWatchlistProvider);
    final dealsAsync = ref.watch(myDealsListProvider(null));
    final projectsAsync = ref.watch(projectsListProvider);
    final requestsAsync = ref.watch(incomingContactRequestsProvider);

    final watchlistCount = watchlistAsync.asData?.value.length ?? 0;
    final deals = dealsAsync.asData?.value ?? [];
    final activeDealsCount = deals
        .where((d) =>
            d.status == DealStatus.escrowFunded ||
            d.status == DealStatus.inProgress)
        .length;
    final availableProjectsCount = projectsAsync.asData?.value.length ?? 0;
    final requestsCount = requestsAsync.asData?.value.length ?? 0;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myInvestorProfileProvider);
        ref.invalidate(investorWatchlistProvider);
        ref.invalidate(myDealsListProvider(null));
        ref.invalidate(projectsListProvider);
        ref.invalidate(incomingContactRequestsProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Investor Criteria & Portfolio Header
            investorProfileAsync.when(
              data: (profile) => _InvestorHeaderCard(profile: profile),
              loading: () => const SizedBox(height: 120),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const Gap.md(),

            // 4 KPIs Grid
            Row(
              children: [
                Expanded(
                  child: _InvestorMetricCard(
                    label: 'قيد الدراسة (Watchlist)',
                    value: '$watchlistCount',
                    icon: Icons.bookmark_added_rounded,
                    color: context.colors.primary,
                  ),
                ),
                const Gap.xs(),
                Expanded(
                  child: _InvestorMetricCard(
                    label: 'صفقات الضمان Escrow',
                    value: '$activeDealsCount',
                    icon: Icons.shield_rounded,
                    color: Colors.green.shade700,
                  ),
                ),
                const Gap.xs(),
                Expanded(
                  child: _InvestorMetricCard(
                    label: 'مشاريع Deal Flow',
                    value: '$availableProjectsCount',
                    icon: Icons.rocket_launch_outlined,
                    color: context.colors.secondary,
                  ),
                ),
                const Gap.xs(),
                Expanded(
                  child: _InvestorMetricCard(
                    label: 'طلبات التواصل',
                    value: '$requestsCount',
                    icon: Icons.chat_outlined,
                    color: context.colors.tertiary,
                  ),
                ),
              ],
            ),
            const Gap.lg(),

            // Fast Action Shortcuts
            Text(
              'أدوات المستثمر الذكي',
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
                    icon: const Icon(Icons.explore_rounded),
                    label: const Text('استكشاف صفقات المشاريع'),
                    onPressed: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(1),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.gavel_rounded),
                    label: const Text('عقود الضمان والوساطة Escrow'),
                    onPressed: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(2),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.playlist_add_check_rounded),
                    label: const Text('قائمة الدراسة المحفوظة'),
                    onPressed: () => unawaited(context.push(AppRoutes.myProjects)),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('تعديل معايير الاستثمار'),
                    onPressed: () =>
                        unawaited(context.push(AppRoutes.editInvestorProfile)),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('المستشار التحليلي'),
                    onPressed: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(3),
                  ),
                ],
              ),
            ),
            const Gap.xl(),

            // Section 1: Top High-Potential Deal Flow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'أبرز الفرص الاستثمارية المتاحة للتمويل',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(roleNavIndexProvider.notifier).setIndex(1),
                  child: const Text('استعراض الكل'),
                ),
              ],
            ),
            const Gap.xs(),

            projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) {
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
                            Icon(Icons.hub_outlined,
                                size: 48, color: context.colors.outline),
                            const Gap.sm(),
                            const Text('لا توجد مشاريع معروضة حالياً'),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: projects.take(3).map((proj) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: context.colors.outlineVariant),
                        borderRadius: AppRadius.mediumAll,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    proj.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    proj.helpNeededType,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap.xs(),
                            Text(
                              proj.summary.isNotEmpty
                                  ? proj.summary
                                  : proj.problemStatement,
                              style: context.textStyles.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap.sm(),
                            Row(
                              children: [
                                Icon(Icons.category_outlined,
                                    size: 14, color: context.colors.primary),
                                const Gap.xxs(),
                                Text(
                                  proj.stage.labelAr,
                                  style: context.textStyles.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.remove_red_eye_outlined,
                                      size: 16),
                                  label: const Text('دراسة العرض والصفقة'),
                                  onPressed: () => unawaited(
                                    context.push('/network/project/${proj.id}'),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

            // Section 2: Active Deals & Escrow Agreements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'صفقاتك وعقود الضمان الجارية',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(roleNavIndexProvider.notifier).setIndex(2),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const Gap.xs(),
            dealsAsync.when(
              data: (deals) {
                if (deals.isEmpty) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: context.colors.outlineVariant),
                      borderRadius: AppRadius.mediumAll,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              color: context.colors.outline),
                          const Gap.md(),
                          const Expanded(
                            child: Text(
                              'لا توجد صفقات استثمار نشطة حالياً. عند الاتفاق مع رائد أعمال، يتم ربط الأموال بحساب الضمان المعتمد.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: () => ref
                                .read(roleNavIndexProvider.notifier)
                                .setIndex(2),
                            child: const Text('بدء صفقة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: deals.take(2).map((deal) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: context.colors.outlineVariant),
                        borderRadius: AppRadius.mediumAll,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.security_rounded,
                              color: Colors.green.shade800),
                        ),
                        title: Text(
                          deal.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'المبلغ: ${deal.targetAmount.toStringAsFixed(0)} AED • ${deal.status.labelAr}',
                          style: context.textStyles.bodySmall,
                        ),
                        trailing: const Icon(Icons.chevron_left_rounded),
                        onTap: () => unawaited(
                          context.push('/deals/details/${deal.id}'),
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

class _InvestorHeaderCard extends StatelessWidget {
  const _InvestorHeaderCard({this.profile});

  final InvestorProfile? profile;

  @override
  Widget build(BuildContext context) {
    final minTicket = profile?.minTicketSize?.toStringAsFixed(0) ?? '50,000';
    final maxTicket = profile?.maxTicketSize?.toStringAsFixed(0) ?? '500,000';
    final currency = profile?.currency ?? 'AED';
    final type = profile?.investorType ?? 'مستثمر ملائكي';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withValues(alpha: 0.1),
            context.colors.primaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: AppRadius.largeAll,
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: context.colors.primary,
                child: Icon(
                  Icons.trending_up_rounded,
                  color: context.colors.onPrimary,
                  size: 26,
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
                          'محفظة المستثمر الذكي',
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
                            color: context.colors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: context.colors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'نطاق التذكرة: من $minTicket إلى $maxTicket $currency',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded),
                tooltip: 'تعديل المعايير',
                onPressed: () =>
                    unawaited(context.push(AppRoutes.editInvestorProfile)),
              ),
            ],
          ),
          if (profile?.sectorsOfInterest.isNotEmpty == true) ...[
            const Gap.sm(),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: profile!.sectorsOfInterest.map((sector) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.outlineVariant),
                  ),
                  child: Text(
                    sector,
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _InvestorMetricCard extends StatelessWidget {
  const _InvestorMetricCard({
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
