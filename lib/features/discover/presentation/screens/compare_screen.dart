import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/states/data_quality_badge.dart';
import 'package:moneyideas/core/widgets/states/empty_state.dart';
import 'package:moneyideas/features/discover/presentation/controllers/discover_controller.dart';

/// Screen 26: Side-by-side interactive comparison matrix for up to 3 opportunities.
class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final compareList = ref.watch(compareListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مقارنة الفرص (${compareList.length}/3)',
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (compareList.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(compareListProvider.notifier).clearCompare();
              },
              child: Text(
                l10n.commonClear,
                style: TextStyle(color: context.colors.error),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: compareList.isEmpty
            ? EmptyState(
                title: 'لا توجد فرص محددة للمقارنة',
                message:
                    'تصفح سوق الفرص واضغط على أيقونة المقارنة على أي فرصة لتحديد ما يصل إلى 3 فرص ومقارنتها جنبًا إلى جنب.',
                actionLabel: 'استكشف الفرص',
                onAction: () => context.pop(),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowHeight: 80,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 56,
                    border: TableBorder.all(
                      color: context.colors.outlineVariant.withValues(alpha: 0.5),
                      borderRadius: AppRadius.mediumAll,
                    ),
                    columnSpacing: 24,
                    columns: [
                      const DataColumn(
                        label: Text(
                          'المعيار',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...compareList.map((opp) {
                        return DataColumn(
                          label: SizedBox(
                            width: 140,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  opp.titleAr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Gap.xxs(),
                                InkWell(
                                  onTap: () {
                                    ref
                                        .read(compareListProvider.notifier)
                                        .toggleCompare(opp);
                                  },
                                  child: Text(
                                    'إزالة',
                                    style: TextStyle(
                                      color: context.colors.error,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    rows: [
                      // Data Quality
                      DataRow(
                        cells: [
                          const DataCell(Text('مصداقية البيانات')),
                          ...compareList.map(
                            (opp) => DataCell(
                              DataQualityBadge.fromStatus(
                                opp.dataQualityStatus,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Min Capital
                      DataRow(
                        cells: [
                          const DataCell(Text('رأس المال الأدنى')),
                          ...compareList.map(
                            (opp) => DataCell(
                              Text(
                                '${opp.minCapital.toStringAsFixed(0)} ${opp.currency}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Max Capital
                      DataRow(
                        cells: [
                          const DataCell(Text('سقف رأس المال')),
                          ...compareList.map(
                            (opp) => DataCell(
                              Text(
                                '${opp.maxCapital.toStringAsFixed(0)} ${opp.currency}',
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Risk
                      DataRow(
                        cells: [
                          const DataCell(Text('درجة المخاطرة')),
                          ...compareList.map(
                            (opp) => DataCell(
                              Text(
                                switch (opp.riskLevel.toLowerCase()) {
                                  'low' => 'منخفضة',
                                  'medium' => 'متوسطة',
                                  'high' => 'عالية',
                                  _ => opp.riskLevel,
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Weekly Hours
                      DataRow(
                        cells: [
                          const DataCell(Text('الوقت الأسبوعي')),
                          ...compareList.map(
                            (opp) => DataCell(
                              Text('${opp.weeklyHoursRequired} س/أسبوع'),
                            ),
                          ),
                        ],
                      ),
                      // Management Type
                      DataRow(
                        cells: [
                          const DataCell(Text('طبيعة الإدارة')),
                          ...compareList.map(
                            (opp) => DataCell(
                              Text(
                                opp.managementType == 'active'
                                    ? 'تشغيل مباشر'
                                    : 'استثمار سلبي',
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Location
                      DataRow(
                        cells: [
                          const DataCell(Text('السوق المستهدف')),
                          ...compareList.map(
                            (opp) => DataCell(Text(opp.city)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
