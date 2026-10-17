import 'package:flutter/material.dart';

import '../database/hive_storage.dart';

/// LocaleController manages dynamic runtime locale switching between English and Hindi.
/// Persists the selected language code in Hive and notifies listeners instantaneously.
class LocaleController extends ChangeNotifier {
  static final LocaleController instance = LocaleController._internal();
  LocaleController._internal();

  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isHindi => _locale.languageCode == 'hi';

  /// Initializes locale from persistent Hive storage
  void init() {
    try {
      final savedCode = HiveStorage().getLanguageCode();
      _locale = Locale(savedCode == 'hi' ? 'hi' : 'en');
    } catch (_) {
      _locale = const Locale('en');
    }
  }

  /// Sets locale and persists preference to Hive
  Future<void> setLocale(Locale newLocale) async {
    final code = newLocale.languageCode == 'hi' ? 'hi' : 'en';
    if (_locale.languageCode == code) return;

    _locale = Locale(code);
    try {
      await HiveStorage().setLanguageCode(code);
    } catch (_) {}
    notifyListeners();
  }

  /// Toggles between English ('en') and Hindi ('hi')
  Future<void> toggleLanguage() async {
    final nextCode = isHindi ? 'en' : 'hi';
    await setLocale(Locale(nextCode));
  }
}
