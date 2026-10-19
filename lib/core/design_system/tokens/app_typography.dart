import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 type scale with Google fonts:
/// - Latin: **Google Sans**
/// - Arabic: **Noto Sans Arabic** (Google Noto family)
///
/// The active locale decides which font is primary; the other is used as
/// fallback so mixed Arabic/English text always renders with Google fonts.
abstract final class AppTypography {
  /// M3 type scale: size / line-height / weight / letter-spacing.
  static const TextTheme _scale = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      height: 64 / 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      height: 52 / 45,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      height: 44 / 36,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      height: 28 / 22,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  static String get _latinFamily => GoogleFonts.googleSans().fontFamily!;
  static String get _arabicFamily => GoogleFonts.notoSansArabic().fontFamily!;

  /// Builds the text theme for [languageCode] with the given [colorScheme].
  static TextTheme textTheme({
    required String languageCode,
    required ColorScheme colorScheme,
  }) {
    final isArabic = languageCode == 'ar';
    final themed = isArabic
        ? GoogleFonts.notoSansArabicTextTheme(_arabicScale)
        : GoogleFonts.googleSansTextTheme(_scale);
    return themed.apply(
      fontFamilyFallback: [
        if (isArabic) _latinFamily else _arabicFamily,
      ],
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }

  /// Letter spacing breaks Arabic glyph joining, so it is reset to zero.
  static TextTheme get _arabicScale {
    TextStyle? zero(TextStyle? s) => s?.copyWith(letterSpacing: 0);
    return TextTheme(
      displayLarge: zero(_scale.displayLarge),
      displayMedium: zero(_scale.displayMedium),
      displaySmall: zero(_scale.displaySmall),
      headlineLarge: zero(_scale.headlineLarge),
      headlineMedium: zero(_scale.headlineMedium),
      headlineSmall: zero(_scale.headlineSmall),
      titleLarge: zero(_scale.titleLarge),
      titleMedium: zero(_scale.titleMedium),
      titleSmall: zero(_scale.titleSmall),
      bodyLarge: zero(_scale.bodyLarge),
      bodyMedium: zero(_scale.bodyMedium),
      bodySmall: zero(_scale.bodySmall),
      labelLarge: zero(_scale.labelLarge),
      labelMedium: zero(_scale.labelMedium),
      labelSmall: zero(_scale.labelSmall),
    );
  }
}
