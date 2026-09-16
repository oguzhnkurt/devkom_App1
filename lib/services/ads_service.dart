import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/ad_config.dart';

/// Ödüllü video sonucu.
class RewardedAdResult {
  const RewardedAdResult({required this.earned, required this.reason});

  /// Kullanıcı videoyu sonuna kadar izledi ve ödülü hak etti.
  final bool earned;

  /// Hak etmediyse nedeni — arayüzde doğru mesajı göstermek için.
  final RewardedAdFailure? reason;

  static const RewardedAdResult success =
      RewardedAdResult(earned: true, reason: null);
}

enum RewardedAdFailure {
  /// Pro üye: reklam hiç yok.
  proMember,

  /// Bugünkü hak dolmuş.
  dailyCapReached,

  /// Reklam yüklenemedi (ağ, doluluk, kimlik yok).
  notAvailable,

  /// Kullanıcı videoyu yarıda kapattı.
  dismissedEarly,
}

/// Uygulamadaki bütün reklamların tek kapısı.
///
/// NEDEN TEK SERVİS
/// ----------------
/// Reklam kodu ekranlara dağılırsa üç kural tek tek unutuluyor:
///
/// 1. **Pro üyeye reklam gösterilmez.** Paywall'da "Reklamsız kullanım"
///    yazıyor; bu bir vaat, bir tercih değil. [setProMember] ile
///    beslenen bayrak her giriş noktasında ilk kontrol.
/// 2. **Kişiselleştirme kapalı.** Kitlede çocuk var. AdMob'a
///    `tagForChildDirectedTreatment` ve `tagForUnderAgeOfConsent`
///    işaretleniyor, içerik derecesi G'ye sabitleniyor ve istek
///    `nonPersonalizedAds: true` gidiyor. Böylece ATT izin ekranına da
///    gerek kalmıyor, App Store 1.3 ve COPPA/GDPR-K tarafı temiz.
/// 3. **Sıklık sınırı.** Çocuk her ders sonunda reklam görürse
///    uygulama öğretici olmaktan çıkıyor. Geçiş reklamı için hem iki
///    reklam arası en az süre hem günlük tavan hem de yeni kullanıcı
///    için ısınma payı var.
///
/// GEÇİŞ REKLAMI NEDEN "İŞARETLE, SONRA GÖSTER"
/// --------------------------------------------
/// Ders ya da oyun biter bitmez tam ekran reklam açmak iki şeyi bozuyor:
/// kutlama ekranının üstüne biniyor ve çocuk "devam" düğmesine basarken
/// reklama denk geliyor. Bu yüzden bitiş anında yalnızca [markDue]
/// çağrılıyor; reklam, kullanıcı o ekrandan **çıkarken**
/// [showInterstitialIfDue] ile gösteriliyor. Çağrıyı `main.dart`
/// içindeki [AdNavigatorObserver] yapıyor.
class AdsService {
  AdsService._();

  static final AdsService instance = AdsService._();

  static const String _kRewardedDayKey = 'ads_rewarded_day';
  static const String _kRewardedCountKey = 'ads_rewarded_count';
  static const String _kInterstitialDayKey = 'ads_interstitial_day';
  static const String _kInterstitialCountKey = 'ads_interstitial_count';

  /// Son bilinen Pro durumu.
  ///
  /// `AuthProvider` bunu kullaniciyi yukleyince yaziyor, ama yukleme
  /// ag uzerinden geliyor. Arada gecen surede `_isProMember` false
  /// kaliyordu: Pro bir kullanici uygulamayi acar acmaz bir gecis
  /// reklami gorebilirdi. Paywall'da "Reklamsiz kullanim" yaziyor —
  /// bu bir vaat. Son bilinen durum cihazda tutuluyor ve acilista geri
  /// yukleniyor; ag cevabi gelince zaten tazeleniyor.
  static const String _kIsProKey = 'ads_is_pro';

  bool _initialized = false;
  bool _isProMember = false;
  bool _interstitialDue = false;
  int _milestonesThisSession = 0;
  DateTime? _lastInterstitialShownAt;

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  /// Testlerin gerçek AdMob'a gitmeden servisin kararlarını
  /// doğrulayabilmesi için. `null` ise gerçek SDK kullanılır.
  @visibleForTesting
  AdsPlatform? platformOverride;

  AdsPlatform get _platform => platformOverride ?? const _RealAdsPlatform();

  /// Pro üyelik durumu. `AuthProvider` kullanıcıyı her yüklediğinde
  /// buraya yazıyor.
  bool get isProMember => _isProMember;

  /// [kalici] false ise cihaza yazilmaz.
  ///
  /// Reklam test ekranindaki "Pro'yu ac/kapa" dugmesi icin: orada
  /// gecici olarak Pro'ya gecip reklamlarin kesildigini gormek
  /// isteniyor. Bu deger cihaza yazilsaydi uygulama yeniden acildiginda
  /// da Pro sayilirdi ve "reklam neden gelmiyor" sorusu bu sefer test
  /// ekraninin kendisinden kaynaklanirdi.
  void setProMember(bool value, {bool kalici = true}) {
    if (kalici) {
      // Deger degismemis olsa bile cihaza yazmak zararsiz; degisince
      // yazmamak ise ilk kurulumda kaydi hic olusturmuyordu.
      SharedPreferences.getInstance()
          .then((p) => p.setBool(_kIsProKey, value))
          .catchError((Object e) {
        debugPrint('⚠️ Pro durumu kaydedilemedi: $e');
        return false;
      });
    }
    if (_isProMember == value) return;
    _isProMember = value;
    if (value) {
      // Pro'ya geçen kullanıcının cebinde bekleyen reklam kalmasın.
      _interstitialDue = false;
      _interstitial?.dispose();
      _interstitial = null;
    }
  }

  /// Reklam altyapısı bu cihazda çalışabilir mi?
  bool get isSupported => _platform.supported;

  Future<void> initialize() async {
    if (_initialized || !isSupported) return;
    try {
      // Once son bilinen Pro durumu: ag cevabi gelene kadar gecerli.
      //
      // Zaten Pro olarak isaretlenmisse (ornegin AuthProvider bizden
      // once yetismisse) cihazdaki eski deger onu EZMEMELI.
      if (!_isProMember) {
        final prefs = await SharedPreferences.getInstance();
        _isProMember = prefs.getBool(_kIsProKey) ?? false;
      }

      await _platform.initialize();
      await _platform.applyChildSafeConfiguration();
      _initialized = true;
      debugPrint('✅ AdsService initialized (kişiselleştirme kapalı)');
    } catch (e) {
      debugPrint('⚠️ AdsService initialization failed: $e');
    }
  }

  // ---------------------------------------------------------------- ödüllü

  /// Ödüllü video izlenebilir mi? Arayüz düğmeyi buna göre gösteriyor.
  Future<bool> canWatchRewarded() async {
    if (_isProMember || !isSupported || !_initialized) return false;
    if (_platform.rewardedUnitId == null) return false;
    return await _rewardedCountToday() < AdConfig.rewardedDailyCap;
  }

  /// Ödüllü videoyu gösterir. Jetonu **çağıran** ekler — bu servis
  /// veritabanına dokunmuyor, yalnızca "hak edildi mi" sorusunu
  /// cevaplıyor.
  Future<RewardedAdResult> showRewarded() async {
    if (_isProMember) {
      return const RewardedAdResult(
          earned: false, reason: RewardedAdFailure.proMember);
    }
    if (!isSupported || !_initialized) {
      return const RewardedAdResult(
          earned: false, reason: RewardedAdFailure.notAvailable);
    }
    final unitId = _platform.rewardedUnitId;
    if (unitId == null) {
      return const RewardedAdResult(
          earned: false, reason: RewardedAdFailure.notAvailable);
    }
    if (await _rewardedCountToday() >= AdConfig.rewardedDailyCap) {
      return const RewardedAdResult(
          earned: false, reason: RewardedAdFailure.dailyCapReached);
    }

    final earned = await _platform.showRewarded(unitId);
    if (earned == null) {
      return const RewardedAdResult(
          earned: false, reason: RewardedAdFailure.notAvailable);
    }
    if (!earned) {
      return const RewardedAdResult(
          earned: false, reason: RewardedAdFailure.dismissedEarly);
    }
    await _bumpRewardedCount();
    return RewardedAdResult.success;
  }

  // ------------------------------------------------------------ geçiş rek.

  /// Ders/oyun bitti — sıradaki ekran geçişinde reklam gösterilebilir.
  ///
  /// Burada reklam **gösterilmiyor**; yalnızca işaretleniyor. Nedeni
  /// sınıf açıklamasında.
  void markDue() {
    if (_isProMember || !isSupported) return;
    _milestonesThisSession++;
    if (_milestonesThisSession <= AdConfig.interstitialWarmupMilestones) {
      // Yeni kullanıcı ilk birkaç adımda reklam görmüyor.
      return;
    }
    _interstitialDue = true;
    _preloadInterstitial();
  }

  /// Kullanıcı ders/oyun ekranından çıkarken çağrılıyor.
  Future<bool> showInterstitialIfDue() async {
    if (!_interstitialDue || _isProMember || !isSupported) return false;
    if (!await _interstitialAllowedNow()) return false;

    final ad = _interstitial;
    if (ad == null) {
      // Hazır değilse bu seferi atlıyoruz; bekletip kullanıcıyı
      // ekrana kilitlemek reklamdan daha kötü.
      _preloadInterstitial();
      return false;
    }

    _interstitial = null;
    _interstitialDue = false;
    final shown = await _platform.showInterstitial(ad);
    if (shown) {
      _lastInterstitialShownAt = DateTime.now();
      await _bumpInterstitialCount();
    }
    _preloadInterstitial();
    return shown;
  }

  Future<bool> _interstitialAllowedNow() async {
    final last = _lastInterstitialShownAt;
    if (last != null &&
        DateTime.now().difference(last) < AdConfig.interstitialMinGap) {
      return false;
    }
    return await _interstitialCountToday() < AdConfig.interstitialDailyCap;
  }

  void _preloadInterstitial() {
    if (_isProMember || _loadingInterstitial || _interstitial != null) return;
    final unitId = _platform.interstitialUnitId;
    if (unitId == null || !_initialized) return;
    _loadingInterstitial = true;
    _platform.loadInterstitial(unitId).then((ad) {
      _interstitial = ad;
      _loadingInterstitial = false;
    }).catchError((Object e) {
      _loadingInterstitial = false;
      debugPrint('⚠️ Interstitial load failed: $e');
    });
  }

  // ------------------------------------------------------------- sayaçlar

  String get _today {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<int> _counterToday(String dayKey, String countKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(dayKey) != _today) return 0;
    return prefs.getInt(countKey) ?? 0;
  }

  Future<void> _bumpCounter(String dayKey, String countKey) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(dayKey) == _today
        ? (prefs.getInt(countKey) ?? 0)
        : 0;
    await prefs.setString(dayKey, _today);
    await prefs.setInt(countKey, current + 1);
  }

  Future<int> _rewardedCountToday() =>
      _counterToday(_kRewardedDayKey, _kRewardedCountKey);

  Future<void> _bumpRewardedCount() =>
      _bumpCounter(_kRewardedDayKey, _kRewardedCountKey);

  Future<int> _interstitialCountToday() =>
      _counterToday(_kInterstitialDayKey, _kInterstitialCountKey);

  Future<void> _bumpInterstitialCount() =>
      _bumpCounter(_kInterstitialDayKey, _kInterstitialCountKey);

  /// Yalnızca testler için: servisi sıfırla.
  @visibleForTesting
  void resetForTest() {
    _initialized = false;
    _isProMember = false;
    _interstitialDue = false;
    _milestonesThisSession = 0;
    _lastInterstitialShownAt = null;
    _interstitial = null;
    _loadingInterstitial = false;
    platformOverride = null;
  }

  @visibleForTesting
  void markInitializedForTest() => _initialized = true;

  /// Bekleyen bir geçiş reklamı var mı? [AdNavigatorObserver] her
  /// ekran değişiminde bunu soruyor, bu yüzden ucuz olmalı.
  bool get interstitialPending => _interstitialDue && !_isProMember;

  // ------------------------------------------------------- tanı (debug)
  //
  // Reklamı denerken "hiçbir şey çıkmadı" demenin ON TANE sebebi var:
  // Pro üyelik, ısınma payı, günlük tavan, dört dakikalık ara, kimliğin
  // .env'de olmaması, platformun desteklememesi... Hepsi SESSIZ.
  // Aşağıdakiler `lib/screens/dev/ad_test_screen.dart` için; o ekran da
  // yalnızca `kDebugMode` içinde açılıyor.

  bool get debugInitialized => _initialized;
  String? get debugRewardedUnitId => _platform.rewardedUnitId;
  String? get debugInterstitialUnitId => _platform.interstitialUnitId;
  bool get debugInterstitialLoaded => _interstitial != null;
  int get debugMilestonesThisSession => _milestonesThisSession;
  DateTime? get debugLastInterstitialShownAt => _lastInterstitialShownAt;

  Future<int> debugRewardedCountToday() => _rewardedCountToday();
  Future<int> debugInterstitialCountToday() => _interstitialCountToday();

  /// Geçiş reklamını sıra/ara/tavan gözetmeden gösterir.
  ///
  /// YALNIZCA hata ayıklama ekranı için: gerçek akışta reklamın ne zaman
  /// çıkacağına [showInterstitialIfDue] karar veriyor ve o kurallar
  /// bilerek konuldu.
  Future<bool> debugForceInterstitial() async {
    if (!kDebugMode) return false;
    if (!isSupported || !_initialized) return false;
    final unitId = _platform.interstitialUnitId;
    if (unitId == null) return false;
    var ad = _interstitial;
    ad ??= await _platform.loadInterstitial(unitId);
    if (ad == null) return false;
    _interstitial = null;
    final shown = await _platform.showInterstitial(ad);
    _preloadInterstitial();
    return shown;
  }

  /// Günlük sayaçları sıfırlar; tavana takılınca yeniden denemek için.
  Future<void> debugResetDailyCounters() async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRewardedDayKey);
    await prefs.remove(_kRewardedCountKey);
    await prefs.remove(_kInterstitialDayKey);
    await prefs.remove(_kInterstitialCountKey);
    // Kayitli Pro bayragi da temizleniyor: test sirasinda takilip
    // kalmis bir "Pro" degeri reklamlari sessizce kapatir.
    await prefs.remove(_kIsProKey);
    _lastInterstitialShownAt = null;
    _milestonesThisSession = 0;
    _interstitialDue = false;
  }

  /// Pro üyeliği GEÇİCİ olarak kapatır.
  ///
  /// Kendi hesabın Pro ise hiçbir reklam görmezsin — reklamı denerken
  /// en sık düşülen tuzak bu. Bir sonraki `AuthProvider` yüklemesinde
  /// gerçek değer geri geliyor.
  void debugSetProMember(bool value) {
    if (!kDebugMode) return;
    // Cihaza YAZMIYOR: test ekranindaki gecici degisiklik, uygulamayi
    // kapatinca uzerinde kalmasin.
    setProMember(value, kalici: false);
  }

  /// Geçiş reklamını "sırada" işaretler, ısınma payını atlayarak.
  void debugMarkDueNow() {
    if (!kDebugMode) return;
    if (_isProMember || !isSupported) return;
    _interstitialDue = true;
    _preloadInterstitial();
  }

  @visibleForTesting
  bool get interstitialDueForTest => _interstitialDue;
}

/// AdMob SDK'sını saran ince katman. Testlerde yerine sahtesi konuyor.
abstract class AdsPlatform {
  const AdsPlatform();

  /// Bu cihazda AdMob calisiyor mu? Masaustunde ve testlerin kostugu
  /// Dart VM'inde `false`; bu yuzden platform bilgisi de sahtelenebilir
  /// olmali, yoksa servisin karar mantigi hic test edilemiyor.
  bool get supported;

  String? get rewardedUnitId;

  String? get interstitialUnitId;

  Future<void> initialize();

  Future<void> applyChildSafeConfiguration();

  /// `null` = reklam yüklenemedi, `false` = kullanıcı yarıda kapattı,
  /// `true` = ödül hak edildi.
  Future<bool?> showRewarded(String unitId);

  Future<InterstitialAd?> loadInterstitial(String unitId);

  Future<bool> showInterstitial(InterstitialAd ad);
}

class _RealAdsPlatform extends AdsPlatform {
  const _RealAdsPlatform();

  @override
  bool get supported => AdConfig.supportedPlatform;

  @override
  String? get rewardedUnitId => AdConfig.rewardedUnitId;

  @override
  String? get interstitialUnitId => AdConfig.interstitialUnitId;

  /// Çocuk kitlesi için zorunlu ayarlar.
  ///
  /// `tagForChildDirectedTreatment` + `tagForUnderAgeOfConsent` birlikte
  /// verildiğinde AdMob davranışsal hedefleme yapmıyor ve reklam
  /// kimliğini kullanmıyor; bu yüzden ATT izin ekranı gerekmiyor.
  /// `maxAdContentRating: G` de yetişkin içerikli reklamları eliyor.
  @override
  Future<void> applyChildSafeConfiguration() async {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
        maxAdContentRating: MaxAdContentRating.g,
        testDeviceIds: AdConfig.testDeviceIds,
      ),
    );
  }

  @override
  Future<void> initialize() => MobileAds.instance.initialize();

  static const AdRequest _request = AdRequest(nonPersonalizedAds: true);

  /// NEDEN COMPLETER
  /// ---------------
  /// `RewardedAd.load()`'un dondurdugu Future, reklam YUKLENINCE degil
  /// yukleme ISTEGI GONDERILINCE tamamlaniyor. Sonuc `onAdLoaded` /
  /// `onAdFailedToLoad` ile sonradan geliyor.
  ///
  /// Onceki surum `await RewardedAd.load(...)` diyip hemen ardindan
  /// degiskene bakiyordu; o an her zaman null oluyordu. Yani odullu
  /// video HIC GOSTERILEMIYORDU — kullanici "Reklam izle"ye basiyor,
  /// "Su an gosterilecek video yok" yaziyordu. Her seferinde.
  ///
  /// Zaman asimi var cunku ag kotuyse hicbir geri cagirma gelmeyebilir
  /// ve cocuk bos bir ekranda beklerdi.
  @override
  Future<bool?> showRewarded(String unitId) async {
    final sonuc = Completer<RewardedAd?>();
    void bitir(RewardedAd? ad) {
      if (!sonuc.isCompleted) sonuc.complete(ad);
    }

    try {
      await RewardedAd.load(
        adUnitId: unitId,
        request: _request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: bitir,
          onAdFailedToLoad: (error) {
            debugPrint('⚠️ Rewarded load failed: $error');
            bitir(null);
          },
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Rewarded load threw: $e');
      bitir(null);
    }

    final loaded = await sonuc.future
        .timeout(const Duration(seconds: 12), onTimeout: () => null);
    if (loaded == null) return null;

    var earned = false;
    loaded.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) => a.dispose(),
      onAdFailedToShowFullScreenContent: (a, e) => a.dispose(),
    );
    await loaded.show(onUserEarnedReward: (_, __) => earned = true);
    return earned;
  }

  /// Ayni Completer gerekcesi gecis reklami icin de gecerli; bkz.
  /// [showRewarded]. Bu yol sessizce basarisiz oluyordu: gecis reklami
  /// hic yuklenmiyor, dolayisiyla hic gosterilmiyordu.
  @override
  Future<InterstitialAd?> loadInterstitial(String unitId) async {
    final sonuc = Completer<InterstitialAd?>();
    void bitir(InterstitialAd? ad) {
      if (!sonuc.isCompleted) sonuc.complete(ad);
    }

    try {
      await InterstitialAd.load(
        adUnitId: unitId,
        request: _request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: bitir,
          onAdFailedToLoad: (error) {
            debugPrint('⚠️ Interstitial load failed: $error');
            bitir(null);
          },
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Interstitial load threw: $e');
      bitir(null);
    }

    return sonuc.future
        .timeout(const Duration(seconds: 12), onTimeout: () => null);
  }

  @override
  Future<bool> showInterstitial(InterstitialAd ad) async {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) => a.dispose(),
      onAdFailedToShowFullScreenContent: (a, e) => a.dispose(),
    );
    await ad.show();
    return true;
  }
}
