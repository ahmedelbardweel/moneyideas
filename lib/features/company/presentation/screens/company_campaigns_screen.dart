import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/company/presentation/controllers/company_controller.dart';

class CompanyCampaignsScreen extends ConsumerWidget {
  const CompanyCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(companyCampaignsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الحملات الإعلانية الممولة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Regulatory & Transparency Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.secondaryContainer.withOpacity(0.4),
                borderRadius: AppRadius.lgAll,
                border: Border.all(
                  color: context.colors.secondary.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.campaign_rounded,
                    color: context.colors.secondary,
                    size: 28,
                  ),
                  const Gap.sm(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'شفافية الإعلانات الممولة',
                          style: context.textStyles.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSecondaryContainer,
                          ),
                        ),
                        const Gap.xxs(),
                        Text(
                          'الحملات الإعلانية الممولة معزولة كلياً عن نتائج وتوصيات «المستشار الذكي» ومحرك المطابقة، وتُميَّز دائماً بوسم «إعلان ممول» وتخضع لموافقة الإدارة المسبقة وضوابط الإعلانات التجارية في دولة الإمارات.',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap.xl(),

            // Campaigns List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'حملاتك الإعلانية',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('طلب حملة ممولة'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'باقات الترويج والإعلانات الممولة ستتوفر قريباً للشركات الموثقة رسمياً.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Gap.sm(),

            campaignsAsync.when(
              data: (campaigns) {
                if (campaigns.isEmpty) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.lgAll,
                      side: BorderSide(
                        color: context.colors.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.ads_click_rounded,
                            size: 48,
                            color: context.colors.outline,
                          ),
                          const Gap.md(),
                          const Text('لا توجد حملات إعلانية نشطة حالياً'),
                          const Gap.xs(),
                          Text(
                            'تساعدك الحملات الممولة على رفع ظهور عروضك في أعلى نتائج البحث العامة وواجهة الاستكشاف.',
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: campaigns.map((c) {
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                        side: BorderSide(
                          color: context.colors.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  c.campaignTitle,
                                  style: context.textStyles.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: c.adminApproved
                                        ? context.colors.primary.withOpacity(0.12)
                                        : const Color(0xFFFFF4E5),
                                    borderRadius: AppRadius.smAll,
                                  ),
                                  child: Text(
                                    c.adminApproved ? 'نشطة' : 'قيد التدقيق',
                                    style: TextStyle(
                                      color: c.adminApproved
                                          ? context.colors.primary
                                          : const Color(0xFFE5A93C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap.sm(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('الظهور: ${c.totalImpressions}'),
                                Text('النقرات: ${c.totalClicks}'),
                                Text('المدن: ${c.targetCities.join(', ')}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('خطأ: $err')),
            ),
          ],
        ),
      ),
    );
  }
}
