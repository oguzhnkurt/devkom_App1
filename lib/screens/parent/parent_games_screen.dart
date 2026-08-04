import 'package:flutter/material.dart';
import '../../theme.dart';
import '../games/millionaire_game_screen.dart';
import '../games/chess_game_screen.dart';

/// Parent games screen - allows parents to play games
class ParentGamesScreen extends StatelessWidget {
  const ParentGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Oyunlar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.accentTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(Icons.games, size: 64, color: AppTheme.white),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Eğlenceli Oyunlar',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Zihin geliştirici oyunlar oynayın',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Tüm Oyunlar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildGameCard(context, Icons.emoji_events, 'Kim Milyoner',
                  'Bilgi yarışması', const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MillionaireGameScreen())))),
                const SizedBox(width: 12),
                Expanded(child: _buildGameCard(context, Icons.castle, 'Satranç',
                  'Strateji oyunu', const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChessGameScreen())))),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.lightbulb_outline, color: AppTheme.warningOrange),
                      const SizedBox(width: 8),
                      Text('Oyun İpuçları', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 12),
                    _buildTipItem('🏆 Kim Milyoner: Genel kültür bilginizi test edin'),
                    const SizedBox(height: 2),
                    _buildTipItem('♟️ Satranç: Strateji becerilerinizi geliştirin'),
                    const SizedBox(height: 2),
                    _buildTipItem('🎮 Düzenli oyun oynamak zihinsel becerileri geliştirir'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, IconData icon, String title, 
    String description, Gradient gradient, VoidCallback onTap) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: BoxDecoration(gradient: gradient),
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.white.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: Icon(icon, size: 24, color: AppTheme.white),
              ),
              const SizedBox(height: 2),
              Text(title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.white, height: 1.2)),
              // const SizedBox(height: 2),
              Text(description, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: AppTheme.white.withValues(alpha: 0.9))),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20)),
                child: const Text('OYNA',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.white, letterSpacing: 1.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(children: [Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])))]);
  }
}
