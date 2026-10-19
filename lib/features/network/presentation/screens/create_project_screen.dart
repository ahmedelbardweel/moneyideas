import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/discover/presentation/controllers/discover_controller.dart';
import 'package:moneyideas/features/network/domain/models/network_models.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';

/// Screen 59: Project Publishing Form for Entrepreneurs.
class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _summaryController = TextEditingController();
  final _problemController = TextEditingController();
  final _solutionController = TextEditingController();
  final _audienceController = TextEditingController();
  final _revenueModelController = TextEditingController();

  String? _selectedCategoryId;
  ProjectType _selectedType = ProjectType.idea;
  ProjectStage _selectedStage = ProjectStage.concept;
  String _selectedHelpNeeded = 'شريك تقني';
  bool _declarationAccepted = false;
  bool _isSaving = false;

  final _helpNeededTypes = const [
    'شريك تقني',
    'شريك تسويق ومبيعات',
    'استثمار وتمويل',
    'مرشد ومستشار أعمال',
    'شريك تشغيلي',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _summaryController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    _audienceController.dispose();
    _revenueModelController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى اختيار قطاع وتصنيف المشروع'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يجب الموافقة على إقرار صحة البيانات والنزاهة'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final project = Project(
      id: '',
      ownerId: '',
      categoryId: _selectedCategoryId!,
      name: _nameController.text.trim(),
      summary: _summaryController.text.trim(),
      problemStatement: _problemController.text.trim(),
      solutionStatement: _solutionController.text.trim(),
      targetAudience: _audienceController.text.trim(),
      revenueModel: _revenueModelController.text.trim(),
      type: _selectedType,
      stage: _selectedStage,
      helpNeededType: _selectedHelpNeeded,
    );

    final res =
        await ref.read(networkActionControllerProvider).createProject(project);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم نشر مشروعك بنجاح في شبكة الأعمال'),
          backgroundColor: context.appColors.success.color,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.debugMessage ?? 'فشل النشر'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مشروع جديد'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.page,
            children: [
              Text(
                'بيانات المشروع والفرصة',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap.xs(),
              Text(
                'اعرض مشروعك القائم أو فكرتك الواعدة لاستقطاب الشركاء التقنيين أو المستثمرين المهتمين بقطاعك.',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const Gap.lg(),

              // Project Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المشروع *',
                  hintText: 'مثال: منصة فريش كافيه للمقاهي المتخصصة',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().length < 3
                    ? 'يرجى إدخال اسم لا يقل عن 3 أحرف'
                    : null,
              ),
              const Gap.md(),

              // Category
              categoriesAsync.when(
                data: (categories) {
                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'قطاع وتصنيف المشروع *',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              c.nameAr,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                    validator: (val) => val == null ? 'يرجى اختيار القطاع' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('خطأ في تحميل التصنيفات: $e'),
              ),
              const Gap.md(),

              // Type & Stage (Stacked for mobile responsive layouts)
              DropdownButtonFormField<ProjectType>(
                isExpanded: true,
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'نوع العرض *',
                  border: OutlineInputBorder(),
                ),
                items: ProjectType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t.labelAr,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const Gap.md(),
              DropdownButtonFormField<ProjectStage>(
                isExpanded: true,
                initialValue: _selectedStage,
                decoration: const InputDecoration(
                  labelText: 'مرحلة المشروع *',
                  border: OutlineInputBorder(),
                ),
                items: ProjectStage.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.labelAr,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStage = val);
                },
              ),

              // Regulatory disclosure for investment requests
              if (_selectedType == ProjectType.investmentRequest) ...[
                const Gap.sm(),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.amber.shade900),
                      const Gap.xs(),
                      Expanded(
                        child: Text(
                          'تنبيه تنظيمي: طلبات الاستثمار المالي تخضع لمراجعة وتدقيق الإدارة مسبقاً قبل نشرها علناً لضمان الامتثال للوائح الاستثمار.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Gap.md(),

              // Help Needed
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedHelpNeeded,
                decoration: const InputDecoration(
                  labelText: 'نوع الشراكة أو المساعدة المطلوبة *',
                  border: OutlineInputBorder(),
                ),
                items: _helpNeededTypes
                    .map(
                      (h) => DropdownMenuItem(
                        value: h,
                        child: Text(
                          h,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedHelpNeeded = val);
                },
              ),
              const Gap.md(),

              // Summary
              TextFormField(
                controller: _summaryController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'الملخص المكثف (Elevator Pitch) *',
                  hintText: 'سطران يلخصان فكرة المشروع وجاذبيته التجارية...',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().length < 10
                    ? 'يرجى كتابة ملخص واضح'
                    : null,
              ),
              const Gap.md(),

              // Problem & Solution
              TextFormField(
                controller: _problemController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'المشكلة التي يعالجها المشروع *',
                  hintText: 'ما هي الفجوة أو الصعوبة التي يعاني منها العملاء في السوق؟',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'يرجى تعبئة المشكلة' : null,
              ),
              const Gap.md(),

              TextFormField(
                controller: _solutionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الحل المقترح والقيمة المضافة *',
                  hintText: 'كيف يحل منتجك/خدمتك هذه المشكلة بشكل أفضل وأسرع؟',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'يرجى تعبئة الحل' : null,
              ),
              const Gap.md(),

              // Target Audience & Revenue Model
              TextFormField(
                controller: _audienceController,
                decoration: const InputDecoration(
                  labelText: 'السوق والجمهور المستهدف',
                  hintText: 'مثال: أصحاب الأعمال الصغيرة ومحبو القهوة في دبي',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap.md(),

              TextFormField(
                controller: _revenueModelController,
                decoration: const InputDecoration(
                  labelText: 'نموذج تحقيق الأرباح (Business Model)',
                  hintText: 'مثال: اشتراكات شهرية متكررة وعمولة على الطلبات',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap.lg(),

              // Declaration checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _declarationAccepted,
                onChanged: (val) =>
                    setState(() => _declarationAccepted = val ?? false),
                title: const Text(
                  'أقر بصحة البيانات المقدمة وخلوها من أي وعود أرباح مضللة أو غير مضمونة',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const Gap.lg(),

              // Submit button
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
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
                    : const Icon(Icons.rocket_launch_rounded),
                label: Text(_isSaving ? 'جاري النشر...' : 'نشر المشروع في الشبكة'),
                onPressed: _isSaving ? null : _submit,
              ),
              const Gap.xl(),
            ],
          ),
        ),
      ),
    );
  }
}
