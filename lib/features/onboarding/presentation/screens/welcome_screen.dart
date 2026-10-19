import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';

/// Screen 04: Welcome screen offering Sign Up, Sign In, and Guest Exploration.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Brand Icon Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.budget,
                  size: AppSizes.appLogo,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              const Gap.xl(),

              Text(
                l10n.welcomeTitle,
                style: context.textStyles.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap.sm(),
              Text(
                l10n.welcomeSubtitle,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Primary Actions
              AppButton(
                text: l10n.authRegister,
                isFullWidth: true,
                onPressed: () => context.push(AppRoutes.register),
              ),
              const Gap.md(),

              AppButton.outlined(
                text: l10n.authLogin,
                isFullWidth: true,
                onPressed: () => context.push(AppRoutes.login),
              ),
              const Gap.md(),

              // Guest exploration option
              AppButton.text(
                text: l10n.authGuest,
                icon: AppIcons.discover,
                onPressed: () => context.go(AppRoutes.home),
              ),
              const Gap.lg(),
            ],
          ),
        ),
      ),
    );
  }
}
