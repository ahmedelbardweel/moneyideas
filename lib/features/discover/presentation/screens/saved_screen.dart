import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/states/empty_state.dart';
import 'package:moneyideas/core/widgets/states/loading_state.dart';
import 'package:moneyideas/features/discover/presentation/controllers/discover_controller.dart';
import 'package:moneyideas/features/discover/presentation/widgets/opportunity_card.dart';

/// Screen 27: Saved bookmarks for bookmarked investment opportunities.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedOpportunitiesProvider);
    final opportunitiesAsync = ref.watch(opportunitiesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الفرص المحفوظة (${savedIds.length})',
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: opportunitiesAsync.when(
          data: (opportunities) {
            final savedOpps =
                opportunities.where((o) => savedIds.contains(o.id)).toList();

            if (savedOpps.isEmpty) {
              return EmptyState(
                title: 'لا توجد فرص محفوظة حالياً',
                message:
                    'يمكنك حفظ أي فرصة تجارية تنال إعجابك للرجوع إليها ودراستها في أي وقت لاحقاً.',
                actionLabel: 'استكشف الفرص الآن',
                onAction: () => context.pop(),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: savedOpps.length,
              itemBuilder: (context, index) {
                return OpportunityCard(opportunity: savedOpps[index]);
              },
            );
          },
          loading: () => const LoadingState(),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}
