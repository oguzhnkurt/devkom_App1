import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../models/game_model.dart';
import '../../models/leaderboard_model.dart';
import '../../services/leaderboard_service.dart';
import '../../services/sound_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/score_calculator.dart';
import '../../widgets/play_time_gate.dart';

/// Değişken Ustası Oyunu
/// Değişken kavramını, atama işlemlerini ve değişken değerlerini takip etmeyi öğreten oyun
class VariableMasterGameScreen extends StatelessWidget {
  const VariableMasterGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlayTimeGate(
      gameName: 'Değişken Ustası',
      child: const _VariableMasterGameContent(),
    );
  }
}

class _VariableMasterGameContent extends StatefulWidget {
  const _VariableMasterGameContent({Key? key}) : super(key: key);

  @override
  State<_VariableMasterGameContent> createState() => _VariableMasterGameContentState();
}

class _VariableMasterGameContentState extends State<_VariableMasterGameContent> {
  // Oyun ayarları
  final int maxLevels = 20;
  final Random _random = Random();
  final LeaderboardService _leaderboardService = LeaderboardService();

  // Oyun durumu
  int currentLevel = 1;
  double score = 0;
  int lives = 3;
  List<VariableOperation> operations = [];
  Map<String, int> currentVariables = {};
  String questionVariable = '';
  int correctAnswer = 0;
  List<int> options = [];
  bool showHint = false;
  bool gameWon = false;
  bool gameOver = false;
  DateTime? startTime;
  int? finalTimeSeconds;

  // Değişken isimleri
  final List<String> variableNames = [
    'x', 'y', 'z', 'a', 'b', 'c', 'n', 'm', 'k', 'i', 'j', 'p', 'q', 'r', 's', 't'
  ];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _generateNewLevel();
  }

  int get operationCount {
    if (currentLevel <= 5) return 2;  // Seviye 1-5: 2 işlem
    if (currentLevel <= 10) return 3; // Seviye 6-10: 3 işlem
    if (currentLevel <= 15) return 4; // Seviye 11-15: 4 işlem
    return 5;                         // Seviye 16-20: 5 işlem
  }

  void _generateNewLevel() {
    operations = [];
    currentVariables = {};
    options = [];

    // Kullanılacak değişken sayısı
    final varCount = min(2 + (currentLevel ~/ 4), 4);
    final usedVars = variableNames.take(varCount).toList();

    // İşlemler oluştur
    for (int i = 0; i < operationCount; i++) {
      final variable = usedVars[_random.nextInt(usedVars.length)];
      final operationType = _random.nextInt(5); // 0: atama, 1: toplama, 2: çıkarma, 3: çarpma, 4: kopyalama

      if (operationType == 0) {
        // Basit atama: x = 5
        final value = _random.nextInt(20) + 1;
        operations.add(VariableOperation(
          variable: variable,
          operation: '=',
          value: value,
        ));
        currentVariables[variable] = value;
      } else if (operationType == 4 && currentVariables.isNotEmpty) {
        // Kopyalama: x = y
        final sourceVar = currentVariables.keys.elementAt(_random.nextInt(currentVariables.length));
        operations.add(VariableOperation(
          variable: variable,
          operation: '=',
          sourceVariable: sourceVar,
        ));
        currentVariables[variable] = currentVariables[sourceVar]!;
      } else if (currentVariables.containsKey(variable)) {
        // İşlem: x = x + 3
        final value = _random.nextInt(10) + 1;
        String op;

        switch (operationType) {
          case 1:
            op = '+';
            currentVariables[variable] = currentVariables[variable]! + value;
            break;
          case 2:
            op = '-';
            currentVariables[variable] = max(0, currentVariables[variable]! - value);
            break;
          case 3:
            op = '*';
            currentVariables[variable] = currentVariables[variable]! * value;
            break;
          default:
            op = '+';
            currentVariables[variable] = currentVariables[variable]! + value;
        }

        operations.add(VariableOperation(
          variable: variable,
          operation: op,
          value: value,
        ));
      } else {
        // Değişken yoksa atama yap
        final value = _random.nextInt(20) + 1;
        operations.add(VariableOperation(
          variable: variable,
          operation: '=',
          value: value,
        ));
        currentVariables[variable] = value;
      }
    }

    // Soru değişkenini seç
    questionVariable = currentVariables.keys.elementAt(_random.nextInt(currentVariables.length));
    correctAnswer = currentVariables[questionVariable]!;

    // Yanlış seçenekler üret
    final wrongAnswers = <int>{};
    while (wrongAnswers.length < 3) {
      final wrong = correctAnswer + _random.nextInt(20) - 10;
      if (wrong >= 0 && wrong != correctAnswer) {
        wrongAnswers.add(wrong);
      }
    }

    options = [correctAnswer, ...wrongAnswers]..shuffle();

    setState(() {});
  }

  void _checkAnswer(int selectedAnswer) async {
    if (selectedAnswer == correctAnswer) {
      // Doğru cevap
      await SoundService.playCorrectSound();

      final points = ScoreCalculator.calculateScore(
        baseScore: 100,
        level: currentLevel,
        timeBonus: 0,
      );

      setState(() {
        score += points;
        currentLevel++;
      });

      if (currentLevel > maxLevels) {
        _completeGame();
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        _generateNewLevel();
      }
    } else {
      // Yanlış cevap
      await SoundService.playWrongSound();

      setState(() {
        lives--;
      });

      if (lives <= 0) {
        _endGame();
      } else {
        _showWrongAnswerDialog();
      }
    }
  }

  void _showWrongAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.close, color: AppTheme.errorRed),
            const SizedBox(width: 8),
            const Text('Yanlış Cevap'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Doğru cevap: $correctAnswer',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Kalan can: $lives',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateNewLevel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  void _completeGame() async {
    await SoundService.playSuccessSound();

    final endTime = DateTime.now();
    finalTimeSeconds = endTime.difference(startTime!).inSeconds;

    final finalScore = ScoreCalculator.calculateFinalScore(
      score: score,
      timeTaken: finalTimeSeconds!,
      maxTime: 600,
    );

    setState(() {
      score = finalScore;
      gameWon = true;
    });

    _saveToLeaderboard();
  }

  void _endGame() {
    final endTime = DateTime.now();
    finalTimeSeconds = endTime.difference(startTime!).inSeconds;

    setState(() {
      gameOver = true;
    });

    _saveToLeaderboard();
  }

  Future<void> _saveToLeaderboard() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;

    if (userId == null) return;

    final entry = LeaderboardEntry(
      id: '',
      userId: userId,
      userName: authProvider.currentUser?.displayName ?? 'Oyuncu',
      score: score.round(),
      difficulty: currentLevel,
      gameType: GameType.variableMaster,
      completedAt: DateTime.now(),
    );

    await _leaderboardService.addScore(entry);
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb, color: AppTheme.warningOrange),
            const SizedBox(width: 8),
            const Text('İpucu'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Değişken Değerlerini Takip Et:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...currentVariables.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: entry.key == questionVariable
                            ? AppTheme.warningOrange.withOpacity(0.2)
                            : AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: entry.key == questionVariable
                              ? AppTheme.warningOrange
                              : AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('=', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => showHint = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (gameWon || gameOver) {
      return _buildResultScreen();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        title: const Text('Değişken Ustası', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _showHintDialog,
            tooltip: 'İpucu',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInstructionCard(),
                    const SizedBox(height: 24),
                    _buildCodeEditor(),
                    const SizedBox(height: 24),
                    _buildQuestionCard(),
                    const SizedBox(height: 24),
                    _buildOptionsGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Seviye', '$currentLevel/$maxLevels', Icons.trending_up, AppTheme.primaryBlue),
          _buildStatItem('Skor', '$score', Icons.stars, AppTheme.warningOrange),
          _buildLivesIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLivesIndicator() {
    return Column(
      children: [
        Row(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                index < lives ? Icons.favorite : Icons.favorite_border,
                color: AppTheme.errorRed,
                size: 20,
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          'Can',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInstructionCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.code, color: AppTheme.primaryBlue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kod Yürütme',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kodu takip et ve değişken değerini bul',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeEditor() {
    return Card(
      elevation: 5,
      color: const Color(0xFF1E1E1E), // VS Code dark theme
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.code, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'main.dart',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...operations.asMap().entries.map((entry) {
              final index = entry.key;
              final op = entry.value;
              return _buildCodeLine(index + 1, op);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeLine(int lineNumber, VariableOperation op) {
    String code;
    if (op.sourceVariable != null) {
      code = '${op.variable} = ${op.sourceVariable}';
    } else if (op.operation == '=') {
      code = '${op.variable} = ${op.value}';
    } else {
      code = '${op.variable} = ${op.variable} ${op.operation} ${op.value}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$lineNumber',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace',
                  height: 1.5,
                ),
                children: _highlightCode(code),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _highlightCode(String code) {
    final parts = code.split(' ');
    return parts.map((part) {
      Color color;
      if (variableNames.contains(part)) {
        color = const Color(0xFF9CDCFE); // Variable color
      } else if (part == '=') {
        color = Colors.white;
      } else if (['+', '-', '*', '/'].contains(part)) {
        color = const Color(0xFFD4D4D4); // Operator color
      } else if (int.tryParse(part) != null) {
        color = const Color(0xFFB5CEA8); // Number color
      } else {
        color = Colors.white;
      }

      return TextSpan(
        text: part == parts.last ? part : '$part ',
        style: TextStyle(color: color),
      );
    }).toList();
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 4,
      color: AppTheme.warningOrange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline, color: AppTheme.warningOrange, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Soru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warningOrange, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    questionVariable,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    '= ?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warningOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return _buildOptionCard(options[index]);
      },
    );
  }

  Widget _buildOptionCard(int option) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => _checkAnswer(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppTheme.primaryBlue.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: Text(
              '$option',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: gameWon ? AppTheme.successGreen : AppTheme.errorRed,
        foregroundColor: Colors.white,
        title: Text(gameWon ? 'Tebrikler!' : 'Oyun Bitti'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                gameWon ? Icons.emoji_events : Icons.refresh,
                size: 100,
                color: gameWon ? AppTheme.successGreen : AppTheme.errorRed,
              ),
              const SizedBox(height: 24),
              Text(
                gameWon ? 'Harika İş!' : 'Tekrar Dene!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: gameWon ? AppTheme.successGreen : AppTheme.errorRed,
                ),
              ),
              const SizedBox(height: 16),
              _buildResultCard('Seviye', '$currentLevel/$maxLevels', Icons.trending_up),
              _buildResultCard('Skor', '$score', Icons.stars),
              if (finalTimeSeconds != null)
                _buildResultCard('Süre', '$finalTimeSeconds saniye', Icons.timer),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Ana Menü'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        currentLevel = 1;
                        score = 0;
                        lives = 3;
                        gameWon = false;
                        gameOver = false;
                        startTime = DateTime.now();
                        _generateNewLevel();
                      });
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Tekrar Oyna'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 32),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Değişken işlemi modeli
class VariableOperation {
  final String variable;
  final String operation;
  final int? value;
  final String? sourceVariable;

  VariableOperation({
    required this.variable,
    required this.operation,
    this.value,
    this.sourceVariable,
  });
}
