import '../courses/data/course_modules.dart';
import '../courses/data/courses_data.dart';
import '../courses/models/course_model.dart';
import '../courses/models/interactive_lesson_model.dart';
import '../models/learner_profile.dart';
import '../utils/lang.dart';
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
  ///
  /// [oncelikliKurs]: cocugun en son ders actigi kurs. Bitmemis dersi
  /// varsa ONCE o kurs donuyor. Cocuk katalogdan yolun disinda bir kursa
  /// (ornegin yolu Python ile baslarken Scratch'e) baslamis olabilir;
  /// ertesi gun ana sayfa onu yolun ilk kursuna degil, kaldigi kursa
  /// goturmeli.
  static NextStep? resolve(
    LearnerProfile profile,
    Set<String> completedLessonIds, {
    String? oncelikliKurs,
  }) {
    final path = LearningPathService.buildPath(profile);
    final isFirstEver = completedLessonIds.isEmpty;

    final oncelikli =
        oncelikliKurs == null ? null : CoursesData.byId(oncelikliKurs);
    for (final course in [if (oncelikli != null) oncelikli, ...path]) {
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
    // Dersin HANGI KURSA ait oldugu da tasiniyor: serit artik
    // tiklanabilir ve dokunuldugunda dersi acmak icin kursu bilmek
    // gerekiyor. Once yalnizca dersler toplaniyordu ve bu yuzden
    // seritteki noktalar hicbir seye goturemiyordu.
    final lessons = <InteractiveLesson>[];
    final kurslar = <Course>[];
    for (final course in path) {
      final dersler = CourseModules.allLessons(course.id);
      lessons.addAll(dersler);
      kurslar.addAll(List<Course>.filled(dersler.length, course));
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
          course: kurslar[i],
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
    required this.course,
    required this.lesson,
    required this.done,
    required this.current,
  });

  /// Dersin kursu. Serit noktasina dokununca ders bununla aciliyor.
  final Course course;

  final InteractiveLesson lesson;
  final bool done;
  final bool current;

  /// Ne bitmis ne de sirada: ileride. Kilit degil, onizleme —
  /// "yapamazsin" degil "buraya geleceksin" demek istiyoruz.
  bool get upcoming => !done && !current;
}

/// Bir kursun ana tusunun durumu.
enum KursDurumu {
  /// Hic ders acilmamis ve bitirilmemis.
  baslanmadi,

  /// En az bir ders acilmis ya da bitirilmis, bitmeyen ders var.
  devam,

  /// Butun dersler bitmis.
  bitti,
}

/// Bir kursun "baslat / devam et" tusu: hangi derse gidecegi ve ne yazacagi.
///
/// NEDEN TEK YERDE
/// ---------------
/// Kurs sayfasindaki tus her zaman "Ogrenmeye Basla" yaziyor ve her zaman
/// 1. dersi aciyordu; 3 dersi bitiren cocuk ertesi gun yine en basa
/// donuyordu. Ana sayfa ise ayni durumu baska bir kelimeyle anlatiyordu.
/// Etiket ve hedef ders burada hesaplaniyor ki iki ekran ayni seyi
/// soylesin ve test edilebilsin.
class KursDevam {
  const KursDevam({
    required this.lesson,
    required this.index,
    required this.completedInCourse,
    required this.lessonCount,
    required this.durum,
  });

  /// Tusa basinca acilacak ders: ilk BITMEMIS ders. Hepsi bittiyse
  /// tekrar icin ilk ders.
  final InteractiveLesson lesson;

  /// [lesson]'in kurs icindeki sifir tabanli sirasi.
  final int index;

  final int completedInCourse;
  final int lessonCount;
  final KursDurumu durum;

  /// Kursun tus durumunu hesaplar. Kursun dersi yoksa null.
  ///
  /// [acildi]: kursun bir dersi daha once acildi mi. Ders bitirilmemis
  /// olsa bile acilmissa cocuk "baslamis" sayiliyor; ona "basla" demek
  /// yaptigini yok saymak olur.
  static KursDevam? hesapla(
    String courseId,
    Set<String> completedLessonIds, {
    bool acildi = false,
  }) {
    final dersler = CourseModules.allLessons(courseId);
    if (dersler.isEmpty) return null;

    final biten =
        dersler.where((l) => completedLessonIds.contains(l.id)).length;
    final ilkBitmemis =
        dersler.indexWhere((l) => !completedLessonIds.contains(l.id));

    if (ilkBitmemis < 0) {
      // Hepsi bitti: tus tekrar icin ilk dersi aciyor. "Bitti" deyip
      // tusu kaldirmak yerine tekrar teklif etmek, kursa geri donen
      // cocugu bos bir ekranla karsilamamak icin.
      return KursDevam(
        lesson: dersler.first,
        index: 0,
        completedInCourse: biten,
        lessonCount: dersler.length,
        durum: KursDurumu.bitti,
      );
    }

    return KursDevam(
      lesson: dersler[ilkBitmemis],
      index: ilkBitmemis,
      completedInCourse: biten,
      lessonCount: dersler.length,
      durum: (biten > 0 || acildi)
          ? KursDurumu.devam
          : KursDurumu.baslanmadi,
    );
  }

  /// Tusun yazisi. [kisa] dar yerler (kart icindeki kucuk tus) icin.
  ///
  /// "Ogrenmeye basla" hicbir durumda yazilmiyor: baslamis cocuga
  /// yanlis, baslamamis cocuga da belirsiz (hangi ders?). Baslamamis
  /// kursta tus neyi actigini soyluyor: ilk ders.
  String etiket(String lang, {bool kisa = false}) {
    switch (durum) {
      case KursDurumu.devam:
        return kisa
            ? AppLang.pick(lang,
                tr: 'Devam et', en: 'Continue', de: 'Weiter', es: 'Continuar')
            : AppLang.pick(lang,
                tr: 'Kaldığın yerden devam et',
                en: 'Continue where you left off',
                de: 'Weiter, wo du aufgehört hast',
                es: 'Continúa donde lo dejaste');
      case KursDurumu.bitti:
        return kisa
            ? AppLang.pick(lang,
                tr: 'Tekrar et', en: 'Review', de: 'Wiederholen', es: 'Repasar')
            : AppLang.pick(lang,
                tr: 'Baştan tekrar et',
                en: 'Review from the start',
                de: 'Von vorne wiederholen',
                es: 'Repasar desde el inicio');
      case KursDurumu.baslanmadi:
        return kisa
            ? AppLang.pick(lang,
                tr: 'Başla', en: 'Start', de: 'Starten', es: 'Empezar')
            : AppLang.pick(lang,
                tr: 'İlk derse başla',
                en: 'Start the first lesson',
                de: 'Erste Lektion starten',
                es: 'Empieza la primera lección');
    }
  }
}
