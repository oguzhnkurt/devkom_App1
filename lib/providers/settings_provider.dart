import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // Language/Locale
  Locale _locale = const Locale('tr', 'TR');

  // Theme Mode
  ThemeMode _themeMode = ThemeMode.light;

  // Notifications
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Accessibility
  double _textScaleFactor = 1.0;
  bool _highContrastMode = false;

  // Privacy
  bool _shareDataForImprovement = false;

  // Onboarding
  bool _hasSeenOnboarding = false;

  // Getters
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  double get textScaleFactor => _textScaleFactor;
  bool get highContrastMode => _highContrastMode;
  bool get shareDataForImprovement => _shareDataForImprovement;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  // Language display names
  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Türkçe';
    }
  }

  SettingsProvider() {
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load language
    final languageCode = prefs.getString('language_code') ?? 'tr';
    final countryCode = prefs.getString('country_code') ?? 'TR';
    _locale = Locale(languageCode, countryCode);

    // Load theme
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];

    // Load notifications
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;

    // Load accessibility
    _textScaleFactor = prefs.getDouble('text_scale_factor') ?? 1.0;
    _highContrastMode = prefs.getBool('high_contrast_mode') ?? false;

    // Load privacy
    _shareDataForImprovement = prefs.getBool('share_data') ?? false;

    // Load onboarding
    _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    notifyListeners();
  }

  // Change Language
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');

    notifyListeners();
  }

  // Change Theme Mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);

    notifyListeners();
  }

  // Toggle Notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;

    _notificationsEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    notifyListeners();
  }

  // Toggle Sound
  Future<void> setSoundEnabled(bool enabled) async {
    if (_soundEnabled == enabled) return;

    _soundEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);

    notifyListeners();
  }

  // Toggle Vibration
  Future<void> setVibrationEnabled(bool enabled) async {
    if (_vibrationEnabled == enabled) return;

    _vibrationEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', enabled);

    notifyListeners();
  }

  // Change Text Scale Factor
  Future<void> setTextScaleFactor(double factor) async {
    if (_textScaleFactor == factor) return;

    _textScaleFactor = factor;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale_factor', factor);

    notifyListeners();
  }

  // Toggle High Contrast Mode
  Future<void> setHighContrastMode(bool enabled) async {
    if (_highContrastMode == enabled) return;

    _highContrastMode = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast_mode', enabled);

    notifyListeners();
  }

  // Toggle Share Data
  Future<void> setShareDataForImprovement(bool enabled) async {
    if (_shareDataForImprovement == enabled) return;

    _shareDataForImprovement = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('share_data', enabled);

    notifyListeners();
  }

  // Mark onboarding as seen
  Future<void> markOnboardingAsSeen() async {
    _hasSeenOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    notifyListeners();
  }

  // Reset onboarding (for settings)
  Future<void> resetOnboarding() async {
    _hasSeenOnboarding = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', false);
    notifyListeners();
  }

  // Reset all settings to default
  Future<void> resetToDefaults() async {
    _locale = const Locale('tr', 'TR');
    _themeMode = ThemeMode.light;
    _notificationsEnabled = true;
    _soundEnabled = true;
    _vibrationEnabled = true;
    _textScaleFactor = 1.0;
    _highContrastMode = false;
    _shareDataForImprovement = false;
    _hasSeenOnboarding = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
