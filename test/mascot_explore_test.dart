@Tags(['shots'])
library;

// Devi icin 3D gorunum denemeleri — TEST DEGIL, ARAC.
//
//     flutter test --run-skipped --tags shots test/mascot_explore_test.dart
//
// Cikti: outputs/mascot/denemeler.png
//
// Dort yon ayni siluetle ciziliyor ki fark ISIK ve HACIMDEN gelsin,
// karakterin degismesinden degil. Hepsi CustomPainter: ruh halleri,
// goz kirpma, nefes ve MascotAnchors (sapka/gozluk/ayakkabi) oldugu
// gibi calismaya devam eder.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

enum Look {
  flat,   // A - bugunku
  soft,   // B - yumusak hacim
  clay,   // C - kil / oyuncak
  gloss,  // D - parlak vinil
}

const _ink = Color(0xFF1F2430);

Color _dark(Color c, double t) => Color.lerp(c, const Color(0xFF0B1220), t)!;
Color _light(Color c, double t) => Color.lerp(c, Colors.white, t)!;

class DeviLookPainter extends CustomPainter {
  DeviLookPainter(this.look, this.color);
  final Look look;
  final Color color;

  /// Govde ve kafa icin dolgu. Duz renk yerine kureyi ele veren bir
  /// gradyan: isik sol ustten, alt kenarda yansima.
  Paint _volume(Offset c, double r) {
    switch (look) {
      case Look.flat:
        return Paint()..color = color;
      case Look.soft:
        return Paint()
          ..shader = ui.Gradient.radial(
            Offset(c.dx - r * 0.32, c.dy - r * 0.36), r * 1.45,
            [_light(color, 0.30), color, _dark(color, 0.22)],
            [0.0, 0.55, 1.0],
          );
      case Look.clay:
        // Mat kil: gecisler genis ve yumusak, parlama yok.
        return Paint()
          ..shader = ui.Gradient.radial(
            Offset(c.dx - r * 0.28, c.dy - r * 0.42), r * 1.7,
            [_light(color, 0.22), color, _dark(color, 0.30)],
            [0.0, 0.5, 1.0],
          );
      case Look.gloss:
        // Parlak vinil: koyudan aciga sert gecis, ustte guclu parlama.
        return Paint()
          ..shader = ui.Gradient.linear(
            Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r),
            [_light(color, 0.42), color, _dark(color, 0.34)],
            [0.0, 0.45, 1.0],
          );
    }
  }

  /// Ust kenardaki ince isik seridi — sekli havada durduran sey.
  void _rim(Canvas canvas, Offset c, double r) {
    if (look == Look.flat) return;
    final a = look == Look.clay ? 0.22 : 0.38;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.94),
      math.pi * 1.08, math.pi * 0.62, false,
      Paint()
        ..color = Colors.white.withValues(alpha: a)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.075
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    final headR = w * 0.34;
    final headC = Offset(cx, w * 0.46);
    final bodyTop = headC.dy + headR * 0.72;
    final bodyC = Offset(cx, bodyTop + w * 0.17);

    // --- zemin golgesi ------------------------------------------------
    // Duz surumde tek duz oval; digerlerinde yumusak, karaktere yakin
    // yerde koyu: temas golgesi cismi yere oturtuyor.
    if (look == Look.flat) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, w * 0.935),
            width: w * 0.52, height: w * 0.075),
        Paint()..color = Colors.black.withValues(alpha: 0.10),
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, w * 0.94),
            width: w * 0.58, height: w * 0.10),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.030),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, w * 0.932),
            width: w * 0.34, height: w * 0.055),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.20)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.014),
      );
    }

    // --- antenler ------------------------------------------------------
    final antenna = Paint()
      ..color = look == Look.flat ? color : _dark(color, 0.10)
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final dir in [-1.0, 1.0]) {
      final baseX = cx + dir * headR * 0.46;
      final baseY = headC.dy - headR * 0.88;
      final tipX = cx + dir * headR * 0.78;
      final tipY = baseY - w * 0.14;
      canvas.drawPath(
        Path()
          ..moveTo(baseX, baseY)
          ..quadraticBezierTo(cx + dir * headR * 0.80, baseY - w * 0.04,
              tipX, tipY),
        antenna,
      );
      final tip = Offset(tipX, tipY);
      const ballR = 0.055;
      canvas.drawCircle(tip, w * ballR, _volume(tip, w * ballR));
      if (look != Look.flat) {
        canvas.drawCircle(
          Offset(tip.dx - w * 0.018, tip.dy - w * 0.018),
          w * 0.016,
          Paint()..color = Colors.white.withValues(alpha: 0.55),
        );
      }
    }

    // --- ayaklar (govdenin arkasinda) ------------------------------------
    for (final dir in [-1.0, 1.0]) {
      final f = Offset(cx + dir * w * 0.135, w * 0.90);
      canvas.drawOval(
        Rect.fromCenter(center: f, width: w * 0.16, height: w * 0.085),
        look == Look.flat
            ? (Paint()..color = _dark(color, 0.12))
            : (Paint()
              ..shader = ui.Gradient.linear(
                Offset(f.dx, f.dy - w * 0.043),
                Offset(f.dx, f.dy + w * 0.043),
                [_dark(color, 0.04), _dark(color, 0.30)],
              )),
      );
    }

    // --- kollar -----------------------------------------------------------
    final armPaint = Paint()
      ..color = look == Look.flat ? color : _dark(color, 0.06)
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round;
    for (final dir in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(cx + dir * w * 0.25, bodyTop + w * 0.08),
        Offset(cx + dir * w * 0.37, bodyTop + w * 0.22),
        armPaint,
      );
    }

    // --- govde ------------------------------------------------------------
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: bodyC, width: w * 0.52, height: w * 0.40),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(bodyRect, _volume(bodyC, w * 0.30));

    // Govdenin ust kismi, kafanin altinda kaliyor: ince bir kapali
    // golge (ambient occlusion) ikisini ayni sahneye koyan sey.
    if (look != Look.flat) {
      canvas.save();
      canvas.clipRRect(bodyRect);
      canvas.drawCircle(
        headC, headR * 1.16,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.22)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.035),
      );
      canvas.restore();
    }

    // Gogus ekrani
    final chest = Rect.fromCenter(
      center: Offset(cx, bodyTop + w * 0.15),
      width: w * 0.22, height: w * 0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(chest, Radius.circular(w * 0.045)),
      look == Look.flat
          ? (Paint()..color = Colors.white.withValues(alpha: 0.85))
          : (Paint()
            ..shader = ui.Gradient.linear(
              chest.topCenter, chest.bottomCenter,
              [Colors.white, const Color(0xFFDCE4F2)],
            )),
    );

    // --- kafa --------------------------------------------------------------
    canvas.drawCircle(headC, headR, _volume(headC, headR));
    _rim(canvas, headC, headR);

    final faceR = headR * 0.82;
    final faceC = Offset(headC.dx, headC.dy + headR * 0.03);
    canvas.drawCircle(
      faceC, faceR,
      look == Look.flat
          ? (Paint()..color = const Color(0xFFF7FAFF))
          // Yuz PARLAK kalmali. Ilk denemede yuze de govdeyle ayni
          // gucte gradyan ve kafanin golgesi konmustu; kucuk boyutta
          // yuz grilesip karakter kirli gorunuyordu.
          : (Paint()
            ..shader = ui.Gradient.radial(
              Offset(faceC.dx - faceR * 0.3, faceC.dy - faceR * 0.35),
              faceR * 1.6,
              [Colors.white, const Color(0xFFF4F7FC)],
            )),
    );
    // Yuzun ust kenarinda kafanin dusurdugu ince golge — cok hafif,
    // yoksa yuz kirli gorunuyor.
    if (look != Look.flat) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: faceC, radius: faceR)));
      canvas.drawCircle(
        Offset(faceC.dx, faceC.dy - faceR * 0.92), faceR * 0.85,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.055)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, faceR * 0.14),
      );
      canvas.restore();
    }

    _face(canvas, faceC, faceR);

    // Parlak surumde kafanin ustunde tek buyuk parlama.
    if (look == Look.gloss) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: headC, radius: headR)));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(headC.dx - headR * 0.34, headC.dy - headR * 0.60),
          width: headR * 0.62, height: headR * 0.34),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, headR * 0.06),
      );
      canvas.restore();
    }
  }

  void _face(Canvas canvas, Offset c, double r) {
    final eyeDx = r * 0.38;
    final eyeY = c.dy - r * 0.08;
    for (final dir in [-1.0, 1.0]) {
      final e = Offset(c.dx + dir * eyeDx, eyeY);
      canvas.drawOval(
        Rect.fromCenter(center: e, width: r * 0.30, height: r * 0.34),
        Paint()..color = _ink,
      );
      canvas.drawCircle(
        Offset(e.dx + r * 0.07, e.dy - r * 0.08),
        r * 0.055,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
    // Gulen agiz
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.30),
        width: r * 0.52, height: r * 0.40),
      0.15, math.pi - 0.30, false,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant DeviLookPainter old) =>
      old.look != look || old.color != color;
}

const _labels = {
  Look.flat: 'A — bugünkü Devi',
  Look.soft: 'B — yumuşak hacim',
  Look.clay: 'C — kil / oyuncak',
  Look.gloss: 'D — parlak vinil',
};

Future<void> _loadFonts() async {
  for (final w in ['400', '600', '700', '800']) {
    final f = File('assets/fonts/Nunito-$w.ttf');
    if (f.existsSync()) {
      await (FontLoader('Nunito')
            ..addFont(Future.value(f.readAsBytesSync().buffer.asByteData())))
          .load();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  testWidgets('devi 3d denemeleri', (tester) async {
    // Karakter kare bir kutuya sigmiyor: govde ve ayaklar genisligin
    // 1.05 katina kadar iniyor. Kutuyu buna gore uzatiyoruz.
    const cell = 340.0;
    const tileH = cell * 1.10 + 34 + 100;
    const sheetW = cell * 2 + 90;
    const sheetH = tileH * 2 + 130;

    tester.view.physicalSize = const Size(sheetW * 2, sheetH * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    const color = Color(0xFF6C3CE0);

    Widget tile(Look look) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: cell,
              height: cell * 1.10,
              child: CustomPaint(painter: DeviLookPainter(look, color)),
            ),
            const SizedBox(height: 6),
            Text(_labels[look]!,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF303648))),
            const SizedBox(height: 8),
            // Ayni gorunum UYGULAMADAKI GERCEK BOYUTTA. 3B golgeleme
            // kucukken camura donebiliyor; karar bu satira bakilarak
            // verilmeli.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final s in [40.0, 56.0, 80.0])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: SizedBox(
                      width: s,
                      height: s * 1.10,
                      child: CustomPaint(painter: DeviLookPainter(look, color)),
                    ),
                  ),
              ],
            ),
          ],
        );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(sheetW, sheetH)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: sheetW,
              height: sheetH,
              color: const Color(0xFFF3F5FA),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [tile(Look.flat), tile(Look.soft)],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [tile(Look.clay), tile(Look.gloss)],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // toImage/toByteData gercek bir olay dongusu istiyor; runAsync
    // olmadan test asili kaliyor.
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      Directory('outputs/mascot').createSync(recursive: true);
      File('outputs/mascot/denemeler.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
