import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/tokens/app_radius.dart';

/// Chips, switches, checkboxes, radios, sliders and badges.
abstract final class SelectionThemes {
  static ChipThemeData chip(ColorScheme c, TextTheme t) => ChipThemeData(
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.smallAll),
    side: BorderSide(color: c.outlineVariant),
    labelStyle: t.labelLarge?.copyWith(color: c.onSurfaceVariant),
    secondaryLabelStyle: t.labelLarge?.copyWith(
      color: c.onSecondaryContainer,
    ),
    selectedColor: c.secondaryContainer,
    checkmarkColor: c.onSecondaryContainer,
    backgroundColor: Colors.transparent,
    showCheckmark: true,
  );

  static SwitchThemeData switchTheme() => const SwitchThemeData();

  static CheckboxThemeData checkbox() => const CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  static SliderThemeData slider(ColorScheme c) => SliderThemeData(
    activeTrackColor: c.primary,
    inactiveTrackColor: c.secondaryContainer,
    thumbColor: c.primary,
    showValueIndicator: ShowValueIndicator.onDrag,
  );

  static BadgeThemeData badge(ColorScheme c, TextTheme t) => BadgeThemeData(
    backgroundColor: c.error,
    textColor: c.onError,
    textStyle: t.labelSmall,
  );
}
