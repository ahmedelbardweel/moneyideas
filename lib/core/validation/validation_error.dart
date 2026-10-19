/// Pure, UI-agnostic validation errors. Converted to localized text by
/// `ValidationMessages` in the presentation layer.
sealed class ValidationError {
  const ValidationError();
}

final class RequiredError extends ValidationError {
  const RequiredError();
}

final class MinLengthError extends ValidationError {
  const MinLengthError(this.min);
  final int min;
}

final class MaxLengthError extends ValidationError {
  const MaxLengthError(this.max);
  final int max;
}

final class InvalidNameError extends ValidationError {
  const InvalidNameError();
}

final class InvalidEmailError extends ValidationError {
  const InvalidEmailError();
}

/// Lists the requirements that the password does not meet yet.
final class WeakPasswordError extends ValidationError {
  const WeakPasswordError(this.missing);
  final Set<PasswordRequirement> missing;
}

enum PasswordRequirement { minLength, uppercase, lowercase, digit }

final class MismatchError extends ValidationError {
  const MismatchError();
}

final class InvalidOtpError extends ValidationError {
  const InvalidOtpError(this.length);
  final int length;
}

final class InvalidNumberError extends ValidationError {
  const InvalidNumberError();
}

final class OutOfRangeError extends ValidationError {
  const OutOfRangeError({this.min, this.max});
  final num? min;
  final num? max;
}

final class TooManyDecimalsError extends ValidationError {
  const TooManyDecimalsError(this.maxDecimals);
  final int maxDecimals;
}

final class InvalidUrlError extends ValidationError {
  const InvalidUrlError();
}

final class InsecureUrlError extends ValidationError {
  const InsecureUrlError();
}

final class InvalidPhoneError extends ValidationError {
  const InvalidPhoneError();
}

final class InvalidLicenseError extends ValidationError {
  const InvalidLicenseError();
}

/// Text contains claims that are not allowed (e.g. "guaranteed profit").
final class ForbiddenClaimError extends ValidationError {
  const ForbiddenClaimError();
}

final class MustAcceptError extends ValidationError {
  const MustAcceptError();
}

final class SelectionRequiredError extends ValidationError {
  const SelectionRequiredError({this.min = 1});
  final int min;
}

final class FileTooLargeError extends ValidationError {
  const FileTooLargeError(this.maxBytes);
  final int maxBytes;
}

final class FileTypeNotAllowedError extends ValidationError {
  const FileTypeNotAllowedError(this.allowedExtensions);
  final List<String> allowedExtensions;
}
