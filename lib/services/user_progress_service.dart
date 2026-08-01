import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_progress_model.dart';

/// Kullanıcı İlerleme Servisi
/// XP, Seviye, Streak ve Günlük Hedefler yönetimi
class UserProgressService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _progressTable = 'user_progress';

  UserProgress? _currentProgress;
  bool _isLoading = false;

  UserProgress? get currentProgress => _currentProgress;
  bool get isLoading => _isLoading;

  /// Kullanıcının ilerlemesini yükle
  Future<UserProgress?> loadUserProgress(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from(_progressTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        _currentProgress = UserProgress.fromSupabase(response);

        // Günlük hedefleri sıfırla gerekirse
        if (_currentProgress!.shouldResetDailyGoals) {
          await _resetDailyGoals(userId);
        }

        // Streak kontrolü
        await _checkAndUpdateStreak(userId);
      } else {
        // Yeni kullanıcı - ilerleme oluştur
        _currentProgress = await createInitialProgress(userId);
      }

      _isLoading = false;
      notifyListeners();
      return _currentProgress;
    } catch (e) {
      debugPrint('Error loading user progress: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Yeni kullanıcı için başlangıç ilerlemesi oluştur
  Future<UserProgress> createInitialProgress(String userId) async {
    try {
      final now = DateTime.now();
      final progress = UserProgress(
        userId: userId,
        totalXP: 0,
        level: 1,
        streakDays: 0,
        lastActiveDate: now,
        dailyLessonsCompleted: 0,
        dailyGamesPlayed: 0,
        dailyQuizzesCompleted: 0,
        lastGoalResetDate: now,
        completedLessonIds: [],
        earnedBadgeIds: [],
        createdAt: now,
        updatedAt: now,
      );

      await _supabase.from(_progressTable).insert({
        ...progress.toSupabaseMap(),
        'created_at': now.toIso8601String(),
      });

      _currentProgress = progress;
      notifyListeners();
      return progress;
    } catch (e) {
      debugPrint('Error creating initial progress: $e');
      // Return empty progress if insert fails (might already exist)
      return UserProgress.empty(userId);
    }
  }

  /// XP ekle ve seviye kontrolü yap
  Future<void> addXP(String userId, int xp, {String? source}) async {
    try {
      if (_currentProgress == null) {
        await loadUserProgress(userId);
      }

      final newTotalXP = (_currentProgress?.totalXP ?? 0) + xp;
      final newLevel = UserProgress.calculateLevel(newTotalXP);
      final oldLevel = _currentProgress?.level ?? 1;

      await _supabase.from(_progressTable).update({
        'total_xp': newTotalXP,
        'level': newLevel,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      _currentProgress = _currentProgress?.copyWith(
        totalXP: newTotalXP,
        level: newLevel,
      );

      // Seviye atladıysa rozet kontrolü yap
      if (newLevel > oldLevel) {
        await _checkMilestoneBadges(userId, newTotalXP);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding XP: $e');
    }
  }

  /// Jeton ekle (Market'te harcanabilir para birimi). XP'nin aksine bu
  /// bakiye satın alma ile azalabilir; azaltma işlemi StoreService
  /// üzerinden purchase_store_item RPC'si ile atomik yapılır.
  Future<void> addJeton(String userId, int amount, {String? source}) async {
    if (amount <= 0) return;
    try {
      if (_currentProgress == null) {
        await loadUserProgress(userId);
      }

      final newBalance = (_currentProgress?.jetonBalance ?? 0) + amount;

      await _supabase.from(_progressTable).update({
        'jeton_balance': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      _currentProgress = _currentProgress?.copyWith(jetonBalance: newBalance);
      notifyListeners();
      debugPrint('🪙 Jeton eklendi: +$amount (${source ?? 'bilinmiyor'}) -> $newBalance');
    } catch (e) {
      debugPrint('Error adding jeton: $e');
    }
  }

  /// Ders tamamlandığında
  Future<void> onLessonCompleted(String userId, String lessonId, int xpReward) async {
    try {
      // XP ekle
      await addXP(userId, xpReward, source: 'lesson');
      // Jeton ödülü (Market'te harcanabilir)
      await addJeton(userId, 8, source: 'lesson');

      // Günlük hedef güncelle
      final newCount = (_currentProgress?.dailyLessonsCompleted ?? 0) + 1;

      // Tamamlanan dersler listesine ekle
      final completedLessons = List<String>.from(_currentProgress?.completedLessonIds ?? []);
      if (!completedLessons.contains(lessonId)) {
        completedLessons.add(lessonId);
      }

      await _supabase.from(_progressTable).update({
        'daily_lessons_completed': newCount,
        'completed_lesson_ids': completedLessons,
        'last_active_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      _currentProgress = _currentProgress?.copyWith(
        dailyLessonsCompleted: newCount,
        completedLessonIds: completedLessons,
        lastActiveDate: DateTime.now(),
      );

      // İlk ders rozeti kontrolü
      if (completedLessons.length == 1) {
        await _awardBadge(userId, 'first_step');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error on lesson completed: $e');
    }
  }

  /// Oyun oynandığında
  Future<void> onGamePlayed(String userId, int score, int xpReward) async {
    try {
      // XP ekle
      await addXP(userId, xpReward, source: 'game');
      // Jeton ödülü: skorla orantılı, en az 5
      final jeton = (score / 20).round().clamp(5, 60);
      await addJeton(userId, jeton, source: 'game');

      // Günlük hedef güncelle
      final newCount = (_currentProgress?.dailyGamesPlayed ?? 0) + 1;

      await _supabase.from(_progressTable).update({
        'daily_games_played': newCount,
        'last_active_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      _currentProgress = _currentProgress?.copyWith(
        dailyGamesPlayed: newCount,
        lastActiveDate: DateTime.now(),
      );

      // 10 oyun rozeti kontrolü
      if (newCount >= 10) {
        await _awardBadge(userId, 'gamer');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error on game played: $e');
    }
  }

  /// Quiz tamamlandığında
  Future<void> onQuizCompleted(String userId, int correctAnswers, int xpReward) async {
    try {
      // XP ekle
      await addXP(userId, xpReward, source: 'quiz');
      // Jeton ödülü: doğru cevap başına 3 jeton
      await addJeton(userId, correctAnswers * 3, source: 'quiz');

      // Günlük hedef güncelle
      final newCount = (_currentProgress?.dailyQuizzesCompleted ?? 0) + 1;

      await _supabase.from(_progressTable).update({
        'daily_quizzes_completed': newCount,
        'last_active_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      _currentProgress = _currentProgress?.copyWith(
        dailyQuizzesCompleted: newCount,
        lastActiveDate: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error on quiz completed: $e');
    }
  }

  /// Günlük hedefleri sıfırla
  Future<void> _resetDailyGoals(String userId) async {
    try {
      final now = DateTime.now();
      await _supabase.from(_progressTable).update({
        'daily_lessons_completed': 0,
        'daily_games_played': 0,
        'daily_quizzes_completed': 0,
        'last_goal_reset_date': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      }).eq('user_id', userId);

      _currentProgress = _currentProgress?.copyWith(
        dailyLessonsCompleted: 0,
        dailyGamesPlayed: 0,
        dailyQuizzesCompleted: 0,
        lastGoalResetDate: now,
      );
    } catch (e) {
      debugPrint('Error resetting daily goals: $e');
    }
  }

  /// Streak kontrolü ve güncelleme
  Future<void> _checkAndUpdateStreak(String userId) async {
    try {
      if (_currentProgress == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastActive = _currentProgress!.lastActiveDate;

      if (lastActive == null) {
        // İlk giriş - streak 1'den başla
        await _updateStreak(userId, 1);
        return;
      }

      final lastActiveDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
      final daysDifference = today.difference(lastActiveDay).inDays;

      if (daysDifference == 0) {
        // Bugün zaten aktif - streak değişmez
        return;
      } else if (daysDifference == 1) {
        // Dün aktifti - streak artır
        final newStreak = (_currentProgress!.streakDays) + 1;
        await _updateStreak(userId, newStreak);

        // Streak rozetleri kontrolü
        if (newStreak >= 3) await _awardBadge(userId, 'streak_3');
        if (newStreak >= 7) await _awardBadge(userId, 'streak_7');
      } else {
        // Ara verildi - streak sıfırla
        await _updateStreak(userId, 1);
      }
    } catch (e) {
      debugPrint('Error checking streak: $e');
    }
  }

  /// Streak güncelle
  Future<void> _updateStreak(String userId, int newStreak) async {
    try {
      await _supabase.from(_progressTable).update({
        'streak_days': newStreak,
        'last_active_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      _currentProgress = _currentProgress?.copyWith(
        streakDays: newStreak,
        lastActiveDate: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating streak: $e');
    }
  }

  /// Rozet ver
  Future<void> _awardBadge(String userId, String badgeId) async {
    try {
      final earnedBadges = List<String>.from(_currentProgress?.earnedBadgeIds ?? []);

      // Zaten kazanılmışsa atla
      if (earnedBadges.contains(badgeId)) return;

      earnedBadges.add(badgeId);

      await _supabase.from(_progressTable).update({
        'earned_badge_ids': earnedBadges,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      _currentProgress = _currentProgress?.copyWith(
        earnedBadgeIds: earnedBadges,
      );

      notifyListeners();
      debugPrint('Badge awarded: $badgeId');
    } catch (e) {
      debugPrint('Error awarding badge: $e');
    }
  }

  /// XP milestone rozetleri kontrolü
  Future<void> _checkMilestoneBadges(String userId, int totalXP) async {
    if (totalXP >= 100) await _awardBadge(userId, 'xp_100');
    if (totalXP >= 500) await _awardBadge(userId, 'xp_500');
    if (totalXP >= 1000) await _awardBadge(userId, 'xp_1000');
  }

  /// Günlük hedefleri getir
  List<DailyGoal> getDailyGoals() {
    return [
      DailyGoal(
        id: 'lesson',
        type: DailyGoalType.lesson,
        title: '1 Ders Tamamla',
        description: 'Bugün bir ders izle veya oku',
        targetValue: 1,
        currentProgress: _currentProgress?.dailyLessonsCompleted ?? 0,
        rewardXP: 25,
        isCompleted: (_currentProgress?.dailyLessonsCompleted ?? 0) >= 1,
      ),
      DailyGoal(
        id: 'game',
        type: DailyGoalType.game,
        title: '1 Oyun Oyna',
        description: 'Eğlenceli bir oyun oyna',
        targetValue: 1,
        currentProgress: _currentProgress?.dailyGamesPlayed ?? 0,
        rewardXP: 20,
        isCompleted: (_currentProgress?.dailyGamesPlayed ?? 0) >= 1,
      ),
      DailyGoal(
        id: 'quiz',
        type: DailyGoalType.quiz,
        title: '1 Quiz Çöz',
        description: 'Bilgini test et',
        targetValue: 1,
        currentProgress: _currentProgress?.dailyQuizzesCompleted ?? 0,
        rewardXP: 30,
        isCompleted: (_currentProgress?.dailyQuizzesCompleted ?? 0) >= 1,
      ),
    ];
  }

  /// Kullanıcının rozetlerini getir
  List<Badge> getUserBadges() {
    final earnedIds = _currentProgress?.earnedBadgeIds ?? [];
    return DefaultBadges.all.map((badge) {
      if (earnedIds.contains(badge.id)) {
        return Badge(
          id: badge.id,
          name: badge.name,
          description: badge.description,
          emoji: badge.emoji,
          category: badge.category,
          requiredXP: badge.requiredXP,
          earnedAt: DateTime.now(), // Gerçek tarih Supabase'den gelebilir
        );
      }
      return badge;
    }).toList();
  }

  /// Visitor için demo ilerleme (kayıt olmadan)
  UserProgress getVisitorProgress() {
    return UserProgress(
      userId: 'visitor',
      totalXP: 0,
      level: 1,
      streakDays: 0,
      dailyLessonsCompleted: 0,
      dailyGamesPlayed: 0,
      dailyQuizzesCompleted: 0,
      completedLessonIds: [],
      earnedBadgeIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
