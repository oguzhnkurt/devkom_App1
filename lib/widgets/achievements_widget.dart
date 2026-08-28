import 'package:flutter/material.dart';
import '../models/user_progress_model.dart';
import '../services/user_progress_service.dart';
import '../screens/character_screen.dart';

/// Rozetler Widget'ı
/// Ana ekranda son kazanılan rozetleri göster
///
/// Not: Eskiden AchievementBadgeService (Firebase→Supabase göçü tamamlanmamış,
/// hep boş veri dönen stub) kullanıyordu ve bu yüzden rozet sayfası açılırken
/// çöküyordu. Artık UserProgressService/DefaultBadges üzerinden gerçek,
/// Supabase'den okunan rozet verisini kullanıyor (uygulamanın geri kalanında
/// zaten kullanılan sistemle aynı).
class AchievementsWidget extends StatelessWidget {
  final String userId;
  final UserProgressService _progressService = UserProgressService();

  AchievementsWidget({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProgress?>(
      future: _progressService.loadUserProgress(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final badges = _progressService.getUserBadges();
        final unlockedCount = badges.where((b) => b.isEarned).length;
        final totalCount = badges.length;
        final percentage =
            totalCount == 0 ? 0 : ((unlockedCount / totalCount) * 100).round();
        final recentBadges = badges.where((b) => b.isEarned).take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade600],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Rozetlerim',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    _showAllAchievements(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$unlockedCount/$totalCount',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: Colors.amber.shade700, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade50, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber.shade200, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tamamlanma',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '%$percentage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Karakterim girişi
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CharacterScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF6C3CE0)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('👾', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Karakterim: kolye, şapka ve daha fazlasıyla özelleştir',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recent Achievements
            if (recentBadges.isEmpty)
              _buildEmptyState()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Son Kazanılanlar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recentBadges.map((badge) => _buildBadgeTile(badge)),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Henüz Rozet Yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ders izleyerek, oyun oynayarak rozet kazan!',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTile(Badge badge) {
    final color = badgeCategoryColor(badge.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(badge.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  void _showAllAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AllAchievementsScreen(userId: userId),
      ),
    );
  }
}

/// Kategoriye göre renk (widget + tam ekran arasında paylaşılıyor)
Color badgeCategoryColor(BadgeCategory category) {
  switch (category) {
    case BadgeCategory.milestone:
      return Colors.amber.shade700;
    case BadgeCategory.streak:
      return Colors.deepOrange;
    case BadgeCategory.lesson:
      return Colors.blue;
    case BadgeCategory.game:
      return Colors.purple;
    case BadgeCategory.special:
      return Colors.teal;
  }
}

/// Tüm Rozetler Ekranı
class _AllAchievementsScreen extends StatelessWidget {
  final String userId;
  final UserProgressService _progressService = UserProgressService();

  _AllAchievementsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rozetlerim'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Karakterim',
            icon: const Text('👾', style: TextStyle(fontSize: 20)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CharacterScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<UserProgress?>(
        future: _progressService.loadUserProgress(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final badges = _progressService.getUserBadges();
          if (badges.isEmpty) {
            return const Center(child: Text('Rozet bulunamadı'));
          }

          final categories = <BadgeCategory, List<Badge>>{};
          for (final badge in badges) {
            categories.putIfAbsent(badge.category, () => []).add(badge);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories.keys.elementAt(index);
              final categoryBadges = categories[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _getCategoryName(category),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...categoryBadges.map((badge) => _buildFullBadgeCard(badge)),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFullBadgeCard(Badge badge) {
    final isLocked = !badge.isEarned;
    final color = badgeCategoryColor(badge.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey[100] : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isLocked ? Colors.grey.shade300 : color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey[300] : color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              badge.emoji,
              style: TextStyle(
                fontSize: 26,
                color: isLocked ? Colors.grey : null,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.grey : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (isLocked && badge.requiredXP > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${badge.requiredXP} XP gerekli',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
                if (!isLocked) ...[
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Kazanıldı!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.milestone:
        return 'Kilometre Taşları';
      case BadgeCategory.streak:
        return 'Süreklilik Başarıları';
      case BadgeCategory.lesson:
        return 'Ders Başarıları';
      case BadgeCategory.game:
        return 'Oyun Başarıları';
      case BadgeCategory.special:
        return 'Özel Başarılar';
    }
  }
}
