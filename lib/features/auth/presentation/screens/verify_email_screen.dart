import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/validation/validators.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/core/widgets/inputs/app_text_field.dart';
import 'package:moneyideas/features/auth/presentation/controllers/auth_controller.dart';

/// Screen 06: Email OTP Verification with countdown timer for resend.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, this.email = ''});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    final res = await ref.read(authControllerProvider.notifier).verifyOtp(
          email: widget.email,
          otp: _otpController.text.trim(),
        );

    if (!mounted) return;

    if (res.isSuccess) {
      // Transition to Profile Setup Stepper (Screen 09)
      context.go(AppRoutes.setup);
    } else {
      final message = res.failureOrNull?.debugMessage ?? 'رمز التحقق غير صحيح أو منتهي الصلاحية';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    _startTimer();
    final res = await ref
        .read(authControllerProvider.notifier)
        .resendOtp(email: widget.email);

    if (!mounted) return;

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إعادة إرسال رمز التحقق إلى بريدك الإلكتروني بنجاح'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.debugMessage ?? 'فشل إعادة الإرسال'),
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
        title: Text(l10n.authVerifyEmailTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.email,
                      size: AppSizes.iconXLarge,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const Gap.xl(),
                Text(
                  l10n.authVerifyEmailTitle,
                  style: context.textStyles.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap.xs(),
                Text(
                  l10n.authVerifyEmailDesc(widget.email),
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const Gap.xl(),

                // OTP field
                AppTextField(
                  controller: _otpController,
                  label: 'رمز التحقق (OTP)',
                  hint: '123456',
                  prefixIcon: AppIcons.password,
                  keyboardType: TextInputType.number,
                  validator: Validators.otp(context),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _verify(),
                ),
                const Gap.xl(),

                AppButton(
                  text: l10n.commonConfirm,
                  isFullWidth: true,
                  isLoading: authState.isLoading,
                  onPressed: _verify,
                ),
                const Gap.lg(),

                // Resend Timer
                Center(
                  child: _secondsRemaining > 0
                      ? Text(
                          l10n.authResendInSeconds(_secondsRemaining),
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        )
                      : TextButton.icon(
                          icon: const Icon(AppIcons.refresh),
                          label: Text(l10n.authResendOtp),
                          onPressed: _resendOtp,
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
