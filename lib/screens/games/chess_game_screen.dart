import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/oyun_basligi.dart';
import '../../widgets/oyun_kimligi.dart';
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
import '../../services/sound_service.dart';
import '../../utils/lang.dart';

class ChessGameScreen extends StatefulWidget {
  final ChessDifficulty? initialDifficulty;

  /// Oyunu bu konumdan baslatir (ekran goruntusu araci ve testler icin;
  /// uygulama hep bastan baslatiyor). Konum oyun sonuysa sonuc paneli
  /// hemen acilir.
  @visibleForTesting
  final String? baslangicFen;

  const ChessGameScreen(
      {super.key, this.initialDifficulty, this.baslangicFen});

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
  BoardColor _selectedBoardColor = BoardColor.brown;

  // Game data
  String? _gameId;
  DateTime? _startTime;
  DateTime? _endTime;
  final List<String> _moveHistory = [];
  Timer? _gameTimer;
  int _elapsedSeconds = 0;
  String? _lastAIMove;
  String? _lastMoveFrom;
  String? _lastMoveTo;

  // DOKUNARAK OYNAMA VE HAMLE IPUCU.
  //
  // Taslar eskiden yalnizca SURUKLENEREK oynaniyordu ve bir tasin nereye
  // gidebilecegi hicbir yerde gorunmuyordu. Artik cocuk tasina bir kez
  // dokununca gidebilecegi kareler tahtada nokta nokta isaretleniyor
  // (alinabilecek tasin karesi halka); noktaya dokununca tas oraya
  // gidiyor. Surukleme de calismaya devam ediyor.
  String? _secili;
  Set<String> _hedefler = const {};
  Set<String> _alinanHedefler = const {};

  /// Oyun sonu paneli acik mi. Sonuc eskiden tahtanin USTUNE acilan bir
  /// pencereydi: cocuk nasil mat oldugunu goremiyordu. Panel artik
  /// tahtanin altinda ve kapanabiliyor; tahta hep gorunuyor.
  bool _sonucAcik = true;

  // User data
  UserModel? _currentUser;

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  ///
  /// Onceki surumde her yerde `_isEn ? ingilizce : turkce` vardi; almanca
  /// ya da ispanyolca secen cocuk oyunun tamamini turkce goruyordu.
  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (Satranc). Ekran tamamen sessizdi ve
    // bir onceki oyunun ses rengini devraliyordu.
    SoundService.useVoice(SfxVoice.deep);
    _selectedDifficulty = widget.initialDifficulty;
    _boardController = ChessBoardController();
    _loadUserData();

    if (_selectedDifficulty != null) {
      // ILK KAREDEN SONRA: _startGame() showDialog ve ScaffoldMessenger
      // cagiriyor, ikisi de Localizations'a bagimli. initState'in
      // icinden cagrilinca Flutter "dependOnInheritedWidgetOfExactType
      // ... initState tamamlanmadan cagrildi" diye atiyor ve ekran hic
      // cizilmiyordu. Zorluk secerek giren cocuk bunu gormuyordu cunku
      // orada _startGame bir dokunustan sonra calisiyor; yalnizca
      // ekrana initialDifficulty ile GIRILDIGINDE patliyordu.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startGame();
      });
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    // Stockfish AYRI BIR SUREC. Ekran kapanirken durdurulmazsa arka
    // planda calismaya devam ediyordu: cocuk satranci birakip derse
    // donse bile pil ve bellek tuketiliyor, birkac kez girip cikinca
    // ust uste birikiyordu.
    _aiService.dispose();
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
              Text(_tl('Satranç motoru başlatılıyor...', 'Starting chess engine...', 'Schach-Engine wird gestartet ...', 'Iniciando el motor de ajedrez...')),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    try {
      // Kolay seviye motoru hic kullanmiyor; Stockfish surecini bosuna
      // ayaga kaldirmiyoruz (pil, bellek).
      if (_selectedDifficulty != ChessDifficulty.beginner) {
        await _aiService.initialize();
      }

      if (!mounted) return;

      if (widget.baslangicFen != null) {
        _boardController = ChessBoardController.fromFEN(widget.baslangicFen!);
      }
      setState(() {
        _isGameStarted = true;
        _gameId = const Uuid().v4();
        _startTime = DateTime.now();
        _elapsedSeconds = 0;
        _moveHistory.clear();
        _gameResult = GameResult.ongoing;
        _lastAIMove = null;
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
            content: Text(_tl('Oyun başladı! İyi şanslar!', 'Game started! Good luck!', 'Spiel gestartet! Viel Glück!', '¡Partida iniciada! ¡Buena suerte!')),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      debugPrint(
          '🎮 Chess game started with difficulty: ${_selectedDifficulty?.name}');

      if (widget.baslangicFen != null) {
        _checkGameState();
        if (_gameResult != GameResult.ongoing) await _endGame();
      }
    } catch (e) {
      debugPrint('❌ Failed to start game: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _tl('Oyun başlatılamadı: $e', 'Failed to start game: $e', 'Spiel konnte nicht gestartet werden: $e', 'No se pudo iniciar la partida: $e')),
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

  /// Cocuk su an hamle yapabilir mi?
  ///
  /// Uc kosul: oyun suruyor, bilgisayar dusunmuyor ve sira BEYAZDA
  /// (cocuk her zaman beyaz oynuyor, tahta da ona gore cevrili).
  bool get _cocukOynayabilir =>
      _gameResult == GameResult.ongoing &&
      !_isAIThinking &&
      _boardController.game.turn == chess_lib.Color.WHITE;

  Future<void> _onMove() async {
    if (_gameResult != GameResult.ongoing || _isAIThinking) return;
    _secimiTemizle();

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
          // "AI dusunuyor..." seridi sonuc ekraninin arkasinda donmeye
          // devam ediyordu: bayrak ancak sonuc kapaninca iniyordu.
          setState(() => _isAIThinking = false);
          await _endGame();
        }
      }
    } catch (e) {
      // Ham istisna metni cocuga gosterilmiyordu kuralina aykiriydi:
      // ekranda "AI hareketi başarısız: SocketException ..." yaziyordu.
      // Ayrinti gunluge, cocuga ne oldugunu anlatan bir cumle.
      debugPrint('❌ AI move error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tl(
                'Bilgisayar bu hamlede takıldı. Yeniden başlatmayı dene.',
                'The computer got stuck on this move. Try starting again.',
                'Der Computer ist bei diesem Zug hängengeblieben. Starte neu.',
                'El ordenador se atascó en esta jugada. Empieza de nuevo.')),
          ),
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
    } else if (_boardController.game.in_stalemate ||
        _boardController.game.in_draw ||
        _boardController.game.in_threefold_repetition) {
      setState(() => _gameResult = GameResult.draw);
      debugPrint('🏁 Draw!');
    }
  }

  Future<void> _endGame() async {
    _gameTimer?.cancel();
    _endTime = DateTime.now();

    // Sonuc paneli tahtanin altinda aciliyor (pencere degil).
    if (mounted) {
      setState(() => _sonucAcik = true);
      if (_gameResult == GameResult.win) {
        SoundService.playLevelComplete();
      } else if (_gameResult == GameResult.loss) {
        SoundService.playGameOver();
      }
    }

    // Save game to Firestore
    await _saveGame();
  }

  Future<void> _saveGame() async {
    if (_currentUser == null || _gameId == null) return;

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
          final score = _puan;

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
          await UserProgressService()
              .addJeton(_currentUser!.uid, jeton, source: 'chess');
        } catch (e) {
          debugPrint('❌ Error adding to leaderboard: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tl('Oyun kaydedildi!', 'Game saved!', 'Spiel gespeichert!', '¡Partida guardada!')),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving game: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_tl('Oyun kaydedilemedi: $e', 'Failed to save game: $e', 'Spiel konnte nicht gespeichert werden: $e', 'No se pudo guardar la partida: $e'))),
        );
      }
    }
  }

  /// Oyun sonu puani (kaydedilen puanla ayni hesap).
  int get _puan {
    const baseScore = 1000;
    final timeBonus = (_elapsedSeconds > 0) ? (3600 ~/ _elapsedSeconds) : 0;
    final difficultyMultiplier = _selectedDifficulty == ChessDifficulty.advanced
        ? 3
        : _selectedDifficulty == ChessDifficulty.intermediate
            ? 2
            : 1;
    return (baseScore + timeBonus) * difficultyMultiplier;
  }

  /// Oyun sonu paneli: tahtanin ALTINDA, acilip kapanan.
  ///
  /// Eskiden sonuc tahtanin ustune acilan bir pencereydi ve tahtayi
  /// ortuyordu; cocuk nasil mat oldugunu goremiyordu. Simdi tahta acik
  /// kaliyor: son hamle sari, mat olan sah kirmizi isaretli. Panelin
  /// basligina dokununca ayrintilar kapanip aciliyor.
  Widget _buildSonucPaneli() {
    final String baslik;
    final String mesaj;
    final IconData ikon;
    final ui.Color renk;
    if (_gameResult == GameResult.win) {
      baslik = _tl('🎉 Tebrikler, kazandın!', '🎉 You won!', '🎉 Du hast gewonnen!', '🎉 ¡Has ganado!');
      mesaj = _tl('Şah mat ettin! Kırmızı kare rakibin mat olan şahı.', 'Checkmate! The red square is the checkmated king.', 'Schachmatt! Das rote Feld ist der mattgesetzte König.', '¡Jaque mate! La casilla roja es el rey en jaque mate.');
      ikon = Icons.emoji_events_rounded;
      renk = AppTheme.successGreen;
    } else if (_gameResult == GameResult.loss) {
      baslik = _tl('😔 Mat oldun', '😔 Checkmate', '😔 Schachmatt', '😔 Jaque mate');
      mesaj = _tl('Tahtaya bak: sarı kareler rakibin son hamlesi, kırmızı kare mat olan şahın. Bir dahaki sefere şahının kaçış karelerini açık tut!', 'Look at the board: the yellow squares are the last move, the red square is your checkmated king. Next time keep escape squares open for your king!', 'Schau aufs Brett: Gelb ist der letzte Zug, Rot dein mattgesetzter König. Halte deinem König beim nächsten Mal Fluchtfelder frei!', 'Mira el tablero: las casillas amarillas son la última jugada y la roja es tu rey en jaque mate. ¡La próxima vez deja casillas de escape a tu rey!');
      ikon = Icons.psychology_rounded;
      renk = AppTheme.errorRed;
    } else {
      baslik = _tl('🤝 Berabere', '🤝 Draw', '🤝 Unentschieden', '🤝 Tablas');
      mesaj = _tl('Oyun berabere bitti. İyi bir savunma yaptın!', 'The game ended in a draw. Good defending!', 'Die Partie endet unentschieden. Gut verteidigt!', 'La partida terminó en tablas. ¡Buena defensa!');
      ikon = Icons.handshake_rounded;
      renk = AppTheme.accentTeal;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: renk.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: renk.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _sonucAcik = !_sonucAcik),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(ikon, color: renk, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        baslik,
                        style: TextStyle(
                          color: renk,
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                        ),
                      ),
                    ),
                    Icon(
                      _sonucAcik
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_up_rounded,
                      color: AppTheme.mediumGray,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
            if (_sonucAcik) ...[
              Text(mesaj, style: const TextStyle(fontSize: 14.5, height: 1.35)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _sonucCipi(Icons.timer_rounded, _formatDuration(_elapsedSeconds)),
                  _sonucCipi(Icons.swap_horiz_rounded,
                      _tl('${_moveHistory.length} hamle', '${_moveHistory.length} moves', '${_moveHistory.length} Züge', '${_moveHistory.length} jugadas')),
                  // Puan yalnizca kazaninca (kayipta "1000 puan" yaziyordu).
                  if (_gameResult == GameResult.win)
                    _sonucCipi(Icons.emoji_events_rounded,
                        _tl('$_puan puan', '$_puan points', '$_puan Punkte', '$_puan puntos')),
                  _sonucCipi(Icons.psychology_rounded,
                      _selectedDifficulty?.displayNameFor(_lang) ?? ''),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _tl('Oyunlara Dön', 'Back to Games', 'Zu den Spielen', 'Volver a los juegos'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _tl('Yeni Oyun', 'New Game', 'Neue Partie', 'Nueva partida'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            if (_sonucAcik &&
                _gameResult != GameResult.loss &&
                _currentUser != null)
              TextButton(
                onPressed: () async {
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => GameResultScreen(
                        userId: _currentUser!.uid,
                        userName: _currentUser!.displayName,
                        gameType: GameType.chess,
                        score: _puan,
                        timeSeconds: _elapsedSeconds,
                        difficulty: _selectedDifficulty?.index,
                      ),
                    ),
                  );
                },
                child: Text(_tl('Skor Tablosu', 'Leaderboard', 'Bestenliste', 'Clasificación')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sonucCipi(IconData ikon, String yazi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 5),
          Text(yazi,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppTheme.darkBlue)),
        ],
      ),
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
      _lastMoveFrom = null;
      _lastMoveTo = null;
      _secili = null;
      _hedefler = const {};
      _alinanHedefler = const {};
      _sonucAcik = true;
    });
  }

  // ------------------------------------------------ dokunarak oynama

  /// Tahtadaki bir noktanin karesi (beyaz altta).
  String _kare(Offset p, double kenar) {
    final s = kenar / 8;
    final sutun = (p.dx / s).floor().clamp(0, 7);
    final satir = (p.dy / s).floor().clamp(0, 7);
    return '${'abcdefgh'[sutun]}${8 - satir}';
  }

  void _secimiTemizle() {
    if (_secili == null && _hedefler.isEmpty) return;
    setState(() {
      _secili = null;
      _hedefler = const {};
      _alinanHedefler = const {};
    });
  }

  /// Parmak tahtaya degdi. Kendi tasina degdiyse tas secilir ve
  /// gidebilecegi kareler gosterilir — surukleme baslarken de noktalar
  /// gorunuyor.
  void _kareyeBasildi(String kare) {
    if (!_cocukOynayabilir) return;
    // Secili tasin hedefine basildi: hamleyi dokunma bitince yapiyoruz.
    if (_secili != null && _hedefler.contains(kare)) return;
    final tas = _boardController.game.get(kare);
    if (tas != null && tas.color == chess_lib.Color.WHITE) {
      final hamleler =
          _boardController.game.generate_moves({'square': kare});
      setState(() {
        _secili = kare;
        _hedefler = {for (final m in hamleler) m.toAlgebraic};
        _alinanHedefler = {
          for (final m in hamleler)
            if (m.captured != null) m.toAlgebraic
        };
      });
    } else {
      _secimiTemizle();
    }
  }

  /// Dokunma (surukleme degil) bitti: secili tasin hedefiyse oyna.
  Future<void> _kareyeDokunuldu(String kare) async {
    if (!_cocukOynayabilir || _secili == null || !_hedefler.contains(kare)) {
      return;
    }
    final nereden = _secili!;
    final tas = _boardController.game.get(nereden);
    _secimiTemizle();
    // Piyon son siraya: dokunarak oynayan cocuga terfi sorulmuyor,
    // vezir oluyor (sureklemede paketin kendi secim penceresi acilir).
    if (tas?.type == chess_lib.PieceType.PAWN && kare[1] == '8') {
      _boardController.makeMoveWithPromotion(
          from: nereden, to: kare, pieceToPromoteTo: 'q');
    } else {
      _boardController.makeMove(from: nereden, to: kare);
    }
    SoundService.playDrop();
    await _onMove();
  }

  /// Sah tehdit altindaysa (ya da mat olduysa) onun karesi.
  String? _tehditAltindakiSah() {
    final oyun = _boardController.game;
    if (!oyun.in_check) return null;
    for (final dosya in 'abcdefgh'.split('')) {
      for (var sira = 1; sira <= 8; sira++) {
        final kare = '$dosya$sira';
        final t = oyun.get(kare);
        if (t != null &&
            t.type == chess_lib.PieceType.KING &&
            t.color == oyun.turn) {
          return kare;
        }
      }
    }
    return null;
  }

  /// Secili kare, hamle noktalari ve tehdit altindaki sah.
  /// IgnorePointer: dokunmalar alttaki tahtaya gidiyor.
  Widget _buildIpucuKatmani(double kenar) {
    final s = kenar / 8;
    Rect yer(String kare) {
      final x = kare.codeUnitAt(0) - 97;
      final y = 8 - int.parse(kare[1]);
      return Rect.fromLTWH(x * s, y * s, s, s);
    }

    final sah = _tehditAltindakiSah();
    return IgnorePointer(
      child: SizedBox(
        width: kenar,
        height: kenar,
        child: Stack(
          children: [
            if (sah != null)
              Positioned.fromRect(
                rect: yer(sah),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(colors: [
                      Colors.red.withValues(alpha: 0.85),
                      Colors.red.withValues(alpha: 0.25),
                    ]),
                  ),
                ),
              ),
            if (_secili != null)
              Positioned.fromRect(
                rect: yer(_secili!),
                child: Container(
                  color: const ui.Color(0xFF66BB6A).withValues(alpha: 0.45),
                ),
              ),
            for (final k in _hedefler)
              Positioned.fromRect(
                rect: yer(k),
                child: Center(
                  child: _alinanHedefler.contains(k)
                      // Alinabilecek tas: kareyi cevreleyen halka.
                      ? Container(
                          width: s * 0.92,
                          height: s * 0.92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.30),
                              width: s * 0.09,
                            ),
                          ),
                        )
                      : Container(
                          width: s * 0.30,
                          height: s * 0.30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.38),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OyunZemini.ustRenk(OyunKimligi.renk(GameType.chess)),
      appBar: OyunBasligi.oyun(
        GameType.chess,
        baslikWidget: Text(_tl('Satranç Oyunu', 'Chess Game', 'Schachspiel', 'Juego de ajedrez')),
        eylemler: [
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
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _showResetConfirmation(),
              tooltip: _tl('Yeni Oyun', 'New Game', 'Neue Partie', 'Nueva partida'),
            ),
          ],
        ],
      ),
      body: OyunZemini(
        renk: OyunKimligi.renk(GameType.chess),
        child: SafeArea(
          top: false,
          child:
              _isGameStarted ? _buildGameView() : _buildDifficultySelection()),
      ),
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
              Icons.psychology_rounded,
              size: 80,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 24),
            Text(
              _tl('Zorluk Seviyesi Seçin', 'Select Difficulty Level', 'Schwierigkeitsgrad wählen', 'Elige el nivel de dificultad'),
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
        icon = Icons.sports_esports_rounded;
        break;
      case ChessDifficulty.intermediate:
        cardColor = AppTheme.accentTeal;
        icon = Icons.sports;
        break;
      case ChessDifficulty.advanced:
        cardColor = AppTheme.errorRed;
        icon = Icons.military_tech_rounded;
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
                          Icon(Icons.star_rounded, size: 16, color: cardColor),
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
                Icon(Icons.arrow_forward_ios_rounded,
                    color: AppTheme.mediumGray),
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
                  _tl('AI düşünüyor...', 'AI is thinking...', 'Die KI denkt nach ...', 'La IA está pensando...'),
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
                  Icons.smart_toy_rounded,
                  size: 20,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 12),
                Text(
                  _tl('Rakip hamle: ${_convertMoveToTurkish(_lastAIMove!)}', 'Opponent move: ${_lastAIMove!}', 'Zug der Gegnerin: ${_lastAIMove!}', 'Jugada del rival: ${_lastAIMove!}'),
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
                    final maxWidth =
                        constraints.maxWidth - 24; // Space for rank numbers
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
                                  // SIRA KIMDEYSE O OYNAR.
                                  //
                                  // `enableUserMoves` sabit true idi:
                                  // bilgisayar dusunurken ya da hamle
                                  // uretemeyip sira siyahta kalinca
                                  // cocuk BILGISAYARIN taslarini
                                  // oynatabiliyordu. Oyun iki tarafi da
                                  // cocugun oynadigi bir seye donuyor,
                                  // ustelik "neden benim sıram gelmiyor"
                                  // diye anlasilmaz hale geliyordu.
                                  // Listener: parmak degdigi anda tas
                                  // secilir (surukleme baslarken de
                                  // noktalar gorunur). GestureDetector:
                                  // surukleme olmayan dokunma, secili
                                  // tasi noktaya goturur.
                                  Listener(
                                    behavior: HitTestBehavior.opaque,
                                    onPointerDown: (e) => _kareyeBasildi(
                                        _kare(e.localPosition, maxWidth)),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapUp: (d) => _kareyeDokunuldu(
                                          _kare(d.localPosition, maxWidth)),
                                      child: ChessBoard(
                                        controller: _boardController,
                                        boardColor: _selectedBoardColor,
                                        boardOrientation: PlayerColor.white,
                                        onMove: _onMove,
                                        enableUserMoves: _cocukOynayabilir,
                                      ),
                                    ),
                                  ),
                                  // Last move highlight overlay
                                  if (_lastMoveFrom != null &&
                                      _lastMoveTo != null)
                                    IgnorePointer(
                                        child: _buildMoveHighlightOverlay()),
                                  _buildIpucuKatmani(maxWidth),
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
                            children: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
                                .map((file) {
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

        // Oyun bittiyse sonuc paneli, surerken bilgi seridi.
        if (_gameResult != GameResult.ongoing)
          _buildSonucPaneli()
        else
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
                icon: Icons.timer_rounded,
                label: _formatDuration(_elapsedSeconds),
              ),
              _buildInfoChip(
                icon: Icons.swap_horiz_rounded,
                label: _tl('${_moveHistory.length} hamle', '${_moveHistory.length} moves', '${_moveHistory.length} Züge', '${_moveHistory.length} jugadas'),
              ),
              _buildInfoChip(
                icon: Icons.psychology_rounded,
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
                  _tl('Tema Seçin', 'Select Theme', 'Design wählen', 'Elige un tema'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // IKI TAHTA YETER (Ekim 2026): dort secenekten ikisi
                // (koyu kahverengi, turuncu) birbirine cok benziyordu.
                _buildThemeOption(
                    BoardColor.brown,
                    _tl('Klasik', 'Classic', 'Klassisch', 'Clásico'),
                    setDialogState),
                const SizedBox(height: 12),
                _buildThemeOption(BoardColor.green, _tl('Yeşil', 'Green', 'Grün', 'Verde'),
                    setDialogState),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        _tl('İptal', 'Cancel', 'Abbrechen', 'Cancelar'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: Text(
                        _tl('Başlat', 'Start', 'Starten', 'Empezar'),
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
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

  Widget _buildThemeOption(
      BoardColor color, String name, StateSetter setDialogState) {
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
    }
  }

  Future<void> _showResetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tl('Oyunu Sıfırla', 'Reset Game', 'Partie zurücksetzen', 'Reiniciar la partida')),
        content: Text(_tl('Mevcut oyun kaybolacak. Emin misiniz?', 'The current game will be lost. Are you sure?', 'Die aktuelle Partie geht verloren. Bist du sicher?', 'Se perderá la partida actual. ¿Seguro?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_tl('İptal', 'Cancel', 'Abbrechen', 'Cancelar')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text(_tl('Sıfırla', 'Reset', 'Zurücksetzen', 'Reiniciar')),
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
                    color: Colors.yellow.withValues(alpha: 0.35),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.8),
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
                    color: Colors.yellow.withValues(alpha: 0.45),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.9),
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
    if (firstChar.toUpperCase() == firstChar &&
        RegExp(r'[A-Z]').hasMatch(firstChar)) {
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
