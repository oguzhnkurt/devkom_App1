import 'package:flutter/material.dart';
import '../models/daily_quest_model.dart';
import '../services/daily_quest_service.dart';

/// Günlük Görevler Widget'ı
/// Ana ekranda görevleri görsel olarak gösterir
class DailyQuestsWidget extends StatelessWidget {
  final String userId;
  final DailyQuestService _questService = DailyQuestService();

  DailyQuestsWidget({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Migrate to Supabase - Stream type mismatch
    return StreamBuilder<List<dynamic>>(
      stream: _questService.getUserQuests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Görev yoksa oluştur
          _questService.generateDailyQuests(userId);
          return _buildEmptyCard(context);
        }

        final quests = snapshot.data!;
        final completedCount = quests.where((q) => q.isCompleted).length;

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
                          colors: [Colors.orange.shade400, Colors.red.shade400],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Günlük Görevler',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: completedCount == quests.length
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completedCount/${quests.length}',
                    style: TextStyle(
                      color: completedCount == quests.length
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quest Cards
            ...quests.map((quest) => _buildQuestCard(context, quest)),

            // Completion Badge
            if (completedCount == quests.length) _buildCompletionBadge(context),
          ],
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.red.shade50],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 48,
            color: Colors.orange[400],
          ),
          const SizedBox(height: 12),
          const Text(
            'Günlük Görevler Yükleniyor...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(BuildContext context, DailyQuest quest) {
    final isCompleted = quest.isCompleted;
    final progressPercent = quest.progressPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade100
                      : _getQuestColor(quest.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getQuestIcon(quest.type),
                  color: isCompleted ? Colors.green.shade700 : _getQuestColor(quest.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green.shade700 : Colors.black87,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quest.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Reward Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade300, Colors.orange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${quest.rewardXP}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'İlerleme',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${quest.currentProgress}/${quest.targetValue}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted ? Colors.green.shade700 : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green.shade400 : _getQuestColor(quest.type),
                  ),
                ),
              ),
            ],
          ),

          // Completion Check
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Tamamlandı!',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletionBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade400],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tebrikler!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tüm günlük görevleri tamamladın!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  IconData _getQuestIcon(QuestType type) {
    switch (type) {
      case QuestType.playGames:
        return Icons.sports_esports;
      case QuestType.earnScore:
        return Icons.stars;
      case QuestType.completeLevel:
        return Icons.flag;
      case QuestType.perfectScore:
        return Icons.emoji_events;
      case QuestType.playStreak:
        return Icons.local_fire_department;
      case QuestType.tryAllGames:
        return Icons.explore;
    }
  }

  Color _getQuestColor(QuestType type) {
    switch (type) {
      case QuestType.playGames:
        return Colors.blue;
      case QuestType.earnScore:
        return Colors.amber;
      case QuestType.completeLevel:
        return Colors.purple;
      case QuestType.perfectScore:
        return Colors.red;
      case QuestType.playStreak:
        return Colors.orange;
      case QuestType.tryAllGames:
        return Colors.teal;
    }
  }
}
