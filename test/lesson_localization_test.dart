// Ders icerigi dil testleri.
//
// Iki ayri kusuru yakaliyor:
//
//  1. `pickLang` eskiden yalnizca `lang == 'en'` ise Ingilizceyi
//     seciyordu. Uygulama Almanca ve Ispanyolcayi da destekler hale
//     gelince bu, Almanca secen bir kullaniciya — Ingilizce cevirisi
//     HAZIR OLDUGU HALDE — Turkce ders icerigi gostermek demek oldu.
//
//  2. Ders BASLIKLARININ Ingilizcesi 95 dersin 19'unda vardi. Ana
//     sayfadaki "sirada ne var" karti, yol haritasi ve kurs listeleri
//     hep bu basligi gosteriyor; yani Ingilizce acan bir kullanicinin
//     gordugu neredeyse her ders adi Turkceydi.
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

List<InteractiveLesson> get _allLessons => [
      ...ArduinoLessonsData.module1,
      ...ArduinoLessonsData.module2,
      ...ArduinoLessonsData.module3,
      ...ArduinoLessonsData.module4,
      ...ArduinoLessonsData.module5,
      ...ArduinoLessonsData.module6,
      ...CSharpLessonsData.module1,
      ...CSharpLessonsData.module2,
      ...CSharpLessonsData.module3,
      ...CSharpLessonsData.module4,
      ...CssLessonsData.module1,
      ...CssLessonsData.module2,
      ...CssLessonsData.module3,
      ...CssLessonsData.module4,
      ...HtmlLessonsData.module1,
      ...HtmlLessonsData.module2,
      ...HtmlLessonsData.module3,
      ...HtmlLessonsData.module4,
      ...HtmlLessonsData.module5,
      ...HtmlLessonsData.module6,
      ...JavaLessonsData.module1,
      ...JavaLessonsData.module2,
      ...JavaLessonsData.module3,
      ...JavaLessonsData.module4,
      ...PythonLessonsData.module1,
      ...PythonLessonsData.module2,
      ...PythonLessonsData.module3,
      ...PythonLessonsData.module4,
      ...PythonLessonsData.module5,
      ...PythonLessonsData.module6,
      ...PythonLessonsData.module7,
      ...PythonLessonsData.module8,
      ...PythonLessonsData.module9,
      ...ScratchLessonsData.allLessons,
      ...MBlockLessonsData.allLessons,
    ];

void main() {
  group('pickLang', () {
    test('Turkce her zaman Turkce metni verir', () {
      expect(pickLang('Merhaba', 'Hello', 'tr'), 'Merhaba');
    });

    test('Turkce disindaki diller, varsa Ingilizceye duser', () {
      for (final lang in ['en', 'de', 'es']) {
        expect(pickLang('Merhaba', 'Hello', lang), 'Hello', reason: lang);
      }
    });

    test('Ingilizcesi yoksa Turkce metin kalir — ekran bos kalmaz', () {
      for (final lang in ['en', 'de', 'es']) {
        expect(pickLang('Merhaba', null, lang), 'Merhaba', reason: lang);
        expect(pickLang('Merhaba', '  ', lang), 'Merhaba', reason: lang);
      }
    });

    test('liste ve nullable surumleri de ayni kurala uyar', () {
      expect(pickLangList(['a'], ['b'], 'de'), ['b']);
      expect(pickLangList(['a'], const [], 'de'), ['a']);
      expect(pickLangNullable('a', 'b', 'es'), 'b');
      expect(pickLangNullable('a', null, 'es'), 'a');
    });
  });

  group('Ders basliklari', () {
    test('her dersin Ingilizce basligi ve alt basligi var', () {
      final missing = <String>[];
      for (final lesson in _allLessons) {
        if ((lesson.titleEn ?? '').trim().isEmpty) {
          missing.add('${lesson.id} (title)');
        }
        if ((lesson.subtitleEn ?? '').trim().isEmpty) {
          missing.add('${lesson.id} (subtitle)');
        }
      }
      expect(missing, isEmpty,
          reason: 'Ingilizce basligi eksik dersler:\n${missing.join('\n')}');
    });

    test('baslik dogru dili veriyor, yoksa Ingilizceye duser', () {
      // Ceviri kurs kurs ekleniyor: Almanca/Ispanyolca baslik VARSA o
      // gosterilir, yoksa Ingilizce, o da yoksa Turkce. Bu test her uc
      // basamagi da kontrol ediyor - "hep Ingilizce" diye sabitlemek,
      // ceviri eklendigi anda yaniltici olurdu.
      for (final lesson in _allLessons) {
        expect(lesson.titleFor('tr'), lesson.title, reason: lesson.id);
        expect(lesson.titleFor('en'), lesson.titleEn, reason: lesson.id);

        expect(lesson.titleFor('de'), lesson.titleDe ?? lesson.titleEn,
            reason: '${lesson.id}/de');
        expect(lesson.titleFor('es'), lesson.titleEs ?? lesson.titleEn,
            reason: '${lesson.id}/es');
      }
    });

    test('hicbir dilde Turkce metne dusen ders yok', () {
      // Ingilizce baslik her derste zorunlu (ustteki test); dolayisiyla
      // hicbir dil Turkce'ye dusmemeli. Duserse o dili secen cocuk
      // anlamadigi bir dilde baslik goruyor demektir.
      final dusenler = <String>[];
      for (final lesson in _allLessons) {
        for (final lang in ['en', 'de', 'es']) {
          if (lesson.titleFor(lang) == lesson.title &&
              lesson.title != lesson.titleEn) {
            dusenler.add('${lesson.id}/$lang');
          }
        }
      }
      expect(dusenler, isEmpty,
          reason: 'Turkce metne dusen dersler:\n${dusenler.join('\n')}');
    });
  });
}
