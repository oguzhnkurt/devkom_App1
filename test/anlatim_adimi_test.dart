// ANLATIM ADIMI — metin paragraf paragraf açılıyor.
//
// Anlatım ekranı bir duvar metniydi: bütün paragraflar bir anda
// duruyor, altta DEVAM tuşu hazır bekliyordu. Çocuk tek dokunuşla
// geçiyor, okumuyordu.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/providers/settings_provider.dart';

final _adim = ExplanationStep(
  id: 'anlatim_deneme',
  title: 'C# Nedir?',
  content: 'Birinci paragraf.\n\nİkinci paragraf.\n\nÜçüncü paragraf.',
  tip: 'Küçük bir ipucu.',
);

Future<int> _ciz(
  WidgetTester tester, {
  bool tumunuGoster = false,
  bool ekranOkuyucu = false,
}) async {
  var bittiSayisi = 0;
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
        home: MediaQuery(
          data: MediaQueryData(accessibleNavigation: ekranOkuyucu),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExplanationStepWidget(
                step: _adim,
                course: CoursesData.allCourses.first,
                isDark: false,
                tumunuGoster: tumunuGoster,
                onComplete: () => bittiSayisi++,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 700));
  return bittiSayisi;
}

void main() {
  testWidgets('ilk açılışta yalnızca ilk paragraf var', (tester) async {
    await _ciz(tester);
    expect(find.text('Birinci paragraf.'), findsOneWidget);
    expect(find.text('İkinci paragraf.'), findsNothing);
    // Cocuktan bir sey ISTEMIYORUZ: "dokun" yazisi yok, yalnizca
    // metnin bitmedigini soyleyen uc nokta var.
    expect(find.text('Devam etmek için ekrana dokun'), findsNothing);
    // Ipucu kutusu da sona sakli.
    expect(find.text('Küçük bir ipucu.'), findsNothing);
  });

  testWidgets('paragraflar dokunmadan kendiliğinden geliyor', (tester) async {
    await _ciz(tester);
    expect(find.text('İkinci paragraf.'), findsNothing);

    // Hicbir dokunus yok — yalnizca zaman geciyor.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('İkinci paragraf.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Üçüncü paragraf.'), findsOneWidget);
    expect(find.text('Küçük bir ipucu.'), findsOneWidget);
  });

  testWidgets('dokunmak kalanı hemen açıyor ve adım tamamlanıyor',
      (tester) async {
    var bitti = 0;
    // _ciz kendi sayacini donduruyor; burada yeniden kuruyoruz.
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final settings = SettingsProvider();
    await settings.setLocale(const Locale('tr'));
    await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ExplanationStepWidget(
              step: _adim,
              course: CoursesData.allCourses.first,
              isDark: false,
              onComplete: () => bitti++,
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 700));

    expect(bitti, 0, reason: 'Metin okunmadan adım tamamlanmış sayıldı.');

    // Hizli okuyan cocuk beklemesin: tek dokunus kalanini getiriyor.
    await tester.tap(find.text('Birinci paragraf.'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('İkinci paragraf.'), findsOneWidget);
    expect(find.text('Üçüncü paragraf.'), findsOneWidget);
    expect(find.text('Küçük bir ipucu.'), findsOneWidget,
        reason: 'İpucu kutusu sonunda açılmalı.');
    expect(bitti, 1, reason: 'Adım bitince bir kez haber verilmeli.');
  });

  testWidgets('ekran okuyucu açıkken metnin tamamı bir anda', (tester) async {
    final bitti = await _ciz(tester, ekranOkuyucu: true);
    expect(find.text('Üçüncü paragraf.'), findsOneWidget,
        reason: 'Ekran okuyucu kullanan birine metni parçalamak, '
            'gezinmeyi zorlaştırmak demek.');
    expect(bitti, 1);
  });

  testWidgets('araç modunda tamamı görünüyor', (tester) async {
    // Magaza ekran goruntuleri ve tasma olcumu metnin tamamini gormeli.
    await _ciz(tester, tumunuGoster: true);
    expect(find.text('Üçüncü paragraf.'), findsOneWidget);
  });

  test('DEVAM tuşu anlatımda otomatik açılmıyor', () {
    final src = File('lib/courses/screens/interactive_lesson_screen.dart')
        .readAsStringSync();
    final bas = src.indexOf('bool _canProceed()');
    final govde = src.substring(bas, src.indexOf('\n  }', bas));
    expect(govde.contains('StepType.explanation'), isFalse,
        reason: 'Anlatım adımı yine kendiliğinden geçiyor.');
  });
}
