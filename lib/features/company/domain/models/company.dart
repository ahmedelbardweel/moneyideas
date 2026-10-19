import 'package:flutter/foundation.dart';

/// Verification status for a registered company.
enum CompanyVerificationStatus {
  unverified,
  pendingReview,
  verified,
  rejected;

  static CompanyVerificationStatus fromString(String? val) {
    return switch (val) {
      'verified' => CompanyVerificationStatus.verified,
      'pending_review' => CompanyVerificationStatus.pendingReview,
      'rejected' => CompanyVerificationStatus.rejected,
      _ => CompanyVerificationStatus.unverified,
    };
  }

  String toDbValue() {
    return switch (this) {
      CompanyVerificationStatus.verified => 'verified',
      CompanyVerificationStatus.pendingReview => 'pending_review',
      CompanyVerificationStatus.rejected => 'rejected',
      CompanyVerificationStatus.unverified => 'unverified',
    };
  }

  String get labelAr => switch (this) {
        CompanyVerificationStatus.verified => 'جهة موثقة رسمياً',
        CompanyVerificationStatus.pendingReview => 'قيد التدقيق والمراجعة',
        CompanyVerificationStatus.rejected => 'مرفوض - يحتاج تعديل',
        CompanyVerificationStatus.unverified => 'غير موثقة',
      };
}

/// Registered business / company entity mapped to public.companies.
@immutable
class Company {
  const Company({
    required this.id,
    required this.ownerId,
    required this.legalName,
    required this.tradeName,
    required this.businessType,
    required this.tradeLicenseNumber,
    required this.officialEmail,
    this.countryCode = 'AE',
    this.city = 'Dubai',
    this.licenseIssuingAuthority,
    this.licenseExpiryDate,
    this.officialPhone,
    this.websiteUrl,
    this.logoUrl,
    this.bio,
    this.verificationStatus = CompanyVerificationStatus.unverified,
    this.verificationNotes,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      legalName: json['legal_name'] as String? ?? '',
      tradeName: json['trade_name'] as String? ?? '',
      businessType: json['business_type'] as String? ?? 'عام',
      countryCode: json['country_code'] as String? ?? 'AE',
      city: json['city'] as String? ?? 'Dubai',
      tradeLicenseNumber: json['trade_license_number'] as String? ?? '',
      licenseIssuingAuthority: json['license_issuing_authority'] as String?,
      licenseExpiryDate: json['license_expiry_date'] != null
          ? DateTime.tryParse(json['license_expiry_date'] as String)
          : null,
      officialEmail: json['official_email'] as String? ?? '',
      officialPhone: json['official_phone'] as String?,
      websiteUrl: json['website_url'] as String?,
      logoUrl: json['logo_url'] as String?,
      bio: json['bio'] as String?,
      verificationStatus: CompanyVerificationStatus.fromString(
        json['verification_status'] as String?,
      ),
      verificationNotes: json['verification_notes'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String ownerId;
  final String legalName;
  final String tradeName;
  final String businessType;
  final String countryCode;
  final String city;
  final String tradeLicenseNumber;
  final String? licenseIssuingAuthority;
  final DateTime? licenseExpiryDate;
  final String officialEmail;
  final String? officialPhone;
  final String? websiteUrl;
  final String? logoUrl;
  final String? bio;
  final CompanyVerificationStatus verificationStatus;
  final String? verificationNotes;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isVerified =>
      verificationStatus == CompanyVerificationStatus.verified;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'legal_name': legalName,
      'trade_name': tradeName,
      'business_type': businessType,
      'country_code': countryCode,
      'city': city,
      'trade_license_number': tradeLicenseNumber,
      'license_issuing_authority': licenseIssuingAuthority,
      'license_expiry_date': licenseExpiryDate?.toIso8601String().split('T').first,
      'official_email': officialEmail,
      'official_phone': officialPhone,
      'website_url': websiteUrl,
      'logo_url': logoUrl,
      'bio': bio,
      'verification_status': verificationStatus.toDbValue(),
      'verification_notes': verificationNotes,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  Company copyWith({
    String? id,
    String? ownerId,
    String? legalName,
    String? tradeName,
    String? businessType,
    String? countryCode,
    String? city,
    String? tradeLicenseNumber,
    String? licenseIssuingAuthority,
    DateTime? licenseExpiryDate,
    String? officialEmail,
    String? officialPhone,
    String? websiteUrl,
    String? logoUrl,
    String? bio,
    CompanyVerificationStatus? verificationStatus,
    String? verificationNotes,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      legalName: legalName ?? this.legalName,
      tradeName: tradeName ?? this.tradeName,
      businessType: businessType ?? this.businessType,
      countryCode: countryCode ?? this.countryCode,
      city: city ?? this.city,
      tradeLicenseNumber: tradeLicenseNumber ?? this.tradeLicenseNumber,
      licenseIssuingAuthority:
          licenseIssuingAuthority ?? this.licenseIssuingAuthority,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      officialEmail: officialEmail ?? this.officialEmail,
      officialPhone: officialPhone ?? this.officialPhone,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      bio: bio ?? this.bio,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
