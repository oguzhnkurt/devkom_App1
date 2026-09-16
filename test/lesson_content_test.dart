// Ders iceriginin yapisal butunlugu.
//
// Bu testler icerigin DOGRU olup olmadigini soylemiyor — bir sorunun
// cevabinin gercekten dogru olup olmadigina insan bakmali. Burada
// yakalanan sey, iceriğin cocugun ilerlemesini FIZIKSEL olarak
// engelledigi ya da cevabi ele verdigi durumlar. Hepsi gercekten
// yasandi:
//
//  * Her coktan secmeli soruda dogru secenege `emoji: '✅'`, yanlislara
//    '❌' yazilmisti ve bunlar cocuk cevaplamadan ONCE ciziliyordu.
//    556 secenek boyleydi: hicbir ders sorusu bir sey olcmuyordu.
//  * Arduino final projesinin blok adiminin dogru dizilimi 'set_yağmur'
//    diyordu, blogun kimligi ise 'set_yagmur' idi — adim %100 kayipla
//    bitiyordu, cocuk ne yaparsa yapsin.
//  * python_5_2 ile python_9_1 ayni `order` degerine sahipti.
//  * Ders icinde kullanilan uc adim tipinin ekranda karsiligi yoktu ve
//    "Step tipi henüz desteklenmiyor" yazisi ciziliyordu.
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/data/arduino_lessons_data.dart';
import 'package:devkom_app/courses/data/csharp_lessons_data.dart';
import 'package:devkom_app/courses/data/css_lessons_data.dart';
import 'package:devkom_app/courses/data/html_lessons_data.dart';
import 'package:devkom_app/courses/data/java_lessons_data.dart';
import 'package:devkom_app/courses/data/python_lessons_data.dart';
import 'package:devkom_app/courses/data/scratch_lessons_data.dart';
import 'package:devkom_app/courses/data/mblock_lessons_data.dart';

/// Kurs -> dersler (modul sirasiyla).
final Map<String, List<InteractiveLesson>> courses = {
  'arduino': [
    ...ArduinoLessonsData.module1,
    ...ArduinoLessonsData.module2,
    ...ArduinoLessonsData.module3,
    ...ArduinoLessonsData.module4,
    ...ArduinoLessonsData.module5,
    ...ArduinoLessonsData.module6,
  ],
  'csharp': [
    ...CSharpLessonsData.module1,
    ...CSharpLessonsData.module2,
    ...CSharpLessonsData.module3,
    ...CSharpLessonsData.module4,
  ],
  'css': [
    ...CssLessonsData.module1,
    ...CssLessonsData.module2,
    ...CssLessonsData.module3,
    ...CssLessonsData.module4,
  ],
  'html': [
    ...HtmlLessonsData.module1,
    ...HtmlLessonsData.module2,
    ...HtmlLessonsData.module3,
    ...HtmlLessonsData.module4,
    ...HtmlLessonsData.module5,
    ...HtmlLessonsData.module6,
  ],
  'java': [
    ...JavaLessonsData.module1,
    ...JavaLessonsData.module2,
    ...JavaLessonsData.module3,
    ...JavaLessonsData.module4,
  ],
  'python': [
    ...PythonLessonsData.module1,
    ...PythonLessonsData.module2,
    ...PythonLessonsData.module3,
    ...PythonLessonsData.module4,
    ...PythonLessonsData.module5,
    ...PythonLessonsData.module6,
    ...PythonLessonsData.module7,
    ...PythonLessonsData.module8,
    ...PythonLessonsData.module9,
  ],
  'scratch': ScratchLessonsData.allLessons,
  'mblock': MBlockLessonsData.allLessons,
};

Iterable<LessonStep> get allSteps =>
    courses.values.expand((l) => l).expand((l) => l.steps);

/// `interactive_lesson_screen.dart`'in `_buildStepWidget` switch'inde
/// gercekten bir dali olan tipler. Buraya eklemeden icerige yeni bir
/// tip koymak, cocuga hata metni gostermek demek.
const Set<StepType> supportedStepTypes = {
  StepType.intro,
  StepType.explanation,
  StepType.multipleChoice,
  StepType.dragAndDrop,
  StepType.blockBuilder,
  StepType.ordering,
  StepType.matching,
  StepType.miniGame,
  StepType.project,
  StepType.animation,
  StepType.codeComplete,
  StepType.typeTheCode,
  StepType.spotTheError,
};

/// Cevap anahtarini ele veren emojiler.
const Set<String> answerKeyEmojis = {'✅', '❌', '✔️', '✔', '❎', '✖️'};

void main() {
  test('kullanilan her adim tipinin ekranda bir karsiligi var', () {
    final used = allSteps.map((s) => s.type).toSet();
    final unsupported = used.difference(supportedStepTypes);
    expect(unsupported, isEmpty,
        reason: 'Bu tipler "Step tipi henüz desteklenmiyor" yazisina '
            'dusuyor: $unsupported');
  });

  group('Coktan secmeli sorular', () {
    test('correctIndex secenek araliginda', () {
      for (final step in allSteps.whereType<MultipleChoiceStep>()) {
        expect(step.options.length, greaterThanOrEqualTo(2),
            reason: step.id);
        expect(step.correctIndex, inInclusiveRange(0, step.options.length - 1),
            reason: step.id);
      }
    });

    test('hicbir secenek cevabi ele veren emoji tasimiyor', () {
      final leaks = <String>[];
      for (final step in allSteps.whereType<MultipleChoiceStep>()) {
        for (final o in step.options) {
          if (o.emoji != null && answerKeyEmojis.contains(o.emoji)) {
            leaks.add('${step.id}: ${o.emoji}');
          }
        }
      }
      expect(leaks, isEmpty,
          reason: 'Cevap ekranda isaretli:\n${leaks.take(20).join('\n')}');
    });

    test('ayni soruda iki ayni secenek yok', () {
      for (final step in allSteps.whereType<MultipleChoiceStep>()) {
        final texts = step.options.map((o) => o.text.trim()).toList();
        expect(texts.toSet().length, texts.length,
            reason: '${step.id}: ayni metinli iki secenek var');
      }
    });
  });

  test('blok adimlarinin dogru dizilimi gercekten kurulabiliyor', () {
    final broken = <String>[];
    for (final step in allSteps.whereType<BlockBuilderStep>()) {
      final ids = step.availableBlocks.map((b) => b.id).toSet();
      for (final wanted in step.correctSequence) {
        if (!ids.contains(wanted)) {
          broken.add('${step.id}: "$wanted" havuzda yok (${ids.join(", ")})');
        }
      }
      expect(step.correctSequence, isNotEmpty, reason: step.id);
    }
    expect(broken, isEmpty, reason: broken.join('\n'));
  });

  test('siralama adimlarinin dogru sirasi ogelerle ortusuyor', () {
    for (final step in allSteps.whereType<OrderingStep>()) {
      final ids = step.items.map((i) => i.id).toSet();
      expect(step.correctOrder.toSet(), ids, reason: step.id);
      expect(step.correctOrder.length, step.items.length, reason: step.id);
    }
  });

  test('eslestirme adimlarinda tekrar eden taraf yok', () {
    for (final step in allSteps.whereType<MatchingStep>()) {
      final lefts = step.pairs.map((p) => p.left).toList();
      final rights = step.pairs.map((p) => p.right).toList();
      expect(lefts.toSet().length, lefts.length, reason: '${step.id} sol');
      expect(rights.toSet().length, rights.length, reason: '${step.id} sag');
    }
  });

  test('adim kimlikleri kurs icinde benzersiz', () {
    for (final entry in courses.entries) {
      final ids = entry.value.expand((l) => l.steps).map((s) => s.id).toList();
      final dupes = <String>[];
      final seen = <String>{};
      for (final id in ids) {
        if (!seen.add(id)) dupes.add(id);
      }
      expect(dupes, isEmpty, reason: '${entry.key}: ${dupes.join(", ")}');
    }
  });

  test('ders sirasi benzersiz ve modul sirasiyla uyumlu', () {
    for (final entry in courses.entries) {
      final orders = entry.value.map((l) => l.order).toList();
      expect(orders.toSet().length, orders.length,
          reason: '${entry.key}: ayni order iki derste');
      // Modul listeleri zaten sirali eklendi; order da ayni sirada olmali.
      final sorted = [...orders]..sort();
      expect(orders, sorted,
          reason: '${entry.key}: order, modul sirasini takip etmiyor');
    }
  });

  test('ders kimlikleri benzersiz', () {
    final all = courses.values.expand((l) => l).map((l) => l.id).toList();
    expect(all.toSet().length, all.length);
  });
}
