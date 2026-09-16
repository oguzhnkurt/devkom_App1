@Tags(['shots'])
library;

// Karşılama akışının ilk ekranını çizer — TEST DEĞİL, ARAÇ.
//   flutter test --run-skipped --tags shots test/onboarding_shots_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/auth/onboarding_flow_screen.dart';

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

  for (final lang in ['tr', 'en']) {
    testWidgets('onboarding $lang', (tester) async {
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
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Nunito',
              fontFamilyFallback: const ['EmojiFallback'],
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: RepaintBoundary(key: _key, child: const OnboardingFlowScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      await tester.runAsync(() async {
        final b = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await b.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('outputs/onboarding').createSync(recursive: true);
        File('outputs/onboarding/onboarding_$lang.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    });
  }
}
