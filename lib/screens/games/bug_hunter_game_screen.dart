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

/// Bug Hunter Oyunu
/// Koddaki hataları bulma ve debug yapma yeteneklerini geliştiren oyun
class BugHunterGameScreen extends StatelessWidget {
  const BugHunterGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayTimeGate(
      gameName: 'Bug Hunter',
      child: const _BugHunterGameContent(),
    );
  }
}

class _BugHunterGameContent extends StatefulWidget {
  const _BugHunterGameContent();

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

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  /// Oyun ICERIGI (kod satirlari, seviye basliklari, eslestirme ciftleri)
  /// yalnizca turkce ve ingilizce yazildi. Almanca ya da ispanyolca secen
  /// cocuga turkce icerik vermek yerine ingilizcesini veriyoruz; ceviriler
  /// gelene kadar dogru olan bu.
  bool get _isEn => _lang != 'tr';

  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  ///
  /// Onceki surumde her yerde `_isEn ? ingilizce : turkce` vardi; almanca
  /// ya da ispanyolca secen cocuk oyunun tamamini turkce goruyordu.
  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  // Bug türleri
  final List<String> bugTypes = [
    'syntax', // Sözdizimi hatası
    'logic', // Mantık hatası
    'variable', // Değişken hatası
    'operator', // Operatör hatası
    'comparison', // Karşılaştırma hatası
    'loop', // Döngü hatası
    'condition', // Koşul hatası
  ];

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (Kod okuma). Butun oyunlarda ayni tonu
    // calmak oyunlari birbirinden ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.bright);
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
    final bugs = _isEn
        ? [
            'Missing semicolon',
            'Unclosed parenthesis',
            'Missing curly brace',
            'Unclosed quotation mark',
          ]
        : [
            'Noktalı virgül eksik',
            'Parantez kapanmamış',
            'Süslü parantez eksik',
            'Tırnak işareti kapanmamış',
          ];

    final bugIndex = _random.nextInt(bugs.length);
    bugDescription = bugs[bugIndex];

    // BU URETEC IKI SEKILDE BOZUKTU, IKISI DE SESSIZDI:
    //
    //  * `bugIndex == 3` ("tirnak kapanmamis") secildiginde HICBIR satir
    //    hatali isaretlenmiyordu. `indexWhere` -1 donuyor, cocuk hangi
    //    satira dokunursa dokunsun yanlis sayiliyor, uc canini da
    //    kaybediyor ve yanlis cevap kutusu "Dogru satir: 0" yaziyordu.
    //    Dort seviye turunden biri, yani her uc oyundan birinde
    //    kazanilmasi imkansiz bir bolum.
    //
    //  * `bugIndex == 0` ("noktali virgul eksik") secildiginde IKI satir
    //    birden hatali isaretleniyordu. `indexWhere` ilkini seciyor;
    //    ikinci satirdaki gercekten eksik noktali virgulu bulan cocuga
    //    "yanlis" deniyordu.
    //
    // Simdi her hata turu icin tam olarak BIR satir hatali, ve hatasiz
    // durumdaki satirlar gercekten dogru yazilmis kod.
    codeLines = _isEn
        ? [
            CodeLine('int x = 10;', false),
            CodeLine('int y = 20;', false),
            CodeLine(
              bugIndex == 0 ? 'int total = x + y' : 'int total = x + y;',
              bugIndex == 0,
            ),
            CodeLine(
              bugIndex == 1 ? 'print(total;' : 'print(total);',
              bugIndex == 1,
            ),
            CodeLine('if (total > 25) {', false),
            CodeLine(
              bugIndex == 3 ? '  print("Big);' : '  print("Big");',
              bugIndex == 3,
            ),
            CodeLine(bugIndex == 2 ? '// } is missing' : '}', bugIndex == 2),
          ]
        : [
            CodeLine('int x = 10;', false),
            CodeLine('int y = 20;', false),
            CodeLine(
              bugIndex == 0 ? 'int toplam = x + y' : 'int toplam = x + y;',
              bugIndex == 0,
            ),
            CodeLine(
              bugIndex == 1 ? 'print(toplam;' : 'print(toplam);',
              bugIndex == 1,
            ),
            CodeLine('if (toplam > 25) {', false),
            CodeLine(
              bugIndex == 3 ? '  print("Büyük);' : '  print("Büyük");',
              bugIndex == 3,
            ),
            CodeLine(bugIndex == 2 ? '// } eksik' : '}', bugIndex == 2),
          ];

    bugLineIndex = codeLines.indexWhere((line) => line.hasBug);
  }

  void _generateOperatorBug() {
    final bugs = _isEn
        ? [
            'Wrong operator used',
            'Addition instead of multiplication',
            'Multiplication instead of division',
          ]
        : [
            'Yanlış operatör kullanımı',
            'Çarpma yerine toplama',
            'Bölme yerine çarpma',
          ];

    // Aciklama RASTGELE seciliyordu ama koddaki hata her zaman ayni:
    // carpma yerine toplama. Cocuk "Bolme yerine carpma" ipucusunu okuyup
    // bolme ariyordu. Aciklama artik gercek hatayi anlatiyor.
    bugDescription = bugs[1];

    codeLines = _isEn
        ? [
            CodeLine('int price = 100;', false),
            CodeLine('int quantity = 5;', false),
            CodeLine('int total = price + quantity;',
                true), // should be * instead of +
            CodeLine('print(total);', false),
            CodeLine('// Total should be 500', false),
          ]
        : [
            CodeLine('int fiyat = 100;', false),
            CodeLine('int adet = 5;', false),
            CodeLine('int toplam = fiyat + adet;', true), // + yerine * olmalı
            CodeLine('print(toplam);', false),
            CodeLine('// Toplam = 500 olmalı', false),
          ];

    bugLineIndex = 2;
  }

  void _generateComparisonBug() {
    final bugs = _isEn
        ? [
            'Wrong comparison operator',
            'Should use == instead of =',
            'Should use < instead of >',
          ]
        : [
            'Karşılaştırma operatörü yanlış',
            '= yerine == kullanılmalı',
            '> yerine < kullanılmalı',
          ];

    // Koddaki hata her zaman `=` / `==`; aciklama da onu soylemeli.
    bugDescription = bugs[1];

    codeLines = _isEn
        ? [
            CodeLine('int age = 15;', false),
            CodeLine('if (age = 18) {', true), // should be == instead of =
            CodeLine('  print("Adult");', false),
            CodeLine('} else {', false),
            CodeLine('  print("Child");', false),
            CodeLine('}', false),
          ]
        : [
            CodeLine('int yas = 15;', false),
            CodeLine('if (yas = 18) {', true), // = yerine == olmalı
            CodeLine('  print("Yetişkin");', false),
            CodeLine('} else {', false),
            CodeLine('  print("Çocuk");', false),
            CodeLine('}', false),
          ];

    bugLineIndex = 1;
  }

  void _generateVariableBug() {
    final bugs = _isEn
        ? [
            'Variable not defined',
            'Variable name is wrong',
            'Variable used before being assigned',
          ]
        : [
            'Değişken tanımlanmamış',
            'Değişken ismi yanlış',
            'Değişken kullanılmadan önce atanmamış',
          ];

    // Koddaki hata her zaman tanimlanmamis bir degisken.
    bugDescription = bugs[0];

    codeLines = _isEn
        ? [
            CodeLine('int num1 = 10;', false),
            CodeLine('int num2 = 20;', false),
            CodeLine('int result = num1 + num3;', true), // num3 is not defined
            CodeLine('print(result);', false),
          ]
        : [
            CodeLine('int sayi1 = 10;', false),
            CodeLine('int sayi2 = 20;', false),
            CodeLine('int sonuc = sayi1 + sayi3;', true), // sayi3 tanımlı değil
            CodeLine('print(sonuc);', false),
          ];

    bugLineIndex = 2;
  }

  void _generateLogicBug() {
    bugDescription = _tl('Mantık hatası - Yanlış hesaplama', 'Logic error - Wrong calculation', 'Logikfehler - falsche Berechnung', 'Error de lógica: cálculo incorrecto');

    codeLines = _isEn
        ? [
            CodeLine('int grade1 = 80;', false),
            CodeLine('int grade2 = 90;', false),
            CodeLine('int grade3 = 70;', false),
            CodeLine('double average = (grade1 + grade2) / 3;',
                true), // grade3 missing
            CodeLine('print(average);', false),
            CodeLine('// Average should be 80', false),
          ]
        : [
            CodeLine('int not1 = 80;', false),
            CodeLine('int not2 = 90;', false),
            CodeLine('int not3 = 70;', false),
            CodeLine(
                'double ortalama = (not1 + not2) / 3;', true), // not3 eksik
            CodeLine('print(ortalama);', false),
            CodeLine('// Ortalama = 80 olmalı', false),
          ];

    bugLineIndex = 3;
  }

  void _generateConditionBug() {
    bugDescription = _tl('Koşul hatası - Yanlış karşılaştırma', 'Condition error - Wrong comparison', 'Bedingungsfehler - falscher Vergleich', 'Error de condición: comparación incorrecta');

    codeLines = _isEn
        ? [
            CodeLine('int score = 85;', false),
            CodeLine('if (score > 90) {', false),
            CodeLine('  print("Excellent");', false),
            CodeLine(
                '} else if (score < 80) {', true), // should be >= instead of <
            CodeLine('  print("Good");', false),
            CodeLine('} else {', false),
            CodeLine('  print("Average");', false),
            CodeLine('}', false),
          ]
        : [
            CodeLine('int puan = 85;', false),
            CodeLine('if (puan > 90) {', false),
            CodeLine('  print("Mükemmel");', false),
            CodeLine('} else if (puan < 80) {', true), // < yerine >= olmalı
            CodeLine('  print("İyi");', false),
            CodeLine('} else {', false),
            CodeLine('  print("Orta");', false),
            CodeLine('}', false),
          ];

    bugLineIndex = 3;
  }

  void _generateLoopBug() {
    bugDescription = _tl('Döngü hatası - Sonsuz döngü riski', 'Loop error - Infinite loop risk', 'Schleifenfehler - Gefahr einer Endlosschleife', 'Error de bucle: riesgo de bucle infinito');

    codeLines = _isEn
        ? [
            CodeLine('int i = 0;', false),
            CodeLine('while (i < 10) {', false),
            CodeLine('  print(i);', false),
            CodeLine('  // i++; missing', true), // i++ missing - infinite loop
            CodeLine('}', false),
          ]
        : [
            CodeLine('int i = 0;', false),
            CodeLine('while (i < 10) {', false),
            CodeLine('  print(i);', false),
            CodeLine('  // i++; eksik', true), // i++ eksik - sonsuz döngü
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
            Icon(Icons.close_rounded, color: AppTheme.errorRed),
            const SizedBox(width: 8),
            Text(_tl('Yanlış Satır', 'Wrong Line', 'Falsche Zeile', 'Línea incorrecta')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _tl('Doğru satır: ${bugLineIndex! + 1}', 'Correct line: ${bugLineIndex! + 1}', 'Richtige Zeile: ${bugLineIndex! + 1}', 'Línea correcta: ${bugLineIndex! + 1}'),
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
              _tl('Kalan can: $lives', 'Lives left: $lives', 'Verbleibende Leben: $lives', 'Vidas restantes: $lives'),
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
      gameType: GameType.bugHunter,
      completedAt: DateTime.now(),
    );

    await _leaderboardService.addScore(entry);
  }

  void _showHintDialog() {
    String hintText = '';

    if (_isEn) {
      switch (bugType) {
        case 'syntax':
          hintText = 'Hint: Check the punctuation and parentheses!';
          break;
        case 'operator':
          hintText = 'Hint: Is the operator correct?';
          break;
        case 'comparison':
          hintText = 'Hint: Assignment (=) and comparison (==) are different!';
          break;
        case 'variable':
          hintText = 'Hint: Are all variables defined?';
          break;
        case 'logic':
          hintText = 'Hint: Is the calculation formula correct?';
          break;
        case 'condition':
          hintText = 'Hint: Does the comparison operator make sense?';
          break;
        case 'loop':
          hintText = 'Hint: Is the loop variable being updated?';
          break;
      }
    } else {
      switch (bugType) {
        case 'syntax':
          hintText =
              'İpucu: Noktalama işaretlerini ve parantezleri kontrol et!';
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
                color: AppTheme.warningOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _tl('Hata Türü: $bugDescription', 'Bug Type: $bugDescription', 'Fehlerart: $bugDescription', 'Tipo de error: $bugDescription'),
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
        // Kart adi 'Hata Avcisi' oldugu icin baslik da dile uymalı;
        // aksi halde kullanici Turkce karttan Ingilizce bir ekrana giriyor.
        title: Text(_tl('Hata Avcısı', 'Bug Hunter', 'Fehlerjäger', 'Cazador de errores'),
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
                  AppTheme.errorRed.withValues(alpha: 0.05),
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
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bug_report_rounded,
                  color: AppTheme.errorRed, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tl('Hata Avcılığı', 'Bug Hunting', 'Fehlerjagd', 'Caza de errores'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tl('Koddaki hatayı içeren satırı bul', 'Find the line containing the bug in the code', 'Finde die Zeile mit dem Fehler im Code', 'Encuentra la línea con el error en el código'),
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
        icon = Icons.format_quote_rounded;
        color = AppTheme.errorRed;
        break;
      case 'operator':
        icon = Icons.calculate_rounded;
        color = AppTheme.warningOrange;
        break;
      case 'comparison':
        icon = Icons.compare_rounded;
        color = Colors.purple;
        break;
      case 'variable':
        icon = Icons.text_fields_rounded;
        color = AppTheme.primaryBlue;
        break;
      case 'logic':
        icon = Icons.psychology_rounded;
        color = AppTheme.accentTeal;
        break;
      case 'condition':
        icon = Icons.alt_route_rounded;
        color = Colors.indigo;
        break;
      case 'loop':
        icon = Icons.loop_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.bug_report_rounded;
        color = AppTheme.errorRed;
    }

    return Card(
      elevation: 3,
      color: color.withValues(alpha: 0.1),
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
                    _tl('Hatalı satırı tıkla', 'Tap the faulty line', 'Tippe auf die fehlerhafte Zeile', 'Toca la línea incorrecta'),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.bug_report_rounded,
                          color: Colors.white, size: 16),
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
          ? AppTheme.successGreen.withValues(alpha: 0.2)
          : AppTheme.errorRed.withValues(alpha: 0.2);
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryBlue.withValues(alpha: 0.1);
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
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
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
              Icon(Icons.warning_rounded,
                  color: AppTheme.warningOrange, size: 20),
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
                        ? (_tl('Harika Bir Hata Avcısısın!', 'You\'re a Great Bug Hunter!', 'Du bist ein großartiger Fehlerjäger!', '¡Eres un gran cazador de errores!'))
                        : (_tl('Tekrar Dene!', 'Try Again!', 'Versuch es noch mal!', '¡Inténtalo otra vez!')),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          gameWon ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                    textAlign: TextAlign.center,
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

/// Kod satırı modeli
class CodeLine {
  final String code;
  final bool hasBug;

  CodeLine(this.code, this.hasBug);
}
