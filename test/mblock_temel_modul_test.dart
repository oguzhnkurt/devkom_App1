import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/mblock_lessons_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';

/// mBlock kursunun kartsiz ilk modulunun denetimi.
///
/// NEDEN
/// -----
/// Kurs eskiden ilk dersinde "cihaz mi kukla mi secili", "yukleme modu mu
/// canli mod mu" diye soruyordu. Ikisi de dogru bilgi ama cocuk henuz tek
/// blok surüklememisken karsiligi ekranda gorunmuyor. Yeni modul 0 bu
/// yuzden tamamen kartsiz: palet, blok sekilleri, sira, tekrar, bekleme.
///
/// Bu testin isi o sozu korumak. Yarin biri modul 0'a "9. pindeki LED"
/// diye bir ornek eklerse modul sessizce eski haline doner; asagidaki
/// donanim kelimesi taramasi bunu yakalar. Tek istisna son dersin
/// kapanisindaki kopru adimi: orada "ayni bloklar gercek bir karta gidiyor"
/// demek zorundayiz.
void main() {
  /// Modul 0'da gecmemesi gereken donanim kelimeleri (kucuk harf).
  const donanimKelimeleri = [
    'pin',
    'led',
    'direnc',
    'direnç',
    'breadboard',
    'buzzer',
    'servo',
    'volt',
    'arduino',
    'yukleme modu',
    'yükleme modu',
    'canli mod',
    'canlı mod',
  ];

  /// Koprü adimi — donanimdan tek bahseden yer, bilerek muaf.
  const kopruAdimi = 'm0_3_summary';

  List<String> metinleriTopla(LessonStep step) {
    final out = <String>[];
    void ekle(String? s) {
      if (s != null && s.isNotEmpty) out.add(s);
    }

    for (final lang in ['tr', 'en', 'de', 'es']) {
      if (step is IntroStep) {
        ekle(step.mascotMessageFor(lang));
        out.addAll(step.highlightsFor(lang));
      } else if (step is ExplanationStep) {
        ekle(step.titleFor(lang));
        ekle(step.contentFor(lang));
        ekle(step.tipFor(lang));
        for (final v in step.visuals) {
          ekle(v.contentFor(lang));
          ekle(v.labelFor(lang));
        }
      } else if (step is MultipleChoiceStep) {
        ekle(step.questionFor(lang));
        ekle(step.explanationFor(lang));
        for (final o in step.options) {
          ekle(o.textFor(lang));
        }
      } else if (step is MatchingStep) {
        ekle(step.instructionFor(lang));
        for (final p in step.pairs) {
          ekle(p.leftFor(lang));
          ekle(p.rightFor(lang));
        }
      } else if (step is OrderingStep) {
        ekle(step.instructionFor(lang));
        ekle(step.contextFor(lang));
        for (final i in step.items) {
          ekle(i.contentFor(lang));
        }
      } else if (step is BlockBuilderStep) {
        ekle(step.instructionFor(lang));
        ekle(step.goalFor(lang));
        for (final b in step.availableBlocks) {
          ekle(b.labelFor(lang));
        }
      }
    }
    return out;
  }

  group('mBlock modul 0 — kartsiz baslangic', () {
    test('modul 0 uc dersten olusuyor ve kursun basinda duruyor', () {
      expect(MBlockLessonsData.module0.length, 3);

      final moduller = CourseModules.forCourse('mblock');
      expect(moduller.first.lessons.map((l) => l.id).toList(),
          ['mblock_0_1', 'mblock_0_2', 'mblock_0_3'],
          reason: 'Kartsiz modul kursun ILK modulu olmali; donanim '
              'harmani bundan sonra gelir.');
    });

    test('modul 0 derslerinde donanim gecmiyor', () {
      for (final lesson in MBlockLessonsData.module0) {
        for (final step in lesson.steps) {
          if (step.id == kopruAdimi) continue;
          for (final metin in metinleriTopla(step)) {
            final kucuk = metin.toLowerCase();
            for (final kelime in donanimKelimeleri) {
              // Kelime sinirli arama: "pin" aramasi "piksel"i, "led"
              // aramasi Almanca "erledigt"i yakalamasin.
              final desen = RegExp('(?<![a-z])$kelime(?![a-z])');
              expect(desen.hasMatch(kucuk), isFalse,
                  reason:
                      '${lesson.id} / ${step.id} adiminda "$kelime" geciyor. '
                      'Modul 0 kartsiz kalmali — donanim ornekleri modul '
                      '1 ve sonrasina ait.\nMetin: $metin');
            }
          }
        }
      }
    });

    test('kopru adimi karta gecisi gercekten soyluyor', () {
      final son = MBlockLessonsData.module0.last.steps
          .firstWhere((s) => s.id == kopruAdimi) as ExplanationStep;
      for (final lang in ['tr', 'en', 'de', 'es']) {
        expect(son.contentFor(lang).toLowerCase(), contains('led'),
            reason: 'Kapanis, ayni bloklarin gercek donanimi '
                'calistiracagini $lang dilinde de soylemeli.');
      }
    });

    test('modul 0 adimlari dort dilde yazilmis', () {
      for (final lesson in MBlockLessonsData.module0) {
        for (final lang in ['en', 'de', 'es']) {
          expect(lesson.titleFor(lang), isNot(lesson.title),
              reason: '${lesson.id} basligi $lang diline cevrilmemis.');
        }
        for (final step in lesson.steps) {
          if (step is ExplanationStep) {
            for (final lang in ['en', 'de', 'es']) {
              expect(step.contentFor(lang), isNot(step.content),
                  reason: '${step.id} metni $lang diline cevrilmemis.');
            }
          }
        }
      }
    });
  });

  group('mBlock ders sirasi', () {
    test('order degerleri 1..N kesintisiz ve tekrarsiz', () {
      // Sayi elle YAZILMIYOR: her yeni ders eklendiginde testi de
      // duzeltmek zorunda kalmak, testi bir engel haline getiriyordu
      // (once 11'di, proje modulu gelince 13 oldu). Onemli olan kac
      // ders oldugu degil, sirada BOSLUK ya da TEKRAR olmamasi.
      final orders = MBlockLessonsData.allLessons.map((l) => l.order).toList()
        ..sort();
      expect(orders, List.generate(orders.length, (i) => i + 1),
          reason: 'Ders sirasinda bosluk ya da tekrar var: $orders');
    });

    test('blok kurma adimlarindaki her id gercekten paletten geliyor', () {
      for (final lesson in MBlockLessonsData.module0) {
        for (final step in lesson.steps) {
          if (step is! BlockBuilderStep) continue;
          final mevcut = step.availableBlocks.map((b) => b.id).toSet();
          for (final id in step.correctSequence) {
            expect(mevcut, contains(id),
                reason: '${step.id} adiminda dogru cozum "$id" bloguna '
                    'dayaniyor ama o blok cocuga verilmemis — cozulemez '
                    'bir adim olur.');
          }
        }
      }
    });
  });
}
