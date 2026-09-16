import 'dart:async';
import 'dart:math';
import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/foundation.dart';
import '../models/chess_game_model.dart';

// Conditional import for stockfish - use stub on web
import 'package:stockfish_chess_engine/stockfish_chess_engine.dart'
    if (dart.library.js) 'chess_ai_web_stub.dart';

/// Professional Chess AI Service using Stockfish Engine (when available)
/// Provides high-quality chess moves using the Stockfish chess engine on mobile/desktop
/// Falls back to simple AI on web platform
class ChessAIService {
  // Singleton pattern
  static final ChessAIService _instance = ChessAIService._internal();
  factory ChessAIService() => _instance;
  ChessAIService._internal();

  dynamic _stockfish; // Using dynamic to avoid type issues on web
  StreamSubscription? _stockfishSubscription;
  Completer<String?>? _moveCompleter;
  bool _isInitialized = false;

  /// Stockfish GERCEKTEN ayaga kalkti mi.
  ///
  /// [_isInitialized] "hazirlanma denemesi bitti" demek; bu ise "guclu
  /// motor var" demek. Ikisini ayirmak gerekiyordu cunku motor
  /// kalkmadiginda oyun yine de oynanabilir: basit yapay zeka hazir
  /// bekliyor.
  bool _stockfishReady = false;
  final _random = Random();

  /// Oyun su an basit yapay zekayla mi oynaniyor.
  bool get usingSimpleAI => kIsWeb || !_stockfishReady;

  /// Check if Stockfish is available on this platform
  bool get isStockfishAvailable => !kIsWeb;

  /// Initialize Stockfish engine (only on supported platforms)
  Future<void> initialize() async {
    // Skip initialization on web
    if (kIsWeb) {
      debugPrint('ℹ️ Running on web - using simple AI instead of Stockfish');
      _isInitialized = true;
      _stockfishReady = false;
      return;
    }

    if (_isInitialized && _stockfish != null) {
      debugPrint('✅ Stockfish already initialized');
      return;
    }

    // Clean up any existing instance first
    if (_stockfish != null) {
      debugPrint('🧹 Cleaning up existing Stockfish instance');
      _stockfishSubscription?.cancel();
      _stockfish?.dispose();
      _stockfish = null;
      _isInitialized = false;
      _stockfishReady = false;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      _stockfish = Stockfish();

      final uciOkCompleter = Completer<void>();
      final readyOkCompleter = Completer<void>();

      // Subscribe to engine output
      _stockfishSubscription = _stockfish!.stdout.listen((line) {
        debugPrint('🤖 Stockfish: $line');

        // Parse uciok response
        if (line == 'uciok' && !uciOkCompleter.isCompleted) {
          uciOkCompleter.complete();
        }

        // Parse readyok response
        if (line == 'readyok' && !readyOkCompleter.isCompleted) {
          readyOkCompleter.complete();
        }

        // Parse bestmove response
        if (line.startsWith('bestmove')) {
          final parts = line.split(' ');
          if (parts.length >= 2) {
            final move = parts[1];
            if (_moveCompleter != null && !_moveCompleter!.isCompleted) {
              _moveCompleter!.complete(move);
            }
          }
        }
      });

      // Wait for Stockfish to be ready before sending commands
      debugPrint('⏳ Waiting for Stockfish to be ready...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize engine with proper handshake
      _stockfish!.stdin = 'uci';
      await uciOkCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Stockfish UCI timeout');
        },
      );

      _stockfish!.stdin = 'isready';
      await readyOkCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Stockfish ready timeout');
        },
      );

      _isInitialized = true;
      _stockfishReady = true;
      debugPrint('✅ Stockfish engine initialized');
    } catch (e) {
      // BILEREK RETHROW YOK.
      //
      // Eskiden burasi hatayi yukari atiyordu; ekran da onu yakalayip
      // cocugu zorluk secim ekranina geri gonderiyordu. Yani motor
      // kalkmadiginda satranc HIC oynanamiyordu — oysa web icin yazilmis
      // basit yapay zeka her platformda calisiyor ve [getBestMove] zaten
      // ona dusuyor. Motor yoksa oyun basit rakiple devam etsin.
      debugPrint('⚠️ Stockfish baslamadi, basit yapay zekaya dusuluyor: $e');
      _stockfishSubscription?.cancel();
      _stockfishSubscription = null;
      _stockfish = null;
      _stockfishReady = false;
      _isInitialized = true;
    }
  }

  /// Get best move for AI based on difficulty
  Future<String?> getBestMove({
    required chess_lib.Chess game,
    required ChessDifficulty difficulty,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Web'de ve motorun kalkmadigi cihazlarda basit yapay zeka.
    if (usingSimpleAI || _stockfish == null) {
      return _getSimpleAIMove(game, difficulty);
    }

    try {
      // Create new completer for this move
      _moveCompleter = Completer<String?>();

      // Get skill level and think time based on difficulty
      final skillLevel = difficulty.stockfishSkillLevel;
      final thinkTime = difficulty.thinkTimeMs;

      debugPrint('🎯 AI Difficulty: ${difficulty.name}, Skill: $skillLevel, Time: ${thinkTime}ms');

      // Start new game
      _stockfish!.stdin = 'ucinewgame';
      await Future.delayed(const Duration(milliseconds: 50));

      // Set skill level (0-20, where 20 is strongest)
      _stockfish!.stdin = 'setoption name Skill Level value $skillLevel';
      await Future.delayed(const Duration(milliseconds: 50));

      // Set position
      final fen = game.fen;
      _stockfish!.stdin = 'position fen $fen';
      await Future.delayed(const Duration(milliseconds: 50));

      // Request best move with time limit
      _stockfish!.stdin = 'go movetime $thinkTime';

      // Wait for response with timeout
      final uciMove = await _moveCompleter!.future.timeout(
        Duration(milliseconds: thinkTime + 1000),
        onTimeout: () {
          debugPrint('⚠️ Stockfish timeout, returning null');
          return null;
        },
      );

      // MOTOR SESSIZ KALIRSA BASIT RAKIBE DUS.
      //
      // Zaman asimi, '(none)' ya da cevrilemeyen bir hamle null
      // donuyordu; ekran da null gelince HICBIR SEY yapmiyordu. Sonuc:
      // sira siyahta kaliyor, tahta kilitleniyor ve cocuk bilgisayarin
      // taslarini oynatmaya basliyordu. Artik motor bir sey uretmezse
      // basit yapay zeka hamleyi yapiyor; oyun duruyormus gibi
      // gorunmuyor.
      if (uciMove == null || uciMove == '(none)') {
        debugPrint('⚠️ Stockfish hamle vermedi, basit yapay zekaya dusuluyor');
        return _getSimpleAIMove(game, difficulty);
      }

      // Convert UCI format (e2e4) to SAN format (e4)
      final sanMove = _convertUciToSan(game, uciMove);
      debugPrint('✅ Stockfish move: $uciMove → $sanMove');

      return sanMove ?? _getSimpleAIMove(game, difficulty);
    } catch (e) {
      debugPrint('❌ Error getting move from Stockfish: $e');
      // Fallback to simple AI if Stockfish fails
      return _getSimpleAIMove(game, difficulty);
    }
  }

  /// Simple AI for web platform or fallback
  /// Uses basic chess logic to pick moves
  String? _getSimpleAIMove(chess_lib.Chess game, ChessDifficulty difficulty) {
    try {
      final moves = game.generate_moves();
      if (moves.isEmpty) return null;

      debugPrint('🎲 Using simple AI - ${moves.length} legal moves');

      // For beginner difficulty, pick random move
      if (difficulty == ChessDifficulty.beginner) {
        final move = moves[_random.nextInt(moves.length)];
        return game.move_to_san(move);
      }

      // For intermediate/advanced, prefer captures and center control
      // Prioritize: checkmate > capture > center control > random
      chess_lib.Move? bestMove;
      int bestScore = -999999;

      for (final move in moves) {
        int score = 0;

        // Make the move temporarily to evaluate
        final tempGame = chess_lib.Chess.fromFEN(game.fen);
        tempGame.move({'from': move.fromAlgebraic, 'to': move.toAlgebraic});

        // Check for checkmate (highest priority)
        if (tempGame.in_checkmate) {
          score += 10000;
        }

        // Check for check
        if (tempGame.in_check) {
          score += 50;
        }

        // Prefer captures
        if (move.captured != null) {
          score += _getPieceValue(move.captured!) + 100;
        }

        // Prefer center control (e4, d4, e5, d5)
        if (['e4', 'd4', 'e5', 'd5'].contains(move.toAlgebraic)) {
          score += 30;
        }

        // Avoid losing pieces (check if move square is attacked)
        // This is a simplified check
        score -= _getPieceValue(move.piece) ~/ 10;

        // Add randomness for variety (more for beginner)
        if (difficulty == ChessDifficulty.intermediate) {
          score += _random.nextInt(20);
        } else {
          score += _random.nextInt(10);
        }

        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
      }

      if (bestMove != null) {
        final sanMove = game.move_to_san(bestMove);
        debugPrint('✅ Simple AI move: $sanMove (score: $bestScore)');
        return sanMove;
      }

      // Fallback to random
      final move = moves[_random.nextInt(moves.length)];
      return game.move_to_san(move);
    } catch (e) {
      debugPrint('❌ Error in simple AI: $e');
      return null;
    }
  }

  /// Get piece value for simple evaluation
  int _getPieceValue(chess_lib.PieceType piece) {
    switch (piece) {
      case chess_lib.PieceType.PAWN:
        return 100;
      case chess_lib.PieceType.KNIGHT:
      case chess_lib.PieceType.BISHOP:
        return 300;
      case chess_lib.PieceType.ROOK:
        return 500;
      case chess_lib.PieceType.QUEEN:
        return 900;
      case chess_lib.PieceType.KING:
        return 10000;
      default:
        return 0; // Unknown piece type
    }
  }

  /// Convert UCI move format (e2e4) to SAN format (e4)
  String? _convertUciToSan(chess_lib.Chess game, String uciMove) {
    try {
      // UCI format: from square + to square (e.g., e2e4)
      if (uciMove.length < 4) return null;

      final from = uciMove.substring(0, 2);
      final to = uciMove.substring(2, 4);

      // Get all legal moves
      final moves = game.generate_moves();

      // Find matching move
      for (final move in moves) {
        if (move.fromAlgebraic == from && move.toAlgebraic == to) {
          // Make move to get SAN notation
          final tempGame = chess_lib.Chess.fromFEN(game.fen);
          tempGame.move({'from': from, 'to': to});

          // Get the move in SAN format
          return game.move_to_san(move);
        }
      }

      debugPrint('⚠️ Could not convert UCI move $uciMove to SAN');
      return null;
    } catch (e) {
      debugPrint('❌ Error converting UCI to SAN: $e');
      return null;
    }
  }

  /// Reset engine for new game (don't dispose, just reset state)
  Future<void> resetForNewGame() async {
    if (kIsWeb) return; // Nothing to reset on web

    if (_stockfish != null && _isInitialized) {
      debugPrint('♻️ Resetting Stockfish for new game');
      _stockfish!.stdin = 'ucinewgame';
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Dispose engine resources
  void dispose() {
    if (kIsWeb) return; // Nothing to dispose on web

    _stockfishSubscription?.cancel();
    _stockfish?.dispose();
    _stockfish = null;
    _isInitialized = false;
    _stockfishReady = false;
    debugPrint('🗑️ Stockfish engine disposed');
  }
}

/// Extension for Stockfish configuration based on difficulty
extension on ChessDifficulty {
  /// Stockfish skill level (0-20)
  int get stockfishSkillLevel {
    switch (this) {
      case ChessDifficulty.beginner:
        return 1; // Very weak
      case ChessDifficulty.intermediate:
        return 10; // Medium strength
      case ChessDifficulty.advanced:
        return 20; // Maximum strength
    }
  }

  /// Think time in milliseconds
  int get thinkTimeMs {
    switch (this) {
      case ChessDifficulty.beginner:
        return 500; // 0.5 seconds
      case ChessDifficulty.intermediate:
        return 1000; // 1 second
      case ChessDifficulty.advanced:
        return 1500; // 1.5 seconds
    }
  }
}
