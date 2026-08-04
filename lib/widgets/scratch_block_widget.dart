import 'package:flutter/material.dart';
import '../courses/models/interactive_lesson_model.dart';

/// MIT Scratch benzeri GERÇEK yapboz blokları - Based on actual Scratch SVG paths
class ScratchBlockWidget extends StatelessWidget {
  final ScratchBlock block;
  final bool isPlaced;
  final VoidCallback? onTap;
  final bool showRemoveIcon;

  const ScratchBlockWidget({
    super.key,
    required this.block,
    this.isPlaced = false,
    this.onTap,
    this.showRemoveIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _ScratchBlockPainter(
          color: block.color,
          shape: block.shape,
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
    final regex = RegExp(r'<([^>]+)>');
    final matches = regex.allMatches(block.label);

    if (matches.isEmpty) {
      // No special inputs, just show text
      widgets.add(Text(
        block.label,
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
      ));
      return widgets;
    }

    // Parse and build mixed content
    int lastEnd = 0;
    for (final match in matches) {
      // Add text before this match
      if (match.start > lastEnd) {
        final textBefore = block.label.substring(lastEnd, match.start);
        if (textBefore.isNotEmpty) {
          widgets.add(Text(
            textBefore,
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
          ));
        }
      }

      // Add hexagonal boolean input
      final innerText = match.group(1) ?? '';
      widgets.add(_buildBooleanInput(innerText));

      lastEnd = match.end;
    }

    // Add remaining text after last match
    if (lastEnd < block.label.length) {
      final textAfter = block.label.substring(lastEnd);
      if (textAfter.isNotEmpty) {
        widgets.add(Text(
          textAfter,
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
        ));
      }
    }

    return widgets;
  }

  /// Build a hexagonal boolean input slot
  Widget _buildBooleanInput(String text) {
    return Container(
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
        return 64; // Kompakt C için daha az padding
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

  // GERÇEK SCRATCH ÖLÇÜLERİ - From actual Scratch SVG paths
  static const double cornerRadius = 4.0;
  static const double notchStartX = 12.0;  // Where notch begins
  static const double curveW = 4.0;  // Width of each curve section
  static const double curveH = 2.0;  // Height of each curve
  static const double diagonal = 4.0; // Diagonal line distance
  static const double middleW = 12.0; // Flat middle section

  // Total notch height = curveH + diagonal + curveH = 2 + 4 + 2 = 8
  static const double totalNotchHeight = 8.0;

  _ScratchBlockPainter({required this.color, required this.shape});

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
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Koyu border
    final borderPaint = Paint()
      ..color = _darkenColor(color, 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    // Gölge
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    switch (shape) {
      case ScratchBlockShape.cap:
        _drawCapBlock(canvas, size, paint, borderPaint, shadowPaint);
        break;
      case ScratchBlockShape.stack:
        _drawStackBlock(canvas, size, paint, borderPaint, shadowPaint);
        break;
      case ScratchBlockShape.cBlock:
        _drawCBlock(canvas, size, paint, borderPaint, shadowPaint);
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

  void _drawCBlock(Canvas canvas, Size size, Paint paint, Paint borderPaint, Paint shadowPaint) {
    final path = Path();
    const innerHeight = 32.0; // İç boşluk yüksekliği
    const indent = 10.0; // Girinti derinliği

    // Üst sol köşe
    path.moveTo(0, totalNotchHeight + cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, totalNotchHeight),
      radius: const Radius.circular(cornerRadius),
    );

    // Üst notch
    _drawTopNotch(path, totalNotchHeight);

    // Üst sağ köşe
    path.lineTo(size.width - cornerRadius, totalNotchHeight);
    path.arcToPoint(
      Offset(size.width, totalNotchHeight + cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );

    // Sağ kenar yukarı
    path.lineTo(size.width, totalNotchHeight + 12);

    // İç boşluk başlangıcı - sağ üst
    path.lineTo(size.width - indent, totalNotchHeight + 12);
    path.lineTo(size.width - indent, totalNotchHeight + 12 + innerHeight);

    // İç boşluk bitişi - sağ alt
    path.lineTo(size.width, totalNotchHeight + 12 + innerHeight);

    // Sağ kenar aşağı
    path.lineTo(size.width, totalNotchHeight + 12 + innerHeight + 8);

    // Alt sağ köşe
    path.arcToPoint(
      Offset(size.width - cornerRadius, totalNotchHeight + 12 + innerHeight + 8 + cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );

    // Alt tab
    _drawBottomTab(path, size.width, totalNotchHeight + 12 + innerHeight + 8 + cornerRadius);

    // Alt sol köşe
    path.arcToPoint(
      Offset(0, totalNotchHeight + 12 + innerHeight + 8),
      radius: const Radius.circular(cornerRadius),
    );

    path.close();

    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
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
