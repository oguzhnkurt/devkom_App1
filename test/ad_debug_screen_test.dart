// Reklam tani ekrani yayin derlemesine sizmamali.
//
// Ekran Pro uyeligi kapatabiliyor, gunluk sayaclari sifirlayabiliyor ve
// gecis reklamini kurallara takilmadan acabiliyor. Hata ayiklarken tam
// olarak istenen sey bu; yayin derlemesinde ise bir kullanicinin eline
// gecmesi kabul edilemez.
//
// Iki katman var ve ikisi de burada dogrulaniyor:
//   1. Ayarlar ekranindaki satir `kDebugMode` icinde.
//   2. `AdsService`in butun `debug*` yazma cagrilari `kDebugMode`
//      degilse hicbir sey yapmiyor — yol bir sekilde bulunsa bile.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ayarlardaki satir kDebugMode ile korunuyor', () {
    final src =
        File('lib/screens/settings/settings_screen.dart').readAsStringSync();
    expect(src.contains('if (kDebugMode) _buildAdTestTile(context)'), isTrue,
        reason: 'Reklam testi satiri kDebugMode korumasini kaybetmis — '
            'yayin derlemesinde kullaniciya gorunur.');
  });

  test('servisteki debug yazmalari kDebugMode ile korunuyor', () {
    final src = File('lib/services/ads_service.dart').readAsStringSync();

    // Durumu DEGISTIREN her debug metodu ilk satirinda kapiyi kontrol
    // etmeli. Yalnizca okuyan getter'lar (debugInitialized gibi) zararsiz.
    const yazanlar = [
      'Future<bool> debugForceInterstitial() async {',
      'Future<void> debugResetDailyCounters() async {',
      'void debugSetProMember(bool value) {',
      'void debugMarkDueNow() {',
    ];

    for (final imza in yazanlar) {
      final yer = src.indexOf(imza);
      expect(yer, greaterThan(0), reason: '$imza bulunamadi.');
      final govde = src.substring(yer, yer + 220);
      expect(govde.contains('if (!kDebugMode) return'), isTrue,
          reason: '$imza yayin derlemesinde de calisiyor.');
    }
  });

  test('ekranin kendisi de yayin derlemesinde kapali', () {
    final src =
        File('lib/screens/dev/ad_test_screen.dart').readAsStringSync();
    expect(src.contains('if (!kDebugMode)'), isTrue,
        reason: 'Ekran yayin derlemesinde kendini kapatmiyor.');
  });
}
