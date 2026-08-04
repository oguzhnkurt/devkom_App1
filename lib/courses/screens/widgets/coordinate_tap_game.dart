import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              'Oyun Bitti!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Puanın: $_score / ${_totalTargets * 10}',
              style: TextStyle(
                fontSize: 24,
                color: widget.course.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _score >= widget.step.targetScore
                  ? 'Harika! Hedefi geçtin! 🎯'
                  : 'İyi deneme! Tekrar dene! 💪',
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
                    'Hedef ${_currentTarget + 1}/$_totalTargets',
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
                      'Hedef: X: $_targetX, Y: $_targetY',
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
                  _wasCorrect ? 'Doğru! 🎯' : 'Yanlış koordinat!',
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
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '($x,$y)',
                    style: TextStyle(
                      fontSize: 9,
                      color: widget.isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
