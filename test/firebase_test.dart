// Firebase (1.0.18): yapilandirma ve cocuk kitlesi kurallari.
//
// Kilitlenen seyler:
//  * Secenekler YENI projeye (deveducation-c550b) ve com.devkom.app'e ait;
//    eski devkom-dfdca / com.example dosyalari geri gelmesin.
//  * Reklam kimligi toplanmiyor, reklam kisisellestirme kapali (Android
//    manifest, iOS Info.plist, onay modu).
//  * iOS: SKAdNetwork kaydi acik, uzak bildirim modu ve aps-environment var.
//  * Gelirli `purchase` olayi istemciden ATILMIYOR (Adapty entegrasyonu
//    gonderiyor; cift sayim olmasin).
import 'dart:io';

import 'package:devkom_app/firebase_options.dart';
import 'package:flutter_test/flutter_test.dart';

String _oku(String p) => File(p).readAsStringSync();

void main() {
  test('secenekler yeni projeye ve paket adina ait', () {
    expect(DefaultFirebaseOptions.android.projectId, 'deveducation-c550b');
    expect(DefaultFirebaseOptions.ios.projectId, 'deveducation-c550b');
    expect(DefaultFirebaseOptions.ios.iosBundleId, 'com.devkom.app');
    expect(DefaultFirebaseOptions.android.appId, contains(':android:'));
    expect(DefaultFirebaseOptions.ios.appId, contains(':ios:'));

    final json = _oku('android/app/google-services.json');
    expect(json, contains('"package_name": "com.devkom.app"'));
    expect(json, isNot(contains('com.example')));
    final plist = _oku('ios/Runner/GoogleService-Info.plist');
    expect(plist, contains('<string>com.devkom.app</string>'));
    expect(plist, isNot(contains('devkom-dfdca')));
  });

  test('Android: reklam kimligi ve kisisellestirme kapali', () {
    final m = _oku('android/app/src/main/AndroidManifest.xml');
    expect(
        RegExp(r'google_analytics_adid_collection_enabled"\s*android:value="false"')
            .hasMatch(m),
        isTrue);
    expect(
        RegExp(r'google_analytics_default_allow_ad_personalization_signals"\s*android:value="false"')
            .hasMatch(m),
        isTrue);
    // AD_ID izni hala birlesik manifestten siliniyor.
    expect(m, contains('com.google.android.gms.permission.AD_ID'));
    expect(m, contains('tools:node="remove"'));
  });

  test('iOS: SKAdNetwork, kisisellestirme kapali, push', () {
    final p = _oku('ios/Runner/Info.plist');
    expect(
        RegExp(r'GOOGLE_ANALYTICS_REGISTRATION_WITH_AD_NETWORK_ENABLED</key>\s*<true/>')
            .hasMatch(p),
        isTrue);
    expect(
        RegExp(r'GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_PERSONALIZATION_SIGNALS</key>\s*<false/>')
            .hasMatch(p),
        isTrue);
    expect(p, contains('cstr6suwn9.skadnetwork')); // Google
    expect(p, contains('<string>remote-notification</string>'));
    expect(p, isNot(contains('NSUserTrackingUsageDescription')));
    expect(_oku('ios/Runner/Runner.entitlements'), contains('aps-environment'));
  });

  test('onay modu: reklam depolama / kullanici verisi / kisisellestirme kapali',
      () {
    final s = _oku('lib/services/firebase_servisi.dart');
    expect(s, contains('adStorageConsentGranted: false'));
    expect(s, contains('adUserDataConsentGranted: false'));
    expect(s, contains('adPersonalizationSignalsConsentGranted: false'));
    expect(s, contains("key: 'firebase_app_instance_id'"));
  });

  test('istemciden gelirli purchase olayi atilmiyor', () {
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final s = f.readAsStringSync();
      expect(s.contains('logPurchase('), isFalse, reason: f.path);
      expect(s.contains("name: 'purchase'"), isFalse, reason: f.path);
    }
  });

  test('Firebase main icinde Adapty\'den sonra baslatiliyor', () {
    final m = _oku('lib/main.dart');
    final adapty = m.indexOf('subscriptionService.initialize()');
    final fb = m.indexOf('FirebaseServisi.instance.baslat()');
    expect(adapty, greaterThan(0));
    expect(fb, greaterThan(adapty));
    expect(m, contains('FirebaseServisi.instance.gozlemci'));
  });
}
