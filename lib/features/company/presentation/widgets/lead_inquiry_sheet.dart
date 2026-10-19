import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/company/data/repositories/company_repository.dart';

class LeadInquirySheet extends ConsumerStatefulWidget {
  const LeadInquirySheet({
    required this.offerId,
    required this.offerTitle,
    super.key,
  });

  final String offerId;
  final String offerTitle;

  static Future<bool?> show(
    BuildContext context, {
    required String offerId,
    required String offerTitle,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LeadInquirySheet(
        offerId: offerId,
        offerTitle: offerTitle,
      ),
    );
  }

  @override
  ConsumerState<LeadInquirySheet> createState() => _LeadInquirySheetState();
}

class _LeadInquirySheetState extends ConsumerState<LeadInquirySheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);
    final repo = ref.read(companyRepositoryProvider);
    final result = await repo.submitLeadInquiry(
      offerId: widget.offerId,
      inquiryMessage: text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلبك بنجاح! ستقوم الشركة بالتواصل معك.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? 'تعذر إرسال الطلب'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        top: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلب استفسار عن العرض',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Gap.xs(),
          Text(
            widget.offerTitle,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap.md(),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'اكتب تفاصيل استفسارك أو متطلبات مشروعك، وسيتم تزويد الشركة ببيانات الاتصال في ملفك...',
              border: OutlineInputBorder(),
            ),
          ),
          const Gap.lg(),
          AppButton(
            text: 'إرسال طلب التواصل',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
