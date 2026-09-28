import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';

/// Siralama adimi cocuga COZULMUS gelmesin.
///
/// GERCEK OLAY: "Kediyi Yürüt!" dersinde ekranda uc satir vardi ve
/// kullanici "bu etkinligin mantigini anlamadim" dedi. Satirlarin
/// dogru sirada gorunuyor olmasi ihtimali, etkinligi anlamsiz kilar:
/// yapilacak tek sey "Kontrol Et"e basmak olur.
///
/// `karistir()` bunu engellemek icin yaziimisti ama guvencesi hic
/// sinanmamisti. Burasi sinar: uygulamadaki HER siralama adimi icin
/// gercek karistirma calistirilir ve sonucun cozumle ayni OLMADIGI
/// dogrulanir. Dart'in kendi Random'i kullanildigi icin testin gordugu
/// dizilim, cocugun ekranda gordugunun aynisidir.
void main() {
  final adimlar = <OrderingStep>[
    for (final kurs in CoursesData.allCourses)
      for (final modul in CourseModules.forCourse(kurs.id))
        for (final ders in modul.lessons)
          for (final adim in ders.steps)
            if (adim is OrderingStep) adim,
  ];

  test('uygulamada siralama adimi var', () {
    expect(adimlar, isNotEmpty);
  });

  test('hicbir siralama adimi cozulmus baslamiyor', () {
    for (final adim in adimlar) {
      final gosterilen = karistir(
        adim.items,
        adim.id,
        adim.correctOrder,
        (e) => e.id,
      ).map((e) => e.id).toList();

      expect(gosterilen, isNot(adim.correctOrder),
          reason: '${adim.id} adimi ekrana DOGRU sirada geliyor; cocugun '
              'yapacagi bir sey kalmiyor.');
    }
  });

  test('cozumdeki her kimlik listede var', () {
    // Cozumde olup listede olmayan bir kimlik, cozulemeyen bir adim
    // demek: cocuk dogru siraya dizse bile kontrol hep yanlis der.
    for (final adim in adimlar) {
      final kimlikler = adim.items.map((e) => e.id).toSet();
      for (final id in adim.correctOrder) {
        expect(kimlikler, contains(id),
            reason: '${adim.id}: cozum "$id" ogesini istiyor ama listede '
                'boyle bir oge yok.');
      }
      expect(adim.correctOrder.length, adim.items.length,
          reason: '${adim.id}: cozum ile oge sayisi tutmuyor.');
    }
  });

  test('siralama ogelerinin METINLERI dort dile cevrilmis', () {
    // Kod parcalari MUAF — ve bunu tahmin etmiyoruz: modelde zaten
    // `isCode` var ve icerik dosyalari onu dogru isaretlemis
    // (`<table>`, `h1`, `color: purple;`). Bir kod satirini cevirmek
    // dersi bozar.
    //
    // Once bu ayrimi metnin icindeki isaretlerden tahmin etmeye
    // calistim (`<>{};=()`), CSS'teki `h1` ogesinde dustu. Modelin
    // tasidigi niyeti okumak varken karakter saymak yanlisti.
    for (final adim in adimlar) {
      for (final oge in adim.items) {
        if (oge.isCode) continue;
        for (final dil in ['en', 'de', 'es']) {
          expect(oge.contentFor(dil), isNot(oge.content),
              reason: '${adim.id}/${oge.id} $dil diline cevrilmemis.');
        }
      }
    }
  });

  test('siralama yonergeleri dort dile cevrilmis', () {
    // Yonerge ve baglam her zaman metindir; kod istisnasi yok.
    for (final adim in adimlar) {
      for (final dil in ['en', 'de', 'es']) {
        expect(adim.instructionFor(dil), isNot(adim.instruction),
            reason: '${adim.id} yonergesi $dil diline cevrilmemis.');
        expect(adim.contextFor(dil), isNot(adim.context),
            reason: '${adim.id} baglami $dil diline cevrilmemis.');
      }
    }
  });
}
