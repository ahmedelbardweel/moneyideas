import 'package:flutter/foundation.dart';

/// Status of a commercial offer in its review & publication lifecycle.
enum OfferStatus {
  draft,
  inReview,
  needsChanges,
  approved,
  rejected,
  paused,
  expired,
  archived;

  static OfferStatus fromString(String? val) {
    return switch (val) {
      'in_review' => OfferStatus.inReview,
      'needs_changes' => OfferStatus.needsChanges,
      'approved' => OfferStatus.approved,
      'rejected' => OfferStatus.rejected,
      'paused' => OfferStatus.paused,
      'expired' => OfferStatus.expired,
      'archived' => OfferStatus.archived,
      _ => OfferStatus.draft,
    };
  }

  String toDbValue() {
    return switch (this) {
      OfferStatus.inReview => 'in_review',
      OfferStatus.needsChanges => 'needs_changes',
      OfferStatus.approved => 'approved',
      OfferStatus.rejected => 'rejected',
      OfferStatus.paused => 'paused',
      OfferStatus.expired => 'expired',
      OfferStatus.archived => 'archived',
      OfferStatus.draft => 'draft',
    };
  }

  String get labelAr => switch (this) {
        OfferStatus.draft => 'مسودة',
        OfferStatus.inReview => 'قيد المراجعة',
        OfferStatus.needsChanges => 'تحتاج تعديلات',
        OfferStatus.approved => 'منشور ونشط',
        OfferStatus.rejected => 'مرفوض',
        OfferStatus.paused => 'متوقف مؤقتاً',
        OfferStatus.expired => 'منتهي الصلاحية',
        OfferStatus.archived => 'مؤرشف',
      };
}

/// Commercial offer domain model mapped to public.company_offers.
@immutable
class CompanyOffer {
  const CompanyOffer({
    required this.id,
    required this.companyId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.serviceType,
    required this.termsAndConditions,
    required this.validUntil,
    this.categoryTitle,
    this.companyTradeName,
    this.companyLogoUrl,
    this.isCompanyVerified = false,
    this.price,
    this.priceCurrency = 'AED',
    this.additionalFeesDescription,
    this.targetCities = const ['Dubai'],
    this.validFrom,
    this.status = OfferStatus.draft,
    this.adminReviewNotes,
    this.viewsCount = 0,
    this.detailsOpenedCount = 0,
    this.leadsCount = 0,
    this.mediaUrls = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyOffer.fromJson(Map<String, dynamic> json) {
    final companyObj = json['companies'] as Map<String, dynamic>?;
    final catObj = json['categories'] as Map<String, dynamic>?;

    final rawCities = json['target_cities'];
    final cities = rawCities is List
        ? rawCities.map((e) => e.toString()).toList()
        : <String>['Dubai'];

    final rawMedia = json['offer_media'];
    final media = rawMedia is List
        ? rawMedia
            .map((m) => (m as Map<String, dynamic>)['file_url'] as String? ?? '')
            .where((u) => u.isNotEmpty)
            .toList()
        : <String>[];

    return CompanyOffer(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      categoryId: json['category_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? 'خدمة تجارية',
      termsAndConditions: json['terms_and_conditions'] as String? ?? '',
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'] as String) ??
              DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      categoryTitle: catObj != null
          ? (catObj['title_ar'] as String? ?? catObj['title_en'] as String?)
          : null,
      companyTradeName: companyObj?['trade_name'] as String?,
      companyLogoUrl: companyObj?['logo_url'] as String?,
      isCompanyVerified:
          companyObj?['verification_status'] == 'verified',
      price: json['price'] != null
          ? (json['price'] as num).toDouble()
          : null,
      priceCurrency: json['price_currency'] as String? ?? 'AED',
      additionalFeesDescription:
          json['additional_fees_description'] as String?,
      targetCities: cities,
      validFrom: json['valid_from'] != null
          ? DateTime.tryParse(json['valid_from'] as String)
          : null,
      status: OfferStatus.fromString(json['status'] as String?),
      adminReviewNotes: json['admin_review_notes'] as String?,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      detailsOpenedCount:
          (json['details_opened_count'] as num?)?.toInt() ?? 0,
      leadsCount: (json['leads_count'] as num?)?.toInt() ?? 0,
      mediaUrls: media,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String companyId;
  final String categoryId;
  final String title;
  final String description;
  final String serviceType;
  final String termsAndConditions;
  final DateTime validUntil;

  final String? categoryTitle;
  final String? companyTradeName;
  final String? companyLogoUrl;
  final bool isCompanyVerified;

  final double? price;
  final String priceCurrency;
  final String? additionalFeesDescription;
  final List<String> targetCities;
  final DateTime? validFrom;
  final OfferStatus status;
  final String? adminReviewNotes;
  final int viewsCount;
  final int detailsOpenedCount;
  final int leadsCount;
  final List<String> mediaUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPriceOnDemand => price == null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'service_type': serviceType,
      'price': price,
      'price_currency': priceCurrency,
      'additional_fees_description': additionalFeesDescription,
      'target_cities': targetCities,
      'terms_and_conditions': termsAndConditions,
      'valid_from': validFrom?.toIso8601String().split('T').first,
      'valid_until': validUntil.toIso8601String().split('T').first,
      'status': status.toDbValue(),
    };
  }

  CompanyOffer copyWith({
    String? id,
    String? companyId,
    String? categoryId,
    String? title,
    String? description,
    String? serviceType,
    String? termsAndConditions,
    DateTime? validUntil,
    String? categoryTitle,
    String? companyTradeName,
    String? companyLogoUrl,
    bool? isCompanyVerified,
    double? price,
    String? priceCurrency,
    String? additionalFeesDescription,
    List<String>? targetCities,
    DateTime? validFrom,
    OfferStatus? status,
    String? adminReviewNotes,
    int? viewsCount,
    int? detailsOpenedCount,
    int? leadsCount,
    List<String>? mediaUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyOffer(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      serviceType: serviceType ?? this.serviceType,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      validUntil: validUntil ?? this.validUntil,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      companyTradeName: companyTradeName ?? this.companyTradeName,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      isCompanyVerified: isCompanyVerified ?? this.isCompanyVerified,
      price: price ?? this.price,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      additionalFeesDescription:
          additionalFeesDescription ?? this.additionalFeesDescription,
      targetCities: targetCities ?? this.targetCities,
      validFrom: validFrom ?? this.validFrom,
      status: status ?? this.status,
      adminReviewNotes: adminReviewNotes ?? this.adminReviewNotes,
      viewsCount: viewsCount ?? this.viewsCount,
      detailsOpenedCount: detailsOpenedCount ?? this.detailsOpenedCount,
      leadsCount: leadsCount ?? this.leadsCount,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
