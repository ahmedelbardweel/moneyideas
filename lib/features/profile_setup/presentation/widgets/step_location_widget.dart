import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/features/profile_setup/presentation/controllers/profile_setup_controller.dart';

/// Screen 11: Location and Target Markets Selection.
class StepLocationWidget extends ConsumerWidget {
  const StepLocationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final setupData = ref.watch(profileSetupProvider);
    final controller = ref.read(profileSetupProvider.notifier);

    final cities = [
      'Dubai',
      'Abu Dhabi',
      'Sharjah',
      'Ajman',
      'Ras Al Khaimah',
      'Fujairah',
      'Umm Al Quwain',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.setupStepLocation,
          style: context.textStyles.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.xs(),
        Text(
          l10n.setupStepLocationDesc,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Gap.xl(),

        // Country indicator card
        Card(
          color: context.colors.surfaceContainerHigh,
          child: ListTile(
            leading: const Icon(AppIcons.location),
            title: Text(l10n.setupCountry),
            subtitle: const Text('الإمارات العربية المتحدة (UAE)'),
            trailing: const Icon(AppIcons.check, color: Colors.green),
          ),
        ),
        const Gap.lg(),

        Text(
          l10n.setupCity,
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.sm(),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: cities.map((city) {
            final isSelected = setupData.city == city;
            return ChoiceChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) controller.updateLocation(city: city);
              },
            );
          }).toList(),
        ),
        const Gap.xl(),

        // Preferred currency
        Text(
          l10n.setupCurrency,
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap.sm(),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'AED', label: Text('درهم إماراتي (AED)')),
            ButtonSegment(value: 'USD', label: Text('دولار أمريكي (USD)')),
          ],
          selected: {setupData.currency},
          onSelectionChanged: (set) {
            controller.updateLocation(currency: set.first);
          },
        ),
      ],
    );
  }
}
