/// Domain-level error categories. The UI maps each type to a localized
/// message via `FailureMessage` so no raw backend text reaches users.
sealed class Failure {
  const Failure({this.debugMessage});

  factory Failure.network([String? debugMessage]) =>
      NetworkFailure(debugMessage: debugMessage);
  factory Failure.server([String? debugMessage, String? code]) =>
      ServerFailure(debugMessage: debugMessage, code: code);
  factory Failure.unauthorized([String? debugMessage]) =>
      PermissionFailure(debugMessage: debugMessage);
  factory Failure.notFound([String? debugMessage]) =>
      NotFoundFailure(debugMessage: debugMessage);

  /// Technical details for logs only. Never shown to users.
  final String? debugMessage;

  String get message => debugMessage ?? 'حدث خطأ غير متوقع';

  @override
  String toString() => 'Failure(${debugMessage ?? ''})';
}

/// No internet connection or the server could not be reached.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.debugMessage});
}

/// Unexpected server-side error.
final class ServerFailure extends Failure {
  const ServerFailure({super.debugMessage, this.code});
  final String? code;
}

/// Authentication failures (wrong credentials, expired session, etc).
final class AuthFailure extends Failure {
  const AuthFailure(this.reason, {super.debugMessage});
  final AuthFailureReason reason;
}

enum AuthFailureReason {
  invalidCredentials,
  emailNotConfirmed,
  emailAlreadyUsed,
  weakPassword,
  invalidOtp,
  otpExpired,
  sessionExpired,
  tooManyRequests,
  unknown,
}

/// The current user is not allowed to perform this action (RLS / role).
final class PermissionFailure extends Failure {
  const PermissionFailure({super.debugMessage});
}

/// Requested entity does not exist or is no longer available.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.debugMessage});
}

/// Input rejected by business rules or database constraints.
final class ValidationFailure extends Failure {
  const ValidationFailure({this.fieldErrors = const {}, super.debugMessage});

  /// Field name -> localization key of the error.
  final Map<String, String> fieldErrors;
}

/// Uploaded file has a forbidden type or exceeds the allowed size.
final class FileRejectedFailure extends Failure {
  const FileRejectedFailure({super.debugMessage});
}

/// Feature is disabled by a server-side feature flag.
final class FeatureDisabledFailure extends Failure {
  const FeatureDisabledFailure(this.flag, {super.debugMessage});
  final String flag;
}

/// Local cache read/write error.
final class CacheFailure extends Failure {
  const CacheFailure({super.debugMessage});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({super.debugMessage});
}
