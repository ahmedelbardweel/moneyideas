import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/admin/domain/models/admin_models.dart';
import 'package:moneyideas/features/admin/presentation/controllers/admin_controller.dart';

/// Screen 87: Admin Reports, Fraud Complaints, and Moderation Resolution.
class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  Future<void> _handleResolve(
    BuildContext context,
    WidgetRef ref,
    AdminReportItem report,
  ) async {
    final notesController =
        TextEditingController(text: report.adminNotes ?? '');
    String selectedStatus = report.status;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('البت في البلاغ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تحديد الإجراء المتخذ:'),
                const Gap.xs(),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('جديد وبانتظار المراجعة'),
                    ),
                    DropdownMenuItem(
                      value: 'under_investigation',
                      child: Text('قيد التحقيق'),
                    ),
                    DropdownMenuItem(
                      value: 'action_taken',
                      child: Text('تم اتخاذ إجراء (حظر / إزالة)'),
                    ),
                    DropdownMenuItem(
                      value: 'dismissed',
                      child: Text('حفظ البلاغ (غير صحيح)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedStatus = val);
                  },
                ),
                const Gap.md(),
                const Text('ملاحظات الإدارة:'),
                const Gap.xs(),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'اكتب حيثيات القرار المتخذ...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('حفظ القرار'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true) return;

    final res = await ref.read(adminActionControllerProvider).resolveReport(
          reportId: report.id,
          status: selectedStatus,
          adminNotes: notesController.text.trim(),
        );

    if (!context.mounted) return;

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ قرار الإدارة بنجاح'),
          backgroundColor: context.appColors.success.color,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.debugMessage ?? 'فشلت العملية'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(adminReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('البلاغات والنزاهة وحماية المنصة'),
      ),
      body: SafeArea(
        child: reportsAsync.when(
          data: (reports) {
            if (reports.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 64,
                      color: context.colors.outline,
                    ),
                    const Gap.md(),
                    Text(
                      'لا توجد بلاغات مسجلة حالياً',
                      style: context.textStyles.titleMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: AppSpacing.page,
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: context.colors.outlineVariant),
                    borderRadius: AppRadius.mediumAll,
                  ),
                  child: Padding(
                    padding: AppSpacing.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'نوع البلاغ: ${report.reportedEntityType}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onErrorContainer,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                report.statusLabelAr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap.sm(),
                        Text(
                          report.reason,
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (report.details != null &&
                            report.details!.isNotEmpty) ...[
                          const Gap.xxs(),
                          Text(
                            report.details!,
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (report.adminNotes != null &&
                            report.adminNotes!.isNotEmpty) ...[
                          const Gap.sm(),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'قرار المشرف: ${report.adminNotes}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                        const Gap.md(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.gavel_rounded, size: 16),
                            label: const Text('البت في البلاغ'),
                            onPressed: () => _handleResolve(context, ref, report),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}
