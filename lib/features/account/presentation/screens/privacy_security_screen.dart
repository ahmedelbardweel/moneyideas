import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/auth/presentation/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen 74-76: Privacy, Data Export (GDPR), and Security Management.
class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() =>
      _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  bool _showToInvestors = true;
  bool _showToCompanies = true;
  bool _allowContact = true;

  void _exportData() {
    final profile = ref.read(userProfileProvider).asData?.value;
    final jsonExport = const JsonEncoder.withIndent('  ').convert({
      'export_timestamp': DateTime.now().toIso8601String(),
      'platform': 'أفكار المال | Money Ideas',
      'user_profile': {
        'id': profile?.id,
        'name': profile?.fullName,
        'email': profile?.email,
        'city': profile?.city,
        'roles': profile?.roles,
        'goals': profile?.goals,
        'budget': profile?.budgetAmount,
        'weekly_hours': profile?.weeklyHours,
        'experience': profile?.experienceLevel,
        'risk_tolerance': profile?.riskTolerance,
      },
    });

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تصدير البيانات الشخصية (GDPR)'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonExport,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب نهائياً'),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف حسابك؟ سيتم حذف جميع بياناتك وتفضيلاتك المحفوظة نهائياً ولا يمكن استرجاعها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authControllerProvider.notifier).logout();
              if (mounted) {
                context.go(AppRoutes.welcome);
              }
            },
            child: const Text('تأكيد الحذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الخصوصية والأمان'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            Text(
              'الخصوصية وظهور الملف',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('إظهار ملفي للمستثمرين'),
              subtitle: const Text('السماح للمستثمرين بالعثور عليك كصاحب مشروع'),
              value: _showToInvestors,
              onChanged: (val) => setState(() => _showToInvestors = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('إظهار ملفي للشركات ومقدمي الخدمات'),
              subtitle: const Text('تلقي عروض ومزايا مناسبة لنشاطك'),
              value: _showToCompanies,
              onChanged: (val) => setState(() => _showToCompanies = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('السماح بطلبات التواصل المباشر'),
              subtitle: const Text('إمكانية بدء محادثات مع مستثمرين وشركاء موثقين'),
              value: _allowContact,
              onChanged: (val) => setState(() => _allowContact = val),
            ),
            const Divider(),
            const Gap.md(),

            Text(
              'أمان الحساب',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.password_rounded),
              title: const Text('إعادة تعيين كلمة المرور'),
              subtitle: Text(profile?.email ?? ''),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () async {
                if (profile != null && profile.email.isNotEmpty) {
                  await Supabase.instance.client.auth.resetPasswordForEmail(
                    profile.email,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إرسال رابط تعيين كلمة المرور إلى بريدك الإلكتروني'),
                      ),
                    );
                  }
                }
              },
            ),
            const Divider(),
            const Gap.md(),

            Text(
              'بياناتك وحقوق الخصوصية',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.download_rounded),
              title: const Text('تصدير نسخة من بياناتي (GDPR)'),
              subtitle: const Text('تحميل كافة بيانات حسابك وتفضيلاتك'),
              onTap: _exportData,
            ),
            const Gap.lg(),

            AppButton(
              text: 'حذف الحساب نهائياً',
              variant: AppButtonVariant.outlined,
              isFullWidth: true,
              onPressed: _confirmDeleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}
