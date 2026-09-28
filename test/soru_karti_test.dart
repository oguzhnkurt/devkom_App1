import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/course_model.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/providers/settings_provider.dart';

/// Soru karti KURSUN kimligini tasisin.
///
/// ONCEDEN: beyaz bir kutu, ortasinda 40 puntoluk bir dusunen yuz
/// emojisi ve altinda soru. Her kursta ayniydi — CSS dersi ile Java
/// dersi ayirt edilemiyordu, ekran "ders" degil "form" gibi duruyordu.
/// Emoji de her soruda ayni seyi soyluyordu: hicbir sey.
///
/// Simdi kart kursun degradesini tasiyor ve kose rozetinde KURSUN
/// simgesi duruyor.
const _adim = MultipleChoiceStep(
  id: 'soru_deneme',
  question: 'CSS ne işe yarar?',
  questionEn: 'What is CSS for?',
  options: [
    ChoiceOption(text: 'Sayfanın görünümünü değiştirir', textEn: 'Styling'),
    ChoiceOption(text: 'Veritabanına bağlanır', textEn: 'Database'),
  ],
  correctIndex: 0,
  explanation: 'CSS görünümü düzenler.',
  explanationEn: 'CSS styles the page.',
);

Future<void> _ciz(WidgetTester tester, Course kurs) async {
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
            child: MultipleChoiceStepWidget(
              step: _adim,
              course: kurs,
              isDark: false,
              onComplete: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final css = CoursesData.allCourses.firstWhere((c) => c.id == 'css');
  final python = CoursesData.allCourses.firstWhere((c) => c.id == 'python');

  testWidgets('soru kartinda kursun simgesi var, genel emoji yok',
      (tester) async {
    await _ciz(tester, css);
    expect(find.text(css.icon), findsOneWidget,
        reason: 'Kart kursun simgesini tasimali.');
    expect(find.text('🤔'), findsNothing,
        reason: 'Her kursta ayni duran genel emoji kaldirildi.');
  });

  testWidgets('kart kursun rengini tasiyor', (tester) async {
    await _ciz(tester, css);

    final kutular = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.decoration is BoxDecoration)
        .map((c) => c.decoration as BoxDecoration)
        .where((d) => d.gradient is LinearGradient)
        .toList();

    expect(kutular, isNotEmpty, reason: 'Degradeli soru karti yok.');
    final renkler = (kutular.first.gradient as LinearGradient).colors;
    expect(renkler, contains(css.primaryColor));
    expect(renkler, contains(css.secondaryColor));
  });

  testWidgets('iki farkli kurs iki farkli kart veriyor', (tester) async {
    // Asil sikayet buydu: butun kurslarda ayni ekran.
    await _ciz(tester, css);
    expect(find.text(css.icon), findsOneWidget);

    await _ciz(tester, python);
    expect(find.text(python.icon), findsOneWidget);
    expect(find.text(css.icon), findsNothing);
  });

  testWidgets('soru ve siklar okunuyor', (tester) async {
    await _ciz(tester, css);
    expect(find.text('CSS ne işe yarar?'), findsOneWidget);
    expect(find.text('Veritabanına bağlanır'), findsOneWidget,
        reason: 'Turkce karakterler yerinde olmali.');
  });
}
