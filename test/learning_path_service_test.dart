import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/models/learner_profile.dart';
import 'package:devkom_app/services/learning_path_service.dart';

/// Kisisel ogrenme yolu testleri.
///
/// Onboarding'de sorulan uc sorunun gercekten kurs sirasini degistirdigini
/// dogruluyor. Bu mantik bozulursa onboarding yine "dekoratif" bir anket
/// haline gelir ve kimse fark etmez - o yuzden test ediyoruz.
void main() {
  List<String> idsFor({
    required LearnerAgeBand age,
    required SkillLevel level,
    required LearningGoal goal,
  }) =>
      LearningPathService.buildPath(
        LearnerProfile(ageBand: age, skillLevel: level, goal: goal),
      ).map((c) => c.id).toList();

  group('Yol kurulumu', () {
    test('profil eksikse varsayilan yol (pathStep sirasi) doner', () {
      final path = LearningPathService.buildPath(const LearnerProfile());
      expect(path.map((c) => c.id).toList(),
          ['scratch', 'mblock', 'arduino', 'html', 'css', 'python', 'arduino_ide', 'java', 'csharp']);
    });

    test('yol her zaman tum kurslari icerir, hicbiri kaybolmaz', () {
      for (final goal in LearningGoal.values) {
        for (final level in SkillLevel.values) {
          for (final age in LearnerAgeBand.values) {
            final ids = idsFor(age: age, level: level, goal: goal);
            expect(ids.length, CoursesData.allCourses.length,
                reason: '$age / $level / $goal');
            expect(ids.toSet().length, ids.length,
                reason: 'tekrar eden kurs var: $age / $level / $goal');
          }
        }
      }
    });
  });

  group('Hedef sirayi belirler', () {
    test('robot yapmak isteyen yeni baslayanda Arduino one geliyor', () {
      final ids = idsFor(
        age: LearnerAgeBand.age10to12,
        level: SkillLevel.beginner,
        goal: LearningGoal.robotics,
      );
      expect(ids.first, 'scratch');
      // mBlock, Arduino'dan once: cocuk devre kurmadan once editoru taniyor.
      expect(ids[1], 'mblock');
      expect(ids.indexOf('mblock'), lessThan(ids.indexOf('arduino')));
      expect(ids.indexOf('arduino'), lessThan(ids.indexOf('html')));
    });

    test('web sitesi yapmak isteyende HTML/CSS one geliyor', () {
      final ids = idsFor(
        age: LearnerAgeBand.age10to12,
        level: SkillLevel.someBlocks,
        goal: LearningGoal.websites,
      );
      expect(ids.first, 'html');
      expect(ids[1], 'css');
    });

    test('yapay zeka hedefinde Python one geliyor', () {
      final ids = idsFor(
        age: LearnerAgeBand.age13plus,
        level: SkillLevel.someCode,
        goal: LearningGoal.ai,
      );
      expect(ids.first, 'python');
    });

    test('"kesfetmek istiyorum" varsayilan sirayi bozmuyor', () {
      final ids = idsFor(
        age: LearnerAgeBand.age10to12,
        level: SkillLevel.beginner,
        goal: LearningGoal.explore,
      );
      expect(ids, ['scratch', 'mblock', 'arduino', 'html', 'css', 'python', 'arduino_ide', 'java', 'csharp']);
    });
  });

  group('Deneyim seviyesi giris noktasini belirler', () {
    test('kod yazabilen cocuga Scratch ilk adim olarak gosterilmiyor', () {
      final ids = idsFor(
        age: LearnerAgeBand.age13plus,
        level: SkillLevel.someCode,
        goal: LearningGoal.games,
      );
      expect(ids.first, isNot('scratch'));
      // Kurs kayboluyor degil, sadece yolun sonuna aliniyor.
      expect(ids.contains('scratch'), isTrue);
      expect(ids.indexOf('scratch'), greaterThan(ids.length ~/ 2));
    });

    test('bloklari bilen cocukta Scratch geriye, siradaki adim one geliyor', () {
      final ids = idsFor(
        age: LearnerAgeBand.age10to12,
        level: SkillLevel.someBlocks,
        goal: LearningGoal.robotics,
      );
      expect(ids.first, 'mblock');
      expect(ids.indexOf('scratch'), greaterThan(ids.indexOf('mblock')));
    });

    test('hic kod yazmamis cocuk her zaman Scratch ile basliyor', () {
      for (final goal in [LearningGoal.games, LearningGoal.robotics, LearningGoal.explore]) {
        final ids = idsFor(
          age: LearnerAgeBand.age7to9,
          level: SkillLevel.beginner,
          goal: goal,
        );
        expect(ids.first, 'scratch', reason: '$goal');
      }
    });
  });

  group('Yas araligi klavyeye gecisi belirler', () {
    test('4-6 yasta yol blok tabanli kurslarla basliyor', () {
      // Cocuk "biraz kod yazdim" dese ve web sitesi istese bile: bu yasta
      // klavyeyle kod yazdirmiyoruz.
      final ids = idsFor(
        age: LearnerAgeBand.age4to6,
        level: SkillLevel.someCode,
        goal: LearningGoal.websites,
      );
      expect(ids.first, 'scratch');
      expect(ids[1], 'mblock');
    });

    test('buyuk yasta ayni cevaplar yazili kurslarla basliyor', () {
      final ids = idsFor(
        age: LearnerAgeBand.age13plus,
        level: SkillLevel.someCode,
        goal: LearningGoal.websites,
      );
      expect(ids.first, 'html');
    });
  });

  group('Yardimci metotlar', () {
    test('firstCourse yolun ilk kursunu veriyor', () {
      const profile = LearnerProfile(
        ageBand: LearnerAgeBand.age7to9,
        skillLevel: SkillLevel.beginner,
        goal: LearningGoal.robotics,
      );
      expect(LearningPathService.firstCourse(profile)?.id, 'scratch');
    });

    test('nextCourse tamamlananlari atliyor', () {
      const profile = LearnerProfile(
        ageBand: LearnerAgeBand.age7to9,
        skillLevel: SkillLevel.beginner,
        goal: LearningGoal.robotics,
      );
      expect(
        LearningPathService.nextCourse(profile, {'scratch'})?.id,
        'mblock',
      );
      expect(
        LearningPathService.nextCourse(profile, {'scratch', 'mblock'})?.id,
        'arduino',
      );
      expect(
        LearningPathService.nextCourse(
          profile,
          {'scratch', 'mblock', 'arduino'},
        )?.id,
        'arduino_ide',
      );
    });

    test('her sey tamamlaninca nextCourse null doner', () {
      const profile = LearnerProfile(
        ageBand: LearnerAgeBand.age7to9,
        skillLevel: SkillLevel.beginner,
        goal: LearningGoal.games,
      );
      final all = CoursesData.allCourses.map((c) => c.id).toSet();
      expect(LearningPathService.nextCourse(profile, all), isNull);
    });

    test('ozet cumlesi hedefi ve ilk kursu iceriyor', () {
      const profile = LearnerProfile(
        ageBand: LearnerAgeBand.age10to12,
        skillLevel: SkillLevel.someBlocks,
        goal: LearningGoal.websites,
      );
      final summary = LearningPathService.summaryTr(profile);
      expect(summary, contains('web sitesi'));
      expect(summary, contains('HTML'));
    });
  });

  group('Profil modeli', () {
    test('isComplete yalnizca uc cevap da varsa true', () {
      expect(const LearnerProfile().isComplete, isFalse);
      expect(
        const LearnerProfile(
          ageBand: LearnerAgeBand.age7to9,
          skillLevel: SkillLevel.beginner,
        ).isComplete,
        isFalse,
      );
      expect(
        const LearnerProfile(
          ageBand: LearnerAgeBand.age7to9,
          skillLevel: SkillLevel.beginner,
          goal: LearningGoal.games,
        ).isComplete,
        isTrue,
      );
    });

    test('Supabase degerleri gidip geri donuyor', () {
      // Enum degerleri veritabanindaki learner_* enum'lariyla birebir ayni
      // olmali; yoksa kayit sessizce basarisiz olur.
      const profile = LearnerProfile(
        ageBand: LearnerAgeBand.age10to12,
        skillLevel: SkillLevel.someCode,
        goal: LearningGoal.ai,
      );
      final map = profile.toSupabase();
      expect(map['age_band'], 'age_10_12');
      expect(map['skill_level'], 'some_code');
      expect(map['learning_goal'], 'ai');

      final back = LearnerProfile.fromSupabase(map);
      expect(back.ageBand, profile.ageBand);
      expect(back.skillLevel, profile.skillLevel);
      expect(back.goal, profile.goal);
    });

    test('bilinmeyen veritabani degeri null doner, patlamaz', () {
      final back = LearnerProfile.fromSupabase({
        'age_band': 'age_6_9', // eski bozuk enum degeri
        'skill_level': null,
        'learning_goal': 'uzay',
      });
      expect(back.ageBand, isNull);
      expect(back.skillLevel, isNull);
      expect(back.goal, isNull);
    });
  });
}
