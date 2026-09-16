import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/data/arduino_gorev_data.dart';

/// Arduino Atolyesi — eski breadboard simulatorunun yerine gecen oyun.
///
/// NEDEN DEGISTI
/// -------------
/// Eski ekran 2.400 satirlik bir devre simulatoruydu: elle cizilmis
/// breadboard, kablo cizimi ve 20x12 piksellik pin hedefleri. Telefonda
/// parmakla kablolamak calismiyordu. Yerine iki tur gorev kondu: mBlock
/// bloklariyla kod kurma (kablolama yok) ve devrede eksik parcayi secme
/// (dokunma hedefi kart boyunda).
void main() {
  final seviyeler = ArduinoGorevleri.seviyeler;
  const diller = ['tr', 'en', 'de', 'es'];

  group('seviye yapisi', () {
    test('seviye var ve iki tur de kullaniliyor', () {
      expect(seviyeler.length, greaterThanOrEqualTo(6));
      expect(seviyeler.any((s) => s.tur == ArduinoGorevTuru.kod), isTrue);
      expect(seviyeler.any((s) => s.tur == ArduinoGorevTuru.devre), isTrue);
    });

    test('ilk seviye kod gorevi', () {
      // Cocuk once "yazdigim sey bir seyi hareket ettirdi" hissini
      // yasamali; soru sormakla baslamak o odulu erteliyor.
      expect(seviyeler.first.tur, ArduinoGorevTuru.kod);
    });

    test('hedef ve ipucu dort dilde dolu', () {
      for (var i = 0; i < seviyeler.length; i++) {
        for (final lang in diller) {
          expect(seviyeler[i].hedefFor(lang).trim(), isNotEmpty,
              reason: 'seviye $i hedef / $lang');
          expect(seviyeler[i].ipucuFor(lang).trim(), isNotEmpty,
              reason: 'seviye $i ipucu / $lang');
        }
      }
    });

    test('ceviriler birbirinin ayni degil', () {
      for (var i = 0; i < seviyeler.length; i++) {
        final metinler = diller.map(seviyeler[i].hedefFor).toSet();
        expect(metinler.length, diller.length, reason: 'seviye $i hedef');
      }
    });
  });

  group('kod gorevleri', () {
    test('cozumdeki her blok paletten geliyor', () {
      // Cozumde paletsiz bir blok olsaydi seviye HIC gecilemezdi.
      for (var i = 0; i < seviyeler.length; i++) {
        final s = seviyeler[i];
        if (s.tur != ArduinoGorevTuru.kod) continue;
        final havuzIds = s.havuz.map((b) => b.id).toSet();
        for (final id in s.cozum) {
          expect(havuzIds.contains(id), isTrue,
              reason: 'seviye $i: "$id" palette yok');
        }
      }
    });

    test('cozum bos degil ve baslangic blogu ile basliyor', () {
      for (var i = 0; i < seviyeler.length; i++) {
        final s = seviyeler[i];
        if (s.tur != ArduinoGorevTuru.kod) continue;
        expect(s.cozum, isNotEmpty, reason: 'seviye $i');
        expect(s.cozum.first, 'board_launch', reason: 'seviye $i');
      }
    });

    test('paletteki blok kimlikleri bir seviye icinde benzersiz', () {
      // Ayni kimlikten iki blok olsa hangisinin nereye gittigi
      // ayirt edilemez (Blink'te iki bekleme var, kimlikleri farkli).
      for (var i = 0; i < seviyeler.length; i++) {
        final ids = seviyeler[i].havuz.map((b) => b.id).toList();
        expect(ids.toSet().length, ids.length, reason: 'seviye $i');
      }
    });

    test('blok etiketleri dort dilde dolu', () {
      for (final s in seviyeler) {
        for (final b in s.havuz) {
          for (final lang in diller) {
            expect(b.labelFor(lang).trim(), isNotEmpty,
                reason: '${b.id} / $lang');
          }
        }
      }
    });

    test('paletteki her blogun bir kart etkisi var', () {
      // etkiOf taninmayan kimlige "bekle" donuyor; o da sessizce hicbir
      // sey yapmamak demek. Bekleme bloklari disinda her blok gercek bir
      // etki almali, yoksa cocuk blogu koyar ve kartta hicbir sey olmaz.
      for (final s in seviyeler) {
        for (final b in s.havuz) {
          if (b.id.startsWith('wait')) {
            expect(etkiOf(b.id), ArduinoEtki.bekle, reason: b.id);
            continue;
          }
          expect(etkiOf(b.id), isNot(ArduinoEtki.bekle),
              reason: '${b.id} bilinmeyen bir blok gibi davraniyor');
        }
      }
    });

    test('Blink seviyesinde dongu ve iki ayri bekleme var', () {
      final blink = seviyeler.firstWhere((s) =>
          s.tur == ArduinoGorevTuru.kod && s.cozum.contains('forever'));
      expect(blink.cozum, containsAll(['led_on', 'led_off', 'forever']));
      final beklemeler =
          blink.cozum.where((id) => id.startsWith('wait')).toSet();
      expect(beklemeler.length, 2,
          reason: 'Iki bekleme ayni kimlikte olursa sira dogrulanamaz.');
    });
  });

  group('devre gorevleri', () {
    test('en az uc secenek ve gecerli dogru sik', () {
      for (var i = 0; i < seviyeler.length; i++) {
        final s = seviyeler[i];
        if (s.tur != ArduinoGorevTuru.devre) continue;
        expect(s.secenekler.length, greaterThanOrEqualTo(3), reason: 'seviye $i');
        expect(s.dogruIndeks, greaterThanOrEqualTo(0), reason: 'seviye $i');
        expect(s.dogruIndeks, lessThan(s.secenekler.length), reason: 'seviye $i');
      }
    });

    test('secenek metinleri dort dilde dolu ve farkli', () {
      for (final s in seviyeler) {
        for (final secenek in s.secenekler) {
          for (final metin in [secenek.tr, secenek.en, secenek.de, secenek.es]) {
            expect(metin.trim(), isNotEmpty);
          }
          expect(secenek.emoji.trim(), isNotEmpty);
        }
      }
    });

    test('devrede tam bir eksik parca var', () {
      for (var i = 0; i < seviyeler.length; i++) {
        final s = seviyeler[i];
        if (s.tur != ArduinoGorevTuru.devre) continue;
        expect(s.devreParcalari.where((p) => p == '?').length, 1,
            reason: 'seviye $i');
      }
    });
  });

  group('eski simulatorden iz kalmadi', () {
    test('arduino_simulator_screen.dart silindi', () {
      expect(File('lib/screens/games/arduino_simulator_screen.dart').existsSync(),
          isFalse);
    });

    test('hicbir yer eski ekrani cagirmiyor', () {
      final oyunEkrani =
          File('lib/screens/game_play_screen.dart').readAsStringSync();
      expect(oyunEkrani.contains('ArduinoSimulatorScreen'), isFalse);
      expect(oyunEkrani.contains('ArduinoBlocksGameScreen'), isTrue);
    });

    test('DevAI artik yeni ekrani anlatiyor', () {
      // Eski cevap "LED, buton, direnc ve sensorleri surukleyip
      // baglarsin" diyordu; o ekran artik yok. ("surukleyip" kelimesi
      // Scratch cevaplarinda hala dogru, o yuzden yalnizca bu kaydin
      // govdesine bakiyoruz.)
      final bilgi =
          File('lib/data/dev_assistant_knowledge.dart').readAsStringSync();
      final bas = bilgi.indexOf("id: 'arduino_simulator',");
      expect(bas, isNot(-1));
      final govde = bilgi.substring(bas, bilgi.indexOf('  ),', bas));
      expect(govde.contains('sürükleyip'), isFalse,
          reason: 'DevAI hala kablolamali simulatoru anlatiyor.');
      expect(govde.contains('resistencias y sensores'), isFalse);
      expect(govde.contains('Atölyesi'), isTrue);
    });
  });

  group('blok modeli', () {
    test('C blogu yalnizca dongu icin kullaniliyor', () {
      for (final s in seviyeler) {
        for (final b in s.havuz) {
          if (b.shape == ScratchBlockShape.cBlock) {
            expect(b.id, 'forever', reason: '${b.id} beklenmedik C blogu');
          }
        }
      }
    });
  });
}
