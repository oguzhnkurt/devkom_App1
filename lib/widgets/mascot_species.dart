import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'mascot_face.dart';
import 'mascot_mood.dart';

/// Çocuğun seçebildiği maskotlar.
///
/// Beşi de AYNI yüzü taşıyor (bkz. [MascotFace]) ve aynı çıpa
/// sözleşmesine uyuyor: mağazadan alınan şapka, gözlük, kolye ve
/// ayakkabı hepsinde doğru yere oturuyor.
enum MascotSpecies {
  /// Yumuşak canavar. AÇILIŞTAKİ karakter.
  puf,

  /// Kedi-robot.
  mia,

  /// Minik robot.
  bit,

  /// Astronot.
  kasif,

  /// Kod böceği.
  bug,
}

/// Bir maskotun gövde oranları.
///
/// Ekipmanlar (şapka, gözlük, kolye, ayakkabı) bu çıpalara göre
/// konumlanıyor. Hepsi figürün GENİŞLİĞİNE oranlı — yani 28 puntoda da
/// 240 puntoda da şapka aynı yere oturuyor.
///
/// DİKKAT: bu değerler her türün boyacısındaki geometriden türetildi.
/// Boyacıdaki bir ölçüyü değiştirirseniz buradaki çıpaları da
/// güncelleyin, yoksa şapka kafanın içine kayar.
/// `test/mascot_and_placement_test.dart` bu ikisinin ayrışmasını
/// yakalıyor.
@immutable
class MascotAnchors {
  const MascotAnchors({
    required this.stageHeight,
    required this.topY,
    required this.headTopY,
    required this.faceCenterY,
    required this.faceRadius,
    required this.bodyTopY,
    required this.feetY,
  });

  /// Tuval yüksekliği = genişlik × bu.
  final double stageHeight;

  /// Silüetin en tepesi (anten ucu, kulak ucu, boynuz ucu).
  final double topY;

  final double headTopY;

  /// Yüzün merkezi ve yarıçapı — gözler ve ağız buradan türüyor.
  final double faceCenterY;
  final double faceRadius;

  final double bodyTopY;

  /// Ayakların hizası — ayakkabı buraya.
  final double feetY;

  /// Göz hizası — gözlük buraya oturuyor. [MascotFace] gözleri
  /// merkezin `0.08 × yarıçap` üstüne koyuyor; gözlük de oraya.
  double get eyeLineY => faceCenterY - faceRadius * 0.08;

  /// Şapkanın MERKEZİ. Kafanın tepesinin biraz üstünde: alt kenarı
  /// kafaya oturuyor, üstü serbest kalıyor.
  double get hatY => headTopY - 0.045;

  /// Göğüsteki küçük ekranın merkezi.
  double get chestY => bodyTopY + 0.15;

  /// Kolyenin merkezi — göğsün üst kısmı.
  double get necklaceY => bodyTopY + 0.035;
}

/// Bir maskotun kimliği: adı, varsayılan rengi, oranları.
@immutable
class MascotSpec {
  const MascotSpec({
    required this.species,
    required this.name,
    required this.tagline,
    required this.taglineEn,
    required this.taglineDe,
    required this.taglineEs,
    required this.defaultColor,
    required this.anchors,
    this.previewScale = 1.0,
  });

  final MascotSpecies species;

  /// Karakterin adı. Metinlerde geçiyor, çevrilmiyor — bu bir isim.
  final String name;

  final String tagline;
  final String taglineEn;
  final String taglineDe;
  final String taglineEs;

  /// Gövde rengi verilmediğinde kullanılan renk.
  final Color defaultColor;

  final MascotAnchors anchors;

  /// Seçici gibi yan yana dizildiği yerlerde ölçek düzeltmesi.
  ///
  /// Her karakter tuvalini farklı doldurıyor: Puf neredeyse tamamını,
  /// Kaşif ve Bug daha azını. Aynı `size` verildiğinde şeritte biri
  /// kocaman biri minik duruyordu; bu çarpan onları göz için eşitliyor.
  final double previewScale;

  String taglineFor(String lang) => switch (lang) {
        'en' => taglineEn,
        'de' => taglineDe,
        'es' => taglineEs,
        _ => tagline,
      };
}

const Map<MascotSpecies, MascotSpec> mascotSpecs = {
  MascotSpecies.puf: MascotSpec(
    species: MascotSpecies.puf,
    name: 'Puf',
    tagline: 'Yumuşak canavar',
    taglineEn: 'Soft monster',
    taglineDe: 'Weiches Monster',
    taglineEs: 'Monstruo blandito',
    defaultColor: Color(0xFFFF7A59),
    anchors: MascotAnchors(
      stageHeight: 1.12,
      topY: 0.02,
      headTopY: 0.20,
      faceCenterY: 0.44,
      faceRadius: 0.29,
      bodyTopY: 0.58,
      feetY: 0.90,
    ),
    previewScale: 0.94,
  ),
  MascotSpecies.mia: MascotSpec(
    species: MascotSpecies.mia,
    name: 'Mia',
    tagline: 'Kedi-robot',
    taglineEn: 'Cat-robot',
    taglineDe: 'Katzen-Roboter',
    taglineEs: 'Gato robot',
    defaultColor: Color(0xFF8B5CF6),
    anchors: MascotAnchors(
      stageHeight: 1.12,
      topY: 0.10,
      headTopY: 0.12,
      faceCenterY: 0.446,
      faceRadius: 0.26,
      bodyTopY: 0.59,
      feetY: 0.90,
    ),
    previewScale: 1.00,
  ),
  MascotSpecies.bit: MascotSpec(
    species: MascotSpecies.bit,
    name: 'Bit',
    tagline: 'Minik robot',
    taglineEn: 'Little robot',
    taglineDe: 'Kleiner Roboter',
    taglineEs: 'Robot pequeño',
    defaultColor: Color(0xFF6C3CE0),
    anchors: MascotAnchors(
      stageHeight: 1.12,
      topY: 0.05,
      headTopY: 0.15,
      faceCenterY: 0.442,
      faceRadius: 0.28,
      bodyTopY: 0.585,
      feetY: 0.90,
    ),
    previewScale: 1.00,
  ),
  MascotSpecies.kasif: MascotSpec(
    species: MascotSpecies.kasif,
    name: 'Kaşif',
    tagline: 'Astronot',
    taglineEn: 'Astronaut',
    taglineDe: 'Astronautin',
    taglineEs: 'Astronauta',
    defaultColor: Color(0xFF3B82F6),
    anchors: MascotAnchors(
      stageHeight: 1.12,
      topY: 0.10,
      headTopY: 0.10,
      faceCenterY: 0.420,
      faceRadius: 0.25,
      bodyTopY: 0.56,
      feetY: 0.905,
    ),
    previewScale: 1.10,
  ),
  MascotSpecies.bug: MascotSpec(
    species: MascotSpecies.bug,
    name: 'Bug',
    tagline: 'Kod böceği',
    taglineEn: 'Code bug',
    taglineDe: 'Code-Käfer',
    taglineEs: 'Bicho del código',
    defaultColor: Color(0xFF14B8A6),
    anchors: MascotAnchors(
      stageHeight: 1.12,
      topY: 0.06,
      headTopY: 0.11,
      faceCenterY: 0.355,
      faceRadius: 0.25,
      bodyTopY: 0.46,
      feetY: 0.86,
    ),
    previewScale: 1.08,
  ),
};

MascotSpec specOf(MascotSpecies s) => mascotSpecs[s]!;

// ---------------------------------------------------------------------------
// Ortak boyama yardımcıları
// ---------------------------------------------------------------------------

Color _dark(Color c, double t) => Color.lerp(c, const Color(0xFF0B1220), t)!;
Color _light(Color c, double t) => Color.lerp(c, Colors.white, t)!;

/// Kil hissi veren dolgu: ışık sol üstten, alt kenarda koyulaşma.
///
/// Düz renk yerine bunu kullanmak karakteri havada duran bir şekle
/// çeviriyor. Yüz bu gradyanın DIŞINDA tutuluyor: ilk denemede yüze de
/// aynı güçte gradyan konmuştu ve küçük boyutta yüz grileşip karakter
/// kirli görünüyordu.
Paint _clay(Offset c, double r, Color color) => Paint()
  ..shader = ui.Gradient.radial(
    Offset(c.dx - r * 0.28, c.dy - r * 0.42),
    r * 1.7,
    [_light(color, 0.24), color, _dark(color, 0.30)],
    [0.0, 0.5, 1.0],
  );

void _groundShadow(Canvas canvas, double w, double y, double breath) {
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(w / 2, w * y),
      width: w * (0.58 - breath * 0.03),
      height: w * 0.10,
    ),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.030),
  );
}

/// Kolların sevinçte kalkma miktarı.
double _armLift(MascotMood mood, double w, double breath) => switch (mood) {
      MascotMood.cheering => w * 0.20 + breath * w * 0.05,
      MascotMood.happy => w * 0.06,
      _ => 0.0,
    };

/// Kafanın yana eğilmesi. Düşünürken ve merak ederken.
double _tilt(MascotMood mood) => switch (mood) {
      MascotMood.thinking => -0.10,
      MascotMood.curious => 0.08,
      _ => 0.0,
    };

/// Antenlerin / kulakların açılması.
double _spread(MascotMood mood) => switch (mood) {
      MascotMood.cheering => 1.30,
      MascotMood.curious => 1.15,
      MascotMood.thinking => 0.92,
      _ => 1.0,
    };

// ---------------------------------------------------------------------------

/// Bütün maskot boyacılarının ortak tabanı.
abstract class MascotBodyPainter extends CustomPainter {
  const MascotBodyPainter({
    required this.mood,
    required this.color,
    required this.blink,
    required this.breath,
    required this.shadow,
  });

  final MascotMood mood;
  final Color color;

  /// 0 = göz açık, 1 = kapalı.
  final double blink;
  final double breath;
  final bool shadow;

  MascotSpecies get species;
  MascotAnchors get anchors => specOf(species).anchors;

  /// Yüzü çizer. Kafanın eğimi ile birlikte döndüğü için gövdeden
  /// sonra ve kafa dönüşümünün İÇİNDE çağrılıyor.
  void drawFace(Canvas canvas, double w, {Color ink = MascotFace.ink}) {
    MascotFace.paint(
      canvas,
      Offset(w / 2, w * anchors.faceCenterY),
      w * anchors.faceRadius,
      mood: mood,
      blink: blink,
      inkColor: ink,
    );
  }

  @override
  bool shouldRepaint(covariant MascotBodyPainter old) =>
      old.mood != mood ||
      old.color != color ||
      old.blink != blink ||
      old.breath != breath ||
      old.shadow != shadow;
}

/// Puf — yumuşak canavar. Tek boynuz, geniş gövde, kısa kollar.
class PufPainter extends MascotBodyPainter {
  const PufPainter({
    required super.mood,
    required super.color,
    required super.blink,
    required super.breath,
    required super.shadow,
  });

  @override
  MascotSpecies get species => MascotSpecies.puf;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    if (shadow) _groundShadow(canvas, w, 0.93, breath);

    // boynuz
    final horn = Path()
      ..moveTo(cx - w * 0.055, w * 0.20)
      ..quadraticBezierTo(cx, w * 0.02, cx + w * 0.055, w * 0.20)
      ..close();
    canvas.drawPath(
        horn, _clay(Offset(cx, w * 0.12), w * 0.10, const Color(0xFFFFC24B)));

    // gövde
    final bodyC = Offset(cx, w * 0.56);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(center: bodyC, width: w * 0.70, height: w * 0.72),
        topLeft: Radius.circular(w * 0.35),
        topRight: Radius.circular(w * 0.35),
        bottomLeft: Radius.circular(w * 0.24),
        bottomRight: Radius.circular(w * 0.24),
      ),
      _clay(bodyC, w * 0.38, color),
    );

    // karın
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, w * 0.72), width: w * 0.36, height: w * 0.30),
      Paint()..color = _light(color, 0.55).withValues(alpha: 0.85),
    );

    // kollar
    final lift = _armLift(mood, w, breath);
    for (final dir in [-1.0, 1.0]) {
      final a = Offset(cx + dir * w * 0.36, w * 0.62 - lift);
      canvas.drawOval(
        Rect.fromCenter(center: a, width: w * 0.16, height: w * 0.22),
        _clay(a, w * 0.11, _dark(color, 0.08)),
      );
    }

    // ayaklar
    for (final dir in [-1.0, 1.0]) {
      final f = Offset(cx + dir * w * 0.155, w * anchors.feetY);
      canvas.drawOval(
        Rect.fromCenter(center: f, width: w * 0.20, height: w * 0.10),
        _clay(f, w * 0.10, _dark(color, 0.18)),
      );
    }

    // yüz — kafa eğimiyle birlikte
    final headC = Offset(cx, w * anchors.faceCenterY);
    canvas.save();
    canvas.translate(headC.dx, headC.dy);
    canvas.rotate(_tilt(mood));
    canvas.translate(-headC.dx, -headC.dy);
    drawFace(canvas, w);
    canvas.restore();
  }
}

/// Mia — kedi-robot. Kulaklar sayesinde 40 pikselde bile tanınıyor.
class MiaPainter extends MascotBodyPainter {
  const MiaPainter({
    required super.mood,
    required super.color,
    required super.blink,
    required super.breath,
    required super.shadow,
  });

  @override
  MascotSpecies get species => MascotSpecies.mia;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    if (shadow) _groundShadow(canvas, w, 0.94, breath);

    // kuyruk
    canvas.drawPath(
      Path()
        ..moveTo(cx + w * 0.22, w * 0.82)
        ..quadraticBezierTo(
            cx + w * 0.46, w * 0.80, cx + w * 0.40, w * 0.60 - breath * w * 0.02),
      Paint()
        ..color = _dark(color, 0.10)
        ..strokeWidth = w * 0.055
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // gövde
    final bodyC = Offset(cx, w * 0.76);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: bodyC, width: w * 0.48, height: w * 0.34),
        Radius.circular(w * 0.16),
      ),
      _clay(bodyC, w * 0.28, color),
    );
    // göğüs ekranı
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, w * anchors.chestY),
            width: w * 0.20,
            height: w * 0.13),
        Radius.circular(w * 0.045),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, w * 0.69),
          Offset(cx, w * 0.82),
          [Colors.white, const Color(0xFFDCE4F2)],
        ),
    );

    // patiler
    for (final dir in [-1.0, 1.0]) {
      final f = Offset(cx + dir * w * 0.13, w * anchors.feetY);
      canvas.drawOval(
        Rect.fromCenter(center: f, width: w * 0.17, height: w * 0.09),
        _clay(f, w * 0.09, _dark(color, 0.18)),
      );
    }

    // kafa + kulaklar, eğimle birlikte
    final headC = Offset(cx, w * 0.44);
    canvas.save();
    canvas.translate(headC.dx, headC.dy);
    canvas.rotate(_tilt(mood));
    canvas.translate(-headC.dx, -headC.dy);

    final sp = _spread(mood);
    for (final dir in [-1.0, 1.0]) {
      final tipX = cx + dir * w * 0.26 * sp;
      canvas.drawPath(
        Path()
          ..moveTo(cx + dir * w * 0.09, w * 0.24)
          ..lineTo(tipX, w * 0.10)
          ..lineTo(cx + dir * w * 0.33, w * 0.32)
          ..close(),
        _clay(Offset(tipX, w * 0.10), w * 0.16, color),
      );
      canvas.drawPath(
        Path()
          ..moveTo(cx + dir * w * 0.135, w * 0.245)
          ..lineTo(cx + dir * w * 0.245 * sp, w * 0.145)
          ..lineTo(cx + dir * w * 0.285, w * 0.295)
          ..close(),
        Paint()..color = const Color(0xFFFFB4C8).withValues(alpha: 0.9),
      );
    }

    canvas.drawCircle(headC, w * 0.32, _clay(headC, w * 0.32, color));
    // yüz plakası
    final faceC = Offset(cx, w * anchors.faceCenterY);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: faceC, width: w * 0.46, height: w * 0.36),
        Radius.circular(w * 0.16),
      ),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(faceC.dx - w * 0.08, faceC.dy - w * 0.10),
          w * 0.40,
          [Colors.white, const Color(0xFFF1F4FB)],
        ),
    );
    drawFace(canvas, w);
    canvas.restore();
  }
}

/// Bit — minik robot. Koyu vizör; yüz açık mürekkeple çiziliyor.
class BitPainter extends MascotBodyPainter {
  const BitPainter({
    required super.mood,
    required super.color,
    required super.blink,
    required super.breath,
    required super.shadow,
  });

  @override
  MascotSpecies get species => MascotSpecies.bit;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    if (shadow) _groundShadow(canvas, w, 0.94, breath);

    // gövde
    final bodyC = Offset(cx, w * 0.755);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: bodyC, width: w * 0.50, height: w * 0.34),
        Radius.circular(w * 0.14),
      ),
      _clay(bodyC, w * 0.28, color),
    );
    // göğüs ekranı
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, w * anchors.chestY),
            width: w * 0.20,
            height: w * 0.13),
        Radius.circular(w * 0.045),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, w * 0.68),
          Offset(cx, w * 0.81),
          [Colors.white, const Color(0xFFDCE4F2)],
        ),
    );

    // kollar
    final lift = _armLift(mood, w, breath);
    final arm = Paint()
      ..color = _dark(color, 0.10)
      ..strokeWidth = w * 0.080
      ..strokeCap = StrokeCap.round;
    for (final dir in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(cx + dir * w * 0.225, w * 0.735),
        Offset(cx + dir * w * 0.355, w * 0.845 - lift * 0.8),
        arm,
      );
    }
    // ayaklar
    for (final dir in [-1.0, 1.0]) {
      final f = Offset(cx + dir * w * 0.135, w * anchors.feetY);
      canvas.drawOval(
        Rect.fromCenter(center: f, width: w * 0.17, height: w * 0.09),
        _clay(f, w * 0.09, _dark(color, 0.18)),
      );
    }

    // kafa, eğimle birlikte
    final headC = Offset(cx, w * 0.44);
    canvas.save();
    canvas.translate(headC.dx, headC.dy);
    canvas.rotate(_tilt(mood));
    canvas.translate(-headC.dx, -headC.dy);

    // anten
    final sp = _spread(mood);
    final tip = Offset(cx, w * (0.09 - (sp - 1) * 0.06));
    canvas.drawLine(
      Offset(cx, w * 0.17),
      tip,
      Paint()
        ..color = _dark(color, 0.10)
        ..strokeWidth = w * 0.030
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
        tip, w * 0.048, _clay(tip, w * 0.048, const Color(0xFFFFC24B)));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: headC, width: w * 0.66, height: w * 0.58),
        Radius.circular(w * 0.22),
      ),
      _clay(headC, w * 0.34, color),
    );

    // kulaklar
    for (final dir in [-1.0, 1.0]) {
      final e = Offset(cx + dir * w * 0.345, w * 0.44);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: e, width: w * 0.07, height: w * 0.16),
          Radius.circular(w * 0.035),
        ),
        _clay(e, w * 0.08, _dark(color, 0.16)),
      );
    }

    // vizör
    final visorC = Offset(cx, w * 0.44);
    final visor = RRect.fromRectAndRadius(
      Rect.fromCenter(center: visorC, width: w * 0.52, height: w * 0.34),
      Radius.circular(w * 0.15),
    );
    canvas.drawRRect(
      visor,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(visorC.dx, visorC.dy - w * 0.17),
          Offset(visorC.dx, visorC.dy + w * 0.17),
          [const Color(0xFF2A3350), const Color(0xFF141A2B)],
        ),
    );
    // Yüz KOYU zemine çiziliyor: açık mürekkep.
    canvas.save();
    canvas.clipRRect(visor);
    drawFace(canvas, w, ink: MascotFace.lightInk);
    canvas.restore();
    // vizörde parlama
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - w * 0.15, visorC.dy - w * 0.11),
          width: w * 0.16,
          height: w * 0.045),
      Paint()..color = Colors.white.withValues(alpha: 0.14),
    );
    canvas.restore();
  }
}

/// Kaşif — kasklı astronot. Yüz kaskın camının içinde.
class KasifPainter extends MascotBodyPainter {
  const KasifPainter({
    required super.mood,
    required super.color,
    required super.blink,
    required super.breath,
    required super.shadow,
  });

  @override
  MascotSpecies get species => MascotSpecies.kasif;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    if (shadow) _groundShadow(canvas, w, 0.94, breath);

    // sırt çantası
    final packC = Offset(cx, w * 0.70);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: packC, width: w * 0.66, height: w * 0.30),
        Radius.circular(w * 0.12),
      ),
      _clay(packC, w * 0.34, _dark(color, 0.30)),
    );

    // gövde
    final bodyC = Offset(cx, w * 0.74);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: bodyC, width: w * 0.50, height: w * 0.36),
        Radius.circular(w * 0.15),
      ),
      _clay(bodyC, w * 0.28, Colors.white),
    );
    // göğüs rozeti
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, w * anchors.chestY),
            width: w * 0.19,
            height: w * 0.13),
        Radius.circular(w * 0.045),
      ),
      Paint()..color = color,
    );

    // kollar
    final lift = _armLift(mood, w, breath);
    for (final dir in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(cx + dir * w * 0.225, w * 0.715),
        Offset(cx + dir * w * 0.355, w * 0.825 - lift * 0.8),
        Paint()
          ..color = _light(color, 0.35)
          ..strokeWidth = w * 0.085
          ..strokeCap = StrokeCap.round,
      );
    }
    // ayaklar
    for (final dir in [-1.0, 1.0]) {
      final f = Offset(cx + dir * w * 0.135, w * anchors.feetY);
      canvas.drawOval(
        Rect.fromCenter(center: f, width: w * 0.18, height: w * 0.09),
        _clay(f, w * 0.09, _dark(color, 0.25)),
      );
    }

    // kask, eğimle birlikte
    final headC = Offset(cx, w * 0.42);
    canvas.save();
    canvas.translate(headC.dx, headC.dy);
    canvas.rotate(_tilt(mood));
    canvas.translate(-headC.dx, -headC.dy);

    canvas.drawCircle(headC, w * 0.32, _clay(headC, w * 0.32, Colors.white));
    canvas.drawCircle(
      headC,
      w * 0.255,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(headC.dx - w * 0.09, headC.dy - w * 0.11),
          w * 0.42,
          [const Color(0xFFB7DDFF), const Color(0xFF5E93DE)],
        ),
    );
    drawFace(canvas, w);
    // camda parlama
    canvas.save();
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: headC, radius: w * 0.255)));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - w * 0.11, w * 0.315),
          width: w * 0.20,
          height: w * 0.09),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.012),
    );
    canvas.restore();
    canvas.restore();
  }
}

/// Bug — kod böceği. Hatanın korkutucu değil sevimli olduğunu anlatan
/// bir karakter, hata ayıklamayı öğrenen çocuk için iyi bir fikir.
class BugPainter extends MascotBodyPainter {
  const BugPainter({
    required super.mood,
    required super.color,
    required super.blink,
    required super.breath,
    required super.shadow,
  });

  @override
  MascotSpecies get species => MascotSpecies.bug;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    if (shadow) _groundShadow(canvas, w, 0.93, breath);

    // bacaklar
    final leg = Paint()
      ..color = _dark(color, 0.35)
      ..strokeWidth = w * 0.030
      ..strokeCap = StrokeCap.round;
    for (final dir in [-1.0, 1.0]) {
      for (var i = 0; i < 3; i++) {
        final y = w * (0.60 + i * 0.10);
        canvas.drawLine(
          Offset(cx + dir * w * 0.20, y),
          Offset(cx + dir * w * 0.38, y + w * 0.09),
          leg,
        );
      }
    }

    // kabuk
    final shellC = Offset(cx, w * 0.62);
    canvas.drawOval(
      Rect.fromCenter(center: shellC, width: w * 0.58, height: w * 0.56),
      _clay(shellC, w * 0.30, color),
    );
    canvas.drawLine(
      Offset(cx, w * 0.36),
      Offset(cx, w * 0.88),
      Paint()
        ..color = _dark(color, 0.35)
        ..strokeWidth = w * 0.016,
    );
    for (final p in [
      Offset(cx - w * 0.15, w * 0.56),
      Offset(cx + w * 0.15, w * 0.62),
      Offset(cx - w * 0.10, w * 0.74),
    ]) {
      canvas.drawCircle(p, w * 0.038,
          Paint()..color = _dark(color, 0.28).withValues(alpha: 0.55));
    }

    // kafa + antenler, eğimle birlikte
    final headC = Offset(cx, w * 0.36);
    canvas.save();
    canvas.translate(headC.dx, headC.dy);
    canvas.rotate(_tilt(mood));
    canvas.translate(-headC.dx, -headC.dy);

    final sp = _spread(mood);
    for (final dir in [-1.0, 1.0]) {
      final base = Offset(cx + dir * w * 0.13, w * 0.26);
      final t = Offset(cx + dir * w * 0.26 * sp, w * 0.09);
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(cx + dir * w * 0.24, w * 0.16, t.dx, t.dy),
        Paint()
          ..color = _dark(color, 0.30)
          ..strokeWidth = w * 0.026
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(
          t, w * 0.042, _clay(t, w * 0.042, const Color(0xFFFFC24B)));
    }

    canvas.drawCircle(
        headC, w * 0.25, _clay(headC, w * 0.25, _dark(color, 0.12)));
    drawFace(canvas, w);
    canvas.restore();
  }
}

/// Seçili türe göre boyacıyı kurar.
MascotBodyPainter mascotPainter({
  required MascotSpecies species,
  required MascotMood mood,
  required Color color,
  required double blink,
  required double breath,
  required bool shadow,
}) =>
    switch (species) {
      MascotSpecies.puf => PufPainter(
          mood: mood,
          color: color,
          blink: blink,
          breath: breath,
          shadow: shadow),
      MascotSpecies.mia => MiaPainter(
          mood: mood,
          color: color,
          blink: blink,
          breath: breath,
          shadow: shadow),
      MascotSpecies.bit => BitPainter(
          mood: mood,
          color: color,
          blink: blink,
          breath: breath,
          shadow: shadow),
      MascotSpecies.kasif => KasifPainter(
          mood: mood,
          color: color,
          blink: blink,
          breath: breath,
          shadow: shadow),
      MascotSpecies.bug => BugPainter(
          mood: mood,
          color: color,
          blink: blink,
          breath: breath,
          shadow: shadow),
    };
