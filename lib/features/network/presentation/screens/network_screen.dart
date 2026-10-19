import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/features/network/domain/models/network_models.dart';
import 'package:moneyideas/features/network/presentation/controllers/network_controller.dart';
import 'package:moneyideas/features/network/presentation/dialogs/send_contact_request_dialog.dart';

/// Screen 53: Central Business Network Hub connecting Projects and Investors.
class NetworkScreen extends ConsumerWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pendingCount = ref.watch(pendingRequestsCountProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navNetwork),
          actions: [
            // Direct Chats button
            IconButton(
              tooltip: 'المحادثات المباشرة',
              icon: const Icon(Icons.forum_outlined),
              onPressed: () => context.push(AppRoutes.chatList),
            ),
            // Contact Requests Inbox button with badge
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'طلبات التواصل',
                  icon: const Icon(Icons.swap_horiz_rounded),
                  onPressed: () => context.push(AppRoutes.contactRequests),
                ),
                if (pendingCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.colors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // My Projects & Watchlist shortcut
            IconButton(
              tooltip: 'مشاريعي وقوائم دراستي',
              icon: const Icon(Icons.folder_shared_outlined),
              onPressed: () => context.push(AppRoutes.myProjects),
            ),
            // Quick popup menu for extra shortcuts
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (val) {
                if (val == 'chats') {
                  context.push(AppRoutes.chatList);
                } else if (val == 'deals') {
                  context.push(AppRoutes.deals);
                } else if (val == 'new_project') {
                  context.push(AppRoutes.createProject);
                } else if (val == 'investor_profile') {
                  context.push(AppRoutes.editInvestorProfile);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'chats',
                  child: Row(
                    children: [
                      Icon(Icons.forum_outlined, size: 18),
                      Gap.xs(),
                      Text('المحادثات المباشرة'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'deals',
                  child: Row(
                    children: [
                      Icon(Icons.handshake_outlined, size: 18),
                      Gap.xs(),
                      Text('الصفقات والتمويل (Deals)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'new_project',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 18),
                      Gap.xs(),
                      Text('نشر مشروع جديد'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'investor_profile',
                  child: Row(
                    children: [
                      Icon(Icons.trending_up_rounded, size: 18),
                      Gap.xs(),
                      Text('إعداد ملفي الاستثماري'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المشاريع والفرص', icon: Icon(AppIcons.projectOwner)),
              Tab(text: 'دليل المستثمرين', icon: Icon(AppIcons.investor)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProjectsDirectoryTab(),
            _InvestorsDirectoryTab(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tab 1: Projects Showcase & Directory
// -----------------------------------------------------------------------------
class _ProjectsDirectoryTab extends ConsumerStatefulWidget {
  const _ProjectsDirectoryTab();

  @override
  ConsumerState<_ProjectsDirectoryTab> createState() =>
      _ProjectsDirectoryTabState();
}

class _ProjectsDirectoryTabState extends ConsumerState<_ProjectsDirectoryTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(projectFilterProvider);
    final projectsAsync = ref.watch(projectsListProvider);

    return Column(
      children: [
        // Search & Filter header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'البحث عن مشاريع أو أفكار أو شركاء...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(projectFilterProvider.notifier)
                            .update((c) => c.copyWith(searchQuery: () => null));
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(borderRadius: AppRadius.mediumAll),
            ),
            onSubmitted: (val) {
              ref.read(projectFilterProvider.notifier).update(
                    (c) => c.copyWith(
                      searchQuery: () => val.trim().isEmpty ? null : val.trim(),
                    ),
                  );
            },
          ),
        ),

        // Type Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('كافة المشاريع'),
                selected: filter.type == null,
                onSelected: (val) {
                  if (val) {
                    ref
                        .read(projectFilterProvider.notifier)
                        .update((c) => c.copyWith(type: () => null));
                  }
                },
              ),
              const Gap.xs(),
              ChoiceChip(
                label: const Text('أفكار جديدة'),
                selected: filter.type == ProjectType.idea,
                onSelected: (val) {
                  ref.read(projectFilterProvider.notifier).update(
                        (c) => c.copyWith(
                          type: () => val ? ProjectType.idea : null,
                        ),
                      );
                },
              ),
              const Gap.xs(),
              ChoiceChip(
                label: const Text('مشاريع قائمة'),
                selected: filter.type == ProjectType.existingBusiness,
                onSelected: (val) {
                  ref.read(projectFilterProvider.notifier).update(
                        (c) => c.copyWith(
                          type: () => val ? ProjectType.existingBusiness : null,
                        ),
                      );
                },
              ),
              const Gap.xs(),
              ChoiceChip(
                label: const Text('طلبات استثمار'),
                selected: filter.type == ProjectType.investmentRequest,
                onSelected: (val) {
                  ref.read(projectFilterProvider.notifier).update(
                        (c) => c.copyWith(
                          type: () => val ? ProjectType.investmentRequest : null,
                        ),
                      );
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Project List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(projectsListProvider.future),
            child: projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rocket_launch_outlined,
                          size: 64,
                          color: context.colors.outline,
                        ),
                        const Gap.md(),
                        Text(
                          'لا توجد مشاريع مطابقة للبحث حالياً',
                          style: context.textStyles.titleMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const Gap.sm(),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('كن أول من يضيف مشروعاً'),
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
                      child: InkWell(
                        onTap: () => context.push(
                          '/network/project/${project.id}',
                        ),
                        borderRadius: AppRadius.mediumAll,
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
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colors.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      project.categoryNameAr ?? 'ريادة أعمال',
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
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colors.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
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
                                style: context.textStyles.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap.xxs(),
                              Text(
                                project.summary,
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap.sm(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'المطلوب: ${project.helpNeededType}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                              const Gap.md(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'بواسطة: ${project.ownerName ?? "مؤسس"}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.send_rounded, size: 14),
                                    label: const Text('طلب تواصل'),
                                    onPressed: () =>
                                        SendContactRequestDialog.show(
                                      context,
                                      receiverId: project.ownerId,
                                      receiverName:
                                          project.ownerName ?? 'صاحب المشروع',
                                      projectId: project.id,
                                      projectName: project.name,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Tab 2: Verified Investors Directory
// -----------------------------------------------------------------------------
class _InvestorsDirectoryTab extends ConsumerStatefulWidget {
  const _InvestorsDirectoryTab();

  @override
  ConsumerState<_InvestorsDirectoryTab> createState() =>
      _InvestorsDirectoryTabState();
}

class _InvestorsDirectoryTabState
    extends ConsumerState<_InvestorsDirectoryTab> {
  String? _selectedSector;

  final _sectors = const [
    'التقنية والبرمجيات',
    'التجارة الإلكترونية',
    'الأغذية والمشروبات',
    'الخدمات اللوجستية',
    'العقارات والتطوير',
    'الخدمات المالية (FinTech)',
  ];

  @override
  Widget build(BuildContext context) {
    final investorsAsync =
        ref.watch(investorsListProvider(_selectedSector));

    return Column(
      children: [
        // Sector Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('كافة القطاعات'),
                selected: _selectedSector == null,
                onSelected: (val) {
                  if (val) setState(() => _selectedSector = null);
                },
              ),
              ..._sectors.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(s),
                      selected: _selectedSector == s,
                      onSelected: (val) {
                        setState(() => _selectedSector = val ? s : null);
                      },
                    ),
                  )),
            ],
          ),
        ),
        const Divider(height: 1),

        // Investors List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(investorsListProvider(_selectedSector).future),
            child: investorsAsync.when(
              data: (investors) {
                if (investors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 64,
                          color: context.colors.outline,
                        ),
                        const Gap.md(),
                        Text(
                          'لا يوجد مستثمرون مسجلون في هذا القطاع حالياً',
                          style: context.textStyles.titleMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const Gap.sm(),
                        FilledButton.icon(
                          icon: const Icon(Icons.badge_outlined),
                          label: const Text('سجل كأول مستثمر'),
                          onPressed: () =>
                              context.push(AppRoutes.editInvestorProfile),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: AppSpacing.page,
                  itemCount: investors.length,
                  itemBuilder: (context, index) {
                    final investor = investors[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: context.colors.outlineVariant),
                        borderRadius: AppRadius.mediumAll,
                      ),
                      child: InkWell(
                        onTap: () => context.push(
                          '/network/investor/${investor.userId}',
                        ),
                        borderRadius: AppRadius.mediumAll,
                        child: Padding(
                          padding: AppSpacing.card,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        context.colors.primaryContainer,
                                    child: Text(
                                      investor.fullName?.isNotEmpty == true
                                          ? investor.fullName![0]
                                          : 'I',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: context
                                            .colors.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const Gap.sm(),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              investor.fullName ??
                                                  'مستثمر معتمد',
                                              style: context
                                                  .textStyles.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (investor.isVerified) ...[
                                              const Gap.xxs(),
                                              Icon(
                                                Icons.verified_rounded,
                                                size: 16,
                                                color: Colors.green.shade700,
                                              ),
                                            ],
                                          ],
                                        ),
                                        Text(
                                          investor.investorType,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.colors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (investor.showFinancialRangePublicly &&
                                      investor.minTicketSize != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colors.primaryContainer
                                            .withValues(alpha: 0.4),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'من ${investor.minTicketSize!.toStringAsFixed(0)} ${investor.currency}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: context.colors.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (investor.bio != null &&
                                  investor.bio!.isNotEmpty) ...[
                                const Gap.sm(),
                                Text(
                                  investor.bio!,
                                  style: context.textStyles.bodySmall?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (investor.sectorsOfInterest.isNotEmpty) ...[
                                const Gap.sm(),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: investor.sectorsOfInterest
                                      .take(3)
                                      .map((s) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: context.colors
                                                  .surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              s,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: context
                                                    .colors.onSurfaceVariant,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                              const Gap.md(),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.send_rounded, size: 14),
                                  label: const Text('طلب تواصل'),
                                  onPressed: () =>
                                      SendContactRequestDialog.show(
                                    context,
                                    receiverId: investor.userId,
                                    receiverName:
                                        investor.fullName ?? 'المستثمر',
                                  ),
                                ),
                              ),
                            ],
                          ),
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
        ),
      ],
    );
  }
}
