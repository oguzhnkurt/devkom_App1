import 'package:flutter/foundation.dart';

import '../models/user_progress_model.dart';
import 'child_link_service.dart';
import 'cocuk_raporu.dart';
import 'progress_report_service.dart';

/// Bir cocugun raporunu getiren fonksiyon. Testlerde sahtesi veriliyor.
typedef CocukRaporuYukleyici = Future<CocukRaporu> Function(ChildLink cocuk);

/// Raporu Supabase'ten kurar. Hicbir sey YAZMAZ.
Future<CocukRaporu> cocukRaporuYukle(ChildLink cocuk) async {
  UserProgress? ilerleme;
  final satir = await ChildLinkService.childProgressRow(cocuk.childId);
  if (satir != null) {
    try {
      ilerleme = UserProgress.fromSupabase(satir);
    } catch (e) {
      debugPrint('cocukRaporuYukle: ilerleme satiri cozulemedi: $e');
    }
  }
  // Yalnizca gunluk kirilim, video ve gorev sayilari icin; kurs hesabi
  // CocukRaporu'nda yapiliyor.
  final r = await ProgressReportService().build(null, forUserId: cocuk.childId);
  return CocukRaporu(
    ad: cocuk.childName,
    ilerleme: ilerleme,
    gunler: r.lastDays,
    izlenenVideo: r.videosWatched,
    bitenGorev: r.questsCompleted,
  );
}
