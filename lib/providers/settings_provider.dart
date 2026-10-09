import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kLang = 'language';
  static const _kTheme = 'theme';
  static const _kOnboarding = 'onboarding_done';

  final SharedPreferences _prefs;
  SettingsProvider._(this._prefs);

  static Future<SettingsProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsProvider._(prefs);
  }

  // Default: English & Light
  Locale get locale => Locale(_prefs.getString(_kLang) ?? 'en');
  ThemeMode get themeMode => switch (_prefs.getString(_kTheme)) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };
  bool get onboardingDone => _prefs.getBool(_kOnboarding) ?? false;

  Future<void> setLanguage(String code) async {
    await _prefs.setString(_kLang, code);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_kTheme, mode.name);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_kOnboarding, true);
    notifyListeners();
  }
}
