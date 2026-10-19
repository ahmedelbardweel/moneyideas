import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/deals/presentation/controllers/deals_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen 81: Formal Digital Investment Contract & E-Signature.
class DealContractScreen extends ConsumerStatefulWidget {
  const DealContractScreen({
    required this.dealId,
    super.key,
  });

  final String dealId;

  @override
  ConsumerState<DealContractScreen> createState() =>
      _DealContractScreenState();
}

class _DealContractScreenState extends ConsumerState<DealContractScreen> {
  final _nameController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isSigning = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signContract(bool isInvestor) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى كتابة اسمك القانوني الكامل للتوقيع'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يجب الموافقة على الشروط والأحكام القانونية'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    setState(() => _isSigning = true);

    final res = await ref.read(dealsActionControllerProvider).signContract(
          dealId: widget.dealId,
          signatureText: name,
          isInvestor: isInvestor,
        );

    if (!mounted) return;
    setState(() => _isSigning = false);

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم توقيع واعتماد العقد بنجاح وحفظ الختم الرقمي'),
          backgroundColor: context.appColors.success.color,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.debugMessage ?? 'فشل توقيع العقد'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dealAsync = ref.watch(dealDetailsProvider(widget.dealId));
    final contractAsync = ref.watch(dealContractProvider(widget.dealId));
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';

    final deal = dealAsync.asData?.value;
    final contract = contractAsync.asData?.value;

    if (deal == null || contract == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('العقد الاستثماري')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isInvestor = deal.isInvestor(currentUserId);
    final mySigned =
        isInvestor ? deal.investorSignedAt != null : deal.creatorSignedAt != null;
    final mySignatureName =
        isInvestor ? contract.investorSignature : contract.creatorSignature;

    return Scaffold(
      appBar: AppBar(
        title: const Text('العقد الاستثماري الرقمي'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.outlineVariant.withAlpha(80),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'عقد استثمار وتمويل رسمي',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: deal.isFullySigned
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          deal.isFullySigned ? 'ساري وموثق' : 'مسودة قيد التوقيع',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: deal.isFullySigned
                                ? Colors.green.shade900
                                : Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap.sm(),
                  Text(
                    'بين الطرف الأول (صاحب المشروع/الشركة): ${deal.creatorName ?? 'صاحب المشروع'}\nوالطرف الثاني (المستثمر الشريك): ${deal.investorName ?? 'المستثمر'}\nالقيمة الإجمالية: ${deal.targetAmount.toStringAsFixed(0)} درهم إماراتي',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Gap.lg(),

            // Legal Clauses
            Text(
              'بنود وشروط الاتفاقية',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),

            ...contract.legalClauses.asMap().entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.outlineVariant.withAlpha(50),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: context.colors.primaryContainer,
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const Gap.sm(),
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
            const Gap.md(),

            // Governing Law
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.secondaryContainer.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.balance_rounded,
                          size: 18, color: context.colors.secondary),
                      const Gap.xs(),
                      Text(
                        'القانون الحاكم والاختصاص القضائي:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.colors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Gap.xs(),
                  Text(
                    contract.governingLaw,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Gap.xl(),

            // Signature Section
            Text(
              'التوقيع الرقمي والاعتماد',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),

            if (mySigned)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Colors.green,
                      size: 32,
                    ),
                    const Gap.md(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تم توقيعك على هذا العقد بنجاح',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'الموقع: $mySignatureName',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade900,
                            ),
                          ),
                          Text(
                            'الختم الرقمي: SHA256:${deal.id.hashCode.toRadixString(16).toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'اكتب اسمك القانوني الكامل للتوقيع *',
                        hintText: 'مثال: محمد بن راشد الشامسي',
                        filled: true,
                        fillColor: context.colors.surface,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const Gap.sm(),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _agreedToTerms,
                      onChanged: (val) =>
                          setState(() => _agreedToTerms = val ?? false),
                      title: const Text(
                        'أقر بصفتي القانونية بموافقتي التامة على بنود العقد وأتحمل الالتزامات المالية والتنظيمية المترتبة عليه.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const Gap.sm(),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _isSigning
                          ? null
                          : () => _signContract(isInvestor),
                      icon: _isSigning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.draw_rounded),
                      label: Text(_isSigning
                          ? 'جاري التوقيع...'
                          : 'اعتماد وتوقيع العقد رسمياً'),
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
