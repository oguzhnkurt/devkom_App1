// KOD BLOKLARI ("Cizim Ustasi"): seviyeler gercek Scratch bloklariyla
// cozulebiliyor, yanlis cizim gecmiyor, oyun Robot Simulatoru'nun
// izgarasini artik kullanmiyor.
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/kod_bloklari_seviyeleri.dart';
import 'package:devkom_app/courses/data/scratch_atolyeleri.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/yurutme/atolye_hedefleri.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/courses/yurutme/scratch_blok_katalogu.dart';

List<bool> _durum(ProjeAtolyesiStep a, String kod) => AtolyeDenetimi.durumlar(
    a.hedefler,
    AtolyeDenetimi.atolyede(a, KodYapisi.coz(kod), rastgele: Random(1)));

void main() {
  final hepsi = KodBloklariSeviyeleri.hepsi;

  test('on seviye, kimlikler benzersiz', () {
    expect(hepsi.length, 10);
    expect(hepsi.map((s) => s.id).toSet().length, 10);
  });

  for (final s in hepsi) {
    test('${s.id}: ornek cozum butun hedefleri sagliyor', () {
      expect(_durum(s, s.ornekCozum), everyElement(isTrue));
    });
    test('${s.id}: bos kod hicbir hedefi saglamiyor', () {
      expect(_durum(s, ''), everyElement(isFalse));
    });
    test('${s.id}: bloklar palette ve katalogda, dort dilde metin', () {
      final ids = s.palet.map((b) => b.id).toSet();
      for (final id in KodYapisi.bloklar(s.ornekCozum)) {
        expect(ids, contains(id), reason: id);
      }
      expect(s.sayiDuzenlenebilir.difference(ids), isEmpty);
      for (final d in ['tr', 'en', 'de', 'es']) {
        for (final b in s.palet) {
          expect(ScratchBlokKatalogu.tanim(b.id, d), isNotNull, reason: b.id);
        }
        expect(s.titleFor(d).trim(), isNotEmpty);
        expect(s.descriptionFor(d).trim(), isNotEmpty);
        expect(s.ipucuFor(d).trim(), isNotEmpty);
        for (final h in s.hedefler) {
          expect(h.metinFor(d).trim(), isNotEmpty);
          if (d != 'tr') expect(h.metinFor(d), isNot(h.metin));
        }
        if (d != 'tr') expect(s.titleFor(d), isNot(s.title));
      }
      expect(s.hedefler.length, inInclusiveRange(2, 4));
    });
  }

  group('yanlis cizimler gecmiyor', () {
    ProjeAtolyesiStep sv(int n) => hepsi[n - 1];

    test('kose: dönmeden iki git tek cizgi', () {
      expect(_durum(sv(2), 'green_flag pen_clear pen_down move_100 move_100'),
          [false, false]);
    });
    test('ucgen: kare cizmek ucgen sayilmiyor', () {
      expect(
          _durum(sv(5),
              'green_flag pen_clear pen_down repeat_4 move_100 turn_90 }'),
          [false, true]);
    });
    test('yildiz: besgen yildiz sayilmiyor', () {
      expect(
          _durum(sv(8),
              'green_flag pen_clear pen_down repeat_4=5 move_100 turn_90=72 }'),
          [true, false]);
    });
    test('iki kare: kalem kaldirmadan gecmiyor', () {
      final d = _durum(
          sv(9),
          'green_flag pen_clear pen_down repeat_4 move_100=60 turn_90 } '
          'move_100 repeat_4 move_100=60 turn_90 }');
      expect(d, [true, false, true]);
    });
  });

  test('Projelerim kayitli Kod Bloklari cizimini acabiliyor', () {
    expect(ScratchAtolyeleri.bul('kod_bloklari_4'), same(hepsi[3]));
  });

  test('oyun Robot Simulatoru gibi izgarada robot yurutmuyor', () {
    final k = File('lib/screens/games/block_coding_game_screen.dart')
        .readAsStringSync();
    expect(k.contains('KodBloklariSeviyeleri'), isTrue);
    expect(k.contains('ProjeAtolyesiWidget('), isTrue);
    expect(k.contains('_playerX'), isFalse);
    expect(k.contains('enum Direction'), isFalse);
  });
}
