import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/oyun_basligi.dart';
import '../../widgets/oyun_kimligi.dart';
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
import '../../ui/answer_feedback.dart';
import '../../ui/count_up.dart';
import '../../ui/motion.dart';
import '../../ui/press_button.dart';
import '../../widgets/oyun_cipleri.dart';
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
    // 30 punto eksen sutunu + 2x16 kenar boslugu + 2 punto cerceve +
    // tahta kartinin 2x8 ic boslugu.
    final izgaraGenisligi = genislik - 30 - 34 - 16;
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
      // Yeni hedef seridi temizliyor; cocuk neden degistigini bilsin.
      _showMessage(
        _tl('Süre doldu, bu yeni hedef!', 'Time ran out, here is a new target!',
            'Die Zeit ist um, hier ist ein neues Ziel!',
            '¡Se acabó el tiempo, aquí tienes un objetivo nuevo!'),
        AppTheme.warningOrange,
      );
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
      _mesaj = null;
    });
  }

  /// Yanlis cevapta tahtayi sallamak icin sayac (ShakeOnChange tetigi).
  int _yanlisSayaci = 0;

  /// Tahtanin altindaki geri bildirim seridi. SnackBar yerine: SnackBar
  /// ekranin en altindan cikip "Kontrol Et" tusunun ustunu kapatiyordu
  /// ve cocuk mesaji tahtadan uzakta goruyordu.
  String? _mesaj;
  Color _mesajRengi = AppTheme.successGreen;
  IconData _mesajSimgesi = Icons.info_rounded;

  void _checkAnswer() {
    // CIFT PUAN HATASI: dogru cevaptan sonra sonraki seviyeye gecis iki
    // saniye bekliyor. Bu arada "Kontrol Et"e tekrar basan cocuk ayni
    // hedef icin puani bir daha aliyor ve iki gecikmeli "sonraki
    // seviye" kuruluyordu (seviye atlaniyordu).
    if (gameWon || timeExpired) return;
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

      // Sure sayaci bu iki saniyelik kutlamada da isliyordu; son
      // saniyelerde dogru bilen cocuga "sure doldu" deyip hedefi
      // degistiriyordu.
      _levelTimer?.cancel();
      setState(() {
        score += levelScore;
        gameWon = true;
        _sonKazanc = levelScore;
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
      _yanlisSayaci++;
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
    if (!mounted) return;
    setState(() {
      _mesaj = message;
      _mesajRengi = color;
      _mesajSimgesi = color == AppTheme.successGreen
          ? Icons.check_circle_rounded
          : color == AppTheme.errorRed
              ? Icons.cancel_rounded
              : color == AppTheme.warningOrange
                  ? Icons.timer_off_rounded
                  : Icons.touch_app_rounded;
    });
  }

  /// Son dogru cevabin puani (kutlama kartinda yaziyor).
  int _sonKazanc = 0;

  Color _getTimeColor() {
    if (remainingTime == null) return AppTheme.successGreen;
    final percentage = remainingTime! / timeLimit;
    if (percentage > 0.5) return AppTheme.successGreen;
    if (percentage > 0.25) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  // X ve Y her yerde AYNI renkte: hedefteki sayi, eksendeki rakamlar ve
  // ipucundaki kelime. Cocuk "turuncu sayi = alttaki turuncu rakamlar"
  // eslemesini renkten yapiyor; (X, Y) sirasini ezberlemesi gerekmiyor.
  static const Color _xRenk = Color(0xFFF4511E);
  static const Color _yRenk = Color(0xFF8E24AA);
  static const Color _renk = Color(0xFF5C6BC0);

  @override
  Widget build(BuildContext context) {
    // Oyun tamamlandıysa completion screen göster
    if (gameCompleted) {
      return _buildCompletionScreen();
    }

    return Scaffold(
      backgroundColor: OyunZemini.ustRenk(OyunKimligi.renk(GameType.coordinates)),
      appBar: OyunBasligi.oyun(
        GameType.coordinates,
        baslikWidget: Text(_tl('Koordinat Macerası', 'Coordinate Adventure', 'Koordinaten-Abenteuer', 'Aventura de coordenadas')),
      ),
      body: OyunZemini(
        renk: OyunKimligi.renk(GameType.coordinates),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ciplerSatiri(),
              const SizedBox(height: 14),
              _hedefKarti(),
              const SizedBox(height: 14),
              _buildGrid(),
              const SizedBox(height: 14),
              _geriBildirimAlani(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: PressButton(
                      label: _tl('İpucu', 'Hint', 'Tipp', 'Pista'),
                      icon: Icons.lightbulb_rounded,
                      color: AppTheme.warningOrange,
                      height: 52,
                      onPressed: () => setState(() => showHint = !showHint),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PressButton(
                      key: const ValueKey('koordinat_kontrol'),
                      label: _tl('Kontrol Et', 'Check', 'Prüfen', 'Comprobar'),
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF43A047),
                      height: 52,
                      onPressed: gameWon ? null : _checkAnswer,
                    ),
                  ),
                ],
              ),

              // İpucu
              AnimatedSize(
                duration: Motion.adapt(context, Motion.medium2),
                curve: Motion.emphasized,
                alignment: Alignment.topCenter,
                child: showHint ? _ipucuKarti() : const SizedBox(width: double.infinity),
              ),

              const SizedBox(height: 20),

              // Açıklama
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ciplerSatiri() {
    final az = remainingTime != null && remainingTime! / timeLimit <= 0.25;
    return Row(
      children: [
        Expanded(
          child: OyunCipi(
            key: const ValueKey('koordinat_cip_seviye'),
            simge: Icons.flag_rounded,
            etiket: _tl('Seviye', 'Level', 'Level', 'Nivel'),
            deger: Text('$currentLevel/$maxLevels'),
            renk: _renk,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OyunCipi(
            key: const ValueKey('koordinat_cip_sure'),
            simge: Icons.timer_rounded,
            etiket: _tl('Süre', 'Time', 'Zeit', 'Tiempo'),
            deger: Text('${remainingTime ?? timeLimit} s'),
            renk: _getTimeColor(),
            vurgu: az,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OyunCipi(
            key: const ValueKey('koordinat_cip_skor'),
            simge: Icons.star_rounded,
            etiket: _tl('Skor', 'Score', 'Punkte', 'Puntos'),
            deger: CountUpText(
              value: score,
              fontSize: 18,
              color: const Color(0xFFE65100),
            ),
            renk: const Color(0xFFFFA000),
          ),
        ),
      ],
    );
  }

  /// Hedef karti: robot ve gidecegi kare. X turuncu, Y mor.
  Widget _hedefKarti() {
    final kalan = (remainingTime ?? timeLimit) / timeLimit;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _renk.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _Robot(boyut: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tl('Robotu hazineye götür!', 'Take the robot to the treasure!',
                          'Bring den Roboter zum Schatz!', '¡Lleva al robot al tesoro!'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkGray.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _tl('Hedef Koordinat:', 'Target Coordinate:', 'Zielkoordinate:', 'Coordenada objetivo:'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkGray.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Hedef: (X, Y). Sayilar eksenlerin renginde.
              Container(
                key: const ValueKey('koordinat_hedef'),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _renk.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _renk.withValues(alpha: 0.25), width: 1.5),
                ),
                child: Text.rich(
                  TextSpan(
                    style: AppTheme.number(fontSize: 30, color: AppTheme.darkGray),
                    children: [
                      const TextSpan(text: '('),
                      TextSpan(text: '$targetX', style: const TextStyle(color: _xRenk)),
                      const TextSpan(text: ', '),
                      TextSpan(text: '$targetY', style: const TextStyle(color: _yRenk)),
                      const TextSpan(text: ')'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Kalan sure cubugu: rakam kucuk ciptte, burada goz ucuyla.
          ProgressTrack(
            value: kalan,
            color: _getTimeColor(),
            background: _renk.withValues(alpha: 0.10),
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return ShakeOnChange(
      trigger: _yanlisSayaci,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 10, 12, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _renk.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(builder: (context, c) {
          final n = gridSize;
          const eksen = 30.0;
          final kare = (c.maxWidth - eksen) / n;
          return Column(
            children: [
              // Y ekseninin adi ve yonu (yukari).
              Row(
                children: [
                  SizedBox(
                    width: eksen,
                    child: Column(
                      children: [
                        _eksenAdi('Y', _yRenk),
                        const Icon(Icons.arrow_upward_rounded, color: _yRenk, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: kare * n,
                child: Row(
                  children: [
                    // Y ekseni numaraları (sol)
                    SizedBox(
                      width: eksen,
                      child: Column(
                        children: List.generate(
                          n,
                          (index) => SizedBox(
                            height: kare,
                            child: Center(
                              child: _eksenRakami(
                                n - 1 - index,
                                _yRenk,
                                vurgu: answerRevealed && selectedY == n - 1 - index,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Grid cells + eksen cizgileri
                    Expanded(
                      child: CustomPaint(
                        painter: _EksenRessami(n: n, renk: _renk),
                        child: Column(
                          children: List.generate(
                            n,
                            (y) => Expanded(
                              child: Row(
                                children: List.generate(
                                  n,
                                  (x) => _buildGridCell(x, n - 1 - y),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // X ekseni numaraları (alt)
              Row(
                children: [
                  const SizedBox(width: eksen),
                  for (var x = 0; x < n; x++)
                    SizedBox(
                      width: kare,
                      child: Center(
                        child: _eksenRakami(x, _xRenk,
                            vurgu: answerRevealed && selectedX == x),
                      ),
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _eksenAdi('X', _xRenk),
                  const Icon(Icons.arrow_forward_rounded, color: _xRenk, size: 16),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _eksenAdi(String ad, Color renk) => Text(
        ad,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: renk,
        ),
      );

  /// Eksendeki rakam. Yanlis cevaptan sonra secilen sutun/satirin rakami
  /// dolu daireyle vurgulaniyor: cocuk sectigi karenin hangi sayiya
  /// denk geldigini eksende okuyor.
  Widget _eksenRakami(int deger, Color renk, {bool vurgu = false}) {
    return AnimatedContainer(
      duration: Motion.adapt(context, Motion.medium1),
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: vurgu ? renk : renk.withValues(alpha: 0.10),
      ),
      child: Text(
        '$deger',
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w900,
          color: vurgu ? Colors.white : renk,
        ),
      ),
    );
  }

  Widget _buildGridCell(int x, int y) {
    final bool isSelected = selectedX == x && selectedY == y;
    final bool isTarget = targetX == x && targetY == y && gameWon;
    final bool yanlis = isSelected && answerRevealed;
    // Yanlistan sonra secilen sutun turuncu, satir mor boyaniyor: "senin
    // kare X'te su, Y'de su" ders aninin kendisi.
    final sutun = answerRevealed && selectedX == x;
    final satir = answerRevealed && selectedY == y;

    Color zemin = _renk.withValues(alpha: 0.06);
    if (sutun && satir) {
      zemin = Color.lerp(_xRenk, _yRenk, 0.5)!.withValues(alpha: 0.22);
    } else if (sutun) {
      zemin = _xRenk.withValues(alpha: 0.13);
    } else if (satir) {
      zemin = _yRenk.withValues(alpha: 0.13);
    }
    if (isTarget) zemin = const Color(0xFFC8E6C9);

    return Expanded(
      child: GestureDetector(
        key: ValueKey('koordinat_kare_${x}_$y'),
        behavior: HitTestBehavior.opaque,
        onTap: gameWon
            ? null
            : () {
                setState(() {
                  selectedX = x;
                  selectedY = y;
                  answerRevealed = false;
                  _mesaj = null;
                });
              },
        child: AnimatedContainer(
          duration: Motion.adapt(context, Motion.short4),
          margin: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: zemin,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isTarget
                  ? const Color(0xFF43A047)
                  : yanlis
                      ? AppTheme.errorRed
                      : isSelected
                          ? _renk
                          : _renk.withValues(alpha: 0.12),
              width: isTarget || isSelected ? 2.5 : 1,
            ),
          ),
          child: Center(
            child: isTarget
                ? const _Hazine()
                : isSelected
                    ? _Robot(boyut: 30, uzgun: yanlis)
                    : null,
          ),
        ),
      ),
    );
  }

  /// Tahtanin altindaki alan: kutlama, mesaj ya da secim bilgisi.
  Widget _geriBildirimAlani() {
    final Widget icerik;
    if (gameWon) {
      icerik = SeviyeKutlamaKarti(
        key: const ValueKey('koordinat_kutlama'),
        simge: Icons.diamond_rounded,
        renk: const Color(0xFF43A047),
        baslik: _tl('Hazineyi buldun!', 'You found the treasure!',
            'Du hast den Schatz gefunden!', '¡Encontraste el tesoro!'),
        altYazi: currentLevel >= maxLevels
            ? _tl('+$_sonKazanc puan', '+$_sonKazanc points', '+$_sonKazanc Punkte', '+$_sonKazanc puntos')
            : _tl('+$_sonKazanc puan · Sıradaki hedef geliyor…',
                '+$_sonKazanc points · Next target coming…',
                '+$_sonKazanc Punkte · Das nächste Ziel kommt …',
                '+$_sonKazanc puntos · Llega el siguiente objetivo…'),
      );
    } else {
      icerik = Column(
        key: ValueKey('koordinat_bilgi_${_mesaj ?? ''}_$answerRevealed'),
        children: [
          if (_mesaj != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Color.lerp(_mesajRengi, Colors.white, 0.86),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _mesajRengi.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(_mesajSimgesi, color: _mesajRengi, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _mesaj!,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color.lerp(_mesajRengi, Colors.black, 0.35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Seçili koordinat
          //
          // Kart hep ayni yerde duruyor (kayma olmasin diye), ama
          // koordinat sayilari yalnizca kontrolden sonra aciliyor.
          if (selectedX != null && selectedY != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _renk.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (answerRevealed) ...[
                    Text(
                      _tl('Seçtiğin Koordinat: ', 'Your Coordinate: ',
                          'Deine Koordinate: ', 'Tu coordenada: '),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '($selectedX, $selectedY)',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _renk,
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
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            )
          else if (_mesaj == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app_rounded, color: _renk, size: 20),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _tl('Hazinenin olduğu kareye dokun.', 'Tap the square where the treasure is.',
                        'Tippe auf das Feld, in dem der Schatz liegt.',
                        'Toca la casilla donde está el tesoro.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color.lerp(_renk, Colors.black, 0.3),
                    ),
                  ),
                ),
              ],
            ),
        ],
      );
    }
    return AnimatedSwitcher(
      duration: Motion.adapt(context, Motion.medium2),
      child: icerik,
    );
  }

  Widget _ipucuKarti() {
    final xSol = targetX < gridSize ~/ 2;
    final yAlt = targetY < gridSize ~/ 2;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppTheme.warningOrange, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tl('İpucu:', 'Hint:', 'Tipp:', 'Pista:'),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  _tl('X koordinatı ${xSol ? "soldadır" : "sağdadır"}.',
                      'The X coordinate is on the ${xSol ? "left" : "right"}.',
                      'Die X-Koordinate liegt ${xSol ? "links" : "rechts"}.',
                      'La coordenada X está a la ${xSol ? "izquierda" : "derecha"}.'),
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: _xRenk),
                ),
                Text(
                  _tl('Y koordinatı ${yAlt ? "alttadır" : "üsttedir"}.',
                      'The Y coordinate is at the ${yAlt ? "bottom" : "top"}.',
                      'Die Y-Koordinate liegt ${yAlt ? "unten" : "oben"}.',
                      'La coordenada Y está ${yAlt ? "abajo" : "arriba"}.'),
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: _yRenk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _renk.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: _renk),
              const SizedBox(width: 8),
              Text(
                _tl('Nasıl Oynanır?', 'How to Play?', 'So wird gespielt', '¿Cómo se juega?'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
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
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _renk.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _tl('💡 İpucu: (X, Y) formatında X yatay, Y dikeydir. '
                      'Örneğin (3, 5) → X=3 sağa, Y=5 yukarı', '💡 Hint: In (X, Y) format, X is horizontal, Y is vertical. '
                      'For example (3, 5) → X=3 right, Y=5 up', '💡 Tipp: Im Format (X, Y) ist X waagerecht und Y senkrecht. Zum Beispiel (3, 5) → X=3 nach rechts, Y=5 nach oben', '💡 Pista: en el formato (X, Y), X es horizontal e Y es vertical. Por ejemplo (3, 5) → X=3 a la derecha, Y=5 hacia arriba'),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: _renk,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: OyunZemini.ustRenk(OyunKimligi.renk(GameType.coordinates)),
      appBar: OyunBasligi.oyun(
        GameType.coordinates,
        baslikWidget: Text(_tl('Oyun Tamamlandı!', 'Game Complete!', 'Spiel geschafft!', '¡Juego completado!')),
        geriTusu: false,
      ),
      body: OyunZemini(
        renk: OyunKimligi.renk(GameType.coordinates),
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Kupa: buyuyerek geliyor.
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1),
                    duration: Motion.adapt(context, Motion.extraLong2),
                    curve: Curves.elasticOut,
                    builder: (context, s, child) =>
                        Transform.scale(scale: s, child: child),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFFF59D), Color(0xFFFFC107)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        size: 88,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Congratulations Text
                  Text(
                    _tl('Tebrikler!', 'Congratulations!', 'Glückwunsch!', '¡Felicidades!'),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: _renk,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _tl('Koordinat Macerasını Tamamladın!', 'You completed the Coordinate Adventure!', 'Du hast das Koordinaten-Abenteuer geschafft!', '¡Completaste la Aventura de coordenadas!'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkGray,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _renk.withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
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

                  const SizedBox(height: 24),

                  // Action Buttons
                  PressButton(
                    label: _tl('Liderlik Tablosunu Gör', 'View Leaderboard', 'Bestenliste ansehen', 'Ver la clasificación'),
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFFFFB300),
                    foreground: Colors.black87,
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
                  ),
                  const SizedBox(height: 12),
                  PressButton(
                    label: _tl('Tekrar Oyna', 'Play Again', 'Noch mal spielen', 'Jugar otra vez'),
                    icon: Icons.refresh_rounded,
                    color: _renk,
                    onPressed: _restartGame,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.home_rounded, size: 26),
                      label: Text(
                        _tl('Ana Menüye Dön', 'Back to Main Menu', 'Zurück zum Hauptmenü', 'Volver al menú principal'),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _renk,
                        side: const BorderSide(color: _renk, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
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

/// Oyunun karakteri: kucuk mor robot. Hedef kartinda ve secilen karede.
class _Robot extends StatelessWidget {
  const _Robot({required this.boyut, this.uzgun = false});
  final double boyut;

  /// Yanlis karede: kirmiziya donuyor.
  final bool uzgun;

  @override
  Widget build(BuildContext context) {
    final renk = uzgun ? AppTheme.errorRed : const Color(0xFF5C6BC0);
    return TweenAnimationBuilder<double>(
      key: ValueKey(uzgun),
      tween: Tween(begin: 0.4, end: 1),
      duration: Motion.adapt(context, Motion.medium4),
      curve: Motion.overshoot,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: Container(
        width: boyut,
        height: boyut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [Color.lerp(renk, Colors.white, 0.4)!, renk],
          ),
          border: Border.all(color: Colors.white, width: boyut * 0.06),
          boxShadow: [
            BoxShadow(
              color: renk.withValues(alpha: 0.35),
              blurRadius: boyut * 0.2,
              offset: Offset(0, boyut * 0.08),
            ),
          ],
        ),
        child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: boyut * 0.6),
      ),
    );
  }
}

/// Bulunan hazine: ziplayarak beliren altin elmas.
class _Hazine extends StatelessWidget {
  const _Hazine();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.adapt(context, Motion.extraLong2),
      curve: Curves.elasticOut,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: LayoutBuilder(builder: (context, c) {
        final b = min(c.maxWidth, c.maxHeight) * 0.8;
        return Container(
          width: b,
          height: b,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFFFF59D), Color(0xFFFFB300)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(Icons.diamond_rounded, color: Colors.white, size: b * 0.62),
        );
      }),
    );
  }
}

/// Izgaranin arkasindaki eksenler: sol kenarda yukari, alt kenarda saga
/// bakan kalin cizgiler. Eskiden izgara yalnizca mavi bir cerceveydi;
/// "Y yukari, X saga buyur" fikri hicbir yerde gorunmuyordu.
class _EksenRessami extends CustomPainter {
  _EksenRessami({required this.n, required this.renk});
  final int n;
  final Color renk;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = renk.withValues(alpha: 0.55)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    // Y ekseni (sol) ve X ekseni (alt).
    canvas.drawLine(Offset(0, size.height), const Offset(0, -6), p);
    canvas.drawLine(Offset(0, size.height), Offset(size.width + 6, size.height), p);
  }

  @override
  bool shouldRepaint(covariant _EksenRessami old) => old.n != n || old.renk != renk;
}
