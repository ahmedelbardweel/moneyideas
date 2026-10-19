import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';

/// Screen 73: Multi-role management screen.
class ManageRolesScreen extends ConsumerStatefulWidget {
  const ManageRolesScreen({super.key});

  @override
  ConsumerState<ManageRolesScreen> createState() => _ManageRolesScreenState();
}

class _ManageRolesScreenState extends ConsumerState<ManageRolesScreen> {
  late Set<String> _selectedRoles;
  bool _isSaving = false;

  final _allRoles = const [
    (
      'individual',
      'فرد / باحث عن فكرة',
      'استكشاف الفرص والمشاريع المناسبة لمهاراتك وإمكاناتك',
      Icons.person_rounded,
    ),
    (
      'investor',
      'مستثمر',
      'البحث عن مشاريع قائمة أو أفكار واعدة لتمويلها كشريك مالي',
      Icons.trending_up_rounded,
    ),
    (
      'project_owner',
      'صاحب مشروع / رائد أعمال',
      'عرض مشروعك أو فكرتك والبحث عن شركاء تقنيين أو تسويقيين',
      Icons.rocket_launch_rounded,
    ),
    (
      'company',
      'شركة / مزود خدمات',
      'تقديم عروض رسمية وخدمات موثقة لرواد الأعمال والمستثمرين',
      Icons.business_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).asData?.value;
    _selectedRoles = (profile?.roles ?? ['individual']).toSet();
  }

  Future<void> _save() async {
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يجب اختيار دور واحد على الأقل'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final res = await ref
        .read(userProfileProvider.notifier)
        .updateActiveRoles(_selectedRoles.toList());

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تحديث أدوار الحساب بنجاح'),
          backgroundColor: context.appColors.success.color,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.debugMessage ?? 'فشل التحديث'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأدوار المتعددة'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            Text(
              'أدوارك الفعّالة في المنصة',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            Text(
              'يمكنك تفعيل أكثر من دور في نفس الحساب دون الحاجة للتسجيل مجدداً، للتنقل السلس بين الاستثمار والريادة.',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Gap.lg(),
            ..._allRoles.map((role) {
              final isSelected = _selectedRoles.contains(role.$1);

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.outlineVariant,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: AppRadius.mediumAll,
                ),
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.sm),
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedRoles.add(role.$1);
                      } else {
                        if (_selectedRoles.length > 1) {
                          _selectedRoles.remove(role.$1);
                        }
                      }
                    });
                  },
                  secondary: CircleAvatar(
                    backgroundColor: isSelected
                        ? context.colors.primaryContainer
                        : context.colors.surfaceContainerHighest,
                    child: Icon(
                      role.$4,
                      color: isSelected
                          ? context.colors.onPrimaryContainer
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    role.$2,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(role.$3),
                ),
              );
            }),
            const Gap.xl(),
            AppButton(
              text: 'حفظ الأدوار',
              isLoading: _isSaving,
              isFullWidth: true,
              onPressed: _save,
            ),
            if (_selectedRoles.contains('company')) ...[
              const Gap.md(),
              OutlinedButton.icon(
                icon: const Icon(Icons.business_rounded),
                label: const Text('الانتقال إلى لوحة تحكم الشركة'),
                onPressed: () => context.push(AppRoutes.companyDashboard),
              ),
            ],
            if (_selectedRoles.contains('admin')) ...[
              const Gap.md(),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.error,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.admin_panel_settings_rounded),
                label: const Text('الانتقال إلى لوحة تحكم الإدارة العليا (Admin)'),
                onPressed: () => context.push(AppRoutes.admin),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
