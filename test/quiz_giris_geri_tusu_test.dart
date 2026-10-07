import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/screens/quiz/quiz_intro_screen.dart';

/// Quiz giris ekraninda geri tusu.
///
/// Ekran Etkinlikler'den ve ana sayfadan itiliyor ama ustunde geri tusu
/// yoktu (Ekim 2026). Itilmis rotada tus var ve basinca geri donuyor; ilk
/// ekran olarak acildiginda tus cizilmiyor.
void main() {
  testWidgets('itilmis rotada geri tusu var ve calisiyor', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const QuizIntroScreen())),
              child: const Text('ac'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('ac'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('ac'), findsOneWidget);
  });

  testWidgets('ilk ekranken geri tusu yok', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: QuizIntroScreen()));
    await tester.pump();
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });
}
