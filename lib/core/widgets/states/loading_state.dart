import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/design_system.dart';

/// Clean M3 loading indicator state.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: context.colors.primary,
              strokeWidth: 3,
            ),
            if (message != null) ...[
              const Gap.lg(),
              Text(
                message!,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
