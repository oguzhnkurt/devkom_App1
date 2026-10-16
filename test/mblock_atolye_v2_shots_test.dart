@Tags(['shots'])
library;

// mBlock atolyesi v2 (Flutter tezgah), sahne bayragi ve mBlock 1. ders
// kareleri.
//
//     flutter test --run-skipped --tags shots test/mblock_atolye_v2_shots_test.dart
//
// Cikti: /mnt/user-data/outputs/mblock_atolye_v2/*.png
// (MBLOCK_ATOLYE_V2_DIR ile degistirilebilir).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/sahne/kategorili_tezgah.dart';
import 'package:devkom_app/courses/sahne/mblock_sahnesi.dart';
import 'package:devkom_app/courses/screens/mblock_atolye_ekrani.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/mascot.dart';
import 'package:devkom_app/widgets/scratch_blok.dart';

final _dizin = Platform.environment['MBLOCK_ATOLYE_V2_DIR'] ??
    '/mnt/user-data/outputs/mblock_atolye_v2';
final _key = GlobalKey();
final _mblock = CoursesData.byId('mblock')!;
final _scratch = CoursesData.byId('scratch')!;

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

Future<void> _kur(WidgetTester tester, Widget home,
    {Size boy = const Size(430, 932), double yazi = 1.0}) async {
  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = yazi;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final ayar = SettingsProvider();
  await ayar.setLocale(const Locale('tr'));
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: ayar,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr'),
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
      theme: ThemeData(useMaterial3: true, fontFamily: 'Nunito'),
      builder: (context, child) => RepaintBoundary(key: _key, child: child),
      home: home,
    ),
  ));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.runAsync(() async {
    try {
      await precacheImage(
              const AssetImage(Mascot.durgunGorsel), _key.currentContext!)
          .timeout(const Duration(seconds: 20));
    } catch (_) {}
  });
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _bekle(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
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

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}

Future<void> _dokun(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 120));
}

Future<void> _kategori(WidgetTester tester, String ad) async {
  final f = find.byKey(ValueKey('palet_kategori_$ad'));
  final serit = find.descendant(
      of: find.byKey(const ValueKey('palet_kategori_seridi')),
      matching: find.byType(Scrollable));
  for (var i = 0; i < 18 && f.evaluate().isEmpty; i++) {
    await tester.drag(serit.first, Offset(i < 6 ? -150 : 150, 0));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await _dokun(tester, f);
  await _bekle(tester, 600);
}

final _ledProgrami = [
  const MBlockBlok(tip: 'dev_kart_acilis'),
  const MBlockBlok(tip: 'dev_surekli', icerik: [
    MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'PIN': '13', 'SEVIYE': 'HIGH'}),
    MBlockBlok(tip: 'dev_bekle', alanlar: {'SANIYE': '1'}),
    MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'PIN': '13', 'SEVIYE': 'LOW'}),
    MBlockBlok(tip: 'dev_bekle', alanlar: {'SANIYE': '1'}),
  ]),
];

void main() {
  _seciciKaresi();
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await _fontlar();
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('atolye 430x932', (tester) async {
    await _kur(tester, MBlockAtolyeEkrani(course: _mblock));
    await _cek(tester, '1_atolye_430_bos');
    await _kategori(tester, 'hareket');
    await _cek(tester, '2_atolye_430_hareket');
    await _kategori(tester, 'mblockPin');
    await _cek(tester, '3_atolye_430_pin');
    final s = tester
        .state<MBlockAtolyeEkraniState>(find.byType(MBlockAtolyeEkrani));
    s.durumVer([_ledProgrami]);
    await tester.pump();
    final sahne = tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
    await _dokun(tester, find.byKey(const ValueKey('mblock_sahne_bayragi')));
    for (var i = 0; i < 40 && sahne.unoKarti.dijital[13] != true; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await _bekle(tester, 300);
    await tester.drag(find.byKey(const ValueKey('mblock_atolye_sayfasi')),
        const Offset(0, -400));
    await _bekle(tester, 200);
    await tester.drag(find.byKey(const ValueKey('mblock_atolye_sayfasi')),
        const Offset(0, 400));
    await _bekle(tester, 200);
    await _cek(tester, '4_atolye_430_led_yanik');
    sahne.durdur();
    await _kapat(tester);
  });

  testWidgets('atolye 375x667', (tester) async {
    await _kur(tester, MBlockAtolyeEkrani(course: _mblock),
        boy: const Size(375, 667));
    final s = tester
        .state<MBlockAtolyeEkraniState>(find.byType(MBlockAtolyeEkrani));
    s.durumVer([_ledProgrami]);
    await tester.pump();
    await _bekle(tester, 300);
    await _cek(tester, '5_atolye_375_program');
    await _kategori(tester, 'kontrol');
    await _cek(tester, '5b_atolye_375_kontrol');
    await _kapat(tester);
  });

  testWidgets('atolye 360x640 x1.3', (tester) async {
    await _kur(tester, MBlockAtolyeEkrani(course: _mblock),
        boy: const Size(360, 640), yazi: 1.3);
    final s = tester
        .state<MBlockAtolyeEkraniState>(find.byType(MBlockAtolyeEkrani));
    s.durumVer([_ledProgrami]);
    await tester.pump();
    await _bekle(tester, 300);
    await _cek(tester, '6_atolye_360_yazi13');
    expect(find.byType(KategoriliTezgah), findsOneWidget);
    await _kapat(tester);
  });

  testWidgets('scratch sahnesi: bayrak calisirken', (tester) async {
    final step = CourseModules.allLessons('scratch')
        .expand((l) => l.steps)
        .whereType<BlockBuilderStep>()
        .firstWhere((s) => s.id == 's1_3_build1');
    await _kur(
        tester,
        Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: BlockBuilderStepWidget(
                  step: step,
                  course: _scratch,
                  isDark: false,
                  onComplete: (_) {}),
            ),
          ),
        ));
    for (final id in step.correctSequence) {
      final f = find
          .byWidgetPredicate((w) => w is ScratchBlok && w.kimlik == id)
          .first;
      await _dokun(tester, f);
      await _bekle(tester, 300);
    }
    await _dokun(tester, find.byKey(const ValueKey('sahne_bayragi')));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
    await _bekle(tester, 1500);
    await _cek(tester, '7_scratch_bayrak_aktif');
    await _bekle(tester, 20000);
    await _kapat(tester);
  });
}

void _seciciKaresi() {
  testWidgets('secici', (tester) async {
    await _kur(tester, MBlockAtolyeEkrani(course: _mblock));
    final s = tester
        .state<MBlockAtolyeEkraniState>(find.byType(MBlockAtolyeEkrani));
    s.durumVer([_ledProgrami]);
    await tester.pump();
    await _bekle(tester, 300);
    final blok = find.byKey(const ValueKey('ic_ice_blok_2'));
    final cizim = tester.widget<ScratchBlok>(
        find.descendant(of: blok, matching: find.byType(ScratchBlok)).first);
    final kutular =
        ScratchBlokOlcer.parcaKutulari(cizim.tanim, cizim.olcek, silme: true);
    await tester.tapAt(tester.getTopLeft(blok) + kutular[0].kutu.center);
    await _bekle(tester, 600);
    await _cek(tester, '8_pin_secici');
    await _kapat(tester);
  });
}
