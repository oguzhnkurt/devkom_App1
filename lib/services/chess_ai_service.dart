import 'dart:async';
import 'dart:math';
import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/foundation.dart';
import '../models/chess_game_model.dart';
import 'satranc_rakip.dart';

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
  late final SatrancRakip _rakip = SatrancRakip(_random);

  /// Orta seviyede motor yerine "dikkatli ama kusurlu" rakibin oynadigi
  /// hamlelerin orani. Stockfish'in en zayif ayari bile cocuk icin
  /// fazla isabetli; arada bir insani bir hamle geliyor.
  static const double ortaInsaniHamle = 0.25;

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
    // KOLAY: motor hic kullanilmiyor. Stockfish'in en zayif ayari bile
    // yeni baslayan bir cocuk icin fazla gucluydu (bkz. satranc_rakip.dart).
    if (difficulty == ChessDifficulty.beginner) {
      await Future.delayed(const Duration(milliseconds: 450));
      return _rakip.kolayHamle(game);
    }

    // ORTA: dortte bir hamle insani rakipten.
    if (difficulty == ChessDifficulty.intermediate &&
        _random.nextDouble() < ortaInsaniHamle) {
      await Future.delayed(const Duration(milliseconds: 450));
      return _rakip.dikkatliHamle(game, gurultu: 120);
    }

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

  /// Motorsuz rakip (web, motorun kalkmadigi cihaz ya da motor
  /// sustugunda). Seviyeler motorlu halin kabaca karsiligi.
  String? _getSimpleAIMove(chess_lib.Chess game, ChessDifficulty difficulty) {
    try {
      switch (difficulty) {
        case ChessDifficulty.beginner:
          return _rakip.kolayHamle(game);
        case ChessDifficulty.intermediate:
          return _rakip.dikkatliHamle(game, gurultu: 120);
        case ChessDifficulty.advanced:
          return _rakip.dikkatliHamle(game, gurultu: 30);
        case ChessDifficulty.impossible:
          return _rakip.dikkatliHamle(game, gurultu: 0);
      }
    } catch (e) {
      debugPrint('❌ Error in simple AI: $e');
      return null;
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
      // Kolay seviye motoru kullanmiyor (getBestMove); bu deger yalnizca
      // bir gun motora dusulurse diye en zayif ayar.
      case ChessDifficulty.beginner:
        return 0;
      // ORTA: eskiden 10'du — "orta" adi altinda neredeyse usta. Cocuk
      // icin ne zor ne kolay: 3 ve kisa dusunme suresi, ustune dortte
      // bir insani hamle.
      case ChessDifficulty.intermediate:
        return 3;
      // ZOR: eskiden 20'ydi ve "Ileri" adiyla cocugun karsisina tam guc
      // cikiyordu. 6: deneme maclarinda Orta'yi 8/8 ve Elo 1700 ayarli
      // Stockfish'i 8/8 yendi; guclu ama yenilebilir bir rakip.
      case ChessDifficulty.advanced:
        return 6;
      case ChessDifficulty.impossible:
        return 20; // Maximum strength
    }
  }

  /// Think time in milliseconds
  int get thinkTimeMs {
    switch (this) {
      case ChessDifficulty.beginner:
        return 500; // 0.5 seconds
      case ChessDifficulty.intermediate:
        return 300;
      case ChessDifficulty.advanced:
        return 600;
      case ChessDifficulty.impossible:
        return 2000; // 2 seconds
    }
  }
}
