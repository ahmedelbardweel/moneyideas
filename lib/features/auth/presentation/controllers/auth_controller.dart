import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';
import 'package:moneyideas/features/profile_setup/presentation/controllers/profile_setup_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// State of the authentication process.
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
    this.pendingEmailVerification,
  });

  final bool isLoading;
  final Failure? error;
  final bool isLoggedIn;
  final String? pendingEmailVerification;

  AuthState copyWith({
    bool? isLoading,
    Failure? error,
    bool? isLoggedIn,
    String? pendingEmailVerification,
    bool clearPendingVerification = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      pendingEmailVerification: clearPendingVerification
          ? null
          : (pendingEmailVerification ?? this.pendingEmailVerification),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    try {
      final hasUser = Env.isConfigured &&
          Supabase.instance.client.auth.currentSession != null;
      return AuthState(isLoggedIn: hasUser);
    } on Object catch (_) {
      return const AuthState();
    }
  }

  /// Registers a new user with email and password.
  Future<Result<void>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);

    if (!Env.isConfigured) {
      const failure = ServerFailure(
        debugMessage: 'Supabase غير متصل. يرجى توفير بيانات الربط في env/dev.json.',
      );
      state = state.copyWith(isLoading: false, error: failure);
      return const Result.failure(failure);
    }

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final isAutoLoggedIn = res.session != null;
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: isAutoLoggedIn,
        pendingEmailVerification:
            isAutoLoggedIn ? null : (res.user?.email ?? email),
      );
      ref.invalidate(userProfileProvider);
      ref.invalidate(profileSetupProvider);
      return const Result.success(null);
    } on AuthException catch (e) {
      final failure = AuthFailure(
        AuthFailureReason.unknown,
        debugMessage: e.message,
      );
      state = state.copyWith(isLoading: false, error: failure);
      return Result.failure(failure);
    } on Exception catch (e) {
      final failure = ServerFailure(debugMessage: e.toString());
      state = state.copyWith(isLoading: false, error: failure);
      return Result.failure(failure);
    }
  }

  /// Verifies the 6-digit email OTP.
  Future<Result<void>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true);

    if (!Env.isConfigured) {
      const failure = ServerFailure(
        debugMessage: 'Supabase غير متصل.',
      );
      state = state.copyWith(isLoading: false, error: failure);
      return const Result.failure(failure);
    }

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
      );

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        clearPendingVerification: true,
      );
      ref.invalidate(userProfileProvider);
      ref.invalidate(profileSetupProvider);
      return const Result.success(null);
    } on AuthException catch (e) {
      final failure = AuthFailure(
        AuthFailureReason.invalidOtp,
        debugMessage: e.message,
      );
      state = state.copyWith(isLoading: false, error: failure);
      return Result.failure(failure);
    } on Exception catch (e) {
      final failure = ServerFailure(debugMessage: e.toString());
      state = state.copyWith(isLoading: false, error: failure);
      return Result.failure(failure);
    }
  }

  /// Resends the OTP token to the user's email.
  Future<Result<void>> resendOtp({required String email}) async {
    if (!Env.isConfigured) {
      return const Result.failure(
        ServerFailure(debugMessage: 'Supabase غير متصل.'),
      );
    }

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      return const Result.success(null);
    } on AuthException catch (e) {
      final failure = AuthFailure(
        AuthFailureReason.unknown,
        debugMessage: e.message,
      );
      return Result.failure(failure);
    } on Exception catch (e) {
      final failure = ServerFailure(debugMessage: e.toString());
      return Result.failure(failure);
    }
  }

  /// Logs in an existing user.
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);

    if (!Env.isConfigured) {
      const failure = ServerFailure(
        debugMessage: 'Supabase غير متصل.',
      );
      state = state.copyWith(isLoading: false, error: failure);
      return const Result.failure(failure);
    }

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(isLoading: false, isLoggedIn: true);
      ref.invalidate(userProfileProvider);
      ref.invalidate(profileSetupProvider);
      return const Result.success(null);
    } on AuthException catch (e) {
      final failure = AuthFailure(
        AuthFailureReason.invalidCredentials,
        debugMessage: e.message,
      );
      state = state.copyWith(isLoading: false, error: failure);
      return Result.failure(failure);
    } on Exception catch (e) {
      final failure = ServerFailure(debugMessage: e.toString());
      state = state.copyWith(isLoading: false, error: failure);
      return Result.failure(failure);
    }
  }

  /// Requests a password reset link.
  Future<Result<void>> resetPassword(String email) async {
    state = state.copyWith(isLoading: true);

    if (!Env.isConfigured) {
      const failure = ServerFailure(
        debugMessage: 'Supabase غير متصل.',
      );
      state = state.copyWith(isLoading: false, error: failure);
      return const Result.failure(failure);
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      state = state.copyWith(isLoading: false);
      return const Result.success(null);
    } on AuthException catch (e) {
      final failure = AuthFailure(
        AuthFailureReason.unknown,
        debugMessage: e.message,
      );
      state = state.copyWith(isLoading: false, error: failure);
      return Result.failure(failure);
    } on Exception catch (e) {
      final failure = ServerFailure(debugMessage: e.toString());
      state = state.copyWith(isLoading: false, error: failure);
      return Result.failure(failure);
    }
  }

  /// Signs out current session and thoroughly cleans cached providers.
  Future<void> logout() async {
    if (Env.isConfigured) {
      try {
        await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
      } on Exception {
        try {
          await Supabase.instance.client.auth.signOut();
        } on Exception {
          // Suppress on logout
        }
      }
    }
    state = const AuthState();
    ref.invalidate(userProfileProvider);
    ref.invalidate(profileSetupProvider);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
