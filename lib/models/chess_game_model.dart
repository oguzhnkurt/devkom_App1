import '../utils/lang.dart';

/// Difficulty levels for chess AI
///
/// DORT SEVIYE (Ekim 2026): Kolay · Orta · Zor · Imkansiz. "Ileri" eskiden
/// dogrudan Stockfish'in tam gucuydu; cocuk icin "zor" degil "kazanilamaz"
/// demekti ve Orta ile arasinda koca bir bosluk vardi. Zor artik
/// kazanilabilir bir rakip; tam guc ayri bir seviye: Imkansiz.
///
/// SIRA ONEMLI: skor tablosu seviyeyi `index` olarak sakliyor. Yeni seviye
/// en sona eklendi; eski kayitlarin anlami degismiyor.
enum ChessDifficulty {
  beginner, // Kolay: kendi rakibimiz, cogu hamle rastgele, mati cogu zaman gormez
  intermediate, // Orta: Stockfish Skill 3, 300 ms + dortte bir insani hamle
  advanced, // Zor: Stockfish Skill 6, 600 ms
  impossible, // Imkansiz: Stockfish Skill 20, 2 sn
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
  final String maxLevelPlayed; // beginner, intermediate, advanced, impossible
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
        return 'Kolay';
      case ChessDifficulty.intermediate:
        return 'Orta';
      case ChessDifficulty.advanced:
        return 'Zor';
      case ChessDifficulty.impossible:
        return 'İmkânsız';
    }
  }

  // Almanca ve Ispanyolca eskiden Turkceye dusuyordu: "Başlangıç"
  // magaza gorselinde Almanca ekranda gorundu.
  String displayNameFor(String languageCode) {
    switch (this) {
      case ChessDifficulty.beginner:
        return AppLang.pick(languageCode,
            tr: 'Kolay', en: 'Easy', de: 'Leicht', es: 'Fácil');
      case ChessDifficulty.intermediate:
        return AppLang.pick(languageCode,
            tr: 'Orta', en: 'Medium', de: 'Mittel', es: 'Medio');
      case ChessDifficulty.advanced:
        return AppLang.pick(languageCode,
            tr: 'Zor', en: 'Hard', de: 'Schwer', es: 'Difícil');
      case ChessDifficulty.impossible:
        return AppLang.pick(languageCode,
            tr: 'İmkânsız', en: 'Impossible', de: 'Unmöglich', es: 'Imposible');
    }
  }

  String get description {
    switch (this) {
      case ChessDifficulty.beginner:
        return 'Satranca yeni başlayanlar için';
      case ChessDifficulty.intermediate:
        return 'Kuralları bilenler için';
      case ChessDifficulty.advanced:
        return 'Plan yapıp hamle hesaplayanlar için';
      case ChessDifficulty.impossible:
        return 'Tam güç: yenebilir misin?';
    }
  }

  String descriptionFor(String languageCode) {
    switch (this) {
      case ChessDifficulty.beginner:
        return AppLang.pick(languageCode,
            tr: 'Satranca yeni başlayanlar için', en: 'For chess beginners',
            de: 'Für Schach-Einsteiger', es: 'Para quienes empiezan');
      case ChessDifficulty.intermediate:
        return AppLang.pick(languageCode,
            tr: 'Kuralları bilenler için', en: 'For players who know the rules',
            de: 'Für alle, die die Regeln kennen', es: 'Para quienes conocen las reglas');
      case ChessDifficulty.advanced:
        return AppLang.pick(languageCode,
            tr: 'Plan yapıp hamle hesaplayanlar için', en: 'For players who plan ahead',
            de: 'Für alle, die vorausdenken', es: 'Para quienes planifican');
      case ChessDifficulty.impossible:
        return AppLang.pick(languageCode,
            tr: 'Tam güç: yenebilir misin?', en: 'Full strength: can you win?',
            de: 'Volle Stärke: Schaffst du es?', es: 'Máxima potencia: ¿puedes ganar?');
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
      case ChessDifficulty.impossible:
        return 4;  // Full engine strength
    }
  }

  int get estimatedElo {
    switch (this) {
      // Ekim 2026: kolay seviye bilerek hata yapan kendi rakibimiz,
      // orta seviye Stockfish 3 + insani hamleler (chess_ai_service.dart).
      case ChessDifficulty.beginner:
        return 400;
      // Deneme maclari (Ekim 2026): Orta, Elo 1320 ayarli Stockfish'e
      // 6/10; Zor, Elo 1700'e 8/8; Imkansiz, Zor'a 6/6.
      case ChessDifficulty.intermediate:
        return 1300;
      case ChessDifficulty.advanced:
        return 1900;
      case ChessDifficulty.impossible:
        return 2800;
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
