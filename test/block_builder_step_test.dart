// Blok kurma adimi (BlockBuilderStep) icin kaynak okuyan koruma testleri.
//
// Sikayet: "kodu yazdigim halde devam butonu gelmiyor." Iki ayri sebep
// vardi ve ikisi de gorsel: geri bildirim ekranin disinda kaliyordu, ve
// dongunun ICI ile ALTI arasinda hicbir gorsel fark yoktu.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/course_modules.dart';

void main() {
  const yol = 'lib/courses/screens/widgets/step_widgets.dart';
  late String govde;

  setUpAll(() {
    final s = File(yol).readAsStringSync();
    final bas = s.indexOf('class _BlockBuilderStepWidgetState');
    expect(bas, greaterThan(0));
    final son = s.indexOf('// ORDERING STEP WIDGET', bas);
    govde = s.substring(bas, son > 0 ? son : s.length);
  });

  test('geri bildirim blok paletinin ustunde', () {
    // Uyari, basari kutusu ve DEVAM tusu sayfanin en altindaydi;
    // telefonda ekranin disinda kaliyordu.
    final uyari = govde.indexOf('if (_yanlisDizi)');
    final basari = govde.indexOf('if (_completed) ...[');
    final palet = govde.indexOf("'Kullanılabilir Bloklar:'");
    expect(uyari, greaterThan(0));
    expect(basari, greaterThan(0));
    expect(palet, greaterThan(0));
    expect(uyari, lessThan(palet),
        reason: 'Yanlis sira uyarisi yine paletin altinda kalmis.');
    expect(basari, lessThan(palet),
        reason: 'DEVAM tusu yine paletin altinda kalmis.');
  });

  test('C-blogunun ici girintili ciziliyor', () {
    expect(govde.contains('_buildPlacedList'), isTrue);
    expect(govde.contains('ScratchBlockShape.cBlock'), isTrue,
        reason: 'Dongu blogu duz listede digerlerinden ayirt edilemiyor.');
    expect(govde.contains('girinti'), isTrue);
  });

  test('bos dongu icin uyari var', () {
    // "4 kere tekrarla" en sona konup ici bos birakildiginda cocuk
    // eksigi goremiyordu.
    expect(govde.contains('Bu döngünün içi boş'), isTrue);
    expect(govde.contains('This loop is empty'), isTrue);
    expect(govde.contains('Diese Schleife ist leer'), isTrue);
    expect(govde.contains('Este bucle está vacío'), isTrue);
  });

  test('yanlis sira cevabi ele vermiyor', () {
    // Uyari yalnizca "sira yanlis" diyor; dogru sirayi yazmiyor.
    expect(govde.contains('correctSequence[i]'), isTrue);
    final i = govde.indexOf('Blok sayisi dogru ama sira yanlis');
    expect(i, greaterThan(0));
    final blok = govde.substring(i, i + 400);
    expect(blok.contains('correctSequence'), isFalse);
  });

  test('bloklar birbirine degiyor', () {
    // Aralarinda 4 piksel bosluk vardi: yapboz tirnagi bir sonraki
    // blogun centigine oturmuyor, bloklar ayri kartlar gibi duruyordu.
    expect(govde.contains("margin: const EdgeInsets.only(bottom: 4)"), isFalse);
  });

  test('C blogu kod alaninda yalnizca ust cubuk olarak ciziliyor', () {
    // Tam C silueti 64 piksellik bos bir agiz tasiyordu; icindeki blok
    // agzin DISINDA duruyormus gibi gorunuyordu.
    expect(govde.contains('cHeadOnly: block.shape == ScratchBlockShape.cBlock'),
        isTrue);
  });

  test('C blogunun agzi soldan aciliyor', () {
    // Onceki cizimde isirik SAG KENARDAN aliniyordu; blok, icine blok
    // alan bir C gibi degil sagi centikli bir dikdortgen gibi duruyordu.
    final painter =
        File('lib/widgets/scratch_block_widget.dart').readAsStringSync();
    expect(painter.contains('path.lineTo(size.width - indent'), isFalse);
    expect(painter.contains('_drawInnerNotch'), isTrue);
  });

  test('palet karistirma cozume esit olmuyor ve sabit kaliyor', () {
    var adimSayisi = 0;
    for (final kurs in CoursesData.allCourses) {
      for (final modul in CourseModules.forCourse(kurs.id)) {
        for (final ders in modul.lessons) {
          for (final adim in ders.steps) {
            if (adim is! BlockBuilderStep) continue;
            adimSayisi++;
            final bir = karistir(adim.availableBlocks, adim.id,
                adim.correctSequence, (b) => b.id);
            final iki = karistir(adim.availableBlocks, adim.id,
                adim.correctSequence, (b) => b.id);

            // Sabit: cocuk adimdan cikip donunce ayni dizilimi bulmali.
            expect(bir.map((b) => b.id).toList(),
                iki.map((b) => b.id).toList(),
                reason: '${adim.id} her acilista farkli diziliyor');

            // Ve cozumun ta kendisi olmamali.
            if (adim.availableBlocks.length > 1) {
              expect(bir.map((b) => b.id).join('|'),
                  isNot(adim.correctSequence.join('|')),
                  reason: '${adim.id} paleti cozum sirasinda');
            }

            // Karistirma blok KAYBETMEMELI.
            expect(bir.length, adim.availableBlocks.length);
            expect(bir.map((b) => b.id).toSet(),
                adim.availableBlocks.map((b) => b.id).toSet());
          }
        }
      }
    }
    expect(adimSayisi, greaterThan(10));
  });

}

