// Regresyon: blok görsellerinin üstündeki yazılar.
//
// BU HATA BİR KEZ "DÜZELTİLDİ" SANILDI VE GERİ GELDİ
// ---------------------------------------------------
// Ders adımlarındaki görsel öğelerin (Scratch blokları, kod parçaları)
// üstünde çocuğa görünen bir yazı var. Sırasıyla iki şey oldu:
//
//  1. Modelde bu yazıların çeviri alanı hiç yoktu; `contentEn` /
//     `labelEn` eklendi.
//  2. Alan eklendi ama ÇİZİM yapan yardımcılar hâlâ ham `visual.content`
//     okuyordu. `_buildVisual` çeviriyi hesaplayıp bir yerel değişkene
//     yazıyor, sonra kullanmadan bırakıyordu. Yani model doğru, çağrı
//     doğru, ekran hâlâ Türkçe.
//
// İkincisini yalnızca analyzer'ın "kullanılmayan değişken" uyarısı ele
// verdi. Bu test o uyarıya güvenmek yerine ekranın kendisine bakıyor:
// İngilizce seçiliyken blok yazısı İngilizce mi, Türkçe metin ekranda
// KALMIYOR mu.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/courses/models/course_model.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';

const _course = Course(
  id: 'test',
  name: 'Test',
  slug: 'test',
  description: 'Test',
  icon: '🧩',
  primaryColor: Color(0xFF4C97FF),
  secondaryColor: Color(0xFF4C97FF),
  category: CourseCategory.kids,
  difficulty: DifficultyLevel.beginner,
  tags: [],
  totalLessons: 1,
  estimatedMinutes: 1,
  sortOrder: 1,
);

final _step = ExplanationStep(
  id: 'x',
  title: 'Başlık',
  titleEn: 'Title',
  content: 'Gövde',
  contentEn: 'Body',
  visuals: [
    VisualElement(
      type: VisualType.scratchBlock,
      content: '10 adım git',
      contentEn: 'move 10 steps',
      label: 'Hareket bloğu',
      labelEn: 'Motion block',
      color: Color(0xFF4C97FF),
    ),
    VisualElement(
      type: VisualType.codeSnippet,
      content: 'yaz("merhaba")',
      contentEn: 'print("hello")',
    ),
  ],
);

Future<void> _pump(WidgetTester tester, String lang) async {
  SharedPreferences.setMockInitialValues({'language_code': lang});
  final settings = SettingsProvider();
  await settings.setLocale(Locale(lang));

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExplanationStepWidget(
              tumunuGoster: true,
              step: _step,
              course: _course,
              isDark: false,
              onComplete: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Ingilizcede blok gorselleri Ingilizce yaziyor', (tester) async {
    await _pump(tester, 'en');

    expect(find.text('move 10 steps'), findsOneWidget);
    expect(find.text('Motion block'), findsOneWidget);
    expect(find.text('print("hello")'), findsOneWidget);

    // Asil sart: Turkce metin ekranda KALMAMALI.
    expect(find.text('10 adım git'), findsNothing);
    expect(find.text('Hareket bloğu'), findsNothing);
    expect(find.text('yaz("merhaba")'), findsNothing);
  });

  testWidgets('Turkcede blok gorselleri Turkce kaliyor', (tester) async {
    await _pump(tester, 'tr');

    expect(find.text('10 adım git'), findsOneWidget);
    expect(find.text('Hareket bloğu'), findsOneWidget);
    expect(find.text('yaz("merhaba")'), findsOneWidget);
    expect(find.text('move 10 steps'), findsNothing);
  });

  testWidgets('Almanca cevirisi yoksa Ingilizceye duser', (tester) async {
    // Almanca ders metni henuz yok; dogru davranis Turkce degil
    // Ingilizce gostermek.
    await _pump(tester, 'de');

    expect(find.text('move 10 steps'), findsOneWidget);
    expect(find.text('10 adım git'), findsNothing);
  });
}
