import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ui/motion.dart';

/// Oyunlar ekraninin arka plani.
///
/// Ekran duz gri bir zemin uzerinde beyaz kartlardan ibaretti; icerik iyiydi
/// ama sayfa "oyun" degil "liste" gibi duruyordu. Buraya konu ile ilgili,
/// yavasca suzulen semboller koyduk: kod bloklari, disliler, yon oklari,
/// devre dugumleri, satranc karesi. Cocuk sayfaya girer girmez burasinin
/// oyun alani oldugunu simgelerden anliyor.
///
/// Uc kural:
///  * **Soluk, ama gorunur.** Ilk denemede opaklik 0.055-0.10 idi ve
///    simulatorde semboller HIC secilmiyordu: kart okunurlugunu korumak
///    icin o kadar geri cekilmisti ki ortada arka plan diye bir sey
///    kalmamisti. Simdi 0.11-0.20; hala kartlarin arkasinda duruyor ama
///    sayfaya girince fark ediliyor.
///  * **Cok yavas.** Tam tur 30-45 saniye; goz takip etmeye calismiyor.
///  * **Duraklatilabilir.** Sistem "hareketi azalt" diyorsa hic oynamiyor,
///    semboller sabit duruyor.
class PlayfulBackground extends StatefulWidget {
  const PlayfulBackground({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFF5F7FA),
    this.tint = const Color(0xFF7E57C2),
    this.symbolCount = 16,
  });

  final Widget child;

  /// Zemin rengi.
  final Color baseColor;

  /// Sembollerin ve renk kumelerinin ana rengi.
  final Color tint;

  final int symbolCount;

  @override
  State<PlayfulBackground> createState() => _PlayfulBackgroundState();
}

class _PlayfulBackgroundState extends State<PlayfulBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 36),
  );

  late final List<_Symbol> _symbols;

  @override
  void initState() {
    super.initState();
    // Sabit tohum: uygulama her acildiginda semboller ayni yerde olsun.
    // Rastgele yerlesim her acilista farkli olsa ekran "oynak" hissederdi.
    final rnd = math.Random(7);
    _symbols = List.generate(widget.symbolCount, (i) {
      return _Symbol(
        kind: _SymbolKind.values[i % _SymbolKind.values.length],
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        size: 20 + rnd.nextDouble() * 30,
        phase: rnd.nextDouble(),
        drift: 0.5 + rnd.nextDouble(),
        tilt: (rnd.nextDouble() - 0.5) * 0.6,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !Motion.reduced(context)) _c.repeat();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _PlayfulPainter(
                  t: _c.value,
                  base: widget.baseColor,
                  tint: widget.tint,
                  symbols: _symbols,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

enum _SymbolKind { block, gear, arrow, node, square, bracket }

class _Symbol {
  const _Symbol({
    required this.kind,
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.drift,
    required this.tilt,
  });

  final _SymbolKind kind;

  /// 0..1 oranli konum.
  final double x;
  final double y;

  final double size;

  /// Dongudeki baslangic noktasi; hepsi ayni anda hareket etmesin.
  final double phase;

  /// Suzulme hizi carpani.
  final double drift;

  /// Sabit egim (radyan).
  final double tilt;
}

class _PlayfulPainter extends CustomPainter {
  _PlayfulPainter({
    required this.t,
    required this.base,
    required this.tint,
    required this.symbols,
  });

  final double t;
  final Color base;
  final Color tint;
  final List<_Symbol> symbols;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = base);

    // Iki yumusak renk kumesi: sayfanin ust ve alt yarisina hafif bir
    // derinlik veriyor. Kartlarin arkasinda kalacak kadar soluk.
    _blob(canvas, size, Offset(size.width * 0.15, size.height * 0.12),
        size.width * 0.62, tint.withValues(alpha: 0.16));
    _blob(canvas, size, Offset(size.width * 0.92, size.height * 0.55),
        size.width * 0.58, const Color(0xFF1E88E5).withValues(alpha: 0.13));
    _blob(canvas, size, Offset(size.width * 0.1, size.height * 0.95),
        size.width * 0.5, const Color(0xFF2E7D32).withValues(alpha: 0.09));

    for (final s in symbols) {
      // Yukaridan asagi degil, asagidan yukari suzuluyorlar: sayfa
      // kaydirilirken ters yonde hareket ediyormus hissi vermesin.
      final p = (t * s.drift + s.phase) % 1.0;
      final dy = (1 - p) * size.height * 1.1 - size.height * 0.05;
      final wobble = math.sin((p + s.phase) * math.pi * 2) * 14;
      final center = Offset(s.x * size.width + wobble, dy);

      // Kenarlara yakin olanlar iyice soluklasin ki kartlarin altinda
      // "kirli" bir doku olusmasin.
      final fade = (math.sin(p * math.pi)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = tint.withValues(alpha: 0.11 + 0.09 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(s.tilt + math.sin(p * math.pi * 2) * 0.12);
      _drawSymbol(canvas, s.kind, s.size, paint);
      canvas.restore();
    }
  }

  void _blob(
      Canvas canvas, Size size, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawSymbol(Canvas canvas, _SymbolKind kind, double s, Paint paint) {
    final h = s / 2;
    switch (kind) {
      case _SymbolKind.block:
        // Scratch tarzi tirnakli blok.
        final path = Path()
          ..moveTo(-h, -h * 0.55)
          ..lineTo(-h * 0.35, -h * 0.55)
          ..lineTo(-h * 0.15, -h * 0.85)
          ..lineTo(h * 0.15, -h * 0.85)
          ..lineTo(h * 0.35, -h * 0.55)
          ..lineTo(h, -h * 0.55)
          ..lineTo(h, h * 0.55)
          ..lineTo(-h, h * 0.55)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case _SymbolKind.gear:
        canvas.drawCircle(Offset.zero, h * 0.55, paint);
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          canvas.drawLine(
            Offset(math.cos(a) * h * 0.65, math.sin(a) * h * 0.65),
            Offset(math.cos(a) * h, math.sin(a) * h),
            paint,
          );
        }
        break;
      case _SymbolKind.arrow:
        canvas.drawLine(Offset(-h, 0), Offset(h, 0), paint);
        canvas.drawLine(Offset(h, 0), Offset(h * 0.35, -h * 0.5), paint);
        canvas.drawLine(Offset(h, 0), Offset(h * 0.35, h * 0.5), paint);
        break;
      case _SymbolKind.node:
        // Devre dugumu: iki bacakli kucuk bir baglanti.
        canvas.drawCircle(Offset.zero, h * 0.32, paint);
        canvas.drawLine(Offset(-h, 0), Offset(-h * 0.32, 0), paint);
        canvas.drawLine(Offset(h * 0.32, 0), Offset(h, 0), paint);
        canvas.drawLine(Offset(0, h * 0.32), Offset(0, h), paint);
        break;
      case _SymbolKind.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: s * 0.8, height: s * 0.8),
            Radius.circular(s * 0.16),
          ),
          paint,
        );
        break;
      case _SymbolKind.bracket:
        // { } — kod parantezi.
        canvas.drawPath(
          Path()
            ..moveTo(-h * 0.25, -h)
            ..quadraticBezierTo(-h * 0.8, -h, -h * 0.8, 0)
            ..quadraticBezierTo(-h * 0.8, h, -h * 0.25, h),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(h * 0.25, -h)
            ..quadraticBezierTo(h * 0.8, -h, h * 0.8, 0)
            ..quadraticBezierTo(h * 0.8, h, h * 0.25, h),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(_PlayfulPainter old) => old.t != t;
}
