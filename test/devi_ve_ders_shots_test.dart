@Tags(['shots'])
library;

// Devi'nin tanismasi, ilk gorev, Ayarlar > Maskotunun adi ve ders
// anlatim ekranlarindan onizleme kareleri — TEST DEGIL, ARAC.
//
//     flutter test --run-skipped --tags shots test/devi_ve_ders_shots_test.dart
//
// Cikti: /mnt/user-data/outputs/devi_ve_ders_gorunumu/*.png
// (DEVI_DERS_DIR ile degistirilebilir). DEVI_DERS_ONEK verilirse ders
// kareleri o onekle kaydediliyor (orn. "once_": degisiklikten onceki
// hali).
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
import 'package:devkom_app/courses/screens/interactive_lesson_screen.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/auth/devi_tanisma.dart';
import 'package:devkom_app/screens/auth/onboarding_flow_screen.dart';
import 'package:devkom_app/screens/settings/settings_screen.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/utils/app_localizations.dart';
import 'package:devkom_app/widgets/mascot.dart';

final _dizin = Platform.environment['DEVI_DERS_DIR'] ??
    '/mnt/user-data/outputs/devi_ve_ders_gorunumu';
final _onek = Platform.environment['DEVI_DERS_ONEK'] ?? '';
final _yalnizDers = _onek.isNotEmpty;
final _key = GlobalKey();

Future<void> _fontlar() async {
  final n = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    n.addFont(Future.value(File('assets/fonts/Nunito-$w.ttf')
        .readAsBytesSync()
        .buffer
        .asByteData()));
  }
  await n.load();
  final b = FontLoader('Baloo2')
    ..addFont(Future.value(File('assets/fonts/Baloo2-ExtraBold.ttf')
        .readAsBytesSync()
        .buffer
        .asByteData()));
  await b.load();
  // iOS'ta kod yazisi Menlo; burada yerine DejaVu Sans Mono.
  final mono = File('/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf');
  if (mono.existsSync()) {
    await (FontLoader('Menlo')
          ..addFont(Future.value(mono.readAsBytesSync().buffer.asByteData())))
        .load();
  }
  final emoji = File('/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf');
  if (emoji.existsSync()) {
    await (FontLoader('EmojiFallback')
          ..addFont(Future.value(emoji.readAsBytesSync().buffer.asByteData())))
        .load();
  }
  final root = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.path;
  final ikon = File(
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (ikon.existsSync()) {
    await (FontLoader('MaterialIcons')
          ..addFont(Future.value(ikon.readAsBytesSync().buffer.asByteData())))
        .load();
  }
}

Future<SettingsProvider> _kur(WidgetTester tester, Widget home,
    {String lang = 'tr',
    Size boy = const Size(390, 844),
    double yazi = 1.0,
    AuthProvider? auth}) async {
  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // Testte golgeler varsayilan olarak siyah cerceve gibi ciziliyor.
  debugDisableShadows = false;
  final ayar = SettingsProvider();
  await ayar.setLocale(Locale(lang));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: ayar),
      if (auth != null) ChangeNotifierProvider<AuthProvider>.value(value: auth),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(lang),
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('es')
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        fontFamilyFallback: const ['EmojiFallback'],
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(yazi)),
        child: RepaintBoundary(key: _key, child: child),
      ),
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
  return ayar;
}

Future<void> _bekle(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _cek(WidgetTester tester, String ad, {double oran = 2.5}) async {
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
  debugDisableShadows = true;
}

InteractiveLesson _ders(String kurs, String id) =>
    CourseModules.allLessons(kurs).firstWhere((l) => l.id == id);

/// Dersi [adimId] adimindan acar (o adim basa alinir, gerisi sirayla).
InteractiveLesson _adimdan(InteractiveLesson l, String adimId) {
  final i = l.steps.indexWhere((s) => s.id == adimId);
  return InteractiveLesson(
    id: l.id,
    courseId: l.courseId,
    title: l.title,
    subtitle: l.subtitle,
    titleEn: l.titleEn,
    titleDe: l.titleDe,
    titleEs: l.titleEs,
    order: l.order,
    xpReward: l.xpReward,
    steps: [l.steps[i], ...l.steps.where((s) => s.id != adimId)],
  );
}

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

  // ---------------------------------------------------------------- Devi
  for (final lang in ['tr', 'en']) {
    testWidgets('devi tanisma $lang', (tester) async {
      if (_yalnizDers) return;
      SharedPreferences.setMockInitialValues({'language_code': lang});
      await _kur(tester, DeviTanisma(lang: lang, onDone: () {}), lang: lang);
      await _bekle(tester, 3200);
      await _cek(tester, '01_devi_tanisma_${lang}_merhaba');
      // Ikinci sayfa, gozler kapali (kirpma ani).
      await tester.tap(find.byKey(const ValueKey('devi_tanisma_devam')));
      await _bekle(tester, 3600);
      Mascot.debugGozKapali = 1;
      await tester.pump(const Duration(milliseconds: 16));
      await _cek(tester, '02_devi_tanisma_${lang}_goz_kirpma');
      Mascot.debugGozKapali = null;
      await _kapat(tester);
    });
  }

  testWidgets('devi goz kirpma yakin', (tester) async {
    if (_yalnizDers) return;
    for (final k in [0.0, 0.5, 1.0]) {
      Mascot.debugGozKapali = k;
      await _kur(
          tester,
          const Scaffold(
            backgroundColor: Color(0xFF4A63E0),
            body: Center(
                child: Mascot(size: 300, blink: true, showShadow: false)),
          ),
          boy: const Size(360, 360));
      await tester.pump(const Duration(milliseconds: 16));
      await _cek(tester, '03_devi_goz_${(k * 100).round()}', oran: 2);
      await _kapat(tester);
    }
    Mascot.debugGozKapali = null;
  });

  for (final lang in ['en', 'tr']) {
    testWidgets('ilk gorev $lang', (tester) async {
      if (_yalnizDers) return;
      SharedPreferences.setMockInitialValues({'language_code': lang});
      await _kur(tester, const OnboardingFlowScreen(), lang: lang);
      await tester.tap(find.byKey(const ValueKey('devi_tanisma_atla')));
      await _bekle(tester, 2500);
      await _cek(tester, '04_ilk_gorev_$lang');
      await _kapat(tester);
    });
  }

  // ------------------------------------------------------------ Ayarlar
  for (final lang in ['tr', 'en']) {
    testWidgets('ayarlar maskot adi $lang', (tester) async {
      if (_yalnizDers) return;
      SharedPreferences.setMockInitialValues({'language_code': lang});
      await _kur(tester, const SettingsScreen(), lang: lang);
      final satir = find.byKey(const ValueKey('ayarlar_maskot_adi'));
      await tester.scrollUntilVisible(satir, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
      await _bekle(tester, 600);
      await _cek(tester, '05_ayarlar_maskot_adi_$lang');
      await tester.tap(satir);
      await _bekle(tester, 900);
      await tester.enterText(
          find.byKey(const ValueKey('maskot_adi_alani')), 'Robi');
      await _bekle(tester, 300);
      await _cek(tester, '06_ayarlar_maskot_adi_pencere_$lang');
      await _kapat(tester);
    });
  }

  // -------------------------------------------------------------- Dersler
  final scratch = CoursesData.byId('scratch')!;
  final python = CoursesData.byId('python')!;

  for (final lang in ['en', 'tr']) {
    testWidgets('scratch problem adimi $lang', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': lang});
      final auth = AuthProvider();
      await _kur(
          tester,
          InteractiveLessonScreen(
              course: scratch, lesson: _ders('scratch', 'scratch_1_3')),
          lang: lang,
          auth: auth);
      await _bekle(tester, 800);
      await tester.tap(find.text(lang == 'tr' ? 'Devam' : 'Continue'));
      await _bekle(tester, 2500);
      await _cek(tester, '${_onek}10_ders_scratch_problem_$lang');
      await _kapat(tester);
    });
  }

  testWidgets('python kodlu anlatim', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'en'});
    final auth = AuthProvider();
    await _kur(
        tester,
        InteractiveLessonScreen(
            course: python,
            lesson: _adimdan(_ders('python', 'python_1_1'), 'p1_1_exp3')),
        lang: 'en',
        auth: auth);
    await _bekle(tester, 5000);
    await _cek(tester, '${_onek}11_ders_python_kod_en');
    await _kapat(tester);
  });

  testWidgets('python ipucu kutusu', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final auth = AuthProvider();
    await _kur(
        tester,
        InteractiveLessonScreen(
            course: python,
            lesson: _adimdan(_ders('python', 'python_1_1'), 'p1_1_exp1')),
        lang: 'tr',
        auth: auth);
    await _bekle(tester, 3000);
    await _cek(tester, '${_onek}12_ders_python_ipucu_tr');
    await _kapat(tester);
  });

  testWidgets('kucuk ekran buyuk yazi', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'en'});
    final auth = AuthProvider();
    await _kur(
        tester,
        InteractiveLessonScreen(
            course: scratch, lesson: _ders('scratch', 'scratch_1_3')),
        lang: 'en',
        boy: const Size(375, 667),
        yazi: 1.3,
        auth: auth);
    await _bekle(tester, 800);
    await tester.tap(find.text('Continue'));
    await _bekle(tester, 2500);
    expect(tester.takeException(), isNull);
    await _cek(tester, '${_onek}13_ders_kucuk_ekran_yazi130_en');
    await _kapat(tester);
  });
}
