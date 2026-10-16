@Tags(['shots'])
library;

// Sanal devre (Arduino kursu) kareleri.
//
//     flutter test --run-skipped --tags shots test/arduino_devre_shots_test.dart
//
// Cikti: /mnt/user-data/outputs/arduino_devre/*.png (ARDUINO_DEVRE_DIR).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/sahne/mblock_sahnesi.dart';
import 'package:devkom_app/courses/screens/interactive_lesson_screen.dart';
import 'package:devkom_app/courses/screens/widgets/devre_kurma_adimi.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_blok_adimi.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_tezgahi.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/courses/devre/arduino_projeleri.dart';
import 'package:devkom_app/courses/devre/devre_duzenleyici.dart';
import 'package:devkom_app/courses/screens/arduino_atolye_ekrani.dart';
import 'package:devkom_app/courses/devre/devre_modeli.dart';
import 'package:devkom_app/courses/devre/devre_paneli.dart';
import 'package:devkom_app/courses/devre/devre_simulasyonu.dart';
import 'package:devkom_app/courses/yurutme/mblock_uno.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/mascot.dart';

final _dizin = Platform.environment['ARDUINO_DEVRE_DIR'] ??
    '/mnt/user-data/outputs/arduino_devre';
final _key = GlobalKey();

Future<void> _fontlar() async {
  final n = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    n.addFont(Future.value(
        File('assets/fonts/Nunito-$w.ttf').readAsBytesSync().buffer.asByteData()));
  }
  await n.load();
  await (FontLoader('Baloo2')
        ..addFont(Future.value(File('assets/fonts/Baloo2-ExtraBold.ttf')
            .readAsBytesSync()
            .buffer
            .asByteData())))
      .load();
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
    {Size boy = const Size(430, 932),
    double yazi = 1.0,
    bool iphone = false}) async {
  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;
  // iPhone 15/16 Pro Max: durum cubugu ve ev cizgisi.
  if (iphone) {
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
  }
  tester.platformDispatcher.textScaleFactorTestValue = yazi;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final ayar = SettingsProvider();
  await ayar.setLocale(const Locale('tr'));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: ayar),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ],
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

Future<void> _cek(WidgetTester tester, String ad, {String? dizin}) async {
  final hedef = dizin ?? _dizin;
  await tester.runAsync(() async {
    final b = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(hedef).createSync(recursive: true);
    File('$hedef/$ad.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}



final _ornek = Devre(parcalar: [
  Parca.led('L1', 'c12'),
  Parca.direnc('R1', 'd13', dikey: true),
  Parca.led('L2', 'c17', renk: LedRengi.yesil),
  Parca.direnc('R2', 'd18', dikey: true),
  Parca.buton('B1', 'e23'),
  Parca.pot('P1', 'a3'),
  Parca.servo('S1'),
], kablolar: const [
  Kablo('D13', 'a12'),
  Kablo('D9', 'a17'),
  Kablo('j13', 'U-13'),
  Kablo('j18', 'U-18'),
  Kablo('U-1', 'GND'),
  Kablo('5V', 'L+2'),
  Kablo('S1.gnd', 'GND1'),
  Kablo('S1.vcc', '5V'),
  Kablo('S1.sinyal', 'D6'),
]);

void main() {
  setUpAll(() async {
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    for (final kanal in const [
      'com.llfbandit.app_links/events',
      'com.llfbandit.app_links/messages',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(kanal), (_) async => null);
    }
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
    await _fontlar();
  });

  testWidgets('serbest devre', (tester) async {
    final kart = UnoKarti();
    final sim = DevreSimulasyonu(kart: kart, devre: _ornek, ses: false);
    kart.dijitalYaz(13, true);
    kart.pwmYaz(9, 90);
    kart.servoYaz(6, 30);
    final anahtar = GlobalKey<DevreDuzenleyiciState>();
    await _kur(
        tester,
        Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(title: const Text('Arduino Atölyesi')),
          body: ListView(padding: const EdgeInsets.all(14), children: [
            DevreDuzenleyici(key: anahtar, sim: sim, lang: 'tr', yukseklik: 430),
            DevreGirdiPaneli(sim: sim, lang: 'tr', seriGoster: true),
            DevreUyariSeridi(sim: sim, lang: 'tr'),
          ]),
        ),
        boy: const Size(390, 844));
    await _bekle(tester, 400);
    await _cek(tester, '01_serbest');
    anahtar.currentState!.ucaDokun('D12');
    await _bekle(tester, 400);
    await _cek(tester, '02_yakin_kablo_basi');
    anahtar.currentState!.ucaDokun('a14');
    await _bekle(tester, 400);
    await _cek(tester, '03_kablo_takildi');
    anahtar.currentState!.parcaEkle(ParcaTuru.mesafe);
    await _bekle(tester, 600);
    await _cek(tester, '04_hayalet');
    await _kapat(tester);
    sim.dispose();
  });

  testWidgets('atolye ekrani', (tester) async {
    final arduino = CoursesData.byId('arduino')!;
    final anahtar = GlobalKey<ArduinoAtolyeEkraniState>();
    await _kur(tester, ArduinoAtolyeEkrani(key: anahtar, course: arduino),
        boy: const Size(390, 844));
    await _bekle(tester, 400);
    await _cek(tester, '10_secim');
    anahtar.currentState!.projeAc(arduinoProjeleri[2]);
    await _bekle(tester, 600);
    await _cek(tester, '11_rehberli');
    final d = tester.state<DevreDuzenleyiciState>(find.byType(DevreDuzenleyici));
    d.ucaDokun('5V');
    await _bekle(tester, 200);
    d.ucaDokun('U+19');
    await _bekle(tester, 400);
    d.ucaDokun('D7');
    await _bekle(tester, 200);
    d.ucaDokun('a3');
    await _bekle(tester, 600);
    await _cek(tester, '12_rehberli_yanlis');
    for (var i = 0; i < 4; i++) {
      d.hedefiTak();
      await _bekle(tester, 200);
    }
    await _bekle(tester, 800);
    await _cek(tester, '13_devre_tamam_kod');
    await tester.ensureVisible(find.byKey(const ValueKey('arduino_ornek_kod')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('arduino_ornek_kod')));
    await _bekle(tester, 600);
    await _cek(tester, '13b_ornek_kod');
    await tester.tap(find.byKey(const ValueKey('arduino_calistir')));
    await _bekle(tester, 300);
    await tester.tap(find.byKey(const ValueKey('arduino_sekme_0')));
    await _bekle(tester, 400);
    await _cek(tester, '14_calisiyor');
    await tester.tap(find.byKey(const ValueKey('devre_buton_B1')), warnIfMissed: false);
    final b = tester.getCenter(find.byKey(const ValueKey('devre_buton_B1')));
    final g = await tester.startGesture(b);
    await _bekle(tester, 400);
    await _cek(tester, '15_buton_basili');
    await g.up();
    await tester.tap(find.byKey(const ValueKey('arduino_calistir')));
    await _bekle(tester, 300);
    await _kapat(tester);
  });

  // Ders adimlari: devre kurma ve devreli kod adimi (iPhone 15 Pro Max ve SE).
  final dersler = CourseModules.allLessons('arduino');
  final secilen = [
    for (final id in const ['a1_1_kod', 'a1_3_devre', 'a1_3_kod', 'a3_1_devre', 'a3_1_kod', 'a4_3_kod', 'a6_3_kod'])
      dersler.expand((l) => l.steps).firstWhere((s) => s.id == id),
  ];
  for (final boy in const [Size(430, 932), Size(375, 667)]) {
    for (final adim in secilen) {
      testWidgets('ders adimi ${adim.id} ${boy.width.round()}', (tester) async {
        MBlockTezgahi.webviewsiz = true;
        addTearDown(() => MBlockTezgahi.webviewsiz = false);
        final ders = dersler.firstWhere((l) => l.steps.contains(adim));
        await _kur(
            tester,
            InteractiveLessonScreen(
                course: CoursesData.byId('arduino')!,
                lesson: InteractiveLesson(
                    id: ders.id,
                    courseId: 'arduino',
                    title: ders.title,
                    subtitle: ders.subtitle,
                    order: ders.order,
                    steps: [adim])),
            boy: boy,
            iphone: boy.height > 900);
        await _bekle(tester, 1500);
        final ad = '${boy.width.round()}_${adim.id}';
        if (adim is DevreKurmaStep) {
          await _cek(tester, 'ders_${ad}_1');
          final st = tester.state<DevreKurmaAdimiState>(find.byType(DevreKurmaAdimi));
          final d = st.duzenleyici!;
          d.ucaDokun(adim.hedefler.first.a);
          await _bekle(tester, 300);
          await _cek(tester, 'ders_${ad}_2_secili');
          for (var i = 0; i < adim.hedefler.length; i++) {
            d.hedefiTak();
            await _bekle(tester, 150);
          }
          await _bekle(tester, 600);
          await _cek(tester, 'ders_${ad}_3_tamam');
        } else if (adim is BlockBuilderStep) {
          final s = tester.state<MBlockBlokAdimiState>(find.byType(MBlockBlokAdimi));
          s.durumVer([mblockCozumProgrami(adim.mblock!.cozum, 'tr')]);
          await tester.pump();
          final sahne = tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
          sahne.calistir();
          await _bekle(tester, 700);
          await _cek(tester, 'ders_$ad');
          sahne.durdur();
          await _bekle(tester, 200);
        }
        await _kapat(tester);
      });
    }
  }
}
