import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/deals/domain/models/deal_models.dart';
import 'package:moneyideas/features/deals/presentation/controllers/deals_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen 82: Regulatory Escrow Account Details & Fiduciary Disclosures.
class DealEscrowScreen extends ConsumerWidget {
  const DealEscrowScreen({
    required this.dealId,
    super.key,
  });

  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealAsync = ref.watch(dealDetailsProvider(dealId));
    final milestonesAsync = ref.watch(dealMilestonesProvider(dealId));
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';

    final deal = dealAsync.asData?.value;
    final milestones = milestonesAsync.asData?.value ?? [];

    if (deal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('حساب الضمان المالي')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isInvestor = deal.isInvestor(currentUserId);
    final isFunded = deal.escrowStatus == EscrowStatus.heldInEscrow;
    final escrowRef = deal.escrowAccountId ??
        'ESC-UAE-2026-${deal.id.substring(0, 6).toUpperCase()}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب الضمان المالي المعتمد'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isFunded ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFunded
                      ? Colors.green.shade200
                      : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isFunded
                        ? Icons.verified_user_rounded
                        : Icons.account_balance_rounded,
                    color: isFunded ? Colors.green.shade800 : Colors.blue.shade800,
                    size: 36,
                  ),
                  const Gap.md(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حالة الضمان: ${deal.escrowStatus.labelAr}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isFunded
                                ? Colors.green.shade900
                                : Colors.blue.shade900,
                          ),
                        ),
                        const Gap.xxs(),
                        Text(
                          isFunded
                            ? 'أموال الصفقة مؤمنة ومحفوظة في حساب وسيط ائتماني محمي'
                            : 'بانتظار تحويل المستثمر لمبلغ الصفقة إلى حساب الضمان',
                          style: TextStyle(
                            fontSize: 12,
                            color: isFunded
                                ? Colors.green.shade800
                                : Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap.lg(),

            // Custody & Bank Details
            Text(
              'بيانات حساب الحفظ الائتماني (Escrow Custody)',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: context.colors.outlineVariant.withAlpha(60),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'الجهة الائتمانية الحافظة:',
                      value: 'مصرف وسيط معتمد (مرخص من مصرف الإمارات المركزي)',
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'رقم مرجع حساب الضمان:',
                      value: escrowRef,
                      isMonospace: true,
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'المستفيد من الإفراج المشروط:',
                      value: deal.creatorName ?? 'صاحب المشروع',
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'المودع والمفوض بالاعتماد:',
                      value: deal.investorName ?? 'المستثمر الشريك',
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'المبلغ الإجمالي المودع:',
                      value: isFunded
                          ? '${deal.targetAmount.toStringAsFixed(0)} درهم'
                          : '0 درهم (بانتظار التحويل)',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const Gap.lg(),

            // Regulatory Disclosures
            Text(
              'الإفصاحات والامتثال التنظيمي في دولة الإمارات',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security_rounded, size: 18),
                      Gap.xs(),
                      Text(
                        'حماية رأس المال وفصل الحسابات',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Gap.xs(),
                  Text(
                    'تلتزم منصة «أفكار المال» بتشريعات تنظيم الأنشطة المالية في دولة الإمارات وسلطة دبي للخدمات المالية (DFSA). لا تدخل أموال الصفقات في حسابات الشركة التشغيلية إطلاقاً، بل تودع مباشرة في حسابات ضمان مستقلة خاضعة للإشراف المصرفي.',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const Gap.md(),

                  const Row(
                    children: [
                      Icon(Icons.balance_rounded, size: 18),
                      Gap.xs(),
                      Text(
                        'آلية التحكيم وفض النزاعات',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Gap.xs(),
                  Text(
                    'في حال حدوث أي خلاف حول إنجاز أحد المعالم، يتم تجميد الدفعة المتنازع عليها تلقائياً وإحالتها لغرفة الوساطة والتحكيم المالي في مركز دبي المالي العالمي (DIFC) أو سوق أبوظبي العالمي (ADGM).',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Gap.xl(),

            // Action if investor needs to deposit
            if (isInvestor && !isFunded) ...[
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.account_balance_wallet_rounded),
                label: const Text('تأكيد إيداع مبلغ الضمان في الحساب المحمي'),
                onPressed: () async {
                  await ref
                      .read(dealsActionControllerProvider)
                      .updateEscrowStatus(
                        dealId: deal.id,
                        escrowStatus: EscrowStatus.heldInEscrow,
                        escrowAccountId: escrowRef,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'تم تأكيد إيداع مبلغ الضمان بنجاح وتفعيل جدول الدفعات',
                        ),
                        backgroundColor: context.appColors.success.color,
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isMonospace = false,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isMonospace;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const Gap.sm(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
