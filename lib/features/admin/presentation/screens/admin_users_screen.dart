import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/admin/domain/models/admin_models.dart';
import 'package:moneyideas/features/admin/presentation/controllers/admin_controller.dart';

/// Screen 86: Admin User Governance, Ban Management, and Role Assignment.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleToggleBan(AdminUserItem user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(user.isBanned ? 'إلغاء حظر المستخدم' : 'حظر المستخدم'),
        content: Text(
          user.isBanned
              ? 'هل تريد بالتأكيد إلغاء حظر "${user.fullName}" والسماح له بالدخول مجدداً؟'
              : 'هل تريد بالتأكيد حظر "${user.fullName}" ومنعه من الوصول لمنصة أفكار المال؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: user.isBanned ? Colors.green : context.colors.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(user.isBanned ? 'إلغاء الحظر' : 'تأكيد الحظر'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await ref.read(adminActionControllerProvider).toggleUserBan(
          userId: user.id,
          isBanned: !user.isBanned,
        );

    if (!mounted) return;

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(user.isBanned ? 'تم إلغاء الحظر' : 'تم حظر المستخدم'),
          backgroundColor: context.appColors.success.color,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.debugMessage ?? 'فشلت العملية'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  Future<void> _handleManageRoles(AdminUserItem user) async {
    final availableRoles = [
      ('admin', 'مدير نظام (Admin)', Icons.admin_panel_settings_rounded),
      ('company', 'شركة تجارية (Company)', Icons.business_rounded),
      ('investor', 'مستثمر (Investor)', Icons.trending_up_rounded),
      ('project_owner', 'رائد أعمال (Entrepreneur)', Icons.rocket_launch_rounded),
      ('individual', 'مستكشف (Explorer)', Icons.person_rounded),
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إدارة أدوار: ${user.fullName}',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap.xs(),
                  Text(
                    'يمكنك منح أو سحب الصلاحيات العليا في سوبابيز مباشرة:',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const Gap.md(),
                  ...availableRoles.map((roleInfo) {
                    final hasRole = user.roles.contains(roleInfo.$1);

                    return SwitchListTile(
                      title: Text(roleInfo.$2),
                      secondary: Icon(roleInfo.$3),
                      value: hasRole,
                      onChanged: (newVal) async {
                        final res = await ref
                            .read(adminActionControllerProvider)
                            .toggleUserRole(
                              userId: user.id,
                              role: roleInfo.$1,
                              shouldHaveRole: newVal,
                            );

                        if (res.isSuccess) {
                          setModalState(() {
                            if (newVal) {
                              user.roles.add(roleInfo.$1);
                            } else {
                              user.roles.remove(roleInfo.$1);
                            }
                          });
                        }
                      },
                    );
                  }),
                  const Gap.md(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين والأدوار'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'البحث بالاسم عن أي مستخدم...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = null);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.mediumAll,
                  ),
                ),
                onSubmitted: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
            ),
            const Divider(height: 1),

            // Users list
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        'لا يوجد مستخدمون مطابقون',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: AppSpacing.page,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: user.isBanned
                                ? context.colors.error
                                : context.colors.outlineVariant,
                          ),
                          borderRadius: AppRadius.mediumAll,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppSpacing.sm),
                          leading: CircleAvatar(
                            backgroundColor: user.isBanned
                                ? context.colors.errorContainer
                                : context.colors.primaryContainer,
                            child: Icon(
                              user.isBanned
                                  ? Icons.block_rounded
                                  : Icons.person_rounded,
                              color: user.isBanned
                                  ? context.colors.onErrorContainer
                                  : context.colors.onPrimaryContainer,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: user.isBanned
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              if (user.isBanned) ...[
                                const Gap.xs(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.error,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'محظور',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap.xxs(),
                              Text(
                                'المدينة: ${user.city}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                              const Gap.xs(),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: user.roles.map((r) {
                                  final isAdmin = r == 'admin';
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAdmin
                                          ? Colors.red.shade100
                                          : context.colors.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isAdmin
                                            ? Colors.red
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      r,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isAdmin
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isAdmin
                                            ? Colors.red.shade900
                                            : context.colors.onSurfaceVariant,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'إدارة الأدوار',
                                icon: const Icon(Icons.shield_outlined),
                                onPressed: () => _handleManageRoles(user),
                              ),
                              IconButton(
                                tooltip: user.isBanned ? 'إلغاء الحظر' : 'حظر المستخدم',
                                icon: Icon(
                                  user.isBanned
                                      ? Icons.lock_open_rounded
                                      : Icons.lock_outline_rounded,
                                  color: user.isBanned
                                      ? Colors.green
                                      : context.colors.error,
                                ),
                                onPressed: () => _handleToggleBan(user),
                              ),
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
            ),
          ],
        ),
      ),
    );
  }
}
