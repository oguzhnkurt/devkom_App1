// Ayarlar > Maskotunun adi: kaydediyor, kirpiyor, bos adi kabul
// etmiyor ve "Devi'ye geri don" ile sifirliyor.
//
// Ad degistirme kurulumdan kaldirildi; tek yeri burasi.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/settings/settings_screen.dart';
import 'package:devkom_app/utils/app_localizations.dart';

Future<SettingsProvider> _ayarlar(String lang) async {
  SharedPreferences.setMockInitialValues({'language_code': lang});
  final s = SettingsProvider();
  await s.setLocale(Locale(lang));
  return s;
}

Widget _app(SettingsProvider s, String lang) =>
    ChangeNotifierProvider<SettingsProvider>.value(
      value: s,
      child: MaterialApp(
        locale: Locale(lang),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr'),
          Locale('en'),
          Locale('de'),
          Locale('es'),
        ],
        home: const SettingsScreen(),
      ),
    );

Future<void> _kareler(WidgetTester t, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _ac(WidgetTester tester) async {
  final satir = find.byKey(const ValueKey('ayarlar_maskot_adi'));
  await tester.scrollUntilVisible(satir, 200,
      scrollable: find.byType(Scrollable).first);
  await tester.pump();
  await tester.tap(satir, warnIfMissed: true);
  await _kareler(tester);
  expect(find.byKey(const ValueKey('maskot_adi_penceresi')), findsOneWidget);
}

void main() {
  testWidgets('ad kaydediliyor, kirpiliyor ve her yerde okunuyor',
      (tester) async {
    final s = await _ayarlar('tr');
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(s, 'tr'));
    await _kareler(tester, 3);

    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('ayarlar_maskot_adi')), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Maskotunun adı'), findsOneWidget);
    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('ayarlar_maskot_adi_deger')))
            .data,
        'Devi');

    await _ac(tester);
    final alan = find.byKey(const ValueKey('maskot_adi_alani'));
    expect(tester.widget<TextField>(alan).maxLength, 14);

    // Bos ad kaydedilemiyor.
    await tester.enterText(alan, '   ');
    await tester.pump();
    expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('maskot_adi_kaydet')))
            .onPressed,
        isNull);

    await tester.enterText(alan, '  Robi  ');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('maskot_adi_kaydet')));
    await _kareler(tester);

    expect(s.mascotName, 'Robi');
    expect(s.hasCustomMascotName, isTrue);
    expect((await SharedPreferences.getInstance()).getString('mascot_name'),
        'Robi');
    expect(find.byKey(const ValueKey('maskot_adi_penceresi')), findsNothing);
    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('ayarlar_maskot_adi_deger')))
            .data,
        'Robi');
  });

  testWidgets("Devi'ye geri don adi sifirliyor", (tester) async {
    final s = await _ayarlar('en');
    await s.setMascotName('Zap');
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(s, 'en'));
    await _kareler(tester, 3);
    await _ac(tester);
    expect(find.text("Your mascot's name"), findsNWidgets(2));
    expect(find.text('Back to Devi'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('maskot_adi_sifirla')));
    await _kareler(tester);

    expect(s.hasCustomMascotName, isFalse);
    expect(s.mascotName, 'Devi');
  });

  for (final lang in ['de', 'es']) {
    testWidgets('pencere $lang dilinde tasmadan ciziliyor', (tester) async {
      final s = await _ayarlar(lang);
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(s, lang));
      await _kareler(tester, 3);
      await _ac(tester);
      expect(tester.takeException(), isNull);
    });
  }
}
