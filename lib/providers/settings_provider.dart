import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/lang.dart';

import '../services/sound_service.dart';
import '../widgets/mascot.dart';

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

  /// Çocuğun maskota verdiği ad.
  ///
  /// Boşsa karakterin kendi adı (Devi) kullanılıyor. Kurulumda
  /// çocuğa "ona ne ad koyalım?" diye soruluyor: adını kendi koyduğu bir
  /// karakter, kendisine verilen bir karakterden başka bir şey.
  String _mascotName = '';

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
  /// Maskotun adı; çocuk ad vermediyse karakterin kendi adı.
  String get mascotName =>
      _mascotName.trim().isEmpty ? Mascot.ad : _mascotName.trim();

  /// Çocuk maskota kendi bir ad verdi mi?
  bool get hasCustomMascotName => _mascotName.trim().isNotEmpty;

  // Language display names
  /// Secili dilin KENDI adi ("Deutsch", "Español").
  ///
  /// Bir dili secerken kullanicinin o dili zaten okuyor olmasini
  /// bekleyemeyiz; bu yuzden "Almanca" degil "Deutsch" yaziyoruz.
  String get currentLanguageName =>
      AppLang.nativeName[_locale.languageCode] ?? 'English';

  SettingsProvider() {
    _loadSettings();
  }

  /// Desteklenen diller. Tek kaynak [AppLang.supported].
  static const supportedLanguages = AppLang.supported;

  /// Cihazin dili destekleniyorsa onu, degilse Ingilizce'yi dondurur.
  ///
  /// ONCEDEN desteklenmeyen bir cihaz dili TURKCE'ye dusuyordu. Iki dil
  /// varken savunulabilirdi; dort dil varken degil. Fransizca bir
  /// cihazda uygulamanin Turkce acilmasi, kullaniciya "bu uygulama sana
  /// gore degil" demek olur. Ingilizce en genis anlasilan yedek.
  static Locale _deviceLocaleOrDefault() {
    final device = PlatformDispatcher.instance.locale;
    if (supportedLanguages.contains(device.languageCode)) {
      return Locale(device.languageCode, device.countryCode ?? '');
    }
    return const Locale(AppLang.en);
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load language
    //
    // ONCEDEN: kayitli tercih yoksa her zaman 'tr' seciliyordu. App Store'dan
    // indiren Ingilizce konusan bir kullanici uygulamayi bastan sona Turkce
    // goruyor, dili degistirebilecegini de bilmiyordu. Artik ilk acilista
    // cihazin diline bakiyoruz; destekledigimiz bir dil degilse Turkce'ye
    // dusuyoruz. Kullanici bir kez sectiginde tercihi her zaman kazaniyor.
    final savedLanguage = prefs.getString('language_code');
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage, prefs.getString('country_code') ?? '');
    } else {
      _locale = _deviceLocaleOrDefault();
    }

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

    // KARAKTER SECIMI KALKTI: tek maskot var (Devi). Eski kurulumlarda
    // kalan `mascot_species` anahtari artik okunmuyor; cocugun maskota
    // verdigi AD ise duruyor, cunku onu kendisi koydu.
    _mascotName = prefs.getString('mascot_name') ?? '';

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


  /// Maskota ad ver. Boş verilirse karakterin kendi adına dönülüyor.
  Future<void> setMascotName(String name) async {
    final temiz = name.trim();
    if (_mascotName == temiz) return;
    _mascotName = temiz;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mascot_name', temiz);
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
    SoundService.configure(sound: enabled);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);

    notifyListeners();
  }

  // Toggle Vibration
  Future<void> setVibrationEnabled(bool enabled) async {
    if (_vibrationEnabled == enabled) return;

    _vibrationEnabled = enabled;
    SoundService.configure(vibration: enabled);

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
    SoundService.configure(sound: true, vibration: true);
    _textScaleFactor = 1.0;
    _highContrastMode = false;
    _shareDataForImprovement = false;
    _hasSeenOnboarding = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
