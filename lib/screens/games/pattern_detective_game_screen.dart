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
import '../../providers/settings_provider.dart';

/// Kod Dedektifi Oyunu
/// Pattern matching ve dizi tamamlama yeteneklerini geliştiren oyun
class PatternDetectiveGameScreen extends StatelessWidget {
  const PatternDetectiveGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn = Provider.of<SettingsProvider>(context, listen: false).locale.languageCode == 'en';
    return PlayTimeGate(
      gameName: isEn ? 'Code Detective' : 'Kod Dedektifi',
      child: const _PatternDetectiveGameContent(),
    );
  }
}

class _PatternDetectiveGameContent extends StatefulWidget {
  const _PatternDetectiveGameContent({super.key});

  @override
  State<_PatternDetectiveGameContent> createState() => _PatternDetectiveGameContentState();
}

class _PatternDetectiveGameContentState extends State<_PatternDetectiveGameContent> {
  // Oyun ayarları
  final int maxLevels = 20;
  final Random _random = Random();
  final LeaderboardService _leaderboardService = LeaderboardService();

  // Oyun durumu
  int currentLevel = 1;
  double score = 0;
  int lives = 3;
  List<String> pattern = [];
  List<String> options = [];
  String? correctAnswer;
  bool showHint = false;
  bool gameWon = false;
  bool gameOver = false;
  DateTime? startTime;
  int? finalTimeSeconds;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  // Pattern türleri
  final List<String> patternTypes = [
    'numeric',      // Sayı dizileri (1,2,3,4,?)
    'arithmetic',   // Aritmetik işlemler (2,4,6,8,?)
    'geometric',    // Geometrik şekiller
    'color',        // Renk desenleri
    'letter',       // Harf dizileri (A,B,C,D,?)
    'symbol',       // Sembol desenleri
  ];

  // Şekiller, renkler ve semboller
  final List<IconData> shapes = [
    Icons.circle,
    Icons.square,
    Icons.change_history, // Üçgen
    Icons.star,
    Icons.favorite,
    Icons.hexagon_outlined,
  ];

  final List<Color> colors = [
    AppTheme.primaryBlue,
    AppTheme.successGreen,
    AppTheme.errorRed,
    AppTheme.warningOrange,
    AppTheme.accentTeal,
    Colors.purple,
  ];

  final List<String> symbols = ['@', '#', '\$', '%', '&', '*'];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _generateNewPattern();
  }

  String get currentPatternType {
    if (currentLevel <= 5) return 'numeric';
    if (currentLevel <= 8) return 'arithmetic';
    if (currentLevel <= 11) return 'color';
    if (currentLevel <= 14) return 'geometric';
    if (currentLevel <= 17) return 'letter';
    return 'symbol';
  }

  void _generateNewPattern() {
    final type = currentPatternType;

    switch (type) {
      case 'numeric':
        _generateNumericPattern();
        break;
      case 'arithmetic':
        _generateArithmeticPattern();
        break;
      case 'geometric':
        _generateGeometricPattern();
        break;
      case 'color':
        _generateColorPattern();
        break;
      case 'letter':
        _generateLetterPattern();
        break;
      case 'symbol':
        _generateSymbolPattern();
        break;
    }
  }

  // Sayı dizileri: 1,2,3,4,? veya 2,4,6,8,?
  void _generateNumericPattern() {
    final start = _random.nextInt(5) + 1;
    final step = _random.nextInt(3) + 1;
    final length = min(4 + (currentLevel ~/ 3), 7);

    pattern = List.generate(length - 1, (i) => (start + i * step).toString());
    correctAnswer = (start + (length - 1) * step).toString();

    // Yanlış seçenekler üret
    final wrongAnswers = <String>{};
    while (wrongAnswers.length < 3) {
      final wrong = (start + (length - 1) * step) + _random.nextInt(10) - 5;
      if (wrong > 0 && wrong.toString() != correctAnswer) {
        wrongAnswers.add(wrong.toString());
      }
    }

    options = [correctAnswer!, ...wrongAnswers]..shuffle();
  }

  // Aritmetik işlemler: +2, +2, +2 veya *2, *2, *2
  void _generateArithmeticPattern() {
    final operations = ['+', '-', '*'];
    final operation = operations[_random.nextInt(operations.length)];
    final start = _random.nextInt(10) + 1;
    int step = _random.nextInt(5) + 1;

    if (operation == '*') step = min(step, 3);

    pattern = [start.toString()];
    int current = start;

    for (int i = 0; i < 3; i++) {
      switch (operation) {
        case '+':
          current += step;
          break;
        case '-':
          current -= step;
          if (current < 0) current = 0;
          break;
        case '*':
          current *= step;
          break;
      }
      pattern.add(current.toString());
    }

    // Doğru cevap
    switch (operation) {
      case '+':
        current += step;
        break;
      case '-':
        current -= step;
        if (current < 0) current = 0;
        break;
      case '*':
        current *= step;
        break;
    }
    correctAnswer = current.toString();

    // Yanlış seçenekler
    final wrongAnswers = <String>{};
    while (wrongAnswers.length < 3) {
      final wrong = current + _random.nextInt(20) - 10;
      if (wrong >= 0 && wrong.toString() != correctAnswer) {
        wrongAnswers.add(wrong.toString());
      }
    }

    options = [correctAnswer!, ...wrongAnswers]..shuffle();
  }

  // Geometrik şekiller
  void _generateGeometricPattern() {
    final repeatCount = _random.nextInt(2) + 2; // 2 veya 3 kez tekrar

    pattern = [];
    for (int i = 0; i < repeatCount; i++) {
      pattern.add('shape_${i % shapes.length}');
    }

    correctAnswer = 'shape_${repeatCount % shapes.length}';

    // Yanlış şekiller
    final wrongAnswers = <String>{};
    while (wrongAnswers.length < 3) {
      final idx = _random.nextInt(shapes.length);
      if ('shape_$idx' != correctAnswer) {
        wrongAnswers.add('shape_$idx');
      }
    }

    options = [correctAnswer!, ...wrongAnswers]..shuffle();
  }

  // Renk desenleri
  void _generateColorPattern() {
    final repeatCount = _random.nextInt(2) + 2;

    pattern = [];
    for (int i = 0; i < repeatCount; i++) {
      pattern.add('color_${i % colors.length}');
    }

    correctAnswer = 'color_${repeatCount % colors.length}';

    // Yanlış renkler
    final wrongAnswers = <String>{};
    while (wrongAnswers.length < 3) {
      final idx = _random.nextInt(colors.length);
      if ('color_$idx' != correctAnswer) {
        wrongAnswers.add('color_$idx');
      }
    }

    options = [correctAnswer!, ...wrongAnswers]..shuffle();
  }

  // Harf dizileri
  void _generateLetterPattern() {
    final start = _random.nextInt(20); // A-T arası başlangıç
    final step = _random.nextInt(2) + 1;
    final length = min(4 + (currentLevel ~/ 5), 6);

    pattern = List.generate(
      length - 1,
      (i) => String.fromCharCode(65 + start + i * step),
    );

    correctAnswer = String.fromCharCode(65 + start + (length - 1) * step);

    // Yanlış harfler
    final wrongAnswers = <String>{};
    while (wrongAnswers.length < 3) {
      final idx = _random.nextInt(26);
      final letter = String.fromCharCode(65 + idx);
      if (letter != correctAnswer && !pattern.contains(letter)) {
        wrongAnswers.add(letter);
      }
    }

    options = [correctAnswer!, ...wrongAnswers]..shuffle();
  }

  // Sembol desenleri
  void _generateSymbolPattern() {
    final repeatCount = _random.nextInt(2) + 2;

    pattern = [];
    for (int i = 0; i < repeatCount; i++) {
      pattern.add(symbols[i % symbols.length]);
    }

    correctAnswer = symbols[repeatCount % symbols.length];

    // Yanlış semboller
    final wrongAnswers = <String>{};
    while (wrongAnswers.length < 3) {
      final symbol = symbols[_random.nextInt(symbols.length)];
      if (symbol != correctAnswer && !pattern.contains(symbol)) {
        wrongAnswers.add(symbol);
      }
    }

    options = [correctAnswer!, ...wrongAnswers]..shuffle();
  }

  void _checkAnswer(String selectedAnswer) async {
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
        setState(() {
          _generateNewPattern();
          showHint = false;
        });
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
            Text(_isEn ? 'Wrong Answer' : 'Yanlış Cevap'),
          ],
        ),
        content: Text(
          _isEn ? 'Correct answer: $correctAnswer\nLives left: $lives' : 'Doğru cevap: $correctAnswer\nKalan can: $lives',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _generateNewPattern();
                showHint = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(_isEn ? 'Continue' : 'Devam Et'),
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
      userName: authProvider.currentUser?.displayName ?? (_isEn ? 'Player' : 'Oyuncu'),
      score: score.round(),
      difficulty: currentLevel,
      gameType: GameType.patternDetective,
      completedAt: DateTime.now(),
    );

    await _leaderboardService.addScore(entry);
  }

  void _showHintDialog() {
    String hintText = '';

    if (_isEn) {
      switch (currentPatternType) {
        case 'numeric':
          hintText = 'Hint: Find the difference between the numbers!';
          break;
        case 'arithmetic':
          hintText = 'Hint: Which operation is repeating?';
          break;
        case 'geometric':
          hintText = 'Hint: The order of shapes is repeating!';
          break;
        case 'color':
          hintText = 'Hint: The color order is repeating!';
          break;
        case 'letter':
          hintText = 'Hint: How many letters does it skip in the alphabet?';
          break;
        case 'symbol':
          hintText = 'Hint: The symbol order is repeating!';
          break;
      }
    } else {
      switch (currentPatternType) {
        case 'numeric':
          hintText = 'İpucu: Sayılar arasındaki farkı bul!';
          break;
        case 'arithmetic':
          hintText = 'İpucu: Hangi işlem tekrar ediyor?';
          break;
        case 'geometric':
          hintText = 'İpucu: Şekillerin sırası tekrar ediyor!';
          break;
        case 'color':
          hintText = 'İpucu: Renk sırası tekrar ediyor!';
          break;
        case 'letter':
          hintText = 'İpucu: Alfabede kaç harf atlıyor?';
          break;
        case 'symbol':
          hintText = 'İpucu: Sembol sırası tekrar ediyor!';
          break;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb, color: AppTheme.warningOrange),
            const SizedBox(width: 8),
            Text(_isEn ? 'Hint' : 'İpucu'),
          ],
        ),
        content: Text(hintText, style: const TextStyle(fontSize: 16)),
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
            child: Text(_isEn ? 'OK' : 'Tamam'),
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
        title: Text(_isEn ? 'Code Detective' : 'Kod Dedektifi', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _showHintDialog,
            tooltip: _isEn ? 'Hint' : 'İpucu',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.05),
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
                    _buildPatternDisplay(),
                    const SizedBox(height: 32),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(_isEn ? 'Level' : 'Seviye', '$currentLevel/$maxLevels', Icons.trending_up, AppTheme.primaryBlue),
          _buildStatItem(_isEn ? 'Score' : 'Skor', '$score', Icons.stars, AppTheme.warningOrange),
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
          _isEn ? 'Lives' : 'Can',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInstructionCard() {
    String instruction = '';

    if (_isEn) {
      switch (currentPatternType) {
        case 'numeric':
          instruction = 'Complete the number sequence';
          break;
        case 'arithmetic':
          instruction = 'Find the operation pattern';
          break;
        case 'geometric':
          instruction = 'Complete the shape order';
          break;
        case 'color':
          instruction = 'Complete the color pattern';
          break;
        case 'letter':
          instruction = 'Complete the letter sequence';
          break;
        case 'symbol':
          instruction = 'Complete the symbol pattern';
          break;
      }
    } else {
      switch (currentPatternType) {
        case 'numeric':
          instruction = 'Sayı dizisini tamamla';
          break;
        case 'arithmetic':
          instruction = 'İşlem desenini bul';
          break;
        case 'geometric':
          instruction = 'Şekil sırasını tamamla';
          break;
        case 'color':
          instruction = 'Renk desenini tamamla';
          break;
        case 'letter':
          instruction = 'Harf dizisini tamamla';
          break;
        case 'symbol':
          instruction = 'Sembol desenini tamamla';
          break;
      }
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.psychology, color: AppTheme.primaryBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instruction,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEn ? 'Select the value that completes the pattern' : 'Deseni tamamlayan değeri seç',
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

  Widget _buildPatternDisplay() {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            ...pattern.map((item) => _buildPatternItem(item, false)),
            _buildPatternItem('?', true),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(String item, bool isQuestion) {
    if (item.startsWith('shape_')) {
      final index = int.parse(item.split('_')[1]);
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isQuestion ? AppTheme.warningOrange.withValues(alpha: 0.2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isQuestion ? Icons.help_outline : shapes[index],
          size: 32,
          color: isQuestion ? AppTheme.warningOrange : AppTheme.primaryBlue,
        ),
      );
    } else if (item.startsWith('color_')) {
      final index = int.parse(item.split('_')[1]);
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isQuestion ? AppTheme.warningOrange.withValues(alpha: 0.2) : colors[index],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: isQuestion
            ? const Icon(Icons.help_outline, color: AppTheme.warningOrange, size: 32)
            : null,
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isQuestion ? AppTheme.warningOrange.withValues(alpha: 0.2) : AppTheme.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryBlue, width: 2),
        ),
        child: Center(
          child: Text(
            item,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isQuestion ? AppTheme.warningOrange : AppTheme.primaryBlue,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildOptionsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return _buildOptionCard(options[index]);
      },
    );
  }

  Widget _buildOptionCard(String option) {
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
                AppTheme.primaryBlue.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Center(
            child: _buildOptionContent(option),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionContent(String option) {
    if (option.startsWith('shape_')) {
      final index = int.parse(option.split('_')[1]);
      return Icon(shapes[index], size: 48, color: AppTheme.primaryBlue);
    } else if (option.startsWith('color_')) {
      final index = int.parse(option.split('_')[1]);
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: colors[index],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors[index].withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    } else {
      return Text(
        option,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
        ),
      );
    }
  }

  Widget _buildResultScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: gameWon ? AppTheme.successGreen : AppTheme.errorRed,
        foregroundColor: Colors.white,
        title: Text(gameWon ? (_isEn ? 'Congratulations!' : 'Tebrikler!') : (_isEn ? 'Game Over' : 'Oyun Bitti')),
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
                gameWon ? (_isEn ? 'Great Job!' : 'Harika İş!') : (_isEn ? 'Try Again!' : 'Tekrar Dene!'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: gameWon ? AppTheme.successGreen : AppTheme.errorRed,
                ),
              ),
              const SizedBox(height: 16),
              _buildResultCard(_isEn ? 'Level' : 'Seviye', '$currentLevel/$maxLevels', Icons.trending_up),
              _buildResultCard(_isEn ? 'Score' : 'Skor', '$score', Icons.stars),
              if (finalTimeSeconds != null)
                _buildResultCard(_isEn ? 'Duration' : 'Süre', _isEn ? '$finalTimeSeconds seconds' : '$finalTimeSeconds saniye', Icons.timer),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: Text(_isEn ? 'Main Menu' : 'Ana Menü'),
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
                        _generateNewPattern();
                      });
                    },
                    icon: const Icon(Icons.replay),
                    label: Text(_isEn ? 'Play Again' : 'Tekrar Oyna'),
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
