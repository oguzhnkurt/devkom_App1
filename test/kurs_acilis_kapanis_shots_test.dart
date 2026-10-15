@Tags(['shots'])
library;

// Scratch kursunun acilis/kapanis sahnelerinden onizleme kareleri.
//
//     flutter test --run-skipped --tags shots test/kurs_acilis_kapanis_shots_test.dart
//
// Cikti: /mnt/user-data/outputs/scratch_acilis_kapanis/*.png
// (KURS_SHOTS_DIR ile degistirilebilir).
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
import 'package:devkom_app/courses/screens/interactive_lesson_screen.dart';
import 'package:devkom_app/courses/tanitim/kurs_acilis_ekrani.dart';
import 'package:devkom_app/courses/tanitim/kurs_kapanis_ekrani.dart';
import 'package:devkom_app/courses/tanitim/kurs_tanitimi.dart';
import 'package:devkom_app/courses/tanitim/sertifika_paylasimi.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/mascot.dart';

final _dizin = Platform.environment['KURS_SHOTS_DIR'] ??
    '/mnt/user-data/outputs/scratch_acilis_kapanis';
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

Future<void> _kur(WidgetTester tester, Widget home,
    {String lang = 'tr', Size boy = const Size(390, 844), AuthProvider? auth}) async {
  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  if (auth == null) {
    SharedPreferences.setMockInitialValues({'language_code': lang});
  }
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
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(useMaterial3: true, fontFamily: 'Nunito'),
      // Alt sayfa ve diyaloglar da kareye girsin: sinir Navigator'in ustunde.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await _fontlar();
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
  });

  final scratch = CoursesData.byId('scratch')!;
  final hepsi = CourseModules.allLessons('scratch').map((l) => l.id).toSet();

  KursAcilisEkraniState durum(WidgetTester t) =>
      t.state<KursAcilisEkraniState>(find.byType(KursAcilisEkrani));

  for (final boy in const [Size(390, 844), Size(320, 568)]) {
    final ek = boy.width == 320 ? '_se' : '';
    testWidgets('acilis kareleri$ek', (tester) async {
      await _kur(
          tester,
          KursAcilisEkrani(
              course: scratch, tanitim: KursTanitimi.forCourse('scratch')!),
          boy: boy);
      await _bekle(tester, 4500);
      await _cek(tester, '1_acilis_selam$ek');

      await tester.tap(find.byKey(const ValueKey('acilis_basla')));
      await _bekle(tester, 3500);
      await _cek(tester, '2_acilis_blogu_yerlestir$ek');

      await tester.tap(find.byKey(const ValueKey('acilis_palet_blogu')));
      await _bekle(tester, 3000);
      await _cek(tester, '3_acilis_blok_yerlesti$ek');

      durum(tester).calistir();
      await _bekle(tester, 1750);
      await _cek(tester, '4_acilis_kutlama$ek');

      await _bekle(tester, 3500);
      await _cek(tester, '5_acilis_hazirsin$ek');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
    });
  }

  testWidgets('ilk ders acilisi', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final auth = AuthProvider();
    await _kur(
        tester,
        InteractiveLessonScreen(
            course: scratch,
            lesson: CourseModules.allLessons('scratch').first),
        auth: auth);
    await _bekle(tester, 1500);
    await _cek(tester, '6_ilk_ders_acilisi');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('kapanis kareleri', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _kur(
        tester,
        KursKapanisEkrani(
            course: scratch,
            tamamlanan: hepsi,
            ad: 'Elif',
            tarih: DateTime(2026, 10, 15)));
    await _bekle(tester, 700);
    await _cek(tester, '7_kapanis_kutlama');

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -560));
    await _bekle(tester, 800);
    await _cek(tester, '8_kapanis_sertifika');

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await _bekle(tester, 800);
    await _cek(tester, '9_kapanis_siradaki_kurs');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('sertifika (paylasilan PNG)', (tester) async {
    await _kur(
        tester,
        Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SizedBox(
              width: 380,
              child: KursSertifikasi(
                course: scratch,
                ad: 'Elif',
                tarih: DateTime(2026, 10, 15),
                dersSayisi: hepsi.length,
                lang: 'tr',
              ),
            ),
          ),
        ),
        boy: const Size(400, 290));
    await _cek(tester, '10_sertifika', oran: 3);
  });

  testWidgets('sertifika secenekleri', (tester) async {
    await _kur(
        tester,
        KursKapanisEkrani(
            course: scratch,
            tamamlanan: hepsi,
            ad: 'Elif',
            tarih: DateTime(2026, 10, 15),
            tekrar: true));
    await _bekle(tester, 700);
    final d = find.byKey(const ValueKey('kapanis_paylas'));
    await tester.scrollUntilVisible(d, 150,
        scrollable: find.byType(Scrollable).first);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await _bekle(tester, 600);
    await tester.tap(d);
    await _bekle(tester, 900);
    await _cek(tester, '11_sertifika_secenekleri');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('paylasim gorselleri (Instagram 4:5, TikTok 9:16)',
      (tester) async {
    final v = SertifikaVerisi(
      course: scratch,
      ad: 'Elif',
      tarih: DateTime(2026, 10, 15),
      dersSayisi: hepsi.length,
      lang: 'tr',
    );
    await tester.runAsync(() async {
      Directory(_dizin).createSync(recursive: true);
      File('$_dizin/12_paylasim_instagram_4x5.png').writeAsBytesSync(
          await SertifikaCizici.paylasimPng(v, PaylasimBicimi.instagram));
      File('$_dizin/13_paylasim_tiktok_9x16.png').writeAsBytesSync(
          await SertifikaCizici.paylasimPng(v, PaylasimBicimi.tiktok));
    });
  });
}
