import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/company/domain/models/company.dart';

class CompanyVerificationBadge extends StatelessWidget {
  const CompanyVerificationBadge({
    required this.status,
    super.key,
    this.compact = false,
  });

  final CompanyVerificationStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status) {
      CompanyVerificationStatus.verified => (
          context.colors.primary,
          Icons.verified_rounded,
          'جهة موثقة رسمياً',
        ),
      CompanyVerificationStatus.pendingReview => (
          const Color(0xFFE5A93C),
          Icons.pending_actions_rounded,
          'قيد التدقيق',
        ),
      CompanyVerificationStatus.rejected => (
          context.colors.error,
          Icons.cancel_outlined,
          'مرفوض',
        ),
      CompanyVerificationStatus.unverified => (
          context.colors.outline,
          Icons.info_outline_rounded,
          'غير موثقة',
        ),
    };

    if (compact) {
      return Tooltip(
        message: label,
        child: Icon(icon, color: color, size: 18),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const Gap.xxs(),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
