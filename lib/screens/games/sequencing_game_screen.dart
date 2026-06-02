import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class SequencingGameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const SequencingGameScreen({
    Key? key,
    required this.gameData,
  }) : super(key: key);

  @override
  State<SequencingGameScreen> createState() => _SequencingGameScreenState();
}

class _SequencingGameScreenState extends State<SequencingGameScreen> {
  int _currentLevel = 0;
  List<Map<String, dynamic>> _levels = [];
  List<String> _userSequence = [];
  List<String> _correctSequence = [];
  List<Map<String, dynamic>> _shuffledCommands = [];
  bool _isChecking = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  void _loadLevels() {
    final levelsData = widget.gameData['levels'];
    if (levelsData is List) {
      _levels = List<Map<String, dynamic>>.from(levelsData);
    } else {
      _levels = _getDefaultLevels();
    }
    _loadLevel(_currentLevel);
  }

  List<Map<String, dynamic>> _getDefaultLevels() {
    return [
      {
        'title': 'Sabah Rutini',
        'description': 'Sabah rutinini doğru sıraya koy',
        'commands': [
          {'id': 'wake', 'label': 'Uyan', 'icon': 'alarm'},
          {'id': 'wash', 'label': 'Yüzünü Yıka', 'icon': 'wash'},
          {'id': 'dress', 'label': 'Giyim', 'icon': 'checkroom'},
          {'id': 'breakfast', 'label': 'Kahvaltı Yap', 'icon': 'breakfast_dining'},
          {'id': 'school', 'label': 'Okula Git', 'icon': 'school'},
        ],
        'correctOrder': ['wake', 'wash', 'dress', 'breakfast', 'school'],
        'hasRobotMap': false,
      },
      {
        'title': 'Robot Hareketi - Seviye 1',
        'description': 'Robotu hedefe ulaştırmak için komutları sırala',
        'commands': [
          {'id': 'start', 'label': 'Başla', 'icon': 'play_arrow'},
          {'id': 'forward', 'label': 'İleri Git', 'icon': 'arrow_upward'},
          {'id': 'turn', 'label': 'Sola Dön', 'icon': 'turn_left'},
          {'id': 'forward2', 'label': 'İleri Git', 'icon': 'arrow_upward'},
          {'id': 'stop', 'label': 'Dur', 'icon': 'stop'},
        ],
        'correctOrder': ['start', 'forward', 'turn', 'forward2', 'stop'],
        'hasRobotMap': true,
        'robotStartX': 0,
        'robotStartY': 0,
        'robotStartDirection': 'down',
        'goalX': 1,
        'goalY': 1,
        'obstacles': [],
        'mapSize': 3,
      },
      {
        'title': 'Robot Hareketi - Seviye 2',
        'description': 'Robotu engelleri aşarak hedefe götür',
        'commands': [
          {'id': 'start', 'label': 'Başla', 'icon': 'play_arrow'},
          {'id': 'forward1', 'label': 'İleri Git', 'icon': 'arrow_upward'},
          {'id': 'turn_right', 'label': 'Sağa Dön', 'icon': 'turn_right'},
          {'id': 'forward2', 'label': 'İleri Git', 'icon': 'arrow_upward'},
          {'id': 'forward3', 'label': 'İleri Git', 'icon': 'arrow_upward'},
          {'id': 'forward4', 'label': 'İleri Git', 'icon': 'arrow_upward'},
          {'id': 'stop', 'label': 'Dur', 'icon': 'stop'},
        ],
        'correctOrder': ['start', 'forward1', 'turn_right', 'forward2', 'forward3', 'forward4', 'stop'],
        'hasRobotMap': true,
        'robotStartX': 0,
        'robotStartY': 0,
        'robotStartDirection': 'right',
        'goalX': 1,
        'goalY': 3,
        'obstacles': [
          {'x': 0, 'y': 1},
          {'x': 0, 'y': 2},
        ],
        'mapSize': 4,
      },
      {
        'title': 'Döngü ile Hareket',
        'description': 'Döngü kullanarak hareketi optimize et',
        'commands': [
          {'id': 'start', 'label': 'Başla', 'icon': 'play_arrow'},
          {'id': 'loop_start', 'label': '3 Kez Tekrarla {', 'icon': 'repeat'},
          {'id': 'forward', 'label': '  İleri Git', 'icon': 'arrow_upward'},
          {'id': 'turn', 'label': '  Sağa Dön', 'icon': 'turn_right'},
          {'id': 'loop_end', 'label': '}', 'icon': 'repeat_on'},
          {'id': 'stop', 'label': 'Dur', 'icon': 'stop'},
        ],
        'correctOrder': ['start', 'loop_start', 'forward', 'turn', 'loop_end', 'stop'],
      },
      {
        'title': 'Koşullu Hareket',
        'description': 'If-else yapısını kullan',
        'commands': [
          {'id': 'start', 'label': 'Başla', 'icon': 'play_arrow'},
          {'id': 'if', 'label': 'Eğer (sensör aktif)', 'icon': 'help'},
          {'id': 'turn_left', 'label': '  Sola Dön', 'icon': 'turn_left'},
          {'id': 'else', 'label': 'Değilse', 'icon': 'help_outline'},
          {'id': 'turn_right', 'label': '  Sağa Dön', 'icon': 'turn_right'},
          {'id': 'endif', 'label': 'Bitir', 'icon': 'done'},
          {'id': 'stop', 'label': 'Dur', 'icon': 'stop'},
        ],
        'correctOrder': ['start', 'if', 'turn_left', 'else', 'turn_right', 'endif', 'stop'],
      },
    ];
  }

  void _loadLevel(int levelIndex) {
    if (levelIndex >= _levels.length) {
      _showCompletionDialog();
      return;
    }

    final level = _levels[levelIndex];
    setState(() {
      _correctSequence = List<String>.from(level['correctOrder']);
      _userSequence.clear();
      _isChecking = false;

      // Shuffle commands for display (except for robot map levels)
      _shuffledCommands = List<Map<String, dynamic>>.from(level['commands']);
      if (level['hasRobotMap'] != true) {
        _shuffledCommands.shuffle(Random());
      }
    });
  }

  void _onCommandTap(String commandId) {
    if (_isChecking) return;

    setState(() {
      if (_userSequence.contains(commandId)) {
        _userSequence.remove(commandId);
      } else {
        _userSequence.add(commandId);
      }
    });
  }

  void _checkAnswer() {
    setState(() {
      _isChecking = true;
    });

    bool isCorrect = _userSequence.length == _correctSequence.length;
    if (isCorrect) {
      for (int i = 0; i < _userSequence.length; i++) {
        if (_userSequence[i] != _correctSequence[i]) {
          isCorrect = false;
          break;
        }
      }
    }

    if (isCorrect) {
      setState(() {
        _score += 20;
      });
      _showFeedbackDialog(true);
    } else {
      _showFeedbackDialog(false);
    }
  }

  void _showFeedbackDialog(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? '🎉 Doğru!' : '❌ Yanlış'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCorrect
                  ? 'Harika! Komutları doğru sıraladın.'
                  : 'Yanlış sıralama!',
              style: const TextStyle(fontSize: 16),
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 16),
              const Text(
                'Doğru Sıralama:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              ..._correctSequence.asMap().entries.map((entry) {
                final index = entry.key;
                final commandId = entry.value;
                final cmd = _shuffledCommands.firstWhere(
                  (c) => c['id'] == commandId,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.green,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getIcon(cmd['icon']),
                        size: 20,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          cmd['label'],
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
        actions: [
          if (!isCorrect)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isChecking = false;
                });
              },
              child: const Text('Tekrar Dene'),
            ),
          if (isCorrect)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentLevel++;
                });
                _loadLevel(_currentLevel);
              },
              child: const Text('Sonraki Seviye'),
            ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🏆 Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tüm seviyeleri tamamladın!'),
            const SizedBox(height: 16),
            Text(
              'Toplam Puan: $_score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentLevel = 0;
                _score = 0;
              });
              _loadLevel(0);
            },
            child: const Text('Yeniden Başla'),
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

  void _resetLevel() {
    setState(() {
      _userSequence.clear();
      _isChecking = false;
    });
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'alarm':
        return Icons.alarm;
      case 'wash':
        return Icons.wash;
      case 'checkroom':
        return Icons.checkroom;
      case 'breakfast_dining':
        return Icons.breakfast_dining;
      case 'school':
        return Icons.school;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'arrow_upward':
        return Icons.arrow_upward;
      case 'turn_right':
        return Icons.turn_right;
      case 'turn_left':
        return Icons.turn_left;
      case 'stop':
        return Icons.stop;
      case 'repeat':
        return Icons.repeat;
      case 'repeat_on':
        return Icons.repeat_on;
      case 'help':
        return Icons.help;
      case 'help_outline':
        return Icons.help_outline;
      case 'done':
        return Icons.done;
      default:
        return Icons.code;
    }
  }

  IconData _getDirectionIcon(String direction) {
    switch (direction.toLowerCase()) {
      case 'up':
        return Icons.arrow_upward;
      case 'down':
        return Icons.arrow_downward;
      case 'left':
        return Icons.arrow_back;
      case 'right':
        return Icons.arrow_forward;
      default:
        return Icons.arrow_upward;
    }
  }

  Widget _buildRobotMapWidget(Map<String, dynamic> level) {
    final mapSize = level['mapSize'] ?? 3;
    final robotStartX = level['robotStartX'] ?? 0;
    final robotStartY = level['robotStartY'] ?? 0;
    final robotStartDirection = level['robotStartDirection'] ?? 'up';
    final goalX = level['goalX'] ?? 0;
    final goalY = level['goalY'] ?? 0;
    final obstacles = (level['obstacles'] as List?) ?? [];

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 300,
          maxHeight: 300,
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: mapSize,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: mapSize * mapSize,
                itemBuilder: (context, index) {
                  final x = index % mapSize;
                  final y = index ~/ mapSize;

                  final isRobotStart = x == robotStartX && y == robotStartY;
                  final isGoal = x == goalX && y == goalY;
                  final isObstacle = obstacles.any((obs) => obs['x'] == x && obs['y'] == y);

                  return Container(
                    decoration: BoxDecoration(
                      color: isObstacle
                          ? Colors.grey[800]
                          : isGoal
                              ? Colors.green[200]
                              : isRobotStart
                                  ? Colors.blue[100]
                                  : Colors.white,
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: isRobotStart
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.smart_toy,
                                  color: Colors.blue,
                                  size: 32,
                                ),
                                Positioned(
                                  bottom: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.orange,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      _getDirectionIcon(robotStartDirection),
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : isGoal
                              ? const Icon(
                                  Icons.flag,
                                  color: Colors.green,
                                  size: 32,
                                )
                              : isObstacle
                                  ? const Icon(
                                      Icons.block,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLevel >= _levels.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final level = _levels[_currentLevel];
    final commands = _shuffledCommands.isNotEmpty
        ? _shuffledCommands
        : level['commands'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text('Komut Dizilimi - Seviye ${_currentLevel + 1}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Puan: $_score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Level info
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          level['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Robot map visualization (if level has robot map)
                if (level['hasRobotMap'] == true) ...[
                  const Text(
                    'Robot Haritası:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.smart_toy, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Robot (Altındaki sarı ok başlangıç yönünü gösterir)',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.flag, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text('Hedef'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.block, color: Colors.grey[800], size: 20),
                      const SizedBox(width: 8),
                      const Text('Engel'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRobotMapWidget(level),
                  const SizedBox(height: 24),
                ],

                // Available commands
                const Text(
                  'Komutlar:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: commands.map((cmd) {
                    final commandId = cmd['id'] as String;
                    final isSelected = _userSequence.contains(commandId);
                    final orderIndex = _userSequence.indexOf(commandId);

                    return InkWell(
                      onTap: () => _onCommandTap(commandId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.shade300
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Text(
                                  '${orderIndex + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              _getIcon(cmd['icon']),
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cmd['label'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // User sequence
                const Text(
                  'Senin Sıralaman:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _userSequence.isEmpty
                      ? const Center(
                          child: Text(
                            'Komutları sıralamak için yukarıdan seç',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _userSequence.asMap().entries.map((entry) {
                            final index = entry.key;
                            final commandId = entry.value;
                            final cmd = commands.firstWhere(
                              (c) => c['id'] == commandId,
                            );

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${index + 1}.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _getIcon(cmd['icon']),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(cmd['label']),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _resetLevel,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Sıfırla'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _userSequence.length == _correctSequence.length &&
                              !_isChecking
                          ? _checkAnswer
                          : null,
                      icon: const Icon(Icons.check),
                      label: const Text('Kontrol Et'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showLoginRequiredDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Devam Etmek İçin Giriş Yapın',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'İlk seviyeyi tamamladınız!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor: $_score',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Devam etmek ve tüm seviyelere erişmek için giriş yapın.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Ana Sayfa'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
              await authProvider.signOut();

              if (!mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('Giriş Yap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
