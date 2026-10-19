import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/tokens/app_dimensions.dart';
import 'package:moneyideas/core/design_system/tokens/app_radius.dart';

/// Containers: cards, dialogs, sheets, snackbars, tooltips, dividers.
/// M3 favors tonal surfaces over shadows, so elevation is kept low.
abstract final class SurfaceThemes {
  static CardThemeData card(ColorScheme c) => CardThemeData(
    elevation: AppElevation.level0,
    color: c.surfaceContainerLow,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
  );

  static DialogThemeData dialog(ColorScheme c, TextTheme t) => DialogThemeData(
    backgroundColor: c.surfaceContainerHigh,
    surfaceTintColor: Colors.transparent,
    elevation: AppElevation.level3,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.extraLargeAll),
    titleTextStyle: t.headlineSmall,
    contentTextStyle: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
  );

  static BottomSheetThemeData bottomSheet(ColorScheme c) =>
      BottomSheetThemeData(
        backgroundColor: c.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surfaceContainerLow,
        elevation: AppElevation.level1,
        modalElevation: AppElevation.level1,
        showDragHandle: true,
        dragHandleColor: c.onSurfaceVariant.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
        clipBehavior: Clip.antiAlias,
      );

  static SnackBarThemeData snackBar(ColorScheme c, TextTheme t) =>
      SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.inverseSurface,
        contentTextStyle: t.bodyMedium?.copyWith(color: c.onInverseSurface),
        actionTextColor: c.inversePrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.extraSmallAll,
        ),
      );

  static TooltipThemeData tooltip(ColorScheme c, TextTheme t) =>
      TooltipThemeData(
        decoration: BoxDecoration(
          color: c.inverseSurface,
          borderRadius: AppRadius.extraSmallAll,
        ),
        textStyle: t.bodySmall?.copyWith(color: c.onInverseSurface),
      );

  static DividerThemeData divider(ColorScheme c) => DividerThemeData(
    color: c.outlineVariant,
    thickness: AppSizes.strokeThin,
    space: AppSizes.strokeThin,
  );

  static ListTileThemeData listTile(ColorScheme c, TextTheme t) =>
      ListTileThemeData(
        iconColor: c.onSurfaceVariant,
        titleTextStyle: t.bodyLarge?.copyWith(color: c.onSurface),
        subtitleTextStyle: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
        minVerticalPadding: 8,
      );

  static ProgressIndicatorThemeData progress(ColorScheme c) =>
      ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.secondaryContainer,
        circularTrackColor: c.secondaryContainer,
        linearMinHeight: AppSizes.progressStroke,
        borderRadius: AppRadius.fullAll,
      );
}
