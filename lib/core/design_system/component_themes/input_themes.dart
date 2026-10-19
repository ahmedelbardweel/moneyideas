import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/tokens/app_radius.dart';
import 'package:moneyideas/core/design_system/tokens/app_spacing.dart';

/// M3 filled text fields with rounded top corners; outlined error states.
abstract final class InputThemes {
  static InputDecorationTheme decoration(ColorScheme c, TextTheme t) {
    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: AppRadius.mediumAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(c.primary, width: 2),
      errorBorder: border(c.error),
      focusedErrorBorder: border(c.error, width: 2),
      disabledBorder: border(Colors.transparent),
      labelStyle: t.bodyLarge?.copyWith(color: c.onSurfaceVariant),
      floatingLabelStyle: t.bodySmall?.copyWith(color: c.primary),
      hintStyle: t.bodyLarge?.copyWith(color: c.onSurfaceVariant),
      helperStyle: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
      errorStyle: t.bodySmall?.copyWith(color: c.error),
      errorMaxLines: 3,
      helperMaxLines: 3,
      prefixIconColor: c.onSurfaceVariant,
      suffixIconColor: c.onSurfaceVariant,
    );
  }

  static SearchBarThemeData searchBar(ColorScheme c, TextTheme t) =>
      SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(c.surfaceContainerHigh),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        textStyle: WidgetStatePropertyAll(t.bodyLarge),
        hintStyle: WidgetStatePropertyAll(
          t.bodyLarge?.copyWith(color: c.onSurfaceVariant),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      );

  static TextSelectionThemeData selection(ColorScheme c) =>
      TextSelectionThemeData(
        cursorColor: c.primary,
        selectionHandleColor: c.primary,
        selectionColor: c.primary.withValues(alpha: 0.3),
      );
}
