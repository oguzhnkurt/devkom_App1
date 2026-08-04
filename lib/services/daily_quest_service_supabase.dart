import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_quest_model.dart';
import 'package:flutter/foundation.dart';

/// Günlük Görev Servisi - Supabase
/// Görevleri yönetir, ilerlemeyi takip eder ve ödülleri dağıtır
class DailyQuestServiceSupabase {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _questsTable = 'daily_quests';
  static const String _usersTable = 'users';

  /// Kullanıcının günlük görevlerini getir - Real-time
  Stream<List<DailyQuest>> getUserQuests(String userId) {
    final now = DateTime.now().toIso8601String();
    return _supabase
        .from(_questsTable)
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((item) =>
                item['user_id'] == userId &&
                (item['expires_at'] as String).compareTo(now) > 0)
            .map((item) => DailyQuest.fromSupabase(item))
            .toList());
  }

  /// Yeni günlük görevler oluştur
  Future<void> generateDailyQuests(String userId) async {
    // Bugünün görevlerini kontrol et
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final existingQuests = await _supabase
        .from(_questsTable)
        .select()
        .eq('user_id', userId)
        .gte('created_at', todayStart.toIso8601String())
        .lte('created_at', todayEnd.toIso8601String());

    // Eğer bugün için görev varsa yenisini oluşturma
    if (existingQuests.isNotEmpty) {
      return;
    }

    // Yeni görevler oluştur
    final quests = DailyQuestFactory.generateDailyQuests(userId);

    // Supabase'e kaydet
    for (final quest in quests) {
      await _supabase.from(_questsTable).insert({
        'user_id': userId,
        ...quest.toSupabaseMap(),
      });
    }
  }

  /// Görev ilerlemesini güncelle
  Future<void> updateQuestProgress(
    String userId,
    QuestType questType,
    int increment,
  ) async {
    try {
      // Aktif görevleri getir
      final response = await _supabase
          .from(_questsTable)
          .select()
          .eq('user_id', userId)
          .eq('type', questType.toString().split('.').last)
          .eq('is_completed', false)
          .gt('expires_at', DateTime.now().toIso8601String());

      if (response.isEmpty) return;

      for (final item in response) {
        final quest = DailyQuest.fromSupabase(item);
        final newProgress = quest.currentProgress + increment;
        final isNowCompleted = newProgress >= quest.targetValue;

        await _supabase.from(_questsTable).update({
          'current_progress': newProgress,
          'is_completed': isNowCompleted,
        }).eq('id', quest.id);

        // Görev tamamlandıysa XP ver
        if (isNowCompleted && !quest.isCompleted) {
          await _awardXP(userId, quest.rewardXP);
        }
      }
    } catch (e) {
      debugPrint('Quest progress update error: $e');
    }
  }

  /// XP ödülü ver
  Future<void> _awardXP(String userId, int xp) async {
    try {
      // Get current XP
      final response = await _supabase
          .from(_usersTable)
          .select('total_xp')
          .eq('id', userId)
          .single();

      final currentXP = response['total_xp'] ?? 0;

      // Update XP
      await _supabase.from(_usersTable).update({
        'total_xp': currentXP + xp,
        'last_xp_earned': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      debugPrint('XP award error: $e');
    }
  }

  /// Tamamlanan görevleri topla
  Future<void> claimCompletedQuest(String userId, String questId) async {
    try {
      await _supabase
          .from(_questsTable)
          .update({
            'claimed': true,
            'claimed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', questId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Claim quest error: $e');
    }
  }

  /// Süresi dolan görevleri temizle
  Future<void> cleanupExpiredQuests(String userId) async {
    try {
      await _supabase
          .from(_questsTable)
          .delete()
          .eq('user_id', userId)
          .lt('expires_at', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  /// Oyun sonrası görev güncellemesi
  Future<void> onGameCompleted(
    String userId, {
    required int score,
    required int levelsCompleted,
    required String gameType,
  }) async {
    // Oyun oynama görevi
    await updateQuestProgress(userId, QuestType.playGames, 1);

    // Puan kazanma görevi
    await updateQuestProgress(userId, QuestType.earnScore, score);

    // Seviye tamamlama görevi
    await updateQuestProgress(userId, QuestType.completeLevel, levelsCompleted);

    // Mükemmel skor görevi
    if (score >= 900) {
      await updateQuestProgress(userId, QuestType.perfectScore, 1);
    }
  }

  /// Kullanıcının toplam XP'sini getir
  Future<int> getUserTotalXP(String userId) async {
    try {
      final response = await _supabase
          .from(_usersTable)
          .select('total_xp')
          .eq('id', userId)
          .single();

      return response['total_xp'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get daily quests (stub method for compatibility)
  Future<List<dynamic>> getDailyQuests(String userId) async {
    final quests = await getUserQuests(userId).first;
    return quests;
  }

  /// Complete a quest (stub method for compatibility)
  Future<void> completeQuest(String userId, String questId) async {
    await claimCompletedQuest(userId, questId);
  }
}
