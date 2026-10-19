import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';

/// Screen 64: My Published Projects & Investor Private Watchlist.
class MyProjectsScreen extends ConsumerWidget {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مشاريعي وقوائم الدراسة'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'مشاريعي المعروضة'),
              Tab(text: 'قائمة دراسة المستثمر'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MyProjectsTab(),
            _InvestorWatchlistTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة مشروع'),
          onPressed: () => context.push(AppRoutes.createProject),
        ),
      ),
    );
  }
}

class _MyProjectsTab extends ConsumerWidget {
  const _MyProjectsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(myProjectsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(myProjectsProvider.future),
      child: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rocket_outlined,
                    size: 64,
                    color: context.colors.outline,
                  ),
                  const Gap.md(),
                  Text(
                    'لم تقم بإضافة أي مشروع بعد',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const Gap.sm(),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('أضف مشروعك الآن'),
                    onPressed: () => context.push(AppRoutes.createProject),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.page,
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];

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
                          Expanded(
                            child: Text(
                              project.name,
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Switch(
                            value: project.isPublished,
                            onChanged: (val) {
                              ref
                                  .read(networkActionControllerProvider)
                                  .toggleProjectPublish(project.id, val);
                            },
                          ),
                        ],
                      ),
                      Text(
                        '${project.categoryNameAr ?? "مشروع"} • ${project.stage.labelAr} • ${project.type.labelAr}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const Gap.sm(),
                      Text(
                        project.summary,
                        style: context.textStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap.md(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.push(
                              '/network/project/${project.id}',
                            ),
                            child: const Text('معاينة التفاصيل'),
                          ),
                        ],
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
    );
  }
}

class _InvestorWatchlistTab extends ConsumerWidget {
  const _InvestorWatchlistTab();

  Future<void> _editNotes(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String? currentNotes,
  ) async {
    final controller = TextEditingController(text: currentNotes ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل الملاحظات السرية'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'اكتب ملاحظاتك الاستثمارية الخاصة...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حفظ التعديل'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await ref.read(networkActionControllerProvider).updateWatchlistNotes(
          projectId: projectId,
          notes: controller.text.trim(),
        );

    if (!context.mounted) return;

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تحديث الملاحظات بنجاح'),
          backgroundColor: context.appColors.success.color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(investorWatchlistProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(investorWatchlistProvider.future),
      child: watchlistAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: context.colors.outline,
                  ),
                  const Gap.md(),
                  Text(
                    'قائمة دراسة المشاريع فارغة',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const Gap.xs(),
                  Text(
                    'يمكنك حفظ أي مشروع من شبكة الأعمال لإضافة ملاحظاتك التحليلية السرية عليه.',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.page,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final project = item.project;

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
                          Expanded(
                            child: Text(
                              project?.name ?? 'مشروع محفوظ',
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.bookmark_remove_outlined),
                            tooltip: 'إزالة من القائمة',
                            onPressed: () {
                              ref
                                  .read(networkActionControllerProvider)
                                  .toggleWatchlist(projectId: item.projectId);
                            },
                          ),
                        ],
                      ),
                      if (project != null)
                        Text(
                          '${project.categoryNameAr ?? ""} • ${project.stage.labelAr}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      const Gap.sm(),

                      // Private Notes Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lock_outline_rounded,
                                    size: 14, color: Colors.amber.shade900),
                                const Gap.xxs(),
                                Text(
                                  'ملاحظاتك السرية الخاصة:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const Gap.xxs(),
                            Text(
                              item.privateNotes?.isNotEmpty == true
                                  ? item.privateNotes!
                                  : 'لا توجد ملاحظات مسجلة بعد...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap.sm(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit_note_rounded, size: 16),
                            label: const Text('تعديل الملاحظات'),
                            onPressed: () => _editNotes(
                              context,
                              ref,
                              item.projectId,
                              item.privateNotes,
                            ),
                          ),
                          const Gap.xs(),
                          FilledButton(
                            onPressed: () => context.push(
                              '/network/project/${item.projectId}',
                            ),
                            child: const Text('فتح المشروع'),
                          ),
                        ],
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
    );
  }
}
