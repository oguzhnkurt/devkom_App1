import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/mblock_lessons_data.dart';
import 'package:devkom_app/courses/data/rozet_katalogu.dart';
import 'package:devkom_app/courses/data/scratch_lessons_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/courses/yurutme/scratch_blok_katalogu.dart';
import 'package:devkom_app/services/user_progress_service.dart';

/// Ekim 2026 Scratch/mBlock denetiminin icerik kilitleri.
Iterable<InteractiveLesson> get _tumDersler => CoursesData.allCourses
    .expand((k) => CourseModules.allLessons(k.id));

/// Dersin "... rozetini kazandin" diyen ozet adimi (yoksa null).
ExplanationStep? _rozetVaadi(InteractiveLesson l) {
  ExplanationStep? son;
  for (final s in l.steps) {
    if (s is ExplanationStep &&
        (s.tipEn ?? '').toLowerCase().contains('badge')) {
      son = s;
    }
  }
  return son;
}

BlockBuilderStep _adim(String id) => CoursesData.allCourses
    .expand((k) => CourseModules.allLessons(k.id))
    .expand((l) => l.steps)
    .whereType<BlockBuilderStep>()
    .firstWhere((s) => s.id == id);

/// Beklenen cozumden "cocugun kurdugu" programi uretir.
MBlockBlok _kur(MBlockBeklenen b, {Map<String, String> metin = const {}}) =>
    MBlockBlok(
      tip: b.tip,
      alanlar: {...b.alanlar, ...metin},
      icerik: [for (final c in b.icerik) _kur(c, metin: metin)],
      girdiler: {
        for (final e in b.girdiler.entries) e.key: _kur(e.value, metin: metin)
      },
    );

void main() {
  group('rozet katalogu', () {
    test('her ders rozeti katalogda, dort dilde ve simgeli', () {
      final eksik = <String>[];
      for (final l in _tumDersler) {
        final id = l.badge;
        if (id == null) continue;
        final r = RozetKatalogu.rozetler[id];
        if (r == null) {
          eksik.add('${l.id}: $id');
          continue;
        }
        for (final ad in [r.tr, r.en, r.de, r.es, r.simge]) {
          expect(ad.trim(), isNotEmpty, reason: id);
        }
      }
      expect(eksik, isEmpty, reason: 'Katalogda olmayan rozetler: $eksik');
    });

    test('rozet vaat eden her ozetin bir rozeti var ve adi ayni', () {
      final hatalar = <String>[];
      for (final l in _tumDersler) {
        final vaat = _rozetVaadi(l);
        if (vaat == null) continue;
        if (l.badge == null) {
          hatalar.add('${l.id}: ozet rozet vaat ediyor, ders rozet vermiyor');
          continue;
        }
        final r = RozetKatalogu.of(l.badge!);
        if (!(vaat.tipEn ?? '').contains(r.en)) {
          hatalar.add('${l.id}: "${vaat.tipEn}" / katalog "${r.en}"');
        }
        if (!(vaat.tip ?? '').contains(r.tr)) {
          hatalar.add('${l.id}: "${vaat.tip}" / katalog "${r.tr}"');
        }
      }
      expect(hatalar, isEmpty, reason: hatalar.join('\n'));
    });

    test('ayni rozeti iki ders vaat etmiyor (mBlock 1.1 / 0.1)', () {
      final mblock = MBlockLessonsData.allLessons
          .where((l) => l.badge != null)
          .map((l) => l.badge)
          .toList();
      expect(mblock.toSet().length, mblock.length);
      final birBir = MBlockLessonsData.byId('mblock_1_1')!;
      expect(_rozetVaadi(birBir)!.tipEn, isNot(contains('Hello mBlock')));
      for (final id in const ['mblock_1_2', 'mblock_2_1', 'mblock_2_2',
          'mblock_4_2']) {
        expect(MBlockLessonsData.byId(id)!.badge, isNotNull, reason: id);
      }
    });

    test('olu ikinci rozet listesi ve kutlamadaki yarim tablolar yok', () {
      final scratch =
          File('lib/courses/data/scratch_lessons_data.dart').readAsStringSync();
      expect(scratch.contains('class ScratchBadges'), isFalse);
      final ekran = File('lib/courses/screens/interactive_lesson_screen.dart')
          .readAsStringSync();
      expect(ekran.contains('_getBadgeEmoji'), isFalse);
      expect(ekran.contains('RozetKatalogu.of('), isTrue);
      // Rozet kaydediliyor ve "YENI" yalnizca ilk kez.
      expect(ekran.contains('rozet: rozet'), isTrue);
      expect(ekran.contains('authProvider.rozetVar(rozet)'), isTrue);
    });
  });

  group('tekrar odulu', () {
    test('tekrar: XP dortte bir, jeton yok', () {
      expect(UserProgressService.tekrarXp(100), 25);
      expect(UserProgressService.tekrarXp(150), 38);
      final servis =
          File('lib/services/user_progress_service.dart').readAsStringSync();
      expect(servis.contains('if (tamOdul) await addJeton('), isTrue);
    });

    test('modul sinavi odulu yalnizca ilk geciste', () {
      final s = File('lib/courses/screens/module_quiz_screen.dart')
          .readAsStringSync();
      expect(s.contains('await _ilkGecis()'), isTrue);
      expect(s.contains("'+\$_kazanilanXp'"), isTrue);
    });
  });

  group('Scratch icerigi', () {
    test('4.2: puani sifirlamak cozumun parcasi, baska bir celdirici var', () {
      final a = _adim('s4_2_build1');
      expect(a.correctSequence.take(2), ['green_flag', 'set_score_0']);
      final celdiriciler = a.availableBlocks
          .where((b) => !a.correctSequence.contains(b.id));
      expect(celdiriciler, isNotEmpty);
    });

    test('4.2: kukla fareye degiyor, fare imlecine degil', () {
      for (final dil in const ['tr', 'en', 'de', 'es']) {
        final t = ScratchBlokKatalogu.tanim('if_touching', dil)!.duzMetin;
        expect(
            t,
            contains(
                {'tr': 'Fare', 'en': 'Mouse', 'de': 'Maus', 'es': 'Ratón'}[dil]),
            reason: '$dil: $t');
        expect(t.toLowerCase(), isNot(contains('pointer')));
        expect(t.toLowerCase(), isNot(contains('imleci')));
      }
    });

    test('7.1 "Scratch temellerini bitirdin" demiyor, ileri seviye var', () {
      final l = CourseModules.allLessons('scratch')
          .firstWhere((l) => l.id == 'scratch_7_1');
      final ozet =
          l.steps.whereType<ExplanationStep>().firstWhere((s) => s.id == 's7_1_summary');
      expect(ozet.contentEn, isNot(contains('Scratch basics')));
      for (final m in [ozet.content, ozet.contentEn, ozet.contentDe,
          ozet.contentEs]) {
        expect(m, isNotNull);
      }
      expect(ozet.contentEn, contains('advanced'));
    });

    test('kurs suresi derslerin suresiyle uyumlu', () {
      for (final id in const ['scratch', 'mblock']) {
        final k = CoursesData.allCourses.firstWhere((c) => c.id == id);
        final toplam = CourseModules.allLessons(id)
            .fold<int>(0, (t, l) => t + l.estimatedMinutes);
        expect((k.estimatedMinutes - toplam).abs(), lessThanOrEqualTo(toplam ~/ 10),
            reason: '$id: kurs ${k.estimatedMinutes} dk, dersler $toplam dk');
      }
    });
  });

  group('mBlock icerigi', () {
    final adimlar = [
      for (final l in MBlockLessonsData.allLessons)
        for (final s in l.steps)
          if (s is BlockBuilderStep && s.mblock != null) s,
    ];

    test('her cozum dort dilde de kabul ediliyor (serbest metin kutulari)', () {
      // Kutuya yazilan sozler dile gore: cozum serbest metin istememeli.
      const sozler = {
        'tr': 'Merhaba!',
        'en': 'Hello!',
        'de': 'Hallo!',
        'es': '¡Hola!',
      };
      for (final a in adimlar) {
        void gez(List<MBlockBeklenen> l) {
          for (final b in l) {
            expect(b.alanlar.containsKey('METIN'), isFalse,
                reason: '${a.id}: ${b.tip} kutudaki YAZIYI istiyor');
            gez(b.icerik);
            gez(b.girdiler.values.toList());
          }
        }

        gez(a.mblock!.cozum);
        for (final soz in sozler.values) {
          final yigin = [
            for (final b in a.mblock!.cozum) _kur(b, metin: {'METIN': soz})
          ];
          expect(mblockCozumDogruMu([yigin], a.mblock!.cozum), isTrue,
              reason: '${a.id} / $soz');
        }
      }
    });

    test('0.2: "Hello!" yazan cocuk da dogru', () {
      final a = _adim('m0_2_build1');
      final yigin = [
        const MBlockBlok(tip: 'dev_bayrak'),
        const MBlockBlok(tip: 'dev_de', alanlar: {'METIN': 'Hello!'}),
        const MBlockBlok(tip: 'dev_git', alanlar: {'ADIM': '50'}),
      ];
      expect(mblockCozumDogruMu([yigin], a.mblock!.cozum), isTrue);
      final js = File('assets/mblock/mblock_bloklari.js').readAsStringSync();
      expect(js.contains("en: 'Hello!'"), isTrue,
          reason: 'Kutudaki ilk yazi cocugun dilinde olmali.');
    });

    test('Elma Toplama: topraga degen elma siliniyor (ikinci kontrol)', () {
      final a = _adim('p3_build_ikiz');
      final ayar = a.mblock!;
      expect(ayar.bloklar, contains('dev_renge_dokunuyor'));
      final js = File('assets/mblock/mblock_bloklari.js').readAsStringSync();
      expect(js.contains("id: 'dev_renge_dokunuyor'"), isTrue);

      final dogru = [for (final b in ayar.cozum) _kur(b)];
      expect(mblockCozumDogruMu([dogru], ayar.cozum), isTrue);

      // Iki "eger" ters sirada: ayni program.
      final surekli = dogru[2];
      final ters = [
        dogru[0],
        dogru[1],
        MBlockBlok(tip: surekli.tip, icerik: [
          surekli.icerik[0],
          surekli.icerik[2],
          surekli.icerik[1],
        ]),
      ];
      expect(mblockCozumDogruMu([ters], ayar.cozum), isTrue);

      // Ikinci kontrol eksik: yanlis.
      final eksik = [
        dogru[0],
        dogru[1],
        MBlockBlok(tip: surekli.tip, icerik: surekli.icerik.take(2).toList()),
      ];
      expect(mblockCozumDogruMu([eksik], ayar.cozum), isFalse);
      expect(a.correctSequence, contains('if_touching_color'));
    });

    test('3.1: kardes "eger"lerin sirasi serbest, ici degil', () {
      final ayar = _adim('m3_1_build1').mblock!;
      final dogru = [for (final b in ayar.cozum) _kur(b)];
      final s = dogru[1];
      final ters = [
        dogru[0],
        MBlockBlok(tip: s.tip, icerik: [s.icerik[1], s.icerik[0]]),
      ];
      expect(mblockCozumDogruMu([ters], ayar.cozum), isTrue);
      // Icler degisirse (basiliyken sondur) yanlis.
      MBlockBlok iciDegis(MBlockBlok eger, MBlockBlok yeniIc) =>
          MBlockBlok(tip: eger.tip, girdiler: eger.girdiler, icerik: [yeniIc]);
      final karisik = [
        dogru[0],
        MBlockBlok(tip: s.tip, icerik: [
          iciDegis(s.icerik[0], s.icerik[1].icerik.first),
          iciDegis(s.icerik[1], s.icerik[0].icerik.first),
        ]),
      ];
      expect(mblockCozumDogruMu([karisik], ayar.cozum), isFalse);
    });

    test('1.2 eslestirme: renkler Almanca/Ispanyolcada cevrilmis, sari yok',
        () {
      final m = MBlockLessonsData.byId('mblock_1_2')!
          .steps
          .whereType<MatchingStep>()
          .firstWhere((s) => s.id == 'm1_2_match1');
      for (final p in m.pairs) {
        expect(p.rightEn, isNot('Yellow'));
        expect(p.rightEs, isNot(p.rightEn), reason: p.right);
        if (p.rightEn != 'Orange') {
          expect(p.rightDe, isNot(p.rightEn), reason: p.right);
        }
      }
    });

    test('1.1 kedi demiyor; 4.2 "final" degil', () {
      final birBir = MBlockLessonsData.byId('mblock_1_1')!;
      final intro = birBir.steps.whereType<IntroStep>().first;
      for (final m in [intro.mascotMessage, intro.mascotMessageEn,
          intro.mascotMessageDe, intro.mascotMessageEs]) {
        expect(m, isNotNull);
        final k = m!.toLowerCase();
        for (final kedi in ['kedi', ' cat ', 'katze', 'gato']) {
          expect(k.contains(kedi), isFalse, reason: m);
        }
      }
      final dortIki = MBlockLessonsData.byId('mblock_4_2')!;
      for (final t in [dortIki.title, dortIki.titleEn, dortIki.titleDe,
          dortIki.titleEs]) {
        expect(t!.toLowerCase(), isNot(contains('final')));
        expect(t.toLowerCase(), isNot(contains('abschluss')));
      }
    });
  });

  group('performans', () {
    test('ders verisi ve blok tanimlari bir kez kuruluyor', () {
      expect(identical(CourseModules.forCourse('scratch'),
          CourseModules.forCourse('scratch')), isTrue);
      expect(identical(ScratchLessonsData.allLessons,
          ScratchLessonsData.allLessons), isTrue);
      expect(identical(ScratchBlokKatalogu.tanim('move_10', 'de'),
          ScratchBlokKatalogu.tanim('move_10', 'de')), isTrue);
    });

    test('sahne boyacisi her karede bastan cizmiyor; calisan blok bildirimi',
        () {
      final oynatici =
          File('lib/widgets/block_animation_player.dart').readAsStringSync();
      expect(oynatici.contains('shouldRepaint(covariant _SahneBoyaci old) => true'),
          isFalse);
      expect(oynatici.contains('RepaintBoundary('), isTrue);
      final adimlar =
          File('lib/courses/screens/widgets/step_widgets.dart').readAsStringSync();
      expect(adimlar.contains('ValueNotifier<int?> _calisanSira'), isTrue);
      expect(adimlar.contains('setState(() => _calisanSira = sira)'), isFalse);
      final kurs = File('lib/courses/screens/interactive_course_screen.dart')
          .readAsStringSync();
      expect(kurs.contains('_sinavSorulari.putIfAbsent('), isTrue);
    });

    test('ilerleme karti XP: bitis odulu + adimlarin XP si', () {
      final l = CourseModules.allLessons('scratch').first;
      final adimlar = l.steps.fold<int>(0, (t, s) => t + s.xpReward);
      expect(l.tamXp, l.xpReward + adimlar);
      expect(adimlar, greaterThan(0));
    });
  });
}
