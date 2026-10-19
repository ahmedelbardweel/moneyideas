import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';
import 'package:moneyideas/features/company/presentation/widgets/offer_card.dart';

class CompanyOffersScreen extends ConsumerStatefulWidget {
  const CompanyOffersScreen({super.key});

  @override
  ConsumerState<CompanyOffersScreen> createState() =>
      _CompanyOffersScreenState();
}

class _CompanyOffersScreenState extends ConsumerState<CompanyOffersScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(companyOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العروض التجارية'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('عرض جديد'),
        onPressed: () => unawaited(context.push('/company/offers/new')),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث في عروضك...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.fullAll,
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
                const Gap.sm(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'الكل',
                        selected: _selectedFilter == 'all',
                        onSelected: () =>
                            setState(() => _selectedFilter = 'all'),
                      ),
                      const Gap.xs(),
                      _FilterChip(
                        label: 'منشورة ونشطة',
                        selected: _selectedFilter == 'approved',
                        onSelected: () =>
                            setState(() => _selectedFilter = 'approved'),
                      ),
                      const Gap.xs(),
                      _FilterChip(
                        label: 'قيد المراجعة',
                        selected: _selectedFilter == 'in_review',
                        onSelected: () =>
                            setState(() => _selectedFilter = 'in_review'),
                      ),
                      const Gap.xs(),
                      _FilterChip(
                        label: 'مسودات',
                        selected: _selectedFilter == 'draft',
                        onSelected: () =>
                            setState(() => _selectedFilter = 'draft'),
                      ),
                      const Gap.xs(),
                      _FilterChip(
                        label: 'متوقفة مؤقتاً',
                        selected: _selectedFilter == 'paused',
                        onSelected: () =>
                            setState(() => _selectedFilter = 'paused'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Offers List
          Expanded(
            child: offersAsync.when(
              data: (offers) {
                var filtered = offers;
                if (_selectedFilter != 'all') {
                  filtered = filtered
                      .where((o) => o.status.toDbValue() == _selectedFilter)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered
                      .where(
                        (o) =>
                            o.title.contains(_searchQuery) ||
                            o.serviceType.contains(_searchQuery),
                      )
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: context.colors.outline,
                          ),
                          const Gap.md(),
                          Text(
                            'لا توجد عروض تطابق هذا الفلتر',
                            style: context.textStyles.titleMedium,
                          ),
                          const Gap.sm(),
                          Text(
                            'يمكنك إنشاء عرض تجاري جديد أو تغيير خيارات التصفية.',
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(companyOffersProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      final offer = filtered[index];
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
                          final newStatus = offer.status == OfferStatus.paused
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
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('خطأ في تحميل العروض: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
