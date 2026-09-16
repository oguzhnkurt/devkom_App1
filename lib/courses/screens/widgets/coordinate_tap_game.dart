import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/settings_provider.dart';
import '../../../services/sound_service.dart';
import '../../../utils/lang.dart';
import '../../models/course_model.dart';
import '../../models/interactive_lesson_model.dart';

// ==========================================
// COORDINATE TAP GAME
// ==========================================

class CoordinateTapGame extends StatefulWidget {
  final MiniGameStep step;
  final Course course;
  final bool isDark;
  final Function(int score) onComplete;

  const CoordinateTapGame({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<CoordinateTapGame> createState() => _CoordinateTapGameState();
}

class _CoordinateTapGameState extends State<CoordinateTapGame> {
  int _score = 0;
  int _currentTarget = 0;
  int _totalTargets = 10;
  int _gridSize = 5;

  late int _targetX;
  late int _targetY;

  bool _showFeedback = false;
  bool _wasCorrect = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    // Koordinat/renk/desen oyunlarinin ses rengi.
    SoundService.useVoice(SfxVoice.soft);
    _gridSize = widget.step.gameConfig['grid_size'] as int? ?? 5;
    _totalTargets = widget.step.gameConfig['targets'] as int? ?? 10;
    _generateNewTarget();
  }

  void _generateNewTarget() {
    final random = Random();
    // Koordinatlar -2 ile 2 arasında (5x5 grid için)
    final halfSize = _gridSize ~/ 2;
    _targetX = random.nextInt(_gridSize) - halfSize;
    _targetY = random.nextInt(_gridSize) - halfSize;
  }

  void _onGridTap(int x, int y) {
    if (_showFeedback || _gameOver) return;

    final isCorrect = (x == _targetX && y == _targetY);

    setState(() {
      _showFeedback = true;
      _wasCorrect = isCorrect;

      if (isCorrect) {
        _score += 10;
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    });

    // Ekran tamamen sessizdi.
    if (isCorrect) {
      SoundService.playCorrect();
    } else {
      SoundService.playWrong();
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      setState(() {
        _showFeedback = false;
        _currentTarget++;

        if (_currentTarget >= _totalTargets) {
          _gameOver = true;
          Future.delayed(const Duration(seconds: 1), () {
            widget.onComplete(_score);
          });
        } else {
          _generateNewTarget();
        }
      });
    });
  }

  /// Bu ekranin arayuz metinleri.
  ///
  /// Dosyanin tamami Turkce sabitti: Almanca ya da Ispanyolca secen cocuk
  /// dersin icinde birden Turkce bir oyun buluyordu.
  String _t(String lang, String tr, String en, String de, String es) =>
      AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    if (_gameOver) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              _t(lang, 'Oyun Bitti!', 'Game Over!', 'Spiel vorbei!',
                  '¡Fin del juego!'),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_t(lang, 'Puanın', 'Your score', 'Deine Punkte', 'Tu puntuación')}: $_score / ${_totalTargets * 10}',
              style: TextStyle(
                fontSize: 24,
                color: widget.course.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _score >= widget.step.targetScore
                  ? _t(lang, 'Harika! Hedefi geçtin! 🎯',
                      'Great! You beat the target! 🎯',
                      'Super! Du hast das Ziel geschafft! 🎯',
                      '¡Genial! ¡Superaste el objetivo! 🎯')
                  : _t(lang, 'İyi deneme! Tekrar dene! 💪',
                      'Good try! Give it another go! 💪',
                      'Guter Versuch! Probier es noch mal! 💪',
                      '¡Buen intento! ¡Prueba otra vez! 💪'),
              style: TextStyle(
                fontSize: 16,
                color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.course.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '$_score',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_t(lang, 'Hedef', 'Target', 'Ziel', 'Objetivo')} ${_currentTarget + 1}/$_totalTargets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.course.secondaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.course.secondaryColor,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.gps_fixed, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '${_t(lang, 'Hedef', 'Target', 'Ziel', 'Objetivo')}: X: $_targetX, Y: $_targetY',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Grid
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: _buildGrid(),
          ),
        ),

        const SizedBox(height: 16),

        // Feedback
        AnimatedOpacity(
          opacity: _showFeedback ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _wasCorrect
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _wasCorrect ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _wasCorrect ? Icons.check_circle : Icons.cancel,
                  color: _wasCorrect ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _wasCorrect
                      ? _t(lang, 'Doğru! 🎯', 'Correct! 🎯', 'Richtig! 🎯',
                          '¡Correcto! 🎯')
                      : _t(lang, 'Yanlış koordinat!', 'Wrong coordinate!',
                          'Falsche Koordinate!', '¡Coordenada equivocada!'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _wasCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final halfSize = _gridSize ~/ 2;

    return Stack(
      children: [
        // Grid lines
        CustomPaint(
          painter: _GridPainter(
            gridSize: _gridSize,
            isDark: widget.isDark,
          ),
          child: Container(),
        ),

        // Cat emoji at center
        Center(
          child: Text(
            '🐱',
            style: const TextStyle(fontSize: 32),
          ),
        ),

        // Tap areas
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridSize,
          ),
          itemCount: _gridSize * _gridSize,
          itemBuilder: (context, index) {
            final row = index ~/ _gridSize;
            final col = index % _gridSize;
            final x = col - halfSize;
            final y = halfSize - row;  // Invert Y axis

            final isTarget = (x == _targetX && y == _targetY);

            return GestureDetector(
              onTap: () => _onGridTap(x, y),
              child: Container(
                decoration: BoxDecoration(
                  color: _showFeedback && isTarget
                      ? (_wasCorrect
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3))
                      : Colors.transparent,
                  // Hicbir sey cizmeyen seffaf cerceve kaldirildi.
                ),
                // Karenin icinde koordinat YAZMIYOR. Cocuk sayilari
                // eksenlerden okuyup saymali.
                child: const SizedBox.expand(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final int gridSize;
  final bool isDark;

  _GridPainter({
    required this.gridSize,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.grey.shade700 : Colors.grey.shade300
      ..strokeWidth = 1;

    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;

    // Vertical lines
    for (int i = 0; i <= gridSize; i++) {
      final x = i * cellWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 0; i <= gridSize; i++) {
      final y = i * cellHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Center lines (thicker)
    final centerPaint = Paint()
      ..color = isDark ? Colors.grey.shade500 : Colors.grey.shade600
      ..strokeWidth = 2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // X axis
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerPaint,
    );

    // Y axis
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      centerPaint,
    );

    _eksenSayilari(canvas, size, cellWidth, cellHeight, centerX, centerY);
  }

  /// Eksenlerin uzerine sayilari yazar.
  ///
  /// Eskiden HER KARENIN icinde kendi koordinati yaziyordu ve ustte de
  /// hedef ayni yazimla duruyordu — cocuk eksenlere hic bakmadan, ayni
  /// yaziyi bulup dokunarak kazanabiliyordu. Sayilar artik yalnizca
  /// eksenlerde: karenin yerini bulmak icin saymak gerekiyor. Gercek bir
  /// koordinat duzlemi de boyle gorunur.
  void _eksenSayilari(Canvas canvas, Size size, double cellWidth,
      double cellHeight, double centerX, double centerY) {
    final yari = gridSize ~/ 2;
    final renk = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    void yaz(String metin, Offset merkez) {
      final tp = TextPainter(
        text: TextSpan(
          text: metin,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: renk,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, merkez - Offset(tp.width / 2, tp.height / 2));
    }

    for (int i = 0; i < gridSize; i++) {
      final deger = i - yari;
      if (deger == 0) continue; // sifir iki kez yazilmasin

      // X ekseni: sayilar yatay cizginin hemen altinda
      yaz('$deger',
          Offset((i + 0.5) * cellWidth, centerY + cellHeight * 0.32));

      // Y ekseni: yukari dogru buyuyor, o yuzden satir sirasi ters
      final satir = yari - deger;
      yaz('$deger',
          Offset(centerX - cellWidth * 0.32, (satir + 0.5) * cellHeight));
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.gridSize != gridSize || oldDelegate.isDark != isDark;
}
