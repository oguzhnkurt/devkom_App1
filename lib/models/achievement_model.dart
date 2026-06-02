import 'package:flutter/material.dart';

/// Rozet Kategorisi
enum AchievementCategory {
  games,        // Oyun başarıları
  score,        // Skor başarıları
  streak,       // Süreklilik başarıları
  mastery,      // Ustalık başarıları
  social,       // Sosyal başarılar
  special,      // Özel başarılar
}

/// Rozet Rariti (Nadirlik)
enum AchievementRarity {
  common,       // Yaygın (Gri)
  rare,         // Nadir (Mavi)
  epic,         // Destansı (Mor)
  legendary,    // Efsanevi (Turuncu)
}

/// Rozet (Achievement) Modeli
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final IconData icon;
  final int requiredValue;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.rarity,
    required this.icon,
    required this.requiredValue,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  // İlerleme yüzdesi
  double get progressPercentage {
    return (currentProgress / requiredValue).clamp(0.0, 1.0);
  }

  // Renk
  Color get color {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  // Nadirlik etiketi
  String get rarityLabel {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Yaygın';
      case AchievementRarity.rare:
        return 'Nadir';
      case AchievementRarity.epic:
        return 'Destansı';
      case AchievementRarity.legendary:
        return 'Efsanevi';
    }
  }

  // // REMOVED: Firebase-specific method
  // // factory Achievement.fromFirestore(DocumentSnapshot doc, Map<String, dynamic> templateData) { ... }

  // Icon string'den Icon'a çevir
  static IconData getIconFromString(String? iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'stars':
        return Icons.stars;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'psychology':
        return Icons.psychology;
      case 'speed':
        return Icons.speed;
      case 'military_tech':
        return Icons.military_tech;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'explore':
        return Icons.explore;
      case 'assignment_turned_in':
        return Icons.assignment_turned_in;
      case 'wb_sunny':
        return Icons.wb_sunny;
      default:
        return Icons.emoji_events;
    }
  }

  // // REMOVED: Firebase-specific method
  // // Map<String, dynamic> toFirestore() { ... }

  // Copy with
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementCategory? category,
    AchievementRarity? rarity,
    IconData? icon,
    int? requiredValue,
    int? xpReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      icon: icon ?? this.icon,
      requiredValue: requiredValue ?? this.requiredValue,
      xpReward: xpReward ?? this.xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }
}

/// Rozet Template'leri
class AchievementTemplates {
  static final List<Map<String, dynamic>> templates = [
    // Oyun Başarıları
    {
      'id': 'first_game',
      'title': 'İlk Adım',
      'description': 'İlk oyununu oyna',
      'category': 'games',
      'rarity': 'common',
      'icon': 'emoji_events',
      'requiredValue': 1,
      'xpReward': 10,
    },
    {
      'id': 'game_explorer',
      'title': 'Oyun Kaşifi',
      'description': '5 farklı oyun oyna',
      'category': 'games',
      'rarity': 'rare',
      'icon': 'explore',
      'requiredValue': 5,
      'xpReward': 50,
    },
    {
      'id': 'game_master',
      'title': 'Oyun Ustası',
      'description': 'Tüm oyunları oyna',
      'category': 'games',
      'rarity': 'epic',
      'icon': 'military_tech',
      'requiredValue': 11,
      'xpReward': 150,
    },

    // Skor Başarıları
    {
      'id': 'score_hunter',
      'title': 'Puan Avcısı',
      'description': 'Toplamda 1000 puan kazan',
      'category': 'score',
      'rarity': 'common',
      'icon': 'stars',
      'requiredValue': 1000,
      'xpReward': 20,
    },
    {
      'id': 'high_scorer',
      'title': 'Yüksek Skorcu',
      'description': 'Toplamda 5000 puan kazan',
      'category': 'score',
      'rarity': 'rare',
      'icon': 'stars',
      'requiredValue': 5000,
      'xpReward': 75,
    },
    {
      'id': 'legendary_scorer',
      'title': 'Efsanevi Skorcu',
      'description': 'Toplamda 10000 puan kazan',
      'category': 'score',
      'rarity': 'legendary',
      'icon': 'workspace_premium',
      'requiredValue': 10000,
      'xpReward': 200,
    },

    // Ustalık Başarıları
    {
      'id': 'perfectionist',
      'title': 'Mükemmeliyetçi',
      'description': 'Bir oyunda 900+ puan al',
      'category': 'mastery',
      'rarity': 'epic',
      'icon': 'auto_awesome',
      'requiredValue': 1,
      'xpReward': 100,
    },
    {
      'id': 'speed_demon',
      'title': 'Hız Canavarı',
      'description': '10 seviyeyi 5 dakikadan kısa sürede tamamla',
      'category': 'mastery',
      'rarity': 'epic',
      'icon': 'speed',
      'requiredValue': 1,
      'xpReward': 100,
    },

    // Süreklilik Başarıları
    {
      'id': 'daily_player',
      'title': 'Günlük Oyuncu',
      'description': '3 gün üst üste oyna',
      'category': 'streak',
      'rarity': 'rare',
      'icon': 'local_fire_department',
      'requiredValue': 3,
      'xpReward': 50,
    },
    {
      'id': 'dedicated_player',
      'title': 'Adanmış Oyuncu',
      'description': '7 gün üst üste oyna',
      'category': 'streak',
      'rarity': 'epic',
      'icon': 'local_fire_department',
      'requiredValue': 7,
      'xpReward': 125,
    },
    {
      'id': 'unstoppable',
      'title': 'Durdurulamaz',
      'description': '30 gün üst üste oyna',
      'category': 'streak',
      'rarity': 'legendary',
      'icon': 'local_fire_department',
      'requiredValue': 30,
      'xpReward': 500,
    },

    // Özel Başarılar
    {
      'id': 'quest_completer',
      'title': 'Görev Tamamlayıcı',
      'description': '10 günlük görevi tamamla',
      'category': 'special',
      'rarity': 'rare',
      'icon': 'assignment_turned_in',
      'requiredValue': 10,
      'xpReward': 75,
    },
    {
      'id': 'early_bird',
      'title': 'Erken Kuş',
      'description': 'Sabah 8 öncesi oyun oyna',
      'category': 'special',
      'rarity': 'rare',
      'icon': 'wb_sunny',
      'requiredValue': 1,
      'xpReward': 25,
    },
  ];

  static Map<String, dynamic>? getTemplate(String id) {
    try {
      return templates.firstWhere((t) => t['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
