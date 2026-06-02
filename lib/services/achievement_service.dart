import 'package:flutter/foundation.dart';

/// Achievement Service Stub
class AchievementService {
  Future<List<dynamic>> getUserAchievements(String userId) async {
    debugPrint('⚠️ AchievementService: Supabase migration pending');
    return [];
  }

  Future<void> checkAndUnlockAchievements(String userId) async {
    debugPrint('⚠️ AchievementService: Supabase migration pending');
  }

  Future<Map<String, dynamic>> getOverallStatistics(String userId) async {
    debugPrint('⚠️ AchievementService.getOverallStatistics: Supabase migration pending');
    return {};
  }

  Future<List<dynamic>> getGameStatistics(String userId) async {
    debugPrint('⚠️ AchievementService.getGameStatistics: Supabase migration pending');
    return [];
  }

  Future<void> saveGameResult({
    required String userId,
    required String gameId,
    required int score,
    required int duration,
  }) async {
    debugPrint('⚠️ AchievementService.saveGameResult: Supabase migration pending');
  }
}
