import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';
import '../models/game_model.dart';

/// Games Service Stub - Redirects to Supabase
class GamesService {
  Future<List<dynamic>> getAllGames() async {
    debugPrint('🔄 GamesService: Redirecting to GamesServiceSupabase');
    return await gamesService.getAllGames().first;
  }

  Future<dynamic> getGame(String gameId) async {
    debugPrint('🔄 GamesService: Redirecting to GamesServiceSupabase');
    return await gamesService.getGame(gameId);
  }

  Future<void> saveGameProgress(GameProgress progress) async {
    debugPrint('🔄 GamesService: Redirecting to GamesServiceSupabase');
    await gamesService.saveGameProgress(progress);
  }

  Future<Map<String, dynamic>?> getGameProgress(String userId, String gameId) async {
    debugPrint('🔄 GamesService: Redirecting to GamesServiceSupabase');
    return await gamesService.getGameProgress(userId, gameId);
  }

  Future<List<dynamic>> getGamesByCategory(String category) async {
    debugPrint('⚠️  getGamesByCategory - stub');
    return [];
  }
}
