import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../courses/data/courses_data.dart';
import '../courses/models/course_model.dart';
import '../models/user_progress_model.dart';

/// Bir kursun tamamlanma durumu.
class CourseProgress {
  final Course course;
  final int completed;

  const CourseProgress({required this.course, required this.completed});

  int get total => course.totalLessons;
  double get ratio => total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);
  bool get started => completed > 0;
  bool get finished => total > 0 && completed >= total;
}

/// Bir günün çalışma özeti.
class DayActivity {
  final DateTime day;
  final int xp;
  final int lessons;
  final int quizzes;
  final int videos;

  const DayActivity({
    required this.day,
    required this.xp,
    required this.lessons,
    required this.quizzes,
    required this.videos,
  });

  bool get isEmpty => xp == 0 && lessons == 0 && quizzes == 0 && videos == 0;
}

class ProgressReport {
  final List<CourseProgress> courses;
  final List<DayActivity> lastDays;
  final int videosWatched;
  final int questsCompleted;

  const ProgressReport({
    required this.courses,
    required this.lastDays,
    required this.videosWatched,
    required this.questsCompleted,
  });

  /// En çok ilerlenen, başlanmış kurslar.
  List<CourseProgress> get strongest {
    final started = courses.where((c) => c.started).toList()
      ..sort((a, b) => b.ratio.compareTo(a.ratio));
    return started.take(3).toList();
  }

  /// Başlanmış ama yarım kalmış kurslar — "buraya dön" önerisi.
  List<CourseProgress> get unfinished {
    final list = courses.where((c) => c.started && !c.finished).toList()
      ..sort((a, b) => a.ratio.compareTo(b.ratio));
    return list.take(3).toList();
  }

  /// Öğrenme yolunda henüz başlanmamış ilk kurs.
  CourseProgress? get nextStep {
    for (final c in courses) {
      if (c.course.pathStep > 0 && !c.started) return c;
    }
    return null;
  }

  int get activeDays => lastDays.where((d) => !d.isEmpty).length;
  int get weeklyXP => lastDays.fold(0, (a, d) => a + d.xp);
}

/// İlerleme raporu servisi.
///
/// Ders id'leri kurs id'siyle ön ekli (`scratch_1_1`, `arduino_6_1`).
/// Kurs kırılımını bu ön ekten çıkarıyoruz — ayrı bir eşleme tablosu
/// tutmaya gerek yok.
class ProgressReportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// `arduino_6_*` dersleri Arduino IDE kursuna ait; ön ek ikisinde de
  /// `arduino_` olduğu için özel olarak ayrılıyor.
  static const _arduinoIdeModule = 'arduino_6_';

  String? _courseIdOf(String lessonId) {
    if (lessonId.startsWith(_arduinoIdeModule)) return 'arduino_ide';
    for (final course in CoursesData.allCourses) {
      if (lessonId.startsWith('${course.id}_')) return course.id;
    }
    return null;
  }

  /// [forUserId] verilirse O kullanicinin verisi okunur.
  ///
  /// Ebeveyn kendi cihazindan cocugunun raporunu goruyor; o cihazda
  /// oturum acan kisi EBEVEYN, veri ise cocuga ait. Onceden butun
  /// sorgular `auth.currentUser` uzerinden gidiyordu, yani ebeveyn
  /// kendi bos raporunu goruyordu.
  Future<ProgressReport> build(
    UserProgress? progress, {
    String? forUserId,
  }) async {
    final counts = <String, int>{};
    for (final lessonId in progress?.completedLessonIds ?? const <String>[]) {
      final courseId = _courseIdOf(lessonId);
      if (courseId != null) counts[courseId] = (counts[courseId] ?? 0) + 1;
    }

    final courses = CoursesData.learningPath
        .map((c) => CourseProgress(course: c, completed: counts[c.id] ?? 0))
        .toList();

    return ProgressReport(
      courses: courses,
      lastDays: await _lastDays(14, forUserId),
      videosWatched: await _count('user_video_progress',
          extra: 'completed=is.true', forUserId: forUserId),
      questsCompleted: await _count('user_quests',
          extra: 'completed=is.true', forUserId: forUserId),
    );
  }

  Future<List<DayActivity>> _lastDays(int days, [String? forUserId]) async {
    final userId = forUserId ?? _supabase.auth.currentUser?.id;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));

    final byDay = <String, DayActivity>{};
    if (userId != null) {
      try {
        final rows = await _supabase
            .from('user_daily_activity')
            .select()
            .eq('user_id', userId)
            .gte('day', start.toIso8601String().substring(0, 10));
        for (final r in (rows as List)) {
          final d = DateTime.parse(r['day']);
          byDay[r['day']] = DayActivity(
            day: d,
            xp: r['xp'] ?? 0,
            lessons: r['lessons'] ?? 0,
            quizzes: r['quizzes'] ?? 0,
            videos: r['videos'] ?? 0,
          );
        }
      } catch (e) {
        debugPrint('❌ Günlük aktivite okunamadı: $e');
      }
    }

    return List.generate(days, (i) {
      final d = start.add(Duration(days: i));
      final key = d.toIso8601String().substring(0, 10);
      return byDay[key] ??
          DayActivity(day: d, xp: 0, lessons: 0, quizzes: 0, videos: 0);
    });
  }

  Future<int> _count(String table, {String? extra, String? forUserId}) async {
    final userId = forUserId ?? _supabase.auth.currentUser?.id;
    if (userId == null) return 0;
    try {
      var query = _supabase.from(table).select('user_id').eq('user_id', userId);
      if (extra == 'completed=is.true') query = query.eq('completed', true);
      final rows = await query;
      return (rows as List).length;
    } catch (_) {
      return 0;
    }
  }
}
