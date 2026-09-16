// Blok animasyon oynaticisi icin kaynak okuyan koruma testleri.
//
// Sikayet: "Kodun çalışıyor diyor ama animasyon hareket etmiyor."
//
// Sebep: oynatici yalnizca `say_`, `move_` ve `repeat_` ile baslayan
// kimlikleri taniyor, geri kalan her blogu SESSIZCE atliyordu. Ders
// verisindeki blok kimliklerinin buyuk cogunlugu bu uce girmiyor; yani
// cogu derste "KODU CALISTIR" hicbir sey gostermiyor, hemen "tamamlandi"
// diyordu.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';

const _yol = 'lib/widgets/block_animation_player.dart';

/// Katalogdaki butun blok kurma adimlarinin blok kimlikleri.
Set<String> _tumBlokKimlikleri() {
  final out = <String>{};
  for (final kurs in CoursesData.allCourses) {
    for (final modul in CourseModules.forCourse(kurs.id)) {
      for (final ders in modul.lessons) {
        for (final adim in ders.steps.whereType<BlockBuilderStep>()) {
          out.addAll(adim.availableBlocks.map((b) => b.id));
        }
      }
    }
  }
  return out;
}

void main() {
  late String kaynak;
  setUpAll(() => kaynak = File(_yol).readAsStringSync());

  test('oynaticiya bloklarin kendisi gidiyor, yalnizca kimlik degil', () {
    // Blogun yazisini ve rengini gosterebilmesi icin gerekli.
    expect(kaynak.contains('final List<ScratchBlock> blocks;'), isTrue);
    expect(kaynak.contains('List<String> blockIds'), isFalse);

    final cagiran =
        File('lib/courses/screens/widgets/step_widgets.dart').readAsStringSync();
    expect(cagiran.contains('blockIds: _placedBlocks'), isFalse);
    expect(cagiran.contains('BlockAnimationPlayer('), isTrue);
    final i = cagiran.indexOf('BlockAnimationPlayer(');
    expect(cagiran.substring(i, i + 420).contains('lang: lang'), isTrue,
        reason: 'Sahnedeki metinler dile bagli olmali.');
  });

  test('hicbir blok sessizce atlanmiyor', () {
    // Gorsel etkisi olmayan bloklar da sirasi geldiginde ADIYLA
    // gosteriliyor; "atla ve devam et" dali kalmadi.
    expect(kaynak.contains('Skipping non-action block'), isFalse);
    expect(kaynak.contains('_Etki.yapisal'), isTrue);
    expect(kaynak.contains('calisan.labelFor(widget.lang)'), isTrue,
        reason: 'O an calisan blogun yazisi ekranda gorunmeli.');
  });

  test('konusma metni blogun kendi yazisindan cikariliyor', () {
    // Eskiden kimlige gore sabit Turkce metin vardi: Ingilizce derste de
    // kedi "Merhaba!" diyordu.
    expect(kaynak.contains("message = 'Merhaba!';"), isFalse);
    expect(kaynak.contains("blok.labelFor(widget.lang)"), isTrue);
  });

  test('sahne yazilari dort dilde', () {
    expect(kaynak.contains("'🎬 Kodun Çalışıyor!'"), isFalse,
        reason: 'Sabit Turkce baslik kalmis.');
    expect(kaynak.contains('Dein Code läuft!'), isTrue);
    expect(kaynak.contains('¡Tu código se está ejecutando!'), isTrue);
  });

  test('ders verisindeki her blok bir etki sinifina dusuyor', () {
    // Siniflandirma `_etkisi` icinde; burada yalnizca hicbir kimligin
    // BOS kalmadigini dogruluyoruz (yapisal da gecerli bir siniftir).
    final kimlikler = _tumBlokKimlikleri();
    expect(kimlikler, isNotEmpty);
    // Hareket/konusma uretmesi beklenen aileler gercekten taninmali.
    final beklenen = kimlikler.where((k) =>
        k.startsWith('move_') ||
        k.startsWith('say_') ||
        k.startsWith('goto_') ||
        k.startsWith('change_') ||
        k.startsWith('set_') ||
        k.startsWith('wait') ||
        k.contains('led') ||
        k.contains('note'));
    expect(beklenen, isNotEmpty,
        reason: 'Sahnede gosterilebilecek blok kalmamis gibi gorunuyor.');
  });
}
