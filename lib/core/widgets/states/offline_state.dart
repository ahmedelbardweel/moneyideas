import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';

/// Full screen state for when connection is required and unavailable.
class OfflineState extends StatelessWidget {
  const OfflineState({super.key, this.onRetry});

  final VoidCallback? onRetry;

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
                AppIcons.offline,
                size: AppSizes.iconXLarge,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Gap.xl(),
            Text(
              context.l10n.networkErrorTitle,
              style: context.textStyles.titleLarge?.copyWith(
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap.sm(),
            Text(
              context.l10n.networkErrorMessage,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const Gap.xl(),
              AppButton(
                text: context.l10n.commonRetry,
                icon: AppIcons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact persistent banner shown at the top of a screen when working offline with cached data.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.appColors.warning.container,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.offline,
            size: AppSizes.iconSmall,
            color: context.appColors.warning.onContainer,
          ),
          const Gap.sm(),
          Expanded(
            child: Text(
              context.l10n.networkErrorMessage,
              style: context.textStyles.labelSmall?.copyWith(
                color: context.appColors.warning.onContainer,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
