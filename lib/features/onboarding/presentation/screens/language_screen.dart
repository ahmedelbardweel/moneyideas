import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyideas/app/router/routes.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/l10n_context.dart';
import 'package:moneyideas/core/l10n/locale_provider.dart';
import 'package:moneyideas/core/widgets/buttons/app_button.dart';

/// Screen 02: Language selection screen with instant locale and directionality switch.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(appLocaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.languageTitle,
                style: context.textStyles.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              const Gap.xs(),
              Text(
                l10n.languageSubtitle,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const Gap.xl(),

              // Arabic Option
              _LanguageTile(
                title: l10n.arabic,
                subtitle: 'Arabic',
                isSelected: currentLocale.languageCode == 'ar',
                onTap: () {
                  unawaited(ref.read(appLocaleProvider.notifier).setLocale('ar'));
                },
              ),
              const Gap.md(),

              // English Option
              _LanguageTile(
                title: l10n.english,
                subtitle: 'English',
                isSelected: currentLocale.languageCode == 'en',
                onTap: () {
                  unawaited(ref.read(appLocaleProvider.notifier).setLocale('en'));
                },
              ),

              const Spacer(),

              AppButton(
                text: l10n.commonContinue,
                isFullWidth: true,
                onPressed: () {
                  context.go(AppRoutes.onboarding);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? context.colors.primaryContainer.withValues(alpha: 0.4)
          : context.colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mediumAll,
        side: BorderSide(
          color: isSelected ? context.colors.primary : context.colors.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? context.colors.primary
              : context.colors.surfaceContainerHigh,
          child: Icon(
            AppIcons.language,
            size: AppSizes.iconMedium,
            color: isSelected ? context.colors.onPrimary : context.colors.onSurfaceVariant,
          ),
        ),
        title: Text(
          title,
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(
                AppIcons.check,
                color: context.colors.primary,
                size: AppSizes.iconMedium,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
