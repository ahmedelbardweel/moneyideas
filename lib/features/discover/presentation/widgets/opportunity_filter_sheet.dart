import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';
import 'package:moneyideas/features/discover/presentation/controllers/discover_controller.dart';

/// Modal bottom sheet allowing advanced filtering of business opportunities.
class OpportunityFilterSheet extends ConsumerStatefulWidget {
  const OpportunityFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      builder: (_) => const OpportunityFilterSheet(),
    );
  }

  @override
  ConsumerState<OpportunityFilterSheet> createState() =>
      _OpportunityFilterSheetState();
}

class _OpportunityFilterSheetState
    extends ConsumerState<OpportunityFilterSheet> {
  late String? _selectedCategory;
  late String? _selectedRisk;
  late bool _isOnlyVerified;
  RangeValues _capitalRange = const RangeValues(0, 100000);

  @override
  void initState() {
    super.initState();
    final current = ref.read(opportunityFilterProvider);
    _selectedCategory = current.categoryId;
    _selectedRisk = current.riskLevel;
    _isOnlyVerified = current.isOnlyVerified;
    _capitalRange = RangeValues(
      current.minCapital ?? 0,
      current.maxCapital ?? 100000,
    );
  }

  void _apply() {
    ref.read(opportunityFilterProvider.notifier)
      ..setCategory(_selectedCategory)
      ..setCapitalRange(min: _capitalRange.start, max: _capitalRange.end)
      ..setRiskLevel(_selectedRisk)
      ..toggleOnlyVerified(value: _isOnlyVerified);

    Navigator.of(context).pop();
  }

  void _reset() {
    ref.read(opportunityFilterProvider.notifier).resetFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(categoriesListProvider);

    final risks = [
      ('low', l10n.riskLow),
      ('medium', l10n.riskMedium),
      ('high', l10n.riskHigh),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: AppSpacing.lg,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Drag handle
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.commonFilter,
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _reset,
                child: Text(
                  l10n.commonClear,
                  style: TextStyle(color: context.colors.error),
                ),
              ),
            ],
          ),
          const Divider(),
          const Gap.sm(),

          // Categories chips
          Text(
            'القطاع الاستثماري',
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap.xs(),
          categoriesAsync.when(
            data: (categories) => Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat.id;
                return ChoiceChip(
                  label: Text(cat.nameAr),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? cat.id : null;
                    });
                  },
                );
              }).toList(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          const Gap.lg(),

          // Capital Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'نطاق رأس المال',
                style: context.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_capitalRange.start.toStringAsFixed(0)} - ${_capitalRange.end.toStringAsFixed(0)} درهم',
                style: context.textStyles.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _capitalRange,
            max: 100000,
            divisions: 20,
            labels: RangeLabels(
              '${_capitalRange.start.round()} AED',
              '${_capitalRange.end.round()} AED',
            ),
            onChanged: (vals) => setState(() => _capitalRange = vals),
          ),
          const Gap.md(),

          // Risk Tolerance
          Text(
            l10n.setupRiskTolerance,
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap.xs(),
          Wrap(
            spacing: AppSpacing.xs,
            children: risks.map((r) {
              final isSelected = _selectedRisk == r.$1;
              return ChoiceChip(
                label: Text(r.$2),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedRisk = selected ? r.$1 : null;
                  });
                },
              );
            }).toList(),
          ),
          const Gap.md(),

          // Only verified toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.dataVerified,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            value: _isOnlyVerified,
            onChanged: (val) => setState(() => _isOnlyVerified = val),
          ),
          const Gap.xl(),

          // Submit
          AppButton(
            text: 'تطبيق الفلاتر',
            isFullWidth: true,
            onPressed: _apply,
          ),
        ],
      ),
    ),
  );
}
}
