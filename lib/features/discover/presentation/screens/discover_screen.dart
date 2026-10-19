import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/states/empty_state.dart';
import 'package:moneyideas/core/widgets/states/loading_state.dart';
import 'package:moneyideas/features/discover/presentation/controllers/discover_controller.dart';
import 'package:moneyideas/features/discover/presentation/widgets/opportunity_card.dart';
import 'package:moneyideas/features/discover/presentation/widgets/opportunity_filter_sheet.dart';

/// Screen 17: Opportunities Marketplace and Discovery.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final opportunitiesAsync = ref.watch(opportunitiesListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final currentFilter = ref.watch(opportunityFilterProvider);
    final compareList = ref.watch(compareListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.navDiscover,
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'المحفوظات',
            icon: const Icon(AppIcons.save),
            onPressed: () => context.push(AppRoutes.saved),
          ),
          IconButton(
            tooltip: 'البحث المتقدم',
            icon: const Icon(AppIcons.search),
            onPressed: () => context.push(AppRoutes.search),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter & Search bar header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: AppRadius.fullAll,
                      onTap: () => context.push(AppRoutes.search),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                          borderRadius: AppRadius.fullAll,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.search,
                              size: AppSizes.iconSmall,
                              color: context.colors.onSurfaceVariant,
                            ),
                            const Gap.sm(),
                            Text(
                              currentFilter.searchQuery ?? 'ابحث عن فكرة مشروع أو قطاع...',
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap.sm(),
                  IconButton.filledTonal(
                    icon: Icon(
                      AppIcons.filter,
                      color: currentFilter.hasActiveFilters
                          ? context.colors.primary
                          : null,
                    ),
                    onPressed: () => OpportunityFilterSheet.show(context),
                  ),
                ],
              ),
            ),

            // Horizontal Categories Selector
            categoriesAsync.when(
              data: (categories) => SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (context, index) => const Gap.xs(),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isAll = currentFilter.categoryId == null;
                      return ChoiceChip(
                        label: const Text('الكل'),
                        selected: isAll,
                        onSelected: (_) {
                          ref
                              .read(opportunityFilterProvider.notifier)
                              .setCategory(null);
                        },
                      );
                    }
                    final cat = categories[index - 1];
                    final isSelected = currentFilter.categoryId == cat.id;
                    return ChoiceChip(
                      label: Text(cat.nameAr),
                      selected: isSelected,
                      onSelected: (_) {
                        ref
                            .read(opportunityFilterProvider.notifier)
                            .setCategory(cat.id);
                      },
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(height: 48),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            const Divider(height: 1),

            // Opportunities List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(opportunitiesListProvider);
                },
                child: opportunitiesAsync.when(
                  data: (opportunities) {
                    if (opportunities.isEmpty) {
                      return EmptyState(
                        title: l10n.emptyStateTitle,
                        message: l10n.emptyStateMessage,
                        actionLabel: 'إعادة ضبط الفلاتر',
                        onAction: () {
                          ref
                              .read(opportunityFilterProvider.notifier)
                              .resetFilters();
                        },
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: opportunities.length,
                      itemBuilder: (context, index) {
                        return OpportunityCard(
                          opportunity: opportunities[index],
                        );
                      },
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (error, _) => Center(
                    child: Text('خطأ أثناء تحميل الفرص: $error'),
                  ),
                ),
              ),
            ),

            // Bottom Comparison Bar
            if (compareList.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.compare,
                      color: context.colors.onPrimaryContainer,
                      size: AppSizes.iconMedium,
                    ),
                    const Gap.md(),
                    Expanded(
                      child: Text(
                        'محدد للمقارنة: ${compareList.length} من 3',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () => context.push(AppRoutes.compare),
                      child: const Text('قارن الآن'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
