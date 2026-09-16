import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// TODO: Migrate to Supabase
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import '../../theme.dart';
import '../../ui/motion.dart';
import '../../utils/lang.dart';
import 'kukla_cizimi.dart';

/// Sağım-Solum Kodlama Oyunu (Flame 2D)
/// Wordwall tarzı hızlı tempolu oyun
class LeftRightCodingGameScreen extends StatefulWidget {
  final Map<String, dynamic>? gameData;

  const LeftRightCodingGameScreen({super.key, this.gameData});

  @override
  State<LeftRightCodingGameScreen> createState() =>
      _LeftRightCodingGameScreenState();
}

class _LeftRightCodingGameScreenState extends State<LeftRightCodingGameScreen> {
  late LeftRightCodingGame _game;
  int _currentLevel = 1;
  int _totalScore = 0;
  int _moves = 0;
  DateTime? _startTime;
  bool _gameStarted = false;
  bool _showingQuestion = false;
  PuppetType? _selectedPuppet;

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
    // Bu ekranin ses rengi (Sag-sol). Ekran tamamen sessizdi ve
    // bir onceki oyunun ses rengini devraliyordu.
    SoundService.useVoice(SfxVoice.soft);
    // Show puppet selection dialog on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPuppetSelectionDialog();
    });
  }

  void _initializeGame() {
    _game = LeftRightCodingGame(
      onLevelComplete: _handleLevelComplete,
      onMove: _handleMove,
      onGameStart: _handleGameStart,
      onGameOver: _handleGameOver,
      onBonusSquare: _handleBonusSquare,
      onUnansweredQuestions: _handleUnansweredQuestions,
      puppetType: _selectedPuppet!,
      lang: _lang,
    );
  }

  void _handleGameOver() {
    _showGameOverDialog();
  }

  void _handleBonusSquare(Map<String, dynamic> question) {
    if (_showingQuestion) return;
    _showingQuestion = true;
    _showQuestionDialog(question);
  }

  void _handleUnansweredQuestions(int unansweredCount) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tl('⚠️ Hedefe ulaştın ama $unansweredCount soru cevaplanmadı!\nKırmızı yanan karelerdeki soruları cevapla.', '⚠️ You reached the goal but $unansweredCount question(s) were not answered!\nAnswer the questions in the red flashing squares.', '⚠️ Du hast das Ziel erreicht, aber $unansweredCount Frage(n) blieben offen!\nBeantworte die Fragen in den rot blinkenden Feldern.', '⚠️ Llegaste a la meta, pero quedaron $unansweredCount pregunta(s) sin responder.\nResponde las preguntas de las casillas que parpadean en rojo.'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  /// Kukla secme ekrani.
  ///
  /// Eskiden emoji gosteriyordu: cocuk 🦊 secip tahtada bambaska cizilmis
  /// bir tilki goruyordu — secilen sey ile oynanan sey ayni degildi.
  /// Simdi kartlar oyundaki cizimin birebir aynisini ve kuklanin kendi
  /// rengini tasiyor.
  Future<void> _showPuppetSelectionDialog() async {
    final selectedPuppet = await showDialog<PuppetType>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _tl('Kiminle oynayalım?', 'Who are we playing with?',
                    'Mit wem spielen wir?', '¿Con quién jugamos?'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _tl('Seçtiğin karakter tahtada seninle yürüyecek.',
                    'Your character will walk the board with you.',
                    'Deine Figur läuft mit dir über das Feld.',
                    'Tu personaje caminará contigo por el tablero.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.mediumGray,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: PuppetType.values.map((puppet) {
                  final renk = KuklaCizimi.anaRenk(puppet);
                  return Semantics(
                    button: true,
                    label: puppet.nameFor(_lang),
                    child: Material(
                      color: renk.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pop(context, puppet),
                        child: Container(
                          // 96 + 12 bosluk: dar telefonda bile satira uc
                          // kart siğıyor, bes karakter 3+2 diziliyor.
                          width: 96,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: renk.withValues(alpha: 0.35), width: 2),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              KuklaOnizleme(kukla: puppet, boyut: 68),
                              const SizedBox(height: 10),
                              Text(
                                puppet.nameFor(_lang),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: renk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedPuppet != null) {
      setState(() {
        _selectedPuppet = selectedPuppet;
        _initializeGame();
      });
    } else {
      // If user somehow dismisses without selecting, default to fox
      setState(() {
        _selectedPuppet = PuppetType.fox;
        _initializeGame();
      });
    }
  }

  void _handleGameStart() {
    setState(() {
      _gameStarted = true;
      _startTime = DateTime.now();
    });
  }

  void _handleMove() {
    setState(() {
      _moves++;
    });
  }

  void _handleLevelComplete(int score, int level) {
    setState(() {
      _totalScore += score;
      _currentLevel = level + 1;
    });

    // Level tamamlandı mesajı
    if (level < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tl('🎉 Level $level Tamamlandı! +$score puan', '🎉 Level $level Complete! +$score points', '🎉 Level $level geschafft! +$score Punkte', '🎉 ¡Nivel $level completado! +$score puntos')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Oyun bitti
      _showGameCompleteDialog();
    }
  }

  Future<void> _showQuestionDialog(Map<String, dynamic> questionData) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _QuestionDialogContent(
        questionData: questionData,
        onAnswerSelected: (isCorrect, points) {
          _handleAnswer(isCorrect, points);
        },
      ),
    );

    _showingQuestion = false;
  }

  void _handleAnswer(bool isCorrect, int points) {
    setState(() {
      if (isCorrect) {
        _totalScore += points;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tl('✅ Doğru! +$points puan', '✅ Correct! +$points points', '✅ Richtig! +$points Punkte', '✅ ¡Correcto! +$points puntos')),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Yanlis cevapta puan KESILMEZ. Ceza, denemekten cekinmeye yol
        // aciyor; cocuk oyununda dogru davranis yeniden denemeyi
        // desteklemek.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tl('Bu olmadı, tekrar dene!', 'Not quite — try again!',
                'Leider nicht — versuch es noch mal!', 'Casi — ¡inténtalo otra vez!')),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _showGameOverDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_tl('💥 Engele Çarptın!', '💥 You Hit an Obstacle!', '💥 Du bist gegen ein Hindernis gestoßen!', '💥 ¡Chocaste con un obstáculo!'),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.dangerous, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _tl('Level: $_currentLevel', 'Level: $_currentLevel', 'Level: $_currentLevel', 'Nivel: $_currentLevel'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_tl('Toplam Skor: $_totalScore', 'Total Score: $_totalScore', 'Gesamtpunkte: $_totalScore', 'Puntuación total: $_totalScore')),
            Text(_tl('Hamle: $_moves', 'Moves: $_moves', 'Züge: $_moves', 'Movimientos: $_moves')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_tl('Ana Sayfa', 'Home', 'Startseite', 'Inicio')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
            ),
            child: Text(_tl('Tekrar Dene', 'Try Again', 'Noch mal versuchen', 'Intentar de nuevo')),
          ),
        ],
      ),
    );
  }

  Future<void> _showGameCompleteDialog() async {
    final duration = DateTime.now().difference(_startTime!).inSeconds;

    // Firebase'e kaydet
    await _saveScore();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_tl('🏆 Oyun Tamamlandı!', '🏆 Game Complete!', '🏆 Spiel geschafft!', '🏆 ¡Juego completado!'),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _tl('Toplam Skor: $_totalScore', 'Total Score: $_totalScore', 'Gesamtpunkte: $_totalScore', 'Puntuación total: $_totalScore'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_tl('Hamle: $_moves', 'Moves: $_moves', 'Züge: $_moves', 'Movimientos: $_moves')),
            Text(_tl('Süre: $duration saniye', 'Duration: $duration seconds', 'Dauer: $duration Sekunden', 'Duración: $duration segundos')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_tl('Ana Sayfa', 'Home', 'Startseite', 'Inicio')),
          ),
          // Eskiden 'Siralama Gor' vardi; arkasindaki liderlik tablosu
          // Supabase gecisinde kaldirilmisti ve tus cocugu oyundan
          // atiyordu. Yerine gercekten calisan 'Tekrar Oyna' koyuldu.
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            child: Text(_tl('Tekrar Oyna', 'Play Again', 'Noch mal spielen', 'Jugar de nuevo')),
          ),
        ],
      ),
    );
  }

  Future<void> _saveScore() async {
    try {
      // TODO: Migrate to Supabase
      // Replace Firestore with Supabase
      /*
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final duration = DateTime.now().difference(_startTime!).inSeconds;

        await FirebaseFirestore.instance.collection('left_right_scores').add({
          'userId': user.uid,
          'userName': user.displayName ?? 'Oyuncu',
          'score': _totalScore,
          'moves': _moves,
          'duration': duration,
          'levelsCompleted': _currentLevel - 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      */

      // Placeholder - TODO: Implement with Supabase
      debugPrint('Score save pending Supabase migration');
    } catch (e) {
      debugPrint('Error saving score: $e');
    }
  }

  void _resetGame() {
    setState(() {
      _currentLevel = 1;
      _totalScore = 0;
      _moves = 0;
      _startTime = DateTime.now();
      _gameStarted = true;
      _showingQuestion = false;
      _game = LeftRightCodingGame(
        onLevelComplete: _handleLevelComplete,
        onMove: _handleMove,
        onGameStart: _handleGameStart,
        onGameOver: _handleGameOver,
        onBonusSquare: _handleBonusSquare,
        onUnansweredQuestions: _handleUnansweredQuestions,
        puppetType: _selectedPuppet!,
        lang: _lang,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while puppet is being selected
    if (_selectedPuppet == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _ustPanel(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GameWidget(game: _game),
                ),
              ),
            ),
            _yonPaneli(),
          ],
        ),
      ),
    );
  }

  /// Ust panel.
  ///
  /// Eskiden mavi bir seride "Level 1 • Skor: 0 • Hamle: 0" diye tek satir
  /// yaziyordu: uc ayri sayi ayni puntoda, ayni renkte, yan yana. Cocuk
  /// hangisinin ne oldugunu okumadan anlayamiyordu. Ucu de kendi ikonu ve
  /// kendi kutusu olan birer rozete ayrildi; "Level" de artik dile
  /// cevriliyor.
  Widget _ustPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppTheme.darkGray,
                tooltip: _tl('Geri', 'Back', 'Zurück', 'Atrás'),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  _tl('Sağım-Solum', 'Left-Right Coding',
                      'Links-Rechts-Coding', 'Código izquierda-derecha'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkGray,
                  ),
                ),
              ),
              if (_selectedPuppet != null)
                KuklaOnizleme(kukla: _selectedPuppet!, boyut: 52),
            ],
          ),
          if (_gameStarted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _rozet(
                  Icons.flag_rounded,
                  _tl('Seviye', 'Level', 'Level', 'Nivel'),
                  '$_currentLevel',
                  AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                _rozet(
                  Icons.star_rounded,
                  _tl('Puan', 'Score', 'Punkte', 'Puntos'),
                  '$_totalScore',
                  AppTheme.warningOrange,
                ),
                const SizedBox(width: 8),
                _rozet(
                  Icons.directions_walk_rounded,
                  _tl('Hamle', 'Moves', 'Züge', 'Movimientos'),
                  '$_moves',
                  AppTheme.accentTeal,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _rozet(IconData ikon, String etiket, String deger, Color renk) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: renk.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(ikon, size: 18, color: renk),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                etiket,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: renk,
                ),
              ),
            ),
            Text(
              deger,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: renk,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Yon tuslari.
  ///
  /// Eskiden dort buyuk dikdortgen vardi ve her biri BASKA renkteydi:
  /// yukari mavi, sol turuncu, asagi KIRMIZI, sag yesil. Kirmizi bir
  /// "asagi" tusu cocuga tehlike/yanlis diye okunuyor, yesil "sag" ise
  /// dogru cevap gibi. Halbuki dordu de ayni seyin dort yonu.
  ///
  /// Simdi gercek bir yon pedi: ayni renk, ayni agirlik, capraz dizilim.
  /// Her tus 64x64 — Apple'in 44pt alt siniri rahatlikla asiliyor ve
  /// bashparmakla tek elle kullanilabiliyor.
  Widget _yonPaneli() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _yonTusu(Icons.keyboard_arrow_up_rounded,
              _tl('Yukarı', 'Up', 'Oben', 'Arriba'), _game.moveUp),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _yonTusu(Icons.keyboard_arrow_left_rounded,
                  _tl('Sol', 'Left', 'Links', 'Izquierda'), _game.moveLeft),
              const SizedBox(width: 10),
              // Pedin ortasi: hangi kukla ile oynadigini surekli
              // gosteren sabit nokta.
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: KuklaOnizleme(kukla: _selectedPuppet!, boyut: 62),
              ),
              const SizedBox(width: 10),
              _yonTusu(Icons.keyboard_arrow_right_rounded,
                  _tl('Sağ', 'Right', 'Rechts', 'Derecha'), _game.moveRight),
            ],
          ),
          const SizedBox(height: 10),
          _yonTusu(Icons.keyboard_arrow_down_rounded,
              _tl('Aşağı', 'Down', 'Unten', 'Abajo'), _game.moveDown),
        ],
      ),
    );
  }

  Widget _yonTusu(IconData ikon, String etiket, VoidCallback basinca) {
    return Semantics(
      button: true,
      label: etiket,
      child: Material(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.selectionClick();
            basinca();
          },
          child: SizedBox(
            width: 64,
            height: 64,
            child: Icon(ikon, size: 38, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Question Dialog Widget with answer feedback
class _QuestionDialogContent extends StatefulWidget {
  final Map<String, dynamic> questionData;
  final Function(bool isCorrect, int points) onAnswerSelected;

  const _QuestionDialogContent({
    required this.questionData,
    required this.onAnswerSelected,
  });

  @override
  State<_QuestionDialogContent> createState() => _QuestionDialogContentState();
}

class _QuestionDialogContentState extends State<_QuestionDialogContent> {
  int? _selectedAnswerIndex;
  bool _answered = false;

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Bu sinifin kisa arayuz yazilari icin dort dilli yardimci.
  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  Future<void> _selectAnswer(int index) async {
    if (_answered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _answered = true;
    });

    // Wait for user to see the result
    await Future.delayed(const Duration(milliseconds: 1500));

    // Notify parent and close dialog
    final isCorrect = index == widget.questionData['correctAnswer'];
    widget.onAnswerSelected(isCorrect, widget.questionData['points']);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Color _getButtonColor(int index) {
    if (!_answered) {
      return Colors.white;
    }

    final correctAnswer = widget.questionData['correctAnswer'];

    // If this is the selected answer
    if (index == _selectedAnswerIndex) {
      return index == correctAnswer
          ? Colors.green.shade100
          : Colors.red.shade100;
    }

    // If this is the correct answer and user selected wrong
    if (index == correctAnswer && _selectedAnswerIndex != correctAnswer) {
      return Colors.green.shade100;
    }

    return Colors.white;
  }

  Color _getBorderColor(int index) {
    if (!_answered) {
      return Colors.purple.shade200;
    }

    final correctAnswer = widget.questionData['correctAnswer'];

    // If this is the selected answer
    if (index == _selectedAnswerIndex) {
      return index == correctAnswer
          ? Colors.green.shade700
          : Colors.red.shade700;
    }

    // If this is the correct answer and user selected wrong
    if (index == correctAnswer && _selectedAnswerIndex != correctAnswer) {
      return Colors.green.shade700;
    }

    return Colors.purple.shade200;
  }

  IconData? _getIcon(int index) {
    if (!_answered) return null;

    final correctAnswer = widget.questionData['correctAnswer'];

    // If this is the selected answer
    if (index == _selectedAnswerIndex) {
      return index == correctAnswer
          ? Icons.check_circle_rounded
          : Icons.cancel_rounded;
    }

    // If this is the correct answer and user selected wrong
    if (index == correctAnswer && _selectedAnswerIndex != correctAnswer) {
      return Icons.check_circle_rounded;
    }

    return null;
  }

  Color? _getIconColor(int index) {
    if (!_answered) return null;

    final correctAnswer = widget.questionData['correctAnswer'];

    // If this is the selected answer
    if (index == _selectedAnswerIndex) {
      return index == correctAnswer
          ? Colors.green.shade700
          : Colors.red.shade700;
    }

    // If this is the correct answer and user selected wrong
    if (index == correctAnswer && _selectedAnswerIndex != correctAnswer) {
      return Colors.green.shade700;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.help_outline_rounded,
              color: Colors.purple.shade700, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _tl('Bonus Soru!', 'Bonus Question!', 'Bonusfrage!', '¡Pregunta extra!'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.questionData['question'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(widget.questionData['options'].length, (index) {
            final icon = _getIcon(index);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: _answered ? null : () => _selectAnswer(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(index),
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: _getBorderColor(index), width: 2),
                  padding: const EdgeInsets.all(16),
                  disabledBackgroundColor: _getButtonColor(index),
                  disabledForegroundColor: Colors.black87,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _answered
                          ? _getButtonColor(index)
                          : Colors.purple.shade100,
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _answered
                              ? _getBorderColor(index)
                              : Colors.purple.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.questionData['options'][index],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, color: _getIconColor(index), size: 24),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Scratch Question Bank organized by difficulty
class ScratchQuestions {
  static List<Map<String, dynamic>> getQuestionsByDifficulty(int difficulty,
      {String lang = 'tr'}) {
    final allQuestions = [
      // Easy Questions (Difficulty 1)
      {
        'question':
            'Bir karakteri hareket ettirmek için hangi blok kullanılır?',
        'questionEn': 'Which block is used to move a character?',
        'questionDe': 'Mit welchem Block bewegt man eine Figur?',
        'questionEs': '¿Qué bloque se usa para mover un objeto?',
        'options': ['Adım At', 'Döndür', 'Bekle', 'Ses Çıkar'],
        'optionsEn': ['Move Steps', 'Turn', 'Wait', 'Play Sound'],
        'optionsDe': ['Gehe Schritte', 'Drehe dich', 'Warte', 'Spiele Klang'],
        'optionsEs': ['Mover pasos', 'Girar', 'Esperar', 'Iniciar sonido'],
        'correctAnswer': 0,
        'points': 50,
        'difficulty': 1,
      },
      {
        'question': 'Yeşil bayrak neyi başlatır?',
        'questionEn': 'What does the green flag start?',
        'questionDe': 'Was startet die grüne Flagge?',
        'questionEs': '¿Qué inicia la bandera verde?',
        'options': ['Programı', 'Oyunu', 'Projeyi', 'Hepsini'],
        'optionsEn': ['The program', 'The game', 'The project', 'All of them'],
        'optionsDe': ['Das Programm', 'Das Spiel', 'Das Projekt', 'Alles davon'],
        'optionsEs': ['El programa', 'El juego', 'El proyecto', 'Todo lo anterior'],
        'correctAnswer': 3,
        'points': 50,
        'difficulty': 1,
      },
      {
        'question': 'Ekrandaki karaktere ne denir?',
        'questionEn': 'What is the character on the screen called?',
        'questionDe': 'Wie heißt die Spielfigur auf dem Bildschirm?',
        'questionEs': '¿Cómo se llama el personaje de la pantalla?',
        'options': ['Kukla', 'Kutu', 'Şekil', 'Figür'],
        'optionsEn': ['Sprite', 'Box', 'Shape', 'Figure'],
        'optionsDe': ['Figur', 'Kasten', 'Form', 'Bild'],
        'optionsEs': ['Objeto', 'Caja', 'Forma', 'Imagen'],
        'correctAnswer': 0,
        'points': 50,
        'difficulty': 1,
      },
      {
        'question': 'Sahneye arka plan eklemek için ne kullanılır?',
        'questionEn': 'What is used to add a background to the stage?',
        'questionDe': 'Womit fügt man der Bühne einen Hintergrund hinzu?',
        'questionEs': '¿Qué se usa para añadir un fondo al escenario?',
        'options': ['Fon', 'Arkaplan', 'Kukla', 'Kostüm'],
        'optionsEn': ['Backdrop', 'Background', 'Sprite', 'Costume'],
        'optionsDe': ['Bühnenbild', 'Hintergrundbild', 'Figur', 'Kostüm'],
        'optionsEs': ['Fondo', 'Imagen de fondo', 'Objeto', 'Disfraz'],
        'correctAnswer': 0,
        'points': 50,
        'difficulty': 1,
      },

      // Medium Questions (Difficulty 2)
      {
        'question': 'Bir işlemi 10 kez tekrarlamak için hangi blok kullanılır?',
        'questionEn': 'Which block is used to repeat an action 10 times?',
        'questionDe': 'Welcher Block wiederholt eine Aktion 10-mal?',
        'questionEs': '¿Qué bloque repite una acción 10 veces?',
        'options': [
          'Sürekli Tekrarla',
          '10 Kez Tekrarla',
          'Eğer Koşul',
          'Bekle'
        ],
        'optionsEn': ['Forever', 'Repeat 10 Times', 'If Condition', 'Wait'],
        'optionsDe': ['wiederhole fortlaufend', 'wiederhole 10 mal', 'falls ... dann', 'warte'],
        'optionsEs': ['por siempre', 'repetir 10', 'si ... entonces', 'esperar'],
        'correctAnswer': 1,
        'points': 75,
        'difficulty': 2,
      },
      {
        'question': 'Değişken oluşturmak ne işe yarar?',
        'questionEn': 'What is a variable used for?',
        'questionDe': 'Wofür ist eine Variable da?',
        'questionEs': '¿Para qué sirve una variable?',
        'options': [
          'Veri saklamak',
          'Ses eklemek',
          'Renk değiştirmek',
          'Döndürmek'
        ],
        'optionsEn': [
          'Storing data',
          'Adding sound',
          'Changing color',
          'Turning'
        ],
        'optionsDe': ['Daten speichern', 'Klang hinzufügen', 'Farbe ändern', 'Drehen'],
        'optionsEs': ['Guardar datos', 'Añadir sonido', 'Cambiar el color', 'Girar'],
        'correctAnswer': 0,
        'points': 75,
        'difficulty': 2,
      },
      {
        'question': 'Koşullu ifade için hangi blok kullanılır?',
        'questionEn': 'Which block is used for a conditional statement?',
        'questionDe': 'Welcher Block wird für eine Bedingung benutzt?',
        'questionEs': '¿Qué bloque se usa para una condición?',
        'options': ['Eğer-O zaman', 'Tekrarla', 'Bekle', 'Gönder'],
        'optionsEn': ['If-Then', 'Repeat', 'Wait', 'Broadcast'],
        'optionsDe': ['falls ... dann', 'wiederhole', 'warte', 'sende an alle'],
        'optionsEs': ['si ... entonces', 'repetir', 'esperar', 'enviar'],
        'correctAnswer': 0,
        'points': 75,
        'difficulty': 2,
      },
      {
        'question': 'İki kukla arasında mesaj göndermek için ne kullanılır?',
        'questionEn': 'What is used to send a message between two sprites?',
        'questionDe': 'Womit schickt man eine Nachricht von einer Figur zur anderen?',
        'questionEs': '¿Qué se usa para enviar un mensaje entre dos objetos?',
        'options': ['Mesaj Gönder', 'Konuş', 'Ses Çal', 'Değişken'],
        'optionsEn': ['Broadcast', 'Say', 'Play Sound', 'Variable'],
        'optionsDe': ['sende an alle', 'sage', 'spiele Klang', 'Variable'],
        'optionsEs': ['enviar', 'decir', 'iniciar sonido', 'variable'],
        'correctAnswer': 0,
        'points': 75,
        'difficulty': 2,
      },

      // Hard Questions (Difficulty 3)
      {
        'question': 'Klon oluşturmak ne işe yarar?',
        'questionEn': 'What does creating a clone do?',
        'questionDe': 'Was bewirkt das Erzeugen eines Klons?',
        'questionEs': '¿Qué hace crear un clon?',
        'options': [
          'Kukla kopyası yaratır',
          'Proje kaydeder',
          'Ses kopyalar',
          'Renk değiştirir'
        ],
        'optionsEn': [
          'Creates a copy of the sprite',
          'Saves the project',
          'Copies a sound',
          'Changes the color'
        ],
        'optionsDe': ['Es erstellt eine Kopie der Figur', 'Es speichert das Projekt', 'Es kopiert einen Klang', 'Es ändert die Farbe'],
        'optionsEs': ['Crea una copia del objeto', 'Guarda el proyecto', 'Copia un sonido', 'Cambia el color'],
        'correctAnswer': 0,
        'points': 100,
        'difficulty': 3,
      },
      {
        'question': 'Sürekli tekrarla bloğunun içindeki kodlar ne zaman durur?',
        'questionEn': 'When does the code inside a forever block stop?',
        'questionDe': 'Wann stoppt der Code in der Endlosschleife?',
        'questionEs': '¿Cuándo se detiene el código dentro del bucle infinito?',
        'options': [
          'Program durdurulunca',
          '10 saniye sonra',
          'Otomatik durur',
          'Asla çalışmaz'
        ],
        'optionsEn': [
          'When the program is stopped',
          'After 10 seconds',
          'It stops automatically',
          'It never runs'
        ],
        'optionsDe': ['Wenn das Programm gestoppt wird', 'Nach 10 Sekunden', 'Er stoppt von allein', 'Er läuft nie'],
        'optionsEs': ['Cuando se detiene el programa', 'Después de 10 segundos', 'Se detiene solo', 'Nunca se ejecuta'],
        'correctAnswer': 0,
        'points': 100,
        'difficulty': 3,
      },
      {
        'question': 'Algılayıcı blokları ne yapar?',
        'questionEn': 'What do sensing blocks do?',
        'questionDe': 'Was machen die Fühlen-Blöcke?',
        'questionEs': '¿Qué hacen los bloques de sensores?',
        'options': [
          'Çevreden veri alır',
          'Ses çalar',
          'Renk değiştirir',
          'Hareket ettirir'
        ],
        'optionsEn': [
          'Get data from the environment',
          'Play sound',
          'Change color',
          'Move'
        ],
        'optionsDe': ['Sie holen Daten aus der Umgebung', 'Sie spielen Klänge ab', 'Sie ändern die Farbe', 'Sie bewegen die Figur'],
        'optionsEs': ['Obtienen datos del entorno', 'Reproducen sonidos', 'Cambian el color', 'Mueven el objeto'],
        'correctAnswer': 0,
        'points': 100,
        'difficulty': 3,
      },
      {
        'question': 'İşlemci blokları hangi kategoridedir?',
        'questionEn': 'What category do operator blocks belong to?',
        'questionDe': 'Wofür sind die Operatoren-Blöcke da?',
        'questionEs': '¿Para qué sirven los bloques de operadores?',
        'options': ['Matematiksel işlemler', 'Hareket', 'Görünüm', 'Ses'],
        'optionsEn': ['Mathematical operations', 'Motion', 'Looks', 'Sound'],
        'optionsDe': ['Für Rechenoperationen', 'Für Bewegung', 'Für das Aussehen', 'Für Klang'],
        'optionsEs': ['Para operaciones matemáticas', 'Para el movimiento', 'Para la apariencia', 'Para el sonido'],
        'correctAnswer': 0,
        'points': 100,
        'difficulty': 3,
      },
    ];

    final filtered =
        allQuestions.where((q) => q['difficulty'] == difficulty).toList();
    if (lang == 'tr') return filtered;

    // Almanca/Ispanyolca oyuncu artik Ingilizce soru gormuyor. Eksik bir
    // dil olursa zincir kendi dili -> Ingilizce -> Turkce olarak isler.
    const ekler = {'en': 'En', 'de': 'De', 'es': 'Es'};
    final ek = ekler[lang];
    if (ek == null) return filtered;

    return filtered.map((q) {
      final copy = Map<String, dynamic>.from(q);
      copy['question'] = q['question$ek'] ?? q['questionEn'] ?? q['question'];
      copy['options'] = q['options$ek'] ?? q['optionsEn'] ?? q['options'];
      return copy;
    }).toList();
  }
}

/// Flame Game Engine
class LeftRightCodingGame extends FlameGame {
  final Function(int score, int level) onLevelComplete;
  final VoidCallback onMove;
  final VoidCallback onGameStart;
  final VoidCallback onGameOver;
  final Function(Map<String, dynamic>) onBonusSquare;
  final Function(int unansweredCount) onUnansweredQuestions;
  final PuppetType puppetType;
  final String lang;

  late RobotPlayer robot;
  late TargetStar target;
  late GridBackground grid;
  List<Obstacle> obstacles = [];
  List<BonusSquare> bonusSquares = [];
  Set<String> answeredBonusSquares = {}; // Track answered bonus squares
  Set<String> _usedQuestions = {}; // Track used questions to avoid repetition

  int currentLevel = 1;
  int gridSize = 5;
  bool _gameStarted = false;
  bool _gameOver = false;

  /// Tahtanin disinda kalan kenar payi. Varsayilan siyah, yuvarlatilmis
  /// kose maskesinin altinda koyu bir cerceve gibi duruyordu.
  @override
  Color backgroundColor() => Colors.white;

  LeftRightCodingGame({
    required this.onLevelComplete,
    required this.onMove,
    required this.onGameStart,
    required this.onGameOver,
    required this.onBonusSquare,
    required this.onUnansweredQuestions,
    required this.puppetType,
    this.lang = 'tr',
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background
    grid = GridBackground(gridSize: gridSize);
    add(grid);

    // Start game
    _startLevel();
  }

  void _startLevel() {
    if (!_gameStarted) {
      _gameStarted = true;
      onGameStart();
    }

    _gameOver = false;

    // Remove old components
    removeWhere((component) =>
        component is RobotPlayer ||
        component is TargetStar ||
        component is Obstacle ||
        component is BonusSquare);
    obstacles.clear();
    bonusSquares.clear();
    answeredBonusSquares.clear();
    _usedQuestions.clear(); // Reset used questions for new level

    // Increase difficulty
    if (currentLevel > 3 && currentLevel <= 6) {
      gridSize = 7;
    } else if (currentLevel > 6) {
      gridSize = 9;
    }

    grid.gridSize = gridSize;

    // Random robot position (left side)
    final robotX = 0;
    final robotY = (gridSize / 2).floor();

    // Random target position (right side)
    final targetX = gridSize - 1;
    final targetY = (gridSize / 2).floor();

    // Add robot
    robot = RobotPlayer(
      gridX: robotX,
      gridY: robotY,
      gridSize: gridSize,
      puppetType: puppetType,
    );
    add(robot);

    // Add target
    target = TargetStar(
      gridX: targetX,
      gridY: targetY,
      gridSize: gridSize,
    );
    add(target);

    final random = Random();

    // Add obstacles (increase with level)
    final obstacleCount = (currentLevel * 2).clamp(2, gridSize * 2);
    int addedObstacles = 0;

    while (addedObstacles < obstacleCount) {
      final obsX = random.nextInt(gridSize);
      final obsY = random.nextInt(gridSize);

      // Don't place obstacles on robot, target, or already occupied positions
      final isRobotPos = (obsX == robotX && obsY == robotY);
      final isTargetPos = (obsX == targetX && obsY == targetY);
      final isOccupied =
          obstacles.any((obs) => obs.gridX == obsX && obs.gridY == obsY);

      if (!isRobotPos && !isTargetPos && !isOccupied) {
        final obstacle = Obstacle(
          gridX: obsX,
          gridY: obsY,
          gridSize: gridSize,
          type: random.nextInt(3), // 0: rock, 1: bug, 2: spike
        );
        obstacles.add(obstacle);
        add(obstacle);
        addedObstacles++;
      }
    }

    // Add bonus squares (1-2 per level based on difficulty)
    final bonusCount = currentLevel <= 3 ? 1 : 2;
    int addedBonus = 0;

    // Determine question difficulty based on level
    int questionDifficulty = 1;
    if (currentLevel >= 4 && currentLevel <= 7) {
      questionDifficulty = 2;
    } else if (currentLevel >= 8) {
      questionDifficulty = 3;
    }

    while (addedBonus < bonusCount) {
      final bonusX = random.nextInt(gridSize);
      final bonusY = random.nextInt(gridSize);

      // Don't place bonus squares on robot, target, obstacles, or already occupied positions
      final isRobotPos = (bonusX == robotX && bonusY == robotY);
      final isTargetPos = (bonusX == targetX && bonusY == targetY);
      final isObstaclePos =
          obstacles.any((obs) => obs.gridX == bonusX && obs.gridY == bonusY);
      final isBonusOccupied = bonusSquares
          .any((bonus) => bonus.gridX == bonusX && bonus.gridY == bonusY);

      if (!isRobotPos && !isTargetPos && !isObstaclePos && !isBonusOccupied) {
        // Get a random question of appropriate difficulty
        final availableQuestions = ScratchQuestions.getQuestionsByDifficulty(
            questionDifficulty,
            lang: lang);
        if (availableQuestions.isNotEmpty) {
          // Filter out already used questions
          final unusedQuestions = availableQuestions
              .where((q) => !_usedQuestions.contains(q['question']))
              .toList();

          // If all questions used, reset the used questions set
          final questionsToUse =
              unusedQuestions.isNotEmpty ? unusedQuestions : availableQuestions;
          if (unusedQuestions.isEmpty) {
            _usedQuestions.clear();
          }

          final question =
              questionsToUse[random.nextInt(questionsToUse.length)];

          // Mark this question as used
          _usedQuestions.add(question['question']);

          final bonusSquare = BonusSquare(
            gridX: bonusX,
            gridY: bonusY,
            gridSize: gridSize,
            questionData: question,
          );
          bonusSquares.add(bonusSquare);
          add(bonusSquare);
          addedBonus++;
        }
      }
    }
  }

  void moveLeft() {
    if (_gameOver) return;
    if (robot.gridY > 0) {
      final newX = robot.gridX;
      final newY = robot.gridY - 1;
      robot.moveTo(newX, newY);
      onMove();
      _checkCollision();
      if (!_gameOver) {
        _checkBonusSquare();
        _checkWin();
      }
    }
  }

  void moveRight() {
    if (_gameOver) return;
    if (robot.gridY < gridSize - 1) {
      final newX = robot.gridX;
      final newY = robot.gridY + 1;
      robot.moveTo(newX, newY);
      onMove();
      _checkCollision();
      if (!_gameOver) {
        _checkBonusSquare();
        _checkWin();
      }
    }
  }

  void moveUp() {
    if (_gameOver) return;
    if (robot.gridX > 0) {
      final newX = robot.gridX - 1;
      final newY = robot.gridY;
      robot.moveTo(newX, newY);
      onMove();
      _checkCollision();
      if (!_gameOver) {
        _checkBonusSquare();
        _checkWin();
      }
    }
  }

  void moveDown() {
    if (_gameOver) return;
    if (robot.gridX < gridSize - 1) {
      final newX = robot.gridX + 1;
      final newY = robot.gridY;
      robot.moveTo(newX, newY);
      onMove();
      _checkCollision();
      if (!_gameOver) {
        _checkBonusSquare();
        _checkWin();
      }
    }
  }

  void _checkCollision() {
    for (final obstacle in obstacles) {
      if (robot.gridX == obstacle.gridX && robot.gridY == obstacle.gridY) {
        _gameOver = true;
        onGameOver();
        return;
      }
    }
  }

  void _checkBonusSquare() {
    for (final bonusSquare in bonusSquares) {
      if (robot.gridX == bonusSquare.gridX &&
          robot.gridY == bonusSquare.gridY) {
        final squareId = '${bonusSquare.gridX}_${bonusSquare.gridY}';
        // Only trigger question if not already answered
        if (!answeredBonusSquares.contains(squareId)) {
          answeredBonusSquares.add(squareId);
          bonusSquare.markAsAnswered();
          onBonusSquare(bonusSquare.questionData);
        }
        return;
      }
    }
  }

  void _checkWin() {
    if (robot.gridX == target.gridX && robot.gridY == target.gridY) {
      // Check if all bonus squares are answered
      final totalBonusSquares = bonusSquares.length;
      final answeredCount = answeredBonusSquares.length;

      if (answeredCount < totalBonusSquares) {
        // Not all questions answered - highlight unanswered squares in red
        for (final bonusSquare in bonusSquares) {
          final squareId = '${bonusSquare.gridX}_${bonusSquare.gridY}';
          if (!answeredBonusSquares.contains(squareId)) {
            bonusSquare.highlightRed();
          }
        }
        // Show warning message
        onUnansweredQuestions(totalBonusSquares - answeredCount);
        return; // Don't complete level
      }

      // All questions answered - Level complete!
      final score = _calculateScore();
      onLevelComplete(score, currentLevel);

      currentLevel++;

      if (currentLevel <= 10) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _startLevel();
        });
      }
    }
  }

  int _calculateScore() {
    // Base score + level bonus
    return 100 + (currentLevel * 50);
  }
}

/// Grid Background Component
class GridBackground extends PositionComponent
    with HasGameRef<LeftRightCodingGame> {
  int gridSize;

  GridBackground({required this.gridSize});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2.zero();
    size = gameRef.size;
  }

  /// Oyun alani sonradan kuculdugunde (or. alt panel buyudugunde)
  /// tahta eski olculeriyle cizilmeye devam ediyor ve alt siradaki
  /// hedef ekranin disinda kaliyordu. Boyut artik her degisimde
  /// yenileniyor.
  @override
  void onGameResize(Vector2 boyut) {
    super.onGameResize(boyut);
    size = boyut;
  }

  /// Tahtayi cizer.
  ///
  /// Eskiden once izgara cizgileri, SONRA damali zemin ciziliyordu:
  /// zemin cizgilerin ustunu kapattigi icin o cizgiler hicbir zaman
  /// gorunmedi. Simdi hucreler yuvarlatilmis kareler halinde, aralarinda
  /// kucuk bosluklarla ciziliyor — "izgara" hissi cizgiden degil
  /// boslugan geliyor ve tahta uygulamanin geri kalaniyla ayni dili
  /// konusuyor. Renkler de daha yumusak: eski mavi damalar, uzerlerinde
  /// duran kukladan daha cok dikkat cekiyordu.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final cellWidth = size.x / gridSize;
    final cellHeight = size.y / gridSize;
    const bosluk = 3.0;
    final yaricap = Radius.circular(cellWidth * 0.18);

    // Iki ton da ZEMINDEN ayirt edilebilir olmali. Ilk denemede acik
    // hucre ile oyunun arka plani ayni renkti; tahta 5x5 bir izgara
    // gibi degil, dagilmis gri kareler gibi goruniyordu.
    final acik = Paint()..color = const Color(0xFFE9F0F8);
    final koyu = Paint()..color = const Color(0xFFD7E3F1);

    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final isLight = (x + y) % 2 == 0;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              y * cellWidth + bosluk,
              x * cellHeight + bosluk,
              cellWidth - bosluk * 2,
              cellHeight - bosluk * 2,
            ),
            yaricap,
          ),
          isLight ? acik : koyu,
        );
      }
    }
  }
}

/// Robot Player Component
class RobotPlayer extends PositionComponent
    with HasGameRef<LeftRightCodingGame> {
  int gridX;
  int gridY;
  int gridSize;
  final PuppetType puppetType;

  RobotPlayer({
    required this.gridX,
    required this.gridY,
    required this.gridSize,
    required this.puppetType,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updatePosition();
  }

  @override
  void onGameResize(Vector2 boyut) {
    super.onGameResize(boyut);
    if (isMounted) _updatePosition();
  }

  void moveTo(int newX, int newY) {
    gridX = newX;
    gridY = newY;
    _boyutlandir();

    // Eskiden kukla bir kareden digerine isinlaniyordu: komut calisinca
    // aniden yeni hucrede beliriyor, cocuk hangi yone gittigini
    // goremiyordu. Artik aradaki mesafeyi kayarak geciyor.
    final hedef = _hedefKonum();
    if (Motion.reducedRaw) {
      position = hedef;
      return;
    }
    removeAll(children.whereType<MoveToEffect>().toList());
    add(MoveToEffect(
      hedef,
      EffectController(duration: 0.22, curve: Motion.emphasized),
    ));
  }

  Vector2 _hedefKonum() {
    final cellWidth = gameRef.size.x / gridSize;
    final cellHeight = gameRef.size.y / gridSize;
    return Vector2(
      gridY * cellWidth + cellWidth / 2,
      gridX * cellHeight + cellHeight / 2,
    );
  }

  void _boyutlandir() {
    final cellWidth = gameRef.size.x / gridSize;
    final cellHeight = gameRef.size.y / gridSize;
    size = Vector2(cellWidth * 0.6, cellHeight * 0.6);
    anchor = Anchor.center;
  }

  void _updatePosition() {
    _boyutlandir();
    position = _hedefKonum();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    KuklaCizimi.ciz(canvas, size / 2, size, puppetType);
  }
}

/// Target Star Component
class TargetStar extends PositionComponent
    with HasGameRef<LeftRightCodingGame> {
  int gridX;
  int gridY;
  int gridSize;
  double _rotation = 0;

  TargetStar({
    required this.gridX,
    required this.gridY,
    required this.gridSize,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updatePosition();
  }

  @override
  void onGameResize(Vector2 boyut) {
    super.onGameResize(boyut);
    // onGameResize mount'tan ONCE de cagriliyor; gameRef o an hazir
    // olmayabilir.
    if (isMounted) _updatePosition();
  }

  void _updatePosition() {
    final cellWidth = gameRef.size.x / gridSize;
    final cellHeight = gameRef.size.y / gridSize;

    position = Vector2(
      gridY * cellWidth + cellWidth / 2,
      gridX * cellHeight + cellHeight / 2,
    );

    size = Vector2(cellWidth * 0.5, cellHeight * 0.5);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _rotation += dt * 2; // Rotate animation
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rotation);

    // Draw star
    final starPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final starPath = Path();
    final radius = size.x / 2;
    final innerRadius = radius * 0.5;
    final points = 5;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * 3.14159 / points) - 3.14159 / 2;
      final r = i % 2 == 0 ? radius : innerRadius;
      final x = r * cos(angle);
      final y = r * sin(angle);

      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    canvas.drawPath(starPath, starPaint);

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.orange.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(starPath, outlinePaint);

    canvas.restore();
  }
}

/// Obstacle Component (Rocks, Bugs, Spikes)
class Obstacle extends PositionComponent with HasGameRef<LeftRightCodingGame> {
  int gridX;
  int gridY;
  int gridSize;
  int type; // 0: rock, 1: bug, 2: spike

  Obstacle({
    required this.gridX,
    required this.gridY,
    required this.gridSize,
    required this.type,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updatePosition();
  }

  @override
  void onGameResize(Vector2 boyut) {
    super.onGameResize(boyut);
    // onGameResize mount'tan ONCE de cagriliyor; gameRef o an hazir
    // olmayabilir.
    if (isMounted) _updatePosition();
  }

  void _updatePosition() {
    final cellWidth = gameRef.size.x / gridSize;
    final cellHeight = gameRef.size.y / gridSize;

    position = Vector2(
      gridY * cellWidth + cellWidth / 2,
      gridX * cellHeight + cellHeight / 2,
    );

    size = Vector2(cellWidth * 0.6, cellHeight * 0.6);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = size / 2;

    switch (type) {
      case 0: // Rock
        _drawRock(canvas, center);
        break;
      case 1: // Bug
        _drawBug(canvas, center);
        break;
      case 2: // Spike
        _drawSpike(canvas, center);
        break;
    }
  }

  void _drawRock(Canvas canvas, Vector2 center) {
    // Draw rock as an irregular shape
    final rockPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.x - size.x * 0.3, center.y);
    path.lineTo(center.x - size.x * 0.1, center.y - size.y * 0.35);
    path.lineTo(center.x + size.x * 0.2, center.y - size.y * 0.3);
    path.lineTo(center.x + size.x * 0.35, center.y);
    path.lineTo(center.x + size.x * 0.2, center.y + size.y * 0.35);
    path.lineTo(center.x - size.x * 0.2, center.y + size.y * 0.3);
    path.close();

    canvas.drawPath(path, rockPaint);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, shadowPaint);
  }

  void _drawBug(Canvas canvas, Vector2 center) {
    // Draw bug body
    final bodyPaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.x, center.y),
        width: size.x * 0.5,
        height: size.y * 0.7,
      ),
      bodyPaint,
    );

    // Draw bug head
    canvas.drawCircle(
      Offset(center.x, center.y - size.y * 0.25),
      size.x * 0.15,
      Paint()..color = Colors.black,
    );

    // Draw legs
    final legPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = -1; i <= 1; i++) {
      if (i == 0) continue;
      // Left legs
      canvas.drawLine(
        Offset(center.x - size.x * 0.25, center.y + i * size.y * 0.15),
        Offset(center.x - size.x * 0.4, center.y + i * size.y * 0.25),
        legPaint,
      );
      // Right legs
      canvas.drawLine(
        Offset(center.x + size.x * 0.25, center.y + i * size.y * 0.15),
        Offset(center.x + size.x * 0.4, center.y + i * size.y * 0.25),
        legPaint,
      );
    }
  }

  void _drawSpike(Canvas canvas, Vector2 center) {
    // Draw spike as a triangle
    final spikePaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.x, center.y - size.y * 0.4);
    path.lineTo(center.x - size.x * 0.3, center.y + size.y * 0.4);
    path.lineTo(center.x + size.x * 0.3, center.y + size.y * 0.4);
    path.close();

    canvas.drawPath(path, spikePaint);

    // Draw sharp tip
    final tipPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.x, center.y - size.y * 0.4),
      size.x * 0.08,
      tipPaint,
    );

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.brown.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, outlinePaint);
  }
}

/// Bonus Square Component (Question Squares)
class BonusSquare extends PositionComponent
    with HasGameRef<LeftRightCodingGame> {
  int gridX;
  int gridY;
  int gridSize;
  Map<String, dynamic> questionData;
  bool _answered = false;
  bool _highlightedRed = false;
  double _pulseTimer = 0;
  double _redFlashTimer = 0;

  BonusSquare({
    required this.gridX,
    required this.gridY,
    required this.gridSize,
    required this.questionData,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updatePosition();
  }

  @override
  void onGameResize(Vector2 boyut) {
    super.onGameResize(boyut);
    // onGameResize mount'tan ONCE de cagriliyor; gameRef o an hazir
    // olmayabilir.
    if (isMounted) _updatePosition();
  }

  void _updatePosition() {
    final cellWidth = gameRef.size.x / gridSize;
    final cellHeight = gameRef.size.y / gridSize;

    position = Vector2(
      gridY * cellWidth + cellWidth / 2,
      gridX * cellHeight + cellHeight / 2,
    );

    size = Vector2(cellWidth * 0.7, cellHeight * 0.7);
    anchor = Anchor.center;
  }

  void markAsAnswered() {
    _answered = true;
    _highlightedRed = false; // Remove red highlight when answered
  }

  void highlightRed() {
    if (!_answered) {
      _highlightedRed = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_answered) {
      _pulseTimer += dt * 3; // Pulse animation
    }
    if (_highlightedRed) {
      _redFlashTimer += dt * 5; // Faster flash for red warning
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = size / 2;

    // Determine color based on state
    Color squareColor;

    if (_highlightedRed) {
      // Red flashing for unanswered questions when reached goal
      final flashIntensity = (sin(_redFlashTimer) + 1) / 2; // 0 to 1
      squareColor =
          Color.lerp(Colors.red.shade700, Colors.red.shade300, flashIntensity)!;
    } else {
      // Normal color based on difficulty
      final difficulty = questionData['difficulty'] ?? 1;
      if (difficulty == 1) {
        squareColor = Colors.purple.shade400;
      } else if (difficulty == 2) {
        squareColor = Colors.orange.shade400;
      } else {
        squareColor = Colors.amber.shade400;
      }

      // If answered, make it transparent
      if (_answered) {
        squareColor = squareColor.withValues(alpha: 0.3);
      }
    }

    // Pulse effect (stronger for red warning)
    final pulseScale = _highlightedRed
        ? 1.0 + (sin(_redFlashTimer) * 0.15)
        : (_answered ? 1.0 : 1.0 + (sin(_pulseTimer) * 0.1));

    canvas.save();
    canvas.translate(center.x, center.y);
    canvas.scale(pulseScale);

    // Draw square background
    final squarePaint = Paint()
      ..color = squareColor
      ..style = PaintingStyle.fill;

    final squareRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x * 0.9,
        height: size.y * 0.9,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(squareRect, squarePaint);

    // Draw border (white or yellow for red highlight)
    final borderPaint = Paint()
      ..color = _highlightedRed ? Colors.yellow : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _highlightedRed ? 4 : 3;

    canvas.drawRRect(squareRect, borderPaint);

    // Draw question mark or checkmark
    if (!_answered) {
      // Draw question mark
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
    } else {
      // Draw checkmark
      final checkPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final checkPath = Path()
        ..moveTo(-size.x * 0.15, 0)
        ..lineTo(-size.x * 0.05, size.y * 0.1)
        ..lineTo(size.x * 0.15, -size.y * 0.1);

      canvas.drawPath(checkPath, checkPaint);
    }

    canvas.restore();

    // Draw sparkles for unanswered bonus squares
    if (!_answered) {
      _drawSparkles(canvas, center);
    }
  }

  void _drawSparkles(Canvas canvas, Vector2 center) {
    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final sparklePositions = [
      Offset(center.x - size.x * 0.4, center.y - size.y * 0.4),
      Offset(center.x + size.x * 0.4, center.y - size.y * 0.4),
      Offset(center.x - size.x * 0.4, center.y + size.y * 0.4),
      Offset(center.x + size.x * 0.4, center.y + size.y * 0.4),
    ];

    for (var i = 0; i < sparklePositions.length; i++) {
      final pos = sparklePositions[i];
      final sparkleScale = sin(_pulseTimer + i * 1.5) * 0.5 + 0.5;

      canvas.drawCircle(
        pos,
        2 * sparkleScale,
        sparklePaint,
      );
    }
  }
}
