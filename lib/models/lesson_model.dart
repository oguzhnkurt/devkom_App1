/// Lesson Model for Professional Learning System
class LessonModel {
  final String id;
  final String title;
  final String category; // Python, Java, ASP.NET, AI, etc.
  final String level; // Beginner, Intermediate, Advanced
  final String description;
  final List<LessonSection> sections;
  final List<QuizQuestion> quiz;
  final int estimatedMinutes;
  final bool isCompleted;
  final int? userScore;
  final String? completedDate;

  LessonModel({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.description,
    required this.sections,
    required this.quiz,
    required this.estimatedMinutes,
    this.isCompleted = false,
    this.userScore,
    this.completedDate,
  });
}

/// Lesson Section - Topic Explanation
class LessonSection {
  final String title;
  final String content;
  final String? codeExample;
  final String? language; // For syntax highlighting
  final List<String>? keyPoints;
  final String? imageUrl;

  LessonSection({
    required this.title,
    required this.content,
    this.codeExample,
    this.language,
    this.keyPoints,
    this.imageUrl,
  });
}

/// Quiz Question Types
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInBlank,
  matching,
  codeCompletion,
}

/// Quiz Question Model
class QuizQuestion {
  final String id;
  final QuestionType type;
  final String question;
  final List<String>? options; // For multiple choice
  final String? correctAnswer; // For single answer questions
  final Map<String, String>? matchingPairs; // For matching questions
  final List<String>? blanks; // For fill in blank
  final String? codeSnippet; // For code-based questions
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.type,
    required this.question,
    this.options,
    this.correctAnswer,
    this.matchingPairs,
    this.blanks,
    this.codeSnippet,
    required this.explanation,
  });
}

/// Daily Goal Model
class DailyGoal {
  final String date; // yyyy-MM-dd
  final int targetLessons;
  final int completedLessons;
  final int targetMinutes;
  final int completedMinutes;
  final List<String> completedLessonIds;

  DailyGoal({
    required this.date,
    required this.targetLessons,
    this.completedLessons = 0,
    required this.targetMinutes,
    this.completedMinutes = 0,
    this.completedLessonIds = const [],
  });

  bool get isCompleted => completedLessons >= targetLessons;

  double get progress => targetLessons > 0
      ? (completedLessons / targetLessons).clamp(0.0, 1.0)
      : 0.0;
}
