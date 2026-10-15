// Ekim 2026 ders akisi incelemesi: simulatorde gorulen hatalarin kilitleri.
//
//  1. Ders alt cubugu: "Back" ceviriliyor, ana tus "Devam" kaliyordu.
//  2. Blok kurma adimi "Bloklari buraya surukle" diyordu ama surukleme
//     yoktu; yalnizca dokunmak calisiyordu.
//  3. KODU CALISTIR'dan sonra sahne ekranin altinda aciliyordu; sahne
//     donguleri iz/kod alanindan FARKLI calistiriyordu.
//  4. Python dersinde durum cubugu acik zeminde beyaz kaliyordu.
//  5. Katalogda Python/Arduino IDE/Java/C# aciklamalari Turkce kaliyordu.
//  7. Tanitim "16 mini oyun" diyordu; sekmede 15 oyun var.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/interactive_lesson_screen.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/courses/yurutme/blok_yorumlayici.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/robotics_games_screen.dart' show ProGames;
import 'package:devkom_app/ui/answer_feedback.dart';
import 'package:devkom_app/widgets/block_animation_player.dart';

ScratchBlock _b(String id, String yazi,
        {ScratchBlockShape sekil = ScratchBlockShape.stack}) =>
    ScratchBlock(
      id: id,
      blockType: ScratchBlockType.motion,
      shape: sekil,
      label: yazi,
      color: const Color(0xFF4C97FF),
    );

final _adim = BlockBuilderStep(
  id: 'akis_denemesi',
  instruction: 'Kediyi yurut',
  goal: 'Dort tur',
  availableBlocks: [
    _b('green_flag', 'yeşil bayrak tıklandığında',
        sekil: ScratchBlockShape.cap),
    _b('repeat_4', '4 defa tekrarla', sekil: ScratchBlockShape.cBlock),
    _b('move_10', '10 adım git'),
    _b('say_meow', 'Miyav! de'),
  ],
  correctSequence: const ['green_flag', 'repeat_4', 'move_10', 'say_meow'],
);

Future<SettingsProvider> _ayarlar(String dil) async {
  SharedPreferences.setMockInitialValues({'language_code': dil});
  final s = SettingsProvider();
  await s.setLocale(Locale(dil));
  return s;
}

Widget _sar(SettingsProvider s, Widget child) =>
    ChangeNotifierProvider<SettingsProvider>.value(
      value: s,
      child: MaterialApp(home: child),
    );

Future<void> _blokAdimi(WidgetTester tester, {Size boyut = const Size(390, 844)}) async {
  final s = await _ayarlar('tr');
  tester.view.physicalSize = boyut * 3;
  tester.view.devicePixelRatio = 3;
  await tester.pumpWidget(_sar(
    s,
    Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: BlockBuilderStepWidget(
          step: _adim,
          course: CoursesData.allCourses.first,
          isDark: false,
          onComplete: (_) {},
        ),
      ),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 200));
}

/// Paletteki blogu (son eslesen yazi) basili tutup kod alanina surukler.
Future<void> _surukle(WidgetTester tester, String yazi, Finder hedef) async {
  final kaynak = find.text(yazi).last;
  await tester.ensureVisible(kaynak);
  await tester.pump();
  final g = await tester.startGesture(tester.getCenter(kaynak));
  await tester.pump(const Duration(milliseconds: 250)); // basili tut
  await g.moveBy(const Offset(0, -10));
  await tester.pump();
  await g.moveTo(tester.getCenter(hedef));
  await tester.pump();
  await g.up();
  await tester.pump(const Duration(milliseconds: 300));
}

List<String> _koddakiYazilar(WidgetTester tester) {
  // Kod alani paletin USTUNDE: ayni yazinin ilk eslesmesi kod alaninda.
  final out = <String>[];
  for (final y in const [
    'yeşil bayrak tıklandığında',
    '4 defa tekrarla',
    '10 adım git',
    'Miyav! de'
  ]) {
    final n = find.text(y).evaluate().length;
    if (n > 1) out.add(y);
  }
  return out;
}

void main() {
  group('ders alt cubugu', () {
    for (final (dil, devam, geri) in const [
      ('en', 'Continue', 'Back'),
      ('de', 'Weiter', 'Zurück'),
      ('es', 'Continuar', 'Atrás'),
      ('tr', 'Devam', 'Önceki'),
    ]) {
      testWidgets('$dil: ana tus ve geri tusu ayni dilde', (tester) async {
        final s = await _ayarlar(dil);
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        final ders = CourseModules.allLessons('scratch')
            .firstWhere((l) => l.id == 'scratch_1_2');
        await tester.pumpWidget(_sar(
            s,
            InteractiveLessonScreen(
                course: CoursesData.allCourses
                    .firstWhere((c) => c.id == 'scratch'),
                lesson: ders)));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text(devam), findsOneWidget,
            reason: '$dil ekranda ana tus cevrilmemis');
        if (dil != 'tr') expect(find.text('Devam'), findsNothing);

        // Ikinci adima gec: geri tusu da gorunsun.
        await tester.tap(find.text(devam));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text(geri), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      });
    }

    testWidgets('durum cubugu acik zeminde koyu', (tester) async {
      // Python kurs sayfasindan (koyu mavi baslik -> beyaz ikonlar) gelince
      // ders ekrani stil vermiyordu; beyaz ikonlar acik zeminde kaliyordu.
      final s = await _ayarlar('tr');
      final ders = CourseModules.allLessons('python').first;
      await tester.pumpWidget(_sar(
          s,
          InteractiveLessonScreen(
              course:
                  CoursesData.allCourses.firstWhere((c) => c.id == 'python'),
              lesson: ders)));
      await tester.pump(const Duration(milliseconds: 300));

      final bolge = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.byType(AnnotatedRegion<SystemUiOverlayStyle>).first);
      expect(bolge.value, SystemUiOverlayStyle.dark);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    test('renkli basliklarda yazi beyaz, durum cubugu acik', () {
      for (final yol in const [
        'lib/courses/screens/interactive_course_screen.dart',
        'lib/courses/screens/quiz_screen.dart',
        'lib/courses/screens/module_quiz_screen.dart',
      ]) {
        expect(File(yol).readAsStringSync(),
            contains('systemOverlayStyle: SystemUiOverlayStyle.light'),
            reason: yol);
      }
    });
  });

  testWidgets('cevap seridinin varsayilan yazilari dilde', (tester) async {
    final s = await _ayarlar('en');
    await tester.pumpWidget(_sar(
        s,
        Scaffold(
          body: Column(children: [
            AnswerFeedbackBar(
                result: AnswerResult.correct, inline: true, onContinue: () {}),
            AnswerFeedbackBar(
                result: AnswerResult.wrong, inline: true, onContinue: () {}),
          ]),
        )));
    expect(find.text('Correct!'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Not this time'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });

  test('katalog aciklamalari dort dilde', () {
    // Almanca ve Ispanyolcada da o/u noktali harfler var; orada yalnizca
    // Turkceye OZGU harflere bakiyoruz.
    for (final c in CoursesData.allCourses) {
      for (final dil in const ['en', 'de', 'es']) {
        final tr = dil == 'en' ? 'çÇğĞıİöÖşŞüÜ' : 'çÇğĞıİşŞ';
        final a = c.descriptionFor(dil);
        expect(a.split('').any(tr.contains), isFalse,
            reason: '${c.id} ($dil) aciklamasi Turkce: $a');
      }
    }
  });

  group('blok kurma adimi', () {
    testWidgets('paletten basili tutup surukleyince blok eklenir',
        (tester) async {
      addTearDown(tester.view.reset);
      await _blokAdimi(tester);
      expect(find.text('Aşağıdaki bloklara dokun ya da basılı tutup buraya sürükle'),
          findsOneWidget);

      await _surukle(tester, 'yeşil bayrak tıklandığında',
          find.text('Aşağıdaki bloklara dokun ya da basılı tutup buraya sürükle'));
      expect(_koddakiYazilar(tester), ['yeşil bayrak tıklandığında']);

      // Dokunarak ekleme hala calisiyor.
      final dokun = find.text('10 adım git').last;
      await tester.ensureVisible(dokun);
      await tester.tap(dokun);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_koddakiYazilar(tester),
          ['yeşil bayrak tıklandığında', '10 adım git']);

      // Ucuncu blogu ikincinin ONUNE surukle: araya girmeli.
      await _surukle(tester, '4 defa tekrarla', find.text('10 adım git').first);
      final dongu = tester.getTopLeft(find.text('4 defa tekrarla').first).dy;
      final git = tester.getTopLeft(find.text('10 adım git').first).dy;
      expect(dongu, lessThan(git),
          reason: 'Birakilan blok uzerine birakildigi blogun onune girmeli.');
      expect(tester.takeException(), isNull);
    });

    testWidgets('kod alanindaki blok surukleyerek yeniden siralanir',
        (tester) async {
      addTearDown(tester.view.reset);
      await _blokAdimi(tester);
      for (final y in const ['10 adım git', 'yeşil bayrak tıklandığında']) {
        final f = find.text(y).last;
        await tester.ensureVisible(f);
        await tester.tap(f);
        await tester.pump(const Duration(milliseconds: 300));
      }
      // Bayrak ikinci sirada; onu birincinin ustune tasi.
      final bayrak = find.text('yeşil bayrak tıklandığında').first;
      final g = await tester.startGesture(tester.getCenter(bayrak));
      await tester.pump(const Duration(milliseconds: 250));
      await g.moveBy(const Offset(0, -5));
      await tester.pump();
      await g.moveTo(tester.getCenter(find.text('10 adım git').first));
      await tester.pump();
      await g.up();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
          tester.getTopLeft(find.text('yeşil bayrak tıklandığında').first).dy,
          lessThan(tester.getTopLeft(find.text('10 adım git').first).dy));
    });

    testWidgets('KODU CALISTIR sahneyi ekrana getirir ve blogu parlatir',
        (tester) async {
      addTearDown(tester.view.reset);
      // Kucuk ekran: sahne ancak kaydirilinca gorunur.
      await _blokAdimi(tester, boyut: const Size(320, 568));
      for (final y in const [
        'yeşil bayrak tıklandığında',
        '4 defa tekrarla',
        '10 adım git',
        'Miyav! de',
      ]) {
        final f = find.text(y).last;
        await tester.ensureVisible(f);
        await tester.tap(f);
        await tester.pump(const Duration(milliseconds: 300));
      }
      final tus = find.text('KODU ÇALIŞTIR');
      await tester.ensureVisible(tus);
      await tester.pump();
      await tester.tap(tus);
      await tester.pump(); // sahne kuruldu
      // Kaydirma animasyonu kare kare ilerliyor.
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }

      final sahne = find.byType(BlockAnimationPlayer);
      expect(sahne, findsOneWidget);
      final alt = tester.getBottomLeft(sahne).dy;
      expect(alt, lessThanOrEqualTo(568),
          reason: 'Sahne ekranin altinda kaldi; cocuk yurumeyi goremiyor.');

      // Animasyon kaydirmadan SONRA basliyor; ilk blok kod alaninda
      // parlatiliyor.
      await tester.pump(const Duration(milliseconds: 100));
      final parlak = find.byWidgetPredicate((w) {
        if (w is! AnimatedContainer) return false;
        final d = w.foregroundDecoration;
        return d is BoxDecoration &&
            d.border is Border &&
            (d.border! as Border).left.color == const Color(0xFFFFE066);
      });
      expect(parlak, findsOneWidget,
          reason: 'Calisan blok kod alaninda isaretlenmiyor.');

      // Sonuna kadar oynat; dogru kodda kutlama cumlesi.
      await tester.pump(const Duration(seconds: 20));
      expect(find.textContaining('Kodun hedefe ulaştı'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('sahne ve iz ayni yurutmeyi oynatiyor', () {
    testWidgets('dongunun govdesindeki HER blok her turda calisiyor',
        (tester) async {
      final s = await _ayarlar('tr');
      final bloklar = _adim.availableBlocks; // bayrak, 4 tekrar, git, miyav
      final siralar = <int?>[];
      await tester.pumpWidget(_sar(
          s,
          Scaffold(
            body: SingleChildScrollView(
              child: BlockAnimationPlayer(
                blocks: bloklar,
                lang: 'tr',
                onAdim: siralar.add,
              ),
            ),
          )));
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      final beklenen = const BlokYorumlayici()
          .yurut(bloklar)
          .adimlar
          .map((a) => a.blokSirasi)
          .toList();
      expect(siralar.whereType<int>().toList(), beklenen);
      expect(siralar.where((s) => s == 3).length, 4,
          reason: 'Miyav dongunun icinde: dort kez calismali '
              '(eski oynatici yalnizca ilk blogu donguye aliyordu).');
      expect(siralar.last, isNull, reason: 'Bitince parlatma kalkmali.');
    });
  });

  group('yorumlayici', () {
    test('kare cizen kod basladigi yere doner', () {
      final sonuc = const BlokYorumlayici().yurut([
        _b('repeat_4', 'tekrar', sekil: ScratchBlockShape.cBlock),
        _b('move_100', 'git'),
        _b('turn_90', 'don'),
      ]);
      expect(sonuc.sonSahne.x, closeTo(0, 0.01));
      expect(sonuc.sonSahne.y, closeTo(0, 0.01));
    });

    test('sozlukte olmayan C blogu da govdesini iceri aliyor', () {
      // mBlock/Arduino: kod alani if_pressed'in altini girintili ciziyor.
      final sonuc = const BlokYorumlayici().yurut([
        _b('board_launch', 'baslat', sekil: ScratchBlockShape.cap),
        _b('if_pressed', 'eger', sekil: ScratchBlockShape.cBlock),
        _b('led_on', 'yak'),
      ]);
      expect(sonuc.adimlar.map((a) => a.derinlik).toList(), [0, 0, 1]);
      expect(sonuc.adimlar.map((a) => a.blokSirasi).toList(), [0, 1, 2]);
    });
  });

  testWidgets('dongu karsilastirmasi dilde', (tester) async {
    final s = await _ayarlar('en');
    final adim = CourseModules.allLessons('scratch')
        .expand((l) => l.steps)
        .whereType<AnimationStep>()
        .firstWhere((a) => a.animationType == AnimationType.comparison);
    await tester.pumpWidget(_sar(
        s,
        Scaffold(
          body: SingleChildScrollView(
            child: AnimationStepWidget(
              step: adim,
              course: CoursesData.allCourses.first,
              isDark: false,
              onComplete: () {},
            ),
          ),
        )));
    expect(find.text('move 10 steps'), findsWidgets);
    expect(find.text('10 adim git'), findsNothing);
  });

  test('tanitimdaki oyun sayisi katalogdan geliyor', () {
    expect(ProGames.catalogGameCount, 15);
    final s =
        File('lib/screens/auth/onboarding_flow_screen.dart').readAsStringSync();
    expect(s.contains('16 mini'), isFalse);
    expect(s.contains('ProGames.catalogGameCount'), isTrue);
  });
}
