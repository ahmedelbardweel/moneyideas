import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';

/// Screen 62: Anti-Spam Mutual Contact Request Bottom Sheet / Dialog.
class SendContactRequestDialog extends ConsumerStatefulWidget {
  const SendContactRequestDialog({
    required this.receiverId,
    required this.receiverName,
    this.projectId,
    this.projectName,
    super.key,
  });

  final String receiverId;
  final String receiverName;
  final String? projectId;
  final String? projectName;

  static Future<bool?> show(
    BuildContext context, {
    required String receiverId,
    required String receiverName,
    String? projectId,
    String? projectName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SendContactRequestDialog(
        receiverId: receiverId,
        receiverName: receiverName,
        projectId: projectId,
        projectName: projectName,
      ),
    );
  }

  @override
  ConsumerState<SendContactRequestDialog> createState() =>
      _SendContactRequestDialogState();
}

class _SendContactRequestDialogState
    extends ConsumerState<SendContactRequestDialog> {
  final _messageController = TextEditingController();
  String _selectedReason = 'طلب شراكة استراتيجية';
  bool _isSending = false;
  String? _errorText;

  final _reasons = const [
    'طلب شراكة استراتيجية',
    'استثمار وتمويل مالي',
    'شراكة تقنية وتطوير',
    'شراكة تسويق ومبيعات',
    'استفسار عن نموذج العمل',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.length < 20) {
      setState(() {
        _errorText = 'يرجى كتابة رسالة تعارف واضحة لا تقل عن 20 حرفاً لمنع الإزعاج';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _errorText = null;
    });

    final res = await ref.read(networkActionControllerProvider).sendContactRequest(
          receiverId: widget.receiverId,
          projectId: widget.projectId,
          reason: _selectedReason,
          introductionMessage: message,
        );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (res.isSuccess) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم إرسال طلب التواصل بنجاح، وستفتح المحادثة فور موافقة الطرف الآخر',
          ),
          backgroundColor: context.appColors.success.color,
        ),
      );
    } else {
      setState(() {
        _errorText = res.failureOrNull?.debugMessage ?? 'فشل إرسال الطلب';
      });
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
                backgroundColor: context.colors.primaryContainer,
                child: Icon(
                  Icons.connect_without_contact_rounded,
                  color: context.colors.primary,
                ),
              ),
              const Gap.sm(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إرسال طلب تواصل رسمي',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'إلى: ${widget.receiverName}${widget.projectName != null ? ' • بخصوص: ${widget.projectName}' : ''}',
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

          // Anti-Spam policy note
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: context.colors.primary,
                ),
                const Gap.xs(),
                Expanded(
                  child: Text(
                    'لحماية خصوصية مجتمع الأعمال، تفتح المحادثة الثنائية فقط بعد موافقة الطرف المستقبل على رسالتك التعارفية.',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap.md(),

          // Reason selector
          Text(
            'سبب التواصل الرئيسي',
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

          // Message
          Text(
            'رسالة التعارف والعرض الأولي',
            style: context.textStyles.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap.xs(),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'عرّف بنفسك وبمشروعك باختصار، وما هي القيمة المتبادلة التي تطمح لتحقيقها...',
              border: const OutlineInputBorder(),
              errorText: _errorText,
            ),
          ),
          const Gap.lg(),

          // Submit button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            icon: _isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_isSending ? 'جاري الإرسال...' : 'إرسال طلب التواصل'),
            onPressed: _isSending ? null : _submit,
          ),
        ],
      ),
    );
  }
}
