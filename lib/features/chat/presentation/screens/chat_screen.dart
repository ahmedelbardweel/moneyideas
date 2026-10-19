import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/chat/domain/models/chat_models.dart';
import 'package:moneyideas/features/chat/presentation/controllers/chat_controller.dart';
import 'package:moneyideas/features/chat/presentation/dialogs/report_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen 66: 1-on-1 Direct Realtime Chat Room.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.conversationId,
    super.key,
  });

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    // Mark as read upon entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatActionControllerProvider)
          .markConversationRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final res = await ref.read(chatActionControllerProvider).sendMessage(
          conversationId: widget.conversationId,
          body: text,
        );

    if (mounted) {
      setState(() => _isSending = false);
      if (!res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.failureOrNull?.debugMessage ?? 'فشل إرسال الرسالة'),
            backgroundColor: context.colors.error,
          ),
        );
      } else {
        _scrollToBottom();
      }
    }
  }

  String _formatMessageTime(DateTime? date) {
    if (date == null) return '';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final conversationAsync =
        ref.watch(conversationDetailsProvider(widget.conversationId));
    final messagesAsync =
        ref.watch(chatMessagesStreamProvider(widget.conversationId));

    final conversation = conversationAsync.asData?.value;
    final otherUserId = conversation?.otherUserId ?? '';
    final blockStateAsync = ref.watch(chatBlockStateProvider(otherUserId));
    final blockState = blockStateAsync.asData?.value ?? ChatBlockState.none;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: context.colors.primaryContainer,
              backgroundImage: (conversation?.otherUserAvatar != null &&
                      conversation!.otherUserAvatar!.isNotEmpty)
                  ? NetworkImage(conversation.otherUserAvatar!)
                  : null,
              child: (conversation?.otherUserAvatar == null ||
                      conversation!.otherUserAvatar!.isEmpty)
                  ? Text(
                      conversation != null && conversation.otherUserName.isNotEmpty
                          ? conversation.otherUserName.characters.first
                              .toUpperCase()
                          : '؟',
                      style: TextStyle(
                        color: context.colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const Gap.sm(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation?.otherUserName ?? 'المحادثة',
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    conversation?.otherUserCity ?? 'شريك معتمد',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) async {
              if (conversation == null) return;

              if (val == 'profile') {
                context.push('/network/investor/$otherUserId');
              } else if (val == 'block') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تأكيد الحظر'),
                    content: Text(
                      'هل أنت متأكد من رغبتك في حظر ${conversation.otherUserName}؟ لن يتمكن من مراسلتك مجدداً.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('إلغاء'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: ctx.colors.error,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('حظر'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref
                      .read(chatActionControllerProvider)
                      .blockUser(otherUserId);
                }
              } else if (val == 'unblock') {
                await ref
                    .read(chatActionControllerProvider)
                    .unblockUser(otherUserId);
              } else if (val == 'report') {
                await ReportDialog.show(
                  context,
                  entityType: 'user',
                  entityId: otherUserId,
                  entityName: conversation.otherUserName,
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 20),
                    Gap.sm(),
                    Text('الملف التعريفي'),
                  ],
                ),
              ),
              if (blockState == ChatBlockState.blockedByMe)
                const PopupMenuItem(
                  value: 'unblock',
                  child: Row(
                    children: [
                      Icon(Icons.lock_open_rounded, size: 20),
                      Gap.sm(),
                      Text('إلغاء الحظر'),
                    ],
                  ),
                )
              else
                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(Icons.block_rounded,
                          size: 20, color: ctx.colors.error),
                      const Gap.sm(),
                      Text('حظر المستخدم',
                          style: TextStyle(color: ctx.colors.error)),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined,
                        size: 20, color: ctx.colors.error),
                    const Gap.sm(),
                    Text('إبلاغ عن مخالفة',
                        style: TextStyle(color: ctx.colors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Block alert banner if blocked
          if (blockState == ChatBlockState.blockedByMe)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: context.colors.errorContainer,
              child: Row(
                children: [
                  Icon(Icons.block_rounded,
                      color: context.colors.onErrorContainer, size: 18),
                  const Gap.sm(),
                  Expanded(
                    child: Text(
                      'لقد قمت بحظر هذا المستخدم. لا يمكن تبادل الرسائل.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(chatActionControllerProvider)
                        .unblockUser(otherUserId),
                    child: const Text('إلغاء الحظر'),
                  ),
                ],
              ),
            )
          else if (blockState == ChatBlockState.blockedMe)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: context.colors.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: context.colors.onSurfaceVariant, size: 18),
                  const Gap.sm(),
                  Expanded(
                    child: Text(
                      'تم حظر إرسال واستقبال الرسائل في هذه المحادثة.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages stream list
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('خطأ في استرجاع الرسائل: $err'),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: AppSpacing.page,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.handshake_outlined,
                                size: 40,
                                color: context.colors.primary,
                              ),
                            ),
                            const Gap.md(),
                            Text(
                              'تم قبول طلب التواصل بنجاح!',
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap.xs(),
                            Text(
                              'يمكنك الآن بدء نقاش تفاصيل الفرصة الاستثمارية ومشاركة الملفات بثقة وأمان.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Auto-scroll when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMine = msg.isMine(_currentUserId);
                    final timeStr = _formatMessageTime(msg.createdAt);

                    return _MessageBubble(
                      message: msg,
                      isMine: isMine,
                      timeStr: timeStr,
                    );
                  },
                );
              },
            ),
          ),

          // Message input field bar
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.xs,
              bottom: MediaQuery.of(context).viewInsets.bottom > 0
                  ? AppSpacing.xs
                  : AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(
                top: BorderSide(
                  color: context.colors.outlineVariant.withAlpha(50),
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !blockState.isBlocked && !_isSending,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: blockState.isBlocked
                            ? 'المحادثة محظورة'
                            : 'اكتب رسالتك هنا...',
                        filled: true,
                        fillColor: context.colors.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const Gap.xs(),
                  IconButton.filled(
                    onPressed: (blockState.isBlocked || _isSending)
                        ? null
                        : _sendMessage,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.timeStr,
  });

  final ChatMessage message;
  final bool isMine;
  final String timeStr;

  @override
  Widget build(BuildContext context) {
    final bg = isMine
        ? context.colors.primary
        : context.colors.surfaceContainerHighest;
    final fg = isMine
        ? context.colors.onPrimary
        : context.colors.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMine ? 16 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.body,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const Gap.xs(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: fg.withAlpha(180),
                      ),
                    ),
                    if (isMine) ...[
                      const Gap.xs(),
                      Icon(
                        message.isRead
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 14,
                        color: message.isRead
                            ? (isMine ? Colors.lightBlueAccent : Colors.blue)
                            : fg.withAlpha(180),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
