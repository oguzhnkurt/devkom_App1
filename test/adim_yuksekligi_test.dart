@Tags(['overflow'])
library;

// HANGI DERS ADIMI EKRANA SIGMIYOR — ve ne kadar tasiyor.
//
// `small_screen_overflow_test.dart` yalnizca Flutter'in kendi tasma
// HATASINI yakaliyor: yatay tasma ve dar ekranda patlayan RenderFlex.
// Ama kullanicinin sikayeti o degildi:
//
//   "Tam sigmiyor ekrana, tastigi icin asagi yukari yapmak zorunda
//    kaliyorum. Herkesin telefonu neyse tam sigsin."
//
// Bu bir HATA degil, bir OLCU meselesi: icerik kaydirilabilir bir
// alanda duruyor, hicbir istisna atilmiyor, ama cocuk secenekleri
// gormek icin itmek zorunda kaliyor. Alti yasindaki bir kullanici
// icin gormedigi secenek yok demektir.
//
// Bu test bir sey SINAMIYOR, OLCUYOR. Her ders adimini gercek
// genislikte cizip dogal yuksekligini aliyor ve ders ekraninda o adima
// kalan yukseklikle karsilastiriyor. Cikti, `Sigdir`'in hangi adimlara
// uygulanmasi gerektigini tahmin etmek yerine SOYLUYOR.
//
// Calistirmak icin:
//
//     flutter test --run-skipped --tags overflow test/adim_yuksekligi_test.dart
//
// Tasan adimlar en cok tasandan basa dogru siralaniyor.
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

/// Denenen ekranlar (mantiksal piksel).
const _boylar = <String, Size>{
  'SE 320x568': Size(320, 568),
  'i8 375x667': Size(375, 667),
  '15 393x852': Size(393, 852),
};

/// Ders ekraninin adima BIRAKMADIGI dikey alan.
///
/// Ust cubuk (kapat, baslik, "Adim 8/9", ilerleme cubugu) ve alttaki
/// Onceki/Devam seridi. Olcu ekran goruntusunden alindi; birkac piksel
/// sapmasi sonucu degistirmiyor, cunku tasan adimlar onlarca piksel
/// tasiyor.
const double _kabukYuksekligi = 210;

/// Govdenin yatay dolgusu.
const double _yatayDolgu = 40;

Widget? _adimWidget(LessonStep step, Course course) {
  switch (step.type) {
    case StepType.intro:
      return IntroStepWidget(
          step: step as IntroStep, course: course, isDark: false,
          onComplete: () {});
    case StepType.explanation:
      return ExplanationStepWidget(
          step: step as ExplanationStep, course: course, isDark: false,
          onComplete: () {});
    case StepType.multipleChoice:
      return MultipleChoiceStepWidget(
          step: step as MultipleChoiceStep, course: course, isDark: false,
          onComplete: (_) {});
    case StepType.dragAndDrop:
      return DragDropStepWidget(
          step: step as DragDropStep, course: course, isDark: false,
          onComplete: (_) {});
    case StepType.blockBuilder:
      return BlockBuilderStepWidget(
          step: step as BlockBuilderStep, course: course, isDark: false,
          onComplete: (_) {});
    case StepType.ordering:
      return OrderingStepWidget(
          step: step as OrderingStep, course: course, isDark: false,
          onComplete: (_) {});
    case StepType.matching:
      return MatchingStepWidget(
          step: step as MatchingStep, course: course, isDark: false,
          onComplete: (_) {});
    case StepType.project:
      return ProjectStepWidget(
          step: step as ProjectStep, course: course, isDark: false,
          onComplete: (_) {});
    case StepType.codeComplete:
      return CodeCompleteStepWidget(
          step: step as CodeCompleteStep, course: course, isDark: false,
          onComplete: (_) {});
    case StepType.typeTheCode:
      return TypeCodeStepWidget(
          step: step as TypeCodeStep, course: course, isDark: false,
          onComplete: (_) {});
    case StepType.spotTheError:
      return SpotErrorStepWidget(
          step: step as SpotErrorStep, course: course, isDark: false,
          onComplete: (_) {});
    case StepType.animation:
      return AnimationStepWidget(
          step: step as AnimationStep, course: course, isDark: false,
          onComplete: () {});
    default:
      // MiniGame kendi zamanlayicisini calistiriyor; ayri ele alinmali.
      return null;
  }
}

final _anahtar = GlobalKey();

/// Adimin verilen genislikteki DOGAL yuksekligi.
Future<double?> _yukseklik(
  WidgetTester tester,
  Widget adim,
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
          Locale('tr'), Locale('en'), Locale('de'), Locale('es'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Yukseklik SINIRSIZ: adim ne kadar isterse o kadar alsin,
        // biz de gercekte ne kadar istedigini olcelim.
        home: Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            child: SizedBox(
              width: boy.width - _yatayDolgu,
              child: KeyedSubtree(key: _anahtar, child: adim),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));

  if (tester.takeException() != null) return null; // tasma testinin isi
  final kutu = _anahtar.currentContext?.findRenderObject();
  return kutu is RenderBox && kutu.hasSize ? kutu.size.height : null;
}

void main() {
  testWidgets('ders adimlari ekrana sigiyor mu (olcum)', (tester) async {
    addTearDown(tester.view.reset);

    final tasanlar = <({String kimlik, String ekran, double dogal,
        double alan})>[];
    var olculen = 0;

    for (final kurs in CoursesData.allCourses) {
      for (final modul in CourseModules.forCourse(kurs.id)) {
        for (final ders in modul.lessons) {
          for (final adim in ders.steps) {
            final w = _adimWidget(adim, kurs);
            if (w == null) continue;
            for (final giris in _boylar.entries) {
              final h = await _yukseklik(tester, w, giris.value, 'tr');
              if (h == null) continue;
              olculen++;
              final alan = giris.value.height - _kabukYuksekligi;
              if (h > alan) {
                tasanlar.add((
                  kimlik: '${kurs.id}/${ders.id}/${adim.id}',
                  ekran: giris.key,
                  dogal: h,
                  alan: alan,
                ));
              }
            }
          }
        }
      }
    }

    tasanlar.sort((a, b) =>
        (b.dogal - b.alan).compareTo(a.dogal - a.alan));

    // ignore: avoid_print
    print('\n=== OLCUM: $olculen adim-ekran cizildi, '
        '${tasanlar.length} tanesi sigmiyor ===');
    for (final t in tasanlar) {
      final oran = (t.alan / t.dogal);
      // ignore: avoid_print
      print('${(t.dogal - t.alan).toStringAsFixed(0).padLeft(5)} px fazla  '
          '| olcek ${oran.toStringAsFixed(2)}  '
          '| ${t.ekran}  | ${t.kimlik}');
    }

    // Bu test DUSMUYOR: amaci bir kurali korumak degil, listeyi
    // cikarmak. Sigdir hangi adimlara uygulanacaksa bu listeden
    // secilecek — ve olcek 0.55'in altina dusen adimlar kucultmeyle
    // degil, tasarimla duzelmeli.
    expect(olculen, greaterThan(0),
        reason: 'Hicbir adim cizilemediyse olcum bir sey soylemiyor.');
  });
}
