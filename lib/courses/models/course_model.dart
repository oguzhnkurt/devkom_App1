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
  });

  String get difficultyText {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Baslangic';
      case DifficultyLevel.intermediate:
        return 'Orta';
      case DifficultyLevel.advanced:
        return 'Ileri';
    }
  }

  String get categoryText {
    switch (category) {
      case CourseCategory.kids:
        return 'Gorsel Programlama';
      case CourseCategory.web:
        return 'Web Gelistirme';
      case CourseCategory.mobile:
        return 'Mobil & Masaustu';
      case CourseCategory.systems:
        return 'Sistem Programlama';
      case CourseCategory.robotics:
        return 'Robotik & IoT';
      case CourseCategory.data:
        return 'Veri & Yapay Zeka';
      case CourseCategory.scripting:
        return 'Script Dilleri';
    }
  }

  String get estimatedTimeText {
    if (estimatedMinutes < 60) {
      return '$estimatedMinutes dk';
    }
    final hours = estimatedMinutes ~/ 60;
    final mins = estimatedMinutes % 60;
    if (mins == 0) {
      return '$hours saat';
    }
    return '$hours saat $mins dk';
  }
}

/// Lesson within a course
class Lesson {
  final String id;
  final String courseId;
  final String title;
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
    required this.description,
    required this.order,
    this.estimatedMinutes = 5,
    this.type = LessonType.theory,
    this.contents = const [],
    this.quiz,
    this.xpReward = 10,
  });
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
class QuizQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;  // For multiple choice
  final dynamic correctAnswer; // Index for MC, string for fill-in
  final String? explanation;
  final String? codeSnippet;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options = const [],
    required this.correctAnswer,
    this.explanation,
    this.codeSnippet,
  });
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
