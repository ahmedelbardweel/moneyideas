import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';
import 'package:moneyideas/features/company/presentation/controllers/offer_create_controller.dart';
import 'package:moneyideas/features/discover/domain/models/category_model.dart';
import 'package:moneyideas/features/discover/presentation/controllers/discover_controller.dart';

class CreateOfferStepperScreen extends ConsumerStatefulWidget {
  const CreateOfferStepperScreen({super.key});

  @override
  ConsumerState<CreateOfferStepperScreen> createState() =>
      _CreateOfferStepperScreenState();
}

class _CreateOfferStepperScreenState
    extends ConsumerState<CreateOfferStepperScreen> {
  // Step 0 controllers
  final _titleController = TextEditingController();
  final _serviceTypeController =
      TextEditingController(text: 'خدمات التأسيس والحلول التشغيلية');
  final _descriptionController = TextEditingController();
  String _selectedCategoryId = '';

  // Step 1 controllers
  bool _isPriceOnDemand = false;
  final _priceController = TextEditingController(text: '2500');
  final _additionalFeesController = TextEditingController();
  final Set<String> _selectedCities = {'Dubai', 'Abu Dhabi'};
  DateTime _validUntil = DateTime.now().add(const Duration(days: 60));

  // Step 2 controllers
  final _mediaUrlController = TextEditingController();
  final _termsController = TextEditingController(
    text:
        'العرض ساري للمشاريع المؤهلة. لا يشمل الرسوم الحكومية المباشرة إلا إذا ذُكر ذلك صراحة.',
  );
  final List<String> _mediaUrls = [];

  bool _isSubmitting = false;

  final _allCities = [
    ('Dubai', 'دبي'),
    ('Abu Dhabi', 'أبوظبي'),
    ('Sharjah', 'الشارقة'),
    ('Ajman', 'عجمان'),
    ('Ras Al Khaimah', 'رأس الخيمة'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _additionalFeesController.dispose();
    _mediaUrlController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer({required bool asDraft}) async {
    final draft = ref.read(offerCreateControllerProvider);
    if (!asDraft && !draft.declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الموافقة على إقرار صحة البيانات لنشر العرض'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final res = await ref
        .read(offerCreateControllerProvider.notifier)
        .submitOffer(asDraft: asDraft);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            asDraft
                ? 'تم حفظ العرض كمسودة بنجاح'
                : 'تم إرسال العرض للمراجعة والتدقيق الإداري بنجاح!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.message ?? 'تعذر حفظ العرض'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(offerCreateControllerProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء عرض تجاري جديد'),
      ),
      body: Column(
        children: [
          // Stepper Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _StepIndicator(
                  step: 0,
                  currentStep: draft.currentStep,
                  title: 'البيانات',
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: draft.currentStep >= 1
                        ? context.colors.primary
                        : context.colors.outlineVariant,
                  ),
                ),
                _StepIndicator(
                  step: 1,
                  currentStep: draft.currentStep,
                  title: 'التسعير',
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: draft.currentStep >= 2
                        ? context.colors.primary
                        : context.colors.outlineVariant,
                  ),
                ),
                _StepIndicator(
                  step: 2,
                  currentStep: draft.currentStep,
                  title: 'الشروط',
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: draft.currentStep >= 3
                        ? context.colors.primary
                        : context.colors.outlineVariant,
                  ),
                ),
                _StepIndicator(
                  step: 3,
                  currentStep: draft.currentStep,
                  title: 'المعاينة',
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: switch (draft.currentStep) {
                0 => _buildStep0BasicInfo(categoriesAsync),
                1 => _buildStep1PricingAndTarget(),
                2 => _buildStep2MediaAndTerms(),
                _ => _buildStep3PreviewAndSubmit(draft),
              },
            ),
          ),

          // Footer Navigation Buttons
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (draft.currentStep > 0)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('السابق'),
                    onPressed: () {
                      ref
                          .read(offerCreateControllerProvider.notifier)
                          .setStep(draft.currentStep - 1);
                    },
                  )
                else
                  const SizedBox.shrink(),
                if (draft.currentStep < 3)
                  FilledButton.icon(
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('التالي'),
                    onPressed: _validateAndProceed,
                  )
                else
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitOffer(asDraft: true),
                        child: const Text('حفظ كمسودة'),
                      ),
                      const Gap.sm(),
                      FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitOffer(asDraft: false),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('إرسال للمراجعة'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _validateAndProceed() {
    final step = ref.read(offerCreateControllerProvider).currentStep;
    final notifier = ref.read(offerCreateControllerProvider.notifier);

    if (step == 0) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال عنوان واضح للعرض')),
        );
        return;
      }
      if (_selectedCategoryId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار التصنيف المناسب')),
        );
        return;
      }
      notifier.updateBasicInfo(
        title: _titleController.text.trim(),
        categoryId: _selectedCategoryId,
        serviceType: _serviceTypeController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      notifier.setStep(1);
    } else if (step == 1) {
      final price = double.tryParse(_priceController.text) ?? 0;
      notifier.updatePricingAndTarget(
        isPriceOnDemand: _isPriceOnDemand,
        price: price,
        priceCurrency: 'AED',
        additionalFees: _additionalFeesController.text.trim(),
        targetCities: _selectedCities.toList(),
        validUntil: _validUntil,
      );
      notifier.setStep(2);
    } else if (step == 2) {
      if (_termsController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى توضيح شروط وأحكام العرض')),
        );
        return;
      }
      notifier.updateMediaAndTerms(
        terms: _termsController.text.trim(),
        mediaUrls: _mediaUrls,
      );
      notifier.setStep(3);
    }
  }

  Widget _buildStep0BasicInfo(AsyncValue<List<CategoryModel>> categoriesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '1. البيانات الأساسية للعرض التجاري',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          'اكتب عنواناً محدداً ووصفاً دقيقاً للخدمة أو الحزمة التي تقدمها شركتك.',
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.lg(),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'عنوان العرض التجاري *',
            hintText: 'e.g. باقة تأسيس متجر إلكتروني متكامل مع بوابات الدفع',
            prefixIcon: Icon(Icons.title_rounded),
          ),
        ),
        const Gap.md(),
        categoriesAsync.when(
          data: (cats) {
            if (_selectedCategoryId.isEmpty && cats.isNotEmpty) {
              _selectedCategoryId = cats.first.id;
            }
            return DropdownButtonFormField<String>(
              value: _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
              decoration: const InputDecoration(
                labelText: 'التصنيف *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: cats.map((c) {
                return DropdownMenuItem<String>(
                  value: c.id,
                  child: Text(c.nameAr),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategoryId = val);
              },
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const Text('تعذر تحميل التصنيفات'),
        ),
        const Gap.md(),
        TextFormField(
          controller: _serviceTypeController,
          decoration: const InputDecoration(
            labelText: 'نوع الخدمة *',
            hintText: 'e.g. استشارات / برمجة / تأسيس شركات',
            prefixIcon: Icon(Icons.work_outline_rounded),
          ),
        ),
        const Gap.md(),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'الوصف التفصيلي للعرض والخدمات المشمولة *',
            hintText:
                'اشرح بالتفصيل ما سيحصل عليه العميل، المخرجات، وفترة التنفيذ...',
          ),
        ),
      ],
    );
  }

  Widget _buildStep1PricingAndTarget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '2. التسعير والنطاق الجغرافي',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          'حدد هيكل التسعير بشفافية مع توضيح أي رسوم خارجية.',
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.lg(),
        SwitchListTile(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
            side: BorderSide(color: context.colors.outlineVariant),
          ),
          title: const Text('السعر عند الطلب'),
          subtitle: const Text('حدد هذا الخيار إذا كانت التكلفة تعتمد على حجم متطلبات العميل'),
          value: _isPriceOnDemand,
          onChanged: (val) => setState(() => _isPriceOnDemand = val),
        ),
        if (!_isPriceOnDemand) ...[
          const Gap.md(),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'السعر بالدرهم الإماراتي (AED) *',
              hintText: '2500',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
        ],
        const Gap.md(),
        TextFormField(
          controller: _additionalFeesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'توضيح الرسوم الإضافية (إن وجدت)',
            hintText: 'e.g. لا تشمل رسوم الدوائر الحكومية وضريبة القيمة المضافة',
          ),
        ),
        const Gap.lg(),
        Text(
          'المدن المستهدفة بالعرض',
          style: context.textStyles.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Wrap(
          spacing: 8,
          children: _allCities.map((city) {
            final isSelected = _selectedCities.contains(city.$1);
            return FilterChip(
              label: Text(city.$2),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCities.add(city.$1);
                  } else if (_selectedCities.length > 1) {
                    _selectedCities.remove(city.$1);
                  }
                });
              },
            );
          }).toList(),
        ),
        const Gap.lg(),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
            side: BorderSide(color: context.colors.outlineVariant),
          ),
          leading: const Icon(Icons.event_available_rounded),
          title: const Text('تاريخ انتهاء صلاحية العرض'),
          subtitle: Text(
            '${_validUntil.year}-${_validUntil.month.toString().padLeft(2, '0')}-${_validUntil.day.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
          trailing: const Icon(Icons.edit_calendar_rounded),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _validUntil,
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (picked != null) setState(() => _validUntil = picked);
          },
        ),
      ],
    );
  }

  Widget _buildStep2MediaAndTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '3. الوسائط والشروط والأحكام الإلزامية',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          'أرفق رابط صورة واضحة للشعار أو الخدمة واكتب الشروط لتجنب أي خلاف تعاقدي.',
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.lg(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _mediaUrlController,
                decoration: const InputDecoration(
                  labelText: 'رابط صورة العرض (URL)',
                  hintText: 'https://images.unsplash.com/...',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
            ),
            const Gap.sm(),
            IconButton.filled(
              icon: const Icon(Icons.add_rounded),
              onPressed: () {
                final url = _mediaUrlController.text.trim();
                if (url.isNotEmpty) {
                  setState(() {
                    _mediaUrls.add(url);
                    _mediaUrlController.clear();
                  });
                }
              },
            ),
          ],
        ),
        if (_mediaUrls.isNotEmpty) ...[
          const Gap.sm(),
          Wrap(
            spacing: 8,
            children: _mediaUrls.map((url) {
              return Chip(
                avatar: const Icon(Icons.image, size: 16),
                label: Text(
                  url.length > 25 ? '${url.substring(0, 22)}...' : url,
                  style: const TextStyle(fontSize: 11),
                ),
                onDeleted: () => setState(() => _mediaUrls.remove(url)),
              );
            }).toList(),
          ),
        ],
        const Gap.lg(),
        TextFormField(
          controller: _termsController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'الشروط والأحكام *',
            hintText: 'حدد آلية الدفع، مدة التنفيذ، وشروط الاسترجاع أو الإلغاء...',
          ),
        ),
        const Gap.md(),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.secondaryContainer.withOpacity(0.3),
            borderRadius: AppRadius.mdAll,
          ),
          child: Row(
            children: [
              Icon(
                Icons.policy_outlined,
                color: context.colors.secondary,
                size: 24,
              ),
              const Gap.sm(),
              Expanded(
                child: Text(
                  'سياسة النشر تمنع صراحة أي ادعاءات مضللة مثل «أرباح مضمونة 100%» أو وعود غير قابلة للتحقق. تخضع جميع العروض للتدقيق الإداري.',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3PreviewAndSubmit(OfferCreateDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '4. المعاينة النهائية والإقرار',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          'راجع تفاصيل العرض بعناية قبل إرساله للمراجعة.',
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.lg(),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgAll,
            side: BorderSide(
              color: context.colors.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.title,
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap.xxs(),
                Text(
                  draft.serviceType,
                  style: TextStyle(color: context.colors.primary),
                ),
                const Gap.md(),
                Text(
                  draft.description,
                  style: context.textStyles.bodyMedium,
                ),
                const Gap.md(),
                const Divider(),
                const Gap.xs(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('السعر المقترح:'),
                    Text(
                      draft.isPriceOnDemand
                          ? 'عند الطلب'
                          : '${draft.price.toStringAsFixed(0)} ${draft.priceCurrency}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Gap.xs(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المدن:'),
                    Text(draft.targetCities.join('، ')),
                  ],
                ),
                const Gap.xs(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('صالح حتى:'),
                    Text(
                      '${draft.validUntil?.year}-${draft.validUntil?.month.toString().padLeft(2, '0')}-${draft.validUntil?.day.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Gap.lg(),
        CheckboxListTile(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
            side: BorderSide(color: context.colors.outlineVariant),
          ),
          title: const Text('إقرار بصحة البيانات والامتثال'),
          subtitle: const Text(
            'أقر بأن شركتي مرخصة قانونياً لتقديم هذه الخدمات وأن جميع البيانات والشروط المذكورة أعلاه صحيحة وتتحمل الشركة المسؤولية القانونية عنها.',
          ),
          value: draft.declarationAccepted,
          onChanged: (val) {
            ref
                .read(offerCreateControllerProvider.notifier)
                .toggleDeclaration(val ?? false);
          },
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.step,
    required this.currentStep,
    required this.title,
  });

  final int step;
  final int currentStep;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isActive = currentStep == step;
    final isDone = currentStep > step;

    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isDone
              ? context.colors.primary
              : isActive
                  ? context.colors.primaryContainer
                  : context.colors.surfaceContainerHighest,
          child: isDone
              ? Icon(Icons.check, size: 16, color: context.colors.onPrimary)
              : Text(
                  '${step + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? context.colors.primary
                        : context.colors.onSurfaceVariant,
                  ),
                ),
        ),
        const Gap.xxs(),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? context.colors.primary : context.colors.outline,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
