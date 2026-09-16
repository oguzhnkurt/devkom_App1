import '../courses/data/course_modules.dart';
import '../courses/models/course_model.dart';
import '../courses/models/interactive_lesson_model.dart';
import '../models/learner_profile.dart';
import 'learning_path_service.dart';

/// Cocugun su anda yapmasi gereken tek ders.
class NextStep {
  const NextStep({
    required this.course,
    required this.lesson,
    required this.indexInCourse,
    required this.courseLessonCount,
    required this.completedInCourse,
    required this.isFirstEver,
  });

  final Course course;
  final InteractiveLesson lesson;

  /// Dersin kurs icindeki sirasi (1'den baslar).
  final int indexInCourse;

  final int courseLessonCount;

  /// Bu kursta tamamlanmis ders sayisi.
  final int completedInCourse;

  /// Cocuk hic ders bitirmemis mi? Ana sayfa bos durumu buna gore kuruyor.
  final bool isFirstEver;

  double get courseProgress =>
      courseLessonCount == 0 ? 0 : completedInCourse / courseLessonCount;
}

/// "Kaldigin yerden devam et" hesabi.
///
/// Ana sayfa bugune kadar bir DURUM PANOSUYDU: seviye, XP, gunluk hedef,
/// rozetler... Yeni bir cocukta hepsi sifir gosteriyor ve ekranda
/// "simdi ne yapayim" sorusunun cevabi hicbir yerde yoktu. Rakip
/// uygulamalarin degerlendirmelerinde en cok ovulen sey tam tersi:
/// tek bir belirgin sonraki adim.
///
/// Burasi o adimi hesapliyor: cocugun kisisel yolundaki ilk bitmemis ders.
class NextLessonService {
  NextLessonService._();

  /// [profile] ve tamamlanmis ders kimliklerinden sonraki adimi bulur.
  ///
  /// Yoldaki tum dersler bitmisse null doner (o zaman ana sayfa "hepsini
  /// bitirdin" durumunu gosteriyor).
  static NextStep? resolve(
    LearnerProfile profile,
    Set<String> completedLessonIds,
  ) {
    final path = LearningPathService.buildPath(profile);
    final isFirstEver = completedLessonIds.isEmpty;

    for (final course in path) {
      final lessons = CourseModules.allLessons(course.id);
      if (lessons.isEmpty) continue;

      final completedInCourse =
          lessons.where((l) => completedLessonIds.contains(l.id)).length;

      for (var i = 0; i < lessons.length; i++) {
        if (completedLessonIds.contains(lessons[i].id)) continue;
        return NextStep(
          course: course,
          lesson: lessons[i],
          indexInCourse: i + 1,
          courseLessonCount: lessons.length,
          completedInCourse: completedInCourse,
          isFirstEver: isFirstEver,
        );
      }
    }
    return null;
  }

  /// Ana sayfadaki yol seridi icin: siradaki dersin etrafindaki birkac ders.
  ///
  /// Ilerlemeyi bir SAYI olarak degil, bir YOL olarak gostermek icin.
  /// Kucuk bir cocuk "0 XP" ifadesini okuyamiyor ama sonu gelmemis bir
  /// patikada nerede oldugunu tek bakista goruyor.
  static List<PathNode> strip(
    LearnerProfile profile,
    Set<String> completedLessonIds, {
    int size = 5,
  }) {
    final path = LearningPathService.buildPath(profile);
    final lessons = <InteractiveLesson>[];
    for (final course in path) {
      lessons.addAll(CourseModules.allLessons(course.id));
      if (lessons.length > 60) break; // Seridi hesaplamak icin bu fazlasiyla yeter.
    }
    if (lessons.isEmpty) return const [];

    var currentIndex = lessons.indexWhere(
      (l) => !completedLessonIds.contains(l.id),
    );
    if (currentIndex < 0) currentIndex = lessons.length - 1;

    // Simdiki adim seridin ortasina yakin dursun; basta ve sonda tasmasin.
    var start = currentIndex - (size ~/ 2);
    if (start < 0) start = 0;
    var end = start + size;
    if (end > lessons.length) {
      end = lessons.length;
      start = end - size < 0 ? 0 : end - size;
    }

    return [
      for (var i = start; i < end; i++)
        PathNode(
          lesson: lessons[i],
          done: completedLessonIds.contains(lessons[i].id),
          current: i == currentIndex,
        ),
    ];
  }
}

/// Yol seridindeki tek nokta.
class PathNode {
  const PathNode({
    required this.lesson,
    required this.done,
    required this.current,
  });

  final InteractiveLesson lesson;
  final bool done;
  final bool current;

  /// Ne bitmis ne de sirada: ileride. Kilit degil, onizleme —
  /// "yapamazsin" degil "buraya geleceksin" demek istiyoruz.
  bool get upcoming => !done && !current;
}
