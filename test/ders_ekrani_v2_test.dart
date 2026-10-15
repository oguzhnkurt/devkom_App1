// Ders ekrani v2: tek parca ilerleme cubugu, bos alani dolduran Devi
// arkadasi ve kurs sayfasinin cocugun modulunde acilmasi.
import 'package:flutter/material.dart';
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
import 'package:devkom_app/courses/screens/widgets/ders_arkadasi.dart';
import 'package:devkom_app/courses/screens/widgets/ders_ilerleme_cubugu.dart';
import 'package:devkom_app/courses/screens/widgets/devi_tepkisi.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/ders_ilerleme_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/mascot.dart';

Future<void> _kur(WidgetTester tester, Widget home,
    {Size boy = const Size(430, 932),
    double yazi = 1.0,
    AuthProvider? auth}) async {
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
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(yazi)),
        child: child!,
      ),
      home: home,
    ),
  ));
}

Future<void> _bekle(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}

InteractiveLesson _ders(List<LessonStep> adimlar) => InteractiveLesson(
      id: 'v2_ders',
      courseId: 'scratch',
      title: 'Tekrarla Tekrarla!',
      subtitle: '',
      order: 1,
      steps: adimlar,
    );

void main() {
  final scratch = CoursesData.byId('scratch')!;
  final soru = CourseModules.allLessons('scratch')
      .expand((l) => l.steps)
      .firstWhere((s) => s.id == 's1_3_q1') as MultipleChoiceStep;

  setUpAll(() async {
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
  });

  group('ilerleme cubugu', () {
    for (final n in [3, 10, 30]) {
      testWidgets('$n adim: cizilir, etiket okunur', (tester) async {
        final semantik = tester.ensureSemantics();
        Widget cubuk(int adim) => MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 380,
                    child: DersIlerlemeCubugu(
                      adim: adim,
                      toplam: n,
                      renk: scratch.primaryColor,
                      renk2: scratch.secondaryColor,
                      etiket: 'Adım ${adim + 1}/$n',
                    ),
                  ),
                ),
              ),
            );
        await tester.pumpWidget(cubuk(0));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.bySemanticsLabel('Adım 1/$n'), findsOneWidget);
        final ilk = tester
            .getCenter(find.byKey(const ValueKey('ders_ilerleme_binici')))
            .dx;

        // Ileri: Devi saga gidiyor (yumusakca).
        await tester.pumpWidget(cubuk(n ~/ 2));
        await tester.pump(const Duration(milliseconds: 1000));
        expect(find.bySemanticsLabel('Adım ${n ~/ 2 + 1}/$n'), findsOneWidget);
        final orta = tester
            .getCenter(find.byKey(const ValueKey('ders_ilerleme_binici')))
            .dx;
        expect(orta, greaterThan(ilk));

        // Son adim: kupanin yanina kadar, tasmadan.
        await tester.pumpWidget(cubuk(n - 1));
        await tester.pump(const Duration(milliseconds: 1000));
        final son = tester
            .getRect(find.byKey(const ValueKey('ders_ilerleme_binici')));
        expect(son.right, lessThanOrEqualTo(tester.getRect(
                find.byKey(const ValueKey('ders_ilerleme_cubugu'))).right));
        expect(tester.getSize(find.byKey(const ValueKey('ders_ilerleme_cubugu'))).height,
            DersIlerlemeCubugu.yukseklik);

        // Geri de gidiyor.
        await tester.pumpWidget(cubuk(0));
        await tester.pump(const Duration(milliseconds: 1000));
        expect(
            tester
                .getCenter(find.byKey(const ValueKey('ders_ilerleme_binici')))
                .dx,
            closeTo(ilk, 0.5));
        expect(tester.takeException(), isNull);
        semantik.dispose();
        await tester.pumpWidget(const SizedBox());
      });
    }

    test('cok adimda noktalar seyreltiliyor', () {
      expect(DersIlerlemeCubugu.noktalar(10).length, 10);
      expect(DersIlerlemeCubugu.noktalar(16).length, 16);
      expect(DersIlerlemeCubugu.noktalar(30).length, lessThanOrEqualTo(11));
      expect(DersIlerlemeCubugu.noktalar(30).last, 29);
      expect(DersIlerlemeCubugu.noktalar(1), isEmpty);
    });
  });

  group('Devi arkadasi', () {
    testWidgets('kisa soru 430x932: arkadas bos alanda, tasma yok, tek Devi',
        (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': 'tr'});
      await _kur(
          tester,
          InteractiveLessonScreen(
              course: scratch,
              lesson: _ders([soru, ...CourseModules.allLessons('scratch')
                  .firstWhere((l) => l.id == 'scratch_1_3')
                  .steps
                  .where((s) => s.id != soru.id)])),
          auth: AuthProvider());
      await _bekle(tester, 900);
      expect(tester.takeException(), isNull);
      final arkadas = find.byKey(const ValueKey('ders_arkadasi'));
      expect(arkadas, findsOneWidget);
      // Ekranda (Devam cubugunun ustunde) ve seceneklerin altinda.
      final kutu = tester.getRect(arkadas);
      final devam = tester.getRect(find.widgetWithText(ElevatedButton, 'Devam'));
      expect(kutu.bottom, lessThan(devam.top));
      expect(kutu.top, greaterThan(tester.getRect(find.text('10 kere')).bottom));
      expect(find.text(DersArkadasi.soz(DersArkadasiTuru.soru, 'tr', soru.id.hashCode)),
          findsOneWidget);

      await tester.tap(find.text('5 kere'));
      await _bekle(tester, 1200);
      expect(tester.takeException(), isNull);
      // Tepkiyi ayni Devi veriyor: ikinci (kucuk) Devi yok.
      expect(find.byType(DeviTepkisi), findsNothing);
      expect(find.byType(Mascot), findsOneWidget);
      expect(
          find.text(DeviTepkisi.soz(DeviTepkiTuru.dogru, 'tr',
              soru.id.hashCode + 1)),
          findsOneWidget);
      await _kapat(tester);
    });

    testWidgets('uzun anlatim 375x667, yazi 1.3: tasma yok', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': 'tr'});
      final uzun = ExplanationStep(
        id: 'v2_uzun',
        title: 'Uzun bir anlatım başlığı burada duruyor',
        content: List.filled(
                6,
                'Döngüler aynı işi tekrar tekrar yapmamızı sağlar. '
                'Bir bloğu on kere yazmak yerine bir kez yazıp tekrarlarız.')
            .join('\n\n'),
        tip: 'Döngü kullanmak kodu kısa ve okunur yapar.',
      );
      await _kur(tester,
          InteractiveLessonScreen(course: scratch, lesson: _ders([uzun, soru])),
          boy: const Size(375, 667), yazi: 1.3, auth: AuthProvider());
      await _bekle(tester, 11000);
      expect(tester.takeException(), isNull);
      // Arkadas icerigin altinda, kaydirilarak gorunuyor.
      expect(find.byKey(const ValueKey('ders_arkadasi'), skipOffstage: false),
          findsOneWidget);
      await _kapat(tester);
    });

    // Kucuk ekranda cevaptan sonra sayfa SONUNA kaydiriliyor, soru karti
    // ekranin ustunden cikiyordu. Artik soru metni ve secilen secenek
    // ekranda kaliyor; Devi'nin tepkisi de gorunuyor (alttaki arkadas ya
    // da secenegin altindaki kucuk balon).
    for (final kod in [false, true]) {
      for (final secim in ['10 kere', '5 kere', '50 kere', '100 kere']) {
        testWidgets(
            '375x667${kod ? ' (kodlu)' : ''}: "$secim" sonrasi soru ve secim '
            'ekranda, tepki gorunuyor', (tester) async {
          SharedPreferences.setMockInitialValues({'language_code': 'tr'});
          final q = kod
              ? MultipleChoiceStep(
                  id: 'v2_kodlu',
                  question: soru.question,
                  options: soru.options,
                  correctIndex: soru.correctIndex,
                  explanation: soru.explanation,
                  codeContext: 'tekrarla ?\n  10 adım git',
                )
              : soru;
          await _kur(
              tester,
              InteractiveLessonScreen(
                  course: scratch,
                  lesson: _ders([
                    q,
                    ...CourseModules.allLessons('scratch')
                        .firstWhere((l) => l.id == 'scratch_1_3')
                        .steps
                        .where((s) => s.id != soru.id)
                  ])),
              boy: const Size(375, 667),
              auth: AuthProvider());
          await _bekle(tester, 900);
          final ekran = tester.getRect(find.byType(CustomScrollView));
          bool icinde(Rect r) =>
              r.top >= ekran.top - 0.5 && r.bottom <= ekran.bottom + 0.5;
          final soruMetni = find.text(q.question);
          final secilen = find.text(secim);
          // Cocuk secenegi gorup dokunuyor: gerekiyorsa once ona kaydir.
          if (!icinde(tester.getRect(secilen))) {
            await Scrollable.ensureVisible(tester.element(secilen),
                alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
            await tester.pump(const Duration(milliseconds: 300));
          }
          final soruGorunurdu = icinde(tester.getRect(soruMetni));
          if (!kod) expect(soruGorunurdu, isTrue);
          await tester.tap(secilen);
          await _bekle(tester, 1500);
          expect(tester.takeException(), isNull);

          if (soruGorunurdu) {
            expect(icinde(tester.getRect(soruMetni)), isTrue,
                reason: 'soru ekranin disinda: '
                    '${tester.getRect(soruMetni)} / $ekran');
            expect(soruMetni.hitTestable(), findsOneWidget);
          }
          expect(icinde(tester.getRect(secilen)), isTrue,
              reason: 'secim ekranin disinda: ${tester.getRect(secilen)} / $ekran');
          expect(secilen.hitTestable(), findsOneWidget);

          // Tepki: ya alttaki arkadasin balonu ekranda ya da secilen
          // secenegin icinde kucuk Devi ve sozu (o zaman alttaki Devi
          // cekiliyor, ekranda tek Devi).
          final sozu = find.byKey(const ValueKey('secenek_tepkisi'));
          final arkadas = find.byKey(const ValueKey('ders_arkadasi'),
              skipOffstage: false);
          if (sozu.evaluate().isNotEmpty) {
            final r = tester.getRect(sozu);
            expect(icinde(r), isTrue, reason: 'tepki gorunmuyor: $r / $ekran');
            expect(r.top, greaterThanOrEqualTo(tester.getRect(secilen).bottom));
            expect(find.byKey(const ValueKey('secenek_devi')), findsOneWidget);
            expect(
                tester
                    .widget<AnimatedOpacity>(find
                        .ancestor(
                            of: arkadas,
                            matching: find.byType(AnimatedOpacity,
                                skipOffstage: false))
                        .first)
                    .opacity,
                0);
          } else {
            for (final e in find
                .descendant(of: arkadas, matching: find.byType(Text))
                .evaluate()) {
              final kutu = e.renderObject! as RenderBox;
              final r = kutu.localToGlobal(Offset.zero) & kutu.size;
              expect(icinde(r), isTrue,
                  reason: 'arkadasin balonu gorunmuyor: $r / $ekran');
            }
          }
          expect(
              find.textContaining(secim == '5 kere' ? 'Doğru!' : 'Yanlış!'),
              findsOneWidget);
          await _kapat(tester);
        });
      }
    }

    test('sozler dort dilde', () {
      for (final l in ['tr', 'en', 'de', 'es']) {
        final s = DersArkadasi.butunSozler(l).toList();
        expect(s.length, 13, reason: l);
        expect(s.toSet().length, s.length, reason: l);
      }
    });
  });

  testWidgets('kurs sayfasi cocugun modulunde aciliyor', (tester) async {
    final moduller = CourseModules.forCourse('scratch');
    final biten = [
      for (final m in moduller.take(5)) ...m.lessons.map((l) => l.id),
    ];
    SharedPreferences.setMockInitialValues({
      'language_code': 'tr',
      DersIlerlemeDeposu.tamamlananAnahtari: biten,
    });
    final auth = AuthProvider();
    await _kur(tester, InteractiveCourseScreen(course: scratch),
        boy: const Size(390, 844), auth: auth);
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('MODÜL 6'), findsOneWidget);
    expect(find.text('MODÜL 1'), findsNothing);

    // Baska bir dugum secilince: liste o modul, dugumde secili halkasi.
    await tester.tap(find.byKey(const ValueKey('yol_tamam_4')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('MODÜL 5'), findsOneWidget);
    expect(find.byKey(const ValueKey('yol_secili_4')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('kurs sayfasi: initialModule verilirse o modul', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    await _kur(tester, InteractiveCourseScreen(course: scratch, initialModule: 2),
        boy: const Size(390, 844), auth: AuthProvider());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('MODÜL 3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
