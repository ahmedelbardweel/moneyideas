import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/account/data/repositories/account_repository.dart';
import 'package:moneyideas/features/account/domain/models/user_profile.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return const AccountRepository();
});

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);

final isAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).asData?.value;
  return profile?.roles.contains('admin') ?? false;
});

/// Controller for switching active role view in real time.
class ActiveRoleNotifier extends Notifier<String> {
  @override
  String build() {
    final profile = ref.watch(userProfileProvider).asData?.value;
    final roles = profile?.roles ?? const ['individual'];
    return roles.firstOrNull ?? 'individual';
  }

  void setRole(String role) {
    state = role;
  }
}

/// Currently active role view. Defaults to the primary role in the user profile.
final activeRoleProvider =
    NotifierProvider<ActiveRoleNotifier, String>(ActiveRoleNotifier.new);

/// Controller for the active BottomNavigationBar tab index (0..4).
class RoleNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final roleNavIndexProvider =
    NotifierProvider<RoleNavIndexNotifier, int>(RoleNavIndexNotifier.new);

class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final repo = ref.watch(accountRepositoryProvider);
    final result = await repo.getUserProfile();
    return result.valueOrNull;
  }

  Future<Result<void>> updateInfo({
    required String fullName,
    required String city,
    String? phone,
  }) async {
    final repo = ref.read(accountRepositoryProvider);
    final res = await repo.updateProfile(
      fullName: fullName,
      city: city,
      phone: phone,
    );

    if (res.isSuccess) {
      ref.invalidateSelf();
    }
    return res;
  }

  Future<Result<void>> updateInvestmentPreferences({
    required double budget,
    required bool hasNoCapital,
    required int weeklyHours,
    required String experience,
    required String risk,
  }) async {
    final repo = ref.read(accountRepositoryProvider);
    final res = await repo.updatePreferences(
      budget: budget,
      hasNoCapital: hasNoCapital,
      weeklyHours: weeklyHours,
      experience: experience,
      risk: risk,
    );

    if (res.isSuccess) {
      ref.invalidateSelf();
    }
    return res;
  }

  Future<Result<void>> updateActiveRoles(List<String> roles) async {
    final repo = ref.read(accountRepositoryProvider);
    final res = await repo.updateRoles(roles);

    if (res.isSuccess) {
      ref.invalidateSelf();
    }
    return res;
  }
}
