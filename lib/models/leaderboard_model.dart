import 'game_model.dart';

/// Leaderboard entry types
enum LeaderboardType {
  highScore,    // En yüksek skor (Quiz, Puzzle, etc.)
  fastestTime,  // En hızlı süre (Maze, Simulation, etc.)
  winRate,      // Kazanma oranı (Chess)
}

/// Leaderboard Entry Model
class LeaderboardEntry {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final GameType gameType;
  final int score;              // Puan (quiz, puzzle için)
  final int? timeSeconds;       // Süre (maze, simulation, quiz için)
  final int? correctCount;      // Doğru sayısı (quiz için)
  final int? totalQuestions;    // Toplam soru sayısı (quiz için)
  final int? difficulty;        // Zorluk seviyesi (1-5)
  final DateTime completedAt;
  final Map<String, dynamic>? metadata; // Extra bilgiler

  LeaderboardEntry({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.gameType,
    required this.score,
    this.timeSeconds,
    this.correctCount,
    this.totalQuestions,
    this.difficulty,
    required this.completedAt,
    this.metadata,
  });

  /// Siralamada adin yanindaki kucuk rozet (marketten alinan isim rozeti).
  ///
  /// Ayri bir sutun ACILMADI: `metadata` zaten jsonb ve herkes tarafindan
  /// okunabiliyor. Rozet kaydin ICINDE durdugu icin baska bir cocugun
  /// envanterini okumaya gerek kalmiyor — o veriye erisim zaten kapali
  /// ve acilmasi dogru olmazdi.
  String? get nameBadge {
    final v = metadata?['name_badge'];
    return (v is String && v.trim().isNotEmpty) ? v : null;
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'gameType': gameType.name,
      'score': score,
      'timeSeconds': timeSeconds,
      'correctCount': correctCount,
      'totalQuestions': totalQuestions,
      'difficulty': difficulty,
      'completedAt': completedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // // REMOVED: Firebase-specific method
  // // factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) { ... }

  /// Helper to parse int safely
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Get display rank icon
  String getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  /// Get formatted time
  String getFormattedTime() {
    if (timeSeconds == null) return '-';
    final minutes = timeSeconds! ~/ 60;
    final seconds = timeSeconds! % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  // Supabase methods
  factory LeaderboardEntry.fromSupabase(Map<String, dynamic> data) {
    return LeaderboardEntry(
      id: data['id']?.toString() ?? '',
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? 'Unknown',
      userPhotoUrl: data['user_photo_url'],
      gameType: GameType.values.firstWhere(
        (e) => e.name == data['game_type'],
        orElse: () => GameType.quiz,
      ),
      score: _parseInt(data['score']),
      timeSeconds: data['time_seconds'] != null ? _parseInt(data['time_seconds']) : null,
      correctCount: data['correct_count'] != null ? _parseInt(data['correct_count']) : null,
      totalQuestions: data['total_questions'] != null ? _parseInt(data['total_questions']) : null,
      difficulty: data['difficulty'] != null ? _parseInt(data['difficulty']) : null,
      completedAt: data['completed_at'] != null
          ? DateTime.parse(data['completed_at'])
          : DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'game_type': gameType.name,
      'score': score,
      'time_seconds': timeSeconds,
      'correct_count': correctCount,
      'total_questions': totalQuestions,
      'difficulty': difficulty,
      'completed_at': completedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Copy with method
  LeaderboardEntry copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    GameType? gameType,
    int? score,
    int? timeSeconds,
    int? correctCount,
    int? totalQuestions,
    int? difficulty,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return LeaderboardEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      gameType: gameType ?? this.gameType,
      score: score ?? this.score,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      correctCount: correctCount ?? this.correctCount,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      difficulty: difficulty ?? this.difficulty,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Leaderboard configuration for each game type
extension GameTypeLeaderboard on GameType {
  LeaderboardType get leaderboardType {
    switch (this) {
      case GameType.quiz:
      case GameType.puzzle:
      case GameType.blockCoding:
      case GameType.wordMatch:
      case GameType.sequencing:
      case GameType.coordinates:
      case GameType.colorCoding:
      case GameType.leftRightCoding:
      case GameType.pipesPuzzle:
      case GameType.patternDetective:
      case GameType.variableMaster:
      case GameType.bugHunter:
      case GameType.matchingGame:
        return LeaderboardType.highScore;
      case GameType.chess:
        return LeaderboardType.winRate;
      case GameType.simulation:
      case GameType.mazeExplorer:
      case GameType.robotSimulator:
      case GameType.arduinoSimulator:
        return LeaderboardType.fastestTime;
    }
  }

  String get leaderboardTitle {
    switch (this) {
      case GameType.quiz:
        return 'Quiz Şampiyonları';
      case GameType.chess:
        return 'Satranç Ustaları';
      case GameType.blockCoding:
        return 'Kodlama Kahramanları';
      case GameType.wordMatch:
        return 'Kelime Uzmanları';
      case GameType.sequencing:
        return 'Sıralama Ustası';
      case GameType.coordinates:
        return 'Koordinat Kralları';
      case GameType.puzzle:
        return 'Bulmaca Dehası';
      case GameType.simulation:
        return 'Simülasyon Liderleri';
      case GameType.mazeExplorer:
        return 'Labirent Kaşifleri';
      case GameType.colorCoding:
        return 'Renk Kodu Uzmanları';
      case GameType.robotSimulator:
        return 'Robot Simülatörü Şampiyonları';
      case GameType.leftRightCoding:
        return 'Sağım-Solum Şampiyonları';
      case GameType.arduinoSimulator:
        return 'Arduino Atölyesi Ustaları';
      case GameType.pipesPuzzle:
        return 'Boru Bulmacası Ustaları';
      case GameType.patternDetective:
        return 'Kod Dedektifi Şampiyonları';
      case GameType.variableMaster:
        return 'Değişken Ustası Liderleri';
      case GameType.bugHunter:
        return 'Bug Hunter Uzmanları';
      case GameType.matchingGame:
        return 'Eşleştirme Şampiyonları';
    }
  }

  String get scoreLabel {
    // Special case for Quiz
    if (this == GameType.quiz) {
      return 'Doğru/Süre';
    }

    switch (leaderboardType) {
      case LeaderboardType.highScore:
        return 'Puan';
      case LeaderboardType.fastestTime:
        return 'Süre';
      case LeaderboardType.winRate:
        return 'Kazanma Oranı';
    }
  }

  String leaderboardTitleFor(String languageCode) {
    if (languageCode != 'en') return leaderboardTitle;
    switch (this) {
      case GameType.quiz:
        return 'Quiz Champions';
      case GameType.chess:
        return 'Chess Masters';
      case GameType.blockCoding:
        return 'Coding Heroes';
      case GameType.wordMatch:
        return 'Word Experts';
      case GameType.sequencing:
        return 'Sequencing Masters';
      case GameType.coordinates:
        return 'Coordinate Kings';
      case GameType.puzzle:
        return 'Puzzle Geniuses';
      case GameType.simulation:
        return 'Simulation Leaders';
      case GameType.mazeExplorer:
        return 'Maze Explorers';
      case GameType.colorCoding:
        return 'Color Code Experts';
      case GameType.robotSimulator:
        return 'Robot Simulator Champions';
      case GameType.leftRightCoding:
        return 'Left-Right Coding Champions';
      case GameType.arduinoSimulator:
        return 'Arduino Workshop Masters';
      case GameType.pipesPuzzle:
        return 'Pipe Puzzle Masters';
      case GameType.patternDetective:
        return 'Code Detective Champions';
      case GameType.variableMaster:
        return 'Variable Master Leaders';
      case GameType.bugHunter:
        return 'Bug Hunter Experts';
      case GameType.matchingGame:
        return 'Matching Champions';
    }
  }

  String scoreLabelFor(String languageCode) {
    if (languageCode != 'en') return scoreLabel;
    if (this == GameType.quiz) {
      return 'Correct/Time';
    }
    switch (leaderboardType) {
      case LeaderboardType.highScore:
        return 'Score';
      case LeaderboardType.fastestTime:
        return 'Time';
      case LeaderboardType.winRate:
        return 'Win Rate';
    }
  }
}
