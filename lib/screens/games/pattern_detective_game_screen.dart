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
import '../../utils/lang.dart';

/// Kod Dedektifi Oyunu
/// Pattern matching ve dizi tamamlama yeteneklerini geliştiren oyun
class PatternDetectiveGameScreen extends StatelessWidget {
  const PatternDetectiveGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn = Provider.of<SettingsProvider>(context, listen: false)
            .locale
            .languageCode ==
        'en';
    return PlayTimeGate(
      gameName: isEn ? 'Code Detective' : 'Kod Dedektifi',
      child: const _PatternDetectiveGameContent(),
    );
  }
}

class _PatternDetectiveGameContent extends StatefulWidget {
  const _PatternDetectiveGameContent();

  @override
  State<_PatternDetectiveGameContent> createState() =>
      _PatternDetectiveGameContentState();
}

class _PatternDetectiveGameContentState
    extends State<_PatternDetectiveGameContent> {
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

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  ///
  /// Onceki surumde her yerde `_isEn ? ingilizce : turkce` vardi; almanca
  /// ya da ispanyolca secen cocuk oyunun tamamini turkce goruyordu.
  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  // Pattern türleri
  final List<String> patternTypes = [
    'numeric', // Sayı dizileri (1,2,3,4,?)
    'arithmetic', // Aritmetik işlemler (2,4,6,8,?)
    'geometric', // Geometrik şekiller
    'color', // Renk desenleri
    'letter', // Harf dizileri (A,B,C,D,?)
    'symbol', // Sembol desenleri
  ];

  // Şekiller, renkler ve semboller
  final List<IconData> shapes = [
    Icons.circle_rounded,
    Icons.square_rounded,
    Icons.change_history_rounded, // Üçgen
    Icons.star_rounded,
    Icons.favorite_rounded,
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
    // Bu ekranin ses rengi (Desen). Butun oyunlarda ayni tonu
    // calmak oyunlari birbirinden ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.soft);
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

  /// Gercekten TEKRAR EDEN bir desen uretir: A B A B ? ya da A B C A B ?
  ///
  /// SEKIL, RENK VE SEMBOL DESENLERINDE CIKARILABILIR BIR KURAL YOKTU.
  ///
  /// Eski uretici `pattern`e listenin ilk 2-3 ogesini koyuyor, dogru
  /// cevap olarak da bir SONRAKI ogeyi aliyordu:
  ///
  ///     pattern = [shape_0, shape_1]      correctAnswer = shape_2
  ///
  /// Yani ekranda tekrar eden hicbir sey yoktu; cocuktan koddaki gizli
  /// sekil sirasini bilmesi bekleniyordu. Ipucu ise "sıra tekrar ediyor"
  /// diyordu. Oyun cozulebilir degildi, tahmin oyunuydu.
  ///
  /// Simdi havuzdan 2 ya da 3 ogelik bir dongu seciliyor ve ekranda EN AZ
  /// IKI TUR gorunuyor; dogru cevap dongunun bir sonraki ogesi.
  /// Yanlis secenekler ayni dongunun obur ogelerini de iceriyor: en
  /// cezbedici yanlis odur, ve onu elemek icin deseni saymak gerekir.
  void _dongulukDesenKur(List<String> havuz) {
    final karisik = [...havuz]..shuffle(_random);
    final donguBoyu = _random.nextInt(2) + 2; // 2 ya da 3
    final dongu = karisik.take(donguBoyu).toList();

    final gorunen = donguBoyu == 2 ? 4 : 5; // iki tam tur (ya da 1,67)
    pattern = List.generate(gorunen, (i) => dongu[i % donguBoyu]);
    correctAnswer = dongu[gorunen % donguBoyu];

    final yanlislar = <String>{};
    // Once dongunun obur ogeleri: en mantikli yanlis secenek.
    for (final o in dongu) {
      if (o != correctAnswer) yanlislar.add(o);
    }
    // Sonra havuzdan doldur.
    while (yanlislar.length < 3) {
      final o = havuz[_random.nextInt(havuz.length)];
      if (o != correctAnswer) yanlislar.add(o);
    }

    options = [correctAnswer!, ...yanlislar.take(3)]..shuffle();
  }

  // Geometrik şekiller
  void _generateGeometricPattern() {
    _dongulukDesenKur(List.generate(shapes.length, (i) => 'shape_$i'));
  }


  // Renk desenleri
  void _generateColorPattern() {
    _dongulukDesenKur(List.generate(colors.length, (i) => 'color_$i'));
  }


  // Harf dizileri
  /// Bir cevabi cocugun okuyabilecegi bir isme cevirir.
  ///
  /// Sayi ve harf desenlerinde cevap zaten okunabilir. Sekil, renk ve
  /// sembol desenlerinde ise ic bir anahtar ('shape_2', 'color_3') ve
  /// bu anahtar dogrudan ekrana basiliyordu.
  String _readableAnswer(String? answer) {
    if (answer == null) return '';
    if (!answer.contains('_')) return answer;

    final parts = answer.split('_');
    final index = int.tryParse(parts.length > 1 ? parts[1] : '');
    if (index == null) return answer;

    // Sekil ve renk adlari dort dilde. Onceki hali
    // `_lang == 'tr' ? ...Tr : ...En` idi; Almanca ve Ispanyolca oynayan
    // cocuk ipucunda "circle" ve "blue" goruyordu.
    const shapeNamesTr = [
      'daire',
      'kare',
      'üçgen',
      'yıldız',
      'kalp',
      'altıgen'
    ];
    const shapeNamesEn = [
      'circle',
      'square',
      'triangle',
      'star',
      'heart',
      'hexagon'
    ];
    const shapeNamesDe = [
      'Kreis',
      'Quadrat',
      'Dreieck',
      'Stern',
      'Herz',
      'Sechseck'
    ];
    const shapeNamesEs = [
      'círculo',
      'cuadrado',
      'triángulo',
      'estrella',
      'corazón',
      'hexágono'
    ];
    const colorNamesTr = [
      'mavi',
      'yeşil',
      'kırmızı',
      'turuncu',
      'turkuaz',
      'mor'
    ];
    const colorNamesEn = ['blue', 'green', 'red', 'orange', 'teal', 'purple'];
    const colorNamesDe = [
      'blau',
      'grün',
      'rot',
      'orange',
      'türkis',
      'lila'
    ];
    const colorNamesEs = [
      'azul',
      'verde',
      'rojo',
      'naranja',
      'turquesa',
      'morado'
    ];

    switch (parts[0]) {
      case 'shape':
        final names = AppLang.pickOf(
          _lang,
          tr: shapeNamesTr,
          en: shapeNamesEn,
          de: shapeNamesDe,
          es: shapeNamesEs,
        );
        return index < names.length ? names[index] : answer;
      case 'color':
        final names = AppLang.pickOf(
          _lang,
          tr: colorNamesTr,
          en: colorNamesEn,
          de: colorNamesDe,
          es: colorNamesEs,
        );
        return index < names.length ? names[index] : answer;
      case 'symbol':
        return index < symbols.length ? symbols[index] : answer;
      default:
        return answer;
    }
  }

  void _generateLetterPattern() {
    final step = _random.nextInt(2) + 1;
    final length = min(4 + (currentLevel ~/ 5), 6);

    // DIZI ALFABENIN DISINA TASIYORDU.
    //
    // Baslangic 0-19 arasindan seciliyor, adim 2 olabiliyor ve dizi 6
    // uzunluga cikiyordu: 19 + 5*2 = 29, yani 'Z'yi (25) asip '\' ve '^'
    // karakterlerine varan diziler cikiyordu. Yanlis secenekler ise
    // yalnizca A-Z'den uretildigi icin, harf olmayan karakter HER ZAMAN
    // dogru cevap oluyordu: cocuk deseni cozmeden kazaniyordu.
    //
    // Artik baslangic, dizinin son harfi 'Z'yi asmayacak sekilde
    // siniralaniyor.
    final span = (length - 1) * step;
    final start = _random.nextInt(26 - span);

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
    _dongulukDesenKur(symbols);
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
            Icon(Icons.close_rounded, color: AppTheme.errorRed),
            const SizedBox(width: 8),
            Text(_tl('Yanlış Cevap', 'Wrong Answer', 'Falsche Antwort', 'Respuesta incorrecta')),
          ],
        ),
        // HAM ANAHTAR GOSTERILIYORDU.
        //
        // Sekil, renk ve sembol seviyelerinde `correctAnswer` bir ic
        // anahtar ('shape_2', 'color_3'). Cocuk "Dogru cevap: color_3"
        // yazisini okuyordu. Artik anahtarlar okunabilir bir isme
        // cevriliyor.
        content: Text(
          _tl('Doğru cevap: ${_readableAnswer(correctAnswer)}'
                  '\nKalan can: $lives', 'Correct answer: ${_readableAnswer(correctAnswer)}'
                  '\nLives left: $lives', 'Richtige Antwort: ${_readableAnswer(correctAnswer)}\nVerbleibende Leben: $lives', 'Respuesta correcta: ${_readableAnswer(correctAnswer)}\nVidas restantes: $lives'),
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
      userName: authProvider.currentUser?.displayName ??
          (_tl('Oyuncu', 'Player', 'Spieler', 'Jugador')),
      score: score.round(),
      difficulty: currentLevel,
      gameType: GameType.patternDetective,
      completedAt: DateTime.now(),
    );

    await _leaderboardService.addScore(entry);
  }

  void _showHintDialog() {
    // Ipuclari yalnizca Turkce ve Ingilizce idi; almanca ya da
    // ispanyolca secen cocuk Ingilizce ipucu goruyordu.
    String hintText;
    switch (currentPatternType) {
      case 'numeric':
        hintText = _tl(
            'İpucu: Sayılar arasındaki farkı bul!',
            'Hint: Find the difference between the numbers!',
            'Tipp: Finde den Abstand zwischen den Zahlen!',
            'Pista: ¡Busca la diferencia entre los números!');
        break;
      case 'arithmetic':
        hintText = _tl(
            'İpucu: Hangi işlem tekrar ediyor?',
            'Hint: Which operation is repeating?',
            'Tipp: Welche Rechenart wiederholt sich?',
            'Pista: ¿Qué operación se repite?');
        break;
      case 'geometric':
        hintText = _tl(
            'İpucu: Şekillerin sırası tekrar ediyor!',
            'Hint: The order of shapes is repeating!',
            'Tipp: Die Reihenfolge der Formen wiederholt sich!',
            'Pista: ¡El orden de las formas se repite!');
        break;
      case 'color':
        hintText = _tl(
            'İpucu: Renk sırası tekrar ediyor!',
            'Hint: The color order is repeating!',
            'Tipp: Die Reihenfolge der Farben wiederholt sich!',
            'Pista: ¡El orden de los colores se repite!');
        break;
      case 'letter':
        hintText = _tl(
            'İpucu: Alfabede kaç harf atlıyor?',
            'Hint: How many letters does it skip in the alphabet?',
            'Tipp: Wie viele Buchstaben überspringt es im Alphabet?',
            'Pista: ¿Cuántas letras salta en el alfabeto?');
        break;
      default:
        hintText = _tl(
            'İpucu: Sembol sırası tekrar ediyor!',
            'Hint: The symbol order is repeating!',
            'Tipp: Die Reihenfolge der Zeichen wiederholt sich!',
            'Pista: ¡El orden de los símbolos se repite!');
    }

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
        title: Text(_tl('Kod Dedektifi', 'Code Detective', 'Code-Detektiv', 'Detective de código'),
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
                        _buildPatternDisplay(),
                        const SizedBox(height: 32),
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
          _buildLivesIndicator(),
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

  Widget _buildLivesIndicator() {
    return Column(
      children: [
        Row(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                index < lives
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: AppTheme.errorRed,
                size: 20,
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          _tl('Can', 'Lives', 'Leben', 'Vidas'),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInstructionCard() {
    // Yonerge de yalnizca iki dildeydi.
    final String instruction;
    switch (currentPatternType) {
      case 'numeric':
        instruction = _tl('Sayı dizisini tamamla', 'Complete the number sequence',
            'Vervollständige die Zahlenreihe', 'Completa la serie de números');
        break;
      case 'arithmetic':
        instruction = _tl('İşlem desenini bul', 'Find the operation pattern',
            'Finde das Rechenmuster', 'Encuentra el patrón de la operación');
        break;
      case 'geometric':
        instruction = _tl('Şekil sırasını tamamla', 'Complete the shape order',
            'Vervollständige die Formenreihe', 'Completa el orden de las formas');
        break;
      case 'color':
        instruction = _tl('Renk desenini tamamla', 'Complete the color pattern',
            'Vervollständige das Farbmuster', 'Completa el patrón de colores');
        break;
      case 'letter':
        instruction = _tl('Harf dizisini tamamla', 'Complete the letter sequence',
            'Vervollständige die Buchstabenreihe',
            'Completa la serie de letras');
        break;
      default:
        instruction = _tl('Sembol desenini tamamla',
            'Complete the symbol pattern', 'Vervollständige das Zeichenmuster',
            'Completa el patrón de símbolos');
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
                    _tl('Deseni tamamlayan değeri seç',
                        'Select the value that completes the pattern',
                        'Wähle den Wert, der das Muster vervollständigt',
                        'Elige el valor que completa el patrón'),
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
                            lives = 3;
                            gameWon = false;
                            gameOver = false;
                            startTime = DateTime.now();
                            _generateNewPattern();
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
