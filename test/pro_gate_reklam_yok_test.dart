// AdMob askisi (17 Ekim 2026): odullu video YUKLENEMEZSE kilit yine aciliyor.
//
// Hesap askidayken reklam birimleri dolmuyor; `ensureOrAd` eskiden "Su an
// gosterilecek video yok" deyip kilidi kapali birakiyordu. Artik
// `AdConfig.reklamYoksaKilitAc` acikken notAvailable -> ProUnlock.reklam.
// Yarida kapatilan video ve jeton videolari ESKISI GIBI.
import 'dart:io';

import 'package:devkom_app/config/ad_config.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/services/ads_service.dart';
import 'package:devkom_app/utils/pro_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAdsPlatform extends AdsPlatform {
  @override
  bool get supported => true;
  @override
  String? rewardedUnitId = 'fake-rewarded';
  @override
  String? interstitialUnitId = 'fake-interstitial';

  /// null: yuklenemedi, false: yarida kapatildi, true: izlendi.
  bool? rewardedResult;
  int rewardedShowCalls = 0;

  @override
  Future<void> initialize() async {}
  @override
  Future<void> applyChildSafeConfiguration() async {}
  @override
  Future<bool?> showRewarded(String unitId) async {
    rewardedShowCalls++;
    return rewardedResult;
  }

  @override
  Future<InterstitialAd?> loadInterstitial(String unitId) async => null;
  @override
  Future<bool> showInterstitial(InterstitialAd ad) async => false;
}

const _sonuclar = {
  'izlendi': RewardedAdResult(earned: true, reason: null),
  'yuklenemedi':
      RewardedAdResult(earned: false, reason: RewardedAdFailure.notAvailable),
  'yarida':
      RewardedAdResult(earned: false, reason: RewardedAdFailure.dismissedEarly),
  'sinir': RewardedAdResult(
      earned: false, reason: RewardedAdFailure.dailyCapReached),
  'pro': RewardedAdResult(earned: false, reason: RewardedAdFailure.proMember),
};

void main() {
  group('reklamSonucu', () {
    test('bayrak varsayilan olarak acik (AdMob askisi)', () {
      expect(AdConfig.reklamYoksaKilitAc, isTrue);
    });

    test('bayrak acik: izlendi ve yuklenemedi aciyor, digerleri kapali', () {
      ProUnlock k(String ad) =>
          ProGate.reklamSonucu(_sonuclar[ad]!, reklamYoksaKilitAc: true);
      expect(k('izlendi'), ProUnlock.reklam);
      expect(k('yuklenemedi'), ProUnlock.reklam);
      expect(k('yarida'), ProUnlock.kapali);
      expect(k('sinir'), ProUnlock.kapali);
      expect(k('pro'), ProUnlock.kapali);
    });

    test('bayrak kapali: eski davranis, yalnizca izlenen video aciyor', () {
      ProUnlock k(String ad) =>
          ProGate.reklamSonucu(_sonuclar[ad]!, reklamYoksaKilitAc: false);
      expect(k('izlendi'), ProUnlock.reklam);
      expect(k('yuklenemedi'), ProUnlock.kapali);
      expect(k('yarida'), ProUnlock.kapali);
    });
  });

  group('ensureOrAd ekranda', () {
    late _FakeAdsPlatform fake;

    // AuthProvider Supabase istemcisini kuruyor; erisilemez bir adresle
    // baslatmak yetiyor (kullanici yok -> Pro degil).
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await Supabase.initialize(
          url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
    });

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fake = _FakeAdsPlatform();
      AdsService.instance.resetForTest();
      AdsService.instance.platformOverride = fake;
      AdsService.instance.markInitializedForTest();
    });
    tearDown(() => AdsService.instance.resetForTest());

    Future<ProUnlock?> calistir(WidgetTester tester) async {
      ProUnlock? sonuc;
      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  sonuc = await ProGate.ensureOrAd(
                    context,
                    featureName: 'Bilgi Yarışması',
                    reklamEtiketi: (_) => 'Video izle, sıradaki soruyu aç',
                  );
                },
                child: const Text('ac'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('ac'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Video izle, sıradaki soruyu aç'));
      await tester.pumpAndSettle();
      return sonuc;
    }

    testWidgets('video yuklenemezse kilit aciliyor, mesaj yok', (t) async {
      fake.rewardedResult = null;
      expect(await calistir(t), ProUnlock.reklam);
      expect(fake.rewardedShowCalls, 1);
      expect(find.text('No video available right now.'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('video yarida kapatilirsa kilit kapali, mesaj var', (t) async {
      fake.rewardedResult = false;
      expect(await calistir(t), ProUnlock.kapali);
      expect(
          find.text(
              'The video was not finished, so it did not unlock this time.'),
          findsOneWidget);
    });

    testWidgets('video izlenirse kilit aciliyor', (t) async {
      fake.rewardedResult = true;
      expect(await calistir(t), ProUnlock.reklam);
    });
  });

  test('jeton videosu bayraga baglanmiyor: reklam yoksa jeton yok', () {
    // Para birimi bedava basilmasin. Jeton videosu ensureOrAd'i degil
    // dogrudan showRewarded'i kullaniyor ve earned'e bakiyor.
    final k = File('lib/widgets/jeton_videosu.dart').readAsStringSync();
    expect(k.contains('reklamYoksaKilitAc'), isFalse);
    expect(k.contains('reklamSonucu'), isFalse);
    expect(k.contains('showRewarded(gonullu: true)'), isTrue);
  });
}
