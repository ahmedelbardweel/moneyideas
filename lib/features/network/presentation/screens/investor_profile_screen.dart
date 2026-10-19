import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/network/domain/models/network_models.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';
import 'package:moneyideas/features/network/presentation/dialogs/send_contact_request_dialog.dart';

final investorDetailsProvider =
    FutureProvider.family<InvestorProfile?, String>((ref, id) async {
  final repo = ref.watch(networkRepositoryProvider);
  final res = await repo.getInvestorProfile(id);
  return res.valueOrNull;
});

/// Screen 55: Public Investor Credentials & Criteria View.
class InvestorProfileScreen extends ConsumerWidget {
  const InvestorProfileScreen({required this.investorId, super.key});

  final String investorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorAsync = ref.watch(investorDetailsProvider(investorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الاستثماري'),
      ),
      body: SafeArea(
        child: investorAsync.when(
          data: (investor) {
            if (investor == null) {
              return const Center(child: Text('لم يتم العثور على الملف الاستثماري'));
            }

            return ListView(
              padding: AppSpacing.page,
              children: [
                // Header Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: context.colors.outlineVariant),
                    borderRadius: AppRadius.mediumAll,
                  ),
                  child: Padding(
                    padding: AppSpacing.card,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: context.colors.primaryContainer,
                          child: Text(
                            investor.fullName?.isNotEmpty == true
                                ? investor.fullName![0]
                                : 'I',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: context.colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const Gap.md(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    investor.fullName ?? 'مستثمر معتمد',
                                    style: context.textStyles.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (investor.isVerified) ...[
                                    const Gap.xxs(),
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 18,
                                      color: Colors.green.shade700,
                                    ),
                                  ],
                                ],
                              ),
                              const Gap.xxs(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  investor.investorType,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.primary,
                                  ),
                                ),
                              ),
                              const Gap.xxs(),
                              Text(
                                '${investor.city} • الإمارات',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap.md(),

                // Bio
                if (investor.bio != null && investor.bio!.isNotEmpty) ...[
                  Text(
                    'نبذة استثمارية',
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap.xs(),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: context.colors.outlineVariant),
                      borderRadius: AppRadius.mediumAll,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        investor.bio!,
                        style: context.textStyles.bodyMedium,
                      ),
                    ),
                  ),
                  const Gap.md(),
                ],

                // Sectors of Interest
                if (investor.sectorsOfInterest.isNotEmpty) ...[
                  Text(
                    'القطاعات الاستثمارية المستهدفة',
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap.xs(),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: investor.sectorsOfInterest.map((s) {
                      return Chip(
                        label: Text(s),
                        backgroundColor: context.colors.primaryContainer.withValues(alpha: 0.4),
                      );
                    }).toList(),
                  ),
                  const Gap.md(),
                ],

                // Preferred Stages
                if (investor.preferredStages.isNotEmpty) ...[
                  Text(
                    'مراحل المشاريع المفضلة',
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap.xs(),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: investor.preferredStages.map((st) {
                      return Chip(
                        avatar: const Icon(Icons.rocket_launch_outlined, size: 16),
                        label: Text(st.labelAr),
                      );
                    }).toList(),
                  ),
                  const Gap.md(),
                ],

                // Financial Ticket Range
                if (investor.showFinancialRangePublicly &&
                    (investor.minTicketSize != null ||
                        investor.maxTicketSize != null)) ...[
                  Text(
                    'نطاق التمويل المتاح (Ticket Size)',
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap.xs(),
                  Card(
                    color: context.colors.primaryContainer.withValues(alpha: 0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: context.colors.primary.withValues(alpha: 0.3),
                      ),
                      borderRadius: AppRadius.mediumAll,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on_rounded,
                            color: context.colors.primary,
                          ),
                          const Gap.sm(),
                          Text(
                            '${investor.minTicketSize?.toStringAsFixed(0) ?? "0"} - ${investor.maxTicketSize?.toStringAsFixed(0) ?? "غير محدد"} ${investor.currency}',
                            style: context.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap.md(),
                ],

                // Contact Conditions
                if (investor.contactConditions != null &&
                    investor.contactConditions!.isNotEmpty) ...[
                  Text(
                    'شروط التواصل الأولية',
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap.xs(),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius: AppRadius.mediumAll,
                    ),
                    child: Text(
                      investor.contactConditions!,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Gap.lg(),
                ],

                // Action CTA
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('إرسال طلب تواصل وشراكة'),
                  onPressed: () => SendContactRequestDialog.show(
                    context,
                    receiverId: investor.userId,
                    receiverName: investor.fullName ?? 'المستثمر',
                  ),
                ),
                const Gap.xl(),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}
