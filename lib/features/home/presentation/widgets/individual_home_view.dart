import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/states/data_quality_badge.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/discover/domain/models/category_model.dart';
import 'package:moneyideas/features/discover/presentation/controllers/discover_controller.dart';
import 'package:moneyideas/features/discover/presentation/widgets/opportunity_card.dart';
import 'package:moneyideas/features/profile_setup/presentation/controllers/profile_setup_controller.dart';

/// Screen for Individual / Seeker role home view.
/// Focuses on matching opportunities, AI advisor discovery, profile completeness, and sector exploration.
class IndividualHomeView extends ConsumerWidget {
  const IndividualHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupData = ref.watch(profileSetupProvider);
    final opportunitiesAsync = ref.watch(opportunitiesListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final completionScore = setupData.completenessPercentage;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(opportunitiesListProvider);
        ref.invalidate(categoriesListProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytical Profile Health Banner
            if (completionScore < 100)
              _ProfileHealthCard(
                score: completionScore,
                onComplete: () => unawaited(context.push(AppRoutes.setup)),
              ),
            if (completionScore < 100) const Gap.md(),

            // Fast Action Shortcuts
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: AppIcons.discover,
                    label: 'سوق الفرص',
                    color: context.colors.primary,
                    onTap: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(1),
                  ),
                ),
                const Gap.xs(),
                Expanded(
                  child: _ActionTile(
                    icon: AppIcons.assistant,
                    label: 'المستشار الذكي',
                    color: context.colors.secondary,
                    onTap: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(2),
                  ),
                ),
                const Gap.xs(),
                Expanded(
                  child: _ActionTile(
                    icon: AppIcons.network,
                    label: 'شبكة الأعمال',
                    color: context.colors.tertiary,
                    onTap: () =>
                        ref.read(roleNavIndexProvider.notifier).setIndex(3),
                  ),
                ),
                const Gap.xs(),
                Expanded(
                  child: _ActionTile(
                    icon: AppIcons.compare,
                    label: 'المقارنة',
                    color: Colors.amber.shade800,
                    onTap: () => unawaited(context.push(AppRoutes.compare)),
                  ),
                ),
              ],
            ),
            const Gap.lg(),

            // Sponsored Transparent Card
            const _SponsoredBanner(),

            // Section: Top Verified Opportunities
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'أفضل الفرص المطابقة لملفك',
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

            opportunitiesAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.analytics_outlined,
                              size: 48,
                            ),
                            const Gap.sm(),
                            const Text('لا توجد فرص مطابقة حالياً لملفك'),
                            const Gap.xs(),
                            TextButton(
                              onPressed: () => ref
                                  .read(roleNavIndexProvider.notifier)
                                  .setIndex(1),
                              child: const Text('استكشاف جميع الفرص المتاحة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: list.take(3).map((opp) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: OpportunityCard(
                        opportunity: opp,
                        onTap: () => unawaited(
                          context.push('/discover/opportunity/${opp.id}'),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Center(
                child: Text('حدث خطأ في جلب الفرص: $err'),
              ),
            ),
            const Gap.md(),

            // Categories Section
            Text(
              'تصفح حسب القطاعات',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),
            categoriesAsync.when(
              data: (categories) => SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const Gap.sm(),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _SectorCard(
                      category: cat,
                      onTap: () {
                        ref
                            .read(opportunityFilterProvider.notifier)
                            .setCategory(cat.id);
                        ref
                            .read(roleNavIndexProvider.notifier)
                            .setIndex(1);
                      },
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(height: 90),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            const Gap.xxl(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHealthCard extends StatelessWidget {
  const _ProfileHealthCard({
    required this.score,
    required this.onComplete,
  });

  final int score;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: AppRadius.largeAll,
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 4,
                backgroundColor: context.colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(context.colors.primary),
              ),
              Text(
                '$score%',
                style: context.textStyles.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          const Gap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أكمل ملفك التحليلي للحصول على دقة مطابقة أعلى',
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap.xxs(),
                Text(
                  'أضف تفضيلات المخاطرة والسيولة وساعات العمل المتاحة',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Gap.xs(),
          FilledButton.tonal(
            onPressed: onComplete,
            child: const Text('إكمال'),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.mediumAll,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.mediumAll,
          border: Border.all(
            color: color.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppSizes.iconMedium),
            const Gap.xs(),
            Text(
              label,
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SponsoredBanner extends ConsumerWidget {
  const _SponsoredBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(opportunitiesListProvider);

    return opportunitiesAsync.when(
      data: (opps) {
        final sponsored = opps.firstOrNull;
        if (sponsored == null) return const SizedBox.shrink();

        final sponsorName = sponsored.sponsorName ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.largeAll,
            side: BorderSide(
              color: context.colors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mediumAll,
                  ),
                  child: Icon(
                    AppIcons.verified,
                    color: context.colors.primary,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.tertiaryContainer,
                              borderRadius: AppRadius.fullAll,
                            ),
                            child: Text(
                              'امتياز تجاري موثق',
                              style: context.textStyles.labelSmall?.copyWith(
                                color: context.colors.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Gap.xs(),
                          const DataQualityBadge.verified(),
                        ],
                      ),
                      const Gap.xs(),
                      Text(
                        sponsored.titleAr,
                        style: context.textStyles.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (sponsorName.isNotEmpty) ...[
                        const Gap.xxs(),
                        Text(
                          sponsorName,
                          style: context.textStyles.labelSmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap.md(),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(roleNavIndexProvider.notifier).setIndex(3),
                  child: const Text('تواصل'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _SectorCard extends StatelessWidget {
  const _SectorCard({
    required this.category,
    required this.onTap,
  });

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.mediumAll,
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadius.mediumAll,
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.commerce,
              size: AppSizes.iconSmall,
              color: context.colors.primary,
            ),
            const Gap.xs(),
            Text(
              category.nameAr,
              style: context.textStyles.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${category.opportunitiesCount} فرصة',
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
