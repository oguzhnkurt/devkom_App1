@Tags(['shots'])
library;

// Devi icin FARKLI KARAKTER denemeleri — TEST DEGIL, ARAC.
//
//     flutter test --run-skipped --tags shots test/mascot_characters_test.dart
//
// Cikti: outputs/mascot/karakterler.png
//
// Hepsi ayni cizim sistemiyle (CustomPainter) ve ayni kil golgelemesiyle
// ciziliyor ki fark SILUETTEN gelsin. Hepsi MascotAnchors sozlesmesine
// uyuyor: kafanin tepesi (sapka), goz hizasi (gozluk), ayak hizasi
// (ayakkabi) ayni yerlerde — yani magaza sistemi degismeden calisir.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _ink = Color(0xFF1F2430);
const _brand = Color(0xFF6C3CE0);

Color _dark(Color c, double t) => Color.lerp(c, const Color(0xFF0B1220), t)!;
Color _light(Color c, double t) => Color.lerp(c, Colors.white, t)!;

/// Kil hissi veren dolgu: isik sol ustten, alt kenarda koyulasma.
Paint _clay(Offset c, double r, Color color) => Paint()
  ..shader = ui.Gradient.radial(
    Offset(c.dx - r * 0.28, c.dy - r * 0.42), r * 1.7,
    [_light(color, 0.24), color, _dark(color, 0.30)],
    [0.0, 0.5, 1.0],
  );

void _groundShadow(Canvas canvas, double w, {double y = 0.94, double s = 1}) {
  canvas.drawOval(
    Rect.fromCenter(center: Offset(w / 2, w * y),
        width: w * 0.58 * s, height: w * 0.10),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.030),
  );
}

/// Iki yuvarlak goz + parlama. Her karakterde ayni goz: tanidiklik
/// silueten degil, BAKISTAN geliyor.
void _eyes(Canvas canvas, Offset c, double r, {double dx = 0.38}) {
  for (final dir in [-1.0, 1.0]) {
    final e = Offset(c.dx + dir * r * dx, c.dy);
    canvas.drawOval(
      Rect.fromCenter(center: e, width: r * 0.30, height: r * 0.36),
      Paint()..color = _ink,
    );
    canvas.drawCircle(Offset(e.dx + r * 0.07, e.dy - r * 0.09), r * 0.055,
        Paint()..color = Colors.white.withValues(alpha: 0.92));
  }
}

void _smile(Canvas canvas, Offset c, double r, {double w = 0.52}) {
  canvas.drawArc(
    Rect.fromCenter(center: c, width: r * w, height: r * 0.40),
    0.15, math.pi - 0.30, false,
    Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.10
      ..strokeCap = StrokeCap.round,
  );
}

// ---------------------------------------------------------------------------

/// 1 — BIT: kucuk robot. Yuvarlatilmis kare kafa, tek genis vizor,
/// tepede tek anten. Siluet 40 pikselde bile "robot" diyor.
class BitPainter extends CustomPainter {
  const BitPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    _groundShadow(canvas, w);

    // anten
    final tip = Offset(cx, w * 0.09);
    canvas.drawLine(Offset(cx, w * 0.17), tip,
        Paint()
          ..color = _dark(_brand, 0.10)
          ..strokeWidth = w * 0.030
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(tip, w * 0.048, _clay(tip, w * 0.048, const Color(0xFFFFC24B)));

    // govde
    final bodyC = Offset(cx, w * 0.755);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: bodyC, width: w * 0.50, height: w * 0.34),
      Radius.circular(w * 0.14));
    canvas.drawRRect(body, _clay(bodyC, w * 0.28, _brand));

    // kollar
    final arm = Paint()
      ..color = _dark(_brand, 0.06)
      ..strokeWidth = w * 0.070
      ..strokeCap = StrokeCap.round;
    for (final dir in [-1.0, 1.0]) {
      canvas.drawLine(Offset(cx + dir * w * 0.24, w * 0.70),
          Offset(cx + dir * w * 0.36, w * 0.82), arm);
    }
    // ayaklar
    for (final dir in [-1.0, 1.0]) {
      final f = Offset(cx + dir * w * 0.135, w * 0.90);
      canvas.drawOval(
        Rect.fromCenter(center: f, width: w * 0.17, height: w * 0.09),
        _clay(f, w * 0.09, _dark(_brand, 0.18)));
    }

    // kafa
    final headC = Offset(cx, w * 0.44);
    final head = RRect.fromRectAndRadius(
      Rect.fromCenter(center: headC, width: w * 0.66, height: w * 0.58),
      Radius.circular(w * 0.22));
    canvas.drawRRect(head, _clay(headC, w * 0.34, _brand));

    // vizor: gozluk tam buraya oturuyor
    final visorC = Offset(cx, w * 0.418);
    final visor = RRect.fromRectAndRadius(
      Rect.fromCenter(center: visorC, width: w * 0.50, height: w * 0.28),
      Radius.circular(w * 0.13));
    canvas.drawRRect(visor,
        Paint()..shader = ui.Gradient.linear(
          Offset(visorC.dx, visorC.dy - w * 0.14),
          Offset(visorC.dx, visorC.dy + w * 0.14),
          [const Color(0xFF2A3350), const Color(0xFF141A2B)]));
    _eyes(canvas, visorC, w * 0.30, dx: 0.42);
    // vizorde parlama
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.14, visorC.dy - w * 0.07),
          width: w * 0.16, height: w * 0.05),
      Paint()..color = Colors.white.withValues(alpha: 0.16));

    // kulaklar
    for (final dir in [-1.0, 1.0]) {
      final e = Offset(cx + dir * w * 0.345, w * 0.44);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: e, width: w * 0.07, height: w * 0.16),
          Radius.circular(w * 0.035)),
        _clay(e, w * 0.08, _dark(_brand, 0.16)));
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 2 — BUG: kod bocegi. "Bug" kelimesiyle oynuyor; hatanin korkutucu
/// degil sevimli oldugunu anlatan bir karakter cocuk icin iyi bir fikir.
class BugPainter extends CustomPainter {
  const BugPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    const teal = Color(0xFF14B8A6);
    _groundShadow(canvas, w, y: 0.93);

    // bacaklar
    final leg = Paint()
      ..color = _dark(teal, 0.35)
      ..strokeWidth = w * 0.030
      ..strokeCap = StrokeCap.round;
    for (final dir in [-1.0, 1.0]) {
      for (var i = 0; i < 3; i++) {
        final y = w * (0.60 + i * 0.10);
        canvas.drawLine(Offset(cx + dir * w * 0.20, y),
            Offset(cx + dir * w * 0.38, y + w * 0.09), leg);
      }
    }

    // antenler
    for (final dir in [-1.0, 1.0]) {
      final base = Offset(cx + dir * w * 0.13, w * 0.26);
      final t = Offset(cx + dir * w * 0.26, w * 0.09);
      canvas.drawPath(
        Path()..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(cx + dir * w * 0.24, w * 0.16, t.dx, t.dy),
        Paint()
          ..color = _dark(teal, 0.30)
          ..strokeWidth = w * 0.026
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
      canvas.drawCircle(t, w * 0.042, _clay(t, w * 0.042, const Color(0xFFFFC24B)));
    }

    // kabuk (govde)
    final shellC = Offset(cx, w * 0.62);
    canvas.drawOval(
      Rect.fromCenter(center: shellC, width: w * 0.58, height: w * 0.56),
      _clay(shellC, w * 0.30, teal));
    // kabuk ortasindaki cizgi + iki benek
    canvas.drawLine(Offset(cx, w * 0.36), Offset(cx, w * 0.88),
        Paint()
          ..color = _dark(teal, 0.35)
          ..strokeWidth = w * 0.016);
    for (final p in [
      Offset(cx - w * 0.15, w * 0.56), Offset(cx + w * 0.15, w * 0.62),
      Offset(cx - w * 0.10, w * 0.74),
    ]) {
      canvas.drawCircle(p, w * 0.038,
          Paint()..color = _dark(teal, 0.28).withValues(alpha: 0.55));
    }

    // kafa
    final headC = Offset(cx, w * 0.36);
    canvas.drawCircle(headC, w * 0.25, _clay(headC, w * 0.25, _dark(teal, 0.12)));
    _eyes(canvas, Offset(cx, w * 0.335), w * 0.25, dx: 0.40);
    _smile(canvas, Offset(cx, w * 0.435), w * 0.25);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 3 — PUF: yumusak canavar. Tek boynuz, genis agiz, kucuk kollar.
/// En "sarilabilir" secenek; kucuk yaslar icin en guclusu.
class PufPainter extends CustomPainter {
  const PufPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    const coral = Color(0xFFFF7A59);
    _groundShadow(canvas, w, y: 0.93);

    // boynuz
    final horn = Path()
      ..moveTo(cx - w * 0.055, w * 0.20)
      ..quadraticBezierTo(cx, w * 0.02, cx + w * 0.055, w * 0.20)
      ..close();
    canvas.drawPath(horn, _clay(Offset(cx, w * 0.12), w * 0.10,
        const Color(0xFFFFC24B)));

    // govde: tek parca damla
    final bodyC = Offset(cx, w * 0.56);
    final body = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromCenter(center: bodyC, width: w * 0.70, height: w * 0.72),
        topLeft: Radius.circular(w * 0.35),
        topRight: Radius.circular(w * 0.35),
        bottomLeft: Radius.circular(w * 0.24),
        bottomRight: Radius.circular(w * 0.24),
      ));
    canvas.drawPath(body, _clay(bodyC, w * 0.38, coral));

    // karin (acik alan)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, w * 0.72), width: w * 0.36,
          height: w * 0.30),
      Paint()..color = _light(coral, 0.55).withValues(alpha: 0.85));

    // kollar
    for (final dir in [-1.0, 1.0]) {
      final a = Offset(cx + dir * w * 0.36, w * 0.62);
      canvas.drawOval(
        Rect.fromCenter(center: a, width: w * 0.16, height: w * 0.22),
        _clay(a, w * 0.11, _dark(coral, 0.08)));
    }
    // ayaklar
    for (final dir in [-1.0, 1.0]) {
      final f = Offset(cx + dir * w * 0.155, w * 0.90);
      canvas.drawOval(
        Rect.fromCenter(center: f, width: w * 0.20, height: w * 0.10),
        _clay(f, w * 0.10, _dark(coral, 0.18)));
    }

    _eyes(canvas, Offset(cx, w * 0.40), w * 0.30, dx: 0.42);
    // genis gulen agiz + tek dis
    final mouth = Rect.fromCenter(
        center: Offset(cx, w * 0.50), width: w * 0.24, height: w * 0.18);
    canvas.drawArc(mouth, 0, math.pi, true, Paint()..color = _ink);
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * 0.05, w * 0.50)
        ..lineTo(cx - w * 0.015, w * 0.50)
        ..lineTo(cx - w * 0.033, w * 0.545)
        ..close(),
      Paint()..color = Colors.white);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 4 — KASIF: kaskli astronot. Kesif/merak temasi kodlamayla iyi
/// ortusuyor; kask ayni zamanda gozluk cizgisini serbest birakiyor.
class KasifPainter extends CustomPainter {
  const KasifPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    const suit = Color(0xFF3B82F6);
    _groundShadow(canvas, w);

    // sirt cantasi
    final packC = Offset(cx, w * 0.70);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: packC, width: w * 0.66, height: w * 0.30),
        Radius.circular(w * 0.12)),
      _clay(packC, w * 0.34, _dark(suit, 0.30)));

    // govde
    final bodyC = Offset(cx, w * 0.74);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: bodyC, width: w * 0.50, height: w * 0.36),
        Radius.circular(w * 0.15)),
      _clay(bodyC, w * 0.28, Colors.white));
    // gogus rozeti
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, w * 0.72),
            width: w * 0.18, height: w * 0.12),
        Radius.circular(w * 0.04)),
      Paint()..color = suit);

    // kollar
    for (final dir in [-1.0, 1.0]) {
      canvas.drawLine(Offset(cx + dir * w * 0.24, w * 0.68),
          Offset(cx + dir * w * 0.37, w * 0.80),
          Paint()
            ..color = _light(suit, 0.55)
            ..strokeWidth = w * 0.075
            ..strokeCap = StrokeCap.round);
    }
    // ayaklar
    for (final dir in [-1.0, 1.0]) {
      final f = Offset(cx + dir * w * 0.135, w * 0.905);
      canvas.drawOval(
        Rect.fromCenter(center: f, width: w * 0.18, height: w * 0.09),
        _clay(f, w * 0.09, _dark(suit, 0.25)));
    }

    // kask
    final headC = Offset(cx, w * 0.42);
    canvas.drawCircle(headC, w * 0.32, _clay(headC, w * 0.32, Colors.white));
    // cam
    canvas.drawCircle(headC, w * 0.255,
      Paint()..shader = ui.Gradient.radial(
        Offset(headC.dx - w * 0.09, headC.dy - w * 0.11), w * 0.42,
        [const Color(0xFF9FD2FF), const Color(0xFF3E7BD6)]));
    // yuz camin icinde
    _eyes(canvas, Offset(cx, w * 0.40), w * 0.25, dx: 0.40);
    _smile(canvas, Offset(cx, w * 0.485), w * 0.25, w: 0.46);
    // camda parlama
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: headC, radius: w * 0.255)));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.11, w * 0.315),
          width: w * 0.20, height: w * 0.09),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.012));
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 5 — MIA: kedi-robot. Kulaklar sayesinde 40 pikselde bile taninan
/// en guclu siluet; kedi cocuklarda en yuksek ilk-bakis sempatisi.
class MiaPainter extends CustomPainter {
  const MiaPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    const violet = Color(0xFF8B5CF6);
    _groundShadow(canvas, w);

    // kuyruk
    canvas.drawPath(
      Path()
        ..moveTo(cx + w * 0.22, w * 0.82)
        ..quadraticBezierTo(cx + w * 0.46, w * 0.80, cx + w * 0.40, w * 0.60),
      Paint()
        ..color = _dark(violet, 0.10)
        ..strokeWidth = w * 0.055
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke);

    // govde
    final bodyC = Offset(cx, w * 0.76);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: bodyC, width: w * 0.48, height: w * 0.34),
        Radius.circular(w * 0.16)),
      _clay(bodyC, w * 0.28, violet));
    // gogus ekrani
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, w * 0.755),
            width: w * 0.20, height: w * 0.13),
        Radius.circular(w * 0.045)),
      Paint()..shader = ui.Gradient.linear(
        Offset(cx, w * 0.69), Offset(cx, w * 0.82),
        [Colors.white, const Color(0xFFDCE4F2)]));

    // patiler
    for (final dir in [-1.0, 1.0]) {
      final f = Offset(cx + dir * w * 0.13, w * 0.90);
      canvas.drawOval(
        Rect.fromCenter(center: f, width: w * 0.17, height: w * 0.09),
        _clay(f, w * 0.09, _dark(violet, 0.18)));
    }

    // kulaklar (kafanin arkasinda)
    final headC = Offset(cx, w * 0.44);
    for (final dir in [-1.0, 1.0]) {
      final tip = Offset(cx + dir * w * 0.26, w * 0.10);
      canvas.drawPath(
        Path()
          ..moveTo(cx + dir * w * 0.09, w * 0.24)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(cx + dir * w * 0.33, w * 0.32)
          ..close(),
        _clay(tip, w * 0.16, violet));
      canvas.drawPath(
        Path()
          ..moveTo(cx + dir * w * 0.135, w * 0.245)
          ..lineTo(cx + dir * w * 0.245, w * 0.145)
          ..lineTo(cx + dir * w * 0.285, w * 0.295)
          ..close(),
        Paint()..color = const Color(0xFFFFB4C8).withValues(alpha: 0.9));
    }

    // kafa
    canvas.drawCircle(headC, w * 0.32, _clay(headC, w * 0.32, violet));
    // yuz plakasi
    final faceC = Offset(cx, w * 0.455);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: faceC, width: w * 0.46, height: w * 0.34),
        Radius.circular(w * 0.16)),
      Paint()..shader = ui.Gradient.radial(
        Offset(faceC.dx - w * 0.08, faceC.dy - w * 0.10), w * 0.40,
        [Colors.white, const Color(0xFFF1F4FB)]));
    _eyes(canvas, Offset(cx, w * 0.425), w * 0.26, dx: 0.42);
    // kedi agzi
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - w * 0.028, w * 0.515),
          width: w * 0.055, height: w * 0.045),
      0, math.pi, false,
      Paint()..color = _ink..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.016..strokeCap = StrokeCap.round);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + w * 0.028, w * 0.515),
          width: w * 0.055, height: w * 0.045),
      0, math.pi, false,
      Paint()..color = _ink..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.016..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

const _cands = <(String, CustomPainter)>[
  ('1 — Bit  ·  minik robot', BitPainter()),
  ('2 — Bug  ·  kod böceği', BugPainter()),
  ('3 — Puf  ·  yumuşak canavar', PufPainter()),
  ('4 — Kaşif  ·  astronot', KasifPainter()),
  ('5 — Mia  ·  kedi-robot', MiaPainter()),
];

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

  testWidgets('devi karakter denemeleri', (tester) async {
    const cell = 300.0;
    const tileH = cell * 1.10 + 34 + 92;
    const cols = 3;
    const sheetW = cell * cols + 80;
    const sheetH = tileH * 2 + 70;

    tester.view.physicalSize = const Size(sheetW * 2, sheetH * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final key = GlobalKey();

    Widget tile(String label, CustomPainter p) => SizedBox(
          width: cell,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  width: cell, height: cell * 1.10,
                  child: CustomPaint(painter: p)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Nunito', fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF303648))),
              const SizedBox(height: 8),
              // Uygulamadaki gercek boyutlar.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final s in [40.0, 56.0, 76.0])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                          width: s, height: s * 1.10,
                          child: CustomPaint(painter: p)),
                    ),
                ],
              ),
            ],
          ),
        );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(sheetW, sheetH)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: sheetW, height: sheetH,
              color: const Color(0xFFF3F5FA),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final c in _cands.take(3)) tile(c.$1, c.$2),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final c in _cands.skip(3)) tile(c.$1, c.$2),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.runAsync(() async {
      final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await b.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      Directory('outputs/mascot').createSync(recursive: true);
      File('outputs/mascot/karakterler.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
