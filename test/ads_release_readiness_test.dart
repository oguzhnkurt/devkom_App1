// Yayina cikmadan once reklam katmaninin yapilandirma denetimi.
//
// Bu testler AdMob'a hic baglanmiyor; dosyalari okuyup "yayinda
// calisacak mi" sorusunun kaynak tarafini dogruluyor. Bu ayarlarin
// yanlis olmasi derleme hatasi vermez — yalnizca yayinda reklam
// gelmemesi ya da politika ihlali olarak geri doner.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS Info.plist reklam icin eksiksiz', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    // AdMob uygulama kimligi (birim kimligi degil) plist'te olmak
    // zorunda; yoksa SDK acilista cokuyor.
    expect(plist.contains('<key>GADApplicationIdentifier</key>'), isTrue);
    expect(plist.contains('ca-app-pub-4519840641603310~9762876692'), isTrue);

    // SKAdNetwork: yalnizca Google'in kendi kimligi varken, AdMob'un
    // sattigi obur aglardan gelen yuklemeler eslestirilmiyordu.
    final sayi = RegExp(r'<key>SKAdNetworkIdentifier</key>')
        .allMatches(plist)
        .length;
    expect(sayi, greaterThanOrEqualTo(40),
        reason: 'Google resmi listesi ~50 kimlik iceriyor; $sayi bulundu.');

    // ATT izin ekrani BILEREK yok: cocuk kitlesinde reklam kimligi
    // kullanilmiyor, istenmeyen izin App Store'da geri cevrilme sebebi.
    // Duz metin aramak yetmiyor: plist'te bu izni NEDEN eklemedigimizi
    // anlatan bir XML yorumu var ve contains ona da takiliyordu. Gercek
    // olcut, anahtarin kendisinin tanimli olmamasi.
    expect(plist.contains('<key>NSUserTrackingUsageDescription</key>'), isFalse);
  });

  test('yayinda test kimligi kullanilmiyor', () {
    final cfg = File('lib/config/ad_config.dart').readAsStringSync();
    // Test kimlikleri yalnizca `!kReleaseMode` dalinda donmeli.
    expect(cfg.contains('if (!kReleaseMode)'), isTrue);
    final i = cfg.indexOf('String? get rewardedUnitId');
    final govde = cfg.substring(i, i + 400);
    expect(govde.indexOf('if (!kReleaseMode)'),
        lessThan(govde.indexOf("_env('ADMOB_IOS_REWARDED')")),
        reason: 'Release dali test kimliginden ONCE gelirse yayinda test '
            'reklami cikar.');
  });

  test('Android manifestinde AdMob kimligi GOMULU DEGIL', () {
    // Manifeste dogrudan yazilan kimlik iki sekilde patliyor: Google'in
    // test kimligi yayina sizabiliyor (hic gelir gelmez, politika
    // ihlali) ya da gercek kimlik depoya girip herkese aciliyor.
    // Dogru yer key.properties (.gitignore'da) -> manifest yer tutucusu.
    final man =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final i = man.indexOf('com.google.android.gms.ads.APPLICATION_ID');
    expect(i, greaterThan(0),
        reason: 'AdMob uygulama kimligi meta-data satiri yok; '
            'SDK acilista cokuyor.');
    final govde = man.substring(i, i + 200);
    expect(govde.contains(r'${admobAppId}'), isTrue,
        reason: 'Kimlik yer tutucudan gelmeli.');
    expect(govde.contains('ca-app-pub-'), isFalse,
        reason: 'Manifeste kimlik GOMULMUS. key.properties kullanin.');
  });

  test('Android yayin derlemesi test kimligiyle cikamaz', () {
    // Bu olmazsa hata sessiz: test kimligiyle derlenen bir surum
    // sorunsuz build olur, magazaya cikar ve hic reklam getirmez.
    final g = File('android/app/build.gradle').readAsStringSync();
    expect(g.contains("keystoreProperties['admobAppId']"), isTrue,
        reason: 'Kimlik key.properties disinda bir yerden okunuyor.');
    expect(g.contains('manifestPlaceholders += '), isTrue,
        reason: 'Yer tutucu haritasi `=` ile EZILMEMELI: Flutter ayni '
            'haritaya applicationName koyuyor.');
    expect(g.contains('GradleException'), isTrue,
        reason: 'Yayin derlemesinde test kimligi kontrolu yok.');
    final i = g.indexOf('(assemble|bundle)Release');
    expect(i, greaterThan(0),
        reason: 'Kontrol yalnizca yayin gorevlerine baglanmali; '
            'yoksa hata ayiklama derlemeleri de kirilir.');
  });

  test('Android reklam birimleri .env icinden okunuyor', () {
    // iOS dalinin aynisi: test kimlikleri YALNIZCA !kReleaseMode'da.
    final cfg = File('lib/config/ad_config.dart').readAsStringSync();
    for (final alan in ['rewardedUnitId', 'interstitialUnitId']) {
      final i = cfg.indexOf('String? get $alan');
      final govde = cfg.substring(i, i + 400);
      final release = govde.indexOf('if (!kReleaseMode)');
      final env = govde.indexOf("_env('ADMOB_ANDROID_");
      expect(env, greaterThan(0),
          reason: '$alan Android dalinda .env okumuyor.');
      expect(release, lessThan(env),
          reason: '$alan icinde release dali test kimliginden SONRA '
              'gelmeli; yoksa yayinda test reklami cikar.');
    }
  });

  test('key.properties ornegi Android kimligini anlatiyor', () {
    // Yeni bir makinede kurulum yapan kisi neyi doldurmasi gerektigini
    // dosyanin kendisinden gormeli.
    final f = File('android/key.properties.example');
    expect(f.existsSync(), isTrue);
    final s = f.readAsStringSync();
    expect(s.contains('admobAppId'), isTrue);
    expect(s.contains('storeFile'), isTrue);
  });

  test('cocuk guvenli yapilandirma zorunlu alanlari iceriyor', () {
    final s = File('lib/services/ads_service.dart').readAsStringSync();
    expect(s.contains('TagForChildDirectedTreatment.yes'), isTrue);
    // Google: child-directed ile under-age-of-consent BIRLIKTE
    // verilmemeli, verilirse child-directed zaten oncelikli.
    expect(s.contains('tagForUnderAgeOfConsent:'), isFalse,
        reason: 'tagForUnderAgeOfConsent geri gelmis; '
            'tagForChildDirectedTreatment tek basina yeterli.');
    expect(s.contains('MaxAdContentRating.g'), isTrue);
    expect(s.contains('AdRequest(nonPersonalizedAds: true)'), isTrue);
  });

  test('reklam servisi kendi try blogunda baslatiliyor', () {
    // Eskiden bildirim/baglanti/abonelik servisleriyle AYNI try icindeydi:
    // onlardan biri patlayinca reklamlar hic baslamiyordu.
    final s = File('lib/main.dart').readAsStringSync();
    final i = s.indexOf('AdsService.instance.initialize()');
    expect(i, greaterThan(0));
    final oncesi = s.substring(i - 300, i);
    expect(oncesi.contains('subscriptionService'), isFalse,
        reason: 'Reklam baslatma yine baska servislerle ayni try icinde.');
    expect(oncesi.contains('try {'), isTrue);
  });

  test('Pro durumu cihazda saklaniyor', () {
    // Ag cevabi gelene kadar Pro kullanici reklam gorebiliyordu.
    final s = File('lib/services/ads_service.dart').readAsStringSync();
    expect(s.contains("_kIsProKey = 'ads_is_pro'"), isTrue);
    expect(s.contains('prefs.getBool(_kIsProKey)'), isTrue);
    expect(s.contains('p.setBool(_kIsProKey, value)'), isTrue);
  });

  test('gecis reklami ekran degisiminde gosteriliyor', () {
    // Kutlama ekraninin ustune binmemeli.
    final s = File('lib/main.dart').readAsStringSync();
    expect(s.contains('navigatorObservers: [AdNavigatorObserver()]'), isTrue);
    final obs =
        File('lib/services/ad_navigator_observer.dart').readAsStringSync();
    expect(obs.contains('didPop'), isTrue);
    expect(obs.contains('addPostFrameCallback'), isTrue);
  });

  test('test ekranindaki Pro anahtari cihaza yazilmiyor', () {
    // Gecici olarak Pro'ya gecip reklamlarin kesildigini gormek icin.
    // Cihaza yazilsaydi uygulama yeniden acildiginda da Pro sayilirdi ve
    // "reklam neden gelmiyor" sorusu test ekraninin kendisinden
    // kaynaklanirdi.
    final s = File('lib/services/ads_service.dart').readAsStringSync();
    expect(s.contains('void setProMember(bool value, {bool kalici = true})'),
        isTrue);
    expect(s.contains('setProMember(value, kalici: false)'), isTrue);
    // Sayac sifirlama kayitli Pro bayragini da temizliyor: cikis yolu.
    expect(s.contains('await prefs.remove(_kIsProKey)'), isTrue);
  });
}
