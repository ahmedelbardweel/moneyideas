import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/company/data/repositories/company_repository.dart';
import 'package:moneyideas/features/company/domain/models/ad_campaign.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';
import 'package:moneyideas/features/company/domain/models/company_member.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/domain/models/offer_lead.dart';

/// Provider for the user's primary company profile.
final myCompanyProvider =
    AsyncNotifierProvider<MyCompanyNotifier, Company?>(MyCompanyNotifier.new);

class MyCompanyNotifier extends AsyncNotifier<Company?> {
  @override
  FutureOr<Company?> build() async {
    final repo = ref.watch(companyRepositoryProvider);
    final result = await repo.getMyCompany();
    return result.valueOrNull;
  }

  Future<Result<Company>> createCompany(Company company) async {
    final repo = ref.read(companyRepositoryProvider);
    final res = await repo.createCompany(company);
    if (res.isSuccess) {
      state = AsyncData(res.valueOrNull);
    }
    return res;
  }

  Future<Result<Company>> updateCompany(Company company) async {
    final repo = ref.read(companyRepositoryProvider);
    final res = await repo.updateCompany(company);
    if (res.isSuccess) {
      state = AsyncData(res.valueOrNull);
    }
    return res;
  }

  Future<Result<void>> submitVerification({
    required String documentType,
    required String fileUrl,
    required String fileName,
  }) async {
    final company = state.asData?.value;
    if (company == null) {
      return Result.failure(
        const NotFoundFailure(debugMessage: 'لم يتم العثور على الشركة'),
      );
    }

    final repo = ref.read(companyRepositoryProvider);
    final res = await repo.submitVerificationDocuments(
      companyId: company.id,
      documentType: documentType,
      fileUrl: fileUrl,
      fileName: fileName,
    );

    if (res.isSuccess) {
      ref.invalidateSelf();
    }
    return res;
  }
}

/// Provider for company offers.
final companyOffersProvider =
    AsyncNotifierProvider<CompanyOffersNotifier, List<CompanyOffer>>(
  CompanyOffersNotifier.new,
);

class CompanyOffersNotifier extends AsyncNotifier<List<CompanyOffer>> {
  @override
  FutureOr<List<CompanyOffer>> build() async {
    final company = await ref.watch(myCompanyProvider.future);
    if (company == null) return [];

    final repo = ref.watch(companyRepositoryProvider);
    final result = await repo.getCompanyOffers(company.id);
    return result.valueOrNull ?? [];
  }

  Future<Result<CompanyOffer>> createOffer(CompanyOffer offer) async {
    final repo = ref.read(companyRepositoryProvider);
    final res = await repo.createOffer(offer);
    if (res.isSuccess) {
      ref.invalidateSelf();
    }
    return res;
  }

  Future<Result<void>> updateStatus(String offerId, OfferStatus status) async {
    final repo = ref.read(companyRepositoryProvider);
    final res = await repo.updateOfferStatus(offerId, status);
    if (res.isSuccess) {
      ref.invalidateSelf();
    }
    return res;
  }

  Future<Result<CompanyOffer>> duplicateOffer(String offerId) async {
    final repo = ref.read(companyRepositoryProvider);
    final res = await repo.duplicateOffer(offerId);
    if (res.isSuccess) {
      ref.invalidateSelf();
    }
    return res;
  }
}

/// Provider for company leads.
final companyLeadsProvider =
    AsyncNotifierProvider<CompanyLeadsNotifier, List<OfferLead>>(
  CompanyLeadsNotifier.new,
);

class CompanyLeadsNotifier extends AsyncNotifier<List<OfferLead>> {
  @override
  FutureOr<List<OfferLead>> build() async {
    final company = await ref.watch(myCompanyProvider.future);
    if (company == null) return [];

    final repo = ref.watch(companyRepositoryProvider);
    final result = await repo.getCompanyLeads(company.id);
    return result.valueOrNull ?? [];
  }

  Future<Result<void>> updateLeadStatus({
    required String leadId,
    required LeadStatus status,
    String? companyNotes,
  }) async {
    final repo = ref.read(companyRepositoryProvider);
    final res = await repo.updateLeadStatus(
      leadId: leadId,
      status: status,
      companyNotes: companyNotes,
    );
    if (res.isSuccess) {
      ref.invalidateSelf();
    }
    return res;
  }
}

/// Provider for company team members.
final companyMembersProvider =
    FutureProvider.autoDispose<List<CompanyMember>>((ref) async {
  final company = await ref.watch(myCompanyProvider.future);
  if (company == null) return [];
  final repo = ref.watch(companyRepositoryProvider);
  final result = await repo.getCompanyMembers(company.id);
  return result.valueOrNull ?? [];
});

/// Provider for company campaigns (feature-flagged).
final companyCampaignsProvider =
    FutureProvider.autoDispose<List<AdCampaign>>((ref) async {
  final company = await ref.watch(myCompanyProvider.future);
  if (company == null) return [];
  final repo = ref.watch(companyRepositoryProvider);
  final result = await repo.getAdCampaigns(company.id);
  return result.valueOrNull ?? [];
});

/// Aggregated stats computed from offers and leads.
final companyStatsProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  final offers = ref.watch(companyOffersProvider).asData?.value ?? [];
  final leads = ref.watch(companyLeadsProvider).asData?.value ?? [];

  final totalViews =
      offers.fold<int>(0, (sum, o) => sum + o.viewsCount);
  final totalOpens =
      offers.fold<int>(0, (sum, o) => sum + o.detailsOpenedCount);
  final totalLeads = leads.length;
  final activeOffers =
      offers.where((o) => o.status == OfferStatus.approved).length;

  final conversionRate =
      totalViews > 0 ? ((totalLeads / totalViews) * 100).toStringAsFixed(1) : '0.0';

  return {
    'total_views': totalViews,
    'total_opens': totalOpens,
    'total_leads': totalLeads,
    'active_offers': activeOffers,
    'conversion_rate': conversionRate,
  };
});
