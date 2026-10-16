// KOD BLOKLARI ekran goruntuleri: seviye haritasi ve cozulmus bir
// seviye. `flutter test --run-skipped --tags shots test/kod_bloklari_shots_test.dart`
@Tags(['shots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/kod_bloklari_seviyeleri.dart';
import 'package:devkom_app/courses/screens/widgets/proje_atolyesi.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/games/block_coding_game_screen.dart';
import 'package:devkom_app/services/proje_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';

final _dizin = Platform.environment['KOD_BLOKLARI_DIR'] ??
    '/mnt/user-data/outputs/kod_bloklari';
final _key = GlobalKey();

Future<void> _fontlar() async {
  final n = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    n.addFont(Future.value(
        File('assets/fonts/Nunito-$w.ttf').readAsBytesSync().buffer.asByteData()));
  }
  await n.load();
  final root = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.path;
  final ikon =
      File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (ikon.existsSync()) {
    await (FontLoader('MaterialIcons')
          ..addFont(Future.value(ikon.readAsBytesSync().buffer.asByteData())))
        .load();
  }
}

Future<void> _kur(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final ayar = SettingsProvider();
  await ayar.setLocale(const Locale('tr'));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: ayar),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Nunito'),
      builder: (context, child) => RepaintBoundary(key: _key, child: child),
      home: home,
    ),
  ));
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _cek(WidgetTester tester, String ad) async {
  await tester.runAsync(() async {
    final b = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_dizin).createSync(recursive: true);
    File('$_dizin/$ad.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    SoundService.configure(sound: false, vibration: false);
    await _fontlar();
  });

  testWidgets('harita', (tester) async {
    SharedPreferences.setMockInitialValues({
      'language_code': 'tr',
      'howto_seen_block_coding': true,
      BlockCodingGameScreen.cozulenAnahtari: [
        'kod_bloklari_1',
        'kod_bloklari_2',
        'kod_bloklari_3',
      ],
    });
    await _kur(tester, const BlockCodingGameScreen());
    await _cek(tester, '01_harita');
    await tester.tap(find.byKey(const ValueKey('kod_bloklari_seviye_3')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _cek(tester, '02_seviye4');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('yildiz cozuldu', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final s = KodBloklariSeviyeleri.hepsi[7];
    await _kur(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ProjeAtolyesiWidget(
            step: s,
            course: CoursesData.byId('scratch')!,
            isDark: false,
            lang: 'tr',
            onComplete: (_) {},
            kayitli: KayitliProje(
              id: 'k',
              ad: 'Yıldız',
              kursId: 'scratch',
              adimId: s.id,
              kod: KodYapisi.coz(s.ornekCozum),
              tarih: DateTime(2026, 10, 16),
            ),
          ),
        ),
      ),
    );
    final bayrak = find.byKey(const ValueKey('ders_bayrak'));
    await tester.ensureVisible(bayrak.first);
    await tester.pump();
    await tester.tap(bayrak.first);
    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _cek(tester, '03_yildiz');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });
}
