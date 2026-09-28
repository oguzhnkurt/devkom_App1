import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Alt sayfa (bottom sheet) KAPANDIKTAN sonra bir kez daha cizilir.
///
/// GERCEK OLAY: cocuk "Hesabımı oluştur" deyip kayit oldu; baglama
/// ISLEMI calisti ("Anonim hesap e-postaya baglandi") ama ekrana
/// "Bir seyler ters gitti" hata ekrani dustu.
///
/// Sebep cizim tarafindaydi: islem bitince sayfa agactan kalkiyor,
/// alt sayfanin StatefulBuilder'i bir kez daha ciziliyor ve
/// icerideki `_t4(context, ...)` OLU bir context uzerinden Provider'a
/// bakiyordu:
///
///   Looking up a deactivated widget's ancestor is unsafe.
///
/// `mounted` bunu YAKALAMAZ: `mounted` State'i korur, BuildContext'i
/// degil. Dogru cozum context'i saglamlastirmak degil, ona hic
/// ihtiyac duymamak — dil kodu alt sayfa acilmadan once bir kez
/// okunuyor ve icerideki butun yazilar o kapanistan geciyor.
///
/// Bu test dosyayi degil KURALI koruyor.
void main() {
  final kaynak =
      File('lib/screens/auth/profile_screen.dart').readAsStringSync();

  /// `_showLinkAccountSheet` govdesini suslu parantez eslemesiyle ayikla.
  String metodGovdesi(String ad) {
    final bas = kaynak.indexOf('Future<void> $ad');
    expect(bas, greaterThan(-1), reason: '$ad metodu bulunamadi');
    var i = kaynak.indexOf('{', bas);
    var derinlik = 0;
    for (; i < kaynak.length; i++) {
      if (kaynak[i] == '{') derinlik++;
      if (kaynak[i] == '}') {
        derinlik--;
        if (derinlik == 0) break;
      }
    }
    return kaynak.substring(bas, i + 1);
  }

  /// Yorum satirlarini at: kural kendi gerekcesine takilmasin.
  /// (Bu hata bu depoda daha once uc kez yapildi.)
  String yorumsuz(String kod) => kod
      .split('\n')
      .where((s) => !s.trimLeft().startsWith('//'))
      .join('\n');

  group('hesap baglama alt sayfasi', () {
    late final String govde = yorumsuz(metodGovdesi('_showLinkAccountSheet'));

    test('alt sayfanin icinde context ile ceviri aranmiyor', () {
      expect(govde.contains('_t4(context'), isFalse,
          reason: 'Alt sayfa kapandiktan sonra bir kez daha ciziliyor; o '
              'anda sayfanin context\'i olu olabiliyor. Dil kodunu sayfa '
              'canliyken bir kez al, iceride kapanis kullan.');
      expect(RegExp(r'_t4\(\s*\n\s*context').hasMatch(govde), isFalse,
          reason: 'Ayni sey cok satirli yazimda da gecerli.');
    });

    test('Provider yalnizca alt sayfa ACILMADAN once okunuyor', () {
      final acilis = govde.indexOf('showModalBottomSheet');
      expect(acilis, greaterThan(-1));

      final once = govde.substring(0, acilis);
      final sonra = govde.substring(acilis);

      expect(once.contains('Provider.of<SettingsProvider>'), isTrue,
          reason: 'Dil kodu sayfa canliyken alinmali.');
      expect(sonra.contains('Provider.of'), isFalse,
          reason: 'Alt sayfanin ICINDE Provider aramasi kalmis; olu '
              'context riski geri gelir.');
    });

    test('icerideki yazilar yerel kapanisdan geciyor', () {
      expect(govde.contains('String t(String tr, String en'), isTrue,
          reason: 'Dort dilli yerel kapanis yok.');
      expect(govde.contains('final dilKodu'), isTrue);
    });
  });
}
