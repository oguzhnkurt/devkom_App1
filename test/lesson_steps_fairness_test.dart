// Ders adimlarinin "oynanabilir ama ogretmeyen" hale donmesini engeller.
//
// Blok Yakala'da cikan kalip butun ders adimlarinda arandi ve ayni iki
// kusur baska yerlerde de vardi:
//
//   (a) Cevabi RENK ele veriyor — ayni bolgeye giden parcalar ayni
//       renkteydi, cocuk yaziyi hic okumadan ayirabiliyordu.
//   (b) Yanlis cevabin BEDELI yok — yanlis dizilim hicbir sey
//       uretmiyordu, cocuk yesil kutu cikana kadar bedavaya deniyordu.
//
// Ayrica bir adim HICBIR YOLDAN tamamlanamiyordu (CSS kutu modeli: dort
// parca, iki esleme).
//
// Bu dosya widget calistirmiyor, kaynagi ve icerik verisini okuyor:
// uc kusur da sessiz: ne derlemede ne calisirken hata veriyorlar.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';

/// Katalogdaki butun derslerin butun adimlari.
List<LessonStep> _tumAdimlar() {
  final adimlar = <LessonStep>[];
  for (final kurs in CoursesData.allCourses) {
    for (final modul in CourseModules.forCourse(kurs.id)) {
      for (final ders in modul.lessons) {
        adimlar.addAll(ders.steps);
      }
    }
  }
  return adimlar;
}

void main() {
  test('her surukle-birak adimi cozulebilir', () {
    // `_checkCompletion` TUM yerlestirmeleri denetliyor: eslemede
    // karsiligi olmayan bir parca her zaman yanlis sayilir ve adim
    // tamamlanamaz. CSS kutu modeli adimi tam olarak bu yuzden
    // hicbir cocuk tarafindan bitirilemiyordu.
    final bozuk = <String>[];
    for (final adim in _tumAdimlar().whereType<DragDropStep>()) {
      final bolgeler = adim.dropZones.map((z) => z.id).toSet();
      for (final parca in adim.items) {
        final hedef = adim.correctMapping[parca.id];
        if (hedef == null) {
          bozuk.add('${adim.id}: "${parca.id}" parcasinin eslemesi yok');
        } else if (!bolgeler.contains(hedef)) {
          bozuk.add('${adim.id}: "${parca.id}" -> "$hedef" diye bir bolge yok');
        }
      }
    }
    expect(bozuk, isEmpty,
        reason: 'Bu adimlar hicbir yoldan tamamlanamaz:\n${bozuk.join('\n')}');
  });

  test('surukle-birak parcalarinin rengi cevabi ele vermiyor', () {
    // Ayni bolgeye giden parcalar ayni renkteyse oyun "yaziyi oku"
    // olmaktan cikip "ayni rengi bul" oyununa doner.
    final sizinti = <String>[];
    for (final adim in _tumAdimlar().whereType<DragDropStep>()) {
      final renkliler = adim.items.where((i) => i.color != null);
      if (renkliler.isEmpty) continue;

      // Renk -> gittigi bolgeler
      final renkBolge = <int, Set<String>>{};
      for (final parca in renkliler) {
        final hedef = adim.correctMapping[parca.id];
        if (hedef == null) continue;
        renkBolge.putIfAbsent(parca.color!.toARGB32(), () => <String>{}).add(hedef);
      }
      // Her rengin TEK bir bolgeye gitmesi = renk cevabi soyluyor.
      final bolgeSayisi = adim.dropZones.length;
      if (bolgeSayisi > 1 &&
          renkBolge.length > 1 &&
          renkBolge.values.every((b) => b.length == 1)) {
        sizinti.add(adim.id);
      }
    }
    expect(sizinti, isEmpty,
        reason: 'Bu adimlarda renk dogrudan cevabi veriyor: '
            '${sizinti.join(', ')}');
  });

  test('yanlis cevapta da geri bildirim var', () {
    final src = File('lib/courses/screens/widgets/step_widgets.dart')
        .readAsStringSync();
    for (final bayrak in ['_yanlisYerlesim', '_yanlisDizi']) {
      expect(src.contains(bayrak), isTrue,
          reason: '$bayrak yok: yanlis cevap yine sessiz kaldi, '
              'cocuk bedavaya deneme yanilma yapabilir.');
    }
    expect(src.contains('SoundService.playWrong'), isTrue,
        reason: 'Yanlis cevapta ses yok.');
    // Ders sorularinin dogru sesi oyunlarinkinden AYRI: oyunlar
    // sentezlenmis ton ailesini calarken sorular gercek kayiti caliyor
    // (bkz. SoundService.playSoruDogru).
    expect(src.contains('SoundService.playSoruDogru'), isTrue,
        reason: 'Dogru cevapta ses yok.');
  });

  test('siklar ve siralar cizim sirasinda yeniden uretilmiyor', () {
    // `build()` icinde `shuffle()` ya da sik uretimi, cocuk parmagini
    // uzatirken seceneklerin yer degistirmesi demek.
    final src = File('lib/courses/screens/widgets/step_widgets.dart')
        .readAsStringSync();
    expect(src.contains('List<MatchPair>.from(_shuffledPairs)..shuffle()'),
        isFalse,
        reason: 'Eslestirmenin sag sutunu her cizimde yeniden karisiyor.');
    expect(src.contains('final answers = _generateAnswers();'), isFalse,
        reason: 'Dongu hesabinin siklari her cizimde yeniden uretiliyor.');
  });

  test('koordinat oyunu cevabi karenin uzerine yazmiyor', () {
    final src = File('lib/courses/screens/widgets/coordinate_tap_game.dart')
        .readAsStringSync();
    // Her karenin icinde kendi koordinati yaziyordu; ustteki hedefle
    // ayni yazim. Cocuk eksenlere hic bakmadan yaziyi eslestiriyordu.
    expect(src.contains(r"'($x,$y)'"), isFalse,
        reason: 'Kareler yine kendi koordinatini yaziyor — oyun yazi '
            'eslestirmeye donuyor.');
    expect(src.contains('_eksenSayilari'), isTrue,
        reason: 'Eksen sayilari yok: cocuk nereye dokunacagini okuyamaz.');
  });

  test('ders adimi arayuzunde iki dilli metin kalmadi', () {
    for (final yol in [
      'lib/courses/screens/widgets/step_widgets.dart',
      'lib/courses/screens/widgets/coordinate_tap_game.dart',
      'lib/courses/screens/widgets/catch_block_game.dart',
    ]) {
      final kod = File(yol)
          .readAsLinesSync()
          .map((l) => l.trimLeft().startsWith('//') ? '' : l)
          .join('\n');
      expect(RegExp(r"isEn\s*\?").hasMatch(kod), isFalse,
          reason: '$yol: isEn ikilisi kalmis, Almanca/Ispanyolca duser.');
      expect(RegExp(r"lang == 'en'\s*\?").hasMatch(kod), isFalse,
          reason: '$yol: lang == \'en\' ikilisi kalmis.');
    }
  });
}
