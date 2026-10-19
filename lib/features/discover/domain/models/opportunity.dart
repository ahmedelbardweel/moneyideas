/// Domain model representing a verified investment/business opportunity.
class Opportunity {
  const Opportunity({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.summaryAr,
    required this.summaryEn,
    required this.categoryId,
    required this.minCapital,
    required this.maxCapital,
    required this.currency,
    required this.weeklyHoursRequired,
    required this.experienceLevel,
    required this.riskLevel,
    required this.liquidityHorizon,
    required this.managementType,
    required this.country,
    required this.city,
    required this.dataQualityStatus,
    this.estimatedRoiAnnual,
    this.viewCount = 0,
    this.saveCount = 0,
    this.isFeatured = false,
    this.isSponsored = false,
    this.sponsorName,
    this.categoryNameAr,
    this.categoryNameEn,
    this.categoryIcon,
    this.verifiedAt,
    this.createdAt,
    this.explanationPoints = const [],
    this.costs = const [],
    this.risks = const [],
    this.sources = const [],
    this.steps = const [],
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'] as String,
      titleAr: json['title_ar'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      summaryAr: json['summary_ar'] as String? ?? '',
      summaryEn: json['summary_en'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      minCapital:
          ((json['min_capital'] ?? json['min_budget']) as num?)?.toDouble() ??
              0.0,
      maxCapital:
          ((json['max_capital'] ?? json['max_budget']) as num?)?.toDouble() ??
              0.0,
      currency: json['currency'] as String? ?? 'AED',
      weeklyHoursRequired:
          ((json['weekly_hours_required'] ?? json['min_weekly_hours'])
                  as int?) ??
              10,
      experienceLevel: json['experience_level'] as String? ??
          json['knowledge_level_required'] as String? ??
          'beginner',
      riskLevel: json['risk_level'] as String? ?? 'medium',
      liquidityHorizon: json['liquidity_horizon'] as String? ?? 'medium_term',
      managementType: json['management_type'] as String? ?? 'active',
      country: json['country'] as String? ??
          json['target_country'] as String? ??
          'AE',
      city: json['city'] as String? ??
          ((json['target_cities'] as List<dynamic>?)?.firstOrNull as String?) ??
          'Dubai',
      dataQualityStatus: json['is_verified'] == true
          ? 'verified'
          : (json['data_quality_status'] as String? ?? 'verified'),
      estimatedRoiAnnual:
          (json['estimated_roi_annual'] as num?)?.toDouble(),
      viewCount: json['view_count'] as int? ?? 0,
      saveCount: json['save_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isSponsored: json['is_sponsored'] as bool? ?? false,
      sponsorName: json['sponsor_name'] as String?,
      categoryNameAr: json['category_name_ar'] as String? ??
          (json['categories'] as Map<String, dynamic>?)?['title_ar'] as String? ??
          (json['categories'] as Map<String, dynamic>?)?['name_ar'] as String?,
      categoryNameEn: json['category_name_en'] as String? ??
          (json['categories'] as Map<String, dynamic>?)?['title_en'] as String? ??
          (json['categories'] as Map<String, dynamic>?)?['name_en'] as String?,
      categoryIcon: json['category_icon'] as String? ??
          (json['categories'] as Map<String, dynamic>?)?['icon_name'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      explanationPoints: (json['explanation_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      costs: ((json['opportunity_costs'] ?? json['costs']) as List<dynamic>?)
              ?.map((c) => OpportunityCost.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      risks: ((json['opportunity_risks'] ?? json['risks']) as List<dynamic>?)
              ?.map((r) => OpportunityRisk.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
      sources: ((json['opportunity_sources'] ?? json['sources']) as List<dynamic>?)
              ?.map((s) => OpportunitySource.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      steps: ((json['opportunity_steps'] ?? json['steps']) as List<dynamic>?)
              ?.map((st) => OpportunityStep.fromJson(st as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  final String id;
  final String titleAr;
  final String titleEn;
  final String summaryAr;
  final String summaryEn;
  final String categoryId;
  final double minCapital;
  final double maxCapital;
  final String currency;
  final int weeklyHoursRequired;
  final String experienceLevel;
  final String riskLevel;
  final String liquidityHorizon;
  final String managementType;
  final String country;
  final String city;
  final String dataQualityStatus;
  final double? estimatedRoiAnnual;
  final int viewCount;
  final int saveCount;
  final bool isFeatured;
  final bool isSponsored;
  final String? sponsorName;
  final String? categoryNameAr;
  final String? categoryNameEn;
  final String? categoryIcon;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final List<String> explanationPoints;
  final List<OpportunityCost> costs;
  final List<OpportunityRisk> risks;
  final List<OpportunitySource> sources;
  final List<OpportunityStep> steps;

  String localizedTitle(String locale) => locale == 'en' && titleEn.isNotEmpty ? titleEn : titleAr;
  String localizedSummary(String locale) => locale == 'en' && summaryEn.isNotEmpty ? summaryEn : summaryAr;
}

class OpportunityCost {
  const OpportunityCost({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.amount,
    required this.isMandatory,
    required this.isEstimated,
    this.notesAr,
    this.notesEn,
  });

  factory OpportunityCost.fromJson(Map<String, dynamic> json) {
    return OpportunityCost(
      id: json['id'] as String? ?? '',
      titleAr: json['item_name_ar'] as String? ??
          json['item_title_ar'] as String? ??
          json['title_ar'] as String? ??
          '',
      titleEn: json['item_name_en'] as String? ??
          json['item_title_en'] as String? ??
          json['title_en'] as String? ??
          '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isMandatory: json['is_mandatory'] as bool? ?? true,
      isEstimated: json['is_estimated'] as bool? ??
          (json['is_documented'] == false),
      notesAr: json['source_reference'] as String? ?? json['notes_ar'] as String?,
      notesEn: json['notes_en'] as String?,
    );
  }

  final String id;
  final String titleAr;
  final String titleEn;
  final double amount;
  final bool isMandatory;
  final bool isEstimated;
  final String? notesAr;
  final String? notesEn;
}

class OpportunityRisk {
  const OpportunityRisk({
    required this.id,
    required this.riskTitleAr,
    required this.riskTitleEn,
    required this.severity,
    required this.mitigationAr,
    required this.mitigationEn,
    required this.verificationQuestionAr,
    required this.verificationQuestionEn,
  });

  factory OpportunityRisk.fromJson(Map<String, dynamic> json) {
    return OpportunityRisk(
      id: json['id'] as String? ?? '',
      riskTitleAr: json['title_ar'] as String? ??
          json['risk_title_ar'] as String? ??
          '',
      riskTitleEn: json['title_en'] as String? ??
          json['risk_title_en'] as String? ??
          '',
      severity: json['risk_type'] as String? ??
          json['severity'] as String? ??
          'medium',
      mitigationAr: json['description_ar'] as String? ??
          json['mitigation_ar'] as String? ??
          '',
      mitigationEn: json['description_en'] as String? ??
          json['mitigation_en'] as String? ??
          '',
      verificationQuestionAr:
          json['verification_question_ar'] as String? ?? '',
      verificationQuestionEn:
          json['verification_question_en'] as String? ?? '',
    );
  }

  final String id;
  final String riskTitleAr;
  final String riskTitleEn;
  final String severity;
  final String mitigationAr;
  final String mitigationEn;
  final String verificationQuestionAr;
  final String verificationQuestionEn;
}

class OpportunitySource {
  const OpportunitySource({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.sourceType,
    this.url,
    this.verifiedDate,
  });

  factory OpportunitySource.fromJson(Map<String, dynamic> json) {
    final ds = json['data_sources'] as Map<String, dynamic>?;
    return OpportunitySource(
      id: json['source_id'] as String? ?? json['id'] as String? ?? '',
      nameAr: ds?['name_ar'] as String? ?? json['name_ar'] as String? ?? '',
      nameEn: ds?['name_en'] as String? ?? json['name_en'] as String? ?? '',
      sourceType: ds?['source_type'] as String? ??
          json['source_type'] as String? ??
          'government',
      url: ds?['website_url'] as String? ?? json['url'] as String?,
      verifiedDate: json['last_verified_at'] as String? ??
          json['verified_date'] as String?,
    );
  }

  final String id;
  final String nameAr;
  final String nameEn;
  final String sourceType;
  final String? url;
  final String? verifiedDate;
}

class OpportunityStep {
  const OpportunityStep({
    required this.id,
    required this.stepNumber,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    this.estimatedDays,
    this.estimatedCost,
  });

  factory OpportunityStep.fromJson(Map<String, dynamic> json) {
    return OpportunityStep(
      id: json['id'] as String,
      stepNumber: json['step_number'] as int? ?? 1,
      titleAr: json['title_ar'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      descriptionAr: json['description_ar'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      estimatedDays: json['estimated_days'] as int?,
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
    );
  }

  final String id;
  final int stepNumber;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final int? estimatedDays;
  final double? estimatedCost;
}
