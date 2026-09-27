import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// ODEME EKRANI MAGAZAYA GORE KONUSMALI
///
/// NEDEN VAR
/// ---------
/// `subscription_screen.dart` iki magazada birden aciliyor ama uzun sure
/// tek magazaya gore yazilmisti: abonelik cumlesi her yerde "odeme
/// App Store hesabindan tahsil edilir" diyor, Kullanim Kosullari
/// baglantisi da Apple'in standart EULA'sina gidiyordu.
///
/// Android'de ikisi de yanlis:
///
///  * Parayi Google tahsil ediyor. Google Play, faturalandirma
///    bilgisinin dogru olmasini sart kosuyor.
///  * Apple EULA'si Play'de gecersiz bir belge.
///  * Play magaza aciklamasinda (docs/PLAY_MAGAZA_METNI.md) "Google Play
///    hesabinizdan tahsil edilir" yaziyor. Uygulama baska sey derse
///    magaza metni ile uygulama celisir — bu, iOS tarafinda 3.1.2(c)
///    reddiyle bir kez yasandi.
///
/// Bu test iki dalin da durdugunu ve dogru URL'lere gittigini kilitliyor.
void main() {
  late String kaynak;

  setUpAll(() {
    kaynak = File('lib/screens/subscription_screen.dart').readAsStringSync();
  });

  test('magaza secimi defaultTargetPlatform ile yapiliyor', () {
    expect(
      kaynak.contains('defaultTargetPlatform == TargetPlatform.android'),
      isTrue,
      reason: 'Platform dallanmasi kaybolmus.',
    );
    expect(
      kaynak.contains("import 'dart:io'"),
      isFalse,
      reason: "dart:io web'de patliyor ve widget testinde dallanma "
          'denenemez hale geliyor; defaultTargetPlatform kullanilmali.',
    );
  });

  test('Kullanim Kosullari baglantisi magazaya gore degisiyor', () {
    expect(
      kaynak.contains(
          "'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'"),
      isTrue,
    );
    expect(
      kaynak.contains("'https://play.google.com/about/play-terms/'"),
      isTrue,
      reason: "Android'de Apple EULA'si gosterilemez.",
    );
    expect(
      kaynak.contains('_termsUrl => _android ? _playTermsUrl : _appleTermsUrl'),
      isTrue,
      reason: 'Baglanti secimi dallanmaya bagli kalmali.',
    );
  });

  test('otomatik yenileme cumlesi her iki magaza icin de var', () {
    for (final cumle in const [
      'ödeme Google Play ',
      'your Google Play account is charged',
      'ödeme App Store ',
      'your App Store account is charged',
    ]) {
      expect(kaynak.contains(cumle), isTrue,
          reason: 'Eksik yenileme metni: $cumle');
    }
  });

  test('Play magaza metni uygulamayla ayni seyi soyluyor', () {
    final magaza = File('docs/PLAY_MAGAZA_METNI.md').readAsStringSync();
    expect(magaza.contains('Google Play hesabınızdan tahsil edilir'), isTrue);
    expect(
      magaza.contains('apple.com/legal'),
      isFalse,
      reason: "Play aciklamasinda Apple EULA baglantisi olamaz.",
    );
  });
}
