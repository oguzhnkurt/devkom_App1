import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_model.dart';
import 'embedded_games_service.dart';
import 'package:flutter/foundation.dart';

class GamesServiceSupabase {
  final SupabaseClient _supabase = Supabase.instance.client;
  static final List<GameModel> _demoGames = _createDemoGames();

  static const String _gamesTable = 'games';
  static const String _gameProgressTable = 'game_progress';

  // Get all games (combines embedded games, demo games, and Supabase games) - Real-time
  Stream<List<GameModel>> getAllGames() async* {
    // Get embedded and demo games
    final embeddedGames = EmbeddedGamesService.getActiveGames();
    final demoGames = _demoGames.where((game) => game.isActive).toList();

    try {
      // Stream Supabase games and combine with local games
      await for (final data in _supabase
          .from(_gamesTable)
          .stream(primaryKey: ['id'])
          .eq('is_active', true)) {

        final supabaseGames = data
            .map((item) {
              try {
                return GameModel.fromSupabase(item);
              } catch (e) {
                debugPrint('Error parsing game ${item['id']}: $e');
                return null;
              }
            })
            .where((game) => game != null)
            .cast<GameModel>()
            .toList();

        // Combine all games: embedded + demo + supabase
        yield [...embeddedGames, ...demoGames, ...supabaseGames];
      }
    } catch (error) {
      // If Supabase fails, return only local games
      debugPrint('Error fetching Supabase games: $error');
      yield [...embeddedGames, ...demoGames];
    }
  }

  // Get games for visitors (only Quiz and Left-Right games)
  Stream<List<GameModel>> getVisitorGames() async* {
    // Get only visitor-accessible games
    final visitorGames = EmbeddedGamesService.getVisitorGames();

    // Return visitor games immediately (no Supabase needed for visitors)
    yield visitorGames;
  }

  static List<GameModel> _createDemoGames() {
    // Return empty list - demo games are now in games_service.dart
    // We keep this method for backward compatibility
    return [];
  }

  // Get games by category - Real-time
  Stream<List<GameModel>> getGamesByCategory(GameCategory category) async* {
    // Get local games filtered by category
    final embeddedGames = EmbeddedGamesService.getGamesByCategory(category)
        .where((game) => game.isActive)
        .toList();
    final demoGames = _demoGames
        .where((game) => game.category == category && game.isActive)
        .toList();

    try {
      // Stream Supabase games filtered by category and active status
      await for (final data in _supabase
          .from(_gamesTable)
          .stream(primaryKey: ['id'])) {

        final supabaseGames = data
            .where((item) =>
                item['category'] == category.name &&
                item['is_active'] == true)
            .map((item) {
              try {
                return GameModel.fromSupabase(item);
              } catch (e) {
                debugPrint('Error parsing game ${item['id']}: $e');
                return null;
              }
            })
            .where((game) => game != null)
            .cast<GameModel>()
            .toList();

        // Combine all games
        yield [...embeddedGames, ...demoGames, ...supabaseGames];
      }
    } catch (error) {
      // If Supabase fails, return only local games
      debugPrint('Error fetching category games: $error');
      yield [...embeddedGames, ...demoGames];
    }
  }

  // Get single game
  Future<GameModel?> getGame(String gameId) async {
    try {
      // First check embedded games
      final embeddedGame = EmbeddedGamesService.getGameById(gameId);
      if (embeddedGame != null) {
        return embeddedGame;
      }

      // Then check demo games
      try {
        final demoGame = _demoGames.firstWhere((game) => game.id == gameId);
        return demoGame;
      } catch (e) {
        // Not found in demo games, try Supabase
      }

      // Finally check Supabase
      final response = await _supabase
          .from(_gamesTable)
          .select()
          .eq('id', gameId)
          .single();

      return GameModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Oyun yüklenemedi: $e');
    }
  }

  // Save game progress
  Future<void> saveGameProgress(GameProgress progress) async {
    try {
      await _supabase
          .from(_gameProgressTable)
          .insert(progress.toSupabaseMap());
    } catch (e) {
      throw Exception('İlerleme kaydedilemedi: $e');
    }
  }

  // Get user progress for a game
  Future<GameProgress?> getUserGameProgress(String userId, String gameId) async {
    try {
      final response = await _supabase
          .from(_gameProgressTable)
          .select()
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .order('played_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return GameProgress.fromSupabase(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get all user progress - Real-time
  Stream<List<GameProgress>> getUserProgress(String userId) {
    return _supabase
        .from(_gameProgressTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('played_at', ascending: false)
        .map((data) => data.map((item) => GameProgress.fromSupabase(item)).toList());
  }

  // Initialize default robotics games in Supabase
  Future<void> initializeDefaultRoboticsGames() async {
    try {
      debugPrint('🎮 Robotik oyunları kontrol ediliyor...');

      // Check for each specific game by title and update/create as needed
      final games = {
        'Labirent Kaşifi': {
          'description': 'Labirenti çözerek çıkış yolunu bulun! Algoritmik düşünme becerilerinizi geliştirin.',
          'category': 'robotics',
          'type': 'mazeExplorer',
          'thumbnail_url': '',
          'difficulty': 2,
          'estimated_minutes': 15,
          'tags': ['algoritma', 'problem çözme', 'mantık'],
          'is_active': true,
          'game_data': {
            'levels': 10,
            'initialLevel': 1,
          },
        },
      };

      int updatedCount = 0;
      int createdCount = 0;

      for (var entry in games.entries) {
        final title = entry.key;
        final gameData = entry.value;

        // Check if game exists
        final existing = await _supabase
            .from(_gamesTable)
            .select()
            .eq('title', title)
            .limit(1)
            .maybeSingle();

        if (existing != null) {
          // Update existing game
          await _supabase
              .from(_gamesTable)
              .update({
                ...gameData,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', existing['id']);
          debugPrint('🔄 $title güncellendi');
          updatedCount++;
        } else {
          // Create new game
          await _supabase.from(_gamesTable).insert({
            'title': title,
            ...gameData,
            'created_at': DateTime.now().toIso8601String(),
          });
          debugPrint('✅ $title eklendi');
          createdCount++;
        }
      }

      debugPrint('🎉 Tamamlandı: $createdCount yeni, $updatedCount güncellendi');
    } catch (e) {
      debugPrint('❌ Robotik oyunlar eklenirken hata: $e');
    }
  }

  // Delete duplicate chess games from Supabase
  Future<void> deleteDuplicateChessGames() async {
    try {
      debugPrint('🗑️ Duplicate satranç oyunları siliniyor...');

      // Get all games
      final allGames = await _supabase.from(_gamesTable).select();

      int deletedCount = 0;

      for (var data in allGames) {
        final title = data['title'] as String?;
        final type = data['type'] as String?;

        // Delete if it's a chess game OR has "satranç" in title
        if (title != null &&
            (title.toLowerCase().contains('satranç') ||
                title.toLowerCase().contains('chess') ||
                type == 'chess')) {
          debugPrint('  🗑️ Siliniyor: $title (ID: ${data['id']})');
          await _supabase.from(_gamesTable).delete().eq('id', data['id']);
          deletedCount++;
        }
      }

      debugPrint('✅ $deletedCount duplicate satranç oyunu silindi!');
      debugPrint('👉 Sadece embedded_chess (kod içinde) kalacak.');
    } catch (e) {
      debugPrint('❌ Satranç oyunları silinirken hata: $e');
      rethrow;
    }
  }

  /// Get game progress (stub method for compatibility)
  Future<Map<String, dynamic>?> getGameProgress(String userId, String gameId) async {
    final progress = await getUserGameProgress(userId, gameId);
    if (progress == null) return null;
    return {
      'userId': progress.userId,
      'gameId': progress.gameId,
      'score': progress.score,
      'completed': progress.completed,
      'timeSpentMinutes': progress.timeSpentMinutes,
      'progressData': progress.progressData,
    };
  }
}
