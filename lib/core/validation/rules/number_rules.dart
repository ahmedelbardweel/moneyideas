import 'package:moneyideas/core/validation/rules/text_rules.dart';
import 'package:moneyideas/core/validation/validation_error.dart';

/// Rules for numeric inputs such as budgets, prices and weekly hours.
abstract final class NumberRules {
  static const num maxMoneyAmount = 1000000000;
  static const int maxWeeklyHours = 80;

  /// Parses user input that may contain Arabic-Indic digits or separators.
  static num? parse(String? raw) {
    if (raw == null) return null;
    final normalized = normalizeDigits(raw).replaceAll(',', '').trim();
    if (normalized.isEmpty) return null;
    return num.tryParse(normalized);
  }

  /// Converts Arabic-Indic (٠-٩) and Persian (۰-۹) digits to Latin digits
  /// and the Arabic decimal separator (٫) to a dot.
  static String normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.writeCharCode(rune - 0x0660 + 0x30);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.writeCharCode(rune - 0x06F0 + 0x30);
      } else if (rune == 0x066B) {
        buffer.write('.');
      } else if (rune == 0x066C) {
        buffer.write(',');
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static ValidationRule<String?> number() =>
      (v) => parse(v) == null ? const InvalidNumberError() : null;

  static ValidationRule<String?> range({num? min, num? max}) => (v) {
    final value = parse(v);
    if (value == null) return const InvalidNumberError();
    final belowMin = min != null && value < min;
    final aboveMax = max != null && value > max;
    return (belowMin || aboveMax) ? OutOfRangeError(min: min, max: max) : null;
  };

  static ValidationRule<String?> maxDecimals(int decimals) => (v) {
    final normalized = normalizeDigits(v ?? '').replaceAll(',', '');
    final parts = normalized.split('.');
    if (parts.length < 2) return null;
    return parts.last.length > decimals ? TooManyDecimalsError(decimals) : null;
  };

  /// Money amount. [allowZero] supports "I have no capital right now".
  static ValidationRule<String?> money({bool allowZero = false}) =>
      composeRules([
        TextRules.required(),
        number(),
        range(min: allowZero ? 0 : 0.01, max: maxMoneyAmount),
        maxDecimals(2),
      ]);

  static ValidationRule<String?> weeklyHours() => composeRules([
    TextRules.required(),
    number(),
    range(min: 0, max: maxWeeklyHours),
  ]);
}
