// "Blok Yakala" oyununun oyun olarak ayakta kalmasini koruyan testler.
//
// Sikayet suydu: oyunda hep AYNI blok dusuyordu ve dusen blok, alttaki
// butonlarla AYNI renkteydi. Yani cocuk blogu hic okumadan, yalnizca
// rengi eslestirerek kazanabiliyordu. Oyun "blogu anla" oyunu olmaktan
// cikmisti.
//
// Bu dosya widget'i calistirmiyor, kaynagini okuyor. Sebep: iki kural da
// GORSEL kurallar; bir kez duzeltildikten sonra sessizce geri gelmeleri
// cok kolay (birinin "blok renksiz gorunmus, renklendireyim" demesi
// yeterli).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _oyun = 'lib/courses/screens/widgets/catch_block_game.dart';

String _kaynak() => File(_oyun).readAsStringSync();

/// Yorum satirlarini bosaltir: aciklama metninde gecen bir kelime testi
/// yanlisligla dusurmesin.
String _kodu(String src) => src
    .split('\n')
    .map((l) => l.trimLeft().startsWith('//') ? '' : l)
    .join('\n');

void main() {
  test('havuzda iki kategoriden de birden fazla blok var', () {
    final kod = _kodu(_kaynak());
    final motion = "type: 'motion'".allMatches(kod).length;
    final looks = "type: 'looks'".allMatches(kod).length;

    expect(motion, greaterThanOrEqualTo(5),
        reason: 'Hareket blogu cesidi az; ayni blok tekrar tekrar duser.');
    expect(looks, greaterThanOrEqualTo(5),
        reason: 'Gorunum blogu cesidi az; ayni blok tekrar tekrar duser.');
  });

  test('havuzdaki her blogun dort dilde de yazisi var', () {
    final kod = _kodu(_kaynak());
    final toplam = '_BlockDef('.allMatches(kod).length - 1; // sinif tanimi haric
    for (final alan in ['tr:', 'en:', 'de:', 'es:']) {
      // Her blok tanimi dort alani da veriyor mu?
      expect(alan.allMatches(kod).length, greaterThanOrEqualTo(toplam),
          reason: '$alan alani eksik kalan blok var; o dilde Ingilizceye duser.');
    }
  });

  test('bloklar torbadan cekiliyor, zar atilarak degil', () {
    final kod = _kodu(_kaynak());
    expect(kod.contains('_bag'), isTrue,
        reason: 'Karistirilmis torba yok; ayni blok ust uste gelebilir.');
    expect(kod.contains('nextBool()'), isFalse,
        reason: 'nextBool() ile secim ayni blogun ust uste gelmesine izin '
            'verir — sikayetin sebebi buydu.');
  });

  test('dusen blok kategori rengiyle boyanmiyor', () {
    final kod = _kodu(_kaynak());

    // Kategori renkleri yalnizca butonlarda ve cevap VERILDIKTEN sonraki
    // kisa aciklamada kullanilabilir. _BlockWidget icinde kosulsuz bir
    // kategori rengi olmamali.
    final basla = kod.indexOf('class _BlockWidget');
    expect(basla, greaterThan(0));
    final blokWidget = kod.substring(basla);

    expect(blokWidget.contains('0xFF4C97FF'), isFalse,
        reason: 'Dusen blokta Hareket mavisi var; cevabi ele veriyor.');
    expect(blokWidget.contains('0xFF9966FF'), isFalse,
        reason: 'Dusen blokta Gorunum moru var; cevabi ele veriyor.');
    expect(blokWidget.contains('cevaplandi'), isTrue,
        reason: 'Renk, cevap verilmeden once gizli olmali.');
  });

  test('dogru cevapta ses caliniyor', () {
    final kod = _kodu(_kaynak());
    expect(kod.contains('SoundService.playCorrect'), isTrue,
        reason: 'Dogru cevapta ses yok.');
    expect(kod.contains('SoundService.playWrong'), isTrue,
        reason: 'Yanlis cevapta ses yok.');
  });

  test('sectigi ses rengi icin dosyalar gercekten var', () {
    final kod = _kodu(_kaynak());
    final m = RegExp(r'SfxVoice\.(\w+)').firstMatch(kod);
    expect(m, isNotNull, reason: 'Oyun bir ses rengi secmiyor.');
    final renk = m!.group(1);
    for (final ad in ['correct', 'wrong', 'complete']) {
      expect(File('assets/sounds/${ad}_$renk.wav').existsSync(), isTrue,
          reason: 'assets/sounds/${ad}_$renk.wav yok.');
    }
  });

  test('oyun arayuzu dort dil veriyor', () {
    final kod = _kodu(_kaynak());
    expect(kod.contains("lang == 'en'"), isFalse,
        reason: 'Iki dilli ternary kalmis.');
    // Butonlar ve oyun sonu metinleri AppLang.pick ile veriliyor.
    expect('AppLang.pick('.allMatches(kod).length, greaterThanOrEqualTo(6),
        reason: 'Arayuz metinlerinin bir kismi hala tek dilde.');
  });

  test('ders yonergesi artik renk eslestirmeyi ogretmiyor', () {
    final ders =
        File('lib/courses/data/scratch_lessons_data.dart').readAsStringSync();
    final basla = ders.indexOf("id: 's1_1_game'");
    expect(basla, greaterThan(0));
    final adim = ders.substring(basla, basla + 1600);

    for (final ipucu in ['Mavi = Hareket', 'Blue = Motion', 'Blau = Bewegung', 'Azul = Movimiento']) {
      expect(adim.contains(ipucu), isFalse,
          reason: 'Yonerge hala rengi cevap olarak veriyor: "$ipucu"');
    }
  });
}
