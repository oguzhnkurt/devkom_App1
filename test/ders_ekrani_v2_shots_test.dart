@Tags(['shots'])
library;

// Ders ekrani v2: ilerleme cubugu, Devi arkadasi ve kurs ekrani
// onizleme kareleri — TEST DEGIL, ARAC.
//
//     flutter test --run-skipped --tags shots test/ders_ekrani_v2_shots_test.dart
//
// Cikti: /mnt/user-data/outputs/ders_ekrani_v2/*.png
// (DERS_V2_DIR ile degistirilebilir).
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
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/ders_ilerleme_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/utils/app_localizations.dart';
import 'package:devkom_app/widgets/mascot.dart';

final _dizin = Platform.environment['DERS_V2_DIR'] ??
    '/mnt/user-data/outputs/ders_ekrani_v2';
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

/// "Devam" etkinlesince basar; [kez] adim ilerler.
Future<void> _ilerle(WidgetTester tester, int kez, {String devam = 'Devam'}) async {
  for (var i = 0; i < kez; i++) {
    final dugme = find.widgetWithText(ElevatedButton, devam).last;
    for (var t = 0; t < 40; t++) {
      if (tester.widget<ElevatedButton>(dugme).onPressed != null) break;
      await tester.pump(const Duration(milliseconds: 250));
    }
    // Animasyon adiminin kendi ic Devam'i var; alttaki ancak o basilinca
    // aciliyor.
    if (tester.widget<ElevatedButton>(dugme).onPressed == null) {
      await tester.tap(find.text(devam).first);
      await _bekle(tester, 600);
    }
    await tester.tap(dugme);
    await _bekle(tester, 700);
  }
}

/// Ilerleme cubugunun cevresi kirpilarak.
Future<void> _cubukCek(WidgetTester tester, String ad) async {
  await tester.runAsync(() async {
    final b = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    const oran = 3.0;
    final img = await b.toImage(pixelRatio: oran);
    final kutu = tester.getRect(find.byKey(const ValueKey('ders_ilerleme_cubugu')));
    final ust = tester.getRect(find.byTooltip('Kapat'));
    final r = Rect.fromLTRB(0, ust.top - 4, img.width / oran, kutu.bottom + 10);
    final kayit = ui.PictureRecorder();
    final c = Canvas(kayit);
    c.drawImageRect(
        img,
        Rect.fromLTWH(r.left * oran, r.top * oran, r.width * oran, r.height * oran),
        Rect.fromLTWH(0, 0, r.width * oran, r.height * oran),
        Paint());
    final kirp = await kayit
        .endRecording()
        .toImage((r.width * oran).round(), (r.height * oran).round());
    final bytes = await kirp.toByteData(format: ui.ImageByteFormat.png);
    Directory(_dizin).createSync(recursive: true);
    File('$_dizin/$ad.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
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

  final scratch = CoursesData.byId('scratch')!;
  const promax = Size(430, 932);
  const se = Size(375, 667);

  testWidgets('ilerleme cubugu 1, 5, 10', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    await _kur(
        tester,
        InteractiveLessonScreen(
            course: scratch, lesson: _ders('scratch', 'scratch_1_3')),
        boy: promax,
        auth: AuthProvider());
    await _bekle(tester, 900);
    await _cubukCek(tester, '01_ilerleme_adim01');
    await _ilerle(tester, 4);
    await _bekle(tester, 600);
    await _cubukCek(tester, '02_ilerleme_adim05');
    // 10. adima kadar: blok kurma ve oyun adimlari Devam'i kilitliyor;
    // cubugu gormek icin dersi son adimdan aciyoruz.
    await _kapat(tester);
  });

  testWidgets('ilerleme cubugu son adim', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final l = _ders('scratch', 'scratch_1_3');
    final ters = InteractiveLesson(
      id: l.id,
      courseId: l.courseId,
      title: l.title,
      titleEn: l.titleEn,
      subtitle: l.subtitle,
      order: l.order,
      xpReward: l.xpReward,
      steps: [
        for (var i = 0; i < 9; i++) l.steps[i % 3 == 0 ? 1 : 2],
        l.steps.last,
      ],
    );
    await _kur(tester, InteractiveLessonScreen(course: scratch, lesson: ters),
        boy: promax, auth: AuthProvider());
    await _bekle(tester, 600);
    // Ayni adim kimlikleri tekrarlandigi icin her adim tek tek geciliyor.
    await _ilerle(tester, 9);
    await _bekle(tester, 1200);
    await _cubukCek(tester, '03_ilerleme_adim10');
    await _cek(tester, '04_son_adim_430');
    await _kapat(tester);
  });

  for (final (boy, ad) in [(promax, '430x932'), (se, '375x667')]) {
    testWidgets('coktan secmeli $ad', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': 'tr'});
      await _kur(
          tester,
          InteractiveLessonScreen(
              course: scratch, lesson: _ders('scratch', 'scratch_1_3')),
          boy: boy,
          auth: AuthProvider());
      await _bekle(tester, 900);
      await _ilerle(tester, 4);
      await _bekle(tester, 1500);
      expect(tester.takeException(), isNull);
      await _cek(tester, '10_soru_${ad}_once');
      await tester.tap(find.text('5 kere'));
      await _bekle(tester, 1600);
      expect(tester.takeException(), isNull);
      await _cek(tester, '11_soru_${ad}_dogru');
      await _kapat(tester);
    });
  }

  testWidgets('anlatim 430', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    await _kur(
        tester,
        InteractiveLessonScreen(
            course: scratch, lesson: _ders('scratch', 'scratch_1_3')),
        boy: promax,
        auth: AuthProvider());
    await _bekle(tester, 900);
    await _ilerle(tester, 1);
    await _bekle(tester, 5000);
    await _cek(tester, '20_anlatim_430x932');
    await _ilerle(tester, 1);
    await _bekle(tester, 5000);
    await _cek(tester, '21_anlatim2_430x932');
    await _kapat(tester);
  });

  testWidgets('anlatim kucuk ekran buyuk yazi', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    await _kur(
        tester,
        InteractiveLessonScreen(
            course: scratch, lesson: _ders('scratch', 'scratch_1_3')),
        boy: se,
        yazi: 1.3,
        auth: AuthProvider());
    await _bekle(tester, 900);
    await _ilerle(tester, 1);
    await _bekle(tester, 5000);
    expect(tester.takeException(), isNull);
    await _cek(tester, '22_anlatim_375x667_yazi130');
    await _kapat(tester);
  });

  testWidgets('kurs sayfasi su anki modulde', (tester) async {
    final biten = [
      for (final m in CourseModules.forCourse('scratch').take(5))
        ...m.lessons.map((l) => l.id),
    ];
    SharedPreferences.setMockInitialValues({
      'language_code': 'tr',
      DersIlerlemeDeposu.tamamlananAnahtari: biten,
    });
    final auth = AuthProvider();
    await _kur(tester, InteractiveCourseScreen(course: scratch),
        boy: promax, auth: auth);
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await _bekle(tester, 1200);
    await _cek(tester, '30_kurs_ekrani_simdiki_modul');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -260));
    await _bekle(tester, 900);
    await _cek(tester, '31_kurs_ekrani_harita');
    await tester.tap(find.byKey(const ValueKey('yol_tamam_3')));
    await _bekle(tester, 1200);
    await _cek(tester, '32_kurs_ekrani_secili_modul4');
    await _kapat(tester);
  });
}
