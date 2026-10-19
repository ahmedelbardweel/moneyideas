import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/admin/domain/models/admin_models.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepository {
  const AdminRepository();

  SupabaseClient get _client => Supabase.instance.client;

  /// Fetches system-wide KPI summary metrics for the Admin dashboard.
  Future<Result<AdminKpiStats>> getAdminKpis() async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      final pendingCompaniesRes = await _client
          .from('companies')
          .select('id')
          .eq('verification_status', 'pending_review');
      final pendingOffersRes = await _client
          .from('company_offers')
          .select('id')
          .eq('status', 'in_review');
      final pendingProjectsRes = await _client
          .from('projects')
          .select('id')
          .eq('regulatory_approval_status', 'pending_review');
      final totalUsersRes = await _client.from('profiles').select('id');
      final pendingReportsRes = await _client
          .from('reports')
          .select('id')
          .eq('status', 'pending');
      final activeCompaniesRes = await _client
          .from('companies')
          .select('id')
          .eq('verification_status', 'verified');
      final activeOffersRes = await _client
          .from('company_offers')
          .select('id')
          .eq('status', 'approved');

      return Result.success(
        AdminKpiStats(
          pendingCompaniesCount: (pendingCompaniesRes as List).length,
          pendingOffersCount: (pendingOffersRes as List).length,
          pendingProjectsCount: (pendingProjectsRes as List).length,
          totalUsersCount: (totalUsersRes as List).length,
          pendingReportsCount: (pendingReportsRes as List).length,
          activeCompaniesCount: (activeCompaniesRes as List).length,
          activeOffersCount: (activeOffersRes as List).length,
        ),
      );
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches all companies or filtered by verification status.
  Future<Result<List<Company>>> getCompanies({String? statusFilter}) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      var query = _client.from('companies').select('*');
      if (statusFilter != null && statusFilter.isNotEmpty) {
        query = query.eq('verification_status', statusFilter);
      }

      final res = await query.order('created_at', ascending: false);
      final list = (res as List<dynamic>)
          .map((json) => Company.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Updates the verification status of a company with administrative review notes.
  Future<Result<void>> updateCompanyVerification({
    required String companyId,
    required CompanyVerificationStatus status,
    String? notes,
  }) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      await _client.from('companies').update({
        'verification_status': status.toDbValue(),
        'verification_notes': notes,
        'verified_at': status == CompanyVerificationStatus.verified
            ? DateTime.now().toIso8601String()
            : null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', companyId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches offers awaiting review or all offers.
  Future<Result<List<CompanyOffer>>> getOffers({String? statusFilter}) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      var query = _client.from('company_offers').select('*');
      if (statusFilter != null && statusFilter.isNotEmpty) {
        query = query.eq('status', statusFilter);
      }

      final res = await query.order('created_at', ascending: false);
      final list = (res as List<dynamic>)
          .map((json) => CompanyOffer.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Approves, requests changes, or rejects an offer with audit notes.
  Future<Result<void>> updateOfferReview({
    required String offerId,
    required OfferStatus status,
    String? notes,
  }) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      await _client.from('company_offers').update({
        'status': status.toDbValue(),
        'admin_review_notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', offerId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches all users with their assigned roles and ban status.
  Future<Result<List<AdminUserItem>>> getAllUsers({String? searchQuery}) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      var query = _client.from('profiles').select('*, user_roles(role, is_active)');
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('full_name', '%$searchQuery%');
      }

      final res = await query.order('created_at', ascending: false);
      final list = (res as List<dynamic>).map((json) {
        final map = json as Map<String, dynamic>;
        final rolesData = map['user_roles'] as List<dynamic>? ?? [];
        final roles = rolesData
            .where((r) => (r as Map<String, dynamic>)['is_active'] == true)
            .map((r) => (r as Map<String, dynamic>)['role'] as String)
            .toList();

        return AdminUserItem(
          id: map['id'] as String? ?? '',
          fullName: map['full_name'] as String? ?? 'مستخدم',
          email: '',
          roles: roles,
          isBanned: map['is_banned'] as bool? ?? false,
          isVerified: map['is_verified'] as bool? ?? false,
          city: map['city'] as String? ?? 'Dubai',
          createdAt: map['created_at'] != null
              ? DateTime.tryParse(map['created_at'] as String)
              : null,
        );
      }).toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Toggles ban status for a user.
  Future<Result<void>> toggleUserBan({
    required String userId,
    required bool isBanned,
  }) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      await _client.from('profiles').update({
        'is_banned': isBanned,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Adds or removes a role for a user.
  Future<Result<void>> toggleUserRole({
    required String userId,
    required String role,
    required bool shouldHaveRole,
  }) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      if (shouldHaveRole) {
        await _client.from('user_roles').upsert(
          {
            'user_id': userId,
            'role': role,
            'is_active': true,
          },
          onConflict: 'user_id,role',
        );
      } else {
        await _client
            .from('user_roles')
            .delete()
            .eq('user_id', userId)
            .eq('role', role);
      }

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches all moderation and fraud reports.
  Future<Result<List<AdminReportItem>>> getReports() async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      final res = await _client
          .from('reports')
          .select('*')
          .order('created_at', ascending: false);

      final list = (res as List<dynamic>).map((json) {
        final map = json as Map<String, dynamic>;
        return AdminReportItem(
          id: map['id'] as String? ?? '',
          reporterId: map['reporter_id'] as String? ?? '',
          reportedEntityType: map['reported_entity_type'] as String? ?? '',
          reportedEntityId: map['reported_entity_id'] as String? ?? '',
          reason: map['reason'] as String? ?? '',
          details: map['details'] as String?,
          status: map['status'] as String? ?? 'pending',
          adminNotes: map['admin_notes'] as String?,
          createdAt: map['created_at'] != null
              ? DateTime.tryParse(map['created_at'] as String)
              : null,
        );
      }).toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Resolves an administrative report with action status and notes.
  Future<Result<void>> resolveReport({
    required String reportId,
    required String status,
    String? adminNotes,
  }) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      await _client.from('reports').update({
        'status': status,
        'admin_notes': adminNotes,
        'resolved_at': DateTime.now().toIso8601String(),
        'resolved_by': _client.auth.currentUser?.id,
      }).eq('id', reportId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }
}
