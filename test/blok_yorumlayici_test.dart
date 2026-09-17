import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/yurutme/blok_anlami.dart';
import 'package:devkom_app/courses/yurutme/blok_sozlugu.dart';
import 'package:devkom_app/courses/yurutme/blok_yorumlayici.dart';

/// Blok yorumlayicisinin GERCEKTEN calistirdiginin kaniti.
///
/// Mevcut oynatici blogun ne yaptigini kimliginden tahmin ediyor
/// (`id.startsWith('move_')`). Boyle bir sey bir dongunun kac tur
/// dondugunu ya da bir degiskenin son degerini SOYLEYEMEZ. Buradaki
/// testler tam olarak onu sinar: tur sayisi ve degisken degeri.
ScratchBlock _b(String id, {ScratchBlockShape sekil = ScratchBlockShape.stack}) =>
    ScratchBlock(
      id: id,
      blockType: ScratchBlockType.motion,
      shape: sekil,
      label: id,
      color: const Color(0xFF4C97FF),
    );

void main() {
  const yorumlayici = BlokYorumlayici();

  test('dongu gercekten sayiyor', () {
    // yesil bayrak -> 4 defa tekrarla -> "Miyav!" de
    final sonuc = yorumlayici.yurut([
      _b('green_flag', sekil: ScratchBlockShape.cap),
      _b('repeat_4', sekil: ScratchBlockShape.cBlock),
      _b('say_meow'),
    ]);

    final miyavlar =
        sonuc.adimlar.where((a) => a.blokId == 'say_meow').toList();
    expect(miyavlar.length, 4, reason: 'Dort tur donmeliydi.');
    expect(miyavlar.map((a) => a.tekrarNo).toList(), [1, 2, 3, 4],
        reason: 'Cocuga "kacinci tur" diyebilmeliyiz.');
    expect(sonuc.sonSahne.soyledigi, 'Miyav!');
    expect(sonuc.butceBitti, isFalse);
  });

  test('degisken gercekten sayiyor', () {
    // Puan 0 yap, sonra uc kez 1 arttir.
    final sonuc = yorumlayici.yurut([
      _b('green_flag', sekil: ScratchBlockShape.cap),
      _b('set_score_0'),
      _b('change_score'),
      _b('change_score'),
      _b('change_score'),
    ]);
    expect(sonuc.sonSahne.degiskenler['Puan'], 3);
  });

  test('once arttirip sonra sifirlamak FARKLI sonuc veriyor', () {
    // Bu, "sira onemli" dersinin olculebilir hali: ayni bloklar, baska
    // sira, baska sonuc. Yorumlayici olmadan bunu soyleyemiyorduk.
    final dogru = yorumlayici.yurut([
      _b('set_score_0'),
      _b('change_score'),
    ]).sonSahne.degiskenler['Puan'];
    final yanlis = yorumlayici.yurut([
      _b('change_score'),
      _b('set_score_0'),
    ]).sonSahne.degiskenler['Puan'];
    expect(dogru, 1);
    expect(yanlis, 0);
  });

  test('hareket bloklari konumu degistiriyor', () {
    final sonuc = yorumlayici.yurut([
      _b('move_10'),
      _b('move_10'),
      _b('change_y_up'),
    ]);
    expect(sonuc.sonSahne.x, 20);
    expect(sonuc.sonSahne.y, 10);
  });

  test('surekli tekrarla uygulamayi dondurmuyor', () {
    // "Cokmesin" sartinin olculebilir hali: sonsuz dongu butceyle
    // duruyor ve bunu SOYLUYORUZ; ekran "bitti" diye yalan soylemiyor.
    const kucukButce = BlokYorumlayici(butce: 50);
    final sonuc = kucukButce.yurut([
      _b('forever', sekil: ScratchBlockShape.cBlock),
      _b('move_10'),
    ]);
    expect(sonuc.butceBitti, isTrue);
    expect(sonuc.adimlar.length, lessThanOrEqualTo(50));
  });

  test('bos surekli tekrarla sonsuza donmuyor', () {
    final sonuc = yorumlayici
        .yurut([_b('forever', sekil: ScratchBlockShape.cBlock)]);
    expect(sonuc.butceBitti, isFalse);
  });

  test('sozlukte olmayan blok atlanmiyor, etkisiz sayiliyor', () {
    final sonuc = yorumlayici.yurut([_b('bilinmeyen_blok')]);
    expect(sonuc.adimlar.length, 1,
        reason: 'Blogun sirasi geldigi yine de gorunmeli.');
    expect(sonuc.adimlar.single.etkisiz, isTrue);
  });

  test('C blogunun govdesi girintili', () {
    final sonuc = yorumlayici.yurut([
      _b('repeat_4', sekil: ScratchBlockShape.cBlock),
      _b('say_meow'),
    ]);
    expect(sonuc.adimlar.first.derinlik, 0);
    expect(sonuc.adimlar[1].derinlik, 1,
        reason: 'Kod alani da govdeyi bir kademe iceri ciziyor.');
  });

  test('OLCUM: hangi blok kimlikleri hala sozlukte yok', () {
    final eksik = <String>{};
    var toplam = 0;
    for (final kurs in CoursesData.allCourses) {
      for (final modul in CourseModules.forCourse(kurs.id)) {
        for (final ders in modul.lessons) {
          for (final adim in ders.steps) {
            if (adim is! BlockBuilderStep) continue;
            for (final blok in adim.availableBlocks) {
              toplam++;
              if (!blokSozlugu.containsKey(blok.id)) eksik.add(blok.id);
            }
          }
        }
      }
    }
    // ignore: avoid_print
    print('\nSozluk: ${blokSozlugu.length} kimlik. '
        'Ders verisinde $toplam blok kullanimi, '
        '${eksik.length} farkli kimlik hala eksik:\n  ${eksik.join(', ')}');
    // Dusmuyor: bu bir kural degil, OLCUM. Bosluk sessiz degil sayili
    // kalsin diye.
    expect(toplam, greaterThan(0));
  });
}
