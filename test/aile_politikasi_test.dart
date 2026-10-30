// Google Play Aile politikasi: reklam kimligi (AAID) gonderilmemeli.
// 30 Ekim 2026'da "Families Device Identifiers" gerekcesiyle red geldi.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  test('AD_ID izni birlesik manifestten siliniyor', () {
    expect(manifest.contains('xmlns:tools="http://schemas.android.com/tools"'),
        isTrue);
    final izin = RegExp(
        r'<uses-permission\s+android:name="com\.google\.android\.gms\.permission\.AD_ID"\s+tools:node="remove"\s*/>');
    expect(izin.hasMatch(manifest), isTrue);
  });

  test('Meta SDK Android\'de kendiliginden baslamiyor, kimlik toplamiyor', () {
    for (final ad in [
      'com.facebook.sdk.AutoInitEnabled',
      'com.facebook.sdk.AutoLogAppEventsEnabled',
      'com.facebook.sdk.AdvertiserIDCollectionEnabled',
    ]) {
      final r = RegExp('android:name="${RegExp.escape(ad)}"\\s+android:value="false"');
      expect(r.hasMatch(manifest), isTrue, reason: ad);
    }
  });

  test('Adapty reklam kimligi toplamiyor', () {
    final servis =
        File('lib/services/subscription_service.dart').readAsStringSync();
    expect(servis.contains('withGoogleAdvertisingIdCollectionDisabled(true)'),
        isTrue);
    expect(servis.contains('withAppleIdfaCollectionDisabled(true)'), isTrue);
  });

  test('AdMob cocuga yonelik isaretli kaliyor', () {
    final ads = File('lib/services/ads_service.dart').readAsStringSync();
    expect(ads.contains('TagForChildDirectedTreatment.yes'), isTrue);
    expect(ads.contains('MaxAdContentRating.g'), isTrue);
  });
}
