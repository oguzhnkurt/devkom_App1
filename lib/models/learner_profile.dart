/// Onboarding'de sorulan üç soru ve bunlardan üretilen kişisel öğrenme yolu.
///
/// Neden bu üç soru: uygulama daha önce herkese aynı ana ekranı gösteriyordu.
/// Scratch'e yeni başlayan 7 yaşındaki çocukla Python bilen 12 yaşındaki
/// çocuk aynı listeye bakıyordu. Bu üç cevap, kurs sırasını ve nereden
/// başlanacağını belirliyor.
///
/// Bilerek SORMADIKLARIMIZ: doğum tarihi ve cinsiyet. Uygulama 4+ yaş
/// derecelendirmeli; gereksiz kişisel veri toplamak hem App Privacy beyanını
/// değiştirir hem de KVKK/GDPR açısından yük getirir. Yaş, tarih olarak değil
/// kaba bir aralık olarak tutuluyor ve yalnızca dersin dilini/zorluğunu
/// ayarlamak için kullanılıyor.
library;

import '../utils/lang.dart';

/// Kaba yaş aralığı. Ders dilini ve zorluğunu ayarlar.
enum LearnerAgeBand { age4to6, age7to9, age10to12, age13plus }

/// Çocuğun kodlamayla önceki teması.
enum SkillLevel {
  /// Hiç kodlama yapmamış.
  beginner,

  /// Scratch/blok kodlama denemiş.
  someBlocks,

  /// Yazarak kod yazmış (Python, HTML vb.).
  someCode,
}

/// Çocuğun ne yapmak istediği. Yolun sırasını belirler.
enum LearningGoal {
  /// Oyun yapmak istiyorum.
  games,

  /// Robot yapmak istiyorum.
  robotics,

  /// Web sitesi yapmak istiyorum.
  websites,

  /// Yapay zekâ öğrenmek istiyorum.
  ai,

  /// Emin değilim, keşfetmek istiyorum.
  explore,
}

extension LearnerAgeBandX on LearnerAgeBand {
  /// Supabase `learner_age_band` enum karşılığı.
  String get dbValue => switch (this) {
        LearnerAgeBand.age4to6 => 'age_4_6',
        LearnerAgeBand.age7to9 => 'age_7_9',
        LearnerAgeBand.age10to12 => 'age_10_12',
        LearnerAgeBand.age13plus => 'age_13_plus',
      };

  String get labelTr => switch (this) {
        LearnerAgeBand.age4to6 => '4-6 yaş',
        LearnerAgeBand.age7to9 => '7-9 yaş',
        LearnerAgeBand.age10to12 => '10-12 yaş',
        LearnerAgeBand.age13plus => '13 yaş ve üzeri',
      };

  String get labelEn => switch (this) {
        LearnerAgeBand.age4to6 => 'Ages 4-6',
        LearnerAgeBand.age7to9 => 'Ages 7-9',
        LearnerAgeBand.age10to12 => 'Ages 10-12',
        LearnerAgeBand.age13plus => 'Age 13+',
      };

  String get labelDe => switch (this) {
        LearnerAgeBand.age4to6 => '4-6 Jahre',
        LearnerAgeBand.age7to9 => '7-9 Jahre',
        LearnerAgeBand.age10to12 => '10-12 Jahre',
        LearnerAgeBand.age13plus => 'Ab 13 Jahren',
      };

  String get labelEs => switch (this) {
        LearnerAgeBand.age4to6 => '4-6 años',
        LearnerAgeBand.age7to9 => '7-9 años',
        LearnerAgeBand.age10to12 => '10-12 años',
        LearnerAgeBand.age13plus => '13 años o más',
      };

  String labelFor(String lang) =>
      AppLang.pick(lang, tr: labelTr, en: labelEn, de: labelDe, es: labelEs);

  /// Küçük yaşlarda yazarak kod yazdırmıyoruz; yol blok tabanlı kalıyor.
  bool get prefersBlocksOnly => this == LearnerAgeBand.age4to6;

  static LearnerAgeBand? fromDb(String? value) => switch (value) {
        'age_4_6' => LearnerAgeBand.age4to6,
        'age_7_9' => LearnerAgeBand.age7to9,
        'age_10_12' => LearnerAgeBand.age10to12,
        'age_13_plus' => LearnerAgeBand.age13plus,
        _ => null,
      };
}

extension SkillLevelX on SkillLevel {
  String get dbValue => switch (this) {
        SkillLevel.beginner => 'beginner',
        SkillLevel.someBlocks => 'some_blocks',
        SkillLevel.someCode => 'some_code',
      };

  String get labelTr => switch (this) {
        SkillLevel.beginner => 'Hiç kod yazmadım',
        SkillLevel.someBlocks => 'Scratch/blok denedim',
        SkillLevel.someCode => 'Biraz kod yazdım',
      };

  String get labelEn => switch (this) {
        SkillLevel.beginner => 'I have never coded',
        SkillLevel.someBlocks => 'I have tried Scratch/blocks',
        SkillLevel.someCode => 'I have written some code',
      };

  String get descriptionTr => switch (this) {
        SkillLevel.beginner => 'En baştan, acele etmeden başlayalım',
        SkillLevel.someBlocks => 'Blokları biliyorsun, üstüne koyalım',
        SkillLevel.someCode => 'Klavyeyle yazmaya geçebilirsin',
      };

  String get descriptionEn => switch (this) {
        SkillLevel.beginner => 'We will start from the very beginning',
        SkillLevel.someBlocks => 'You know blocks, let us build on that',
        SkillLevel.someCode => 'You are ready to type real code',
      };

  String get labelDe => switch (this) {
        SkillLevel.beginner => 'Ich habe noch nie programmiert',
        SkillLevel.someBlocks => 'Ich habe Scratch/Blöcke probiert',
        SkillLevel.someCode => 'Ich habe schon etwas Code geschrieben',
      };

  String get labelEs => switch (this) {
        SkillLevel.beginner => 'Nunca he programado',
        SkillLevel.someBlocks => 'He probado Scratch o bloques',
        SkillLevel.someCode => 'He escrito algo de código',
      };

  String get descriptionDe => switch (this) {
        SkillLevel.beginner => 'Wir fangen ganz von vorne an, ohne Eile',
        SkillLevel.someBlocks => 'Du kennst Blöcke — darauf bauen wir auf',
        SkillLevel.someCode => 'Du kannst mit dem Tippen loslegen',
      };

  String get descriptionEs => switch (this) {
        SkillLevel.beginner => 'Empezamos desde cero, sin prisa',
        SkillLevel.someBlocks => 'Conoces los bloques; seguimos desde ahí',
        SkillLevel.someCode => 'Ya puedes escribir código de verdad',
      };

  String labelFor(String lang) =>
      AppLang.pick(lang, tr: labelTr, en: labelEn, de: labelDe, es: labelEs);
  String descriptionFor(String lang) => AppLang.pick(lang,
      tr: descriptionTr, en: descriptionEn, de: descriptionDe,
      es: descriptionEs);

  static SkillLevel? fromDb(String? value) => switch (value) {
        'beginner' => SkillLevel.beginner,
        'some_blocks' => SkillLevel.someBlocks,
        'some_code' => SkillLevel.someCode,
        _ => null,
      };
}

extension LearningGoalX on LearningGoal {
  String get dbValue => switch (this) {
        LearningGoal.games => 'games',
        LearningGoal.robotics => 'robotics',
        LearningGoal.websites => 'websites',
        LearningGoal.ai => 'ai',
        LearningGoal.explore => 'explore',
      };

  String get labelTr => switch (this) {
        LearningGoal.games => 'Oyun yapmak',
        LearningGoal.robotics => 'Robot yapmak',
        LearningGoal.websites => 'Web sitesi yapmak',
        LearningGoal.ai => 'Yapay zekâ öğrenmek',
        LearningGoal.explore => 'Hepsini keşfetmek',
      };

  String get labelEn => switch (this) {
        LearningGoal.games => 'Make games',
        LearningGoal.robotics => 'Build robots',
        LearningGoal.websites => 'Build websites',
        LearningGoal.ai => 'Learn about AI',
        LearningGoal.explore => 'Explore everything',
      };

  String get labelDe => switch (this) {
        LearningGoal.games => 'Spiele machen',
        LearningGoal.robotics => 'Roboter bauen',
        LearningGoal.websites => 'Webseiten bauen',
        LearningGoal.ai => 'KI verstehen',
        LearningGoal.explore => 'Alles entdecken',
      };

  String get labelEs => switch (this) {
        LearningGoal.games => 'Crear juegos',
        LearningGoal.robotics => 'Construir robots',
        LearningGoal.websites => 'Crear páginas web',
        LearningGoal.ai => 'Aprender sobre IA',
        LearningGoal.explore => 'Explorarlo todo',
      };

  String labelFor(String lang) =>
      AppLang.pick(lang, tr: labelTr, en: labelEn, de: labelDe, es: labelEs);

  String get emoji => switch (this) {
        LearningGoal.games => '🎮',
        LearningGoal.robotics => '🤖',
        LearningGoal.websites => '🌐',
        LearningGoal.ai => '🧠',
        LearningGoal.explore => '🧭',
      };

  static LearningGoal? fromDb(String? value) => switch (value) {
        'games' => LearningGoal.games,
        'robotics' => LearningGoal.robotics,
        'websites' => LearningGoal.websites,
        'ai' => LearningGoal.ai,
        'explore' => LearningGoal.explore,
        _ => null,
      };
}

/// Bir çocuğun onboarding cevapları.
class LearnerProfile {
  const LearnerProfile({this.ageBand, this.skillLevel, this.goal});

  final LearnerAgeBand? ageBand;
  final SkillLevel? skillLevel;
  final LearningGoal? goal;

  /// Üç cevabın da verilmiş olması, kişisel yolun kurulabildiği anlamına gelir.
  bool get isComplete => ageBand != null && skillLevel != null && goal != null;

  LearnerProfile copyWith({
    LearnerAgeBand? ageBand,
    SkillLevel? skillLevel,
    LearningGoal? goal,
  }) =>
      LearnerProfile(
        ageBand: ageBand ?? this.ageBand,
        skillLevel: skillLevel ?? this.skillLevel,
        goal: goal ?? this.goal,
      );

  Map<String, dynamic> toSupabase() => {
        'age_band': ageBand?.dbValue,
        'skill_level': skillLevel?.dbValue,
        'learning_goal': goal?.dbValue,
      };

  factory LearnerProfile.fromSupabase(Map<String, dynamic> data) =>
      LearnerProfile(
        ageBand: LearnerAgeBandX.fromDb(data['age_band'] as String?),
        skillLevel: SkillLevelX.fromDb(data['skill_level'] as String?),
        goal: LearningGoalX.fromDb(data['learning_goal'] as String?),
      );
}
