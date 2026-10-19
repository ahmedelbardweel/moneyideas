/// Model representing an explainable matched opportunity returned from Supabase RPC.
class MatchResult {
  const MatchResult({
    required this.opportunityId,
    required this.slug,
    required this.titleAr,
    required this.titleEn,
    required this.summaryAr,
    required this.summaryEn,
    required this.categoryId,
    required this.minBudget,
    required this.currency,
    required this.criteriaMetCount,
    required this.totalCriteriaCount,
    required this.matchReasons,
    required this.missingCriteria,
    required this.explanationAr,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      opportunityId: json['opportunity_id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      titleAr: json['title_ar'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      summaryAr: json['summary_ar'] as String? ?? '',
      summaryEn: json['summary_en'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      minBudget: (json['min_budget'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'AED',
      criteriaMetCount: json['criteria_met_count'] as int? ?? 0,
      totalCriteriaCount: json['total_criteria_count'] as int? ?? 5,
      matchReasons: (json['match_reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      missingCriteria: (json['missing_criteria'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      explanationAr: json['explanation_ar'] as String? ?? '',
    );
  }

  final String opportunityId;
  final String slug;
  final String titleAr;
  final String titleEn;
  final String summaryAr;
  final String summaryEn;
  final String categoryId;
  final double minBudget;
  final String currency;
  final int criteriaMetCount;
  final int totalCriteriaCount;
  final List<String> matchReasons;
  final List<String> missingCriteria;
  final String explanationAr;

  bool get isFullMatch => criteriaMetCount >= totalCriteriaCount;
  double get matchRatio =>
      totalCriteriaCount > 0 ? criteriaMetCount / totalCriteriaCount : 0.0;
}
