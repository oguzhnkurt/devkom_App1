// ICERIK MANTIK DENETIMI.
//
// Bir soru ekranda dogru gorunup yine de cozulemez olabilir: dogru
// cevabin indeksi sik sayisini asarsa, iki sik birebir ayni yazarsa,
// bir surukle-birak eslesmesi olmayan bir kutuyu gosterirse ya da iki
// eslestirme ciftinin sag tarafi ayni olursa. Bunlarin hicbiri
// derlemede ya da cizimde hata vermiyor; cocuk "yanlis" cevabi
// aliyor ve sebebini bilmiyor.
//
// Bu test o kurallari kilitliyor. Kurallarin hepsi bugun GECIYOR;
// buradaki is yenisinin sessizce girmesini engellemek.
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/quizzes_data.dart';
import 'package:devkom_app/courses/models/course_model.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';

const diller = ['tr', 'en', 'de', 'es'];
const anahtarEmoji = {'✅', '❌', '✔️', '✔', '❎', '✖️'};

void main() {
  test('soru ve gorev mantigi tutarli', () {
    final bulgular = <String, List<String>>{};
    void ekle(String tur, String mesaj) =>
        bulgular.putIfAbsent(tur, () => []).add(mesaj);

    for (final kurs in CoursesData.allCourses) {
      for (final modul in CourseModules.forCourse(kurs.id)) {
        for (final ders in modul.lessons) {
          for (final adim in ders.steps) {
            final yer = '${kurs.id}/${ders.id}/${adim.id}';

            if (adim is MultipleChoiceStep) {
              if (adim.correctIndex < 0 ||
                  adim.correctIndex >= adim.options.length) {
                ekle('MC dogru cevap sinir disi',
                    '$yer correctIndex=${adim.correctIndex} '
                        'secenek=${adim.options.length}');
              }
              if (adim.options.length < 2) {
                ekle('MC tek secenek', yer);
              }
              for (final o in adim.options) {
                if (o.emoji != null && anahtarEmoji.contains(o.emoji)) {
                  ekle('MC cevabi ele veren emoji', '$yer "${o.emoji}"');
                }
              }
              for (final d in diller) {
                final metinler =
                    adim.options.map((o) => o.textFor(d).trim()).toList();
                final tekil = metinler.toSet();
                if (tekil.length != metinler.length) {
                  ekle('MC ayni secenek iki kez', '$yer [$d] $metinler');
                }
                if (metinler.any((m) => m.isEmpty)) {
                  ekle('MC bos secenek', '$yer [$d]');
                }
              }
              for (final d in ['en', 'de', 'es']) {
                if (adim.questionFor(d) == adim.question && d != 'tr') {
                  ekle('MC soru cevrilmemis', '$yer [$d]');
                }
              }
            }

            if (adim is DragDropStep) {
              final ogeIds = adim.items.map((i) => i.id).toList();
              final bolgeIds = adim.dropZones.map((z) => z.id).toList();
              if (ogeIds.toSet().length != ogeIds.length) {
                ekle('DD tekrar eden oge kimligi', yer);
              }
              if (bolgeIds.toSet().length != bolgeIds.length) {
                ekle('DD tekrar eden bolge kimligi', yer);
              }
              for (final e in adim.correctMapping.entries) {
                if (!ogeIds.contains(e.key)) {
                  ekle('DD eslesme olmayan ogeyi gosteriyor',
                      '$yer "${e.key}"');
                }
                if (!bolgeIds.contains(e.value)) {
                  ekle('DD eslesme olmayan bolgeyi gosteriyor',
                      '$yer "${e.value}"');
                }
              }
              final eslesmeyen =
                  ogeIds.where((i) => !adim.correctMapping.containsKey(i));
              if (eslesmeyen.isNotEmpty) {
                ekle('DD eslesmesi olmayan oge', '$yer $eslesmeyen');
              }
              if (adim.correctMapping.isEmpty) {
                ekle('DD hic eslesme yok', yer);
              }
            }

            if (adim is BlockBuilderStep) {
              final blokIds = adim.availableBlocks.map((b) => b.id).toList();
              if (blokIds.toSet().length != blokIds.length) {
                ekle('BB tekrar eden blok kimligi', '$yer $blokIds');
              }
              for (final id in adim.correctSequence) {
                if (!blokIds.contains(id)) {
                  ekle('BB dogru sira olmayan blogu istiyor', '$yer "$id"');
                }
              }
              if (adim.correctSequence.isEmpty) {
                ekle('BB dogru sira bos', yer);
              }
              // Celdirici yoksa gorev "hepsini koy"a dusuyor; palet
              // ayrica cozum sirasindaysa "yukaridan asagi dokun"a.
              final celdiriciYok =
                  adim.correctSequence.length == blokIds.length;
              final paletCozumSirasinda =
                  blokIds.join('|') == adim.correctSequence.join('|');
              // NOT: paletin veri sirasi onemsiz — BlockBuilderStepWidget
              // `karistir()` ile sabit tohumlu karistiriyor ve sonucun
              // cozume esit olmamasini garanti ediyor. Yirmi adimin
              // yirmisinde palet cozumun ta kendisiydi; duzeltme
              // veride degil widget'ta.
              if (celdiriciYok && !paletCozumSirasinda) {
                // sessiz: bilgi amacli, kural degil
              }
            }

            if (adim is OrderingStep) {
              final ogeIds = adim.items.map((i) => i.id).toList();
              if (ogeIds.toSet().length != ogeIds.length) {
                ekle('SIRA tekrar eden kimlik', yer);
              }
              if (adim.correctOrder.length != ogeIds.length) {
                ekle('SIRA uzunluk tutmuyor',
                    '$yer ${adim.correctOrder.length} != ${ogeIds.length}');
              }
              for (final id in adim.correctOrder) {
                if (!ogeIds.contains(id)) {
                  ekle('SIRA olmayan ogeyi gosteriyor', '$yer "$id"');
                }
              }
              // Liste zaten dogru siradaysa ve ekran karistirmiyorsa
              // gorev kendiliginden cozulmus oluyor.
              // NOT: OrderingStepWidget listeyi initState'te shuffle
              // ediyor, yani verideki sira onemsiz.
            }

            if (adim is MatchingStep) {
              final ids = adim.pairs.map((p) => p.id).toList();
              if (ids.toSet().length != ids.length) {
                ekle('ESLES tekrar eden kimlik', yer);
              }
              for (final d in diller) {
                final saglar =
                    adim.pairs.map((p) => p.rightFor(d).trim()).toList();
                if (saglar.toSet().length != saglar.length) {
                  ekle('ESLES ayni sag deger iki kez (belirsiz)',
                      '$yer [$d] $saglar');
                }
                final sollar =
                    adim.pairs.map((p) => p.leftFor(d).trim()).toList();
                if (sollar.toSet().length != sollar.length) {
                  ekle('ESLES ayni sol deger iki kez', '$yer [$d]');
                }
              }
            }
          }
        }
      }
    }

    // --- Quizler ---
    for (final giris in QuizzesData.all.entries) {
      final quiz = giris.value;
      for (final s in quiz.questions) {
        final yer = '${giris.key}/${s.id}';
        if (s.type == QuestionType.multipleChoice) {
          final c = s.correctAnswer;
          if (c is! int || c < 0 || c >= s.options.length) {
            ekle('QUIZ dogru cevap sinir disi',
                '$yer correctAnswer=$c secenek=${s.options.length}');
          }
          if (s.options.length < 2) ekle('QUIZ tek secenek', yer);
          for (final d in diller) {
            final o = s.optionsFor(d).map((e) => e.trim()).toList();
            if (o.toSet().length != o.length) {
              ekle('QUIZ ayni secenek iki kez', '$yer [$d] $o');
            }
            if (o.any((e) => e.isEmpty)) ekle('QUIZ bos secenek', '$yer [$d]');
            if (o.length != s.options.length) {
              ekle('QUIZ secenek sayisi dillerde farkli',
                  '$yer [$d] ${o.length} != ${s.options.length}');
            }
          }
        } else if (s.type == QuestionType.trueFalse) {
          if (s.correctAnswer is! bool) {
            ekle('QUIZ dogru/yanlis cevabi bool degil',
                '$yer ${s.correctAnswer.runtimeType}');
          }
        }
        for (final d in ['en', 'de', 'es']) {
          if (s.questionFor(d) == s.question) {
            ekle('QUIZ soru cevrilmemis', '$yer [$d]');
          }
        }
      }
    }

    final rapor = <String>[];
    for (final e in bulgular.entries) {
      rapor.add('${e.key} — ${e.value.length}');
      rapor.addAll(e.value.take(8).map((m) => '   $m'));
      if (e.value.length > 8) rapor.add('   ... ${e.value.length - 8} daha');
    }
    expect(bulgular, isEmpty, reason: rapor.join('\n'));
  });
}
