import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/features/discover/data/repositories/opportunity_repository.dart';
import 'package:moneyideas/features/discover/domain/models/category_model.dart';
import 'package:moneyideas/features/discover/domain/models/opportunity.dart';
import 'package:moneyideas/features/discover/domain/models/opportunity_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return const OpportunityRepository();
});

class OpportunityFilterController extends Notifier<OpportunityFilter> {
  @override
  OpportunityFilter build() {
    return const OpportunityFilter();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String? categoryId) {
    if (state.categoryId == categoryId) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  void setCapitalRange({double? min, double? max}) {
    state = state.copyWith(minCapital: min, maxCapital: max);
  }

  void setRiskLevel(String? risk) {
    state = state.copyWith(riskLevel: risk);
  }

  void toggleOnlyVerified({required bool value}) {
    state = state.copyWith(isOnlyVerified: value);
  }

  void resetFilters() {
    state = const OpportunityFilter();
  }
}

final opportunityFilterProvider =
    NotifierProvider<OpportunityFilterController, OpportunityFilter>(
      OpportunityFilterController.new,
    );

final opportunitiesListProvider = FutureProvider<List<Opportunity>>((
  ref,
) async {
  final repository = ref.watch(opportunityRepositoryProvider);
  final filter = ref.watch(opportunityFilterProvider);

  final result = await repository.getOpportunities(filter: filter);
  return result.when(
    success: (list) => list,
    failure: (error) => throw Exception(error.debugMessage ?? 'فشل في تحميل الفرص'),
  );
});

final categoriesListProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.watch(opportunityRepositoryProvider);
  final result = await repository.getCategories();
  return result.when(
    success: (list) => list,
    failure: (_) => const [],
  );
});

/// Comparison slot controller (holds up to 3 live opportunities for Screen 26).
class CompareListController extends Notifier<List<Opportunity>> {
  @override
  List<Opportunity> build() => const [];

  bool toggleCompare(Opportunity opp) {
    if (state.any((item) => item.id == opp.id)) {
      state = state.where((item) => item.id != opp.id).toList();
      return false;
    } else {
      if (state.length >= 3) {
        return false; // Limit to 3 items
      }
      state = [...state, opp];
      return true;
    }
  }

  bool isInCompare(String id) => state.any((item) => item.id == id);

  void clearCompare() => state = const [];
}

final compareListProvider =
    NotifierProvider<CompareListController, List<Opportunity>>(
      CompareListController.new,
    );

/// Saved Bookmarks controller (Screen 27) connected directly to Supabase.
class SavedOpportunitiesController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    unawaited(_loadSaved());
    return const {};
  }

  Future<void> _loadSaved() async {
    final repo = ref.read(opportunityRepositoryProvider);
    final res = await repo.getSavedOpportunityIds();
    res.when(
      success: (ids) => state = ids,
      failure: (_) {},
    );
  }

  void toggleSave(String opportunityId) {
    final isSaved = state.contains(opportunityId);
    final updated = Set<String>.from(state);
    if (isSaved) {
      updated.remove(opportunityId);
    } else {
      updated.add(opportunityId);
    }
    state = updated;

    final repo = ref.read(opportunityRepositoryProvider);
    unawaited(
      repo.toggleSaveOpportunity(
        opportunityId,
        isCurrentlySaved: isSaved,
      ),
    );
  }

  bool isSaved(String opportunityId) => state.contains(opportunityId);
}

final savedOpportunitiesProvider =
    NotifierProvider<SavedOpportunitiesController, Set<String>>(
      SavedOpportunitiesController.new,
    );

/// Dynamic featured commercial offer from Supabase.
final featuredOfferProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  if (!Env.isConfigured) return null;
  try {
    final res = await Supabase.instance.client
        .from('company_offers')
        .select('*, companies(trade_name)')
        .eq('status', 'approved')
        .limit(1)
        .maybeSingle();
    return res;
  } on Exception {
    return null;
  }
});
