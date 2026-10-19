import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/features/profile_setup/domain/models/profile_setup_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupController extends Notifier<ProfileSetupData> {
  @override
  ProfileSetupData build() {
    return const ProfileSetupData();
  }

  void toggleRole(String role) {
    final updated = Set<String>.from(state.selectedRoles);
    if (updated.contains(role)) {
      if (updated.length > 1) updated.remove(role);
    } else {
      updated.add(role);
    }
    state = state.copyWith(selectedRoles: updated);
  }

  void toggleGoal(String goal) {
    final updated = Set<String>.from(state.selectedGoals);
    if (updated.contains(goal)) {
      if (updated.length > 1) updated.remove(goal);
    } else {
      updated.add(goal);
    }
    state = state.copyWith(selectedGoals: updated);
  }

  void updateLocation({String? country, String? city, String? currency}) {
    state = state.copyWith(country: country, city: city, currency: currency);
  }

  void updateBudget({
    required double amount,
    required bool hasNoCapital,
    double? ceiling,
  }) {
    state = state.copyWith(
      budgetAmount: hasNoCapital ? 0 : amount,
      hasNoCapital: hasNoCapital,
      budgetCeiling: ceiling,
    );
  }

  void updateExperience({
    required String level,
    required int hours,
    required bool activeManagement,
  }) {
    state = state.copyWith(
      experienceLevel: level,
      weeklyHours: hours,
      wantsActiveManagement: activeManagement,
    );
  }

  void updateRisk({
    required String tolerance,
    required String liquidity,
  }) {
    state = state.copyWith(
      riskTolerance: tolerance,
      liquidityNeed: liquidity,
    );
  }

  /// Persists analytical setup to Supabase user_preferences and user_roles.
  Future<void> saveProfile() async {
    if (!Env.isConfigured) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Update user preferences
      await Supabase.instance.client.from('user_preferences').upsert({
        'user_id': user.id,
        'has_no_capital': state.hasNoCapital,
        'budget_amount': state.budgetAmount,
        'budget_ceiling': state.budgetCeiling,
        'experience_level': state.experienceLevel,
        'weekly_available_hours': state.weeklyHours,
        'wants_active_management': state.wantsActiveManagement,
        'risk_tolerance': state.riskTolerance,
        'liquidity_need': state.liquidityNeed,
        'profile_completion_percentage': state.completenessPercentage,
      });

      // 2. Insert roles
      for (final role in state.selectedRoles) {
        await Supabase.instance.client.from('user_roles').upsert({
          'user_id': user.id,
          'role': role,
        });
      }

      // 3. Insert goals
      for (final goal in state.selectedGoals) {
        await Supabase.instance.client.from('user_goals').upsert({
          'user_id': user.id,
          'goal': goal,
        });
      }
    } on Exception {
      // Log or handle silently; offline fallback continues
    }
  }
}

final profileSetupProvider =
    NotifierProvider<ProfileSetupController, ProfileSetupData>(
  ProfileSetupController.new,
);
