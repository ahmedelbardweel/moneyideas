import 'package:flutter/foundation.dart';

/// Aggregated system-wide KPIs for the platform administrators.
@immutable
class AdminKpiStats {
  const AdminKpiStats({
    this.pendingCompaniesCount = 0,
    this.pendingOffersCount = 0,
    this.pendingProjectsCount = 0,
    this.totalUsersCount = 0,
    this.pendingReportsCount = 0,
    this.activeCompaniesCount = 0,
    this.activeOffersCount = 0,
  });

  final int pendingCompaniesCount;
  final int pendingOffersCount;
  final int pendingProjectsCount;
  final int totalUsersCount;
  final int pendingReportsCount;
  final int activeCompaniesCount;
  final int activeOffersCount;
}

/// User overview item for administrative user governance.
@immutable
class AdminUserItem {
  const AdminUserItem({
    required this.id,
    required this.fullName,
    required this.email,
    this.roles = const [],
    this.isBanned = false,
    this.isVerified = false,
    this.city = 'Dubai',
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final List<String> roles;
  final bool isBanned;
  final bool isVerified;
  final String city;
  final DateTime? createdAt;

  bool get isAdmin => roles.contains('admin');
  bool get isCompanyOwner => roles.contains('company');
  bool get isInvestor => roles.contains('investor');
  bool get isProjectOwner => roles.contains('project_owner');
}

/// Moderation and fraud report item for administrative resolution.
@immutable
class AdminReportItem {
  const AdminReportItem({
    required this.id,
    required this.reporterId,
    required this.reportedEntityType,
    required this.reportedEntityId,
    required this.reason,
    this.details,
    this.status = 'pending',
    this.adminNotes,
    this.createdAt,
  });

  final String id;
  final String reporterId;
  final String reportedEntityType;
  final String reportedEntityId;
  final String reason;
  final String? details;
  final String status;
  final String? adminNotes;
  final DateTime? createdAt;

  String get statusLabelAr => switch (status) {
        'under_investigation' => 'قيد التحقيق',
        'action_taken' => 'تم اتخاذ إجراء',
        'dismissed' => 'تم حفظ البلاغ',
        _ => 'جديد وبانتظار المراجعة',
      };
}
