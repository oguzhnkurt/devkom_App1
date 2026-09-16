@Tags(['overflow'])
library;

// QUIZ EKRANLARI — dort dilde, iki ekran boyunda.
//
// Ders adimlarinin tasma denetimi vardi, quizlerin yoktu. Oysa quiz
// ekrani metni ders adimindan daha dar bir yerlesime koyuyor: soru
// kutusu, dort sik ve altta ilerleme seridi. Almanca birlesik kelimeler
// ve Ispanyolca uzun cumleler asil tasmayi orada uretiyor.
//
// Bu test bir sey CIZIYOR ve Flutter'in kendi tasma hatasini yakaliyor;
// icerik dogrulugu `quiz_localization_test.dart`'ta.
//
//     flutter test --run-skipped --tags overflow test/quiz_ekrani_dort_dil_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/quizzes_data.dart';
import 'package:devkom_app/courses/models/course_model.dart';
import 'package:devkom_app/courses/screens/module_quiz_screen.dart';
import 'package:devkom_app/courses/screens/quiz_screen.dart';
import 'package:devkom_app/providers/settings_provider.dart';

const _boylar = <String, Size>{
  'SE 320x568': Size(320, 568),
  'i8 375x667': Size(375, 667),
};
const _diller = ['tr', 'en', 'de', 'es'];

Future<String?> _ciz(
    WidgetTester tester, Widget ekran, Size boy, String dil) async {
  SharedPreferences.setMockInitialValues({'language_code': dil});
  final settings = SettingsProvider();
  await settings.setLocale(Locale(dil));

  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(dil),
        supportedLocales: const [
          Locale('tr'), Locale('en'), Locale('de'), Locale('es'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ekran,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
  final hata = tester.takeException();
  return hata == null ? null : hata.toString().split('\n').first;
}

void main() {
  testWidgets('modul quizi dort dilde tasmiyor', (tester) async {
    addTearDown(tester.view.reset);
    final tasanlar = <String>[];

    for (final kurs in CoursesData.allCourses) {
      for (final modul in CourseModules.forCourse(kurs.id)) {
        final sorular = ModuleQuizScreen.collectQuestions(modul.lessons);
        if (sorular.isEmpty) continue;
        for (final boy in _boylar.entries) {
          for (final dil in _diller) {
            final hata = await _ciz(
              tester,
              ModuleQuizScreen(
                course: kurs,
                moduleTitle: modul.title,
                questions: sorular,
              ),
              boy.value,
              dil,
            );
            if (hata != null) {
              tasanlar.add('${kurs.id}/${modul.title} @ ${boy.key} [$dil]: $hata');
            }
          }
        }
      }
    }
    expect(tasanlar, isEmpty,
        reason: 'Modul quizinde tasan yerler:\n${tasanlar.join('\n')}');
  });

  testWidgets('ders quizi dort dilde tasmiyor', (tester) async {
    addTearDown(tester.view.reset);
    final tasanlar = <String>[];

    for (final giris in QuizzesData.all.entries) {
      final quiz = giris.value;
      // Ekran bir Lesson istiyor; quizin kendi kimligi yeterli.
      final ders = Lesson(
        id: quiz.lessonId,
        courseId: '',
        title: quiz.lessonId,
        description: '',
        order: 1,
      );
      final kurs = CoursesData.allCourses.first;
      for (final boy in _boylar.entries) {
        for (final dil in _diller) {
          final hata = await _ciz(
            tester,
            QuizScreen(course: kurs, lesson: ders, quiz: quiz),
            boy.value,
            dil,
          );
          if (hata != null) {
            tasanlar.add('${giris.key} @ ${boy.key} [$dil]: $hata');
          }
        }
      }
    }
    expect(tasanlar, isEmpty,
        reason: 'Ders quizinde tasan yerler:\n${tasanlar.join('\n')}');
  });
}
