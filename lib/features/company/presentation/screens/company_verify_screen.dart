import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';
import 'package:moneyideas/features/company/presentation/widgets/company_verification_badge.dart';

class CompanyVerifyScreen extends ConsumerStatefulWidget {
  const CompanyVerifyScreen({super.key});

  @override
  ConsumerState<CompanyVerifyScreen> createState() => _CompanyVerifyScreenState();
}

class _CompanyVerifyScreenState extends ConsumerState<CompanyVerifyScreen> {
  final _documentUrlController = TextEditingController();
  final _fileNameController = TextEditingController(text: 'Trade_License_2026.pdf');
  String _selectedDocType = 'trade_license';
  bool _isLoading = false;

  final _docTypes = [
    ('trade_license', 'الرخصة التجارية سارية المفعول'),
    ('incorporation_cert', 'شهادة السجل التجاري / عقد التأسيس'),
    ('power_of_attorney', 'خطاب تفويض الممثل الرسمي'),
  ];

  @override
  void dispose() {
    _documentUrlController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _submitDocument() async {
    final url = _documentUrlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رابط أو مسار المستند')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await ref.read(myCompanyProvider.notifier).submitVerification(
          documentType: _selectedDocType,
          fileUrl: url,
          fileName: _fileNameController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال مستند التوثيق بنجاح للمراجعة!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.message ?? 'تعذر إرسال المستند'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyAsync = ref.watch(myCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('توثيق الشركة والاعتماد'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_rounded),
            tooltip: 'لوحة التحكم',
            onPressed: () => context.go(AppRoutes.companyDashboard),
          ),
        ],
      ),
      body: companyAsync.when(
        data: (company) {
          if (company == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.business_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const Gap.md(),
                    const Text('لم تقم بتسجيل شركة بعد'),
                    const Gap.lg(),
                    AppButton(
                      text: 'تسجيل شركة الآن',
                      onPressed: () => unawaited(context.push('/company/create')),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Status Card
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              company.tradeName,
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            CompanyVerificationBadge(
                              status: company.verificationStatus,
                            ),
                          ],
                        ),
                        const Gap.xs(),
                        Text(
                          'رقم الرخصة: ${company.tradeLicenseNumber}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'جهة الإصدار: ${company.licenseIssuingAuthority ?? 'غير محدد'}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        if (company.verificationNotes != null) ...[
                          const Gap.sm(),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: context.colors.errorContainer.withOpacity(0.3),
                              borderRadius: AppRadius.smAll,
                            ),
                            child: Text(
                              'ملاحظات المراجعة: ${company.verificationNotes}',
                              style: TextStyle(
                                color: context.colors.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Gap.lg(),

                // Status Explanations
                if (company.isVerified) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer.withOpacity(0.4),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: context.colors.primary,
                          size: 32,
                        ),
                        const Gap.sm(),
                        Expanded(
                          child: Text(
                            'تم التحقق من رخصتك التجارية رسمياً. عروضك التجارية تحمل شارة الموثوقية وتظهر في نتائج البحث المعتمدة.',
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: context.colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (company.verificationStatus ==
                    CompanyVerificationStatus.pendingReview) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.hourglass_top_rounded,
                          color: Color(0xFFE5A93C),
                          size: 32,
                        ),
                        const Gap.sm(),
                        Expanded(
                          child: Text(
                            'طلبك قيد المراجعة والتدقيق الإداري من قبل فريق المنصة. يستغرق التدقيق ما بين 24 إلى 48 ساعة عمل للتأكد من سريان الرخصة.',
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: const Color(0xFF6B4500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Upload Form
                  Text(
                    'رفع مستندات التوثيق الرسمية',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap.xs(),
                  Text(
                    'ارفع صورة أو ملف PDF واضح للرخصة التجارية سارية المفعول لتفعيل حساب الشركة ونشر العروض.',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const Gap.md(),

                  DropdownButtonFormField<String>(
                    value: _selectedDocType,
                    decoration: const InputDecoration(
                      labelText: 'نوع المستند *',
                      prefixIcon: Icon(Icons.file_present_rounded),
                    ),
                    items: _docTypes
                        .map((d) => DropdownMenuItem(value: d.$1, child: Text(d.$2)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDocType = val);
                    },
                  ),
                  const Gap.md(),

                  TextFormField(
                    controller: _fileNameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الملف *',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const Gap.md(),

                  TextFormField(
                    controller: _documentUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الملف أو المستند الرقمي *',
                      hintText: 'https://storage.example.com/license.pdf',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                  ),
                  const Gap.lg(),

                  AppButton(
                    text: 'إرسال المستندات للتدقيق',
                    isLoading: _isLoading,
                    onPressed: _submitDocument,
                  ),
                ],

                const Gap.xl(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('العودة إلى لوحة تحكم الشركة'),
                  onPressed: () => context.go(AppRoutes.companyDashboard),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}
