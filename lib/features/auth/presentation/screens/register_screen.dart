import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/validation/rules/auth_rules.dart';
import 'package:moneyideas/core/validation/validators.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/core/widgets/inputs/app_text_field.dart';
import 'package:moneyideas/features/auth/presentation/controllers/auth_controller.dart';

/// Screen 05: User Registration with password strength meter and terms acceptance.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = AuthRules.passwordStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorMustAccept)),
      );
      return;
    }

    final res = await ref.read(authControllerProvider.notifier).register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (res.isSuccess) {
      final authState = ref.read(authControllerProvider);
      if (authState.isLoggedIn) {
        context.go(AppRoutes.setup);
      } else {
        unawaited(
          context.push(
            AppRoutes.verifyEmail,
            extra: _emailController.text.trim(),
          ),
        );
      }
    } else {
      final msg = res.failureOrNull?.debugMessage ?? 'فشل إنشاء الحساب';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authRegister),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.authRegister,
                  style: context.textStyles.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap.xs(),
                Text(
                  l10n.welcomeSubtitle,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const Gap.xl(),

                // Full Name
                AppTextField(
                  controller: _nameController,
                  label: l10n.authFullName,
                  prefixIcon: AppIcons.person,
                  validator: Validators.personName(context),
                  textInputAction: TextInputAction.next,
                ),
                const Gap.md(),

                // Email
                AppTextField(
                  controller: _emailController,
                  label: l10n.authEmail,
                  prefixIcon: AppIcons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email(context),
                  textInputAction: TextInputAction.next,
                ),
                const Gap.md(),

                // Password
                AppTextField(
                  controller: _passwordController,
                  label: l10n.authPassword,
                  prefixIcon: AppIcons.password,
                  isPassword: true,
                  validator: Validators.strongPassword(context),
                  textInputAction: TextInputAction.next,
                ),
                if (_passwordController.text.isNotEmpty) ...[
                  const Gap.xs(),
                  LinearProgressIndicator(
                    value: _passwordStrength,
                    color: _passwordStrength < 0.5
                        ? context.colors.error
                        : (_passwordStrength < 0.8
                            ? context.appColors.warning.color
                            : context.appColors.success.color),
                    backgroundColor: context.colors.surfaceContainerHighest,
                  ),
                ],
                const Gap.md(),

                // Confirm Password
                AppTextField(
                  controller: _confirmPasswordController,
                  label: l10n.authConfirmPassword,
                  prefixIcon: AppIcons.password,
                  isPassword: true,
                  validator: Validators.confirmPassword(
                    context,
                    () => _passwordController.text,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const Gap.md(),

                // Terms agreement checkbox
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _agreedToTerms,
                  onChanged: (val) {
                    setState(() => _agreedToTerms = val ?? false);
                  },
                  title: Text(
                    l10n.authAgreeTerms,
                    style: context.textStyles.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const Gap.lg(),

                AppButton(
                  text: l10n.authRegister,
                  isFullWidth: true,
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const Gap.lg(),

                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(l10n.authAlreadyHaveAccount),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
