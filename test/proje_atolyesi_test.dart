// PROJE ATOLYESI: hedefler sonuca bakiyor, ornek cozumler gercekten
// cozuyor, yanlis kod gecmiyor; projeler kaydedilip yeniden aciliyor.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/scratch_atolyeleri.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/yurutme/atolye_hedefleri.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/courses/yurutme/scratch_blok_katalogu.dart';
import 'package:devkom_app/services/proje_deposu.dart';

List<bool> _durum(ProjeAtolyesiStep a, String kod, {int tohum = 3}) =>
    AtolyeDenetimi.durumlar(
        a.hedefler,
        AtolyeDenetimi.atolyede(a, KodYapisi.coz(kod),
            rastgele: Random(tohum)));

void main() {
  group('ornek cozumler', () {
    for (final a in ScratchAtolyeleri.hepsi) {
      test('${a.id}: ornek cozum butun hedefleri sagliyor', () {
        for (var t = 0; t < 8; t++) {
          expect(_durum(a, a.ornekCozum, tohum: t), everyElement(isTrue),
              reason: '${a.id} tohum $t');
        }
      });
    }

    test('her atolyenin 2-4 hedefi, ipucu ve dort dilde metni var', () {
      for (final a in ScratchAtolyeleri.hepsi) {
        expect(a.hedefler.length, inInclusiveRange(2, 4), reason: a.id);
        for (final d in ['tr', 'en', 'de', 'es']) {
          expect(a.titleFor(d).trim(), isNotEmpty);
          expect(a.ipucuFor(d).trim(), isNotEmpty);
          for (final h in a.hedefler) {
            expect(h.metinFor(d).trim(), isNotEmpty, reason: '${a.id} $d');
          }
          if (d != 'tr') {
            expect(a.titleFor(d), isNot(a.title), reason: '${a.id} $d');
            expect(a.descriptionFor(d), isNot(a.description));
            for (final h in a.hedefler) {
              expect(h.metinFor(d), isNot(h.metin), reason: '${a.id} $d');
            }
          }
        }
      }
    });

    test('ornek cozumun her blogu palette ve Scratch katalogunda', () {
      for (final a in [...ScratchAtolyeleri.hepsi, ScratchAtolyeleri.serbest]) {
        final ids = a.palet.map((b) => b.id).toSet();
        for (final id in KodYapisi.bloklar(a.ornekCozum)) {
          expect(ids, contains(id), reason: '${a.id}: $id');
        }
        for (final b in a.palet) {
          for (final d in ['tr', 'en', 'de', 'es']) {
            expect(ScratchBlokKatalogu.tanim(b.id, d), isNotNull,
                reason: '${a.id}: ${b.id}');
          }
        }
        expect(a.sayiDuzenlenebilir.difference(ids), isEmpty, reason: a.id);
      }
    });
  });

  group('yanlis kod gecmiyor', () {
    test('bos kod hicbir hedefi saglamiyor', () {
      for (final a in ScratchAtolyeleri.hepsi) {
        expect(_durum(a, ''), everyElement(isFalse), reason: a.id);
      }
    });

    test('yildiz: kare ciziliyor ama 5 cizgi ve kapali yildiz yok', () {
      final d = _durum(ScratchAtolyeleri.yildizCiz,
          'green_flag pen_clear pen_down repeat_4 move_100 turn_90 }');
      expect(d, [false, false, true]);
      // Kalem inmeden: cizgi yok.
      expect(
          _durum(ScratchAtolyeleri.yildizCiz,
              'green_flag repeat_4=5 move_100 turn_90=144 }'),
          [false, false, true]);
      // Acik cizgi (donmeden): 5 parca ama ayni yonde -> tek kenar.
      expect(
          _durum(ScratchAtolyeleri.yildizCiz,
              'green_flag pen_down repeat_4=5 move_100 }')[0],
          isFalse);
    });

    test('yildiz toplayici: eger dongunun ICINDE olursa sonuc ayni ama '
        'puan 10 artmazsa hedef tutmuyor', () {
      final d = _durum(ScratchAtolyeleri.yildizToplayici,
          'green_flag set_score_0 repeat_5 change_score } if_score_50 say_win }');
      expect(d, [true, false, false]);
    });

    test('tuslarla Devi: sapkasiz bloklar calismiyor', () {
      final d = _durum(ScratchAtolyeleri.tuslarlaDevi,
          'say_hello change_x=100 change_y_up');
      expect(d, everyElement(isFalse));
    });

    test('dans: haberi alan yoksa haber hedefi tutmuyor', () {
      final d = _durum(ScratchAtolyeleri.dansPartisi,
          'green_flag broadcast_dance repeat_4 next_costume turn_90 }');
      expect(d, [false, true, false]);
    });

    test('cicek: kutuphanedeki tanimla cagirmak "tanimla" hedefini '
        'saglamiyor', () {
      final d = _durum(ScratchAtolyeleri.cokgenCicegi,
          'green_flag pen_down repeat_4 call_polygon_6 turn_90 }');
      expect(d[0], isFalse);
      expect(d[1], isTrue);
    });
  });

  group('derslerde', () {
    test('proje adimlari atolyeye dondu; 8-11 modullerinin projesi var', () {
      final adimlar =
          CourseModules.allLessons('scratch').expand((l) => l.steps).toList();
      expect(adimlar.whereType<ProjectStep>(), isEmpty,
          reason: 'Scratch kursunda "bilgisayarda yap" projesi kalmamali');
      final atolyeler =
          adimlar.whereType<ProjeAtolyesiStep>().map((s) => s.id).toSet();
      expect(atolyeler,
          containsAll(ScratchAtolyeleri.hepsi.map((a) => a.id).toSet()));
      for (final m in CourseModules.forCourse('scratch').skip(7)) {
        expect(m.lessons.expand((l) => l.steps).whereType<ProjeAtolyesiStep>(),
            isNotEmpty,
            reason: m.title);
      }
    });
  });

  group('Projelerim (kaydet / ac)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('kaydet, listele, ac, ustune yaz, sil', () async {
      final kod = KodYapisi.coz(ScratchAtolyeleri.yildizCiz.ornekCozum);
      final p = await ProjeDeposu.kaydet(KayitliProje(
        id: 'a1',
        ad: 'Yıldızım',
        kursId: 'scratch',
        adimId: 's8_2_atolye',
        kod: kod,
        tarih: DateTime(2026, 10, 1),
      ));
      await ProjeDeposu.kaydet(KayitliProje(
        id: 'a2',
        ad: 'Zar',
        kursId: 'scratch',
        kod: KodYapisi.coz('green_flag say_hello'),
        tarih: DateTime(2026, 10, 2),
      ));
      final hepsi = await ProjeDeposu.tumu(kursId: 'scratch');
      expect(hepsi.map((k) => k.id), ['a2', 'a1'], reason: 'yeni once');

      final acilan = (await ProjeDeposu.bul('a1'))!;
      expect(acilan.kod, kod, reason: 'sayilar (repeat_4=5) dahil');
      expect(acilan.kod[3].deger, 5);
      // Yeniden calistirilinca ayni sonuc.
      final atolye = ScratchAtolyeleri.bul(acilan.adimId)!;
      expect(
          AtolyeDenetimi.durumlar(atolye.hedefler,
              AtolyeDenetimi.calistir(acilan.kod, atolye.palet)),
          everyElement(isTrue));

      await ProjeDeposu.kaydet(p.copyWith(ad: 'Yıldız 2'));
      expect((await ProjeDeposu.tumu()).length, 2);
      expect((await ProjeDeposu.bul('a1'))!.ad, 'Yıldız 2');

      await ProjeDeposu.sil('a2');
      expect((await ProjeDeposu.tumu()).map((k) => k.id), ['a1']);
    });

    test('bozuk kayit listeyi bozmuyor', () async {
      SharedPreferences.setMockInitialValues({
        ProjeDeposu.anahtar: '[{"id":"x"}, {"id":"y","ad":"Y","kurs":"scratch",'
            '"kod":[{"id":"green_flag"}],"t":1}]'
      });
      final l = await ProjeDeposu.tumu();
      expect(l.map((k) => k.id), ['y']);
    });
  });
}
