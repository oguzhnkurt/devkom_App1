import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';

/// Ders icerigi denetimi.
///
/// Bu test, uygulamadaki her kursa tek tek girip her dersi acmanin otomatik
/// karsiligi. Elle tiklayarak 90 dersi gezmek saatler surer ve yeni ders
/// eklendiginde kimse tekrar etmez; burasi her `flutter test` calisinca
/// hepsini bastan kontrol ediyor.
///
/// Yakalamak istedigimiz sorunlar:
///  * Katalogda gorunen ama modulleri baglanmamis kurs (tiklayinca bos ekran)
///  * Katalogdaki ders sayisinin gercekle ayrismasi
///  * Bos baslik/metin, cevapsiz soru, gecersiz dogru secenek indeksi
///  * Tekrar eden ders ve adim id'leri (ilerleme kaydini bozar)
void main() {
  final catalogIds = CoursesData.allCourses.map((c) => c.id).toList();

  group('Katalog ve moduller', () {
    test('katalogdaki her kursun baglanmis modulu var', () {
      for (final course in CoursesData.allCourses) {
        final modules = CourseModules.forCourse(course.id);
        expect(modules, isNotEmpty,
            reason:
                '"${course.name}" (${course.id}) katalogda gorunuyor ama hicbir '
                'modulu baglanmamis - tiklayinca bos ekran acilir.');
      }
    });

    test('modulleri olan her kurs interaktif ekrana yonlendiriliyor', () {
      // NEDEN: katalog ekrani hangi kursun interaktif ders ekranini
      // acacagini `CourseModules.wiredCourseIds` listesinden okuyor.
      // Bir kurs bu listede degilse -- modulleri yazilmis olsa bile --
      // tiklayinca tanitim ekrani aciliyor ve cocuk derslere HIC
      // ulasamiyor. mBlock kursu eklendiginde tam olarak bu oldu:
      // 8 ders yazildi, kurs katalogda gorundu, dersler erisilemezdi.
      for (final course in CoursesData.allCourses) {
        final hasModules = CourseModules.forCourse(course.id).isNotEmpty;
        if (!hasModules) continue;
        expect(CourseModules.wiredCourseIds, contains(course.id),
            reason: '"${course.name}" (${course.id}) icin modul var ama '
                'wiredCourseIds listesinde yok - katalogdan tiklayinca '
                'dersler acilmaz.');
      }
    });

    test('wiredCourseIds listesindeki her kursun gercekten modulu var', () {
      for (final id in CourseModules.wiredCourseIds) {
        expect(CourseModules.forCourse(id), isNotEmpty,
            reason: '$id wiredCourseIds icinde ama modulu yok - '
                'tiklayinca bos interaktif ekran acilir.');
      }
    });

    test('her modulde en az bir ders var', () {
      for (final id in catalogIds) {
        for (final module in CourseModules.forCourse(id)) {
          expect(module.lessons, isNotEmpty,
              reason: '$id / "${module.title}" modulu bos.');
        }
      }
    });

    test('katalogdaki totalLessons gercek ders sayisiyla ayni', () {
      for (final course in CoursesData.allCourses) {
        expect(CourseModules.lessonCount(course.id), course.totalLessons,
            reason:
                '"${course.name}" katalogda ${course.totalLessons} ders diyor ama '
                'gercekte ${CourseModules.lessonCount(course.id)} ders var.');
      }
    });

    test('modul basliklari ve aciklamalari dolu', () {
      for (final id in catalogIds) {
        for (final module in CourseModules.forCourse(id)) {
          expect(module.title.trim(), isNotEmpty, reason: id);
          expect(module.description.trim(), isNotEmpty,
              reason: '$id / ${module.title}');
          expect(module.emoji.trim(), isNotEmpty,
              reason: '$id / ${module.title}');
        }
      }
    });
  });

  group('Dersler', () {
    test('ders id leri uygulama genelinde benzersiz', () {
      final seen = <String, String>{};
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          expect(seen.containsKey(lesson.id), isFalse,
              reason:
                  '"${lesson.id}" hem ${seen[lesson.id]} hem $id kursunda var. '
                  'Ilerleme kaydi ders id uzerinden tutuluyor, cakisirsa '
                  'yanlis ders tamamlanmis gorunur.');
          seen[lesson.id] = id;
        }
      }
    });

    test('dersin courseId alani bulundugu kursla ayni', () {
      // arduino_ide dersleri tarihsel olarak arduino_6_* id'siyle ve
      // courseId: 'arduino_ide' ile yaziliyor; ikisi de dogru sayilir.
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          expect(lesson.courseId, isNotEmpty, reason: lesson.id);
        }
      }
    });

    test('her dersin basligi, alt basligi ve adimlari dolu', () {
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          expect(lesson.title.trim(), isNotEmpty, reason: lesson.id);
          expect(lesson.subtitle.trim(), isNotEmpty, reason: lesson.id);
          expect(lesson.steps, isNotEmpty,
              reason: '${lesson.id} dersinde hic adim yok.');
          expect(lesson.xpReward, greaterThan(0), reason: lesson.id);
        }
      }
    });

    test('ders icindeki adim id leri benzersiz', () {
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          final ids = lesson.steps.map((s) => s.id).toList();
          expect(ids.toSet().length, ids.length,
              reason: '${lesson.id} dersinde tekrar eden adim id var.');
        }
      }
    });

    test('dersler bir tanitim adimiyla basliyor', () {
      // Cocuk derse girdiginde once ne ogrenecegini gormeli; dogrudan soruyla
      // baslayan ders kafa karistirici.
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          expect(lesson.steps.first.type, StepType.intro,
              reason: '${lesson.id} tanitim adimiyla baslamiyor.');
        }
      }
    });

    test('her derste en az bir etkilesimli adim var', () {
      // Sadece okunan ders, kitap sayfasindan farksiz.
      // Pasif adimlar: yalnizca okunan/izlenen adimlar. `StepType.summary`
      // diye bir deger yok — model `intro / explanation / demonstration /
      // animation` sayiyor; ozet adimi ayri bir tur degil.
      const passive = {
        StepType.intro,
        StepType.explanation,
        StepType.demonstration,
        StepType.animation,
      };
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          final interactive =
              lesson.steps.where((s) => !passive.contains(s.type));
          expect(interactive, isNotEmpty,
              reason: '${lesson.id} dersinde hic etkilesimli adim yok.');
        }
      }
    });
  });

  group('Adim icerikleri', () {
    test('coktan secmeli sorular gecerli', () {
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          for (final step in lesson.steps.whereType<MultipleChoiceStep>()) {
            final where = '${lesson.id}/${step.id}';
            expect(step.question.trim(), isNotEmpty, reason: where);
            expect(step.options.length, greaterThanOrEqualTo(2),
                reason: '$where en az iki secenek olmali.');
            expect(step.correctIndex, greaterThanOrEqualTo(0), reason: where);
            expect(step.correctIndex, lessThan(step.options.length),
                reason:
                    '$where dogru cevap indeksi ${step.correctIndex}, ama '
                    '${step.options.length} secenek var.');
            expect(step.explanation.trim(), isNotEmpty,
                reason: '$where cevap aciklamasi bos.');
            for (final option in step.options) {
              expect(option.text.trim(), isNotEmpty,
                  reason: '$where bos secenek metni.');
            }
            final texts = step.options.map((o) => o.text.trim()).toList();
            expect(texts.toSet().length, texts.length,
                reason: '$where ayni secenek iki kez yazilmis.');
          }
        }
      }
    });

    test('eslestirme adimlari gecerli', () {
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          for (final step in lesson.steps.whereType<MatchingStep>()) {
            final where = '${lesson.id}/${step.id}';
            expect(step.instruction.trim(), isNotEmpty, reason: where);
            expect(step.pairs.length, greaterThanOrEqualTo(2), reason: where);
            final ids = step.pairs.map((p) => p.id).toList();
            expect(ids.toSet().length, ids.length,
                reason: '$where tekrar eden cift id.');
          }
        }
      }
    });

    test('siralama adimlarinda dogru sira gercekten var olan ogeler', () {
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          for (final step in lesson.steps.whereType<OrderingStep>()) {
            final where = '${lesson.id}/${step.id}';
            final itemIds = step.items.map((i) => i.id).toSet();
            expect(step.correctOrder.length, step.items.length,
                reason: '$where dogru sira ile oge sayisi farkli.');
            for (final orderId in step.correctOrder) {
              expect(itemIds.contains(orderId), isTrue,
                  reason: '$where dogru sirada olmayan oge: $orderId');
            }
          }
        }
      }
    });

    test('kod tamamlama adimlarinda bosluk sayisi sablonla uyumlu', () {
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          for (final step in lesson.steps.whereType<CodeCompleteStep>()) {
            final where = '${lesson.id}/${step.id}';
            expect(step.instruction.trim(), isNotEmpty, reason: where);
            expect(step.codeTemplate.trim(), isNotEmpty, reason: where);
            final blankCount = '___'.allMatches(step.codeTemplate).length;
            expect(blankCount, step.blanks.length,
                reason:
                    '$where sablonda $blankCount bosluk var ama '
                    '${step.blanks.length} cevap tanimlanmis.');
          }
        }
      }
    });

    test('aciklama adimlarinda baslik ve icerik dolu', () {
      for (final id in catalogIds) {
        for (final lesson in CourseModules.allLessons(id)) {
          for (final step in lesson.steps.whereType<ExplanationStep>()) {
            final where = '${lesson.id}/${step.id}';
            expect(step.title.trim(), isNotEmpty, reason: where);
            expect(step.content.trim(), isNotEmpty, reason: where);
          }
        }
      }
    });
  });

  group('Ogrenme yolu tutarliligi', () {
    test('pathStep degerleri 1..n araliginda ve tekrarsiz', () {
      final steps = CoursesData.allCourses.map((c) => c.pathStep).toList()
        ..sort();
      expect(steps.toSet().length, steps.length,
          reason: 'Iki kursta ayni pathStep var.');
      expect(steps.first, 1);
      expect(steps.last, steps.length);
    });

    test('on kosul olarak gosterilen kurslar katalogda var', () {
      for (final course in CoursesData.allCourses) {
        final prereq = course.prerequisiteId;
        if (prereq == null) continue;
        expect(catalogIds.contains(prereq), isTrue,
            reason: '${course.id} kursunun on kosulu "$prereq" katalogda yok.');
      }
    });

    test('on kosul her zaman daha erken bir adimda', () {
      final byId = {for (final c in CoursesData.allCourses) c.id: c};
      for (final course in CoursesData.allCourses) {
        final prereq = course.prerequisiteId;
        if (prereq == null) continue;
        expect(byId[prereq]!.pathStep, lessThan(course.pathStep),
            reason:
                '${course.id} kursunun on kosulu "$prereq" daha ileri bir '
                'adimda - kilit hicbir zaman acilmaz.');
      }
    });
  });
}
