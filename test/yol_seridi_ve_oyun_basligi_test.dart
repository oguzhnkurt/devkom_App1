// Iki gorunur kusur:
//
// 1. Ana sayfadaki "Yolun" seridinde bir OYNAT ucgeni vardi ama hicbir
//    seye goturmuyordu — cocuk basiyor, hicbir sey olmuyordu.
// 2. Oyunlar sayfasinin baslik cubugu sayfanin zemin rengiyle ayniydi;
//    sol ustteki geri oku fark edilmiyordu. Ustelik baslik tek dildi.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/models/learner_profile.dart';
import 'package:devkom_app/services/next_lesson_service.dart';

void main() {
  group('yol seridi', () {
    test('her nokta kendi kursunu tasiyor', () {
      // Kurs olmadan noktaya dokunmak dersi ACAMAZ; serit bu yuzden
      // olu bir suslemeydi.
      final nodes =
          NextLessonService.strip(const LearnerProfile(), <String>{});
      expect(nodes, isNotEmpty);
      final kursKimlikleri =
          CoursesData.allCourses.map((k) => k.id).toSet();
      for (final n in nodes) {
        expect(kursKimlikleri.contains(n.course.id), isTrue,
            reason: '${n.lesson.id} var olmayan bir kursa bagli');
      }
    });

    test('nokta dersi gercekten aciyor', () {
      final s =
          File('lib/screens/unified_home_screen.dart').readAsStringSync();
      final bas = s.indexOf('Widget _buildPathNode(');
      expect(bas, greaterThan(0));
      final govde = s.substring(bas, s.indexOf('\n  }\n', bas));
      expect(govde.contains('onTap:'), isTrue,
          reason: 'Serit noktasi hala dokunmaya tepki vermiyor.');
      expect(govde.contains('InteractiveLessonScreen('), isTrue);
      expect(govde.contains('course: node.course'), isTrue);
    });
  });

  group('oyunlar baslik cubugu', () {
    late String kaynak;
    setUpAll(() {
      kaynak =
          File('lib/screens/robotics_games_screen.dart').readAsStringSync();
    });

    test('cubuk zeminle ayni renkte degil', () {
      final bas = kaynak.indexOf('PreferredSizeWidget _buildAppBar()');
      final govde = kaynak.substring(bas, kaynak.indexOf('\n  }\n', bas));
      expect(govde.contains('backgroundColor: AppTheme.lightGray'), isFalse,
          reason: 'Baslik cubugu yine sayfa zemini ile ayni renkte.');
      expect(govde.contains('foregroundColor: Colors.white'), isTrue,
          reason: 'Geri oku beyaz degil — koyu cubukta gorunmez.');
    });

    test('baslik ve arama ipucu dort dilde', () {
      expect(kaynak.contains("title: const Text('Oyunlar')"), isFalse);
      for (final yazi in const [
        "tr: 'Oyunlar'",
        "en: 'Games'",
        "de: 'Spiele'",
        "es: 'Juegos'",
        "tr: 'Oyun ara'",
        "en: 'Search games'",
      ]) {
        expect(kaynak.contains(yazi), isTrue, reason: 'eksik: $yazi');
      }
    });
  });
}
