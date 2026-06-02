import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';
import '../models/leaderboard_model.dart';
import '../models/game_model.dart';

/// Leaderboard Service Stub - Redirects to Supabase
class LeaderboardService {
  Future<void> saveScore({
    required String userId,
    required String gameId,
    required int score,
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint('⚠️  saveScore stub called');
  }

  Future<List<dynamic>> getLeaderboard(String gameId, {int limit = 10}) async {
    debugPrint('⚠️  getLeaderboard stub called');
    return [];
  }

  Future<List<LeaderboardEntry>> getTopEntries({
    required GameType gameType,
    int limit = 10,
    int? difficulty,
  }) async {
    debugPrint('🔄 LeaderboardService: Redirecting to LeaderboardServiceSupabase');
    return await leaderboardService.getTopEntries(
      gameType: gameType,
      limit: limit,
      difficulty: difficulty,
    );
  }

  Future<void> addEntry(dynamic entry) async {
    debugPrint('⚠️  addEntry stub called');
    if (entry is LeaderboardEntry) {
      await leaderboardService.addEntry(entry);
    }
  }

  Future<void> addScore(dynamic entry) async {
    debugPrint('⚠️  addScore stub called');
    if (entry is LeaderboardEntry) {
      await leaderboardService.addScore(entry);
    }
  }

  Future<int?> getUserRank({
    required String userId,
    required GameType gameType,
    int? difficulty,
  }) async {
    debugPrint('🔄 LeaderboardService: Redirecting to LeaderboardServiceSupabase');
    return await leaderboardService.getUserRank(
      userId: userId,
      gameType: gameType,
      difficulty: difficulty,
    );
  }
}
