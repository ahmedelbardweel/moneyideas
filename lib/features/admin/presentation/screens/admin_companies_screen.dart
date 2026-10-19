import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/admin/presentation/controllers/admin_controller.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';

/// Screen 84: Admin Company Verification & Commercial Audit Screen.
class AdminCompaniesScreen extends ConsumerStatefulWidget {
  const AdminCompaniesScreen({super.key});

  @override
  ConsumerState<AdminCompaniesScreen> createState() =>
      _AdminCompaniesScreenState();
}

class _AdminCompaniesScreenState extends ConsumerState<AdminCompaniesScreen> {
  String? _selectedFilter = 'pending_review';

  Future<void> _handleVerification(
    Company company,
    CompanyVerificationStatus newStatus,
  ) async {
    String? notes;
    if (newStatus == CompanyVerificationStatus.rejected) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('سبب رفض التوثيق'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'يرجى كتابة سبب الرفض أو النواقص في الرخصة التجارية ليتمكن العميل من تصحيحها:',
              ),
              const Gap.sm(),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'مثال: رقم الرخصة منتهي أو غير مطابق للاسم التجاري',
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
              child: const Text('تأكيد الرفض'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
      notes = controller.text.trim();
    }

    final res = await ref.read(adminActionControllerProvider).verifyCompany(
          companyId: company.id,
          status: newStatus,
          notes: notes,
        );

    if (!mounted) return;

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == CompanyVerificationStatus.verified
                ? 'تم اعتماد وتوثيق الشركة بنجاح'
                : 'تم تحديث حالة الشركة',
          ),
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
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(adminCompaniesProvider(_selectedFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تدقيق وتوثيق الشركات'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('بانتظار التدقيق'),
                    selected: _selectedFilter == 'pending_review',
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = 'pending_review');
                    },
                  ),
                  const Gap.xs(),
                  ChoiceChip(
                    label: const Text('موثقة رسمياً'),
                    selected: _selectedFilter == 'verified',
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = 'verified');
                    },
                  ),
                  const Gap.xs(),
                  ChoiceChip(
                    label: const Text('مرفوضة'),
                    selected: _selectedFilter == 'rejected',
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = 'rejected');
                    },
                  ),
                  const Gap.xs(),
                  ChoiceChip(
                    label: const Text('كافة الشركات'),
                    selected: _selectedFilter == null,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = null);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // List
            Expanded(
              child: companiesAsync.when(
                data: (companies) {
                  if (companies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 64,
                            color: context.colors.outline,
                          ),
                          const Gap.md(),
                          Text(
                            'لا توجد شركات في هذا التصنيف حالياً',
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
                    itemCount: companies.length,
                    itemBuilder: (context, index) {
                      final company = companies[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: company.verificationStatus ==
                                    CompanyVerificationStatus.verified
                                ? Colors.green.shade300
                                : context.colors.outlineVariant,
                          ),
                          borderRadius: AppRadius.mediumAll,
                        ),
                        child: Padding(
                          padding: AppSpacing.card,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: context.colors.primaryContainer,
                                    child: const Icon(Icons.business_rounded),
                                  ),
                                  const Gap.sm(),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          company.tradeName,
                                          style: context.textStyles.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'الاسم القانوني: ${company.legalName}',
                                          style: context.textStyles.bodySmall?.copyWith(
                                            color: context.colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _StatusChip(status: company.verificationStatus),
                                ],
                              ),
                              const Gap.md(),
                              const Divider(),
                              const Gap.xs(),

                              // DED Details
                              Row(
                                children: [
                                  Expanded(
                                    child: _DetailRow(
                                      label: 'رقم الرخصة',
                                      value: company.tradeLicenseNumber,
                                    ),
                                  ),
                                  Expanded(
                                    child: _DetailRow(
                                      label: 'جهة الإصدار',
                                      value: company.licenseIssuingAuthority ??
                                          'اقتصادية دبي',
                                    ),
                                  ),
                                ],
                              ),
                              const Gap.xs(),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DetailRow(
                                      label: 'البريد الرسمي',
                                      value: company.officialEmail,
                                    ),
                                  ),
                                  Expanded(
                                    child: _DetailRow(
                                      label: 'المدينة والنشاط',
                                      value:
                                          '${company.city} • ${company.businessType}',
                                    ),
                                  ),
                                ],
                              ),

                              if (company.verificationNotes != null &&
                                  company.verificationNotes!.isNotEmpty) ...[
                                const Gap.sm(),
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: context.colors.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ملاحظات التدقيق السابقة: ${company.verificationNotes}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],

                              const Gap.md(),

                              // Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (company.verificationStatus !=
                                      CompanyVerificationStatus.rejected) ...[
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.close_rounded, size: 16),
                                      label: const Text('رفض التوثيق'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: context.colors.error,
                                      ),
                                      onPressed: () => _handleVerification(
                                        company,
                                        CompanyVerificationStatus.rejected,
                                      ),
                                    ),
                                    const Gap.sm(),
                                  ],
                                  if (company.verificationStatus !=
                                      CompanyVerificationStatus.verified) ...[
                                    FilledButton.icon(
                                      icon: const Icon(Icons.check_rounded, size: 16),
                                      label: const Text('اعتماد وتوثيق الشركة'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                      ),
                                      onPressed: () => _handleVerification(
                                        company,
                                        CompanyVerificationStatus.verified,
                                      ),
                                    ),
                                  ] else ...[
                                    TextButton.icon(
                                      icon: const Icon(Icons.refresh_rounded, size: 16),
                                      label: const Text('إعادة للمراجعة'),
                                      onPressed: () => _handleVerification(
                                        company,
                                        CompanyVerificationStatus.pendingReview,
                                      ),
                                    ),
                                  ],
                                ],
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
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
            fontSize: 11,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final CompanyVerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CompanyVerificationStatus.verified => (
          'موثقة رسمياً',
          Colors.green.shade700
        ),
      CompanyVerificationStatus.pendingReview => (
          'قيد التدقيق',
          Colors.orange.shade800
        ),
      CompanyVerificationStatus.rejected => ('مرفوضة', Colors.red.shade700),
      CompanyVerificationStatus.unverified => ('غير موثقة', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
