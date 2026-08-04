import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../services/achievement_badge_service.dart';

/// Rozetler Widget'ı
/// Ana ekranda son kazanılan rozetleri göster
class AchievementsWidget extends StatelessWidget {
  final String userId;
  final AchievementBadgeService _achievementService = AchievementBadgeService();

  AchievementsWidget({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _achievementService.getAchievementStats(userId),
      builder: (context, statsSnapshot) {
        if (!statsSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stats = statsSnapshot.data!;
        final unlockedCount = stats['unlocked'] as int;
        final totalCount = stats['total'] as int;
        final percentage = stats['percentage'] as int;

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
            const SizedBox(height: 16),

            // Recent Achievements
            // TODO: Migrate to Supabase - Future type mismatch
            FutureBuilder<List<dynamic>>(
              future: _achievementService.getRecentlyUnlocked(userId, limit: 3),
              builder: (context, achievementsSnapshot) {
                if (!achievementsSnapshot.hasData || achievementsSnapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final achievements = achievementsSnapshot.data!;

                return Column(
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
                    ...achievements.map((achievement) =>
                        _buildAchievementTile(achievement)),
                  ],
                );
              },
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
            'Oyunları oynayarak rozet kazan!',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            achievement.color.withValues(alpha: 0.1),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: achievement.color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: achievement.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.rarityLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: achievement.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // XP Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: achievement.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(
                  '+${achievement.xpReward}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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

/// Tüm Rozetler Ekranı
class _AllAchievementsScreen extends StatelessWidget {
  final String userId;
  final AchievementBadgeService _achievementService = AchievementBadgeService();

  _AllAchievementsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rozetlerim'),
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _achievementService.getUserAchievements(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Rozet bulunamadı'));
          }

          final achievements = snapshot.data!;
          final categories = <AchievementCategory, List<Achievement>>{};

          // Kategorilere göre grupla
          for (final achievement in achievements) {
            if (!categories.containsKey(achievement.category)) {
              categories[achievement.category] = [];
            }
            categories[achievement.category]!.add(achievement);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories.keys.elementAt(index);
              final categoryAchievements = categories[category]!;

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
                  ...categoryAchievements.map((achievement) =>
                      _buildFullAchievementCard(achievement)),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFullAchievementCard(Achievement achievement) {
    final isLocked = !achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey[100] : achievement.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isLocked ? Colors.grey.shade300 : achievement.color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey[300]
                      : achievement.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  color: isLocked ? Colors.grey : achievement.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Rarity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey : achievement.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  achievement.rarityLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar (if not unlocked)
          if (isLocked) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İlerleme',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${achievement.currentProgress}/${achievement.requiredValue}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: achievement.progressPercentage,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
              ),
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Açıldı! +${achievement.xpReward} XP',
                  style: const TextStyle(
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
    );
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.games:
        return 'Oyun Başarıları';
      case AchievementCategory.score:
        return 'Skor Başarıları';
      case AchievementCategory.streak:
        return 'Süreklilik Başarıları';
      case AchievementCategory.mastery:
        return 'Ustalık Başarıları';
      case AchievementCategory.social:
        return 'Sosyal Başarılar';
      case AchievementCategory.special:
        return 'Özel Başarılar';
    }
  }
}
