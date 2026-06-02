/// Günlük Görev Tipi
enum QuestType {
  playGames,       // X oyun oyna
  earnScore,       // X puan kazan
  completeLevel,   // X seviye tamamla
  perfectScore,    // Bir oyunda 900+ puan al
  playStreak,      // Arka arkaya X gün oyna
  tryAllGames,     // Farklı oyunlar oyna
}

/// Günlük Görev Modeli
class DailyQuest {
  final String id;
  final QuestType type;
  final String title;
  final String description;
  final int targetValue;
  final int currentProgress;
  final int rewardXP;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isCompleted;

  DailyQuest({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentProgress = 0,
    required this.rewardXP,
    required this.createdAt,
    required this.expiresAt,
    this.isCompleted = false,
  });

  // Progress yüzdesi
  double get progressPercentage {
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  // Tamamlanma durumu
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  // // REMOVED: Firebase-specific method
  // // factory DailyQuest.fromFirestore(DocumentSnapshot doc) { ... }

  // // REMOVED: Firebase-specific method
  // // Map<String, dynamic> toFirestore() { ... }

  // Supabase methods
  factory DailyQuest.fromSupabase(Map<String, dynamic> data) {
    return DailyQuest(
      id: data['id']?.toString() ?? '',
      type: QuestType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => QuestType.playGames,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      targetValue: data['target_value'] ?? 0,
      currentProgress: data['current_progress'] ?? 0,
      rewardXP: data['reward_xp'] ?? 0,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      expiresAt: data['expires_at'] != null
          ? DateTime.parse(data['expires_at'])
          : DateTime.now(),
      isCompleted: data['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'target_value': targetValue,
      'current_progress': currentProgress,
      'reward_xp': rewardXP,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  // Copy with
  DailyQuest copyWith({
    String? id,
    QuestType? type,
    String? title,
    String? description,
    int? targetValue,
    int? currentProgress,
    int? rewardXP,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isCompleted,
  }) {
    return DailyQuest(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardXP: rewardXP ?? this.rewardXP,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Günlük görev fabrikası - Rastgele görev oluşturur
class DailyQuestFactory {
  static List<DailyQuest> generateDailyQuests(String userId) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final quests = [
      // 3 günlük görev oluştur
      _createQuest(
        type: QuestType.playGames,
        title: '3 Farklı Oyun Oyna',
        description: 'Bugün 3 farklı oyun oynayarak yeteneklerini geliştir',
        targetValue: 3,
        rewardXP: 50,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      _createQuest(
        type: QuestType.earnScore,
        title: '500 Puan Kazan',
        description: 'Oyunlarda toplamda 500 puan kazanarak günü tamamla',
        targetValue: 500,
        rewardXP: 75,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      _createQuest(
        type: QuestType.completeLevel,
        title: '5 Seviye Tamamla',
        description: 'Herhangi bir oyunda 5 seviye başarıyla tamamla',
        targetValue: 5,
        rewardXP: 100,
        createdAt: now,
        expiresAt: tomorrow,
      ),
    ];

    return quests;
  }

  static DailyQuest _createQuest({
    required QuestType type,
    required String title,
    required String description,
    required int targetValue,
    required int rewardXP,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) {
    return DailyQuest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      description: description,
      targetValue: targetValue,
      rewardXP: rewardXP,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }
}
