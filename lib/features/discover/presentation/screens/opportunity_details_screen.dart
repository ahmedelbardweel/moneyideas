import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/locale_provider.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/core/widgets/states/data_quality_badge.dart';
import 'package:moneyideas/features/discover/domain/models/opportunity.dart';
import 'package:moneyideas/features/discover/presentation/controllers/discover_controller.dart';

/// Screen 20-25: Multi-tab comprehensive Opportunity Details.
class OpportunityDetailsScreen extends ConsumerStatefulWidget {
  const OpportunityDetailsScreen({required this.opportunityId, super.key});

  final String opportunityId;

  @override
  ConsumerState<OpportunityDetailsScreen> createState() =>
      _OpportunityDetailsScreenState();
}

class _OpportunityDetailsScreenState
    extends ConsumerState<OpportunityDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Opportunity? _opportunity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    unawaited(_loadOpportunity());
  }

  Future<void> _loadOpportunity() async {
    final repo = ref.read(opportunityRepositoryProvider);
    final res = await repo.getOpportunityById(widget.opportunityId);
    if (mounted) {
      setState(() {
        _opportunity = res.when(
          success: (data) => data,
          failure: (_) => null,
        );
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider).languageCode;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_opportunity == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('الفرصة غير متوفرة')),
      );
    }

    final opp = _opportunity!;
    final isSaved = ref.watch(savedOpportunitiesProvider).contains(opp.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          opp.localizedTitle(locale),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'حفظ الفرصة',
            icon: Icon(
              isSaved ? AppIcons.save : AppIcons.saveOutline,
              color: isSaved ? context.colors.primary : null,
            ),
            onPressed: () {
              ref.read(savedOpportunitiesProvider.notifier).toggleSave(opp.id);
            },
          ),
          IconButton(
            tooltip: 'مقارنة',
            icon: const Icon(AppIcons.compare),
            onPressed: () {
              final added =
                  ref.read(compareListProvider.notifier).toggleCompare(opp);
              if (added) {
                unawaited(context.push(AppRoutes.compare));
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'التكاليف'),
            Tab(text: 'المخاطر'),
            Tab(text: 'المصادر'),
            Tab(text: 'خارطة الطريق'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(opportunity: opp),
          _CostsTab(opportunity: opp),
          _RisksTab(opportunity: opp),
          _SourcesTab(opportunity: opp),
          _RoadmapTab(opportunity: opp),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.colors.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رأس المال المطلوب',
                    style: context.textStyles.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${opp.minCapital.toStringAsFixed(0)} ${opp.currency}',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: AppButton(
                text: 'إضافة لخطة عملي',
                icon: AppIcons.check,
                onPressed: () {
                  unawaited(context.push(AppRoutes.nextSteps));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab 1: Overview (Screen 20)
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.opportunity});
  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataQualityBadge.fromStatus(opportunity.dataQualityStatus),
          const Gap.sm(),
          Text(
            opportunity.titleAr,
            style: context.textStyles.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap.xs(),
          Text(
            opportunity.summaryAr,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const Gap.lg(),

          // Explainable Matching Card ("لماذا تناسبك؟")
          if (opportunity.explanationPoints.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.35),
                borderRadius: AppRadius.largeAll,
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        AppIcons.why,
                        color: context.colors.primary,
                        size: AppSizes.iconMedium,
                      ),
                      const Gap.sm(),
                      Text(
                        'لماذا تناسبك هذه الفرصة؟',
                        style: context.textStyles.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Gap.sm(),
                  ...opportunity.explanationPoints.map((reason) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            AppIcons.check,
                            size: 16,
                            color: context.colors.primary,
                          ),
                          const Gap.xs(),
                          Expanded(
                            child: Text(
                              reason,
                              style: context.textStyles.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Gap.lg(),
          ],

          // Quick Specs Grid
          Text(
            'المواصفات والمتطلبات الأساسية',
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap.sm(),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mediumAll,
              side: BorderSide(color: context.colors.outlineVariant),
            ),
            child: Column(
              children: [
                _SpecRow(
                  icon: AppIcons.budget,
                  label: 'رأس المال المبدئي',
                  value:
                      '${opportunity.minCapital.toStringAsFixed(0)} - ${opportunity.maxCapital.toStringAsFixed(0)} ${opportunity.currency}',
                ),
                const Divider(height: 1),
                _SpecRow(
                  icon: AppIcons.time,
                  label: 'الوقت الأسبوعي المطلوب',
                  value: '${opportunity.weeklyHoursRequired} ساعة / أسبوع',
                ),
                const Divider(height: 1),
                _SpecRow(
                  icon: AppIcons.experience,
                  label: 'مستوى الخبرة',
                  value: opportunity.experienceLevel == 'beginner'
                      ? 'مبتدئ (لا يتطلب خبرة مسبقة)'
                      : opportunity.experienceLevel,
                ),
                const Divider(height: 1),
                _SpecRow(
                  icon: AppIcons.risk,
                  label: 'درجة المخاطرة',
                  value: opportunity.riskLevel,
                ),
                const Divider(height: 1),
                _SpecRow(
                  icon: AppIcons.location,
                  label: 'السوق المستهدف',
                  value: '${opportunity.city} (${opportunity.country})',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSmall, color: context.colors.primary),
          const Gap.sm(),
          Expanded(
            child: Text(label, style: context.textStyles.bodySmall),
          ),
          Text(
            value,
            style: context.textStyles.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 2: Costs (Screen 21)
class _CostsTab extends StatelessWidget {
  const _CostsTab({required this.opportunity});
  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final totalCosts = opportunity.costs.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل التكاليف ورأس المال',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap.xs(),
          Text(
            'جميع التكاليف مفصلة ومرتبطة بجهات حكومية ورسوم موثقة، والتقديرات مميزة بوضوح.',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const Gap.md(),

          ...opportunity.costs.map((cost) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mediumAll,
                side: BorderSide(color: context.colors.outlineVariant),
              ),
              child: ListTile(
                title: Text(
                  cost.titleAr,
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: cost.notesAr != null ? Text(cost.notesAr!) : null,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${cost.amount.toStringAsFixed(0)} ${opportunity.currency}',
                      style: context.textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                    Text(
                      cost.isEstimated ? 'تقديري' : 'موثق رسمياً',
                      style: context.textStyles.labelSmall?.copyWith(
                        color: cost.isEstimated
                            ? Colors.orange
                            : context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Gap.lg(),

          // Total Summary Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: AppRadius.mediumAll,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي التكلفة المتوقعة:',
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${totalCosts.toStringAsFixed(0)} ${opportunity.currency}',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 3: Risks (Screen 22)
class _RisksTab extends StatelessWidget {
  const _RisksTab({required this.opportunity});
  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مصفوفة المخاطر وأسئلة التحقق الحرجة',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap.xs(),
          Text(
            'قبل دفع أي مبلغ، راجع خطة تفادي المخاطر واطرح الأسئلة المحددة هنا.',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const Gap.md(),

          ...opportunity.risks.map((risk) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.largeAll,
                side: BorderSide(color: context.colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            risk.riskTitleAr,
                            style: context.textStyles.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: AppRadius.smallAll,
                          ),
                          child: Text(
                            'خطورة ${risk.severity}',
                            style: context.textStyles.labelSmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap.sm(),
                    Text(
                      'خطة التفادي والحل:',
                      style: context.textStyles.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      risk.mitigationAr,
                      style: context.textStyles.bodySmall,
                    ),
                    const Gap.md(),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: context.colors.tertiaryContainer.withValues(alpha: 0.3),
                        borderRadius: AppRadius.smallAll,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            AppIcons.help,
                            size: AppSizes.iconSmall,
                            color: context.colors.tertiary,
                          ),
                          const Gap.xs(),
                          Expanded(
                            child: Text(
                              'سؤال تحقق حاسم: ${risk.verificationQuestionAr}',
                              style: context.textStyles.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Tab 4: Sources (Screen 23)
class _SourcesTab extends StatelessWidget {
  const _SourcesTab({required this.opportunity});
  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: opportunity.sources.length,
      itemBuilder: (context, index) {
        final src = opportunity.sources[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mediumAll,
            side: BorderSide(color: context.colors.outlineVariant),
          ),
          child: ListTile(
            leading: const Icon(AppIcons.sources, color: Colors.blue),
            title: Text(
              src.nameAr,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('النوع: ${src.sourceType} • تاريخ التحقق: ${src.verifiedDate ?? '2026'}'),
            trailing: src.url != null
                ? const Icon(AppIcons.openExternal, size: AppSizes.iconSmall)
                : null,
          ),
        );
      },
    );
  }
}

/// Tab 5: Roadmap (Screen 24)
class _RoadmapTab extends StatelessWidget {
  const _RoadmapTab({required this.opportunity});
  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: opportunity.steps.length,
      itemBuilder: (context, index) {
        final step = opportunity.steps[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mediumAll,
            side: BorderSide(color: context.colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: context.colors.primary,
                  child: Text(
                    '${step.stepNumber}',
                    style: TextStyle(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Gap.md(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.titleAr,
                        style: context.textStyles.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap.xxs(),
                      Text(
                        step.descriptionAr,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const Gap.xs(),
                      Text(
                        'المدة المقدرة: ${step.estimatedDays ?? 1} أيام • التكلفة: ${step.estimatedCost?.toStringAsFixed(0) ?? 0} درهم',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
