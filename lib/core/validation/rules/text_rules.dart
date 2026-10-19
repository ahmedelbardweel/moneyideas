import 'package:moneyideas/core/validation/validation_error.dart';

/// A single validation rule. Returns `null` when the value is valid.
typedef ValidationRule<T> = ValidationError? Function(T value);

/// Runs [rules] in order and returns the first error, or `null`.
ValidationRule<T> composeRules<T>(List<ValidationRule<T>> rules) {
  return (value) {
    for (final rule in rules) {
      final error = rule(value);
      if (error != null) return error;
    }
    return null;
  };
}

/// Makes a rule pass for empty input. Useful for optional fields that must
/// still be well-formed when provided.
ValidationRule<String?> optional(ValidationRule<String?> rule) {
  return (value) {
    if (value == null || value.trim().isEmpty) return null;
    return rule(value);
  };
}

/// Generic rules shared across all text fields.
abstract final class TextRules {
  static ValidationRule<String?> required() =>
      (v) => (v == null || v.trim().isEmpty) ? const RequiredError() : null;

  static ValidationRule<String?> minLength(int min) =>
      (v) => (v ?? '').trim().length < min ? MinLengthError(min) : null;

  static ValidationRule<String?> maxLength(int max) =>
      (v) => (v ?? '').trim().length > max ? MaxLengthError(max) : null;

  /// Arabic or Latin letters, spaces, apostrophes and hyphens.
  static final RegExp _namePattern = RegExp(
    r"^[\u0600-\u06FFa-zA-Z\s'\-]+$",
  );

  static ValidationRule<String?> personName() => composeRules([
    required(),
    minLength(2),
    maxLength(60),
    (v) => _namePattern.hasMatch(v!.trim()) ? null : const InvalidNameError(),
  ]);

  /// Phrases that imply guaranteed returns. Content containing them is
  /// rejected client-side and flagged again during admin review.
  static const List<String> forbiddenClaims = [
    'ربح مضمون',
    'أرباح مضمونة',
    'عائد مضمون',
    'بدون مخاطر',
    'guaranteed profit',
    'guaranteed return',
    'risk-free',
    'risk free',
  ];

  static ValidationRule<String?> noForbiddenClaims() => (v) {
    final text = (v ?? '').toLowerCase();
    final hit = forbiddenClaims.any(text.contains);
    return hit ? const ForbiddenClaimError() : null;
  };
}
