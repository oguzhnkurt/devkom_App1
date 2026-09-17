// Kartların arkasındaki kod akıntısı.
//
// Düz renkli kart ucuz duruyordu; arkada çok soluk kod simgeleri
// süzülünce kart bir yüzey gibi duruyor. Buradaki testler o etkinin
// OKUNURLUĞU bozmamasını ve hareket azaltma ayarına uymasını koruyor.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/ui/kod_akintisi.dart';

Widget _kart({bool hareketAzalt = false}) => MediaQuery(
      data: MediaQueryData(disableAnimations: hareketAzalt),
      child: const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              height: 200,
              child: KodAkintisi(child: Text('Bugün ilk kodunu yazıyorsun.')),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('akıntı kartın içeriğini gizlemiyor', (tester) async {
    await tester.pumpWidget(_kart());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Bugün ilk kodunu yazıyorsun.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hareket azaltılmışken akıntı durur', (tester) async {
    await tester.pumpWidget(_kart(hareketAzalt: true));
    await tester.pump(const Duration(milliseconds: 500));
    // Durmuş bir denetleyici: sonraki kare çizim istemiyor.
    expect(tester.binding.hasScheduledFrame, isFalse,
        reason: 'Hareket azaltılmışken akıntı hâlâ dönüyor — vestibüler '
            'rahatsızlığı olan çocuk için bu bir erişilebilirlik kusuru.');
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('kendi katmanında çiziliyor', (tester) async {
    // RepaintBoundary olmasaydı kartın içindeki her şey — başlık,
    // düğme — saniyede 60 kez yeniden çizilirdi.
    await tester.pumpWidget(_kart());
    await tester.pump();
    expect(
      find.descendant(
          of: find.byType(KodAkintisi), matching: find.byType(RepaintBoundary)),
      findsWidgets,
    );
  });

  test('opaklık okunurluğu bozacak kadar yüksek değil', () {
    final s = File('lib/ui/kod_akintisi.dart').readAsStringSync();
    final m = RegExp(r'this\.opaklik = ([0-9.]+)').firstMatch(s);
    expect(m, isNotNull);
    expect(double.parse(m!.group(1)!), lessThanOrEqualTo(0.12),
        reason: 'Desen metnin kontrastını bozacak kadar koyu.');

    // Tam tur en az yarım dakika: hızlı bir arka plan gözü takip
    // etmeye zorluyor ve okumayı zorlaştırıyor.
    final sure = RegExp(r'Duration\(seconds: (\d+)\)').firstMatch(s);
    expect(int.parse(sure!.group(1)!), greaterThanOrEqualTo(30));
  });

  test('ana sayfadaki iki kart da akıntıyı kullanıyor', () {
    final s = File('lib/screens/unified_home_screen.dart').readAsStringSync();
    expect('KodAkintisi('.allMatches(s).length, greaterThanOrEqualTo(2),
        reason: 'Hem ilk gün kartı hem devam kartı derinlik almalı.');
  });
}
