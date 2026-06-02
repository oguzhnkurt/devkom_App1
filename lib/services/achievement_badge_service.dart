import 'package:flutter/foundation.dart';

/// Achievement Badge Service Stub
class AchievementBadgeService {
  Future<List<dynamic>> getUserAchievements(String userId) async {
    debugPrint('⚠️ AchievementBadgeService: Supabase migration pending');
    return [];
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    debugPrint('⚠️ AchievementBadgeService: Supabase migration pending');
  }

  Future<Map<String, dynamic>> getAchievementStats(String userId) async {
    debugPrint('⚠️  getAchievementStats - stub');
    return {};
  }

  Future<List<dynamic>> getRecentlyUnlocked(String userId, {int limit = 3}) async {
    debugPrint('⚠️  getRecentlyUnlocked - stub');
    return [];
  }
}
