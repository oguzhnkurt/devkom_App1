@Tags(['shots'])
library;

// Scratch ve mBlock kurslarini heyecanli kilan ekranlardan onizleme
// kareleri: ders bitis penceresi, modul kutlamasi, yol haritasi, Devi'nin
// tepkileri, mBlock acilisi, sanal Uno, kukla sahnesi, yedek tezgah.
//
//     flutter test --run-skipped --tags shots test/kurs_heyecan_shots_test.dart
//
// Cikti: /mnt/user-data/outputs/kurs_heyecan/*.png
// (KURS_HEYECAN_DIR ile degistirilebilir).
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
import 'package:devkom_app/courses/screens/interactive_course_screen.dart';
import 'package:devkom_app/courses/screens/interactive_lesson_screen.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_blok_adimi.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_tezgahi.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/courses/sahne/mblock_sahnesi.dart';
import 'package:devkom_app/courses/tanitim/kurs_acilis_ekrani.dart';
import 'package:devkom_app/courses/tanitim/kurs_tanitimi.dart';
import 'package:devkom_app/courses/tanitim/modul_kutlamasi.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/ders_ilerleme_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/mascot.dart';
import 'package:devkom_app/widgets/scratch_blok.dart';

final _dizin = Platform.environment['KURS_HEYECAN_DIR'] ??
    '/mnt/user-data/outputs/kurs_heyecan';
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
    {Size boy = const Size(390, 844), AuthProvider? auth}) async {
  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final ayar = SettingsProvider();
  await ayar.setLocale(const Locale('tr'));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: ayar),
      if (auth != null) ChangeNotifierProvider<AuthProvider>.value(value: auth),
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

Future<void> _cek(WidgetTester tester, String ad, {double oran = 2}) async {
  await tester.runAsync(() async {
    final b = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: oran);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_dizin).createSync(recursive: true);
    File('$_dizin/$ad.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}

Widget _adimSayfasi(Widget adim) => Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: adim,
        ),
      ),
    );

BlockBuilderStep _mblockAdimi(String id) => CourseModules.allLessons('mblock')
    .expand((l) => l.steps)
    .whereType<BlockBuilderStep>()
    .firstWhere((s) => s.id == id);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await _fontlar();
    SoundService.configure(sound: false);
    for (final kanal in const [
      'com.llfbandit.app_links/events',
      'com.llfbandit.app_links/messages',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(kanal), (_) async => null);
    }
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
  });

  testWidgets('1 ders bitis penceresi', (tester) async {
    final bugun = DateTime.now();
    String g(int geri) => DersSerisi.gunAnahtari(
        DateTime(bugun.year, bugun.month, bugun.day - geri));
    SharedPreferences.setMockInitialValues({
      'language_code': 'tr',
      DersSerisi.anahtar: [g(2), g(1)],
    });
    final auth = AuthProvider();
    final ilk = CourseModules.allLessons('scratch')[2];
    final ders = InteractiveLesson(
      id: ilk.id,
      courseId: 'scratch',
      title: ilk.title,
      subtitle: ilk.subtitle,
      order: ilk.order,
      xpReward: 40,
      badge: 'loop_master',
      steps: const [
        ExplanationStep(id: 'k1', title: 'Bir', content: 'Tek paragraf.'),
      ],
    );
    await _kur(tester,
        InteractiveLessonScreen(course: _scratch, lesson: ders), auth: auth);
    await _bekle(tester, 700);
    await tester.tap(find.text('Tamamla'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)));
    await _bekle(tester, 2200);
    await _cek(tester, '1_ders_bitis_penceresi');
    await _kapat(tester);
  });

  testWidgets('2 modul kutlamasi', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final moduller = CourseModules.forCourse('scratch');
    final biten = {
      for (final m in moduller.take(5))
        for (final l in m.lessons) l.id
    };
    await _kur(
        tester,
        ModulKutlamaEkrani(
          course: _scratch,
          modulNo: 4,
          biten: biten,
          sonrakiDers: moduller[5].lessons.first,
          onSonrakiDers: () {},
          tekrar: true,
        ));
    await _bekle(tester, 1600);
    await _cek(tester, '2_modul_kutlamasi');
    await _kapat(tester);
  });

  testWidgets('3 kurs yol haritasi', (tester) async {
    final moduller = CourseModules.forCourse('scratch');
    SharedPreferences.setMockInitialValues({
      'language_code': 'tr',
      DersIlerlemeDeposu.tamamlananAnahtari: [
        for (final m in moduller.take(4))
          for (final l in m.lessons) l.id,
        moduller[4].lessons.first.id,
      ],
    });
    final auth = AuthProvider();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await _kur(tester, InteractiveCourseScreen(course: _scratch), auth: auth);
    await _bekle(tester, 800);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -260));
    await _bekle(tester, 900);
    await _cek(tester, '3_kurs_yol_haritasi');
    await _kapat(tester);
  });

  testWidgets('4 Devi tepkisi: dogru ve yanlis', (tester) async {
    final soru = CourseModules.allLessons('scratch')
        .expand((l) => l.steps)
        .whereType<MultipleChoiceStep>()
        .first;
    await _kur(
        tester,
        _adimSayfasi(MultipleChoiceStepWidget(
          step: soru,
          course: _scratch,
          isDark: false,
          onComplete: (_) {},
        )));
    await tester.tap(find.text(soru.options[soru.correctIndex].textFor('tr')));
    await _bekle(tester, 900);
    await _cek(tester, '4a_devi_tepkisi_dogru');
    await _kapat(tester);

    // Scratch blok kurma: tam ama yanlis sirali dizi.
    final adim = CourseModules.allLessons('scratch')
        .expand((l) => l.steps)
        .whereType<BlockBuilderStep>()
        .firstWhere((s) => s.id == 's1_2_build2');
    await _kur(
        tester,
        _adimSayfasi(BlockBuilderStepWidget(
          step: adim,
          course: _scratch,
          isDark: false,
          onComplete: (_) {},
        )));
    final ters = [
      adim.correctSequence.first,
      ...adim.correctSequence.skip(1).toList().reversed,
    ];
    for (final id in ters) {
      final f =
          find.byWidgetPredicate((w) => w is ScratchBlok && w.kimlik == id).first;
      await tester.ensureVisible(f);
      await tester.tap(f);
      await _bekle(tester, 250);
    }
    await tester.ensureVisible(find.byKey(const ValueKey('ders_bayrak')));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
    await _bekle(tester, 900);
    await _cek(tester, '4b_devi_tepkisi_yanlis');
    await _kapat(tester);
  });

  testWidgets('5 mBlock acilis sahnesi', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _kur(
        tester,
        KursAcilisEkrani(
            course: _mblock, tanitim: KursTanitimi.forCourse('mblock')!));
    await _bekle(tester, 4500);
    await _cek(tester, '5a_mblock_acilis_selam');
    await tester.tap(find.byKey(const ValueKey('acilis_basla')));
    await _bekle(tester, 3500);
    await tester.tap(find.byKey(const ValueKey('acilis_palet_blogu')));
    await _bekle(tester, 2500);
    await _cek(tester, '5b_mblock_acilis_blok_yerlesti');
    await tester.tap(find.byKey(const ValueKey('acilis_bayrak')));
    await _bekle(tester, 2300);
    await _cek(tester, '5c_mblock_acilis_led_yandi');
    await _kapat(tester);
  });

  group('mBlock adimi (tezgah onizlemede)', () {
    setUp(() => MBlockTezgahi.webviewsiz = true);
    tearDown(() => MBlockTezgahi.webviewsiz = false);

    Future<MBlockBlokAdimiState> adimiKur(
        WidgetTester tester, String id, {Size boy = const Size(390, 1400)}) async {
      final adim = _mblockAdimi(id);
      await _kur(
          tester,
          _adimSayfasi(MBlockBlokAdimi(
            step: adim,
            ayar: adim.mblock!,
            course: _mblock,
            isDark: false,
            onComplete: (_) {},
          )),
          boy: boy);
      final s = tester.state<MBlockBlokAdimiState>(find.byType(MBlockBlokAdimi));
      s.durumVer([mblockCozumProgrami(adim.mblock!.cozum, 'tr')]);
      await tester.pump();
      return s;
    }

    testWidgets('6 sanal Uno: buton basili, LED yanik', (tester) async {
      final s = await adimiKur(tester, 'm3_1_build1', boy: const Size(390, 1500));
      s.kontrolEt();
      await _bekle(tester, 300);
      final sahne = tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
      sahne.unoKarti.butonBasili = true;
      await _bekle(tester, 400);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      await _bekle(tester, 500);
      await _cek(tester, '6a_mblock_uno_buton_led');
      await _kapat(tester);
    });

    testWidgets('6b sanal Uno: PWM ve potansiyometre', (tester) async {
      final s = await adimiKur(tester, 'm3_2_build1', boy: const Size(390, 1500));
      final sahne = tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
      sahne.unoKarti.pot = 700;
      s.kontrolEt();
      await _bekle(tester, 600);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      await _bekle(tester, 500);
      await _cek(tester, '6b_mblock_uno_pwm');
      await _kapat(tester);
    });

    testWidgets('7 kukla sahnesi', (tester) async {
      final s = await adimiKur(tester, 'm0_2_build1');
      s.kontrolEt();
      await _bekle(tester, 1250);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      await _bekle(tester, 200);
      await _cek(tester, '7_mblock_kukla_sahnesi');
      await _kapat(tester);
    });

    testWidgets('8 ipucu ve cozumu goster', (tester) async {
      final s = await adimiKur(tester, 'm2_2_build1', boy: const Size(390, 1500));
      s.durumVer(const [
        [
          MBlockBlok(tip: 'dev_kart_acilis'),
          MBlockBlok(
              tip: 'dev_dijital_yaz', alanlar: {'PIN': '9', 'SEVIYE': 'HIGH'}),
        ]
      ]);
      await tester.pump();
      for (var i = 0; i < MBlockBlokAdimi.cozumEsigi; i++) {
        s.kontrolEt();
        await _bekle(tester, 150);
      }
      await _bekle(tester, 800);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
      await _bekle(tester, 500);
      await _cek(tester, '8_mblock_ipucu');
      await _kapat(tester);
    });
  });

  testWidgets('9 yedek tezgah (WebView yok)', (tester) async {
    final adim = _mblockAdimi('m2_2_build1');
    await _kur(
        tester,
        _adimSayfasi(MBlockBlokAdimi(
          step: adim,
          ayar: adim.mblock!,
          course: _mblock,
          isDark: false,
          onComplete: (_) {},
        )));
    await _bekle(tester, 400);
    for (final id in adim.correctSequence.take(3)) {
      final b = adim.availableBlocks.firstWhere((x) => x.id == id);
      final f = find.text(b.labelFor('tr')).last;
      await tester.ensureVisible(f);
      await tester.tap(f);
      await _bekle(tester, 200);
    }
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1000));
    await _bekle(tester, 500);
    await _cek(tester, '9_mblock_yedek_tezgah');
    await _kapat(tester);
  });
}
