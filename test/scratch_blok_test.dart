// SCRATCH BLOKLARI SCRATCH 3'TEKI GIBI MI?
//
// Kullanici sikayeti: "Scratch bloklarini orijinalleri gibi yaptin mi?"
// Kurs bloklari duz haplardi. Bu testler yeni cizimin uc sozunu
// tutuyor:
//
//  1. Scratch derslerinde gecen HER blok (kimlik, anlatim gorseli,
//     siralama satiri, dongu karsilastirmasi) bir Scratch karsiligina
//     esleniyor — eslesmeyen blok sessizce eski hapa dusmesin.
//  2. Blok YAZILARI uydurma degil: uretilmis etiket haritasi Scratch'in
//     resmi dil dosyalariyla (tool/bloklar/) birebir ayni, ve bloklarin
//     uzerindeki her sabit yazi bu sablonlardan geliyor.
//  3. Olculer Scratch'in olculeri ve bloklar bosluksuz ust uste oturuyor.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/yurutme/scratch_blok_katalogu.dart';
import 'package:devkom_app/courses/yurutme/scratch_resmi_etiketler.dart';
import 'package:devkom_app/widgets/scratch_blok.dart';

const _diller = ['tr', 'en', 'de', 'es'];

List<LessonStep> get _adimlar =>
    CourseModules.allLessons('scratch').expand((l) => l.steps).toList();

/// Bir blogun (ic ice bloklar dahil) butun parcalari.
Iterable<(ScratchBlokTanimi, SbParca)> _parcalar(ScratchBlokTanimi t) sync* {
  for (final p in [...t.satir, ...?t.degilse]) {
    yield (t, p);
    if (p is SbIcBlok) yield* _parcalar(p.blok);
  }
  for (final i in [...t.ic, ...t.ic2]) {
    yield* _parcalar(i);
  }
}

void main() {
  group('eslesme', () {
    test('blok kurma adimlarindaki her kimligin Scratch karsiligi var', () {
      final eksik = <String>{};
      var sayi = 0;
      for (final s in _adimlar.whereType<BlockBuilderStep>()) {
        for (final b in s.availableBlocks) {
          sayi++;
          for (final d in _diller) {
            if (ScratchBlokKatalogu.tanim(b.id, d) == null) {
              eksik.add('${s.id}/${b.id}');
            }
          }
        }
      }
      expect(sayi, greaterThan(50));
      expect(eksik, isEmpty, reason: 'Katalogda yok: $eksik');
    });

    test('blok sekli ders verisiyle uyumlu', () {
      // C blogu veride de C olmali: kod alani ve yorumlayici agzi buna
      // gore kuruyor.
      for (final s in _adimlar.whereType<BlockBuilderStep>()) {
        for (final b in s.availableBlocks) {
          final t = ScratchBlokKatalogu.tanim(b.id, 'en')!;
          expect(t.cMi, b.shape == ScratchBlockShape.cBlock,
              reason: '${b.id}: veride ${b.shape}, katalogda ${t.sekil}');
        }
      }
    });

    test('anlatim, siralama ve karsilastirma gorselleri esleniyor', () {
      final eksik = <String>[];
      for (final s in _adimlar) {
        if (s is ExplanationStep) {
          for (final v in s.visuals) {
            if (v.type != VisualType.scratchBlock) continue;
            if (ScratchBlokKatalogu.kategoriGorseli(v.content) == null &&
                ScratchBlokKatalogu.gorsel(v.content, 'en') == null) {
              eksik.add('${s.id}: ${v.content}');
            }
          }
        }
        if (s is OrderingStep) {
          for (final o in s.items) {
            if (ScratchBlokKatalogu.gorsel(o.content, 'en') == null) {
              eksik.add('${s.id}: ${o.content}');
            }
          }
        }
        if (s is AnimationStep &&
            s.animationType == AnimationType.comparison) {
          for (final ad in ['before', 'after']) {
            for (final o in (s.animationData[ad] as List? ?? const [])) {
              if (o == '...') continue;
              if (ScratchBlokKatalogu.gorsel('$o', 'en') == null) {
                eksik.add('${s.id}: $o');
              }
            }
          }
        }
      }
      expect(eksik, isEmpty, reason: eksik.join('\n'));
    });

    test('Scratch kategorileri: kontrol sapkasi ve eklentiler dogru renkte',
        () {
      // Scratch'te "ikiz olarak basladigimda" KONTROL (turuncu) sapkasi,
      // nota ve kalem bloklari eklenti yesili.
      expect(ScratchBlokKatalogu.tanim('when_clone', 'tr')!.kategori,
          ScratchKategori.kontrol);
      expect(ScratchBlokKatalogu.tanim('play_note_60', 'tr')!.kategori,
          ScratchKategori.muzik);
      expect(ScratchBlokKatalogu.tanim('pen_down', 'tr')!.kategori,
          ScratchKategori.kalem);
      expect(ScratchKategori.hareket.renk, const Color(0xFF4C97FF));
      expect(ScratchKategori.hareket.renk3, const Color(0xFF3373CC));
      expect(ScratchKategori.kontrol.renk2, const Color(0xFFEC9C13));
      expect(ScratchKategori.kalem.renk, const Color(0xFF0FBD8C));
    });
  });

  group('resmi etiketler', () {
    Map<String, dynamic> sozluk(String d) => {
          ...jsonDecode(File('tool/bloklar/scratch_$d.json').readAsStringSync())
              as Map<String, dynamic>,
          ...jsonDecode(File('tool/bloklar/scratch_eklenti_$d.json')
              .readAsStringSync()) as Map<String, dynamic>,
        };

    test('uretilmis harita tool/bloklar ile birebir ayni', () {
      for (final d in _diller) {
        final s = sozluk(d);
        final h = scratchResmiEtiketler[d]!;
        expect(h, isNotEmpty);
        for (final e in h.entries) {
          expect(e.value, s[e.key],
              reason: '$d/${e.key} elle degistirilmis; '
                  'tool/bloklar/scratch_etiketleri_uret.py ile yeniden uret.');
        }
      }
    });

    test('bloklardaki her sabit yazi resmi sablondan geliyor', () {
      final yer = RegExp(r'%\d|\[[A-Z_]+\]');
      for (final d in _diller) {
        final parcalar = <String>{
          for (final v in scratchResmiEtiketler[d]!.values)
            for (final p in v.split(yer))
              if (p.trim().isNotEmpty) p.trim(),
        };
        for (final id in ScratchBlokKatalogu.kimlikler) {
          final t = ScratchBlokKatalogu.tanim(id, d)!;
          for (final (sahibi, p) in _parcalar(t)) {
            if (p is! SbYazi) continue;
            // Kendi blok adlari ("kare") ve degisken ovali ("puan")
            // cocugun programina ait; Scratch'te de kullanici yaziyor.
            if (sahibi.kategori == ScratchKategori.bloklarim) continue;
            if (sahibi.kategori == ScratchKategori.degiskenler &&
                sahibi.sekil == ScratchSekil.raportor) {
              continue;
            }
            expect(parcalar, contains(p.metin),
                reason: '$d/$id: "${p.metin}" Scratch sozlugunde yok');
          }
        }
      }
    });

    test('ornek bloklar dort dilde Scratch\'teki yaziyla', () {
      String m(String id, String d) =>
          ScratchBlokKatalogu.tanim(id, d)!.duzMetin;
      expect(m('move_10', 'tr'), '10 adım git');
      expect(m('move_10', 'en'), 'move 10 steps');
      expect(m('move_10', 'de'), 'gehe 10 er Schritt');
      expect(m('move_10', 'es'), 'mover 10 pasos');
      expect(m('repeat_4', 'tr'), '4 defa tekrarla');
      expect(m('repeat_4', 'de'), 'wiederhole 4 mal');
      expect(m('green_flag', 'en'), 'when ⚑ clicked');
      expect(m('green_flag', 'tr'), '⚑ e tıklandığında');
      expect(m('if_space', 'en'), 'if <key space pressed?> then');
      expect(m('if_space', 'es'), 'si <¿tecla espacio presionada?> entonces');
      expect(m('say_hello', 'de'), 'sage Hallo!');
      expect(m('pen_down', 'tr'), 'kalemi bastır');
      expect(m('play_note_60', 'en'), 'play note 60 for 0.5 beats');
      // Bayrak bir SIMGE, yazi degil (Scratch'teki gibi).
      expect(
          ScratchBlokKatalogu.tanim('green_flag', 'en')!
              .satir
              .whereType<SbIkon>()
              .single
              .ikon,
          ScratchIkon.bayrak);
    });
  });

  group('olculer ve oturma', () {
    const s = 1.0;
    ScratchBlokTanimi t(String id) => ScratchBlokKatalogu.tanim(id, 'en')!;

    test('Scratch olculeri (1x)', () {
      // Yigin blok 48, sapka 16.5 + 48, C ust kol 48, alt kol 32, bos
      // agiz 24, deger blogu 40 (girdili) / 32 (yalniz yazi).
      expect(ScratchBlokOlcer.yukseklik(t('move_10'), s), 48);
      expect(ScratchBlokOlcer.yukseklik(t('green_flag'), s), 64.5);
      expect(
          ScratchBlokOlcer.yukseklik(t('repeat_4'), s,
              parca: ScratchCParcasi.ust),
          48);
      expect(
          ScratchBlokOlcer.yukseklik(t('repeat_4'), s,
              parca: ScratchCParcasi.alt),
          32);
      expect(ScratchBlokOlcer.yukseklik(t('repeat_4'), s), 48 + 24 + 32);
      expect(ScratchBlokOlcer.yukseklik(t('random_1_6'), s), 40);
      expect(ScratchBlokOlcer.yukseklik(t('len_questions'), s), 40);
      // Ic ice altigen satiri buyutur (Scratch'te de oyle).
      expect(
          ScratchBlokOlcer.yukseklik(t('if_space'), s,
              parca: ScratchCParcasi.ust),
          greaterThan(48));
      // En az genislikler.
      expect(ScratchBlokOlcer.genislik(t('forever'), s,
              parca: ScratchCParcasi.ust),
          greaterThanOrEqualTo(160));
      expect(ScratchBlokOlcer.genislik(t('green_flag'), s),
          greaterThanOrEqualTo(100));
      // Olcek dogrusal.
      expect(ScratchBlokOlcer.yukseklik(t('move_10'), 0.5), 24);
    });

    testWidgets('her sekil cizilir, tasmaz, yerlesim boyu olcuyle ayni',
        (tester) async {
      final ornekler = {
        'sapka': 'green_flag',
        'yigin': 'move_10',
        'kapak': 'delete_clone',
        'c': 'repeat_4',
        'cKapak': 'forever',
        'degilse': 'if_else_empty',
        'raportor': 'random_1_10',
        'mantiksal': 'touching_edge',
        'tanim': 'define_polygon',
      };
      for (final e in ornekler.entries) {
        final tanim = t(e.value);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: ScratchBlok(
                  key: ValueKey(e.key), tanim: tanim, olcek: s, sigdir: false),
            ),
          ),
        ));
        expect(tester.takeException(), isNull, reason: e.key);
        final boyut = tester.getSize(find.byKey(ValueKey(e.key)));
        expect(boyut.height, closeTo(ScratchBlokOlcer.yukseklik(tanim, s), 0.01),
            reason: e.key);
        expect(boyut.width,
            closeTo(ScratchBlokOlcer.genislik(tanim, s), 0.01),
            reason: e.key);
      }
    });

    testWidgets('bosluksuz Column\'da bloklar ust uste oturuyor',
        (tester) async {
      const olcek = ScratchBlok.varsayilanOlcek;
      final ids = ['green_flag', 'move_10', 'say_hello', 'turn_90'];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final id in ids)
                  ScratchBlok(key: ValueKey(id), tanim: t(id), olcek: olcek),
                ScratchBlok(
                    key: const ValueKey('ust'),
                    tanim: t('repeat_4'),
                    olcek: olcek,
                    parca: ScratchCParcasi.ust),
                ScratchCSirti(
                  kategori: ScratchKategori.kontrol,
                  olcek: olcek,
                  child: ScratchBlok(
                      key: const ValueKey('ic'),
                      tanim: t('move_10'),
                      olcek: olcek),
                ),
                ScratchBlok(
                    key: const ValueKey('alt'),
                    tanim: t('repeat_4'),
                    olcek: olcek,
                    parca: ScratchCParcasi.alt,
                    icDolu: true),
              ],
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
      // Her blogun ustu, bir oncekinin govdesinin alti: tirnak sinirin
      // disinda kaliyor ve bir sonraki blogun centigine oturuyor.
      final sira = [...ids, 'ust'];
      for (var i = 1; i < sira.length; i++) {
        final onceki = tester.getRect(find.byKey(ValueKey(sira[i - 1])));
        final bu = tester.getRect(find.byKey(ValueKey(sira[i])));
        expect(bu.top, closeTo(onceki.bottom, 0.01), reason: sira[i]);
        // Centik ve tirnak ayni x'te: bloklar soldan hizali.
        expect(bu.left, onceki.left);
      }
      final ust = tester.getRect(find.byKey(const ValueKey('ust')));
      final ic = tester.getRect(find.byKey(const ValueKey('ic')));
      final alt = tester.getRect(find.byKey(const ValueKey('alt')));
      expect(ic.top, closeTo(ust.bottom, 0.01));
      expect(ic.left - ust.left,
          closeTo(ScratchBlokOlcer.kolGenisligi(olcek), 0.01),
          reason: 'Agizdaki blok C kolunun hemen yaninda.');
      expect(alt.top, closeTo(ic.bottom, 0.01));
      expect(alt.width, ust.width, reason: 'Ust ve alt kol ayni genislikte.');
    });

    testWidgets('dar alanda blok kuculup sigiyor', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 200,
              child: ScratchBlok(
                  key: const ValueKey('b'), tanim: t('say_random_question')),
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(const ValueKey('b'))).width,
          lessThanOrEqualTo(200));
    });
  });

  test('Scratch kursu disinda eski cizim korunuyor', () {
    // Arduino/mBlock bloklari Scratch etiketi tasimiyor; Scratch'e ozgu
    // cizim yalnizca Scratch kursunda.
    final kod =
        File('lib/courses/screens/widgets/step_widgets.dart').readAsStringSync();
    expect(kod.contains("bool scratchKursu(Course course) => course.id == 'scratch';"),
        isTrue);
  });
}
