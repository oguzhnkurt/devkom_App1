import 'package:flutter/material.dart';
// TODO: Migrate to Supabase - import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';
import '../theme.dart';

/// İlerleme Göstergesi Widget
/// Öğrencinin oyun ilerlemesini görsel olarak gösterir
class ProgressIndicatorWidget extends StatelessWidget {
  final String userId;

  const ProgressIndicatorWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Migrate to Supabase - Firebase StreamBuilder disabled
    return _buildEmptyCard(context);
  }

  // TODO: Migrate to Supabase - Commented out Firebase StreamBuilder
  // @override
  // Widget build(BuildContext context) {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: FirebaseFirestore.instance
  //         .collection('leaderboard')
  //         .where('userId', isEqualTo: userId)
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return _buildLoadingCard();
  //       }
  //
  //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //         return _buildEmptyCard(context);
  //       }
  //
  //       // Oyunlara göre en iyi skorları topla
  //       Map<GameType, int> bestScores = {};
  //       int totalGamesPlayed = 0;
  //
  //       for (var doc in snapshot.data!.docs) {
  //         final data = doc.data() as Map<String, dynamic>;
  //         final gameTypeStr = data['gameType'] as String?;
  //         final score = data['score'] as int? ?? 0;
  //
  //         if (gameTypeStr != null) {
  //           try {
  //             final gameType = GameType.values.firstWhere(
  //               (e) => e.toString().split('.').last == gameTypeStr,
  //             );
  //
  //             if (!bestScores.containsKey(gameType) ||
  //                 bestScores[gameType]! < score) {
  //               bestScores[gameType] = score;
  //             }
  //           } catch (e) {
  //             // Geçersiz gameType
  //           }
  //         }
  //       }
  //
  //       totalGamesPlayed = bestScores.length;
  //       int totalScore = bestScores.values.fold(0, (sum, score) => sum + score);
  //
  //       // Ortalama skor hesapla
  //       int averageScore = totalGamesPlayed > 0
  //           ? (totalScore / totalGamesPlayed).round()
  //           : 0;
  //
  //       // Tamamlama oranı (11 ana oyun var)
  //       double completionRate = (totalGamesPlayed / 11 * 100).clamp(0, 100);
  //
  //       // Seviye belirleme (ortalama skora göre)
  //       String level = _calculateLevel(averageScore);
  //       Color levelColor = _getLevelColor(averageScore);
  //
  //       return _buildProgressCard(
  //         context,
  //         totalGamesPlayed: totalGamesPlayed,
  //         totalScore: totalScore,
  //         averageScore: averageScore,
  //         completionRate: completionRate,
  //         level: level,
  //         levelColor: levelColor,
  //         bestScores: bestScores,
  //       );
  //     },
  //   );
  // }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
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
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.videogame_asset,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz Oyun Oynamadın',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Oyunları oynayarak ilerleme kaydet!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context, {
    required int totalGamesPlayed,
    required int totalScore,
    required int averageScore,
    required double completionRate,
    required String level,
    required Color levelColor,
    required Map<GameType, int> bestScores,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelColor.withOpacity(0.2), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: levelColor,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'İlerleme Durumun',
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
                  color: levelColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.sports_esports,
                  label: 'Oyun',
                  value: '$totalGamesPlayed',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  label: 'Toplam Puan',
                  value: '$totalScore',
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.analytics,
                  label: 'Ortalama',
                  value: '$averageScore',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'Tamamlama',
                  value: '${completionRate.toStringAsFixed(0)}%',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Oyun Tamamlama',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$totalGamesPlayed / 11 Oyun',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: completionRate / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateLevel(int averageScore) {
    if (averageScore >= 800) return 'Uzman';
    if (averageScore >= 600) return 'İleri';
    if (averageScore >= 400) return 'Orta';
    if (averageScore >= 200) return 'Başlangıç';
    return 'Yeni';
  }

  Color _getLevelColor(int averageScore) {
    if (averageScore >= 800) return const Color(0xFF00F5FF); // Diamond
    if (averageScore >= 600) return const Color(0xFFFFD700); // Gold
    if (averageScore >= 400) return const Color(0xFFC0C0C0); // Silver
    if (averageScore >= 200) return const Color(0xFFCD7F32); // Bronze
    return Colors.grey; // Yeni
  }
}
