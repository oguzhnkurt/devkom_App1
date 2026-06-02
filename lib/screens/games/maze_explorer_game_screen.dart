import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _generateMaze();
  }

  void _generateMaze() {
    // Simple maze generation
    _maze = List.generate(8, (y) => List.generate(8, (x) {
      // Start and goal positions
      if ((x == 0 && y == 0) || (x == 7 && y == 7)) return 0;

      // Create some walls
      if ((x + y) % 3 == 0 && (x != _goalX || y != _goalY)) return 1;

      // Random coins
      if ((x * y) % 5 == 0 && x > 0 && y > 0) return 2;

      return 0;
    }));
  }

  void _movePlayer(int dx, int dy) {
    final newX = _playerX + dx;
    final newY = _playerY + dy;

    // Check boundaries
    if (newX < 0 || newX >= 8 || newY < 0 || newY >= 8) return;

    // Check walls
    if (_maze[newY][newX] == 1) {
      _showMessage('❌ Duvara çarptın!');
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
        _showMessage('🪙 +10 puan!');
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
        title: const Text('🎉 Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Labirenti tamamladın!'),
            const SizedBox(height: 16),
            Text(
              'Puan: $_score',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Hamle: $_moves'),
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
            child: const Text('Yeni Oyun'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Bitir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Labirent Kaşifi'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Puan: $_score | Hamle: $_moves',
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
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ok tuşları ile hareket et, paraları topla ve hedefe ulaş!',
                    style: TextStyle(fontSize: 14),
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
