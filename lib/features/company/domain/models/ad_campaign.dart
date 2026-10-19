import 'package:flutter/foundation.dart';

/// Ad campaign domain model mapped to public.ad_campaigns.
@immutable
class AdCampaign {
  const AdCampaign({
    required this.id,
    required this.companyId,
    required this.campaignTitle,
    required this.startDate,
    required this.endDate,
    this.offerId,
    this.offerTitle,
    this.targetCities = const ['Dubai'],
    this.bannerUrl,
    this.isActive = true,
    this.adminApproved = false,
    this.totalImpressions = 0,
    this.totalClicks = 0,
    this.createdAt,
  });

  factory AdCampaign.fromJson(Map<String, dynamic> json) {
    final offerObj = json['company_offers'] as Map<String, dynamic>?;

    final rawCities = json['target_cities'];
    final cities = rawCities is List
        ? rawCities.map((e) => e.toString()).toList()
        : <String>['Dubai'];

    return AdCampaign(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      campaignTitle: json['campaign_title'] as String? ?? '',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String) ??
              DateTime.now().add(const Duration(days: 14))
          : DateTime.now().add(const Duration(days: 14)),
      offerId: json['offer_id'] as String?,
      offerTitle: offerObj?['title'] as String?,
      targetCities: cities,
      bannerUrl: json['banner_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      adminApproved: json['admin_approved'] as bool? ?? false,
      totalImpressions: (json['total_impressions'] as num?)?.toInt() ?? 0,
      totalClicks: (json['total_clicks'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String companyId;
  final String campaignTitle;
  final DateTime startDate;
  final DateTime endDate;
  final String? offerId;
  final String? offerTitle;
  final List<String> targetCities;
  final String? bannerUrl;
  final bool isActive;
  final bool adminApproved;
  final int totalImpressions;
  final int totalClicks;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'campaign_title': campaignTitle,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'offer_id': offerId,
      'target_cities': targetCities,
      'banner_url': bannerUrl,
      'is_active': isActive,
      'admin_approved': adminApproved,
    };
  }
}
