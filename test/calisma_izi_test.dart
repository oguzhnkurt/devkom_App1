// CALISTIRMA TUSU BIR ODUL DEGIL.
//
// Blok kurma adiminda "KODU CALISTIR" tusu `if (_completed)` blogunun
// icindeydi: cocuk ancak DOGRU sirayi buldugunda kodunu calistirabiliyordu.
// Yani kendi YANLIS kodunun ne yaptigini hicbir zaman goremiyor, sadece
// yesil cerceve cikana kadar blok deniyordu. Ogrenmenin tam tersi.
//
// Buradaki testler tusun yanlis kodda da calistigini ve izin gercek
// yurutmeden geldigini (tahminden degil) gosteriyor.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/calisma_izi.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/ui/press_button.dart';
import 'package:devkom_app/widgets/scratch_blok.dart';

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
  id: 'iz_denemesi',
  instruction: 'Kediyi dort defa yurut',
  goal: 'Dort adim',
  availableBlocks: [
    _b('green_flag', 'yeşil bayrak tıklandığında',
        sekil: ScratchBlockShape.cap),
    _b('repeat_4', '4 defa tekrarla', sekil: ScratchBlockShape.cBlock),
    _b('move_10', '10 adım git'),
    _b('say_meow', 'Miyav! de'),
  ],
  // Dordüncü blok bilerek burada: testler kodu EKSIK birakip
  // calistiriyor, yani cevap yanlisken. Tamamlanmis bir dizide
  // animasyon oynaticisi devreye girip zamanlayici birakiyor.
  correctSequence: const ['green_flag', 'repeat_4', 'move_10', 'say_meow'],
);

Future<void> _ciz(WidgetTester tester, String dil) async {
  SharedPreferences.setMockInitialValues({'language_code': dil});
  final settings = SettingsProvider();
  await settings.setLocale(Locale(dil));

  tester.view.physicalSize = const Size(320 * 3, 568 * 3);
  tester.view.devicePixelRatio = 3;

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        locale: Locale(dil),
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
            padding: const EdgeInsets.all(12),
            child: BlockBuilderStepWidget(
              step: _adim,
              course: CoursesData.allCourses.first,
              isDark: false,
              onComplete: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

/// Scratch kursunda bloklar yazi degil, Scratch blogu olarak ciziliyor
/// (yazi boyanarak, Text widget'i yok). Blogu ders kimligiyle buluyoruz.
const _kimlik = {
  'yeşil bayrak tıklandığında': 'green_flag',
  '4 defa tekrarla': 'repeat_4',
  '10 adım git': 'move_10',
  'Miyav! de': 'say_meow',
};

Finder _blok(String yazi) => find.byWidgetPredicate(
    (w) => w is ScratchBlok && w.kimlik == _kimlik[yazi]);

/// Palet kucuk ekranda kayabiliyor; once gorunur kil sonra dokun.
/// Scratch duzeninde palet ("Bloklar") kod alaninin solunda / ustunde:
/// ilk eslesen paletteki blok.
Future<void> _koy(WidgetTester tester, String yazi) async {
  final hedef = _blok(yazi).first;
  await tester.ensureVisible(hedef);
  await tester.pump();
  await tester.tap(hedef);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Buyuk "Yesil bayraga bas" dugmesi (sahnedeki bayrakla ayni is).
final _tus = find.byKey(const ValueKey('ders_bayrak'));

bool _tusAktif(WidgetTester tester) =>
    tester.widget<PressButton>(_tus).onPressed != null;

Future<void> _calistir(WidgetTester tester) async {
  await tester.ensureVisible(_tus);
  await tester.pump();
  await tester.tap(_tus);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('tus yalnizca dogru cevaptan sonra cikmiyor', (tester) async {
    addTearDown(tester.view.reset);
    await _ciz(tester, 'tr');

    // Hic blok yokken tus pasif — calistiracak bir sey de yok. (Yeri
    // bastan ayrilmis: yerlesim kaymiyor.)
    expect(_tus, findsOneWidget);
    expect(_tusAktif(tester), isFalse);

    // TEK bir blok koy: dizi eksik, yani cevap YANLIS.
    await _koy(tester, '10 adım git');

    expect(_tusAktif(tester), isTrue,
        reason: 'Yanlis kod calistirilamiyor — tus yine odule baglanmis.');
    expect(find.byType(CalismaIzi), findsNothing);

    await _calistir(tester);

    expect(find.byType(CalismaIzi), findsOneWidget);
    expect(find.text('Kodun ne yaptı'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('iz dongunun turlarini gosteriyor', (tester) async {
    addTearDown(tester.view.reset);
    await _ciz(tester, 'tr');

    for (final yazi in const [
      'yeşil bayrak tıklandığında',
      '4 defa tekrarla',
      '10 adım git'
    ]) {
      await _koy(tester, yazi);
    }

    await _calistir(tester);

    // Dongu GERCEKTEN donuyor: dorduncu tur ekranda.
    expect(find.text('4. tur'), findsOneWidget,
        reason: 'Iz tahminle degil gercek yurutmeyle uretilmeli.');
    expect(find.textContaining('x: 40'), findsOneWidget,
        reason: '4 x 10 adim = 40. Sonuc seridi sahneyi yansitmiyor.');
    expect(tester.takeException(), isNull);
  });

  testWidgets('blok cikarilinca iz kapaniyor', (tester) async {
    addTearDown(tester.view.reset);
    await _ciz(tester, 'tr');

    await _koy(tester, '10 adım git');
    await _calistir(tester);
    expect(find.byType(CalismaIzi), findsOneWidget);

    // Kod degisti: eski iz artik yalan soyler. Kod alanindaki bloga
    // dokunmak onu cikariyor (blogun sagindaki "x" cizili). Kod alani
    // paletin sagi / alti: son eslesen.
    final sil = _blok('10 adım git').last;
    await tester.ensureVisible(sil);
    await tester.pump();
    await tester.tap(sil);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CalismaIzi), findsNothing);
  });

  testWidgets('yanlis sira kacinci bloktan bozuldugunu soyluyor',
      (tester) async {
    addTearDown(tester.view.reset);
    await _ciz(tester, 'tr');

    // Ilk iki blok dogru, ucuncuden itibaren ters.
    for (final yazi in const [
      'yeşil bayrak tıklandığında',
      '4 defa tekrarla',
      'Miyav! de',
      '10 adım git',
    ]) {
      await _koy(tester, yazi);
    }

    expect(find.text('İlk 2 blok yerinde. 3. bloğa bir daha bak.'),
        findsOneWidget,
        reason: 'Uyari hala tek tip genel cumle.');
    expect(tester.takeException(), isNull);
  });

  test('calistirma tusu _completed blogunun disinda', () {
    final s = File('lib/courses/screens/widgets/step_widgets.dart')
        .readAsStringSync();
    final bas = s.indexOf('class _BlockBuilderStepWidgetState');
    final son = s.indexOf('// ORDERING STEP WIDGET', bas);
    final govde = s.substring(bas, son > 0 ? son : s.length);

    final tus = govde.indexOf("'KODU ÇALIŞTIR'");
    final basari = govde.indexOf('if (_completed) ...[');
    expect(tus, greaterThan(0));
    expect(basari, greaterThan(0));
    expect(tus, lessThan(basari),
        reason: 'Calistirma tusu yine basari blogunun icine girmis.');
  });
}
