import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  final SharedPreferences _prefs;

  LocaleProvider(this._locale, this._prefs);

  Locale get locale => _locale;

  void setLocale(Locale locale) async {
    if (!['en', 'ar'].contains(locale.languageCode)) return;
    
    _locale = locale;
    await _prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }
}
