import 'package:flutter/foundation.dart';

/// Role of a team member in a registered company.
enum CompanyMemberRole {
  owner,
  admin,
  supportAgent;

  static CompanyMemberRole fromString(String? val) {
    return switch (val) {
      'owner' => CompanyMemberRole.owner,
      'admin' => CompanyMemberRole.admin,
      _ => CompanyMemberRole.supportAgent,
    };
  }

  String toDbValue() {
    return switch (this) {
      CompanyMemberRole.owner => 'owner',
      CompanyMemberRole.admin => 'admin',
      CompanyMemberRole.supportAgent => 'support_agent',
    };
  }

  String get labelAr => switch (this) {
        CompanyMemberRole.owner => 'مالك الشركة',
        CompanyMemberRole.admin => 'مدير الحساب',
        CompanyMemberRole.supportAgent => 'وكيل دعم واستفسارات',
      };
}

/// Company team member domain model mapped to public.company_members.
@immutable
class CompanyMember {
  const CompanyMember({
    required this.id,
    required this.companyId,
    required this.userId,
    this.role = CompanyMemberRole.supportAgent,
    this.userFullName,
    this.userEmail,
    this.invitedAt,
  });

  factory CompanyMember.fromJson(Map<String, dynamic> json) {
    final userObj = json['profiles'] as Map<String, dynamic>?;

    return CompanyMember(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      role: CompanyMemberRole.fromString(json['role'] as String?),
      userFullName: userObj?['full_name'] as String?,
      userEmail: userObj?['email'] as String?,
      invitedAt: json['invited_at'] != null
          ? DateTime.tryParse(json['invited_at'] as String)
          : null,
    );
  }

  final String id;
  final String companyId;
  final String userId;
  final CompanyMemberRole role;
  final String? userFullName;
  final String? userEmail;
  final DateTime? invitedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'user_id': userId,
      'role': role.toDbValue(),
    };
  }
}
