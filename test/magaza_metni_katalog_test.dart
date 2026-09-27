import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/models/store_item_model.dart';

/// MAGAZA METNI KATALOGDAN SAPMAMALI
///
/// NEDEN VAR
/// ---------
/// Bes karakter (Puf, Mia, Bit, Kasif, Bug) tek maskota (Devi) indi;
/// sapka, gozluk, ayakkabi, kolye, robot kilifi ve karakterlerin kendisi
/// katalogdan kalkti (`kaldirilanKategoriler`), jetonlar iade edildi.
///
/// Play metni (docs/PLAY_MAGAZA_METNI.md) o gun guncellendi ama App Store
/// metni (docs/MAGAZA_METNI.md) ayni paragrafi HAFTALARCA tasidi: iki
/// dilde de "bes karakterden biri seciliyor... sapka, gozluk, ayakkabi
/// aliniyor" yaziyordu. Olmayan bir ozelligi anlatmak App Store 2.3.1
/// (dogru olmayan magaza bilgisi) kapsamina giriyor.
///
/// YALNIZCA MAGAZAYA GIDEN METIN TARANIYOR
/// ---------------------------------------
/// Iki dosya da magaza kopyasinin yaninda GEREKCE tutuyor: "sapka,
/// gozluk, kolye ve karakterler katalogdan kalkti" cumlesi tarihcede
/// duruyor ve durmali. Tum dosyayi taramak o cumleleri de yakaliyordu.
/// Bu yuzden yalnizca magazaya kopyalanan bolumler okunuyor:
///
///   * Play: basligi dil kodu tasiyan bolumler — "## Turkce (tr-TR)"
///   * App Store: alan basliklari — ad, alt baslik, aciklama, anahtar
///     kelimeler, surum notlari
///
/// Baslik yeniden adlandirilirsa kontrol sessizce kapanmasin diye her
/// dosya icin "en az bir bolum bulundu" guvencesi var.
void main() {
  /// Kaldirilan kategorilerin magaza metninde aranacak izleri.
  ///
  /// Kategori adlari ("Sapkalar") metinde gecmiyor; metin gunluk dille
  /// yaziliyor. Bu yuzden kategori basina dort dilin karsiliklari elle
  /// veriliyor.
  ///
  /// KELIME SINIRI SART: duz `contains('hat')` Ingilizce metindeki
  /// "that" kelimesine takiliyordu. Desenler `\b` ile kelime basindan
  /// baglaniyor, sonu Turkce ekler icin serbest ("sapkalar" yakalanir).
  const izler = <StoreItemCategory, List<String>>{
    StoreItemCategory.hat: [
      'şapka', 'sapka', r'hats?\b', r'H(u|ü)te?\b', 'sombrero',
    ],
    StoreItemCategory.glasses: [
      'gözlük', 'gozluk', r'glasses\b', 'Brille', r'gafas\b',
    ],
    StoreItemCategory.shoes: [
      'ayakkab', r'shoes\b', r'Schuhe\b', r'zapatos\b',
    ],
    StoreItemCategory.necklace: [
      'kolye', 'necklace', 'Halskette', r'collar\b',
    ],
    StoreItemCategory.robotSkin: [
      'robot k(i|ı)l(i|ı)f', 'robot skin',
    ],
  };

  /// Artik olmayan karakter adlari.
  ///
  /// "Bit" bilerek YOK: Turkce ve Ingilizce'de fazla yaygin bir hece.
  const eskiKarakterler = ['Puf', 'Mia', 'Kaşif', 'Kasif', 'Bug'];

  /// App Store dosyasinda magazaya kopyalanan `##` bolumleri.
  const appStoreBolumleri = [
    'Uygulama adı',
    'Alt başlık',
    'Açıklama',
    'Anahtar kelimeler',
    "What's New",
  ];

  /// Bir markdown dosyasindan magazaya giden bolumlerin govdesini toplar.
  String magazaGovdesi(String yol, bool Function(String baslik) secici) {
    final satirlar = File(yol).readAsLinesSync();
    final toplanan = <String>[];
    var icerde = false;
    var bolumSayisi = 0;
    for (final satir in satirlar) {
      if (satir.startsWith('## ')) {
        icerde = secici(satir.substring(3).trim());
        if (icerde) bolumSayisi++;
        continue;
      }
      if (icerde) toplanan.add(satir);
    }
    expect(
      bolumSayisi,
      greaterThan(0),
      reason: '$yol icinde magaza bolumu bulunamadi. Baslik yeniden '
          'adlandirilmis olabilir; bu testin secicisi guncellenmeli.',
    );
    return toplanan.join('\n');
  }

  final govdeler = <String, String Function()>{
    // Play: "## Turkce (tr-TR)" gibi, basliginda dil kodu olanlar.
    'docs/PLAY_MAGAZA_METNI.md': () => magazaGovdesi(
          'docs/PLAY_MAGAZA_METNI.md',
          (baslik) => RegExp(r'\([a-z]{2}-[A-Z]{2}\)').hasMatch(baslik),
        ),
    'docs/MAGAZA_METNI.md': () => magazaGovdesi(
          'docs/MAGAZA_METNI.md',
          // `contains`, `startsWith` DEGIL: surum notu basligi
          // tirnakla basliyor (`## "What's New in This Version" — 1.0.8`)
          // ve startsWith ile kacip taranmadan kaliyordu.
          (baslik) => appStoreBolumleri.any(baslik.contains),
        ),
  };

  govdeler.forEach((yol, oku) {
    group(yol, () {
      late String metin;

      setUpAll(() => metin = oku());

      test('kaldirilan kategoriler anlatilmiyor', () {
        for (final kategori in kaldirilanKategoriler) {
          for (final iz in izler[kategori] ?? const <String>[]) {
            expect(
              RegExp('\\b$iz', caseSensitive: false).hasMatch(metin),
              isFalse,
              reason: '"$iz" geçiyor ama $kategori katalogdan kalkti. '
                  'Uygulamada olmayan bir urunu magazada anlatmak '
                  'App Store 2.3.1 kapsamina giriyor.',
            );
          }
        }
      });

      test('eski karakter adlari gecmiyor', () {
        for (final ad in eskiKarakterler) {
          expect(
            RegExp('\\b$ad\\b').hasMatch(metin),
            isFalse,
            reason: '"$ad" geçiyor. Uygulamada tek maskot var: Devi.',
          );
        }
      });
    });
  });

  test('satilan kategoriler tam olarak uc tane', () {
    // Metinler "avatar cercevesi, profil afisi ve isim rozeti" diyor.
    // Katalog buyurse metin de buyumeli; bu test o ani yakaliyor.
    expect(
      satilanKategoriler.toSet(),
      {
        StoreItemCategory.avatarFrame,
        StoreItemCategory.profileBanner,
        StoreItemCategory.nameBadge,
      },
      reason: 'Katalog degismis — magaza metinlerindeki urun cumlesi de '
          'guncellenmeli.',
    );
  });
}
