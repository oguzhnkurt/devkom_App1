import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/models/learner_profile.dart';
import 'package:devkom_app/services/learning_path_service.dart';
import 'package:devkom_app/services/next_lesson_service.dart';

/// Ana sayfanin tek baskin eylemi buradan geliyor: "siradaki ders".
/// Yanlis ders onerirsek cocuk ya bildigi bir dersi tekrar yapiyor ya da
/// hazir olmadigi bir yere atliyor — ikisi de sessiz hatalar, ekranda
/// hicbir sey kirilmis gorunmuyor. Bu yuzden mantigi ayrica sinamak sart.
void main() {
  const emptyProfile = LearnerProfile();

  LearnerProfile profileOf({
    LearnerAgeBand? age,
    SkillLevel? level,
    LearningGoal? goal,
  }) =>
      LearnerProfile(ageBand: age, skillLevel: level, goal: goal);

  group('resolve', () {
    test('hic ders bitmemisken yolun ilk dersini verir', () {
      final step = NextLessonService.resolve(emptyProfile, {});
      expect(step, isNotNull);
      expect(step!.isFirstEver, isTrue);
      expect(step.indexInCourse, 1);
      expect(step.completedInCourse, 0);

      // Yolun gercekten ilk kursunun ilk dersi mi?
      final path = LearningPathService.buildPath(emptyProfile);
      final firstCourseWithLessons = path.firstWhere(
        (c) => CourseModules.allLessons(c.id).isNotEmpty,
      );
      expect(step.course.id, firstCourseWithLessons.id);
      expect(step.lesson.id,
          CourseModules.allLessons(firstCourseWithLessons.id).first.id);
    });

    test('ilk ders bitince ikinci dersi verir', () {
      final first = NextLessonService.resolve(emptyProfile, {})!;
      final lessons = CourseModules.allLessons(first.course.id);
      // Bu kursta en az iki ders olmali, yoksa test bir sey olcmuyor.
      expect(lessons.length, greaterThan(1));

      final step = NextLessonService.resolve(emptyProfile, {first.lesson.id})!;
      expect(step.lesson.id, lessons[1].id);
      expect(step.indexInCourse, 2);
      expect(step.completedInCourse, 1);
      expect(step.isFirstEver, isFalse);
    });

    test('bir kurs tamamen bitince sonraki kursa gecer', () {
      final first = NextLessonService.resolve(emptyProfile, {})!;
      final done =
          CourseModules.allLessons(first.course.id).map((l) => l.id).toSet();

      final step = NextLessonService.resolve(emptyProfile, done)!;
      expect(step.course.id, isNot(first.course.id));
      expect(step.indexInCourse, 1);
    });

    test('yoldaki her ders bitmisse null doner', () {
      final all = <String>{};
      for (final c in LearningPathService.buildPath(emptyProfile)) {
        all.addAll(CourseModules.allLessons(c.id).map((l) => l.id));
      }
      expect(NextLessonService.resolve(emptyProfile, all), isNull);
    });

    test('profil hedefe gore farkli bir kursla baslayabilir', () {
      // Robotik hedefi olan, blok bilen bir cocuk ile hicbir sey belirtmemis
      // bir cocugun yolu ayni olmak zorunda degil; onemli olan ikisinin de
      // gecerli bir ilk ders almasi.
      final robotics = NextLessonService.resolve(
        profileOf(
          age: LearnerAgeBand.age10to12,
          level: SkillLevel.someBlocks,
          goal: LearningGoal.robotics,
        ),
        {},
      );
      expect(robotics, isNotNull);
      expect(robotics!.indexInCourse, 1);
      expect(robotics.courseLessonCount, greaterThan(0));
    });

    test('kurs ilerlemesi 0 ile 1 arasinda kalir', () {
      final first = NextLessonService.resolve(emptyProfile, {})!;
      expect(first.courseProgress, 0);

      final lessons = CourseModules.allLessons(first.course.id);
      final half = lessons.take(lessons.length ~/ 2).map((l) => l.id).toSet();
      final mid = NextLessonService.resolve(emptyProfile, half)!;
      expect(mid.courseProgress, greaterThan(0));
      expect(mid.courseProgress, lessThan(1));
    });
  });

  group('strip', () {
    test('istenen sayida dugum doner', () {
      final nodes = NextLessonService.strip(emptyProfile, {}, size: 5);
      expect(nodes.length, 5);
    });

    test('tam olarak bir dugum "simdiki" olarak isaretli', () {
      final nodes = NextLessonService.strip(emptyProfile, {});
      expect(nodes.where((n) => n.current).length, 1);
    });

    test('bastayken simdiki dugum ilk siradadir', () {
      final nodes = NextLessonService.strip(emptyProfile, {});
      expect(nodes.first.current, isTrue);
      // Geri kalanlar ilerideki dersler: kilitli degil, onizleme.
      expect(nodes.skip(1).every((n) => n.upcoming), isTrue);
    });

    test('ilerledikce bitmis dugumler solda birikir', () {
      final first = NextLessonService.resolve(emptyProfile, {})!;
      final lessons = CourseModules.allLessons(first.course.id);
      final done = lessons.take(3).map((l) => l.id).toSet();

      final nodes = NextLessonService.strip(emptyProfile, done);
      expect(nodes.any((n) => n.done), isTrue);

      // Bitmisler her zaman simdikinin solunda olmali.
      final currentIndex = nodes.indexWhere((n) => n.current);
      for (var i = 0; i < nodes.length; i++) {
        if (nodes[i].done) expect(i, lessThan(currentIndex));
      }
    });

    test('dugum durumlari birbirini dislar', () {
      final nodes = NextLessonService.strip(emptyProfile, {});
      for (final n in nodes) {
        final flags = [n.done, n.current, n.upcoming].where((f) => f).length;
        expect(flags, 1, reason: 'bir dugum ayni anda iki durumda olamaz');
      }
    });
  });
}
