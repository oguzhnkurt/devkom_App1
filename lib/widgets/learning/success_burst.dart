import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/motion.dart';

/// Dogru cevap aninda bir noktadan disari acilan halka + kivilcimlar.
///
/// Oyunlarda dogru cevabin karsiligi bir SnackBar'di: ekranin altinda
/// beliren gri bir cubuk, cocugun bakmadigi yerde, bir saniye sonra
/// kaybolan. Basari geri bildirimi olayin GERCEKLESTIGI yerde olmali —
/// cocuk zaten oraya bakiyor.
///
/// Tek atislik: [onDone] ile kendini kaldirir. Hareket azaltilmisken
/// kivilcim ucusmuyor, sadece kisa bir halka cikiyor.
class SuccessBurst extends StatefulWidget {
  const SuccessBurst({
    super.key,
    required this.center,
    this.color = const Color(0xFF2E7D32),
    this.onDone,
  });

  /// Efektin merkezi (sarmalayan Stack'in koordinatlarinda).
  final Offset center;
  final Color color;
  final VoidCallback? onDone;

  @override
  State<SuccessBurst> createState() => _SuccessBurstState();
}

class _SuccessBurstState extends State<SuccessBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.long4,
  )..forward().whenComplete(() => widget.onDone?.call());

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _BurstPainter(
            t: Curves.easeOut.transform(_c.value),
            center: widget.center,
            color: widget.color,
            sparks: !Motion.reduced(context),
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.t,
    required this.center,
    required this.color,
    required this.sparks,
  });

  final double t;
  final Offset center;
  final Color color;
  final bool sparks;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = (1 - t).clamp(0.0, 1.0);

    // Genisleyen halka.
    canvas.drawCircle(
      center,
      12 + t * 46,
      Paint()
        ..color = color.withValues(alpha: 0.55 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 * fade + 0.5,
    );

    // Ortada kisa bir parlama.
    canvas.drawCircle(
      center,
      18 * (1 - t) + 4,
      Paint()..color = color.withValues(alpha: 0.28 * fade),
    );

    if (!sparks) return;

    // Sekiz kivilcim, disari dogru.
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + 0.2;
      final d = 18 + t * 52;
      final p = center + Offset(math.cos(a) * d, math.sin(a) * d);
      canvas.drawCircle(
        p,
        3.2 * fade + 0.6,
        Paint()..color = color.withValues(alpha: 0.75 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
