import 'dart:async';
import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/errors/failure.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/chat/domain/models/chat_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository {
  const ChatRepository();

  SupabaseClient get _client => Supabase.instance.client;

  /// Fetches all active conversations for the authenticated user with partner profile.
  Future<Result<List<ConversationItem>>> getConversations() async {
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
      final rows = await _client
          .from('conversations')
          .select(
            '*, p_one_profile:profiles!participant_one(full_name, avatar_url, city), p_two_profile:profiles!participant_two(full_name, avatar_url, city)',
          )
          .or('participant_one.eq.${user.id},participant_two.eq.${user.id}')
          .order('last_message_at', ascending: false);

      final List<ConversationItem> items = [];

      for (final raw in (rows as List<dynamic>)) {
        final row = raw as Map<String, dynamic>;
        final convId = row['id'] as String;

        // Fetch last message preview
        final lastMsgRes = await _client
            .from('messages')
            .select('body')
            .eq('conversation_id', convId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        // Fetch unread count for current user
        final unreadRes = await _client
            .from('messages')
            .select('id')
            .eq('conversation_id', convId)
            .eq('is_read', false)
            .neq('sender_id', user.id);

        items.add(
          ConversationItem.fromRow(
            conversationRow: row,
            currentUserId: user.id,
            lastMessage: lastMsgRes?['body'] as String?,
            unread: (unreadRes as List).length,
          ),
        );
      }

      return Result.success(items);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Fetches single conversation header and partner profile.
  Future<Result<ConversationItem?>> getConversationDetails(
    String conversationId,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      final row = await _client
          .from('conversations')
          .select(
            '*, p_one_profile:profiles!participant_one(full_name, avatar_url, city), p_two_profile:profiles!participant_two(full_name, avatar_url, city)',
          )
          .eq('id', conversationId)
          .maybeSingle();

      if (row == null) return const Result.success(null);

      return Result.success(
        ConversationItem.fromRow(
          conversationRow: row as Map<String, dynamic>,
          currentUserId: user.id,
        ),
      );
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// One-time fetch of messages for initial load.
  Future<Result<List<ChatMessage>>> getMessages(String conversationId) async {
    if (!Env.isConfigured) {
      return const Result.failure(ServerFailure(debugMessage: 'Supabase غير متصل'));
    }

    try {
      final res = await _client
          .from('messages')
          .select('*')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final list = (res as List<dynamic>)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Realtime stream of messages in a conversation.
  Stream<List<ChatMessage>> streamMessages(String conversationId) {
    if (!Env.isConfigured) {
      return Stream.value([]);
    }

    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((r) => ChatMessage.fromJson(r)).toList());
  }

  /// Sends a new message in a conversation.
  Future<Result<void>> sendMessage({
    required String conversationId,
    required String body,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      await _client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': user.id,
        'body': body,
        'attachment_url': attachmentUrl,
        'attachment_type': attachmentType,
        'created_at': DateTime.now().toIso8601String(),
      });

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Marks unread messages in a conversation as read.
  Future<Result<void>> markConversationRead(String conversationId) async {
    final user = _client.auth.currentUser;
    if (user == null) return const Result.success(null);

    try {
      // First attempt using secure RPC function
      try {
        await _client.rpc(
          'mark_conversation_read',
          params: {'p_conversation_id': conversationId},
        );
      } catch (_) {
        // Fallback directly
        await _client
            .from('messages')
            .update({
              'is_read': true,
              'read_at': DateTime.now().toIso8601String(),
            })
            .eq('conversation_id', conversationId)
            .neq('sender_id', user.id)
            .eq('is_read', false);
      }

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Inspects block state between authenticated user and another user.
  Future<Result<ChatBlockState>> getBlockState(String otherUserId) async {
    final user = _client.auth.currentUser;
    if (user == null) return const Result.success(ChatBlockState.none);

    try {
      try {
        final res = await _client.rpc(
          'chat_block_state',
          params: {'p_other_user': otherUserId},
        );
        return Result.success(ChatBlockState.fromString(res as String?));
      } catch (_) {
        // Direct query fallback
        final blockedByMe = await _client
            .from('user_blocks')
            .select('created_at')
            .eq('user_id', user.id)
            .eq('blocked_user_id', otherUserId)
            .maybeSingle();

        if (blockedByMe != null) {
          return const Result.success(ChatBlockState.blockedByMe);
        }

        final blockedMe = await _client
            .from('user_blocks')
            .select('created_at')
            .eq('user_id', otherUserId)
            .eq('blocked_user_id', user.id)
            .maybeSingle();

        if (blockedMe != null) {
          return const Result.success(ChatBlockState.blockedMe);
        }

        return const Result.success(ChatBlockState.none);
      }
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Blocks another user.
  Future<Result<void>> blockUser(String otherUserId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      await _client.from('user_blocks').upsert({
        'user_id': user.id,
        'blocked_user_id': otherUserId,
        'created_at': DateTime.now().toIso8601String(),
      });

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Unblocks a user.
  Future<Result<void>> unblockUser(String otherUserId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      await _client
          .from('user_blocks')
          .delete()
          .eq('user_id', user.id)
          .eq('blocked_user_id', otherUserId);

      return const Result.success(null);
    } on PostgrestException catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(debugMessage: e.toString()));
    }
  }

  /// Submits an integrity, fraud, or abuse report.
  Future<Result<void>> submitReport({
    required String entityType,
    required String entityId,
    required String reason,
    String? details,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.unknown, debugMessage: 'لا توجد جلسة نشطة'),
      );
    }

    try {
      await _client.from('reports').insert({
        'reporter_id': user.id,
        'reported_entity_type': entityType,
        'reported_entity_id': entityId,
        'reason': reason,
        'details': details,
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
}
