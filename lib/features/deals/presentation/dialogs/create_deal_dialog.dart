import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/deals/domain/models/deal_models.dart';
import 'package:moneyideas/features/deals/presentation/controllers/deals_controller.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modal dialog for drafting and proposing a new investment deal.
class CreateDealDialog extends ConsumerStatefulWidget {
  const CreateDealDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CreateDealDialog(),
    );
  }

  @override
  ConsumerState<CreateDealDialog> createState() => _CreateDealDialogState();
}

class _CreateDealDialogState extends ConsumerState<CreateDealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _equityController = TextEditingController(text: '10');
  final _termsController = TextEditingController();
  final _milestoneTitleController =
      TextEditingController(text: 'الدفعة الأولى: إطلاق النسخة التجريبية والموافقة المبدئية');

  DealType _selectedType = DealType.equity;
  String? _selectedInvestorId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _equityController.dispose();
    _termsController.dispose();
    _milestoneTitleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInvestorId == null || _selectedInvestorId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى اختيار المستثمر الشريك من القائمة'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final equity = double.tryParse(_equityController.text.trim());

    final res = await ref.read(dealsActionControllerProvider).createDeal(
          investorId: _selectedInvestorId!,
          title: _titleController.text.trim(),
          dealType: _selectedType,
          targetAmount: amount,
          equityPercentage: equity,
          termsSummary: _termsController.text.trim(),
          initialMilestones: [
            {
              'title': _milestoneTitleController.text.trim().isNotEmpty
                  ? _milestoneTitleController.text.trim()
                  : 'الدفعة الأولى',
              'description': 'المرحلة الأولى من خطة المعالم الاستثمارية',
              'amount': amount * 0.4, // 40% initial tranche
            },
            {
              'title': 'الدفعة الثانية: استكمال النمو وتحقيق الأهداف التسويقية',
              'description': 'المرحلة الثانية بعد استيفاء شروط النمو والتقارير المالية',
              'amount': amount * 0.6, // 60% second tranche
            },
          ],
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.isSuccess) {
      Navigator.of(context).pop();
      final deal = res.valueOrNull!;
      context.push('/deals/${deal.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إنشاء مقترح الصفقة والعقد الرقمي بنجاح'),
          backgroundColor: context.appColors.success.color,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.debugMessage ?? 'فشل إنشاء الصفقة'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final investorsAsync = ref.watch(investorsListProvider(null));

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إنشاء مقترح صفقة استثمارية',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Gap.sm(),
              Text(
                'تتيح لك المنصة توثيق الصفقات بنظام العقود الرقمية المتوافقة مع DIFC وجدول المعالم والدفعات عبر حساب الضمان المالي المعتمد.',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const Gap.md(),

              // Deal Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الصفقة أو جولة التمويل *',
                  hintText: 'مثال: جولة استثمار تمويل أولي - مشروع لوجستي',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const Gap.md(),

              // Investor selector
              investorsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (investors) {
                  final currentUserId =
                      Supabase.instance.client.auth.currentUser?.id;
                  // Filter out self
                  final validInvestors =
                      investors.where((i) => i.userId != currentUserId).toList();

                  return DropdownButtonFormField<String>(
                    value: _selectedInvestorId,
                    decoration: const InputDecoration(
                      labelText: 'المستثمر الشريك *',
                      border: OutlineInputBorder(),
                    ),
                    items: validInvestors
                        .map(
                          (i) => DropdownMenuItem(
                            value: i.userId,
                            child: Text('${i.fullName ?? "مستثمر معتمد"} (${i.investorType})'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedInvestorId = val),
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'اختر مستثمراً' : null,
                  );
                },
              ),
              const Gap.md(),

              // Deal Type
              DropdownButtonFormField<DealType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'نوع الصفقة والشراكة *',
                  border: OutlineInputBorder(),
                ),
                items: DealType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.labelAr),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const Gap.md(),

              // Target Amount & Equity
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'مبلغ الاستثمار الإجمالي (درهم) *',
                        hintText: '100000',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'مطلوب';
                        if (double.tryParse(val) == null) return 'رقم غير صحيح';
                        return null;
                      },
                    ),
                  ),
                  const Gap.sm(),
                  Expanded(
                    child: TextFormField(
                      controller: _equityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'حصة الملكية (%)',
                        hintText: '10',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap.md(),

              // First Milestone preview
              TextFormField(
                controller: _milestoneTitleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الدفعة/المرحلة الأولى',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap.md(),

              // Terms Summary
              TextFormField(
                controller: _termsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ملخص الشروط المتفق عليها مبدئياً',
                  hintText: 'توزيع الحصص، خطة استهلاك الميزانية، أو شروط خاصة...',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap.lg(),

              // Submit Button
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  _isSubmitting
                      ? 'جاري إنشاء الصفقة...'
                      : 'تأكيد وإنشاء مقترح الصفقة',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
