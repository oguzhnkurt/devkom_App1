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

/// Bug Hunter Oyunu
/// Koddaki hataları bulma ve debug yapma yeteneklerini geliştiren oyun
class BugHunterGameScreen extends StatelessWidget {
  const BugHunterGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlayTimeGate(
      gameName: 'Bug Hunter',
      child: const _BugHunterGameContent(),
    );
  }
}

class _BugHunterGameContent extends StatefulWidget {
  const _BugHunterGameContent({Key? key}) : super(key: key);

  @override
  State<_BugHunterGameContent> createState() => _BugHunterGameContentState();
}

class _BugHunterGameContentState extends State<_BugHunterGameContent> {
  // Oyun ayarları
  final int maxLevels = 20;
  final Random _random = Random();
  final LeaderboardService _leaderboardService = LeaderboardService();

  // Oyun durumu
  int currentLevel = 1;
  double score = 0;
  int lives = 3;
  List<CodeLine> codeLines = [];
  int? bugLineIndex;
  int? selectedLineIndex;
  String bugType = '';
  String bugDescription = '';
  bool showHint = false;
  bool gameWon = false;
  bool gameOver = false;
  DateTime? startTime;
  int? finalTimeSeconds;

  // Bug türleri
  final List<String> bugTypes = [
    'syntax',           // Sözdizimi hatası
    'logic',            // Mantık hatası
    'variable',         // Değişken hatası
    'operator',         // Operatör hatası
    'comparison',       // Karşılaştırma hatası
    'loop',             // Döngü hatası
    'condition',        // Koşul hatası
  ];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _generateNewLevel();
  }

  String get currentBugType {
    if (currentLevel <= 3) return 'syntax';
    if (currentLevel <= 6) return 'operator';
    if (currentLevel <= 9) return 'comparison';
    if (currentLevel <= 12) return 'variable';
    if (currentLevel <= 15) return 'logic';
    if (currentLevel <= 17) return 'condition';
    return 'loop';
  }

  void _generateNewLevel() {
    codeLines = [];
    bugLineIndex = null;
    selectedLineIndex = null;
    bugType = currentBugType;
    showHint = false;

    switch (bugType) {
      case 'syntax':
        _generateSyntaxBug();
        break;
      case 'operator':
        _generateOperatorBug();
        break;
      case 'comparison':
        _generateComparisonBug();
        break;
      case 'variable':
        _generateVariableBug();
        break;
      case 'logic':
        _generateLogicBug();
        break;
      case 'condition':
        _generateConditionBug();
        break;
      case 'loop':
        _generateLoopBug();
        break;
    }

    setState(() {});
  }

  void _generateSyntaxBug() {
    final bugs = [
      'Noktalı virgül eksik',
      'Parantez kapanmamış',
      'Süslü parantez eksik',
      'Tırnak işareti kapanmamış',
    ];

    final bugIndex = _random.nextInt(bugs.length);
    bugDescription = bugs[bugIndex];

    codeLines = [
      CodeLine('int x = 10;', false),
      CodeLine('int y = 20;', false),
      CodeLine('int toplam = x + y', bugIndex == 0), // Noktalı virgül eksik
      CodeLine('print(toplam;', bugIndex == 1),      // Parantez kapanmamış
      CodeLine('if (toplam > 25) {', false),
      CodeLine('  print("Büyük")', bugIndex == 0),   // Noktalı virgül eksik
      CodeLine(bugIndex == 2 ? '// Eksik }' : '}', bugIndex == 2), // Süslü parantez eksik
    ];

    bugLineIndex = codeLines.indexWhere((line) => line.hasBug);
  }

  void _generateOperatorBug() {
    final bugs = [
      'Yanlış operatör kullanımı',
      'Çarpma yerine toplama',
      'Bölme yerine çarpma',
    ];

    bugDescription = bugs[_random.nextInt(bugs.length)];

    codeLines = [
      CodeLine('int fiyat = 100;', false),
      CodeLine('int adet = 5;', false),
      CodeLine('int toplam = fiyat + adet;', true),  // + yerine * olmalı
      CodeLine('print(toplam);', false),
      CodeLine('// Toplam = 500 olmalı', false),
    ];

    bugLineIndex = 2;
  }

  void _generateComparisonBug() {
    final bugs = [
      'Karşılaştırma operatörü yanlış',
      '= yerine == kullanılmalı',
      '> yerine < kullanılmalı',
    ];

    bugDescription = bugs[_random.nextInt(bugs.length)];

    codeLines = [
      CodeLine('int yas = 15;', false),
      CodeLine('if (yas = 18) {', true),             // = yerine == olmalı
      CodeLine('  print("Yetişkin");', false),
      CodeLine('} else {', false),
      CodeLine('  print("Çocuk");', false),
      CodeLine('}', false),
    ];

    bugLineIndex = 1;
  }

  void _generateVariableBug() {
    final bugs = [
      'Değişken tanımlanmamış',
      'Değişken ismi yanlış',
      'Değişken kullanılmadan önce atanmamış',
    ];

    bugDescription = bugs[_random.nextInt(bugs.length)];

    codeLines = [
      CodeLine('int sayi1 = 10;', false),
      CodeLine('int sayi2 = 20;', false),
      CodeLine('int sonuc = sayi1 + sayi3;', true), // sayi3 tanımlı değil
      CodeLine('print(sonuc);', false),
    ];

    bugLineIndex = 2;
  }

  void _generateLogicBug() {
    bugDescription = 'Mantık hatası - Yanlış hesaplama';

    codeLines = [
      CodeLine('int not1 = 80;', false),
      CodeLine('int not2 = 90;', false),
      CodeLine('int not3 = 70;', false),
      CodeLine('double ortalama = (not1 + not2) / 3;', true), // not3 eksik
      CodeLine('print(ortalama);', false),
      CodeLine('// Ortalama = 80 olmalı', false),
    ];

    bugLineIndex = 3;
  }

  void _generateConditionBug() {
    bugDescription = 'Koşul hatası - Yanlış karşılaştırma';

    codeLines = [
      CodeLine('int puan = 85;', false),
      CodeLine('if (puan > 90) {', false),
      CodeLine('  print("Mükemmel");', false),
      CodeLine('} else if (puan < 80) {', true),     // < yerine >= olmalı
      CodeLine('  print("İyi");', false),
      CodeLine('} else {', false),
      CodeLine('  print("Orta");', false),
      CodeLine('}', false),
    ];

    bugLineIndex = 3;
  }

  void _generateLoopBug() {
    bugDescription = 'Döngü hatası - Sonsuz döngü riski';

    codeLines = [
      CodeLine('int i = 0;', false),
      CodeLine('while (i < 10) {', false),
      CodeLine('  print(i);', false),
      CodeLine('  // i++; eksik', true),             // i++ eksik - sonsuz döngü
      CodeLine('}', false),
    ];

    bugLineIndex = 3;
  }

  void _checkAnswer(int selectedIndex) async {
    setState(() => selectedLineIndex = selectedIndex);

    await Future.delayed(const Duration(milliseconds: 300));

    if (selectedIndex == bugLineIndex) {
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
        selectedLineIndex = null;
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
            const Text('Yanlış Satır'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Doğru satır: ${bugLineIndex! + 1}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              bugDescription,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
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
              setState(() {
                selectedLineIndex = null;
                _generateNewLevel();
              });
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
      gameType: GameType.bugHunter,
      completedAt: DateTime.now(),
    );

    await _leaderboardService.addScore(entry);
  }

  void _showHintDialog() {
    String hintText = '';

    switch (bugType) {
      case 'syntax':
        hintText = 'İpucu: Noktalama işaretlerini ve parantezleri kontrol et!';
        break;
      case 'operator':
        hintText = 'İpucu: İşlem operatörü doğru mu?';
        break;
      case 'comparison':
        hintText = 'İpucu: Atama (=) ile karşılaştırma (==) farklıdır!';
        break;
      case 'variable':
        hintText = 'İpucu: Tüm değişkenler tanımlandı mı?';
        break;
      case 'logic':
        hintText = 'İpucu: Hesaplama formülü doğru mu?';
        break;
      case 'condition':
        hintText = 'İpucu: Karşılaştırma operatörü mantıklı mı?';
        break;
      case 'loop':
        hintText = 'İpucu: Döngü değişkeni güncelleniyor mu?';
        break;
    }

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
            Text(
              hintText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Hata Türü: $bugDescription',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
        title: const Text('Bug Hunter', style: TextStyle(fontWeight: FontWeight.bold)),
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
              AppTheme.errorRed.withOpacity(0.05),
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
                    _buildBugTypeCard(),
                    const SizedBox(height: 24),
                    _buildCodeEditor(),
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
                color: AppTheme.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bug_report, color: AppTheme.errorRed, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hata Avcılığı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Koddaki hatayı içeren satırı bul',
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

  Widget _buildBugTypeCard() {
    IconData icon;
    Color color;

    switch (bugType) {
      case 'syntax':
        icon = Icons.format_quote;
        color = AppTheme.errorRed;
        break;
      case 'operator':
        icon = Icons.calculate;
        color = AppTheme.warningOrange;
        break;
      case 'comparison':
        icon = Icons.compare;
        color = Colors.purple;
        break;
      case 'variable':
        icon = Icons.text_fields;
        color = AppTheme.primaryBlue;
        break;
      case 'logic':
        icon = Icons.psychology;
        color = AppTheme.accentTeal;
        break;
      case 'condition':
        icon = Icons.alt_route;
        color = Colors.indigo;
        break;
      case 'loop':
        icon = Icons.loop;
        color = Colors.orange;
        break;
      default:
        icon = Icons.bug_report;
        color = AppTheme.errorRed;
    }

    return Card(
      elevation: 3,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bugDescription,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hatalı satırı tıkla',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.bug_report, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'buggy_code.dart',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...codeLines.asMap().entries.map((entry) {
              final index = entry.key;
              final line = entry.value;
              return _buildCodeLine(index, line);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeLine(int index, CodeLine line) {
    final isSelected = selectedLineIndex == index;
    final isCorrect = bugLineIndex == index;
    final showResult = isSelected && (isCorrect || !isCorrect);

    Color? backgroundColor;
    if (showResult) {
      backgroundColor = isCorrect
          ? AppTheme.successGreen.withOpacity(0.2)
          : AppTheme.errorRed.withOpacity(0.2);
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryBlue.withOpacity(0.1);
    }

    return InkWell(
      onTap: selectedLineIndex == null ? () => _checkAnswer(index) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? Border.all(
                  color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (showResult)
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                size: 20,
              ),
            if (showResult) const SizedBox(width: 8),
            Expanded(
              child: Text(
                line.code,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  height: 1.5,
                ),
              ),
            ),
            if (line.hasBug && showHint)
              Icon(Icons.warning, color: AppTheme.warningOrange, size: 20),
          ],
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
                gameWon ? 'Harika Bir Hata Avcısısın!' : 'Tekrar Dene!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: gameWon ? AppTheme.successGreen : AppTheme.errorRed,
                ),
                textAlign: TextAlign.center,
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

/// Kod satırı modeli
class CodeLine {
  final String code;
  final bool hasBug;

  CodeLine(this.code, this.hasBug);
}
