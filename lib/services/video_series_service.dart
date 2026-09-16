import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video_series_model.dart';
import 'user_progress_service.dart';

/// Video dersler servisi.
///
/// Katalog (video_series + video_episodes) Supabase'den okunur; içerik
/// uygulama güncellemesi gerekmeden yönetilebilir. İzlenen bölümler
/// user_video_progress tablosunda tutulur ve bölüm ilk kez tamamlandığında
/// XP + jeton ödülü verilir.
class VideoSeriesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Tüm aktif serileri bölümleriyle birlikte getirir.
  Future<List<VideoSeries>> getSeries() async {
    try {
      final data = await _supabase
          .from('video_series')
          .select('*, video_episodes(*)')
          .eq('is_active', true)
          .order('sort_order', ascending: true);
      return (data as List).map((m) => VideoSeries.fromMap(m)).toList();
    } catch (e) {
      debugPrint('❌ Video serileri okunamadı: $e');
      return [];
    }
  }

  /// Kullanıcının tamamladığı bölüm id'leri.
  Future<Set<String>> getCompletedEpisodeIds() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};
    try {
      final data = await _supabase
          .from('user_video_progress')
          .select('episode_id')
          .eq('user_id', userId)
          .eq('completed', true);
      return (data as List).map((m) => m['episode_id'] as String).toSet();
    } catch (e) {
      debugPrint('❌ Video ilerlemesi okunamadı: $e');
      return {};
    }
  }

  /// Bölümü tamamlandı olarak işaretler.
  ///
  /// Dönüş: ödül verildiyse true (yani bölüm ilk kez tamamlandıysa).
  /// Zaten tamamlanmışsa tekrar ödül verilmez.
  Future<bool> markCompleted(VideoEpisode episode) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final existing = await _supabase
          .from('user_video_progress')
          .select('id, completed')
          .eq('user_id', userId)
          .eq('episode_id', episode.id)
          .maybeSingle();

      if (existing != null && existing['completed'] == true) return false;

      await _supabase.from('user_video_progress').upsert({
        'user_id': userId,
        'episode_id': episode.id,
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,episode_id');

      final progressService = UserProgressService();
      if (episode.xpReward > 0) {
        await progressService.addXP(userId, episode.xpReward, source: 'video');
      }
      if (episode.jetonReward > 0) {
        await progressService.addJeton(userId, episode.jetonReward, source: 'video');
      }
      return true;
    } catch (e) {
      debugPrint('❌ Video tamamlama kaydedilemedi: $e');
      return false;
    }
  }
}
