import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/deals/domain/models/deal_models.dart';
import 'package:moneyideas/features/deals/presentation/controllers/deals_controller.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';

/// Screen for Project Owner / Startup Founder role home view.
/// Focuses on venture showcase, funding progress bars, investor inquiries, escrow milestones, and pitch decks.
class ProjectOwnerHomeView extends ConsumerWidget {
  const ProjectOwnerHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProjectsAsync = ref.watch(myProjectsProvider);
    final incomingRequestsAsync = ref.watch(incomingContactRequestsProvider);
    final dealsAsync = ref.watch(myDealsListProvider(null));
    final investorsAsync = ref.watch(investorsListProvider(null));

    final projects = myProjectsAsync.asData?.value ?? [];
    final incomingCount = incomingRequestsAsync.asData?.value.length ?? 0;
    final activeDealsCount = dealsAsync.asData?.value
            .where((d) =>
                d.status == DealStatus.escrowFunded ||
                d.status == DealStatus.inProgress)
            .length ??
        0;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myProjectsProvider);
        ref.invalidate(incomingContactRequestsProvider);
        ref.invalidate(myDealsListProvider(null));
        ref.invalidate(investorsListProvider(null));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Founder Hub Header Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.secondary.withValues(alpha: 0.1),
                    context.colors.secondaryContainer.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: AppRadius.largeAll,
                border: Border.all(
                  color: context.colors.secondary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: context.colors.secondary,
                        child: Icon(
                          Icons.rocket_launch_rounded,
                          color: context.colors.onSecondary,
                          size: 26,
                        ),
                      ),
                      const Gap.md(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مساحة رائد الأعمال والمشاريع',
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'إدارة جولات التمويل، التواصل مع المستثمرين، وحسابات الضمان',
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
                  const Divider(),
                  const Gap.xs(),
                  // Overview stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatMini(
                          label: 'المشاريع المعروضة',
                          value: '${projects.length}',
                          icon: Icons.lightbulb_outline,
                        ),
                      ),
                      Expanded(
                        child: _StatMini(
                          label: 'المشاريع النشطة',
                          value: '${projects.where((p) => p.isPublished).length}',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      Expanded(
                        child: _StatMini(
                          label: 'طلبات المستثمرين',
                          value: '$incomingCount',
                          icon: Icons.mark_email_unread_outlined,
                        ),
                      ),
                      Expanded(
                        child: _StatMini(
                          label: 'صفقات الضمان',
                          value: '$activeDealsCount',
                          icon: Icons.shield_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap.md(),

            // Fast Action Shortcuts
            Text(
              'أدوات رائد الأعمال',
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
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('طرح مشروع جديد'),
                    onPressed: () => unawaited(context.push(AppRoutes.createProject)),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.folder_shared_rounded),
                    label: const Text('مشاريعي المعروضة'),
                    onPressed: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(1),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.gavel_rounded),
                    label: const Text('عقود الضمان Escrow'),
                    onPressed: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(2),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: const Text('استفسارات المستثمرين'),
                    onPressed: () => unawaited(context.push(AppRoutes.contactRequests)),
                  ),
                  const Gap.sm(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('مستشار الـ Pitch'),
                    onPressed: () => unawaited(context.push(AppRoutes.assistant)),
                  ),
                ],
              ),
            ),
            const Gap.xl(),

            // Section 1: My Ventures Showcase
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مشاريعي الاستثمارية',
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

            myProjectsAsync.when(
              data: (list) {
                if (list.isEmpty) {
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
                            Icon(Icons.rocket_outlined,
                                size: 48, color: context.colors.outline),
                            const Gap.sm(),
                            const Text(
                              'لم تقم بطرح أي مشروع استثماري حتى الآن',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Gap.xxs(),
                            const Text(
                              'اطرح فكرتك أو شركتك الناشئة أمام المستثمرين الملائكيين والصناديق',
                              textAlign: TextAlign.center,
                            ),
                            const Gap.md(),
                            FilledButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('طرح مشروعك الأول الآن'),
                              onPressed: () =>
                                  unawaited(context.push(AppRoutes.createProject)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: list.take(3).map((proj) {
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
                                      fontSize: 15,
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
                                    color: context.colors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    proj.stage.labelAr,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.onSecondaryContainer,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'الدعم المطلوب: ${proj.helpNeededType}',
                                    style: context.textStyles.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.secondary,
                                    ),
                                  ),
                                ),
                                if (proj.categoryNameAr != null)
                                  Text(
                                    proj.categoryNameAr!,
                                    style: context.textStyles.labelSmall?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                            const Gap.xs(),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: const Text('عرض صفحة المشروع والـ Pitch Deck'),
                                onPressed: () => unawaited(
                                  context.push('/network/project/${proj.id}'),
                                ),
                              ),
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

            // Section 2: Active Deals & Escrow Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'صفقات التمويل ومراحل الإنجاز (Escrow)',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(roleNavIndexProvider.notifier).setIndex(2),
                  child: const Text('مركز الصفقات'),
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
                              'لا توجد صفقات تمويل جارية حالياً. يمكنك إنشاء اتفاقية استثمار موثقة عبر حساب الضمان.',
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
                          backgroundColor:
                              context.colors.primaryContainer.withValues(alpha: 0.5),
                          child: Icon(Icons.handshake_rounded,
                              color: context.colors.primary),
                        ),
                        title: Text(
                          deal.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'قيمة التمويل: ${deal.targetAmount.toStringAsFixed(0)} AED • ${deal.status.labelAr}',
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
            const Gap.lg(),

            // Section 3: Potential Investors to Pitch to
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مستثمرون نشطون في شبكة الأعمال',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(roleNavIndexProvider.notifier).setIndex(3),
                  child: const Text('دليل المستثمرين'),
                ),
              ],
            ),
            const Gap.xs(),
            investorsAsync.when(
              data: (investors) {
                if (investors.isEmpty) return const SizedBox.shrink();

                return Column(
                  children: investors.take(2).map((inv) {
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
                            inv.fullName?.isNotEmpty == true
                                ? inv.fullName![0]
                                : 'م',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                        title: Text(
                          inv.fullName ?? 'مستثمر ملائكي',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'تذكرة الاستثمار: ${inv.minTicketSize?.toStringAsFixed(0) ?? '50k'} - ${inv.maxTicketSize?.toStringAsFixed(0) ?? '500k'} ${inv.currency}',
                          style: context.textStyles.bodySmall,
                        ),
                        trailing: FilledButton.tonal(
                          onPressed: () => unawaited(
                            context.push('/network/investor/${inv.userId}'),
                          ),
                          child: const Text('طلب تواصل'),
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

class _StatMini extends StatelessWidget {
  const _StatMini({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: context.colors.secondary),
        const Gap.xxs(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
    );
  }
}
