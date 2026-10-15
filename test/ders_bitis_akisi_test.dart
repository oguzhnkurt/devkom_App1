// DERS BITIS AKISI: siradaki ders, seri, modul kutlamasi, yol haritasi.
//
// Bu dosya kilitliyor:
//  * Ders bitis penceresinde "Siradaki ders: <baslik>" dugmesi var ve o
//    dersi DOGRUDAN aciyor; "Listeye don" ikincil.
//  * Seri (ust uste ders gunleri) dogru hesaplaniyor; pencerede gorunuyor.
//  * Modulun butun dersleri bitince modul kutlamasi BIR KEZ cikiyor.
//  * Yol haritasi: bitmis / su anki / sirada dugumleri.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/interactive_lesson_screen.dart';
import 'package:devkom_app/courses/screens/widgets/kurs_yol_haritasi.dart';
import 'package:devkom_app/courses/tanitim/modul_kutlamasi.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/ders_ilerleme_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';

final _scratch = CoursesData.byId('scratch')!;
final _moduller = CourseModules.forCourse('scratch');
final _dersler = CourseModules.allLessons('scratch');

/// Gercek bir dersin KIMLIGIYLE, tek adimlik kisa bir ders: siradaki
/// ders ve modul hesabi kimlikten yapiliyor.
InteractiveLesson _kisa(InteractiveLesson asil) => InteractiveLesson(
      id: asil.id,
      courseId: 'scratch',
      title: asil.title,
      subtitle: 'Deneme',
      order: asil.order,
      xpReward: 10,
      steps: const [
        ExplanationStep(id: 'kisa_1', title: 'Bir', content: 'Tek paragraf.'),
      ],
    );

Future<SettingsProvider> _ayarlar() async {
  final s = SettingsProvider();
  await s.setLocale(const Locale('tr'));
  return s;
}

Widget _kabuk(SettingsProvider s, AuthProvider a, Widget child) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: s),
        ChangeNotifierProvider<AuthProvider>.value(value: a),
      ],
      child: MaterialApp(home: child),
    );

Future<void> _bekle(WidgetTester t, [int ms = 700]) async {
  for (var i = 0; i < ms; i += 100) {
    await t.pump(const Duration(milliseconds: 100));
  }
  await t.pump();
}

Future<void> _dersiBitir(WidgetTester tester) async {
  await _bekle(tester);
  await tester.tap(find.text('Tamamla'));
  await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)));
  await _bekle(tester, 1500);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
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

  group('seri', () {
    test('ust uste gunler; ara verince bastan', () {
      final bugun = DateTime(2026, 10, 15);
      String g(int geri) =>
          DersSerisi.gunAnahtari(DateTime(2026, 10, 15 - geri));
      expect(DersSerisi.hesapla([g(0), g(1), g(2)], bugun), 3);
      expect(DersSerisi.hesapla([g(0), g(2), g(3)], bugun), 1);
      expect(DersSerisi.hesapla([g(1), g(2)], bugun), 0,
          reason: 'Bugun ders bitmediyse bugunun serisi yok.');
      // Ay donumu.
      expect(
          DersSerisi.hesapla(['2026-09-30', '2026-10-01'], DateTime(2026, 10, 1)),
          2);
    });

    test('bugunuIsle ayni gunu iki kez yazmiyor', () async {
      SharedPreferences.setMockInitialValues({
        DersSerisi.anahtar: ['2026-10-13', '2026-10-14'],
      });
      expect(await DersSerisi.bugunuIsle(DateTime(2026, 10, 15, 9)), 3);
      expect(await DersSerisi.bugunuIsle(DateTime(2026, 10, 15, 18)), 3);
      final p = await SharedPreferences.getInstance();
      expect(p.getStringList(DersSerisi.anahtar)!.length, 3);
    });
  });

  testWidgets('pencere: Siradaki ders dugmesi o dersi aciyor; seri ve XP',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final s = await _ayarlar();
    final auth = AuthProvider();

    await tester.pumpWidget(_kabuk(s, auth,
        InteractiveLessonScreen(lesson: _kisa(_dersler[0]), course: _scratch)));
    await _dersiBitir(tester);

    expect(find.text('TEBRİKLER!'), findsOneWidget);
    expect(find.byKey(const ValueKey('ders_xp')), findsOneWidget);
    expect(find.byKey(const ValueKey('ders_serisi')), findsOneWidget);
    expect(find.text('Serin başladı!'), findsOneWidget);
    expect(find.byKey(const ValueKey('ders_listeye_don')), findsOneWidget);
    final sonraki = find.byKey(const ValueKey('ders_sonraki'));
    expect(sonraki, findsOneWidget);
    expect(
        find.descendant(
            of: sonraki, matching: find.text(_dersler[1].titleFor('tr'))),
        findsOneWidget);

    await tester.tap(sonraki);
    await _bekle(tester, 900);
    final ekran = tester.widget<InteractiveLessonScreen>(
        find.byType(InteractiveLessonScreen));
    expect(ekran.lesson.id, _dersler[1].id);
    expect(find.text('TEBRİKLER!'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await _bekle(tester, 3000);
  });

  testWidgets('modul kutlamasi: modulun son dersi bitince, bir kez',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final m1 = _moduller[0].lessons;
    // 1. modulun son dersi DISINDA hepsi bitmis.
    SharedPreferences.setMockInitialValues({
      'language_code': 'tr',
      DersIlerlemeDeposu.tamamlananAnahtari: [
        for (final l in m1.take(m1.length - 1)) l.id
      ],
    });
    final s = await _ayarlar();
    final auth = AuthProvider();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));

    await tester.pumpWidget(_kabuk(
        s, auth, InteractiveLessonScreen(lesson: _kisa(m1.last), course: _scratch)));
    await _dersiBitir(tester);
    expect(find.text('TEBRİKLER!'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('ders_sonraki')));
    await _bekle(tester, 1200);
    expect(find.byType(ModulKutlamaEkrani), findsOneWidget);
    expect(find.text('Modül 1 tamamlandı!'), findsOneWidget);
    expect(find.text('1/${_moduller.length} modül'), findsOneWidget);
    expect(find.byKey(const ValueKey('yol_tamam_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('yol_simdiki_1')), findsOneWidget);
    expect(find.textContaining(_moduller[1].titleFor('tr')), findsWidgets);

    // Isaret yazildi: ikinci kez yok.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    expect(
        await ModulKutlamaEkrani.gosterilmeli(
            'scratch', m1.last.id, auth.tamamlananDersler),
        isNull);

    // Kutlamadan siradaki derse.
    await tester.tap(find.byKey(const ValueKey('modul_sonraki_ders')));
    await _bekle(tester, 900);
    expect(find.byType(ModulKutlamaEkrani), findsNothing);
    expect(
        tester
            .widget<InteractiveLessonScreen>(find.byType(InteractiveLessonScreen))
            .lesson
            .id,
        _moduller[1].lessons.first.id);

    await tester.pumpWidget(const SizedBox());
    await _bekle(tester, 3000);
  });

  test('modul kutlamasi kosullari', () async {
    SharedPreferences.setMockInitialValues({});
    final m1 = _moduller[0].lessons;
    final biten = {for (final l in m1) l.id};
    expect(await ModulKutlamaEkrani.gosterilmeli('scratch', m1.last.id, biten),
        0);
    // Modulun bir dersi eksik: yok.
    expect(
        await ModulKutlamaEkrani.gosterilmeli(
            'scratch', m1.last.id, biten.difference({m1.first.id})),
        isNull);
    // Kurs bitti: kapanis toreninin ani, modul kutlamasi yok.
    expect(
        await ModulKutlamaEkrani.gosterilmeli(
            'scratch', _dersler.last.id, {for (final l in _dersler) l.id}),
        isNull);
    await ModulKutlamaDeposu.isaretle('scratch', 0);
    expect(await ModulKutlamaEkrani.gosterilmeli('scratch', m1.last.id, biten),
        isNull);
  });

  group('yol haritasi', () {
    test('durumlar: bitmis, su anki (ilk bitmemis), sirada', () {
      final biten = {
        for (final l in _moduller[0].lessons) l.id,
        for (final l in _moduller[2].lessons) l.id, // sirasiz bitmis
      };
      final d = KursYolHaritasi.durumlar(_moduller, biten);
      expect(d[0], ModulDurumu.tamam);
      expect(d[1], ModulDurumu.simdiki);
      expect(d[2], ModulDurumu.tamam);
      expect(d.skip(3), everyElement(ModulDurumu.sirada));
      expect(KursYolHaritasi.bitenModul(_moduller, biten), 2);
      expect(KursYolHaritasi.durumlar(_moduller, {}).first,
          ModulDurumu.simdiki);
    });

    testWidgets('dugumler ve dokunma; hareket azaltilmisken de',
        (tester) async {
      for (final azalt in [false, true]) {
        int? secilen;
        await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
                size: const Size(390, 844), disableAnimations: azalt),
            child: Scaffold(
              body: KursYolHaritasi(
                moduller: _moduller,
                biten: {for (final l in _moduller[0].lessons) l.id},
                renk: _scratch.primaryColor,
                renk2: _scratch.secondaryColor,
                lang: 'tr',
                onSec: (i) => secilen = i,
              ),
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byKey(const ValueKey('yol_tamam_0')), findsOneWidget);
        expect(find.byKey(const ValueKey('yol_simdiki_1')), findsOneWidget);
        expect(find.byKey(const ValueKey('yol_sirada_2')), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('yol_simdiki_1')));
        expect(secilen, 1);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });
  });
}
