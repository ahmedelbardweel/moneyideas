import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moneyideas/core/config/env.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/states/empty_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _NotificationItem {
  _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  bool isRead;
}

/// Screen 29: Notifications Center for matched opportunities and live alerts from Supabase.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadNotifications());
  }

  Future<void> _loadNotifications() async {
    if (!Env.isConfigured) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final items = (res as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        return _NotificationItem(
          id: map['id'] as String,
          title: map['title'] as String? ?? 'تنبيه جديد',
          body: map['message'] as String? ?? '',
          time: 'الآن',
          icon: AppIcons.notifications,
          isRead: map['is_read'] as bool? ?? false,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _notifications
            ..clear()
            ..addAll(items);
          _isLoading = false;
        });
      }
    } on Exception {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });

    if (Env.isConfigured) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        unawaited(
          Supabase.instance.client
              .from('notifications')
              .update({'is_read': true})
              .eq('user_id', user.id),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإشعارات والتنبيهات',
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('تحديد الكل كمقروء'),
            ),
        ],
      ),
      body: SafeArea(
        child: _notifications.isEmpty
            ? const EmptyState(
                icon: AppIcons.notifications,
                title: 'لا توجد إشعارات حالياً',
                message:
                    'سنخبرك فور إضافة فرص جديدة تطابق ميزانيتك وخبرتك أو عند وجود تحديثات في رخص وتكاليف الفرص المحفوظة.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) => const Gap.xs(),
                itemBuilder: (context, index) {
                  final item = _notifications[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mediumAll,
                      side: BorderSide(
                        color: item.isRead
                            ? context.colors.outlineVariant
                                .withValues(alpha: 0.5)
                            : context.colors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    color: item.isRead
                        ? context.colors.surface
                        : context.colors.primaryContainer
                            .withValues(alpha: 0.12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.isRead
                            ? context.colors.surfaceContainerHighest
                            : context.colors.primaryContainer,
                        child: Icon(
                          item.icon,
                          size: AppSizes.iconSmall,
                          color: item.isRead
                              ? context.colors.onSurfaceVariant
                              : context.colors.primary,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: context.textStyles.titleSmall?.copyWith(
                          fontWeight:
                              item.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap.xxs(),
                          Text(
                            item.body,
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          const Gap.xs(),
                          Text(
                            item.time,
                            style: context.textStyles.labelSmall?.copyWith(
                              color: context.colors.outline,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          item.isRead = true;
                        });
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
