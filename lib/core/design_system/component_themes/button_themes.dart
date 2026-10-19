import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/tokens/app_dimensions.dart';
import 'package:moneyideas/core/design_system/tokens/app_radius.dart';
import 'package:moneyideas/core/design_system/tokens/app_spacing.dart';

/// Button themes: all buttons are pill-shaped (M3 full radius).
abstract final class ButtonThemes {
  static const _shape = StadiumBorder();
  static const _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: AppSpacing.sm,
  );
  static const _minSize = Size(64, AppSizes.buttonHeight);

  static FilledButtonThemeData filled(TextTheme text) => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: _shape,
      padding: _padding,
      minimumSize: _minSize,
      textStyle: text.labelLarge,
    ),
  );

  static ElevatedButtonThemeData elevated(TextTheme text) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: _shape,
          padding: _padding,
          minimumSize: _minSize,
          textStyle: text.labelLarge,
          elevation: AppElevation.level1,
        ),
      );

  static OutlinedButtonThemeData outlined(TextTheme text, ColorScheme c) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: _shape,
          padding: _padding,
          minimumSize: _minSize,
          textStyle: text.labelLarge,
          side: BorderSide(color: c.outline),
        ),
      );

  static TextButtonThemeData text(TextTheme text) => TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: _shape,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      minimumSize: _minSize,
      textStyle: text.labelLarge,
    ),
  );

  static IconButtonThemeData icon() => IconButtonThemeData(
    style: IconButton.styleFrom(
      minimumSize: const Size.square(AppSizes.minTouchTarget),
    ),
  );

  static FloatingActionButtonThemeData fab(ColorScheme c) =>
      FloatingActionButtonThemeData(
        backgroundColor: c.primaryContainer,
        foregroundColor: c.onPrimaryContainer,
        elevation: AppElevation.level3,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.largeAll),
      );

  static SegmentedButtonThemeData segmented(TextTheme text) =>
      SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(textStyle: text.labelLarge),
      );
}
