@Tags(['shots'])
library;

// Ayarlar ekranını dört dilde çizip PNG yazar — TEST DEĞİL, ARAÇ.
//
//   flutter test --run-skipped --tags shots test/settings_shots_test.dart
//
// Çıktı: outputs/settings/settings_<dil>.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/settings/settings_screen.dart';
import 'package:devkom_app/utils/app_localizations.dart';

const _outDir = 'outputs/settings';
final _key = GlobalKey();

Future<void> _loadFonts() async {
  final loader = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    loader.addFont(Future.value(
        File('assets/fonts/Nunito-$w.ttf').readAsBytesSync().buffer.asByteData()));
  }
  await loader.load();

  final emoji = File('/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf');
  if (emoji.existsSync()) {
    final l = FontLoader('EmojiFallback')
      ..addFont(Future.value(emoji.readAsBytesSync().buffer.asByteData()));
    await l.load();
  }
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final icons = File(
        '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      final l = FontLoader('MaterialIcons')
        ..addFont(Future.value(icons.readAsBytesSync().buffer.asByteData()));
      await l.load();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  for (final lang in ['tr', 'en', 'de', 'es']) {
    testWidgets('ayarlar $lang', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': lang});
      final settings = SettingsProvider();
      await settings.setLocale(Locale(lang));

      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
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
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Nunito',
              fontFamilyFallback: const ['EmojiFallback'],
            ),
            home: RepaintBoundary(key: _key, child: const SettingsScreen()),
          ),
        ),
      );
      // Abonelik bilgisi GERCEK async; sahte zaman onu ilerletmiyor.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      });
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 2));

      await tester.runAsync(() async {
        final boundary =
            _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory(_outDir).createSync(recursive: true);
        File('$_outDir/settings_$lang.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
      });

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
