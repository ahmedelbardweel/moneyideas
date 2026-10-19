import 'package:flutter/widgets.dart';
import 'package:moneyideas/core/l10n/generated/app_localizations.dart';

/// Context extension for quick access to localized strings.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
