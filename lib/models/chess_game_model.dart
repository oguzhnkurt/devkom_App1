/// Difficulty levels for chess AI
enum ChessDifficulty {
  beginner, // Depth 1-2, Random moves
  intermediate, // Depth 3-4, Basic strategy
  advanced, // Depth 5-6, Advanced tactics
}

/// Game result
enum GameResult {
  win,
  loss,
  draw,
  ongoing,
}

/// Chess game model for Firestore
class ChessGameModel {
  final String gameId;
  final String playerId;
  final String playerName;
  final String opponent; // "AI" or user UID
  final ChessDifficulty difficulty;
  final GameResult result;
  final int duration; // in seconds
  final List<String> moveHistory; // Standard algebraic notation
  final String finalFEN; // Final board position
  final DateTime timestamp;
  final DateTime? startTime;
  final DateTime? endTime;

  ChessGameModel({
    required this.gameId,
    required this.playerId,
    required this.playerName,
    required this.opponent,
    required this.difficulty,
    required this.result,
    required this.duration,
    required this.moveHistory,
    required this.finalFEN,
    required this.timestamp,
    this.startTime,
    this.endTime,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'playerId': playerId,
      'playerName': playerName,
      'opponent': opponent,
      'difficulty': difficulty.name,
      'result': result.name,
      'duration': duration,
      'moveHistory': moveHistory,
      'finalFEN': finalFEN,
      'timestamp': timestamp.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  // // REMOVED: Firebase-specific method
  // // factory ChessGameModel.fromFirestore(DocumentSnapshot doc) { ... }

  /// Copy with method
  ChessGameModel copyWith({
    String? gameId,
    String? playerId,
    String? playerName,
    String? opponent,
    ChessDifficulty? difficulty,
    GameResult? result,
    int? duration,
    List<String>? moveHistory,
    String? finalFEN,
    DateTime? timestamp,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ChessGameModel(
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      opponent: opponent ?? this.opponent,
      difficulty: difficulty ?? this.difficulty,
      result: result ?? this.result,
      duration: duration ?? this.duration,
      moveHistory: moveHistory ?? this.moveHistory,
      finalFEN: finalFEN ?? this.finalFEN,
      timestamp: timestamp ?? this.timestamp,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Chess player statistics model
class ChessStatsModel {
  final String userId;
  final String email;
  final String name;
  final String role;
  final int totalGames;
  final int wins;
  final int losses;
  final int draws;
  final int avgDuration; // in seconds
  final String maxLevelPlayed; // beginner, intermediate, advanced
  final DateTime lastPlayed;

  ChessStatsModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.avgDuration,
    required this.maxLevelPlayed,
    required this.lastPlayed,
  });

  /// Computed properties
  double get winRate => totalGames > 0 ? (wins / totalGames) * 100 : 0.0;
  double get lossRate => totalGames > 0 ? (losses / totalGames) * 100 : 0.0;
  double get drawRate => totalGames > 0 ? (draws / totalGames) * 100 : 0.0;

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'role': role,
      'totalGames': totalGames,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'avgDuration': avgDuration,
      'maxLevelPlayed': maxLevelPlayed,
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  // // REMOVED: Firebase-specific method
  // // factory ChessStatsModel.fromFirestore(DocumentSnapshot doc) { ... }
}

/// Extension for difficulty display
extension ChessDifficultyExtension on ChessDifficulty {
  String get displayName {
    switch (this) {
      case ChessDifficulty.beginner:
        return 'Başlangıç';
      case ChessDifficulty.intermediate:
        return 'Orta';
      case ChessDifficulty.advanced:
        return 'İleri';
    }
  }

  String displayNameFor(String languageCode) {
    if (languageCode != 'en') return displayName;
    switch (this) {
      case ChessDifficulty.beginner:
        return 'Beginner';
      case ChessDifficulty.intermediate:
        return 'Intermediate';
      case ChessDifficulty.advanced:
        return 'Advanced';
    }
  }

  String get description {
    switch (this) {
      case ChessDifficulty.beginner:
        return 'Yeni başlayanlar için';
      case ChessDifficulty.intermediate:
        return 'Orta seviye oyuncular için';
      case ChessDifficulty.advanced:
        return 'İleri seviye oyuncular için';
    }
  }

  String descriptionFor(String languageCode) {
    if (languageCode != 'en') return description;
    switch (this) {
      case ChessDifficulty.beginner:
        return 'For beginners';
      case ChessDifficulty.intermediate:
        return 'For intermediate players';
      case ChessDifficulty.advanced:
        return 'For advanced players';
    }
  }

  int get depth {
    switch (this) {
      case ChessDifficulty.beginner:
        return 1;  // Easy, makes mistakes
      case ChessDifficulty.intermediate:
        return 2;  // Decent tactical play
      case ChessDifficulty.advanced:
        return 3;  // Strong, challenging play
    }
  }

  int get estimatedElo {
    switch (this) {
      case ChessDifficulty.beginner:
        return 800;
      case ChessDifficulty.intermediate:
        return 1400;
      case ChessDifficulty.advanced:
        return 2000;
    }
  }
}

/// Extension for result display
extension GameResultExtension on GameResult {
  String get displayName {
    switch (this) {
      case GameResult.win:
        return 'Kazanıldı';
      case GameResult.loss:
        return 'Kaybedildi';
      case GameResult.draw:
        return 'Berabere';
      case GameResult.ongoing:
        return 'Devam Ediyor';
    }
  }
}
