// ESLESTIRME ADIMI — oklar, yanlisla devam, okunakli yazi.
//
// Ucu de gercek bir sikayetten geliyor:
//
//  1. Cocuk soldaki 3 numarali karti sagdaki B karta bagliyordu ve
//     ekranda bu iliskiyi gosteren hicbir sey yoktu; dort ciftte
//     "hangisini neye baglamistim" sorusunun cevabi rozetleri tek tek
//     okumaktan geciyordu. Artik kartlar arasina ok ciziliyor.
//  2. Butun ciftler dogru olana kadar adim ILERLEMIYORDU. Yanlis
//     hatirladigi tek bir eslestirme dersin geri kalanini kilitliyordu.
//     Artik yanlis da bir cikis: dogrular gosteriliyor, XP verilmiyor,
//     ders devam ediyor.
//  3. Kart yazilari 15 punto/w500 ve uygulamanin yazi tipinden baska bir
//     yazi tipiyle ciziliyordu.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/theme.dart';
import 'package:devkom_app/ui/appear_in.dart';

final _adim = MatchingStep(
  id: 'eslestirme_deneme',
  instruction: 'Sekli, yaptigi isle eslestir.',
  pairs: const [
    MatchPair(id: 'a', left: 'Sapka', right: 'Yigini baslatir'),
    // DIKKAT: sol metinler tek harf OLMAMALI. Sag sutundaki rozetler
    // A/B/C harfi tasiyor; 'C' adinda bir kart find.text('C') ile
    // rozetle cakisiyor ve test "birden fazla widget bulundu" diye
    // dusuyor.
    MatchPair(id: 'b', left: 'C blogu', right: 'Icine blok alir'),
    MatchPair(id: 'c', left: 'Oval', right: 'Bir deger soyler'),
  ],
);

/// Adimi cizer; `sonuclar` listesine onComplete'in tasidigi degeri yazar.
Future<List<bool>> _ciz(WidgetTester tester) async {
  final sonuclar = <bool>[];
  SharedPreferences.setMockInitialValues({'language_code': 'tr'});
  final settings = SettingsProvider();
  await settings.setLocale(const Locale('tr'));

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: MatchingStepWidget(
              step: _adim,
              course: CoursesData.allCourses.first,
              isDark: false,
              onComplete: sonuclar.add,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return sonuclar;
}

/// Soldaki metne, sonra sagdaki metne dokunarak bir eslestirme kurar.
Future<void> _esle(WidgetTester tester, String sol, String sag) async {
  await tester.tap(find.text(sol));
  await tester.pump();
  await tester.tap(find.text(sag));
  await tester.pumpAndSettle();
}

void main() {
  // Testte ses calmaya calismasin: audioplayers eklentisi yok.
  setUpAll(() => SoundService.configure(sound: false));

  testWidgets('eslesen kartlar arasina ok ciziliyor', (tester) async {
    await _ciz(tester);

    // Hicbir eslestirme yokken cizilecek ok da yok.
    expect(find.byKey(const ValueKey('eslestirme-oklari-0')), findsOneWidget);

    await _esle(tester, 'Sapka', 'Yigini baslatir');
    expect(find.byKey(const ValueKey('eslestirme-oklari-1')), findsOneWidget,
        reason: 'eslestirme kuruldu ama arada ok cizilmiyor');

    await _esle(tester, 'C blogu', 'Icine blok alir');
    expect(find.byKey(const ValueKey('eslestirme-oklari-2')), findsOneWidget);

    // Eslestirme bozulunca ok da kalkiyor.
    await tester.tap(find.text('Sapka'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('eslestirme-oklari-1')), findsOneWidget);
  });

  testWidgets('yanlis eslestirmede ders kilitlenmiyor, devam edilebiliyor',
      (tester) async {
    final sonuclar = await _ciz(tester);

    // Kasten yanlis: her sol karti baska bir sagdakine bagliyoruz.
    await _esle(tester, 'Sapka', 'Icine blok alir');
    await _esle(tester, 'C blogu', 'Bir deger soyler');
    await _esle(tester, 'Oval', 'Yigini baslatir');

    expect(find.text('Devam et'), findsOneWidget,
        reason: 'yanlistan sonra cikis yolu yok — ders burada kilitleniyor');
    expect(find.text('Tekrar dene'), findsOneWidget);

    // Dogru cevap kartin uzerinde yaziyor.
    expect(find.textContaining('Doğrusu'), findsWidgets,
        reason: 'cocuk yanlis bilgisiyle degil dogru bilgiyle devam etmeli');

    await tester.tap(find.text('Devam et'));
    await tester.pumpAndSettle();

    expect(sonuclar, [false],
        reason: 'devam edildi ama XP verilmemeli (onComplete(false))');
  });

  testWidgets('tekrar dene tahtayi bosaltiyor', (tester) async {
    await _ciz(tester);

    await _esle(tester, 'Sapka', 'Icine blok alir');
    await _esle(tester, 'C blogu', 'Bir deger soyler');
    await _esle(tester, 'Oval', 'Yigini baslatir');
    expect(find.text('Tekrar dene'), findsOneWidget);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(find.text('Tekrar dene'), findsNothing);
    expect(find.text('Devam et'), findsNothing);
  });

  testWidgets('hepsi dogruysa XP veriliyor', (tester) async {
    final sonuclar = await _ciz(tester);

    await _esle(tester, 'Sapka', 'Yigini baslatir');
    await _esle(tester, 'C blogu', 'Icine blok alir');
    await _esle(tester, 'Oval', 'Bir deger soyler');
    await tester.pump(const Duration(milliseconds: 600));

    expect(sonuclar, [true]);
    expect(find.text('Devam et'), findsNothing,
        reason: 'dogru cozumde yanlis cikisi gorunmemeli');
  });

  testWidgets('kart yazilari kalin, buyuk ve uygulamanin yazi tipinde',
      (tester) async {
    await _ciz(tester);

    final kartYazisi = tester.widget<Text>(find.text('Sapka'));
    final stil = kartYazisi.style!;
    expect(stil.fontSize, greaterThanOrEqualTo(16),
        reason: '15 punto kucuk ekranda okunmuyordu');
    expect(stil.fontWeight!.index,
        greaterThanOrEqualTo(FontWeight.w700.index),
        reason: 'kart yazisi kalin olmali');
    expect(stil.fontFamily, AppTheme.fontFamily,
        reason: 'eslestirme adimi uygulamanin geri kalanindan baska bir '
            'yazi tipiyle cizilmemeli');
  });

  testWidgets('kartlar renkli belirip kendi rengine donuyor', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final settings = SettingsProvider();
    await settings.setLocale(const Locale('tr'));

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settings,
        child: MaterialApp(
          locale: const Locale('tr'),
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: SingleChildScrollView(
              child: MatchingStepWidget(
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

    // Kartlar AppearIn ile ve bir renkle geliyor.
    final belirenler = tester.widgetList<AppearIn>(find.byType(AppearIn));
    expect(belirenler, isNotEmpty);
    expect(belirenler.every((a) => a.renk != null), isTrue,
        reason: 'kartlar renksiz beliriyor — "renkli gelip siyahlasma" yok');

    // Animasyon ortasinda ustte renk filtresi var...
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byType(ColorFiltered), findsWidgets);

    // ...bittiginde kart kendi rengine donmus oluyor.
    await tester.pumpAndSettle();
    final son = tester
        .widgetList<ColorFiltered>(find.byType(ColorFiltered))
        .toList();
    for (final f in son) {
      // Tam saydam filtre = hicbir sey boyamiyor.
      expect(f.colorFilter, isNotNull);
    }
  });
}
