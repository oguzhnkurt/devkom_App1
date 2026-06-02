/// W3Schools-style Interactive Learning Model
/// Focus: Practical, example-driven, age-appropriate content

class W3Course {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji or icon name
  final String color; // hex color
  final List<String> tags; // Python, Beginner, Kids, etc.
  final int ageMin; // Minimum age
  final int ageMax; // Maximum age (99 for adult)
  final List<W3Chapter> chapters;
  final int totalLessons;
  final int estimatedHours;

  W3Course({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tags,
    this.ageMin = 6,
    this.ageMax = 99,
    required this.chapters,
    required this.totalLessons,
    required this.estimatedHours,
  });
}

class W3Chapter {
  final String id;
  final String title;
  final String? emoji;
  final String? description;
  final List<W3Lesson> lessons;
  final bool isLocked;

  W3Chapter({
    required this.id,
    required this.title,
    this.emoji,
    this.description,
    required this.lessons,
    this.isLocked = false,
  });
}

class W3Lesson {
  final String id;
  final String title;
  final String shortDescription;
  final List<W3Content> contents;
  final W3Quiz? quiz;
  final int estimatedMinutes;
  final String difficulty; // Easy, Medium, Hard
  final int? xpReward; // XP earned for completing this lesson

  W3Lesson({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.contents,
    this.quiz,
    required this.estimatedMinutes,
    this.difficulty = 'Easy',
    this.xpReward,
  });
}

/// Content types for lessons
enum W3ContentType {
  text,           // Simple explanation
  codeExample,    // Code with "Try it Yourself" button
  tip,           // Pro tip / Did you know?
  warning,       // Common mistakes / Watch out!
  interactive,   // Interactive widget (drag-drop, fill-blank, etc.)
  video,         // Video tutorial
  image,         // Diagram or screenshot
  challenge,     // Mini challenge
}

class W3Content {
  final W3ContentType type;
  final String? title;
  final String? text;
  final String? code;
  final String? language; // python, java, html, etc.
  final String? output; // Expected output for code
  final bool? editable; // Can user edit and run?
  final String? imageUrl;
  final String? videoUrl;
  final Map<String, dynamic>? interactiveData; // For custom widgets

  W3Content({
    required this.type,
    this.title,
    this.text,
    this.code,
    this.language,
    this.output,
    this.editable = true,
    this.imageUrl,
    this.videoUrl,
    this.interactiveData,
  });

  // Factory constructors for common types
  factory W3Content.text(String text, {String? title}) {
    return W3Content(
      type: W3ContentType.text,
      title: title,
      text: text,
    );
  }

  factory W3Content.code({
    required String code,
    required String language,
    String? output,
    bool editable = true,
    String? title,
  }) {
    return W3Content(
      type: W3ContentType.codeExample,
      title: title,
      code: code,
      language: language,
      output: output,
      editable: editable,
    );
  }

  factory W3Content.tip(String text) {
    return W3Content(
      type: W3ContentType.tip,
      text: text,
    );
  }

  factory W3Content.warning(String text) {
    return W3Content(
      type: W3ContentType.warning,
      text: text,
    );
  }
}

/// Quiz for end of lesson
class W3Quiz {
  final String id;
  final String title;
  final List<W3Question> questions;
  final int passingScore; // percentage

  W3Quiz({
    required this.id,
    required this.title,
    required this.questions,
    this.passingScore = 70,
  });
}

enum W3QuestionType {
  multipleChoice,
  trueFalse,
  fillInBlank,
  codeOutput, // "What will this code print?"
  findError,  // "Find the error in this code"
}

class W3Question {
  final String id;
  final W3QuestionType type;
  final String question;
  final String? code; // For code-based questions
  final List<String>? options; // For multiple choice
  final String correctAnswer;
  final String explanation;
  final int points;

  W3Question({
    required this.id,
    required this.type,
    required this.question,
    this.code,
    this.options,
    required this.correctAnswer,
    required this.explanation,
    this.points = 10,
  });
}

/// User progress tracking
class W3Progress {
  final String userId;
  final String courseId;
  final Map<String, LessonProgress> lessonProgress; // lessonId -> progress
  final int totalXP;
  final int currentLevel;
  final List<String> earnedBadges;
  final int streakDays;
  final DateTime lastStudyDate;
  final Map<String, int> quizScores; // lessonId -> score

  W3Progress({
    required this.userId,
    required this.courseId,
    this.lessonProgress = const {},
    this.totalXP = 0,
    this.currentLevel = 1,
    this.earnedBadges = const [],
    this.streakDays = 0,
    required this.lastStudyDate,
    this.quizScores = const {},
  });

  double get overallProgress {
    if (lessonProgress.isEmpty) return 0;
    int completed = lessonProgress.values.where((p) => p.isCompleted).length;
    return completed / lessonProgress.length;
  }
}

class LessonProgress {
  final String lessonId;
  final bool isStarted;
  final bool isCompleted;
  final int currentContentIndex;
  final DateTime? completedAt;
  final int? quizScore;
  final int attemptsCount;

  LessonProgress({
    required this.lessonId,
    this.isStarted = false,
    this.isCompleted = false,
    this.currentContentIndex = 0,
    this.completedAt,
    this.quizScore,
    this.attemptsCount = 0,
  });
}

/// Achievement badges
class W3Badge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String requirement; // "Complete 5 lessons", "7 day streak", etc.
  final int xpReward;

  W3Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.requirement,
    this.xpReward = 50,
  });
}

/// Pre-defined badges
class W3Badges {
  static final List<W3Badge> all = [
    W3Badge(
      id: 'first_lesson',
      name: 'Ilk Adim',
      description: 'Ilk dersini tamamla',
      emoji: '🎯',
      requirement: 'Complete 1 lesson',
      xpReward: 25,
    ),
    W3Badge(
      id: 'week_warrior',
      name: 'Hafta Savascisi',
      description: '7 gun ust uste calis',
      emoji: '🔥',
      requirement: '7 day streak',
      xpReward: 100,
    ),
    W3Badge(
      id: 'code_master',
      name: 'Kod Ustasi',
      description: '50 kod ornegi dene',
      emoji: '💻',
      requirement: 'Run 50 code examples',
      xpReward: 150,
    ),
    W3Badge(
      id: 'quiz_champion',
      name: 'Quiz Sampiyonu',
      description: '10 quiz\'de tam puan al',
      emoji: '🏆',
      requirement: 'Perfect score on 10 quizzes',
      xpReward: 200,
    ),
    W3Badge(
      id: 'speed_learner',
      name: 'Hizli Ogrenci',
      description: 'Bir gundebirbolum tamamla',
      emoji: '⚡',
      requirement: 'Complete a chapter in one day',
      xpReward: 75,
    ),
    W3Badge(
      id: 'helper',
      name: 'Yardim Kahramani',
      description: '5 arkadas davet et',
      emoji: '🤝',
      requirement: 'Invite 5 friends',
      xpReward: 100,
    ),
  ];
}
