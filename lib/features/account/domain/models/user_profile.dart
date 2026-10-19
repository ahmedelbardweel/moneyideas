/// Complete user profile aggregating data from Supabase profiles, roles, goals, and preferences.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.city = 'Dubai',
    this.countryCode = 'AE',
    this.preferredLanguage = 'ar',
    this.preferredCurrency = 'AED',
    this.isVerified = false,
    this.roles = const ['individual'],
    this.goals = const [],
    this.budgetAmount = 0.0,
    this.hasNoCapital = false,
    this.weeklyHours = 5,
    this.experienceLevel = 'beginner',
    this.riskTolerance = 'low',
    this.skills = const [],
    this.completionPercentage = 20,
  });

  factory UserProfile.fromJson({
    required Map<String, dynamic> profileJson,
    String email = '',
    List<String> roles = const [],
    List<String> goals = const [],
    Map<String, dynamic>? preferencesJson,
  }) {
    return UserProfile(
      id: profileJson['id'] as String? ?? '',
      fullName: profileJson['full_name'] as String? ?? '',
      email: email,
      avatarUrl: profileJson['avatar_url'] as String?,
      phone: profileJson['phone'] as String?,
      city: profileJson['city'] as String? ?? 'Dubai',
      countryCode: profileJson['country_code'] as String? ?? 'AE',
      preferredLanguage: profileJson['preferred_language'] as String? ?? 'ar',
      preferredCurrency: profileJson['preferred_currency'] as String? ?? 'AED',
      isVerified: profileJson['is_verified'] as bool? ?? false,
      roles: roles.isNotEmpty ? roles : const ['individual'],
      goals: goals,
      budgetAmount:
          (preferencesJson?['budget_amount'] as num?)?.toDouble() ?? 0.0,
      hasNoCapital: preferencesJson?['has_no_capital'] as bool? ?? false,
      weeklyHours: preferencesJson?['weekly_available_hours'] as int? ?? 5,
      experienceLevel:
          preferencesJson?['experience_level'] as String? ?? 'beginner',
      riskTolerance: preferencesJson?['risk_tolerance'] as String? ?? 'low',
      skills: (preferencesJson?['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      completionPercentage:
          preferencesJson?['profile_completion_percentage'] as int? ?? 20,
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final String city;
  final String countryCode;
  final String preferredLanguage;
  final String preferredCurrency;
  final bool isVerified;
  final List<String> roles;
  final List<String> goals;
  final double budgetAmount;
  final bool hasNoCapital;
  final int weeklyHours;
  final String experienceLevel;
  final String riskTolerance;
  final List<String> skills;
  final int completionPercentage;

  bool get isAdmin => roles.contains('admin');

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? avatarUrl,
    String? phone,
    String? city,
    String? countryCode,
    String? preferredLanguage,
    String? preferredCurrency,
    bool? isVerified,
    List<String>? roles,
    List<String>? goals,
    double? budgetAmount,
    bool? hasNoCapital,
    int? weeklyHours,
    String? experienceLevel,
    String? riskTolerance,
    List<String>? skills,
    int? completionPercentage,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      isVerified: isVerified ?? this.isVerified,
      roles: roles ?? this.roles,
      goals: goals ?? this.goals,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      hasNoCapital: hasNoCapital ?? this.hasNoCapital,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      skills: skills ?? this.skills,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}
