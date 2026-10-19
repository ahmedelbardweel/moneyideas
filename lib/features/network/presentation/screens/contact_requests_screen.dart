import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/network/domain/models/network_models.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';

/// Screen 63: Mutual Contact Requests Inbox (Incoming & Outgoing).
class ContactRequestsScreen extends ConsumerWidget {
  const ContactRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingRequestsCountProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلبات التواصل والشراكة'),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('الطلبات الواردة'),
                    if (pendingCount > 0) ...[
                      const Gap.xs(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'الطلبات الصادرة'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _IncomingRequestsTab(),
            _OutgoingRequestsTab(),
          ],
        ),
      ),
    );
  }
}

class _IncomingRequestsTab extends ConsumerWidget {
  const _IncomingRequestsTab();

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    ContactRequestStatus status,
  ) async {
    final res = await ref.read(networkActionControllerProvider).respondToContactRequest(
          requestId: requestId,
          status: status,
        );

    if (!context.mounted) return;

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == ContactRequestStatus.accepted
                ? 'تم قبول الطلب وبدء المحادثة بنجاح'
                : 'تم الاعتذار عن الطلب',
          ),
          backgroundColor: status == ContactRequestStatus.accepted
              ? context.appColors.success.color
              : context.colors.outline,
          action: status == ContactRequestStatus.accepted
              ? SnackBarAction(
                  label: 'فتح المحادثات',
                  textColor: Colors.white,
                  onPressed: () => context.push(AppRoutes.chatList),
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(incomingContactRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(incomingContactRequestsProvider.future),
      child: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 64,
                    color: context.colors.outline,
                  ),
                  const Gap.md(),
                  Text(
                    'لا توجد طلبات تواصل واردة حالياً',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.page,
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final isPending = req.status == ContactRequestStatus.pending;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isPending
                        ? context.colors.primary.withValues(alpha: 0.5)
                        : context.colors.outlineVariant,
                  ),
                  borderRadius: AppRadius.mediumAll,
                ),
                child: Padding(
                  padding: AppSpacing.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: context.colors.primaryContainer,
                                child: Text(
                                  req.senderName?.isNotEmpty == true
                                      ? req.senderName![0]
                                      : 'U',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const Gap.sm(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    req.senderName ?? 'مستخدم مهتم',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    req.reason,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _StatusBadge(status: req.status),
                        ],
                      ),
                      if (req.projectName != null) ...[
                        const Gap.sm(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'المشروع المستهدف: ${req.projectName}',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                      const Gap.sm(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          req.introductionMessage,
                          style: context.textStyles.bodySmall,
                        ),
                      ),
                      if (isPending) ...[
                        const Gap.md(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.colors.error,
                              ),
                              onPressed: () => _respond(
                                context,
                                ref,
                                req.id,
                                ContactRequestStatus.rejected,
                              ),
                              child: const Text('اعتذار'),
                            ),
                            const Gap.sm(),
                            FilledButton.icon(
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('قبول وبدء المحادثة'),
                              onPressed: () => _respond(
                                context,
                                ref,
                                req.id,
                                ContactRequestStatus.accepted,
                              ),
                            ),
                          ],
                        ),
                      ] else if (req.status == ContactRequestStatus.accepted) ...[
                        const Gap.sm(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                            label: const Text('فتح المحادثة المباشرة'),
                            onPressed: () => context.push(AppRoutes.chatList),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}

class _OutgoingRequestsTab extends ConsumerWidget {
  const _OutgoingRequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(outgoingContactRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(outgoingContactRequestsProvider.future),
      child: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.outbox_rounded,
                    size: 64,
                    color: context.colors.outline,
                  ),
                  const Gap.md(),
                  Text(
                    'لم تقم بإرسال أي طلبات تواصل بعد',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.page,
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: context.colors.outlineVariant),
                  borderRadius: AppRadius.mediumAll,
                ),
                child: Padding(
                  padding: AppSpacing.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'مرسل إلى: ${req.receiverName ?? "شريك مستهدف"}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _StatusBadge(status: req.status),
                        ],
                      ),
                      const Gap.xxs(),
                      Text(
                        'سبب الطلب: ${req.reason}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.primary,
                        ),
                      ),
                      const Gap.sm(),
                      Text(
                        req.introductionMessage,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (req.status == ContactRequestStatus.accepted) ...[
                        const Gap.sm(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                            label: const Text('فتح المحادثة المباشرة'),
                            onPressed: () => context.push(AppRoutes.chatList),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ContactRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ContactRequestStatus.accepted => ('مقبول', Colors.green.shade700),
      ContactRequestStatus.pending => ('بانتظار الرد', Colors.orange.shade800),
      ContactRequestStatus.rejected => ('معتذر عنه', Colors.red.shade700),
      ContactRequestStatus.cancelled => ('ملغى', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
