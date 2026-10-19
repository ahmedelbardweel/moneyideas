import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';

/// Screen gate shown when guest users access authenticated actions (e.g. saving, chat, offers).
class UnauthorizedState extends StatelessWidget {
  const UnauthorizedState({super.key, this.onLogin});

  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.locked,
                size: AppSizes.iconXLarge,
                color: context.colors.primary,
              ),
            ),
            const Gap.xl(),
            Text(
              context.l10n.unauthorizedTitle,
              style: context.textStyles.titleLarge?.copyWith(
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap.sm(),
            Text(
              context.l10n.unauthorizedMessage,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onLogin != null) ...[
              const Gap.xl(),
              AppButton(
                text: context.l10n.authLogin,
                icon: AppIcons.person,
                onPressed: onLogin,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
