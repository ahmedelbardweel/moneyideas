import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/auth/presentation/controllers/auth_controller.dart';
import 'package:moneyideas/features/company/domain/models/ad_campaign.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';
import 'package:moneyideas/features/company/domain/models/company_member.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/domain/models/offer_lead.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepository(Supabase.instance.client);
});

class CompanyRepository {
  CompanyRepository(this._client);

  final SupabaseClient _client;

  /// Fetches the user's primary company (owner or member).
  Future<Result<Company?>> getMyCompany() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return Result.failure(
          const PermissionFailure(debugMessage: 'المستخدم غير مسجل'),
        );
      }

      final data = await _client
          .from('companies')
          .select()
          .eq('owner_id', userId)
          .maybeSingle();

      if (data == null) {
        // Also check if member of another company
        final memberRow = await _client
            .from('company_members')
            .select('company_id')
            .eq('user_id', userId)
            .maybeSingle();

        if (memberRow != null && memberRow['company_id'] != null) {
          final compData = await _client
              .from('companies')
              .select()
              .eq('id', memberRow['company_id'] as String)
              .maybeSingle();
          if (compData != null) {
            return Result.success(Company.fromJson(compData));
          }
        }
        return const Result.success(null);
      }

      return Result.success(Company.fromJson(data));
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر تحميل بيانات الشركة: $e'),
      );
    }
  }

  /// Registers a new company profile.
  Future<Result<Company>> createCompany(Company company) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return Result.failure(
          const PermissionFailure(debugMessage: 'المستخدم غير مسجل'),
        );
      }

      final payload = company.toJson()..remove('id');
      payload['owner_id'] = userId;

      final res = await _client
          .from('companies')
          .insert(payload)
          .select()
          .single();

      // Ensure user has 'company' role in user_roles
      await _client.from('user_roles').upsert({
        'user_id': userId,
        'role': 'company',
      }, onConflict: 'user_id,role');

      return Result.success(Company.fromJson(res));
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر تسجيل بيانات الشركة: $e'),
      );
    }
  }

  /// Updates existing company profile details.
  Future<Result<Company>> updateCompany(Company company) async {
    try {
      final res = await _client
          .from('companies')
          .update(company.toJson())
          .eq('id', company.id)
          .select()
          .single();

      return Result.success(Company.fromJson(res));
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر تحديث بيانات الشركة: $e'),
      );
    }
  }

  /// Submits trade license or commercial documents for verification.
  Future<Result<void>> submitVerificationDocuments({
    required String companyId,
    required String documentType,
    required String fileUrl,
    required String fileName,
    int? fileSizeBytes,
  }) async {
    try {
      await _client.from('company_documents').insert({
        'company_id': companyId,
        'document_type': documentType,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size_bytes': fileSizeBytes,
      });

      // Update company verification status to pending_review
      await _client.from('companies').update({
        'verification_status': 'pending_review',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', companyId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر رفع مستندات التوثيق: $e'),
      );
    }
  }

  /// Retrieves all commercial offers for this company.
  Future<Result<List<CompanyOffer>>> getCompanyOffers(String companyId) async {
    try {
      final data = await _client
          .from('company_offers')
          .select('''
            *,
            categories (id, title_ar, title_en),
            offer_media (file_url, file_type, display_order)
          ''')
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      final offers = (data as List<dynamic>)
          .map((item) => CompanyOffer.fromJson(item as Map<String, dynamic>))
          .toList();

      return Result.success(offers);
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر جلب عروض الشركة: $e'),
      );
    }
  }

  /// Creates a new commercial offer.
  Future<Result<CompanyOffer>> createOffer(CompanyOffer offer) async {
    try {
      final payload = offer.toJson()..remove('id');
      final res = await _client
          .from('company_offers')
          .insert(payload)
          .select('''
            *,
            categories (id, title_ar, title_en)
          ''')
          .single();

      // If media urls are present, insert into offer_media
      if (offer.mediaUrls.isNotEmpty) {
        final offerId = res['id'] as String;
        final mediaItems = offer.mediaUrls.asMap().entries.map((entry) {
          return {
            'offer_id': offerId,
            'file_url': entry.value,
            'file_type': 'image',
            'display_order': entry.key,
          };
        }).toList();

        await _client.from('offer_media').insert(mediaItems);
      }

      return Result.success(CompanyOffer.fromJson(res));
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر إنشاء العرض: $e'),
      );
    }
  }

  /// Updates an offer's lifecycle status (e.g. paused, in_review, archived).
  Future<Result<void>> updateOfferStatus(String offerId, OfferStatus status) async {
    try {
      await _client.from('company_offers').update({
        'status': status.toDbValue(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', offerId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر تحديث حالة العرض: $e'),
      );
    }
  }

  /// Duplicates an existing offer as a new draft.
  Future<Result<CompanyOffer>> duplicateOffer(String offerId) async {
    try {
      final original = await _client
          .from('company_offers')
          .select('''
            *,
            categories (id, title_ar, title_en),
            offer_media (file_url)
          ''')
          .eq('id', offerId)
          .single();

      final parsed = CompanyOffer.fromJson(original);
      final newOffer = parsed.copyWith(
        id: '',
        title: 'نسخة - ${parsed.title}',
        status: OfferStatus.draft,
        viewsCount: 0,
        detailsOpenedCount: 0,
        leadsCount: 0,
      );

      return await createOffer(newOffer);
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر نسخ العرض: $e'),
      );
    }
  }

  /// Fetches incoming client leads for the company.
  Future<Result<List<OfferLead>>> getCompanyLeads(String companyId) async {
    try {
      final data = await _client
          .from('offer_leads')
          .select('''
            *,
            company_offers!inner (id, title, company_id),
            profiles (full_name, email, phone)
          ''')
          .eq('company_offers.company_id', companyId)
          .order('created_at', ascending: false);

      final leads = (data as List<dynamic>)
          .map((item) => OfferLead.fromJson(item as Map<String, dynamic>))
          .toList();

      return Result.success(leads);
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر جلب طلبات العملاء: $e'),
      );
    }
  }

  /// Updates a lead's progress status or company internal notes.
  Future<Result<void>> updateLeadStatus({
    required String leadId,
    required LeadStatus status,
    String? companyNotes,
  }) async {
    try {
      await _client.from('offer_leads').update({
        'status': status.toDbValue(),
        if (companyNotes != null) 'company_notes': companyNotes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', leadId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر تحديث حالة الطلب: $e'),
      );
    }
  }

  /// Creates a client lead inquiry for an offer (public user action).
  Future<Result<void>> submitLeadInquiry({
    required String offerId,
    required String inquiryMessage,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return Result.failure(
          const PermissionFailure(debugMessage: 'يرجى تسجيل الدخول لتقديم طلب تواصل'),
        );
      }

      await _client.from('offer_leads').insert({
        'offer_id': offerId,
        'user_id': userId,
        'inquiry_message': inquiryMessage,
        'status': 'new',
      });

      // Increment leads_count on company_offers
      await _client.rpc('increment_offer_leads', params: {'p_offer_id': offerId})
          .catchError((_) {
        // Fallback direct update if RPC is not present
        return _client
            .from('company_offers')
            .update({'updated_at': DateTime.now().toIso8601String()})
            .eq('id', offerId);
      });

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر إرسال الطلب: $e'),
      );
    }
  }

  /// Fetches a public offer by ID with full details.
  Future<Result<CompanyOffer>> getPublicOffer(String offerId) async {
    try {
      final data = await _client
          .from('company_offers')
          .select('''
            *,
            companies (id, trade_name, legal_name, logo_url, verification_status, city, official_phone, website_url),
            categories (id, title_ar, title_en),
            offer_media (file_url, file_type, display_order)
          ''')
          .eq('id', offerId)
          .single();

      // Track view asynchronously
      await _client
          .from('company_offers')
          .update({'views_count': (data['views_count'] as int? ?? 0) + 1})
          .eq('id', offerId)
          .catchError((_) {});

      return Result.success(CompanyOffer.fromJson(data));
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر تحميل تفاصيل العرض: $e'),
      );
    }
  }

  /// Fetches a company's public profile and its approved offers.
  Future<Result<Map<String, dynamic>>> getPublicCompanyProfile(String companyId) async {
    try {
      final compData = await _client
          .from('companies')
          .select()
          .eq('id', companyId)
          .single();

      final offersData = await _client
          .from('company_offers')
          .select('''
            *,
            categories (id, title_ar, title_en),
            offer_media (file_url)
          ''')
          .eq('company_id', companyId)
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      final company = Company.fromJson(compData);
      final offers = (offersData as List<dynamic>)
          .map((item) => CompanyOffer.fromJson(item as Map<String, dynamic>))
          .toList();

      return Result.success({
        'company': company,
        'offers': offers,
      });
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر تحميل ملف الشركة العام: $e'),
      );
    }
  }

  /// Team members for collaboration.
  Future<Result<List<CompanyMember>>> getCompanyMembers(String companyId) async {
    try {
      final data = await _client
          .from('company_members')
          .select('''
            *,
            profiles (full_name, email)
          ''')
          .eq('company_id', companyId);

      final members = (data as List<dynamic>)
          .map((item) => CompanyMember.fromJson(item as Map<String, dynamic>))
          .toList();

      return Result.success(members);
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر جلب أعضاء فريق الشركة: $e'),
      );
    }
  }

  /// Invites a team member by email.
  Future<Result<void>> inviteMember({
    required String companyId,
    required String email,
    required CompanyMemberRole role,
  }) async {
    try {
      // Find user profile by email
      final user = await _client
          .from('profiles')
          .select('id')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      if (user == null) {
        return Result.failure(
          const NotFoundFailure(
            debugMessage: 'لم يتم العثور على مستخدم مسجل بهذا البريد الإلكتروني',
          ),
        );
      }

      await _client.from('company_members').insert({
        'company_id': companyId,
        'user_id': user['id'] as String,
        'role': role.toDbValue(),
      });

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر إضافة العضو: $e'),
      );
    }
  }

  /// Ad campaigns (behind feature flag).
  Future<Result<List<AdCampaign>>> getAdCampaigns(String companyId) async {
    try {
      final data = await _client
          .from('ad_campaigns')
          .select('''
            *,
            company_offers (title)
          ''')
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      final campaigns = (data as List<dynamic>)
          .map((item) => AdCampaign.fromJson(item as Map<String, dynamic>))
          .toList();

      return Result.success(campaigns);
    } catch (e) {
      return Result.failure(
        Failure.server('تعذر جلب الحملات الإعلانية: $e'),
      );
    }
  }
}
