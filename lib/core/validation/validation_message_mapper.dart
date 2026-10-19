import 'package:moneyideas/core/l10n/generated/app_localizations.dart';
import 'package:moneyideas/core/validation/validation_error.dart';

/// Translates domain-level [ValidationError] into user-facing localized text.
abstract final class ValidationMessageMapper {
  static String map(AppLocalizations l10n, ValidationError error) {
    return switch (error) {
      RequiredError() => l10n.errorRequired,
      MinLengthError(:final min) => l10n.errorMinLength(min),
      MaxLengthError(:final max) => l10n.errorMaxLength(max),
      InvalidNameError() => l10n.errorInvalidName,
      InvalidEmailError() => l10n.errorInvalidEmail,
      WeakPasswordError() => l10n.errorWeakPassword,
      MismatchError() => l10n.errorPasswordMismatch,
      InvalidOtpError(:final length) => l10n.errorInvalidOtp(length),
      InvalidNumberError() => l10n.errorInvalidNumber,
      OutOfRangeError() => l10n.errorOutOfRange,
      TooManyDecimalsError(:final maxDecimals) =>
        l10n.errorTooManyDecimals(maxDecimals),
      InvalidUrlError() => l10n.errorInvalidUrl,
      InsecureUrlError() => l10n.errorInsecureUrl,
      InvalidPhoneError() => l10n.errorInvalidPhone,
      InvalidLicenseError() => l10n.errorInvalidLicense,
      ForbiddenClaimError() => l10n.errorForbiddenClaim,
      MustAcceptError() => l10n.errorMustAccept,
      SelectionRequiredError() => l10n.errorSelectionRequired,
      FileTooLargeError() => l10n.errorFileTooLarge,
      FileTypeNotAllowedError() => l10n.errorFileTypeNotAllowed,
    };
  }
}
