import 'dart:async';
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
import '../leaderboard/leaderboard_screen.dart';
import '../../utils/lang.dart';

/// Koordinat Macerası Oyunu
/// X-Y koordinat sistemini öğreten interaktif oyun
class CoordinatesGameScreen extends StatefulWidget {
  const CoordinatesGameScreen({super.key});

  @override
  State<CoordinatesGameScreen> createState() => _CoordinatesGameScreenState();
}

class _CoordinatesGameScreenState extends State<CoordinatesGameScreen> {
  // Oyun ayarları
  final int maxLevels = 15; // Maksimum seviye (arttırıldı)
  final Random _random = Random();
  final LeaderboardService _leaderboardService = LeaderboardService();

  // Oyun durumu
  int currentLevel = 1;
  int score = 0;
  int targetX = 0;
  int targetY = 0;
  int? selectedX;
  int? selectedY;
  bool showHint = false;
  bool gameWon = false;

  /// Secilen karenin koordinati ekranda yaziyla gosterilsin mi?
  ///
  /// Eskiden kare secilir secilmez alt kartta "Seçtiğin Koordinat: (3, 5)"
  /// yaziyordu. Hedef zaten ustte yazili oldugu icin cocuk iki sayiyi
  /// karsilastirip dogru oldugunu ANLIYOR, "Kontrol Et" gereksiz
  /// kaliyordu; dahasi kareyi okumayi ogrenmeden dene-yanil ile
  /// ilerleyebiliyordu. Sayilar artik yalnizca kontrolden SONRA, o da
  /// yanlissa ogretmek icin aciliyor.
  bool answerRevealed = false;
  bool gameCompleted = false;
  DateTime? startTime;
  int? finalTimeSeconds;

  // Süre limiti sistemi
  DateTime? levelStartTime;
  int? remainingTime;
  bool timeExpired = false;

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  ///
  /// Onceki surumde her yerde `_isEn ? ingilizce : turkce` vardi; almanca
  /// ya da ispanyolca secen cocuk oyunun tamamini turkce goruyordu.
  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  /// Ekrana sigan en buyuk izgara.
  ///
  /// DOKUNMA HEDEFI.
  /// 10x10 izgara 390 puntoluk bir telefonda (kenar bosluklari ve 30
  /// puntoluk Y ekseni sutunu dusunce) hucre basina ~32 punto birakiyor.
  /// Apple'in en az onerdigi 44; 4-12 yas icin 32 punto, cocugun
  /// istedigi kareye basamamasi demek. Genislik yetmiyorsa izgarayi
  /// buyutmek yerine SEVIYE ilerlesin: hedef hala rastgele, sure hala
  /// kisaliyor, ama kare parmakla basilabilir kaliyor.
  ///
  /// Genis ekranda (tablet, yatay) 10x10 duruyor.
  int get _ekranaSiganIzgara {
    final genislik = MediaQuery.sizeOf(context).width;
    // 30 punto eksen sutunu + 2x16 kenar boslugu + 2 punto cerceve.
    final izgaraGenisligi = genislik - 30 - 34;
    final kare = (izgaraGenisligi / 44).floor();
    return kare.clamp(6, 10);
  }

  // Seviye bazlı grid boyutu (6x6 → 8x8 → 10x10), ekrana gore sinirli.
  int get gridSize {
    final istenen = currentLevel <= 5
        ? 6
        : currentLevel <= 10
            ? 8
            : 10;
    // initState icinde MediaQuery'ye BAKILAMAZ (dependOnInherited...
    // "before initState completed" diye patliyor). Ilk olcum
    // didChangeDependencies'te yapiliyor; o ana kadar istenen deger
    // donuyor. Ilk seviye zaten 6x6, yani sinirin altinda.
    if (!_olculdu) return istenen;
    return istenen < _ekranaSiganIzgara ? istenen : _ekranaSiganIzgara;
  }

  // Seviye bazlı süre limiti (saniye)
  int get timeLimit {
    if (currentLevel <= 5) return 45; // Seviye 1-5: 45 saniye
    if (currentLevel <= 10) return 60; // Seviye 6-10: 60 saniye
    return 75; // Seviye 11-15: 75 saniye
  }

  /// MediaQuery okunabilir hale geldi mi? Bkz. [gridSize].
  bool _olculdu = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_olculdu) {
      _olculdu = true;
      // Hedef initState'te sinirsiz izgaraya gore uretilmis olabilir;
      // olcum gelince izgara kuculduyse hedef disarida kalmasin.
      if (targetX >= gridSize || targetY >= gridSize) {
        _generateNewTarget();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (Koordinat). Butun oyunlarda ayni tonu
    // calmak oyunlari birbirinden ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.soft);
    startTime = DateTime.now();
    _generateNewTarget();
    _startLevelTimer();
  }

  @override
  void dispose() {
    // Yorum "Timer'i temizle" diyordu ama temizleyen bir sey yoktu.
    _levelTimer?.cancel();
    super.dispose();
  }

  /// Seviye sayaci.
  ///
  /// Once bu bir `Future.doWhile` dongusuydu ve HER SEVIYE BASINDA
  /// YENISI BASLATILIYORDU; eskisi durmuyordu. 15. seviyede saniyede 15
  /// kez `setState` cagiran 15 dongu vardi ve birden fazlasi sureyi
  /// bitirip ard arda `Navigator.pop` cagirabiliyordu. "Tekrar Oyna" ise
  /// sayaci hic baslatmadigi icin sure sonsuza kadar duruyordu.
  Timer? _levelTimer;

  void _startLevelTimer() {
    _levelTimer?.cancel();
    levelStartTime = DateTime.now();
    remainingTime = timeLimit;
    timeExpired = false;

    _levelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || gameCompleted || timeExpired) {
        timer.cancel();
        return;
      }
      final start = levelStartTime;
      if (start == null) return;

      setState(() {
        final elapsed = DateTime.now().difference(start).inSeconds;
        remainingTime = timeLimit - elapsed;
        if (remainingTime! <= 0) {
          remainingTime = 0;
          timeExpired = true;
        }
      });

      if (timeExpired) {
        timer.cancel();
        _handleTimeExpired();
      }
    });
  }

  /// Sure dolunca.
  ///
  /// Once oyun BITIYOR ve cocuk iki saniye sonra `Navigator.pop` ile
  /// ekrandan atiliyordu: hicbir sey kaydedilmiyor, hicbir sey
  /// aciklanmiyordu. Yavas cevap veren cocuk butun oturumunu
  /// kaybediyordu. Artik sure dolunca sadece o seviye yenileniyor.
  void _handleTimeExpired() {
    SoundService.playWrong();
    _showMessage(
      _tl('Bu hedefte süre doldu — yeni hedef geliyor.', 'Time is up for this one — here comes a new target.', 'Die Zeit für dieses Ziel ist um — ein neues kommt.', 'Se acabó el tiempo para este objetivo: llega uno nuevo.'),
      AppTheme.warningOrange,
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      _generateNewTarget();
      _startLevelTimer();
    });
  }

  void _generateNewTarget() {
    setState(() {
      targetX = _random.nextInt(gridSize);
      targetY = _random.nextInt(gridSize);
      selectedX = null;
      selectedY = null;
      showHint = false;
      gameWon = false;
      answerRevealed = false;
    });
  }

  void _checkAnswer() {
    if (selectedX == null || selectedY == null) {
      _showMessage(_tl('Lütfen bir nokta seç!', 'Please select a point!', 'Bitte wähle einen Punkt aus!', '¡Elige un punto!'),
          Colors.orange);
      return;
    }

    if (selectedX == targetX && selectedY == targetY) {
      // Doğru cevap sesi
      SoundService.playCorrect();

      // Standardize edilmiş skor hesapla
      final levelScore = ScoreCalculator.calculateCoordinatesScore(
        level: currentLevel,
        timeRemaining: remainingTime ?? 0,
        totalTime: timeLimit,
      );

      setState(() {
        score += levelScore;
        gameWon = true;
      });
      _showMessage(
          _tl('Harika! +$levelScore puan! 🎉', 'Great! +$levelScore points! 🎉', 'Super! +$levelScore Punkte! 🎉', '¡Genial! ¡+$levelScore puntos! 🎉'),
          AppTheme.successGreen);

      // Oyun tamamlandı mı kontrol et
      if (currentLevel >= maxLevels) {
        // Oyun tamamlama sesi
        SoundService.playLevelComplete();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _completeGame();
          }
        });
      } else {
        // Seviye tamamlama sesi
        SoundService.playScore();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              currentLevel++;
            });
            _generateNewTarget();
            _startLevelTimer(); // Yeni seviye için timer'ı yeniden başlat
          }
        });
      }
    } else {
      // Yanlış cevap sesi
      SoundService.playWrong();
      // Yanlis secimde koordinati YAZIYLA gosteriyoruz: cocuk hangi
      // kareyi sectigini sayi olarak gorup hedefle karsilastirsin.
      setState(() => answerRevealed = true);
      _showMessage(
        _tl('Tekrar dene! İpucu için yardım butonuna bas.', 'Try again! Tap the hint button for help.', 'Versuch es noch mal! Tippe für einen Tipp auf die Hilfe-Taste.', '¡Inténtalo otra vez! Toca el botón de ayuda para una pista.'),
        AppTheme.errorRed,
      );
    }
  }

  Future<void> _completeGame() async {
    // Süreyi hesapla
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime!);
      finalTimeSeconds = duration.inSeconds;
    }

    setState(() {
      gameCompleted = true;
    });

    // Leaderboard'a kaydet
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      try {
        final entry = LeaderboardEntry(
          id: '',
          userId: authProvider.currentUser!.uid,
          userName: authProvider.currentUser!.displayName,
          userPhotoUrl: authProvider.currentUser!.profilePictureUrl,
          gameType: GameType.coordinates,
          score: score,
          timeSeconds: finalTimeSeconds,
          difficulty: 1,
          completedAt: DateTime.now(),
          metadata: {
            'levelsCompleted': maxLevels,
            'gridSize': gridSize,
          },
        );

        await _leaderboardService.addEntry(entry);
      } catch (e) {
        debugPrint('Error saving to leaderboard: $e');
      }
    }
  }

  void _restartGame() {
    setState(() {
      currentLevel = 1;
      score = 0;
      gameCompleted = false;
      startTime = DateTime.now();
      finalTimeSeconds = null;
      timeExpired = false;
    });
    _generateNewTarget();
    // "Tekrar Oyna" sayaci yeniden baslatmiyordu.
    _startLevelTimer();
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getTimeColor() {
    if (remainingTime == null) return AppTheme.successGreen;
    final percentage = remainingTime! / timeLimit;
    if (percentage > 0.5) return AppTheme.successGreen;
    if (percentage > 0.25) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    // Oyun tamamlandıysa completion screen göster
    if (gameCompleted) {
      return _buildCompletionScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_tl('Koordinat Macerası', 'Coordinate Adventure', 'Koordinaten-Abenteuer', 'Aventura de coordenadas')),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, color: AppTheme.warningOrange),
                  const SizedBox(width: 4),
                  Text(
                    _tl('Skor: $score', 'Score: $score', 'Punkte: $score', 'Puntos: $score'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Level ve hedef bilgisi
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tl('Seviye $currentLevel', 'Level $currentLevel', 'Level $currentLevel', 'Nivel $currentLevel'),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                        ),
                        // Grid boyutu göstergesi
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${gridSize}x$gridSize',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Süre göstergesi
                    if (remainingTime != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getTimeColor().withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getTimeColor(), width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_rounded,
                                color: _getTimeColor(), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _tl('Kalan Süre: $remainingTime saniye', 'Time Left: $remainingTime s', 'Verbleibende Zeit: $remainingTime s', 'Tiempo restante: $remainingTime s'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getTimeColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _tl('Hedef Koordinat:', 'Target Coordinate:', 'Zielkoordinate:', 'Coordenada objetivo:'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '($targetX, $targetY)',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentTeal,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Grid
            _buildGrid(),

            const SizedBox(height: 24),

            // Seçili koordinat
            //
            // Kart hep ayni yerde duruyor (kayma olmasin diye), ama
            // koordinat sayilari yalnizca kontrolden sonra aciliyor.
            if (selectedX != null && selectedY != null)
              Card(
                color: AppTheme.lightBlue.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (answerRevealed) ...[
                        Text(
                          _tl('Seçtiğin Koordinat: ', 'Your Coordinate: ',
                              'Deine Koordinate: ', 'Tu coordenada: '),
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '($selectedX, $selectedY)',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ] else
                        Flexible(
                          child: Text(
                            _tl('Bir kare seçtin. Şimdi "Kontrol Et"e bas.',
                                'You picked a square. Now tap "Check".',
                                'Du hast ein Feld gewählt. Tippe jetzt auf "Prüfen".',
                                'Elegiste una casilla. Ahora pulsa "Comprobar".'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() => showHint = !showHint),
                  icon: const Icon(Icons.lightbulb_rounded),
                  label: Text(_tl('İpucu', 'Hint', 'Tipp', 'Pista')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _checkAnswer,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text(_tl('Kontrol Et', 'Check', 'Prüfen', 'Comprobar')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),

            // İpucu
            if (showHint) ...[
              const SizedBox(height: 16),
              Card(
                color: AppTheme.warningOrange.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppTheme.warningOrange),
                          const SizedBox(width: 8),
                          Text(
                            _tl('İpucu:', 'Hint:', 'Tipp:', 'Pista:'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _tl('X koordinatı ${targetX < gridSize ~/ 2 ? "soldadır" : "sağdadır"}.\n'
                                'Y koordinatı ${targetY < gridSize ~/ 2 ? "alttadır" : "üsttedir"}.', 'The X coordinate is on the ${targetX < gridSize ~/ 2 ? "left" : "right"}.\n'
                                'The Y coordinate is at the ${targetY < gridSize ~/ 2 ? "bottom" : "top"}.', 'Die X-Koordinate liegt ${targetX < gridSize ~/ 2 ? "links" : "rechts"}.\nDie Y-Koordinate liegt ${targetY < gridSize ~/ 2 ? "unten" : "oben"}.', 'La coordenada X está a la ${targetX < gridSize ~/ 2 ? "izquierda" : "derecha"}.\nLa coordenada Y está ${targetY < gridSize ~/ 2 ? "abajo" : "arriba"}.'),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Açıklama
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryBlue, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Y ekseni üstte
            Expanded(
              child: Row(
                children: [
                  // Y ekseni numaraları (sol)
                  SizedBox(
                    width: 30,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        gridSize,
                        (index) => Text(
                          '${gridSize - 1 - index}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Grid cells
                  Expanded(
                    child: Column(
                      children: List.generate(
                        gridSize,
                        (y) => Expanded(
                          child: Row(
                            children: List.generate(
                              gridSize,
                              (x) => _buildGridCell(x, gridSize - 1 - y),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // X ekseni numaraları (alt)
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  gridSize,
                  (index) => Text(
                    '$index',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(int x, int y) {
    final bool isSelected = selectedX == x && selectedY == y;
    final bool isTarget = targetX == x && targetY == y && gameWon;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedX = x;
            selectedY = y;
            answerRevealed = false;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isTarget
                ? AppTheme.successGreen
                : isSelected
                    ? AppTheme.accentTeal
                    : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected || isTarget ? Colors.white : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Center(
            child: isTarget
                ? const Icon(Icons.star_rounded, color: Colors.white)
                : isSelected
                    ? const Icon(Icons.circle_rounded,
                        color: Colors.white, size: 16)
                    : null,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      color: AppTheme.lightGray,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school_rounded, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  _tl('Nasıl Oynanır?', 'How to Play?', 'So wird gespielt', '¿Cómo se juega?'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '1',
              _tl('Yukarıda verilen koordinatı bul', 'Find the coordinate given above', 'Finde die oben angegebene Koordinate', 'Encuentra la coordenada indicada arriba'),
            ),
            _buildInstructionItem(
              '2',
              _tl('Izgara üzerinde doğru noktaya tıkla', 'Tap the correct point on the grid', 'Tippe auf den richtigen Punkt im Gitter', 'Toca el punto correcto de la cuadrícula'),
            ),
            _buildInstructionItem(
              '3',
              _tl('X (yatay) ve Y (dikey) değerlerini kontrol et', 'Check the X (horizontal) and Y (vertical) values', 'Prüfe die Werte X (waagerecht) und Y (senkrecht)', 'Comprueba los valores X (horizontal) e Y (vertical)'),
            ),
            _buildInstructionItem(
              '4',
              _tl('"Kontrol Et" butonuna bas', 'Tap the "Check" button', 'Tippe auf die Taste "Prüfen"', 'Pulsa el botón "Comprobar"'),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _tl('💡 İpucu: (X, Y) formatında X yatay, Y dikeydir. '
                        'Örneğin (3, 5) → X=3 sağa, Y=5 yukarı', '💡 Hint: In (X, Y) format, X is horizontal, Y is vertical. '
                        'For example (3, 5) → X=3 right, Y=5 up', '💡 Tipp: Im Format (X, Y) ist X waagerecht und Y senkrecht. Zum Beispiel (3, 5) → X=3 nach rechts, Y=5 nach oben', '💡 Pista: en el formato (X, Y), X es horizontal e Y es vertical. Por ejemplo (3, 5) → X=3 a la derecha, Y=5 hacia arriba'),
                style:
                    const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tl('Oyun Tamamlandı!', 'Game Complete!', 'Spiel geschafft!', '¡Juego completado!')),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy Icon
                  const Icon(
                    Icons.emoji_events_rounded,
                    size: 120,
                    color: Color(0xFFFFD700),
                  ),
                  const SizedBox(height: 24),

                  // Congratulations Text
                  Text(
                    _tl('Tebrikler!', 'Congratulations!', 'Glückwunsch!', '¡Felicidades!'),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tl('Koordinat Macerasını Tamamladın!', 'You completed the Coordinate Adventure!', 'Du hast das Koordinaten-Abenteuer geschafft!', '¡Completaste la Aventura de coordenadas!'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Stats Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildStatRow(
                            Icons.star_rounded,
                            _tl('Toplam Puan', 'Total Score', 'Gesamtpunkte', 'Puntos totales'),
                            '$score',
                            AppTheme.warningOrange,
                          ),
                          const Divider(height: 24),
                          _buildStatRow(
                            Icons.timer_rounded,
                            _tl('Süre', 'Time', 'Zeit', 'Tiempo'),
                            _formatTime(finalTimeSeconds ?? 0),
                            AppTheme.primaryBlue,
                          ),
                          const Divider(height: 24),
                          _buildStatRow(
                            Icons.trending_up_rounded,
                            _tl('Tamamlanan Seviye', 'Levels Completed', 'Abgeschlossene Level', 'Niveles completados'),
                            '$maxLevels / $maxLevels',
                            AppTheme.successGreen,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LeaderboardScreen(
                                  initialGameType: GameType.coordinates,
                                ),
                              ),
                            );
                          },
                          icon:
                              const Icon(Icons.emoji_events_rounded, size: 28),
                          label: Text(
                            _tl('Liderlik Tablosunu Gör', 'View Leaderboard', 'Bestenliste ansehen', 'Ver la clasificación'),
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _restartGame,
                          icon: const Icon(Icons.refresh_rounded, size: 28),
                          label: Text(
                            _tl('Tekrar Oyna', 'Play Again', 'Noch mal spielen', 'Jugar otra vez'),
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.home_rounded, size: 28),
                          label: Text(
                            _tl('Ana Menüye Dön', 'Back to Main Menu', 'Zurück zum Hauptmenü', 'Volver al menú principal'),
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${seconds}s';
  }
}
