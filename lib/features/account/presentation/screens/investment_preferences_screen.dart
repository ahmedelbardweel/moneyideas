import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/account/presentation/controllers/account_controller.dart';

/// Screen 72: Investment Preferences editing screen with live persistence.
class InvestmentPreferencesScreen extends ConsumerStatefulWidget {
  const InvestmentPreferencesScreen({super.key});

  @override
  ConsumerState<InvestmentPreferencesScreen> createState() =>
      _InvestmentPreferencesScreenState();
}

class _InvestmentPreferencesScreenState
    extends ConsumerState<InvestmentPreferencesScreen> {
  late double _budget;
  late bool _hasNoCapital;
  late int _weeklyHours;
  late String _experience;
  late String _risk;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).asData?.value;
    _budget = profile?.budgetAmount ?? 10000;
    _hasNoCapital = profile?.hasNoCapital ?? false;
    _weeklyHours = profile?.weeklyHours ?? 10;
    _experience = profile?.experienceLevel ?? 'beginner';
    _risk = profile?.riskTolerance ?? 'low';
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final res = await ref
        .read(userProfileProvider.notifier)
        .updateInvestmentPreferences(
          budget: _budget,
          hasNoCapital: _hasNoCapital,
          weeklyHours: _weeklyHours,
          experience: _experience,
          risk: _risk,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تحديث تفضيلات الاستثمار بنجاح'),
          backgroundColor: context.appColors.success.color,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull?.debugMessage ?? 'فشل التحديث'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفضيلات الاستثمار'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // No Capital Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('لا أملك رأس مال حالياً'),
                subtitle: const Text('التركيز على الفرص المعتمدة على المهارة والخدمات'),
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
                    Text('الميزانية المتاحة:', style: context.textStyles.titleSmall),
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

              // Weekly Hours
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الوقت المتاح أسبوعياً:', style: context.textStyles.titleSmall),
                  Text(
                    '$_weeklyHours ساعات',
                    style: context.textStyles.titleSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _weeklyHours.toDouble().clamp(5.0, 50.0),
                min: 5,
                max: 50,
                divisions: 9,
                label: '$_weeklyHours ساعة',
                onChanged: (val) => setState(() => _weeklyHours = val.round()),
              ),
              const Gap.lg(),

              // Experience
              Text('مستوى الخبرة', style: context.textStyles.titleSmall),
              const Gap.xs(),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  ('beginner', 'مبتدئ'),
                  ('intermediate', 'متوسط'),
                  ('advanced', 'متقدم'),
                ].map((exp) {
                  final isSelected = _experience == exp.$1;
                  return ChoiceChip(
                    label: Text(exp.$2),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _experience = exp.$1);
                    },
                  );
                }).toList(),
              ),
              const Gap.lg(),

              // Risk Tolerance
              Text('درجة تحمل المخاطر', style: context.textStyles.titleSmall),
              const Gap.xs(),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  ('low', 'منخفضة (حفظ رأس المال)'),
                  ('medium', 'معتدلة (تذبذب معقول)'),
                  ('high', 'عالية (مخاطرة لنمو سريع)'),
                ].map((r) {
                  final isSelected = _risk == r.$1;
                  return ChoiceChip(
                    label: Text(r.$2),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _risk = r.$1);
                    },
                  );
                }).toList(),
              ),
              const Gap.xl(),

              AppButton(
                text: 'حفظ تفضيلات الاستثمار',
                isLoading: _isSaving,
                isFullWidth: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
