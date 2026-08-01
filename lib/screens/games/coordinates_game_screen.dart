import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../models/game_model.dart';
import '../../models/leaderboard_model.dart';
import '../../services/leaderboard_service.dart';
import '../../services/sound_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/score_calculator.dart';
import '../leaderboard/leaderboard_screen.dart';

/// Koordinat Macerası Oyunu
/// X-Y koordinat sistemini öğreten interaktif oyun
class CoordinatesGameScreen extends StatefulWidget {
  const CoordinatesGameScreen({Key? key}) : super(key: key);

  @override
  State<CoordinatesGameScreen> createState() => _CoordinatesGameScreenState();
}

class _CoordinatesGameScreenState extends State<CoordinatesGameScreen> {
  // Oyun ayarları
  final int maxLevels = 15; // Maksimum seviye (arttırıldı)
  final Random _random = Random();
  final LeaderboardService _leaderboardService = LeaderboardService();

  // Oyun durumu
  int currentLevel = 1;
  int score = 0;
  int targetX = 0;
  int targetY = 0;
  int? selectedX;
  int? selectedY;
  bool showHint = false;
  bool gameWon = false;
  bool gameCompleted = false;
  DateTime? startTime;
  int? finalTimeSeconds;

  // Süre limiti sistemi
  DateTime? levelStartTime;
  int? remainingTime;
  bool timeExpired = false;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  // Seviye bazlı grid boyutu (6x6 → 8x8 → 10x10)
  int get gridSize {
    if (currentLevel <= 5) return 6;  // Seviye 1-5: 6x6
    if (currentLevel <= 10) return 8; // Seviye 6-10: 8x8
    return 10;                        // Seviye 11-15: 10x10
  }

  // Seviye bazlı süre limiti (saniye)
  int get timeLimit {
    if (currentLevel <= 5) return 45;  // Seviye 1-5: 45 saniye
    if (currentLevel <= 10) return 60; // Seviye 6-10: 60 saniye
    return 75;                         // Seviye 11-15: 75 saniye
  }

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _generateNewTarget();
    _startLevelTimer();
  }

  @override
  void dispose() {
    // Timer'ı temizle
    super.dispose();
  }

  void _startLevelTimer() {
    levelStartTime = DateTime.now();
    remainingTime = timeLimit;
    timeExpired = false;

    // Her saniye güncelle
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || gameCompleted || timeExpired) return false;

      setState(() {
        if (levelStartTime != null) {
          final elapsed = DateTime.now().difference(levelStartTime!).inSeconds;
          remainingTime = timeLimit - elapsed;

          if (remainingTime! <= 0) {
            remainingTime = 0;
            timeExpired = true;
            _handleTimeExpired();
          }
        }
      });

      return !timeExpired && !gameCompleted && mounted;
    });
  }

  void _handleTimeExpired() {
    // Oyun bitti sesi
    SoundService.playGameOver();
    _showMessage(_isEn ? 'Time\'s up! Game over.' : 'Süre doldu! Oyun bitti.', AppTheme.errorRed);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _generateNewTarget() {
    setState(() {
      targetX = _random.nextInt(gridSize);
      targetY = _random.nextInt(gridSize);
      selectedX = null;
      selectedY = null;
      showHint = false;
      gameWon = false;
    });
  }

  void _checkAnswer() {
    if (selectedX == null || selectedY == null) {
      _showMessage(_isEn ? 'Please select a point!' : 'Lütfen bir nokta seç!', Colors.orange);
      return;
    }

    if (selectedX == targetX && selectedY == targetY) {
      // Doğru cevap sesi
      SoundService.playCorrect();

      // Standardize edilmiş skor hesapla
      final levelScore = ScoreCalculator.calculateCoordinatesScore(
        level: currentLevel,
        timeRemaining: remainingTime ?? 0,
        totalTime: timeLimit,
      );

      setState(() {
        score += levelScore;
        gameWon = true;
      });
      _showMessage(_isEn ? 'Great! +$levelScore points! 🎉' : 'Harika! +$levelScore puan! 🎉', AppTheme.successGreen);

      // Oyun tamamlandı mı kontrol et
      if (currentLevel >= maxLevels) {
        // Oyun tamamlama sesi
        SoundService.playLevelComplete();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _completeGame();
          }
        });
      } else {
        // Seviye tamamlama sesi
        SoundService.playScore();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              currentLevel++;
            });
            _generateNewTarget();
            _startLevelTimer(); // Yeni seviye için timer'ı yeniden başlat
          }
        });
      }
    } else {
      // Yanlış cevap sesi
      SoundService.playWrong();
      _showMessage(
        _isEn ? 'Try again! Tap the hint button for help.' : 'Tekrar dene! İpucu için yardım butonuna bas.',
        AppTheme.errorRed,
      );
    }
  }

  Future<void> _completeGame() async {
    // Süreyi hesapla
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime!);
      finalTimeSeconds = duration.inSeconds;
    }

    setState(() {
      gameCompleted = true;
    });

    // Leaderboard'a kaydet
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      try {
        final entry = LeaderboardEntry(
          id: '',
          userId: authProvider.currentUser!.uid,
          userName: authProvider.currentUser!.displayName,
          userPhotoUrl: authProvider.currentUser!.profilePictureUrl,
          gameType: GameType.coordinates,
          score: score,
          timeSeconds: finalTimeSeconds,
          difficulty: 1,
          completedAt: DateTime.now(),
          metadata: {
            'levelsCompleted': maxLevels,
            'gridSize': gridSize,
          },
        );

        await _leaderboardService.addEntry(entry);
      } catch (e) {
        debugPrint('Error saving to leaderboard: $e');
      }
    }
  }

  void _restartGame() {
    setState(() {
      currentLevel = 1;
      score = 0;
      gameCompleted = false;
      startTime = DateTime.now();
      finalTimeSeconds = null;
    });
    _generateNewTarget();
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getTimeColor() {
    if (remainingTime == null) return AppTheme.successGreen;
    final percentage = remainingTime! / timeLimit;
    if (percentage > 0.5) return AppTheme.successGreen;
    if (percentage > 0.25) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    // Oyun tamamlandıysa completion screen göster
    if (gameCompleted) {
      return _buildCompletionScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEn ? 'Coordinate Adventure' : 'Koordinat Macerası'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.star, color: AppTheme.warningOrange),
                  const SizedBox(width: 4),
                  Text(
                    _isEn ? 'Score: $score' : 'Skor: $score',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Level ve hedef bilgisi
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isEn ? 'Level $currentLevel' : 'Seviye $currentLevel',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                        ),
                        // Grid boyutu göstergesi
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${gridSize}x$gridSize',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Süre göstergesi
                    if (remainingTime != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getTimeColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getTimeColor(), width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer, color: _getTimeColor(), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _isEn ? 'Time Left: $remainingTime sec' : 'Kalan Süre: $remainingTime saniye',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getTimeColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _isEn ? 'Target Coordinate:' : 'Hedef Koordinat:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '($targetX, $targetY)',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentTeal,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Grid
            _buildGrid(),

            const SizedBox(height: 24),

            // Seçili koordinat
            if (selectedX != null && selectedY != null)
              Card(
                color: AppTheme.lightBlue.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isEn ? 'Your Coordinate: ' : 'Seçtiğin Koordinat: ',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '($selectedX, $selectedY)',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() => showHint = !showHint),
                  icon: const Icon(Icons.lightbulb),
                  label: Text(_isEn ? 'Hint' : 'İpucu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _checkAnswer,
                  icon: const Icon(Icons.check_circle),
                  label: Text(_isEn ? 'Check' : 'Kontrol Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),

            // İpucu
            if (showHint) ...[
              const SizedBox(height: 16),
              Card(
                color: AppTheme.warningOrange.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.warningOrange),
                          const SizedBox(width: 8),
                          Text(
                            _isEn ? 'Hint:' : 'İpucu:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEn
                            ? 'The X coordinate is on the ${targetX < gridSize ~/ 2 ? "left" : "right"}.\n'
                              'The Y coordinate is at the ${targetY < gridSize ~/ 2 ? "bottom" : "top"}.'
                            : 'X koordinatı ${targetX < gridSize ~/ 2 ? "soldadır" : "sağdadır"}.\n'
                              'Y koordinatı ${targetY < gridSize ~/ 2 ? "alttadır" : "üsttedir"}.',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Açıklama
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryBlue, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Y ekseni üstte
            Expanded(
              child: Row(
                children: [
                  // Y ekseni numaraları (sol)
                  SizedBox(
                    width: 30,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        gridSize,
                        (index) => Text(
                          '${gridSize - 1 - index}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Grid cells
                  Expanded(
                    child: Column(
                      children: List.generate(
                        gridSize,
                        (y) => Expanded(
                          child: Row(
                            children: List.generate(
                              gridSize,
                              (x) => _buildGridCell(x, gridSize - 1 - y),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // X ekseni numaraları (alt)
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  gridSize,
                  (index) => Text(
                    '$index',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(int x, int y) {
    final bool isSelected = selectedX == x && selectedY == y;
    final bool isTarget = targetX == x && targetY == y && gameWon;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedX = x;
            selectedY = y;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isTarget
                ? AppTheme.successGreen
                : isSelected
                    ? AppTheme.accentTeal
                    : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected || isTarget
                  ? Colors.white
                  : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Center(
            child: isTarget
                ? const Icon(Icons.star, color: Colors.white)
                : isSelected
                    ? const Icon(Icons.circle, color: Colors.white, size: 16)
                    : null,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      color: AppTheme.lightGray,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  _isEn ? 'How to Play?' : 'Nasıl Oynanır?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '1',
              _isEn ? 'Find the coordinate given above' : 'Yukarıda verilen koordinatı bul',
            ),
            _buildInstructionItem(
              '2',
              _isEn ? 'Tap the correct point on the grid' : 'Izgara üzerinde doğru noktaya tıkla',
            ),
            _buildInstructionItem(
              '3',
              _isEn ? 'Check the X (horizontal) and Y (vertical) values' : 'X (yatay) ve Y (dikey) değerlerini kontrol et',
            ),
            _buildInstructionItem(
              '4',
              _isEn ? 'Tap the "Check" button' : '"Kontrol Et" butonuna bas',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isEn
                    ? '💡 Hint: In (X, Y) format, X is horizontal, Y is vertical. '
                      'For example (3, 5) → X=3 right, Y=5 up'
                    : '💡 İpucu: (X, Y) formatında X yatay, Y dikeydir. '
                      'Örneğin (3, 5) → X=3 sağa, Y=5 yukarı',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEn ? 'Game Complete!' : 'Oyun Tamamlandı!'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy Icon
                  const Icon(
                    Icons.emoji_events,
                    size: 120,
                    color: Color(0xFFFFD700),
                  ),
                  const SizedBox(height: 24),

                  // Congratulations Text
                  Text(
                    _isEn ? 'Congratulations!' : 'Tebrikler!',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEn ? 'You completed the Coordinate Adventure!' : 'Koordinat Macerasını Tamamladın!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Stats Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildStatRow(
                            Icons.star,
                            _isEn ? 'Total Score' : 'Toplam Puan',
                            '$score',
                            AppTheme.warningOrange,
                          ),
                          const Divider(height: 24),
                          _buildStatRow(
                            Icons.timer,
                            _isEn ? 'Time' : 'Süre',
                            _formatTime(finalTimeSeconds ?? 0),
                            AppTheme.primaryBlue,
                          ),
                          const Divider(height: 24),
                          _buildStatRow(
                            Icons.trending_up,
                            _isEn ? 'Levels Completed' : 'Tamamlanan Seviye',
                            '$maxLevels / $maxLevels',
                            AppTheme.successGreen,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LeaderboardScreen(
                                  initialGameType: GameType.coordinates,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.emoji_events, size: 28),
                          label: Text(
                            _isEn ? 'View Leaderboard' : 'Liderlik Tablosunu Gör',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _restartGame,
                          icon: const Icon(Icons.refresh, size: 28),
                          label: Text(
                            _isEn ? 'Play Again' : 'Tekrar Oyna',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.home, size: 28),
                          label: Text(
                            _isEn ? 'Back to Main Menu' : 'Ana Menüye Dön',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${seconds}s';
  }
}
