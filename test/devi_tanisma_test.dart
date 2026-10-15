// Ilk acilista Devi kendini tanitiyor; maskota ad verme adimi yok.
//
// Kullanici: "Devi'nin adi degistirilebilir olmasin (kurulumda);
// yalnizca Ayarlar'a ad degistirme secenegi koy" ve "ilk girildiginde
// Devi kendini tanitmali, gozlerini kirparak".
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/auth/devi_tanisma.dart';
import 'package:devkom_app/screens/auth/onboarding_flow_screen.dart';
import 'package:devkom_app/widgets/mascot.dart';

Future<void> _kareler(WidgetTester t, [int n = 10, int ms = 100]) async {
  for (var i = 0; i < n; i++) {
    await t.pump(Duration(milliseconds: ms));
  }
}

Widget _tanisma(VoidCallback bitti, {String lang = 'tr', bool azalt = false}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: const Size(390, 844), disableAnimations: azalt),
        child: DeviTanisma(lang: lang, onDone: bitti),
      ),
    );

String _balon(WidgetTester t) {
  final rich = t.widget<RichText>(find.descendant(
      of: find.byKey(const ValueKey('devi_tanisma_metin')),
      matching: find.byType(RichText)));
  final span = rich.text as TextSpan;
  // Gorunen kisim ilk cocuk; ikincisi saydam (yer tutucu).
  return (span.children!.first as TextSpan).children!.first.toPlainText();
}

void main() {
  test('dort dilde uc sayfa, ilk sayfada adi soyluyor', () {
    for (final lang in ['tr', 'en', 'de', 'es']) {
      final s = DeviTanisma.sayfalar(lang);
      expect(s, hasLength(3));
      expect(s.first, contains(Mascot.ad));
      for (final m in s) {
        expect(m.trim(), isNotEmpty);
      }
    }
    expect(DeviTanisma.sayfalar('en').first, 'Hi there! My name is Devi 👋');
    expect(DeviTanisma.sayfalar('tr')[1], contains('yapay zekâ'));
  });

  testWidgets('daktilo yaziyor, dokununca tamamlaniyor ve ilerliyor',
      (tester) async {
    var bitti = 0;
    await tester.pumpWidget(_tanisma(() => bitti++));
    await tester.pump(const Duration(milliseconds: 700));
    final ilk = DeviTanisma.sayfalar('tr').first;
    expect(_balon(tester).length, lessThan(ilk.length),
        reason: 'metin daktilo gibi yazilmali');

    // Ilk dokunus: yaziyi tamamla.
    await tester.tap(find.byKey(const ValueKey('devi_tanisma_devam')));
    await tester.pump();
    expect(_balon(tester), ilk);

    final durum =
        tester.state<DeviTanismaState>(find.byType(DeviTanisma));
    for (var sayfa = 1; sayfa < 3; sayfa++) {
      await tester.tap(find.byKey(const ValueKey('devi_tanisma_devam')));
      await tester.pump();
      expect(durum.sayfa, sayfa);
      await _kareler(tester, 40);
    }
    expect(find.text("Hadi başlayalım!"), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('devi_tanisma_devam')));
    await tester.pump();
    expect(bitti, 1);
  });

  testWidgets('Atla her an bitiriyor', (tester) async {
    var bitti = 0;
    await tester.pumpWidget(_tanisma(() => bitti++, lang: 'en'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('devi_tanisma_atla')));
    expect(bitti, 1);
  });

  testWidgets('hareket azaltilmisken metin hemen tam, gozler kirpmiyor',
      (tester) async {
    await tester.pumpWidget(_tanisma(() {}, azalt: true));
    await tester.pump();
    expect(_balon(tester), DeviTanisma.sayfalar('tr').first);
    final mascot = tester.widget<Mascot>(find.byType(Mascot));
    expect(mascot.blink, isTrue);
  });

  test('Devi ~3 saniyede bir gozlerini kirpiyor', () {
    // 7 sn'lik donguyu 10 ms adimla tara: kapali anlarin sayisi ve
    // aralari.
    final kapanislar = <double>[];
    var onceki = 0.0;
    for (var ms = 0; ms <= 7000; ms += 10) {
      final k = Mascot.gozKapanikligi(ms / 7000);
      if (k > 0.9 && onceki <= 0.9) kapanislar.add(ms / 1000);
      onceki = k;
    }
    expect(kapanislar.length, 3, reason: 'tek + cift kirpma');
    expect(Mascot.gozKapanikligi(0.2), 0);
    expect(kapanislar.first, inInclusiveRange(2.5, 3.5));
  });

  testWidgets('kurulum Devi ile basliyor, maskota ad sorulmuyor',
      (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'en'});
    final settings = SettingsProvider();
    await settings.setLocale(const Locale('en'));
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: const MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: OnboardingFlowScreen(),
      ),
    ));
    await _kareler(tester, 5);
    expect(find.byType(DeviTanisma), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('devi_tanisma_atla')));
    await _kareler(tester, 12);
    expect(find.byType(DeviTanisma), findsNothing);
    // Dogrudan ilk gorev: ad alani yok.
    expect(find.byType(Draggable<String>), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('NAME YOUR BUDDY'), findsNothing);
    expect(find.textContaining("Hi, I'm Devi!"), findsOneWidget);
    expect(settings.hasCustomMascotName, isFalse);
  });
}
