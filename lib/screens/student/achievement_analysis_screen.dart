import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../services/achievement_service.dart';
import '../../models/game_result_model.dart';
import '../../utils/app_localizations.dart';

/// Kazanım Analizleri Ekranı
class AchievementAnalysisScreen extends StatefulWidget {
  const AchievementAnalysisScreen({super.key});

  @override
  State<AchievementAnalysisScreen> createState() => _AchievementAnalysisScreenState();
}

class _AchievementAnalysisScreenState extends State<AchievementAnalysisScreen> {
  final AchievementService _achievementService = AchievementService();
  bool _isLoading = true;
  OverallStatistics? _overallStats;
  List<GameStatistics> _gameStats = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final overallStats = await _achievementService.getOverallStatistics(userId);
      final gameStats = await _achievementService.getGameStatistics(userId);

      setState(() {
        _overallStats = overallStats as OverallStatistics;
        _gameStats = gameStats.cast<GameStatistics>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.loadingDataError}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.achievementAnalysis),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _overallStats == null || _overallStats!.totalGamesPlayed == 0
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    final loc = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            loc.noGamesPlayed,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            loc.playGamesMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final loc = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel Başarı Kartı
            _buildOverallCard(),
            const SizedBox(height: 24),

            // Oyun Bazlı İstatistikler
            Text(
              loc.gameBasedPerformance,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Oyun kartları
            ..._gameStats.map((stat) => _buildGameCard(stat)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallCard() {
    final loc = AppLocalizations.of(context);
    final stats = _overallStats!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              loc.overallSuccess,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Daire grafik
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: stats.totalCorrect.toDouble(),
                      title: '${stats.overallSuccessRate.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: stats.totalWrong.toDouble(),
                      title: '',
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // İstatistik özeti
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  loc.totalGames,
                  stats.totalGamesPlayed.toString(),
                  Icons.games,
                  Colors.blue,
                ),
                _buildStatItem(
                  loc.correct,
                  stats.totalCorrect.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  loc.wrong,
                  stats.totalWrong.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(GameStatistics stat) {
    final loc = AppLocalizations.of(context);
    final correctPercent = stat.totalQuestions == 0
        ? 0.0
        : (stat.totalCorrect / stat.totalQuestions) * 100;
    final wrongPercent = 100 - correctPercent;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.gamepad,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stat.gameName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getSuccessColor(stat.averageSuccessRate).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stat.averageSuccessRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getSuccessColor(stat.averageSuccessRate),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mini pie chart
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 1,
                      centerSpaceRadius: 25,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: stat.totalCorrect.toDouble(),
                          title: '',
                          radius: 25,
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: stat.totalWrong.toDouble(),
                          title: '',
                          radius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        loc.correct,
                        stat.totalCorrect,
                        correctPercent,
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        loc.wrong,
                        stat.totalWrong,
                        wrongPercent,
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stat.totalPlays} ${loc.timesPlayed}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int count, double percent, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $count (${percent.toStringAsFixed(1)}%)',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Color _getSuccessColor(double successRate) {
    if (successRate >= 80) return Colors.green;
    if (successRate >= 60) return Colors.orange;
    return Colors.red;
  }
}
