import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// TODO: Migrate to Supabase
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme.dart';
import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import '../../utils/lang.dart';

/// 3D First-Person Maze Explorer Game
/// Uses ray-casting technique for pseudo-3D rendering
class Maze3DGameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const Maze3DGameScreen({
    super.key,
    required this.gameData,
  });

  @override
  State<Maze3DGameScreen> createState() => _Maze3DGameScreenState();
}

class _Maze3DGameScreenState extends State<Maze3DGameScreen> {
  // Player position and rotation
  double _playerX = 1.5;
  double _playerY = 1.5;
  double _playerAngle = 0.0;

  // Game state
  int _score = 0;
  int _moves = 0;
  int _coinsCollected = 0;
  int _totalCoins = 0;
  bool _gameWon = false;
  DateTime? _startTime;

  // Maze data (0 = empty, 1 = wall, 2 = coin, 3 = exit)
  late List<List<int>> _maze;
  final int _mazeSize = 12;

  // Collected coins tracker
  Set<String> _collectedCoins = {};

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  ///
  /// Onceki surumde her yerde `_isEn ? ingilizce : turkce` vardi; almanca
  /// ya da ispanyolca secen cocuk oyunun tamamini turkce goruyordu.
  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  // Movement constants
  static const double _moveSpeed = 0.15;
  static const double _rotateSpeed = 0.08;
  static const double _fov = math.pi / 3; // 60 degrees
  static const int _rayCount = 120;

  // Colors - Stone castle theme like the image
  static const Color _wallColor = Color(0xFF9E9E9E); // Light gray stone
  static const Color _wallDarkColor = Color(0xFF616161); // Dark gray stone
  static const Color _floorColor = Color(0xFF4CAF50); // Grass green
  static const Color _ceilingColor = Color(0xFF87CEEB); // Sky blue
  static const Color _coinColor = Color(0xFFFFD700); // Gold
  static const Color _exitColor = Color(0xFF8B4513); // Castle brown

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (Labirent). Ekran tamamen sessizdi ve
    // bir onceki oyunun ses rengini devraliyordu.
    SoundService.useVoice(SfxVoice.deep);
    _startTime = DateTime.now();
    _generateMaze();
    _setupKeyboardListener();
  }

  void _setupKeyboardListener() {
    // Keyboard focus for desktop/web
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }

  void _generateMaze() {
    // Create maze with recursive backtracker algorithm
    _maze = List.generate(
      _mazeSize,
      (y) => List.generate(_mazeSize, (x) => 1),
    );

    // Generate paths using recursive backtracking
    _carvePath(1, 1);

    // Set start position (clear area)
    _maze[1][1] = 0;
    _maze[1][2] = 0;
    _maze[2][1] = 0;

    // Set exit position
    _maze[_mazeSize - 2][_mazeSize - 2] = 3;
    _maze[_mazeSize - 2][_mazeSize - 3] = 0;
    _maze[_mazeSize - 3][_mazeSize - 2] = 0;

    // Add coins in empty spaces
    _totalCoins = 0;
    for (int y = 1; y < _mazeSize - 1; y++) {
      for (int x = 1; x < _mazeSize - 1; x++) {
        if (_maze[y][x] == 0 && math.Random().nextDouble() < 0.15) {
          _maze[y][x] = 2;
          _totalCoins++;
        }
      }
    }
  }

  void _carvePath(int x, int y) {
    final directions = [
      [0, -2],
      [2, 0],
      [0, 2],
      [-2, 0]
    ]..shuffle();

    for (var dir in directions) {
      final nx = x + dir[0];
      final ny = y + dir[1];

      if (nx > 0 &&
          nx < _mazeSize - 1 &&
          ny > 0 &&
          ny < _mazeSize - 1 &&
          _maze[ny][nx] == 1) {
        _maze[ny][nx] = 0;
        _maze[y + dir[1] ~/ 2][x + dir[0] ~/ 2] = 0;
        _carvePath(nx, ny);
      }
    }
  }

  void _moveForward() {
    final newX = _playerX + math.cos(_playerAngle) * _moveSpeed;
    final newY = _playerY + math.sin(_playerAngle) * _moveSpeed;
    _tryMove(newX, newY);
  }

  void _moveBackward() {
    final newX = _playerX - math.cos(_playerAngle) * _moveSpeed;
    final newY = _playerY - math.sin(_playerAngle) * _moveSpeed;
    _tryMove(newX, newY);
  }

  void _strafeLeft() {
    final newX = _playerX + math.cos(_playerAngle - math.pi / 2) * _moveSpeed;
    final newY = _playerY + math.sin(_playerAngle - math.pi / 2) * _moveSpeed;
    _tryMove(newX, newY);
  }

  void _strafeRight() {
    final newX = _playerX + math.cos(_playerAngle + math.pi / 2) * _moveSpeed;
    final newY = _playerY + math.sin(_playerAngle + math.pi / 2) * _moveSpeed;
    _tryMove(newX, newY);
  }

  void _tryMove(double newX, double newY) {
    final mapX = newX.floor();
    final mapY = newY.floor();

    if (mapX >= 0 && mapX < _mazeSize && mapY >= 0 && mapY < _mazeSize) {
      final cell = _maze[mapY][mapX];

      if (cell != 1) {
        setState(() {
          _playerX = newX;
          _playerY = newY;
          _moves++;

          // Collect coin
          if (cell == 2) {
            final coinKey = '$mapX,$mapY';
            if (!_collectedCoins.contains(coinKey)) {
              _collectedCoins.add(coinKey);
              _maze[mapY][mapX] = 0;
              _coinsCollected++;
              _score += 10;
              _showMessage(_tl('🪙 Altın topladın! +10 puan', '🪙 You collected gold! +10 points', '🪙 Du hast Gold gesammelt! +10 Punkte', '🪙 ¡Recogiste oro! +10 puntos'));
            }
          }

          // Reach exit
          if (cell == 3 && !_gameWon) {
            _gameWon = true;
            _winGame();
          }
        });
      }
    }
  }

  void _rotateLeft() {
    setState(() {
      _playerAngle -= _rotateSpeed;
    });
  }

  void _rotateRight() {
    setState(() {
      _playerAngle += _rotateSpeed;
    });
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 800),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  Future<void> _winGame() async {
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    final bonusScore =
        (_totalCoins > 0 ? (_coinsCollected / _totalCoins * 100).round() : 0);
    final timeBonus = math.max(0, 300 - duration);
    final finalScore = _score + bonusScore + timeBonus;

    // TODO: Migrate to Supabase
    // Save to Supabase Database
    try {
      /*
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('maze_3d_scores').add({
          'userId': user.uid,
          'userName': user.displayName ?? 'Oyuncu',
          'score': finalScore,
          'coins': _coinsCollected,
          'moves': _moves,
          'duration': duration,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      */

      // Placeholder - TODO: Implement with Supabase
      debugPrint('Score save pending Supabase migration');
    } catch (e) {
      debugPrint('Error saving score: $e');
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.emoji_events_rounded,
                  color: AppTheme.successGreen, size: 32),
              const SizedBox(width: 12),
              Text(_tl('🎉 Tebrikler!', '🎉 Congratulations!', '🎉 Glückwunsch!', '🎉 ¡Felicidades!')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tl('Labirenti başarıyla tamamladın!', 'You successfully completed the maze!', 'Du hast das Labyrinth geschafft!', '¡Completaste el laberinto!'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildStatRow(_tl('🏆 Toplam Puan', '🏆 Total Score', '🏆 Gesamtpunkte', '🏆 Puntos totales'),
                  finalScore.toString()),
              _buildStatRow(_tl('🪙 Altınlar', '🪙 Gold', '🪙 Gold', '🪙 Oro'),
                  '$_coinsCollected / $_totalCoins'),
              _buildStatRow(_tl('👣 Adım Sayısı', '👣 Step Count', '👣 Anzahl der Schritte', '👣 Número de pasos'),
                  _moves.toString()),
              _buildStatRow(_tl('⏱️ Süre', '⏱️ Time', '⏱️ Zeit', '⏱️ Tiempo'), '${duration}s'),
              _buildStatRow(
                  _tl('⭐ Bonus', '⭐ Bonus', '⭐ Bonus', '⭐ Bonus'),
                  _tl('+$bonusScore (altın) +$timeBonus (zaman)', '+$bonusScore (gold) +$timeBonus (time)', '+$bonusScore (Gold) +$timeBonus (Zeit)', '+$bonusScore (oro) +$timeBonus (tiempo)')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(_tl('Ana Menü', 'Main Menu', 'Hauptmenü', 'Menú principal')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _playerX = 1.5;
                  _playerY = 1.5;
                  _playerAngle = 0.0;
                  _score = 0;
                  _moves = 0;
                  _coinsCollected = 0;
                  _gameWon = false;
                  _collectedCoins.clear();
                  _startTime = DateTime.now();
                  _generateMaze();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(_tl('Yeni Oyun', 'New Game', 'Neue Partie', 'Nueva partida')),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // Sky blue background
      body: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Main game view
              Column(
                children: [
                  // 3D View with outdoor theme
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF87CEEB), // Sky blue
                            Color(0xFF4CAF50), // Grass green at horizon
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _Maze3DPainter(
                          playerX: _playerX,
                          playerY: _playerY,
                          playerAngle: _playerAngle,
                          maze: _maze,
                          mazeSize: _mazeSize,
                        ),
                      ),
                    ),
                  ),

                  // Controls at bottom
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Forward
                        _buildControlButton(Icons.arrow_upward_rounded,
                            _moveForward, _tl('İleri', 'Forward', 'Vorwärts', 'Adelante')),
                        const SizedBox(height: 4),
                        // Left/Right movement and rotation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlButton(
                                Icons.rotate_left_rounded, _rotateLeft, '←'),
                            _buildControlButton(
                                Icons.arrow_back_rounded, _strafeLeft, '◀'),
                            _buildControlButton(Icons.arrow_downward_rounded,
                                _moveBackward, '▼'),
                            _buildControlButton(
                                Icons.arrow_forward_rounded, _strafeRight, '▶'),
                            _buildControlButton(
                                Icons.rotate_right_rounded, _rotateRight, '→'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // HUD Overlay - Top stats
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Time and coins
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${DateTime.now().difference(_startTime!).inSeconds}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Coins collected
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_coinsCollected/$_totalCoins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.circle_rounded,
                              color: Colors.amber, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Mini-map overlay
              Positioned(
                top: 100,
                right: 16,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CustomPaint(
                      painter: _MiniMapPainter(
                        playerX: _playerX,
                        playerY: _playerY,
                        playerAngle: _playerAngle,
                        maze: _maze,
                        mazeSize: _mazeSize,
                      ),
                    ),
                  ),
                ),
              ),

              // Back button
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildControlButton(
      IconData icon, VoidCallback onPressed, String tooltip) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[700]!,
            Colors.grey[900]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 24,
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Custom painter for 3D ray-casting view
class _Maze3DPainter extends CustomPainter {
  final double playerX;
  final double playerY;
  final double playerAngle;
  final List<List<int>> maze;
  final int mazeSize;

  _Maze3DPainter({
    required this.playerX,
    required this.playerY,
    required this.playerAngle,
    required this.maze,
    required this.mazeSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Draw sky with gradient
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.center,
      colors: [
        _Maze3DGameScreenState._ceilingColor,
        _Maze3DGameScreenState._ceilingColor.withValues(alpha: 0.8),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenWidth, screenHeight / 2),
      Paint()
        ..shader = skyGradient
            .createShader(Rect.fromLTWH(0, 0, screenWidth, screenHeight / 2)),
    );

    // Draw floor with grass texture effect
    final floorGradient = LinearGradient(
      begin: Alignment.center,
      end: Alignment.bottomCenter,
      colors: [
        _Maze3DGameScreenState._floorColor.withValues(alpha: 0.9),
        _Maze3DGameScreenState._floorColor,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, screenHeight / 2, screenWidth, screenHeight / 2),
      Paint()
        ..shader = floorGradient.createShader(
            Rect.fromLTWH(0, screenHeight / 2, screenWidth, screenHeight / 2)),
    );

    // Ray casting
    const rayCount = _Maze3DGameScreenState._rayCount;
    const fov = _Maze3DGameScreenState._fov;

    for (int ray = 0; ray < rayCount; ray++) {
      final rayAngle = playerAngle - fov / 2 + (ray / rayCount) * fov;
      final rayDirX = math.cos(rayAngle);
      final rayDirY = math.sin(rayAngle);

      // Cast ray
      double distance = 0.0;
      bool hitWall = false;
      int hitType = 0;
      const maxDistance = 20.0;
      const step = 0.05;

      while (!hitWall && distance < maxDistance) {
        distance += step;
        final testX = playerX + rayDirX * distance;
        final testY = playerY + rayDirY * distance;
        final mapX = testX.floor();
        final mapY = testY.floor();

        if (mapX >= 0 && mapX < mazeSize && mapY >= 0 && mapY < mazeSize) {
          final cell = maze[mapY][mapX];
          if (cell == 1) {
            hitWall = true;
            hitType = 1;
          } else if (cell == 2) {
            hitWall = true;
            hitType = 2;
          } else if (cell == 3) {
            hitWall = true;
            hitType = 3;
          }
        } else {
          hitWall = true;
          hitType = 1;
        }
      }

      // Fix fish-eye effect
      distance *= math.cos(rayAngle - playerAngle);

      // Calculate wall height
      final wallHeight =
          distance > 0 ? (screenHeight / distance) : screenHeight;
      final wallTop = (screenHeight - wallHeight) / 2;

      // Draw wall slice
      final sliceWidth = screenWidth / rayCount;
      final x = ray * sliceWidth;

      Color wallColor;
      if (hitType == 2) {
        // Coin - draw as 3D sphere
        wallColor = _Maze3DGameScreenState._coinColor;
        final coinCenter = Offset(x + sliceWidth / 2, screenHeight / 2);
        final coinRadius = (wallHeight / 4).clamp(10.0, 30.0);

        // Coin glow
        canvas.drawCircle(
          coinCenter,
          coinRadius + 5,
          Paint()
            ..color = _Maze3DGameScreenState._coinColor.withValues(alpha: 0.3),
        );

        // Coin body with gradient
        final coinGradient = RadialGradient(
          colors: [
            _Maze3DGameScreenState._coinColor.withValues(alpha: 0.9),
            _Maze3DGameScreenState._coinColor,
            Colors.orange[900]!,
          ],
        );
        canvas.drawCircle(
          coinCenter,
          coinRadius,
          Paint()
            ..shader = coinGradient.createShader(
              Rect.fromCircle(center: coinCenter, radius: coinRadius),
            ),
        );
        // BURADA `return` VARDI.
        //
        // Isin taramasi ekrani soldan saga dilim dilim ciziyor. Bir dilim
        // madeni paraya carptiginda `return` butun donguyu bitiriyor,
        // yani o paranin SAGINDA kalan her duvar dilimi hic cizilmiyordu:
        // ekranin sag tarafi bos gokyuzu/zemin olarak kaliyordu. Kodda
        // bir korumaya benziyor, aslinda cizimi yarida kesiyor.
        continue;
      } else if (hitType == 3) {
        // Exit - castle/door with texture
        final shade = (1.0 - (distance / maxDistance)).clamp(0.0, 1.0);
        wallColor = Color.lerp(
          Colors.black,
          _Maze3DGameScreenState._exitColor,
          shade,
        )!;
      } else {
        // Stone wall with shading and texture
        final shade = (1.0 - (distance / maxDistance)).clamp(0.0, 1.0);

        // Alternate between light and dark stones for texture
        final isLightStone = (ray % 3 == 0);
        final baseColor = isLightStone
            ? _Maze3DGameScreenState._wallColor
            : _Maze3DGameScreenState._wallDarkColor;

        wallColor = Color.lerp(
          Colors.black,
          baseColor,
          shade * shade, // Square for more dramatic lighting
        )!;
      }

      // Draw wall with slight gradient for 3D effect
      final wallGradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          wallColor.withValues(alpha: 0.8),
          wallColor,
          wallColor.withValues(alpha: 0.8),
        ],
      );

      canvas.drawRect(
        Rect.fromLTWH(x, wallTop, sliceWidth + 1, wallHeight),
        Paint()
          ..shader = wallGradient.createShader(
            Rect.fromLTWH(x, wallTop, sliceWidth + 1, wallHeight),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_Maze3DPainter oldDelegate) => true;
}

/// Mini-map painter
class _MiniMapPainter extends CustomPainter {
  final double playerX;
  final double playerY;
  final double playerAngle;
  final List<List<int>> maze;
  final int mazeSize;

  _MiniMapPainter({
    required this.playerX,
    required this.playerY,
    required this.playerAngle,
    required this.maze,
    required this.mazeSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = math.min(size.width, size.height) / mazeSize;

    // Draw maze
    for (int y = 0; y < mazeSize; y++) {
      for (int x = 0; x < mazeSize; x++) {
        Color color;
        switch (maze[y][x]) {
          case 1:
            color = Colors.grey[800]!;
            break;
          case 2:
            color = Colors.amber;
            break;
          case 3:
            color = Colors.green;
            break;
          default:
            color = Colors.grey[700]!;
        }

        canvas.drawRect(
          Rect.fromLTWH(x * cellSize, y * cellSize, cellSize - 1, cellSize - 1),
          Paint()..color = color,
        );
      }
    }

    // Draw player
    final playerPixelX = playerX * cellSize;
    final playerPixelY = playerY * cellSize;

    canvas.drawCircle(
      Offset(playerPixelX, playerPixelY),
      cellSize / 3,
      Paint()..color = Colors.blue,
    );

    // Draw direction indicator
    final dirEndX = playerPixelX + math.cos(playerAngle) * cellSize;
    final dirEndY = playerPixelY + math.sin(playerAngle) * cellSize;

    canvas.drawLine(
      Offset(playerPixelX, playerPixelY),
      Offset(dirEndX, dirEndY),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_MiniMapPainter oldDelegate) => true;
}
