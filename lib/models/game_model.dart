enum GameCategory {
  arduino,
  python,
  quiz,
  age4to6,
  age7to9,
  robotics,
  software,
}

enum GameType {
  quiz,          // Quiz (çoktan seçmeli)
  chess,         // Satranç
  blockCoding,   // Blok tabanlı kodlama (Scratch tarzı)
  wordMatch,     // İngilizce kelime eşleştirme (sürükle-bırak)
  sequencing,    // Komut dizilimi/sıralama (döngüler, koşullar)
  coordinates,   // X-Y koordinat öğrenme
  puzzle,        // Bulmaca
  simulation,    // Simülasyon
  mazeExplorer,  // Labirent Kaşifi
  colorCoding,   // Renkli Kodlar
  robotSimulator,// Robot Simülatörü
  leftRightCoding, // Sağım-Solum Kodlama (Flame 2D oyunu)
  arduinoSimulator, // Arduino Devre Simülatörü
  pipesPuzzle, // Boru Bulmacası (Pipes Puzzle)
  patternDetective, // Kod Dedektifi (Pattern Matching)
  variableMaster, // Değişken Ustası (Variable concepts)
  bugHunter, // Bug Hunter (Debugging)
}

/// GameType extension for display names
extension GameTypeExtension on GameType {
  String getTypeDisplayName() {
    switch (this) {
      case GameType.quiz:
        return 'Quiz';
      case GameType.chess:
        return 'Satranç';
      case GameType.blockCoding:
        return 'Blok Kodlama';
      case GameType.wordMatch:
        return 'Kelime Eşleştirme';
      case GameType.sequencing:
        return 'Komut Dizilimi';
      case GameType.coordinates:
        return 'Koordinat Öğrenme';
      case GameType.puzzle:
        return 'Bulmaca';
      case GameType.simulation:
        return 'Simülasyon';
      case GameType.mazeExplorer:
        return 'Labirent Kaşifi';
      case GameType.colorCoding:
        return 'Renkli Kodlar';
      case GameType.robotSimulator:
        return 'Robot Simülatörü';
      case GameType.leftRightCoding:
        return 'Sağım-Solum';
      case GameType.arduinoSimulator:
        return 'Arduino Simülatörü';
      case GameType.pipesPuzzle:
        return 'Boru Bulmacası';
      case GameType.patternDetective:
        return 'Kod Dedektifi';
      case GameType.variableMaster:
        return 'Değişken Ustası';
      case GameType.bugHunter:
        return 'Bug Hunter';
    }
  }
}

/// Game Model for Robotics Games
class GameModel {
  final String id;
  final String title;
  final String description;
  final GameCategory category;
  final GameType type;
  final String thumbnailUrl;
  final int difficulty; // 1-5
  final int estimatedMinutes;
  final List<String> tags;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Game content
  final Map<String, dynamic> gameData; // Quiz questions, simulation params, etc.

  GameModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.thumbnailUrl,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.tags,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    required this.gameData,
  });

  // // REMOVED: Firebase-specific method
  // // factory GameModel.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'type': type.name,
      'thumbnailUrl': thumbnailUrl,
      'difficulty': difficulty,
      'estimatedMinutes': estimatedMinutes,
      'tags': tags,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'gameData': gameData,
    };
  }

  String getCategoryDisplayName() {
    switch (category) {
      case GameCategory.arduino:
        return 'Arduino';
      case GameCategory.python:
        return 'Python';
      case GameCategory.quiz:
        return 'Quiz';
      case GameCategory.age4to6:
        return '4-6 Yaş';
      case GameCategory.age7to9:
        return '7-9 Yaş';
      case GameCategory.robotics:
        return 'Robotik';
      case GameCategory.software:
        return 'Yazılım';
    }
  }

  // Supabase methods
  factory GameModel.fromSupabase(Map<String, dynamic> data) {
    return GameModel(
      id: data['id']?.toString() ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: GameCategory.values.byName(data['category'] ?? 'arduino'),
      type: GameType.values.byName(data['type'] ?? 'quiz'),
      thumbnailUrl: data['thumbnail_url'] ?? '',
      difficulty: data['difficulty'] ?? 1,
      estimatedMinutes: data['estimated_minutes'] ?? 10,
      tags: data['tags'] != null
          ? List<String>.from(data['tags'])
          : [],
      isActive: data['is_active'] ?? true,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
      gameData: data['game_data'] != null
          ? Map<String, dynamic>.from(data['game_data'])
          : {},
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'type': type.name,
      'thumbnail_url': thumbnailUrl,
      'difficulty': difficulty,
      'estimated_minutes': estimatedMinutes,
      'tags': tags,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'game_data': gameData,
    };
  }

  String getTypeDisplayName() {
    switch (type) {
      case GameType.quiz:
        return 'Quiz';
      case GameType.chess:
        return 'Satranç';
      case GameType.blockCoding:
        return 'Blok Kodlama';
      case GameType.wordMatch:
        return 'Kelime Eşleştirme';
      case GameType.sequencing:
        return 'Komut Dizilimi';
      case GameType.coordinates:
        return 'Koordinat Öğrenme';
      case GameType.puzzle:
        return 'Bulmaca';
      case GameType.simulation:
        return 'Simülasyon';
      case GameType.mazeExplorer:
        return 'Labirent Kaşifi';
      case GameType.colorCoding:
        return 'Renkli Kodlar';
      case GameType.robotSimulator:
        return 'Robot Simülatörü';
      case GameType.leftRightCoding:
        return 'Sağım-Solum';
      case GameType.arduinoSimulator:
        return 'Arduino Simülatörü';
      case GameType.pipesPuzzle:
        return 'Boru Bulmacası';
      case GameType.patternDetective:
        return 'Kod Dedektifi';
      case GameType.variableMaster:
        return 'Değişken Ustası';
      case GameType.bugHunter:
        return 'Bug Hunter';
    }
  }
}

/// Game Progress Model
class GameProgress {
  final String userId;
  final String gameId;
  final int score;
  final bool completed;
  final int timeSpentMinutes;
  final DateTime playedAt;
  final Map<String, dynamic> progressData;

  GameProgress({
    required this.userId,
    required this.gameId,
    required this.score,
    required this.completed,
    required this.timeSpentMinutes,
    required this.playedAt,
    required this.progressData,
  });

  // // REMOVED: Firebase-specific method
  // // factory GameProgress.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'gameId': gameId,
      'score': score,
      'completed': completed,
      'timeSpentMinutes': timeSpentMinutes,
      'playedAt': playedAt.toIso8601String(),
      'progressData': progressData,
    };
  }

  // Supabase methods
  factory GameProgress.fromSupabase(Map<String, dynamic> data) {
    return GameProgress(
      userId: data['user_id'] ?? '',
      gameId: data['game_id'] ?? '',
      score: data['score'] ?? 0,
      completed: data['completed'] ?? false,
      timeSpentMinutes: data['time_spent_minutes'] ?? 0,
      playedAt: data['played_at'] != null
          ? DateTime.parse(data['played_at'])
          : DateTime.now(),
      progressData: data['progress_data'] != null
          ? Map<String, dynamic>.from(data['progress_data'])
          : {},
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'user_id': userId,
      'game_id': gameId,
      'score': score,
      'completed': completed,
      'time_spent_minutes': timeSpentMinutes,
      'played_at': playedAt.toIso8601String(),
      'progress_data': progressData,
    };
  }
}
