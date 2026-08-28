import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_result_model.dart';
import 'games_service_supabase.dart';

/// Kazanım Analizleri servisi.
///
/// Not: Eskiden bu servis Firebase→Supabase göçü tamamlanmadığı için stub'dı
/// (her zaman boş Map/List döndürüyordu). "Kazanım Analizleri" ekranı bu boş
/// veriyi `as OverallStatistics` diye cast etmeye çalıştığı için
/// "type Map<String, dynamic> is not a subtype of type OverallStatistics"
/// hatasıyla çöküyordu. Şimdi `game_progress` tablosundaki gerçek oyun
/// kayıtlarından OverallStatistics/GameStatistics hesaplıyor.
class AchievementService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GamesServiceSupabase _gamesService = GamesServiceSupabase();

  Future<List<GameResult>> _loadResults(String userId) async {
    try {
      final rows = await _supabase
          .from('game_progress')
          .select()
          .eq('user_id', userId)
          .order('played_at', ascending: false);

      final nameCache = <String, String>{};
      final results = <GameResult>[];

      for (final row in rows) {
        final gameId = row['game_id']?.toString() ?? 'bilinmeyen';

        if (!nameCache.containsKey(gameId)) {
          try {
            final game = await _gamesService.getGame(gameId);
            nameCache[gameId] = game?.title ?? gameId;
          } catch (_) {
            nameCache[gameId] = gameId;
          }
        }

        final progressData =
            (row['progress_data'] as Map?)?.cast<String, dynamic>() ?? {};
        final score = (row['score'] as num?)?.toInt() ?? 0;

        int correct;
        int total;
        if (progressData['correctAnswers'] != null &&
            progressData['totalQuestions'] != null) {
          correct = (progressData['correctAnswers'] as num).toInt();
          total = (progressData['totalQuestions'] as num).toInt();
        } else {
          // progress_data doldurulmamış (embedded) oyunlar için skor
          // yüzdesinden kaba bir doğru/yanlış tahmini üret; en azından
          // ekran çökmesin ve genel eğilimi göstersin.
          total = 1;
          correct = score >= 50 ? 1 : 0;
        }
        final wrong = (total - correct).clamp(0, total);

        results.add(GameResult(
          id: row['id']?.toString() ?? '',
          playerId: userId,
          gameName: nameCache[gameId]!,
          correctAnswers: correct,
          wrongAnswers: wrong,
          totalQuestions: total,
          successRate: GameResult.calculateSuccessRate(correct, total),
          playedAt: row['played_at'] != null
              ? DateTime.parse(row['played_at'])
              : DateTime.now(),
        ));
      }

      return results;
    } catch (e) {
      debugPrint('⚠️ AchievementService._loadResults error: $e');
      return [];
    }
  }

  /// Rozetler artık UserProgressService/DefaultBadges üzerinden yönetiliyor
  /// (bkz. widgets/achievements_widget.dart). Bu metod geriye dönük
  /// uyumluluk için boş liste döndürür.
  Future<List<dynamic>> getUserAchievements(String userId) async => [];

  Future<void> checkAndUnlockAchievements(String userId) async {}

  Future<OverallStatistics> getOverallStatistics(String userId) async {
    final results = await _loadResults(userId);
    return OverallStatistics.fromResults(results);
  }

  Future<List<GameStatistics>> getGameStatistics(String userId) async {
    final results = await _loadResults(userId);
    final grouped = <String, List<GameResult>>{};
    for (final r in results) {
      grouped.putIfAbsent(r.gameName, () => []).add(r);
    }
    return grouped.entries
        .map((e) => GameStatistics.fromResults(e.key, e.value))
        .toList();
  }

  /// game_result_screen.dart (Bilgi Yarışması, Eşleştirme, Satranç, Robot
  /// Simülatörü vb. çoğu oyun) oyun bitince bunu çağırır. game_play_screen
  /// (jenerik quiz akışı) ise doğrudan GamesServiceSupabase.saveGameProgress
  /// kullanır — ikisi de aynı game_progress tablosuna yazar, "Kazanım
  /// Analizleri" ekranı ikisini birden görür.
  Future<void> saveGameResult({
    required String userId,
    required String gameId,
    required int score,
    required int duration,
    int? correctAnswers,
    int? totalQuestions,
  }) async {
    try {
      final progressData = <String, dynamic>{};
      if (correctAnswers != null && totalQuestions != null) {
        progressData['correctAnswers'] = correctAnswers;
        progressData['totalQuestions'] = totalQuestions;
      }

      await _supabase.from('game_progress').insert({
        'user_id': userId,
        'game_id': gameId,
        'score': score.clamp(0, 100000),
        'completed': true,
        'time_spent_minutes': (duration / 60).ceil(),
        'played_at': DateTime.now().toIso8601String(),
        'progress_data': progressData,
      });
    } catch (e) {
      debugPrint('⚠️ AchievementService.saveGameResult error: $e');
    }
  }
}
