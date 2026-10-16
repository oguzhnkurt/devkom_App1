@Tags(['shots'])
library;

// Serbest atolyede kuklayi surukleme kareleri: once, suruklerken ve
// birakinca (konum gostergesi), iki kuklali atolyede secim, mBlock
// atolyesi.
//
//     flutter test --run-skipped --tags shots test/kukla_surukle_shots_test.dart
//
// Cikti: /mnt/user-data/outputs/kukla_surukle/*.png
// (KUKLA_SURUKLE_DIR ile degistirilebilir).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/scratch_atolyeleri.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/sahne/proje_sahnesi.dart';
import 'package:devkom_app/courses/screens/mblock_atolye_ekrani.dart';
import 'package:devkom_app/courses/screens/projelerim_ekrani.dart';
import 'package:devkom_app/courses/screens/widgets/scratch_tezgahi.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/proje_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/mascot.dart';

final _dizin = Platform.environment['KUKLA_SURUKLE_DIR'] ??
    '/mnt/user-data/outputs/kukla_surukle';
final _key = GlobalKey();
final _scratch = CoursesData.byId('scratch')!;
final _mblock = CoursesData.byId('mblock')!;

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
    {Size boy = const Size(430, 932)}) async {
  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final ayar = SettingsProvider();
  await ayar.setLocale(const Locale('tr'));
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: ayar,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
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

Finder get _devi => find.descendant(
    of: find.byType(ProjeSahnesi), matching: find.byType(Mascot));

double _olcek(WidgetTester tester) {
  final s = tester.getSize(find.byType(ProjeSahnesi));
  return (s.width / 480) < (s.height / 360) ? s.width / 480 : s.height / 360;
}

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}

KayitliProje _proje(String kod, {String? adim}) => KayitliProje(
      id: 'p1',
      ad: 'Benim oyunum',
      kursId: 'scratch',
      adimId: adim,
      kod: KodYapisi.coz(kod),
      tarih: DateTime(2026, 10, 16),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await _fontlar();
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
  });

  testWidgets('serbest atolye: once, suruklerken, birakinca', (tester) async {
    await _kur(
        tester,
        AtolyeEkrani(
          course: _scratch,
          step: ScratchAtolyeleri.serbest,
          kayitli: _proje('green_flag say_hello move_10'),
        ));
    await tester.ensureVisible(find.byType(ProjeSahnesi));
    await _bekle(tester, 300);
    await _cek(tester, '1_serbest_once');
    final o = _olcek(tester);
    final g = await tester.startGesture(tester.getCenter(_devi.first));
    await g.moveBy(Offset(60 * o, -35 * o));
    await tester.pump();
    await g.moveBy(Offset(60 * o, -35 * o));
    await _bekle(tester, 100);
    await _cek(tester, '2_serbest_suruklerken');
    await g.up();
    await _bekle(tester, 300);
    await _cek(tester, '3_serbest_birakinca');
    tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi)).calistir();
    await _bekle(tester, 900);
    await _cek(tester, '4_serbest_calisirken');
    await _bekle(tester, 3000);
    await _kapat(tester);
  });

  testWidgets('yakala: iki kukla, Fare secili', (tester) async {
    final a = ScratchAtolyeleri.yakalaOyunu;
    await _kur(
        tester,
        AtolyeEkrani(
            course: _scratch,
            step: a,
            kayitli: _proje(a.ornekCozum, adim: a.id)));
    await tester.ensureVisible(find.byType(ProjeSahnesi));
    await _bekle(tester, 300);
    final o = _olcek(tester);
    final fare =
        tester.getCenter(find.byType(ProjeSahnesi)) + Offset(100 * o, -50 * o);
    final g = await tester.startGesture(fare);
    await g.moveBy(Offset(30 * o, 40 * o));
    await tester.pump();
    await g.moveBy(Offset(30 * o, 40 * o));
    await g.up();
    await _bekle(tester, 300);
    await _cek(tester, '5_yakala_fare_secili');
    await _kapat(tester);
  });

  testWidgets('mBlock atolyesi: Devi suruklendi', (tester) async {
    await _kur(tester, MBlockAtolyeEkrani(course: _mblock));
    tester
        .state<MBlockAtolyeEkraniState>(find.byType(MBlockAtolyeEkrani))
        .durumVer([
      [
        const MBlockBlok(tip: 'dev_bayrak'),
        const MBlockBlok(tip: 'dev_de'),
        const MBlockBlok(tip: 'dev_git', alanlar: {'ADIM': '50'}),
      ]
    ]);
    await _bekle(tester, 300);
    final o = _olcek(tester);
    final g = await tester.startGesture(tester.getCenter(_devi.first));
    await g.moveBy(Offset(-75 * o, -30 * o));
    await tester.pump();
    await g.moveBy(Offset(-75 * o, -30 * o));
    await g.up();
    await _bekle(tester, 300);
    await _cek(tester, '6_mblock_suruklendi');
    await tester.tap(find.byKey(const ValueKey('mblock_sahne_bayragi')));
    await _bekle(tester, 3500);
    await _cek(tester, '7_mblock_calisti');
    await _kapat(tester);
  });
}
