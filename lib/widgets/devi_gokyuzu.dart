import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ui/motion.dart';

/// Devi'nin gokyuzu: DevAI ekraninin ve yapay zeka dersinin zemini.
///
/// Duz mor gecis yerine yavasca nefes alan bir "sinir agi takimyildizi":
/// koyu lacivert-mor bir gok, uzerinde suzulen yumusak isik bulutlari,
/// birbirine ince cizgilerle bagli dugumler ve cizgiler boyunca akan
/// kucuk isik sinyalleri. Yapay zekanin "beyin agi" fikrini cocuga
/// hissettiriyor ama yaziyi okumayi zorlastirmayacak kadar soluk.
///
/// Hareketi azalt aciksa sahne duruyor.
class DeviGokyuzu extends StatefulWidget {
  const DeviGokyuzu({
    super.key,
    required this.child,
    this.renkler = varsayilan,
    this.yogunluk = 1.0,
  });

  final Widget child;

  /// Ustten alta zemin gecisi.
  final List<Color> renkler;

  /// Dugum ve isiklarin parlakligi (0-1+).
  final double yogunluk;

  static const varsayilan = [
    Color(0xFF1B1446),
    Color(0xFF3A1F7A),
    Color(0xFF5B2A9E),
  ];

  @override
  State<DeviGokyuzu> createState() => _DeviGokyuzuState();
}

class _DeviGokyuzuState extends State<DeviGokyuzu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _t.stop();
    } else if (!_t.isAnimating) {
      _t.repeat();
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.renkler,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _GokRessami(_t, widget.yogunluk),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Dugum {
  _Dugum(this.x, this.y, this.faz, this.r);
  final double x, y, faz, r;
}

class _GokRessami extends CustomPainter {
  _GokRessami(this.t, this.yogunluk) : super(repaint: t);

  final Animation<double> t;
  final double yogunluk;

  // Sabit tohum: her acilista ayni takimyildizi; ekran "titremesin".
  static final List<_Dugum> _dugumler = () {
    final r = math.Random(7);
    return List.generate(
      26,
      (_) => _Dugum(r.nextDouble(), r.nextDouble(), r.nextDouble() * math.pi * 2,
          1.2 + r.nextDouble() * 1.8),
    );
  }();

  static final List<Offset> _yildizlar = () {
    final r = math.Random(11);
    return List.generate(46, (_) => Offset(r.nextDouble(), r.nextDouble()));
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value * math.pi * 2;
    final w = size.width, h = size.height;

    // Isik bulutlari.
    void bulut(double cx, double cy, double rad, Color c) {
      final o = Offset(cx * w, cy * h);
      canvas.drawCircle(
        o,
        rad,
        Paint()
          ..shader = RadialGradient(colors: [c, c.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: o, radius: rad)),
      );
    }

    bulut(0.2 + 0.08 * math.sin(v), 0.18 + 0.05 * math.cos(v), w * 0.75,
        const Color(0xFF00D1FF).withValues(alpha: 0.16 * yogunluk));
    bulut(0.85 + 0.06 * math.cos(v * 1.3), 0.55 + 0.06 * math.sin(v), w * 0.8,
        const Color(0xFFFF4FD8).withValues(alpha: 0.13 * yogunluk));
    bulut(0.35 + 0.07 * math.sin(v * 0.7), 0.92, w * 0.7,
        const Color(0xFFFFB347).withValues(alpha: 0.10 * yogunluk));

    // Yildizlar (goz kirpar).
    final yildiz = Paint();
    for (var i = 0; i < _yildizlar.length; i++) {
      final s = _yildizlar[i];
      final a = 0.25 + 0.35 * (0.5 + 0.5 * math.sin(v * 3 + i));
      yildiz.color = Colors.white.withValues(alpha: a * 0.6 * yogunluk);
      canvas.drawCircle(Offset(s.dx * w, s.dy * h), 0.9, yildiz);
    }

    // Dugumler (hafifce suzuluyor).
    final konum = [
      for (final d in _dugumler)
        Offset(
          (d.x + 0.015 * math.sin(v + d.faz)) * w,
          (d.y + 0.012 * math.cos(v * 1.2 + d.faz)) * h,
        ),
    ];

    final esik = math.min(w, h) * 0.32;
    final cizgi = Paint()..strokeWidth = 0.8;
    final sinyal = Paint();
    for (var i = 0; i < konum.length; i++) {
      for (var j = i + 1; j < konum.length; j++) {
        final d = (konum[i] - konum[j]).distance;
        if (d > esik) continue;
        final a = (1 - d / esik) * 0.22 * yogunluk;
        cizgi.color = Colors.white.withValues(alpha: a);
        canvas.drawLine(konum[i], konum[j], cizgi);
        // Bazi kenarlarda akan sinyal.
        if ((i + j) % 4 == 0) {
          final p = (t.value * 2 + (i * 0.13)) % 1.0;
          final o = Offset.lerp(konum[i], konum[j], p)!;
          sinyal.color = const Color(0xFF7FF6FF)
              .withValues(alpha: (a * 3.2).clamp(0.0, 0.8));
          canvas.drawCircle(o, 1.8, sinyal);
        }
      }
    }
    final nokta = Paint();
    for (var i = 0; i < konum.length; i++) {
      final nab = 0.5 + 0.5 * math.sin(v * 2 + _dugumler[i].faz);
      nokta.color = Colors.white.withValues(alpha: (0.25 + 0.35 * nab) * yogunluk);
      canvas.drawCircle(konum[i], _dugumler[i].r, nokta);
    }
  }

  @override
  bool shouldRepaint(_GokRessami old) => old.yogunluk != yogunluk;
}
