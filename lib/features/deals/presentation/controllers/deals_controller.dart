import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/deals/data/repositories/deals_repository.dart';
import 'package:moneyideas/features/deals/domain/models/deal_models.dart';

final dealsRepositoryProvider = Provider<DealsRepository>((ref) {
  return const DealsRepository();
});

/// Live deals list for current user.
final myDealsListProvider =
    FutureProvider.family<List<Deal>, DealStatus?>((ref, statusFilter) async {
  final repo = ref.watch(dealsRepositoryProvider);
  final res = await repo.getDeals(statusFilter: statusFilter);
  return res.valueOrNull ?? const [];
});

/// Single deal details.
final dealDetailsProvider =
    FutureProvider.family<Deal?, String>((ref, dealId) async {
  final repo = ref.watch(dealsRepositoryProvider);
  final res = await repo.getDealDetails(dealId);
  return res.valueOrNull;
});

/// Deal milestones list.
final dealMilestonesProvider =
    FutureProvider.family<List<DealMilestone>, String>((ref, dealId) async {
  final repo = ref.watch(dealsRepositoryProvider);
  final res = await repo.getMilestones(dealId);
  return res.valueOrNull ?? const [];
});

/// Deal digital contract.
final dealContractProvider =
    FutureProvider.family<DealContract?, String>((ref, dealId) async {
  final repo = ref.watch(dealsRepositoryProvider);
  final res = await repo.getContract(dealId);
  return res.valueOrNull;
});

/// Deals action controller.
final dealsActionControllerProvider =
    Provider<DealsActionController>((ref) => DealsActionController(ref));

class DealsActionController {
  DealsActionController(this._ref);

  final Ref _ref;

  DealsRepository get _repo => _ref.read(dealsRepositoryProvider);

  Future<Result<Deal>> createDeal({
    String? projectId,
    required String investorId,
    required String title,
    required DealType dealType,
    required double targetAmount,
    double? equityPercentage,
    String? termsSummary,
    List<Map<String, dynamic>>? initialMilestones,
  }) async {
    final res = await _repo.createDeal(
      projectId: projectId,
      investorId: investorId,
      title: title,
      dealType: dealType,
      targetAmount: targetAmount,
      equityPercentage: equityPercentage,
      termsSummary: termsSummary,
      initialMilestones: initialMilestones,
    );

    if (res.isSuccess) {
      _ref.invalidate(myDealsListProvider);
    }
    return res;
  }

  Future<Result<void>> signContract({
    required String dealId,
    required String signatureText,
    required bool isInvestor,
  }) async {
    final res = await _repo.signContract(
      dealId: dealId,
      signatureText: signatureText,
      isInvestor: isInvestor,
    );

    if (res.isSuccess) {
      _ref.invalidate(dealDetailsProvider(dealId));
      _ref.invalidate(dealContractProvider(dealId));
      _ref.invalidate(myDealsListProvider);
    }
    return res;
  }

  Future<Result<void>> updateMilestoneStatus({
    required String dealId,
    required String milestoneId,
    required MilestoneStatus status,
    String? proofUrl,
  }) async {
    final res = await _repo.updateMilestoneStatus(
      milestoneId: milestoneId,
      status: status,
      proofUrl: proofUrl,
    );

    if (res.isSuccess) {
      _ref.invalidate(dealMilestonesProvider(dealId));
      _ref.invalidate(dealDetailsProvider(dealId));
      _ref.invalidate(myDealsListProvider);
    }
    return res;
  }

  Future<Result<void>> updateEscrowStatus({
    required String dealId,
    required EscrowStatus escrowStatus,
    String? escrowAccountId,
  }) async {
    final res = await _repo.updateEscrowStatus(
      dealId: dealId,
      escrowStatus: escrowStatus,
      escrowAccountId: escrowAccountId,
    );

    if (res.isSuccess) {
      _ref.invalidate(dealDetailsProvider(dealId));
      _ref.invalidate(myDealsListProvider);
    }
    return res;
  }
}
