import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/game_model.dart';
import 'games/chess_game_screen.dart';
import 'games/coordinates_game_screen.dart';
import 'games/block_coding_game_screen.dart';
import 'games/word_match_game_screen.dart';
import 'games/sequencing_game_screen.dart';
import 'games/maze_explorer_game_screen.dart';
import 'games/maze_3d_game_screen.dart';
import 'games/left_right_coding_game_screen.dart';
import 'games/arduino_blocks_game_screen.dart';
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

  const GamePlayScreen({super.key, required this.game});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

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
        // Eski breadboard simulatoru kaldirildi (telefonda kablolama
        // calismiyordu, bkz. ArduinoBlocksGameScreen'in basindaki not).
        return ArduinoBlocksGameScreen(gameData: widget.game.gameData);
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
