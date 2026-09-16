import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'mascot_mood.dart';

/// Maskotun YÜZÜ — gövdeden bağımsız.
///
/// Uygulamada beş farklı karakter var (bkz. [MascotSpecies]) ama hepsi
/// AYNI yüzü taşıyor. Sebebi şu: bir karakteri tanıdık kılan şey siluet
/// değil BAKIŞ. Çocuk Puf'tan Mia'ya geçtiğinde başka bir uygulamaya
/// girmiş gibi hissetmemeli; aynı arkadaş, farklı kılık.
///
/// Ruh hâllerinin taşındığı yer de burası. Gövde neşeyi taşımıyor —
/// kaşlar ve ağız taşıyor.
class MascotFace {
  const MascotFace._();

  /// Koyu zemine (Bit'in vizörü gibi) çizerken kullanılan açık mürekkep.
  static const Color lightInk = Color(0xFFEAF0FF);
  static const Color ink = Color(0xFF1F2430);

  /// [c] yüzün merkezi, [r] yüz yarıçapı, [blink] 0 açık → 1 kapalı.
  static void paint(
    Canvas canvas,
    Offset c,
    double r, {
    required MascotMood mood,
    required double blink,
    Color inkColor = ink,
  }) {
    final eyeDx = r * 0.38;
    final eyeY = c.dy - r * 0.08;

    // --- gözler ------------------------------------------------------
    // Mutluyken gözler yukarı kıvrık iki yay (kapalı gülen göz).
    if (mood == MascotMood.happy || mood == MascotMood.cheering) {
      final arc = Paint()
        ..color = inkColor
        ..strokeWidth = r * 0.13
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (final dir in [-1.0, 1.0]) {
        final rect = Rect.fromCenter(
          center: Offset(c.dx + dir * eyeDx, eyeY + r * 0.06),
          width: r * 0.42,
          height: r * 0.34,
        );
        canvas.drawArc(rect, math.pi, math.pi, false, arc);
      }
    } else {
      final open = (1 - blink).clamp(0.08, 1.0);
      final big = mood == MascotMood.curious ? 1.18 : 1.0;
      for (final dir in [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx + dir * eyeDx, eyeY),
            width: r * 0.30 * big,
            height: r * 0.34 * big * open,
          ),
          Paint()..color = inkColor,
        );
        // Küçük parlama — gözü canlı yapan tek detay.
        if (open > 0.5) {
          canvas.drawCircle(
            Offset(c.dx + dir * eyeDx + r * 0.07, eyeY - r * 0.08),
            r * 0.055 * big,
            Paint()..color = Colors.white.withValues(alpha: 0.9),
          );
        }
      }
    }

    // --- kaşlar ------------------------------------------------------
    // Endişe/soru kaşlarda taşınıyor. idle ve happy hâllerinde kaş
    // ÇİZİLMİYOR: sakin yüz, nötr yüzdür.
    //
    // İŞARET KURALI — burada bir kez hata yapıldı, tekrar yapılmasın:
    // tuvalde y aşağı doğru arttığı için `rotate` POZİTİF açıda saat
    // yönünde döndürür. (-half,0)-(half,0) çizgisini +θ ile döndürmek
    // SAĞ ucu AŞAĞI indirir. İlk sürümde açılar terstir ve "düşünüyor"
    // ile "cesaret veriyor" yüzleri ekranda KIZGIN okunuyordu.
    //
    // Kural: içteki uç aşağı = öfke. Maskotun hiçbir hâlinde içteki uç
    // aşağı inmez.
    final browShape = switch (mood) {
      MascotMood.thinking => (0.0, 0.0, 0.0, -r * 0.13),
      MascotMood.curious => (0.0, 0.0, -r * 0.12, -r * 0.12),
      MascotMood.encouraging => (-0.20, 0.20, -r * 0.04, -r * 0.04),
      _ => null,
    };
    if (browShape != null) {
      final brow = Paint()
        ..color = inkColor
        ..strokeWidth = r * 0.10
        ..strokeCap = StrokeCap.round;
      final (leftA, rightA, leftLift, rightLift) = browShape;
      for (final (dir, angle, lift) in [
        (-1.0, leftA, leftLift),
        (1.0, rightA, rightLift),
      ]) {
        final bx = c.dx + dir * eyeDx;
        final by = eyeY - r * 0.40 + lift;
        final half = r * 0.19;
        canvas.save();
        canvas.translate(bx, by);
        canvas.rotate(angle);
        canvas.drawLine(Offset(-half, 0), Offset(half, 0), brow);
        canvas.restore();
      }
    }

    // --- ağız --------------------------------------------------------
    // Neşenin taşıyıcısı. Her hâlde çiziliyor ve hiçbir hâlde aşağı
    // kıvrılmıyor — maskotun somurtan bir yüzü yok.
    final mouthPaint = Paint()
      ..color = inkColor
      ..strokeWidth = r * 0.11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final mouthY = c.dy + r * 0.36;

    switch (mood) {
      case MascotMood.cheering:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx, mouthY - r * 0.02),
            width: r * 0.52,
            height: r * 0.46,
          ),
          0,
          math.pi,
          true,
          Paint()..color = inkColor,
        );
      case MascotMood.happy:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx, mouthY - r * 0.10),
            width: r * 0.52,
            height: r * 0.40,
          ),
          0.12,
          math.pi - 0.24,
          false,
          mouthPaint,
        );
      case MascotMood.encouraging:
        // Küçük ama YUKARI kıvrık: "olur, tekrar deneyelim".
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx, mouthY - r * 0.06),
            width: r * 0.30,
            height: r * 0.22,
          ),
          0.2,
          math.pi - 0.4,
          false,
          mouthPaint,
        );
      case MascotMood.thinking:
        canvas.drawLine(
          Offset(c.dx - r * 0.04, mouthY),
          Offset(c.dx + r * 0.18, mouthY - r * 0.03),
          mouthPaint,
        );
      case MascotMood.curious:
        canvas.drawCircle(
          Offset(c.dx, mouthY),
          r * 0.10,
          Paint()
            ..color = inkColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.09,
        );
      case MascotMood.idle:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx, mouthY - r * 0.08),
            width: r * 0.34,
            height: r * 0.26,
          ),
          0.25,
          math.pi - 0.5,
          false,
          mouthPaint,
        );
    }
  }
}
