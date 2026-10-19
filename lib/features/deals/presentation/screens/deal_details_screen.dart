import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/deals/domain/models/deal_models.dart';
import 'package:moneyideas/features/deals/presentation/controllers/deals_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen 80: Deal Details & Milestone Roadmap.
class DealDetailsScreen extends ConsumerWidget {
  const DealDetailsScreen({
    required this.dealId,
    super.key,
  });

  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealAsync = ref.watch(dealDetailsProvider(dealId));
    final milestonesAsync = ref.watch(dealMilestonesProvider(dealId));
    final contractAsync = ref.watch(dealContractProvider(dealId));
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';

    return dealAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الصفقة')),
        body: Center(child: Text('خطأ: $err')),
      ),
      data: (deal) {
        if (deal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل الصفقة')),
            body: const Center(child: Text('الصفقة غير موجودة أو تم حذفها')),
          );
        }

        final isInvestor = deal.isInvestor(currentUserId);
        final isCreator = deal.isCreator(currentUserId);

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(deal.title),
              actions: [
                IconButton(
                  tooltip: 'تحديث',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () {
                    ref.invalidate(dealDetailsProvider(dealId));
                    ref.invalidate(dealMilestonesProvider(dealId));
                    ref.invalidate(dealContractProvider(dealId));
                  },
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'المعالم والدفعات'),
                  Tab(text: 'العقد الرقمي'),
                  Tab(text: 'حساب الضمان'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // Tab 1: Milestones & Payments
                _MilestonesTab(
                  deal: deal,
                  milestonesAsync: milestonesAsync,
                  isInvestor: isInvestor,
                  isCreator: isCreator,
                ),

                // Tab 2: Digital Contract
                _ContractTab(
                  deal: deal,
                  contractAsync: contractAsync,
                  isInvestor: isInvestor,
                  isCreator: isCreator,
                ),

                // Tab 3: Regulatory Escrow
                _EscrowTab(
                  deal: deal,
                  isInvestor: isInvestor,
                  isCreator: isCreator,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MilestonesTab extends ConsumerWidget {
  const _MilestonesTab({
    required this.deal,
    required this.milestonesAsync,
    required this.isInvestor,
    required this.isCreator,
  });

  final Deal deal;
  final AsyncValue<List<DealMilestone>> milestonesAsync;
  final bool isInvestor;
  final bool isCreator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return milestonesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ في تحميل المعالم: $e')),
      data: (milestones) {
        final totalAmount = deal.targetAmount;
        final completedAmount = milestones
            .where((m) =>
                m.status == MilestoneStatus.approved ||
                m.status == MilestoneStatus.released)
            .fold<double>(0.0, (acc, m) => acc + m.amount);
        final progressRatio =
            totalAmount > 0 ? (completedAmount / totalAmount).clamp(0.0, 1.0) : 0.0;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dealMilestonesProvider(deal.id));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Progress Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: context.colors.outlineVariant.withAlpha(80),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إجمالي مبلغ الصفقة',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${deal.targetAmount.toStringAsFixed(0)} درهم',
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Gap.sm(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressRatio,
                            minHeight: 8,
                            backgroundColor:
                                context.colors.surfaceContainerHighest,
                          ),
                        ),
                        const Gap.sm(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المحرر: ${completedAmount.toStringAsFixed(0)} درهم',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appColors.success.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'المتبقي: ${(totalAmount - completedAmount).toStringAsFixed(0)} درهم',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap.md(),

                Text(
                  'جدول معالم التنفيذ والدفعات المالية',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap.xs(),
                Text(
                  'يتم صرف دفعات كل مرحلة بعد تقديم رائد الأعمال لإثبات الإنجاز وموافقة المستستثمر الرقمية.',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const Gap.md(),

                if (milestones.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    alignment: Alignment.center,
                    child: const Text('لم يتم تحديد معالم تنفيذ لهذه الصفقة بعد'),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: milestones.length,
                    separatorBuilder: (_, __) => const Gap.sm(),
                    itemBuilder: (context, idx) {
                      final m = milestones[idx];
                      return _MilestoneCard(
                        milestone: m,
                        dealId: deal.id,
                        isInvestor: isInvestor,
                        isCreator: isCreator,
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MilestoneCard extends ConsumerWidget {
  const _MilestoneCard({
    required this.milestone,
    required this.dealId,
    required this.isInvestor,
    required this.isCreator,
  });

  final DealMilestone milestone;
  final String dealId;
  final bool isInvestor;
  final bool isCreator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: context.colors.outlineVariant.withAlpha(70),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: context.colors.primaryContainer,
                      child: Text(
                        '${milestone.orderIndex}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const Gap.sm(),
                    Text(
                      milestone.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                _MilestoneBadge(status: milestone.status),
              ],
            ),
            if (milestone.description != null &&
                milestone.description!.isNotEmpty) ...[
              const Gap.xs(),
              Text(
                milestone.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
            const Gap.sm(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'قيمة الدفعة: ${milestone.amount.toStringAsFixed(0)} درهم',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                if (milestone.proofUrl != null)
                  Text(
                    'تم إرفاق إثبات التسليم ✓',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appColors.success.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

            // Actions per role
            if (isCreator &&
                milestone.status == MilestoneStatus.pending) ...[
              const Gap.sm(),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text('تقديم إثبات إنجاز المعلم'),
                  onPressed: () async {
                    await ref
                        .read(dealsActionControllerProvider)
                        .updateMilestoneStatus(
                          dealId: dealId,
                          milestoneId: milestone.id,
                          status: MilestoneStatus.submittedForApproval,
                          proofUrl: 'https://storage.moneyideas.ae/proofs/m1.pdf',
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'تم تقديم إثبات المعلم وإرسال إشعار للمستثمر للاعتماد',
                          ),
                          backgroundColor: context.appColors.success.color,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],

            if (isInvestor &&
                milestone.status == MilestoneStatus.submittedForApproval) ...[
              const Gap.sm(),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_circle_rounded, size: 16),
                  label: const Text('اعتماد وصرف الدفعة من الضمان'),
                  onPressed: () async {
                    await ref
                        .read(dealsActionControllerProvider)
                        .updateMilestoneStatus(
                          dealId: dealId,
                          milestoneId: milestone.id,
                          status: MilestoneStatus.released,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'تم اعتماد المعلم بنجاح وإصدار أمر تحرير الدفعة من حساب الضمان',
                          ),
                          backgroundColor: context.appColors.success.color,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  const _MilestoneBadge({required this.status});

  final MilestoneStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      MilestoneStatus.pending => ('بانتظار الإنجاز', Colors.grey.shade700),
      MilestoneStatus.submittedForApproval => ('قيد مراجعة المستثمر', Colors.orange.shade800),
      MilestoneStatus.approved => ('معتمد', Colors.blue.shade700),
      MilestoneStatus.released => ('تم صرف الدفعة ✓', Colors.green.shade700),
      MilestoneStatus.disputed => ('نزاع مالي', Colors.red.shade700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ContractTab extends StatelessWidget {
  const _ContractTab({
    required this.deal,
    required this.contractAsync,
    required this.isInvestor,
    required this.isCreator,
  });

  final Deal deal;
  final AsyncValue<DealContract?> contractAsync;
  final bool isInvestor;
  final bool isCreator;

  @override
  Widget build(BuildContext context) {
    return contractAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ في تحميل العقد: $e')),
      data: (contract) {
        final isInvestorSigned = deal.investorSignedAt != null;
        final isCreatorSigned = deal.creatorSignedAt != null;

        return SingleChildScrollView(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: context.colors.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.gavel_rounded,
                            color: context.colors.primary,
                          ),
                          const Gap.sm(),
                          Expanded(
                            child: Text(
                              'اتفاقية الاستثمار والتمويل الرقمية',
                              style: context.textStyles.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: deal.isFullySigned
                                  ? Colors.green.shade100
                                  : Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              deal.isFullySigned
                                  ? 'عقد مفعّل وموقع بالكامل'
                                  : 'بانتظار استكمال التوقيعات',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: deal.isFullySigned
                                    ? Colors.green.shade900
                                    : Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap.sm(),
                      const Divider(),
                      const Gap.xs(),
                      Row(
                        children: [
                          Expanded(
                            child: _SignatureStatus(
                              roleLabel: 'المستثمر الشريك',
                              userName: deal.investorName ?? 'المستثمر',
                              isSigned: isInvestorSigned,
                            ),
                          ),
                          Expanded(
                            child: _SignatureStatus(
                              roleLabel: 'رائد الأعمال / الشركة',
                              userName: deal.creatorName ?? 'صاحب المشروع',
                              isSigned: isCreatorSigned,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Gap.lg(),

              Text(
                'البنود القانونية الرئيسية',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap.sm(),

              if (contract != null && contract.legalClauses.isNotEmpty)
                ...contract.legalClauses.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}. ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(height: 1.4, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const Gap.lg(),

              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.edit_document),
                label: Text(
                  deal.isFullySigned
                      ? 'استعراض وثيقة العقد الموثقة'
                      : 'قراءة وثيقة العقد والتوقيع الإلكتروني',
                ),
                onPressed: () => context.push('/deals/${deal.id}/contract'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignatureStatus extends StatelessWidget {
  const _SignatureStatus({
    required this.roleLabel,
    required this.userName,
    required this.isSigned,
  });

  final String roleLabel;
  final String userName;
  final bool isSigned;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          roleLabel,
          style: TextStyle(
            fontSize: 11,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const Gap.xxs(),
        Row(
          children: [
            Icon(
              isSigned ? Icons.verified_rounded : Icons.pending_rounded,
              size: 14,
              color: isSigned ? Colors.green : Colors.orange,
            ),
            const Gap.xs(),
            Text(
              isSigned ? 'تم التوقيع الرقمي' : 'بانتظار التوقيع',
              style: TextStyle(
                fontSize: 10,
                color: isSigned ? Colors.green.shade800 : Colors.orange.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EscrowTab extends ConsumerWidget {
  const _EscrowTab({
    required this.deal,
    required this.isInvestor,
    required this.isCreator,
  });

  final Deal deal;
  final bool isInvestor;
  final bool isCreator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFunded = deal.escrowStatus == EscrowStatus.heldInEscrow;

    return SingleChildScrollView(
      padding: AppSpacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primaryContainer,
                  context.colors.surfaceContainerHighest,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      color: context.colors.primary,
                      size: 28,
                    ),
                    const Gap.sm(),
                    Expanded(
                      child: Text(
                        'نظام الضمان المالي المعتمد (Regulatory Escrow)',
                        style: context.textStyles.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap.sm(),
                Text(
                  'يتم حفظ أموال الاستثمار في حساب ضمان مصرفي مرخص وفق تشريعات DIFC / ADGM. لا يحق لرائد الأعمال سحب المبلغ دفعة واحدة، بل يتم الإفراج تدريجياً وفق المعالم المعتمدة.',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Gap.lg(),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: context.colors.outlineVariant.withAlpha(70),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('حالة الحساب المحمي:'),
                      Text(
                        deal.escrowStatus.labelAr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isFunded
                              ? context.appColors.success.color
                              : context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('رقم مرجع الضمان:'),
                      Text(
                        deal.escrowAccountId ?? 'ESC-UAE-2026-${deal.id.substring(0, 6).toUpperCase()}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المبلغ المودع في الحساب:'),
                      Text(
                        isFunded
                            ? '${deal.targetAmount.toStringAsFixed(0)} درهم'
                            : '0 درهم (بانتظار الإيداع)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Gap.lg(),

          if (isInvestor &&
              deal.escrowStatus == EscrowStatus.pendingDeposit) ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.account_balance_wallet_rounded),
              label: const Text('إيداع مبلغ الاستثمار في حساب الضمان'),
              onPressed: () async {
                await ref
                    .read(dealsActionControllerProvider)
                    .updateEscrowStatus(
                      dealId: deal.id,
                      escrowStatus: EscrowStatus.heldInEscrow,
                      escrowAccountId:
                          'ESC-UAE-2026-${deal.id.substring(0, 6).toUpperCase()}',
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'تم تسجيل إيداع مبلغ الضمان بنجاح وأصبحت الصفقة قيد التنفيذ',
                      ),
                      backgroundColor: context.appColors.success.color,
                    ),
                  );
                }
              },
            ),
            const Gap.sm(),
          ],

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.info_outline_rounded),
            label: const Text('عرض الإفصاحات والوساطة التنظيمية'),
            onPressed: () => context.push('/deals/${deal.id}/escrow'),
          ),
        ],
      ),
    );
  }
}
