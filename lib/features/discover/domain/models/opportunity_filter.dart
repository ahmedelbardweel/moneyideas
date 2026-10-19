/// Search & filter criteria for opportunities marketplace.
class OpportunityFilter {
  const OpportunityFilter({
    this.searchQuery,
    this.categoryId,
    this.minCapital,
    this.maxCapital,
    this.riskLevel,
    this.liquidityHorizon,
    this.managementType,
    this.experienceLevel,
    this.city,
    this.isOnlyVerified = false,
  });

  final String? searchQuery;
  final String? categoryId;
  final double? minCapital;
  final double? maxCapital;
  final String? riskLevel;
  final String? liquidityHorizon;
  final String? managementType;
  final String? experienceLevel;
  final String? city;
  final bool isOnlyVerified;

  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      categoryId != null ||
      minCapital != null ||
      maxCapital != null ||
      riskLevel != null ||
      liquidityHorizon != null ||
      managementType != null ||
      experienceLevel != null ||
      city != null ||
      isOnlyVerified;

  OpportunityFilter copyWith({
    String? searchQuery,
    String? categoryId,
    double? minCapital,
    double? maxCapital,
    String? riskLevel,
    String? liquidityHorizon,
    String? managementType,
    String? experienceLevel,
    String? city,
    bool? isOnlyVerified,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearRisk = false,
    bool clearLiquidity = false,
    bool clearManagement = false,
    bool clearExperience = false,
    bool clearCity = false,
  }) {
    return OpportunityFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      minCapital: minCapital ?? this.minCapital,
      maxCapital: maxCapital ?? this.maxCapital,
      riskLevel: clearRisk ? null : (riskLevel ?? this.riskLevel),
      liquidityHorizon:
          clearLiquidity ? null : (liquidityHorizon ?? this.liquidityHorizon),
      managementType:
          clearManagement ? null : (managementType ?? this.managementType),
      experienceLevel:
          clearExperience ? null : (experienceLevel ?? this.experienceLevel),
      city: clearCity ? null : (city ?? this.city),
      isOnlyVerified: isOnlyVerified ?? this.isOnlyVerified,
    );
  }
}
