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
  final String titleEn;
  final String titleDe;
  final String titleEs;
  final String emoji;
  final Color color;
  final Color secondaryColor;

  /// Bu kursa ait, gerçekten var olan ders id'leri (QuizzesData.all'da
  /// karşılığı bulunanlar) — sırayla oynatılır.
  final List<String> quizKeys;

  QuizCategory({
    required this.courseId,
    required this.title,
    required this.titleEn,
    required this.titleDe,
    required this.titleEs,
    required this.emoji,
    required this.color,
    required this.secondaryColor,
    required this.quizKeys,
  });

  /// Kart basligi — kursun kendi cok dilli adindan geliyor
  /// (bkz. Course.nameFor); burada ayri bir ceviri tutulmuyor.
  String titleFor(String lang) {
    switch (lang) {
      case 'en':
        return titleEn;
      case 'de':
        return titleDe;
      case 'es':
        return titleEs;
      default:
        return title;
    }
  }

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
        titleEn: course.nameFor('en'),
        titleDe: course.nameFor('de'),
        titleEs: course.nameFor('es'),
        emoji: course.icon,
        color: course.primaryColor,
        secondaryColor: course.secondaryColor,
        quizKeys: quizKeys,
      ));
    }

    return categories;
  }
}
