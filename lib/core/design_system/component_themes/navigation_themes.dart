import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/tokens/app_dimensions.dart';
import 'package:moneyideas/core/design_system/tokens/app_radius.dart';

/// App bar, navigation bar, navigation rail (admin web) and tabs.
abstract final class NavigationThemes {
  static AppBarTheme appBar(ColorScheme c, TextTheme t) => AppBarTheme(
    backgroundColor: c.surface,
    foregroundColor: c.onSurface,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: AppElevation.level0,
    elevation: AppElevation.level0,
    centerTitle: false,
    titleTextStyle: t.titleLarge?.copyWith(color: c.onSurface),
  );

  static NavigationBarThemeData navigationBar(ColorScheme c, TextTheme t) =>
      NavigationBarThemeData(
        height: AppSizes.navigationBarHeight,
        backgroundColor: c.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        elevation: AppElevation.level0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => t.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? c.onSurface
                : c.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppSizes.iconMedium,
            fill: states.contains(WidgetState.selected) ? 1 : 0,
            color: states.contains(WidgetState.selected)
                ? c.onSecondaryContainer
                : c.onSurfaceVariant,
          ),
        ),
      );

  static NavigationRailThemeData navigationRail(ColorScheme c, TextTheme t) =>
      NavigationRailThemeData(
        backgroundColor: c.surfaceContainer,
        indicatorColor: c.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        selectedLabelTextStyle: t.labelMedium?.copyWith(color: c.onSurface),
        unselectedLabelTextStyle: t.labelMedium?.copyWith(
          color: c.onSurfaceVariant,
        ),
      );

  static NavigationDrawerThemeData drawer(ColorScheme c, TextTheme t) =>
      NavigationDrawerThemeData(
        backgroundColor: c.surfaceContainerLow,
        indicatorColor: c.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStatePropertyAll(t.labelLarge),
      );

  static TabBarThemeData tabBar(ColorScheme c, TextTheme t) => TabBarThemeData(
    labelColor: c.primary,
    unselectedLabelColor: c.onSurfaceVariant,
    labelStyle: t.titleSmall,
    unselectedLabelStyle: t.titleSmall,
    indicatorColor: c.primary,
    dividerColor: c.outlineVariant,
    indicator: UnderlineTabIndicator(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.extraSmall),
      ),
      borderSide: BorderSide(color: c.primary, width: 3),
    ),
  );
}
