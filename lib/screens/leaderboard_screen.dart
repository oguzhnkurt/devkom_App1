import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/leaderboard_model.dart';
import '../models/game_model.dart';
import '../services/leaderboard_service.dart';
import '../providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  final String? gameId;
  final String? gameName;
  final GameType? gameType;

  const LeaderboardScreen({
    Key? key,
    this.gameId,
    this.gameName,
    this.gameType,
  }) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LeaderboardService _leaderboardService = LeaderboardService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
            const SizedBox(width: 8),
            Text(
              widget.gameName ?? 'Liderlik Tablosu',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Bu Oyun'),
            Tab(text: 'Genel Sıralama'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1D3F), Color(0xFF0D0F1E)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildGameLeaderboard(),
            _buildGlobalLeaderboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameLeaderboard() {
    if (widget.gameType == null) {
      return const Center(
        child: Text(
          'Oyun bilgisi bulunamadı',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return FutureBuilder<List<LeaderboardEntry>>(
      future: _leaderboardService.getTopEntries(
        gameType: widget.gameType!,
        limit: 100,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD700)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Henüz kimse bu oyunu oynamamış.\nİlk sen ol!');
        }

        final entries = snapshot.data!;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUserId = authProvider.currentUser?.uid;

        return Column(
          children: [
            const SizedBox(height: 120),
            if (currentUserId != null) _buildUserRank(entries, currentUserId),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return _buildLeaderboardTile(
                    entries[index],
                    index + 1,
                    currentUserId,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlobalLeaderboard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getGlobalLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD700)),
          );
        }

        if (!snapshot.hasData || (snapshot.data!['entries'] as List).isEmpty) {
          return _buildEmptyState('Henüz genel sıralama yok.\nOyunları oynayarak puan topla!');
        }

        final entries = snapshot.data!['entries'] as List<Map<String, dynamic>>;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUserId = authProvider.currentUser?.uid;

        return Column(
          children: [
            const SizedBox(height: 120),
            if (currentUserId != null) _buildGlobalUserRank(entries, currentUserId),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return _buildGlobalLeaderboardTile(
                    entries[index],
                    index + 1,
                    currentUserId,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getGlobalLeaderboard() async {
    // Basitleştirilmiş global leaderboard - tüm oyunlardan en yüksek skorlar
    final allGameTypes = GameType.values;
    Map<String, int> userScores = {};
    Map<String, String> userNames = {};

    for (final gameType in allGameTypes) {
      final entries = await _leaderboardService.getTopEntries(
        gameType: gameType,
        limit: 100,
      );

      for (final entry in entries) {
        userScores[entry.userId] = (userScores[entry.userId] ?? 0) + entry.score;
        userNames[entry.userId] = entry.userName;
      }
    }

    final sortedEntries = userScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = sortedEntries.map((entry) => {
      'userId': entry.key,
      'userName': userNames[entry.key] ?? 'Anonim',
      'totalScore': entry.value,
    }).toList();

    return {'entries': result};
  }

  Widget _buildUserRank(List<LeaderboardEntry> entries, String userId) {
    final userEntry = entries.where((e) => e.userId == userId).firstOrNull;
    final rank = userEntry != null ? entries.indexOf(userEntry) + 1 : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.3),
            const Color(0xFFFFD700).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Senin Sıralaman',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            rank != null ? '#$rank' : 'Henüz yok',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalUserRank(List<Map<String, dynamic>> entries, String userId) {
    final userIndex = entries.indexWhere((e) => e['userId'] == userId);
    final rank = userIndex != -1 ? userIndex + 1 : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7B2FFF).withOpacity(0.3),
            const Color(0xFF7B2FFF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF7B2FFF), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Genel Sıralaman',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            rank != null ? '#$rank' : 'Henüz yok',
            style: const TextStyle(
              color: Color(0xFF7B2FFF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry, int rank, String? currentUserId) {
    final isCurrentUser = entry.userId == currentUserId;
    Color rankColor = Colors.white;

    if (rank == 1) rankColor = const Color(0xFFFFD700); // Gold
    if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
    if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFF00F5FF).withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrentUser ? const Color(0xFF00F5FF) : Colors.white.withOpacity(0.1),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: rankColor, width: 2),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatTimestamp(entry.completedAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.3),
                  const Color(0xFFFFD700).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${entry.score} puan',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboardTile(Map<String, dynamic> entry, int rank, String? currentUserId) {
    final isCurrentUser = entry['userId'] == currentUserId;
    Color rankColor = Colors.white;

    if (rank == 1) rankColor = const Color(0xFFFFD700); // Gold
    if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
    if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFF7B2FFF).withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrentUser ? const Color(0xFF7B2FFF) : Colors.white.withOpacity(0.1),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: rankColor, width: 2),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User Info
          Expanded(
            child: Text(
              entry['userName'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          // Total Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7B2FFF).withOpacity(0.3),
                  const Color(0xFF7B2FFF).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${entry['totalScore']} puan',
              style: const TextStyle(
                color: Color(0xFF7B2FFF),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Color(0xFFFFD700),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}
