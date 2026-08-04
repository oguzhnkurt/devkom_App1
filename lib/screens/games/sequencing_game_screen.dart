import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../auth/login_screen.dart';
import '../../providers/settings_provider.dart';

class SequencingGameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const SequencingGameScreen({
    super.key,
    required this.gameData,
  });

  @override
  State<SequencingGameScreen> createState() => _SequencingGameScreenState();
}

class _SequencingGameScreenState extends State<SequencingGameScreen> {
  int _currentLevel = 0;
  List<Map<String, dynamic>> _levels = [];
  final List<String> _userSequence = [];
  List<String> _correctSequence = [];
  List<Map<String, dynamic>> _shuffledCommands = [];
  bool _isChecking = false;
  int _score = 0;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  String _levelTitle(Map<String, dynamic> level) {
    if (_isEn && level['titleEn'] != null) return level['titleEn'];
    return level['title'];
  }

  String _levelDescription(Map<String, dynamic> level) {
    if (_isEn && level['descriptionEn'] != null) return level['descriptionEn'];
    return level['description'];
  }

  String _cmdLabel(Map<String, dynamic> cmd) {
    if (_isEn && cmd['labelEn'] != null) return cmd['labelEn'];
    return cmd['label'];
  }

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
        'titleEn': 'Morning Routine',
        'description': 'Sabah rutinini doğru sıraya koy',
        'descriptionEn': 'Put the morning routine in the right order',
        'commands': [
          {'id': 'wake', 'label': 'Uyan', 'labelEn': 'Wake Up', 'icon': 'alarm'},
          {'id': 'wash', 'label': 'Yüzünü Yıka', 'labelEn': 'Wash Your Face', 'icon': 'wash'},
          {'id': 'dress', 'label': 'Giyim', 'labelEn': 'Get Dressed', 'icon': 'checkroom'},
          {'id': 'breakfast', 'label': 'Kahvaltı Yap', 'labelEn': 'Have Breakfast', 'icon': 'breakfast_dining'},
          {'id': 'school', 'label': 'Okula Git', 'labelEn': 'Go to School', 'icon': 'school'},
        ],
        'correctOrder': ['wake', 'wash', 'dress', 'breakfast', 'school'],
        'hasRobotMap': false,
      },
      {
        'title': 'Robot Hareketi - Seviye 1',
        'titleEn': 'Robot Movement - Level 1',
        'description': 'Robotu hedefe ulaştırmak için komutları sırala',
        'descriptionEn': 'Order the commands to get the robot to the goal',
        'commands': [
          {'id': 'start', 'label': 'Başla', 'labelEn': 'Start', 'icon': 'play_arrow'},
          {'id': 'forward', 'label': 'İleri Git', 'labelEn': 'Move Forward', 'icon': 'arrow_upward'},
          {'id': 'turn', 'label': 'Sola Dön', 'labelEn': 'Turn Left', 'icon': 'turn_left'},
          {'id': 'forward2', 'label': 'İleri Git', 'labelEn': 'Move Forward', 'icon': 'arrow_upward'},
          {'id': 'stop', 'label': 'Dur', 'labelEn': 'Stop', 'icon': 'stop'},
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
        'titleEn': 'Robot Movement - Level 2',
        'description': 'Robotu engelleri aşarak hedefe götür',
        'descriptionEn': 'Get the robot past the obstacles to the goal',
        'commands': [
          {'id': 'start', 'label': 'Başla', 'labelEn': 'Start', 'icon': 'play_arrow'},
          {'id': 'forward1', 'label': 'İleri Git', 'labelEn': 'Move Forward', 'icon': 'arrow_upward'},
          {'id': 'turn_right', 'label': 'Sağa Dön', 'labelEn': 'Turn Right', 'icon': 'turn_right'},
          {'id': 'forward2', 'label': 'İleri Git', 'labelEn': 'Move Forward', 'icon': 'arrow_upward'},
          {'id': 'forward3', 'label': 'İleri Git', 'labelEn': 'Move Forward', 'icon': 'arrow_upward'},
          {'id': 'forward4', 'label': 'İleri Git', 'labelEn': 'Move Forward', 'icon': 'arrow_upward'},
          {'id': 'stop', 'label': 'Dur', 'labelEn': 'Stop', 'icon': 'stop'},
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
        'titleEn': 'Movement with a Loop',
        'description': 'Döngü kullanarak hareketi optimize et',
        'descriptionEn': 'Optimize the movement using a loop',
        'commands': [
          {'id': 'start', 'label': 'Başla', 'labelEn': 'Start', 'icon': 'play_arrow'},
          {'id': 'loop_start', 'label': '3 Kez Tekrarla {', 'labelEn': 'Repeat 3 Times {', 'icon': 'repeat'},
          {'id': 'forward', 'label': '  İleri Git', 'labelEn': '  Move Forward', 'icon': 'arrow_upward'},
          {'id': 'turn', 'label': '  Sağa Dön', 'labelEn': '  Turn Right', 'icon': 'turn_right'},
          {'id': 'loop_end', 'label': '}', 'labelEn': '}', 'icon': 'repeat_on'},
          {'id': 'stop', 'label': 'Dur', 'labelEn': 'Stop', 'icon': 'stop'},
        ],
        'correctOrder': ['start', 'loop_start', 'forward', 'turn', 'loop_end', 'stop'],
      },
      {
        'title': 'Koşullu Hareket',
        'titleEn': 'Conditional Movement',
        'description': 'If-else yapısını kullan',
        'descriptionEn': 'Use an if-else structure',
        'commands': [
          {'id': 'start', 'label': 'Başla', 'labelEn': 'Start', 'icon': 'play_arrow'},
          {'id': 'if', 'label': 'Eğer (sensör aktif)', 'labelEn': 'If (sensor active)', 'icon': 'help'},
          {'id': 'turn_left', 'label': '  Sola Dön', 'labelEn': '  Turn Left', 'icon': 'turn_left'},
          {'id': 'else', 'label': 'Değilse', 'labelEn': 'Else', 'icon': 'help_outline'},
          {'id': 'turn_right', 'label': '  Sağa Dön', 'labelEn': '  Turn Right', 'icon': 'turn_right'},
          {'id': 'endif', 'label': 'Bitir', 'labelEn': 'End If', 'icon': 'done'},
          {'id': 'stop', 'label': 'Dur', 'labelEn': 'Stop', 'icon': 'stop'},
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
        title: Text(isCorrect ? (_isEn ? '🎉 Correct!' : '🎉 Doğru!') : (_isEn ? '❌ Wrong' : '❌ Yanlış')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCorrect
                  ? (_isEn ? 'Great! You ordered the commands correctly.' : 'Harika! Komutları doğru sıraladın.')
                  : (_isEn ? 'Wrong order!' : 'Yanlış sıralama!'),
              style: const TextStyle(fontSize: 16),
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 16),
              Text(
                _isEn ? 'Correct Order:' : 'Doğru Sıralama:',
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
                          _cmdLabel(cmd),
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
              child: Text(_isEn ? 'Try Again' : 'Tekrar Dene'),
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
              child: Text(_isEn ? 'Next Level' : 'Sonraki Seviye'),
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
        title: Text(_isEn ? '🏆 Congratulations!' : '🏆 Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isEn ? 'You completed all levels!' : 'Tüm seviyeleri tamamladın!'),
            const SizedBox(height: 16),
            Text(
              _isEn ? 'Total Score: $_score' : 'Toplam Puan: $_score',
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
            child: Text(_isEn ? 'Start Over' : 'Yeniden Başla'),
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
        title: Text(_isEn ? 'Command Sequencing - Level ${_currentLevel + 1}' : 'Komut Dizilimi - Seviye ${_currentLevel + 1}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _isEn ? 'Score: $_score' : 'Puan: $_score',
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
                          _levelTitle(level),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _levelDescription(level),
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
                  Text(
                    _isEn ? 'Robot Map:' : 'Robot Haritası:',
                    style: const TextStyle(
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
                          _isEn ? 'Robot (the yellow arrow below shows the start direction)' : 'Robot (Altındaki sarı ok başlangıç yönünü gösterir)',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.flag, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(_isEn ? 'Goal' : 'Hedef'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.block, color: Colors.grey[800], size: 20),
                      const SizedBox(width: 8),
                      Text(_isEn ? 'Obstacle' : 'Engel'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRobotMapWidget(level),
                  const SizedBox(height: 24),
                ],

                // Available commands
                Text(
                  _isEn ? 'Commands:' : 'Komutlar:',
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
                              _cmdLabel(cmd),
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
                Text(
                  _isEn ? 'Your Order:' : 'Senin Sıralaman:',
                  style: const TextStyle(
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
                      ? Center(
                          child: Text(
                            _isEn ? 'Select above to order the commands' : 'Komutları sıralamak için yukarıdan seç',
                            style: const TextStyle(color: Colors.grey),
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
                                  Text(_cmdLabel(cmd)),
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
                      label: Text(_isEn ? 'Reset' : 'Sıfırla'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _userSequence.length == _correctSequence.length &&
                              !_isChecking
                          ? _checkAnswer
                          : null,
                      icon: const Icon(Icons.check),
                      label: Text(_isEn ? 'Check' : 'Kontrol Et'),
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
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.orange, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isEn ? 'Sign In to Continue' : 'Devam Etmek İçin Giriş Yapın',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              _isEn ? 'You completed the first level!' : 'İlk seviyeyi tamamladınız!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isEn ? 'Score: $_score' : 'Skor: $_score',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              _isEn ? 'Sign in to continue and access all levels.' : 'Devam etmek ve tüm seviyelere erişmek için giriş yapın.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_isEn ? 'Home' : 'Ana Sayfa'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
              await authProvider.signOut();

              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.login),
            label: Text(_isEn ? 'Sign In' : 'Giriş Yap'),
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
