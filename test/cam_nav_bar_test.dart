import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/widgets/cam_nav_bar.dart';

/// Yorum satirlarini atar.
///
/// Yoklugu sinayan kurallar, aciklama yazisinin kendisiyle eslesip
/// bosuna patliyordu ("gradyan kullanmiyoruz" diyen yorum, "gradyan"
/// aramasina takiliyordu).
String _kodu(String yol) => File(yol)
    .readAsLinesSync()
    .where((s) => !s.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  const maddeler = [
    CamNavMaddesi(
      icon: Icons.home_outlined,
      seciliIcon: Icons.home_rounded,
      etiket: 'Ana Sayfa',
      renk: Color(0xFF1565C0),
    ),
    CamNavMaddesi(
      icon: Icons.school_outlined,
      seciliIcon: Icons.school_rounded,
      etiket: 'Kurslar',
      renk: Color(0xFF2E9E5B),
    ),
    CamNavMaddesi(
      icon: Icons.person_outline_rounded,
      seciliIcon: Icons.person_rounded,
      etiket: 'Profil',
      renk: Color(0xFF8E44AD),
    ),
  ];

  Widget kabuk({required int secili, required ValueChanged<int> onSec}) =>
      MaterialApp(
        home: Scaffold(
          extendBody: true,
          body: const SizedBox.expand(),
          bottomNavigationBar:
              CamNavBar(secili: secili, onSec: onSec, maddeler: maddeler),
        ),
      );

  testWidgets('her sekmenin etiketi gorunuyor', (tester) async {
    await tester.pumpWidget(kabuk(secili: 0, onSec: (_) {}));
    for (final m in maddeler) {
      expect(find.text(m.etiket), findsOneWidget);
    }
  });

  testWidgets('sekmeye dokununca indeks bildiriliyor', (tester) async {
    int? secilen;
    await tester.pumpWidget(kabuk(secili: 0, onSec: (i) => secilen = i));
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(secilen, 2);
  });

  testWidgets('secili sekme dolu ikon, otekiler ince ikon', (tester) async {
    await tester.pumpWidget(kabuk(secili: 1, onSec: (_) {}));
    expect(find.byIcon(Icons.school_rounded), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsNothing);
  });

  testWidgets('InkWell bir Material buluyor', (tester) async {
    // Scaffold'un bottomNavigationBar yuvasi Material DEGIL; cubuk
    // kendi Material'ini tasimazsa dokunma "No Material widget found"
    // ile patliyor.
    await tester.pumpWidget(kabuk(secili: 0, onSec: (_) {}));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Kurslar'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  test('cam cubukta gradyan yok', () {
    final kod = _kodu('lib/widgets/cam_nav_bar.dart');
    expect(kod.contains('LinearGradient'), isFalse,
        reason: 'Yan menu ve oyun ekranlari duz renge gecti; alt cubuk da.');
    expect(kod.contains('BackdropFilter'), isTrue,
        reason: 'Buzlu cam etkisi BackdropFilter ile.');
  });

  test('iki ana ekran da eski NavigationBar\'i birakti', () {
    for (final yol in [
      'lib/screens/unified_home_screen.dart',
      'lib/screens/student/student_home_screen.dart',
    ]) {
      final kod = _kodu(yol);
      expect(kod.contains('NavigationBar('), isFalse, reason: yol);
      expect(kod.contains('CamNavBar('), isTrue, reason: yol);
      expect(kod.contains('extendBody: true'), isTrue,
          reason: '$yol: camin arkasinda bulaniklasacak bir sey olmali.');
    }
  });
}
