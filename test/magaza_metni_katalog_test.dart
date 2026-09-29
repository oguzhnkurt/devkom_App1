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
  /// KELIME SINIRI SART AMA HER DESENDE DEGIL.
  ///
  /// Duz `contains('hat')` Ingilizce metindeki "that" kelimesine
  /// takiliyordu, o yuzden sinir gerekiyor. Ama Dart'ta `\b` ASCII
  /// tabanli: `s`, `o`, `u` gibi Turkce harfler kelime karakteri
  /// SAYILMIYOR. Bu yuzden `\bsapka` (s = s-cedilla) HICBIR ZAMAN
  /// eslesmiyor — " sapka" dizisinde bosluk da bastaki harf de
  /// ASCII-disi oldugu icin orada sinir yok.
  ///
  /// Bu tuzak testi Python'la dogrularken kacmisti: Python'un `re`
  /// modulu Unicode farkindadir ve orada `\b` calisir. Dart'ta
  /// calismaz; test sessizce hep gecerdi.
  ///
  /// Cozum: her desen KENDI sinirini tasiyor. Sinir yalnizca ASCII
  /// harfle BASLAYAN desenlerde var. Turkce karsiliklar duz altdizi
  /// olarak araniyor; baska bir kelimenin icinde gecmeyecek kadar
  /// ayirt ediciler.
  const izler = <StoreItemCategory, List<String>>{
    StoreItemCategory.hat: [
      // `hats?` Turkce "hatirla"/"hata" icindeki "hat"i yakaliyordu:
      // `\b` ASCII oldugu icin sonraki `i` (noktasiz i) sinir sayiliyor.
      // Ardindan Turkce harf gelmemesi sarti eklendi.
      'şapka', r'\bsapka', r'\bhats?\b(?![ıçğöşüİÇĞÖŞÜ])',
      r'\bH(u|ü)te?\b', r'\bsombrero',
    ],
    StoreItemCategory.glasses: [
      'gözlük', r'\bgozluk', r'\bglasses\b', r'\bBrille', r'\bgafas\b',
    ],
    StoreItemCategory.shoes: [
      r'\bayakkab', r'\bshoes\b', r'\bSchuhe\b', r'\bzapatos\b',
    ],
    StoreItemCategory.necklace: [
      r'\bkolye', r'\bnecklace', r'\bHalskette', r'\bcollar\b',
    ],
    StoreItemCategory.robotSkin: [
      r'\brobot k(i|ı)l(i|ı)f', r'\brobot skin',
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
    // `expect` DEGIL: bu yardimci `setUpAll` icinden cagriliyor ve
    // orada basarisiz bir expect duzgun raporlanmiyor — test "gecti"
    // gibi gorunup kontrol sessizce kapanabilir.
    if (bolumSayisi == 0) {
      throw StateError(
        '$yol icinde magaza bolumu bulunamadi. Baslik yeniden '
        'adlandirilmis olabilir; bu testin secicisi guncellenmeli.',
      );
    }
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
          // tirnakla basliyor (`## "What's New in This Version" — 1.0.9`)
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
              RegExp(iz, caseSensitive: false).hasMatch(metin),
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
