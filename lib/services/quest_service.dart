import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quest_model.dart';
import '../models/user_progress_model.dart';
import 'user_progress_service.dart';

/// Görev servisi.
///
/// Katalog Supabase'den (quests) okunuyor, kullanıcının durumu
/// user_quests'te tutuluyor. Otomatik görevlerin ilerlemesi mevcut
/// ilerleme verisinden hesaplanıyor — ayrı bir sayaç tutmuyoruz ki
/// veri iki yerde tutulup birbirinden ayrışmasın.
class QuestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Tüm aktif görevleri, kullanıcının durumu ile birlikte getirir.
  ///
  /// [progress] uygulamanın elindeki güncel ilerleme; ders/XP/seri
  /// hedefleri buradan hesaplanıyor.
  Future<List<QuestState>> getQuests(UserProgress? progress) async {
    final userId = _supabase.auth.currentUser?.id;

    List<Quest> catalog;
    try {
      final data = await _supabase
          .from('quests')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);
      catalog = (data as List).map((m) => Quest.fromMap(m)).toList();
    } catch (e) {
      debugPrint('❌ Görev kataloğu okunamadı: $e');
      return [];
    }

    if (userId == null) {
      return catalog
          .map((q) => QuestState(
                quest: q,
                progress: 0,
                completed: false,
                rewarded: false,
                locked: q.unlockAfter != null,
              ))
          .toList();
    }

    // Kayıtlı durumlar
    final Map<String, Map<String, dynamic>> saved = {};
    try {
      final rows = await _supabase
          .from('user_quests')
          .select('quest_id, progress, completed, rewarded, note')
          .eq('user_id', userId);
      for (final r in (rows as List)) {
        saved[r['quest_id'] as String] = Map<String, dynamic>.from(r);
      }
    } catch (e) {
      debugPrint('❌ Görev ilerlemesi okunamadı: $e');
    }

    final videoCount = await _completedVideoCount(userId);
    final equippedCount = await _equippedItemCount(userId);

    // Önce tamamlanma durumunu hesapla, sonra kilitleri çöz.
    final Map<String, QuestState> byslug = {};
    for (final q in catalog) {
      final row = saved[q.id];
      final manualDone = row?['completed'] == true;

      final autoProgress = _autoProgress(
        q,
        progress: progress,
        videoCount: videoCount,
        equippedCount: equippedCount,
      );

      final completed = q.isManual
          ? manualDone
          : (q.targetCount != null && autoProgress >= q.targetCount!);

      byslug[q.slug] = QuestState(
        quest: q,
        progress: q.isManual ? (completed ? 1 : 0) : autoProgress,
        completed: completed,
        rewarded: row?['rewarded'] == true,
        locked: false,
        note: row?['note'] as String?,
      );
    }

    // Kilit: ön koşul görev tamamlanmadıysa kilitli.
    //
    // NOT: Zaten tamamlanmış bir görev asla kilitli gösterilmez. Otomatik
    // görevler (karakter kuşanma, XP gibi) ön koşuldan bağımsız olarak
    // kendiliğinden tamamlanabiliyor; bunlara kilit çizmek "hem yapılmış
    // hem kilitli" gibi tuhaf bir kart üretiyordu.
    return catalog.map((q) {
      final state = byslug[q.slug]!;
      final prereq = q.unlockAfter;
      final locked = !state.completed &&
          prereq != null &&
          !(byslug[prereq]?.completed ?? false);
      return QuestState(
        quest: state.quest,
        progress: state.progress,
        completed: state.completed,
        rewarded: state.rewarded,
        locked: locked,
        note: state.note,
      );
    }).toList();
  }

  int _autoProgress(
    Quest q, {
    required UserProgress? progress,
    required int videoCount,
    required int equippedCount,
  }) {
    switch (q.kind) {
      case QuestKind.lesson:
        return progress?.completedLessonIds.length ?? 0;
      case QuestKind.xp:
        return progress?.totalXP ?? 0;
      case QuestKind.streak:
        return progress?.streakDays ?? 0;
      case QuestKind.quiz:
        return progress?.totalQuizzesCompleted ?? 0;
      case QuestKind.video:
        return videoCount;
      case QuestKind.character:
        return equippedCount;
      case QuestKind.manual:
        return 0;
    }
  }

  Future<int> _completedVideoCount(String userId) async {
    try {
      final rows = await _supabase
          .from('user_video_progress')
          .select('episode_id')
          .eq('user_id', userId)
          .eq('completed', true);
      return (rows as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// Karakterine bir eşya kuşandı mı? (karakterin kendisi sayılmıyor)
  Future<int> _equippedItemCount(String userId) async {
    try {
      final rows = await _supabase
          .from('user_inventory')
          .select('equipped, store_items(category)')
          .eq('user_id', userId)
          .eq('equipped', true);
      return (rows as List)
          .where((r) => (r['store_items']?['category']) != 'character')
          .length;
    } catch (_) {
      return 0;
    }
  }

  /// Manuel görevi tamamlandı olarak işaretler ve notu kaydeder.
  Future<bool> completeManual(Quest quest, String note) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      await _supabase.from('user_quests').upsert({
        'user_id': userId,
        'quest_id': quest.id,
        'progress': 1,
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
        'note': note.trim().isEmpty ? null : note.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,quest_id');
      return true;
    } catch (e) {
      debugPrint('❌ Görev kaydedilemedi: $e');
      return false;
    }
  }

  /// Tamamlanmış ama ödülü alınmamış görevin ödülünü verir.
  ///
  /// Ödül tek sefer verilir: `rewarded` bayrağı veritabanında tutuluyor,
  /// böylece uygulama yeniden açılınca ödül tekrarlanmıyor.
  Future<bool> claimReward(Quest quest) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final existing = await _supabase
          .from('user_quests')
          .select('rewarded')
          .eq('user_id', userId)
          .eq('quest_id', quest.id)
          .maybeSingle();

      if (existing != null && existing['rewarded'] == true) return false;

      await _supabase.from('user_quests').upsert({
        'user_id': userId,
        'quest_id': quest.id,
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
        'rewarded': true,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,quest_id');

      final progressService = UserProgressService();
      if (quest.xpReward > 0) {
        await progressService.addXP(userId, quest.xpReward, source: 'quest');
      }
      if (quest.jetonReward > 0) {
        await progressService.addJeton(userId, quest.jetonReward, source: 'quest');
      }
      return true;
    } catch (e) {
      debugPrint('❌ Görev ödülü verilemedi: $e');
      return false;
    }
  }
}
