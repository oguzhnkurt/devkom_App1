import '../models/game_model.dart';

/// Skor Standardizasyonu - Tüm oyunlar için 0-1000 arası skor
///
/// Formül: baseScore + performanceBonus + difficultyMultiplier
class ScoreCalculator {
  // Her oyun tipi için baz skorlar
  static const Map<GameType, int> _baseScores = {
    GameType.coordinates: 100,
    GameType.colorCoding: 100,
    GameType.pipesPuzzle: 100,
    GameType.wordMatch: 100,
    GameType.sequencing: 100,
    GameType.blockCoding: 150,
    GameType.leftRightCoding: 120,
    GameType.quiz: 200,
    GameType.chess: 300,
    GameType.mazeExplorer: 250,
    GameType.arduinoSimulator: 200,
  };

  // Zorluk çarpanları (oyun tipine göre)
  static const Map<GameType, double> _difficultyMultipliers = {
    GameType.coordinates: 1.0,
    GameType.colorCoding: 1.2,
    GameType.pipesPuzzle: 1.3,
    GameType.wordMatch: 0.8,
    GameType.sequencing: 1.0,
    GameType.blockCoding: 1.5,
    GameType.leftRightCoding: 1.4,
    GameType.quiz: 2.0,
    GameType.chess: 3.0,
    GameType.mazeExplorer: 2.5,
    GameType.arduinoSimulator: 2.0,
  };

  /// Koordinat oyunu için skor hesapla
  ///
  /// Parametreler:
  /// - [level]: Tamamlanan seviye (1-15)
  /// - [timeRemaining]: Kalan süre (saniye)
  /// - [totalTime]: Toplam süre (saniye)
  static int calculateCoordinatesScore({
    required int level,
    required int timeRemaining,
    required int totalTime,
  }) {
    final base = _baseScores[GameType.coordinates]!;
    final levelBonus = level * 10; // Her seviye +10 puan

    // Hız bonusu: Kalan süreye göre 0-50 arası
    final timeRatio = timeRemaining / totalTime;
    final speedBonus = (timeRatio * 50).round();

    final total = base + levelBonus + speedBonus;
    final multiplier = _difficultyMultipliers[GameType.coordinates]!;

    return _normalize((total * multiplier).round());
  }

  /// Renkli Kodlar oyunu için skor hesapla
  ///
  /// Parametreler:
  /// - [level]: Tamamlanan seviye
  /// - [sequenceLength]: Dizinin uzunluğu
  /// - [isPracticeMode]: Pratik modu mu?
  static int calculateColorCodingScore({
    required int level,
    required int sequenceLength,
    bool isPracticeMode = false,
  }) {
    if (isPracticeMode) return 0; // Pratik modda skor yok

    final base = _baseScores[GameType.colorCoding]!;
    final levelBonus = level * 15; // Her seviye +15 puan
    final lengthBonus = sequenceLength * 5; // Her renk +5 puan

    final total = base + levelBonus + lengthBonus;
    final multiplier = _difficultyMultipliers[GameType.colorCoding]!;

    return _normalize((total * multiplier).round());
  }

  /// Pipes oyunu için skor hesapla
  ///
  /// Parametreler:
  /// - [level]: Tamamlanan seviye
  /// - [moves]: Kullanılan hamle sayısı
  /// - [gridSize]: Grid boyutu (4, 6, 8)
  static int calculatePipesScore({
    required int level,
    required int moves,
    required int gridSize,
  }) {
    final base = _baseScores[GameType.pipesPuzzle]!;
    final levelBonus = level * 20; // Her seviye +20 puan

    // Optimal hamle hesapla (grid boyutuna göre)
    final optimalMoves = gridSize * 2;

    // Verimlilik bonusu: Az hamle = yüksek bonus
    final efficiency = optimalMoves / moves.clamp(1, 100);
    final efficiencyBonus = (efficiency * 50).clamp(0, 100).round();

    final total = base + levelBonus + efficiencyBonus;
    final multiplier = _difficultyMultipliers[GameType.pipesPuzzle]!;

    return _normalize((total * multiplier).round());
  }

  /// Kelime Avı oyunu için skor hesapla
  ///
  /// Parametreler:
  /// - [level]: Tamamlanan seviye
  /// - [foundWords]: Bulunan kelime sayısı
  /// - [totalWords]: Toplam kelime sayısı
  static int calculateWordMatchScore({
    required int level,
    required int foundWords,
    required int totalWords,
  }) {
    final base = _baseScores[GameType.wordMatch]!;
    final levelBonus = level * 12;

    // Tamamlama oranı bonusu
    final completionRatio = foundWords / totalWords;
    final completionBonus = (completionRatio * 80).round();

    final total = base + levelBonus + completionBonus;
    final multiplier = _difficultyMultipliers[GameType.wordMatch]!;

    return _normalize((total * multiplier).round());
  }

  /// Milyoner oyunu için skor hesapla
  ///
  /// Parametreler:
  /// - [correctAnswers]: Doğru cevap sayısı
  /// - [totalQuestions]: Toplam soru sayısı (15)
  /// - [usedJokers]: Kullanılan joker sayısı
  static int calculateMillionaireScore({
    required int correctAnswers,
    required int totalQuestions,
    required int usedJokers,
  }) {
    final base = _baseScores[GameType.quiz]!;

    // Her doğru cevap için bonus (üstel artış)
    final answerBonus = correctAnswers * correctAnswers * 10;

    // Joker penaltısı
    final jokerPenalty = usedJokers * 20;

    final total = (base + answerBonus - jokerPenalty).clamp(0, 10000);
    final multiplier = _difficultyMultipliers[GameType.quiz]!;

    return _normalize((total * multiplier).round());
  }

  /// Satranç oyunu için skor hesapla
  ///
  /// Parametreler:
  /// - [didWin]: Kazandı mı?
  /// - [difficulty]: Zorluk seviyesi (0: Kolay, 1: Orta, 2: Zor)
  /// - [movesCount]: Hamle sayısı
  static int calculateChessScore({
    required bool didWin,
    required int difficulty,
    required int movesCount,
  }) {
    if (!didWin) return 0;

    final base = _baseScores[GameType.chess]!;

    // Zorluk bonusu
    final difficultyBonus = [100, 250, 500][difficulty];

    // Hız bonusu (az hamle = yüksek bonus)
    final speedBonus = (100 / (movesCount / 10)).clamp(0, 150).round();

    final total = base + difficultyBonus + speedBonus;
    final multiplier = _difficultyMultipliers[GameType.chess]!;

    return _normalize((total * multiplier).round());
  }

  /// Genel oyun skoru hesapla (diğer oyunlar için)
  ///
  /// Parametreler:
  /// - [gameType]: Oyun tipi
  /// - [level]: Seviye
  /// - [performance]: Performans oranı (0.0 - 1.0)
  static int calculateGenericScore({
    required GameType gameType,
    required int level,
    required double performance,
  }) {
    final base = _baseScores[gameType] ?? 100;
    final levelBonus = level * 15;
    final performanceBonus = (performance * 100).round();

    final total = base + levelBonus + performanceBonus;
    final multiplier = _difficultyMultipliers[gameType] ?? 1.0;

    return _normalize((total * multiplier).round());
  }

  /// Genel skor hesaplama metodu
  /// Doğruluk ve hıza göre skor hesaplar
  static double calculateScore({
    bool? isCorrect,
    int? timeSpent,
    int? maxTime,
    double? baseScore,
    int? level,
    double? timeBonus,
  }) {
    if (isCorrect != null && isCorrect == false) return 0;
    
    // Temel puan
    double points = baseScore ?? 100.0;
    
    // Seviye bonusu
    if (level != null) {
      points += level * 10;
    }
    
    // Zaman bonusu
    if (timeBonus != null) {
      points += timeBonus;
    }
    
    // Hız bonusu: Hızlı cevaplarda daha fazla puan
    if (timeSpent != null && maxTime != null) {
      final timeRatio = 1 - (timeSpent / maxTime).clamp(0.0, 1.0);
      final speedBonus = timeRatio * 50;
      points += speedBonus;
    }
    
    return points;
  }

  /// Final skor hesaplama metodu
  /// Toplam skor, doğruluk oranı ve hıza göre final skoru hesaplar
  static double calculateFinalScore({
    int? correctAnswers,
    int? totalQuestions,
    double? score,
    int? totalScore,
    int? averageTime,
    int? timeTaken,
    int? maxTime,
  }) {
    double finalScore = score ?? totalScore?.toDouble() ?? 0.0;
    
    // Doğruluk oranı bonusu
    if (correctAnswers != null && totalQuestions != null && totalQuestions > 0) {
      final accuracyRatio = correctAnswers / totalQuestions;
      final accuracyBonus = accuracyRatio * 200;
      finalScore += accuracyBonus;
    }
    
    // Zaman bonusu (eğer varsa)
    if (averageTime != null && averageTime < 15) {
      finalScore += (15 - averageTime) * 10.0;
    }
    
    // Süre bonusu (hızlı bitirme)
    if (timeTaken != null && maxTime != null && timeTaken < maxTime) {
      final timeBonus = ((maxTime - timeTaken) / maxTime) * 100;
      finalScore += timeBonus;
    }
    
    return finalScore;
  }

  /// Skoru 0-1000 aralığına normalize et
  static int _normalize(int score) {
    return score.clamp(0, 1000);
  }

  /// Skor seviyesini al (Bronze, Silver, Gold, Diamond)
  static ScoreRank getScoreRank(int score) {
    if (score >= 800) return ScoreRank.diamond;
    if (score >= 600) return ScoreRank.gold;
    if (score >= 400) return ScoreRank.silver;
    return ScoreRank.bronze;
  }

  /// Skor rengini al
  static String getScoreColor(int score) {
    final rank = getScoreRank(score);
    switch (rank) {
      case ScoreRank.diamond:
        return '#00F5FF'; // Cyan
      case ScoreRank.gold:
        return '#FFD700'; // Gold
      case ScoreRank.silver:
        return '#C0C0C0'; // Silver
      case ScoreRank.bronze:
        return '#CD7F32'; // Bronze
    }
  }
}

enum ScoreRank {
  bronze,
  silver,
  gold,
  diamond,
}
