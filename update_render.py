#!/usr/bin/env python3
# -*- coding: utf-8 -*-

with open('lib/screens/games/left_right_coding_game_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Yeni render kodu - daha kompakt ve her hayvan için özel
new_render = """  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = size / 2;
    final primaryColor = _getPuppetColor();
    final secondaryColor = _getSecondaryColor();

    // Shadow for all puppets
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(center.x, center.y + size.y * 0.45), size.x * 0.35, shadowPaint);

    // Draw based on puppet type with unique features
    switch (puppetType) {
      case PuppetType.fox:
        _drawEnhancedFox(canvas, center, primaryColor, secondaryColor);
        break;
      case PuppetType.lion:
        _drawEnhancedLion(canvas, center, primaryColor, secondaryColor);
        break;
      case PuppetType.crocodile:
        _drawEnhancedCrocodile(canvas, center, primaryColor, secondaryColor);
        break;
      case PuppetType.cat:
        _drawEnhancedCat(canvas, center, primaryColor, secondaryColor);
        break;
      case PuppetType.dog:
        _drawEnhancedDog(canvas, center, primaryColor, secondaryColor);
        break;
    }
  }

  void _drawEnhancedFox(Canvas canvas, Vector2 center, Color primaryColor, Color secondaryColor) {
    final bodyPaint = Paint()..color = primaryColor;
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;

    // Body with white chest
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.05), width: size.x * 0.7, height: size.y * 0.75), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.15), width: size.x * 0.45, height: size.y * 0.55), whitePaint);

    // Head
    canvas.drawCircle(Offset(center.x, center.y - size.y * 0.15), size.x * 0.35, bodyPaint);

    // Pointed ears with white inner
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.25, center.y - size.y * 0.35)..lineTo(center.x - size.x * 0.15, center.y - size.y * 0.5)..lineTo(center.x - size.x * 0.05, center.y - size.y * 0.35)..close(), bodyPaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.25, center.y - size.y * 0.35)..lineTo(center.x + size.x * 0.15, center.y - size.y * 0.5)..lineTo(center.x + size.x * 0.05, center.y - size.y * 0.35)..close(), bodyPaint);
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.22, center.y - size.y * 0.36)..lineTo(center.x - size.x * 0.15, center.y - size.y * 0.45)..lineTo(center.x - size.x * 0.08, center.y - size.y * 0.36)..close(), whitePaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.22, center.y - size.y * 0.36)..lineTo(center.x + size.x * 0.15, center.y - size.y * 0.45)..lineTo(center.x + size.x * 0.08, center.y - size.y * 0.36)..close(), whitePaint);

    // Snout
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.05), width: size.x * 0.25, height: size.y * 0.2), whitePaint);

    // Eyes with highlight
    canvas.drawCircle(Offset(center.x - size.x * 0.15, center.y - size.y * 0.2), size.x * 0.08, whitePaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.15, center.y - size.y * 0.2), size.x * 0.045, blackPaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.13, center.y - size.y * 0.22), size.x * 0.02, whitePaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.15, center.y - size.y * 0.2), size.x * 0.08, whitePaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.15, center.y - size.y * 0.2), size.x * 0.045, blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.17, center.y - size.y * 0.22), size.x * 0.02, whitePaint);

    // Nose & smile
    canvas.drawPath(Path()..moveTo(center.x, center.y - size.y * 0.02)..lineTo(center.x - size.x * 0.04, center.y + size.y * 0.02)..lineTo(center.x + size.x * 0.04, center.y + size.y * 0.02)..close(), blackPaint);
    final smilePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(Path()..moveTo(center.x, center.y + size.y * 0.02)..lineTo(center.x, center.y + size.y * 0.05), smilePaint);
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.1, center.y + size.y * 0.05)..quadraticBezierTo(center.x, center.y + size.y * 0.1, center.x + size.x * 0.1, center.y + size.y * 0.05), smilePaint);
  }

  void _drawEnhancedLion(Canvas canvas, Vector2 center, Color primaryColor, Color secondaryColor) {
    final bodyPaint = Paint()..color = primaryColor;
    final blackPaint = Paint()..color = Colors.black;
    final whitePaint = Paint()..color = Colors.white;

    // Majestic double-layer mane
    final maneOuter = Paint()..color = Colors.orange.shade900;
    final maneInner = Paint()..color = Colors.orange.shade700;
    for (int i = 0; i < 16; i++) {
      final angle = (i * 2 * 3.14159 / 16);
      canvas.drawCircle(Offset(center.x + cos(angle) * size.x * 0.42, center.y - size.y * 0.1 + sin(angle) * size.y * 0.42), size.x * 0.13, maneOuter);
    }
    for (int i = 0; i < 16; i++) {
      final angle = (i * 2 * 3.14159 / 16) + 0.2;
      canvas.drawCircle(Offset(center.x + cos(angle) * size.x * 0.35, center.y - size.y * 0.1 + sin(angle) * size.y * 0.35), size.x * 0.11, maneInner);
    }

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.1), width: size.x * 0.65, height: size.y * 0.7), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.18), width: size.x * 0.4, height: size.y * 0.5), Paint()..color = secondaryColor);

    // Head & muzzle
    canvas.drawCircle(Offset(center.x, center.y - size.y * 0.1), size.x * 0.32, bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y), width: size.x * 0.35, height: size.y * 0.25), Paint()..color = secondaryColor);

    // Eyes with highlights
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.13, center.y - size.y * 0.15), width: size.x * 0.12, height: size.y * 0.1), whitePaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.13, center.y - size.y * 0.15), size.x * 0.05, blackPaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.11, center.y - size.y * 0.17), size.x * 0.02, whitePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.13, center.y - size.y * 0.15), width: size.x * 0.12, height: size.y * 0.1), whitePaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.13, center.y - size.y * 0.15), size.x * 0.05, blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.15, center.y - size.y * 0.17), size.x * 0.02, whitePaint);

    // Nose with nostrils
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.02), width: size.x * 0.12, height: size.y * 0.08), Paint()..color = Colors.brown.shade900);
    canvas.drawCircle(Offset(center.x - size.x * 0.03, center.y + size.y * 0.02), size.x * 0.015, blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.03, center.y + size.y * 0.02), size.x * 0.015, blackPaint);

    // Confident smile
    final smilePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.12, center.y + size.y * 0.08)..quadraticBezierTo(center.x, center.y + size.y * 0.15, center.x + size.x * 0.12, center.y + size.y * 0.08), smilePaint);
  }

  void _drawEnhancedCrocodile(Canvas canvas, Vector2 center, Color primaryColor, Color secondaryColor) {
    final bodyPaint = Paint()..color = primaryColor;
    final blackPaint = Paint()..color = Colors.black;

    // Body with scale texture
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.1), width: size.x * 0.75, height: size.y * 0.7), Radius.circular(size.x * 0.15)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.15), width: size.x * 0.45, height: size.y * 0.55), Radius.circular(size.x * 0.1)), Paint()..color = secondaryColor);

    // Scale lines
    final scalePaint = Paint()..color = primaryColor.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      final y = center.y - size.y * 0.05 + i * size.y * 0.12;
      canvas.drawLine(Offset(center.x - size.x * 0.18, y), Offset(center.x + size.x * 0.18, y), scalePaint);
    }

    // Head & long snout
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.1), width: size.x * 0.55, height: size.y * 0.35), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.25), width: size.x * 0.4, height: size.y * 0.18), Radius.circular(size.x * 0.05)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.23), width: size.x * 0.35, height: size.y * 0.12), Radius.circular(size.x * 0.04)), Paint()..color = secondaryColor);

    // Sharp teeth
    final toothPaint = Paint()..color = Colors.white;
    for (int i = -2; i <= 2; i++) {
      canvas.drawPath(Path()..moveTo(center.x + i * size.x * 0.08, center.y - size.y * 0.3)..lineTo(center.x + i * size.x * 0.08 - size.x * 0.02, center.y - size.y * 0.26)..lineTo(center.x + i * size.x * 0.08 + size.x * 0.02, center.y - size.y * 0.26)..close(), toothPaint);
    }

    // Reptilian eyes
    final eyeBase = Paint()..color = Colors.yellow.shade700;
    canvas.drawCircle(Offset(center.x - size.x * 0.15, center.y - size.y * 0.15), size.x * 0.09, eyeBase);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.15, center.y - size.y * 0.15), width: size.x * 0.03, height: size.y * 0.08), blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.15, center.y - size.y * 0.15), size.x * 0.09, eyeBase);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.15, center.y - size.y * 0.15), width: size.x * 0.03, height: size.y * 0.08), blackPaint);

    // Fierce eye ridges
    final ridgePaint = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.22, center.y - size.y * 0.18)..lineTo(center.x - size.x * 0.08, center.y - size.y * 0.18), ridgePaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.22, center.y - size.y * 0.18)..lineTo(center.x + size.x * 0.08, center.y - size.y * 0.18), ridgePaint);

    // Nostrils
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.1, center.y - size.y * 0.3), width: size.x * 0.03, height: size.y * 0.02), blackPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.1, center.y - size.y * 0.3), width: size.x * 0.03, height: size.y * 0.02), blackPaint);
  }

  void _drawEnhancedCat(Canvas canvas, Vector2 center, Color primaryColor, Color secondaryColor) {
    final bodyPaint = Paint()..color = primaryColor;
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;

    // Curled tail
    final tailPaint = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = size.x * 0.08..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.25, center.y + size.y * 0.3)..quadraticBezierTo(center.x - size.x * 0.4, center.y + size.y * 0.15, center.x - size.x * 0.35, center.y - size.y * 0.05), tailPaint);

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.05), width: size.x * 0.65, height: size.y * 0.75), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.12), width: size.x * 0.4, height: size.y * 0.55), Paint()..color = secondaryColor);

    // Head
    canvas.drawCircle(Offset(center.x, center.y - size.y * 0.15), size.x * 0.35, bodyPaint);

    // Triangular ears with pink inner
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.28, center.y - size.y * 0.32)..lineTo(center.x - size.x * 0.15, center.y - size.y * 0.48)..lineTo(center.x - size.x * 0.02, center.y - size.y * 0.32)..close(), bodyPaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.28, center.y - size.y * 0.32)..lineTo(center.x + size.x * 0.15, center.y - size.y * 0.48)..lineTo(center.x + size.x * 0.02, center.y - size.y * 0.32)..close(), bodyPaint);
    final pinkPaint = Paint()..color = Colors.pink.shade200;
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.24, center.y - size.y * 0.33)..lineTo(center.x - size.x * 0.15, center.y - size.y * 0.43)..lineTo(center.x - size.x * 0.06, center.y - size.y * 0.33)..close(), pinkPaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.24, center.y - size.y * 0.33)..lineTo(center.x + size.x * 0.15, center.y - size.y * 0.43)..lineTo(center.x + size.x * 0.06, center.y - size.y * 0.33)..close(), pinkPaint);

    // Fluffy cheeks
    canvas.drawCircle(Offset(center.x - size.x * 0.22, center.y - size.y * 0.08), size.x * 0.15, Paint()..color = secondaryColor);
    canvas.drawCircle(Offset(center.x + size.x * 0.22, center.y - size.y * 0.08), size.x * 0.15, Paint()..color = secondaryColor);

    // Big anime eyes
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.13, center.y - size.y * 0.18), width: size.x * 0.13, height: size.y * 0.15), whitePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.13, center.y - size.y * 0.17), width: size.x * 0.06, height: size.y * 0.1), blackPaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.11, center.y - size.y * 0.2), size.x * 0.025, whitePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.13, center.y - size.y * 0.18), width: size.x * 0.13, height: size.y * 0.15), whitePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.13, center.y - size.y * 0.17), width: size.x * 0.06, height: size.y * 0.1), blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.15, center.y - size.y * 0.2), size.x * 0.025, whitePaint);

    // Pink nose
    canvas.drawPath(Path()..moveTo(center.x, center.y - size.y * 0.05)..lineTo(center.x - size.x * 0.03, center.y - size.y * 0.08)..lineTo(center.x + size.x * 0.03, center.y - size.y * 0.08)..close(), Paint()..color = Colors.pink.shade300);

    // Whiskers
    final whiskerPaint = Paint()..color = Colors.black.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawLine(Offset(center.x - size.x * 0.22, center.y - size.y * 0.08), Offset(center.x - size.x * 0.38, center.y - size.y * 0.12), whiskerPaint);
    canvas.drawLine(Offset(center.x - size.x * 0.22, center.y - size.y * 0.05), Offset(center.x - size.x * 0.4, center.y - size.y * 0.05), whiskerPaint);
    canvas.drawLine(Offset(center.x - size.x * 0.22, center.y - size.y * 0.02), Offset(center.x - size.x * 0.38, center.y + size.y * 0.02), whiskerPaint);
    canvas.drawLine(Offset(center.x + size.x * 0.22, center.y - size.y * 0.08), Offset(center.x + size.x * 0.38, center.y - size.y * 0.12), whiskerPaint);
    canvas.drawLine(Offset(center.x + size.x * 0.22, center.y - size.y * 0.05), Offset(center.x + size.x * 0.4, center.y - size.y * 0.05), whiskerPaint);
    canvas.drawLine(Offset(center.x + size.x * 0.22, center.y - size.y * 0.02), Offset(center.x + size.x * 0.38, center.y + size.y * 0.02), whiskerPaint);

    // Cute smile
    final smilePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(Path()..moveTo(center.x, center.y - size.y * 0.05)..lineTo(center.x, center.y - size.y * 0.01), smilePaint);
    canvas.drawPath(Path()..moveTo(center.x, center.y - size.y * 0.01)..quadraticBezierTo(center.x - size.x * 0.05, center.y + size.y * 0.02, center.x - size.x * 0.08, center.y + size.y * 0.01), smilePaint);
    canvas.drawPath(Path()..moveTo(center.x, center.y - size.y * 0.01)..quadraticBezierTo(center.x + size.x * 0.05, center.y + size.y * 0.02, center.x + size.x * 0.08, center.y + size.y * 0.01), smilePaint);
  }

  void _drawEnhancedDog(Canvas canvas, Vector2 center, Color primaryColor, Color secondaryColor) {
    final bodyPaint = Paint()..color = primaryColor;
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;

    // Wagging tail
    final tailPaint = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = size.x * 0.1..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.28, center.y + size.y * 0.25)..quadraticBezierTo(center.x - size.x * 0.45, center.y + size.y * 0.1, center.x - size.x * 0.35, center.y - size.y * 0.1), tailPaint);

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.05), width: size.x * 0.7, height: size.y * 0.75), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.15), width: size.x * 0.45, height: size.y * 0.6), Paint()..color = secondaryColor);

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.12), width: size.x * 0.55, height: size.y * 0.5), bodyPaint);

    // Floppy ears
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.25, center.y - size.y * 0.3)..quadraticBezierTo(center.x - size.x * 0.35, center.y - size.y * 0.2, center.x - size.x * 0.3, center.y - size.y * 0.05)..quadraticBezierTo(center.x - size.x * 0.2, center.y - size.y * 0.1, center.x - size.x * 0.15, center.y - size.y * 0.25)..close(), bodyPaint);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.25, center.y - size.y * 0.3)..quadraticBezierTo(center.x + size.x * 0.35, center.y - size.y * 0.2, center.x + size.x * 0.3, center.y - size.y * 0.05)..quadraticBezierTo(center.x + size.x * 0.2, center.y - size.y * 0.1, center.x + size.x * 0.15, center.y - size.y * 0.25)..close(), bodyPaint);
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.23, center.y - size.y * 0.28)..quadraticBezierTo(center.x - size.x * 0.3, center.y - size.y * 0.2, center.x - size.x * 0.27, center.y - size.y * 0.1)..lineTo(center.x - size.x * 0.18, center.y - size.y * 0.25)..close(), Paint()..color = secondaryColor);
    canvas.drawPath(Path()..moveTo(center.x + size.x * 0.23, center.y - size.y * 0.28)..quadraticBezierTo(center.x + size.x * 0.3, center.y - size.y * 0.2, center.x + size.x * 0.27, center.y - size.y * 0.1)..lineTo(center.x + size.x * 0.18, center.y - size.y * 0.25)..close(), Paint()..color = secondaryColor);

    // Snout
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y - size.y * 0.02), width: size.x * 0.3, height: size.y * 0.25), Paint()..color = secondaryColor);

    // Happy eyes
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x - size.x * 0.14, center.y - size.y * 0.18), width: size.x * 0.12, height: size.y * 0.13), whitePaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.14, center.y - size.y * 0.17), size.x * 0.05, blackPaint);
    canvas.drawCircle(Offset(center.x - size.x * 0.12, center.y - size.y * 0.19), size.x * 0.025, whitePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x + size.x * 0.14, center.y - size.y * 0.18), width: size.x * 0.12, height: size.y * 0.13), whitePaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.14, center.y - size.y * 0.17), size.x * 0.05, blackPaint);
    canvas.drawCircle(Offset(center.x + size.x * 0.16, center.y - size.y * 0.19), size.x * 0.025, whitePaint);

    // Big nose & pink tongue
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.03), width: size.x * 0.1, height: size.y * 0.07), blackPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.x, center.y + size.y * 0.12), width: size.x * 0.12, height: size.y * 0.1), Paint()..color = Colors.pink.shade400);

    // Big happy smile
    final smilePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(Path()..moveTo(center.x, center.y + size.y * 0.03)..lineTo(center.x, center.y + size.y * 0.08), smilePaint);
    canvas.drawPath(Path()..moveTo(center.x - size.x * 0.15, center.y + size.y * 0.08)..quadraticBezierTo(center.x, center.y + size.y * 0.18, center.x + size.x * 0.15, center.y + size.y * 0.08), smilePaint);
  }
"""

# İlk 1295 satır + yeni kod + 1428'den sonrası
new_lines = lines[:1295] + [new_render + '\n'] + lines[1427:]

# Dosyayı yaz
with open('lib/screens/games/left_right_coding_game_screen.dart', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print('OK: Kukla tasarımı başarıyla güncellendi!')
print(f'✨ Yeni satır sayısı: {len(new_lines)}')
print('📝 Her hayvan için özel render metodları eklendi:')
print('  🦊 Tilki: Sivri kulaklar, beyaz göğüs, parlak gözler')
print('  🦁 Aslan: Çift katmanlı yele, güçlü yüz')
print('  🐊 Timsah: Uzun ağız, dişler, sürüngen gözleri')
print('  🐱 Kedi: Üçgen kulaklar, bıyıklar, anime gözler')
print('  🐶 Köpek: Sarkık kulaklar, dil, mutlu gülümseme')
