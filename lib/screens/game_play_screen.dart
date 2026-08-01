import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_model.dart';
import '../services/games_service.dart';
import '../services/achievement_service.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'games/chess_game_screen.dart';
import 'games/coordinates_game_screen.dart';
import 'games/block_coding_game_screen.dart';
import 'games/word_match_game_screen.dart';
import 'games/sequencing_game_screen.dart';
import 'games/maze_explorer_game_screen.dart';
import 'games/maze_3d_game_screen.dart';
import 'games/left_right_coding_game_screen.dart';
import 'games/arduino_simulator_screen.dart';
import 'games/pipes_game_screen.dart';
import 'games/color_coding_screen.dart';
import 'games/pattern_detective_game_screen.dart';
import 'games/variable_master_game_screen.dart';
import 'games/bug_hunter_game_screen.dart';
import 'games/robot_simulator_game_screen.dart';
import 'games/matching_game_screen.dart';
import 'games/millionaire_game_screen.dart';

class GamePlayScreen extends StatefulWidget {
  final GameModel game;

  const GamePlayScreen({Key? key, required this.game}) : super(key: key);

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  final GamesService _gamesService = GamesService();
  final AchievementService _achievementService = AchievementService();

  int _currentQuestionIndex = 0;
  int _score = 0;
  List<int?> _userAnswers = [];
  bool _showResults = false;
  DateTime? _startTime;
  bool _resultsSaved = false;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    if (widget.game.type == GameType.quiz) {
      final questions = widget.game.gameData['questions'] as List?;
      if (questions != null) {
        _userAnswers = List.filled(questions.length, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Route to specific game screens based on game type
    switch (widget.game.type) {
      case GameType.quiz:
        // "Bilgi Yarışması" artık "Kim Milyoner Olmak İster?" tarzı,
        // para ağacı + 50:50/telefon/seyirci jokerli özel ekranda oynanıyor
        // (eski _buildQuizGame() düz/basit ekranı artık kullanılmıyor).
        return const MillionaireGameScreen();
      case GameType.chess:
        return const ChessGameScreen();
      case GameType.coordinates:
        return const CoordinatesGameScreen();
      case GameType.blockCoding:
        return const BlockCodingGameScreen();
      case GameType.wordMatch:
        return WordMatchGameScreen(gameData: widget.game.gameData);
      case GameType.sequencing:
        return SequencingGameScreen(gameData: widget.game.gameData);
      case GameType.mazeExplorer:
        // Check if it's the 3D maze or regular maze
        if (widget.game.id == 'embedded_maze_3d') {
          return Maze3DGameScreen(gameData: widget.game.gameData);
        }
        return MazeExplorerGameScreen(gameData: widget.game.gameData);
      case GameType.leftRightCoding:
        return LeftRightCodingGameScreen(gameData: widget.game.gameData);
      case GameType.arduinoSimulator:
        return ArduinoSimulatorScreen(gameData: widget.game.gameData);
      case GameType.pipesPuzzle:
        return const PipesGameScreen();
      case GameType.colorCoding:
        return const ColorCodingScreen();
      case GameType.patternDetective:
        return const PatternDetectiveGameScreen();
      case GameType.variableMaster:
        return const VariableMasterGameScreen();
      case GameType.bugHunter:
        return const BugHunterGameScreen();
      case GameType.robotSimulator:
        return RobotSimulatorGameScreen(gameData: widget.game.gameData);
      case GameType.matchingGame:
        return MatchingGameScreen(gameData: widget.game.gameData);
      case GameType.puzzle:
      case GameType.simulation:
        return _buildComingSoon();
    }
  }

  Widget _buildQuizGame() {
    final questions = widget.game.gameData['questions'] as List? ?? [];

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.game.titleFor(_lang)),
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Bu oyun henüz hazırlanmamış.'),
        ),
      );
    }

    if (_showResults) {
      return _buildResultsScreen(questions);
    }

    final currentQuestion = questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.titleFor(_lang)),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            minHeight: 6,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soru ${_currentQuestionIndex + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentQuestion['question'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options
                  ...List.generate(
                    (currentQuestion['options'] as List).length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionButton(
                        currentQuestion['options'][index],
                        index,
                        currentQuestion['correctAnswer'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Önceki'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _userAnswers[_currentQuestionIndex] != null
                        ? () {
                            if (_currentQuestionIndex < questions.length - 1) {
                              setState(() {
                                _currentQuestionIndex++;
                              });
                            } else {
                              _finishQuiz(questions);
                            }
                          }
                        : null,
                    icon: Icon(
                      _currentQuestionIndex < questions.length - 1
                          ? Icons.arrow_forward
                          : Icons.check,
                    ),
                    label: Text(
                      _currentQuestionIndex < questions.length - 1
                          ? 'Sonraki'
                          : 'Bitir',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, int index, int correctAnswer) {
    final isSelected = _userAnswers[_currentQuestionIndex] == index;
    final isCorrect = index == correctAnswer;
    final userAnswer = _userAnswers[_currentQuestionIndex];

    // Determine colors based on answer state
    Color? backgroundColor;
    Color? borderColor;
    Color? circleColor;
    Color? textColor;
    IconData? icon;
    Color? iconColor;

    if (userAnswer != null) {
      // An answer has been selected
      if (isSelected) {
        // This is the selected answer
        if (isCorrect) {
          // Selected answer is correct - GREEN
          backgroundColor = Colors.green.withOpacity(0.1);
          borderColor = Colors.green;
          circleColor = Colors.green;
          textColor = Colors.green.shade900;
          icon = Icons.check_circle;
          iconColor = Colors.green;
        } else {
          // Selected answer is wrong - RED
          backgroundColor = Colors.red.withOpacity(0.1);
          borderColor = Colors.red;
          circleColor = Colors.red;
          textColor = Colors.red.shade900;
          icon = Icons.cancel;
          iconColor = Colors.red;
        }
      } else if (isCorrect) {
        // This is the correct answer (not selected) - GREEN
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        circleColor = Colors.green;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        iconColor = Colors.green;
      } else {
        // Neither selected nor correct - GREY
        backgroundColor = Colors.white;
        borderColor = Colors.grey.shade300;
        circleColor = Colors.transparent;
        textColor = Colors.grey.shade500;
      }
    } else {
      // No answer selected yet - Default blue for selected, grey for others
      if (isSelected) {
        backgroundColor = const Color(0xFF2196F3).withOpacity(0.1);
        borderColor = const Color(0xFF2196F3);
        circleColor = const Color(0xFF2196F3);
        textColor = const Color(0xFF2196F3);
        icon = Icons.check_circle;
        iconColor = const Color(0xFF2196F3);
      } else {
        backgroundColor = Colors.white;
        borderColor = Colors.grey.shade300;
        circleColor = Colors.transparent;
        textColor = Colors.black87;
      }
    }

    return InkWell(
      onTap: () {
        setState(() {
          _userAnswers[_currentQuestionIndex] = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor!,
            width: (isSelected || (userAnswer != null && isCorrect)) ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: circleColor,
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color: circleColor == Colors.transparent ? Colors.grey.shade600 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: (isSelected || (userAnswer != null && isCorrect)) ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (icon != null)
              Icon(
                icon,
                color: iconColor,
              ),
          ],
        ),
      ),
    );
  }

  void _finishQuiz(List questions) {
    // Calculate score
    _score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (_userAnswers[i] == questions[i]['correctAnswer']) {
        _score++;
      }
    }

    setState(() {
      _showResults = true;
    });

    // Save progress to Firebase
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null && _startTime != null) {
      final duration = DateTime.now().difference(_startTime!);
      final scorePercentage = (_score / _userAnswers.length) * 100;

      final progress = GameProgress(
        userId: user.id,
        gameId: widget.game.id,
        score: scorePercentage.round(),
        completed: true,
        timeSpentMinutes: duration.inMinutes,
        playedAt: DateTime.now(),
        progressData: {
          'correctAnswers': _score,
          'totalQuestions': _userAnswers.length,
        },
      );

      try {
        await _gamesService.saveGameProgress(progress);
      } catch (e) {
        // Silently fail in demo mode
      }
    }
  }

  /// Quiz sonuçlarını kaydet
  Future<void> _saveQuizResults(int correctAnswers, int totalQuestions) async {
    if (_resultsSaved) return; // Sadece bir kez kaydet

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.uid;

      if (userId == null) {
        debugPrint('❌ Kullanıcı girişi yapılmamış, sonuç kaydedilemedi');
        return;
      }

      final wrongAnswers = totalQuestions - correctAnswers;

      final duration = _startTime != null ? DateTime.now().difference(_startTime!).inSeconds : 0;
      final score = (correctAnswers / totalQuestions * 100).round();

      await _achievementService.saveGameResult(
        userId: userId,
        gameId: widget.game.id,
        score: score,
        duration: duration,
      );

      setState(() {
        _resultsSaved = true;
      });

      debugPrint('✅ Quiz sonucu kaydedildi: ${widget.game.title}');
    } catch (e) {
      debugPrint('❌ Quiz sonucu kaydetme hatası: $e');
    }
  }

  Widget _buildResultsScreen(List questions) {
    // Sonuçları kaydet (sadece bir kez)
    if (!_resultsSaved) {
      _saveQuizResults(_score, questions.length);
    }

    final percentage = (_score / questions.length) * 100;
    final isPassed = percentage >= 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonuçlar'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPassed
                        ? [const Color(0xFF4CAF50), const Color(0xFF388E3C)]
                        : [const Color(0xFFFF9800), const Color(0xFFF57C00)],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isPassed ? Icons.emoji_events : Icons.sentiment_satisfied,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPassed ? 'Tebrikler!' : 'İyi Çalışma!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_score / ${questions.length} Doğru',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '%${percentage.toStringAsFixed(0)} Başarı',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Ana Sayfa'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex = 0;
                        _score = 0;
                        _userAnswers = List.filled(questions.length, null);
                        _showResults = false;
                        _resultsSaved = false; // Reset sonuç kaydedilme durumu
                        _startTime = DateTime.now();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Oyna'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoon() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.titleFor(_lang)),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Çok Yakında!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.game.type.name} türündeki oyunlar\nşu anda geliştiriliyor.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
