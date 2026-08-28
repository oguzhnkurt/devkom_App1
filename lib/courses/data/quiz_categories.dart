import 'package:flutter/material.dart';
import 'courses_data.dart';
import 'lessons_data.dart';
import 'quizzes_data.dart';

/// Quiz Merkezi'nde gösterilecek bir konu (kurs) kategorisi.
/// Kursun kendi rengi/emojisi kullanılır (bkz. Course.icon/primaryColor) —
/// yeni bir renk paleti icat etmek yerine devkom'un mevcut kurs kimliğiyle
/// tutarlı kalır.
class QuizCategory {
  final String courseId;
  final String title;
  final String emoji;
  final Color color;
  final Color secondaryColor;

  /// Bu kursa ait, gerçekten var olan ders id'leri (QuizzesData.all'da
  /// karşılığı bulunanlar) — sırayla oynatılır.
  final List<String> quizKeys;

  QuizCategory({
    required this.courseId,
    required this.title,
    required this.emoji,
    required this.color,
    required this.secondaryColor,
    required this.quizKeys,
  });

  int get questionCount {
    var total = 0;
    for (final key in quizKeys) {
      total += QuizzesData.all[key]?.questions.length ?? 0;
    }
    return total;
  }
}

/// Quiz Merkezi kategorilerini kurs + ders + quiz verisinden türetir.
///
/// Not: QuizzesData içinde bazı eski/öksüz quiz kayıtları var (js_01,
/// dart_01, sql_01, c_01, go_01, rust_01) — bunlara karşılık gelen kurslar
/// CoursesData.allCourses içinde artık yok (bkz. dosyanın sonundaki "gelecek
/// güncellemelerde eklenecek kurslar" yorumu). Kategoriler CoursesData
/// üzerinden türetildiği için bu öksüz kayıtlar otomatik olarak dışarıda
/// kalır — QuizScreen'e geçersiz bir kurs/ders gönderme riski yok.
class QuizCategoriesData {
  static List<QuizCategory> get all {
    final categories = <QuizCategory>[];

    for (final course in CoursesData.allCourses) {
      final lessons = LessonsData.getLessonsForCourse(course.id);
      final quizKeys = lessons
          .map((lesson) => lesson.id)
          .where((id) => QuizzesData.all.containsKey(id))
          .toList();

      if (quizKeys.isEmpty) continue;

      categories.add(QuizCategory(
        courseId: course.id,
        title: course.name,
        emoji: course.icon,
        color: course.primaryColor,
        secondaryColor: course.secondaryColor,
        quizKeys: quizKeys,
      ));
    }

    return categories;
  }
}
