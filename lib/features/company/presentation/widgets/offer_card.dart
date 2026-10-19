import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    required this.offer,
    super.key,
    this.isOwner = false,
    this.onTap,
    this.onDuplicate,
    this.onTogglePause,
    this.onViewReview,
  });

  final CompanyOffer offer;
  final bool isOwner;
  final VoidCallback? onTap;
  final VoidCallback? onDuplicate;
  final VoidCallback? onTogglePause;
  final VoidCallback? onViewReview;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (offer.status) {
      OfferStatus.approved => context.colors.primary,
      OfferStatus.inReview => const Color(0xFFE5A93C),
      OfferStatus.needsChanges => context.colors.error,
      OfferStatus.draft => context.colors.outline,
      OfferStatus.paused => context.colors.onSurfaceVariant,
      OfferStatus.expired => context.colors.error,
      OfferStatus.rejected => context.colors.error,
      OfferStatus.archived => context.colors.outline,
    };

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(
          color: context.colors.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status chip + Popup Menu (for owners)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      offer.status.labelAr,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isOwner)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      onSelected: (val) {
                        switch (val) {
                          case 'duplicate':
                            onDuplicate?.call();
                          case 'toggle_pause':
                            onTogglePause?.call();
                          case 'review_status':
                            onViewReview?.call();
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.content_copy_rounded, size: 18),
                              Gap.xs(),
                              Text('نسخ العرض ✦'),
                            ],
                          ),
                        ),
                        if (offer.status == OfferStatus.approved ||
                            offer.status == OfferStatus.paused)
                          PopupMenuItem(
                            value: 'toggle_pause',
                            child: Row(
                              children: [
                                Icon(
                                  offer.status == OfferStatus.paused
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_rounded,
                                  size: 18,
                                ),
                                const Gap.xs(),
                                Text(
                                  offer.status == OfferStatus.paused
                                      ? 'استئناف النشر'
                                      : 'إيقاف مؤقت',
                                ),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'review_status',
                          child: Row(
                            children: [
                              Icon(Icons.rule_folder_rounded, size: 18),
                              Gap.xs(),
                              Text('متابعة حالة المراجعة'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const Gap.xs(),

              // Title & Service Type
              Text(
                offer.title,
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap.xxs(),
              Text(
                offer.serviceType,
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const Gap.sm(),

              // Price
              Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 18,
                    color: context.colors.primary,
                  ),
                  const Gap.xxs(),
                  Text(
                    offer.isPriceOnDemand
                        ? 'السعر عند الطلب'
                        : '${offer.price?.toStringAsFixed(0)} ${offer.priceCurrency}',
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
              const Gap.sm(),
              const Divider(height: 1),
              const Gap.xs(),

              // Metrics & Target cities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: context.colors.outline,
                      ),
                      const Gap.xxs(),
                      Text(
                        '${offer.viewsCount}',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: context.colors.outline,
                        ),
                      ),
                      const Gap.md(),
                      Icon(
                        Icons.people_outline_rounded,
                        size: 14,
                        color: context.colors.outline,
                      ),
                      const Gap.xxs(),
                      Text(
                        '${offer.leadsCount} مهتم',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: context.colors.outline,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    offer.targetCities.join('، '),
                    style: context.textStyles.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
