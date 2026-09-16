import '../courses/data/courses_data.dart';
import '../courses/models/course_model.dart';
import '../models/learner_profile.dart';

/// Onboarding cevaplarindan kisisel kurs sirasi uretir.
///
/// CoursesData zaten kolaydan zora bir yol tutuyor (pathStep 1..8). Burada
/// yaptigimiz sey o yolu cocugun cevaplarina gore kirpip yeniden siralamak:
///
///  - Deneyim seviyesi NEREDEN baslanacagini belirler. Python bilen bir cocuga
///    Scratch'i ilk adim diye gostermek onu kaybetmenin en hizli yolu.
///  - Hedef SIRAYI belirler. Robot yapmak isteyen cocuk once Arduino'yu
///    gormeli; HTML/CSS onun icin sonra gelir.
///  - Yas araligi klavyeyle yazmaya ne zaman geciecegini belirler. 4-6 yas
///    icin yol blok tabanli kurslarda kaliyor.
///
/// Atlanan kurslar silinmiyor, sadece yolun sonuna aliniyor; cocuk isterse
/// katalogdan yine ulasabiliyor.
class LearningPathService {
  LearningPathService._();

  /// Blok tabanli (yazi yazmayan) kurslar.
  static const Set<String> blockBasedCourseIds = {'scratch', 'mblock', 'arduino'};

  /// Her hedef icin one alinacak kurslar, oncelik sirasiyla.
  static const Map<LearningGoal, List<String>> _goalPriority = {
    LearningGoal.games: ['scratch', 'python'],
    LearningGoal.robotics: ['scratch', 'mblock', 'arduino', 'arduino_ide'],
    LearningGoal.websites: ['html', 'css'],
    LearningGoal.ai: ['python'],
    // "Kesfetmek istiyorum" diyene mudahale etmiyoruz: varsayilan yol zaten
    // kolaydan zora dizilmis durumda.
    LearningGoal.explore: [],
  };

  /// Deneyim seviyesine gore yolun baslayacagi adim.
  static int _entryStep(SkillLevel level) => switch (level) {
        SkillLevel.beginner => 1, // Scratch'ten
        SkillLevel.someBlocks => 2, // Bloklari biliyor, Arduino/HTML'e
        SkillLevel.someCode => 3, // Yazarak yazmis, HTML/Python tarafina
      };

  /// Profile gore siralanmis kurs listesi. Profil eksikse varsayilan yol doner.
  static List<Course> buildPath(LearnerProfile profile) {
    final all = List<Course>.from(CoursesData.allCourses)
      ..sort((a, b) => a.pathStep.compareTo(b.pathStep));

    if (!profile.isComplete) return all;

    final level = profile.skillLevel!;
    final goal = profile.goal!;
    final ageBand = profile.ageBand!;

    // 1) Yas: kucuk cocuklarda once blok tabanli kurslar gelsin.
    // 2) Seviye: giris adiminin altindaki kurslar arkaya.
    // 3) Hedef: hedefe hizmet eden kurslar one.
    final entry = ageBand.prefersBlocksOnly ? 1 : _entryStep(level);
    final priority = _goalPriority[goal] ?? const <String>[];

    int rank(Course c) {
      // Dusuk sayi = daha erken.
      final isBlockBased = blockBasedCourseIds.contains(c.id);

      // 4-6 yas: bloklu kurslar her kosulda basta.
      if (ageBand.prefersBlocksOnly && isBlockBased) return -200 + c.pathStep;

      // Cocuk bu seviyeyi gectigini soyledi: kursu silmiyoruz ama arkaya
      // aliyoruz. Python yazabilen cocuga Scratch'i "1. adim" diye gostermek
      // onu kaybetmenin en hizli yolu. Hedef listesinden once bakiyoruz ki
      // hedefe hizmet eden bir kurs bile olsa one gecmesin.
      if (c.pathStep < entry) return 200 + c.pathStep;

      final priorityIndex = priority.indexOf(c.id);
      if (priorityIndex >= 0) return -100 + priorityIndex * 10;

      return c.pathStep;
    }

    all.sort((a, b) {
      final diff = rank(a).compareTo(rank(b));
      return diff != 0 ? diff : a.pathStep.compareTo(b.pathStep);
    });
    return all;
  }

  /// Yoldaki ilk kurs — onboarding sonunda "buradan baslayacaksin" derken
  /// ve ana ekrandaki "sirdaki adim" kartinda kullaniliyor.
  static Course? firstCourse(LearnerProfile profile) {
    final path = buildPath(profile);
    return path.isEmpty ? null : path.first;
  }

  /// Tamamlanan kurs id'leri verildiginde siradaki kursu bulur.
  static Course? nextCourse(
    LearnerProfile profile,
    Set<String> completedCourseIds,
  ) {
    for (final course in buildPath(profile)) {
      if (!completedCourseIds.contains(course.id)) return course;
    }
    return null;
  }

  /// Onboarding'in son ekraninda gosterilen ozet cumlesi.
  static String summaryTr(LearnerProfile profile) {
    if (!profile.isComplete) return 'Sana uygun bir yol hazırladık.';
    final first = firstCourse(profile);
    final goalText = switch (profile.goal!) {
      LearningGoal.games => 'oyun yapmak',
      LearningGoal.robotics => 'robot yapmak',
      LearningGoal.websites => 'web sitesi yapmak',
      LearningGoal.ai => 'yapay zekâyı anlamak',
      LearningGoal.explore => 'kodlamayı keşfetmek',
    };
    final start = first?.name ?? 'Scratch';
    return '$goalText istiyorsun. Yolun $start ile başlıyor.';
  }

  static String summaryEn(LearnerProfile profile) {
    if (!profile.isComplete) return 'We have prepared a path for you.';
    final first = firstCourse(profile);
    final goalText = switch (profile.goal!) {
      LearningGoal.games => 'make games',
      LearningGoal.robotics => 'build robots',
      LearningGoal.websites => 'build websites',
      LearningGoal.ai => 'understand AI',
      LearningGoal.explore => 'explore coding',
    };
    final start = first?.name ?? 'Scratch';
    return 'You want to $goalText. Your path starts with $start.';
  }
}
