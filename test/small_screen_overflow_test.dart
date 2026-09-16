@Tags(['overflow'])
library;

// KUCUK EKRAN TASMA DENETIMI — her ders adimini iPhone SE boyunda cizer.
//
// Sikayet: "telefonların ekranına göre optimize olmuyor, aşağı
// kaydırılıyor, birçok derste ve oyunda". Icerik zaten kaydirilabilir
// bir alanda; asil sorun YATAY tasma ve sabit yuksekliklerin dar
// ekranda RenderFlex hatasi uretmesi. Flutter bu hatayi cizim aninda
// firlatiyor, yani bir test bunu yakalayabilir.
//
// Normal `flutter test` kosusunda CALISMAZ (etiket hariç tutulur).
// Elle calistirmak icin:
//
//     flutter test --run-skipped --tags overflow test/small_screen_overflow_test.dart
//
// Cikti: tasan her adimin kurs/ders/adim kimligi ve ekran boyu.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/models/course_model.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/providers/settings_provider.dart';

/// Denenen ekran boylari (mantiksal piksel).
const _boylar = <String, Size>{
  'iPhone SE (320x568)': Size(320, 568),
  'iPhone 8 (375x667)': Size(375, 667),
};

Widget? _adimWidget(LessonStep step, Course course) {
  switch (step.type) {
    case StepType.intro:
      return IntroStepWidget(
          step: step as IntroStep,
          course: course,
          isDark: false,
          onComplete: () {});
    case StepType.explanation:
      return ExplanationStepWidget(
          step: step as ExplanationStep,
          course: course,
          isDark: false,
          onComplete: () {});
    case StepType.multipleChoice:
      return MultipleChoiceStepWidget(
          step: step as MultipleChoiceStep,
          course: course,
          isDark: false,
          onComplete: (_) {});
    case StepType.dragAndDrop:
      return DragDropStepWidget(
          step: step as DragDropStep,
          course: course,
          isDark: false,
          onComplete: (_) {});
    case StepType.blockBuilder:
      return BlockBuilderStepWidget(
          step: step as BlockBuilderStep,
          course: course,
          isDark: false,
          onComplete: (_) {});
    case StepType.ordering:
      return OrderingStepWidget(
          step: step as OrderingStep,
          course: course,
          isDark: false,
          onComplete: (_) {});
    case StepType.matching:
      return MatchingStepWidget(
          step: step as MatchingStep,
          course: course,
          isDark: false,
          onComplete: (_) {});
    case StepType.project:
      return ProjectStepWidget(
          step: step as ProjectStep,
          course: course,
          isDark: false,
          onComplete: () {});
    case StepType.codeComplete:
      return CodeCompleteStepWidget(
          step: step as CodeCompleteStep,
          course: course,
          isDark: false,
          onComplete: (_) {});
    case StepType.typeTheCode:
      return TypeCodeStepWidget(
          step: step as TypeCodeStep,
          course: course,
          isDark: false,
          onComplete: (_) {});
    case StepType.spotTheError:
      return SpotErrorStepWidget(
          step: step as SpotErrorStep,
          course: course,
          isDark: false,
          onComplete: (_) {});
    case StepType.animation:
      return AnimationStepWidget(
          step: step as AnimationStep,
          course: course,
          isDark: false,
          onComplete: () {});
    default:
      // MiniGame zamanlayici calistiriyor; ayri ele alinmali.
      return null;
  }
}

Future<String?> _ciz(
  WidgetTester tester,
  Widget child,
  Size boy,
  String lang,
) async {
  SharedPreferences.setMockInitialValues({'language_code': lang});
  final settings = SettingsProvider();
  await settings.setLocale(Locale(lang));

  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));

  final hata = tester.takeException();
  return hata == null ? null : hata.toString().split('\n').first;
}

void main() {
  testWidgets('ders adimlari kucuk ekranda tasmiyor', (tester) async {
    addTearDown(tester.view.reset);
    final tasanlar = <String>[];

    for (final kurs in CoursesData.allCourses) {
      for (final modul in CourseModules.forCourse(kurs.id)) {
        for (final ders in modul.lessons) {
          for (final adim in ders.steps) {
            final w = _adimWidget(adim, kurs);
            if (w == null) continue;
            for (final giris in _boylar.entries) {
              final hata = await _ciz(tester, w, giris.value, 'tr');
              if (hata != null) {
                tasanlar.add('${kurs.id}/${ders.id}/${adim.id} '
                    '@ ${giris.key}: $hata');
              }
            }
          }
        }
      }
    }

    expect(tasanlar, isEmpty,
        reason: 'Kucuk ekranda tasan adimlar:\n${tasanlar.join('\n')}');
  });
}
