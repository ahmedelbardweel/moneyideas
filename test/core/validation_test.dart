import 'package:flutter_test/flutter_test.dart';
import 'package:moneyideas/core/validation/rules/auth_rules.dart';
import 'package:moneyideas/core/validation/rules/contact_rules.dart';
import 'package:moneyideas/core/validation/rules/number_rules.dart';
import 'package:moneyideas/core/validation/rules/text_rules.dart';
import 'package:moneyideas/core/validation/validation_error.dart';

void main() {
  group('TextRules & Names', () {
    test('required rejects null and empty or whitespace', () {
      final rule = TextRules.required();
      expect(rule(null), isA<RequiredError>());
      expect(rule(''), isA<RequiredError>());
      expect(rule('   '), isA<RequiredError>());
      expect(rule('valid'), isNull);
    });

    test('personName accepts Arabic and English characters with spaces', () {
      final rule = TextRules.personName();
      expect(rule('أحمد محمد'), isNull);
      expect(rule('John Doe'), isNull);
      expect(rule("O'Connor"), isNull);
      expect(rule('A'), isA<MinLengthError>());
      expect(rule('User123'), isA<InvalidNameError>());
      expect(rule('Test@User'), isA<InvalidNameError>());
    });

    test('noForbiddenClaims rejects deceptive phrases', () {
      final rule = TextRules.noForbiddenClaims();
      expect(rule('مشروع ممتاز مع ربح مضمون شهرياً'), isA<ForbiddenClaimError>());
      expect(rule('Totally risk-free investment opportunity'), isA<ForbiddenClaimError>());
      expect(rule('مشروع تجارة إلكترونية بتكاليف تشغيلية منخفضة'), isNull);
    });
  });

  group('AuthRules', () {
    test('email validates format and trims/normalizes', () {
      final rule = AuthRules.email();
      expect(rule('test@example.com'), isNull);
      expect(rule('  ahmed.ali@domain.ae  '), isNull);
      expect(rule('invalid-email'), isA<InvalidEmailError>());
      expect(rule('user@'), isA<InvalidEmailError>());
      expect(rule('@domain.com'), isA<InvalidEmailError>());
    });

    test('strongPassword enforces length, upper, lower, and digit', () {
      final rule = AuthRules.strongPassword();
      expect(rule('Secret12'), isNull); // 8 chars, Upper, Lower, Digit
      final weak = rule('secret');
      expect(weak, isA<WeakPasswordError>());
      if (weak is WeakPasswordError) {
        expect(weak.missing.contains(PasswordRequirement.minLength), isTrue);
        expect(weak.missing.contains(PasswordRequirement.uppercase), isTrue);
        expect(weak.missing.contains(PasswordRequirement.digit), isTrue);
      }
    });

    test('confirmPassword detects mismatch', () {
      final rule = AuthRules.confirmPassword(() => 'MyPassword1');
      expect(rule('MyPassword1'), isNull);
      expect(rule('DifferentPassword1'), isA<MismatchError>());
    });

    test('otp requires exact digits count', () {
      final rule = AuthRules.otp();
      expect(rule('123456'), isNull);
      expect(rule('12345'), isA<InvalidOtpError>());
      expect(rule('12345a'), isA<InvalidOtpError>());
    });
  });

  group('NumberRules', () {
    test('normalizeDigits converts Arabic-Indic and Persian digits', () {
      expect(NumberRules.normalizeDigits('١٥٠٠'), '1500');
      expect(NumberRules.normalizeDigits('۱۲۳۴٫۵'), '1234.5');
    });

    test('money validation supports Arabic digits, commas and allowZero', () {
      final ruleNoZero = NumberRules.money();
      expect(ruleNoZero('1500'), isNull);
      expect(ruleNoZero('١٥٠٠'), isNull);
      expect(ruleNoZero('1,500.50'), isNull);
      expect(ruleNoZero('0'), isA<OutOfRangeError>());

      final ruleWithZero = NumberRules.money(allowZero: true);
      expect(ruleWithZero('0'), isNull);
      expect(ruleWithZero('٠'), isNull);
      expect(ruleWithZero('10.999'), isA<TooManyDecimalsError>());
    });

    test('weeklyHours validates 0..80', () {
      final rule = NumberRules.weeklyHours();
      expect(rule('5'), isNull);
      expect(rule('0'), isNull);
      expect(rule('80'), isNull);
      expect(rule('81'), isA<OutOfRangeError>());
    });
  });

  group('ContactRules', () {
    test('httpsUrl requires valid authority and https scheme', () {
      final rule = ContactRules.httpsUrl();
      expect(rule('https://example.com/details'), isNull);
      expect(rule('http://example.com'), isA<InsecureUrlError>());
      expect(rule('not-a-url'), isA<InvalidUrlError>());
    });

    test('phone validates UAE and international patterns', () {
      final uaeRule = ContactRules.phone(countryCode: 'AE');
      expect(uaeRule('0501234567'), isNull);
      expect(uaeRule('+971501234567'), isNull);
      expect(uaeRule('041234567'), isA<InvalidPhoneError>()); // landline not mobile pattern

      final intlRule = ContactRules.phone();
      expect(intlRule('+966501234567'), isNull);
      expect(intlRule('123'), isA<InvalidPhoneError>());
    });

    test('tradeLicense validates formatted strings', () {
      final rule = ContactRules.tradeLicense();
      expect(rule('CN-1234567'), isNull);
      expect(rule('DED-9876/2026'), isNull);
      expect(rule('12'), isA<InvalidLicenseError>()); // too short
    });
  });
}
