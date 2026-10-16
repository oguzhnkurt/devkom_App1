// mBLOCK DERS YOGUNLUGU — gercek iPhone'da (430x932, durum cubugu ve
// ev cizgisi) ilk mBlock dersinin anlatim adimlari asagi kaydiriliyor,
// blok adiminda sahne + tezgah ekrana sigmiyordu.
//
// Kilitlenenler:
//  * 1. dersin tanitim ve anlatim adimlari kaydirmadan okunuyor.
//  * Ilk blok adiminda (m0_2_build1) sahne VE tezgah ekranda (alt
//    cubugun ustunde); sayfa en fazla bir dugme boyu kayiyor.
//  * Anlatim govdesi 16 pt / 1.45 (17 / 1.55 telefonda buyuktu).
import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:devkom_app/courses/screens/widgets/mblock_tezgahi.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';

final _mblock = CoursesData.byId('mblock')!;
const _boy = Size(430, 932);
const _ust = 59.0, _alt = 34.0;

Future<void> _ac(WidgetTester tester, LessonStep adim) async {
  tester.view.physicalSize = _boy * 3;
  tester.view.devicePixelRatio = 3;
  tester.view.padding =
      const FakeViewPadding(top: _ust * 3, bottom: _alt * 3);
  addTearDown(tester.view.reset);
  final ayar = SettingsProvider();
  await ayar.setLocale(const Locale('tr'));
  final ders = CourseModules.allLessons('mblock').first;
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: ayar),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: 'Nunito'),
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
      home: InteractiveLessonScreen(
          course: _mblock,
          lesson: InteractiveLesson(
              id: ders.id,
              courseId: 'mblock',
              title: ders.title,
              subtitle: ders.subtitle,
              order: 1,
              steps: [adim])),
    ),
  ));
  // Anlatim paragraflari sirayla geliyor: hepsi gelsin.
  for (var i = 0; i < 90; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

double _kaydirma(WidgetTester tester) {
  var m = 0.0;
  for (final e in find.byType(Scrollable).evaluate()) {
    final p = ((e as StatefulElement).state as ScrollableState).position;
    if (p.axis == Axis.vertical && p.maxScrollExtent > m) {
      m = p.maxScrollExtent;
    }
  }
  return m;
}

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}

/// Uygulamanin yazi tipleri (test yazi tipi cok genis; olcum gercekci
/// olsun).
Future<void> _fontlar() async {
  ByteData oku(String yol) =>
      File(yol).readAsBytesSync().buffer.asByteData();
  final n = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    n.addFont(Future.value(oku('assets/fonts/Nunito-$w.ttf')));
  }
  await n.load();
  await (FontLoader('Baloo2')
        ..addFont(Future.value(oku('assets/fonts/Baloo2-ExtraBold.ttf'))))
      .load();
}

void main() {
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
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
  });

  final ders = CourseModules.allLessons('mblock').first;
  // Gorunur alanin alti: alt cubuk (Tamamla) ~90 pt + ev cizgisi.
  const gorunurAlt = 932 - _alt - 70;

  testWidgets('tanitim kaydirmadan okunuyor (onceden 108 pt)', (tester) async {
    await _ac(tester, ders.steps.whereType<IntroStep>().first);
    expect(tester.takeException(), isNull);
    expect(_kaydirma(tester), lessThan(1));
    await _kapat(tester);
  });

  testWidgets('ekranda dort bolge: anlatim karti ekranda (onceden 174 pt '
      'kayiyordu)', (tester) async {
    await _ac(tester, ders.steps.firstWhere((s) => s.id == 'm0_1_exp1'));
    expect(tester.takeException(), isNull);
    final kart = tester.getRect(find.byKey(const ValueKey('anlatim_karti')));
    expect(kart.bottom, lessThanOrEqualTo(gorunurAlt));
    await _kapat(tester);
  });

  testWidgets('blok sekilleri: sayfa kisaldi (onceden 478 pt)',
      (tester) async {
    await _ac(tester, ders.steps.firstWhere((s) => s.id == 'm0_1_exp2'));
    expect(tester.takeException(), isNull);
    expect(_kaydirma(tester), lessThan(300));
    await _kapat(tester);
  });

  testWidgets('anlatim govdesi 16 / 1.45', (tester) async {
    final exp = ders.steps.whereType<ExplanationStep>().first;
    await _ac(tester, exp);
    final govde = tester
        .widgetList<Text>(find.byType(Text))
        .where((t) => t.data != null && t.data!.startsWith('mBlock ilk'))
        .first;
    expect(govde.style!.fontSize, 16);
    expect(govde.style!.height, 1.45);
    await _kapat(tester);
  });

  testWidgets('ilk blok adimi: sahne ve tezgah ekranda', (tester) async {
    MBlockTezgahi.webviewsiz = true;
    addTearDown(() => MBlockTezgahi.webviewsiz = false);
    final build = CourseModules.allLessons('mblock')
        .expand((l) => l.steps)
        .firstWhere((s) => s.id == 'm0_2_build1');
    await _ac(tester, build);
    expect(tester.takeException(), isNull);
    final sahne = tester.getRect(find.byType(MBlockSahnesi));
    final tezgah = tester.getRect(find.byType(MBlockTezgahi));
    expect(sahne.top, greaterThan(_ust));
    expect(tezgah.bottom, lessThanOrEqualTo(gorunurAlt),
        reason: 'tezgah alt cubugun altinda kaliyor');
    expect(_kaydirma(tester), lessThan(120));
    await _kapat(tester);
  });
}
