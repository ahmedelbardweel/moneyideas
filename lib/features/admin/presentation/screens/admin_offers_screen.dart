import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/admin/presentation/controllers/admin_controller.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';

/// Screen 85: Admin Commercial Offer Review & Audit Screen.
class AdminOffersScreen extends ConsumerStatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  ConsumerState<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends ConsumerState<AdminOffersScreen> {
  String? _selectedFilter = 'in_review';

  Future<void> _handleOfferReview(
    CompanyOffer offer,
    OfferStatus newStatus,
  ) async {
    String? notes;
    if (newStatus == OfferStatus.needsChanges ||
        newStatus == OfferStatus.rejected) {
      final controller = TextEditingController();
      final isChanges = newStatus == OfferStatus.needsChanges;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(isChanges ? 'طلب تعديلات على العرض' : 'رفض العرض التجاري'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isChanges
                    ? 'اكتب التعديلات المطلوبة من الشركة (مثل توضيح بنود التسليم أو الشفافية في الأسعار):'
                    : 'اكتب سبب رفض العرض التجاري لتوثيقه في السجل:',
              ),
              const Gap.sm(),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isChanges
                      ? 'مثال: يرجى تفصيل مدة التنفيذ وضمان الخدمة'
                      : 'مثال: وعود أرباح غير واقعية مخالفة للوائح',
                  border: const OutlineInputBorder(),
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
              child: const Text('تأكيد القرار'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
      notes = controller.text.trim();
    }

    final res = await ref.read(adminActionControllerProvider).reviewOffer(
          offerId: offer.id,
          status: newStatus,
          notes: notes,
        );

    if (!mounted) return;

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == OfferStatus.approved
                ? 'تم اعتماد ونشر العرض التجاري بنجاح'
                : 'تم تحديث حالة العرض وملاحظات التدقيق',
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
    final offersAsync = ref.watch(adminOffersProvider(_selectedFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة وتدقيق العروض'),
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
                    selected: _selectedFilter == 'in_review',
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = 'in_review');
                    },
                  ),
                  const Gap.xs(),
                  ChoiceChip(
                    label: const Text('معتمدة ونشطة'),
                    selected: _selectedFilter == 'approved',
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = 'approved');
                    },
                  ),
                  const Gap.xs(),
                  ChoiceChip(
                    label: const Text('تحتاج تعديلات'),
                    selected: _selectedFilter == 'needs_changes',
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = 'needs_changes');
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
                    label: const Text('الكل'),
                    selected: _selectedFilter == null,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = null);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Offers List
            Expanded(
              child: offersAsync.when(
                data: (offers) {
                  if (offers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 64,
                            color: context.colors.outline,
                          ),
                          const Gap.md(),
                          Text(
                            'لا توجد عروض في هذا التصنيف حالياً',
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
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: offer.status == OfferStatus.approved
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
                                    radius: 20,
                                    backgroundColor: context.colors.primaryContainer,
                                    child: const Icon(Icons.local_offer_rounded, size: 20),
                                  ),
                                  const Gap.sm(),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          offer.title,
                                          style: context.textStyles.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          offer.price != null
                                              ? 'السعر: ${offer.price!.toStringAsFixed(0)} ${offer.priceCurrency}'
                                              : 'السعر: حسب الاتفاق والمواصفات',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: context.colors.primary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _OfferStatusChip(status: offer.status),
                                ],
                              ),
                              const Gap.sm(),
                              Text(
                                offer.description,
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap.md(),
                              const Divider(),
                              const Gap.xs(),

                              // Anti-fraud and regulatory terms
                              Row(
                                children: [
                                  Icon(
                                    offer.termsAndConditions.isNotEmpty
                                        ? Icons.gavel_rounded
                                        : Icons.warning_rounded,
                                    size: 16,
                                    color: offer.termsAndConditions.isNotEmpty
                                        ? Colors.green.shade700
                                        : context.colors.error,
                                  ),
                                  const Gap.xxs(),
                                  Text(
                                    offer.termsAndConditions.isNotEmpty
                                        ? 'تم توثيق الشروط والبنود الرسمية'
                                        : 'لم تحدد بنود إضافية',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: offer.termsAndConditions.isNotEmpty
                                          ? Colors.green.shade800
                                          : context.colors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              if (offer.adminReviewNotes != null &&
                                  offer.adminReviewNotes!.isNotEmpty) ...[
                                const Gap.xs(),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: context.colors.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ملاحظات المراجعة: ${offer.adminReviewNotes}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],

                              const Gap.md(),

                              // Action Buttons
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.xs,
                                alignment: WrapAlignment.end,
                                children: [
                                  if (offer.status != OfferStatus.rejected)
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.block_rounded, size: 16),
                                      label: const Text('رفض'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: context.colors.error,
                                      ),
                                      onPressed: () => _handleOfferReview(
                                        offer,
                                        OfferStatus.rejected,
                                      ),
                                    ),
                                  if (offer.status != OfferStatus.needsChanges)
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.edit_note_rounded, size: 16),
                                      label: const Text('طلب تعديلات'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.orange.shade800,
                                      ),
                                      onPressed: () => _handleOfferReview(
                                        offer,
                                        OfferStatus.needsChanges,
                                      ),
                                    ),
                                  if (offer.status != OfferStatus.approved)
                                    FilledButton.icon(
                                      icon: const Icon(Icons.check_rounded, size: 16),
                                      label: const Text('اعتماد ونشر العرض'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                      ),
                                      onPressed: () => _handleOfferReview(
                                        offer,
                                        OfferStatus.approved,
                                      ),
                                    ),
                                  if (offer.status == OfferStatus.approved)
                                    TextButton.icon(
                                      icon: const Icon(Icons.refresh_rounded, size: 16),
                                      label: const Text('إعادة للمراجعة'),
                                      onPressed: () => _handleOfferReview(
                                        offer,
                                        OfferStatus.inReview,
                                      ),
                                    ),
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

class _OfferStatusChip extends StatelessWidget {
  const _OfferStatusChip({required this.status});

  final OfferStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OfferStatus.approved => ('معتمد ونشط', Colors.green.shade700),
      OfferStatus.inReview => ('بانتظار المراجعة', Colors.orange.shade800),
      OfferStatus.needsChanges => ('يحتاج تعديلات', Colors.amber.shade900),
      OfferStatus.rejected => ('مرفوض', Colors.red.shade700),
      OfferStatus.draft => ('مسودة', Colors.grey),
      OfferStatus.paused => ('موقوف مؤقتاً', Colors.blueGrey),
      OfferStatus.expired => ('منتهي الصلاحية', Colors.brown),
      OfferStatus.archived => ('مؤرشف', Colors.black54),
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
