import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AdMob kimlikleri — tek kaynak.
///
/// NEDEN BU DOSYA VAR
/// ------------------
/// Reklam birimi kimlikleri koda gömülürse iOS ve Android karışıyor,
/// test kimliği yanlışlıkla yayına çıkıyor ya da tersi olup geliştirme
/// sırasında gerçek reklam isteniyor (AdMob bunu politika ihlali sayıp
/// hesabı kapatabiliyor). Burada tek yerde toplanıyor ve `kReleaseMode`
/// değilken **her zaman** Google'ın resmî test kimlikleri dönüyor.
///
/// Gerçek kimlikler `.env` içinden okunuyor, depoya yazılmıyor:
///
/// ```
/// ADMOB_IOS_REWARDED=ca-app-pub-XXX/YYY
/// ADMOB_IOS_INTERSTITIAL=ca-app-pub-XXX/YYY
/// ADMOB_ANDROID_REWARDED=ca-app-pub-XXX/YYY
/// ADMOB_ANDROID_INTERSTITIAL=ca-app-pub-XXX/YYY
/// ```
///
/// Bir kimlik `.env`'de yoksa o birim **kapalı** sayılıyor: reklam
/// gösterilmiyor, hata da verilmiyor. Yani kimlikler girilene kadar
/// uygulama bugünkü gibi reklamsız çalışmaya devam ediyor.
class AdConfig {
  const AdConfig._();

  /// Google'ın herkese açık test birimleri.
  /// https://developers.google.com/admob/ios/test-ads
  static const String _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';

  static bool get _ios => !kIsWeb && Platform.isIOS;
  static bool get _android => !kIsWeb && Platform.isAndroid;

  /// Reklam gösterilebilecek bir platformda mıyız?
  /// Masaüstü ve web'de AdMob eklentisi yok.
  static bool get supportedPlatform => _ios || _android;

  static String? _env(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  /// Ödüllü video birimi. Yapılandırılmamışsa `null`.
  static String? get rewardedUnitId {
    if (!kReleaseMode) {
      if (_ios) return _testRewardedIos;
      if (_android) return _testRewardedAndroid;
      return null;
    }
    if (_ios) return _env('ADMOB_IOS_REWARDED');
    if (_android) return _env('ADMOB_ANDROID_REWARDED');
    return null;
  }

  /// Geçiş reklamı birimi. Yapılandırılmamışsa `null`.
  static String? get interstitialUnitId {
    if (!kReleaseMode) {
      if (_ios) return _testInterstitialIos;
      if (_android) return _testInterstitialAndroid;
      return null;
    }
    if (_ios) return _env('ADMOB_IOS_INTERSTITIAL');
    if (_android) return _env('ADMOB_ANDROID_INTERSTITIAL');
    return null;
  }

  /// Bu cihazlarda **her zaman test reklamı** gösterilir.
  ///
  /// NEDEN GEREKLİ
  /// ------------
  /// Kendi reklamına dokunmak AdMob'da geçersiz trafik sayılıyor ve
  /// hesap kapatılabiliyor. Geliştirme sırasında sorun yok — derleme
  /// release değilse zaten test kimlikleri kullanılıyor. Ama uygulamayı
  /// TestFlight'tan kendi telefonuna kurup denediğinde derleme
  /// **release** oluyor ve gerçek reklamlar geliyor.
  ///
  /// Cihaz kimliğini bir kez konsoldan almak gerekiyor: uygulamayı o
  /// telefonda çalıştır, Xcode konsolunda şuna benzer bir satır çıkar:
  ///
  ///   <Google> To get test ads on this device, set:
  ///   GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers
  ///     = @[ @"2077ef9a63d2b398840261c8221a0c9b" ];
  ///
  /// O kimliği `.env` içine yaz (virgülle birden fazla olabilir):
  ///
  ///   ADMOB_TEST_DEVICE_IDS=2077ef9a63d2b398840261c8221a0c9b
  ///
  /// Bundan sonra o telefonda release derlemede bile test reklamı
  /// gelir; istediğin kadar dokunabilirsin.
  static List<String> get testDeviceIds {
    final raw = _env('ADMOB_TEST_DEVICE_IDS');
    if (raw == null) return const [];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  /// Ödüllü video başına verilen jeton.
  ///
  /// Bir ders 8 jeton veriyor (`UserProgressService.onLessonCompleted`).
  /// Reklam ödülü bunun altında tutuluyor: reklam izlemek ders yapmaktan
  /// daha kârlı olursa uygulamanın amacı tersine dönüyor.
  static const int rewardedJeton = 5;

  /// Bir günde izlenebilecek ödüllü video sayısı.
  static const int rewardedDailyCap = 5;

  /// Geçiş reklamları arasındaki en az süre.
  static const Duration interstitialMinGap = Duration(minutes: 4);

  /// Bir günde gösterilecek en fazla geçiş reklamı.
  static const int interstitialDailyCap = 6;

  /// Uygulamanın ilk açılışında geçiş reklamı gösterilmeden önce
  /// tamamlanması gereken ders/oyun sayısı. Yeni kullanıcı ilk
  /// dakikasında reklamla karşılaşmıyor.
  static const int interstitialWarmupMilestones = 3;
}
