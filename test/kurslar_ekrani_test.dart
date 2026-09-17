// KURSLAR EKRANI — yol artık nerede olduğunu söylüyor.
//
// Liste yalnızca "12 ders / 4 saat" diyordu: hangi kursu bitirdiğin,
// nereden devam edeceğin ekranda hiçbir yerde yazmıyordu, dolayısıyla
// bütün kurslar birbirinin aynı duruyordu.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/screens/course_catalog_screen.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/widgets/mascot.dart';

Future<void> _ciz(WidgetTester tester, String dil) async {
  SharedPreferences.setMockInitialValues({'language_code': dil});
  final settings = SettingsProvider();
  await settings.setLocale(Locale(dil));

  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        locale: Locale(dil),
        supportedLocales: const [
          Locale('tr'),
          Locale('en'),
          Locale('de'),
          Locale('es')
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const CourseCatalogScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  final src =
      File('lib/courses/screens/course_catalog_screen.dart').readAsStringSync();

  testWidgets('ekran saglayicisiz da cizilebiliyor ve maskot var',
      (tester) async {
    addTearDown(tester.view.reset);
    // AuthProvider YOK: ekran goruntusu araclari ve bu test boyle
    // caliyor. Ilerleme okunamazsa ekran cokmemeli, yol ilerlemesiz
    // cizilmeli.
    await _ciz(tester, 'tr');
    // Tasma da burada yakalaniyor: kurs kartindaki cipler dar ekranda
    // saga tasiyordu ve sari-siyah seritler cikiyordu.
    expect(tester.takeException(), isNull);
    expect(find.byType(Mascot), findsWidgets,
        reason: 'Devi kurslar sayfasinda yok.');
    expect(find.text('Öğrenme Yolu'), findsOneWidget);
  });

  testWidgets('dort dilde de aciliyor', (tester) async {
    addTearDown(tester.view.reset);
    for (final dil in const ['en', 'de', 'es']) {
      await _ciz(tester, dil);
      expect(tester.takeException(), isNull, reason: '$dil dilinde hata');
    }
  });

  test('yol ilerlemesi GERCEK veriden geliyor', () {
    expect(src.contains('completedLessonIds'), isTrue,
        reason: 'Ilerleme gercek tamamlanan derslerden okunmuyor.');
    // Uydurma bir "ustalik yuzdesi" yazilmamali: ekranda yalnizca
    // bitirilen/toplam ders sayisi var.
    expect(RegExp(r"'%\$\{").hasMatch(src), isFalse);
    expect(src.contains(r"'$bitenDers/$toplamDers'"), isTrue);
  });

  test('siradaki kurs isaretleniyor', () {
    expect(src.contains('simdiBurada'), isTrue);
    for (final yazi in const [
      "'Kaldığın yer'",
      "'Where you left off'",
      "'Wo du aufgehört hast'",
      "'Donde lo dejaste'",
      "'Buradan başla'",
    ]) {
      expect(src.contains(yazi), isTrue, reason: 'eksik: $yazi');
    }
  });

  test('yildizlar hareket azaltmaya uyuyor', () {
    final bas = src.indexOf('class _CanliYildizlarState');
    expect(bas, greaterThan(0));
    final govde = src.substring(bas, src.indexOf('class _StarsPainter'));
    expect(govde.contains('Motion.reduced(context)'), isTrue,
        reason: 'Hareket azaltilmisken yildizlar yine donuyor.');
    expect(govde.contains('RepaintBoundary'), isTrue,
        reason: 'Yildizlar kendi katmaninda cizilmiyor — butun baslik '
            'bandi her karede yeniden cizilir.');
  });
}
