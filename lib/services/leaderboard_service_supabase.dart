import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/leaderboard_model.dart';
import '../models/game_model.dart';

/// Leaderboard Service for Supabase
/// Manages leaderboard entries in Supabase
class LeaderboardServiceSupabase {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Table name
  static const String _leaderboardsTable = 'leaderboards';

  /// Kusanilmis isim rozeti. Bir oturumda bir kez okunuyor.
  String? _rozet;
  bool _rozetOkundu = false;

  /// Kusanilan isim rozetinin emojisi (yoksa null).
  ///
  /// Skor kaydedilirken KAYDIN ICINE yaziliyor; boylece siralamayi okuyan
  /// herkes rozeti goruyor ve kimsenin envanterini okumaya gerek kalmiyor.
  Future<String?> _isimRozeti() async {
    if (_rozetOkundu) return _rozet;
    _rozetOkundu = true;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;
      final data = await _supabase
          .from('user_inventory')
          .select('store_items!inner(icon_emoji, category)')
          .eq('user_id', userId)
          .eq('equipped', true)
          .eq('store_items.category', 'name_badge')
          .maybeSingle();
      _rozet = data?['store_items']?['icon_emoji'] as String?;
    } catch (e) {
      debugPrint('Isim rozeti okunamadi: $e');
      _rozet = null;
    }
    return _rozet;
  }

  /// Rozet degisince bir sonraki skorda yenisi yazilsin.
  void rozetiUnut() {
    _rozet = null;
    _rozetOkundu = false;
  }

  /// Add a new leaderboard entry
  Future<void> addEntry(LeaderboardEntry entry) async {
    try {
      final rozet = await _isimRozeti();
      final map = entry.toSupabaseMap();
      if (rozet != null) {
        final meta = Map<String, dynamic>.from(
            (map['metadata'] as Map?)?.cast<String, dynamic>() ?? {});
        meta['name_badge'] = rozet;
        map['metadata'] = meta;
      }
      await _supabase.from(_leaderboardsTable).insert(map);
      debugPrint('✅ Leaderboard entry added for ${entry.gameType.name}');
    } catch (e) {
      debugPrint('❌ Error adding leaderboard entry: $e');
      rethrow;
    }
  }

  /// Add score (alias for addEntry)
  Future<void> addScore(LeaderboardEntry entry) async {
    return addEntry(entry);
  }

  /// Get top N entries for a specific game type
  Future<List<LeaderboardEntry>> getTopEntries({
    required GameType gameType,
    int limit = 3,
    int? difficulty,
  }) async {
    try {
      var query = _supabase
          .from(_leaderboardsTable)
          .select()
          .eq('game_type', gameType.name);

      // Filter by difficulty if specified
      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }

      final response = await query;
      final entries = response
          .map((item) => LeaderboardEntry.fromSupabase(item))
          .toList();

      // Sort based on game type
      final leaderboardType = gameType.leaderboardType;

      // For Quiz: Get all and sort in memory (correctCount DESC, timeSeconds ASC)
      if (gameType == GameType.quiz) {
        entries.sort((a, b) {
          final correctCompare = (b.correctCount ?? 0).compareTo(a.correctCount ?? 0);
          if (correctCompare != 0) return correctCompare;
          return (a.timeSeconds ?? 999999).compareTo(b.timeSeconds ?? 999999);
        });
        return entries.take(limit).toList();
      }

      // For other game types, sort accordingly
      switch (leaderboardType) {
        case LeaderboardType.highScore:
          entries.sort((a, b) => b.score.compareTo(a.score));
          break;
        case LeaderboardType.fastestTime:
          entries.sort((a, b) =>
              (a.timeSeconds ?? 999999).compareTo(b.timeSeconds ?? 999999));
          break;
        case LeaderboardType.winRate:
          entries.sort((a, b) => b.score.compareTo(a.score));
          break;
      }

      return entries.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Error getting top entries: $e');
      return [];
    }
  }

  /// Get user's best entry for a specific game type
  Future<LeaderboardEntry?> getUserBestEntry({
    required String userId,
    required GameType gameType,
    int? difficulty,
  }) async {
    try {
      var query = _supabase
          .from(_leaderboardsTable)
          .select()
          .eq('user_id', userId)
          .eq('game_type', gameType.name);

      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }

      final response = await query;
      final entries = response
          .map((item) => LeaderboardEntry.fromSupabase(item))
          .toList();

      if (entries.isEmpty) return null;

      // Sort based on game type
      final leaderboardType = gameType.leaderboardType;
      switch (leaderboardType) {
        case LeaderboardType.highScore:
          entries.sort((a, b) => b.score.compareTo(a.score));
          break;
        case LeaderboardType.fastestTime:
          entries.sort((a, b) =>
              (a.timeSeconds ?? 999999).compareTo(b.timeSeconds ?? 999999));
          break;
        case LeaderboardType.winRate:
          entries.sort((a, b) => b.score.compareTo(a.score));
          break;
      }

      return entries.first;
    } catch (e) {
      debugPrint('❌ Error getting user best entry: $e');
      return null;
    }
  }

  /// Get user's rank for a specific game type
  Future<int?> getUserRank({
    required String userId,
    required GameType gameType,
    int? difficulty,
  }) async {
    try {
      // Get user's best entry
      final userEntry = await getUserBestEntry(
        userId: userId,
        gameType: gameType,
        difficulty: difficulty,
      );

      if (userEntry == null) return null;

      var query = _supabase
          .from(_leaderboardsTable)
          .select()
          .eq('game_type', gameType.name);

      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }

      final response = await query;

      // Count how many entries are better
      final leaderboardType = gameType.leaderboardType;
      int betterCount = 0;

      for (var item in response) {
        final entry = LeaderboardEntry.fromSupabase(item);

        switch (leaderboardType) {
          case LeaderboardType.highScore:
            if (entry.score > userEntry.score) betterCount++;
            break;
          case LeaderboardType.fastestTime:
            if ((entry.timeSeconds ?? 999999) < (userEntry.timeSeconds ?? 999999)) {
              betterCount++;
            }
            break;
          case LeaderboardType.winRate:
            if (entry.score > userEntry.score) betterCount++;
            break;
        }
      }

      return betterCount + 1; // +1 because rank starts at 1
    } catch (e) {
      debugPrint('❌ Error getting user rank: $e');
      return null;
    }
  }

  /// Get all entries for a specific game type (paginated)
  Future<List<LeaderboardEntry>> getAllEntries({
    required GameType gameType,
    int? difficulty,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from(_leaderboardsTable)
          .select()
          .eq('game_type', gameType.name);

      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }

      final response = await query.range(offset, offset + limit - 1);
      final entries = response
          .map((item) => LeaderboardEntry.fromSupabase(item))
          .toList();

      // Sort based on game type
      final leaderboardType = gameType.leaderboardType;
      switch (leaderboardType) {
        case LeaderboardType.highScore:
          entries.sort((a, b) => b.score.compareTo(a.score));
          break;
        case LeaderboardType.fastestTime:
          entries.sort((a, b) =>
              (a.timeSeconds ?? 999999).compareTo(b.timeSeconds ?? 999999));
          break;
        case LeaderboardType.winRate:
          entries.sort((a, b) => b.score.compareTo(a.score));
          break;
      }

      return entries;
    } catch (e) {
      debugPrint('❌ Error getting all entries: $e');
      return [];
    }
  }

  /// Delete old entries (keep only best N per user per game type)
  Future<void> cleanupOldEntries({
    required String userId,
    required GameType gameType,
    int? difficulty,
    int keepCount = 5,
  }) async {
    try {
      dynamic query = _supabase
          .from(_leaderboardsTable)
          .select()
          .eq('user_id', userId)
          .eq('game_type', gameType.name);

      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }

      final response = await query.order('completed_at', ascending: false);
      final entries = response
          .map((item) => LeaderboardEntry.fromSupabase(item))
          .toList();

      // Delete entries beyond keepCount
      if (entries.length > keepCount) {
        for (int i = keepCount; i < entries.length; i++) {
          await _supabase
              .from(_leaderboardsTable)
              .delete()
              .eq('id', entries[i].id);
        }
        debugPrint('🧹 Cleaned up ${entries.length - keepCount} old entries');
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up old entries: $e');
    }
  }

  /// Get all game types that have leaderboards
  Future<List<GameType>> getAvailableLeaderboards() async {
    try {
      final response = await _supabase
          .from(_leaderboardsTable)
          .select('game_type')
          .order('completed_at', ascending: false)
          .limit(100);

      final gameTypes = <GameType>{};
      for (var item in response) {
        final gameTypeName = item['game_type'] as String?;
        if (gameTypeName != null) {
          try {
            final gameType = GameType.values.firstWhere(
              (e) => e.name == gameTypeName,
            );
            gameTypes.add(gameType);
          } catch (e) {
            // Skip invalid game types
          }
        }
      }

      return gameTypes.toList();
    } catch (e) {
      debugPrint('❌ Error getting available leaderboards: $e');
      return [];
    }
  }

  /// Get leaderboard entries with pagination
  Future<List<LeaderboardEntry>> getEntriesPaginated(
    GameType gameType, {
    int page = 0,
    int pageSize = 50,
  }) async {
    try {
      final response = await _supabase
          .from(_leaderboardsTable)
          .select()
          .eq('game_type', gameType.name)
          .order('score', ascending: false)
          // NOT: tabloda 'timestamp' diye bir sutun yok; tarih sutunu
          // 'completed_at'. Yanlis sutun adi Supabase'den hata donduruyordu.
          .order('completed_at')
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return (response as List)
          .map((item) => LeaderboardEntry.fromSupabase(item))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting paginated leaderboard: $e');
      rethrow;
    }
  }

  /// Get user-specific leaderboard entries with pagination
  Future<List<LeaderboardEntry>> getUserEntriesPaginated(
    String userId, {
    GameType? gameType,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase
          .from(_leaderboardsTable)
          .select()
          .eq('user_id', userId);

      if (gameType != null) {
        query = query.eq('game_type', gameType.name);
      }

      final response = await query
          // NOT: tarih sutunu 'completed_at' (bkz. LeaderboardEntry.fromSupabase).
          .order('completed_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      return (response as List)
          .map((item) => LeaderboardEntry.fromSupabase(item))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting paginated user entries: $e');
      rethrow;
    }
  }
}
