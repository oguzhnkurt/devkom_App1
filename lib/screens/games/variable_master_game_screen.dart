import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../models/game_model.dart';
import '../../models/leaderboard_model.dart';
import '../../services/leaderboard_service.dart';
import '../../services/sound_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/score_calculator.dart';
import '../../widgets/play_time_gate.dart';
import '../../utils/lang.dart';

/// Değişken Ustası Oyunu
/// Değişken kavramını, atama işlemlerini ve değişken değerlerini takip etmeyi öğreten oyun
class VariableMasterGameScreen extends StatelessWidget {
  const VariableMasterGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn = Provider.of<SettingsProvider>(context, listen: false)
            .locale
            .languageCode ==
        'en';
    return PlayTimeGate(
      gameName: isEn ? 'Variable Master' : 'Değişken Ustası',
      child: const _VariableMasterGameContent(),
    );
  }
}

class _VariableMasterGameContent extends StatefulWidget {
  const _VariableMasterGameContent();

  @override
  State<_VariableMasterGameContent> createState() =>
      _VariableMasterGameContentState();
}

class _VariableMasterGameContentState
    extends State<_VariableMasterGameContent> {
  // Oyun ayarları
  final int maxLevels = 20;
  final Random _random = Random();
  final LeaderboardService _leaderboardService = LeaderboardService();

  // Oyun durumu
  int currentLevel = 1;
  double score = 0;
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
    'x',
    'y',
    'z',
    'a',
    'b',
    'c',
    'n',
    'm',
    'k',
    'i',
    'j',
    'p',
    'q',
    'r',
    's',
    't'
  ];

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
    // Bu ekranin ses rengi (Degisken). Butun oyunlarda ayni tonu
    // calmak oyunlari birbirinden ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.deep);
    startTime = DateTime.now();
    _generateNewLevel();
  }

  int get operationCount {
    if (currentLevel <= 5) return 2; // Seviye 1-5: 2 işlem
    if (currentLevel <= 10) return 3; // Seviye 6-10: 3 işlem
    if (currentLevel <= 15) return 4; // Seviye 11-15: 4 işlem
    return 5; // Seviye 16-20: 5 işlem
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
      final operationType = _random.nextInt(
          5); // 0: atama, 1: toplama, 2: çıkarma, 3: çarpma, 4: kopyalama

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
        final sourceVar = currentVariables.keys
            .elementAt(_random.nextInt(currentVariables.length));
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
            currentVariables[variable] =
                max(0, currentVariables[variable]! - value);
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
    questionVariable = currentVariables.keys
        .elementAt(_random.nextInt(currentVariables.length));
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

  /// Ayni soruya iki kez puan verilmesini engeller.
  ///
  /// Secenekler 500 ms'lik bekleme boyunca canli kaliyordu; hizli iki
  /// dokunus ayni soruyu iki kez puanliyor ve bir seviyeyi atliyordu.
  bool _resolving = false;

  void _checkAnswer(int selectedAnswer) async {
    if (_resolving) return;
    _resolving = true;

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
        _resolving = false;
        _completeGame();
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        _generateNewLevel();
        _resolving = false;
      }
    } else {
      // CAN SISTEMI KALDIRILDI.
      //
      // Yanlis cevap bir can goturuyor, uc yanlista 20 seviyelik oyun
      // bitiyordu. Bu yas grubu icin alinmis karara aykiri: yanlislarin
      // buyuk kismi bilgi hatasi degil parmak hatasi, ve butun ilerlemeyi
      // silmek puan kirmaktan cok daha agir bir ceza. Artik cocuk dogru
      // cevabi goruyor ve ayni soruyu tekrar deniyor.
      await SoundService.playWrong();
      _showWrongAnswerDialog();
      _resolving = false;
    }
  }

  void _showWrongAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.close_rounded, color: AppTheme.errorRed),
            const SizedBox(width: 8),
            Text(_tl('Yanlış Cevap', 'Wrong Answer', 'Falsche Antwort', 'Respuesta incorrecta')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _tl('Doğru cevap: $correctAnswer', 'Correct answer: $correctAnswer', 'Richtige Antwort: $correctAnswer', 'Respuesta correcta: $correctAnswer'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            child: Text(_tl('Devam Et', 'Continue', 'Weiter', 'Continuar')),
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

  Future<void> _saveToLeaderboard() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;

    if (userId == null) return;

    final entry = LeaderboardEntry(
      id: '',
      userId: userId,
      userName: authProvider.currentUser?.displayName ??
          (_tl('Oyuncu', 'Player', 'Spieler', 'Jugador')),
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
            Icon(Icons.lightbulb_rounded, color: AppTheme.warningOrange),
            const SizedBox(width: 8),
            Text(_tl('İpucu', 'Hint', 'Tipp', 'Pista')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tl('Değişken Değerlerini Takip Et:', 'Track the Variable Values:', 'Verfolge die Werte der Variablen:', 'Sigue los valores de las variables:'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...currentVariables.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: entry.key == questionVariable
                            ? AppTheme.warningOrange.withValues(alpha: 0.2)
                            : AppTheme.primaryBlue.withValues(alpha: 0.1),
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
            }),
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
            child: Text(_tl('Tamam', 'OK', 'OK', 'Aceptar')),
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
        title: Text(_tl('Değişken Ustası', 'Variable Master', 'Variablen-Meister', 'Maestro de variables'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded),
            onPressed: _showHintDialog,
            tooltip: _tl('İpucu', 'Hint', 'Tipp', 'Pista'),
          ),
        ],
      ),
      body: SafeArea(
          top: false,
          child: Container(
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
          )),
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
          _buildStatItem(_tl('Seviye', 'Level', 'Level', 'Nivel'), '$currentLevel/$maxLevels',
              Icons.trending_up_rounded, AppTheme.primaryBlue),
          _buildStatItem(_tl('Skor', 'Score', 'Punkte', 'Puntos'), '${score.round()}',
              Icons.stars_rounded, AppTheme.warningOrange),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
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

  /// Kalp sirasinin yerini alan ilerleme gostergesi.
  ///
  /// Uc kalp, "uc yanlista her sey biter" demenin gorsel haliydi. Ceza
  /// kalkinca gosterge de anlamsizlasti; yerine cocugun nerede oldugunu
  /// soyleyen bir sey koyduk.
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Icon(Icons.flag_rounded, color: AppTheme.primaryBlue, size: 20),
        const SizedBox(height: 4),
        Text(
          _tl('Seviye', 'Level', 'Level', 'Nivel'),
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
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.code_rounded,
                  color: AppTheme.primaryBlue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tl('Kod Yürütme', 'Code Execution', 'Code-Ausführung', 'Ejecución del código'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tl('Kodu takip et ve değişken değerini bul', 'Follow the code and find the variable value', 'Folge dem Code und finde den Wert der Variablen', 'Sigue el código y encuentra el valor de la variable'),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.code_rounded, color: Colors.white, size: 16),
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
            }),
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
      color: AppTheme.warningOrange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline_rounded,
                    color: AppTheme.warningOrange, size: 28),
                const SizedBox(width: 12),
                Text(
                  _tl('Soru', 'Question', 'Frage', 'Pregunta'),
                  style: const TextStyle(
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
                AppTheme.primaryBlue.withValues(alpha: 0.05),
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
        title: Text(gameWon
            ? (_tl('Tebrikler!', 'Congratulations!', 'Glückwunsch!', '¡Felicidades!'))
            : (_tl('Oyun Bitti', 'Game Over', 'Spiel vorbei', 'Fin del juego'))),
      ),
      body: SafeArea(
          top: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    gameWon
                        ? Icons.emoji_events_rounded
                        : Icons.refresh_rounded,
                    size: 100,
                    color: gameWon ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    gameWon
                        ? (_tl('Harika İş!', 'Great Job!', 'Gut gemacht!', '¡Buen trabajo!'))
                        : (_tl('Tekrar Dene!', 'Try Again!', 'Versuch es noch mal!', '¡Inténtalo otra vez!')),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color:
                          gameWon ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildResultCard(_tl('Seviye', 'Level', 'Level', 'Nivel'),
                      '$currentLevel/$maxLevels', Icons.trending_up_rounded),
                  _buildResultCard(_tl('Skor', 'Score', 'Punkte', 'Puntos'), '${score.round()}',
                      Icons.stars_rounded),
                  if (finalTimeSeconds != null)
                    _buildResultCard(
                        _tl('Süre', 'Duration', 'Dauer', 'Duración'),
                        _tl('$finalTimeSeconds saniye', '$finalTimeSeconds seconds', '$finalTimeSeconds Sekunden', '$finalTimeSeconds segundos'),
                        Icons.timer_rounded),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home_rounded),
                        label: Text(_tl('Ana Menü', 'Main Menu', 'Hauptmenü', 'Menú principal')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            currentLevel = 1;
                            score = 0;
                            gameWon = false;
                            gameOver = false;
                            startTime = DateTime.now();
                            _generateNewLevel();
                          });
                        },
                        icon: const Icon(Icons.replay_rounded),
                        label: Text(_tl('Tekrar Oyna', 'Play Again', 'Noch mal spielen', 'Jugar otra vez')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
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
