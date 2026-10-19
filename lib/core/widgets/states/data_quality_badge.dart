import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';

enum DataQualityType {
  verified,
  estimated,
  needsUpdate,
  sponsored,
}

/// Distinct badge to communicate information reliability & transparency:
/// - Verified: Authenticated official sources
/// - Estimated: Feasibility approximations
/// - NeedsUpdate: Stale prices / expired offers
/// - Sponsored: Paid business offers (never mixed invisibly into organic matching)
class DataQualityBadge extends StatelessWidget {
  const DataQualityBadge({
    required this.type,
    super.key,
    this.customLabel,
  });

  const DataQualityBadge.verified({super.key, this.customLabel})
      : type = DataQualityType.verified;

  const DataQualityBadge.estimated({super.key, this.customLabel})
      : type = DataQualityType.estimated;

  const DataQualityBadge.needsUpdate({super.key, this.customLabel})
      : type = DataQualityType.needsUpdate;

  const DataQualityBadge.sponsored({super.key, this.customLabel})
      : type = DataQualityType.sponsored;

  factory DataQualityBadge.fromStatus(
    String status, {
    Key? key,
    String? customLabel,
  }) {
    switch (status) {
      case 'estimated':
        return DataQualityBadge.estimated(key: key, customLabel: customLabel);
      case 'needs_update':
        return DataQualityBadge.needsUpdate(key: key, customLabel: customLabel);
      case 'sponsored':
        return DataQualityBadge.sponsored(key: key, customLabel: customLabel);
      case 'verified':
      default:
        return DataQualityBadge.verified(key: key, customLabel: customLabel);
    }
  }

  final DataQualityType type;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    final (SemanticColor semantic, IconData icon, String defaultLabel) =
        switch (type) {
      DataQualityType.verified => (
          context.appColors.success,
          AppIcons.verified,
          context.l10n.dataVerified,
        ),
      DataQualityType.estimated => (
          context.appColors.warning,
          AppIcons.estimated,
          context.l10n.dataEstimated,
        ),
      DataQualityType.needsUpdate => (
          context.appColors.warning,
          AppIcons.needsUpdate,
          context.l10n.dataNeedsUpdate,
        ),
      DataQualityType.sponsored => (
          context.appColors.sponsored,
          AppIcons.sponsored,
          context.l10n.sponsoredAd,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: semantic.container,
        borderRadius: AppRadius.smallAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSmall, color: semantic.onContainer),
          const Gap.xs(),
          Text(
            customLabel ?? defaultLabel,
            style: context.textStyles.labelSmall?.copyWith(
              color: semantic.onContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
