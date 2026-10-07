import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/bilmece/devi_bilmeceleri_api.dart';
import 'package:devkom_app/widgets/devi_bilmece_karti.dart';

/// Devi'nin bilmeceleri: 30 gunluk dongu, gunde 3 soru, dort dil.
void main() {
  group('icerik', () {
    test('90 bilmece, dort dilde eksiksiz', () {
      expect(DeviBilmeceleri.hepsi.length, 90);
      for (final b in DeviBilmeceleri.hepsi) {
        for (final dil in ['tr', 'en', 'de', 'es']) {
          expect(b.soru(dil).trim(), isNotEmpty);
          expect(b.siklar(dil).toSet().length, 3, reason: b.soru(dil));
          expect(b.aciklama(dil).trim(), isNotEmpty);
        }
        expect(b.dogru, inInclusiveRange(0, 2));
      }
    });

    test('30 gun boyunca hicbir bilmece tekrar etmiyor', () {
      final gorulen = <Bilmece>{};
      for (var g = 0; g < 30; g++) {
        final gun = DateTime(2026, 1, 1).add(Duration(days: g));
        final uc = DeviBilmeceleri.gunun(gun);
        expect(uc.length, 3);
        gorulen.addAll(uc);
      }
      expect(gorulen.length, 90);
    });

    test('her gun ilk soru Scratch, ikincisi mBlock ya da Tinkercad', () {
      for (var g = 0; g < 30; g++) {
        final uc = DeviBilmeceleri.gunun(DateTime(2026, 3, 1).add(Duration(days: g)));
        expect(uc[0].kategori, 'scratch');
        expect(['mblock', 'tinkercad'], contains(uc[1].kategori));
        expect(['arduino', 'donanim', 'tinkercad'], contains(uc[2].kategori));
      }
    });

    test('Scratch ve mBlock agirlikli', () {
      final say = <String, int>{};
      for (final b in DeviBilmeceleri.hepsi) {
        say[b.kategori] = (say[b.kategori] ?? 0) + 1;
      }
      expect(say['scratch']! + say['mblock']!, greaterThan(45));
      expect(say.keys.toSet(), {'scratch', 'mblock', 'arduino', 'tinkercad', 'donanim'});
    });

    test('ayni gun ayni sorular, dongu 30 gunde basa doner', () {
      final a = DeviBilmeceleri.gunun(DateTime(2026, 10, 7, 9));
      final b = DeviBilmeceleri.gunun(DateTime(2026, 10, 7, 23));
      final c = DeviBilmeceleri.gunun(DateTime(2026, 11, 6));
      expect(a, b);
      expect(a, c);
      expect(DeviBilmeceleri.gununBilgisi(DateTime(2026, 10, 7), 'de'), isNotEmpty);
    });
  });

  testWidgets('cevap, aciklama, sonraki soru ve kayit', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final gun = DateTime(2026, 10, 7);
    final uc = DeviBilmeceleri.gunun(gun);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: DeviBilmeceKarti(lang: 'tr', simdi: gun),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text(uc[0].soru('tr')), findsOneWidget);

    // Dogru sikki sec.
    await tester.tap(find.text(uc[0].siklar('tr')[uc[0].dogru]));
    await tester.pumpAndSettle();
    expect(find.textContaining('Doğru!'), findsOneWidget);

    await tester.tap(find.text('Sonraki'));
    await tester.pumpAndSettle();
    expect(find.text(uc[1].soru('tr')), findsOneWidget);

    final p = await SharedPreferences.getInstance();
    expect(p.getString('devi_bilmece_2026-10-07'), startsWith('${uc[0].dogru},-1'));
  });

  testWidgets('uc soru cevaplanmissa ozet gorunur', (tester) async {
    final gun = DateTime(2026, 10, 7);
    final uc = DeviBilmeceleri.gunun(gun);
    SharedPreferences.setMockInitialValues({
      'devi_bilmece_2026-10-07': '${uc[0].dogru},${uc[1].dogru},${(uc[2].dogru + 1) % 3}',
    });
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DeviBilmeceKarti(lang: 'tr', simdi: gun)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Bugün 2/3 doğru'), findsOneWidget);
  });
}
