import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/states/empty_state.dart';
import 'package:moneyideas/features/chat/domain/models/chat_models.dart';
import 'package:moneyideas/features/chat/presentation/controllers/chat_controller.dart';

/// Screen 65: Conversations List / Direct Messaging Inbox.
class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} د';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} س';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات المباشرة'),
        actions: [
          IconButton(
            tooltip: 'طلبات التواصل',
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () => context.push(AppRoutes.contactRequests),
          ),
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(conversationsListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث عن شريك، شركة أو محادثة...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: conversationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: AppSpacing.page,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: context.colors.error,
                      ),
                      const Gap.md(),
                      Text(
                        'تعذر تحميل المحادثات',
                        style: context.textStyles.titleMedium,
                      ),
                      const Gap.xs(),
                      Text(
                        err.toString(),
                        style: TextStyle(
                          color: context.colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap.md(),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة المحاولة'),
                        onPressed: () =>
                            ref.invalidate(conversationsListProvider),
                      ),
                    ],
                  ),
                ),
              ),
              data: (conversations) {
                // Filter by search
                final filtered = _searchQuery.isEmpty
                    ? conversations
                    : conversations.where((item) {
                        final name = item.otherUserName.toLowerCase();
                        final msg =
                            (item.lastMessageBody ?? '').toLowerCase();
                        final city = item.otherUserCity.toLowerCase();
                        final q = _searchQuery.toLowerCase();
                        return name.contains(q) ||
                            msg.contains(q) ||
                            city.contains(q);
                      }).toList();

                if (filtered.isEmpty) {
                  if (_searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد محادثات تطابق بحثك "$_searchQuery"',
                        style: TextStyle(color: context.colors.onSurfaceVariant),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(conversationsListProvider);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xxl,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 56,
                                color: context.colors.primary,
                              ),
                            ),
                            const Gap.lg(),
                            Text(
                              'لا توجد محادثات نشطة بعد',
                              style: context.textStyles.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap.sm(),
                            Text(
                              'تبدأ المحادثات الفورية المباشرة بمجرد قبول طلب تواصل بينك وبين مستثمر أو رائد أعمال أو شركة.',
                              style: TextStyle(
                                color: context.colors.onSurfaceVariant,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap.xl(),
                            FilledButton.icon(
                              onPressed: () => context.push(AppRoutes.network),
                              icon: const Icon(Icons.hub_rounded),
                              label: const Text('استكشف شبكة الأعمال والمستثمرين'),
                            ),
                            const Gap.sm(),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  context.push(AppRoutes.contactRequests),
                              icon: const Icon(Icons.swap_horiz_rounded),
                              label: const Text('طلبات التواصل المعلقة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(conversationsListProvider);
                  },
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _ConversationTile(
                        item: item,
                        formattedTime: _formatTime(item.lastMessageAt),
                        onTap: () {
                          context.push('/chat/${item.id}');
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.item,
    required this.formattedTime,
    required this.onTap,
  });

  final ConversationItem item;
  final String formattedTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = item.unreadCount > 0;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: context.colors.primaryContainer,
            backgroundImage: (item.otherUserAvatar != null &&
                    item.otherUserAvatar!.isNotEmpty)
                ? NetworkImage(item.otherUserAvatar!)
                : null,
            child: (item.otherUserAvatar == null ||
                    item.otherUserAvatar!.isEmpty)
                ? Text(
                    item.otherUserName.isNotEmpty
                        ? item.otherUserName.characters.first.toUpperCase()
                        : '؟',
                    style: TextStyle(
                      color: context.colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.otherUserName,
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (formattedTime.isNotEmpty)
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 11,
                color: hasUnread
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.lastMessageBody ?? 'محادثة جديدة، ابدأ التواصل الآن',
                style: TextStyle(
                  fontSize: 13,
                  color: hasUnread
                      ? context.colors.onSurface
                      : context.colors.onSurfaceVariant,
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasUnread) ...[
              const Gap.xs(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${item.unreadCount}',
                  style: TextStyle(
                    color: context.colors.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
