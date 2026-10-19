import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/network/data/repositories/network_repository.dart';
import 'package:moneyideas/features/network/domain/models/network_models.dart';

final networkRepositoryProvider = Provider<NetworkRepository>((ref) {
  return const NetworkRepository();
});

/// Filter state for projects directory.
class ProjectFilterState {
  const ProjectFilterState({
    this.type,
    this.stage,
    this.categoryId,
    this.helpNeeded,
    this.searchQuery,
  });

  final ProjectType? type;
  final ProjectStage? stage;
  final String? categoryId;
  final String? helpNeeded;
  final String? searchQuery;

  ProjectFilterState copyWith({
    ProjectType? Function()? type,
    ProjectStage? Function()? stage,
    String? Function()? categoryId,
    String? Function()? helpNeeded,
    String? Function()? searchQuery,
  }) {
    return ProjectFilterState(
      type: type != null ? type() : this.type,
      stage: stage != null ? stage() : this.stage,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      helpNeeded: helpNeeded != null ? helpNeeded() : this.helpNeeded,
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
    );
  }
}

class ProjectFilterController extends Notifier<ProjectFilterState> {
  @override
  ProjectFilterState build() => const ProjectFilterState();

  void update(ProjectFilterState Function(ProjectFilterState current) updater) {
    state = updater(state);
  }
}

final projectFilterProvider =
    NotifierProvider<ProjectFilterController, ProjectFilterState>(
  ProjectFilterController.new,
);

/// Live projects showcase provider.
final projectsListProvider = FutureProvider<List<Project>>((ref) async {
  final repo = ref.watch(networkRepositoryProvider);
  final filter = ref.watch(projectFilterProvider);

  final res = await repo.getProjects(
    type: filter.type,
    stage: filter.stage,
    categoryId: filter.categoryId,
    helpNeeded: filter.helpNeeded,
    searchQuery: filter.searchQuery,
  );
  return res.valueOrNull ?? const [];
});

/// Live investors directory provider.
final investorsListProvider =
    FutureProvider.family<List<InvestorProfile>, String?>((ref, sector) async {
  final repo = ref.watch(networkRepositoryProvider);
  final res = await repo.getInvestors(sector: sector);
  return res.valueOrNull ?? const [];
});

/// Authenticated user's published projects.
final myProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final repo = ref.watch(networkRepositoryProvider);
  final res = await repo.getMyProjects();
  return res.valueOrNull ?? const [];
});

/// Authenticated investor's private study watchlist.
final investorWatchlistProvider =
    FutureProvider<List<InvestorWatchlistItem>>((ref) async {
  final repo = ref.watch(networkRepositoryProvider);
  final res = await repo.getWatchlist();
  return res.valueOrNull ?? const [];
});

/// Authenticated user's incoming contact requests.
final incomingContactRequestsProvider =
    FutureProvider<List<ContactRequest>>((ref) async {
  final repo = ref.watch(networkRepositoryProvider);
  final res = await repo.getIncomingContactRequests();
  return res.valueOrNull ?? const [];
});

/// Authenticated user's outgoing contact requests.
final outgoingContactRequestsProvider =
    FutureProvider<List<ContactRequest>>((ref) async {
  final repo = ref.watch(networkRepositoryProvider);
  final res = await repo.getOutgoingContactRequests();
  return res.valueOrNull ?? const [];
});

/// Pending incoming requests count badge.
final pendingRequestsCountProvider = Provider<int>((ref) {
  final requests =
      ref.watch(incomingContactRequestsProvider).asData?.value ?? [];
  return requests
      .where((r) => r.status == ContactRequestStatus.pending)
      .length;
});

/// Authenticated user's own investor profile.
final myInvestorProfileProvider =
    FutureProvider<InvestorProfile?>((ref) async {
  final repo = ref.watch(networkRepositoryProvider);
  final res = await repo.getMyInvestorProfile();
  return res.valueOrNull;
});

/// Action controller for mutating network domain entities.
final networkActionControllerProvider =
    Provider<NetworkActionController>((ref) => NetworkActionController(ref));

class NetworkActionController {
  NetworkActionController(this._ref);

  final Ref _ref;

  NetworkRepository get _repo => _ref.read(networkRepositoryProvider);

  Future<Result<String>> createProject(Project project) async {
    final res = await _repo.createProject(project);
    if (res.isSuccess) {
      _ref.invalidate(projectsListProvider);
      _ref.invalidate(myProjectsProvider);
    }
    return res;
  }

  Future<Result<void>> toggleProjectPublish(String projectId, bool isPublished) async {
    final res = await _repo.toggleProjectPublish(projectId, isPublished);
    if (res.isSuccess) {
      _ref.invalidate(projectsListProvider);
      _ref.invalidate(myProjectsProvider);
    }
    return res;
  }

  Future<Result<void>> upsertInvestorProfile(InvestorProfile profile) async {
    final res = await _repo.upsertInvestorProfile(profile);
    if (res.isSuccess) {
      _ref.invalidate(myInvestorProfileProvider);
      _ref.invalidate(investorsListProvider);
    }
    return res;
  }

  Future<Result<bool>> toggleWatchlist({
    required String projectId,
    String? notes,
  }) async {
    final res = await _repo.toggleWatchlist(projectId: projectId, notes: notes);
    if (res.isSuccess) {
      _ref.invalidate(investorWatchlistProvider);
    }
    return res;
  }

  Future<Result<void>> updateWatchlistNotes({
    required String projectId,
    required String notes,
  }) async {
    final res = await _repo.updateWatchlistNotes(
      projectId: projectId,
      notes: notes,
    );
    if (res.isSuccess) {
      _ref.invalidate(investorWatchlistProvider);
    }
    return res;
  }

  Future<Result<void>> sendContactRequest({
    required String receiverId,
    String? projectId,
    required String reason,
    required String introductionMessage,
  }) async {
    final res = await _repo.sendContactRequest(
      receiverId: receiverId,
      projectId: projectId,
      reason: reason,
      introductionMessage: introductionMessage,
    );
    if (res.isSuccess) {
      _ref.invalidate(outgoingContactRequestsProvider);
    }
    return res;
  }

  Future<Result<void>> respondToContactRequest({
    required String requestId,
    required ContactRequestStatus status,
  }) async {
    final res = await _repo.respondToContactRequest(
      requestId: requestId,
      status: status,
    );
    if (res.isSuccess) {
      _ref.invalidate(incomingContactRequestsProvider);
      _ref.invalidate(outgoingContactRequestsProvider);
    }
    return res;
  }
}
