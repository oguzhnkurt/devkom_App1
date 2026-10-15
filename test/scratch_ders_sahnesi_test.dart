// SCRATCH DERS ADIMI = ACILIS SAHNESININ GORUNUMU
//
// Blok kurma adimi (Scratch kursu) acilis sahnesiyle AYNI kartlari
// kullaniyor: "Sahne" karti (yesil bayrak calistirir, kirmizi dur
// durdurur; gokyuzu, bulutlar, zemin, yuruyen Devi, konusma balonu) ve
// "Bloklar | Kod alani" karti.
//
// Kilitlenenler:
//  * 320x568 ve 430x932'de, dort dilde, bos / calisirken / bitince tasma
//    yok.
//  * Yesil bayrak (sahne basligi) ve alttaki buyuk dugme kodu calistiriyor;
//    blok yokken ikisi de pasif.
//  * Kirmizi dur oynatmayi o anda bitiriyor; sonra kutlama gelmiyor.
//  * Dogru sira basari kutusunu ve DEVAM'i gosteriyor; sahne "hedefe
//    ulasti" diyor. Yanlis sira ceza degil: kod yine calisiyor.
//  * Konusma blogu sahnede kuklanin ustunde balon.
//  * Kukla Devi: ders metinlerinde "kedi/cat/Katze/gato" kalmadi.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/sahne/blok_tezgahi_karti.dart';
import 'package:devkom_app/courses/sahne/scratch_sahnesi.dart';
import 'package:devkom_app/courses/screens/widgets/calisma_izi.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/courses/tanitim/kurs_acilis_ekrani.dart';
import 'package:devkom_app/courses/tanitim/kurs_tanitimi.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/ui/press_button.dart';
import 'package:devkom_app/widgets/block_animation_player.dart';
import 'package:devkom_app/widgets/scratch_blok.dart';

final scratch = CoursesData.byId('scratch')!;

BlockBuilderStep adim(String id) => CourseModules.allLessons('scratch')
    .expand((l) => l.steps)
    .whereType<BlockBuilderStep>()
    .firstWhere((s) => s.id == id);

final _bayrak = find.byKey(const ValueKey('sahne_bayragi'));
final _dur = find.byKey(const ValueKey('sahne_dur'));
final _tus = find.byKey(const ValueKey('ders_bayrak'));

Future<void> _kur(WidgetTester tester, BlockBuilderStep step,
    {String lang = 'tr', Size boy = const Size(390, 844)}) async {
  tester.view.physicalSize = boy * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'language_code': lang});
  final ayar = SettingsProvider();
  await ayar.setLocale(Locale(lang));
  final dolgu = boy.height < 700 ? 12.0 : 20.0; // ders ekranindaki gibi
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: ayar,
    child: MaterialApp(
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
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(dolgu, dolgu, dolgu, dolgu + 8),
          child: BlockBuilderStepWidget(
            step: step,
            course: scratch,
            isDark: false,
            onComplete: (_) {},
          ),
        ),
      ),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 200));
}

/// Paletteki blok (palet kod alaninin solunda / ustunde: ilk eslesen).
Future<void> _koy(WidgetTester tester, String id) async {
  final f = find
      .byWidgetPredicate((w) => w is ScratchBlok && w.kimlik == id)
      .first;
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _bas(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump();
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

BlockAnimationPlayerState _oynatici(WidgetTester tester) =>
    tester.state<BlockAnimationPlayerState>(find.byType(BlockAnimationPlayer));

String _tusYazisi(WidgetTester tester) =>
    tester.widget<PressButton>(_tus).label;

void main() {
  setUpAll(() => SoundService.configure(sound: false));

  group('tasma yok', () {
    const etiket = {
      'tr': 'Yeşil bayrağa bas',
      'en': 'Press the green flag',
      'de': 'Grüne Flagge drücken',
      'es': 'Pulsa la bandera verde',
    };
    for (final boy in const [Size(320, 568), Size(430, 932)]) {
      for (final lang in const ['tr', 'en', 'de', 'es']) {
        testWidgets('${boy.width.toInt()}x${boy.height.toInt()} $lang',
            (tester) async {
          final step = adim('s1_3_build1'); // bayrak, 4 tekrar, miyav
          await _kur(tester, step, lang: lang, boy: boy);
          expect(find.byType(ScratchSahneKarti), findsOneWidget);
          expect(find.byType(BlokTezgahiKarti), findsOneWidget);
          expect(_tusYazisi(tester), etiket[lang]);
          expect(tester.takeException(), isNull);

          for (final id in step.correctSequence) {
            await _koy(tester, id);
          }
          expect(tester.takeException(), isNull);

          await _bas(tester, _tus);
          await tester.pump(const Duration(milliseconds: 900));
          expect(tester.takeException(), isNull, reason: 'calisirken');

          await tester.pump(const Duration(seconds: 20));
          expect(tester.takeException(), isNull, reason: 'bitince');
          // Sahne ekranda kaldi (sayfa altina kaymadi).
          final sahne = tester.getRect(find.byType(ScratchSahneKarti));
          expect(sahne.bottom, lessThanOrEqualTo(boy.height + 0.5));
        });
      }
    }
  });

  testWidgets('blok yokken bayrak ve buyuk dugme pasif', (tester) async {
    await _kur(tester, adim('s1_2_build1'));
    expect(tester.widget<PressButton>(_tus).onPressed, isNull);
    await tester.tap(_bayrak);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(BlockAnimationPlayer), findsNothing);
    // Bos sahnede Devi zeminde bekliyor.
    expect(
        find.descendant(
            of: find.byType(ScratchSahneKarti),
            matching: find.byType(Image)),
        findsWidgets);
  });

  testWidgets('sahnedeki yesil bayrak kodu calistirir', (tester) async {
    await _kur(tester, adim('s1_2_build1'));
    await _koy(tester, 'green_flag');
    await _koy(tester, 'move_10');
    await _bas(tester, _bayrak);

    expect(find.byType(BlockAnimationPlayer), findsOneWidget);
    expect(_oynatici(tester).calisiyor, isTrue);
    expect(_tusYazisi(tester), 'Durdur');
    // Calisan blok kod alaninda sari haleyle parliyor.
    await tester.pump(const Duration(milliseconds: 500));
    expect(
        find.byWidgetPredicate(
            (w) => w is ScratchBlok && w.vurgu == ScratchBlok.calisanRengi),
        findsWidgets);

    await tester.pump(const Duration(seconds: 10));
    expect(_oynatici(tester).calisiyor, isFalse);
    expect(_tusYazisi(tester), 'Yeşil bayrağa bas');
    expect(find.textContaining('Kodun hedefe ulaştı'), findsOneWidget);
    // "Kodun ne yapti" izi asagida; katlanabilir.
    expect(find.byType(CalismaIzi), findsOneWidget);
    expect(find.text('10 adım git'), findsWidgets);
    await tester.ensureVisible(find.byKey(const ValueKey('iz_ac_kapa')));
    await tester.tap(find.byKey(const ValueKey('iz_ac_kapa')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Kodun ne yaptı'), findsOneWidget);
    expect(find.text('10 adım git'), findsNothing,
        reason: 'Iz kapanmadi.');
  });

  testWidgets('kirmizi dur oynatmayi o anda bitirir', (tester) async {
    await _kur(tester, adim('s1_3_build1'));
    for (final id in const ['green_flag', 'repeat_4', 'say_meow']) {
      await _koy(tester, id);
    }
    await _bas(tester, _tus);
    await tester.pump(const Duration(milliseconds: 1200));
    expect(_oynatici(tester).calisiyor, isTrue);

    await _bas(tester, _dur);
    expect(_oynatici(tester).calisiyor, isFalse);
    expect(find.textContaining('Kodu durdurdun'), findsOneWidget);
    expect(_tusYazisi(tester), 'Yeşil bayrağa bas');
    expect(
        find.byWidgetPredicate(
            (w) => w is ScratchBlok && w.vurgu == ScratchBlok.calisanRengi),
        findsNothing,
        reason: 'Durunca kod alaninda parlayan blok kalmamali.');

    // Zaman gecse de kutlama / devam yok: kod durdu.
    await tester.pump(const Duration(seconds: 15));
    expect(find.textContaining('Kodun hedefe ulaştı'), findsNothing);
    expect(find.textContaining('Kodu durdurdun'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Yeniden bayrak: bastan calisiyor.
    await _bas(tester, _bayrak);
    expect(_oynatici(tester).calisiyor, isTrue);
    await tester.pump(const Duration(seconds: 20));
  });

  testWidgets('buyuk dugme calisirken "Durdur"', (tester) async {
    await _kur(tester, adim('s1_2_build1'), lang: 'en');
    await _koy(tester, 'green_flag');
    await _bas(tester, _tus);
    expect(_tusYazisi(tester), 'Stop');
    await _bas(tester, _tus);
    expect(_oynatici(tester).calisiyor, isFalse);
    expect(_tusYazisi(tester), 'Press the green flag');
  });

  testWidgets('dogru sira: basari ve DEVAM; konusma balonu sahnede',
      (tester) async {
    await _kur(tester, adim('s1_3_build1'));
    for (final id in const ['green_flag', 'repeat_4', 'say_meow']) {
      await _koy(tester, id);
    }
    expect(find.text('Mükemmel! Doğru sıralamayı buldun!'), findsOneWidget);
    expect(find.text('DEVAM'), findsOneWidget);

    await _bas(tester, _tus);
    // Gecikme + bayrak + tekrarla + ilk miyav.
    String balon() =>
        tester.widget<SahneBalonu>(find.byType(SahneBalonu)).metin;
    for (var i = 0; i < 40 && balon().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(balon(), 'Miyav!');
    // Balon kuklanin USTUNDE.
    final kukla = tester.getRect(find.descendant(
        of: find.byType(BlockAnimationPlayer),
        matching: find.byType(Image)).first);
    expect(tester.getRect(find.byType(SahneBalonu)).bottom,
        lessThanOrEqualTo(kukla.top + 4));
    expect(find.text('2. tur').evaluate().isNotEmpty ||
        find.text('1. tur').evaluate().isNotEmpty, isTrue,
        reason: 'Dongu turu sahnede gorunmuyor.');

    await tester.pump(const Duration(seconds: 20));
    expect(find.textContaining('Kodun hedefe ulaştı'), findsOneWidget);
  });

  testWidgets('yanlis sira ceza degil: kod yine calisir', (tester) async {
    await _kur(tester, adim('s1_3_build1'));
    for (final id in const ['green_flag', 'say_meow', 'repeat_4']) {
      await _koy(tester, id);
    }
    expect(find.textContaining('bloğa bir daha bak'), findsOneWidget);
    await _bas(tester, _tus);
    expect(_oynatici(tester).calisiyor, isTrue);
    await tester.pump(const Duration(seconds: 20));
    expect(find.textContaining('Hedefle karşılaştır'), findsOneWidget);
    expect(find.text('DEVAM'), findsNothing);
  });

  testWidgets('acilis sahnesi de ayni kartlari kullaniyor', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final ayar = SettingsProvider();
    await ayar.setLocale(const Locale('tr'));
    await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
      value: ayar,
      child: MaterialApp(
        home: KursAcilisEkrani(
            course: scratch, tanitim: KursTanitimi.forCourse('scratch')!),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ScratchSahneKarti), findsOneWidget);
    expect(find.byType(BlokTezgahiKarti), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });

  group('kukla Devi', () {
    test('ders basliklari', () {
      final l = CourseModules.allLessons('scratch')
          .firstWhere((l) => l.id == 'scratch_1_2');
      expect(l.title, "Devi'yi Yürüt!");
      expect(l.titleEn, 'Make Devi Walk!');
      expect(l.titleDe, 'Lass Devi laufen!');
      expect(l.titleEs, '¡Haz caminar a Devi!');
    });

    test('Scratch derslerinde kedi kuklasi kalmadi (4 dil)', () {
      final yasak = RegExp(r'\bkedi|\bcat\b|\bcats\b|katze|\bgato\b|🐱',
          caseSensitive: false);
      final bulunan = <String>[];
      for (final l in CourseModules.allLessons('scratch')) {
        for (final lang in const ['tr', 'en', 'de', 'es']) {
          if (yasak.hasMatch(l.titleFor(lang))) {
            bulunan.add('${l.id} baslik: ${l.titleFor(lang)}');
          }
          for (final s in l.steps) {
            final metinler = <String>[
              if (s is BlockBuilderStep) ...[
                s.instructionFor(lang),
                s.goalFor(lang),
              ],
              if (s is ExplanationStep) ...[
                s.titleFor(lang),
                s.contentFor(lang),
              ],
              if (s is OrderingStep) ...[
                s.instructionFor(lang),
                s.contextFor(lang),
              ],
            ];
            for (final m in metinler) {
              if (yasak.hasMatch(m)) bulunan.add('${s.id} ($lang): $m');
            }
          }
        }
      }
      expect(bulunan, isEmpty);
    });
  });
}
