import 'package:flutter/foundation.dart';

/// Block state between current authenticated user and the chat partner.
enum ChatBlockState {
  none,
  blockedByMe,
  blockedMe;

  static ChatBlockState fromString(String? val) {
    return switch (val) {
      'blocked_by_me' => ChatBlockState.blockedByMe,
      'blocked_me' => ChatBlockState.blockedMe,
      _ => ChatBlockState.none,
    };
  }

  bool get isBlocked => this != ChatBlockState.none;
}

/// A 1-on-1 direct message mapped to public.messages.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.attachmentUrl,
    this.attachmentType,
    this.isRead = false,
    this.readAt,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      conversationId: json['conversation_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      attachmentType: json['attachment_type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool isMine(String currentUserId) => senderId == currentUserId;
}

/// Conversation metadata item for the conversation inbox list.
@immutable
class ConversationItem {
  const ConversationItem({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.otherUserCity = 'Dubai',
    this.lastMessageBody,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.contactRequestId,
    this.createdAt,
  });

  factory ConversationItem.fromRow({
    required Map<String, dynamic> conversationRow,
    required String currentUserId,
    String? lastMessage,
    int unread = 0,
  }) {
    final pOne = conversationRow['participant_one'] as String? ?? '';
    final pTwo = conversationRow['participant_two'] as String? ?? '';
    final otherId = pOne == currentUserId ? pTwo : pOne;

    final pOneProfile =
        conversationRow['p_one_profile'] as Map<String, dynamic>?;
    final pTwoProfile =
        conversationRow['p_two_profile'] as Map<String, dynamic>?;
    final otherProfile = pOne == currentUserId ? pTwoProfile : pOneProfile;

    return ConversationItem(
      id: conversationRow['id'] as String? ?? '',
      otherUserId: otherId,
      otherUserName: otherProfile?['full_name'] as String? ?? 'شريك أعمال',
      otherUserAvatar: otherProfile?['avatar_url'] as String?,
      otherUserCity: otherProfile?['city'] as String? ?? 'Dubai',
      lastMessageBody: lastMessage,
      lastMessageAt: conversationRow['last_message_at'] != null
          ? DateTime.tryParse(conversationRow['last_message_at'] as String)
          : null,
      unreadCount: unread,
      contactRequestId: conversationRow['contact_request_id'] as String?,
      createdAt: conversationRow['created_at'] != null
          ? DateTime.tryParse(conversationRow['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String otherUserCity;
  final String? lastMessageBody;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String? contactRequestId;
  final DateTime? createdAt;
}
