import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/assistant/presentation/controllers/assistant_controller.dart';

/// Screen 38: Live Scenario Simulator Bottom Sheet ("تغيير السيناريو 🔄")
class ScenarioSimulatorSheet extends ConsumerStatefulWidget {
  const ScenarioSimulatorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      builder: (_) => const ScenarioSimulatorSheet(),
    );
  }

  @override
  ConsumerState<ScenarioSimulatorSheet> createState() =>
      _ScenarioSimulatorSheetState();
}

class _ScenarioSimulatorSheetState
    extends ConsumerState<ScenarioSimulatorSheet> {
  late double _budget;
  late int _hours;
  late bool _hasNoCapital;

  @override
  void initState() {
    super.initState();
    final current = ref.read(assistantControllerProvider);
    _budget = current.budget;
    _hours = current.weeklyHours;
    _hasNoCapital = current.hasNoCapital;
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
                Icon(
                  Icons.tune_rounded,
                  color: context.colors.primary,
                ),
                const Gap.xs(),
                Text(
                  'محاكي السيناريوهات البديلة',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Gap.xs(),
            Text(
              'جرّب زيادة الميزانية أو تعديل ساعاتك الأسبوعية لملاحظة الفرص التي قد تصبح متاحة لك فوراً.',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Gap.lg(),

            // Has No Capital Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('أريد نموذجاً بدون رأس مال نهائياً'),
              subtitle: const Text('أفكار تعتمد على المهارة والخدمات'),
              value: _hasNoCapital,
              onChanged: (val) {
                setState(() {
                  _hasNoCapital = val;
                  if (val) _budget = 0;
                });
              },
            ),
            const Gap.md(),

            // Budget Slider
            if (!_hasNoCapital) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('رأس المال المتوقع:'),
                  Text(
                    '${_budget.toStringAsFixed(0)} درهم',
                    style: context.textStyles.titleSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _budget.clamp(0.0, 150000.0),
                max: 150000,
                divisions: 30,
                label: '${_budget.round()} AED',
                onChanged: (val) => setState(() => _budget = val),
              ),
              const Gap.md(),
            ],

            // Weekly Hours Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الوقت المتاح أسبوعياً:'),
                Text(
                  '$_hours ساعات',
                  style: context.textStyles.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _hours.toDouble().clamp(5.0, 50.0),
              min: 5,
              max: 50,
              divisions: 9,
              label: '$_hours ساعة',
              onChanged: (val) => setState(() => _hours = val.round()),
            ),
            const Gap.xl(),

            AppButton(
              text: 'إعادة التحليل بهذا السيناريو',
              isFullWidth: true,
              onPressed: () {
                unawaited(
                  ref.read(assistantControllerProvider.notifier).simulateScenario(
                        newBudget: _budget,
                        newHours: _hours,
                        noCapital: _hasNoCapital,
                      ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
