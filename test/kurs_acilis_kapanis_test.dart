// SCRATCH KURSUNUN ACILISI VE KAPANISI
//
// Acilis: "kursa basla"ya ilk basista Devi'li kisa sahne + tek blokluk
// mini etkinlik; atlanabilir, bir kez gosterilir, sonra 1. ders.
// Kapanis: son ders bitince konfeti, gercek veriden ozet, adli sertifika,
// rozet ve siradaki kurs karti; bir kez gosterilir.
//
// Bu dosya kilitliyor:
//  * Atla calisiyor ve derse goturuyor; isaret kaydediliyor.
//  * Blogu yerine koymak (dokunarak / surukleyerek) + yesil bayrak sahneyi
//    bitiriyor; ikinci kez gosterilmiyor.
//  * Ozet sayilari ders verisinden; sertifikada cocugun adi var; siradaki
//    kurs karti mBlock'u aciyor.
//  * Dort dilde metin; 320x568 ve 430x932'de tasma yok.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/course_model.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/interactive_course_screen.dart';
import 'package:devkom_app/courses/screens/interactive_lesson_screen.dart';
import 'package:devkom_app/courses/tanitim/kurs_acilis_ekrani.dart';
import 'package:devkom_app/courses/tanitim/kurs_kapanis_ekrani.dart';
import 'package:devkom_app/courses/tanitim/kurs_tanitimi.dart';
import 'package:devkom_app/courses/tanitim/tanitim_parcalari.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/ders_ilerleme_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';

final Course scratch = CoursesData.byId('scratch')!;
final dersler = CourseModules.allLessons('scratch');
final hepsi = dersler.map((l) => l.id).toSet();

Future<SettingsProvider> _ayarlar(String lang) async {
  final s = SettingsProvider();
  await s.setLocale(Locale(lang));
  return s;
}

Widget _uygulama(
  Widget home, {
  required SettingsProvider ayarlar,
  AuthProvider? auth,
  String lang = 'tr',
  bool azalt = false,
}) {
  final app = MaterialApp(
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
    builder: azalt
        ? (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            )
        : null,
    home: home,
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: ayarlar),
      if (auth != null) ChangeNotifierProvider<AuthProvider>.value(value: auth),
    ],
    child: app,
  );
}

void _ekran(WidgetTester tester, Size s) {
  tester.view.physicalSize = Size(s.width * 3, s.height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Acilisi bir dugmeden acan ev sahibi; sonucu [sonuclar]'a yazar.
class _Ev extends StatelessWidget {
  const _Ev({required this.sonuclar, this.tekrar = false});
  final List<bool> sonuclar;
  final bool tekrar;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async => sonuclar.add(
                await KursAcilisEkrani.ac(context, scratch, tekrar: tekrar)),
            child: const Text('ac'),
          ),
        ),
      );
}

Future<void> _bekle(WidgetTester tester, [int ms = 400]) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(Duration(milliseconds: ms ~/ 6 + 1));
  }
}

Future<void> _acilisiAc(WidgetTester tester) async {
  await tester.tap(find.text('ac'));
  await _bekle(tester, 600);
  expect(find.byType(KursAcilisEkrani), findsOneWidget);
}

KursAcilisEkraniState _durum(WidgetTester tester) =>
    tester.state<KursAcilisEkraniState>(find.byType(KursAcilisEkrani));

void main() {
  setUpAll(() async {
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
  });

  group('acilis sahnesi', () {
    testWidgets('Atla: derse goturur (true) ve isaret kaydedilir',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      _ekran(tester, const Size(390, 844));
      final sonuc = <bool>[];
      await tester.pumpWidget(_uygulama(_Ev(sonuclar: sonuc),
          ayarlar: await _ayarlar('tr')));
      await _acilisiAc(tester);

      await tester.tap(find.text('Atla'));
      await _bekle(tester);
      expect(find.byType(KursAcilisEkrani), findsNothing);
      expect(sonuc, [true]);
      expect(await KursTanitimDeposu.acilisGoruldu('scratch'), isTrue);
    });

    testWidgets('blok dokunarak yerlesir, bayrak kosar, Hazirsin -> derse',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      _ekran(tester, const Size(390, 844));
      final sonuc = <bool>[];
      await tester.pumpWidget(_uygulama(_Ev(sonuclar: sonuc),
          ayarlar: await _ayarlar('tr')));
      await _acilisiAc(tester);
      expect(_durum(tester).evre, AcilisEvresi.selam);

      await tester.tap(find.byKey(const ValueKey('acilis_basla')));
      await _bekle(tester);
      expect(_durum(tester).evre, AcilisEvresi.yerlestir);

      // Bayrak blok yerlesmeden calismiyor.
      await _durum(tester).calistir();
      expect(_durum(tester).evre, AcilisEvresi.yerlestir);

      await tester.tap(find.byKey(const ValueKey('acilis_palet_blogu')));
      await _bekle(tester);
      expect(_durum(tester).evre, AcilisEvresi.calistir);

      await tester.tap(find.byKey(const ValueKey('acilis_bayrak')));
      await tester.pump();
      expect(_durum(tester).evre, AcilisEvresi.kutlama);
      // Yuruyus + kutlama
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      expect(_durum(tester).evre, AcilisEvresi.hazir);
      expect(find.text('Hazırsın!'), findsOneWidget);
      // Sahne bitmeden isaret yok: geri tusuyla cikan cocuk tekrar gorur.
      expect(await KursTanitimDeposu.acilisGoruldu('scratch'), isFalse);

      await tester.tap(find.byKey(const ValueKey('acilis_bitir')));
      await _bekle(tester);
      expect(sonuc, [true]);
      expect(await KursTanitimDeposu.acilisGoruldu('scratch'), isTrue);
    });

    testWidgets('blok surukleyerek de yerlesir', (tester) async {
      SharedPreferences.setMockInitialValues({});
      _ekran(tester, const Size(390, 844));
      await tester.pumpWidget(_uygulama(_Ev(sonuclar: <bool>[]),
          ayarlar: await _ayarlar('en'), lang: 'en'));
      await _acilisiAc(tester);
      await tester.tap(find.byKey(const ValueKey('acilis_basla')));
      await _bekle(tester);

      final bas = tester.getCenter(find.byKey(const ValueKey('acilis_palet_blogu')));
      final hedef = tester.getCenter(find.byKey(const ValueKey('acilis_yuva')));
      final g = await tester.startGesture(bas);
      await tester.pump(const Duration(milliseconds: 50));
      for (var i = 1; i <= 8; i++) {
        await g.moveTo(Offset.lerp(bas, hedef, i / 8)!);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await g.up();
      await _bekle(tester);
      expect(_durum(tester).evre, AcilisEvresi.calistir);
    });

    testWidgets('hareket azaltilmis: daktilo yok, akis yine bitiyor',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      _ekran(tester, const Size(390, 844));
      final sonuc = <bool>[];
      await tester.pumpWidget(_uygulama(_Ev(sonuclar: sonuc),
          ayarlar: await _ayarlar('tr'), azalt: true));
      await _acilisiAc(tester);
      // Metin ilk karede tam: harf harf yazilmiyor.
      expect(tester.state<DaktiloYaziState>(find.byType(DaktiloYazi)).bitti,
          isTrue);

      await tester.tap(find.byKey(const ValueKey('acilis_basla')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('acilis_palet_blogu')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('acilis_bayrak')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      expect(_durum(tester).evre, AcilisEvresi.hazir);
      await tester.tap(find.byKey(const ValueKey('acilis_bitir')));
      await _bekle(tester);
      expect(sonuc, [true]);
    });

    testWidgets('tekrar izleme isaret yazmaz, derse gotumez',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      _ekran(tester, const Size(390, 844));
      final sonuc = <bool>[];
      await tester.pumpWidget(_uygulama(_Ev(sonuclar: sonuc, tekrar: true),
          ayarlar: await _ayarlar('tr')));
      await _acilisiAc(tester);
      await tester.tap(find.text('Atla'));
      await _bekle(tester);
      expect(sonuc, [false]);
      expect(await KursTanitimDeposu.acilisGoruldu('scratch'), isFalse);
    });

    testWidgets(
        'kurs sayfasi: ilk basista acilis, Atla -> 1. ders; '
        'ikinci kez dogrudan ders', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': 'tr'});
      _ekran(tester, const Size(390, 844));
      final auth = AuthProvider();
      await tester.pumpWidget(_uygulama(
          InteractiveCourseScreen(course: scratch),
          ayarlar: await _ayarlar('tr'),
          auth: auth));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('tanitimi_tekrar_izle')),
          findsOneWidget);

      await tester.tap(find.text('İlk derse başla'));
      await _bekle(tester, 600);
      expect(find.byType(KursAcilisEkrani), findsOneWidget);

      await tester.tap(find.text('Atla'));
      await _bekle(tester, 600);
      expect(find.byType(KursAcilisEkrani), findsNothing);
      final ders = tester.widget<InteractiveLessonScreen>(
          find.byType(InteractiveLessonScreen));
      expect(ders.lesson.id, dersler.first.id);

      // Dersten cik, tekrar bas: bu kez acilis yok.
      Navigator.of(tester.element(find.byType(InteractiveLessonScreen)))
          .pop();
      await _bekle(tester, 600);
      await tester.tap(find.byType(ElevatedButton).first);
      await _bekle(tester, 600);
      expect(find.byType(KursAcilisEkrani), findsNothing);
      expect(find.byType(InteractiveLessonScreen), findsOneWidget);
    });

    testWidgets('kursta ders bitmisse acilis gosterilmez', (tester) async {
      SharedPreferences.setMockInitialValues({
        'language_code': 'tr',
        DersIlerlemeDeposu.tamamlananAnahtari: [dersler.first.id],
      });
      _ekran(tester, const Size(390, 844));
      final auth = AuthProvider();
      await tester.pumpWidget(_uygulama(
          InteractiveCourseScreen(course: scratch),
          ayarlar: await _ayarlar('tr'),
          auth: auth));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Kaldığın yerden devam et'));
      await _bekle(tester, 600);
      expect(find.byType(KursAcilisEkrani), findsNothing);
      expect(find.byType(InteractiveLessonScreen), findsOneWidget);
    });

    test('Scratch, mBlock ve Arduino acik; baska kurs ayarsiz', () {
      expect(KursTanitimi.acik('scratch'), isTrue);
      expect(KursTanitimi.acik('mblock'), isTrue);
      // Arduino'nun acilisi ayri ekran: Devi malzemeleri tanitiyor.
      expect(KursTanitimi.acik('arduino'), isTrue);
      const acik = {'scratch', 'mblock', 'arduino'};
      for (final c in CoursesData.allCourses
          .where((c) => !acik.contains(c.id))) {
        expect(KursTanitimi.acik(c.id), isFalse, reason: c.id);
      }
    });
  });

  group('kapanis: ozet gercek veriden', () {
    test('ders, blok ve XP sayilari ders verisinden', () {
      final o = KursOzeti.hesapla('scratch', hepsi);
      expect(o.bitenDers, dersler.length);
      expect(o.toplamDers, dersler.length);
      expect(o.kursBitti, isTrue);
      expect(o.xp, dersler.fold<int>(0, (t, l) => t + l.xpReward));
      expect(o.farkliBlok, greaterThan(10));

      // 1.1'de blok kurma adimi yok.
      final ilk = KursOzeti.hesapla('scratch', {dersler[0].id});
      expect(ilk.farkliBlok, 0);
      expect(ilk.bitenDers, 1);
      expect(ilk.xp, dersler[0].xpReward);
      expect(ilk.kursBitti, isFalse);
      // 1.2'nin iki blok kurma adimi: [bayrak, 10 adim git] ve
      // [bayrak, 10 adim git, Merhaba de] -> 3 farkli blok.
      final ikinci = KursOzeti.farkliBloklar([dersler[1]]);
      expect(ikinci.length, 3);
    });

    test('ayni blogun farkli degeri tek blok sayilir', () {
      // move_10 ve move_100 ayni Scratch blogu ("%1 adim git"): kimlik
      // sayisi tur sayisindan fazla olmali.
      final hepsiTur = KursOzeti.farkliBloklar(dersler);
      final idler = <String>{
        for (final l in dersler)
          for (final s in l.steps.whereType<BlockBuilderStep>())
            ...s.correctSequence,
      };
      expect(idler, containsAll(['move_10', 'move_100']));
      expect(hepsiTur.length, lessThan(idler.length));
    });

    test('kapanis: yalnizca kurs bitince ve bir kez', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await KursKapanisEkrani.gosterilmeli('scratch', {dersler[0].id}),
          isFalse);
      expect(await KursKapanisEkrani.gosterilmeli('scratch', hepsi), isTrue);
      await KursTanitimDeposu.kapanisIsaretle('scratch');
      expect(await KursKapanisEkrani.gosterilmeli('scratch', hepsi), isFalse);
      // Kapanisi acik olmayan kurs hic.
      expect(
          await KursKapanisEkrani.gosterilmeli(
              'python', CourseModules.allLessons('python').map((l) => l.id).toSet()),
          isFalse);
    });

    test('siradaki kurs ogrenme yolundan: Scratch -> mBlock', () {
      expect(KursTanitimi.sonrakiKurs('scratch')?.id, 'mblock');
    });

    testWidgets('ekran: sayilar, ad, rozet; isaret yaziliyor',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      _ekran(tester, const Size(390, 844));
      final o = KursOzeti.hesapla('scratch', hepsi);
      await tester.pumpWidget(_uygulama(
          KursKapanisEkrani(
              course: scratch,
              tamamlanan: hepsi,
              ad: 'Elif',
              tarih: DateTime(2026, 10, 15)),
          ayarlar: await _ayarlar('tr')));
      await _bekle(tester, 900);

      String sayi(String k) => tester
          .widgetList<Text>(find.descendant(
              of: find.byKey(ValueKey(k)), matching: find.byType(Text)))
          .first
          .data!;
      expect(sayi('ozet_ders'), '${o.bitenDers}');
      expect(sayi('ozet_blok'), '${o.farkliBlok}');
      expect(sayi('ozet_xp'), '${o.xp}');
      expect(find.text('Elif'), findsOneWidget);
      expect(find.text('Scratch Mezunu'), findsOneWidget);
      expect(find.text('15 Ekim 2026'), findsOneWidget);
      expect(await KursTanitimDeposu.kapanisGoruldu('scratch'), isTrue);
    });

    testWidgets('siradaki kurs karti mBlock kursunu acar', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': 'tr'});
      _ekran(tester, const Size(390, 844));
      final auth = AuthProvider();
      await tester.pumpWidget(_uygulama(
          KursKapanisEkrani(course: scratch, tamamlanan: hepsi, ad: 'Elif'),
          ayarlar: await _ayarlar('tr'),
          auth: auth));
      await _bekle(tester, 900);
      final kart = find.byKey(const ValueKey('kapanis_sonraki_kurs'));
      await tester.scrollUntilVisible(kart, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(kart);
      await _bekle(tester, 900);
      final acilan = tester.widget<InteractiveCourseScreen>(
          find.byType(InteractiveCourseScreen));
      expect(acilan.course.id, 'mblock');
      expect(find.byType(KursKapanisEkrani), findsNothing);
    });

    testWidgets('tekrar acilan kapanis isaret yazmaz', (tester) async {
      SharedPreferences.setMockInitialValues({});
      _ekran(tester, const Size(390, 844));
      await tester.pumpWidget(_uygulama(
          KursKapanisEkrani(
              course: scratch, tamamlanan: hepsi, tekrar: true),
          ayarlar: await _ayarlar('en'),
          lang: 'en'));
      await _bekle(tester, 900);
      expect(find.text('Young Coder'), findsOneWidget);
      expect(await KursTanitimDeposu.kapanisGoruldu('scratch'), isFalse);
    });

    testWidgets('kurs bitince kurs sayfasinda "Sertifikan" baglantisi',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'language_code': 'tr',
        DersIlerlemeDeposu.tamamlananAnahtari: hepsi.toList(),
      });
      _ekran(tester, const Size(390, 844));
      final auth = AuthProvider();
      await tester.pumpWidget(_uygulama(
          InteractiveCourseScreen(course: scratch),
          ayarlar: await _ayarlar('tr'),
          auth: auth));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const ValueKey('kapanisi_tekrar_ac')));
      await _bekle(tester, 900);
      expect(find.byType(KursKapanisEkrani), findsOneWidget);
      expect(await KursTanitimDeposu.kapanisGoruldu('scratch'), isFalse);
    });
  });

  group('dort dil ve tasma', () {
    const metinler = {
      'tr': ['Atla', 'Hadi deneyelim', 'Kursu bitirdin!', 'BAŞARI SERTİFİKASI'],
      'en': ['Skip', "Let's try it", 'You finished the course!',
        'CERTIFICATE OF ACHIEVEMENT'],
      'de': ['Überspringen', 'Los, probieren wir', 'Kurs geschafft!',
        'URKUNDE'],
      'es': ['Saltar', '¡Vamos a probar!', '¡Terminaste el curso!',
        'CERTIFICADO DE LOGRO'],
    };

    for (final boy in const [Size(320, 568), Size(430, 932)]) {
      for (final lang in metinler.keys) {
        testWidgets('acilis $lang ${boy.width.toInt()}x${boy.height.toInt()}',
            (tester) async {
          SharedPreferences.setMockInitialValues({});
          _ekran(tester, boy);
          await tester.pumpWidget(_uygulama(_Ev(sonuclar: <bool>[]),
              ayarlar: await _ayarlar(lang), lang: lang));
          await _acilisiAc(tester);
          expect(find.text(metinler[lang]![0]), findsOneWidget);
          expect(find.text(metinler[lang]![1]), findsOneWidget);
          // Her evre: tasma olursa test hata ile duser.
          await tester.tap(find.byKey(const ValueKey('acilis_basla')));
          await _bekle(tester);
          await tester.tap(find.byKey(const ValueKey('acilis_palet_blogu')));
          await _bekle(tester);
          await tester.tap(find.byKey(const ValueKey('acilis_bayrak')));
          for (var i = 0; i < 20; i++) {
            await tester.pump(const Duration(milliseconds: 250));
          }
          expect(_durum(tester).evre, AcilisEvresi.hazir);
          expect(tester.takeException(), isNull);
        });

        testWidgets('kapanis $lang ${boy.width.toInt()}x${boy.height.toInt()}',
            (tester) async {
          SharedPreferences.setMockInitialValues({});
          _ekran(tester, boy);
          await tester.pumpWidget(_uygulama(
              KursKapanisEkrani(
                  course: scratch,
                  tamamlanan: hepsi,
                  ad: 'Maximilian-Alexander'),
              ayarlar: await _ayarlar(lang),
              lang: lang));
          await _bekle(tester, 900);
          expect(find.text(metinler[lang]![2]), findsOneWidget);
          await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
          await _bekle(tester, 600);
          expect(find.text(metinler[lang]![3]), findsOneWidget);
          await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
          await _bekle(tester, 600);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('1. ders acilisi: Devi, ders seridi; 320x568 tasma yok',
        (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': 'de'});
      _ekran(tester, const Size(320, 568));
      final auth = AuthProvider();
      await tester.pumpWidget(_uygulama(
          InteractiveLessonScreen(course: scratch, lesson: dersler.first),
          ayarlar: await _ayarlar('de'),
          lang: 'de',
          auth: auth));
      await _bekle(tester, 900);
      expect(find.text('Lektion 1'), findsOneWidget);
      expect(find.text('+${dersler.first.xpReward} XP'), findsOneWidget);
      expect(find.byKey(const ValueKey('ders_ilerleme_cubugu')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
