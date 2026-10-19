import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/network/domain/models/network_models.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';

/// Screen 56: Investor Profile Setup & Editing Screen.
class EditInvestorProfileScreen extends ConsumerStatefulWidget {
  const EditInvestorProfileScreen({super.key});

  @override
  ConsumerState<EditInvestorProfileScreen> createState() =>
      _EditInvestorProfileScreenState();
}

class _EditInvestorProfileScreenState
    extends ConsumerState<EditInvestorProfileScreen> {
  final _bioController = TextEditingController();
  final _minTicketController = TextEditingController();
  final _maxTicketController = TextEditingController();
  final _conditionsController = TextEditingController();

  String _investorType = 'مستثمر فردي';
  bool _showFinancialRangePublicly = false;
  final Set<String> _selectedSectors = {};
  final Set<ProjectStage> _selectedStages = {
    ProjectStage.prototype,
    ProjectStage.generatingRevenue,
  };
  bool _isSaving = false;

  final _allSectors = const [
    'التقنية والبرمجيات',
    'التجارة الإلكترونية',
    'الأغذية والمشروبات',
    'الخدمات اللوجستية',
    'الصحة والعافية',
    'العقارات والتطوير',
    'التعليم والتدريب',
    'الخدمات المالية (FinTech)',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final existing = ref.read(myInvestorProfileProvider).asData?.value;
      if (existing != null) {
        _bioController.text = existing.bio ?? '';
        _minTicketController.text = existing.minTicketSize?.toStringAsFixed(0) ?? '';
        _maxTicketController.text = existing.maxTicketSize?.toStringAsFixed(0) ?? '';
        _conditionsController.text = existing.contactConditions ?? '';
        setState(() {
          _investorType = existing.investorType;
          _showFinancialRangePublicly = existing.showFinancialRangePublicly;
          _selectedSectors.addAll(existing.sectorsOfInterest);
          _selectedStages.clear();
          _selectedStages.addAll(existing.preferredStages);
        });
      }
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _minTicketController.dispose();
    _maxTicketController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final profile = InvestorProfile(
      id: '',
      userId: '',
      investorType: _investorType,
      bio: _bioController.text.trim(),
      sectorsOfInterest: _selectedSectors.toList(),
      targetMarkets: const ['UAE'],
      preferredStages: _selectedStages.toList(),
      showFinancialRangePublicly: _showFinancialRangePublicly,
      minTicketSize: double.tryParse(_minTicketController.text.trim()),
      maxTicketSize: double.tryParse(_maxTicketController.text.trim()),
      currency: 'AED',
      contactConditions: _conditionsController.text.trim(),
    );

    final res = await ref
        .read(networkActionControllerProvider)
        .upsertInvestorProfile(profile);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ وتحديث ملفك الاستثماري بنجاح'),
          backgroundColor: context.appColors.success.color,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.debugMessage ?? 'فشل الحفظ'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد الملف الاستثماري'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            // Info Header
            Text(
              'بيانات ومعايير الاستثمار',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            Text(
              'عرّف رواد الأعمال وأصحاب المشاريع بنوع الفرص التي تبحث عنها والقطاعات ومجال التمويل المتاح لديك.',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Gap.lg(),

            // Investor Type
            Text(
              'نوع المستثمر',
              style: context.textStyles.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            DropdownButtonFormField<String>(
              value: _investorType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(
                  value: 'مستثمر فردي',
                  child: Text('مستثمر فردي (Individual Investor)'),
                ),
                DropdownMenuItem(
                  value: 'مستثمر ملائكي',
                  child: Text('مستثمر ملائكي (Angel Investor)'),
                ),
                DropdownMenuItem(
                  value: 'صندوق استثماري',
                  child: Text('صندوق استثمار جريء (Venture Capital)'),
                ),
                DropdownMenuItem(
                  value: 'مكتب عائلي',
                  child: Text('مكتب عائلي (Family Office)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _investorType = val);
              },
            ),
            const Gap.md(),

            // Bio
            Text(
              'نبذة استثمارية وخبراتك السابقة',
              style: context.textStyles.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'اكتب نبذة عن خبرتك والقطاعات التي استثمرت بها سابقاً...',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap.lg(),

            // Sectors
            Text(
              'القطاعات الاستثمارية المستهدفة',
              style: context.textStyles.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allSectors.map((sector) {
                final isSelected = _selectedSectors.contains(sector);
                return FilterChip(
                  label: Text(sector),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSectors.add(sector);
                      } else {
                        _selectedSectors.remove(sector);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const Gap.lg(),

            // Preferred Stages
            Text(
              'مراحل المشاريع المفضلة لديك',
              style: context.textStyles.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ProjectStage.values.map((stage) {
                final isSelected = _selectedStages.contains(stage);
                return FilterChip(
                  label: Text(stage.labelAr),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedStages.add(stage);
                      } else {
                        if (_selectedStages.length > 1) {
                          _selectedStages.remove(stage);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const Gap.lg(),

            // Financial Range
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: context.colors.outlineVariant),
                borderRadius: AppRadius.mediumAll,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'إظهار حجم التذكرة الاستثمارية علناً',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'عرض النطاق التمويلي بالدرهم الإماراتي في دليلك الاستثماري',
                      ),
                      value: _showFinancialRangePublicly,
                      onChanged: (val) =>
                          setState(() => _showFinancialRangePublicly = val),
                    ),
                    if (_showFinancialRangePublicly) ...[
                      const Gap.sm(),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minTicketController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'الحد الأدنى (AED)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const Gap.sm(),
                          Expanded(
                            child: TextField(
                              controller: _maxTicketController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'الحد الأقصى (AED)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Gap.md(),

            // Conditions
            Text(
              'شروط ومتطلبات التواصل الأولية',
              style: context.textStyles.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            TextField(
              controller: _conditionsController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText:
                    'مثال: يُشترط وجود خطة عمل مالية واضحة ونموذج أولي يعمل...',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap.xl(),

            // Save button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ ونشر الملف الاستثماري'),
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
