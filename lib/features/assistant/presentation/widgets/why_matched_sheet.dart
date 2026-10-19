import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/assistant/domain/models/match_result.dart';

/// Screen 37: Explainable Breakdown Bottom Sheet ("لماذا ظهرت هذه الفرصة؟")
class WhyMatchedSheet extends StatelessWidget {
  const WhyMatchedSheet({required this.match, super.key});

  final MatchResult match;

  static Future<void> show(BuildContext context, MatchResult match) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      builder: (_) => WhyMatchedSheet(match: match),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outlineVariant,
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ),
            const Gap.md(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: match.isFullMatch
                        ? context.appColors.success.color.withValues(alpha: 0.15)
                        : context.appColors.warning.color.withValues(alpha: 0.15),
                    borderRadius: AppRadius.smallAll,
                  ),
                  child: Icon(
                    match.isFullMatch
                        ? Icons.verified_rounded
                        : Icons.info_outline_rounded,
                    color: match.isFullMatch
                        ? context.appColors.success.color
                        : context.appColors.warning.color,
                  ),
                ),
                const Gap.sm(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'شفافية التوصية الذكية',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'استوفت ${match.criteriaMetCount} من أصل ${match.totalCriteriaCount} معايير أساسية',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap.lg(),
            Text(
              match.titleAr,
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.sm(),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: AppRadius.mediumAll,
              ),
              child: Text(
                match.explanationAr.isNotEmpty
                    ? match.explanationAr
                    : 'تم فحص هذه الفرصة عبر المحرك الاستثماري بناءً على قيود الميزانية، الوقت، والمخاطرة المحددة.',
                style: context.textStyles.bodyMedium,
              ),
            ),
            const Gap.lg(),
            if (match.matchReasons.isNotEmpty) ...[
              Text(
                'المعايير المتوافقة بنجاح ✅',
                style: context.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.appColors.success.color,
                ),
              ),
              const Gap.xs(),
              ...match.matchReasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                        color: context.appColors.success.color,
                      ),
                      const Gap.xs(),
                      Expanded(
                        child: Text(
                          reason,
                          style: context.textStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap.md(),
            ],
            if (match.missingCriteria.isNotEmpty) ...[
              Text(
                'نقاط تحتاج منك انتباهاً ⚠️',
                style: context.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.appColors.warning.color,
                ),
              ),
              const Gap.xs(),
              ...match.missingCriteria.map(
                (miss) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: context.appColors.warning.color,
                      ),
                      const Gap.xs(),
                      Expanded(
                        child: Text(
                          miss,
                          style: context.textStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap.md(),
            ],
            const Gap.lg(),
            AppButton(
              text: 'إغلاق',
              isFullWidth: true,
              variant: AppButtonVariant.outlined,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
