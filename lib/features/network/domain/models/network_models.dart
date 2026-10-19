import 'package:flutter/foundation.dart';

/// Type of a network project showcase item.
enum ProjectType {
  idea,
  existingBusiness,
  investmentRequest;

  static ProjectType fromString(String? val) {
    return switch (val) {
      'existing_business' => ProjectType.existingBusiness,
      'investment_request' => ProjectType.investmentRequest,
      _ => ProjectType.idea,
    };
  }

  String toDbValue() {
    return switch (this) {
      ProjectType.existingBusiness => 'existing_business',
      ProjectType.investmentRequest => 'investment_request',
      ProjectType.idea => 'idea',
    };
  }

  String get labelAr => switch (this) {
        ProjectType.idea => 'فكرة مشروع جديدة',
        ProjectType.existingBusiness => 'مشروع قائم يعمل',
        ProjectType.investmentRequest => 'طلب استثمار وتمويل',
      };
}

/// Execution stage of a project.
enum ProjectStage {
  concept,
  prototype,
  generatingRevenue,
  scaling;

  static ProjectStage fromString(String? val) {
    return switch (val) {
      'prototype' => ProjectStage.prototype,
      'generating_revenue' => ProjectStage.generatingRevenue,
      'scaling' => ProjectStage.scaling,
      _ => ProjectStage.concept,
    };
  }

  String toDbValue() {
    return switch (this) {
      ProjectStage.prototype => 'prototype',
      ProjectStage.generatingRevenue => 'generating_revenue',
      ProjectStage.scaling => 'scaling',
      ProjectStage.concept => 'concept',
    };
  }

  String get labelAr => switch (this) {
        ProjectStage.concept => 'مرحلة المفهوم والفكرة',
        ProjectStage.prototype => 'نموذج أولي (MVP)',
        ProjectStage.generatingRevenue => 'يحقق إيرادات فعلية',
        ProjectStage.scaling => 'مرحلة التوسع والنمو',
      };
}

/// Mutual contact request status between two parties.
enum ContactRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled;

  static ContactRequestStatus fromString(String? val) {
    return switch (val) {
      'accepted' => ContactRequestStatus.accepted,
      'rejected' => ContactRequestStatus.rejected,
      'cancelled' => ContactRequestStatus.cancelled,
      _ => ContactRequestStatus.pending,
    };
  }

  String toDbValue() {
    return switch (this) {
      ContactRequestStatus.accepted => 'accepted',
      ContactRequestStatus.rejected => 'rejected',
      ContactRequestStatus.cancelled => 'cancelled',
      ContactRequestStatus.pending => 'pending',
    };
  }

  String get labelAr => switch (this) {
        ContactRequestStatus.pending => 'بانتظار موافقة الطرف الآخر',
        ContactRequestStatus.accepted => 'مقبول (المحادثة نشطة)',
        ContactRequestStatus.rejected => 'تم الاعتذار عن الطلب',
        ContactRequestStatus.cancelled => 'ملغى من قبلك',
      };
}

/// Investor profile mapped to public.investor_profiles.
@immutable
class InvestorProfile {
  const InvestorProfile({
    required this.id,
    required this.userId,
    this.investorType = 'مستثمر فردي',
    this.bio,
    this.sectorsOfInterest = const [],
    this.targetMarkets = const ['UAE'],
    this.preferredStages = const [ProjectStage.prototype, ProjectStage.generatingRevenue],
    this.showFinancialRangePublicly = false,
    this.minTicketSize,
    this.maxTicketSize,
    this.currency = 'AED',
    this.contactConditions,
    this.isVerified = false,
    this.fullName,
    this.avatarUrl,
    this.city = 'Dubai',
    this.createdAt,
  });

  factory InvestorProfile.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    final rawSectors = json['sectors_of_interest'];
    final sectors = rawSectors is List
        ? rawSectors.map((e) => e.toString()).toList()
        : <String>[];

    final rawMarkets = json['target_markets'];
    final markets = rawMarkets is List
        ? rawMarkets.map((e) => e.toString()).toList()
        : <String>['UAE'];

    final rawStages = json['preferred_stages'];
    final stages = rawStages is List
        ? rawStages
            .map((e) => ProjectStage.fromString(e.toString()))
            .toList()
        : <ProjectStage>[ProjectStage.prototype, ProjectStage.generatingRevenue];

    return InvestorProfile(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      investorType: json['investor_type'] as String? ?? 'مستثمر فردي',
      bio: json['bio'] as String?,
      sectorsOfInterest: sectors,
      targetMarkets: markets,
      preferredStages: stages,
      showFinancialRangePublicly:
          json['show_financial_range_publicly'] as bool? ?? false,
      minTicketSize: (json['min_ticket_size'] as num?)?.toDouble(),
      maxTicketSize: (json['max_ticket_size'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'AED',
      contactConditions: json['contact_conditions'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      city: profile?['city'] as String? ?? 'Dubai',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String userId;
  final String investorType;
  final String? bio;
  final List<String> sectorsOfInterest;
  final List<String> targetMarkets;
  final List<ProjectStage> preferredStages;
  final bool showFinancialRangePublicly;
  final double? minTicketSize;
  final double? maxTicketSize;
  final String currency;
  final String? contactConditions;
  final bool isVerified;
  final String? fullName;
  final String? avatarUrl;
  final String city;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'investor_type': investorType,
        'bio': bio,
        'sectors_of_interest': sectorsOfInterest,
        'target_markets': targetMarkets,
        'preferred_stages': preferredStages.map((s) => s.toDbValue()).toList(),
        'show_financial_range_publicly': showFinancialRangePublicly,
        'min_ticket_size': minTicketSize,
        'max_ticket_size': maxTicketSize,
        'currency': currency,
        'contact_conditions': contactConditions,
      };
}

/// Project showcase item mapped to public.projects.
@immutable
class Project {
  const Project({
    required this.id,
    required this.ownerId,
    required this.categoryId,
    required this.name,
    required this.summary,
    required this.problemStatement,
    required this.solutionStatement,
    required this.helpNeededType,
    this.type = ProjectType.idea,
    this.stage = ProjectStage.concept,
    this.targetAudience,
    this.revenueModel,
    this.regulatoryApprovalStatus = 'unverified',
    this.isPublished = true,
    this.ownerName,
    this.ownerAvatarUrl,
    this.categoryNameAr,
    this.documents = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final category = json['categories'] as Map<String, dynamic>?;
    final docsRaw = json['project_documents'] as List<dynamic>? ?? [];

    final docs = docsRaw
        .map((d) => ProjectDocument.fromJson(d as Map<String, dynamic>))
        .toList();

    return Project(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      type: ProjectType.fromString(json['type'] as String?),
      stage: ProjectStage.fromString(json['stage'] as String?),
      name: json['name'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      problemStatement: json['problem_statement'] as String? ?? '',
      solutionStatement: json['solution_statement'] as String? ?? '',
      targetAudience: json['target_audience'] as String?,
      revenueModel: json['revenue_model'] as String?,
      helpNeededType: json['help_needed_type'] as String? ?? 'شريك تقني',
      regulatoryApprovalStatus:
          json['regulatory_approval_status'] as String? ?? 'unverified',
      isPublished: json['is_published'] as bool? ?? true,
      ownerName: profile?['full_name'] as String?,
      ownerAvatarUrl: profile?['avatar_url'] as String?,
      categoryNameAr: category?['title_ar'] as String?,
      documents: docs,
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
  final String categoryId;
  final ProjectType type;
  final ProjectStage stage;
  final String name;
  final String summary;
  final String problemStatement;
  final String solutionStatement;
  final String? targetAudience;
  final String? revenueModel;
  final String helpNeededType;
  final String regulatoryApprovalStatus;
  final bool isPublished;
  final String? ownerName;
  final String? ownerAvatarUrl;
  final String? categoryNameAr;
  final List<ProjectDocument> documents;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'type': type.toDbValue(),
        'stage': stage.toDbValue(),
        'name': name,
        'summary': summary,
        'problem_statement': problemStatement,
        'solution_statement': solutionStatement,
        'target_audience': targetAudience,
        'revenue_model': revenueModel,
        'help_needed_type': helpNeededType,
        'is_published': isPublished,
      };
}

/// Project document mapped to public.project_documents.
@immutable
class ProjectDocument {
  const ProjectDocument({
    required this.id,
    required this.projectId,
    required this.title,
    required this.fileUrl,
    this.isPublic = false,
    this.uploadedAt,
  });

  factory ProjectDocument.fromJson(Map<String, dynamic> json) {
    return ProjectDocument(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'] as String)
          : null,
    );
  }

  final String id;
  final String projectId;
  final String title;
  final String fileUrl;
  final bool isPublic;
  final DateTime? uploadedAt;
}

/// Mutual contact request mapped to public.contact_requests.
@immutable
class ContactRequest {
  const ContactRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.reason,
    required this.introductionMessage,
    this.projectId,
    this.status = ContactRequestStatus.pending,
    this.senderName,
    this.senderAvatarUrl,
    this.receiverName,
    this.projectName,
    this.respondedAt,
    this.createdAt,
  });

  factory ContactRequest.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    final receiver = json['receiver'] as Map<String, dynamic>?;
    final project = json['projects'] as Map<String, dynamic>?;

    return ContactRequest(
      id: json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      receiverId: json['receiver_id'] as String? ?? '',
      projectId: json['project_id'] as String?,
      reason: json['reason'] as String? ?? 'طلب تواصل وشراكة',
      introductionMessage: json['introduction_message'] as String? ?? '',
      status: ContactRequestStatus.fromString(json['status'] as String?),
      senderName: sender?['full_name'] as String?,
      senderAvatarUrl: sender?['avatar_url'] as String?,
      receiverName: receiver?['full_name'] as String?,
      projectName: project?['name'] as String?,
      respondedAt: json['responded_at'] != null
          ? DateTime.tryParse(json['responded_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String senderId;
  final String receiverId;
  final String? projectId;
  final String reason;
  final String introductionMessage;
  final ContactRequestStatus status;
  final String? senderName;
  final String? senderAvatarUrl;
  final String? receiverName;
  final String? projectName;
  final DateTime? respondedAt;
  final DateTime? createdAt;
}

/// Investor private study watchlist item mapped to public.investor_watchlist.
@immutable
class InvestorWatchlistItem {
  const InvestorWatchlistItem({
    required this.id,
    required this.investorId,
    required this.projectId,
    this.privateNotes,
    this.savedAt,
    this.project,
  });

  factory InvestorWatchlistItem.fromJson(Map<String, dynamic> json) {
    final projJson = json['projects'] as Map<String, dynamic>?;

    return InvestorWatchlistItem(
      id: json['id'] as String? ?? '',
      investorId: json['investor_id'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      privateNotes: json['private_notes'] as String?,
      savedAt: json['saved_at'] != null
          ? DateTime.tryParse(json['saved_at'] as String)
          : null,
      project: projJson != null ? Project.fromJson(projJson) : null,
    );
  }

  final String id;
  final String investorId;
  final String projectId;
  final String? privateNotes;
  final DateTime? savedAt;
  final Project? project;
}
