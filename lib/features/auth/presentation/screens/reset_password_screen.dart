import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/validation/validators.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/core/widgets/inputs/app_text_field.dart';
import 'package:moneyideas/features/auth/presentation/controllers/auth_controller.dart';

/// Screen 08: Password Recovery with confirmation state.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final res = await ref.read(authControllerProvider.notifier).resetPassword(
          _emailController.text.trim(),
        );

    if (mounted && res.isSuccess) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authResetPasswordTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: _submitted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap.xxl(),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: context.appColors.success.container,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.check,
                        size: AppSizes.iconXLarge,
                        color: context.appColors.success.onContainer,
                      ),
                    ),
                    const Gap.xl(),
                    Text(
                      l10n.authResetSuccess,
                      style: context.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap.md(),
                    Text(
                      _emailController.text.trim(),
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap.xxl(),
                    AppButton.outlined(
                      text: l10n.authLogin,
                      isFullWidth: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.authResetPasswordTitle,
                        style: context.textStyles.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap.xs(),
                      Text(
                        l10n.authResetPasswordDesc,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const Gap.xl(),
                      AppTextField(
                        controller: _emailController,
                        label: l10n.authEmail,
                        prefixIcon: AppIcons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email(context),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                      const Gap.xl(),
                      AppButton(
                        text: l10n.authSendResetLink,
                        isFullWidth: true,
                        isLoading: authState.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
