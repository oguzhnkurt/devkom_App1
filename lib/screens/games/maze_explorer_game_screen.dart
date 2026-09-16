import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import '../../ui/motion.dart';
import '../../utils/lang.dart';

class MazeExplorerGameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const MazeExplorerGameScreen({
    super.key,
    required this.gameData,
  });

  @override
  State<MazeExplorerGameScreen> createState() => _MazeExplorerGameScreenState();
}

class _MazeExplorerGameScreenState extends State<MazeExplorerGameScreen> {
  int _playerX = 0;
  int _playerY = 0;
  int _goalX = 7;
  int _goalY = 7;
  int _score = 0;
  int _moves = 0;

  // 0 = path, 1 = wall, 2 = coin
  List<List<int>> _maze = [];

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
    // Bu ekranin ses rengi (Labirent kasifi). Ekran tamamen sessizdi ve
    // bir onceki oyunun ses rengini devraliyordu.
    SoundService.useVoice(SfxVoice.soft);
    _generateMaze();
  }

  void _generateMaze() {
    // ÖNEMLİ: Eski üretim yalnızca (x + y) % 3 == 0 formülüyle duvar
    // koyuyordu. Bu formül x+y=6 ve x+y=9 köşegenlerinde IZGARA GENİŞLİĞİ
    // KADAR ARALIKSIZ (boşluksuz) duvar satırları oluşturuyordu, yani
    // labirentin çözülmesi matematiksel olarak imkansızdı - kukla her
    // yönde siyah bloklara (duvarlara) takılıp kalıyordu.
    //
    // Düzeltme: önce başlangıçtan hedefe rastgele ama garanti açık bir yol
    // oyuyoruz (staircase/basamak yolu), sonra duvarları ve paraları sadece
    // bu garanti yolun DIŞINDAKİ hücrelere rastgele dağıtıyoruz. Böylece
    // labirent her zaman çözülebilir oluyor.
    final rng = Random();
    _maze = List.generate(8, (_) => List.generate(8, (_) => 0));

    // 1) Başlangıçtan hedefe garanti bir yol oy (sadece sağa/aşağı hareket)
    final Set<String> guaranteedPath = {};
    int cx = 0, cy = 0;
    guaranteedPath.add('$cx,$cy');
    while (cx != _goalX || cy != _goalY) {
      final canRight = cx < _goalX;
      final canDown = cy < _goalY;
      if (canRight && (!canDown || rng.nextBool())) {
        cx++;
      } else if (canDown) {
        cy++;
      }
      guaranteedPath.add('$cx,$cy');
    }

    // 2) Duvarları sadece garanti yolun dışındaki hücrelere rastgele dağıt
    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        if (guaranteedPath.contains('$x,$y')) continue;
        if (rng.nextDouble() < 0.3) {
          _maze[y][x] = 1; // wall
        }
      }
    }

    // 3) Kalan açık hücrelere (duvar olmayan, başlangıç/hedef olmayan) para dağıt
    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        if (_maze[y][x] == 1) continue;
        if (x == 0 && y == 0) continue;
        if (x == _goalX && y == _goalY) continue;
        if (rng.nextDouble() < 0.15) {
          _maze[y][x] = 2; // coin
        }
      }
    }
  }

  void _movePlayer(int dx, int dy) {
    final newX = _playerX + dx;
    final newY = _playerY + dy;

    // Check boundaries
    if (newX < 0 || newX >= 8 || newY < 0 || newY >= 8) return;

    // Check walls
    if (_maze[newY][newX] == 1) {
      _showMessage(_tl('❌ Duvara çarptın!', '❌ You hit a wall!', '❌ Du bist gegen eine Wand gelaufen!', '❌ ¡Chocaste con una pared!'));
      return;
    }

    setState(() {
      _playerX = newX;
      _playerY = newY;
      _moves++;

      // Collect coin
      if (_maze[newY][newX] == 2) {
        _maze[newY][newX] = 0;
        _score += 10;
        _showMessage(_tl('🪙 +10 puan!', '🪙 +10 points!', '🪙 +10 Punkte!', '🪙 ¡+10 puntos!'));
      }

      // Check goal
      if (_playerX == _goalX && _playerY == _goalY) {
        _showWinDialog();
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_tl('🎉 Tebrikler!', '🎉 Congratulations!', '🎉 Glückwunsch!', '🎉 ¡Felicidades!')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_tl('Labirenti tamamladın!', 'You completed the maze!', 'Du hast das Labyrinth geschafft!', '¡Completaste el laberinto!')),
            const SizedBox(height: 16),
            Text(
              _tl('Puan: $_score', 'Score: $_score', 'Punkte: $_score', 'Puntos: $_score'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(_tl('Hamle: $_moves', 'Moves: $_moves', 'Züge: $_moves', 'Movimientos: $_moves')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _playerX = 0;
                _playerY = 0;
                _score = 0;
                _moves = 0;
                _generateMaze();
              });
            },
            child: Text(_tl('Yeni Oyun', 'New Game', 'Neue Partie', 'Nueva partida')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_tl('Bitir', 'Finish', 'Beenden', 'Terminar')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tl('Labirent Kaşifi', 'Maze Explorer', 'Labyrinth-Forscher', 'Explorador del laberinto')),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _tl('Puan: $_score | Hamle: $_moves', 'Score: $_score | Moves: $_moves', 'Punkte: $_score | Züge: $_moves', 'Puntos: $_score | Movimientos: $_moves'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _tl('Ok tuşları ile hareket et, paraları topla ve hedefe ulaş!', 'Move with the arrow keys, collect coins, and reach the goal!', 'Beweg dich mit den Pfeiltasten, sammle die Münzen und erreiche das Ziel!', '¡Muévete con las flechas, recoge las monedas y llega a la meta!'),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              // Maze
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, kutu) {
                        // Karakteri hucrenin icine cizersek her adimda bir
                        // hucreden kaybolup digerinde beliriyor; cocuk
                        // nereye gittigini goremiyor. Bu yuzden izgarayi
                        // karakterisiz ciziyoruz ve karakteri ustune
                        // AnimatedPositioned ile koyuyoruz: ayni kareler,
                        // ama arada kayan bir hareket var.
                        const kenar = 16.0;
                        const bosluk = 2.0;
                        final hucre =
                            (kutu.maxWidth - kenar * 2 - bosluk * 7) / 8;
                        double konum(int i) => kenar + i * (hucre + bosluk);

                        return Stack(
                          children: [
                            GridView.builder(
                              padding: const EdgeInsets.all(kenar),
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                                mainAxisSpacing: bosluk,
                                crossAxisSpacing: bosluk,
                              ),
                              itemCount: 64,
                              itemBuilder: (context, index) {
                                final x = index % 8;
                                final y = index ~/ 8;
                                final isGoal = x == _goalX && y == _goalY;
                                final cellType = _maze[y][x];

                                return Container(
                                  decoration: BoxDecoration(
                                    color: cellType == 1
                                        ? Colors.grey[800]
                                        : isGoal
                                            ? Colors.green[200]
                                            : Colors.white,
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: isGoal
                                        ? const Icon(Icons.flag_rounded,
                                            color: Colors.green, size: 24)
                                        : cellType == 2
                                            ? const Icon(Icons.circle_rounded,
                                                color: Colors.amber, size: 16)
                                            : null,
                                  ),
                                );
                              },
                            ),
                            AnimatedPositioned(
                              duration: Motion.adapt(context, Motion.short4),
                              curve: Motion.emphasized,
                              left: konum(_playerX),
                              top: konum(_playerY),
                              width: hucre,
                              height: hucre,
                              child: const Center(
                                child: Icon(Icons.person_rounded,
                                    color: Colors.blue, size: 24),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded),
                      iconSize: 48,
                      onPressed: () => _movePlayer(0, -1),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          iconSize: 48,
                          onPressed: () => _movePlayer(-1, 0),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                          ),
                        ),
                        const SizedBox(width: 80),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded),
                          iconSize: 48,
                          onPressed: () => _movePlayer(1, 0),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward_rounded),
                      iconSize: 48,
                      onPressed: () => _movePlayer(0, 1),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
