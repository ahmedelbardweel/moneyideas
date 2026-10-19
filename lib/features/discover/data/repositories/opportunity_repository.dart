import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/discover/domain/models/category_model.dart';
import 'package:moneyideas/features/discover/domain/models/opportunity.dart';
import 'package:moneyideas/features/discover/domain/models/opportunity_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository handling live opportunities, categories, saved bookmarks, and tasks directly from Supabase.
/// Zero mock data: All content is dynamically managed by Admin and stored in PostgreSQL.
class OpportunityRepository {
  const OpportunityRepository();

  SupabaseClient get _client => Supabase.instance.client;

  /// Fetches opportunities matching filter criteria directly from Supabase.
  Future<Result<List<Opportunity>>> getOpportunities({
    OpportunityFilter filter = const OpportunityFilter(),
  }) async {
    if (!Env.isConfigured) {
      return const Result.failure(
        ServerFailure(
          debugMessage:
              'Supabase غير متصل. يرجى تزويد بيانات الربط في env/dev.json للاتصال بقاعدة البيانات المباشرة.',
        ),
      );
    }

    try {
      var query = _client.from('opportunities').select('''
            *,
            categories (title_ar, title_en, icon_name),
            opportunity_costs (*),
            opportunity_risks (*),
            opportunity_sources (*, data_sources (*)),
            opportunity_steps (*)
          ''').eq('is_published', true);

      if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
        final q = filter.searchQuery!.trim();
        query = query.or('title_ar.ilike.%$q%,title_en.ilike.%$q%,summary_ar.ilike.%$q%');
      }

      if (filter.categoryId != null) {
        query = query.eq('category_id', filter.categoryId!);
      }
      if (filter.riskLevel != null) {
        query = query.eq('risk_level', filter.riskLevel!);
      }
      if (filter.minCapital != null) {
        query = query.gte('min_budget', filter.minCapital!);
      }
      if (filter.maxCapital != null) {
        query = query.lte('min_budget', filter.maxCapital!);
      }
      if (filter.isOnlyVerified) {
        query = query.eq('is_verified', true);
      }

      final response = await query.order('created_at', ascending: false);
      final items = (response as List<dynamic>)
          .map((json) => Opportunity.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } on Exception catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches a single opportunity by its unique ID with all child relations from Supabase.
  Future<Result<Opportunity>> getOpportunityById(String id) async {
    if (!Env.isConfigured) {
      return const Result.failure(
        ServerFailure(debugMessage: 'Supabase غير مهيأ بعد.'),
      );
    }

    try {
      final response = await _client.from('opportunities').select('''
            *,
            categories (title_ar, title_en, icon_name),
            opportunity_costs (*),
            opportunity_risks (*),
            opportunity_sources (*, data_sources (*)),
            opportunity_steps (*)
          ''').eq('id', id).single();

      final opp = Opportunity.fromJson(response);
      return Result.success(opp);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } on Exception catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches all dynamic categories managed by the Admin from Supabase.
  Future<Result<List<CategoryModel>>> getCategories() async {
    if (!Env.isConfigured) {
      return const Result.success([]);
    }

    try {
      final response = await _client
          .from('categories')
          .select()
          .order('display_order');

      final items = (response as List<dynamic>)
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } on Exception catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Loads saved opportunities for the authenticated user from Supabase.
  Future<Result<Set<String>>> getSavedOpportunityIds() async {
    if (!Env.isConfigured) return const Result.success({});

    final user = _client.auth.currentUser;
    if (user == null) return const Result.success({});

    try {
      final res = await _client
          .from('saved_opportunities')
          .select('opportunity_id')
          .eq('user_id', user.id);

      final ids = (res as List<dynamic>)
          .map((row) => (row as Map<String, dynamic>)['opportunity_id'] as String)
          .toSet();

      return Result.success(ids);
    } on Exception catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Toggles saved bookmark in Supabase.
  Future<void> toggleSaveOpportunity(String opportunityId, {required bool isCurrentlySaved}) async {
    if (!Env.isConfigured) return;

    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      if (isCurrentlySaved) {
        await _client
            .from('saved_opportunities')
            .delete()
            .eq('user_id', user.id)
            .eq('opportunity_id', opportunityId);
      } else {
        await _client.from('saved_opportunities').upsert({
          'user_id': user.id,
          'opportunity_id': opportunityId,
        });
      }
    } on Exception {
      // Ignored for offline tolerance
    }
  }
}
