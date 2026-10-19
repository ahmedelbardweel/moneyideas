/// Data state for the multi-step user onboarding & analytical profile setup (Screens 09-15).
class ProfileSetupData {
  const ProfileSetupData({
    this.selectedRoles = const {'individual'},
    this.selectedGoals = const {'discover_idea'},
    this.country = 'AE',
    this.city = 'Dubai',
    this.currency = 'AED',
    this.budgetAmount = 1500,
    this.hasNoCapital = false,
    this.budgetCeiling,
    this.experienceLevel = 'beginner',
    this.weeklyHours = 5,
    this.wantsActiveManagement = true,
    this.riskTolerance = 'low',
    this.liquidityNeed = 'medium_term',
  });

  final Set<String> selectedRoles;
  final Set<String> selectedGoals;
  final String country;
  final String city;
  final String currency;
  final double budgetAmount;
  final bool hasNoCapital;
  final double? budgetCeiling;
  final String experienceLevel;
  final int weeklyHours;
  final bool wantsActiveManagement;
  final String riskTolerance;
  final String liquidityNeed;

  /// Calculates the analytical profile completeness percentage (0..100%).
  int get completenessPercentage {
    var score = 0;
    if (selectedRoles.isNotEmpty) score += 15;
    if (selectedGoals.isNotEmpty) score += 15;
    if (city.isNotEmpty) score += 15;
    if (hasNoCapital || budgetAmount > 0) score += 20;
    if (weeklyHours > 0) score += 15;
    if (riskTolerance.isNotEmpty) score += 20;
    return score.clamp(0, 100);
  }

  ProfileSetupData copyWith({
    Set<String>? selectedRoles,
    Set<String>? selectedGoals,
    String? country,
    String? city,
    String? currency,
    double? budgetAmount,
    bool? hasNoCapital,
    double? budgetCeiling,
    String? experienceLevel,
    int? weeklyHours,
    bool? wantsActiveManagement,
    String? riskTolerance,
    String? liquidityNeed,
  }) {
    return ProfileSetupData(
      selectedRoles: selectedRoles ?? this.selectedRoles,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      country: country ?? this.country,
      city: city ?? this.city,
      currency: currency ?? this.currency,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      hasNoCapital: hasNoCapital ?? this.hasNoCapital,
      budgetCeiling: budgetCeiling ?? this.budgetCeiling,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      wantsActiveManagement:
          wantsActiveManagement ?? this.wantsActiveManagement,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      liquidityNeed: liquidityNeed ?? this.liquidityNeed,
    );
  }
}
