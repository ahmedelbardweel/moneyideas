import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/app/router/app_router.dart';
import 'package:moneyideas/core/design_system/design_system.dart';
import 'package:moneyideas/core/l10n/generated/app_localizations.dart';
import 'package:moneyideas/core/l10n/locale_provider.dart';

/// Root application widget.
class MoneyIdeasApp extends ConsumerWidget {
  const MoneyIdeasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'أفكار المال | Money Ideas',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.light(currentLocale.languageCode),
      darkTheme: AppTheme.dark(currentLocale.languageCode),
      locale: currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
