import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/validation/validators.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/core/widgets/inputs/app_text_field.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';

/// Screen 71: Edit personal profile info with real Supabase persistence.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).asData?.value;
    if (profile != null) {
      _nameController.text = profile.fullName;
      _cityController.text = profile.city;
      _phoneController.text = profile.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final res = await ref.read(userProfileProvider.notifier).updateInfo(
          fullName: _nameController.text.trim(),
          city: _cityController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ التغييرات بنجاح'),
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
        title: const Text('تعديل الملف الشخصي'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  prefixIcon: AppIcons.person,
                  validator: Validators.personName(context),
                  textInputAction: TextInputAction.next,
                ),
                const Gap.md(),
                AppTextField(
                  controller: _cityController,
                  label: 'المدينة / السوق المستهدف',
                  prefixIcon: Icons.location_city_rounded,
                  validator: Validators.required(context),
                  textInputAction: TextInputAction.next,
                ),
                const Gap.md(),
                AppTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف (اختياري)',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                ),
                const Gap.xl(),
                AppButton(
                  text: 'حفظ التعديلات',
                  isLoading: _isSaving,
                  isFullWidth: true,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
