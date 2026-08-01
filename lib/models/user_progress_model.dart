/// Kullanıcı İlerleme Modeli
/// XP, Seviye, Streak ve Günlük Hedefler
class UserProgress {
  final String userId;
  final int totalXP;
  final int level;
  final int streakDays;
  final DateTime? lastActiveDate;
  final int dailyLessonsCompleted;
  final int dailyGamesPlayed;
  final int dailyQuizzesCompleted;
  final DateTime? lastGoalResetDate;
  final List<String> completedLessonIds;
  final List<String> earnedBadgeIds;
  /// Harcanabilir mağaza para birimi (jeton). XP'den ayrı: XP seviyeyi
  /// belirler ve asla azalmaz, jeton ise Market'te harcanabilir.
  /// Bkz. supabase/migrations/23_store_and_jeton_economy.sql
  final int jetonBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProgress({
    required this.userId,
    this.totalXP = 0,
    this.level = 1,
    this.streakDays = 0,
    this.lastActiveDate,
    this.dailyLessonsCompleted = 0,
    this.dailyGamesPlayed = 0,
    this.dailyQuizzesCompleted = 0,
    this.lastGoalResetDate,
    this.completedLessonIds = const [],
    this.earnedBadgeIds = const [],
    this.jetonBalance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // XP to Level calculation
  static int calculateLevel(int xp) {
    // Level 1: 0-99 XP
    // Level 2: 100-249 XP
    // Level 3: 250-449 XP
    // Level N: increasing requirements
    if (xp < 100) return 1;
    if (xp < 250) return 2;
    if (xp < 450) return 3;
    if (xp < 700) return 4;
    if (xp < 1000) return 5;
    if (xp < 1400) return 6;
    if (xp < 1900) return 7;
    if (xp < 2500) return 8;
    if (xp < 3200) return 9;
    if (xp < 4000) return 10;
    // After level 10, every 1000 XP is a new level
    return 10 + ((xp - 4000) ~/ 1000);
  }

  // XP needed for next level
  static int xpForLevel(int level) {
    switch (level) {
      case 1: return 100;
      case 2: return 250;
      case 3: return 450;
      case 4: return 700;
      case 5: return 1000;
      case 6: return 1400;
      case 7: return 1900;
      case 8: return 2500;
      case 9: return 3200;
      case 10: return 4000;
      default: return 4000 + ((level - 10) * 1000);
    }
  }

  // XP for previous level (base)
  static int xpForPreviousLevel(int level) {
    if (level <= 1) return 0;
    return xpForLevel(level - 1);
  }

  // Progress to next level (0.0 - 1.0)
  double get progressToNextLevel {
    final currentLevelXP = xpForPreviousLevel(level);
    final nextLevelXP = xpForLevel(level);
    final xpInCurrentLevel = totalXP - currentLevelXP;
    final xpNeededForLevel = nextLevelXP - currentLevelXP;
    return (xpInCurrentLevel / xpNeededForLevel).clamp(0.0, 1.0);
  }

  // XP remaining for next level
  int get xpToNextLevel {
    return xpForLevel(level) - totalXP;
  }

  // Daily goals completed count
  int get dailyGoalsCompleted {
    int count = 0;
    if (dailyLessonsCompleted >= 1) count++;
    if (dailyGamesPlayed >= 1) count++;
    if (dailyQuizzesCompleted >= 1) count++;
    return count;
  }

  // Total daily goals
  int get totalDailyGoals => 3;

  // Daily goals progress (0.0 - 1.0)
  double get dailyGoalsProgress => dailyGoalsCompleted / totalDailyGoals;

  // Check if streak is active today
  bool get isStreakActive {
    if (lastActiveDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = DateTime(
      lastActiveDate!.year,
      lastActiveDate!.month,
      lastActiveDate!.day,
    );
    return today.difference(lastActive).inDays <= 1;
  }

  // Should reset daily goals?
  bool get shouldResetDailyGoals {
    if (lastGoalResetDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastReset = DateTime(
      lastGoalResetDate!.year,
      lastGoalResetDate!.month,
      lastGoalResetDate!.day,
    );
    return today.isAfter(lastReset);
  }

  // Supabase serialization
  factory UserProgress.fromSupabase(Map<String, dynamic> data) {
    return UserProgress(
      userId: data['user_id'] ?? '',
      totalXP: data['total_xp'] ?? 0,
      level: data['level'] ?? 1,
      streakDays: data['streak_days'] ?? 0,
      lastActiveDate: data['last_active_date'] != null
          ? DateTime.parse(data['last_active_date'])
          : null,
      dailyLessonsCompleted: data['daily_lessons_completed'] ?? 0,
      dailyGamesPlayed: data['daily_games_played'] ?? 0,
      dailyQuizzesCompleted: data['daily_quizzes_completed'] ?? 0,
      lastGoalResetDate: data['last_goal_reset_date'] != null
          ? DateTime.parse(data['last_goal_reset_date'])
          : null,
      completedLessonIds: data['completed_lesson_ids'] != null
          ? List<String>.from(data['completed_lesson_ids'])
          : [],
      earnedBadgeIds: data['earned_badge_ids'] != null
          ? List<String>.from(data['earned_badge_ids'])
          : [],
      jetonBalance: data['jeton_balance'] ?? 0,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'user_id': userId,
      'total_xp': totalXP,
      'level': level,
      'streak_days': streakDays,
      'last_active_date': lastActiveDate?.toIso8601String(),
      'daily_lessons_completed': dailyLessonsCompleted,
      'daily_games_played': dailyGamesPlayed,
      'daily_quizzes_completed': dailyQuizzesCompleted,
      'last_goal_reset_date': lastGoalResetDate?.toIso8601String(),
      'completed_lesson_ids': completedLessonIds,
      'earned_badge_ids': earnedBadgeIds,
      'jeton_balance': jetonBalance,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Empty/default progress for new users
  factory UserProgress.empty(String userId) {
    final now = DateTime.now();
    return UserProgress(
      userId: userId,
      totalXP: 0,
      level: 1,
      streakDays: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  // CopyWith
  UserProgress copyWith({
    String? userId,
    int? totalXP,
    int? level,
    int? streakDays,
    DateTime? lastActiveDate,
    int? dailyLessonsCompleted,
    int? dailyGamesPlayed,
    int? dailyQuizzesCompleted,
    DateTime? lastGoalResetDate,
    List<String>? completedLessonIds,
    List<String>? earnedBadgeIds,
    int? jetonBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      dailyLessonsCompleted: dailyLessonsCompleted ?? this.dailyLessonsCompleted,
      dailyGamesPlayed: dailyGamesPlayed ?? this.dailyGamesPlayed,
      dailyQuizzesCompleted: dailyQuizzesCompleted ?? this.dailyQuizzesCompleted,
      lastGoalResetDate: lastGoalResetDate ?? this.lastGoalResetDate,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      jetonBalance: jetonBalance ?? this.jetonBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Günlük Hedef Modeli
class DailyGoal {
  final String id;
  final DailyGoalType type;
  final String title;
  final String description;
  final int targetValue;
  final int currentProgress;
  final int rewardXP;
  final bool isCompleted;

  DailyGoal({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentProgress = 0,
    required this.rewardXP,
    this.isCompleted = false,
  });

  double get progressPercentage => (currentProgress / targetValue).clamp(0.0, 1.0);
}

enum DailyGoalType {
  lesson,   // 1 ders tamamla
  game,     // 1 oyun oyna
  quiz,     // 1 quiz tamamla
}

/// Rozet Modeli
class Badge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final BadgeCategory category;
  final int requiredXP;
  final DateTime? earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    this.requiredXP = 0,
    this.earnedAt,
  });

  bool get isEarned => earnedAt != null;
}

enum BadgeCategory {
  milestone,    // XP milestones
  streak,       // Streak achievements
  lesson,       // Lesson completions
  game,         // Game achievements
  special,      // Special events
}

/// Varsayılan Rozetler
class DefaultBadges {
  static List<Badge> get all => [
    Badge(
      id: 'first_step',
      name: 'İlk Adım',
      description: 'İlk dersini tamamla',
      emoji: '🎯',
      category: BadgeCategory.lesson,
    ),
    Badge(
      id: 'streak_3',
      name: '3 Günlük Seri',
      description: '3 gün üst üste uygulama kullan',
      emoji: '🔥',
      category: BadgeCategory.streak,
    ),
    Badge(
      id: 'streak_7',
      name: 'Haftalık Seri',
      description: '7 gün üst üste uygulama kullan',
      emoji: '⚡',
      category: BadgeCategory.streak,
    ),
    Badge(
      id: 'coder',
      name: 'Kodlamacı',
      description: 'İlk kodlama dersini tamamla',
      emoji: '💻',
      category: BadgeCategory.lesson,
    ),
    Badge(
      id: 'gamer',
      name: 'Oyuncu',
      description: '10 oyun oyna',
      emoji: '🎮',
      category: BadgeCategory.game,
    ),
    Badge(
      id: 'xp_100',
      name: 'Yüzlük',
      description: '100 XP kazan',
      emoji: '💯',
      category: BadgeCategory.milestone,
      requiredXP: 100,
    ),
    Badge(
      id: 'xp_500',
      name: 'Beş Yüzlük',
      description: '500 XP kazan',
      emoji: '🏆',
      category: BadgeCategory.milestone,
      requiredXP: 500,
    ),
    Badge(
      id: 'xp_1000',
      name: 'Binlik',
      description: '1000 XP kazan',
      emoji: '👑',
      category: BadgeCategory.milestone,
      requiredXP: 1000,
    ),
  ];
}
