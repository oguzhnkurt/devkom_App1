// IC ICE KOD, EGER-DEGILSE, DUZENLENEBILIR SAYI, CIZGI IZI.
//
// Eski kod alaninda bir C blogunun govdesi kendisinden SONRAKI her
// seydi: "4 kere {git, don} SONRA Merhaba de" kurulamiyordu. Bu testler
// yeni yapinin sozunu tutuyor ve eski adimlarin aynen calistigini
// gosteriyor.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/yurutme/atolye_hedefleri.dart';
import 'package:devkom_app/courses/yurutme/blok_yorumlayici.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/courses/yurutme/scratch_blok_katalogu.dart';

ScratchBlock _b(String id, {bool c = false}) => ScratchBlock(
      id: id,
      blockType: ScratchBlockType.motion,
      shape: c ? ScratchBlockShape.cBlock : ScratchBlockShape.stack,
      label: id,
      color: const Color(0xFF4C97FF),
    );

final _palet = [
  _b('green_flag'),
  _b('repeat_4', c: true),
  _b('repeat_3', c: true),
  _b('forever', c: true),
  _b('move_10'),
  _b('move_100'),
  _b('turn_90'),
  _b('turn_120'),
  _b('say_hello'),
  _b('pen_down'),
  _b('pen_clear'),
  _b('set_dice_random'),
  _b('say_dice'),
  _b('say_win'),
  _b('say_try_again'),
  _b('ifelse_dice_gt_3', c: true),
  _b('if_score_low', c: true),
  _b('change_score'),
  _b('set_score_0'),
  _b('when_key_space'),
  _b('when_key_right'),
  _b('change_x'),
  _b('change_y_up'),
  _b('broadcast_dance'),
  _b('receive_dance'),
  _b('next_costume'),
];

bool _c(String id) => _palet.any(
    (b) => b.id == id && b.shape == ScratchBlockShape.cBlock);

Yurutme _yurut(String belirtec, {bool proje = false, int tohum = 1}) {
  final bloklar = KodYapisi.blokla(KodYapisi.coz(belirtec), _palet);
  final y = BlokYorumlayici(rastgele: Random(tohum));
  return proje ? y.yurutProje(bloklar) : y.yurut(bloklar);
}

void main() {
  group('ic ice C blogu', () {
    test('kapanistan sonraki blok donguden SONRA bir kez calisiyor', () {
      final y = _yurut('green_flag repeat_4 move_10 turn_90 } say_hello');
      final ids = y.adimlar.map((a) => a.blokId).toList();
      expect(ids.where((i) => i == 'move_10').length, 4);
      expect(ids.where((i) => i == 'say_hello').length, 1);
      expect(ids.last, 'say_hello');
      // Merhaba dongunun disinda: girintisi 0, tur numarasi yok.
      final soz = y.adimlar.last;
      expect(soz.derinlik, 0);
      expect(soz.tekrarNo, isNull);
      // Kare: kukla basladigi yere dondu.
      expect(y.sonSahne.x, closeTo(0, 0.01));
      expect(y.sonSahne.y, closeTo(0, 0.01));
    });

    test('eski adim (kapanissiz) degismedi: geri kalan her sey icinde', () {
      final y = _yurut('green_flag repeat_4 move_10 say_hello');
      final ids = y.adimlar.map((a) => a.blokId).toList();
      expect(ids.where((i) => i == 'say_hello').length, 4);
    });

    test('ic ice iki dongu: 3 x 4', () {
      final y = _yurut('green_flag repeat_3 repeat_4 move_10 } turn_120 }');
      expect(y.adimlar.where((a) => a.blokId == 'move_10').length, 12);
      expect(y.adimlar.where((a) => a.blokId == 'turn_120').length, 3);
      final ic = y.adimlar.firstWhere((a) => a.blokId == 'move_10');
      expect(ic.derinlik, 2);
    });

    test('surekli tekrarla bitmez; butce dolar', () {
      final y = _yurut('green_flag forever move_10 } say_hello');
      expect(y.butceBitti, isTrue);
      expect(y.adimlar.any((a) => a.blokId == 'say_hello'), isFalse);
    });
  });

  group('eger-degilse', () {
    test('kosul dogruysa ilk kol, yanlissa ikinci kol', () {
      // Tohumlarla iki sonucu da bul.
      var kazandi = false, kaybetti = false;
      for (var t = 0; t < 40; t++) {
        final y = _yurut(
            'green_flag set_dice_random ifelse_dice_gt_3 say_win | '
            'say_try_again }',
            tohum: t);
        final zar = y.sonSahne.degiskenler['zar']!;
        final soz = y.adimlar.last.blokId;
        if (zar > 3) {
          expect(soz, 'say_win', reason: 'zar $zar');
          kazandi = true;
        } else {
          expect(soz, 'say_try_again', reason: 'zar $zar');
          kaybetti = true;
        }
        // Iki kol asla birlikte calismiyor.
        expect(
            y.adimlar
                .where((a) => a.blokId == 'say_win' || a.blokId == 'say_try_again')
                .length,
            1);
      }
      expect(kazandi && kaybetti, isTrue);
    });

    test('eger (degilse yok): kosul yanlissa hicbir sey, sonra devam', () {
      // Puan 0 < 5: govde calisir. Puan 5 yapilinca calismaz.
      final y = _yurut('green_flag if_score_low say_hello } turn_90');
      expect(y.adimlar.any((a) => a.blokId == 'say_hello'), isTrue);
      expect(y.adimlar.last.blokId, 'turn_90');
    });

    test('degiskenin degerini soyleyen blok sayiyi soyluyor', () {
      final y = _yurut('green_flag set_dice_random say_dice');
      final zar = y.sonSahne.degiskenler['zar']!;
      expect(y.sonSahne.soyledigi, '${zar.toInt()}');
      expect(y.soylenenler, ['${zar.toInt()}']);
    });
  });

  group('kod yapisi (belirtec listesi)', () {
    test('C blogu kapanisiyla ekleniyor, imlec agzin icinde', () {
      final kod = <KodOgesi>[];
      var imlec = KodYapisi.ekle(kod, 0, _b('green_flag'));
      imlec = KodYapisi.ekle(kod, imlec, _b('repeat_4', c: true));
      expect(KodYapisi.imza(kod), 'green_flag repeat_4 }');
      imlec = KodYapisi.ekle(kod, imlec, _b('move_10'));
      // Ayagin altina gec ve ekle.
      imlec = KodYapisi.kapanis(kod, 1, _c) + 1;
      KodYapisi.ekle(kod, imlec, _b('say_hello'));
      expect(KodYapisi.imza(kod), 'green_flag repeat_4 move_10 } say_hello');
      expect(KodYapisi.girintiler(kod, _c), [0, 0, 1, 0, 0]);
    });

    test('eger-degilse iki agizla geliyor', () {
      final kod = <KodOgesi>[];
      KodYapisi.ekle(kod, 0, _b('ifelse_dice_gt_3', c: true));
      expect(KodYapisi.imza(kod), 'ifelse_dice_gt_3 | }');
      expect(KodYapisi.degilse(kod, 0, _c), 1);
    });

    test('C blogunu silmek icini kaybetmiyor, isaretler gidiyor', () {
      final kod = KodYapisi.coz('green_flag repeat_4 move_10 turn_90 } say_hello');
      KodYapisi.sil(kod, 1, _c);
      expect(KodYapisi.imza(kod), 'green_flag move_10 turn_90 say_hello');
    });

    test('C blogu govdesiyle birlikte tasiniyor', () {
      final kod = KodYapisi.coz('green_flag say_hello repeat_4 move_10 }');
      KodYapisi.tasi(kod, 2, 1, _c);
      expect(KodYapisi.imza(kod), 'green_flag repeat_4 move_10 } say_hello');
      // Kendi govdesinin icine tasinamaz.
      expect(KodYapisi.tasi(kod, 1, 2, _c), isNull);
    });

    test('degerli belirtec: repeat_4=5', () {
      final kod = KodYapisi.coz('green_flag repeat_4=5 move_10=20 }');
      expect(kod[1].deger, 5);
      expect(KodYapisi.imza(kod), 'green_flag repeat_4 move_10 }');
    });
  });

  group('duzenlenebilir sayi', () {
    test('cocugun yazdigi sayi gercekten calisiyor', () {
      final y = _yurut('green_flag repeat_4=3 move_10=50 turn_90=120 }');
      expect(y.adimlar.where((a) => a.blokId == 'move_10').length, 3);
      // Ucgen: basladigi yere doner.
      expect(y.sonSahne.x, closeTo(0, 0.01));
      expect(y.sonSahne.y, closeTo(0, 0.01));
      expect(y.sonSahne.yon, closeTo(90, 0.01));
    });

    test('blokta gorunen sayi da degisiyor', () {
      final t = ScratchBlokKatalogu.tanimDegerli('move_10', 'tr', 25)!;
      expect(t.duzMetin, '25 adım git');
      final r = ScratchBlokKatalogu.tanimDegerli('repeat_4', 'en', 7)!;
      expect(r.duzMetin, 'repeat 7');
    });

    test('ucgen hedefi sonuca bakiyor, sayilara degil', () {
      const hedef = KapaliSekilHedefi(
          metin: 'üçgen',
          metinEn: 'triangle',
          metinDe: 'Dreieck',
          metinEs: 'triángulo',
          kenar: 3);
      bool dene(String kod) => hedef.saglandi(AtolyeSonucu(
          yurutme: _yurut(kod), kod: KodYapisi.coz(kod)));
      expect(dene('green_flag pen_down repeat_4=3 move_100 turn_90=120 }'),
          isTrue);
      expect(dene('green_flag pen_down repeat_3 move_100 turn_120 }'), isTrue);
      // Kare ucgen degil; kalem inmeden cizgi yok.
      expect(dene('green_flag pen_down repeat_4 move_100 turn_90 }'), isFalse);
      expect(dene('green_flag repeat_3 move_100 turn_120 }'), isFalse);
    });
  });

  group('cok betikli yurutme (atolye)', () {
    test('bayrak, sonra tuslar; sapkasiz bloklar calismiyor', () {
      final y = _yurut(
          'move_10 green_flag say_hello when_key_right change_x '
          'when_key_space change_y_up',
          proje: true);
      expect(y.calisanOlaylar, ['bayrak', 'tus:right', 'tus:space']);
      expect(y.sapkasizBlok, 1);
      expect(y.sonSahne.x, 10);
      expect(y.sonSahne.y, 10);
      expect(y.olayBloklari['tus:right'], contains('change_x'));
    });

    test('haber salinca alici o anda calisiyor', () {
      final y = _yurut(
          'green_flag broadcast_dance say_hello '
          'receive_dance repeat_4 next_costume }',
          proje: true);
      expect(y.alinanHaberler, {'dans'});
      expect(y.sonSahne.kostum, 5);
      // Sira: haber -> alici -> Merhaba.
      final ids = y.adimlar.map((a) => a.blokId).toList();
      expect(ids.indexOf('next_costume'), lessThan(ids.indexOf('say_hello')));
    });

    test('alicisi olmayan haber alinmis sayilmiyor', () {
      final y = _yurut('green_flag broadcast_dance', proje: true);
      expect(y.alinanHaberler, isEmpty);
    });

    test('surekli tekrarla tus betiklerini ac birakmiyor', () {
      final y = _yurut(
          'green_flag forever turn_90 } when_key_space say_hello',
          proje: true);
      expect(y.calisanOlaylar, contains('tus:space'));
      expect(y.adimlar.any((a) => a.blokId == 'say_hello'), isTrue);
    });

    test('kalem cizgileri kaydediliyor; sil temizliyor', () {
      final y = _yurut(
          'green_flag pen_down move_100 turn_90 move_100 pen_clear move_100',
          proje: true);
      expect(y.cizgiler.length, 1);
      final y2 = _yurut('green_flag pen_down repeat_4 move_100 turn_90 }',
          proje: true);
      expect(kenarlar(y2.cizgiler).length, 4);
      expect(kapaliMi(y2.cizgiler), isTrue);
    });
  });
}
