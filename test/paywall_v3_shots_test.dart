@Tags(['shots'])
library;

// Yeni (denemesiz) odeme ekranini SAHTE urunlerle cizer — ARAC, test degil.
//   flutter test --run-skipped --tags shots test/paywall_v3_shots_test.dart
// Cikti: outputs/paywall_v3/<dil>.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/subscription_screen.dart';
import 'package:devkom_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sahte_magaza.dart';

Future<void> _fontlar() async {
  final l = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    l.addFont(Future.value(
        File('assets/fonts/Nunito-$w.ttf').readAsBytesSync().buffer.asByteData()));
  }
  await l.load();
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final f = File(
        '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (f.existsSync()) {
      await (FontLoader('MaterialIcons')
            ..addFont(Future.value(f.readAsBytesSync().buffer.asByteData())))
          .load();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_fontlar);
  for (final (lang, zorunlu) in [('tr', true), ('en', true), ('de', false)]) {
    testWidgets('paywall v3 $lang', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': lang});
      final s = SettingsProvider();
      await s.setLocale(Locale(lang));
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
        value: s,
        child: RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            home: SubscriptionScreen(zorunlu: zorunlu, servis: SahteMagaza()),
          ),
        ),
      ));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        if (i == 2) {
          // Maskot gorselinin cozulmesi gercek zaman istiyor.
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 400)));
        }
      }
      await tester.runAsync(() async {
        final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await b.toImage(pixelRatio: 2);
        final data = await img.toByteData(format: ui.ImageByteFormat.png);
        Directory('outputs/paywall_v3').createSync(recursive: true);
        File('outputs/paywall_v3/$lang.png')
            .writeAsBytesSync(data!.buffer.asUint8List());
      });
      await tester.pump(const Duration(seconds: 13));
    });
  }
}
