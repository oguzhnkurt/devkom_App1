// CIKIS PENCERESI — ders ve quizden cikarken cikan uyari.
//
// Eskiden iki ayri `AlertDialog` vardi: kare kose, gri baslik, altta
// kucuk bir "Devam Et" yazisi ve KIRMIZI bir "Çık" dugmesi. Uygulamanin
// geri kalaninin yaninda baska bir uygulamadan yapistirilmis gibi
// duruyordu. Ustelik ders penceresi yalnizca iki dildeydi.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/widgets/cikis_penceresi.dart';

/// Pencereyi acar; donen deger sonradan `.deger` icine dusuyor.
class _Kutu {
  bool? deger;
}

Future<_Kutu> _ac(WidgetTester tester, String dil,
    {bool quiz = false}) async {
  final kutu = _Kutu();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              kutu.deger = quiz
                  ? await CikisPenceresi.quizden(context, dil)
                  : await CikisPenceresi.dersten(context, dil);
            },
            child: const Text('aç'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('aç'));
  await tester.pumpAndSettle();
  return kutu;
}

void main() {
  testWidgets('kalmak birincil eylem, cikis ikincil', (tester) async {
    await _ac(tester, 'tr');

    expect(find.text('Dersten çıkmak üzeresin'), findsOneWidget);
    expect(find.text('Derse devam et'), findsOneWidget);
    expect(find.text('Yine de çık'), findsOneWidget);

    // Cikis bir ElevatedButton DEGIL: buyuk renkli dugme kalmak icin.
    final cikisTusu = tester.widget<TextButton>(
      find.ancestor(
          of: find.text('Yine de çık'), matching: find.byType(TextButton)),
    );
    expect(cikisTusu.style?.foregroundColor, isNotNull);
  });

  testWidgets('devam et false, cikis true donuyor', (tester) async {
    final kal = await _ac(tester, 'tr');
    await tester.tap(find.text('Derse devam et'));
    await tester.pumpAndSettle();
    expect(find.text('Dersten çıkmak üzeresin'), findsNothing);
    expect(kal.deger, isFalse, reason: 'Devam et ekrandan atiyor.');

    final cik = await _ac(tester, 'tr');
    await tester.tap(find.text('Yine de çık'));
    await tester.pumpAndSettle();
    expect(cik.deger, isTrue, reason: 'Cikis dugmesi cikartmiyor.');
  });

  testWidgets('perdeye dokunmak cikarmiyor', (tester) async {
    // Yanlislikla disari dokunan cocuk dersini kaybetmesin.
    final kutu = await _ac(tester, 'tr');
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(kutu.deger, isFalse);
  });

  testWidgets('dort dilde de kendi dilinde aciliyor', (tester) async {
    const beklenen = {
      'tr': 'Dersten çıkmak üzeresin',
      'en': 'You are about to leave the lesson',
      'de': 'Du verlässt gleich die Lektion',
      'es': 'Estás a punto de salir de la lección',
    };
    for (final giris in beklenen.entries) {
      await _ac(tester, giris.key);
      expect(find.text(giris.value), findsOneWidget,
          reason: '${giris.key} dilinde baslik yok');
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('quiz penceresi de dort dilde', (tester) async {
    for (final dil in const ['tr', 'en', 'de', 'es']) {
      await _ac(tester, dil, quiz: true);
      expect(find.byType(CikisPenceresi), findsOneWidget);
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettle();
    }
  });

  test('iki ekran da ortak pencereyi kullaniyor', () {
    for (final yol in const [
      'lib/courses/screens/interactive_lesson_screen.dart',
      'lib/courses/screens/quiz_screen.dart',
    ]) {
      final s = File(yol).readAsStringSync();
      expect(s.contains('CikisPenceresi.'), isTrue, reason: yol);
      // Eski kutudan cikma pencere geri gelmemis olmali.
      expect(s.contains('backgroundColor: Colors.red'), isFalse, reason: yol);
      expect(s.contains('Colors.red.shade400'), isFalse, reason: yol);
    }
  });
}
