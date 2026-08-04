import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
// TODO: Migrate to Supabase
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../../widgets/animated_rank_display.dart';
import '../../services/leaderboard_service.dart';
import '../../models/game_model.dart';
import '../../providers/settings_provider.dart';

/// Puppet types for character selection
enum PuppetType {
  fox,
  lion,
  crocodile,
  cat,
  dog,
}

extension PuppetTypeExtension on PuppetType {
  String get name {
    switch (this) {
      case PuppetType.fox:
        return 'Tilki';
      case PuppetType.lion:
        return 'Aslan';
      case PuppetType.crocodile:
        return 'Timsah';
      case PuppetType.cat:
        return 'Kedi';
      case PuppetType.dog:
        return 'Köpek';
    }
  }

  String get emoji {
    switch (this) {
      case PuppetType.fox:
        return '🦊';
      case PuppetType.lion:
        return '🦁';
      case PuppetType.crocodile:
        return '🐊';
      case PuppetType.cat:
        return '🐱';
      case PuppetType.dog:
        return '🐶';
    }
  }

  String nameFor(String languageCode) {
    if (languageCode != 'en') return name;
    switch (this) {
      case PuppetType.fox:
        return 'Fox';
      case PuppetType.lion:
        return 'Lion';
      case PuppetType.crocodile:
        return 'Crocodile';
      case PuppetType.cat:
        return 'Cat';
      case PuppetType.dog:
        return 'Dog';
    }
  }
}

/// Sağım-Solum Kodlama Oyunu (Flame 2D)
/// Wordwall tarzı hızlı tempolu oyun
class LeftRightCodingGameScreen extends StatefulWidget {
  final Map<String, dynamic>? gameData;

  const LeftRightCodingGameScreen({super.key, this.gameData});

  @override
  State<LeftRightCodingGameScreen> createState() => _LeftRightCodingGameScreenState();
}

class _LeftRightCodingGameScreenState extends State<LeftRightCodingGameScreen> {
  late LeftRightCodingGame _game;
  int _currentLevel = 1;
  int _totalScore = 0;
  int _moves = 0;
  DateTime? _startTime;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _showingQuestion = false;
  PuppetType? _selectedPuppet;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  @override
  void initState() {
    super.initState();
    // Show puppet selection dialog on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPuppetSelectionDialog();
    });
  }

  void _initializeGame() {
    _game = LeftRightCodingGame(
      onLevelComplete: _handleLevelComplete,
      onMove: _handleMove,
      onGameStart: _handleGameStart,
      onGameOver: _handleGameOver,
      onBonusSquare: _handleBonusSquare,
      onUnansweredQuestions: _handleUnansweredQuestions,
      puppetType: _selectedPuppet!,
      isEnglish: _isEn,
    );
  }

  void _handleGameOver() {
    setState(() {
      _gameOver = true;
    });
    _showGameOverDialog();
  }

  void _handleBonusSquare(Map<String, dynamic> question) {
    if (_showingQuestion) return;
    _showingQuestion = true;
    _showQuestionDialog(question);
  }

  void _handleUnansweredQuestions(int unansweredCount) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEn
              ? '⚠️ You reached the goal but $unansweredCount question(s) were not answered!\nAnswer the questions in the red flashing squares.'
              : '⚠️ Hedefe ulaştın ama $unansweredCount soru cevaplanmadı!\nKırmızı yanan karelerdeki soruları cevapla.',
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Future<void> _showPuppetSelectionDialog() async {
    final selectedPuppet = await showDialog<PuppetType>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _isEn ? '🎭 Choose a Character' : '🎭 Kukla Seç',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEn ? 'Choose the character you want to use in the game:' : 'Oyunda kullanmak istediğin kuklayı seç:',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: PuppetType.values.map((puppet) {
                return InkWell(
                  onTap: () => Navigator.pop(context, puppet),
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          puppet.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          puppet.nameFor(_lang),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );

    if (selectedPuppet != null) {
      setState(() {
        _selectedPuppet = selectedPuppet;
        _initializeGame();
      });
    } else {
      // If user somehow dismisses without selecting, default to fox
      setState(() {
        _selectedPuppet = PuppetType.fox;
        _initializeGame();
      });
    }
  }

  void _handleGameStart() {
    setState(() {
      _gameStarted = true;
      _startTime = DateTime.now();
    });
  }

  void _handleMove() {
    setState(() {
      _moves++;
    });
  }

  void _handleLevelComplete(int score, int level) {
    setState(() {
      _totalScore += score;
      _currentLevel = level + 1;
    });

    // Level tamamlandı mesajı
    if (level < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEn ? '🎉 Level $level Complete! +$score points' : '🎉 Level $level Tamamlandı! +$score puan'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Oyun bitti
      _showGameCompleteDialog();
    }
  }

  Future<void> _showQuestionDialog(Map<String, dynamic> questionData) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _QuestionDialogContent(
        questionData: questionData,
        onAnswerSelected: (isCorrect, points) {
          _handleAnswer(isCorrect, points);
        },
      ),
    );

    _showingQuestion = false;
  }

  void _handleAnswer(bool isCorrect, int points) {
    setState(() {
      if (isCorrect) {
        _totalScore += points;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEn ? '✅ Correct! +$points points' : '✅ Doğru! +$points puan'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _totalScore = (_totalScore - points).clamp(0, 999999);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEn ? '❌ Wrong! -$points points' : '❌ Yanlış! -$points puan'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _showGameOverDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_isEn ? '💥 You Hit an Obstacle!' : '💥 Engele Çarptın!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.dangerous, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _isEn ? 'Level: $_currentLevel' : 'Level: $_currentLevel',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_isEn ? 'Total Score: $_totalScore' : 'Toplam Skor: $_totalScore'),
            Text(_isEn ? 'Moves: $_moves' : 'Hamle: $_moves'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_isEn ? 'Home' : 'Ana Sayfa'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
            ),
            child: Text(_isEn ? 'Try Again' : 'Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Future<void> _showGameCompleteDialog() async {
    final duration = DateTime.now().difference(_startTime!).inSeconds;

    // Firebase'e kaydet
    await _saveScore();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_isEn ? '🏆 Game Complete!' : '🏆 Oyun Tamamlandı!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEn ? 'Total Score: $_totalScore' : 'Toplam Skor: $_totalScore',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_isEn ? 'Moves: $_moves' : 'Hamle: $_moves'),
            Text(_isEn ? 'Duration: $duration seconds' : 'Süre: $duration saniye'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_isEn ? 'Home' : 'Ana Sayfa'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _showRankDisplay();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            child: Text(_isEn ? 'View Ranking' : 'Sıralama Gör'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRankDisplay() async {
    try {
      // TODO: Migrate to Supabase
      // Replace FirebaseAuth with Supabase Auth
      /*
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get user rank from leaderboard
      final leaderboardService = LeaderboardService();
      final firestore = FirebaseFirestore.instance;

      // Get top scores
      final snapshot = await firestore
          .collection('left_right_scores')
          .orderBy('score', descending: true)
          .orderBy('duration', descending: false)
          .limit(100)
          .get();

      final scores = snapshot.docs;
      final userRank = scores.indexWhere((doc) => doc['userId'] == user.uid) + 1;

      if (mounted && userRank > 0) {
        // Show animated rank display
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AnimatedRankDisplay(
            rank: userRank,
            totalScore: _totalScore,
            userName: user.displayName ?? 'Oyuncu',
            isNewRecord: false,
            onClose: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        );
      }
      */

      // Placeholder - TODO: Implement with Supabase
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error showing rank: $e');
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showLoginRequiredDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.orange, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isEn ? 'Sign In to Continue' : 'Devam Etmek İçin Giriş Yapın',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              _isEn ? 'You completed the first 3 levels!' : 'İlk 3 seviyeyi tamamladınız!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isEn ? 'Total Score: $_totalScore' : 'Toplam Skor: $_totalScore',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              _isEn ? 'Sign in to continue and access all levels.' : 'Devam etmek ve tüm seviyelere erişmek için giriş yapın.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_isEn ? 'Home' : 'Ana Sayfa'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Sign out visitor
              final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
              await authProvider.signOut();

              if (!mounted) return;

              // Navigate to login screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.login),
            label: Text(_isEn ? 'Sign In' : 'Giriş Yap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveScore() async {
    try {
      // TODO: Migrate to Supabase
      // Replace Firestore with Supabase
      /*
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final duration = DateTime.now().difference(_startTime!).inSeconds;

        await FirebaseFirestore.instance.collection('left_right_scores').add({
          'userId': user.uid,
          'userName': user.displayName ?? 'Oyuncu',
          'score': _totalScore,
          'moves': _moves,
          'duration': duration,
          'levelsCompleted': _currentLevel - 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      */

      // Placeholder - TODO: Implement with Supabase
      debugPrint('Score save pending Supabase migration');
    } catch (e) {
      debugPrint('Error saving score: $e');
    }
  }

  void _resetGame() {
    setState(() {
      _currentLevel = 1;
      _totalScore = 0;
      _moves = 0;
      _startTime = DateTime.now();
      _gameStarted = true;
      _gameOver = false;
      _showingQuestion = false;
      _game = LeftRightCodingGame(
        onLevelComplete: _handleLevelComplete,
        onMove: _handleMove,
        onGameStart: _handleGameStart,
        onGameOver: _handleGameOver,
        onBonusSquare: _handleBonusSquare,
        onUnansweredQuestions: _handleUnansweredQuestions,
        puppetType: _selectedPuppet!,
        isEnglish: _isEn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while puppet is being selected
    if (_selectedPuppet == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEn ? 'Left-Right Coding' : 'Sağım-Solum',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_gameStarted)
                          Text(
                            _isEn
                                ? 'Level $_currentLevel • Score: $_totalScore • Moves: $_moves'
                                : 'Level $_currentLevel • Skor: $_totalScore • Hamle: $_moves',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Game Area
            Expanded(
              child: GameWidget(game: _game),
            ),

            // Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Up Button
                  _buildControlButton(
                    icon: Icons.arrow_upward,
                    label: _isEn ? 'UP' : 'YUKARI',
                    color: Colors.blue,
                    onPressed: () => _game.moveUp(),
                  ),
                  const SizedBox(height: 8),
                  // Left, Down, Right Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Left Button
                      _buildControlButton(
                        icon: Icons.arrow_back,
                        label: _isEn ? 'LEFT' : 'SOL',
                        color: Colors.orange,
                        onPressed: () => _game.moveLeft(),
                      ),
                      // Down Button
                      _buildControlButton(
                        icon: Icons.arrow_downward,
                        label: _isEn ? 'DOWN' : 'AŞAĞI',
                        color: Colors.red,
                        onPressed: () => _game.moveDown(),
                      ),
                      // Right Button
                      _buildControlButton(
                        icon: Icons.arrow_forward,
                        label: _isEn ? 'RIGHT' : 'SAĞ',
                        color: Colors.green,
                        onPressed: () => _game.moveRight(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Question Dialog Widget with answer feedback
class _QuestionDialogContent extends StatefulWidget {
  final Map<String, dynamic> questionData;
  final Function(bool isCorrect, int points) onAnswerSelected;

  const _QuestionDialogContent({
    required this.questionData,
    required this.onAnswerSelected,
  });

  @override
  State<_QuestionDialogContent> createState() => _QuestionDialogContentState();
}

class _QuestionDialogContentState extends State<_QuestionDialogContent> {
  int? _selectedAnswerIndex;
  bool _answered = false;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  Future<void> _selectAnswer(int index) async {
    if (_answered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _answered = true;
    });

    // Wait for user to see the result
    await Future.delayed(const Duration(milliseconds: 1500));

    // Notify parent and close dialog
    final isCorrect = index == widget.questionData['correctAnswer'];
    widget.onAnswerSelected(isCorrect, widget.questionData['points']);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Color _getButtonColor(int index) {
    if (!_answered) {
      return Colors.white;
    }

    final correctAnswer = widget.questionData['correctAnswer'];

    // If this is the selected answer
    if (index == _selectedAnswerIndex) {
      return index == correctAnswer ? Colors.green.shade100 : Colors.red.shade100;
    }

    // If this is the correct answer and user selected wrong
    if (index == correctAnswer && _selectedAnswerIndex != correctAnswer) {
      return Colors.green.shade100;
    }

    return Colors.white;
  }

  Color _getBorderColor(int index) {
    if (!_answered) {
      return Colors.purple.shade200;
    }

    final correctAnswer = widget.questionData['correctAnswer'];

    // If this is the selected answer
    if (index == _selectedAnswerIndex) {
      return index == correctAnswer ? Colors.green.shade700 : Colors.red.shade700;
    }

    // If this is the correct answer and user selected wrong
    if (index == correctAnswer && _selectedAnswerIndex != correctAnswer) {
      return Colors.green.shade700;
    }

    return Colors.purple.shade200;
  }

  IconData? _getIcon(int index) {
    if (!_answered) return null;

    final correctAnswer = widget.questionData['correctAnswer'];

    // If this is the selected answer
    if (index == _selectedAnswerIndex) {
      return index == correctAnswer ? Icons.check_circle : Icons.cancel;
    }

    // If this is the correct answer and user selected wrong
    if (index == correctAnswer && _selectedAnswerIndex != correctAnswer) {
      return Icons.check_circle;
    }

    return null;
  }

  Color? _getIconColor(int index) {
    if (!_answered) return null;

    final correctAnswer = widget.questionData['correctAnswer'];

    // If this is the selected answer
    if (index == _selectedAnswerIndex) {
      return index == correctAnswer ? Colors.green.shade700 : Colors.red.shade700;
    }

    // If this is the correct answer and user selected wrong
    if (index == correctAnswer && _selectedAnswerIndex != correctAnswer) {
      return Colors.green.shade700;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.help_outline, color: Colors.purple.shade700, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isEn ? 'Bonus Question!' : 'Bonus Soru!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.questionData['question'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(widget.questionData['options'].length, (index) {
            final icon = _getIcon(index);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: _answered ? null : () => _selectAnswer(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(index),
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: _getBorderColor(index), width: 2),
                  padding: const EdgeInsets.all(16),
                  disabledBackgroundColor: _getButtonColor(index),
                  disabledForegroundColor: Colors.black87,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _answered
                          ? _getButtonColor(index)
                          : Colors.purple.shade100,
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _answered
                              ? _getBorderColor(index)
                              : Colors.purple.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.questionData['options'][index],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, color: _getIconColor(index), size: 24),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Scratch Question Bank organized by difficulty
class ScratchQuestions {
  static List<Map<String, dynamic>> getQuestionsByDifficulty(int difficulty, {bool isEnglish = false}) {
    final allQuestions = [
      // Easy Questions (Difficulty 1)
      {
        'question': 'Bir karakteri hareket ettirmek için hangi blok kullanılır?',
        'questionEn': 'Which block is used to move a character?',
        'options': ['Adım At', 'Döndür', 'Bekle', 'Ses Çıkar'],
        'optionsEn': ['Move Steps', 'Turn', 'Wait', 'Play Sound'],
        'correctAnswer': 0,
        'points': 50,
        'difficulty': 1,
      },
      {
        'question': 'Yeşil bayrak neyi başlatır?',
        'questionEn': 'What does the green flag start?',
        'options': ['Programı', 'Oyunu', 'Projeyi', 'Hepsini'],
        'optionsEn': ['The program', 'The game', 'The project', 'All of them'],
        'correctAnswer': 3,
        'points': 50,
        'difficulty': 1,
      },
      {
        'question': 'Ekrandaki karaktere ne denir?',
        'questionEn': 'What is the character on the screen called?',
        'options': ['Kukla', 'Kutu', 'Şekil', 'Figür'],
        'optionsEn': ['Sprite', 'Box', 'Shape', 'Figure'],
        'correctAnswer': 0,
        'points': 50,
        'difficulty': 1,
      },
      {
        'question': 'Sahneye arka plan eklemek için ne kullanılır?',
        'questionEn': 'What is used to add a background to the stage?',
        'options': ['Fon', 'Arkaplan', 'Kukla', 'Kostüm'],
        'optionsEn': ['Backdrop', 'Background', 'Sprite', 'Costume'],
        'correctAnswer': 0,
        'points': 50,
        'difficulty': 1,
      },

      // Medium Questions (Difficulty 2)
      {
        'question': 'Bir işlemi 10 kez tekrarlamak için hangi blok kullanılır?',
        'questionEn': 'Which block is used to repeat an action 10 times?',
        'options': ['Sürekli Tekrarla', '10 Kez Tekrarla', 'Eğer Koşul', 'Bekle'],
        'optionsEn': ['Forever', 'Repeat 10 Times', 'If Condition', 'Wait'],
        'correctAnswer': 1,
        'points': 75,
        'difficulty': 2,
      },
      {
        'question': 'Değişken oluşturmak ne işe yarar?',
        'questionEn': 'What is a variable used for?',
        'options': ['Veri saklamak', 'Ses eklemek', 'Renk değiştirmek', 'Döndürmek'],
        'optionsEn': ['Storing data', 'Adding sound', 'Changing color', 'Turning'],
        'correctAnswer': 0,
        'points': 75,
        'difficulty': 2,
      },
      {
        'question': 'Koşullu ifade için hangi blok kullanılır?',
        'questionEn': 'Which block is used for a conditional statement?',
        'options': ['Eğer-O zaman', 'Tekrarla', 'Bekle', 'Gönder'],
        'optionsEn': ['If-Then', 'Repeat', 'Wait', 'Broadcast'],
        'correctAnswer': 0,
        'points': 75,
        'difficulty': 2,
      },
      {
        'question': 'İki kukla arasında mesaj göndermek için ne kullanılır?',
        'questionEn': 'What is used to send a message between two sprites?',
        'options': ['Mesaj Gönder', 'Konuş', 'Ses Çal', 'Değişken'],
        'optionsEn': ['Broadcast', 'Say', 'Play Sound', 'Variable'],
        'correctAnswer': 0,
        'points': 75,
        'difficulty': 2,
      },

      // Hard Questions (Difficulty 3)
      {
        'question': 'Klon oluşturmak ne işe yarar?',
        'questionEn': 'What does creating a clone do?',
        'options': ['Kukla kopyası yaratır', 'Proje kaydeder', 'Ses kopyalar', 'Renk değiştirir'],
        'optionsEn': ['Creates a copy of the sprite', 'Saves the project', 'Copies a sound', 'Changes the color'],
        'correctAnswer': 0,
        'points': 100,
        'difficulty': 3,
      },
      {
        'question': 'Sürekli tekrarla bloğunun içindeki kodlar ne zaman durur?',
        'questionEn': 'When does the code inside a forever block stop?',
        'options': ['Program durdurulunca', '10 saniye sonra', 'Otomatik durur', 'Asla çalışmaz'],
        'optionsEn': ['When the program is stopped', 'After 10 seconds', 'It stops automatically', 'It never runs'],
        'correctAnswer': 0,
        'points': 100,
        'difficulty': 3,
      },
      {
        'question': 'Algılayıcı blokları ne yapar?',
        'questionEn': 'What do sensing blocks do?',
        'options': ['Çevreden veri alır', 'Ses çalar', 'Renk değiştirir', 'Hareket ettirir'],
        'optionsEn': ['Get data from the environment', 'Play sound', 'Change color', 'Move'],
        'correctAnswer': 0,
        'points': 100,
        'difficulty': 3,
      },
      {
        'question': 'İşlemci blokları hangi kategoridedir?',
        'questionEn': 'What category do operator blocks belong to?',
        'options': ['Matematiksel işlemler', 'Hareket', 'Görünüm', 'Ses'],
        'optionsEn': ['Mathematical operations', 'Motion', 'Looks', 'Sound'],
        'correctAnswer': 0,
        'points': 100,
        'difficulty': 3,
      },
    ];

    final filtered = allQuestions.where((q) => q['difficulty'] == difficulty).toList();
    if (!isEnglish) return filtered;

    return filtered.map((q) {
      final copy = Map<String, dynamic>.from(q);
      if (copy['questionEn'] != null) copy['question'] = copy['questionEn'];
      if (copy['optionsEn'] != null) copy['options'] = copy['optionsEn'];
      return copy;
    }).toList();
  }
}

/// Flame Game Engine
class LeftRightCodingGame extends FlameGame {
  final Function(int score, int level) onLevelComplete;
  final VoidCallback onMove;
  final VoidCallback onGameStart;
  final VoidCallback onGameOver;
  final Function(Map<String, dynamic>) onBonusSquare;
  final Function(int unansweredCount) onUnansweredQuestions;
  final PuppetType puppetType;
  final bool isEnglish;

  late RobotPlayer robot;
  late TargetStar target;
  late GridBackground grid;
  List<Obstacle> obstacles = [];
  List<BonusSquare> bonusSquares = [];
  Set<String> answeredBonusSquares = {}; // Track answered bonus squares
  Set<String> _usedQuestions = {}; // Track used questions to avoid repetition

  int currentLevel = 1;
  int gridSize = 5;
  bool _gameStarted = false;
  bool _gameOver = false;

  LeftRightCodingGame({
    required this.onLevelComplete,
    required this.onMove,
    required this.onGameStart,
    required this.onGameOver,
    required this.onBonusSquare,
    required this.onUnansweredQuestions,
    required this.puppetType,
    this.isEnglish = false,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background
    grid = GridBackground(gridSize: gridSize);
    add(grid);

    // Start game
    _startLevel();
  }

  void _startLevel() {
    if (!_gameStarted) {
      _gameStarted = true;
      onGameStart();
    }

    _gameOver = false;

    // Remove old components
    removeWhere((component) =>
      component is RobotPlayer ||
      component is TargetStar ||
      component is Obstacle ||
      component is BonusSquare
    );
    obstacles.clear();
    bonusSquares.clear();
    answeredBonusSquares.clear();
    _usedQuestions.clear(); // Reset used questions for new level

    // Increase difficulty
    if (currentLevel > 3 && currentLevel <= 6) {
      gridSize = 7;
    } else if (currentLevel > 6) {
      gridSize = 9;
    }

    grid.gridSize = gridSize;

    // Random robot position (left side)
    final robotX = 0;
    final robotY = (gridSize / 2).floor();

    // Random target position (right side)
    final targetX = gridSize - 1;
    final targetY = (gridSize / 2).floor();

    // Add robot
    robot = RobotPlayer(
      gridX: robotX,
      gridY: robotY,
      gridSize: gridSize,
      puppetType: puppetType,
    );
    add(robot);

    // Add target
    target = TargetStar(
      gridX: targetX,
      gridY: targetY,
      gridSize: gridSize,
    );
    add(target);

    final random = Random();

    // Add obstacles (increase with level)
    final obstacleCount = (currentLevel * 2).clamp(2, gridSize * 2);
    int addedObstacles = 0;

    while (addedObstacles < obstacleCount) {
      final obsX = random.nextInt(gridSize);
      final obsY = random.nextInt(gridSize);

      // Don't place obstacles on robot, target, or already occupied positions
      final isRobotPos = (obsX == robotX && obsY == robotY);
      final isTargetPos = (obsX == targetX && obsY == targetY);
      final isOccupied = obstacles.any((obs) => obs.gridX == obsX && obs.gridY == obsY);

      if (!isRobotPos && !isTargetPos && !isOccupied) {
        final obstacle = Obstacle(
          gridX: obsX,
          gridY: obsY,
          gridSize: gridSize,
          type: random.nextInt(3), // 0: rock, 1: bug, 2: spike
        );
        obstacles.add(obstacle);
        add(obstacle);
        addedObstacles++;
      }
    }

    // Add bonus squares (1-2 per level based on difficulty)
    final bonusCount = currentLevel <= 3 ? 1 : 2;
    int addedBonus = 0;

    // Determine question difficulty based on level
    int questionDifficulty = 1;
    if (currentLevel >= 4 && currentLevel <= 7) {
      questionDifficulty = 2;
    } else if (currentLevel >= 8) {
      questionDifficulty = 3;
    }

    while (addedBonus < bonusCount) {
      final bonusX = random.nextInt(gridSize);
      final bonusY = random.nextInt(gridSize);

      // Don't place bonus squares on robot, target, obstacles, or already occupied positions
      final isRobotPos = (bonusX == robotX && bonusY == robotY);
      final isTargetPos = (bonusX == targetX && bonusY == targetY);
      final isObstaclePos = obstacles.any((obs) => obs.gridX == bonusX && obs.gridY == bonusY);
      final isBonusOccupied = bonusSquares.any((bonus) => bonus.gridX == bonusX && bonus.gridY == bonusY);

      if (!isRobotPos && !isTargetPos && !isObstaclePos && !isBonusOccupied) {
        // Get a random question of appropriate difficulty
        final availableQuestions = ScratchQuestions.getQuestionsByDifficulty(questionDifficulty, isEnglish: isEnglish);
        if (availableQuestions.isNotEmpty) {
          // Filter out already used questions
          final unusedQuestions = availableQuestions.where((q) =>
            !_usedQuestions.contains(q['question'])
          ).toList();

          // If all questions used, reset the used questions set
          final questionsToUse = unusedQuestions.isNotEmpty ? unusedQuestions : availableQuestions;
          if (unusedQuestions.isEmpty) {
            _usedQuestions.clear();
          }

          final question = questionsToUse[random.nextInt(questionsToUse.length)];

          // Mark this question as used
          _usedQuestions.add(question['question']);

          final bonusSquare = BonusSquare(
            gridX: bonusX,
            gridY: bonusY,
            gridSize: gridSize,
            questionData: question,
          );
          bonusSquares.add(bonusSquare);
          add(bonusSquare);
          addedBonus++;
        }
      }
    }
  }

  void moveLeft() {
    if (_gameOver) return;
    if (robot.gridY > 0) {
      final newX = robot.gridX;
      final newY = robot.gridY - 1;
      robot.moveTo(newX, newY);
      onMove();
      _checkCollision();
      if (!_gameOver) {
        _checkBonusSquare();
        _checkWin();
      }
    }
  }

  void moveRight() {
    if (_gameOver) return;
    if (robot.gridY < gridSize - 1) {
      final newX = robot.gridX;
      final newY = robot.gridY + 1;
      robot.moveTo(newX, newY);
      onMove();
      _checkCollision();
      if (!_gameOver) {
        _checkBonusSquare();
        _checkWin();
      }
    }
  }

  void moveUp() {
    if (_gameOver) return;
    if (robot.gridX > 0) {
      final newX = robot.gridX - 1;
      final newY = robot.gridY;
      robot.moveTo(newX, newY);
      onMove();
      _checkCollision();
      if (!_gameOver) {
        _checkBonusSquare();
        _checkWin();
      }
    }
  }

  void moveDown() {
    if (_gameOver) return;
    if (robot.gridX < gridSize - 1) {
      final newX = robot.gridX + 1;
      final newY = robot.gridY;
      robot.moveTo(newX, newY);
      onMove();
      _checkCollision();
      if (!_gameOver) {
        _checkBonusSquare();
        _checkWin();
      }
    }
  }

  void _checkCollision() {
    for (final obstacle in obstacles) {
      if (robot.gridX == obstacle.gridX && robot.gridY == obstacle.gridY) {
        _gameOver = true;
        onGameOver();
        return;
      }
    }
  }

  void _checkBonusSquare() {
    for (final bonusSquare in bonusSquares) {
      if (robot.gridX == bonusSquare.gridX && robot.gridY == bonusSquare.gridY) {
        final squareId = '${bonusSquare.gridX}_${bonusSquare.gridY}';
        // Only trigger question if not already answered
        if (!answeredBonusSquares.contains(squareId)) {
          answeredBonusSquares.add(squareId);
          bonusSquare.markAsAnswered();
          onBonusSquare(bonusSquare.questionData);
        }
        return;
      }
    }
  }

  void _checkWin() {
    if (robot.gridX == target.gridX && robot.gridY == target.gridY) {
      // Check if all bonus squares are answered
      final totalBonusSquares = bonusSquares.length;
      final answeredCount = answeredBonusSquares.length;

      if (answeredCount < totalBonusSquares) {
        // Not all questions answered - highlight unanswered squares in red
        for (final bonusSquare in bonusSquares) {
          final squareId = '${bonusSquare.gridX}_${bonusSquare.gridY}';
          if (!answeredBonusSquares.contains(squareId)) {
            bonusSquare.highlightRed();
          }
        }
        // Show warning message
        onUnansweredQuestions(totalBonusSquares - answeredCount);
        return; // Don't complete level
      }

      // All questions answered - Level complete!
      final score = _calculateScore();
      onLevelComplete(score, currentLevel);

      currentLevel++;

      if (currentLevel <= 10) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _startLevel();
        });
      }
    }
  }

  int _calculateScore() {
    // Base score + level bonus
    return 100 + (currentLevel * 50);
  }
}

/// Grid Background Component
class GridBackground extends PositionComponent with HasGameRef<LeftRightCodingGame> {
  int gridSize;

  GridBackground({required this.gridSize});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2.zero();
    size = gameRef.size;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final cellWidth = size.x / gridSize;
    final cellHeight = size.y / gridSize;

    // Draw grid lines
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    for (int i = 0; i <= gridSize; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.y),
        paint,
      );

      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.x, i * cellHeight),
        paint,
      );
    }

    // Draw checkerboard pattern
    final lightPaint = Paint()..color = Colors.blue.shade50;
    final darkPaint = Paint()..color = Colors.blue.shade100;

    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final isLight = (x + y) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(
            y * cellWidth,
            x * cellHeight,
            cellWidth,
            cellHeight,
          ),
          isLight ? lightPaint : darkPaint,
        );
      }
    }
  }
}

/// Robot Player Component
class RobotPlayer extends PositionComponent with HasGameRef<LeftRightCodingGame> {
  int gridX;
  int gridY;
  int gridSize;
  final PuppetType puppetType;

  RobotPlayer({
    required this.gridX,
    required this.gridY,
    required this.gridSize,
    required this.puppetType,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updatePosition();
  }

  void moveTo(int newX, int newY) {
    gridX = newX;
    gridY = newY;
    _updatePosition();
  }

  void _updatePosition() {
    final cellWidth = gameRef.size.x / gridSize;
    final cellHeight = gameRef.size.y / gridSize;

    position = Vector2(
      gridY * cellWidth + cellWidth / 2,
      gridX * cellHeight + cellHeight / 2,
    );

    size = Vector2(cellWidth * 0.6, cellHeight * 0.6);
    anchor = Anchor.center;
  }

  Color _getPuppetColor() {
    switch (puppetType) {
      case PuppetType.fox:
        return Colors.orange.shade700;
      case PuppetType.lion:
        return Colors.amber.shade700;
      case PuppetType.crocodile:
        return Colors.green.shade700;
      case PuppetType.cat:
        return Colors.grey.shade700;
      case PuppetType.dog:
        return Colors.brown.shade700;
    }
  }

  Color _getSecondaryColor() {
    switch (puppetType) {
      case PuppetType.fox:
        return Colors.orange.shade300;
      case PuppetType.lion:
        return Colors.amber.shade300;
      case PuppetType.crocodile:
        return Colors.green.shade300;
      case PuppetType.cat:
        return Colors.grey.shade300;
      case PuppetType.dog:
        return Colors.brown.shade300;
    }
  }

  @override
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = size / 2;
    final primaryColor = _getPuppetColor();
    final secondaryColor = _getSecondaryColor();

    // Shadow for all puppets
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(center.x, center.y + size.y * 0.45), size.x * 0.35, shadowPaint);

    // Draw based on puppet type with unique features
    switch (puppetType) {
      case PuppetType.fox:
        _drawEnhancedFox(canvas, center, primaryColor, secondaryColor);
        break;
      case PuppetType.lion:
        _drawEnhancedLion(canvas, center, primaryColor, secondaryColor);
        break;
      case PuppetType.crocodile:
        _drawEnhancedCrocodile(canvas, center, primaryColor, secondaryColor);
        break;
      case PuppetType.cat:
        _drawEnhancedCat(canvas, center, primaryColor, secondaryColor);
        break;
      case PuppetType.dog:
        _drawEnhancedDog(canvas, center, primaryColor, secondaryColor);
        break;
    }
  }

  void _drawEnhancedFox(Canvas canvas, Vector2 center, Color primaryColor, Color secondaryColor) {
    final bodyPaint = Paint()..color = primaryColor;
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;

    // Body with white chest
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.05), width: size.x * 0.7, height: size.y * 0.75), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.15), width: size.x * 0.45, height: size.y * 0.55), whitePaint);

    // Head
    canvas.drawCircle(Offset(center.x, center.y - size.y * 0.15), size.x * 0.35, bodyPaint);

    // Pointed ears with white inner
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.25, center.y - size.y * 0.35)..lineTo(center.x - size.x * 0.15, center.y - size.y * 0.5)..lineTo(center.x - size.x * 0.05, center.y - size.y * 0.35)..close(), bodyPaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.25, center.y - size.y * 0.35)..lineTo(center.x + size.x * 0.15, center.y - size.y * 0.5)..lineTo(center.x + size.x * 0.05, center.y - size.y * 0.35)..close(), bodyPaint);
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.22, center.y - size.y * 0.36)..lineTo(center.x - size.x * 0.15, center.y - size.y * 0.45)..lineTo(center.x - size.x * 0.08, center.y - size.y * 0.36)..close(), whitePaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.22, center.y - size.y * 0.36)..lineTo(center.x + size.x * 0.15, center.y - size.y * 0.45)..lineTo(center.x + size.x * 0.08, center.y - size.y * 0.36)..close(), whitePaint);

    // Snout
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.05), width: size.x * 0.25, height: size.y * 0.2), whitePaint);

    // Eyes with highlight
    canvas.drawCircle(Offset(center.x - size.x * 0.15, center.y - size.y * 0.2), size.x * 0.08, whitePaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.15, center.y - size.y * 0.2), size.x * 0.045, blackPaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.13, center.y - size.y * 0.22), size.x * 0.02, whitePaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.15, center.y - size.y * 0.2), size.x * 0.08, whitePaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.15, center.y - size.y * 0.2), size.x * 0.045, blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.17, center.y - size.y * 0.22), size.x * 0.02, whitePaint);

    // Nose & smile
    canvas.drawPath(Path()..moveTo(center.x, center.y - size.y * 0.02)..lineTo(center.x - size.x * 0.04, center.y + size.y * 0.02)..lineTo(center.x + size.x * 0.04, center.y + size.y * 0.02)..close(), blackPaint);
    final smilePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(Path()..moveTo(center.x, center.y + size.y * 0.02)..lineTo(center.x, center.y + size.y * 0.05), smilePaint);
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.1, center.y + size.y * 0.05)..quadraticBezierTo(center.x, center.y + size.y * 0.1, center.x + size.x * 0.1, center.y + size.y * 0.05), smilePaint);
  }

  void _drawEnhancedLion(Canvas canvas, Vector2 center, Color primaryColor, Color secondaryColor) {
    final bodyPaint = Paint()..color = primaryColor;
    final blackPaint = Paint()..color = Colors.black;
    final whitePaint = Paint()..color = Colors.white;

    // Majestic double-layer mane
    final maneOuter = Paint()..color = Colors.orange.shade900;
    final maneInner = Paint()..color = Colors.orange.shade700;
    for (int i = 0; i < 16; i++) {
      final angle = (i * 2 * 3.14159 / 16);
      canvas.drawCircle(Offset(center.x + cos(angle) * size.x * 0.42, center.y - size.y * 0.1 + sin(angle) * size.y * 0.42), size.x * 0.13, maneOuter);
    }
    for (int i = 0; i < 16; i++) {
      final angle = (i * 2 * 3.14159 / 16) + 0.2;
      canvas.drawCircle(Offset(center.x + cos(angle) * size.x * 0.35, center.y - size.y * 0.1 + sin(angle) * size.y * 0.35), size.x * 0.11, maneInner);
    }

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.1), width: size.x * 0.65, height: size.y * 0.7), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.18), width: size.x * 0.4, height: size.y * 0.5), Paint()..color = secondaryColor);

    // Head & muzzle
    canvas.drawCircle(Offset(center.x, center.y - size.y * 0.1), size.x * 0.32, bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y), width: size.x * 0.35, height: size.y * 0.25), Paint()..color = secondaryColor);

    // Eyes with highlights
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.13, center.y - size.y * 0.15), width: size.x * 0.12, height: size.y * 0.1), whitePaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.13, center.y - size.y * 0.15), size.x * 0.05, blackPaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.11, center.y - size.y * 0.17), size.x * 0.02, whitePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.13, center.y - size.y * 0.15), width: size.x * 0.12, height: size.y * 0.1), whitePaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.13, center.y - size.y * 0.15), size.x * 0.05, blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.15, center.y - size.y * 0.17), size.x * 0.02, whitePaint);

    // Nose with nostrils
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.02), width: size.x * 0.12, height: size.y * 0.08), Paint()..color = Colors.brown.shade900);
    canvas.drawCircle(Offset(center.x - size.x * 0.03, center.y + size.y * 0.02), size.x * 0.015, blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.03, center.y + size.y * 0.02), size.x * 0.015, blackPaint);

    // Confident smile
    final smilePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.12, center.y + size.y * 0.08)..quadraticBezierTo(center.x, center.y + size.y * 0.15, center.x + size.x * 0.12, center.y + size.y * 0.08), smilePaint);
  }

  void _drawEnhancedCrocodile(Canvas canvas, Vector2 center, Color primaryColor, Color secondaryColor) {
    final bodyPaint = Paint()..color = primaryColor;
    final blackPaint = Paint()..color = Colors.black;

    // Body with scale texture
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.1), width: size.x * 0.75, height: size.y * 0.7), Radius.circular(size.x * 0.15)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.15), width: size.x * 0.45, height: size.y * 0.55), Radius.circular(size.x * 0.1)), Paint()..color = secondaryColor);

    // Scale lines
    final scalePaint = Paint()..color = primaryColor.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      final y = center.y - size.y * 0.05 + i * size.y * 0.12;
      canvas.drawLine(Offset(center.x - size.x * 0.18, y), Offset(center.x + size.x * 0.18, y), scalePaint);
    }

    // Head & long snout
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.1), width: size.x * 0.55, height: size.y * 0.35), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.25), width: size.x * 0.4, height: size.y * 0.18), Radius.circular(size.x * 0.05)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.23), width: size.x * 0.35, height: size.y * 0.12), Radius.circular(size.x * 0.04)), Paint()..color = secondaryColor);

    // Sharp teeth
    final toothPaint = Paint()..color = Colors.white;
    for (int i = -2; i <= 2; i++) {
      canvas.drawPath(Path()..moveTo(center.x + i * size.x * 0.08, center.y - size.y * 0.3)..lineTo(center.x + i * size.x * 0.08 - size.x * 0.02, center.y - size.y * 0.26)..lineTo(center.x + i * size.x * 0.08 + size.x * 0.02, center.y - size.y * 0.26)..close(), toothPaint);
    }

    // Reptilian eyes
    final eyeBase = Paint()..color = Colors.yellow.shade700;
    canvas.drawCircle(Offset(center.x - size.x * 0.15, center.y - size.y * 0.15), size.x * 0.09, eyeBase);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.15, center.y - size.y * 0.15), width: size.x * 0.03, height: size.y * 0.08), blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.15, center.y - size.y * 0.15), size.x * 0.09, eyeBase);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.15, center.y - size.y * 0.15), width: size.x * 0.03, height: size.y * 0.08), blackPaint);

    // Fierce eye ridges
    final ridgePaint = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.22, center.y - size.y * 0.18)..lineTo(center.x - size.x * 0.08, center.y - size.y * 0.18), ridgePaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.22, center.y - size.y * 0.18)..lineTo(center.x + size.x * 0.08, center.y - size.y * 0.18), ridgePaint);

    // Nostrils
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.1, center.y - size.y * 0.3), width: size.x * 0.03, height: size.y * 0.02), blackPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.1, center.y - size.y * 0.3), width: size.x * 0.03, height: size.y * 0.02), blackPaint);
  }

  void _drawEnhancedCat(Canvas canvas, Vector2 center, Color primaryColor, Color secondaryColor) {
    final bodyPaint = Paint()..color = primaryColor;
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;

    // Curled tail
    final tailPaint = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = size.x * 0.08..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.25, center.y + size.y * 0.3)..quadraticBezierTo(center.x - size.x * 0.4, center.y + size.y * 0.15, center.x - size.x * 0.35, center.y - size.y * 0.05), tailPaint);

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.05), width: size.x * 0.65, height: size.y * 0.75), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.12), width: size.x * 0.4, height: size.y * 0.55), Paint()..color = secondaryColor);

    // Head
    canvas.drawCircle(Offset(center.x, center.y - size.y * 0.15), size.x * 0.35, bodyPaint);

    // Triangular ears with pink inner
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.28, center.y - size.y * 0.32)..lineTo(center.x - size.x * 0.15, center.y - size.y * 0.48)..lineTo(center.x - size.x * 0.02, center.y - size.y * 0.32)..close(), bodyPaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.28, center.y - size.y * 0.32)..lineTo(center.x + size.x * 0.15, center.y - size.y * 0.48)..lineTo(center.x + size.x * 0.02, center.y - size.y * 0.32)..close(), bodyPaint);
    final pinkPaint = Paint()..color = Colors.pink.shade200;
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.24, center.y - size.y * 0.33)..lineTo(center.x - size.x * 0.15, center.y - size.y * 0.43)..lineTo(center.x - size.x * 0.06, center.y - size.y * 0.33)..close(), pinkPaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.24, center.y - size.y * 0.33)..lineTo(center.x + size.x * 0.15, center.y - size.y * 0.43)..lineTo(center.x + size.x * 0.06, center.y - size.y * 0.33)..close(), pinkPaint);

    // Fluffy cheeks
    canvas.drawCircle(Offset(center.x - size.x * 0.22, center.y - size.y * 0.08), size.x * 0.15, Paint()..color = secondaryColor);
    canvas.drawCircle(Offset(center.x + size.x * 0.22, center.y - size.y * 0.08), size.x * 0.15, Paint()..color = secondaryColor);

    // Big anime eyes
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.13, center.y - size.y * 0.18), width: size.x * 0.13, height: size.y * 0.15), whitePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.13, center.y - size.y * 0.17), width: size.x * 0.06, height: size.y * 0.1), blackPaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.11, center.y - size.y * 0.2), size.x * 0.025, whitePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.13, center.y - size.y * 0.18), width: size.x * 0.13, height: size.y * 0.15), whitePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.13, center.y - size.y * 0.17), width: size.x * 0.06, height: size.y * 0.1), blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.15, center.y - size.y * 0.2), size.x * 0.025, whitePaint);

    // Pink nose
    canvas.drawPath(Path()..moveTo(center.x, center.y - size.y * 0.05)..lineTo(center.x - size.x * 0.03, center.y - size.y * 0.08)..lineTo(center.x + size.x * 0.03, center.y - size.y * 0.08)..close(), Paint()..color = Colors.pink.shade300);

    // Whiskers
    final whiskerPaint = Paint()..color = Colors.black.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawLine(Offset(center.x - size.x * 0.22, center.y - size.y * 0.08), Offset(center.x - size.x * 0.38, center.y - size.y * 0.12), whiskerPaint);
    canvas.drawLine(Offset(center.x - size.x * 0.22, center.y - size.y * 0.05), Offset(center.x - size.x * 0.4, center.y - size.y * 0.05), whiskerPaint);
    canvas.drawLine(Offset(center.x - size.x * 0.22, center.y - size.y * 0.02), Offset(center.x - size.x * 0.38, center.y + size.y * 0.02), whiskerPaint);
    canvas.drawLine(Offset(center.x + size.x * 0.22, center.y - size.y * 0.08), Offset(center.x + size.x * 0.38, center.y - size.y * 0.12), whiskerPaint);
    canvas.drawLine(Offset(center.x + size.x * 0.22, center.y - size.y * 0.05), Offset(center.x + size.x * 0.4, center.y - size.y * 0.05), whiskerPaint);
    canvas.drawLine(Offset(center.x + size.x * 0.22, center.y - size.y * 0.02), Offset(center.x + size.x * 0.38, center.y + size.y * 0.02), whiskerPaint);

    // Cute smile
    final smilePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(Path()..moveTo(center.x, center.y - size.y * 0.05)..lineTo(center.x, center.y - size.y * 0.01), smilePaint);
    canvas.drawPath(Path()..moveTo(center.x, center.y - size.y * 0.01)..quadraticBezierTo(center.x - size.x * 0.05, center.y + size.y * 0.02, center.x - size.x * 0.08, center.y + size.y * 0.01), smilePaint);
    canvas.drawPath(Path()..moveTo(center.x, center.y - size.y * 0.01)..quadraticBezierTo(center.x + size.x * 0.05, center.y + size.y * 0.02, center.x + size.x * 0.08, center.y + size.y * 0.01), smilePaint);
  }

  void _drawEnhancedDog(Canvas canvas, Vector2 center, Color primaryColor, Color secondaryColor) {
    final bodyPaint = Paint()..color = primaryColor;
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;

    // Wagging tail
    final tailPaint = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = size.x * 0.1..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.28, center.y + size.y * 0.25)..quadraticBezierTo(center.x - size.x * 0.45, center.y + size.y * 0.1, center.x - size.x * 0.35, center.y - size.y * 0.1), tailPaint);

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.05), width: size.x * 0.7, height: size.y * 0.75), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.15), width: size.x * 0.45, height: size.y * 0.6), Paint()..color = secondaryColor);

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.12), width: size.x * 0.55, height: size.y * 0.5), bodyPaint);

    // Floppy ears
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.25, center.y - size.y * 0.3)..quadraticBezierTo(center.x - size.x * 0.35, center.y - size.y * 0.2, center.x - size.x * 0.3, center.y - size.y * 0.05)..quadraticBezierTo(center.x - size.x * 0.2, center.y - size.y * 0.1, center.x - size.x * 0.15, center.y - size.y * 0.25)..close(), bodyPaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.25, center.y - size.y * 0.3)..quadraticBezierTo(center.x + size.x * 0.35, center.y - size.y * 0.2, center.x + size.x * 0.3, center.y - size.y * 0.05)..quadraticBezierTo(center.x + size.x * 0.2, center.y - size.y * 0.1, center.x + size.x * 0.15, center.y - size.y * 0.25)..close(), bodyPaint);
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.23, center.y - size.y * 0.28)..quadraticBezierTo(center.x - size.x * 0.3, center.y - size.y * 0.2, center.x - size.x * 0.27, center.y - size.y * 0.1)..lineTo(center.x - size.x * 0.18, center.y - size.y * 0.25)..close(), Paint()..color = secondaryColor);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.23, center.y - size.y * 0.28)..quadraticBezierTo(center.x + size.x * 0.3, center.y - size.y * 0.2, center.x + size.x * 0.27, center.y - size.y * 0.1)..lineTo(center.x + size.x * 0.18, center.y - size.y * 0.25)..close(), Paint()..color = secondaryColor);

    // Snout
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.02), width: size.x * 0.3, height: size.y * 0.25), Paint()..color = secondaryColor);

    // Happy eyes
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.14, center.y - size.y * 0.18), width: size.x * 0.12, height: size.y * 0.13), whitePaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.14, center.y - size.y * 0.17), size.x * 0.05, blackPaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.12, center.y - size.y * 0.19), size.x * 0.025, whitePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.14, center.y - size.y * 0.18), width: size.x * 0.12, height: size.y * 0.13), whitePaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.14, center.y - size.y * 0.17), size.x * 0.05, blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.16, center.y - size.y * 0.19), size.x * 0.025, whitePaint);

    // Big nose & pink tongue
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.03), width: size.x * 0.1, height: size.y * 0.07), blackPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.12), width: size.x * 0.12, height: size.y * 0.1), Paint()..color = Colors.pink.shade400);

    // Big happy smile
    final smilePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(Path()..moveTo(center.x, center.y + size.y * 0.03)..lineTo(center.x, center.y + size.y * 0.08), smilePaint);
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.15, center.y + size.y * 0.08)..quadraticBezierTo(center.x, center.y + size.y * 0.18, center.x + size.x * 0.15, center.y + size.y * 0.08), smilePaint);
  }

}

/// Target Star Component
class TargetStar extends PositionComponent with HasGameRef<LeftRightCodingGame> {
  int gridX;
  int gridY;
  int gridSize;
  double _rotation = 0;

  TargetStar({
    required this.gridX,
    required this.gridY,
    required this.gridSize,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updatePosition();
  }

  void _updatePosition() {
    final cellWidth = gameRef.size.x / gridSize;
    final cellHeight = gameRef.size.y / gridSize;

    position = Vector2(
      gridY * cellWidth + cellWidth / 2,
      gridX * cellHeight + cellHeight / 2,
    );

    size = Vector2(cellWidth * 0.5, cellHeight * 0.5);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _rotation += dt * 2; // Rotate animation
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rotation);

    // Draw star
    final starPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final starPath = Path();
    final radius = size.x / 2;
    final innerRadius = radius * 0.5;
    final points = 5;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * 3.14159 / points) - 3.14159 / 2;
      final r = i % 2 == 0 ? radius : innerRadius;
      final x = r * cos(angle);
      final y = r * sin(angle);

      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    canvas.drawPath(starPath, starPaint);

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.orange.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(starPath, outlinePaint);

    canvas.restore();
  }
}

/// Obstacle Component (Rocks, Bugs, Spikes)
class Obstacle extends PositionComponent with HasGameRef<LeftRightCodingGame> {
  int gridX;
  int gridY;
  int gridSize;
  int type; // 0: rock, 1: bug, 2: spike

  Obstacle({
    required this.gridX,
    required this.gridY,
    required this.gridSize,
    required this.type,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updatePosition();
  }

  void _updatePosition() {
    final cellWidth = gameRef.size.x / gridSize;
    final cellHeight = gameRef.size.y / gridSize;

    position = Vector2(
      gridY * cellWidth + cellWidth / 2,
      gridX * cellHeight + cellHeight / 2,
    );

    size = Vector2(cellWidth * 0.6, cellHeight * 0.6);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = size / 2;

    switch (type) {
      case 0: // Rock
        _drawRock(canvas, center);
        break;
      case 1: // Bug
        _drawBug(canvas, center);
        break;
      case 2: // Spike
        _drawSpike(canvas, center);
        break;
    }
  }

  void _drawRock(Canvas canvas, Vector2 center) {
    // Draw rock as an irregular shape
    final rockPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.x - size.x * 0.3, center.y);
    path.lineTo(center.x - size.x * 0.1, center.y - size.y * 0.35);
    path.lineTo(center.x + size.x * 0.2, center.y - size.y * 0.3);
    path.lineTo(center.x + size.x * 0.35, center.y);
    path.lineTo(center.x + size.x * 0.2, center.y + size.y * 0.35);
    path.lineTo(center.x - size.x * 0.2, center.y + size.y * 0.3);
    path.close();

    canvas.drawPath(path, rockPaint);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, shadowPaint);
  }

  void _drawBug(Canvas canvas, Vector2 center) {
    // Draw bug body
    final bodyPaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.x, center.y),
        width: size.x * 0.5,
        height: size.y * 0.7,
      ),
      bodyPaint,
    );

    // Draw bug head
    canvas.drawCircle(
      Offset(center.x, center.y - size.y * 0.25),
      size.x * 0.15,
      Paint()..color = Colors.black,
    );

    // Draw legs
    final legPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = -1; i <= 1; i++) {
      if (i == 0) continue;
      // Left legs
      canvas.drawLine(
        Offset(center.x - size.x * 0.25, center.y + i * size.y * 0.15),
        Offset(center.x - size.x * 0.4, center.y + i * size.y * 0.25),
        legPaint,
      );
      // Right legs
      canvas.drawLine(
        Offset(center.x + size.x * 0.25, center.y + i * size.y * 0.15),
        Offset(center.x + size.x * 0.4, center.y + i * size.y * 0.25),
        legPaint,
      );
    }
  }

  void _drawSpike(Canvas canvas, Vector2 center) {
    // Draw spike as a triangle
    final spikePaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.x, center.y - size.y * 0.4);
    path.lineTo(center.x - size.x * 0.3, center.y + size.y * 0.4);
    path.lineTo(center.x + size.x * 0.3, center.y + size.y * 0.4);
    path.close();

    canvas.drawPath(path, spikePaint);

    // Draw sharp tip
    final tipPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.x, center.y - size.y * 0.4),
      size.x * 0.08,
      tipPaint,
    );

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.brown.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, outlinePaint);
  }
}

/// Bonus Square Component (Question Squares)
class BonusSquare extends PositionComponent with HasGameRef<LeftRightCodingGame> {
  int gridX;
  int gridY;
  int gridSize;
  Map<String, dynamic> questionData;
  bool _answered = false;
  bool _highlightedRed = false;
  double _pulseTimer = 0;
  double _redFlashTimer = 0;

  BonusSquare({
    required this.gridX,
    required this.gridY,
    required this.gridSize,
    required this.questionData,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updatePosition();
  }

  void _updatePosition() {
    final cellWidth = gameRef.size.x / gridSize;
    final cellHeight = gameRef.size.y / gridSize;

    position = Vector2(
      gridY * cellWidth + cellWidth / 2,
      gridX * cellHeight + cellHeight / 2,
    );

    size = Vector2(cellWidth * 0.7, cellHeight * 0.7);
    anchor = Anchor.center;
  }

  void markAsAnswered() {
    _answered = true;
    _highlightedRed = false; // Remove red highlight when answered
  }

  void highlightRed() {
    if (!_answered) {
      _highlightedRed = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_answered) {
      _pulseTimer += dt * 3; // Pulse animation
    }
    if (_highlightedRed) {
      _redFlashTimer += dt * 5; // Faster flash for red warning
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = size / 2;

    // Determine color based on state
    Color squareColor;

    if (_highlightedRed) {
      // Red flashing for unanswered questions when reached goal
      final flashIntensity = (sin(_redFlashTimer) + 1) / 2; // 0 to 1
      squareColor = Color.lerp(Colors.red.shade700, Colors.red.shade300, flashIntensity)!;
    } else {
      // Normal color based on difficulty
      final difficulty = questionData['difficulty'] ?? 1;
      if (difficulty == 1) {
        squareColor = Colors.purple.shade400;
      } else if (difficulty == 2) {
        squareColor = Colors.orange.shade400;
      } else {
        squareColor = Colors.amber.shade400;
      }

      // If answered, make it transparent
      if (_answered) {
        squareColor = squareColor.withValues(alpha: 0.3);
      }
    }

    // Pulse effect (stronger for red warning)
    final pulseScale = _highlightedRed
        ? 1.0 + (sin(_redFlashTimer) * 0.15)
        : (_answered ? 1.0 : 1.0 + (sin(_pulseTimer) * 0.1));

    canvas.save();
    canvas.translate(center.x, center.y);
    canvas.scale(pulseScale);

    // Draw square background
    final squarePaint = Paint()
      ..color = squareColor
      ..style = PaintingStyle.fill;

    final squareRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x * 0.9,
        height: size.y * 0.9,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(squareRect, squarePaint);

    // Draw border (white or yellow for red highlight)
    final borderPaint = Paint()
      ..color = _highlightedRed ? Colors.yellow : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _highlightedRed ? 4 : 3;

    canvas.drawRRect(squareRect, borderPaint);

    // Draw question mark or checkmark
    if (!_answered) {
      // Draw question mark
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
    } else {
      // Draw checkmark
      final checkPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final checkPath = Path()
        ..moveTo(-size.x * 0.15, 0)
        ..lineTo(-size.x * 0.05, size.y * 0.1)
        ..lineTo(size.x * 0.15, -size.y * 0.1);

      canvas.drawPath(checkPath, checkPaint);
    }

    canvas.restore();

    // Draw sparkles for unanswered bonus squares
    if (!_answered) {
      _drawSparkles(canvas, center);
    }
  }

  void _drawSparkles(Canvas canvas, Vector2 center) {
    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final sparklePositions = [
      Offset(center.x - size.x * 0.4, center.y - size.y * 0.4),
      Offset(center.x + size.x * 0.4, center.y - size.y * 0.4),
      Offset(center.x - size.x * 0.4, center.y + size.y * 0.4),
      Offset(center.x + size.x * 0.4, center.y + size.y * 0.4),
    ];

    for (var i = 0; i < sparklePositions.length; i++) {
      final pos = sparklePositions[i];
      final sparkleScale = sin(_pulseTimer + i * 1.5) * 0.5 + 0.5;

      canvas.drawCircle(
        pos,
        2 * sparkleScale,
        sparklePaint,
      );
    }
  }
}
