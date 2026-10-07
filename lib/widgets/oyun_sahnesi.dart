import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/game_model.dart';
import '../theme.dart';
import '../utils/lang.dart';
import 'oyun_kimligi.dart';

/// Oyun kartlarinin CANLI KAPAGI: her oyunun kendi icinden bir an.
///
/// NEDEN EKRAN GORUNTUSU DEGIL
/// ---------------------------
/// Kartlarda once oyunlarin gercek ekran goruntuleri vardi. Beyaz arayuz
/// ekranlari kucuk bir kartta soluk ve bos duruyordu; cocuk oyunu
/// goruntuden tanimiyordu. Bir surum de yalnizca simge koydu — oyunu
/// anlatmiyordu (Ekim 2026 geri bildirimi: "gorseller oyunlarin
/// icerigine uygun olsun").
///
/// Burada her oyunun ANA HAREKETI kodla ciziliyor ve dongude oynuyor:
/// Boru Bulmacasi'nda bir boru donup yerine oturuyor ve su akiyor,
/// Labirent'te robot hazineye yuruyor, Hata Avcisi'nda bocek kod
/// satirinda geziyor, Satranc'ta at L cizerek ziplıyor...
///
/// Resim dosyasi yok: uygulama buyumuyor, her olcude keskin, dort dilde
/// ayni. Cihazda "hareketi azalt" aciksa sahne tek bir karede duruyor.
///
/// Tum sahneler 200x120'lik sanal bir tuvalde ciziliyor ve verilen
/// alana "cover" mantigiyla olcekleniyor; buyuk Gunun Gorevi kartinda da
/// ayni ressam kullaniliyor.
class OyunSahnesi extends StatefulWidget {
  const OyunSahnesi({
    super.key,
    required this.tur,
    required this.lang,
    this.sure = const Duration(milliseconds: 3600),
  });

  final GameType tur;
  final String lang;
  final Duration sure;

  /// Hareket kapaliyken gosterilen an (sahnenin "hikayesini" anlatan kare).
  static const double duranAn = 0.62;

  @override
  State<OyunSahnesi> createState() => _OyunSahnesiState();
}

class _OyunSahnesiState extends State<OyunSahnesi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.sure);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final az = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (az) {
      _c.stop();
      _c.value = OyunSahnesi.duranAn;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
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
          painter: _SahneRessami(widget.tur, widget.lang, _c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Sahnenin ressami. Testlerde dogrudan da kullaniliyor.
class _SahneRessami extends CustomPainter {
  _SahneRessami(this.tur, this.lang, this.t);

  final GameType tur;
  final String lang;
  final double t;

  static const double _w = 200, _h = 120;

  Color get renk => OyunKimligi.renk(tur);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // "cover": sahne alani tamamen doldursun, tasan kenar kirpilsin.
    final s = math.max(size.width / _w, size.height / _h);
    canvas.translate((size.width - _w * s) / 2, (size.height - _h * s) / 2);
    canvas.scale(s);
    _zemin(canvas);
    switch (tur) {
      case GameType.pipesPuzzle:
        _boru(canvas);
      case GameType.mazeExplorer:
        _labirent(canvas);
      case GameType.bugHunter:
        _hataAvcisi(canvas);
      case GameType.chess:
        _satranc(canvas);
      case GameType.quiz:
        _bilgiYarismasi(canvas);
      case GameType.robotSimulator:
        _robotSimulator(canvas);
      case GameType.leftRightCoding:
        _sagimSolum(canvas);
      case GameType.coordinates:
        _koordinat(canvas);
      case GameType.blockCoding:
        _kodBloklari(canvas);
      case GameType.sequencing:
        _komutDizilimi(canvas);
      case GameType.wordMatch:
        _kelimeAvi(canvas);
      case GameType.colorCoding:
        _renkliKodlar(canvas);
      case GameType.matchingGame:
        _arduinoEslestirme(canvas);
      case GameType.patternDetective:
        _kodDedektifi(canvas);
      case GameType.variableMaster:
        _degiskenUstasi(canvas);
      case GameType.arduinoSimulator:
        _arduinoAtolyesi(canvas);
      default:
        _robot(canvas, const Offset(100, 62), 26, sallan: true);
    }
    canvas.restore();
  }

  // ------------------------------------------------------------ yardimcilar

  Paint _boya(Color c) => Paint()..color = c;

  Paint _cizgi(Color c, double w, {StrokeCap cap = StrokeCap.round}) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = cap
    ..strokeJoin = StrokeJoin.round;

  Color _acik(double a) => Color.lerp(renk, Colors.white, a)!;
  Color _koyu(double a) => Color.lerp(renk, const Color(0xFF14102B), a)!;

  void _zemin(Canvas c) {
    final r = const Offset(0, 0) & const Size(_w, _h);
    c.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_acik(0.80), _acik(0.92)],
        ).createShader(r),
    );
    // Soluk isik lekeleri.
    c.drawCircle(const Offset(178, 14), 34, _boya(Colors.white.withValues(alpha: 0.45)));
    c.drawCircle(const Offset(14, 112), 26, _boya(_acik(0.6).withValues(alpha: 0.35)));
  }

  void _yazi(Canvas c, String metin, Offset merkez,
      {double boy = 10,
      Color renk = Colors.white,
      FontWeight kalinlik = FontWeight.w800}) {
    final tp = TextPainter(
      text: TextSpan(
        text: metin,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: boy,
          fontWeight: kalinlik,
          color: renk,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, merkez - Offset(tp.width / 2, tp.height / 2));
  }

  RRect _rr(double x, double y, double w, double h, double r) =>
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

  /// Kucuk golgeli yuvarlak dikdortgen (kartlar, bloklar).
  void _kutu(Canvas c, RRect r, Color dolgu, {double golge = 2.5}) {
    c.drawRRect(r.shift(Offset(0, golge)), _boya(Colors.black.withValues(alpha: 0.13)));
    c.drawRRect(r, _boya(dolgu));
  }

  /// 0..1 araliginda yumusak gecis.
  double _yumusak(double a, double b) {
    final x = ((t - a) / (b - a)).clamp(0.0, 1.0);
    return x * x * (3 - 2 * x);
  }

  /// Uygulamanin kucuk robotu (Devi'nin sade cizimi).
  void _robot(Canvas c, Offset m, double boy, {bool sallan = false, double yon = 0}) {
    c.save();
    c.translate(m.dx, m.dy);
    if (sallan) c.translate(0, math.sin(t * math.pi * 4) * 1.5);
    c.rotate(yon);
    final b = boy;
    // anten
    c.drawLine(Offset(0, -b * .55), Offset(0, -b * .75), _cizgi(const Color(0xFF455A64), b * .06));
    c.drawCircle(Offset(0, -b * .78), b * .08, _boya(const Color(0xFFFF5252)));
    // govde
    _kutu(c, _rr(-b * .45, -b * .55, b * .9, b * .75, b * .22), const Color(0xFFFFB300), golge: b * .06);
    // yuz paneli
    c.drawRRect(_rr(-b * .33, -b * .42, b * .66, b * .42, b * .14), _boya(const Color(0xFF263238)));
    c.drawCircle(Offset(-b * .14, -b * .22), b * .08, _boya(const Color(0xFF64FFDA)));
    c.drawCircle(Offset(b * .14, -b * .22), b * .08, _boya(const Color(0xFF64FFDA)));
    // ayaklar
    c.drawRRect(_rr(-b * .32, b * .2, b * .22, b * .14, b * .05), _boya(const Color(0xFF546E7A)));
    c.drawRRect(_rr(b * .1, b * .2, b * .22, b * .14, b * .05), _boya(const Color(0xFF546E7A)));
    c.restore();
  }

  void _yildiz(Canvas c, Offset m, double r, Color col) {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final rr = i.isEven ? r : r * 0.45;
      final pt = m + Offset(math.cos(a) * rr, math.sin(a) * rr);
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    c.drawPath(p..close(), _boya(col));
  }

  void _parilti(Canvas c, Offset m, double guc) {
    if (guc <= 0) return;
    final p = _cizgi(Colors.white.withValues(alpha: guc), 2);
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      c.drawLine(m + Offset(math.cos(a), math.sin(a)) * 9,
          m + Offset(math.cos(a), math.sin(a)) * (12 + 4 * guc), p);
    }
  }

  // ---------------------------------------------------------------- sahneler

  /// Boru Bulmacasi: bir boru parcasi donup yerine oturuyor, su
  /// musluktan cicege akiyor, cicek aciyor.
  void _boru(Canvas c) {
    const k = 34.0, x0 = 30.0, y0 = 22.0;
    // karolar
    for (var r = 0; r < 2; r++) {
      for (var col = 0; col < 4; col++) {
        c.drawRRect(_rr(x0 + col * (k + 4), y0 + r * (k + 4), k, k, 7),
            _boya(Colors.white.withValues(alpha: 0.7)));
      }
    }
    Offset mk(int col, int r) =>
        Offset(x0 + col * (k + 4) + k / 2, y0 + r * (k + 4) + k / 2);
    final yol = Path()
      ..moveTo(10, mk(0, 0).dy)
      ..lineTo(mk(1, 0).dx, mk(0, 0).dy)
      ..lineTo(mk(1, 1).dx, mk(1, 1).dy)
      ..lineTo(mk(3, 1).dx + 26, mk(3, 1).dy);
    final don = _yumusak(0.0, 0.18);
    // donen kose karosu: once yanlis yonde, sonra yerine oturuyor
    void boruCiz(Path p, double kalin, Color col) =>
        c.drawPath(p, _cizgi(col, kalin, cap: StrokeCap.butt));
    // sabit borular (kose haric)
    final sabit = Path()
      ..moveTo(10, mk(0, 0).dy)
      ..lineTo(mk(1, 0).dx - k / 2, mk(0, 0).dy)
      ..moveTo(mk(1, 1).dx, mk(1, 1).dy - k / 2)
      ..lineTo(mk(1, 1).dx, mk(1, 1).dy)
      ..lineTo(mk(3, 1).dx + 26, mk(3, 1).dy);
    boruCiz(sabit, 13, const Color(0xFF455A64));
    boruCiz(sabit, 8, const Color(0xFFB0BEC5));
    c.save();
    final km = mk(1, 0);
    c.translate(km.dx, km.dy);
    c.rotate((1 - don) * -math.pi / 2);
    final kose = Path()
      ..moveTo(-k / 2, 0)
      ..lineTo(0, 0)
      ..lineTo(0, k / 2);
    boruCiz(kose, 13, const Color(0xFF455A64));
    boruCiz(kose, 8, const Color(0xFFB0BEC5));
    c.restore();
    // su
    final akis = _yumusak(0.22, 0.78);
    if (akis > 0) {
      for (final m in yol.computeMetrics()) {
        final parca = m.extractPath(0, m.length * akis);
        c.drawPath(parca, _cizgi(const Color(0xFF29B6F6), 5, cap: StrokeCap.round));
        final uc = m.getTangentForOffset(m.length * akis)?.position;
        if (uc != null && akis < 1) {
          c.drawCircle(uc + const Offset(3, 0), 2.4, _boya(const Color(0xFF81D4FA)));
        }
      }
    }
    // musluk
    _kutu(c, _rr(2, mk(0, 0).dy - 9, 12, 18, 4), const Color(0xFF78909C));
    // cicek
    final acil = _yumusak(0.78, 0.9);
    final cm = Offset(mk(3, 1).dx + 30, mk(3, 1).dy - 6);
    c.drawLine(cm + const Offset(0, 14), cm, _cizgi(const Color(0xFF2E7D32), 2.5));
    c.drawOval(Rect.fromCenter(center: cm + const Offset(-5, 6), width: 9, height: 5), _boya(const Color(0xFF66BB6A)));
    final r = 3 + 5 * acil;
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5 + t;
      c.drawCircle(cm + Offset(math.cos(a), math.sin(a)) * r * .9, r * .6, _boya(const Color(0xFFFF7043)));
    }
    c.drawCircle(cm, r * .5, _boya(const Color(0xFFFFEB3B)));
  }

  /// Labirent Kasifi: robot labirentte hazineye yuruyor.
  void _labirent(Canvas c) {
    final duvar = _cizgi(_koyu(0.15), 6);
    final d = Path()
      ..moveTo(20, 14)..lineTo(180, 14)..lineTo(180, 106)..lineTo(20, 106)..close()
      ..moveTo(60, 14)..lineTo(60, 70)
      ..moveTo(100, 50)..lineTo(100, 106)
      ..moveTo(140, 14)..lineTo(140, 70);
    c.drawPath(d, duvar);
    final yol = Path()
      ..moveTo(40, 92)..lineTo(40, 32)..lineTo(42, 30)..lineTo(80, 30)
      ..lineTo(80, 88)..lineTo(120, 88)..lineTo(120, 30)..lineTo(160, 30)..lineTo(160, 86);
    final m = yol.computeMetrics().first;
    final ilerleme = _yumusak(0.0, 0.82);
    // gecilen iz
    c.drawPath(m.extractPath(0, m.length * ilerleme),
        _cizgi(Colors.white.withValues(alpha: 0.9), 3)..strokeCap = StrokeCap.round);
    // hazine
    final hz = const Offset(160, 90);
    _kutu(c, _rr(hz.dx - 11, hz.dy - 8, 22, 15, 3), const Color(0xFF8D6E63));
    c.drawRect(Rect.fromLTWH(hz.dx - 11, hz.dy - 3, 22, 3), _boya(const Color(0xFFFFC107)));
    _parilti(c, hz + const Offset(0, -6), _yumusak(0.82, 0.92) * (1 - _yumusak(0.95, 1)));
    final p = m.getTangentForOffset(m.length * ilerleme)!.position;
    _robot(c, p + const Offset(0, -2), 17);
  }

  /// Hata Avcisi: kod editoru, hatali satir kirmizi, bocek satirda
  /// geziyor, buyutec pesinde.
  void _hataAvcisi(Canvas c) {
    _kutu(c, _rr(14, 10, 172, 100, 10), const Color(0xFF241B35), golge: 3);
    const satirlar = [
      (0.55, Color(0xFFB388FF)),
      (0.75, Color(0xFF4FC3F7)),
      (0.62, Color(0xFFFF8A80)),
      (0.85, Color(0xFFAED581)),
      (0.45, Color(0xFFFFD54F)),
    ];
    for (var i = 0; i < satirlar.length; i++) {
      final y = 22.0 + i * 17;
      _yazi(c, '${i + 1}', Offset(24, y + 3), boy: 7, renk: Colors.white38);
      if (i == 2) {
        c.drawRRect(_rr(32, y - 3, 148, 13, 3), _boya(const Color(0xFFFF5252).withValues(alpha: 0.28)));
      }
      final (oran, col) = satirlar[i];
      c.drawRRect(_rr(38 + (i == 1 || i == 3 ? 10 : 0), y, 130 * oran, 6, 3), _boya(col));
    }
    // bocek
    final bx = 70 + 60 * (0.5 - 0.5 * math.cos(t * math.pi * 2));
    final by = 22.0 + 2 * 17 + 3;
    final yuz = math.sin(t * math.pi * 2) >= 0 ? 1.0 : -1.0;
    c.save();
    c.translate(bx, by);
    c.scale(yuz, 1);
    final bacak = _cizgi(const Color(0xFF1A1A1A), 1.3);
    final sal = math.sin(t * math.pi * 24) * 1.5;
    for (final dy in [-3.0, 0.0, 3.0]) {
      c.drawLine(Offset(-2, dy), Offset(-7, dy - 3 + sal), bacak);
      c.drawLine(Offset(2, dy), Offset(7, dy - 3 - sal), bacak);
    }
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: 11, height: 13), _boya(const Color(0xFFE53935)));
    c.drawLine(const Offset(0, -6), const Offset(0, 6), _cizgi(const Color(0xFF1A1A1A), 1));
    c.drawCircle(const Offset(0, -8), 3.5, _boya(const Color(0xFF1A1A1A)));
    c.drawCircle(const Offset(-2.5, -1), 1.5, _boya(const Color(0xFF1A1A1A)));
    c.drawCircle(const Offset(2.5, 2.5), 1.5, _boya(const Color(0xFF1A1A1A)));
    c.restore();
    // buyutec, bocegi biraz geriden izliyor
    final gx = 70 + 60 * (0.5 - 0.5 * math.cos((t - 0.08) * math.pi * 2));
    final g = Offset(gx + 4, by - 14);
    c.drawLine(g + const Offset(9, 9), g + const Offset(20, 20), _cizgi(const Color(0xFF8D6E63), 5));
    c.drawCircle(g, 12, _boya(Colors.white.withValues(alpha: 0.25)));
    c.drawCircle(g, 12, _cizgi(const Color(0xFFFFD54F), 3.5));
  }

  /// At silueti (satranc). Merkez tabanin ortasi.
  void _at(Canvas c, Offset m, double b, Color dolgu, Color kenar) {
    final p = Path()
      ..moveTo(-0.38 * b, 0)
      ..lineTo(0.42 * b, 0)
      ..lineTo(0.36 * b, -0.14 * b)
      ..lineTo(0.24 * b, -0.16 * b)
      ..cubicTo(0.30 * b, -0.45 * b, 0.32 * b, -0.70 * b, 0.10 * b, -0.92 * b)
      ..lineTo(0.02 * b, -1.04 * b)
      ..lineTo(-0.06 * b, -0.92 * b)
      ..cubicTo(-0.30 * b, -0.86 * b, -0.42 * b, -0.70 * b, -0.46 * b, -0.56 * b)
      ..lineTo(-0.40 * b, -0.48 * b)
      ..lineTo(-0.16 * b, -0.58 * b)
      ..cubicTo(-0.28 * b, -0.40 * b, -0.32 * b, -0.26 * b, -0.30 * b, -0.16 * b)
      ..lineTo(-0.36 * b, -0.14 * b)
      ..close();
    c.save();
    c.translate(m.dx, m.dy);
    c.drawPath(p.shift(const Offset(0, 2)), _boya(Colors.black.withValues(alpha: 0.18)));
    c.drawPath(p, _boya(dolgu));
    c.drawPath(p, _cizgi(kenar, 1.6));
    c.drawCircle(Offset(-0.05 * b, -0.74 * b), 0.05 * b, _boya(kenar));
    c.restore();
  }

  /// Satranc: at L cizerek ziplıyor; gidebilecegi kare noktali.
  void _satranc(Canvas c) {
    const kare = 22.0, x0 = 45.0, y0 = 16.0;
    for (var r = 0; r < 4; r++) {
      for (var col = 0; col < 5; col++) {
        c.drawRect(Rect.fromLTWH(x0 + col * kare, y0 + r * kare, kare, kare),
            _boya((r + col).isEven ? const Color(0xFFF0D9B5) : const Color(0xFFB58863)));
      }
    }
    c.drawRect(const Rect.fromLTWH(x0, y0, kare * 5, kare * 4), _cizgi(const Color(0xFF5D4037), 2));
    Offset mk(int col, int r) => Offset(x0 + col * kare + kare / 2, y0 + r * kare + kare / 2);
    final bas = mk(1, 3), son = mk(2, 1);
    // hedef karesi (oyundaki hamle noktasi)
    c.drawCircle(son, 4, _boya(Colors.black.withValues(alpha: 0.3)));
    c.drawCircle(mk(3, 2), 4, _boya(Colors.black.withValues(alpha: 0.3)));
    // L izi
    final iz = Path()..moveTo(bas.dx, bas.dy)..lineTo(bas.dx, son.dy)..lineTo(son.dx, son.dy);
    for (final m in iz.computeMetrics()) {
      for (double d = 0; d < m.length; d += 6) {
        c.drawPath(m.extractPath(d, math.min(d + 3, m.length)), _cizgi(const Color(0xFFFFB300), 2));
      }
    }
    // rakip vezir
    _vezir(c, mk(4, 0) + const Offset(0, 7), 14);
    final z = _yumusak(0.25, 0.65);
    final p = Offset.lerp(bas, son, z)! + Offset(0, -math.sin(z * math.pi) * 26) + const Offset(0, 9);
    _at(c, p, 22, Colors.white, const Color(0xFF263238));
  }

  /// Bilgi Yarismasi: soru balonu ve dort renkli sik; dogru sik parliyor.
  void _bilgiYarismasi(Canvas c) {
    _kutu(c, _rr(40, 8, 120, 34, 12), Colors.white);
    _yazi(c, '?', const Offset(100, 25), boy: 24, renk: renk);
    const renkler = [Color(0xFFFF6B6B), Color(0xFF4D96FF), Color(0xFFFFA726), Color(0xFF26C6A6)];
    final dogru = _yumusak(0.45, 0.55);
    for (var i = 0; i < 4; i++) {
      final x = 30.0 + (i % 2) * 74, y = 52.0 + (i ~/ 2) * 30;
      final buyu = i == 3 ? 1 + 0.06 * math.sin(dogru * math.pi) : 1.0;
      c.save();
      c.translate(x + 33, y + 12);
      c.scale(buyu);
      _kutu(c, _rr(-33, -12, 66, 24, 9), renkler[i]);
      c.drawCircle(const Offset(-21, 0), 6, _boya(Colors.white.withValues(alpha: 0.85)));
      c.drawRRect(_rr(-10, -3, 34, 6, 3), _boya(Colors.white.withValues(alpha: 0.7)));
      if (i == 3 && dogru > 0) {
        final ok = Path()..moveTo(-24, 0)..lineTo(-21.5, 2.5)..lineTo(-17.5, -3);
        c.drawPath(ok, _cizgi(renkler[3], 2.2));
      }
      c.restore();
    }
    _parilti(c, const Offset(137, 94), dogru * (1 - _yumusak(0.85, 1)));
  }

  /// Robot Simulatoru: komut seridi ve izgarada komutlari uygulayan robot.
  void _robotSimulator(Canvas c) {
    const k = 22.0, x0 = 56.0, y0 = 14.0;
    for (var r = 0; r < 4; r++) {
      for (var col = 0; col < 5; col++) {
        c.drawRRect(_rr(x0 + col * k + 1, y0 + r * k + 1, k - 2, k - 2, 4),
            _boya(Colors.white.withValues(alpha: (r + col).isEven ? 0.85 : 0.6)));
      }
    }
    // bayrak
    final b = Offset(x0 + 4 * k + k / 2, y0 + k / 2);
    c.drawLine(b + const Offset(-3, 8), b + const Offset(-3, -8), _cizgi(const Color(0xFF455A64), 1.6));
    c.drawPath(Path()..moveTo(b.dx - 3, b.dy - 8)..lineTo(b.dx + 7, b.dy - 5)..lineTo(b.dx - 3, b.dy - 2)..close(),
        _boya(const Color(0xFFFF5252)));
    // komut seridi: 3 kez ileri, don, 4 kez ileri
    const komutlar = ['ileri', 'ileri', 'ileri', 'don', 'ileri4'];
    final yol = Path()
      ..moveTo(x0 + k / 2, y0 + 3 * k + k / 2)
      ..lineTo(x0 + k / 2, y0 + k / 2)
      ..lineTo(x0 + 4 * k + k / 2 - 14, y0 + k / 2);
    final m = yol.computeMetrics().first;
    final f = _yumusak(0.0, 0.85);
    final dikey = 3 * k;
    final gidilen = m.length * f;
    final aktif = gidilen < dikey ? (gidilen / k).floor().clamp(0, 2) : (gidilen < dikey + 4 ? 3 : 4);
    for (var i = 0; i < komutlar.length; i++) {
      final ak = i == aktif && f < 1;
      _kutu(c, _rr(8, 10 + i * 20.0, 38, 16, 5), ak ? renk : Colors.white, golge: 1.5);
      _simge(c, komutlar[i], Offset(27, 18 + i * 20.0), ak ? Colors.white : renk);
    }
    c.drawPath(m.extractPath(0, gidilen), _cizgi(renk.withValues(alpha: 0.45), 3));
    final p = m.getTangentForOffset(gidilen)!.position;
    _robot(c, p + const Offset(0, 2), 15);
    _parilti(c, b, _yumusak(0.85, 0.92) * (1 - _yumusak(0.95, 1)));
  }

  /// Komut simgeleri (yazi tipine bagli olmasin diye cizim):
  /// ileri = ucgen, don = donus oku, bayrak, ileri4 = ucgen + "×4".
  void _simge(Canvas c, String ad, Offset m, Color col) {
    switch (ad) {
      case 'ileri':
      case 'ileri4':
        final dx = ad == 'ileri4' ? -7.0 : 0.0;
        c.drawPath(
            Path()
              ..moveTo(m.dx + dx, m.dy - 5)
              ..lineTo(m.dx + dx + 5, m.dy + 4)
              ..lineTo(m.dx + dx - 5, m.dy + 4)
              ..close(),
            _boya(col));
        if (ad == 'ileri4') _yazi(c, 'x4', m + const Offset(7, 0), boy: 8, renk: col);
      case 'don':
        c.drawArc(Rect.fromCircle(center: m, radius: 5), -math.pi * 0.2, math.pi * 1.5, false, _cizgi(col, 2));
        final uc = m + Offset(math.cos(-math.pi * 0.2), math.sin(-math.pi * 0.2)) * 5;
        c.drawPath(
            Path()
              ..moveTo(uc.dx - 3, uc.dy - 3)
              ..lineTo(uc.dx + 3, uc.dy - 1)
              ..lineTo(uc.dx, uc.dy + 3)
              ..close(),
            _boya(col));
      case 'bayrak':
        c.drawLine(m + const Offset(-4, 6), m + const Offset(-4, -6), _cizgi(col, 1.8));
        c.drawPath(
            Path()
              ..moveTo(m.dx - 4, m.dy - 6)
              ..lineTo(m.dx + 6, m.dy - 3)
              ..lineTo(m.dx - 4, m.dy)
              ..close(),
            _boya(col));
    }
  }

  /// Vezir (taban ortasi m).
  void _vezir(Canvas c, Offset m, double b) {
    final p = Path()
      ..moveTo(m.dx - b * .45, m.dy)
      ..lineTo(m.dx + b * .45, m.dy)
      ..lineTo(m.dx + b * .35, m.dy - b * .25)
      ..lineTo(m.dx + b * .5, m.dy - b * .8)
      ..lineTo(m.dx + b * .2, m.dy - b * .45)
      ..lineTo(m.dx, m.dy - b * .95)
      ..lineTo(m.dx - b * .2, m.dy - b * .45)
      ..lineTo(m.dx - b * .5, m.dy - b * .8)
      ..lineTo(m.dx - b * .35, m.dy - b * .25)
      ..close();
    c.drawPath(p, _boya(const Color(0xFF212121)));
    for (final x in [-.5, 0.0, .5]) {
      c.drawCircle(Offset(m.dx + b * x, m.dy - b * (x == 0 ? .98 : .82)), b * .08, _boya(const Color(0xFF212121)));
    }
  }

  /// Sag-Solum: kedi ortada, sol/sag okulari sirayla yaniyor, kedi o
  /// yone kayiyor; hedef yildiz.
  void _sagimSolum(Canvas c) {
    // yol
    c.drawRRect(_rr(18, 50, 164, 22, 11), _boya(Colors.white.withValues(alpha: 0.75)));
    for (var i = 0; i < 7; i++) {
      c.drawCircle(Offset(30 + i * 23.0, 61), 2, _boya(renk.withValues(alpha: 0.35)));
    }
    _yildiz(c, const Offset(168, 61), 8, const Color(0xFFFFC107));
    // kedi saga dogru zikzakla ilerliyor
    final saga = math.sin(t * math.pi * 2) > -0.2;
    final x = 40 + 110 * _yumusak(0.05, 0.85) + (saga ? 0 : -6);
    final y = 52 + math.sin(t * math.pi * 8).abs() * -5;
    _kedi(c, Offset(x, y), 13);
    // oklar
    void ok(Offset m, bool sag, bool yanik) {
      _kutu(c, _rr(m.dx - 22, m.dy - 13, 44, 26, 10), yanik ? renk : Colors.white);
      final p = Path();
      final s = sag ? 1 : -1;
      p.moveTo(m.dx - 9 * s, m.dy - 3);
      p.lineTo(m.dx + 1 * s, m.dy - 3);
      p.lineTo(m.dx + 1 * s, m.dy - 8);
      p.lineTo(m.dx + 10 * s, m.dy);
      p.lineTo(m.dx + 1 * s, m.dy + 8);
      p.lineTo(m.dx + 1 * s, m.dy + 3);
      p.lineTo(m.dx - 9 * s, m.dy + 3);
      p.close();
      c.drawPath(p, _boya(yanik ? Colors.white : renk));
    }
    ok(const Offset(70, 98), false, !saga);
    ok(const Offset(130, 98), true, saga);
  }

  /// Basit kedi (Scratch kedisine benzemeyen, yuvarlak bir kedi).
  void _kedi(Canvas c, Offset m, double b) {
    final g = _boya(const Color(0xFFFFA726));
    c.drawPath(Path()..moveTo(m.dx - b * .6, m.dy - b * .3)..lineTo(m.dx - b * .45, m.dy - b * .95)..lineTo(m.dx - b * .1, m.dy - b * .5)..close(), g);
    c.drawPath(Path()..moveTo(m.dx + b * .6, m.dy - b * .3)..lineTo(m.dx + b * .45, m.dy - b * .95)..lineTo(m.dx + b * .1, m.dy - b * .5)..close(), g);
    c.drawCircle(m, b * .65, g);
    c.drawCircle(m + Offset(-b * .22, -b * .05), b * .09, _boya(const Color(0xFF3E2723)));
    c.drawCircle(m + Offset(b * .22, -b * .05), b * .09, _boya(const Color(0xFF3E2723)));
    c.drawCircle(m + Offset(0, b * .14), b * .07, _boya(const Color(0xFFE91E63)));
  }

  /// Koordinat Macerasi: eksenler, izgara, nokta (x,y) arasinda zipliyor.
  void _koordinat(Canvas c) {
    const o = Offset(40, 106), k = 16.0;
    final izgara = _cizgi(Colors.white.withValues(alpha: 0.8), 1);
    for (var i = 0; i <= 7; i++) {
      c.drawLine(o + Offset(i * k, 0), o + Offset(i * k, -5 * k), izgara);
    }
    for (var j = 0; j <= 5; j++) {
      c.drawLine(o + Offset(0, -j * k), o + Offset(7 * k, -j * k), izgara);
    }
    final eksen = _cizgi(_koyu(0.2), 2.2);
    c.drawLine(o, o + const Offset(7 * k + 8, 0), eksen);
    c.drawLine(o, o + const Offset(0, -5 * k - 8), eksen);
    _yazi(c, 'x', o + const Offset(7 * k + 12, 0), boy: 9, renk: _koyu(0.2));
    _yazi(c, 'y', o + const Offset(0, -5 * k - 12), boy: 9, renk: _koyu(0.2));
    const noktalar = [(2, 1), (5, 3), (3, 4)];
    final i = (t * 3).floor() % 3;
    final f = _yumusakYerel((t * 3) % 1, 0.0, 0.6);
    final (ax, ay) = noktalar[i];
    final (bx, by) = noktalar[(i + 1) % 3];
    final a = o + Offset(ax * k, -ay * k), b = o + Offset(bx * k, -by * k);
    final p = Offset.lerp(a, b, f)! + Offset(0, -math.sin(f * math.pi) * 14);
    final hedef = f >= 1 ? b : a;
    final kesik = _cizgi(renk, 1.4);
    c.drawLine(hedef, Offset(hedef.dx, o.dy), kesik..color = renk.withValues(alpha: 0.6));
    c.drawLine(hedef, Offset(o.dx, hedef.dy), kesik);
    _robot(c, p + const Offset(0, -4), 14);
    final (lx, ly) = f >= 1 ? noktalar[(i + 1) % 3] : noktalar[i];
    _kutu(c, _rr(hedef.dx + 8, hedef.dy - 26, 32, 14, 7), renk, golge: 1.5);
    _yazi(c, '($lx,$ly)', Offset(hedef.dx + 24, hedef.dy - 19), boy: 8);
  }

  double _yumusakYerel(double x, double a, double b) {
    final y = ((x - a) / (b - a)).clamp(0.0, 1.0);
    return y * y * (3 - 2 * y);
  }

  /// Scratch tarzi blok (cikintili).
  void _blok(Canvas c, double x, double y, double w, Color col, {bool sapka = false}) {
    const h = 18.0;
    final p = Path();
    if (sapka) {
      p.moveTo(x, y);
      p.quadraticBezierTo(x + 20, y - 9, x + 40, y);
    } else {
      p.moveTo(x, y);
      p.lineTo(x + 10, y);
      p.lineTo(x + 13, y + 3);
      p.lineTo(x + 21, y + 3);
      p.lineTo(x + 24, y);
    }
    p.lineTo(x + w, y);
    p.lineTo(x + w, y + h);
    p.lineTo(x + 24, y + h);
    p.lineTo(x + 21, y + h + 3);
    p.lineTo(x + 13, y + h + 3);
    p.lineTo(x + 10, y + h);
    p.lineTo(x, y + h);
    p.close();
    c.drawPath(p.shift(const Offset(0, 2)), _boya(Colors.black.withValues(alpha: 0.15)));
    c.drawPath(p, _boya(col));
    c.drawPath(p, _cizgi(Color.lerp(col, Colors.black, 0.2)!, 1));
  }

  /// Kod Bloklari: bloklar ust uste oturuyor, son blok yukaridan gelip
  /// yerine "tik" diye kenetleniyor.
  void _kodBloklari(Canvas c) {
    _blok(c, 50, 22, 92, const Color(0xFFFFBF00), sapka: true);
    _bayrakSimgesi(c, const Offset(64, 31));
    c.drawRRect(_rr(76, 28, 50, 6, 3), _boya(Colors.white.withValues(alpha: 0.8)));
    _blok(c, 50, 40, 80, const Color(0xFF4C97FF));
    c.drawRRect(_rr(60, 46, 40, 6, 3), _boya(Colors.white.withValues(alpha: 0.8)));
    c.drawCircle(const Offset(112, 49), 5, _boya(Colors.white));
    final in_ = _yumusak(0.1, 0.5);
    final x = 50 + (1 - in_) * 70, y = 58 + (1 - in_) * -40;
    c.save();
    c.translate(x + 40, y + 9);
    c.rotate((1 - in_) * 0.25);
    c.translate(-x - 40, -y - 9);
    _blok(c, x, y, 86, const Color(0xFF9966FF));
    c.drawRRect(_rr(x + 10, y + 6, 46, 6, 3), _boya(Colors.white.withValues(alpha: 0.8)));
    c.restore();
    _blok(c, 50, 76 + 18 * (in_ < 1 ? 0 : 0), 70, const Color(0xFF59C059));
    c.drawRRect(_rr(60, 82, 34, 6, 3), _boya(Colors.white.withValues(alpha: 0.8)));
    _parilti(c, const Offset(140, 67), _yumusak(0.5, 0.58) * (1 - _yumusak(0.7, 0.85)));
    // parmak
    if (in_ < 1) _parmak(c, Offset(x + 80, y + 18));
  }

  void _bayrakSimgesi(Canvas c, Offset m) {
    c.drawLine(m + const Offset(-3, 5), m + const Offset(-3, -5), _cizgi(const Color(0xFF2E7D32), 1.4));
    c.drawPath(Path()..moveTo(m.dx - 3, m.dy - 5)..lineTo(m.dx + 5, m.dy - 3)..lineTo(m.dx - 3, m.dy)..close(),
        _boya(const Color(0xFF43A047)));
  }

  void _parmak(Canvas c, Offset m) {
    c.drawRRect(_rr(m.dx - 4, m.dy - 2, 8, 14, 4), _boya(const Color(0xFFFFCC80)));
    c.drawRRect(_rr(m.dx - 4, m.dy - 2, 8, 14, 4), _cizgi(const Color(0xFFE0A060), 1));
  }

  /// Komut Dizilimi: numarali komut kartlari yer degistirip dogru
  /// siraya giriyor, sonunda onay.
  void _komutDizilimi(Canvas c) {
    final takas = _yumusak(0.2, 0.55);
    final kartlar = [
      (1, 'ileri', const Color(0xFF4C97FF)),
      (3, 'bayrak', const Color(0xFFFF8C1A)),
      (2, 'don', const Color(0xFF9966FF)),
    ];
    for (var i = 0; i < 3; i++) {
      var y = 14.0 + i * 30;
      double x = 40;
      if (i == 1) {
        y += 30 * takas;
        x += math.sin(takas * math.pi) * 28;
      } else if (i == 2) {
        y -= 30 * takas;
        x -= math.sin(takas * math.pi) * 12;
      }
      final (no, simge, col) = kartlar[i];
      _kutu(c, _rr(x, y, 120, 24, 8), Colors.white);
      c.drawRRect(_rr(x, y, 24, 24, 8), _boya(col));
      _yazi(c, '$no', Offset(x + 12, y + 12), boy: 12);
      _simge(c, simge, Offset(x + 40, y + 12), col);
      c.drawRRect(_rr(x + 54, y + 9, 54, 6, 3), _boya(col.withValues(alpha: 0.35)));
    }
    final ok = _yumusak(0.62, 0.72);
    if (ok > 0) {
      c.drawCircle(const Offset(178, 60), 12 * ok, _boya(const Color(0xFF43A047)));
      final p = Path()..moveTo(172, 60)..lineTo(176.5, 64.5)..lineTo(184, 55);
      c.drawPath(p, _cizgi(Colors.white, 2.8));
    }
  }

  /// Kelime Avi: Ingilizce terim ile anlami arasina cizgi ciziliyor.
  void _kelimeAvi(Canvas c) {
    final sol = ['loop', 'print', 'if'];
    final sag = switch (lang) {
      'de' => ['Schleife', 'ausgeben', 'wenn'],
      'es' => ['bucle', 'imprimir', 'si'],
      'en' => ['repeat', 'show', 'when'],
      _ => ['döngü', 'yazdır', 'eğer'],
    };
    const eslesme = [2, 0, 1]; // sol i -> sag eslesme[i]
    final renkler = [const Color(0xFF4D96FF), const Color(0xFFFF6B6B), const Color(0xFF26C6A6)];
    for (var i = 0; i < 3; i++) {
      final y = 18.0 + i * 30;
      _kutu(c, _rr(14, y, 64, 22, 11), Colors.white);
      _yazi(c, sol[i], Offset(46, y + 11), boy: 10, renk: renkler[i]);
      // Anlamlar karisik sirada: sol i'nin anlami sag satir eslesme[i]'de.
      final ys = 18.0 + eslesme[i] * 30;
      _kutu(c, _rr(122, ys, 66, 22, 11), Colors.white);
      _yazi(c, sag[i], Offset(155, ys + 11), boy: 9.5, renk: const Color(0xFF37474F));
    }
    for (var i = 0; i < 3; i++) {
      final f = _yumusak(0.1 + i * 0.22, 0.28 + i * 0.22);
      if (f <= 0) continue;
      final a = Offset(78, 29.0 + i * 30);
      final b = Offset(122, 29.0 + eslesme[i] * 30);
      c.drawLine(a, Offset.lerp(a, b, f)!, _cizgi(renkler[i], 2.6));
      c.drawCircle(a, 3, _boya(renkler[i]));
      if (f >= 1) c.drawCircle(b, 3, _boya(renkler[i]));
    }
  }

  /// Renkli Kodlar: dort renk sirayla yaniyor (hafiza dizisi), ustte
  /// dizinin kendisi.
  void _renkliKodlar(Canvas c) {
    const renkler = [Color(0xFFEF5350), Color(0xFF66BB6A), Color(0xFF42A5F5), Color(0xFFFFCA28)];
    const dizi = [2, 0, 3, 1];
    final adim = (t * 5).floor();
    for (var i = 0; i < dizi.length; i++) {
      final gorunur = i < adim;
      c.drawCircle(Offset(70 + i * 20.0, 16), 6,
          _boya(gorunur ? renkler[dizi[i]] : Colors.white.withValues(alpha: 0.7)));
    }
    final yanan = adim < 4 ? dizi[adim] : -1;
    final nabiz = 0.5 + 0.5 * math.sin((t * 5 % 1) * math.pi);
    for (var i = 0; i < 4; i++) {
      final m = Offset(60 + (i % 2) * 80.0, 46 + (i ~/ 2) * 42.0);
      final yan = i == yanan;
      if (yan) {
        c.drawCircle(m, 22 + 4 * nabiz, _boya(renkler[i].withValues(alpha: 0.3)));
      }
      c.drawCircle(m + const Offset(0, 2), 18, _boya(Colors.black.withValues(alpha: 0.15)));
      c.drawCircle(m, 18, _boya(yan ? Color.lerp(renkler[i], Colors.white, 0.25)! : Color.lerp(renkler[i], Colors.black, 0.12)!));
      if (yan) c.drawCircle(m + const Offset(-6, -6), 5, _boya(Colors.white.withValues(alpha: 0.6)));
    }
  }

  /// Arduino karti (kucuk).
  void _arduinoKarti(Canvas c, Rect r) {
    _kutu(c, RRect.fromRectAndRadius(r, const Radius.circular(5)), const Color(0xFF00838F));
    for (var i = 0; i < 8; i++) {
      c.drawRect(Rect.fromLTWH(r.left + 8 + i * (r.width - 16) / 8, r.top + 3, 4, 4), _boya(const Color(0xFF263238)));
    }
    c.drawRRect(_rr(r.center.dx - 12, r.center.dy - 6, 24, 14, 2), _boya(const Color(0xFF263238)));
    c.drawCircle(Offset(r.right - 10, r.bottom - 10), 4, _boya(Colors.white.withValues(alpha: 0.8)));
    c.drawRRect(_rr(r.left - 4, r.top + 10, 10, 12, 2), _boya(const Color(0xFFB0BEC5)));
  }

  void _led(Canvas c, Offset m, bool yanik, Color col) {
    if (yanik) c.drawCircle(m, 14, _boya(col.withValues(alpha: 0.35)));
    c.drawLine(m + const Offset(-3, 6), m + const Offset(-3, 18), _cizgi(const Color(0xFF90A4AE), 1.5));
    c.drawLine(m + const Offset(3, 6), m + const Offset(3, 15), _cizgi(const Color(0xFF90A4AE), 1.5));
    c.drawRRect(_rr(m.dx - 7, m.dy - 9, 14, 16, 7),
        _boya(yanik ? Color.lerp(col, Colors.white, 0.3)! : Color.lerp(col, Colors.black, 0.35)!));
  }

  /// Arduino Eslestirme: kod parcasi ile bilesen eslesiyor, LED yaniyor.
  void _arduinoEslestirme(Canvas c) {
    _kutu(c, _rr(12, 16, 96, 22, 8), const Color(0xFF263238));
    _yazi(c, 'digitalWrite()', const Offset(60, 27), boy: 8.5, renk: const Color(0xFF80CBC4));
    _kutu(c, _rr(12, 46, 96, 22, 8), Colors.white);
    _yazi(c, 'servo.write()', const Offset(60, 57), boy: 8.5, renk: renk);
    _kutu(c, _rr(12, 76, 96, 22, 8), Colors.white);
    _yazi(c, 'tone()', const Offset(60, 87), boy: 8.5, renk: renk);
    final f = _yumusak(0.15, 0.5);
    final a = const Offset(108, 27), b = const Offset(150, 46);
    if (f > 0) {
      c.drawLine(a, Offset.lerp(a, b, f)!, _cizgi(const Color(0xFF26A69A), 2.5));
      c.drawCircle(a, 3, _boya(const Color(0xFF26A69A)));
    }
    final yanik = f >= 1 && ((t * 8).floor().isEven);
    _led(c, const Offset(160, 50), yanik, const Color(0xFFFF5252));
    _kutu(c, _rr(140, 76, 40, 22, 6), const Color(0xFF455A64));
    c.drawCircle(const Offset(160, 87), 6, _boya(const Color(0xFF263238)));
  }

  /// Kod Dedektifi: 2, 4, 6, ? — soru isareti titriyor, sonra 8 aciliyor.
  void _kodDedektifi(Canvas c) {
    const sayilar = ['2', '4', '6'];
    final ac = _yumusak(0.55, 0.65);
    for (var i = 0; i < 4; i++) {
      final x = 18.0 + i * 42;
      final son = i == 3;
      final sall = son && ac == 0 ? math.sin(t * math.pi * 16) * 1.5 : 0.0;
      _kutu(c, _rr(x + sall, 36, 34, 40, 9), son ? (ac > 0 ? const Color(0xFF43A047) : renk) : Colors.white);
      _yazi(c, son ? (ac > 0.5 ? '8' : '?') : sayilar[i], Offset(x + 17 + sall, 56),
          boy: 20, renk: son ? Colors.white : renk);
      if (i < 3) {
        _yazi(c, '+2', Offset(x + 38, 28), boy: 8, renk: _koyu(0.1));
      }
    }
    // buyutec
    final g = Offset(150 - 40 * _yumusak(0.0, 0.5) + 40 * _yumusak(0.7, 1.0), 92);
    c.drawLine(g + const Offset(7, 7), g + const Offset(16, 16), _cizgi(const Color(0xFF8D6E63), 4));
    c.drawCircle(g, 10, _boya(Colors.white.withValues(alpha: 0.3)));
    c.drawCircle(g, 10, _cizgi(const Color(0xFFFFD54F), 3));
  }

  /// Degisken Ustasi: "5" kutuya dusuyor, iki kutunun degerleri takas.
  void _degiskenUstasi(Canvas c) {
    void kutu(Offset m, String ad, String deger, Color col) {
      // kutu: on yuz + kapak
      _kutu(c, _rr(m.dx - 26, m.dy - 14, 52, 38, 6), col);
      c.drawRRect(_rr(m.dx - 29, m.dy - 20, 58, 9, 4), _boya(Color.lerp(col, Colors.black, 0.15)!));
      _yazi(c, ad, m + const Offset(0, 30), boy: 11, renk: _koyu(0.25));
      _yazi(c, deger, m + const Offset(0, 6), boy: 17);
    }
    final dus = _yumusak(0.0, 0.3);
    final takas = _yumusak(0.45, 0.8);
    final ucuyor = takas > 0 && takas < 1;
    final xDeger = dus < 1 || ucuyor ? '' : (takas >= 1 ? '3' : '5');
    final yDeger = ucuyor ? '' : (takas >= 1 ? '5' : '3');
    kutu(const Offset(62, 64), 'x', xDeger, const Color(0xFF5C6BC0));
    kutu(const Offset(138, 64), 'y', yDeger, const Color(0xFFEC407A));
    if (dus < 1) {
      final p = Offset(62, 8 + 52 * dus);
      c.drawCircle(p, 10, _boya(const Color(0xFFFFB300)));
      _yazi(c, '5', p, boy: 12);
    }
    if (takas > 0 && takas < 1) {
      final a = Offset.lerp(const Offset(62, 40), const Offset(138, 40), takas)! +
          Offset(0, -math.sin(takas * math.pi) * 22);
      final b = Offset.lerp(const Offset(138, 40), const Offset(62, 40), takas)! +
          Offset(0, math.sin(takas * math.pi) * 6);
      c.drawCircle(a, 9, _boya(const Color(0xFFFFB300)));
      _yazi(c, '5', a, boy: 11);
      c.drawCircle(b, 9, _boya(const Color(0xFF26C6A6)));
      _yazi(c, '3', b, boy: 11);
    }
  }

  /// Arduino Atolyesi: kart, kablo, LED yanip sonuyor, servo kolu
  /// donuyor, buzzer ses dalgasi.
  void _arduinoAtolyesi(Canvas c) {
    _arduinoKarti(c, const Rect.fromLTWH(14, 34, 74, 54));
    // breadboard
    _kutu(c, _rr(104, 58, 82, 40, 6), const Color(0xFFECEFF1));
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 3; j++) {
        c.drawCircle(Offset(112 + i * 8.5, 68 + j * 10.0), 1.2, _boya(const Color(0xFFB0BEC5)));
      }
    }
    // kablolar
    c.drawPath(Path()..moveTo(80, 38)..cubicTo(100, 10, 120, 30, 124, 58), _cizgi(const Color(0xFFE53935), 2.2));
    c.drawPath(Path()..moveTo(70, 38)..cubicTo(90, 20, 150, 22, 160, 58), _cizgi(const Color(0xFF1E88E5), 2.2));
    final yanik = (t * 6).floor().isEven;
    _led(c, const Offset(124, 50), yanik, const Color(0xFFFF5252));
    // servo
    final sm = const Offset(162, 44);
    _kutu(c, _rr(sm.dx - 12, sm.dy - 6, 24, 14, 3), const Color(0xFF1E88E5));
    final a = -math.pi / 2 + math.sin(t * math.pi * 2) * 0.9;
    c.drawLine(sm, sm + Offset(math.cos(a), math.sin(a)) * 15, _cizgi(Colors.white, 4));
    c.drawCircle(sm, 3, _boya(Colors.white));
    // buzzer dalgalari
    final dal = (t * 3) % 1;
    for (var i = 0; i < 2; i++) {
      final r = 6 + (dal + i * 0.5) % 1 * 12;
      c.drawArc(Rect.fromCircle(center: const Offset(40, 102), radius: r), -math.pi * .85, math.pi * .7, false,
          _cizgi(renk.withValues(alpha: 1 - (dal + i * 0.5) % 1), 1.6));
    }
    c.drawCircle(const Offset(40, 102), 5, _boya(const Color(0xFF263238)));
  }

  @override
  bool shouldRepaint(_SahneRessami old) => old.t != t || old.tur != tur || old.lang != lang;
}

/// Oyunun zorluk etiketi (Kolay / Orta / Zor). Yildiz yerine yazi:
/// cocuk yildizlari "kazandigim yildiz" diye okuyordu.
String zorlukEtiketi(int difficulty, String lang) {
  if (difficulty <= 1) {
    return AppLang.pick(lang, tr: 'Kolay', en: 'Easy', de: 'Leicht', es: 'Fácil');
  }
  if (difficulty == 2) {
    return AppLang.pick(lang, tr: 'Orta', en: 'Medium', de: 'Mittel', es: 'Medio');
  }
  return AppLang.pick(lang, tr: 'Zor', en: 'Hard', de: 'Schwer', es: 'Difícil');
}

/// Oyunun bir cumlelik daveti (Gunun Gorevi karti icin). Aciklama metni
/// degil, cocuga "ne yapacaksin" diyen kisa bir cagri.
String oyunDaveti(GameType tur, String lang) {
  String t(String tr, String en, String de, String es) =>
      AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
  return switch (tur) {
    GameType.pipesPuzzle => t('Boruları döndür, su çiçeğe ulaşsın!',
        'Turn the pipes so the water reaches the flower!',
        'Dreh die Rohre, damit das Wasser zur Blume fließt!',
        '¡Gira las tuberías para que el agua llegue a la flor!'),
    GameType.mazeExplorer => t('Robotu labirentten hazineye götür!',
        'Guide the robot through the maze to the treasure!',
        'Führe den Roboter durchs Labyrinth zum Schatz!',
        '¡Lleva al robot por el laberinto hasta el tesoro!'),
    GameType.bugHunter => t('Koddaki böceği bul, programı düzelt!',
        'Find the bug in the code and fix the program!',
        'Finde den Fehler im Code und repariere das Programm!',
        '¡Encuentra el error en el código y arréglalo!'),
    GameType.chess => t('Atını zıplat, şah mat et!',
        'Make your moves and checkmate!',
        'Zieh deine Figuren und setz matt!',
        '¡Mueve tus piezas y da jaque mate!'),
    GameType.quiz => t('Soruları cevapla, bilgini göster!',
        'Answer the questions and show what you know!',
        'Beantworte die Fragen und zeig, was du weißt!',
        '¡Responde las preguntas y demuestra lo que sabes!'),
    GameType.robotSimulator => t('Komutları ver, robot bayrağa gitsin!',
        'Give commands and drive the robot to the flag!',
        'Gib Befehle und bring den Roboter zur Flagge!',
        '¡Da órdenes y lleva al robot a la bandera!'),
    GameType.leftRightCoding => t('Sağ mı sol mu? Hızlı karar ver!',
        'Left or right? Decide fast!',
        'Links oder rechts? Entscheide schnell!',
        '¿Izquierda o derecha? ¡Decide rápido!'),
    GameType.coordinates => t('Robotu doğru (x, y) noktasına götür!',
        'Move the robot to the right (x, y) point!',
        'Bring den Roboter zum richtigen (x, y)-Punkt!',
        '¡Lleva al robot al punto (x, y) correcto!'),
    GameType.blockCoding => t('Blokları birleştir, kodunu kur!',
        'Snap the blocks together and build your code!',
        'Steck die Blöcke zusammen und bau deinen Code!',
        '¡Une los bloques y arma tu código!'),
    GameType.sequencing => t('Komutları doğru sıraya diz!',
        'Put the commands in the right order!',
        'Bring die Befehle in die richtige Reihenfolge!',
        '¡Ordena los comandos correctamente!'),
    GameType.wordMatch => t('Kodlama kelimelerini anlamlarıyla eşleştir!',
        'Match coding words with their meanings!',
        'Ordne Programmierwörter ihrer Bedeutung zu!',
        '¡Empareja palabras de programación con su significado!'),
    GameType.colorCoding => t('Renk sırasını aklında tut, tekrarla!',
        'Remember the colour order and repeat it!',
        'Merk dir die Farbreihenfolge und wiederhole sie!',
        '¡Recuerda el orden de colores y repítelo!'),
    GameType.matchingGame => t('Arduino kodunu doğru parçayla eşleştir!',
        'Match the Arduino code with the right part!',
        'Ordne den Arduino-Code dem richtigen Bauteil zu!',
        '¡Empareja el código de Arduino con la pieza correcta!'),
    GameType.patternDetective => t('Kuralı bul, sıradaki sayıyı söyle!',
        'Find the rule and say the next number!',
        'Finde die Regel und nenne die nächste Zahl!',
        '¡Descubre la regla y di el siguiente número!'),
    GameType.variableMaster => t('Kutulara değer koy, değiştir, takas et!',
        'Put values in boxes, change and swap them!',
        'Leg Werte in Kisten, ändere und tausche sie!',
        '¡Pon valores en cajas, cámbialos e intercámbialos!'),
    GameType.arduinoSimulator => t('Bloklarla kodla, LED yansın!',
        'Code with blocks and light up the LED!',
        'Programmier mit Blöcken und lass die LED leuchten!',
        '¡Programa con bloques y enciende el LED!'),
    _ => t('Hadi oynayalım!', "Let's play!", "Los geht's!", '¡A jugar!'),
  };
}
