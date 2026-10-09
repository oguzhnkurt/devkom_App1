// KALDIGIN YERDEN DEVAM ET
//
// Sahip geri bildirimi (Ekim 2026): "Scratch kursuna basladim, 3 dersi
// bitirdim, ertesi gun girdim: 'Kaldigin yerden devam et' gorunmeli.
// Butona bastigimda 4'ten devam etmeli." Eskiden kurs sayfasindaki tus
// her zaman "Ogrenmeye Basla" yaziyor ve her zaman 1. dersi aciyordu;
// ilerleme de yalnizca sunucudan okundugu icin ag yokken sifir gorunuyordu.
//
// Bu dosya uc seyi kilitliyor:
//  1. Ilerleme cihazda (SharedPreferences) kalici; "ertesi gun" yeni bir
//     AuthProvider bile onu goruyor.
//  2. Siradaki ders = ilk BITMEMIS ders (1-3 bitti -> 4).
//  3. Tus etiketi durumdan geliyor ve "Ogrenmeye basla" hicbir yerde yok.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/screens/interactive_course_screen.dart';
import 'package:devkom_app/courses/screens/interactive_lesson_screen.dart';
import 'package:devkom_app/models/learner_profile.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/ders_ilerleme_deposu.dart';
import 'package:devkom_app/services/next_lesson_service.dart';
import 'package:devkom_app/services/sound_service.dart';

void main() {
  final scratch = CourseModules.allLessons('scratch');
  final ilkUc = scratch.take(3).map((l) => l.id).toList();

  setUpAll(() async {
    SoundService.configure(sound: false);
    // AuthProvider Supabase istemcisini kuruyor; gercek sunucuya
    // baglanmiyoruz, erisilemez adres assert'i gecmeye yetiyor.
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
  });

  group('cihazdaki kalici ilerleme', () {
    test('biten dersler yazilir ve "ertesi gun" yeniden okunur', () async {
      SharedPreferences.setMockInitialValues({});
      for (final id in ilkUc) {
        await DersIlerlemeDeposu.dersTamamlandi(id);
      }
      // Ayni ders ikinci kez yazilmaz.
      await DersIlerlemeDeposu.dersTamamlandi(ilkUc.first);

      // Uygulama kapanip acildi: bellekte hicbir sey yok, yalnizca
      // diskteki degerler var.
      final prefs = await SharedPreferences.getInstance();
      final disk = prefs.getStringList(DersIlerlemeDeposu.tamamlananAnahtari);
      expect(disk, ilkUc);
      SharedPreferences.setMockInitialValues(
          {DersIlerlemeDeposu.tamamlananAnahtari: disk!});

      expect(await DersIlerlemeDeposu.tamamlananlar(), ilkUc.toSet());
    });

    test('acilan kurs ve son kurs kaydedilir, cikista temizlenir', () async {
      SharedPreferences.setMockInitialValues({});
      await DersIlerlemeDeposu.kursAcildi('scratch');
      expect(await DersIlerlemeDeposu.baslananKurslar(), {'scratch'});
      expect(await DersIlerlemeDeposu.sonKurs(), 'scratch');

      await DersIlerlemeDeposu.dersTamamlandi(ilkUc.first);
      await DersIlerlemeDeposu.temizle();
      expect(await DersIlerlemeDeposu.tamamlananlar(), isEmpty);
      expect(await DersIlerlemeDeposu.baslananKurslar(), isEmpty);
      expect(await DersIlerlemeDeposu.sonKurs(), isNull);
    });

    test('AuthProvider oturum/ag olmadan da dersi kaydeder; yeni ornek okur',
        () async {
      SharedPreferences.setMockInitialValues({});
      final dun = AuthProvider();
      for (final id in ilkUc) {
        await dun.dersTamamlandi(id, 10);
      }
      expect(dun.tamamlananDersler, containsAll(ilkUc));

      // "Ertesi gun": yepyeni bir saglayici, sunucu yine erisilemez.
      final prefs = await SharedPreferences.getInstance();
      SharedPreferences.setMockInitialValues({
        DersIlerlemeDeposu.tamamlananAnahtari:
            prefs.getStringList(DersIlerlemeDeposu.tamamlananAnahtari)!,
      });
      final bugun = AuthProvider();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bugun.tamamlananDersler, containsAll(ilkUc));
    });
  });

  group('KursDevam.hesapla', () {
    test('1-3 bittiyse 4. dersi acar ve "devam" der', () {
      final d = KursDevam.hesapla('scratch', ilkUc.toSet())!;
      expect(d.durum, KursDurumu.devam);
      expect(d.index, 3);
      expect(d.lesson.id, scratch[3].id);
      expect(d.completedInCourse, 3);
    });

    test('sirayla degil: atlanan ders ilk bitmemis olarak doner', () {
      final d = KursDevam.hesapla(
          'scratch', {scratch[0].id, scratch[2].id})!;
      expect(d.lesson.id, scratch[1].id);
      expect(d.durum, KursDurumu.devam);
    });

    test('hic baslanmamis kurs ilk dersi acar', () {
      final d = KursDevam.hesapla('scratch', const {})!;
      expect(d.durum, KursDurumu.baslanmadi);
      expect(d.lesson.id, scratch.first.id);
    });

    test('ders bitmemis ama acilmissa yine "devam"', () {
      final d = KursDevam.hesapla('scratch', const {}, acildi: true)!;
      expect(d.durum, KursDurumu.devam);
      expect(d.lesson.id, scratch.first.id);
    });

    test('hepsi bittiyse tekrar icin ilk ders', () {
      final d = KursDevam.hesapla(
          'scratch', scratch.map((l) => l.id).toSet())!;
      expect(d.durum, KursDurumu.bitti);
      expect(d.lesson.id, scratch.first.id);
    });

    test('dersi olmayan kurs null', () {
      expect(KursDevam.hesapla('yok_boyle_kurs', const {}), isNull);
    });
  });

  group('tus etiketi', () {
    test('devam: dort dilde "kaldigin yerden devam et" ve kisa hali', () {
      final d = KursDevam.hesapla('scratch', ilkUc.toSet())!;
      expect(d.etiket('tr'), 'Kaldığın yerden devam et');
      expect(d.etiket('en'), 'Continue where you left off');
      expect(d.etiket('de'), 'Weiter, wo du aufgehört hast');
      expect(d.etiket('es'), 'Continúa donde lo dejaste');
      expect(d.etiket('tr', kisa: true), 'Devam et');
      expect(d.etiket('en', kisa: true), 'Continue');
    });

    test('bitti: tekrar et', () {
      final d = KursDevam.hesapla(
          'scratch', scratch.map((l) => l.id).toSet())!;
      expect(d.etiket('tr'), 'Baştan tekrar et');
      expect(d.etiket('tr', kisa: true), 'Tekrar et');
      expect(d.etiket('en', kisa: true), 'Review');
    });

    test('hicbir durumda "Ogrenmeye basla" yok', () {
      for (final d in [
        KursDevam.hesapla('scratch', const {})!,
        KursDevam.hesapla('scratch', ilkUc.toSet())!,
        KursDevam.hesapla('scratch', scratch.map((l) => l.id).toSet())!,
      ]) {
        for (final lang in ['tr', 'en', 'de', 'es']) {
          for (final kisa in [false, true]) {
            final e = d.etiket(lang, kisa: kisa).toLowerCase();
            expect(e.contains('öğrenmeye'), isFalse);
            expect(e.contains('start learning'), isFalse);
          }
        }
      }
    });

    test('kaynakta "Ogrenmeye Basla" kalmadi', () {
      final kaynak = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final f in kaynak) {
        final s = f.readAsStringSync().toLowerCase();
        expect(s.contains('öğrenmeye başla'), isFalse, reason: f.path);
        expect(s.contains("'start learning'"), isFalse, reason: f.path);
      }
    });
  });

  test('ana sayfa karti: devam tusu "Kaldigin yerden devam et" diyor', () {
    // Kart ekranin tamamini cizmeden sinanamiyor (Supabase, maskot,
    // oyun sandigi...); etiketin kaynakta durdugunu ve tamamlanan
    // derslerin cihazdaki kayittan da okundugunu kilitliyoruz.
    final src = File('lib/screens/unified_home_screen.dart').readAsStringSync();
    expect(src.contains("_t('Devam Et', 'Continue', 'Weiter', 'Continuar')"),
        isFalse);
    expect(
        src.contains("_t('Kaldığın yerden devam et', "
            "'Continue where you left off',"),
        isTrue);
    expect(src.contains('authProvider.tamamlananDersler'), isTrue);
    expect(src.contains('oncelikliKurs: authProvider.sonKurs'), isTrue);
  });

  group('ana sayfa: son kurs once', () {
    test('yolun disinda baslanan kursun siradaki dersi doner', () {
      // Yolu Python'la baslayan bir profil; cocuk katalogdan Scratch'e
      // baslamis ve 3 ders bitirmis.
      const profil = LearnerProfile(
          ageBand: LearnerAgeBand.age13plus, skillLevel: SkillLevel.someBlocks);
      final adim = NextLessonService.resolve(profil, ilkUc.toSet(),
          oncelikliKurs: 'scratch')!;
      expect(adim.course.id, 'scratch');
      expect(adim.lesson.id, scratch[3].id);
      expect(adim.indexInCourse, 4);
    });

    test('son kurs bittiyse yola donulur', () {
      final hepsi = scratch.map((l) => l.id).toSet();
      final adim = NextLessonService.resolve(const LearnerProfile(), hepsi,
          oncelikliKurs: 'scratch');
      expect(adim, isNotNull);
      expect(adim!.course.id, isNot('scratch'));
    });

    test('oncelik verilmezse eski davranis aynen', () {
      final a = NextLessonService.resolve(const LearnerProfile(), const {});
      final b = NextLessonService.resolve(const LearnerProfile(), const {},
          oncelikliKurs: null);
      expect(a!.lesson.id, b!.lesson.id);
    });
  });

  testWidgets(
      'kurs sayfasi: 3 ders bitmis -> "Kaldigin yerden devam et", '
      'tus 4. dersi acar', (tester) async {
    SharedPreferences.setMockInitialValues({
      'language_code': 'tr',
      DersIlerlemeDeposu.tamamlananAnahtari: ilkUc,
    });
    final settings = SettingsProvider();
    await settings.setLocale(const Locale('tr'));
    final auth = AuthProvider();

    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ],
      child: MaterialApp(
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
        home: InteractiveCourseScreen(course: CoursesData.byId('scratch')!),
      ),
    ));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Kaldığın yerden devam et'), findsOneWidget);
    expect(find.text('Öğrenmeye Başla'), findsNothing);
    expect(find.text('3 / ${scratch.length}'), findsOneWidget);

    await tester.tap(find.text('Kaldığın yerden devam et'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final acilan = tester.widget<InteractiveLessonScreen>(
        find.byType(InteractiveLessonScreen));
    expect(acilan.lesson.id, scratch[3].id);
  });
}
