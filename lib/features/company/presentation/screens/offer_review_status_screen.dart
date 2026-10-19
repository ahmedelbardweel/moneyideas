import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/company/data/repositories/company_repository.dart';
import 'package:moneyideas/features/company/domain/models/company_offer.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';

class OfferReviewStatusScreen extends ConsumerStatefulWidget {
  const OfferReviewStatusScreen({required this.offerId, super.key});

  final String offerId;

  @override
  ConsumerState<OfferReviewStatusScreen> createState() =>
      _OfferReviewStatusScreenState();
}

class _OfferReviewStatusScreenState
    extends ConsumerState<OfferReviewStatusScreen> {
  CompanyOffer? _offer;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadOffer());
  }

  Future<void> _loadOffer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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

  Future<void> _submitForReview() async {
    if (_offer == null) return;
    final repo = ref.read(companyRepositoryProvider);
    final res = await repo.updateOfferStatus(_offer!.id, OfferStatus.inReview);

    if (!mounted) return;
    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال العرض للمراجعة بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      ref.invalidate(companyOffersProvider);
      unawaited(_loadOffer());
    }
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
        appBar: AppBar(title: const Text('حالة المراجعة')),
        body: Center(
          child: Text(_errorMessage ?? 'تعذر العثور على العرض'),
        ),
      );
    }

    final offer = _offer!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('متابعة حالة مراجعة العرض'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Offer Info Card
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
                      offer.title,
                      style: context.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap.xxs(),
                    Text(
                      offer.serviceType,
                      style: TextStyle(color: context.colors.primary),
                    ),
                    const Gap.sm(),
                    Text(
                      offer.description,
                      style: context.textStyles.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Gap.xl(),

            Text(
              'مسار التدقيق والمراجعة الإدارية',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap.md(),

            // Review Timeline
            _TimelineTile(
              title: 'إنشاء مسودة العرض',
              subtitle: 'تم تجهيز الشروط والأسعار والبيانات الأساسية',
              isCompleted: true,
              isCurrent: offer.status == OfferStatus.draft,
            ),
            _TimelineTile(
              title: 'تقديم الطلب للتدقيق',
              subtitle: 'إرسال العرض لفريق الامتثال التجاري للمنصة',
              isCompleted: offer.status != OfferStatus.draft,
              isCurrent: offer.status == OfferStatus.inReview,
            ),
            _TimelineTile(
              title: 'مراجعة التراخيص وصياغة الشروط',
              subtitle: 'التأكد من عدم وجود وعود مضللة ومطابقة النشاط للرخصة',
              isCompleted: offer.status == OfferStatus.approved,
              isCurrent: offer.status == OfferStatus.inReview,
            ),
            _TimelineTile(
              title: 'الاعتماد والنشر في المنصة',
              subtitle: 'يصبح العرض ظاهراً لجميع الزوار مع شارة التوثيق',
              isCompleted: offer.status == OfferStatus.approved,
              isCurrent: offer.status == OfferStatus.approved,
              isLast: true,
            ),
            const Gap.lg(),

            // Admin Review Notes (if present)
            if (offer.adminReviewNotes != null &&
                offer.adminReviewNotes!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.errorContainer.withOpacity(0.2),
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: context.colors.error.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          color: context.colors.error,
                          size: 20,
                        ),
                        const Gap.xs(),
                        Text(
                          'ملاحظات فريق التدقيق والامتثال:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.colors.error,
                          ),
                        ),
                      ],
                    ),
                    const Gap.xs(),
                    Text(
                      offer.adminReviewNotes!,
                      style: TextStyle(color: context.colors.onErrorContainer),
                    ),
                  ],
                ),
              ),
              const Gap.lg(),
            ],

            // Action Buttons
            if (offer.status == OfferStatus.draft)
              AppButton(
                text: 'إرسال العرض للمراجعة الآن',
                onPressed: _submitForReview,
              )
            else if (offer.status == OfferStatus.approved)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withOpacity(0.3),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: context.colors.primary,
                    ),
                    const Gap.sm(),
                    const Expanded(
                      child: Text(
                        'هذا العرض معتمد ونشط حالياً في المنصة ويستقبل استفسارات العملاء.',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isCompleted
                  ? context.colors.primary
                  : isCurrent
                      ? const Color(0xFFE5A93C)
                      : context.colors.surfaceContainerHighest,
              child: Icon(
                isCompleted
                    ? Icons.check
                    : isCurrent
                        ? Icons.hourglass_empty_rounded
                        : Icons.circle,
                size: 14,
                color: isCompleted || isCurrent
                    ? Colors.white
                    : context.colors.outline,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? context.colors.primary
                    : context.colors.outlineVariant,
              ),
          ],
        ),
        const Gap.md(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? context.colors.primary : null,
                ),
              ),
              const Gap.xxs(),
              Text(
                subtitle,
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const Gap.sm(),
            ],
          ),
        ),
      ],
    );
  }
}
