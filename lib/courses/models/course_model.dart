import 'package:flutter/material.dart';

/// Difficulty level for courses and lessons
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

/// Category for organizing courses
enum CourseCategory {
  kids,        // Scratch, visual programming
  web,         // HTML, CSS, JS, PHP, SQL
  mobile,      // Dart, Swift, Kotlin, Java
  systems,     // C, C++, Go, Rust
  robotics,    // Arduino, MicroPython, Raspberry Pi
  data,        // Python, R, Julia
  scripting,   // Ruby, Lua, Bash
}

/// Main Course model
class Course {
  final String id;
  final String name;
  final String slug;           // URL-friendly name
  final String description;

  /// Kurs adinin ve aciklamasinin diger dillerdeki karsiliklari.
  ///
  /// ONCEDEN HIC YOKTU: kurs adlari ve aciklamalari dort dilde de
  /// Turkce goruntyordu — Ingilizce dahil. Uygulamanin en gorunur
  /// icerigi (ana sayfadaki yol, katalog, sertifika adlari) bundan
  /// besleniyor.
  ///
  /// Verilmemisse Ingilizcesine, o da yoksa Turkcesine dusuyor; boylece
  /// bir kursun cevirisi eklenene kadar ekran calismaya devam ediyor.
  final String? nameEn;
  final String? nameDe;
  final String? nameEs;
  final String? descriptionEn;
  final String? descriptionDe;
  final String? descriptionEs;
  final String icon;           // Emoji or asset path
  final Color primaryColor;
  final Color secondaryColor;
  final CourseCategory category;
  final DifficultyLevel difficulty;
  final List<String> tags;
  final int totalLessons;
  final int estimatedMinutes;  // Total estimated time
  final bool isPremium;
  final int sortOrder;

  /// Ogrenme yolundaki sira (1'den baslar). 0 = yolun disinda, sadece
  /// katalogda gorunur. Katalog ekrani filtre yokken kurslari bu siraya
  /// gore "adim adim" gosterir.
  final int pathStep;

  /// Bu kursa baslamadan once tamamlanmasi onerilen kursun id'si.
  /// Zorlayici degil, kullaniciya yol gostermek icin.
  final String? prerequisiteId;

  String nameFor(String lang) => switch (lang) {
        'en' => nameEn ?? name,
        'de' => nameDe ?? nameEn ?? name,
        'es' => nameEs ?? nameEn ?? name,
        _ => name,
      };

  String descriptionFor(String lang) => switch (lang) {
        'en' => descriptionEn ?? description,
        'de' => descriptionDe ?? descriptionEn ?? description,
        'es' => descriptionEs ?? descriptionEn ?? description,
        _ => description,
      };

  const Course({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.category,
    required this.difficulty,
    this.tags = const [],
    this.totalLessons = 0,
    this.estimatedMinutes = 0,
    this.isPremium = false,
    this.sortOrder = 0,
    this.pathStep = 0,
    this.prerequisiteId,
    this.nameEn,
    this.nameDe,
    this.nameEs,
    this.descriptionEn,
    this.descriptionDe,
    this.descriptionEs,
  });

  String get difficultyText {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Başlangıç';
      case DifficultyLevel.intermediate:
        return 'Orta';
      case DifficultyLevel.advanced:
        return 'İleri';
    }
  }

  // `categoryText` KALDIRILDI.
  //
  // Kurs kataloğundaki yatay kategori şeridi kaldırılınca bu getter'ı
  // okuyan hiçbir yer kalmadı; üstelik tek dilliydi (Türkçe sabit).
  // `category` alanı veri olarak duruyor — bir gün gerekirse yeniden
  // kullanılabilir — ama artık hiçbir ekranı beslemiyor.



  /// Turkce sure metni. Yeni kod `estimatedTimeTextFor(lang)`
  /// kullanmali; bu getter geriye donuk uyumluluk icin duruyor.
  String get estimatedTimeText => estimatedTimeTextFor('tr');

  /// Sure metni — dile gore.
  ///
  /// Kurs katalogu magaza slaytinda kullaniliyor ve Ingilizce
  /// kosuda "4 saat" yaziyordu: ekranin geri kalani cevrilmisken
  /// sure ve ders sayisi Turkce kaliyordu.
  String estimatedTimeTextFor(String lang) {
    final hours = estimatedMinutes ~/ 60;
    final mins = estimatedMinutes % 60;
    final (h, m) = switch (lang) {
      'en' => ('h', 'min'),
      'de' => ('Std.', 'Min.'),
      'es' => ('h', 'min'),
      _ => ('saat', 'dk'),
    };
    if (estimatedMinutes < 60) return '$estimatedMinutes $m';
    if (mins == 0) return '$hours $h';
    return '$hours $h $mins $m';
  }

  /// "12 ders" / "12 lessons" — dile gore.
  String lessonCountTextFor(String lang) => switch (lang) {
        'en' => '$totalLessons lessons',
        'de' => '$totalLessons Lektionen',
        'es' => '$totalLessons lecciones',
        _ => '$totalLessons ders',
      };
}

/// Lesson within a course
class Lesson {
  final String id;
  final String courseId;
  final String title;
  // Quiz ekraninin baslik cubugunda gorunuyor; cevirisi olmayan ders
  // Turkce kaliyor (bkz. titleFor).
  final String? titleEn;
  final String? titleDe;
  final String? titleEs;
  final String description;
  final int order;
  final int estimatedMinutes;
  final LessonType type;
  final List<LessonContent> contents;
  final Quiz? quiz;
  final int xpReward;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    this.titleEn,
    this.titleDe,
    this.titleEs,
    required this.description,
    required this.order,
    this.estimatedMinutes = 5,
    this.type = LessonType.theory,
    this.contents = const [],
    this.quiz,
    this.xpReward = 10,
  });

  /// Ders basligi — quiz sorularindakiyle ayni yedek zinciri.
  String titleFor(String lang) {
    String? own;
    if (lang == 'de') own = titleDe;
    if (lang == 'es') own = titleEs;
    if (own != null && own.trim().isNotEmpty) return own;
    if (lang != 'tr' && titleEn != null && titleEn!.trim().isNotEmpty) {
      return titleEn!;
    }
    return title;
  }
}

/// Type of lesson
enum LessonType {
  theory,      // Text-based explanation
  practice,    // Code along
  project,     // Build something
  quiz,        // Test knowledge
}

/// Content block within a lesson
class LessonContent {
  final String id;
  final ContentType type;
  final String content;        // Text, code, or description
  final String? language;      // For code blocks
  final String? imageUrl;      // For images
  final String? hint;          // Optional hint
  final bool isInteractive;    // Can user modify code?

  const LessonContent({
    required this.id,
    required this.type,
    required this.content,
    this.language,
    this.imageUrl,
    this.hint,
    this.isInteractive = false,
  });
}

/// Type of content block
enum ContentType {
  text,        // Markdown text
  heading,     // Section heading
  code,        // Code block
  output,      // Expected output
  image,       // Image/diagram
  note,        // Info/warning note
  task,        // Interactive task
}

/// Quiz model
class Quiz {
  final String id;
  final String lessonId;
  final List<QuizQuestion> questions;
  final int passingScore;      // Percentage to pass
  final int xpReward;

  const Quiz({
    required this.id,
    required this.lessonId,
    required this.questions,
    this.passingScore = 70,
    this.xpReward = 25,
  });
}

/// Quiz question
///
/// DORT DILLI
/// ----------
/// Sorular uzun sure yalnizca Turkce yaziliydi. Almanca secen bir cocuk
/// dersi Almanca/Ingilizce goruyor, quize girince "HTML ne anlama
/// gelir?" ile karsilasiyordu — dort dil vaadinin en gorunur sekilde
/// kirildigi yer burasiydi.
///
/// Yedek zinciri ders icerigiyle AYNI olmali (bkz. `pickLang`):
/// `tr` → Turkce; baska her dil → varsa kendi dili, yoksa Ingilizce,
/// o da yoksa Turkce. Boylece yeni bir dil eklenirken ceviri yetismese
/// bile ekranda bos ya da Turkce metin cikmiyor.
///
/// [correctAnswer] CEVRILMEZ: coktan secmelide dogru siktaki INDEKS,
/// dogru/yanlista bool. Bu yuzden ceviri listelerinin sirasi Turkce
/// listeyle birebir ayni olmak zorunda — `test/quiz_localization_test.dart`
/// uzunlugu ve sirayi kilitliyor.
class QuizQuestion {
  final String id;
  final String question;
  final String? questionEn;
  final String? questionDe;
  final String? questionEs;
  final QuestionType type;
  final List<String> options;  // For multiple choice
  final List<String>? optionsEn;
  final List<String>? optionsDe;
  final List<String>? optionsEs;
  final dynamic correctAnswer; // Index for MC, string for fill-in
  final String? explanation;
  final String? explanationEn;
  final String? explanationDe;
  final String? explanationEs;
  final String? codeSnippet;
  // Kod parcasi da ceviriliyor: icindeki degisken adlari ve yazdirilan
  // metinler ("Cocuk", "Merhaba") siklarda birebir gecmek zorunda.
  // Snippet Turkce kalip sik Ingilizce olursa soru cevapsiz kaliyor.
  final String? codeSnippetEn;
  final String? codeSnippetDe;
  final String? codeSnippetEs;

  const QuizQuestion({
    required this.id,
    required this.question,
    this.questionEn,
    this.questionDe,
    this.questionEs,
    required this.type,
    this.options = const [],
    this.optionsEn,
    this.optionsDe,
    this.optionsEs,
    required this.correctAnswer,
    this.explanation,
    this.explanationEn,
    this.explanationDe,
    this.explanationEs,
    this.codeSnippet,
    this.codeSnippetEn,
    this.codeSnippetDe,
    this.codeSnippetEs,
  });

  static String _pick(
      String tr, String? en, String? de, String? es, String lang) {
    String? own;
    if (lang == 'de') own = de;
    if (lang == 'es') own = es;
    if (own != null && own.trim().isNotEmpty) return own;
    if (lang != 'tr' && en != null && en.trim().isNotEmpty) return en;
    return tr;
  }

  String questionFor(String lang) =>
      _pick(question, questionEn, questionDe, questionEs, lang);

  List<String> optionsFor(String lang) {
    List<String>? own;
    if (lang == 'de') own = optionsDe;
    if (lang == 'es') own = optionsEs;
    if (own != null && own.length == options.length) return own;
    if (lang != 'tr' &&
        optionsEn != null &&
        optionsEn!.length == options.length) {
      return optionsEn!;
    }
    return options;
  }

  String? explanationFor(String lang) {
    if (explanation == null) return null;
    return _pick(
        explanation!, explanationEn, explanationDe, explanationEs, lang);
  }

  String? codeSnippetFor(String lang) {
    if (codeSnippet == null) return null;
    return _pick(
        codeSnippet!, codeSnippetEn, codeSnippetDe, codeSnippetEs, lang);
  }
}

/// Type of quiz question
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInBlank,
  codeOutput,    // What's the output?
  findError,     // Find the bug
}

/// User's progress in a course
class CourseProgress {
  final String courseId;
  final String oderId;
  final List<String> completedLessonIds;
  final Map<String, int> quizScores;  // lessonId -> score
  final int totalXpEarned;
  final DateTime startedAt;
  final DateTime? completedAt;

  const CourseProgress({
    required this.courseId,
    required this.oderId,
    this.completedLessonIds = const [],
    this.quizScores = const {},
    this.totalXpEarned = 0,
    required this.startedAt,
    this.completedAt,
  });

  double get progressPercent {
    // This would need totalLessons from course
    return 0.0;
  }

  bool get isCompleted => completedAt != null;
}
