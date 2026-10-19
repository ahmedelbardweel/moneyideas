import 'package:flutter/material.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';

/// Screen 78: Transparent Subscription Plans and Tier Upgrades.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الباقات والترقية'),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            Text(
              'اختر الباقة المناسبة لطموحك',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap.xs(),
            Text(
              'شفافية كاملة في الأسعار والمزايا دون أي رسوم خفية أو تجديد قسري.',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap.xl(),

            // Plan 1: Free
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: context.colors.outlineVariant),
                borderRadius: AppRadius.mediumAll,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الباقة الأساسية',
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer,
                            borderRadius: AppRadius.fullAll,
                          ),
                          child: const Text('باقتك الحالية', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const Gap.xs(),
                    Text('مجانية دائماً', style: context.textStyles.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Gap.md(),
                    const _PlanFeature(text: 'استكشاف جميع الأفكار والفرص المتاحة'),
                    const _PlanFeature(text: 'استخدام المستشار الذكي لتحليل ميزانيتك'),
                    const _PlanFeature(text: 'حفظ ما يصل إلى 10 فرص ومقارنتها'),
                  ],
                ),
              ),
            ),
            const Gap.lg(),

            // Plan 2: Pro Investor
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: context.colors.primary, width: 2),
                borderRadius: AppRadius.mediumAll,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المستثمر المحترف',
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: AppRadius.fullAll,
                          ),
                          child: const Text(
                            'الأكثر طلباً ⭐',
                            style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Gap.xs(),
                    Text('149 درهم / شهر', style: context.textStyles.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Gap.md(),
                    const _PlanFeature(text: 'جميع مزايا الباقة الأساسية'),
                    const _PlanFeature(text: 'الاطلاع على دراسات الجدوى والأسعار الموثقة'),
                    const _PlanFeature(text: 'تواصل مباشر وغير محدود مع أصحاب المشاريع'),
                    const _PlanFeature(text: 'تنبيهات فورية بالفرص الحصرية ذات العائد المرتفع'),
                    const Gap.lg(),
                    AppButton(
                      text: 'الترقية للباقة المحترفة',
                      isFullWidth: true,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('سيتم توفير بوابات الدفع قريباً')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanFeature extends StatelessWidget {
  const _PlanFeature({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: context.colors.primary),
          const Gap.xs(),
          Expanded(child: Text(text, style: context.textStyles.bodyMedium)),
        ],
      ),
    );
  }
}
