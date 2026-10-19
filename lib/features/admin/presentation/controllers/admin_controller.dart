import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/admin/data/repositories/admin_repository.dart';
import 'package:moneyideas/features/admin/domain/models/admin_models.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return const AdminRepository();
});

/// Real-time live KPIs for platform governance.
final adminKpisProvider = FutureProvider<AdminKpiStats>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final res = await repo.getAdminKpis();
  return res.valueOrNull ?? const AdminKpiStats();
});

/// Companies list filtered by verification status ('pending_review', 'verified', etc.)
final adminCompaniesProvider =
    FutureProvider.family<List<Company>, String?>((ref, statusFilter) async {
  final repo = ref.watch(adminRepositoryProvider);
  final res = await repo.getCompanies(statusFilter: statusFilter);
  return res.valueOrNull ?? const [];
});

/// Commercial offers list filtered by review status ('in_review', 'approved', etc.)
final adminOffersProvider =
    FutureProvider.family<List<CompanyOffer>, String?>((ref, statusFilter) async {
  final repo = ref.watch(adminRepositoryProvider);
  final res = await repo.getOffers(statusFilter: statusFilter);
  return res.valueOrNull ?? const [];
});

/// Users governance provider.
final adminUsersProvider =
    FutureProvider.family<List<AdminUserItem>, String?>((ref, searchQuery) async {
  final repo = ref.watch(adminRepositoryProvider);
  final res = await repo.getAllUsers(searchQuery: searchQuery);
  return res.valueOrNull ?? const [];
});

/// Reports list provider.
final adminReportsProvider = FutureProvider<List<AdminReportItem>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final res = await repo.getReports();
  return res.valueOrNull ?? const [];
});

/// Action controller for admin triggers.
final adminActionControllerProvider =
    Provider<AdminActionController>((ref) => AdminActionController(ref));

class AdminActionController {
  AdminActionController(this._ref);

  final Ref _ref;

  AdminRepository get _repo => _ref.read(adminRepositoryProvider);

  Future<Result<void>> verifyCompany({
    required String companyId,
    required CompanyVerificationStatus status,
    String? notes,
  }) async {
    final res = await _repo.updateCompanyVerification(
      companyId: companyId,
      status: status,
      notes: notes,
    );
    if (res.isSuccess) {
      _ref.invalidate(adminKpisProvider);
      _ref.invalidate(adminCompaniesProvider);
    }
    return res;
  }

  Future<Result<void>> reviewOffer({
    required String offerId,
    required OfferStatus status,
    String? notes,
  }) async {
    final res = await _repo.updateOfferReview(
      offerId: offerId,
      status: status,
      notes: notes,
    );
    if (res.isSuccess) {
      _ref.invalidate(adminKpisProvider);
      _ref.invalidate(adminOffersProvider);
    }
    return res;
  }

  Future<Result<void>> toggleUserBan({
    required String userId,
    required bool isBanned,
  }) async {
    final res = await _repo.toggleUserBan(userId: userId, isBanned: isBanned);
    if (res.isSuccess) {
      _ref.invalidate(adminUsersProvider);
    }
    return res;
  }

  Future<Result<void>> toggleUserRole({
    required String userId,
    required String role,
    required bool shouldHaveRole,
  }) async {
    final res = await _repo.toggleUserRole(
      userId: userId,
      role: role,
      shouldHaveRole: shouldHaveRole,
    );
    if (res.isSuccess) {
      _ref.invalidate(adminUsersProvider);
    }
    return res;
  }

  Future<Result<void>> resolveReport({
    required String reportId,
    required String status,
    String? adminNotes,
  }) async {
    final res = await _repo.resolveReport(
      reportId: reportId,
      status: status,
      adminNotes: adminNotes,
    );
    if (res.isSuccess) {
      _ref.invalidate(adminKpisProvider);
      _ref.invalidate(adminReportsProvider);
    }
    return res;
  }
}
