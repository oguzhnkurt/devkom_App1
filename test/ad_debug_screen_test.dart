// Reklam tani ekrani: yayinda GORULEBILIR ama DEGISTIREMEZ.
//
// ONCEKI KURAL VE NEDEN DEGISTI
// -----------------------------
// Ekran eskiden yayin derlemesinde kendini tamamen kapatiyordu. Mantikli
// gorunuyordu; ama "reklam gelmiyor" sorunu tam olarak yayinda,
// baskasinin telefonunda yasaniyor. Tanisini goremedigimiz tek yer,
// ihtiyac duydugumuz tek yerdi: gerçek bir kullanicida reklamin neden
// cikmadigini bes sessiz sebepten hangisi oldugunu bilemeden tahmin
// etmeye calisiyorduk.
//
// Yeni kural ikiye ayriliyor:
//   * OKUMA serbest — durum kutusu yayinda da gosteriliyor.
//   * YAZMA kapali — Pro'yu kapatan, sayaclari sifirlayan, reklami
//     zorla acan her yol hala `kDebugMode` arkasinda. Bir kullanici
//     ekrani bulsa bile elinden hicbir sey gelmiyor.
//
// Ekrana giden yol da gizli: Ayarlar > Hakkinda satirina UZUN BASIS.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('durumu DEGISTIREN her debug metodu kDebugMode ile korunuyor', () {
    final src = File('lib/services/ads_service.dart').readAsStringSync();

    // Yalnizca okuyan getter'lar (debugInitialized gibi) zararsiz.
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

  test('yayin derlemesinde reklami zorlayan dugmeler cizilmiyor', () {
    final src = File('lib/screens/dev/ad_test_screen.dart').readAsStringSync();

    expect(src.contains('final yayin = !kDebugMode;'), isTrue,
        reason: 'Ekran yayin/hata-ayiklama ayrimini kaybetmis.');

    // Dugme bloku SADECE `yayin` degilken cizilmeli. Kosulsuz bir
    // `_dugmeler()` cagrisi, yayinda kullaniciya "reklami zorla ac"
    // dugmelerini gosterir.
    final cagrilar = RegExp(r'_dugmeler\(\),').allMatches(src).length;
    expect(cagrilar, 1,
        reason: '_dugmeler() birden fazla yerden cagriliyor; yayin '
            'korumasi delinmis olabilir.');
    expect(src.contains('          else\n            _dugmeler(),'), isTrue,
        reason: '_dugmeler() artik `if (yayin) ... else` dalinda degil.');
  });

  test('tani ekranina giden yol gizli kaliyor', () {
    final src =
        File('lib/screens/settings/settings_screen.dart').readAsStringSync();

    // Gorunur satir yalnizca hata ayiklamada.
    expect(src.contains('if (kDebugMode) _buildAdTestTile(context)'), isTrue,
        reason: 'Reklam testi satiri kDebugMode korumasini kaybetmis — '
            'yayin derlemesinde listede gorunur hale gelir.');

    // Yayindaki tek yol uzun basis; normal dokunus Hakkinda penceresini
    // acmali. Ikisi karisirsa cocuk kazara tani ekranina duser.
    expect(src.contains('onLongPress: () => Navigator.push('), isTrue,
        reason: 'Gizli tani yolu kaldirilmis; yayinda reklam sorununu '
            'teshis etmenin yolu kalmaz.');
    expect(src.contains('onTap: () => _showAboutDialog(context),'), isTrue,
        reason: 'Hakkinda satirinin normal dokunusu degismis.');
  });
}
