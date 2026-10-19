import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/validation/rules/number_rules.dart';
import 'package:moneyideas/core/validation/validators.dart';
import 'package:moneyideas/core/widgets/inputs/app_text_field.dart';
import 'package:moneyideas/features/profile_setup/presentation/controllers/profile_setup_controller.dart';

/// Screen 12: Budget and Capital Definition (Supports "Zero Capital" option).
class StepBudgetWidget extends ConsumerStatefulWidget {
  const StepBudgetWidget({super.key});

  @override
  ConsumerState<StepBudgetWidget> createState() => _StepBudgetWidgetState();
}

class _StepBudgetWidgetState extends ConsumerState<StepBudgetWidget> {
  late TextEditingController _budgetController;
  late TextEditingController _ceilingController;

  @override
  void initState() {
    super.initState();
    final data = ref.read(profileSetupProvider);
    _budgetController = TextEditingController(
      text: data.hasNoCapital ? '0' : data.budgetAmount.toStringAsFixed(0),
    );
    _ceilingController = TextEditingController(
      text: data.budgetCeiling != null
          ? data.budgetCeiling!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _ceilingController.dispose();
    super.dispose();
  }

  void _onValuesChanged(bool hasNoCapital) {
    final amount = hasNoCapital
        ? 0.0
        : (NumberRules.parse(_budgetController.text) ?? 0).toDouble();
    final ceiling = _ceilingController.text.isNotEmpty
        ? (NumberRules.parse(_ceilingController.text) ?? 0).toDouble()
        : null;

    ref.read(profileSetupProvider.notifier).updateBudget(
          amount: amount,
          hasNoCapital: hasNoCapital,
          ceiling: ceiling,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final setupData = ref.watch(profileSetupProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.setupStepBudget,
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          l10n.setupStepBudgetDesc,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.xl(),

        // "No Capital" Switch
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l10n.setupNoCapital,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text(
            'سيتم توجيهك لأفكار المشاريع الرقمية والخدمية القائمة على المهارة الشخصية',
          ),
          value: setupData.hasNoCapital,
          onChanged: (val) {
            if (val) _budgetController.text = '0';
            _onValuesChanged(val);
          },
        ),
        const Gap.lg(),

        if (!setupData.hasNoCapital) ...[
          // Budget Amount
          AppTextField(
            controller: _budgetController,
            label: '${l10n.setupBudgetAmount} (${setupData.currency})',
            hint: 'مثال: 1,500',
            prefixIcon: AppIcons.budget,
            keyboardType: TextInputType.number,
            validator: Validators.money(context, allowZero: true),
            onChanged: (_) => _onValuesChanged(false),
          ),
          const Gap.md(),

          // Ceiling
          AppTextField(
            controller: _ceilingController,
            label: '${l10n.setupBudgetCeiling} (${setupData.currency})',
            hint: 'مثال: 5,000',
            prefixIcon: AppIcons.budget,
            keyboardType: TextInputType.number,
            onChanged: (_) => _onValuesChanged(false),
          ),
        ],
      ],
    );
  }
}
