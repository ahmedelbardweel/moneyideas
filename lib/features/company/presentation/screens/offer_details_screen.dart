import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/company/data/repositories/company_repository.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/presentation/widgets/lead_inquiry_sheet.dart';

class OfferDetailsScreen extends ConsumerStatefulWidget {
  const OfferDetailsScreen({required this.offerId, super.key});

  final String offerId;

  @override
  ConsumerState<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends ConsumerState<OfferDetailsScreen> {
  CompanyOffer? _offer;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadOffer());
  }

  Future<void> _loadOffer() async {
    final repo = ref.read(companyRepositoryProvider);
    final res = await repo.getPublicOffer(widget.offerId);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res.isSuccess) {
        _offer = res.valueOrNull;
      } else {
        _errorMessage = res.failureOrNull?.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _offer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل العرض')),
        body: Center(child: Text(_errorMessage ?? 'تعذر العثور على العرض')),
      );
    }

    final offer = _offer!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل العرض التجاري'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ رابط العرض للمشاركة')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: AppButton(
          text: 'طلب استفسار وتواصل مع الشركة',
          onPressed: () {
            unawaited(
              LeadInquirySheet.show(
                context,
                offerId: offer.id,
                offerTitle: offer.title,
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Company Banner Card (Clickable to company profile)
            InkWell(
              onTap: () => unawaited(
                context.push('/company/${offer.companyId}'),
              ),
              borderRadius: AppRadius.mdAll,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withOpacity(0.2),
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: context.colors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: context.colors.primary,
                      child: Text(
                        offer.companyTradeName?.characters.first ?? 'C',
                        style: TextStyle(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap.md(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                offer.companyTradeName ?? 'شركة معتمدة',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const Gap.xxs(),
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          const Gap.xxs(),
                          Text(
                            'اضغط لعرض ملف الشركة وجميع عروضها المعتمدة',
                            style: context.textStyles.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
              ),
            ),
            const Gap.lg(),

            // Title & Category
            Text(
              offer.title,
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            Row(
              children: [
                if (offer.categoryTitle != null) ...[
                  Chip(
                    label: Text(
                      offer.categoryTitle!,
                      style: const TextStyle(fontSize: 11),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  const Gap.xs(),
                ],
                Chip(
                  label: Text(
                    offer.serviceType,
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const Gap.md(),

            // Pricing Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lgAll,
                side: BorderSide(
                  color: context.colors.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التكلفة والتسعير',
                      style: context.textStyles.labelLarge?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const Gap.xs(),
                    Text(
                      offer.isPriceOnDemand
                          ? 'السعر عند الطلب (حسب المتطلبات)'
                          : '${offer.price?.toStringAsFixed(0)} ${offer.priceCurrency}',
                      style: context.textStyles.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                    if (offer.additionalFeesDescription != null) ...[
                      const Gap.xs(),
                      Text(
                        'ملاحظة: ${offer.additionalFeesDescription}',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Gap.lg(),

            // Description
            Text(
              'تفاصيل ومخرجات الخدمة',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            Text(
              offer.description,
              style: context.textStyles.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            const Gap.lg(),

            // Terms and Conditions
            Text(
              'الشروط والأحكام والضمانات',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.xs(),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLowest,
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: context.colors.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Text(
                offer.termsAndConditions,
                style: context.textStyles.bodySmall?.copyWith(
                  height: 1.5,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            const Gap.lg(),

            // Cities & Validity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16),
                    const Gap.xxs(),
                    Text(
                      'المدن: ${offer.targetCities.join('، ')}',
                      style: context.textStyles.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16),
                    const Gap.xxs(),
                    Text(
                      'صالح حتى: ${offer.validUntil.year}-${offer.validUntil.month.toString().padLeft(2, '0')}-${offer.validUntil.day.toString().padLeft(2, '0')}',
                      style: context.textStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const Gap.xxxl(),
          ],
        ),
      ),
    );
  }
}
