import 'package:flutter/material.dart';
import '../courses/models/interactive_lesson_model.dart';

/// MIT Scratch benzeri GERÇEK yapboz blokları - Based on actual Scratch SVG paths
class ScratchBlockWidget extends StatelessWidget {
  final ScratchBlock block;
  final bool isPlaced;
  final VoidCallback? onTap;
  final bool showRemoveIcon;

  /// C blogunun yalnizca UST CUBUGUNU ciz.
  ///
  /// Kod alaninda C blogunun agzini ve ayagini liste cizici kendisi
  /// ciziyor (icindeki bloklarin gercek yuksekligini ancak o biliyor).
  /// Boyle olmazsa blok, icine hicbir sey almayan 64 piksellik bos bir
  /// agiz tasiyor ve altindaki blok agzin DISINDA duruyormus gibi
  /// gorunuyordu. Paletteki blok tam C silueti ile ciziliyor.
  final bool cHeadOnly;

  /// Bloğun yazısının hangi dilde çizileceği.
  ///
  /// ZORUNLU, ve bilerek öyle. Bu widget önceden doğrudan `block.label`
  /// okuyordu: modelde `labelEn` vardı, ders içeriğinde çevirisi de
  /// vardı, ama İngilizce seçen çocuk blokların üstünde Türkçe yazı
  /// görüyordu ("dijital ayarla pin 9 çıkış yüksek"). mBlock kursunun
  /// tek amacı çocuğun uygulamada gördüğü bloğu mBlock'ta BİREBİR aynı
  /// yazıyla bulması olduğu için bu, kursun işini bozan bir hataydı.
  ///
  /// Varsayılan bir değer VERİLMİYOR: varsayılan olsaydı yeni bir çağrı
  /// yeri dili geçirmeyi unutur ve hata sessizce geri gelirdi. Böyle
  /// derleyici soruyor.
  final String lang;

  const ScratchBlockWidget({
    super.key,
    required this.block,
    required this.lang,
    this.isPlaced = false,
    this.onTap,
    this.showRemoveIcon = false,
    this.cHeadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _ScratchBlockPainter(
          color: block.color,
          shape: block.shape,
          cHeadOnly: cHeadOnly,
        ),
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: showRemoveIcon ? 16 : 24,
            top: _getTopPadding(),
            bottom: _getBottomPadding(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (block.id == 'green_flag') ...[
                const Icon(
                  Icons.flag,
                  color: Color(0xFF0FBD8C),
                  size: 22,
                ),
                const SizedBox(width: 10),
              ],
              ..._buildLabelContent(),
              if (showRemoveIcon) ...[
                const SizedBox(width: 12),
                const Icon(Icons.close, color: Colors.white, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Parse label and build content with inline boolean inputs
  List<Widget> _buildLabelContent() {
    final widgets = <Widget>[];
    final label = block.labelFor(lang);
    final regex = RegExp(r'<([^>]+)>');
    final matches = regex.allMatches(label);

    if (matches.isEmpty) {
      // TAŞMAYA KARŞI ESNEK.
      //
      // Blok yazısı sabit genişlikte bir satırdaydı. Türkçe etiketler
      // kısa olduğu için sorun görünmüyordu; İngilizce karşılıkları
      // ("set digital pin 9 output as high") dar ekranda 41 piksel
      // taşıyor ve çocuk sarı-siyah taşma şeridini görüyordu.
      // Flexible + softWrap: uzun etiket ikinci satıra iniyor.
      widgets.add(Flexible(
        child: Text(
        label,
        softWrap: true,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          shadows: [
            Shadow(
              offset: Offset(0, 1.5),
              blurRadius: 0,
              color: Colors.black26,
            ),
          ],
        ),
      ),
      ));
      return widgets;
    }

    // Parse and build mixed content
    int lastEnd = 0;
    for (final match in matches) {
      // Add text before this match
      if (match.start > lastEnd) {
        final textBefore = label.substring(lastEnd, match.start);
        if (textBefore.isNotEmpty) {
          widgets.add(Flexible(
            child: Text(
            textBefore,
            softWrap: true,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              shadows: [
                Shadow(
                  offset: Offset(0, 1.5),
                  blurRadius: 0,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          ));
        }
      }

      // Add hexagonal boolean input
      final innerText = match.group(1) ?? '';
      widgets.add(_buildBooleanInput(innerText));

      lastEnd = match.end;
    }

    // Add remaining text after last match
    if (lastEnd < label.length) {
      final textAfter = label.substring(lastEnd);
      if (textAfter.isNotEmpty) {
        widgets.add(Flexible(
          child: Text(
          textAfter,
          softWrap: true,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            shadows: [
              Shadow(
                offset: Offset(0, 1.5),
                blurRadius: 0,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        ));
      }
    }

    return widgets;
  }

  /// Build a hexagonal boolean input slot
  ///
  /// Altıgen yuva da esnek: içindeki metin uzun olduğunda
  /// ("read analog pin (A) 0 / 4") blok satırı taşıyordu.
  Widget _buildBooleanInput(String text) {
    return Flexible(
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomPaint(
        painter: _HexagonPainter(
          color: Colors.white.withValues(alpha: 0.25),
          borderColor: _darkenColor(block.color, 0.25),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            text,
            softWrap: true,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 0,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  double _getTopPadding() {
    switch (block.shape) {
      case ScratchBlockShape.cap:
        return 18;
      case ScratchBlockShape.stack:
        return 20; // Space for notch
      case ScratchBlockShape.cBlock:
        return 20;
      case ScratchBlockShape.reporter:
        return 14;
      case ScratchBlockShape.boolean:
        return 14;
    }
  }

  double _getBottomPadding() {
    switch (block.shape) {
      case ScratchBlockShape.cap:
        return 20; // Space for tab
      case ScratchBlockShape.stack:
        return 20;
      case ScratchBlockShape.cBlock:
        // Yalnizca ust cubuk ciziliyorsa agiz payi gerekmiyor.
        return cHeadOnly ? 20 : 64;
      case ScratchBlockShape.reporter:
        return 14;
      case ScratchBlockShape.boolean:
        return 14;
    }
  }
}

/// GERÇEK SCRATCH - Based on actual MIT Scratch SVG paths
/// SVG Path reference: c 2,0 3,1 4,2 l 4,4 c 1,1 2,2 4,2 h 12 c 2,0 3,-1 4,-2 l 4,-4 c 1,-1 2,-2 4,-2
class _ScratchBlockPainter extends CustomPainter {
  final Color color;
  final ScratchBlockShape shape;

  /// C blogunun yalnizca ust cubugu ciziliyor (bkz. ScratchBlockWidget).
  final bool cHeadOnly;

  /// Boş yuva çizimi: aynı yapboz silueti, ama içi boş.
  ///
  /// Yuvanın da blokla AYNI şekilde olması önemli — çocuk oraya neyin
  /// oturacağını şekilden anlıyor. Düz bir dikdörtgen yuva, yapbozun
  /// öğrettiği şeyi bozuyor.
  final bool ghost;

  // GERÇEK SCRATCH ÖLÇÜLERİ - From actual Scratch SVG paths
  static const double cornerRadius = 4.0;
  static const double notchStartX = 12.0;  // Where notch begins
  static const double curveW = 4.0;  // Width of each curve section
  static const double curveH = 2.0;  // Height of each curve
  static const double diagonal = 4.0; // Diagonal line distance
  static const double middleW = 12.0; // Flat middle section

  // Total notch height = curveH + diagonal + curveH = 2 + 4 + 2 = 8
  static const double totalNotchHeight = 8.0;

  _ScratchBlockPainter({
    required this.color,
    required this.shape,
    this.ghost = false,
    this.cHeadOnly = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ana renk + gradient
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _lightenColor(color, 0.15),
        color,
        _darkenColor(color, 0.05),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    if (ghost) {
      paint.color = color.withValues(alpha: 0.12);
    } else {
      paint.shader = gradient.createShader(rect);
    }

    // Koyu border
    final borderPaint = Paint()
      ..color = ghost
          ? color.withValues(alpha: 0.55)
          : _darkenColor(color, 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ghost ? 2.5 : 2.0
      ..isAntiAlias = true;

    // Gölge (hayalette yok — yuva yüzeyin altında duruyor)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: ghost ? 0.0 : 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    switch (shape) {
      case ScratchBlockShape.cap:
        _drawCapBlock(canvas, size, paint, borderPaint, shadowPaint);
        break;
      case ScratchBlockShape.stack:
        _drawStackBlock(canvas, size, paint, borderPaint, shadowPaint);
        break;
      case ScratchBlockShape.cBlock:
        if (cHeadOnly) {
          _drawStackBlock(canvas, size, paint, borderPaint, shadowPaint);
        } else {
          _drawCBlock(canvas, size, paint, borderPaint, shadowPaint);
        }
        break;
      case ScratchBlockShape.reporter:
        _drawReporterBlock(canvas, size, paint, borderPaint, shadowPaint);
        break;
      case ScratchBlockShape.boolean:
        _drawBooleanBlock(canvas, size, paint, borderPaint, shadowPaint);
        break;
    }
  }

  void _drawCapBlock(Canvas canvas, Size size, Paint paint, Paint borderPaint, Paint shadowPaint) {
    final path = Path();

    // Yuvarlak başlangıç (Hat block style)
    path.moveTo(0, cornerRadius + 12);
    path.arcToPoint(
      Offset(cornerRadius + 12, 0),
      radius: const Radius.circular(cornerRadius + 12),
    );

    path.lineTo(size.width - cornerRadius - 12, 0);

    path.arcToPoint(
      Offset(size.width, cornerRadius + 12),
      radius: const Radius.circular(cornerRadius + 12),
    );

    path.lineTo(size.width, size.height - totalNotchHeight - cornerRadius);

    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height - totalNotchHeight),
      radius: const Radius.circular(cornerRadius),
    );

    // Bottom TAB (protruding connector)
    _drawBottomTab(path, size.width, size.height - totalNotchHeight);

    path.arcToPoint(
      Offset(0, size.height - totalNotchHeight - cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );

    path.close();

    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawStackBlock(Canvas canvas, Size size, Paint paint, Paint borderPaint, Paint shadowPaint) {
    final path = Path();

    path.moveTo(0, totalNotchHeight + cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, totalNotchHeight),
      radius: const Radius.circular(cornerRadius),
    );

    // Top NOTCH (receiving connector)
    _drawTopNotch(path, totalNotchHeight);

    path.lineTo(size.width - cornerRadius, totalNotchHeight);

    path.arcToPoint(
      Offset(size.width, totalNotchHeight + cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );

    path.lineTo(size.width, size.height - totalNotchHeight - cornerRadius);

    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height - totalNotchHeight),
      radius: const Radius.circular(cornerRadius),
    );

    // Bottom TAB
    _drawBottomTab(path, size.width, size.height - totalNotchHeight);

    path.arcToPoint(
      Offset(0, size.height - totalNotchHeight - cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );

    path.close();

    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  /// C blogu (tekrarla / eger) — agiz SOLDAN degil, ICERIDEN acilir.
  ///
  /// Onceki cizimde isirik SAG KENARDAN aliniyordu: blok, sag tarafinda
  /// centik olan bir dikdortgen gibi gorunuyordu; icine blok alan bir C
  /// gibi degil. Cocuk "bu blogun ICI var" fikrini sekilden alamiyordu.
  /// Dogrusu: tam genislikte ust cubuk, solda ince bir sirt, altta ayak.
  void _drawCBlock(Canvas canvas, Size size, Paint paint, Paint borderPaint,
      Paint shadowPaint) {
    const indent = 16.0;    // sol sirtin kalinligi
    const footH = 20.0;     // alt ayak yuksekligi
    final mouthBottom = size.height - totalNotchHeight - footH;
    final mouthTop = mouthBottom - 32.0;

    final path = Path();
    path.moveTo(0, totalNotchHeight + cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, totalNotchHeight),
      radius: const Radius.circular(cornerRadius),
    );
    _drawTopNotch(path, totalNotchHeight);
    path.lineTo(size.width - cornerRadius, totalNotchHeight);
    path.arcToPoint(
      Offset(size.width, totalNotchHeight + cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );

    // Ust cubugun sag kenari, agzin ust hizasina kadar
    path.lineTo(size.width, mouthTop);

    // Agzin ust kenari: sagdan sola, icerideki blogun oturacagi centikle
    _drawInnerNotch(path, indent, mouthTop);
    path.lineTo(indent, mouthTop);

    // Sol sirt asagi
    path.lineTo(indent, mouthBottom);

    // Agzin alt kenari: soldan saga
    path.lineTo(size.width, mouthBottom);

    // Ayak
    path.lineTo(size.width, size.height - totalNotchHeight - cornerRadius);
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height - totalNotchHeight),
      radius: const Radius.circular(cornerRadius),
    );
    _drawBottomTab(path, size.width, size.height - totalNotchHeight);
    path.arcToPoint(
      Offset(0, size.height - totalNotchHeight - cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );
    path.close();

    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  /// Agzin ust kenarindaki centik — icerideki blogun tirnaginin oturdugu
  /// yer. Sagdan sola cizildigi icin yonler ters.
  void _drawInnerNotch(Path path, double left, double y) {
    final x0 = left + notchStartX;
    path.lineTo(x0 + curveW + diagonal + middleW + diagonal + curveW, y);
    path.relativeLineTo(-curveW, curveH);
    path.relativeLineTo(-diagonal, totalNotchHeight - 2 * curveH);
    path.relativeLineTo(-middleW, 0);
    path.relativeLineTo(-diagonal, -(totalNotchHeight - 2 * curveH));
    path.relativeLineTo(-curveW, -curveH);
    path.lineTo(x0, y);
  }


  void _drawReporterBlock(Canvas canvas, Size size, Paint paint, Paint borderPaint, Paint shadowPaint) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );

    canvas.drawRRect(rect.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(rect, borderPaint);
  }

  void _drawBooleanBlock(Canvas canvas, Size size, Paint paint, Paint borderPaint, Paint shadowPaint) {
    final path = Path();
    final cornerSize = size.height / 2;

    path.moveTo(cornerSize, 0);
    path.lineTo(size.width - cornerSize, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - cornerSize, size.height);
    path.lineTo(cornerSize, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  /// GERÇEK SCRATCH NOTCH with smooth curves
  /// SVG: c 2,0 3,1 4,2 l 4,4 c 1,1 2,2 4,2 h 12 c 2,0 3,-1 4,-2 l 4,-4 c 1,-1 2,-2 4,-2
  void _drawTopNotch(Path path, double y) {
    // Line to notch start
    path.lineTo(notchStartX, y);

    // First curve DOWN (right side entering notch)
    // c 2,0 3,1 4,2
    path.cubicTo(
      notchStartX + 2, y,
      notchStartX + 3, y + 1,
      notchStartX + curveW, y + curveH,
    );

    // Diagonal line into notch depth
    // l 4,4
    double x1 = notchStartX + curveW;
    double y1 = y + curveH;
    path.lineTo(x1 + diagonal, y1 + diagonal);

    // Second curve continuing DOWN
    // c 1,1 2,2 4,2
    double x2 = x1 + diagonal;
    double y2 = y1 + diagonal;
    path.cubicTo(
      x2 + 1, y2 + 1,
      x2 + 2, y2 + 2,
      x2 + curveW, y2 + curveH,
    );

    // Flat middle section of notch
    // h 12
    double x3 = x2 + curveW;
    double y3 = y2 + curveH;
    path.lineTo(x3 + middleW, y3);

    // Third curve UP (exiting notch on left)
    // c 2,0 3,-1 4,-2
    double x4 = x3 + middleW;
    path.cubicTo(
      x4 + 2, y3,
      x4 + 3, y3 - 1,
      x4 + curveW, y3 - curveH,
    );

    // Diagonal line up
    // l 4,-4
    double x5 = x4 + curveW;
    double y5 = y3 - curveH;
    path.lineTo(x5 + diagonal, y5 - diagonal);

    // Final curve back to top level
    // c 1,-1 2,-2 4,-2
    double x6 = x5 + diagonal;
    double y6 = y5 - diagonal;
    path.cubicTo(
      x6 + 1, y6 - 1,
      x6 + 2, y6 - 2,
      x6 + curveW, y6 - curveH,
    );
  }

  /// GERÇEK SCRATCH TAB (mirror of notch)
  void _drawBottomTab(Path path, double width, double y) {
    // Calculate total tab width
    final tabWidth = curveW + diagonal + curveW + middleW + curveW + diagonal + curveW;
    final startX = notchStartX;

    // Line to tab start (from right side)
    path.lineTo(startX + tabWidth, y);

    // First curve DOWN (left side of tab)
    // c -2,0 -3,1 -4,2
    path.cubicTo(
      startX + tabWidth - 2, y,
      startX + tabWidth - 3, y + 1,
      startX + tabWidth - curveW, y + curveH,
    );

    // Diagonal
    double x1 = startX + tabWidth - curveW;
    double y1 = y + curveH;
    path.lineTo(x1 - diagonal, y1 + diagonal);

    // Second curve
    double x2 = x1 - diagonal;
    double y2 = y1 + diagonal;
    path.cubicTo(
      x2 - 1, y2 + 1,
      x2 - 2, y2 + 2,
      x2 - curveW, y2 + curveH,
    );

    // Flat middle
    double x3 = x2 - curveW;
    double y3 = y2 + curveH;
    path.lineTo(x3 - middleW, y3);

    // Third curve UP
    double x4 = x3 - middleW;
    path.cubicTo(
      x4 - 2, y3,
      x4 - 3, y3 - 1,
      x4 - curveW, y3 - curveH,
    );

    // Diagonal up
    double x5 = x4 - curveW;
    double y5 = y3 - curveH;
    path.lineTo(x5 - diagonal, y5 - diagonal);

    // Final curve back to top
    double x6 = x5 - diagonal;
    double y6 = y5 - diagonal;
    path.cubicTo(
      x6 - 1, y6 - 1,
      x6 - 2, y6 - 2,
      x6 - curveW, y6 - curveH,
    );

    // Line to left corner
    path.lineTo(cornerRadius, y);
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(_ScratchBlockPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.shape != shape;
  }
}

/// Hexagon painter for boolean input slots
class _HexagonPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _HexagonPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final cornerSize = size.height / 2;

    // Draw hexagon (diamond shape in Scratch)
    path.moveTo(cornerSize, 0);
    path.lineTo(size.width - cornerSize, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - cornerSize, size.height);
    path.lineTo(cornerSize, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    // Fill
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_HexagonPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderColor != borderColor;
  }
}

/// Bir bloğun oturacağı BOŞ YUVA.
///
/// Bloğun kendisiyle aynı yapboz siluetini çiziyor: üstte girinti,
/// altta çıkıntı. Çocuk sürüklerken neyin nereye oturacağını şekilden
/// görüyor — karşılama ekranındaki ilk görev bunun üzerine kurulu.
class ScratchBlockSlot extends StatelessWidget {
  const ScratchBlockSlot({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    this.shape = ScratchBlockShape.stack,
    this.highlighted = false,
  });

  final double width;
  final double height;
  final Color color;
  final ScratchBlockShape shape;

  /// Sürüklenen blok yuvanın üstündeyken.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ScratchBlockPainter(
          color: highlighted ? color : const Color(0xFF9AA3AF),
          shape: shape,
          ghost: true,
        ),
      ),
    );
  }
}
