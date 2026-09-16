/// Görev (quest) modelleri.
/// Tablolar: quests, user_quests (bkz. Supabase migration: quests_system)
library;

import 'package:flutter/material.dart';

/// Görevin zorluk kademesi. Görevler bu sırayla açılıyor.
enum QuestDifficulty { kolay, orta, zor, usta, efsane, pro }

/// Görevin nasıl tamamlandığı.
///
/// [manual] dışındakiler kullanıcının mevcut ilerlemesinden otomatik
/// hesaplanıyor; [manual] görevlerde çocuk kendisi "yaptım" diyor ve
/// kısa bir not bırakıyor.
enum QuestKind { lesson, video, quiz, xp, streak, character, manual }

QuestDifficulty parseQuestDifficulty(String? value) {
  switch (value) {
    case 'orta':
      return QuestDifficulty.orta;
    case 'zor':
      return QuestDifficulty.zor;
    case 'usta':
      return QuestDifficulty.usta;
    case 'efsane':
      return QuestDifficulty.efsane;
    case 'pro':
      return QuestDifficulty.pro;
    default:
      return QuestDifficulty.kolay;
  }
}

QuestKind parseQuestKind(String? value) {
  switch (value) {
    case 'video':
      return QuestKind.video;
    case 'quiz':
      return QuestKind.quiz;
    case 'xp':
      return QuestKind.xp;
    case 'streak':
      return QuestKind.streak;
    case 'character':
      return QuestKind.character;
    case 'manual':
      return QuestKind.manual;
    default:
      return QuestKind.lesson;
  }
}

String questDifficultyLabel(QuestDifficulty d) {
  switch (d) {
    case QuestDifficulty.kolay:
      return 'Kolay';
    case QuestDifficulty.orta:
      return 'Orta';
    case QuestDifficulty.zor:
      return 'Zor';
    case QuestDifficulty.usta:
      return 'Usta';
    case QuestDifficulty.efsane:
      return 'Efsane';
    case QuestDifficulty.pro:
      return 'Pro';
  }
}

String questDifficultyTagline(QuestDifficulty d) {
  switch (d) {
    case QuestDifficulty.kolay:
      return 'İlk adımlar — hepsi tek oturumda biter';
    case QuestDifficulty.orta:
      return 'Alışkanlık kuruyorsun';
    case QuestDifficulty.zor:
      return 'Artık kendin üretiyorsun';
    case QuestDifficulty.usta:
      return 'Öğrendiklerini birleştir';
    case QuestDifficulty.efsane:
      return 'Uzun soluklu — sabır ister';
    case QuestDifficulty.pro:
      return 'Pro üyelere özel, en büyük ödüller';
  }
}

Color questDifficultyColor(QuestDifficulty d) {
  switch (d) {
    case QuestDifficulty.kolay:
      return const Color(0xFF2E7D32);
    case QuestDifficulty.orta:
      return const Color(0xFF0277BD);
    case QuestDifficulty.zor:
      return const Color(0xFFEF6C00);
    case QuestDifficulty.usta:
      return const Color(0xFFC62828);
    case QuestDifficulty.efsane:
      return const Color(0xFF6A1B9A);
    case QuestDifficulty.pro:
      return const Color(0xFFC79100);
  }
}

class Quest {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String emoji;
  final QuestKind kind;
  final QuestDifficulty difficulty;

  /// Otomatik görevlerde hedef adet (3 ders, 100 XP gibi). Manuel'de null.
  final int? targetCount;
  final String? targetRef;
  final int xpReward;
  final int jetonReward;

  /// Bu görev açılmadan önce tamamlanması gereken görevin slug'ı.
  final String? unlockAfter;
  final int sortOrder;

  /// Pro üyeliğe özel görev. Pro olmayan kullanıcıda kilitli görünür.
  final bool requiresPro;

  const Quest({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.emoji,
    required this.kind,
    required this.difficulty,
    this.targetCount,
    this.targetRef,
    required this.xpReward,
    required this.jetonReward,
    this.unlockAfter,
    this.sortOrder = 0,
    this.requiresPro = false,
  });

  bool get isManual => kind == QuestKind.manual;

  factory Quest.fromMap(Map<String, dynamic> map) {
    return Quest(
      id: map['id'],
      slug: map['slug'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '🎯',
      kind: parseQuestKind(map['kind']),
      difficulty: parseQuestDifficulty(map['difficulty']),
      targetCount: map['target_count'],
      targetRef: map['target_ref'],
      xpReward: map['xp_reward'] ?? 10,
      jetonReward: map['jeton_reward'] ?? 5,
      unlockAfter: map['unlock_after'],
      sortOrder: map['sort_order'] ?? 0,
      requiresPro: map['requires_pro'] ?? false,
    );
  }
}

/// Bir görevin kullanıcıdaki durumu.
class QuestState {
  final Quest quest;
  final int progress;
  final bool completed;
  final bool rewarded;
  final String? note;

  /// Ön koşul görev tamamlanmadıysa görev kilitli görünür.
  final bool locked;

  const QuestState({
    required this.quest,
    required this.progress,
    required this.completed,
    required this.rewarded,
    required this.locked,
    this.note,
  });

  int get target => quest.targetCount ?? 1;

  double get ratio {
    if (completed) return 1.0;
    if (quest.isManual) return 0.0;
    if (target <= 0) return 0.0;
    return (progress / target).clamp(0.0, 1.0);
  }

  /// "2 / 3" biçiminde ilerleme etiketi; manuel görevlerde null.
  String? get progressLabel {
    if (quest.isManual) return null;
    return '${progress.clamp(0, target)} / $target';
  }
}
