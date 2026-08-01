import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class MazeExplorerGameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const MazeExplorerGameScreen({
    Key? key,
    required this.gameData,
  }) : super(key: key);

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

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  @override
  void initState() {
    super.initState();
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
      _showMessage(_isEn ? '❌ You hit a wall!' : '❌ Duvara çarptın!');
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
        _showMessage(_isEn ? '🪙 +10 points!' : '🪙 +10 puan!');
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
        title: Text(_isEn ? '🎉 Congratulations!' : '🎉 Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isEn ? 'You completed the maze!' : 'Labirenti tamamladın!'),
            const SizedBox(height: 16),
            Text(
              _isEn ? 'Score: $_score' : 'Puan: $_score',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(_isEn ? 'Moves: $_moves' : 'Hamle: $_moves'),
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
            child: Text(_isEn ? 'New Game' : 'Yeni Oyun'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_isEn ? 'Finish' : 'Bitir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEn ? 'Maze Explorer' : 'Labirent Kaşifi'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _isEn ? 'Score: $_score | Moves: $_moves' : 'Puan: $_score | Hamle: $_moves',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isEn
                        ? 'Move with the arrow keys, collect coins, and reach the goal!'
                        : 'Ok tuşları ile hareket et, paraları topla ve hedefe ulaş!',
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
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    final x = index % 8;
                    final y = index ~/ 8;
                    final isPlayer = x == _playerX && y == _playerY;
                    final isGoal = x == _goalX && y == _goalY;
                    final cellType = _maze[y][x];

                    return Container(
                      decoration: BoxDecoration(
                        color: cellType == 1
                            ? Colors.grey[800]
                            : isGoal
                                ? Colors.green[200]
                                : Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: isPlayer
                            ? const Icon(Icons.person, color: Colors.blue, size: 24)
                            : isGoal
                                ? const Icon(Icons.flag, color: Colors.green, size: 24)
                                : cellType == 2
                                    ? const Icon(Icons.circle, color: Colors.amber, size: 16)
                                    : null,
                      ),
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
                  icon: const Icon(Icons.arrow_upward),
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
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 48,
                      onPressed: () => _movePlayer(-1, 0),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                      ),
                    ),
                    const SizedBox(width: 80),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      iconSize: 48,
                      onPressed: () => _movePlayer(1, 0),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
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
      ),
    );
  }
}
