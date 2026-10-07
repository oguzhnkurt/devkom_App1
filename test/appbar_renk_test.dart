// Acik zeminli ekranlarda baslik ve geri oku gorunmuyordu (7 Ekim 2026).
//
// Sebep: tema `appBarTheme.titleTextStyle` ve `iconTheme` icinde beyaz renk
// tasiyordu; Flutter'da bu, ekranin kendi `foregroundColor`'ini eziyor.
// Etkinlikler ekrani `foregroundColor: koyu` diyordu ama baslik ve geri
// oku yine beyaz ciziliyordu.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devkom_app/theme.dart';

void main() {
  test('tema AppBar simge/baslik rengini sabitlemiyor', () {
    final t = AppTheme.lightTheme().appBarTheme;
    expect(t.iconTheme, isNull);
    expect(t.titleTextStyle, isNull);
    expect(t.foregroundColor, isNotNull);
  });

  testWidgets('acik zeminli AppBar: geri oku ve baslik koyu', (tester) async {
    const koyu = Color(0xFF1F1D36);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme(),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Etkinlikler'),
                  backgroundColor: Colors.transparent,
                  foregroundColor: koyu,
                ),
              ),
            ),
          ),
          child: const Text('ac'),
        ),
      ),
    ));
    await tester.tap(find.text('ac'));
    await tester.pumpAndSettle();

    final geri = find.byType(BackButtonIcon);
    expect(geri, findsOneWidget);
    expect(IconTheme.of(tester.element(geri)).color, koyu);

    final baslik = tester.widget<RichText>(find.descendant(
        of: find.text('Etkinlikler'), matching: find.byType(RichText)));
    expect(baslik.text.style?.color, koyu);
  });

  testWidgets('renkli zeminli AppBar varsayilani hala beyaz', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme(),
      home: Scaffold(appBar: AppBar(title: const Text('Oyun'))),
    ));
    final baslik = tester.widget<RichText>(find.descendant(
        of: find.text('Oyun'), matching: find.byType(RichText)));
    expect(baslik.text.style?.color, Colors.white);
  });
}
