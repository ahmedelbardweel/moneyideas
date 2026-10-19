import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/deals/domain/models/deal_models.dart';
import 'package:moneyideas/features/deals/presentation/controllers/deals_controller.dart';
import 'package:moneyideas/features/deals/presentation/dialogs/create_deal_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen 79: Deals Hub & Overview (Investment Pipeline, Deals & Escrow).
class DealsHubScreen extends ConsumerStatefulWidget {
  const DealsHubScreen({super.key});

  @override
  ConsumerState<DealsHubScreen> createState() => _DealsHubScreenState();
}

class _DealsHubScreenState extends ConsumerState<DealsHubScreen> {
  DealStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final dealsAsync = ref.watch(myDealsListProvider(_selectedStatusFilter));
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفقات والتمويل الاستثماري'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(myDealsListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('بدء مقترح صفقة'),
        onPressed: () => CreateDealDialog.show(context),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: _selectedStatusFilter == null,
                  onSelected: (_) =>
                      setState(() => _selectedStatusFilter = null),
                ),
                const Gap.xs(),
                FilterChip(
                  label: const Text('قيد التفاوض'),
                  selected: _selectedStatusFilter == DealStatus.negotiation,
                  onSelected: (_) => setState(
                    () => _selectedStatusFilter = DealStatus.negotiation,
                  ),
                ),
                const Gap.xs(),
                FilterChip(
                  label: const Text('قيد التنفيذ والمراحل'),
                  selected: _selectedStatusFilter == DealStatus.inProgress,
                  onSelected: (_) => setState(
                    () => _selectedStatusFilter = DealStatus.inProgress,
                  ),
                ),
                const Gap.xs(),
                FilterChip(
                  label: const Text('مكتملة'),
                  selected: _selectedStatusFilter == DealStatus.completed,
                  onSelected: (_) => setState(
                    () => _selectedStatusFilter = DealStatus.completed,
                  ),
                ),
              ],
            ),
          ),

          // Deals Content
          Expanded(
            child: dealsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: AppSpacing.page,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: context.colors.error,
                      ),
                      const Gap.md(),
                      Text('تعذر تحميل الصفقات',
                          style: context.textStyles.titleMedium),
                      const Gap.xs(),
                      Text(
                        err.toString(),
                        style: TextStyle(
                          color: context.colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap.md(),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة المحاولة'),
                        onPressed: () => ref.invalidate(myDealsListProvider),
                      ),
                    ],
                  ),
                ),
              ),
              data: (deals) {
                if (deals.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(myDealsListProvider);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xxl,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.handshake_outlined,
                                size: 56,
                                color: context.colors.primary,
                              ),
                            ),
                            const Gap.lg(),
                            Text(
                              'لا توجد صفقات استثمارية حالياً',
                              style: context.textStyles.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap.sm(),
                            Text(
                              'يمكنك تقديم مقترح صفقة رسمية مع مستثمر أو رائد أعمال تشمل جداول المعالم المالية، العقود الرقمية، وحسابات الضمان المالي المعتمدة (Escrow).',
                              style: TextStyle(
                                color: context.colors.onSurfaceVariant,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap.xl(),
                            FilledButton.icon(
                              onPressed: () => CreateDealDialog.show(context),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('إنشاء مقترح صفقة جديدة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(myDealsListProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: deals.length,
                    itemBuilder: (context, index) {
                      final deal = deals[index];
                      return _DealCard(
                        deal: deal,
                        currentUserId: currentUserId,
                        onTap: () => context.push('/deals/${deal.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.deal,
    required this.currentUserId,
    required this.onTap,
  });

  final Deal deal;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isInvestor = deal.isInvestor(currentUserId);
    final partnerName = isInvestor
        ? (deal.creatorName ?? 'صاحب المشروع')
        : (deal.investorName ?? 'المستثمر');
    final partnerRole = isInvestor ? 'رائد الأعمال / الشركة' : 'المستثمر الشريك';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.colors.outlineVariant.withAlpha(80),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Project title and deal status chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deal.title,
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (deal.projectName != null) ...[
                          const Gap.xxs(),
                          Text(
                            'المشروع: ${deal.projectName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _StatusChip(status: deal.status),
                ],
              ),
              const Gap.sm(),
              const Divider(),
              const Gap.xs(),

              // Valuation and equity metrics
              Row(
                children: [
                  Expanded(
                    child: _MetricItem(
                      label: 'مبلغ الاستثمار',
                      value: '${deal.targetAmount.toStringAsFixed(0)} درهم',
                    ),
                  ),
                  if (deal.equityPercentage != null)
                    Expanded(
                      child: _MetricItem(
                        label: 'نسبة الملكية',
                        value: '${deal.equityPercentage}%',
                      ),
                    ),
                  Expanded(
                    child: _MetricItem(
                      label: 'نوع الصفقة',
                      value: deal.dealType.labelAr.split('(').first.trim(),
                    ),
                  ),
                ],
              ),
              const Gap.sm(),

              // Partner & Escrow state
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const Gap.xs(),
                      Text(
                        '$partnerRole: $partnerName',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  _EscrowBadge(status: deal.escrowStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.xxs(),
        Text(
          value,
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final DealStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      DealStatus.draft => (Colors.grey.shade200, Colors.grey.shade800),
      DealStatus.negotiation => (Colors.orange.shade50, Colors.orange.shade900),
      DealStatus.contractPending => (Colors.amber.shade100, Colors.amber.shade900),
      DealStatus.escrowFunded => (Colors.blue.shade50, Colors.blue.shade900),
      DealStatus.inProgress => (Colors.indigo.shade50, Colors.indigo.shade900),
      DealStatus.completed => (Colors.green.shade50, Colors.green.shade900),
      DealStatus.cancelled => (Colors.red.shade50, Colors.red.shade900),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.labelAr,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EscrowBadge extends StatelessWidget {
  const _EscrowBadge({required this.status});

  final EscrowStatus status;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      EscrowStatus.heldInEscrow => Icons.verified_user_rounded,
      EscrowStatus.released => Icons.check_circle_outline_rounded,
      EscrowStatus.disputed => Icons.warning_amber_rounded,
      _ => Icons.shield_outlined,
    };

    final color = switch (status) {
      EscrowStatus.heldInEscrow => Colors.blue.shade700,
      EscrowStatus.released => Colors.green.shade700,
      EscrowStatus.disputed => Colors.red.shade700,
      _ => context.colors.onSurfaceVariant,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const Gap.xs(),
        Text(
          'الضمان: ${status.labelAr}',
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
