import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../models/leaderboard_model.dart';
import '../../models/game_model.dart';
import '../../services/leaderboard_service.dart';
import '../../services/achievement_service.dart';
import '../../providers/settings_provider.dart';
import '../../theme.dart';

/// Game Result Screen
/// Oyun bittiğinde gösterilen sonuç ekranı
/// - Konfeti animasyonu
/// - Kullanıcının sıralaması
/// - Tebrik mesajı
/// - Leaderboard tablosu
class GameResultScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final GameType gameType;
  final int score;
  final int? timeSeconds;
  final int? correctCount;
  final int? totalQuestions;
  final int? difficulty;

  const GameResultScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.gameType,
    required this.score,
    this.timeSeconds,
    this.correctCount,
    this.totalQuestions,
    this.difficulty,
  }) : super(key: key);

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AchievementService _achievementService = AchievementService();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  List<LeaderboardEntry> _topEntries = [];
  int? _userRank;
  bool _isLoading = true;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  @override
  void initState() {
    super.initState();
    _loadLeaderboardAndRank();
    _saveGameResult();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Oyun sonucunu achievement sistemine kaydet
  Future<void> _saveGameResult() async {
    try {
      // correctCount ve totalQuestions varsa onları kullan
      if (widget.correctCount != null && widget.totalQuestions != null) {
        final correctAnswers = widget.correctCount!;
        final totalQuestions = widget.totalQuestions!;
        final wrongAnswers = totalQuestions - correctAnswers;

        await _achievementService.saveGameResult(
          userId: widget.userId,
          gameId: widget.gameType.name,
          score: (correctAnswers / totalQuestions * 100).round(),
          duration: widget.timeSeconds ?? 0,
        );
        debugPrint('✅ Oyun sonucu kaydedildi (correct/wrong tracking)');
      }
      // Eğer correctCount yoksa ama score varsa, score-based kaydet
      else if (widget.score > 0) {
        // Score'u 100 üzerinden normalleştir ve doğru/yanlış olarak kaydet
        final normalizedCorrect = widget.score;
        final normalizedTotal = 100; // Varsayılan total
        final wrongAnswers = normalizedTotal - normalizedCorrect;

        await _achievementService.saveGameResult(
          userId: widget.userId,
          gameId: widget.gameType.name,
          score: widget.score,
          duration: widget.timeSeconds ?? 0,
        );
        debugPrint('✅ Oyun sonucu kaydedildi (score-based)');
      }
    } catch (e) {
      // Sessizce hata yakala, kullanıcıyı rahatsız etme
      debugPrint('❌ Achievement kaydetme hatası: $e');
    }
  }

  Future<void> _loadLeaderboardAndRank() async {
    // Get top 10 entries
    final entries = await _leaderboardService.getTopEntries(
      gameType: widget.gameType,
      limit: 10,
    );

    // Get user's rank
    final rank = await _leaderboardService.getUserRank(
      userId: widget.userId,
      gameType: widget.gameType,
      difficulty: widget.difficulty,
    );

    if (mounted) {
      setState(() {
        _topEntries = entries;
        _userRank = rank;
        _isLoading = false;
      });

      // Trigger confetti if user is in top 3
      if (rank != null && rank <= 3) {
        _confettiController.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEn ? 'Game Result' : 'Oyun Sonucu'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
      ),
      body: Stack(
        children: [
          // Main content
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppTheme.primaryBlue,
                AppTheme.accentTeal,
                AppTheme.accentYellow,
                AppTheme.successGreen,
                AppTheme.warningOrange,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Congratulations Card
          _buildCongratulationsCard(),

          const SizedBox(height: 24),

          // Leaderboard Title
          Text(
            widget.gameType.leaderboardTitleFor(_lang),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBlue,
            ),
          ),

          const SizedBox(height: 16),

          // Leaderboard List
          if (_topEntries.isEmpty)
            _buildEmptyState()
          else
            _buildLeaderboardList(),
        ],
      ),
    );
  }

  Widget _buildCongratulationsCard() {
    final rankMessage = _getRankMessage();
    final rankColor = _getRankColor();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [rankColor.withOpacity(0.8), rankColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Rank Icon/Number
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _userRank != null ? _getRankIcon(_userRank!) : '?',
                style: const TextStyle(
                  fontSize: 40,
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Congratulations Message
          Text(
            rankMessage,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Score Details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildScoreDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetails() {
    if (widget.gameType == GameType.quiz) {
      return Column(
        children: [
          Text(
            _isEn ? 'Correct: ${widget.correctCount}/${widget.totalQuestions}' : 'Doğru: ${widget.correctCount}/${widget.totalQuestions}',
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isEn ? 'Time: ${_formatTime(widget.timeSeconds ?? 0)}' : 'Süre: ${_formatTime(widget.timeSeconds ?? 0)}',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.white,
            ),
          ),
        ],
      );
    }

    final type = widget.gameType.leaderboardType;
    switch (type) {
      case LeaderboardType.highScore:
      case LeaderboardType.winRate:
        return Text(
          _isEn ? 'Score: ${widget.score}' : 'Puan: ${widget.score}',
          style: const TextStyle(
            fontSize: 20,
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        );
      case LeaderboardType.fastestTime:
        return Text(
          _isEn ? 'Time: ${_formatTime(widget.timeSeconds ?? 0)}' : 'Süre: ${_formatTime(widget.timeSeconds ?? 0)}',
          style: const TextStyle(
            fontSize: 20,
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  String _getRankMessage() {
    if (_userRank == null) return _isEn ? 'Great performance!' : 'Harika bir performans!';

    switch (_userRank) {
      case 1:
        return _isEn ? 'Congratulations! 🥇\nYou\'re #1!' : 'Tebrikler! 🥇\n1. Oldunuz!';
      case 2:
        return _isEn ? 'Awesome! 🥈\nYou Ranked #2!' : 'Harika! 🥈\n2. Sıraya Yerleştiniz!';
      case 3:
        return _isEn ? 'Amazing! 🥉\nYou Ranked #3!' : 'Muhteşem! 🥉\n3. Sıraya Yerleştiniz!';
      default:
        if (_userRank! <= 10) {
          return _isEn ? 'Very Good! 🎯\nYou Ranked #$_userRank!' : 'Çok İyi! 🎯\n${_userRank}. Sıraya Yerleştiniz!';
        }
        return _isEn ? 'Congratulations! 🎮\nYou Made the Leaderboard!' : 'Tebrikler! 🎮\nSkor Tabelasına Girdiniz!';
    }
  }

  Color _getRankColor() {
    if (_userRank == null) return AppTheme.primaryBlue;

    switch (_userRank) {
      case 1:
        return AppTheme.accentYellow; // Gold
      case 2:
        return AppTheme.mediumGray; // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.accentTeal;
    }
  }

  String _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.emoji_events_outlined, size: 80, color: AppTheme.mediumGray),
            const SizedBox(height: 16),
            Text(
              _isEn ? 'No one has played this game yet!' : 'Henüz kimse bu oyunu oynamamış!',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Column(
      children: _topEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final leaderboardEntry = entry.value;
        final rank = index + 1;
        final isCurrentUser = leaderboardEntry.userId == widget.userId;

        return _buildLeaderboardTile(leaderboardEntry, rank, isCurrentUser);
      }).toList(),
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry, int rank, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.accentYellow.withOpacity(0.2)
            : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: AppTheme.accentYellow, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? AppTheme.accentYellow.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getRankBadgeColor(rank),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getRankIcon(rank),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrentUser
                  ? AppTheme.accentYellow.withOpacity(0.3)
                  : AppTheme.primaryBlue.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                entry.userName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? AppTheme.accentYellow : AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.userName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isEn ? 'YOU' : 'SİZ',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (entry.difficulty != null)
                  Text(
                    _isEn ? 'Difficulty: ${entry.difficulty}' : 'Zorluk: ${entry.difficulty}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.mediumGray,
                    ),
                  ),
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getScoreText(entry),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? AppTheme.accentYellow : AppTheme.primaryBlue,
                ),
              ),
              Text(
                widget.gameType.scoreLabelFor(_lang),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankBadgeColor(int rank) {
    switch (rank) {
      case 1:
        return AppTheme.accentYellow;
      case 2:
        return AppTheme.mediumGray;
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppTheme.primaryBlue;
    }
  }

  String _getScoreText(LeaderboardEntry entry) {
    // Special handling for Quiz
    if (widget.gameType == GameType.quiz) {
      final correct = entry.correctCount ?? 0;
      final total = entry.totalQuestions ?? 0;
      final timeText = _formatTime(entry.timeSeconds ?? 0);
      return '$correct/$total • $timeText';
    }

    final type = widget.gameType.leaderboardType;
    switch (type) {
      case LeaderboardType.highScore:
      case LeaderboardType.winRate:
        return '${entry.score}';
      case LeaderboardType.fastestTime:
        return _formatTime(entry.timeSeconds ?? 0);
    }
  }
}
