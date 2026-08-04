import 'package:flutter/material.dart';
// TODO: Migrate to Supabase - import 'package:cloud_firestore/cloud_firestore.dart';

/// İlerleme Göstergesi Widget
/// Öğrencinin oyun ilerlemesini görsel olarak gösterir
class ProgressIndicatorWidget extends StatelessWidget {
  final String userId;

  const ProgressIndicatorWidget({
    super.key,
    required this.userId,
  });

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
            color: Colors.grey.withValues(alpha: 0.2),
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
}
