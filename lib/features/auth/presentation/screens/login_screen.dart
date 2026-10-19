import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/role_navigation.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/validation/validators.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/core/widgets/inputs/app_text_field.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/auth/presentation/controllers/auth_controller.dart';

/// Screen 07: User Login with session persistence and error mapping.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final res = await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (mounted) {
      if (res.isSuccess) {
        // Fetch fresh profile from Supabase to check role and dispatch
        final profile = await ref.refresh(userProfileProvider.future);
        final roles = profile?.roles ?? ['individual'];
        if (mounted) {
          RoleNavigationHelper.dispatchUser(context, roles);
        }
      } else {
        final failure = res.failureOrNull;
        final message = failure?.debugMessage ?? context.l10n.serverErrorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authLogin),
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
                  l10n.authLogin,
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
                  validator: Validators.loginPassword(context),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const Gap.sm(),

                // Remember me & Forgot password row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (val) {
                            setState(() => _rememberMe = val ?? true);
                          },
                        ),
                        Text(
                          l10n.authRememberMe,
                          style: context.textStyles.bodySmall,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.resetPassword),
                      child: Text(l10n.authForgotPassword),
                    ),
                  ],
                ),
                const Gap.lg(),

                AppButton(
                  text: l10n.authLogin,
                  isFullWidth: true,
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const Gap.lg(),

                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: Text(l10n.authDontHaveAccount),
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
