// HER MODULUN SINAVI VAR.
//
// Modul sinavi derslerin icindeki coktan secmeli sorulari topluyor ve
// en az uc soru istiyor. Scratch'in on bir modulunden yalnizca ikisinde
// (1 ve 4) bu kadar soru vardi; geri kalanlarda sinav karti hic
// cikmiyordu. Modullere ders icinde gorunmeyen TEKRAR sorulari eklendi.
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/module_quiz_screen.dart';

const _diller = ['tr', 'en', 'de', 'es'];

void main() {
  for (final kurs in ['scratch', 'mblock']) {
    test('$kurs: her modulun sinavinda en az 3 soru var', () {
      var no = 0;
      for (final m in CourseModules.forCourse(kurs)) {
        no++;
        final sorular = ModuleQuizScreen.collectQuestions(m.lessons,
            tekrarSorulari: m.tekrarSorulari);
        expect(sorular.length, greaterThanOrEqualTo(3),
            reason: '$kurs modul $no (${m.title})');
      }
    });
  }

  test('tekrar sorulari derslerdeki sorularin kopyasi degil', () {
    final dersSorulari = {
      for (final k in ['scratch', 'mblock'])
        for (final l in CourseModules.allLessons(k))
          for (final s in l.steps.whereType<MultipleChoiceStep>()) s.question,
    };
    final kimlikler = <String>{};
    for (final k in ['scratch', 'mblock']) {
      for (final m in CourseModules.forCourse(k)) {
        for (final s in m.tekrarSorulari) {
          expect(dersSorulari, isNot(contains(s.question)), reason: s.id);
          expect(kimlikler.add(s.id), isTrue, reason: 'tekrar: ${s.id}');
        }
      }
    }
    expect(kimlikler.length, greaterThanOrEqualTo(20));
  });

  test('tekrar sorulari dort dilde, cevabi ele vermiyor, secenekler tekil',
      () {
    for (final k in ['scratch', 'mblock']) {
      for (final m in CourseModules.forCourse(k)) {
        for (final s in m.tekrarSorulari) {
          expect(s.correctIndex, inInclusiveRange(0, s.options.length - 1));
          expect(s.options.length, greaterThanOrEqualTo(3), reason: s.id);
          for (final o in s.options) {
            expect(o.emoji, isNull, reason: s.id);
          }
          for (final d in _diller) {
            final metinler = s.options.map((o) => o.textFor(d)).toList();
            expect(metinler.toSet().length, metinler.length,
                reason: '${s.id} $d');
            expect(s.questionFor(d).trim(), isNotEmpty);
            expect(s.explanationFor(d).trim(), isNotEmpty);
            if (d != 'tr') {
              expect(s.questionFor(d), isNot(s.question), reason: '${s.id} $d');
              expect(s.explanationFor(d), isNot(s.explanation),
                  reason: '${s.id} $d');
            }
          }
        }
      }
    }
  });

  test('dogru cevaplar hep ayni sirada degil', () {
    final siralar = {
      for (final k in ['scratch', 'mblock'])
        for (final m in CourseModules.forCourse(k))
          for (final s in m.tekrarSorulari) s.correctIndex,
    };
    expect(siralar.length, greaterThanOrEqualTo(3));
  });
}
