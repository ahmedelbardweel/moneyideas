import 'package:flutter/material.dart';

/// A semantic color group following the M3 "custom color" pattern.
@immutable
class SemanticColor {
  const SemanticColor({
    required this.color,
    required this.onColor,
    required this.container,
    required this.onContainer,
  });

  factory SemanticColor.lerp(SemanticColor a, SemanticColor b, double t) {
    return SemanticColor(
      color: Color.lerp(a.color, b.color, t)!,
      onColor: Color.lerp(a.onColor, b.onColor, t)!,
      container: Color.lerp(a.container, b.container, t)!,
      onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
    );
  }

  final Color color;
  final Color onColor;
  final Color container;
  final Color onContainer;
}

/// App-specific colors that Material's [ColorScheme] does not cover:
/// success, warning, info (data quality) and sponsored (ads disclosure).
/// Access with `context.appColors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.sponsored,
  });

  /// Verified data, completed tasks, accepted requests.
  final SemanticColor success;

  /// Estimated data, needs update, pending review.
  final SemanticColor warning;

  /// Informational hints and educational content.
  final SemanticColor info;

  /// Paid placements. Always paired with an explicit "Ad" label.
  final SemanticColor sponsored;

  static const AppColors light = AppColors(
    success: SemanticColor(
      color: Color(0xFF3C6939),
      onColor: Color(0xFFFFFFFF),
      container: Color(0xFFBCF0B4),
      onContainer: Color(0xFF245024),
    ),
    warning: SemanticColor(
      color: Color(0xFF855317),
      onColor: Color(0xFFFFFFFF),
      container: Color(0xFFFFDCBD),
      onContainer: Color(0xFF693C00),
    ),
    info: SemanticColor(
      color: Color(0xFF495D92),
      onColor: Color(0xFFFFFFFF),
      container: Color(0xFFDAE2FF),
      onContainer: Color(0xFF304578),
    ),
    sponsored: SemanticColor(
      color: Color(0xFF815512),
      onColor: Color(0xFFFFFFFF),
      container: Color(0xFFFFDDB7),
      onContainer: Color(0xFF653E00),
    ),
  );

  static const AppColors dark = AppColors(
    success: SemanticColor(
      color: Color(0xFFA1D39A),
      onColor: Color(0xFF0A390F),
      container: Color(0xFF245024),
      onContainer: Color(0xFFBCF0B4),
    ),
    warning: SemanticColor(
      color: Color(0xFFFCB974),
      onColor: Color(0xFF492900),
      container: Color(0xFF693C00),
      onContainer: Color(0xFFFFDCBD),
    ),
    info: SemanticColor(
      color: Color(0xFFB2C5FF),
      onColor: Color(0xFF172E60),
      container: Color(0xFF304578),
      onContainer: Color(0xFFDAE2FF),
    ),
    sponsored: SemanticColor(
      color: Color(0xFFF7BB70),
      onColor: Color(0xFF462A00),
      container: Color(0xFF653E00),
      onContainer: Color(0xFFFFDDB7),
    ),
  );

  @override
  AppColors copyWith({
    SemanticColor? success,
    SemanticColor? warning,
    SemanticColor? info,
    SemanticColor? sponsored,
  }) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      sponsored: sponsored ?? this.sponsored,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: SemanticColor.lerp(success, other.success, t),
      warning: SemanticColor.lerp(warning, other.warning, t),
      info: SemanticColor.lerp(info, other.info, t),
      sponsored: SemanticColor.lerp(sponsored, other.sponsored, t),
    );
  }
}
