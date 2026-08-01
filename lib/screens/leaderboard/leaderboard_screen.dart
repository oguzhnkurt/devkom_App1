import 'package:flutter/material.dart';
import '../../models/leaderboard_model.dart';
import '../../models/game_model.dart';
import '../../services/leaderboard_service.dart';
import '../../theme.dart';

class LeaderboardScreen extends StatefulWidget {
  final GameType? initialGameType;

  const LeaderboardScreen({Key? key, this.initialGameType}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();

  List<LeaderboardEntry> _topEntries = [];
  GameType? _selectedGameType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedGameType = widget.initialGameType ?? GameType.quiz;
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    if (_selectedGameType == null) return;

    setState(() => _isLoading = true);

    final entries = await _leaderboardService.getTopEntries(
      gameType: _selectedGameType!,
      limit: 10,
    );

    if (mounted) {
      setState(() {
        _topEntries = entries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skor Tabelası'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
      ),
      body: Column(
        children: [
          // Game type selector
          _buildGameTypeSelector(),

          // Leaderboard content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _topEntries.isEmpty
                    ? _buildEmptyState()
                    : _buildLeaderboardContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.lightGray,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: GameType.values.map((type) {
            final isSelected = _selectedGameType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_getGameTypeLabel(type)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedGameType = type);
                    _loadLeaderboard();
                  }
                },
                selectedColor: AppTheme.primaryBlue,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.white : AppTheme.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getGameTypeLabel(GameType type) {
    switch (type) {
      case GameType.quiz:
        return 'Quiz';
      case GameType.chess:
        return 'Satranç';
      case GameType.blockCoding:
        return 'Kodlama';
      case GameType.wordMatch:
        return 'Kelime';
      case GameType.sequencing:
        return 'Sıralama';
      case GameType.coordinates:
        return 'Koordinat';
      case GameType.puzzle:
        return 'Bulmaca';
      case GameType.simulation:
        return 'Simülasyon';
      case GameType.mazeExplorer:
        return 'Labirent';
      case GameType.colorCoding:
        return 'Renk Kodu';
      case GameType.robotSimulator:
        return 'Robot Sim';
      case GameType.leftRightCoding:
        return 'Sağım-Solum';
      case GameType.arduinoSimulator:
        return 'Arduino Sim';
      case GameType.pipesPuzzle:
        return 'Boru Bulmacası';
      case GameType.patternDetective:
        return 'Kod Dedektifi';
      case GameType.variableMaster:
        return 'Değişken Ustası';
      case GameType.bugHunter:
        return 'Bug Hunter';
      case GameType.matchingGame:
        return 'Eşleştirme';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            'Henüz kimse bu oyunu oynamamış!',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk sıralamaya giren sen ol!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title
        Text(
          _selectedGameType!.leaderboardTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Top 3 Podium
        if (_topEntries.isNotEmpty) _buildPodium(),

        const SizedBox(height: 32),

        // Rest of the list
        if (_topEntries.length > 3) ...[
          const Divider(),
          const SizedBox(height: 16),
          ..._topEntries
              .skip(3)
              .toList()
              .asMap()
              .entries
              .map((entry) => _buildLeaderboardTile(
                    entry.value,
                    entry.key + 4, // +4 because we skip first 3
                  )),
        ],
      ],
    );
  }

  Widget _buildPodium() {
    final top3 = _topEntries.take(3).toList();

    // Arrange: 2nd, 1st, 3rd
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        if (top3.length > 1)
          _buildPodiumPlace(top3[1], 2, AppTheme.mediumGray, 120),

        const SizedBox(width: 16),

        // 1st place
        _buildPodiumPlace(top3[0], 1, AppTheme.accentYellow, 150),

        const SizedBox(width: 16),

        // 3rd place
        if (top3.length > 2)
          _buildPodiumPlace(top3[2], 3, Color(0xFFCD7F32), 100),
      ],
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int rank, Color color, double height) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              entry.userName[0].toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Name
        SizedBox(
          width: 100,
          child: Text(
            entry.userName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),

        // Podium
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.getRankIcon(rank),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                _getScoreText(entry),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                entry.userName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
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
                Text(
                  entry.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.difficulty != null)
                  Text(
                    'Zorluk: ${entry.difficulty}',
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              Text(
                _selectedGameType!.scoreLabel,
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

  String _getScoreText(LeaderboardEntry entry) {
    // Special handling for Quiz
    if (_selectedGameType == GameType.quiz) {
      final correct = entry.correctCount ?? 0;
      final total = entry.totalQuestions ?? 0;
      final timeText = entry.getFormattedTime();
      return '$correct/$total • $timeText';
    }

    final type = _selectedGameType!.leaderboardType;
    switch (type) {
      case LeaderboardType.highScore:
      case LeaderboardType.winRate:
        return '${entry.score}';
      case LeaderboardType.fastestTime:
        return entry.getFormattedTime();
    }
  }
}
