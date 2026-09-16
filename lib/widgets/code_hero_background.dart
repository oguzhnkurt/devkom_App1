import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Onboarding karşılama ekranının hareketli arka planı.
///
/// Neden hazır video değil: uygulamaya video koymak hem lisans işi (kodlama
/// temalı stok görüntünün ticari kullanım hakkı gerekiyor) hem de paket
/// boyutunu onlarca MB büyütüyor — çocukların telefonuna mobil veriyle inen
/// bir eğitim uygulaması için ucuz bir maliyet değil. Aynı hareketi kodla
/// çizince ne lisans sorunu kalıyor ne de boyut; üstelik ekranda gerçekten
/// kod akıyor, konuyla alakasız stok görüntü değil.
///
/// Üç katman var: yükselen kod parçacıkları, aralarını bağlayan soluk devre
/// çizgileri ve en üstte kendini yazan bir terminal satırı.
class CodeHeroBackground extends StatefulWidget {
  const CodeHeroBackground({super.key, this.child});

  final Widget? child;

  @override
  State<CodeHeroBackground> createState() => _CodeHeroBackgroundState();
}

class _CodeHeroBackgroundState extends State<CodeHeroBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 24),
    vsync: this,
  )..repeat();

  late final List<_FloatingToken> _tokens = _buildTokens();

  /// Ekranda süzülen kod parçaları. Hepsi uygulamada gerçekten öğretilen
  /// şeyler: Scratch blokları, Python, HTML, Arduino.
  static const List<String> _snippets = [
    'print("Merhaba")',
    'for i in range(3):',
    'if sensor < 10:',
    'def selam():',
    '<h1>Kodla</h1>',
    'digitalWrite(13, HIGH)',
    'robot.ileri(100)',
    '10 adım git',
    'while True:',
    'led.yak()',
    'body { color: blue; }',
    'return sonuc',
  ];

  List<_FloatingToken> _buildTokens() {
    // Sabit tohum: her açılışta aynı yerleşim çıksın, ekran "zıplamasın".
    final random = math.Random(7);
    return List.generate(_snippets.length, (i) {
      return _FloatingToken(
        text: _snippets[i],
        x: random.nextDouble(),
        startY: random.nextDouble(),
        speed: 0.25 + random.nextDouble() * 0.5,
        opacity: 0.10 + random.nextDouble() * 0.14,
        fontSize: 11 + random.nextDouble() * 5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B3A8C),
            Color(0xFF2D4FBF),
            Color(0xFF1FA5B8),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _CodeRainPainter(
                progress: _controller.value,
                tokens: _tokens,
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _FloatingToken {
  const _FloatingToken({
    required this.text,
    required this.x,
    required this.startY,
    required this.speed,
    required this.opacity,
    required this.fontSize,
  });

  final String text;

  /// 0..1 arası yatay konum.
  final double x;

  /// 0..1 arası başlangıç dikey konumu.
  final double startY;

  /// Yükselme hızı çarpanı.
  final double speed;
  final double opacity;
  final double fontSize;
}

class _CodeRainPainter extends CustomPainter {
  _CodeRainPainter({required this.progress, required this.tokens});

  final double progress;
  final List<_FloatingToken> tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    final points = <Offset>[];

    for (final token in tokens) {
      // Aşağıdan yukarı süzülüyor; ekranın dışına çıkınca alttan geri giriyor.
      final travelled = (token.startY - progress * token.speed) % 1.0;
      final dy = travelled * (size.height + 80) - 40;
      final dx = token.x * size.width;
      points.add(Offset(dx, dy));

      final painter = TextPainter(
        text: TextSpan(
          text: token.text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: token.opacity),
            fontSize: token.fontSize,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(dx, dy));
    }

    // Yakın parçacıkları ince çizgilerle bağla: devre kartı hissi.
    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        final d = (points[i] - points[j]).distance;
        if (d < 140) {
          canvas.drawLine(points[i], points[j], linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CodeRainPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Kendini yazan kod satırı — imleç yanıp söner, satır bitince bir sonrakine
/// geçer. Karşılama ekranındaki "terminal" kartında kullanılıyor.
class TypingCodeLine extends StatefulWidget {
  const TypingCodeLine({
    super.key,
    required this.lines,
    this.textStyle,
    this.cursorColor = Colors.white,
  });

  final List<String> lines;
  final TextStyle? textStyle;
  final Color cursorColor;

  @override
  State<TypingCodeLine> createState() => _TypingCodeLineState();
}

class _TypingCodeLineState extends State<TypingCodeLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursor = AnimationController(
    duration: const Duration(milliseconds: 900),
    vsync: this,
  )..repeat(reverse: true);

  int _lineIndex = 0;
  int _charCount = 0;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  /// Tek bir zamanlayıcı yerine kendini çağıran gecikme kullanıyoruz: yazma,
  /// bekleme ve silme adımlarının süresi farklı.
  Future<void> _tick() async {
    while (mounted) {
      final line = widget.lines[_lineIndex];
      if (!_deleting && _charCount < line.length) {
        await Future.delayed(const Duration(milliseconds: 55));
        if (!mounted) return;
        setState(() => _charCount++);
      } else if (!_deleting) {
        await Future.delayed(const Duration(milliseconds: 1400));
        if (!mounted) return;
        setState(() => _deleting = true);
      } else if (_charCount > 0) {
        await Future.delayed(const Duration(milliseconds: 22));
        if (!mounted) return;
        setState(() => _charCount--);
      } else {
        if (!mounted) return;
        setState(() {
          _deleting = false;
          _lineIndex = (_lineIndex + 1) % widget.lines.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.textStyle ??
        const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );
    final visible = widget.lines[_lineIndex].substring(0, _charCount);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            visible,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
        FadeTransition(
          opacity: _cursor,
          child: Container(
            width: 8,
            height: (style.fontSize ?? 14) + 2,
            margin: const EdgeInsets.only(left: 2),
            color: widget.cursorColor,
          ),
        ),
      ],
    );
  }
}
