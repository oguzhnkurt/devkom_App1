// SURUKLE-BIRAK, SIRALAMA VE BOSLUK DOLDURMA ADIMLARI BLOK SESINI CALIYOR.
//
// Blok kurma alanlari parca oturunca kisa "tok" sesini (blok_tak)
// caliyordu; surukle-birak, siralama ve bosluk doldurma adimlari ise
// yalnizca eski titresimi veriyordu. Artik hepsi ayni sesi caliyor
// (titresim playBlokTak'in icinde).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';

final _kurs = CoursesData.allCourses.firstWhere((c) => c.id == 'python');

Future<List<String>> _hazirla(WidgetTester tester, Widget adim) async {
  final calinan = <String>[];
  SoundService.setEnabled(false);
  SoundService.debugOnPlay = calinan.add;
  addTearDown(() {
    SoundService.debugOnPlay = null;
    SoundService.setEnabled(true);
  });
  SharedPreferences.setMockInitialValues({'language_code': 'en'});
  final settings = SettingsProvider();
  await settings.setLocale(const Locale('en'));
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: settings,
    child: MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: adim)),
    ),
  ));
  await tester.pump();
  return calinan;
}

void main() {
  testWidgets('surukle-birak: parca kutuya oturunca blok_tak', (tester) async {
    const step = DragDropStep(
      id: 'dd_test',
      instruction: 'Yerleştir',
      instructionEn: 'Place it',
      items: [
        DraggableItem(id: 'a', content: 'Alpha'),
        DraggableItem(id: 'b', content: 'Beta'),
      ],
      dropZones: [
        DropZone(id: 'z1', label: 'One'),
        DropZone(id: 'z2', label: 'Two'),
      ],
      correctMapping: {'a': 'z1', 'b': 'z2'},
    );
    final calinan = await _hazirla(
      tester,
      DragDropStepWidget(
          step: step, course: _kurs, isDark: false, onComplete: (_) {}),
    );

    final parca = find.text('Alpha');
    final kutu = find.text('One');
    await tester.drag(parca, tester.getCenter(kutu) - tester.getCenter(parca));
    await tester.pump(const Duration(milliseconds: 300));

    expect(calinan, ['blok_tak']);
  });

  testWidgets('siralama: satir yeni yerine oturunca blok_tak',
      (tester) async {
    const step = OrderingStep(
      id: 'ord_test',
      instruction: 'Sırala',
      instructionEn: 'Order',
      context: 'Adımlar',
      contextEn: 'Steps',
      items: [
        OrderItem(id: '1', content: 'First'),
        OrderItem(id: '2', content: 'Second'),
        OrderItem(id: '3', content: 'Third'),
      ],
      correctOrder: ['1', '2', '3'],
    );
    final calinan = await _hazirla(
      tester,
      OrderingStepWidget(
          step: step, course: _kurs, isDark: false, onComplete: (_) {}),
    );

    // Hangi sirayla karistirildigindan bagimsiz: ilk satiri en alta tasi.
    final satirlar = find.byType(ReorderableDragStartListener);
    final ilk = satirlar.first;
    final son = satirlar.last;
    final g = await tester.startGesture(tester.getCenter(ilk));
    await tester.pump();
    await g.moveBy(const Offset(0, 20));
    await tester.pump();
    await g.moveTo(tester.getBottomLeft(son) + const Offset(20, 30));
    await tester.pump(const Duration(milliseconds: 300));
    await g.up();
    await tester.pumpAndSettle();

    expect(calinan, ['blok_tak']);
  });

  testWidgets('bosluk doldurma: secenek bosluga oturunca blok_tak',
      (tester) async {
    const step = CodeCompleteStep(
      id: 'cc_test',
      instruction: 'Doldur',
      instructionEn: 'Fill in',
      codeTemplate: 'print(___)',
      language: 'python',
      blanks: [
        CodeBlank(
          index: 0,
          correctAnswer: 'answer_x',
          acceptableAlternatives: ['other_y'],
          hint: 'ipucu',
          hintEn: 'hint',
        ),
      ],
    );
    final calinan = await _hazirla(
      tester,
      CodeCompleteStepWidget(
          step: step, course: _kurs, isDark: false, onComplete: (_) {}),
    );

    await tester.tap(find.text('answer_x').last);
    await tester.pump();

    expect(calinan, ['blok_tak']);
  });
}
