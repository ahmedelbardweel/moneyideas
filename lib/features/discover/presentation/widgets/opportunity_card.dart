import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/locale_provider.dart';
import 'package:moneyideas/core/widgets/states/data_quality_badge.dart';
import 'package:moneyideas/features/discover/domain/models/opportunity.dart';
import 'package:moneyideas/features/discover/presentation/controllers/discover_controller.dart';

/// Comprehensive Material 3 card presenting an investment or business opportunity.
class OpportunityCard extends ConsumerWidget {
  const OpportunityCard({
    required this.opportunity,
    this.onTap,
    super.key,
  });

  final Opportunity opportunity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider).languageCode;
    final isSaved = ref.watch(savedOpportunitiesProvider).contains(opportunity.id);
    final isCompared = ref.watch(compareListProvider).any((o) => o.id == opportunity.id);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.largeAll,
        side: BorderSide(
          color: isCompared
              ? context.colors.primary
              : context.colors.outlineVariant.withValues(alpha: 0.6),
          width: isCompared ? 1.5 : 1,
        ),
      ),
      color: isCompared
          ? context.colors.primaryContainer.withValues(alpha: 0.15)
          : context.colors.surface,
      child: InkWell(
        borderRadius: AppRadius.largeAll,
        onTap: onTap ?? () => context.push('/opportunity/${opportunity.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Quality badge & Save action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DataQualityBadge.fromStatus(opportunity.dataQualityStatus),
                  Row(
                    children: [
                      // Compare Button
                      IconButton(
                        tooltip: 'مقارنة الفرصة',
                        icon: Icon(
                          isCompared
                              ? AppIcons.check
                              : AppIcons.compare,
                          color: isCompared
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                          size: AppSizes.iconSmall,
                        ),
                        onPressed: () {
                          final added = ref
                              .read(compareListProvider.notifier)
                              .toggleCompare(opportunity);
                          if (!added && !isCompared) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'الحد الأقصى للمقارنة هو 3 فرص معاً',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      // Save/Bookmark Button
                      IconButton(
                        tooltip: 'حفظ في المفضلة',
                        icon: Icon(
                          isSaved ? AppIcons.save : AppIcons.saveOutline,
                          color: isSaved
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                          size: AppSizes.iconSmall,
                        ),
                        onPressed: () {
                          ref
                              .read(savedOpportunitiesProvider.notifier)
                              .toggleSave(opportunity.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Gap.xs(),

              // Title
              Text(
                opportunity.localizedTitle(locale),
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap.xs(),

              // Summary
              Text(
                opportunity.localizedSummary(locale),
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap.md(),

              // Chips Row (Capital, Time, Risk)
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _MetricChip(
                    icon: AppIcons.budget,
                    label:
                        '${opportunity.minCapital.toStringAsFixed(0)} - ${opportunity.maxCapital.toStringAsFixed(0)} ${opportunity.currency}',
                    color: context.colors.primary,
                  ),
                  _MetricChip(
                    icon: AppIcons.time,
                    label: '${opportunity.weeklyHoursRequired} س/أسبوع',
                    color: context.colors.tertiary,
                  ),
                  _MetricChip(
                    icon: AppIcons.risk,
                    label: 'مخاطرة ${_riskLabel(opportunity.riskLevel)}',
                    color: _riskColor(context, opportunity.riskLevel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _riskLabel(String level) {
    switch (level) {
      case 'low':
        return 'منخفضة';
      case 'medium':
        return 'متوسطة';
      case 'high':
        return 'مرتفعة';
      default:
        return level;
    }
  }

  Color _riskColor(BuildContext context, String level) {
    switch (level) {
      case 'low':
        return context.colors.primary;
      case 'medium':
        return Colors.orange;
      case 'high':
        return context.colors.error;
      default:
        return context.colors.onSurfaceVariant;
    }
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.smallAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const Gap.xxs(),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
