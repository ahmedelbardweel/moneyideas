import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/result/result.dart';
import 'package:moneyideas/features/chat/data/repositories/chat_repository.dart';
import 'package:moneyideas/features/chat/domain/models/chat_models.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return const ChatRepository();
});

/// Live conversations list.
final conversationsListProvider =
    FutureProvider<List<ConversationItem>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  final res = await repo.getConversations();
  return res.valueOrNull ?? const [];
});

/// Single conversation details.
final conversationDetailsProvider =
    FutureProvider.family<ConversationItem?, String>((ref, id) async {
  final repo = ref.watch(chatRepositoryProvider);
  final res = await repo.getConversationDetails(id);
  return res.valueOrNull;
});

/// Realtime live messages stream for a conversation.
final chatMessagesStreamProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, convId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.streamMessages(convId);
});

/// Block state with partner.
final chatBlockStateProvider =
    FutureProvider.family<ChatBlockState, String>((ref, otherUserId) async {
  final repo = ref.watch(chatRepositoryProvider);
  final res = await repo.getBlockState(otherUserId);
  return res.valueOrNull ?? ChatBlockState.none;
});

/// Chat action mutations.
final chatActionControllerProvider =
    Provider<ChatActionController>((ref) => ChatActionController(ref));

class ChatActionController {
  ChatActionController(this._ref);

  final Ref _ref;

  ChatRepository get _repo => _ref.read(chatRepositoryProvider);

  Future<Result<void>> sendMessage({
    required String conversationId,
    required String body,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    final res = await _repo.sendMessage(
      conversationId: conversationId,
      body: body,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
    );
    if (res.isSuccess) {
      _ref.invalidate(conversationsListProvider);
    }
    return res;
  }

  Future<void> markConversationRead(String conversationId) async {
    await _repo.markConversationRead(conversationId);
    _ref.invalidate(conversationsListProvider);
  }

  Future<Result<void>> blockUser(String otherUserId) async {
    final res = await _repo.blockUser(otherUserId);
    if (res.isSuccess) {
      _ref.invalidate(chatBlockStateProvider(otherUserId));
      _ref.invalidate(conversationsListProvider);
    }
    return res;
  }

  Future<Result<void>> unblockUser(String otherUserId) async {
    final res = await _repo.unblockUser(otherUserId);
    if (res.isSuccess) {
      _ref.invalidate(chatBlockStateProvider(otherUserId));
      _ref.invalidate(conversationsListProvider);
    }
    return res;
  }

  Future<Result<void>> submitReport({
    required String entityType,
    required String entityId,
    required String reason,
    String? details,
  }) async {
    return _repo.submitReport(
      entityType: entityType,
      entityId: entityId,
      reason: reason,
      details: details,
    );
  }
}
