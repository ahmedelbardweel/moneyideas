import 'package:flutter/foundation.dart';

/// Status of an inquiry lead for an offer.
enum LeadStatus {
  newLead,
  contacted,
  inNegotiation,
  closed,
  spam;

  static LeadStatus fromString(String? val) {
    return switch (val) {
      'contacted' => LeadStatus.contacted,
      'in_negotiation' => LeadStatus.inNegotiation,
      'closed' => LeadStatus.closed,
      'spam' => LeadStatus.spam,
      _ => LeadStatus.newLead,
    };
  }

  String toDbValue() {
    return switch (this) {
      LeadStatus.newLead => 'new',
      LeadStatus.contacted => 'contacted',
      LeadStatus.inNegotiation => 'in_negotiation',
      LeadStatus.closed => 'closed',
      LeadStatus.spam => 'spam',
    };
  }

  String get labelAr => switch (this) {
        LeadStatus.newLead => 'جديد',
        LeadStatus.contacted => 'تم التواصل',
        LeadStatus.inNegotiation => 'قيد التفاوض',
        LeadStatus.closed => 'مغلق بنجاح',
        LeadStatus.spam => 'سبام / احتيال',
      };
}

/// Inquiry lead domain entity mapped to public.offer_leads.
@immutable
class OfferLead {
  const OfferLead({
    required this.id,
    required this.offerId,
    required this.userId,
    required this.inquiryMessage,
    this.status = LeadStatus.newLead,
    this.offerTitle,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.companyNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory OfferLead.fromJson(Map<String, dynamic> json) {
    final offerObj = json['company_offers'] as Map<String, dynamic>?;
    final userObj = json['profiles'] as Map<String, dynamic>?;

    return OfferLead(
      id: json['id'] as String,
      offerId: json['offer_id'] as String,
      userId: json['user_id'] as String,
      inquiryMessage: json['inquiry_message'] as String? ?? '',
      status: LeadStatus.fromString(json['status'] as String?),
      offerTitle: offerObj?['title'] as String?,
      userName: userObj?['full_name'] as String?,
      userEmail: userObj?['email'] as String?,
      userPhone: userObj?['phone'] as String?,
      companyNotes: json['company_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String offerId;
  final String userId;
  final String inquiryMessage;
  final LeadStatus status;
  final String? offerTitle;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? companyNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offer_id': offerId,
      'user_id': userId,
      'inquiry_message': inquiryMessage,
      'status': status.toDbValue(),
      'company_notes': companyNotes,
    };
  }

  OfferLead copyWith({
    String? id,
    String? offerId,
    String? userId,
    String? inquiryMessage,
    LeadStatus? status,
    String? offerTitle,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? companyNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfferLead(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      userId: userId ?? this.userId,
      inquiryMessage: inquiryMessage ?? this.inquiryMessage,
      status: status ?? this.status,
      offerTitle: offerTitle ?? this.offerTitle,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      companyNotes: companyNotes ?? this.companyNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
