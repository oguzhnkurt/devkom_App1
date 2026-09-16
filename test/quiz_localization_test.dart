// Quiz sorulari dort dilde de kendi dilinde olmali.
//
// NEDEN
// -----
// `QuizQuestion` uzun sure yalnizca Turkce yaziliydi. Ders icerigi
// %100 Ingilizceye cevrilmisti ama quiz cevrilmemisti: Almanca secen
// cocuk dersi Almanca/Ingilizce goruyor, quize girince "HTML ne anlama
// gelir?" ile karsilasiyordu.
//
// Bu test uc seyi kilitliyor:
//  1. Her sorunun en/de/es karsiligi VAR.
//  2. Ceviri siklarinin SAYISI ve SIRASI Turkceyle ayni — cunku
//     `correctAnswer` bir INDEKS. Sirasi kayarsa soru sessizce yanlis
//     cevaplanir; ekranda hicbir hata gorunmez.
//  3. Ingilizce/Almanca/Ispanyolca metinde Turkceye ozgu harf yok.
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/quizzes_data.dart';
import 'package:devkom_app/courses/data/lessons_data.dart';
import 'package:devkom_app/courses/models/course_model.dart';

/// Turkce kalinti ararken hangi harflere bakilacagi DILE GORE degisir:
/// ä/ö/ü almancanin kendi harfleri, á/é/í/ó/ú/ñ ispanyolcanin.
const _turkishOnly = {
  'en': 'çÇğĞıİşŞöÖüÜ',
  'de': 'çÇğĞıİşŞ',
  'es': 'ğĞıİşŞöÖ',
};

/// Kod parcasinda cevrilmesi gereken bir kelime var mi?
///
/// Dilin kendi anahtar kelimeleri ve tek-iki harflik degisken adlari
/// disinda alfabetik bir sozcuk kaliyorsa, o sozcugu yazan biz olmusuz
/// demektir (`yas`, `Cocuk`, `Yetiskin`) ve cevrilmesi gerekir.
bool _dileBagliKod(String kod) {
  const notr = {
    'print', 'input', 'if', 'else', 'elif', 'for', 'while', 'range', 'in',
    'and', 'or', 'not', 'def', 'return', 'import', 'from', 'as', 'int',
    'str', 'float', 'bool', 'len', 'true', 'false', 'none', 'list', 'dict',
    'append', 'upper', 'lower', 'void', 'setup', 'loop', 'delay', 'pinmode',
    'digitalwrite', 'digitalread', 'analogread', 'output', 'input_pullup',
    'high', 'low', 'serial', 'begin', 'println', 'const', 'let', 'var',
    'function', 'console', 'log', 'document', 'style', 'color', 'font',
    'size', 'width', 'height', 'margin', 'padding', 'div', 'span', 'body',
    'html', 'head', 'title', 'select', 'where', 'insert', 'update', 'delete',
  };
  for (final m in RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşü_]+').allMatches(kod)) {
    final k = m.group(0)!.toLowerCase();
    if (k.length <= 2) continue; // a, b, x, y, i, n ...
    if (notr.contains(k)) continue;
    return true;
  }
  return false;
}

void main() {
  final quizzes = QuizzesData.all;

  test('quiz verisi bos degil', () {
    expect(quizzes, isNotEmpty);
    final soru = quizzes.values.fold<int>(0, (a, q) => a + q.questions.length);
    expect(soru, greaterThanOrEqualTo(52),
        reason: 'Soru sayisi dustu — bir quiz silinmis olabilir.');
  });

  for (final entry in quizzes.entries) {
    for (final q in entry.value.questions) {
      final yer = '${entry.key}/${q.id}';

      test('$yer — dort dilde de sorusu var', () {
        for (final lang in ['en', 'de', 'es']) {
          final metin = q.questionFor(lang);
          expect(metin, isNot(q.question),
              reason: '$yer sorusunun $lang cevirisi yok; '
                  'ekranda Turkce gorunuyor.');
          expect(metin.trim(), isNotEmpty);
        }
      });

      test('$yer — sik sayisi ve sirasi butun dillerde ayni', () {
        for (final lang in ['tr', 'en', 'de', 'es']) {
          expect(q.optionsFor(lang).length, q.options.length,
              reason: '$yer icin $lang sik sayisi farkli. '
                  'correctAnswer bir indeks oldugu icin bu, sorunun '
                  'sessizce yanlis cevaplanmasi demek.');
        }
        // Siklarin AYNI kalmasi her zaman hata degil: 'digitalWrite()',
        // 'Cascading Style Sheets', 'Google', '#', '=' gibi siklar kod
        // ya da ozel ad; cevrilmemeleri dogru. Ceviri sarti yalnizca
        // siklarda gercekten Turkce metin varsa aranyor.
        final turkceSik = q.options.any((o) =>
            'çÇğĞıİşŞöÖüÜ'.split('').any(o.contains));
        if (turkceSik) {
          for (final lang in ['en', 'de', 'es']) {
            expect(q.optionsFor(lang), isNot(q.options),
                reason: '$yer siklari Turkce ama $lang cevirisi yok.');
          }
        }
      });

      test('$yer — aciklama dort dilde', () {
        if (q.explanation == null) return;
        for (final lang in ['en', 'de', 'es']) {
          expect(q.explanationFor(lang), isNot(q.explanation),
              reason: '$yer aciklamasinin $lang cevirisi yok.');
        }
      });

      test('$yer — kod parcasi sikla ayni dilde', () {
        final kod = q.codeSnippet;
        if (kod == null) return;

        // DILDEN BAGIMSIZ KOD CEVRILMEZ.
        //
        // Kural sunun icin var: `print("Cocuk")` yazan bir kod parcasi
        // Ingilizce siklarla eslesmez, soru cevapsiz kalir. Ama
        // `print(10 + 2 * 5)` ya da `a = "5"` gibi parcalarda cevrilecek
        // hicbir sey yok; ceviri istemek, ayni metni dort kez yazmaya
        // zorlamak olurdu. O yuzden once "bu kodda gercekten dile bagli
        // bir kelime var mi" diye bakiyoruz.
        if (!_dileBagliKod(kod)) return;

        for (final lang in ['en', 'de', 'es']) {
          expect(q.codeSnippetFor(lang), isNot(kod),
              reason: '$yer kod parcasinin $lang cevirisi yok. '
                  'Kod Turkce kalirsa ("Cocuk" yazdiran bir kod) '
                  'cevrilmis siklarla eslesmez ve soru cevapsiz kalir.');
        }
      });

      test('$yer — cevrilmis metinde turkce harf yok', () {
        for (final lang in ['en', 'de', 'es']) {
          final harfler = _turkishOnly[lang]!.split('');
          final parcalar = <String>[
            q.questionFor(lang),
            ...q.optionsFor(lang),
            q.explanationFor(lang) ?? '',
            q.codeSnippetFor(lang) ?? '',
          ];
          for (final p in parcalar) {
            final kacak = harfler.where(p.contains).toList();
            expect(kacak, isEmpty,
                reason: '$yer / $lang metninde turkce harf: "$p"');
          }
        }
      });
    }
  }

  test('quizi olan her dersin basligi dort dilde', () {
    final dersler = <String, Lesson>{
      for (final courseId in const [
        'python',
        'html',
        'css',
        'javascript',
        'dart',
        'scratch',
        'arduino',
        'sql',
        'c',
        'go',
        'rust',
      ])
        for (final l in LessonsData.getLessonsForCourse(courseId)) l.id: l,
    };
    for (final key in quizzes.keys) {
      final ders = dersler[key];
      if (ders == null) continue; // oksuz quiz kaydi
      for (final lang in ['en', 'de', 'es']) {
        expect(ders.titleFor(lang), isNot(ders.title),
            reason: '$key dersinin $lang basligi yok; quiz ekraninin '
                'baslik cubugunda Turkce gorunuyor.');
      }
    }
  });
}
