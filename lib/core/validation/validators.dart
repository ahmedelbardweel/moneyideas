import 'package:flutter/widgets.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/validation/rules/auth_rules.dart';
import 'package:moneyideas/core/validation/rules/contact_rules.dart';
import 'package:moneyideas/core/validation/rules/number_rules.dart';
import 'package:moneyideas/core/validation/rules/text_rules.dart';
import 'package:moneyideas/core/validation/validation_message_mapper.dart';

/// Convenient Flutter FormFieldValidators ready to attach to any TextFormField or AppTextField.
abstract final class Validators {
  /// Composes multiple rules into a single FormFieldValidator.
  static FormFieldValidator<String> compose(
    BuildContext context,
    List<ValidationRule<String?>> rules,
  ) {
    final l10n = context.l10n;
    return (value) {
      for (final rule in rules) {
        final error = rule(value);
        if (error != null) {
          return ValidationMessageMapper.map(l10n, error);
        }
      }
      return null;
    };
  }

  /// Required text field.
  static FormFieldValidator<String> required(BuildContext context) =>
      compose(context, [TextRules.required()]);

  /// Full person name (letters & spaces, 2..60).
  static FormFieldValidator<String> personName(BuildContext context) =>
      compose(context, [TextRules.personName()]);

  /// Email validation (format, length, normalization).
  static FormFieldValidator<String> email(BuildContext context) =>
      compose(context, [AuthRules.email()]);

  /// Strong registration password.
  static FormFieldValidator<String> strongPassword(BuildContext context) =>
      compose(context, [AuthRules.strongPassword()]);

  /// Login password (checks non-empty).
  static FormFieldValidator<String> loginPassword(BuildContext context) =>
      compose(context, [AuthRules.loginPassword()]);

  /// Password confirmation match.
  static FormFieldValidator<String> confirmPassword(
    BuildContext context,
    String Function() originalPassword,
  ) =>
      compose(context, [AuthRules.confirmPassword(originalPassword)]);

  /// OTP validation.
  static FormFieldValidator<String> otp(BuildContext context, {int length = 6}) =>
      compose(context, [AuthRules.otp(length: length)]);

  /// Money input validation (supports allowZero).
  static FormFieldValidator<String> money(
    BuildContext context, {
    bool allowZero = false,
  }) =>
      compose(context, [NumberRules.money(allowZero: allowZero)]);

  /// Weekly available hours validation (0..80).
  static FormFieldValidator<String> weeklyHours(BuildContext context) =>
      compose(context, [NumberRules.weeklyHours()]);

  /// Phone number (supports country code, default UAE / international).
  static FormFieldValidator<String> phone(
    BuildContext context, {
    String? countryCode,
  }) =>
      compose(context, [ContactRules.phone(countryCode: countryCode)]);

  /// Trade license format.
  static FormFieldValidator<String> tradeLicense(BuildContext context) =>
      compose(context, [ContactRules.tradeLicense()]);

  /// HTTPS URL validation.
  static FormFieldValidator<String> httpsUrl(BuildContext context) =>
      compose(context, [ContactRules.httpsUrl()]);

  /// Prohibits claims of guaranteed profit or risk-free.
  static FormFieldValidator<String> noForbiddenClaims(BuildContext context) =>
      compose(context, [TextRules.noForbiddenClaims()]);
}
