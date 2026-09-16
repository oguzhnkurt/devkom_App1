@Tags(['shots'])
library;

// Maskotun GECTIGI GERCEK EKRANLARI telefon olcusunde cizer — ARAC.
//
//     flutter test --run-skipped --tags shots test/mascot_in_app_test.dart
//
// Amac: bes karakter secilebilir hale gelince uygulamanin icinde bir
// sey kirildi mi. Widget'lar elle kuruluyor, cizim gercek arayuz.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/activity_hub_screen.dart';
import 'package:devkom_app/screens/character_screen.dart';
import 'package:devkom_app/models/store_item_model.dart';
import 'package:devkom_app/widgets/character_stage.dart';
import 'package:devkom_app/widgets/first_task.dart';
import 'package:devkom_app/widgets/mascot.dart';

const _outDir = 'outputs/mascot';

Future<void> _loadFonts() async {
  for (final w in ['400', '600', '700', '800']) {
    final f = File('assets/fonts/Nunito-$w.ttf');
    if (f.existsSync()) {
      await (FontLoader('Nunito')
            ..addFont(Future.value(f.readAsBytesSync().buffer.asByteData())))
          .load();
    }
  }
  for (final path in const [
    '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
    '/System/Library/Fonts/Apple Color Emoji.ttc',
  ]) {
    final f = File(path);
    if (f.existsSync()) {
      await (FontLoader('EmojiFallback')
            ..addFont(Future.value(f.readAsBytesSync().buffer.asByteData())))
          .load();
      break;
    }
  }
}

final _key = GlobalKey();

StoreItem _gear(String key, String emoji, StoreItemCategory c) => StoreItem(
      id: key,
      itemKey: key,
      category: c,
      name: key,
      priceJeton: 0,
      iconEmoji: emoji,
      colorHex: '#7C4DFF',
    );

/// 390x844 mantiksal piksel — iPhone olcusu.
Future<List<String>> _shoot(
  WidgetTester tester,
  String name,
  Widget body, {
  String lang = 'tr',
  MascotSpecies? mascot,
  bool bare = false,
}) async {
  SharedPreferences.setMockInitialValues({
    'language_code': lang,
    if (mascot != null) 'mascot_species': mascot.name,
  });
  late SettingsProvider settings;
  await tester.runAsync(() async {
    settings = SettingsProvider();
    await Future<void>.delayed(const Duration(milliseconds: 30));
  });
  await settings.setLocale(Locale(lang));

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

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(lang),
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Nunito',
          fontFamilyFallback: const ['EmojiFallback'],
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        ),
        home: RepaintBoundary(
          key: _key,
          child: bare
              ? body
              : Scaffold(
                  backgroundColor: const Color(0xFFF5F7FA),
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                      child: body,
                    ),
                  ),
                ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));

  // Gorseller (logo gibi) sahte zamanda COZULMUYOR: precache olmadan
  // hicbiri cizilmiyor ve ekran goruntusu "logo yok" diye yalan
  // soyluyor. Bir kez yanilttigi icin buraya yazildi.
  await tester.runAsync(() async {
    await precacheImage(
        const AssetImage('assets/images/app_icon.png'), _key.currentContext!);
    await Future<void>.delayed(const Duration(milliseconds: 120));
  });
  await tester.pump(const Duration(milliseconds: 120));

  await tester.runAsync(() async {
    final b = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 3);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_outDir).createSync(recursive: true);
    File('$_outDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });

  return overflows;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  testWidgets('ilk gorev — turkce, acilistaki karakter', (tester) async {
    final o = await _shoot(
      tester,
      'app_01_ilk_gorev_tr',
      Center(child: FirstTask(lang: 'tr', onSolved: (_) {})),
    );
    expect(o, isEmpty, reason: 'taşma: ${o.join(" | ")}');
  });

  testWidgets('ilk gorev — almanca, Mia secili', (tester) async {
    final o = await _shoot(
      tester,
      'app_02_ilk_gorev_de',
      Center(child: FirstTask(lang: 'de', onSolved: (_) {})),
      lang: 'de',
      mascot: MascotSpecies.mia,
    );
    expect(o, isEmpty, reason: 'taşma: ${o.join(" | ")}');
  });

  testWidgets('secici — telefon genisliginde', (tester) async {
    final o = await _shoot(
      tester,
      'app_03_secici',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Arkadaşın',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          SizedBox(height: 2),
          Text('Beşinden birini seç — hepsi ücretsiz',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280))),
          SizedBox(height: 14),
          MascotPicker(),
        ],
      ),
    );
    expect(o, isEmpty, reason: 'taşma: ${o.join(" | ")}');
  });

  testWidgets('etkinlik alani', (tester) async {
    final o = await _shoot(
      tester,
      'app_05_etkinlik',
      const ActivityHubScreen(),
      bare: true,
    );
    expect(o, isEmpty, reason: 'taşma: ${o.join(" | ")}');
  });

  testWidgets('karakter sahnesi — ekipmanli', (tester) async {
    final o = await _shoot(
      tester,
      'app_04_sahne',
      Center(
        child: CharacterStage(
          size: 200,
          interactive: false,
          mood: MascotMood.cheering,
          hat: _gear('hat_top', '🎩', StoreItemCategory.hat),
          glasses: _gear('glasses_cool', '🕶️', StoreItemCategory.glasses),
          shoes: _gear('shoes_run', '👟', StoreItemCategory.shoes),
        ),
      ),
      mascot: MascotSpecies.kasif,
    );
    expect(o, isEmpty, reason: 'taşma: ${o.join(" | ")}');
  });
}
