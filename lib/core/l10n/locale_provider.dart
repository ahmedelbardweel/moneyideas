import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kLocaleKey = 'app_locale_code';

/// Manages active application locale with persistence.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    unawaited(_loadPersistedLocale());
    return const Locale('ar');
  }

  Future<void> _loadPersistedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_kLocaleKey);
    if (savedCode != null && (savedCode == 'ar' || savedCode == 'en')) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (state.languageCode == languageCode) return;
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, languageCode);
  }
}

final appLocaleProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
