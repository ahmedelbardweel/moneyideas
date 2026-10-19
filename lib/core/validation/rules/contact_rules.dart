import 'package:moneyideas/core/validation/rules/number_rules.dart';
import 'package:moneyideas/core/validation/rules/text_rules.dart';
import 'package:moneyideas/core/validation/validation_error.dart';

/// Rules for URLs, phone numbers and trade license numbers.
abstract final class ContactRules {
  static ValidationRule<String?> httpsUrl() => (v) {
    final uri = Uri.tryParse((v ?? '').trim());
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) {
      return const InvalidUrlError();
    }
    return uri.scheme == 'https' ? null : const InsecureUrlError();
  };

  /// International E.164-like phone numbers: optional +, 8 to 15 digits.
  static final RegExp _phonePattern = RegExp(r'^\+?[1-9]\d{7,14}$');

  /// UAE mobile numbers: +9715XXXXXXXX or 05XXXXXXXX.
  static final RegExp _uaeMobilePattern = RegExp(r'^(?:\+9715|05)\d{8}$');

  static ValidationRule<String?> phone({String? countryCode}) => (v) {
    final cleaned = NumberRules.normalizeDigits(
      v ?? '',
    ).replaceAll(RegExp(r'[\s\-()]'), '');
    final pattern = countryCode == 'AE' ? _uaeMobilePattern : _phonePattern;
    return pattern.hasMatch(cleaned) ? null : const InvalidPhoneError();
  };

  /// Trade license numbers: 4–30 alphanumeric characters, dashes or slashes.
  static final RegExp _licensePattern = RegExp(r'^[A-Za-z0-9\-/]{4,30}$');

  static ValidationRule<String?> tradeLicense() => composeRules([
    TextRules.required(),
    (v) => _licensePattern.hasMatch(NumberRules.normalizeDigits(v!.trim()))
        ? null
        : const InvalidLicenseError(),
  ]);
}
