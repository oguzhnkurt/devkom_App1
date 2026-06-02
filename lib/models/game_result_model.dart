/// Oyun/Quiz Sonuç Modeli
class GameResult {
  final String id;
  final String playerId; // Firebase rules'da playerId kullanılıyor
  final String gameName;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final double successRate; // Yüzde olarak başarı oranı
  final DateTime playedAt;

  GameResult({
    required this.id,
    required this.playerId,
    required this.gameName,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    required this.successRate,
    required this.playedAt,
  });

  // Başarı yüzdesini hesapla
  static double calculateSuccessRate(int correct, int total) {
    if (total == 0) return 0;
    return (correct / total) * 100;
  }

  // // REMOVED: Firebase-specific method
  // // factory GameResult.fromFirestore(DocumentSnapshot doc) { ... }

  // // REMOVED: Firebase-specific method
  // // Map<String, dynamic> toFirestore() { ... }

  // JSON'dan dönüştür (local cache için)
  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      id: json['id'] ?? '',
      playerId: json['playerId'] ?? '',
      gameName: json['gameName'] ?? '',
      correctAnswers: json['correctAnswers'] ?? 0,
      wrongAnswers: json['wrongAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      successRate: (json['successRate'] ?? 0).toDouble(),
      playedAt: DateTime.parse(json['playedAt']),
    );
  }

  // JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'gameName': gameName,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'totalQuestions': totalQuestions,
      'successRate': successRate,
      'playedAt': playedAt.toIso8601String(),
    };
  }
}

/// Oyun bazında istatistikler
class GameStatistics {
  final String gameName;
  final int totalPlays;
  final int totalCorrect;
  final int totalWrong;
  final int totalQuestions;
  final double averageSuccessRate;

  GameStatistics({
    required this.gameName,
    required this.totalPlays,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalQuestions,
    required this.averageSuccessRate,
  });

  // Oyun sonuçlarından istatistik hesapla
  factory GameStatistics.fromResults(String gameName, List<GameResult> results) {
    final totalPlays = results.length;
    final totalCorrect = results.fold<int>(0, (sum, r) => sum + r.correctAnswers);
    final totalWrong = results.fold<int>(0, (sum, r) => sum + r.wrongAnswers);
    final totalQuestions = results.fold<int>(0, (sum, r) => sum + r.totalQuestions);
    final averageSuccessRate = results.isEmpty
        ? 0.0
        : results.fold<double>(0, (sum, r) => sum + r.successRate) / totalPlays;

    return GameStatistics(
      gameName: gameName,
      totalPlays: totalPlays,
      totalCorrect: totalCorrect,
      totalWrong: totalWrong,
      totalQuestions: totalQuestions,
      averageSuccessRate: averageSuccessRate,
    );
  }
}

/// Genel istatistikler
class OverallStatistics {
  final int totalGamesPlayed;
  final int totalCorrect;
  final int totalWrong;
  final int totalQuestions;
  final double overallSuccessRate;

  OverallStatistics({
    required this.totalGamesPlayed,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalQuestions,
    required this.overallSuccessRate,
  });

  // Tüm sonuçlardan genel istatistik hesapla
  factory OverallStatistics.fromResults(List<GameResult> results) {
    final totalGamesPlayed = results.length;
    final totalCorrect = results.fold<int>(0, (sum, r) => sum + r.correctAnswers);
    final totalWrong = results.fold<int>(0, (sum, r) => sum + r.wrongAnswers);
    final totalQuestions = results.fold<int>(0, (sum, r) => sum + r.totalQuestions);
    final overallSuccessRate = totalQuestions == 0
        ? 0.0
        : (totalCorrect / totalQuestions) * 100;

    return OverallStatistics(
      totalGamesPlayed: totalGamesPlayed,
      totalCorrect: totalCorrect,
      totalWrong: totalWrong,
      totalQuestions: totalQuestions,
      overallSuccessRate: overallSuccessRate,
    );
  }
}
