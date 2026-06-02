import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';

/// Daily Quest Service Stub - Redirects to Supabase
class DailyQuestService {
  Future<List<dynamic>> getDailyQuests(String userId) async {
    debugPrint('🔄 DailyQuestService: Redirecting to DailyQuestServiceSupabase');
    return await dailyQuestService.getDailyQuests(userId);
  }

  Future<void> completeQuest(String userId, String questId) async {
    debugPrint('🔄 DailyQuestService: Redirecting to DailyQuestServiceSupabase');
    await dailyQuestService.completeQuest(userId, questId);
  }

  Stream<List<dynamic>> getUserQuests(String userId) {
    debugPrint('⚠️  getUserQuests - stub');
    return Stream.value([]);
  }

  Future<void> generateDailyQuests(String userId) async {
    debugPrint('⚠️  generateDailyQuests - stub');
  }
}
