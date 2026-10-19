import 'dart:async';
import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/deals/domain/models/deal_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DealsRepository {
  const DealsRepository();

  SupabaseClient get _client => Supabase.instance.client;

  /// Fetches all deals where authenticated user is an investor or creator (or super admin).
  Future<Result<List<Deal>>> getDeals({DealStatus? statusFilter}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      var query = _client.from('deals').select(
            '*, investor_profile:profiles!investor_id(full_name, avatar_url), creator_profile:profiles!creator_id(full_name, avatar_url), project:projects!project_id(title)',
          );

      if (statusFilter != null) {
        query = query.eq('status', statusFilter.toDbString());
      }

      final rows = await query.order('updated_at', ascending: false);

      final list = (rows as List<dynamic>)
          .map((r) => Deal.fromJson(r as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches single deal with details.
  Future<Result<Deal?>> getDealDetails(String dealId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final row = await _client
          .from('deals')
          .select(
            '*, investor_profile:profiles!investor_id(full_name, avatar_url), creator_profile:profiles!creator_id(full_name, avatar_url), project:projects!project_id(title)',
          )
          .eq('id', dealId)
          .maybeSingle();

      if (row == null) return const Result.success(null);

      return Result.success(Deal.fromJson(row as Map<String, dynamic>));
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches all milestones for a deal.
  Future<Result<List<DealMilestone>>> getMilestones(String dealId) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      final rows = await _client
          .from('deal_milestones')
          .select('*')
          .eq('deal_id', dealId)
          .order('order_index', ascending: true);

      final list = (rows as List<dynamic>)
          .map((r) => DealMilestone.fromJson(r as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches latest contract for a deal.
  Future<Result<DealContract?>> getContract(String dealId) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      final row = await _client
          .from('deal_contracts')
          .select('*')
          .eq('deal_id', dealId)
          .order('contract_version', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row == null) return const Result.success(null);

      return Result.success(DealContract.fromJson(row as Map<String, dynamic>));
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Initiates a new deal proposal.
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
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final dealRes = await _client
          .from('deals')
          .insert({
            'project_id': projectId,
            'investor_id': investorId,
            'creator_id': user.id,
            'title': title,
            'deal_type': dealType.toDbString(),
            'target_amount': targetAmount,
            'equity_percentage': equityPercentage,
            'status': 'negotiation',
            'terms_summary': termsSummary,
            'escrow_status': 'not_initiated',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final dealId = dealRes['id'] as String;

      // Seed standard contract clauses
      final standardClauses = [
        'يلتزم الطرف الأول (رائد الأعمال/الشركة) بتنفيذ معالم المشروع وفق الخطة والجدول الزمني المحدد في ملحق الصفقات.',
        'يلتزم الطرف الثاني (المستثمر) بإيداع المبلغ المتفق عليه في حساب الضمان المالي المعتمد لحين إنجاز مراحل التسليم.',
        'لا يتم تحرير أي دفعة مالية إلا بعد تقديم إثبات إنجاز المرحلة وموافقة الطرفين أو التحكيم المالي.',
        'يخضع هذا الاتفاق والبنود والنزاعات لقوانين مركز دبي المالي العالمي (DIFC) والجهات التنظيمية في دولة الإمارات العربية المتحدة.',
      ];

      await _client.from('deal_contracts').insert({
        'deal_id': dealId,
        'contract_version': 1,
        'legal_clauses': standardClauses,
        'governing_law':
            'قوانين وإجراءات مركز دبي المالي العالمي (DIFC) / سوق أبوظبي العالمي (ADGM) ودولة الإمارات العربية المتحدة',
        'dispute_mechanism': 'الوساطة والتحكيم المالي المعتمد',
        'is_finalized': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Insert initial milestones if provided
      if (initialMilestones != null && initialMilestones.isNotEmpty) {
        for (var i = 0; i < initialMilestones.length; i++) {
          final m = initialMilestones[i];
          await _client.from('deal_milestones').insert({
            'deal_id': dealId,
            'title': m['title'],
            'description': m['description'],
            'amount': m['amount'],
            'order_index': i + 1,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }

      final fullDeal = await getDealDetails(dealId);
      return Result.success(fullDeal.valueOrNull!);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Signs the deal digital contract.
  Future<Result<void>> signContract({
    required String dealId,
    required String signatureText,
    required bool isInvestor,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final nowStr = DateTime.now().toIso8601String();

      // Update contract
      final contractUpdate = isInvestor
          ? {
              'investor_signature': signatureText,
              'investor_signed_at': nowStr,
            }
          : {
              'creator_signature': signatureText,
              'creator_signed_at': nowStr,
            };

      await _client
          .from('deal_contracts')
          .update(contractUpdate)
          .eq('deal_id', dealId);

      // Check if both signed to mark finalized and change deal status
      final contract = (await getContract(dealId)).valueOrNull;
      final bothSigned = contract != null &&
          ((isInvestor && contract.creatorSignature != null) ||
              (!isInvestor && contract.investorSignature != null));

      final dealUpdate = isInvestor
          ? {'investor_signed_at': nowStr, 'updated_at': nowStr}
          : {'creator_signed_at': nowStr, 'updated_at': nowStr};

      if (bothSigned) {
        dealUpdate['status'] = 'escrow_funded';
        dealUpdate['escrow_status'] = 'pending_deposit';
        await _client
            .from('deal_contracts')
            .update({'is_finalized': true})
            .eq('deal_id', dealId);
      } else {
        dealUpdate['status'] = 'contract_pending';
      }

      await _client.from('deals').update(dealUpdate).eq('id', dealId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Updates milestone status (submission, approval, release).
  Future<Result<void>> updateMilestoneStatus({
    required String milestoneId,
    required MilestoneStatus status,
    String? proofUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.toDbString(),
      };
      if (proofUrl != null) {
        updateData['proof_url'] = proofUrl;
      }
      if (status == MilestoneStatus.approved ||
          status == MilestoneStatus.released) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _client
          .from('deal_milestones')
          .update(updateData)
          .eq('id', milestoneId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Simulates / records regulatory escrow deposit or release.
  Future<Result<void>> updateEscrowStatus({
    required String dealId,
    required EscrowStatus escrowStatus,
    String? escrowAccountId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'escrow_status': escrowStatus.toDbString(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (escrowAccountId != null) {
        updateData['escrow_account_id'] = escrowAccountId;
      }
      if (escrowStatus == EscrowStatus.heldInEscrow) {
        updateData['status'] = 'in_progress';
      } else if (escrowStatus == EscrowStatus.released) {
        updateData['status'] = 'completed';
      }

      await _client.from('deals').update(updateData).eq('id', dealId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }
}
