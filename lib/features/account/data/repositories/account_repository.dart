import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/account/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountRepository {
  const AccountRepository();

  SupabaseClient get _client => Supabase.instance.client;

  /// Fetches the authenticated user profile and all relations from Supabase.
  Future<Result<UserProfile>> getUserProfile() async {
    if (!Env.isConfigured) {
      return const Result.failure(
        ServerFailure(debugMessage: 'Supabase غير متصل.'),
      );
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة.'),
      );
    }

    try {
      // 1. Profile
      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // 2. Roles
      final rolesData = await _client
          .from('user_roles')
          .select('role')
          .eq('user_id', user.id);
      final roles = (rolesData as List<dynamic>)
          .map((r) => (r as Map<String, dynamic>)['role'] as String)
          .toList();

      // 3. Goals
      final goalsData = await _client
          .from('user_goals')
          .select('goal')
          .eq('user_id', user.id);
      final goals = (goalsData as List<dynamic>)
          .map((g) => (g as Map<String, dynamic>)['goal'] as String)
          .toList();

      // 4. Preferences
      final prefData = await _client
          .from('user_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      final profile = UserProfile.fromJson(
        profileJson: profileData ?? {'id': user.id, 'full_name': user.userMetadata?['full_name'] ?? 'مستخدم أفكار المال'},
        email: user.email ?? '',
        roles: roles,
        goals: goals,
        preferencesJson: prefData,
      );

      return Result.success(profile);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } on Exception catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Updates personal info (name, city, phone).
  Future<Result<void>> updateProfile({
    required String fullName,
    required String city,
    String? phone,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(ServerFailure(debugMessage: 'غير مسجل الدخول'));
    }

    try {
      await _client.from('profiles').update({
        'full_name': fullName,
        'city': city,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } on Exception catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Updates investment preferences in Supabase.
  Future<Result<void>> updatePreferences({
    required double budget,
    required bool hasNoCapital,
    required int weeklyHours,
    required String experience,
    required String risk,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(ServerFailure(debugMessage: 'غير مسجل الدخول'));
    }

    try {
      await _client.from('user_preferences').upsert({
        'user_id': user.id,
        'budget_amount': budget,
        'has_no_capital': hasNoCapital,
        'weekly_available_hours': weeklyHours,
        'experience_level': experience,
        'risk_tolerance': risk,
        'profile_completion_percentage': 85,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } on Exception catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Updates user active roles.
  Future<Result<void>> updateRoles(List<String> newRoles) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(ServerFailure(debugMessage: 'غير مسجل الدخول'));
    }

    try {
      // Security: Filter out 'admin' - clients can never self-assign admin
      final safeRoles = newRoles.where((r) => r != 'admin').toList();

      await _client
          .from('user_roles')
          .delete()
          .eq('user_id', user.id)
          .neq('role', 'admin');

      if (safeRoles.isNotEmpty) {
        final rows =
            safeRoles.map((r) => {'user_id': user.id, 'role': r}).toList();
        await _client.from('user_roles').insert(rows);
      }
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }
}
