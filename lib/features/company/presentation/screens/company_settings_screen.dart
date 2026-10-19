import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/company/data/repositories/company_repository.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';
import 'package:moneyideas/features/company/domain/models/company_member.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';
import 'package:moneyideas/features/company/presentation/widgets/company_verification_badge.dart';

class CompanySettingsScreen extends ConsumerStatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  ConsumerState<CompanySettingsScreen> createState() =>
      _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends ConsumerState<CompanySettingsScreen> {
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final company = ref.read(myCompanyProvider).asData?.value;
    if (company != null) {
      _phoneController.text = company.officialPhone ?? '';
      _websiteController.text = company.websiteUrl ?? '';
      _bioController.text = company.bio ?? '';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final company = ref.read(myCompanyProvider).asData?.value;
    if (company == null) return;

    setState(() => _isSaving = true);

    final updated = company.copyWith(
      officialPhone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      websiteUrl: _websiteController.text.trim().isNotEmpty
          ? _websiteController.text.trim()
          : null,
      bio: _bioController.text.trim(),
    );

    final res = await ref.read(myCompanyProvider.notifier).updateCompany(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ بيانات الشركة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.message ?? 'تعذر حفظ البيانات'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showInviteMemberDialog(String companyId) {
    final emailController = TextEditingController();
    var selectedRole = CompanyMemberRole.supportAgent;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('دعوة عضو فريق جديد'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني للعضو *',
                    hintText: 'member@example.com',
                  ),
                ),
                const Gap.md(),
                DropdownButtonFormField<CompanyMemberRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'الدور والصلاحية *',
                  ),
                  items: [
                    CompanyMemberRole.admin,
                    CompanyMemberRole.supportAgent,
                  ].map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(r.labelAr),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedRole = val);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  if (email.isEmpty) return;
                  Navigator.of(ctx).pop();

                  final repo = ref.read(companyRepositoryProvider);
                  final res = await repo.inviteMember(
                    companyId: companyId,
                    email: email,
                    role: selectedRole,
                  );

                  if (context.mounted) {
                    if (res.isSuccess) {
                      ref.invalidate(companyMembersProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تمت إضافة عضو الفريق بنجاح!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            res.failureOrNull?.message ?? 'تعذر إضافة العضو',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('إرسال الدعوة'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyAsync = ref.watch(myCompanyProvider);
    final membersAsync = ref.watch(companyMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الشركة والفريق'),
      ),
      body: companyAsync.when(
        data: (company) {
          if (company == null) {
            return const Center(child: Text('لم يتم العثور على الشركة'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Identity
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
                              style: context.textStyles.titleLarge?.copyWith(
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
                          'الاسم القانوني: ${company.legalName}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'رقم الرخصة: ${company.tradeLicenseNumber}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap.xl(),

                Text(
                  'بيانات التواصل والملف العام',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap.md(),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'الهاتف الرسمي للتواصل',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const Gap.md(),

                TextFormField(
                  controller: _websiteController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'الموقع الإلكتروني',
                    prefixIcon: Icon(Icons.language_rounded),
                  ),
                ),
                const Gap.md(),

                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'نبذة عن الشركة',
                  ),
                ),
                const Gap.lg(),

                AppButton(
                  text: 'حفظ التعديلات',
                  isLoading: _isSaving,
                  onPressed: _saveSettings,
                ),
                const Gap.xxl(),

                // Team Members Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أعضاء الفريق والصلاحيات ✦',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('إضافة عضو'),
                      onPressed: () => _showInviteMemberDialog(company.id),
                    ),
                  ],
                ),
                const Gap.sm(),

                membersAsync.when(
                  data: (members) {
                    return Column(
                      children: [
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll,
                            side: BorderSide(
                              color: context.colors.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: context.colors.primaryContainer,
                            child: Icon(
                              Icons.admin_panel_settings_rounded,
                              color: context.colors.primary,
                            ),
                          ),
                          title: const Text('أنت (مالك الشركة)'),
                          subtitle: Text(company.officialEmail),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.12),
                              borderRadius: AppRadius.smAll,
                            ),
                            child: Text(
                              'مالك',
                              style: TextStyle(
                                color: context.colors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        ...members.map((m) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.mdAll,
                                side: BorderSide(
                                  color: context.colors.outlineVariant
                                      .withOpacity(0.5),
                                ),
                              ),
                              leading: CircleAvatar(
                                child: Text(
                                  m.userFullName?.characters.first ?? 'M',
                                ),
                              ),
                              title: Text(m.userFullName ?? 'عضو فريق'),
                              subtitle: Text(m.userEmail ?? ''),
                              trailing: Text(m.role.labelAr),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('تعذر تحميل أعضاء الفريق: $e'),
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
