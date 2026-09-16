// Ayarlar ekrani dort dilde de duzgun cizilmeli.
//
// Ekran yeniden tasarlandi (Pro ekraninin gokyuzu temasi, beyaz
// kartlar). Yeniden tasarim sirasinda iki risk var:
//
//  1. Turkce kalinti. Bu ekranin bircok yazisi `_t(...)` ile dort
//     dilli ama bolum basliklarindan biri ('Devkom Pro') elle
//     yazilmisti; almanca secen ebeveyn turkce bir baslik goruyordu.
//  2. Tasma. Almanca ve ispanyolca etiketler ("Datenschutzerklärung
//     und Kontolöschung ansehen") turkce/ingilizceden belirgin uzun;
//     kart icindeki satirlar bunlari kirpabilir.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/app_version.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/settings/settings_screen.dart';
import 'package:devkom_app/utils/app_localizations.dart';

/// Turkce kalinti ararken hangi harflere bakilacagi DILE GORE degisir:
/// ä/ö/ü almancanin kendi harfleri, á/é/í/ó/ú/ñ ispanyolcanin.
const _turkishOnly = {
  'en': 'çÇğĞıİşŞöÖüÜ',
  'de': 'çÇğĞıİşŞ',
  'es': 'ğĞıİşŞöÖ',
};

Future<SettingsProvider> _settings(String lang) async {
  SharedPreferences.setMockInitialValues({'language_code': lang});
  final s = SettingsProvider();
  await s.setLocale(Locale(lang));
  return s;
}

Widget _app(SettingsProvider settings, String lang) => ChangeNotifierProvider<
        SettingsProvider>.value(
      value: settings,
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

void main() {
  for (final lang in ['tr', 'en', 'de', 'es']) {
    testWidgets('ayarlar — $lang dilinde tasma ve turkce kalinti yok',
        (tester) async {
      final settings = await _settings(lang);

      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final overflows = <String>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        final text = details.exceptionAsString();
        if (text.contains('overflowed')) {
          overflows.add(text.split('\n').first);
        } else {
          previous?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = previous);

      await tester.pumpWidget(_app(settings, lang));
      await tester.pump(const Duration(milliseconds: 600));

      expect(overflows, isEmpty,
          reason: '$lang dilinde tasma: ${overflows.join(" | ")}');

      if (lang != 'tr') {
        final letters = _turkishOnly[lang]!.split('');
        final leaks = <String>[];
        for (final t in tester.widgetList<Text>(find.byType(Text))) {
          final text = t.data ?? t.textSpan?.toPlainText() ?? '';
          if (letters.any(text.contains)) leaks.add('"$text"');
        }
        expect(leaks, isEmpty,
            reason: '$lang dilinde turkce yazi: ${leaks.join(", ")}');
      }

      // Gokyuzu bulutlari donuyor; agaci sokup zamanlayicilari
      // bosaltiyoruz.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
  }

  testWidgets('surum ekranda pubspec ile ayni gorunuyor', (tester) async {
    final settings = await _settings('tr');
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(settings, 'tr'));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.scrollUntilVisible(
      find.textContaining(AppVersion.full),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining(AppVersion.full), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('marka adi Devkom degil DevEducation', (tester) async {
    final settings = await _settings('tr');
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(settings, 'tr'));
    await tester.pump(const Duration(milliseconds: 600));

    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      final text = t.data ?? t.textSpan?.toPlainText() ?? '';
      expect(text.toLowerCase().contains('devkom'), isFalse,
          reason: 'Ayarlarda eski marka adi kalmis: "$text"');
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
