// İngilizce seçiliyken ekranda Türkçe kalıyor mu?
//
// NEDEN GEREKLİ
// -------------
// Ders içeriğinin İngilizcesi %100 olduktan sonra bile çocuk ekranda
// Türkçe görüyordu. Sebep içerikte değil, ARAYÜZDEYDİ:
//
//  * Blok görsellerinin çizimi çeviriyi hesaplayıp kullanmıyordu.
//  * `ScratchBlockWidget` doğrudan `block.label` okuyordu.
//  * Yardımcının argümanı Türkçe kalıyordu:
//    "set digital pin 9 output as yüksek".
//  * Adım ekranlarında sabit Türkçe yazılar vardı ("Kod Alanı:",
//    "Kullanılabilir Bloklar:", "Koşullar", "Sonuçlar"...).
//
// Bu hataların hiçbiri veri tarafında görünmüyor: `report` "%100" diyor,
// ekran Türkçe. Bu yüzden test EKRANA bakıyor — gerçek ders verisinden
// her adım tipini çizip, çıkan her yazıda Türkçeye özgü harf arıyor.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/models/course_model.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';

/// Türkçeye özgü harfler. İngilizce bir ekranda hiçbiri görünmemeli.
const _turkishLetters = 'çÇğĞıİöÖşŞüÜ';

/// Adımı, ders ekranının kullandığı widget'a bağlar.
Widget? _widgetFor(LessonStep step, Course course) {
  return switch (step) {
    IntroStep s =>
      IntroStepWidget(step: s, course: course, onComplete: () {}),
    ExplanationStep s => ExplanationStepWidget(
        step: s, course: course, isDark: false, onComplete: () {}),
    MultipleChoiceStep s => MultipleChoiceStepWidget(
        step: s, course: course, isDark: false, onComplete: (_) {}),
    DragDropStep s => DragDropStepWidget(
        step: s, course: course, isDark: false, onComplete: (_) {}),
    BlockBuilderStep s => BlockBuilderStepWidget(
        step: s, course: course, isDark: false, onComplete: (_) {}),
    OrderingStep s => OrderingStepWidget(
        step: s, course: course, isDark: false, onComplete: (_) {}),
    MatchingStep s => MatchingStepWidget(
        step: s, course: course, isDark: false, onComplete: (_) {}),
    CodeCompleteStep s => CodeCompleteStepWidget(
        step: s, course: course, isDark: false, onComplete: (_) {}),
    TypeCodeStep s => TypeCodeStepWidget(
        step: s, course: course, isDark: false, onComplete: (_) {}),
    SpotErrorStep s => SpotErrorStepWidget(
        step: s, course: course, isDark: false, onComplete: (_) {}),
    _ => null,
  };
}

/// Uygulamadaki HER kursun HER dersinin HER adımı.
///
/// Örnekleme yapmıyoruz: tamamı yaklaşık 7 saniyede çiziliyor, örnekleme
/// ise "o adım örneğe düşmedi" diye kaçan hata demek.
List<(Course, LessonStep)> _allSteps() {
  final out = <(Course, LessonStep)>[];
  for (final course in CoursesData.allCourses) {
    for (final module in CourseModules.forCourse(course.id)) {
      for (final lesson in module.lessons) {
        for (final step in lesson.steps) {
          out.add((course, step));
        }
      }
    }
  }
  return out;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Ingilizce ekranda Turkce metin kalmiyor', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'en'});
    final settings = SettingsProvider();
    await settings.setLocale(const Locale('en'));

    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final problems = <String>[];
    final overflows = <String>[];

    // Taşma hatalarını ADIMA BAĞLAYARAK topluyoruz. Flutter bunları
    // konsola döküyor ama hangi adımda olduğunu söylemiyor; öyle olunca
    // "bir yerde taşma var" deyip bırakmak zorunda kalıyorsun.
    final previousOnError = FlutterError.onError;
    String? current;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed by')) {
        final px = RegExp(r'overflowed by ([\d.]+) pixels').firstMatch(text);
        overflows.add('$current -> ${px?.group(1) ?? '?'} px');
      } else {
        previousOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    for (final (course, step) in _allSteps()) {
      final child = _widgetFor(step, course);
      if (child == null) continue;
      current = '${course.id} / ${step.id} (${step.runtimeType})';

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: child),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));

      for (final t in tester.widgetList<Text>(find.byType(Text))) {
        final text = t.data ?? t.textSpan?.toPlainText() ?? '';
        for (final ch in _turkishLetters.split('')) {
          if (text.contains(ch)) {
            problems.add('${course.id} / ${step.id} '
                '(${step.runtimeType}): "$text"');
            break;
          }
        }
      }
    }

    expect(problems, isEmpty,
        reason: 'Ingilizce secilmisken ekranda Turkce metin var '
            '(${problems.length} yer):\n${problems.take(40).join('\n')}');

    // Ingilizce metin Turkcesinden uzun; tasma once burada goruluyor.
    expect(overflows, isEmpty,
        reason: 'Ingilizce metin ekrandan tasiyor '
            '(${overflows.length} yer):\n${overflows.toSet().take(30).join('\n')}');
  });

  testWidgets('Turkce ekranda da tasma yok', (tester) async {
    // Türkçe birincil dil; İngilizce için yapılan esneklik düzeltmeleri
    // Türkçeyi bozmasın diye aynı tarama burada da koşuyor.
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final settings = SettingsProvider();
    await settings.setLocale(const Locale('tr'));

    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final overflows = <String>[];
    final previousOnError = FlutterError.onError;
    String? current;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed by')) {
        final px = RegExp(r'overflowed by ([\d.]+) pixels').firstMatch(text);
        overflows.add('$current -> ${px?.group(1) ?? '?'} px');
      } else {
        previousOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    for (final (course, step) in _allSteps()) {
      final child = _widgetFor(step, course);
      if (child == null) continue;
      current = '${course.id} / ${step.id} (${step.runtimeType})';

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
          child: MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: child)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));
    }

    expect(overflows, isEmpty,
        reason: 'Turkce ekranda tasma '
            '(${overflows.length} yer):\n${overflows.toSet().take(30).join('\n')}');
  });
}
