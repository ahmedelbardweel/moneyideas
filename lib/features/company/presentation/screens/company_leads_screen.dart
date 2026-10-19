import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/company/domain/models/offer_lead.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';

class CompanyLeadsScreen extends ConsumerStatefulWidget {
  const CompanyLeadsScreen({super.key});

  @override
  ConsumerState<CompanyLeadsScreen> createState() => _CompanyLeadsScreenState();
}

class _CompanyLeadsScreenState extends ConsumerState<CompanyLeadsScreen> {
  String _selectedFilter = 'all';

  void _showUpdateDialog(OfferLead lead) {
    var currentStatus = lead.status;
    final notesController = TextEditingController(text: lead.companyNotes ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('تحديث حالة طلب العميل'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'العميل: ${lead.userName ?? 'مستخدم مهتم'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Gap.sm(),
                  DropdownButtonFormField<LeadStatus>(
                    value: currentStatus,
                    decoration: const InputDecoration(
                      labelText: 'حالة المتابعة',
                    ),
                    items: LeadStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.labelAr),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => currentStatus = val);
                      }
                    },
                  ),
                  const Gap.md(),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات الشركة الداخلية',
                      hintText: 'اكتب ملاحظات فريق المبيعات هنا...',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await ref
                      .read(companyLeadsProvider.notifier)
                      .updateLeadStatus(
                        leadId: lead.id,
                        status: currentStatus,
                        companyNotes: notesController.text.trim(),
                      );
                },
                child: const Text('حفظ التحديث'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(companyLeadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات العملاء المهتمين (Leads)'),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: _selectedFilter == 'all',
                  onSelected: () => setState(() => _selectedFilter = 'all'),
                ),
                const Gap.xs(),
                _FilterChip(
                  label: 'جديد',
                  selected: _selectedFilter == 'new',
                  onSelected: () => setState(() => _selectedFilter = 'new'),
                ),
                const Gap.xs(),
                _FilterChip(
                  label: 'تم التواصل',
                  selected: _selectedFilter == 'contacted',
                  onSelected: () =>
                      setState(() => _selectedFilter == 'contacted'),
                ),
                const Gap.xs(),
                _FilterChip(
                  label: 'قيد التفاوض',
                  selected: _selectedFilter == 'in_negotiation',
                  onSelected: () =>
                      setState(() => _selectedFilter == 'in_negotiation'),
                ),
                const Gap.xs(),
                _FilterChip(
                  label: 'مغلق بنجاح',
                  selected: _selectedFilter == 'closed',
                  onSelected: () => setState(() => _selectedFilter == 'closed'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Leads List
          Expanded(
            child: leadsAsync.when(
              data: (leads) {
                var filtered = leads;
                if (_selectedFilter != 'all') {
                  filtered = filtered
                      .where((l) => l.status.toDbValue() == _selectedFilter)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.contact_mail_outlined,
                            size: 64,
                            color: context.colors.outline,
                          ),
                          const Gap.md(),
                          Text(
                            'لا توجد طلبات عملاء مطابقة',
                            style: context.textStyles.titleMedium,
                          ),
                          const Gap.xs(),
                          Text(
                            'تظهر هنا استفسارات وطلبات التواصل التي يرسلها الزوار لعروضك التجارية.',
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, idx) {
                    final lead = filtered[idx];
                    final statusColor = switch (lead.status) {
                      LeadStatus.newLead => context.colors.primary,
                      LeadStatus.contacted => const Color(0xFF1565C0),
                      LeadStatus.inNegotiation => const Color(0xFFE5A93C),
                      LeadStatus.closed => const Color(0xFF2E7D32),
                      LeadStatus.spam => context.colors.error,
                    };

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                        side: BorderSide(
                          color: context.colors.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _showUpdateDialog(lead),
                        borderRadius: AppRadius.mdAll,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      lead.userName ?? 'عميل مهتم',
                                      style: context.textStyles.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: AppRadius.smAll,
                                    ),
                                    child: Text(
                                      lead.status.labelAr,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (lead.offerTitle != null) ...[
                                const Gap.xxs(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.surfaceContainerHighest,
                                    borderRadius: AppRadius.xsAll,
                                  ),
                                  child: Text(
                                    'العرض: ${lead.offerTitle}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                              const Gap.sm(),
                              Text(
                                lead.inquiryMessage,
                                style: context.textStyles.bodyMedium,
                              ),
                              const Gap.sm(),
                              const Divider(height: 1),
                              const Gap.xs(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      if (lead.userPhone != null)
                                        Text(
                                          '📞 ${lead.userPhone}',
                                          style: context.textStyles.labelSmall,
                                        ),
                                      if (lead.userPhone != null &&
                                          lead.userEmail != null)
                                        const Text(' • '),
                                      if (lead.userEmail != null)
                                        Text(
                                          lead.userEmail!,
                                          style: context.textStyles.labelSmall,
                                        ),
                                    ],
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.edit_note_rounded,
                                      size: 16,
                                    ),
                                    label: const Text('تحديث الحالة'),
                                    onPressed: () => _showUpdateDialog(lead),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('خطأ: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
