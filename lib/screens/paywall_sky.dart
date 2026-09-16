import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ui/motion.dart';

/// Pro ekranının arka planı: bulutlu, gökkuşaklı bir gökyüzü.
///
/// NEDEN
/// -----
/// Önceki arka plan kurumsal bir "aurora" idi: mavi-mor lekeler, soğuk
/// gri zemin. Uygulamanın geri kalanı çocuk için tasarlanmışken paranın
/// istendiği ekran bir SaaS açılış sayfası gibi duruyordu. Bu ekran
/// çocuğun ebeveynine gösterdiği ekran; sıcak olmalı.
///
/// TAMAMEN ÇİZİLİYOR, görsel yok: hem uygulama boyutu büyümüyor hem de
/// her ekran boyutunda aynı şekilde ölçekleniyor.
///
/// Hareket: bulutlar çok yavaş sürükleniyor (36 saniyelik tur). Hareket
/// azaltılmışsa hiç dönmüyor — [Motion.reduced].
class PaywallSky extends StatefulWidget {
  const PaywallSky({super.key});

  @override
  State<PaywallSky> createState() => _PaywallSkyState();
}

class _PaywallSkyState extends State<PaywallSky>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 36),
  );

  @override
  void initState() {
    super.initState();
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _SkyPainter(_c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.t);

  /// 0 → 1 arası, bulutların sürüklenme aşaması.
  final double t;

  // Yukarıdan aşağı: sabah turuncusu → şeftali → gök mavisi → çimen
  // yeşili. Yeşil en altta çünkü zemin orada.
  static const _sky = <Color>[
    Color(0xFFFFF1D6),
    Color(0xFFFFD9A8),
    Color(0xFFBFE6FF),
    Color(0xFFDDF3DC),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _sky,
          stops: const [0.0, 0.24, 0.62, 1.0],
        ).createShader(rect),
    );

    // --- güneş ------------------------------------------------------
    canvas.drawCircle(
      Offset(w * 0.16, h * 0.10),
      w * 0.30,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFC24B).withValues(alpha: 0.45),
            const Color(0xFFFFC24B).withValues(alpha: 0.0),
          ],
        ).createShader(
            Rect.fromCircle(center: Offset(w * 0.16, h * 0.10), radius: w * 0.30)),
    );

    // --- gökkuşağı --------------------------------------------------
    // Sağ üstten aşağı inen geniş bir yay. Solgun: arkada durmalı,
    // yazının okunmasını zorlaştırmamalı.
    _rainbow(canvas, Offset(w * 1.02, h * 0.30), w * 0.62);

    // --- bulutlar ---------------------------------------------------
    // Üç katman, farklı hızlarda: derinlik hissi. Her bulut ekranın
    // sağından çıkıp solundan giriyor (sonsuz döngü).
    final clouds = <(double y, double scale, double speed, double alpha)>[
      (0.08, 1.00, 1.00, 0.95),
      (0.20, 0.68, 0.62, 0.80),
      (0.35, 1.25, 1.35, 0.90),
      (0.52, 0.55, 0.45, 0.70),
      (0.72, 0.85, 0.85, 0.85),
    ];
    for (var i = 0; i < clouds.length; i++) {
      final (y, scale, speed, alpha) = clouds[i];
      // Her bulut farklı bir fazda başlıyor ki hepsi aynı anda
      // ekranın kenarına gelmesin.
      final phase = (t * speed + i / clouds.length) % 1.0;
      final x = w * 1.25 - phase * (w * 1.6);
      _cloud(canvas, Offset(x, h * y), w * 0.30 * scale, alpha);
    }
  }

  void _rainbow(Canvas canvas, Offset center, double outerR) {
    const bands = <Color>[
      Color(0xFFFF8A80),
      Color(0xFFFFC24B),
      Color(0xFFFFF176),
      Color(0xFF9CE29C),
      Color(0xFF8AC7FF),
      Color(0xFFC4A7F5),
    ];
    final band = outerR * 0.055;
    for (var i = 0; i < bands.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerR - i * band),
        math.pi * 0.62,
        math.pi * 0.55,
        false,
        Paint()
          // 0.38 idi; basligin arkasindan gecerken metnin
          // okunurlugunu dusuruyordu.
          ..color = bands[i].withValues(alpha: 0.26)
          ..style = PaintingStyle.stroke
          ..strokeWidth = band
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// Üst üste binen dairelerden bir bulut. Tek bir Path'e toplanıp bir
  /// kerede çiziliyor: ayrı ayrı çizilince daireler arasındaki saydam
  /// kesişimler koyu lekeler yapıyordu.
  void _cloud(Canvas canvas, Offset c, double w, double alpha) {
    final r = w * 0.32;
    final path = Path()
      ..addOval(Rect.fromCircle(center: c, radius: r))
      ..addOval(Rect.fromCircle(
          center: Offset(c.dx - r * 0.95, c.dy + r * 0.30), radius: r * 0.72))
      ..addOval(Rect.fromCircle(
          center: Offset(c.dx + r * 0.98, c.dy + r * 0.26), radius: r * 0.66))
      ..addOval(Rect.fromCircle(
          center: Offset(c.dx + r * 0.30, c.dy - r * 0.48), radius: r * 0.60))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(c.dx, c.dy + r * 0.52),
            width: r * 3.0,
            height: r * 0.80),
        Radius.circular(r * 0.40),
      ));

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => old.t != t;
}
