import 'package:moneyideas/core/validation/rules/text_rules.dart';
import 'package:moneyideas/core/validation/validation_error.dart';

/// Rules for authentication fields.
abstract final class AuthRules {
  static const int passwordMinLength = 8;
  static const int otpLength = 6;
  static const int emailMaxLength = 254;

  static final RegExp _emailPattern = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$",
  );

  static ValidationRule<String?> email() => composeRules([
    TextRules.required(),
    TextRules.maxLength(emailMaxLength),
    (v) => _emailPattern.hasMatch(normalizeEmail(v!))
        ? null
        : const InvalidEmailError(),
  ]);

  /// Lower-cases and trims an email before validation and submission.
  static String normalizeEmail(String value) => value.trim().toLowerCase();

  /// Returns the requirements that [value] does not satisfy.
  static Set<PasswordRequirement> missingPasswordRequirements(String value) {
    return {
      if (value.length < passwordMinLength) PasswordRequirement.minLength,
      if (!value.contains(RegExp('[A-Z]'))) PasswordRequirement.uppercase,
      if (!value.contains(RegExp('[a-z]'))) PasswordRequirement.lowercase,
      if (!value.contains(RegExp('[0-9]'))) PasswordRequirement.digit,
    };
  }

  /// Strength from 0.0 to 1.0, used by the password strength indicator.
  static double passwordStrength(String value) {
    if (value.isEmpty) return 0;
    final met = PasswordRequirement.values.length -
        missingPasswordRequirements(value).length;
    return met / PasswordRequirement.values.length;
  }

  static ValidationRule<String?> strongPassword() => (v) {
    if (v == null || v.isEmpty) return const RequiredError();
    final missing = missingPasswordRequirements(v);
    return missing.isEmpty ? null : WeakPasswordError(missing);
  };

  /// Login only checks presence; strength rules apply on registration.
  static ValidationRule<String?> loginPassword() => TextRules.required();

  static ValidationRule<String?> confirmPassword(String Function() original) =>
      (v) {
        if (v == null || v.isEmpty) return const RequiredError();
        return v == original() ? null : const MismatchError();
      };

  static ValidationRule<String?> otp({int length = otpLength}) => (v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return const RequiredError();
    final valid = value.length == length && RegExp(r'^\d+$').hasMatch(value);
    return valid ? null : InvalidOtpError(length);
  };

  static ValidationRule<bool> mustAccept() =>
      (accepted) => accepted ? null : const MustAcceptError();
}
