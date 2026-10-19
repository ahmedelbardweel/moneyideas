import 'package:flutter/foundation.dart';

enum DealType {
  equity,
  convertibleNote,
  debtFinancing,
  franchisePartnership,
  acquisition;

  static DealType fromString(String? val) {
    return switch (val) {
      'equity' => DealType.equity,
      'convertible_note' => DealType.convertibleNote,
      'debt_financing' => DealType.debtFinancing,
      'franchise_partnership' => DealType.franchisePartnership,
      'acquisition' => DealType.acquisition,
      _ => DealType.equity,
    };
  }

  String toDbString() {
    return switch (this) {
      DealType.equity => 'equity',
      DealType.convertibleNote => 'convertible_note',
      DealType.debtFinancing => 'debt_financing',
      DealType.franchisePartnership => 'franchise_partnership',
      DealType.acquisition => 'acquisition',
    };
  }

  String get labelAr {
    return switch (this) {
      DealType.equity => 'استثمار بحصة ملكية (Equity)',
      DealType.convertibleNote => 'سند قابل للتحويل (Convertible Note)',
      DealType.debtFinancing => 'تمويل مرابحة / دين استثماري',
      DealType.franchisePartnership => 'شراكة امتياز تجاري (Franchise)',
      DealType.acquisition => 'استحواذ كامل أو جزئي',
    };
  }
}

enum DealStatus {
  draft,
  negotiation,
  contractPending,
  escrowFunded,
  inProgress,
  completed,
  cancelled;

  static DealStatus fromString(String? val) {
    return switch (val) {
      'draft' => DealStatus.draft,
      'negotiation' => DealStatus.negotiation,
      'contract_pending' => DealStatus.contractPending,
      'escrow_funded' => DealStatus.escrowFunded,
      'in_progress' => DealStatus.inProgress,
      'completed' => DealStatus.completed,
      'cancelled' => DealStatus.cancelled,
      _ => DealStatus.draft,
    };
  }

  String toDbString() {
    return switch (this) {
      DealStatus.draft => 'draft',
      DealStatus.negotiation => 'negotiation',
      DealStatus.contractPending => 'contract_pending',
      DealStatus.escrowFunded => 'escrow_funded',
      DealStatus.inProgress => 'in_progress',
      DealStatus.completed => 'completed',
      DealStatus.cancelled => 'cancelled',
    };
  }

  String get labelAr {
    return switch (this) {
      DealStatus.draft => 'مسودة أولية',
      DealStatus.negotiation => 'قيد التفاوض',
      DealStatus.contractPending => 'بانتظار توقيع العقد',
      DealStatus.escrowFunded => 'تم إيداع الضمان المالي',
      DealStatus.inProgress => 'قيد التنفيذ والمراحل',
      DealStatus.completed => 'مكتملة ومحررة بالكامل',
      DealStatus.cancelled => 'ملغاة',
    };
  }
}

enum EscrowStatus {
  notInitiated,
  pendingDeposit,
  heldInEscrow,
  released,
  disputed;

  static EscrowStatus fromString(String? val) {
    return switch (val) {
      'not_initiated' => EscrowStatus.notInitiated,
      'pending_deposit' => EscrowStatus.pendingDeposit,
      'held_in_escrow' => EscrowStatus.heldInEscrow,
      'released' => EscrowStatus.released,
      'disputed' => EscrowStatus.disputed,
      _ => EscrowStatus.notInitiated,
    };
  }

  String toDbString() {
    return switch (this) {
      EscrowStatus.notInitiated => 'not_initiated',
      EscrowStatus.pendingDeposit => 'pending_deposit',
      EscrowStatus.heldInEscrow => 'held_in_escrow',
      EscrowStatus.released => 'released',
      EscrowStatus.disputed => 'disputed',
    };
  }

  String get labelAr {
    return switch (this) {
      EscrowStatus.notInitiated => 'لم يُفعل بعد',
      EscrowStatus.pendingDeposit => 'بانتظار إيداع المستثمر',
      EscrowStatus.heldInEscrow => 'محفوظ بأمان في حساب الضمان',
      EscrowStatus.released => 'تم تحرير الدفعات بالكامل',
      EscrowStatus.disputed => 'تحت التحكيم المالي / نزاع',
    };
  }
}

enum MilestoneStatus {
  pending,
  submittedForApproval,
  approved,
  released,
  disputed;

  static MilestoneStatus fromString(String? val) {
    return switch (val) {
      'pending' => MilestoneStatus.pending,
      'submitted_for_approval' => MilestoneStatus.submittedForApproval,
      'approved' => MilestoneStatus.approved,
      'released' => MilestoneStatus.released,
      'disputed' => MilestoneStatus.disputed,
      _ => MilestoneStatus.pending,
    };
  }

  String toDbString() {
    return switch (this) {
      MilestoneStatus.pending => 'pending',
      MilestoneStatus.submittedForApproval => 'submitted_for_approval',
      MilestoneStatus.approved => 'approved',
      MilestoneStatus.released => 'released',
      MilestoneStatus.disputed => 'disputed',
    };
  }

  String get labelAr {
    return switch (this) {
      MilestoneStatus.pending => 'قيد الانتظار',
      MilestoneStatus.submittedForApproval => 'قُدمت للمراجعة والاعتماد',
      MilestoneStatus.approved => 'معتمدة من المستثمر',
      MilestoneStatus.released => 'تم صرف الدفعة',
      MilestoneStatus.disputed => 'محل نزاع',
    };
  }
}

@immutable
class Deal {
  const Deal({
    required this.id,
    this.projectId,
    required this.investorId,
    required this.creatorId,
    required this.title,
    required this.dealType,
    required this.targetAmount,
    this.equityPercentage,
    required this.status,
    this.termsSummary,
    this.investorSignedAt,
    this.creatorSignedAt,
    this.escrowAccountId,
    required this.escrowStatus,
    this.createdAt,
    this.updatedAt,
    this.investorName,
    this.investorAvatar,
    this.creatorName,
    this.creatorAvatar,
    this.projectName,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    final investorProfile = json['investor_profile'] as Map<String, dynamic>?;
    final creatorProfile = json['creator_profile'] as Map<String, dynamic>?;
    final project = json['project'] as Map<String, dynamic>?;

    return Deal(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String?,
      investorId: json['investor_id'] as String? ?? '',
      creatorId: json['creator_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      dealType: DealType.fromString(json['deal_type'] as String?),
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      equityPercentage: (json['equity_percentage'] as num?)?.toDouble(),
      status: DealStatus.fromString(json['status'] as String?),
      termsSummary: json['terms_summary'] as String?,
      investorSignedAt: json['investor_signed_at'] != null
          ? DateTime.tryParse(json['investor_signed_at'] as String)
          : null,
      creatorSignedAt: json['creator_signed_at'] != null
          ? DateTime.tryParse(json['creator_signed_at'] as String)
          : null,
      escrowAccountId: json['escrow_account_id'] as String?,
      escrowStatus: EscrowStatus.fromString(json['escrow_status'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      investorName: investorProfile?['full_name'] as String?,
      investorAvatar: investorProfile?['avatar_url'] as String?,
      creatorName: creatorProfile?['full_name'] as String?,
      creatorAvatar: creatorProfile?['avatar_url'] as String?,
      projectName: project?['title'] as String?,
    );
  }

  final String id;
  final String? projectId;
  final String investorId;
  final String creatorId;
  final String title;
  final DealType dealType;
  final double targetAmount;
  final double? equityPercentage;
  final DealStatus status;
  final String? termsSummary;
  final DateTime? investorSignedAt;
  final DateTime? creatorSignedAt;
  final String? escrowAccountId;
  final EscrowStatus escrowStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? investorName;
  final String? investorAvatar;
  final String? creatorName;
  final String? creatorAvatar;
  final String? projectName;

  bool isInvestor(String userId) => investorId == userId;
  bool isCreator(String userId) => creatorId == userId;
  bool get isFullySigned => investorSignedAt != null && creatorSignedAt != null;
}

@immutable
class DealMilestone {
  const DealMilestone({
    required this.id,
    required this.dealId,
    required this.title,
    this.description,
    required this.amount,
    required this.orderIndex,
    required this.status,
    this.proofUrl,
    this.dueDate,
    this.completedAt,
    this.createdAt,
  });

  factory DealMilestone.fromJson(Map<String, dynamic> json) {
    return DealMilestone(
      id: json['id'] as String? ?? '',
      dealId: json['deal_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      status: MilestoneStatus.fromString(json['status'] as String?),
      proofUrl: json['proof_url'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String dealId;
  final String title;
  final String? description;
  final double amount;
  final int orderIndex;
  final MilestoneStatus status;
  final String? proofUrl;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? createdAt;
}

@immutable
class DealContract {
  const DealContract({
    required this.id,
    required this.dealId,
    this.contractVersion = 1,
    this.legalClauses = const [],
    this.governingLaw =
        'قوانين وإجراءات مركز دبي المالي العالمي (DIFC) / سوق أبوظبي العالمي (ADGM) ودولة الإمارات العربية المتحدة',
    this.disputeMechanism = 'الوساطة والتحكيم المالي المعتمد',
    this.investorSignature,
    this.creatorSignature,
    this.investorSignedAt,
    this.creatorSignedAt,
    this.isFinalized = false,
    this.createdAt,
  });

  factory DealContract.fromJson(Map<String, dynamic> json) {
    final clausesRaw = json['legal_clauses'] as List<dynamic>?;
    final clauses = clausesRaw != null
        ? clausesRaw.map((e) => e.toString()).toList()
        : <String>[];

    return DealContract(
      id: json['id'] as String? ?? '',
      dealId: json['deal_id'] as String? ?? '',
      contractVersion: (json['contract_version'] as num?)?.toInt() ?? 1,
      legalClauses: clauses,
      governingLaw: json['governing_law'] as String? ??
          'قوانين وإجراءات مركز دبي المالي العالمي (DIFC) / سوق أبوظبي العالمي (ADGM) ودولة الإمارات العربية المتحدة',
      disputeMechanism: json['dispute_mechanism'] as String? ??
          'الوساطة والتحكيم المالي المعتمد',
      investorSignature: json['investor_signature'] as String?,
      creatorSignature: json['creator_signature'] as String?,
      investorSignedAt: json['investor_signed_at'] != null
          ? DateTime.tryParse(json['investor_signed_at'] as String)
          : null,
      creatorSignedAt: json['creator_signed_at'] != null
          ? DateTime.tryParse(json['creator_signed_at'] as String)
          : null,
      isFinalized: json['is_finalized'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String dealId;
  final int contractVersion;
  final List<String> legalClauses;
  final String governingLaw;
  final String disputeMechanism;
  final String? investorSignature;
  final String? creatorSignature;
  final DateTime? investorSignedAt;
  final DateTime? creatorSignedAt;
  final bool isFinalized;
  final DateTime? createdAt;
}
