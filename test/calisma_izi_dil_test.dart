import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/scratch_lessons_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/calisma_izi.dart';
import 'package:devkom_app/courses/yurutme/konusma_metni.dart';

/// "Kodun ne yapti" izindeki konusma metni cocugun dilinde olmali.
///
/// Ispanyolca derste bloklar "di ¡Hola!" derken iz `"Merhaba"` yaziyordu:
/// metin blok sozlugunden (Turkce) okunuyordu. Magaza slaytinda fark
/// edildi (Ekim 2026).
void main() {
  final adim = ScratchLessonsData.module1
      .expand((l) => l.steps)
      .whereType<BlockBuilderStep>()
      .firstWhere((s) => s.id == 's1_2_build2');
  final bloklar = [
    for (final id in adim.correctSequence)
      adim.availableBlocks.firstWhere((b) => b.id == id),
  ];

  for (final (dil, beklenen) in [
    ('tr', 'Merhaba'),
    ('en', 'Hello!'),
    ('de', 'Hallo!'),
    ('es', '¡Hola!'),
  ]) {
    testWidgets('iz $dil dilinde konusuyor', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CalismaIzi(bloklar: bloklar, lang: dil)),
      ));
      expect(find.textContaining('"$beklenen"'), findsOneWidget);
      if (dil != 'tr') {
        expect(find.textContaining('Merhaba'), findsNothing);
      }
    });
  }

  test('konusmaMetni etiketten "de"/"say" ekini temizliyor', () {
    final say = adim.availableBlocks.firstWhere((b) => b.id == 'say_hello');
    expect(konusmaMetni(say, 'tr'), 'Merhaba');
    expect(konusmaMetni(say, 'en'), 'Hello!');
  });
}
