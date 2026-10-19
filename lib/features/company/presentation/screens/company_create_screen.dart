import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';

class CompanyCreateScreen extends ConsumerStatefulWidget {
  const CompanyCreateScreen({super.key});

  @override
  ConsumerState<CompanyCreateScreen> createState() => _CompanyCreateScreenState();
}

class _CompanyCreateScreenState extends ConsumerState<CompanyCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _legalNameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _authorityController = TextEditingController(text: 'دائرة الاقتصاد والسياحة (DET)');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedBusinessType = 'حلول تقنية وبرمجيات';
  String _selectedCity = 'Dubai';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));
  bool _isLoading = false;

  final _businessTypes = [
    'حلول تقنية وبرمجيات',
    'تجارة إلكترونية وتوريد',
    'تسويق وإعلانات رقمية',
    'استشارات أعمال وقانونية',
    'عقارات وخدمات لوجستية',
    'خدمات مالية وتشغيلية',
  ];

  final _cities = [
    ('Dubai', 'دبي'),
    ('Abu Dhabi', 'أبوظبي'),
    ('Sharjah', 'الشارقة'),
    ('Ajman', 'عجمان'),
    ('Ras Al Khaimah', 'رأس الخيمة'),
  ];

  @override
  void dispose() {
    _legalNameController.dispose();
    _tradeNameController.dispose();
    _licenseNumberController.dispose();
    _authorityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final company = Company(
      id: '',
      ownerId: '',
      legalName: _legalNameController.text.trim(),
      tradeName: _tradeNameController.text.trim(),
      businessType: _selectedBusinessType,
      tradeLicenseNumber: _licenseNumberController.text.trim(),
      licenseIssuingAuthority: _authorityController.text.trim(),
      licenseExpiryDate: _expiryDate,
      officialEmail: _emailController.text.trim().toLowerCase(),
      officialPhone: _phoneController.text.trim(),
      websiteUrl: _websiteController.text.trim().isNotEmpty
          ? _websiteController.text.trim()
          : null,
      city: _selectedCity,
      bio: _bioController.text.trim(),
    );

    final result =
        await ref.read(myCompanyProvider.notifier).createCompany(company);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء ملف الشركة بنجاح! انتقل لخطوة التوثيق.'),
          backgroundColor: Colors.green,
        ),
      );
      context.pushReplacement('/company/verify');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? 'تعذر تسجيل الشركة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل حساب شركة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withOpacity(0.4),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business_center_rounded,
                      color: context.colors.primary,
                      size: 28,
                    ),
                    const Gap.sm(),
                    Expanded(
                      child: Text(
                        'يتيح لك حساب الشركة نشر عروض تجارية وخدمات معتمدة والوصول للباحثين عن شراكات وفرص.',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap.lg(),

              // Trade Name
              TextFormField(
                controller: _tradeNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم التجاري للشركة *',
                  hintText: 'e.g. شركة الأفق للحلول الرقمية',
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'الاسم التجاري مطلوب' : null,
              ),
              const Gap.md(),

              // Legal Name
              TextFormField(
                controller: _legalNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم القانوني المسجل في الرخصة *',
                  hintText: 'e.g. Al-Ofuq Digital Solutions LLC',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'الاسم القانوني مطلوب' : null,
              ),
              const Gap.md(),

              // Business Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBusinessType,
                decoration: const InputDecoration(
                  labelText: 'نوع النشاط *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _businessTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBusinessType = val);
                },
              ),
              const Gap.md(),

              // Trade License Number
              TextFormField(
                controller: _licenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'رقم الرخصة التجارية *',
                  hintText: 'e.g. CN-1029384 أو 1029384',
                  prefixIcon: Icon(Icons.receipt_long_rounded),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'رقم الرخصة مطلوب' : null,
              ),
              const Gap.md(),

              // License Issuing Authority
              TextFormField(
                controller: _authorityController,
                decoration: const InputDecoration(
                  labelText: 'جهة إصدار الرخصة *',
                  hintText: 'e.g. اقتصادية دبي / المنطقة الحرة',
                  prefixIcon: Icon(Icons.account_balance_rounded),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'جهة الإصدار مطلوبة' : null,
              ),
              const Gap.md(),

              // Expiry Date Picker Tile
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                  side: BorderSide(color: context.colors.outlineVariant),
                ),
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('تاريخ انتهاء صلاحية الرخصة'),
                subtitle: Text(
                  '${_expiryDate.year}-${_expiryDate.month.toString().padLeft(2, '0')}-${_expiryDate.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: _pickExpiryDate,
              ),
              const Gap.md(),

              // City
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(
                  labelText: 'المدينة / الإمارة *',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: _cities
                    .map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$2)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCity = val);
                },
              ),
              const Gap.md(),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني الرسمي *',
                  hintText: 'info@company.ae',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'البريد الرسمي مطلوب';
                  if (!val.contains('@')) return 'صيغة بريد غير صحيحة';
                  return null;
                },
              ),
              const Gap.md(),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'الهاتف الرسمي للتواصل',
                  hintText: '+971 4 000 0000',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const Gap.md(),

              // Website
              TextFormField(
                controller: _websiteController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'الموقع الإلكتروني',
                  hintText: 'https://company.ae',
                  prefixIcon: Icon(Icons.language_rounded),
                ),
              ),
              const Gap.md(),

              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'نبذة عن الشركة وخدماتها',
                  hintText: 'اكتب وصفاً موجزاً عن مجالات عمل شركتك والخدمات التي تقدمها...',
                ),
              ),
              const Gap.xl(),

              // Submit Button
              AppButton(
                text: 'حفظ ومتابعة التوثيق',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const Gap.md(),
            ],
          ),
        ),
      ),
    );
  }
}
