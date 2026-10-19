import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/design_system.dart';

enum AppButtonVariant { filled, outlined, text }

/// Material 3 compliant button adhering to Google design simplicity:
/// - M3 Pill shape (AppRadius.full)
/// - Integrated loading spinner without altering button dimensions
/// - Minimum 48dp touch target
class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = AppSizes.buttonHeightLarge,
  });

  const AppButton.outlined({
    required this.text,
    super.key,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = AppSizes.buttonHeightLarge,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    required this.text,
    super.key,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = AppSizes.buttonHeight,
  }) : variant = AppButtonVariant.text;

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: AppSizes.iconMedium,
        height: AppSizes.iconMedium,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: variant == AppButtonVariant.filled
              ? context.colors.onPrimary
              : context.colors.primary,
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppSizes.iconSmall),
          const Gap.sm(),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      buttonChild = Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final buttonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(isFullWidth ? double.infinity : 64, height),
      ),
    );

    Widget widget;
    switch (variant) {
      case AppButtonVariant.filled:
        widget = FilledButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case AppButtonVariant.outlined:
        widget = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case AppButtonVariant.text:
        widget = TextButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: buttonChild,
        );
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: widget);
    }
    return widget;
  }
}
