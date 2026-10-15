import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/yurutme/blok_yorumlayici.dart';

/// Yorumlayicinin kosul, kendi blok (tanim/cagri) ve liste davranisi.
///
/// DENETIMDE BULUNANLAR (Ekim 2026):
///  * Her kosul DOGRU sayiliyordu: `eger <puan < 5> ise` puan 9 iken de
///    govdeyi calistiriyordu.
///  * `kare i tanimla` etkisizdi ve altindaki yigin bayrak varmis gibi
///    calisiyordu; 11.1'in sorusu ("tanim tek basina calismaz") sahnede
///    yalanlaniyordu. `kare` cagrisi ise hicbir sey cizmiyordu.
///  * `kenar kere tekrarla` C bicimi yuzunden "eger" gibi BIR KEZ
///    calisiyordu.
///  * 10.2'de `sorular in rastgele ogesi de` blogu hicbir sey demiyordu.
List<ScratchBlock> _kod(String adimId, [List<String>? sira]) {
  final adim = CourseModules.allLessons('scratch')
      .expand((l) => l.steps)
      .whereType<BlockBuilderStep>()
      .firstWhere((s) => s.id == adimId);
  return [
    for (final id in sira ?? adim.correctSequence)
      adim.availableBlocks.firstWhere((b) => b.id == id),
  ];
}

ScratchBlock _b(String id, {ScratchBlockShape sekil = ScratchBlockShape.stack}) =>
    ScratchBlock(
      id: id,
      blockType: ScratchBlockType.motion,
      shape: sekil,
      label: id,
      color: const Color(0xFF4C97FF),
    );

void main() {
  const y = BlokYorumlayici();

  group('kosullar', () {
    test('9.2: puan 0 iken "puan < 5" dogru, govde calisiyor', () {
      final s = y.yurut(_kod('s9_2_build1'));
      final eger = s.adimlar.firstWhere((a) => a.blokId == 'if_score_low');
      expect(eger.kosulSonucu, isTrue);
      expect(s.sonSahne.soyledigi, 'Devam et!');
    });

    test('puan 5 ve ustundeyken govde CALISMIYOR', () {
      final kod = [
        _b('green_flag', sekil: ScratchBlockShape.cap),
        for (var i = 0; i < 6; i++) _b('change_score'),
        ..._kod('s9_2_build1').skip(1),
      ];
      final s = y.yurut(kod);
      expect(s.sonSahne.degiskenler['Puan'], 6);
      final eger = s.adimlar.firstWhere((a) => a.blokId == 'if_score_low');
      expect(eger.kosulSonucu, isFalse);
      expect(s.adimlar.any((a) => a.blokId == 'say_keep_going'), isFalse);
      expect(s.sonSahne.soyledigi, isNull);
    });

    test('algilama kosullari (tus, degme) belgelenmis varsayimla dogru', () {
      final s = y.yurut([
        _b('green_flag', sekil: ScratchBlockShape.cap),
        _b('if_space', sekil: ScratchBlockShape.cBlock),
        _b('say_jump'),
      ]);
      expect(s.sonSahne.soyledigi, 'Zıpladın!');
      expect(s.adimlar[1].kosulSonucu, isNull,
          reason: 'Olculmeyen kosula "dogru" diye sonuc yazilmamali.');
    });
  });

  group('kendi blogun', () {
    test('11.1: yalnizca tanim -> bayrakta hicbir sey olmuyor', () {
      final s = y.yurut(_kod('s11_1_build1'));
      expect(s.adimlar, isEmpty);
      expect(s.yalnizTanim, isTrue);
      expect(s.sonSahne.x, 0);
      expect(s.sonSahne.y, 0);
    });

    test('11.1: "3 kere { kare, 120 don }" uc kare ciziyor', () {
      final s = y.yurut(_kod('s11_1_build2'));
      final gitler = s.adimlar.where((a) => a.blokId == 'move_100').toList();
      expect(gitler.length, 12, reason: 'Uc kare = 12 kenar.');
      expect(s.adimlar.where((a) => a.blokId == 'turn_90').length, 12);
      expect(s.adimlar.where((a) => a.blokId == 'turn_120').length, 3);
      // Kare kapaniyor: her karenin sonunda kukla karenin basinda.
      expect(s.sonSahne.x.abs(), lessThan(0.01));
      expect(s.sonSahne.y.abs(), lessThan(0.01));
      expect(s.sonSahne.yon, 90, reason: '3 x 120 = tam tur.');
      // Govde kod alaninda yok: kod alaninda cagri parliyor.
      final cagriSirasi = 2;
      expect(gitler.every((a) => a.blokSirasi == cagriSirasi), isTrue);
      expect(gitler.every((a) => a.blok?.id == 'move_100'), isTrue);
      expect(s.adimlar.length, lessThan(37),
          reason: 'Sahne en fazla 36 adim oynatiyor; hepsi gorunmeli.');
    });

    test('11.2: "cokgen 6" altigen ciziyor', () {
      final s = y.yurut(_kod('s11_2_build2'));
      final donusler = s.adimlar
          .where((a) => a.blokId == 'turn_360_over_sides')
          .toList();
      expect(donusler.length, 6, reason: 'kenar kere tekrarla = 6 tur.');
      expect(s.adimlar.where((a) => a.blokId == 'move_100_poly').length, 6);
      // 6 x 60 derece: kukla basladigi yere ve yone donuyor.
      expect(donusler.first.sahne.yon, 150);
      expect(s.sonSahne.yon, 90);
      expect(s.sonSahne.x.abs(), lessThan(0.01));
      expect(s.sonSahne.y.abs(), lessThan(0.01));
    });

    test('"cokgen 4" kare (90 derece)', () {
      final s = y.yurut(_kod('s11_2_build2', ['green_flag', 'call_polygon_4']));
      final d = s.adimlar
          .where((a) => a.blokId == 'turn_360_over_sides')
          .toList();
      expect(d.length, 4);
      expect(d.first.sahne.yon, 180);
    });

    test('kod alanindaki tanim cagrildiginda O calisiyor', () {
      // Tanim ayri bir yigin: bayrak yigini cagiriyor, tanimin govdesi
      // kod alanindaki bloklar (kendi siralariyla).
      final s = y.yurut([
        _b('green_flag', sekil: ScratchBlockShape.cap),
        _b('call_square'),
        _b('define_square'),
        _b('move_10'),
      ]);
      final git = s.adimlar.where((a) => a.blokId == 'move_10').toList();
      expect(git.length, 1, reason: 'Kendi tanimi: tek bir 10 adim.');
      expect(git.single.blokSirasi, 3);
      expect(s.sonSahne.x, 10);
      expect(s.yalnizTanim, isFalse);
    });

    test('kenar kere tekrarla tanimin girdisi kadar donuyor', () {
      final s = y.yurut([
        _b('green_flag', sekil: ScratchBlockShape.cap),
        _b('call_polygon_4'),
        _b('define_polygon'),
        _b('repeat_sides', sekil: ScratchBlockShape.cBlock),
        _b('move_10'),
      ]);
      expect(s.adimlar.where((a) => a.blokId == 'move_10').length, 4);
    });

    test('kendini cagiran tanim uygulamayi dondurmuyor', () {
      final s = y.yurut([
        _b('green_flag', sekil: ScratchBlockShape.cap),
        _b('call_square'),
        _b('define_square'),
        _b('call_square'),
      ]);
      expect(s.adimlar.length, lessThan(50));
    });
  });

  group('listeler', () {
    test('10.2: rastgele soru konusma balonunda, cocugun dilinde', () {
      for (final dil in const ['tr', 'en', 'de', 'es']) {
        for (var tohum = 0; tohum < 10; tohum++) {
          final s = BlokYorumlayici(rastgele: Random(tohum), dil: dil)
              .yurut(_kod('s10_2_build1'));
          expect(BlokYorumlayici.ornekSorular[dil],
              contains(s.sonSahne.soyledigi),
              reason: '$dil: listeden bir soru soylenmeliydi');
        }
      }
    });

    test('liste doluysa ondan seciliyor', () {
      final s = y.yurut([
        _b('add_apple'),
        _b('say_random_question'),
      ]);
      // add_apple 'alışveriş' listesine ekliyor; soru torbasi bos -> ornek.
      expect(BlokYorumlayici.ornekSorular['tr'],
          contains(s.sonSahne.soyledigi));
    });

    test('farkli calistirmalar farkli soru soyleyebiliyor', () {
      final soylenen = <String?>{
        for (var i = 0; i < 40; i++)
          y.yurut(_kod('s10_2_build1')).sonSahne.soyledigi,
      };
      expect(soylenen.length, greaterThan(1));
    });
  });
}
