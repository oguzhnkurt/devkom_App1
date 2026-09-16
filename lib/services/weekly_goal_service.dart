import 'package:shared_preferences/shared_preferences.dart';

import 'progress_report_service.dart';

/// Haftalik hedef ve bu haftaki durum.
class WeeklyGoalState {
  const WeeklyGoalState({
    required this.target,
    required this.done,
    required this.activeDays,
  });

  /// Haftada kac ders hedefleniyor.
  final int target;

  /// Bu hafta (pazartesiden bugune) tamamlanan ders sayisi.
  final int done;

  /// Bu hafta calisilan gun sayisi.
  final int activeDays;

  bool get reached => done >= target;
  double get ratio => target == 0 ? 0 : (done / target).clamp(0.0, 1.0);
  int get remaining => (target - done).clamp(0, target);
}

/// Haftalik hedef.
///
/// NEDEN GUNLUK SERI DEGIL:
///
/// Gunluk seri, okula giden bir cocuk icin kirilmaya mahkum bir sayac.
/// Sinav haftasi, hastalik, aile ziyareti — bir gun atlanir ve sayac
/// sifirlanir. Sifirlanan seri motive etmiyor, tersine "artik bozuldu,
/// bosver" dedirtiyor.
///
/// Haftalik hedef ayni ise yariyor ama esnek: cocuk hangi gunler
/// calistigini kendi secebiliyor. Ayrica hedefi EBEVEYN ya da cocuk
/// koyuyor; urunun dayattigi bir sayi degil, verilmis bir soz. Bu ikisi
/// arasindaki fark, ayni ilerleme cubugunu bir baski kaynagi olmaktan
/// cikarip bir anlasmaya cevirmek.
///
/// Gunluk seri kaldirilmiyor — ikincil sayi olarak duruyor. Basligi
/// haftalik hedef aliyor.
class WeeklyGoalService {
  WeeklyGoalService._();

  static const _key = 'weekly_lesson_goal';

  /// Varsayilan hedef.
  ///
  /// Rakip uygulamalarin ebeveynlere onerdigi ritim haftada 3-5 seans.
  /// Ortasindan basliyoruz; ebeveyn ayarlardan degistirebiliyor.
  static const int defaultTarget = 4;

  static const List<int> choices = [2, 3, 4, 5, 7];

  static Future<int> target() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_key) ?? defaultTarget;
    } catch (_) {
      return defaultTarget;
    }
  }

  static Future<void> setTarget(int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, value);
    } catch (_) {
      // Hedefin kaydedilememesi akisi durdurmamali.
    }
  }

  /// Haftanin pazartesisi (gun basi).
  static DateTime weekStart([DateTime? now]) {
    final d = now ?? DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  /// [days] gunluk etkinlik listesinden bu haftanin durumunu cikarir.
  static WeeklyGoalState stateFrom(
    List<DayActivity> days,
    int target, {
    DateTime? now,
  }) {
    final start = weekStart(now);
    final thisWeek = days.where((d) {
      final day = DateTime(d.day.year, d.day.month, d.day.day);
      return !day.isBefore(start);
    });

    return WeeklyGoalState(
      target: target,
      done: thisWeek.fold(0, (a, d) => a + d.lessons),
      activeDays: thisWeek.where((d) => !d.isEmpty).length,
    );
  }
}
