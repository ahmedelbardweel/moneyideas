/// Compile-time environment values injected with
/// `flutter run --dart-define-from-file=env/dev.json`.
///
/// Never hard-code secrets in source. Only the public anon key belongs on
/// the client; service-role keys stay in Supabase Edge Functions.
abstract final class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dqfdvwtmkuizhrdpthuw.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxZmR2d3Rta3VpemhyZHB0aHV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIyMjY5NzcsImV4cCI6MjEwNzgwMjk3N30.ucpWLhshSCdATJq6izPPce-9w8rhLd2TJxzBYzCEPh8',
  );
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  /// Deep-link used by Supabase for email confirmation and password reset.
  static const String authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: 'io.moneyideas.app://login-callback',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isProduction => appEnv == 'prod';
}
