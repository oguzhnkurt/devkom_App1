import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/providers/settings_provider.dart';

/// Proje adimi dogru sey soyluyor mu?
///
/// Eski hali: gereksinimler, ipuclari ve "Projeyi Tamamladim!" dugmesi.
/// Arada calisma alani yoktu; `starterCode` ve `validation` hicbir
/// yerden okunmuyordu. Cocuk hicbir sey yapmadan dugmeye basip 40 XP
/// aliyordu — ekranda duran cumle yalandi.
///
/// Uygulama ici editor gelene kadar dogru olan sey bunu saklamak degil,
/// dogru soylemek. Bu test o sozu koruyor.
const _proje = ProjectStep(
  id: 'x1',
  title: 'Mini Proje',
  description: 'Uc kukla dans etsin',
  requirements: ['Birinci', 'Ikinci'],
  hints: ['Ipucu'],
  starterCode: '',
  language: 'scratch',
  validation: ProjectValidation(mustContain: []),
  xpReward: 40,
);

Future<Widget> _kabuk(void Function(bool) onComplete) async {
  // Ders metni dili SettingsProvider'dan geliyor; testte cihaz dili
  // Ingilizce oldugu icin acikca Turkceye alinmali.
  SharedPreferences.setMockInitialValues({'language_code': 'tr'});
  final settings = SettingsProvider();
  await settings.setLocale(const Locale('tr'));
  return ChangeNotifierProvider<SettingsProvider>.value(
    value: settings,
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ProjectStepWidget(
            step: _proje,
            course: CoursesData.allCourses.first,
            isDark: false,
            onComplete: onComplete,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('cocuga nerede yapacagi soyleniyor', (tester) async {
    await tester.pumpWidget(await _kabuk((_) {}));
    await tester.pump();
    expect(find.textContaining('bilgisayar'), findsWidgets);
    expect(find.textContaining('scratch.mit.edu'), findsOneWidget);
  });

  testWidgets('gereksinimler isaretlenmeden "Yaptim" basilamiyor',
      (tester) async {
    bool? sonuc;
    await tester.pumpWidget(await _kabuk((v) => sonuc = v));
    await tester.pump();

    final yaptim = find.widgetWithText(ElevatedButton, 'Yaptım');
    expect(yaptim, findsOneWidget);
    expect(tester.widget<ElevatedButton>(yaptim).onPressed, isNull,
        reason: 'Hicbir sey isaretlemeden "Yaptim" acik olmamali.');

    await tester.tap(find.text('Birinci'));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(yaptim).onPressed, isNull);

    await tester.tap(find.text('Ikinci'));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(yaptim).onPressed, isNotNull);

    await tester.tap(yaptim);
    await tester.pump();
    expect(sonuc, isTrue);
  });

  testWidgets('"Sonra yaparim" her zaman acik ve XP vermiyor',
      (tester) async {
    bool? sonuc;
    await tester.pumpWidget(await _kabuk((v) => sonuc = v));
    await tester.pump();

    // Bilgisayar basinda olmayan cocuk dersin geri kalanina kilitlenmesin.
    final sonra = find.text('Sonra yaparım');
    expect(sonra, findsOneWidget);
    await tester.tap(sonra);
    await tester.pump();
    expect(sonuc, isFalse);
  });

  test('ekranda "tamamladim" iddiasi kalmadi', () {
    final kod = File('lib/courses/screens/widgets/step_widgets.dart')
        .readAsLinesSync()
        .where((s) => !s.trimLeft().startsWith('//'))
        .join('\n');
    expect(kod.contains('Projeyi Tamamladim!'), isFalse);
    expect(kod.contains('Projeyi Tamamladım!'), isFalse);
  });

  test('XP yalnizca "Yaptim" denince veriliyor', () {
    final kod = File('lib/courses/screens/interactive_lesson_screen.dart')
        .readAsLinesSync()
        .where((s) => !s.trimLeft().startsWith('//'))
        .join('\n');
    expect(kod.contains('yapti ? step.xpReward : 0'), isTrue);
  });
}
