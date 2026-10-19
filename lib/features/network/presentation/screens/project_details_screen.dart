import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/network/domain/models/network_models.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';
import 'package:moneyideas/features/network/presentation/dialogs/send_contact_request_dialog.dart';

final projectDetailsProvider =
    FutureProvider.family<Project?, String>((ref, id) async {
  final repo = ref.watch(networkRepositoryProvider);
  final res = await repo.getProjectDetails(id);
  return res.valueOrNull;
});

/// Screen 58: Project Showcase Details, Problem-Solution, and Investor Watchlist Notes.
class ProjectDetailsScreen extends ConsumerWidget {
  const ProjectDetailsScreen({required this.projectId, super.key});

  final String projectId;

  Future<void> _handleWatchlist(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة لقائمة دراسة المستثمر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'يمكنك حفظ المشروع وإضافة ملاحظاتك التحليلية السرية الخاصة (لا يراها صاحب المشروع أو أي طرف آخر):',
            ),
            const Gap.sm(),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'ملاحظاتك: التقييم المالي المبدئي، الأسئلة للمؤسس...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حفظ في قائمتي'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await ref.read(networkActionControllerProvider).toggleWatchlist(
          projectId: project.id,
          notes: notesController.text.trim(),
        );

    if (!context.mounted) return;

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.valueOrNull == true
                ? 'تمت إضافة المشروع لقائمتك الاستثمارية السرية'
                : 'تمت إزالة المشروع من قائمتك',
          ),
          backgroundColor: context.appColors.success.color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المشروع'),
      ),
      body: SafeArea(
        child: projectAsync.when(
          data: (project) {
            if (project == null) {
              return const Center(child: Text('لم يتم العثور على المشروع'));
            }

            return ListView(
              padding: AppSpacing.page,
              children: [
                // Header
                Card(
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
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                project.categoryNameAr ?? 'مشروع ريادي',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const Gap.xs(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                project.stage.labelAr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap.sm(),
                        Text(
                          project.name,
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap.xxs(),
                        Text(
                          'بواسطة: ${project.ownerName ?? "رائد أعمال"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const Gap.md(),
                        Text(
                          project.summary,
                          style: context.textStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap.md(),

                // Help Needed Pill Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: AppRadius.mediumAll,
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.handshake_outlined, color: Colors.blue.shade800),
                      const Gap.sm(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الشراكة أو المساعدة المطلوبة:',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            Text(
                              project.helpNeededType,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap.md(),

                // Problem Statement
                Text(
                  'المشكلة في السوق',
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap.xs(),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: context.colors.outlineVariant),
                    borderRadius: AppRadius.mediumAll,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.help_outline_rounded,
                            color: Colors.red.shade700),
                        const Gap.sm(),
                        Expanded(
                          child: Text(
                            project.problemStatement,
                            style: context.textStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap.md(),

                // Solution Statement
                Text(
                  'الحل والقيمة المضافة',
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap.xs(),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: context.colors.outlineVariant),
                    borderRadius: AppRadius.mediumAll,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            color: Colors.green.shade700),
                        const Gap.sm(),
                        Expanded(
                          child: Text(
                            project.solutionStatement,
                            style: context.textStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap.md(),

                // Target Audience & Revenue Model
                if (project.targetAudience != null &&
                    project.targetAudience!.isNotEmpty) ...[
                  _InfoCard(
                    title: 'السوق والجمهور المستهدف',
                    content: project.targetAudience!,
                    icon: Icons.groups_outlined,
                  ),
                  const Gap.sm(),
                ],

                if (project.revenueModel != null &&
                    project.revenueModel!.isNotEmpty) ...[
                  _InfoCard(
                    title: 'نموذج تحقيق الإيرادات',
                    content: project.revenueModel!,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  const Gap.md(),
                ],

                // Project Documents
                if (project.documents.isNotEmpty) ...[
                  Text(
                    'مستندات المشروع المتاحة',
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap.xs(),
                  ...project.documents.map((doc) => ListTile(
                        leading: const Icon(Icons.picture_as_pdf_rounded),
                        title: Text(doc.title),
                        subtitle: Text(
                          doc.isPublic ? 'مستند عام متاح' : 'مستند سري بإذن',
                        ),
                        trailing: const Icon(Icons.download_rounded),
                      )),
                  const Gap.md(),
                ],

                const Gap.lg(),

                // Dual Action Bar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: const Text('دراسة مستثمر (سري)'),
                        onPressed: () => _handleWatchlist(context, ref, project),
                      ),
                    ),
                    const Gap.sm(),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('طلب تواصل وشراكة'),
                        onPressed: () => SendContactRequestDialog.show(
                          context,
                          receiverId: project.ownerId,
                          receiverName: project.ownerName ?? 'صاحب المشروع',
                          projectId: project.id,
                          projectName: project.name,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap.xl(),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  final String title;
  final String content;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.colors.outlineVariant),
        borderRadius: AppRadius.mediumAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: context.colors.primary),
                const Gap.xs(),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const Gap.xs(),
            Text(content, style: context.textStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
