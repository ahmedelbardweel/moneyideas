import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/assistant/domain/models/match_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssistantRepository {
  const AssistantRepository();

  SupabaseClient get _client => Supabase.instance.client;

  /// Executes the explainable matching engine on PostgreSQL directly.
  Future<Result<List<MatchResult>>> matchOpportunities({
    required double budget,
    required String city,
    required int weeklyHours,
    required String experience,
    required String risk,
    required bool hasNoCapital,
  }) async {
    if (!Env.isConfigured) {
      return const Result.failure(
        ServerFailure(debugMessage: 'Supabase غير متصل.'),
      );
    }

    try {
      final response = await _client.rpc<List<dynamic>>(
        'match_opportunities',
        params: {
          'p_budget': budget,
          'p_city': city,
          'p_weekly_hours': weeklyHours,
          'p_experience': experience,
          'p_risk': risk,
          'p_has_no_capital': hasNoCapital,
        },
      );

      final list = response
          .map((item) => MatchResult.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.criteriaMetCount.compareTo(a.criteriaMetCount));

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } on Exception catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }
}
