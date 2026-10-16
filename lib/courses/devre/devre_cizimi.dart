import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../sahne/uno_karti.dart' show UnoKartBoyaci, UnoOlcu;
import '../yurutme/mblock_uno.dart';
import 'devre_modeli.dart';
import 'devre_simulasyonu.dart';
import 'devre_yerlesim.dart';

/// SANAL DEVRE CIZIMI — dunya biriminde (delik araligi = 1).
///
/// Kendi vektor cizimimiz: Tinkercad ya da baska bir programin gorseli
/// kullanilmiyor. Uno icin `uno_karti.dart`'taki kart cizimi
/// ([UnoKartBoyaci]) aynen kullaniliyor; marka logosu ve yazisi yok.
///
/// Uc katman:
///  1. [DevreZeminBoyaci] (durgun): breadboard, Uno, kablolar.
///  2. [DevreParcaBoyaci] (canli): parcalar, LED isiklari, servo kolu,
///     buzzer dalgalari, Uno'nun L/ON ledleri. Simulasyonu dinliyor.
///  3. Duzenleyicinin ust katmani (secim, hedef, hayalet parca) —
///     `devre_duzenleyici.dart`.

const Color _kirmiziHat = Color(0xFFE0322F);
const Color _maviHat = Color(0xFF2F6FD6);
const Color _bacak = Color(0xFFA7ADB4);

Color ledRengi(LedRengi r) => switch (r) {
      LedRengi.kirmizi => const Color(0xFFFF3B3B),
      LedRengi.sari => const Color(0xFFFFC21A),
      LedRengi.yesil => const Color(0xFF2EDB5A),
      LedRengi.mavi => const Color(0xFF3D8BFF),
      LedRengi.beyaz => const Color(0xFFF4F7FF),
    };

/// Dunya biriminde yazi. Yazi 20 piksellik bir fontla diziliyor ve
/// tuval olcekleniyor: 0,4 birimlik bir font dogrudan dizilince satir
/// olculeri tam piksele yuvarlanabiliyor.
void _yazi(Canvas c, String s, Offset m, double boy, Color renk,
    {FontWeight agirlik = FontWeight.w800}) {
  const taban = 20.0;
  final tp = TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: taban,
        fontWeight: agirlik,
        color: renk,
        height: 1.0,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  c.save();
  c.translate(m.dx, m.dy);
  c.scale(boy / taban);
  tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
  c.restore();
}

Paint _cizgi(Color r, double w) => Paint()
  ..color = r
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..style = PaintingStyle.stroke;

// ======================================================================
// Zemin: breadboard, Uno, kablolar
// ======================================================================

class DevreZeminBoyaci extends CustomPainter {
  DevreZeminBoyaci({
    required this.devre,
    required this.dunya,
    this.secilenKablo,
  });

  final Devre devre;
  final DevreDunyasi dunya;
  final int? secilenKablo;

  @override
  void paint(Canvas c, Size size) {
    final k = size.width / dunya.genislik;
    c.save();
    c.scale(k);
    c.clipRect(Offset.zero & dunya.boyut);
    _breadboard(c);
    UnoKartBoyaci(o: DevreDunyasi.unoO, s: DevreDunyasi.unoS).paint(c, size);
    for (final p in devre.parcalar) {
      if (p.tur == ParcaTuru.servo) servoZemini(c, p, dunya);
    }
    for (var i = 0; i < devre.kablolar.length; i++) {
      kabloCiz(c, devre, dunya, i, secili: i == secilenKablo);
    }
    c.restore();
  }

  void _breadboard(Canvas c) {
    final bb = dunya.breadboard;
    double sy(double s) => bb.top + s;
    final govde = RRect.fromRectAndRadius(bb, const Radius.circular(0.35));
    c.drawRRect(
        govde.shift(const Offset(0, 0.25)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.3));
    c.drawRRect(govde, Paint()..color = const Color(0xFFEDEEEF));
    c.drawRRect(
        govde,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.08
          ..color = const Color(0xFFC9CCD0));
    final ray = Paint()..color = const Color(0xFFE3E5E7);
    c.drawRect(Rect.fromLTRB(bb.left + 0.1, sy(0.15), bb.right - 0.1, sy(2.7)), ray);
    c.drawRect(Rect.fromLTRB(bb.left + 0.1, sy(14.65), bb.right - 0.1, sy(17.15)), ray);
    c.drawRect(
        Rect.fromLTRB(bb.left + 0.4, sy(8.7 - 0.32), bb.right - 0.4, sy(8.7 + 0.32)),
        Paint()..color = const Color(0xFFD5D8DB));

    final x0 = DevreDunyasi.sutunX(1) - 0.6;
    final x1 = DevreDunyasi.sutunX(30) + 0.6;
    void hat(double s, Color r) =>
        c.drawLine(Offset(x0, sy(s)), Offset(x1, sy(s)), Paint()
          ..color = r
          ..strokeWidth = 0.1);
    hat(0.45, _maviHat);
    hat(2.45, _kirmiziHat);
    hat(14.95, _maviHat);
    hat(16.85, _kirmiziHat);
    for (final x in [bb.left + 0.7, bb.right - 0.7]) {
      _yazi(c, '−', Offset(x, sy(1.05)), 0.75, _maviHat);
      _yazi(c, '+', Offset(x, sy(1.95)), 0.75, _kirmiziHat);
      _yazi(c, '−', Offset(x, sy(15.45)), 0.75, _maviHat);
      _yazi(c, '+', Offset(x, sy(16.35)), 0.75, _kirmiziHat);
    }

    final kenar = Paint()..color = const Color(0xFF9EA2A8);
    final ic = Paint()..color = const Color(0xFF3E4146);
    void delikCiz(Offset m) {
      c.drawRect(Rect.fromCenter(center: m, width: 0.46, height: 0.46), kenar);
      c.drawRect(Rect.fromCenter(center: m, width: 0.32, height: 0.32), ic);
    }

    for (var s = 1; s <= devreSutunSayisi; s++) {
      final x = DevreDunyasi.sutunX(s);
      for (var r = 0; r < 10; r++) {
        delikCiz(Offset(x, DevreDunyasi.satirY(r)));
      }
      if (rayDeligiVar(s)) {
        for (final u in [true, false]) {
          for (final a in [true, false]) {
            delikCiz(Offset(x, DevreDunyasi.rayY(u, a)));
          }
        }
      }
    }
    const gri = Color(0xFF8C9096);
    for (var s = 1; s <= devreSutunSayisi; s++) {
      final x = DevreDunyasi.sutunX(s);
      _yazi(c, '$s', Offset(x, sy(3.0)), 0.42, gri);
      _yazi(c, '$s', Offset(x, sy(14.4)), 0.42, gri);
    }
    for (var r = 0; r < 10; r++) {
      final y = DevreDunyasi.satirY(r);
      _yazi(c, devreSatirlari[r], Offset(bb.left + 1.2, y), 0.5, gri);
      _yazi(c, devreSatirlari[r], Offset(bb.right - 1.0, y), 0.5, gri);
    }
  }

  @override
  bool shouldRepaint(covariant DevreZeminBoyaci old) =>
      !identical(old.devre, devre) ||
      old.dunya.servoSayisi != dunya.servoSayisi ||
      old.secilenKablo != secilenKablo;
}

/// Kablo: koyu kenarli renkli egri, uclarinda fis.
void kabloCiz(Canvas c, Devre devre, DevreDunyasi dunya, int i,
    {bool secili = false, double saydamlik = 1}) {
  final k = devre.kablolar[i];
  final a = dunya.konum(k.a, devre), b = dunya.konum(k.b, devre);
  if (a == null || b == null) return;
  final renk = Color(k.renk ?? kabloRengi(k, i)).withValues(alpha: saydamlik);
  final yol = dunya.kabloYolu(a, b, k.a, k.b);
  if (secili) {
    c.drawPath(yol, _cizgi(const Color(0xFFFFEB3B).withValues(alpha: 0.85), 0.95));
  }
  c.drawPath(yol, _cizgi(Color.lerp(renk, Colors.black, 0.4)!, 0.46));
  c.drawPath(yol, _cizgi(renk, 0.32));
  c.drawPath(yol, _cizgi(Colors.white.withValues(alpha: 0.22 * saydamlik), 0.08));
  for (final u in [a, b]) {
    c.drawRect(Rect.fromCenter(center: u, width: 0.42, height: 0.42),
        Paint()..color = Color(0xFF3A3C40).withValues(alpha: saydamlik));
  }
}

// ======================================================================
// Parcalar
// ======================================================================

/// Canli katman: parcalar ve isiklar.
class DevreParcaBoyaci extends CustomPainter {
  DevreParcaBoyaci({
    required this.devre,
    required this.dunya,
    required this.sim,
    this.gizli,
  }) : super(repaint: sim);

  final Devre devre;
  final DevreDunyasi dunya;
  final DevreSimulasyonu sim;

  /// Tasinan parca (yerinde cizilmiyor; hayaleti ust katmanda).
  final String? gizli;

  @override
  void paint(Canvas c, Size size) {
    final k = size.width / dunya.genislik;
    final s = sim.sonuc;
    c.save();
    c.scale(k);
    c.clipRect(Offset.zero & dunya.boyut);
    _unoIsiklari(c, sim.kart);
    for (final p in devre.parcalar) {
      if (p.id == gizli) continue;
      devreParcasiCiz(c, p, dunya, sonuc: s, girdiler: sim.girdiler);
    }
    c.restore();
  }

  void _unoIsiklari(Canvas c, UnoKarti kart) {
    c.save();
    c.translate(DevreDunyasi.unoO.dx, DevreDunyasi.unoO.dy);
    c.scale(DevreDunyasi.unoS);
    void led(Offset o, Color renk, double p) {
      if (p <= 0) return;
      c.drawCircle(
          o,
          46,
          Paint()
            ..shader = RadialGradient(colors: [
              renk.withValues(alpha: 0.85 * p),
              renk.withValues(alpha: 0.35 * p),
              renk.withValues(alpha: 0),
            ], stops: const [0, 0.35, 1])
                .createShader(Rect.fromCircle(center: o, radius: 46)));
      c.drawRect(Rect.fromCenter(center: o, width: 24, height: 13),
          Paint()..color = Color.lerp(const Color(0xFFE8E4D6), renk, p)!);
    }

    led(UnoOlcu.onLedi, const Color(0xFF4CE070), 1);
    led(UnoOlcu.lLedi, const Color(0xFFFFA726), kart.parlaklik(13));
    c.restore();
  }

  @override
  bool shouldRepaint(covariant DevreParcaBoyaci old) =>
      !identical(old.devre, devre) ||
      old.sim != sim ||
      old.gizli != gizli ||
      old.dunya.servoSayisi != dunya.servoSayisi;
}

/// Bir parcayi (dunya biriminde) cizer. [saydamlik] hayalet icin.
void devreParcasiCiz(
  Canvas c,
  Parca p,
  DevreDunyasi dunya, {
  DevreSonucu? sonuc,
  DevreGirdileri? girdiler,
  double saydamlik = 1,
}) {
  final u = <String, Offset>{};
  for (final e in p.bacakUclari.entries) {
    final v = e.value;
    if (v == null) {
      if (!p.tur.kartDisi) return;
      continue;
    }
    final k = dunya.konum(v);
    if (k != null) u[e.key] = k;
  }
  if (saydamlik < 1) {
    c.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: saydamlik));
  }
  switch (p.tur) {
    case ParcaTuru.led:
      _led(c, p, u['anot']!, u['katot']!, sonuc?.ledler[p.id] ?? 0);
    case ParcaTuru.direnc:
      _direnc(c, p.ohm, u['u1']!, u['u2']!);
    case ParcaTuru.buton:
      _buton(c, u, girdiler?.basililar.contains(p.id) ?? false);
    case ParcaTuru.pot:
      _pot(c, u['u1']!, u['orta']!, u['u2']!, girdiler?.pot(p.id) ?? 0.5);
    case ParcaTuru.buzzer:
      _buzzer(c, u['arti']!, u['eksi']!, (sonuc?.buzzerlar[p.id] ?? 0) > 0);
    case ParcaTuru.ldr:
      _ldr(c, u['u1']!, u['u2']!);
    case ParcaTuru.sicaklik:
      _sicaklik(c, u['vcc']!, u['cikis']!, u['gnd']!);
    case ParcaTuru.mesafe:
      _mesafe(c, u['vcc']!, u['gnd']!);
    case ParcaTuru.servo:
      _servoKolu(c, dunya.servoKutusu(p.sutun), sonuc?.servolar[p.id]);
  }
  if (saydamlik < 1) c.restore();
}

void _led(Canvas c, Parca p, Offset a, Offset k, double isik) {
  final renk = ledRengi(p.renk);
  final m = Offset((a.dx + k.dx) / 2, a.dy - 1.25);
  const r = 0.78;
  final bacak = _cizgi(_bacak, 0.14);
  // Uzun bacak (anot) kivrik: gercek LED'de uzun olan bacak.
  final yon = a.dx < k.dx ? -1.0 : 1.0;
  c.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(a.dx, a.dy - 0.32)
        ..lineTo(a.dx + 0.16 * -yon, a.dy - 0.46)
        ..lineTo(m.dx + 0.3 * yon, m.dy + 0.62),
      bacak);
  c.drawLine(k, Offset(m.dx - 0.3 * yon, m.dy + 0.62), bacak);
  if (isik > 0) {
    c.drawCircle(
        m,
        2.6,
        Paint()
          ..shader = RadialGradient(colors: [
            renk.withValues(alpha: 0.8 * isik),
            renk.withValues(alpha: 0.3 * isik),
            renk.withValues(alpha: 0),
          ], stops: const [0, 0.4, 1])
              .createShader(Rect.fromCircle(center: m, radius: 2.6)));
  }
  final sonuk = Color.lerp(renk, const Color(0xFF3E4249), 0.5)!;
  final govde = Color.lerp(sonuk, renk, isik)!;
  // Katot tarafinda duz kenar.
  final daire = Path()..addOval(Rect.fromCircle(center: m, radius: r));
  final kesik = Path()
    ..addRect(Rect.fromLTRB(
        yon > 0 ? m.dx - r * 0.82 : m.dx - r - 0.1,
        m.dy - r - 0.1,
        yon > 0 ? m.dx + r + 0.1 : m.dx + r * 0.82,
        m.dy + r + 0.1));
  final kubbe = Path.combine(PathOperation.intersect, daire, kesik);
  c.drawPath(
      kubbe,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [
            Color.lerp(govde, Colors.white, 0.45 + 0.35 * isik)!,
            govde,
            Color.lerp(govde, Colors.black, 0.25)!,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: m, radius: r)));
  c.drawPath(kubbe, _cizgi(Color.lerp(govde, Colors.black, 0.35)!, 0.08));
  if (isik > 0) {
    c.drawCircle(m, r * 0.42,
        Paint()..color = Color.lerp(renk, Colors.white, 0.8)!.withValues(alpha: isik));
  }
  // "+" isareti uzun bacagin yaninda.
  _yazi(c, '+', Offset(a.dx + 0.42 * yon, a.dy - 0.62), 0.5, const Color(0xFFD32F2F),
      agirlik: FontWeight.w900);
}

const List<Color> _bantRenkleri = [
  Color(0xFF1B1B1B), Color(0xFF7A4A21), Color(0xFFD12C2C), Color(0xFFF07F13),
  Color(0xFFF5D10C), Color(0xFF2E9E4F), Color(0xFF1E6FD9), Color(0xFF8E44AD),
  Color(0xFF8E8E8E), Color(0xFFF5F5F5),
];

/// Direncin renk bantlari (iki hane + carpan).
List<Color> direncBantlari(int ohm) {
  var n = math.max(10, ohm);
  var us = 0;
  while (n >= 100) {
    n ~/= 10;
    us++;
  }
  return [_bantRenkleri[n ~/ 10], _bantRenkleri[n % 10], _bantRenkleri[us.clamp(0, 9)]];
}

void _direnc(Canvas c, int ohm, Offset a, Offset b) {
  final bacak = _cizgi(_bacak, 0.13);
  c.drawLine(a, b, bacak);
  final d = b - a;
  final l = d.distance;
  final aci = math.atan2(d.dy, d.dx);
  c.save();
  c.translate((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
  c.rotate(aci);
  final uz = math.min(2.2, l - 0.7);
  final govde = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: uz, height: 0.62),
      const Radius.circular(0.3));
  c.drawRRect(govde.shift(const Offset(0.05, 0.08)),
      Paint()..color = Colors.black.withValues(alpha: 0.18));
  c.drawRRect(
      govde,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0DDB5), Color(0xFFD8BC88)],
        ).createShader(govde.outerRect));
  final r = govde.outerRect;
  final bantlar = [...direncBantlari(ohm), const Color(0xFFC9A23A)];
  for (var i = 0; i < 4; i++) {
    final x = r.left + r.width * (i < 3 ? 0.22 + i * 0.16 : 0.8);
    c.drawRect(Rect.fromLTWH(x - 0.07, r.top, 0.14, r.height),
        Paint()..color = bantlar[i]);
  }
  c.drawRect(Rect.fromLTWH(r.left + 0.15, r.top + 0.08, r.width - 0.3, 0.1),
      Paint()..color = Colors.white.withValues(alpha: 0.25));
  c.restore();
}

void _buton(Canvas c, Map<String, Offset> u, bool basili) {
  final noktalar = u.values.toList();
  var m = Offset.zero;
  for (final n in noktalar) {
    m += n;
  }
  m = m / noktalar.length.toDouble();
  for (final n in noktalar) {
    c.drawLine(n, m + (n - m) * 0.6, _cizgi(_bacak, 0.16));
  }
  final govde = RRect.fromRectAndRadius(
      Rect.fromCenter(center: m, width: 2.3, height: 2.3), const Radius.circular(0.25));
  c.drawRRect(govde.shift(const Offset(0.06, 0.12)),
      Paint()..color = Colors.black.withValues(alpha: 0.25));
  c.drawRRect(govde, Paint()..color = const Color(0xFF34373C));
  c.drawRRect(govde.deflate(0.18), Paint()..color = const Color(0xFF45494F));
  for (final d in const [Offset(-0.8, -0.8), Offset(0.8, -0.8), Offset(-0.8, 0.8), Offset(0.8, 0.8)]) {
    c.drawCircle(m + d, 0.12, Paint()..color = const Color(0xFF26282C));
  }
  final r = basili ? 0.62 : 0.74;
  c.drawCircle(m + const Offset(0, 0.06), r + 0.06,
      Paint()..color = Colors.black.withValues(alpha: 0.3));
  c.drawCircle(
      m,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: basili
              ? const [Color(0xFFB71C1C), Color(0xFF8E1616)]
              : const [Color(0xFFFF6B5E), Color(0xFFD32F2F)],
        ).createShader(Rect.fromCircle(center: m, radius: r)));
}

void _pot(Canvas c, Offset u1, Offset orta, Offset u2, double konum) {
  final bacak = _cizgi(_bacak, 0.15);
  final govdeM = Offset(orta.dx, orta.dy - 1.05);
  for (final n in [u1, orta, u2]) {
    c.drawLine(n, Offset(n.dx, govdeM.dy + 0.4), bacak);
  }
  final govde = RRect.fromRectAndRadius(
      Rect.fromCenter(center: govdeM, width: 3.0, height: 1.1), const Radius.circular(0.25));
  c.drawRRect(govde, Paint()..color = const Color(0xFF1E5AA8));
  final km = Offset(orta.dx, orta.dy - 2.0);
  c.drawCircle(km + const Offset(0.05, 0.12), 1.25,
      Paint()..color = Colors.black.withValues(alpha: 0.25));
  c.drawCircle(
      km,
      1.2,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.35),
          colors: [Color(0xFFF2F3F5), Color(0xFFB8BEC6)],
        ).createShader(Rect.fromCircle(center: km, radius: 1.2)));
  c.drawCircle(km, 1.2, _cizgi(const Color(0xFF8A9099), 0.08));
  // Gosterge: -135..+135 derece (0 = solda, 1 = sagda).
  final aci = (-135 + 270 * konum.clamp(0, 1)) * math.pi / 180 - math.pi / 2;
  c.drawLine(km, km + Offset(math.cos(aci), math.sin(aci)) * 1.0,
      _cizgi(const Color(0xFF263238), 0.2));
}

void _buzzer(Canvas c, Offset arti, Offset eksi, bool caliyor) {
  final m = (arti + eksi) / 2;
  if (caliyor) {
    for (var i = 1; i <= 3; i++) {
      c.drawCircle(m, 1.5 + i * 0.45,
          _cizgi(const Color(0xFF7E57C2).withValues(alpha: 0.6 - i * 0.15), 0.12));
    }
  }
  c.drawCircle(m + const Offset(0.06, 0.12), 1.55,
      Paint()..color = Colors.black.withValues(alpha: 0.25));
  c.drawCircle(
      m,
      1.5,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.35),
          colors: [Color(0xFF4A4D52), Color(0xFF1C1C1E)],
        ).createShader(Rect.fromCircle(center: m, radius: 1.5)));
  c.drawCircle(m, 1.0, _cizgi(const Color(0xFF111214), 0.08));
  c.drawCircle(m, 0.22, Paint()..color = const Color(0xFF0B0B0C));
  _yazi(c, '+', arti + const Offset(0, -0.75), 0.6, const Color(0xFFFF8A80),
      agirlik: FontWeight.w900);
}

void _ldr(Canvas c, Offset a, Offset b) {
  final m = Offset((a.dx + b.dx) / 2, a.dy - 1.0);
  final bacak = _cizgi(_bacak, 0.13);
  c.drawLine(a, m + const Offset(-0.45, 0.5), bacak);
  c.drawLine(b, m + const Offset(0.45, 0.5), bacak);
  c.drawCircle(m, 0.88, Paint()..color = const Color(0xFFF2D9A0));
  c.drawCircle(m, 0.88, _cizgi(const Color(0xFFB08A4A), 0.07));
  final yol = Path()..moveTo(m.dx - 0.55, m.dy - 0.45);
  for (var i = 0; i < 5; i++) {
    final y = m.dy - 0.45 + i * 0.22;
    yol
      ..lineTo(m.dx + (i.isEven ? 0.55 : -0.55), y)
      ..lineTo(m.dx + (i.isEven ? 0.55 : -0.55), y + 0.22);
  }
  c.drawPath(yol, _cizgi(const Color(0xFFB4442B), 0.09));
}

void _sicaklik(Canvas c, Offset vcc, Offset cikis, Offset gnd) {
  final bacak = _cizgi(_bacak, 0.13);
  final m = Offset(cikis.dx, cikis.dy - 1.3);
  for (final n in [vcc, cikis, gnd]) {
    c.drawLine(n, Offset(n.dx, m.dy + 0.4), bacak);
  }
  final r = Rect.fromCenter(center: m, width: 2.4, height: 1.3);
  final govde = Path()
    ..moveTo(r.left, r.bottom)
    ..lineTo(r.left, r.top + 0.5)
    ..quadraticBezierTo(r.left, r.top, r.left + 0.6, r.top)
    ..lineTo(r.right - 0.6, r.top)
    ..quadraticBezierTo(r.right, r.top, r.right, r.top + 0.5)
    ..lineTo(r.right, r.bottom)
    ..close();
  c.drawPath(govde, Paint()..color = const Color(0xFF26282C));
  _yazi(c, '°C', m, 0.62, const Color(0xFFE0E0E0));
}

void _mesafe(Canvas c, Offset vcc, Offset gnd) {
  final pinY = vcc.dy;
  final r = Rect.fromLTRB(vcc.dx - 1.4, pinY - 4.4, gnd.dx + 1.4, pinY - 0.55);
  c.drawRRect(RRect.fromRectAndRadius(r.shift(const Offset(0.06, 0.12)), const Radius.circular(0.2)),
      Paint()..color = Colors.black.withValues(alpha: 0.25));
  c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(0.2)),
      Paint()..color = const Color(0xFF1565C0));
  for (final dx in [0.25, 0.75]) {
    final m = Offset(r.left + r.width * dx, r.top + 1.75);
    c.drawCircle(m, 1.25, Paint()..color = const Color(0xFFCFD5DC));
    c.drawCircle(m, 1.0, Paint()..color = const Color(0xFF3C4148));
    c.drawCircle(m, 0.65, _cizgi(const Color(0xFF5B616A), 0.1));
  }
  const adlar = ['VCC', 'TRIG', 'ECHO', 'GND'];
  for (var i = 0; i < 4; i++) {
    final x = vcc.dx + i * 1.0;
    c.drawLine(Offset(x, pinY), Offset(x, r.bottom), _cizgi(const Color(0xFFD4A63A), 0.16));
    _yazi(c, adlar[i], Offset(x, r.bottom - 0.4), 0.28, Colors.white);
  }
}

/// Servonun durgun kismi: govde, kablolar, fis.
void servoZemini(Canvas c, Parca p, DevreDunyasi dunya) {
  final r = dunya.servoKutusu(p.sutun);
  final renkler = [const Color(0xFF6D4C41), const Color(0xFFE53935), const Color(0xFFFB8C00)];
  final bacaklar = ['gnd', 'vcc', 'sinyal'];
  for (var i = 0; i < 3; i++) {
    final u = dunya.servoUcu(p, bacaklar[i])!;
    final g = Offset(r.left, r.center.dy - 0.4 + i * 0.4);
    c.drawPath(
        Path()
          ..moveTo(u.dx + 0.5, u.dy)
          ..cubicTo(u.dx + 2.2, u.dy, g.dx - 1.6, g.dy, g.dx, g.dy),
        _cizgi(renkler[i], 0.28));
  }
  final fis = Rect.fromLTRB(
      dunya.servoUcu(p, 'gnd')!.dx - 0.4,
      dunya.servoUcu(p, 'gnd')!.dy - 0.55,
      dunya.servoUcu(p, 'sinyal')!.dx + 0.5,
      dunya.servoUcu(p, 'sinyal')!.dy + 0.55);
  c.drawRRect(RRect.fromRectAndRadius(fis, const Radius.circular(0.15)),
      Paint()..color = const Color(0xFF26282C));
  for (final b in bacaklar) {
    final u = dunya.servoUcu(p, b)!;
    c.drawRect(Rect.fromCenter(center: u, width: 0.36, height: 0.36),
        Paint()..color = const Color(0xFF9EA2A8));
  }
  final govde = RRect.fromRectAndRadius(r, const Radius.circular(0.5));
  c.drawRRect(govde.shift(const Offset(0.08, 0.16)),
      Paint()..color = Colors.black.withValues(alpha: 0.22));
  c.drawRRect(
      govde,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2F6FD6), Color(0xFF1E4FA0)],
        ).createShader(r));
  // Kulaklar (vida tablalari).
  for (final x in [r.left - 0.9, r.right - 0.0]) {
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, r.center.dy - 0.9, 0.9, 1.8), const Radius.circular(0.2)),
        Paint()..color = const Color(0xFF1E4FA0));
  }
  _yazi(c, 'SERVO', Offset(r.left + r.width * 0.33, r.center.dy), 0.7,
      Colors.white.withValues(alpha: 0.85));
}

void _servoKolu(Canvas c, Rect r, int? aci) {
  final m = Offset(r.right - 2.4, r.center.dy);
  c.drawCircle(m, 1.3, Paint()..color = const Color(0xFF173E7D));
  // 0 derece sola, 180 saga (ustten bakis).
  final a = (180 - (aci ?? 90)) * math.pi / 180;
  final uc = m + Offset(math.cos(a), -math.sin(a)) * 2.1;
  c.drawLine(m, uc, _cizgi(Colors.black.withValues(alpha: 0.25), 0.95));
  c.drawLine(m, uc, _cizgi(aci == null ? const Color(0xFFDADDE2) : Colors.white, 0.8));
  c.drawCircle(m, 0.5, Paint()..color = const Color(0xFFE6E8EB));
  c.drawCircle(m, 0.2, Paint()..color = const Color(0xFF9EA2A8));
}
