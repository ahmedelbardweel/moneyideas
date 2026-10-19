import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/chat/presentation/controllers/chat_controller.dart';

/// Screen 67: Report Abuse / Fraud / Misleading content dialog.
class ReportDialog extends ConsumerStatefulWidget {
  const ReportDialog({
    required this.entityType,
    required this.entityId,
    required this.entityName,
    super.key,
  });

  final String entityType; // 'user', 'message', 'project', 'offer'
  final String entityId;
  final String entityName;

  static Future<bool?> show(
    BuildContext context, {
    required String entityType,
    required String entityId,
    required String entityName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReportDialog(
        entityType: entityType,
        entityId: entityId,
        entityName: entityName,
      ),
    );
  }

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  final _detailsController = TextEditingController();
  String _selectedReason = 'احتيال أو وعود أرباح مضللة';
  bool _isSubmitting = false;

  final _reasons = const [
    'احتيال أو وعود أرباح مضللة',
    'رسائل غير لائقة أو إزعاج متكرر',
    'انتحال شخصية أو تزوير صفة',
    'انتهاك حقوق ملكية فكرية',
    'طلب تحويلات مالية غير نظامية',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final res = await ref.read(chatActionControllerProvider).submitReport(
          entityType: widget.entityType,
          entityId: widget.entityId,
          reason: _selectedReason,
          details: _detailsController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.isSuccess) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم استلام بلاغك وسيقوم فريق الإدارة بالتحقيق واتخاذ الإجراء اللازم',
          ),
          backgroundColor: context.appColors.success.color,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.debugMessage ?? 'فشل إرسال البلاغ'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: context.colors.errorContainer,
                child: Icon(
                  Icons.report_problem_rounded,
                  color: context.colors.error,
                ),
              ),
              const Gap.sm(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإبلاغ عن مخالفة',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'بخصوص: ${widget.entityName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          const Gap.md(),

          Text(
            'سبب البلاغ',
            style: context.textStyles.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap.xs(),
          DropdownButtonFormField<String>(
            value: _selectedReason,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _reasons
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedReason = val);
            },
          ),
          const Gap.md(),

          Text(
            'تفاصيل إضافية تدعم البلاغ',
            style: context.textStyles.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap.xs(),
          TextField(
            controller: _detailsController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'اكتب توضيحاً لما حدث بدقة ليتسنى للإدارة مراجعته...',
              border: OutlineInputBorder(),
            ),
          ),
          const Gap.lg(),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_isSubmitting ? 'جاري الإرسال...' : 'إرسال البلاغ للإدارة'),
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
