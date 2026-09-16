// W3 ekran ailesi silindi; geri sizmasin diye kilit.
//
// Neden silindi: zincirin tamami (`W3ChapterListScreen` ->
// `W3LessonListScreen` -> `W3LessonDetailScreen` -> `W3ScratchWorkspace`)
// uygulamadan ERISILEMIYORDU. Oraya giden tek referans derlenmeyen bir
// `.bak` dosyasindaydi; ana sayfadaki "Tum Kurslar" tusunun actigi
// `W3CoursesScreen` ise zaten `CourseCatalogScreen`'e yonlendiriyordu.
// Ikinci ve daha kotu bir blok kurma arayuzu (duz liste, Turkce sabit
// metinler) orada yasiyordu.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('W3 dosyalari geri gelmemis', () {
    const silinenler = [
      'lib/screens/w3_chapter_list_screen.dart',
      'lib/screens/w3_code_editor_screen.dart',
      'lib/screens/w3_courses_screen.dart',
      'lib/screens/w3_lesson_detail_screen.dart',
      'lib/screens/w3_lesson_list_screen.dart',
      'lib/screens/w3_profile_screen.dart',
      'lib/screens/w3_quiz_screen.dart',
      'lib/widgets/w3_widgets.dart',
      'lib/models/w3_lesson_model.dart',
      'lib/data/w3_sample_data.dart',
      'lib/services/interactive_lessons_converter.dart',
    ];
    final duranlar =
        silinenler.where((y) => File(y).existsSync()).toList();
    expect(duranlar, isEmpty,
        reason: 'Erisilemeyen W3 ailesi geri eklenmis: $duranlar');
  });

  test('kaynakta W3 referansi kalmamis', () {
    final kalanlar = <String>[];
    final desen = RegExp(r'\bW3[A-Z]\w*|w3_\w+\.dart');
    for (final e in Directory('lib').listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      final m = desen.firstMatch(e.readAsStringSync());
      if (m != null) kalanlar.add('${e.path} -> ${m.group(0)}');
    }
    expect(kalanlar, isEmpty);
  });

  test('ana sayfa dogrudan kurs kataloguna gidiyor', () {
    final s = File('lib/screens/unified_home_screen.dart').readAsStringSync();
    expect(s.contains('const CourseCatalogScreen()'), isTrue);
    expect(s.contains('W3CoursesScreen'), isFalse);
  });
}
