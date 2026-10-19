import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/network/domain/models/network_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NetworkRepository {
  const NetworkRepository();

  SupabaseClient get _client => Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Investor Directory
  // ---------------------------------------------------------------------------

  /// Fetches directory of verified or active investors.
  Future<Result<List<InvestorProfile>>> getInvestors({
    String? sector,
    bool? verifiedOnly,
  }) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      var query = _client.from('investor_profiles').select('*, profiles(*)');

      if (verifiedOnly == true) {
        query = query.eq('is_verified', true);
      }
      if (sector != null && sector.isNotEmpty) {
        query = query.contains('sectors_of_interest', [sector]);
      }

      final res = await query.order('created_at', ascending: false);
      final list = (res as List<dynamic>)
          .map((json) => InvestorProfile.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches an individual investor profile by ID or user ID.
  Future<Result<InvestorProfile?>> getInvestorProfile(String idOrUserId) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      final res = await _client
          .from('investor_profiles')
          .select('*, profiles(*)')
          .or('id.eq.$idOrUserId,user_id.eq.$idOrUserId')
          .maybeSingle();

      if (res == null) return const Result.success(null);
      return Result.success(
        InvestorProfile.fromJson(res as Map<String, dynamic>),
      );
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches the authenticated user's own investor profile (if set up).
  Future<Result<InvestorProfile?>> getMyInvestorProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    return getInvestorProfile(user.id);
  }

  /// Creates or updates authenticated user's investor profile.
  Future<Result<void>> upsertInvestorProfile(InvestorProfile profile) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final payload = {
        'user_id': user.id,
        ...profile.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('investor_profiles')
          .upsert(payload, onConflict: 'user_id');

      // Ensure 'investor' role is active in user_roles
      await _client.from('user_roles').upsert({
        'user_id': user.id,
        'role': 'investor',
        'is_active': true,
      }, onConflict: 'user_id,role');

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Projects Showcase
  // ---------------------------------------------------------------------------

  /// Fetches public projects with filters.
  Future<Result<List<Project>>> getProjects({
    ProjectType? type,
    ProjectStage? stage,
    String? categoryId,
    String? helpNeeded,
    String? searchQuery,
  }) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      var query = _client.from('projects').select(
            '*, profiles(full_name, avatar_url), categories(title_ar), project_documents(*)',
          );

      query = query.eq('is_published', true);

      if (type != null) {
        query = query.eq('type', type.toDbValue());
      }
      if (stage != null) {
        query = query.eq('stage', stage.toDbValue());
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }
      if (helpNeeded != null && helpNeeded.isNotEmpty) {
        query = query.eq('help_needed_type', helpNeeded);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,summary.ilike.%$searchQuery%');
      }

      final res = await query.order('created_at', ascending: false);
      final list = (res as List<dynamic>)
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches detailed project view with all public documents.
  Future<Result<Project?>> getProjectDetails(String projectId) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      final res = await _client
          .from('projects')
          .select(
            '*, profiles(full_name, avatar_url), categories(title_ar), project_documents(*)',
          )
          .eq('id', projectId)
          .maybeSingle();

      if (res == null) return const Result.success(null);
      return Result.success(Project.fromJson(res as Map<String, dynamic>));
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Publishes a new project for the authenticated entrepreneur.
  Future<Result<String>> createProject(Project project) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final payload = {
        'owner_id': user.id,
        ...project.toJson(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final res = await _client
          .from('projects')
          .insert(payload)
          .select('id')
          .single();

      final newId = res['id'] as String;

      // Ensure 'project_owner' role is active
      await _client.from('user_roles').upsert({
        'user_id': user.id,
        'role': 'project_owner',
        'is_active': true,
      }, onConflict: 'user_id,role');

      return Result.success(newId);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches projects owned by the authenticated entrepreneur.
  Future<Result<List<Project>>> getMyProjects() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final res = await _client
          .from('projects')
          .select(
            '*, profiles(full_name, avatar_url), categories(title_ar), project_documents(*)',
          )
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      final list = (res as List<dynamic>)
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Toggles publishing status of a project.
  Future<Result<void>> toggleProjectPublish(String projectId, bool isPublished) async {
    try {
      await _client.from('projects').update({
        'is_published': isPublished,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Investor Private Watchlist & Confidential Notes
  // ---------------------------------------------------------------------------

  /// Fetches private watchlist items for the authenticated investor.
  Future<Result<List<InvestorWatchlistItem>>> getWatchlist() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final res = await _client
          .from('investor_watchlist')
          .select(
            '*, projects(*, profiles(full_name, avatar_url), categories(title_ar))',
          )
          .eq('investor_id', user.id)
          .order('saved_at', ascending: false);

      final list = (res as List<dynamic>)
          .map((json) =>
              InvestorWatchlistItem.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Toggles a project in the investor's private watchlist.
  Future<Result<bool>> toggleWatchlist({
    required String projectId,
    String? notes,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final existing = await _client
          .from('investor_watchlist')
          .select('id')
          .eq('investor_id', user.id)
          .eq('project_id', projectId)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from('investor_watchlist')
            .delete()
            .eq('id', existing['id'] as String);
        return const Result.success(false);
      } else {
        await _client.from('investor_watchlist').insert({
          'investor_id': user.id,
          'project_id': projectId,
          'private_notes': notes,
          'saved_at': DateTime.now().toIso8601String(),
        });
        return const Result.success(true);
      }
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Updates private notes on a watchlisted project.
  Future<Result<void>> updateWatchlistNotes({
    required String projectId,
    required String notes,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      await _client.from('investor_watchlist').update({
        'private_notes': notes,
      }).eq('investor_id', user.id).eq('project_id', projectId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Contact Requests & Anti-Spam Gate
  // ---------------------------------------------------------------------------

  /// Sends a mutual contact request to prevent unsolicited spam.
  Future<Result<void>> sendContactRequest({
    required String receiverId,
    String? projectId,
    required String reason,
    required String introductionMessage,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    if (user.id == receiverId) {
      return const Result.failure(
        ValidationFailure(debugMessage: 'لا يمكنك إرسال طلب تواصل لنفسك'),
      );
    }

    try {
      await _client.from('contact_requests').insert({
        'sender_id': user.id,
        'receiver_id': receiverId,
        'project_id': projectId,
        'reason': reason,
        'introduction_message': introductionMessage,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches incoming contact requests.
  Future<Result<List<ContactRequest>>> getIncomingContactRequests() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final res = await _client
          .from('contact_requests')
          .select(
            '*, sender:profiles!sender_id(full_name, avatar_url), projects(name)',
          )
          .eq('receiver_id', user.id)
          .order('created_at', ascending: false);

      final list = (res as List<dynamic>)
          .map((json) => ContactRequest.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches outgoing contact requests.
  Future<Result<List<ContactRequest>>> getOutgoingContactRequests() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final res = await _client
          .from('contact_requests')
          .select(
            '*, receiver:profiles!receiver_id(full_name, avatar_url), projects(name)',
          )
          .eq('sender_id', user.id)
          .order('created_at', ascending: false);

      final list = (res as List<dynamic>)
          .map((json) => ContactRequest.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Responds to a contact request (accept / reject).
  /// When accepted, automatically opens a conversation between the two parties.
  Future<Result<void>> respondToContactRequest({
    required String requestId,
    required ContactRequestStatus status,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      // On 'accepted', the DB trigger `on_contact_request_accepted`
      // (migration 00009) creates the conversation server-side.
      await _client
          .from('contact_requests')
          .update({
            'status': status.toDbValue(),
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId)
          .eq('receiver_id', user.id);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }
}
