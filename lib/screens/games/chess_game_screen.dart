import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter_chess_board/flutter_chess_board.dart';
// TODO: Migrate to Supabase
import 'package:uuid/uuid.dart';
import '../../models/chess_game_model.dart';
import '../../models/user_model.dart';
import '../../models/game_model.dart';
import '../../models/leaderboard_model.dart';
import '../../services/chess_ai_service.dart';
import '../../services/chess_firestore_service.dart';
import '../../services/leaderboard_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_progress_service.dart';
import '../../theme.dart';
import 'game_result_screen.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class ChessGameScreen extends StatefulWidget {
  final ChessDifficulty? initialDifficulty;

  const ChessGameScreen({super.key, this.initialDifficulty});

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  // Services
  final ChessAIService _aiService = ChessAIService();
  final ChessFirestoreService _firestoreService = ChessFirestoreService();
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AuthService _authService = AuthService();

  // Chess board controller
  late ChessBoardController _boardController;

  // Game state
  ChessDifficulty? _selectedDifficulty;
  GameResult _gameResult = GameResult.ongoing;
  bool _isGameStarted = false;
  bool _isAIThinking = false;
  bool _isSaving = false;
  BoardColor _selectedBoardColor = BoardColor.brown;

  // Game data
  String? _gameId;
  DateTime? _startTime;
  DateTime? _endTime;
  final List<String> _moveHistory = [];
  Timer? _gameTimer;
  int _elapsedSeconds = 0;
  String? _lastAIMove;
  String? _lastPlayerMove;
  String? _lastMoveFrom;
  String? _lastMoveTo;

  // User data
  UserModel? _currentUser;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
    _boardController = ChessBoardController();
    _loadUserData();

    if (_selectedDifficulty != null) {
      _startGame();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUserData();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  Future<void> _startGame() async {
    // Show theme selection dialog first and wait for user to click Start
    final shouldStart = await _showThemeSelectionDialog();

    if (shouldStart != true) {
      // User cancelled, go back to difficulty selection
      setState(() {
        _selectedDifficulty = null;
      });
      return;
    }

    // Show loading indicator while initializing
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text(_isEn ? 'Starting chess engine...' : 'Satranç motoru başlatılıyor...'),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    try {
      // Initialize AI service once
      await _aiService.initialize();

      if (!mounted) return;

      setState(() {
        _isGameStarted = true;
        _gameId = const Uuid().v4();
        _startTime = DateTime.now();
        _elapsedSeconds = 0;
        _moveHistory.clear();
        _gameResult = GameResult.ongoing;
        _lastAIMove = null;
        _lastPlayerMove = null;
        _lastMoveFrom = null;
        _lastMoveTo = null;
      });

      // Start game timer
      _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() => _elapsedSeconds++);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEn ? 'Game started! Good luck!' : 'Oyun başladı! İyi şanslar!'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      debugPrint('🎮 Chess game started with difficulty: ${_selectedDifficulty?.name}');
    } catch (e) {
      debugPrint('❌ Failed to start game: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEn ? 'Failed to start game: $e' : 'Oyun başlatılamadı: $e'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
        // Go back to difficulty selection
        setState(() {
          _selectedDifficulty = null;
        });
      }
    }
  }

  Future<void> _onMove() async {
    if (_gameResult != GameResult.ongoing || _isAIThinking) return;

    // Get move count before AI move (board controller tracks moves internally)
    final currentMoveCount = _boardController.game.history.length;

    // Only process if this is a new move we haven't recorded yet
    if (currentMoveCount <= _moveHistory.length) return;

    // Get the last move in SAN notation
    final sanList = _boardController.getSan();
    if (sanList.isEmpty) return;
    final lastMoveSan = sanList.last!; // Safe to use ! since we checked isEmpty

    // Record player move and get move details
    _moveHistory.add(lastMoveSan);
    debugPrint('👤 Player move: $lastMoveSan');

    // Get the last move's from/to squares for highlighting
    final lastMove = _boardController.game.history.last;
    setState(() {
      _lastPlayerMove = lastMoveSan;
      _lastMoveFrom = lastMove.move.fromAlgebraic;
      _lastMoveTo = lastMove.move.toAlgebraic;
    });

    // Check game state after player move
    _checkGameState();

    if (_gameResult != GameResult.ongoing) {
      await _endGame();
      return;
    }

    // AI's turn
    await _makeAIMove();
  }

  Future<void> _makeAIMove() async {
    setState(() => _isAIThinking = true);

    try {
      final aiMove = await _aiService.getBestMove(
        game: _boardController.game,
        difficulty: _selectedDifficulty!,
      );

      if (aiMove != null && mounted) {
        _boardController.game.move(aiMove);
        _moveHistory.add(aiMove);
        debugPrint('🤖 AI move: $aiMove');

        // Get the last move's from/to squares for highlighting
        final lastMove = _boardController.game.history.last;

        // Force UI update with last AI move
        setState(() {
          _lastAIMove = aiMove;
          _lastMoveFrom = lastMove.move.fromAlgebraic;
          _lastMoveTo = lastMove.move.toAlgebraic;
        });

        // Check game state after AI move
        _checkGameState();

        if (_gameResult != GameResult.ongoing) {
          await _endGame();
        }
      }
    } catch (e) {
      debugPrint('❌ AI move error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEn ? 'AI move failed: $e' : 'AI hareketi başarısız: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAIThinking = false);
      }
    }
  }

  void _checkGameState() {
    if (_boardController.game.in_checkmate) {
      // White (player) is always on bottom, so if it's white's turn and checkmate, player lost
      setState(() {
        _gameResult = _boardController.game.turn == chess_lib.Color.WHITE
            ? GameResult.loss
            : GameResult.win;
      });
      debugPrint('🏁 Checkmate! Result: ${_gameResult.name}');
    } else if (_boardController.game.in_stalemate || _boardController.game.in_draw || _boardController.game.in_threefold_repetition) {
      setState(() => _gameResult = GameResult.draw);
      debugPrint('🏁 Draw!');
    }
  }

  Future<void> _endGame() async {
    _gameTimer?.cancel();
    _endTime = DateTime.now();

    // Show result dialog
    if (mounted) {
      await _showResultDialog();
    }

    // Save game to Firestore
    await _saveGame();
  }

  Future<void> _saveGame() async {
    if (_currentUser == null || _gameId == null) return;

    setState(() => _isSaving = true);

    try {
      final gameModel = ChessGameModel(
        gameId: _gameId!,
        playerId: _currentUser!.uid,
        playerName: _currentUser!.displayName,
        opponent: 'AI',
        difficulty: _selectedDifficulty!,
        result: _gameResult,
        duration: _elapsedSeconds,
        moveHistory: _moveHistory,
        finalFEN: _boardController.game.fen,
        timestamp: DateTime.now(),
        startTime: _startTime,
        endTime: _endTime,
      );

      await _firestoreService.saveGame(gameModel.toMap());
      debugPrint('✅ Game saved to Firestore');

      // Add to leaderboard if player won
      if (_gameResult == GameResult.win) {
        try {
          // Calculate score (higher is better: faster wins get more points)
          final baseScore = 1000;
          final timeBonus = (_elapsedSeconds > 0) ? (3600 ~/ _elapsedSeconds) : 0;
          final difficultyMultiplier = _selectedDifficulty == ChessDifficulty.advanced
              ? 3
              : _selectedDifficulty == ChessDifficulty.intermediate
                  ? 2
                  : 1;
          final score = (baseScore + timeBonus) * difficultyMultiplier;

          final leaderboardEntry = LeaderboardEntry(
            id: '',
            userId: _currentUser!.uid,
            userName: _currentUser!.displayName,
            gameType: GameType.chess,
            score: score,
            timeSeconds: _elapsedSeconds,
            difficulty: _selectedDifficulty?.index,
            completedAt: DateTime.now(),
            metadata: {
              'moves': _moveHistory.length,
              'result': _gameResult.name,
            },
          );

          await _leaderboardService.addEntry(leaderboardEntry);
          debugPrint('✅ Added to leaderboard with score: $score');

          // Jeton ödülü: skorla orantılı (Market'te harcanabilir)
          final jeton = (score / 60).round().clamp(15, 120);
          await UserProgressService().addJeton(_currentUser!.uid, jeton, source: 'chess');
        } catch (e) {
          debugPrint('❌ Error adding to leaderboard: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEn ? 'Game saved!' : 'Oyun kaydedildi!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving game: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEn ? 'Failed to save game: $e' : 'Oyun kaydedilemedi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showResultDialog() async {
    if (_gameResult == GameResult.ongoing) return;

    // Calculate score (same logic as in _saveAndEndGame)
    final baseScore = 1000;
    final timeBonus = (_elapsedSeconds > 0) ? (3600 ~/ _elapsedSeconds) : 0;
    final difficultyMultiplier = _selectedDifficulty == ChessDifficulty.advanced
        ? 3
        : _selectedDifficulty == ChessDifficulty.intermediate
            ? 2
            : 1;
    final score = (baseScore + timeBonus) * difficultyMultiplier;

    // Determine result message and icon
    String title;
    String message;
    IconData icon;
    ui.Color color;

    if (_gameResult == GameResult.win) {
      title = _isEn ? '🎉 Congratulations!' : '🎉 Tebrikler!';
      message = _isEn
          ? 'Checkmate! You beat the AI with a great game.'
          : 'Şah mat ettiniz! Harika bir oyun sergileyerek yapay zekayı yendiniz.';
      icon = Icons.emoji_events;
      color = AppTheme.successGreen;
    } else if (_gameResult == GameResult.loss) {
      title = _isEn ? '😔 You Were Checkmated' : '😔 Mat Oldunuz';
      message = _isEn
          ? 'The AI delivered checkmate. Keep practicing to improve!'
          : 'Yapay zeka şah mat yaptı. Daha fazla pratik yaparak gelişebilirsiniz!';
      icon = Icons.psychology;
      color = AppTheme.errorRed;
    } else {
      title = _isEn ? '🤝 Draw' : '🤝 Berabere';
      message = _isEn
          ? 'The game ended in a draw. You held off the AI with a solid defense.'
          : 'Oyun berabere bitti. İyi bir savunma sergileyerek yapay zekayı durdurdunuz.';
      icon = Icons.handshake;
      color = AppTheme.accentTeal;
    }

    // Show custom game end dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildStatRow(_isEn ? '⏱️ Duration' : '⏱️ Süre', _formatDuration(_elapsedSeconds)),
                  const SizedBox(height: 8),
                  _buildStatRow(_isEn ? '🎯 Move Count' : '🎯 Hamle Sayısı', '${_moveHistory.length}'),
                  const SizedBox(height: 8),
                  _buildStatRow(_isEn ? '🏆 Score' : '🏆 Puan', score.toString()),
                  const SizedBox(height: 8),
                  _buildStatRow(_isEn ? '📊 Difficulty' : '📊 Zorluk', _selectedDifficulty?.displayNameFor(_lang) ?? ''),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to games list
            },
            child: Text(_isEn ? 'Back to Games' : 'Oyunlara Dön'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: Text(_isEn ? 'New Game' : 'Yeni Oyun'),
          ),
          if (_gameResult != GameResult.loss)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Navigate to leaderboard
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GameResultScreen(
                      userId: _currentUser!.uid,
                      userName: _currentUser!.displayName,
                      gameType: GameType.chess,
                      score: score,
                      timeSeconds: _elapsedSeconds,
                      difficulty: _selectedDifficulty?.index,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
              ),
              child: Text(_isEn ? 'Leaderboard' : 'Skor Tablosu'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  void _resetGame() {
    _gameTimer?.cancel();
    _boardController = ChessBoardController();

    // Reset AI engine for new game instead of disposing
    _aiService.resetForNewGame();

    setState(() {
      _isGameStarted = false;
      _selectedDifficulty = null;
      _gameResult = GameResult.ongoing;
      _moveHistory.clear();
      _elapsedSeconds = 0;
      _gameId = null;
      _startTime = null;
      _endTime = null;
      _lastAIMove = null;
      _lastPlayerMove = null;
      _lastMoveFrom = null;
      _lastMoveTo = null;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEn ? 'Chess Game' : 'Satranç Oyunu'),
        actions: [
          if (_isGameStarted) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _formatDuration(_elapsedSeconds),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _showResetConfirmation(),
              tooltip: _isEn ? 'New Game' : 'Yeni Oyun',
            ),
          ],
        ],
      ),
      body: _isGameStarted ? _buildGameView() : _buildDifficultySelection(),
    );
  }

  Widget _buildDifficultySelection() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 80,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 24),
            Text(
              _isEn ? 'Select Difficulty Level' : 'Zorluk Seviyesi Seçin',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 40),
            ...[
              ChessDifficulty.beginner,
              ChessDifficulty.intermediate,
              ChessDifficulty.advanced,
            ].map((difficulty) => _buildDifficultyCard(difficulty)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(ChessDifficulty difficulty) {
    ui.Color cardColor;
    IconData icon;

    switch (difficulty) {
      case ChessDifficulty.beginner:
        cardColor = AppTheme.successGreen;
        icon = Icons.sports_esports;
        break;
      case ChessDifficulty.intermediate:
        cardColor = AppTheme.accentTeal;
        icon = Icons.sports;
        break;
      case ChessDifficulty.advanced:
        cardColor = AppTheme.errorRed;
        icon = Icons.military_tech;
        break;
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () {
            setState(() => _selectedDifficulty = difficulty);
            _startGame();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: cardColor, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        difficulty.displayNameFor(_lang),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        difficulty.descriptionFor(_lang),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: cardColor),
                          const SizedBox(width: 4),
                          Text(
                            'ELO: ~${difficulty.estimatedElo}',
                            style: TextStyle(
                              color: cardColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: AppTheme.mediumGray),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameView() {
    return Column(
      children: [
        // AI status indicator
        if (_isAIThinking)
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.accentTeal.withValues(alpha: 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accentTeal,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEn ? 'AI is thinking...' : 'AI düşünüyor...',
                  style: TextStyle(
                    color: AppTheme.darkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Last AI move indicator
        if (!_isAIThinking && _lastAIMove != null && _lastAIMove!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.smart_toy,
                  size: 20,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 12),
                Text(
                  _isEn
                      ? 'Opponent move: ${_lastAIMove!}'
                      : 'Rakip hamle: ${_convertMoveToTurkish(_lastAIMove!)}',
                  style: TextStyle(
                    color: AppTheme.darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

        // Chess board with last move highlight
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chess board with coordinates
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth - 24; // Space for rank numbers
                    final squareSize = maxWidth / 8;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Board with rank numbers on right
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Chess board
                            SizedBox(
                              width: maxWidth,
                              height: maxWidth,
                              child: Stack(
                                children: [
                                  ChessBoard(
                                    controller: _boardController,
                                    boardColor: _selectedBoardColor,
                                    boardOrientation: PlayerColor.white,
                                    onMove: _onMove,
                                    enableUserMoves: true,
                                  ),
                                  // Last move highlight overlay
                                  if (_lastMoveFrom != null && _lastMoveTo != null)
                                    _buildMoveHighlightOverlay(),
                                ],
                              ),
                            ),
                            // Rank numbers (1-8) on right - aligned with squares
                            SizedBox(
                              width: 24,
                              height: maxWidth,
                              child: Column(
                                children: List.generate(8, (i) {
                                  final rank = 8 - i;
                                  return SizedBox(
                                    height: squareSize,
                                    child: Center(
                                      child: Text(
                                        '$rank',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.mediumGray,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                        // File letters (a-h) at bottom - aligned with squares
                        SizedBox(
                          width: maxWidth,
                          height: 20,
                          child: Row(
                            children: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].map((file) {
                              return SizedBox(
                                width: squareSize,
                                child: Center(
                                  child: Text(
                                    file,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.darkBlue,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Game info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoChip(
                icon: Icons.timer,
                label: _formatDuration(_elapsedSeconds),
              ),
              _buildInfoChip(
                icon: Icons.swap_horiz,
                label: _isEn ? '${_moveHistory.length} moves' : '${_moveHistory.length} hamle',
              ),
              _buildInfoChip(
                icon: Icons.psychology,
                label: _selectedDifficulty?.displayNameFor(_lang) ?? '',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showThemeSelectionDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isEn ? 'Select Theme' : 'Tema Seçin',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildThemeOption(BoardColor.brown, _isEn ? 'Classic Brown' : 'Klasik Kahverengi', setDialogState),
                const SizedBox(height: 12),
                _buildThemeOption(BoardColor.darkBrown, _isEn ? 'Dark Brown' : 'Koyu Kahverengi', setDialogState),
                const SizedBox(height: 12),
                _buildThemeOption(BoardColor.orange, _isEn ? 'Orange' : 'Turuncu', setDialogState),
                const SizedBox(height: 12),
                _buildThemeOption(BoardColor.green, _isEn ? 'Green' : 'Yeşil', setDialogState),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        _isEn ? 'Cancel' : 'İptal',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text(
                        _isEn ? 'Start' : 'Başlat',
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(BoardColor color, String name, StateSetter setDialogState) {
    final isSelected = _selectedBoardColor == color;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBoardColor = color;
        });
        setDialogState(() {
          _selectedBoardColor = color;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: _buildThemePreview(color),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreview(BoardColor color) {
    // Create a mini chess board preview
    final lightColor = _getLightSquareColor(color);
    final darkColor = _getDarkSquareColor(color);

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(child: Container(color: lightColor)),
              Expanded(child: Container(color: darkColor)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(child: Container(color: darkColor)),
              Expanded(child: Container(color: lightColor)),
            ],
          ),
        ),
      ],
    );
  }

  ui.Color _getLightSquareColor(BoardColor color) {
    switch (color) {
      case BoardColor.brown:
        return const ui.Color(0xFFF0D9B5);
      case BoardColor.darkBrown:
        return const ui.Color(0xFFB58863);
      case BoardColor.orange:
        return const ui.Color(0xFFFFCE9E);
      case BoardColor.green:
        return const ui.Color(0xFFEEEED2);
      default:
        return const ui.Color(0xFFF0D9B5);
    }
  }

  ui.Color _getDarkSquareColor(BoardColor color) {
    switch (color) {
      case BoardColor.brown:
        return const ui.Color(0xFFB58863);
      case BoardColor.darkBrown:
        return const ui.Color(0xFF7D4E2A);
      case BoardColor.orange:
        return const ui.Color(0xFFD18B47);
      case BoardColor.green:
        return const ui.Color(0xFF769656);
      default:
        return const ui.Color(0xFFB58863);
    }
  }

  Future<void> _showResetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEn ? 'Reset Game' : 'Oyunu Sıfırla'),
        content: Text(_isEn ? 'The current game will be lost. Are you sure?' : 'Mevcut oyun kaybolacak. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_isEn ? 'Cancel' : 'İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text(_isEn ? 'Reset' : 'Sıfırla'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _resetGame();
    }
  }

  /// Build highlight overlay for last move
  Widget _buildMoveHighlightOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final squareSize = constraints.maxWidth / 8;

        // Convert chess notation (e.g., "e2") to board coordinates
        final fromCoords = _algebraicToCoordinates(_lastMoveFrom!);
        final toCoords = _algebraicToCoordinates(_lastMoveTo!);

        return Stack(
          children: [
            // Highlight "from" square
            Positioned(
              left: fromCoords.x * squareSize,
              top: fromCoords.y * squareSize,
              width: squareSize,
              height: squareSize,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.yellow.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            // Highlight "to" square
            Positioned(
              left: toCoords.x * squareSize,
              top: toCoords.y * squareSize,
              width: squareSize,
              height: squareSize,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.yellow.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Convert chess algebraic notation to board coordinates
  /// e.g., "e2" -> (4, 6) for white's perspective
  ({double x, double y}) _algebraicToCoordinates(String algebraic) {
    final file = algebraic[0].toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.parse(algebraic[1]) - 1;

    // For white's perspective (board orientation is white on bottom)
    // Files: a=0, b=1, ..., h=7 (left to right)
    // Ranks: 1=7, 2=6, ..., 8=0 (bottom to top, inverted for display)
    return (x: file.toDouble(), y: (7 - rank).toDouble());
  }

  /// Convert SAN (Standard Algebraic Notation) to Turkish
  /// e.g., "Nf3" -> "At f3", "Bc4" -> "Fil c4"
  String _convertMoveToTurkish(String sanMove) {
    if (sanMove.isEmpty) return '';

    // Handle castling
    if (sanMove == 'O-O' || sanMove == '0-0') return 'Kısa rok';
    if (sanMove == 'O-O-O' || sanMove == '0-0-0') return 'Uzun rok';

    String result = '';
    String move = sanMove;

    // Extract check/checkmate symbols
    String suffix = '';
    if (move.endsWith('#')) {
      suffix = ' (Mat)';
      move = move.substring(0, move.length - 1);
    } else if (move.endsWith('+')) {
      suffix = ' (Şah)';
      move = move.substring(0, move.length - 1);
    }

    // Get piece name in Turkish
    final firstChar = move[0];
    if (firstChar.toUpperCase() == firstChar && RegExp(r'[A-Z]').hasMatch(firstChar)) {
      // It's a piece (not a pawn)
      switch (firstChar) {
        case 'N':
          result = 'At ';
          break;
        case 'B':
          result = 'Fil ';
          break;
        case 'R':
          result = 'Kale ';
          break;
        case 'Q':
          result = 'Vezir ';
          break;
        case 'K':
          result = 'Şah ';
          break;
        default:
          result = '';
      }
      move = move.substring(1); // Remove piece letter
    } else {
      // It's a pawn move
      result = 'Piyon ';
    }

    // Handle captures
    if (move.contains('x')) {
      move = move.replaceAll('x', '');
      // Add position after removing 'x'
    }

    // Add the remaining move (destination square)
    result += move;
    result += suffix;

    return result;
  }
}
