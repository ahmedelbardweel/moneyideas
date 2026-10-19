import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/inputs/app_text_field.dart';
import 'package:moneyideas/core/widgets/states/empty_state.dart';
import 'package:moneyideas/core/widgets/states/loading_state.dart';
import 'package:moneyideas/features/discover/presentation/controllers/discover_controller.dart';
import 'package:moneyideas/features/discover/presentation/widgets/opportunity_card.dart';

/// Screen 18: Instant and Advanced Search with query history and suggested tags.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _popularSuggestions = [
    'مشاريع بدون رأس مال',
    'دروبشيبينغ',
    'غسيل سيارات متنقل',
    'مطابخ سحابية',
    'استشارات قانونية وتراخيص',
    'مشاريع تقنية ورقمية',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(opportunityFilterProvider.notifier).setSearchQuery(query);
  }

  void _applySuggestion(String tag) {
    _searchController.text = tag;
    _onSearchChanged(tag);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final opportunitiesAsync = ref.watch(opportunitiesListProvider);
    final currentQuery = ref.watch(opportunityFilterProvider).searchQuery ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.commonSearch,
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppTextField(
                controller: _searchController,
                label: 'بحث عن فكرة أو قطاع أو كلمة مفتاحية',
                hint: 'مثال: تجارة إلكترونية، مطاعم...',
                prefixIcon: AppIcons.search,
                suffixIcon: currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.close),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                onChanged: _onSearchChanged,
              ),
            ),

            // Popular Suggestions (visible when query is empty)
            if (currentQuery.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'أكثر عمليات البحث رواجاً',
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Gap.xs(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: _popularSuggestions.map((tag) {
                    return ActionChip(
                      label: Text(tag),
                      avatar: const Icon(AppIcons.search, size: 14),
                      onPressed: () => _applySuggestion(tag),
                    );
                  }).toList(),
                ),
              ),
              const Gap.lg(),
            ],

            // Results List
            Expanded(
              child: opportunitiesAsync.when(
                data: (opportunities) {
                  if (opportunities.isEmpty) {
                    return EmptyState(
                      title: 'لا توجد نتائج مطابقة لبحثك',
                      message: 'جرب استخدام كلمات مفتاحية أخرى أو تصفح الأقسام الرئيسية',
                      actionLabel: 'مسح البحث',
                      onAction: () {
                        _searchController.clear();
                        _onSearchChanged('');
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
                error: (e, _) => Center(child: Text('خطأ: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
