import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/component_themes/button_themes.dart';
import 'package:moneyideas/core/design_system/component_themes/input_themes.dart';
import 'package:moneyideas/core/design_system/component_themes/navigation_themes.dart';
import 'package:moneyideas/core/design_system/component_themes/selection_themes.dart';
import 'package:moneyideas/core/design_system/component_themes/surface_themes.dart';
import 'package:moneyideas/core/design_system/tokens/app_color_schemes.dart';
import 'package:moneyideas/core/design_system/tokens/app_colors.dart';
import 'package:moneyideas/core/design_system/tokens/app_typography.dart';

/// Assembles tokens and component themes into a Material 3 [ThemeData].
abstract final class AppTheme {
  static ThemeData light(String languageCode) =>
      _build(kLightColorScheme, AppColors.light, languageCode);

  static ThemeData dark(String languageCode) =>
      _build(kDarkColorScheme, AppColors.dark, languageCode);

  static ThemeData _build(
    ColorScheme c,
    AppColors semantic,
    String languageCode,
  ) {
    final t = AppTypography.textTheme(
      languageCode: languageCode,
      colorScheme: c,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: c,
      textTheme: t,
      scaffoldBackgroundColor: c.surface,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      extensions: [semantic],
      // Buttons
      filledButtonTheme: ButtonThemes.filled(t),
      elevatedButtonTheme: ButtonThemes.elevated(t),
      outlinedButtonTheme: ButtonThemes.outlined(t, c),
      textButtonTheme: ButtonThemes.text(t),
      iconButtonTheme: ButtonThemes.icon(),
      floatingActionButtonTheme: ButtonThemes.fab(c),
      segmentedButtonTheme: ButtonThemes.segmented(t),
      // Inputs
      inputDecorationTheme: InputThemes.decoration(c, t),
      searchBarTheme: InputThemes.searchBar(c, t),
      textSelectionTheme: InputThemes.selection(c),
      // Surfaces
      cardTheme: SurfaceThemes.card(c),
      dialogTheme: SurfaceThemes.dialog(c, t),
      bottomSheetTheme: SurfaceThemes.bottomSheet(c),
      snackBarTheme: SurfaceThemes.snackBar(c, t),
      tooltipTheme: SurfaceThemes.tooltip(c, t),
      dividerTheme: SurfaceThemes.divider(c),
      listTileTheme: SurfaceThemes.listTile(c, t),
      progressIndicatorTheme: SurfaceThemes.progress(c),
      // Navigation
      appBarTheme: NavigationThemes.appBar(c, t),
      navigationBarTheme: NavigationThemes.navigationBar(c, t),
      navigationRailTheme: NavigationThemes.navigationRail(c, t),
      navigationDrawerTheme: NavigationThemes.drawer(c, t),
      tabBarTheme: NavigationThemes.tabBar(c, t),
      // Selection
      chipTheme: SelectionThemes.chip(c, t),
      switchTheme: SelectionThemes.switchTheme(),
      checkboxTheme: SelectionThemes.checkbox(),
      sliderTheme: SelectionThemes.slider(c),
      badgeTheme: SelectionThemes.badge(c, t),
    );
  }
}
