import 'package:devkom_app/config/ad_config.dart';
import 'package:devkom_app/services/ads_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gercek AdMob'a gitmeden servisin KARARLARINI dogrulayan sahte katman.
class _FakeAdsPlatform extends AdsPlatform {
  @override
  bool get supported => true;

  @override
  String? rewardedUnitId = 'fake-rewarded';

  @override
  String? interstitialUnitId = 'fake-interstitial';

  int initializeCalls = 0;
  int childSafeCalls = 0;
  int rewardedShowCalls = 0;
  int interstitialLoadCalls = 0;
  int interstitialShowCalls = 0;

  /// showRewarded'in donecegi deger.
  bool? rewardedResult = true;

  @override
  Future<void> initialize() async => initializeCalls++;

  @override
  Future<void> applyChildSafeConfiguration() async => childSafeCalls++;

  @override
  Future<bool?> showRewarded(String unitId) async {
    rewardedShowCalls++;
    return rewardedResult;
  }

  @override
  Future<InterstitialAd?> loadInterstitial(String unitId) async {
    interstitialLoadCalls++;
    return null;
  }

  @override
  Future<bool> showInterstitial(InterstitialAd ad) async {
    interstitialShowCalls++;
    return true;
  }
}

void main() {
  late _FakeAdsPlatform fake;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fake = _FakeAdsPlatform();
    AdsService.instance.resetForTest();
    AdsService.instance.platformOverride = fake;
    AdsService.instance.markInitializedForTest();
  });

  tearDown(() => AdsService.instance.resetForTest());

  group('Pro uyeye reklam yok', () {
    test('odullu video Pro uyede hic gosterilmiyor', () async {
      AdsService.instance.setProMember(true);

      final result = await AdsService.instance.showRewarded();

      expect(result.earned, isFalse);
      expect(result.reason, RewardedAdFailure.proMember);
      expect(fake.rewardedShowCalls, 0,
          reason: 'Pro uyede reklam SDK katmanina hic inmemeli');
    });

    test('Pro uyede odullu video dugmesi gorunmuyor', () async {
      AdsService.instance.setProMember(true);
      expect(await AdsService.instance.canWatchRewarded(), isFalse);
    });

    test('markDue Pro uyede bekleyen reklam birakmiyor', () {
      AdsService.instance.setProMember(true);
      for (var i = 0; i < 10; i++) {
        AdsService.instance.markDue();
      }
      expect(AdsService.instance.interstitialPending, isFalse);
    });

    test('Pro olan kullanicinin bekleyen reklami iptal ediliyor', () {
      for (var i = 0; i < 10; i++) {
        AdsService.instance.markDue();
      }
      // Once bekleyen bir reklam olustu.
      expect(AdsService.instance.interstitialDueForTest, isTrue);

      AdsService.instance.setProMember(true);

      expect(AdsService.instance.interstitialPending, isFalse,
          reason: 'Pro"ya gecen kullanici cebinde kalan reklami gormemeli');
    });
  });

  group('Yeni kullanici isinma payi', () {
    test('ilk adimlarda gecis reklami isaretlenmiyor', () {
      for (var i = 0; i < AdConfig.interstitialWarmupMilestones; i++) {
        AdsService.instance.markDue();
      }
      expect(AdsService.instance.interstitialPending, isFalse,
          reason:
              'Ilk ${AdConfig.interstitialWarmupMilestones} ders/oyunda reklam olmamali');
    });

    test('isinma bittikten sonra isaretleniyor', () {
      for (var i = 0; i <= AdConfig.interstitialWarmupMilestones; i++) {
        AdsService.instance.markDue();
      }
      expect(AdsService.instance.interstitialPending, isTrue);
    });
  });

  group('Gunluk sinir', () {
    test('odullu video gunluk tavana takiliyor', () async {
      SharedPreferences.setMockInitialValues({});
      final now = DateTime.now();
      final today = '${now.year}-${now.month}-${now.day}';
      SharedPreferences.setMockInitialValues({
        'ads_rewarded_day': today,
        'ads_rewarded_count': AdConfig.rewardedDailyCap,
      });

      final result = await AdsService.instance.showRewarded();

      expect(result.reason, RewardedAdFailure.dailyCapReached);
      expect(fake.rewardedShowCalls, 0);
    });

    test('yarida kapatilan videoda odul verilmiyor', () async {
      fake.rewardedResult = false;

      final result = await AdsService.instance.showRewarded();

      expect(result.earned, isFalse);
      expect(result.reason, RewardedAdFailure.dismissedEarly);
    });
  });

  group('Ayarlar', () {
    test('baslatmada cocuk guvenli yapilandirma uygulaniyor', () async {
      AdsService.instance.resetForTest();
      AdsService.instance.platformOverride = fake;

      await AdsService.instance.initialize();

      expect(fake.initializeCalls, 1);
      expect(fake.childSafeCalls, 1,
          reason:
              'TFCD/TFUA ve G derecesi uygulanmazsa cocuklara davranissal '
              'reklam gidebilir - App Store 1.3 ve COPPA sorunu');
    });

    test('odul jetonu bir dersin odulunden az', () {
      // Ders 8 jeton veriyor (UserProgressService.onLessonCompleted).
      // Reklam bundan fazlasini verirse reklam izlemek ders yapmaktan
      // karli hale gelir ve uygulamanin amaci tersine doner.
      expect(AdConfig.rewardedJeton, lessThan(8));
    });
  });
}
