import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../ui/motion.dart';
import '../../utils/lang.dart';
import '../yurutme/mblock_uno.dart';

/// SANAL ARDUINO UNO — kartin cizimi ve cevresindeki parcalar.
///
/// Kart kendi vektor cizimimiz (CustomPainter): fotograf ya da baska bir
/// programin gorseli degil, uzerinden de kopyalanmadi. Gercek bir Uno'nun
/// olculeri (68,6 x 53,4 mm) ve yerlesimi: mavi baski devre, sag kenarda
/// girinti, ustte dijital pinler, altta guc ve analog pinler, solda USB
/// (kablosu takili) ve guc girisi, ortada 28 bacakli islemci, kristal,
/// kondansatorler, regulator, reset dugmesi, TX/RX/L/ON ledleri. Marka
/// logosu ve marka yazisi BILEREK cizilmiyor; yalnizca notr "UNO".
///
/// Program harici LED kullaniyorsa ([UnoParcalari.ledler] icinde 13
/// disinda bir pin) kartin altina bir breadboard geliyor: her LED kendi
/// sutununda, pinden gelen kirmizi kablo, 220 ohm direnc ve GND hattina
/// giden siyah kablo ile. Yalnizca pin 13 ise kart tek basina (pin 13
/// kartin uzerindeki "L" ledi).
///
/// Buton, buzzer ve servo kartin altinda, potansiyometre ve mesafe
/// surguleri, seri port monitoru onlarin altinda.
///
/// Performans: kart, breadboard ve kablolar durgun katmanlar (kendi
/// RepaintBoundary'lerinde, bir kez boyaniyor); yalnizca isiklar (L ledi,
/// breadboard LED'leri) [UnoKarti]'yi dinleyip yeniden boyaniyor.
class UnoKartiGorunumu extends StatelessWidget {
  const UnoKartiGorunumu({
    super.key,
    required this.kart,
    required this.parcalar,
    required this.lang,
  });

  final UnoKarti kart;
  final UnoParcalari parcalar;
  final String lang;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

  static const double _kenar = 12;
  static const double _ekstraH = 76;

  /// Gorunumun yuksekligi (sahne karti sabit boyda kalsin, yerlesim
  /// kaymasin).
  static double yukseklik(UnoParcalari p, double genislik) {
    final y = UnoYerlesim.hesapla(p, genislik - 2 * _kenar);
    var h = 10 + y.yukseklik + 10;
    if (_ekstraVar(p) && y.yan == null) h += _ekstraH;
    if (p.pot) h += 46;
    if (p.mesafe) h += 46;
    if (p.seri) h += 84;
    return h;
  }

  static bool _ekstraVar(UnoParcalari p) =>
      p.buzzer || p.buton || p.servolar.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: LayoutBuilder(builder: (context, c) {
          final y = UnoYerlesim.hesapla(parcalar, c.maxWidth - 2 * _kenar);
          return Padding(
            padding: const EdgeInsets.fromLTRB(_kenar, 10, _kenar, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: y.yukseklik, child: _devre(y)),
                if (_ekstraVar(parcalar) && y.yan == null)
                  SizedBox(height: _ekstraH, child: _ekstralar()),
                if (parcalar.pot)
                  _surgu(
                    anahtar: const ValueKey('uno_pot'),
                    ikon: Icons.tune_rounded,
                    ad: _t('Potansiyometre (A0)', 'Potentiometer (A0)',
                        'Potentiometer (A0)', 'Potenciómetro (A0)'),
                    deger: () => kart.pot.toDouble(),
                    min: 0,
                    max: 1023,
                    yazi: () => '${kart.pot}',
                    degisti: (v) => kart.pot = v.round(),
                  ),
                if (parcalar.mesafe)
                  _surgu(
                    anahtar: const ValueKey('uno_mesafe'),
                    ikon: Icons.sensors_rounded,
                    ad: _t('Mesafe sensörü', 'Distance sensor',
                        'Abstandssensor', 'Sensor de distancia'),
                    deger: () => kart.mesafe.toDouble(),
                    min: 2,
                    max: 200,
                    yazi: () => '${kart.mesafe} cm',
                    degisti: (v) => kart.mesafe = v.round(),
                  ),
                if (parcalar.seri) ...[
                  const SizedBox(height: 6),
                  _seriMonitor(),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Kart (+ breadboard, kablolar, LED'ler) tek bir yigin halinde.
  Widget _devre(UnoYerlesim y) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Durgun: kart.
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              key: const ValueKey('uno_karti'),
              painter: UnoKartBoyaci(o: y.kartO, s: y.s),
            ),
          ),
        ),
        // Durgun: breadboard, direncler, LED bacaklari, kablolar.
        if (y.devre)
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                key: const ValueKey('uno_breadboard'),
                painter: _DevreBoyaci(y),
              ),
            ),
          ),
        // Isiklar: L ve ON ledleri, etkin pinler.
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _KartIsiklari(kart: kart, o: y.kartO, s: y.s,
                  kabloluPinler: y.devre ? y.ledler : const []),
            ),
          ),
        ),
        if (y.yan != null)
          Positioned.fromRect(rect: y.yan!, child: _ekstralar()),
        if (!y.devre && parcalar.ledler.contains(13))
          Positioned.fromRect(
            rect: Rect.fromCenter(
                center: y.kartO + UnoOlcu.lLedi * y.s,
                width: 40 * y.s,
                height: 40 * y.s),
            child: const SizedBox(key: ValueKey('uno_led_13')),
          ),
        if (y.devre)
          for (var k = 0; k < y.ledler.length; k++)
            Positioned.fromRect(
              rect: y.ledKutusu(k),
              child: RepaintBoundary(
                child: CustomPaint(
                  key: ValueKey('uno_led_${y.ledler[k]}'),
                  painter: _LedBoyaci(
                      kart: kart, pin: y.ledler[k], p: y.p),
                ),
              ),
            ),
      ],
    );
  }

  Widget _ekstralar() {
    const boy = 52.0;
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 18,
        runSpacing: 4,
        children: [
          if (parcalar.buzzer) UnoBuzzer(kart: kart, boy: boy, lang: lang),
          for (final p in parcalar.servolar)
            UnoServo(kart: kart, pin: p, boy: boy),
          if (parcalar.buton) UnoButon(kart: kart, boy: boy, lang: lang),
        ],
      ),
    );
  }

  Widget _surgu({
    required Key anahtar,
    required IconData ikon,
    required String ad,
    required double Function() deger,
    required double min,
    required double max,
    required String Function() yazi,
    required ValueChanged<double> degisti,
  }) {
    return SizedBox(
      height: 46,
      child: Row(
        children: [
          Icon(ikon, size: 18, color: const Color(0xFF2C6E9B)),
          const SizedBox(width: 6),
          Flexible(
            flex: 3,
            child: Text(
              ad,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF39404F),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: AnimatedBuilder(
              animation: kart,
              builder: (context, _) => Slider(
                key: anahtar,
                value: deger(),
                min: min,
                max: max,
                activeColor: const Color(0xFF2C6E9B),
                onChanged: degisti,
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: AnimatedBuilder(
              animation: kart,
              builder: (context, _) => Text(
                yazi(),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2C6E9B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seriMonitor() {
    return Container(
      key: const ValueKey('uno_seri'),
      height: 78,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF14181F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('Seri port', 'Serial port', 'Serieller Port', 'Puerto serie'),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Color(0xFF7ED321),
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: AnimatedBuilder(
              animation: kart,
              builder: (context, _) {
                final son = kart.seri.length > 3
                    ? kart.seri.sublist(kart.seri.length - 3)
                    : kart.seri;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (final s in son)
                      Text(
                        s,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12.5,
                          color: Color(0xFFB8F28A),
                          height: 1.25,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// Olculer ve yerlesim
// ======================================================================

/// Kartin cizim olculeri. Birim: 0,1 mm; kartin sol ust kosesi (0, 0),
/// dijital pinler ustte, USB solda.
abstract final class UnoOlcu {
  static const double kartW = 686;
  static const double kartH = 534;

  /// Kartin solunda USB fisi ve kablosu icin ayrilan genislik.
  static const double kabloW = 250;

  /// Pin araligi (2,54 mm).
  static const double adim = 25.4;

  static const double baslikH = 26;
  static const double ustY = 8;
  static const double altY = 500;
  static const double dijital1X = 168; // 10'lu blok: SCL SDA AREF GND 13..8
  static const double dijital2X = 436; // 8'li blok: 7..0
  static const double gucX = 252; // 8'li: - IOREF RESET 3.3V 5V GND GND Vin
  static const double analogX = 470; // 6'li: A0..A5

  static const Offset lLedi = Offset(262, 124);
  static const Offset txLedi = Offset(262, 168);
  static const Offset rxLedi = Offset(262, 192);
  static const Offset onLedi = Offset(574, 172);

  /// Dijital pinin (0..13) delik merkezi.
  static Offset dijitalPin(int pin) {
    if (pin >= 8) {
      final i = 9 - (pin - 8);
      return Offset(dijital1X + adim * (i + 0.5), ustY + baslikH / 2);
    }
    final i = 7 - pin;
    return Offset(dijital2X + adim * (i + 0.5), ustY + baslikH / 2);
  }

  /// Guc basligindaki i. delik (5 = ilk GND).
  static Offset gucPin(int i) =>
      Offset(gucX + adim * (i + 0.5), altY + baslikH / 2);
}

/// Breadboard satirlari (adim cinsinden, breadboard'un ustunden).
abstract final class _Bb {
  static const double genislik = 33.2;
  static const double yukseklik = 17.3;
  static const double maviUst = 0.45;
  static const double eksiUst = 1.05;
  static const double artiUst = 1.95;
  static const double kirmiziUst = 2.45;
  static const double sayiUst = 3.0;
  static const double j = 3.7;
  static const double kanal = 8.7;
  static const double e = 9.7;
  static const double sayiAlt = 14.4;
  static const double maviAlt = 14.95;
  static const double eksiAlt = 15.45;
  static const double artiAlt = 16.35;
  static const double kirmiziAlt = 16.85;

  /// Satir harfi (a..j) icin y.
  static double satir(String h) {
    final i = 'jihgfedcba'.indexOf(h);
    return i < 5 ? j + i : e + (i - 5);
  }

  /// Guc hatlarinda 5'li gruplar: 6, 12, 18... sutunlarda delik yok.
  static bool rayDeligi(int sutun) => sutun % 6 != 0;
}

/// Gorunumun parcalarinin yerleri (ekran pikseli, icerik kutusunun sol
/// ustunden).
class UnoYerlesim {
  UnoYerlesim._({
    required this.devre,
    required this.s,
    required this.kartO,
    required this.yukseklik,
    required this.genislik,
    this.bb = Rect.zero,
    this.p = 0,
    this.serit = 0,
    this.ledler = const [],
    this.sutunlar = const [],
    this.yan,
  });

  /// true: breadboard da var.
  final bool devre;

  /// Kart olcegi (piksel / birim).
  final double s;

  /// Kartin sol ust kosesi.
  final Offset kartO;
  final double yukseklik;
  final double genislik;

  final Rect bb;

  /// Breadboard delik araligi (piksel).
  final double p;

  /// Kablo seritleri arasi bosluk.
  final double serit;

  /// Breadboard'daki LED'lerin pinleri (kucukten buyuge, soldan saga).
  final List<int> ledler;

  /// Her LED'in anot sutunu (1..30).
  final List<int> sutunlar;

  /// Breadboard yokken buzzer/servo/buton kartin sagindaki bu alanda
  /// (sahne kisa kalsin); null ise kartin altinda bir sira.
  final Rect? yan;

  static UnoYerlesim hesapla(UnoParcalari parcalar, double genislik) {
    final w = math.max(120.0, genislik);
    final ledler = parcalar.ledler.toSet().toList()..sort();
    final devre = ledler.any((x) => x != 13);
    const toplamW = UnoOlcu.kabloW + UnoOlcu.kartW;
    final ekstra = (parcalar.buzzer ? 1 : 0) +
        (parcalar.buton ? 1 : 0) +
        parcalar.servolar.length;
    if (!devre && ekstra > 0 && ekstra <= 2) {
      final s = math.min(w * 0.68 / toplamW, 150 / UnoOlcu.kartH);
      final kartH = UnoOlcu.kartH * s;
      final x = toplamW * s;
      return UnoYerlesim._(
        devre: false,
        s: s,
        kartO: Offset(UnoOlcu.kabloW * s, 4 * s + 2),
        yukseklik: kartH + 8 * s + 4,
        genislik: w,
        yan: Rect.fromLTWH(x + 6, 0, math.max(0, w - x - 6), kartH + 8 * s + 4),
      );
    }
    if (!devre) {
      final s = math.min(w / (toplamW + 8), 215 / UnoOlcu.kartH);
      final x = (w - toplamW * s) / 2 + UnoOlcu.kabloW * s;
      return UnoYerlesim._(
        devre: false,
        s: s,
        kartO: Offset(x, 4 * s + 2),
        yukseklik: UnoOlcu.kartH * s + 8 * s + 4,
        genislik: w,
      );
    }
    final n = ledler.length;
    final g = (w * 0.014).clamp(4.0, 6.0);
    final sagSerit = (n + 1) * g + 4;
    final s = math.min((w - sagSerit) / toplamW, 185 / UnoOlcu.kartH);
    final kartO = Offset(w - sagSerit - UnoOlcu.kartW * s, (n + 1) * g + 4);
    final kartAlt = kartO.dy + UnoOlcu.kartH * s;
    final bbUst = kartAlt + g * (n + 2) + 8;
    final p = w / _Bb.genislik;
    final bb = Rect.fromLTWH(0, bbUst, w, _Bb.yukseklik * p);

    // LED sutunlari: 3..28 arasina esit dagit; katot bir sagdaki sutundan
    // GND hattina iniyor, orada delik olsun.
    final sutunlar = <int>[];
    for (var k = 0; k < n; k++) {
      var c = 3 + ((k + 0.5) * 26 / n - 0.5).round();
      if (!_Bb.rayDeligi(c + 1)) c -= 1;
      if (sutunlar.isNotEmpty && c <= sutunlar.last) c = sutunlar.last + 1;
      sutunlar.add(c.clamp(3, 29));
    }
    return UnoYerlesim._(
      devre: true,
      s: s,
      kartO: kartO,
      yukseklik: bb.bottom + 2,
      genislik: w,
      bb: bb,
      p: p,
      serit: g,
      ledler: ledler,
      sutunlar: sutunlar,
    );
  }

  /// Breadboard sutununun x'i.
  double sutunX(int c) => bb.left + (1.1 + c) * p;

  /// Breadboard satirinin y'si (adim cinsinden satirdan).
  double satirY(double satir) => bb.top + satir * p;

  /// k. LED'in kubbesinin merkezi (alt kenari).
  Offset ledTaban(int k) =>
      Offset(sutunX(sutunlar[k]) + 0.5 * p, satirY(12.25));

  /// k. LED'in boyandigi kutu (isik halesi icin genis).
  Rect ledKutusu(int k) {
    final t = ledTaban(k);
    return Rect.fromLTWH(t.dx - 2.5 * p, t.dy - 3.8 * p, 5 * p, 5.2 * p);
  }
}

// ======================================================================
// Kart
// ======================================================================

/// Kartin durgun cizimi (bir kez boyaniyor).
class UnoKartBoyaci extends CustomPainter {
  UnoKartBoyaci({required this.o, required this.s});

  final Offset o;
  final double s;

  static const Color pcb = Color(0xFF2C6E9B);
  static const Color pcbKoyu = Color(0xFF1F5A82);
  static const Color pcbAcik = Color(0xFF3479A8);
  static const Color yazi = Color(0xF2FFFFFF);
  static const Color baslik = Color(0xFF2A2B2E);

  /// Kartin dis hatti: sag kenarda girinti, koseler yuvarlak.
  static Path kartYolu() {
    const r = 18.0;
    return Path()
      ..moveTo(r, 0)
      ..lineTo(648, 0)
      ..quadraticBezierTo(660, 0, 660, 12)
      ..lineTo(660, 128)
      ..lineTo(686, 154)
      ..lineTo(686, 452)
      ..lineTo(660, 478)
      ..lineTo(660, 522)
      ..quadraticBezierTo(660, 534, 648, 534)
      ..lineTo(r, 534)
      ..quadraticBezierTo(0, 534, 0, 534 - r)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(s);
    _ciz(canvas);
    canvas.restore();
  }

  void _ciz(Canvas c) {
    final yol = kartYolu();

    // USB kablosu ve fisi (kartin altinda kalsin diye once).
    _usbKablosu(c);

    // Golge + kart.
    c.drawPath(
        yol.shift(const Offset(0, 8)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    c.drawPath(yol, Paint()..color = pcb);
    c.drawPath(
        yol,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = pcbKoyu);
    // Ince ic cerceve (baski devre kenari).
    c.save();
    c.clipPath(yol);
    c.drawPath(
        yol,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..color = pcbAcik.withValues(alpha: 0.35));
    c.restore();

    // Vida delikleri.
    for (final m in const [
      Offset(140, 34),
      Offset(658, 204),
      Offset(640, 468),
      Offset(140, 500),
    ]) {
      c.drawCircle(m, 21, Paint()..color = const Color(0xFFD9C27A));
      c.drawCircle(m, 15, Paint()..color = Colors.white);
    }

    _usbYuvasi(c);
    _gucGirisi(c);
    _resetDugmesi(c);
    _regulator(c);
    _kondansatorler(c);
    _kristal(c);
    _kucukCipler(c);
    _islemci(c);
    _basliklar(c);
    _etiketler(c);
    _kucukLedler(c);

    // Notr etiket: marka logosu ve marka yazisi bilerek cizilmiyor.
    final kutu = RRect.fromRectAndRadius(
        const Rect.fromLTWH(412, 132, 132, 64), const Radius.circular(14));
    c.drawRRect(
        kutu,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = yazi);
    _yazi(c, 'UNO', kutu.center, 44, agirlik: FontWeight.w600, aralik: 5);
  }

  void _usbKablosu(Canvas c) {
    // Kablo: soldan kenara kadar uzaniyor (gorunum kenarinda kesiliyor).
    final kablo = RRect.fromRectAndRadius(
        const Rect.fromLTRB(-1200, 154, -200, 194), const Radius.circular(8));
    c.drawRRect(kablo, Paint()..color = const Color(0xFF1C1D20));
    c.drawRect(const Rect.fromLTRB(-1200, 160, -200, 166),
        Paint()..color = Colors.white.withValues(alpha: 0.10));
    // Tutamak: kabartmali.
    final tutamak = RRect.fromRectAndRadius(
        const Rect.fromLTRB(-250, 134, -186, 214), const Radius.circular(10));
    c.drawRRect(tutamak, Paint()..color = const Color(0xFF26272B));
    for (var x = -240.0; x < -192; x += 12) {
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, 136, 6, 76), const Radius.circular(3)),
          Paint()..color = const Color(0xFF131416));
    }
    // Fis govdesi.
    final govde = RRect.fromRectAndRadius(
        const Rect.fromLTRB(-196, 110, -52, 230), const Radius.circular(10));
    c.drawRRect(govde, Paint()..color = const Color(0xFF2B2C30));
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(-196, 110, -52, 128), const Radius.circular(10)),
        Paint()..color = Colors.white.withValues(alpha: 0.07));
    // Govdedeki cukur ve USB isareti (genel simge, cizgiler).
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(-168, 138, -78, 202), const Radius.circular(6)),
        Paint()..color = const Color(0xFF1E1F22));
    final isaret = Paint()
      ..color = const Color(0xFF55585F)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    c.drawLine(const Offset(-150, 170), const Offset(-96, 170), isaret);
    c.drawLine(const Offset(-136, 170), const Offset(-124, 156), isaret);
    c.drawLine(const Offset(-124, 156), const Offset(-110, 156), isaret);
    c.drawLine(const Offset(-128, 170), const Offset(-118, 184), isaret);
    c.drawLine(const Offset(-118, 184), const Offset(-106, 184), isaret);
    c.drawCircle(const Offset(-152, 170), 6,
        Paint()..color = const Color(0xFF55585F));
    c.drawPath(
        Path()
          ..moveTo(-92, 162)
          ..lineTo(-82, 170)
          ..lineTo(-92, 178)
          ..close(),
        Paint()..color = const Color(0xFF55585F));
  }

  void _usbYuvasi(Canvas c) {
    const r = Rect.fromLTRB(-58, 112, 104, 228);
    c.drawRect(r.shift(const Offset(0, 5)),
        Paint()..color = Colors.black.withValues(alpha: 0.18));
    c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9EBEE), Color(0xFFC3C7CD), Color(0xFFD5D8DC)],
            stops: [0, 0.6, 1],
          ).createShader(r));
    c.drawRect(const Rect.fromLTRB(-58, 112, -46, 228),
        Paint()..color = const Color(0xFFA9AEB5));
    c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF9DA2A9));
  }

  void _gucGirisi(Canvas c) {
    const r = Rect.fromLTRB(-28, 410, 112, 522);
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)),
        Paint()..color = const Color(0xFF26272A));
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(-28, 410, 112, 426), const Radius.circular(6)),
        Paint()..color = const Color(0xFF3A3B3F));
    // On yuz (fisin girdigi yer).
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTRB(-28, 404, 10, 528), const Radius.circular(6)),
        Paint()..color = const Color(0xFF1A1B1D));
    c.drawRect(const Rect.fromLTRB(-24, 444, 4, 488),
        Paint()..color = const Color(0xFF0C0C0D));
  }

  void _resetDugmesi(Canvas c) {
    const r = Rect.fromLTWH(26, 16, 74, 74);
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)),
        Paint()..color = const Color(0xFFE6E7E9));
    c.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFB9BCC1));
    c.drawCircle(r.center + const Offset(0, 2), 22,
        Paint()..color = const Color(0xFF7E2A1E));
    c.drawCircle(r.center, 21, Paint()..color = const Color(0xFFB8432F));
    c.drawCircle(r.center - const Offset(7, 7), 6,
        Paint()..color = Colors.white.withValues(alpha: 0.28));
  }

  void _regulator(Canvas c) {
    final metal = Paint()..color = const Color(0xFFC4C8CE);
    for (final y in const [340.0, 362.0, 384.0]) {
      c.drawRect(Rect.fromLTWH(84, y, 26, 8), metal);
    }
    c.drawRect(const Rect.fromLTWH(38, 318, 34, 14), metal);
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(30, 328, 56, 70), const Radius.circular(3)),
        Paint()..color = const Color(0xFF242528));
  }

  void _kondansatorler(Canvas c) {
    for (final m in const [Offset(170, 446), Offset(244, 446)]) {
      c.drawCircle(m + const Offset(0, 3), 31,
          Paint()..color = Colors.black.withValues(alpha: 0.2));
      c.drawCircle(
          m,
          30,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-0.3, -0.4),
              colors: [Color(0xFFF4F5F7), Color(0xFFBFC3C9)],
            ).createShader(Rect.fromCircle(center: m, radius: 30)));
      // Alt yarim: koyu (eksi kutup bandi).
      c.drawArc(Rect.fromCircle(center: m, radius: 30), 0.15, math.pi - 0.3,
          false, Paint()..color = const Color(0xFF2C2E33));
      c.drawCircle(
          m,
          30,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFF8E939B));
    }
  }

  void _kristal(Canvas c) {
    const r = Rect.fromLTWH(118, 254, 124, 42);
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(21)),
        Paint()..color = const Color(0xFFB4B9C0));
    c.drawRRect(
        RRect.fromRectAndRadius(r.deflate(4), const Radius.circular(17)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F1F3), Color(0xFFCDD1D6)],
          ).createShader(r));
    _yazi(c, '16.000', r.center, 15,
        renk: const Color(0xFF9CA2AA), agirlik: FontWeight.w700);
  }

  void _kucukCipler(Canvas c) {
    final siyah = Paint()..color = const Color(0xFF232427);
    final metal = Paint()..color = const Color(0xFFBFC4CA);
    // USB-seri yonga (kare).
    for (var i = 0; i < 6; i++) {
      final d = 166.0 + i * 8;
      c.drawRect(Rect.fromLTWH(d, 152, 4, 6), metal);
      c.drawRect(Rect.fromLTWH(d, 210, 4, 6), metal);
      c.drawRect(Rect.fromLTWH(156, d + 6, 6, 4), metal);
      c.drawRect(Rect.fromLTWH(214, d + 6, 6, 4), metal);
    }
    c.drawRect(const Rect.fromLTWH(160, 156, 56, 56), siyah);
    // Kucuk kare yonga.
    c.drawRect(const Rect.fromLTWH(178, 318, 32, 32), siyah);
    // 8 bacakli SMD.
    for (var i = 0; i < 4; i++) {
      c.drawRect(Rect.fromLTWH(198, 376 + i * 9.0, 8, 4), metal);
      c.drawRect(Rect.fromLTWH(232, 376 + i * 9.0, 8, 4), metal);
    }
    c.drawRect(const Rect.fromLTWH(204, 372, 30, 38), siyah);
    // Kucuk SMD direncler/kondansatorler.
    final bej = Paint()..color = const Color(0xFFCDB58A);
    for (final o in const [
      Offset(300, 236),
      Offset(330, 236),
      Offset(360, 236),
      Offset(120, 330),
      Offset(300, 284),
    ]) {
      c.drawRect(Rect.fromLTWH(o.dx, o.dy, 18, 10), metal);
      c.drawRect(Rect.fromLTWH(o.dx + 4, o.dy, 10, 10), bej);
    }
  }

  void _islemci(Canvas c) {
    const r = Rect.fromLTRB(272, 314, 638, 400);
    final metal = Paint()..color = const Color(0xFFC9CDD2);
    for (var i = 0; i < 14; i++) {
      final x = r.left + (r.width - 13 * UnoOlcu.adim) / 2 + i * UnoOlcu.adim;
      c.drawRect(Rect.fromLTWH(x - 6, r.top - 8, 12, 10), metal);
      c.drawRect(Rect.fromLTWH(x - 6, r.bottom - 2, 12, 10), metal);
    }
    // Soket.
    c.drawRRect(
        RRect.fromRectAndRadius(r.inflate(3), const Radius.circular(5)),
        Paint()..color = const Color(0xFF3B3D42));
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)),
        Paint()..color = const Color(0xFF202124));
    c.drawRect(Rect.fromLTRB(r.left, r.top, r.right, r.top + 10),
        Paint()..color = Colors.white.withValues(alpha: 0.05));
    // Centik ve noktalar.
    c.drawArc(Rect.fromCircle(center: Offset(r.left, r.center.dy), radius: 13),
        -math.pi / 2, math.pi, true, Paint()..color = const Color(0xFF111214));
    c.drawCircle(Offset(r.left + 48, r.center.dy), 11,
        Paint()..color = const Color(0xFF141517));
    c.drawCircle(Offset(r.right - 30, r.center.dy), 11,
        Paint()..color = const Color(0xFF141517));
  }

  void _baslikBlogu(Canvas c, double x, double y, int adet) {
    final r = Rect.fromLTWH(x, y, adet * UnoOlcu.adim, UnoOlcu.baslikH);
    c.drawRect(r.shift(const Offset(0, 3)),
        Paint()..color = Colors.black.withValues(alpha: 0.25));
    c.drawRect(r, Paint()..color = baslik);
    c.drawRect(Rect.fromLTWH(x, y, r.width, 3),
        Paint()..color = const Color(0xFF45464B));
    for (var i = 0; i < adet; i++) {
      final m = Offset(x + UnoOlcu.adim * (i + 0.5), y + UnoOlcu.baslikH / 2);
      c.drawRect(Rect.fromCenter(center: m, width: 15, height: 15),
          Paint()..color = const Color(0xFF55575D));
      c.drawRect(Rect.fromCenter(center: m, width: 11, height: 11),
          Paint()..color = const Color(0xFF0E0E10));
    }
  }

  void _basliklar(Canvas c) {
    _baslikBlogu(c, UnoOlcu.dijital1X, UnoOlcu.ustY, 10);
    _baslikBlogu(c, UnoOlcu.dijital2X, UnoOlcu.ustY, 8);
    _baslikBlogu(c, UnoOlcu.gucX, UnoOlcu.altY, 8);
    _baslikBlogu(c, UnoOlcu.analogX, UnoOlcu.altY, 6);
  }

  void _etiketler(Canvas c) {
    const ust = UnoOlcu.ustY + UnoOlcu.baslikH + 8;
    const ust1 = ['', '', 'AREF', 'GND', '13', '12', '~11', '~10', '~9', '8'];
    const ust2 = ['7', '~6', '~5', '4', '~3', '2', 'TX>1', 'RX<0'];
    for (var i = 0; i < ust1.length; i++) {
      if (ust1[i].isEmpty) continue;
      _dikey(c, ust1[i],
          UnoOlcu.dijital1X + UnoOlcu.adim * (i + 0.5), ust, ustten: true);
    }
    for (var i = 0; i < ust2.length; i++) {
      _dikey(c, ust2[i],
          UnoOlcu.dijital2X + UnoOlcu.adim * (i + 0.5), ust, ustten: true);
    }
    final cizgi = Paint()
      ..color = yazi
      ..strokeWidth = 3;
    c.drawLine(const Offset(300, 100), const Offset(640, 100), cizgi);
    _yazi(c, 'DIGITAL (PWM~)', const Offset(538, 118), 20);

    const alt = UnoOlcu.altY - 8;
    const guc = ['', 'IOREF', 'RESET', '3.3V', '5V', 'GND', 'GND', 'Vin'];
    for (var i = 0; i < guc.length; i++) {
      if (guc[i].isEmpty) continue;
      _dikey(c, guc[i], UnoOlcu.gucX + UnoOlcu.adim * (i + 0.5), alt,
          ustten: false, boy: 13.5);
    }
    for (var i = 0; i < 6; i++) {
      _dikey(c, 'A$i', UnoOlcu.analogX + UnoOlcu.adim * (i + 0.5), alt,
          ustten: false, boy: 16);
    }
    c.drawLine(const Offset(286, 440), const Offset(454, 440), cizgi);
    c.drawLine(const Offset(472, 440), const Offset(620, 440), cizgi);
    _yazi(c, 'POWER', const Offset(396, 425), 18);
    _yazi(c, 'ANALOG IN', const Offset(546, 425), 18);
  }

  void _kucukLedler(Canvas c) {
    for (final (o, ad) in const [
      (UnoOlcu.lLedi, 'L'),
      (UnoOlcu.txLedi, 'TX'),
      (UnoOlcu.rxLedi, 'RX'),
    ]) {
      kucukLedGovdesi(c, o);
      _yazi(c, ad, o - const Offset(34, 0), 15, sag: true);
    }
    kucukLedGovdesi(c, UnoOlcu.onLedi);
    _yazi(c, 'ON', UnoOlcu.onLedi + const Offset(36, 0), 15);
  }

  /// SMD ledin sonukken hali.
  static void kucukLedGovdesi(Canvas c, Offset o) {
    c.drawRect(Rect.fromCenter(center: o, width: 24, height: 13),
        Paint()..color = const Color(0xFFE8E4D6));
    c.drawRect(Rect.fromCenter(center: o, width: 10, height: 9),
        Paint()..color = const Color(0xFFB9B3A0));
  }

  void _dikey(Canvas c, String s, double x, double y,
      {required bool ustten, double boy = 15}) {
    final tp = _tp(s, boy, yazi, FontWeight.w800, 0.4);
    c.save();
    // Yazi asagidan yukari okunuyor (90 derece sola donuk).
    c.translate(x, ustten ? y + tp.width : y);
    c.rotate(-math.pi / 2);
    tp.paint(c, Offset(0, -tp.height / 2));
    c.restore();
  }

  void _yazi(Canvas c, String s, Offset m, double boy,
      {Color renk = yazi,
      FontWeight agirlik = FontWeight.w800,
      double aralik = 0.6,
      bool sag = false}) {
    final tp = _tp(s, boy, renk, agirlik, aralik);
    tp.paint(
        c, m - Offset(sag ? tp.width : tp.width / 2, tp.height / 2));
  }

  static TextPainter _tp(
          String s, double boy, Color renk, FontWeight agirlik, double aralik) =>
      TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: boy,
            fontWeight: agirlik,
            color: renk,
            letterSpacing: aralik,
            height: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  bool shouldRepaint(covariant UnoKartBoyaci old) => old.o != o || old.s != s;
}

/// Kartin uzerindeki isiklar: ON (hep yanik), L (pin 13), etkin pinler.
class _KartIsiklari extends CustomPainter {
  _KartIsiklari({
    required this.kart,
    required this.o,
    required this.s,
    required this.kabloluPinler,
  }) : super(repaint: kart);

  final UnoKarti kart;
  final Offset o;
  final double s;
  final List<int> kabloluPinler;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(s);
    _led(canvas, UnoOlcu.onLedi, const Color(0xFF4CE070), 1);
    _led(canvas, UnoOlcu.lLedi, const Color(0xFFFFA726), kart.parlaklik(13));
    // Kablosuz etkin pinler: delik sari parliyor.
    for (var pin = 0; pin <= 13; pin++) {
      if (kabloluPinler.contains(pin)) continue;
      final p = math.max(kart.parlaklik(pin),
          kart.servo.containsKey(pin) ? 1.0 : 0.0);
      if (p <= 0) continue;
      final m = UnoOlcu.dijitalPin(pin);
      canvas.drawRect(Rect.fromCenter(center: m, width: 11, height: 11),
          Paint()..color = Color.lerp(
              const Color(0xFF0E0E10), const Color(0xFFFFD54F), p)!);
    }
    canvas.restore();
  }

  void _led(Canvas c, Offset o, Color renk, double p) {
    if (p <= 0) return;
    c.drawCircle(
        o,
        46,
        Paint()
          ..shader = RadialGradient(colors: [
            renk.withValues(alpha: 0.85 * p),
            renk.withValues(alpha: 0.35 * p),
            renk.withValues(alpha: 0),
          ], stops: const [
            0,
            0.35,
            1
          ]).createShader(Rect.fromCircle(center: o, radius: 46)));
    c.drawRect(Rect.fromCenter(center: o, width: 24, height: 13),
        Paint()..color = Color.lerp(const Color(0xFFE8E4D6), renk, p)!);
    c.drawRect(Rect.fromCenter(center: o, width: 10, height: 9),
        Paint()..color = Color.lerp(renk, Colors.white, 0.6 * p)!);
  }

  @override
  bool shouldRepaint(covariant _KartIsiklari old) =>
      old.kart != kart || old.o != o || old.s != s;
}

// ======================================================================
// Breadboard
// ======================================================================

/// Breadboard, direncler, LED bacaklari ve kablolar (durgun).
class _DevreBoyaci extends CustomPainter {
  _DevreBoyaci(this.y);
  final UnoYerlesim y;

  static const Color _kirmizi = Color(0xFFE0322F);
  static const Color _mavi = Color(0xFF2F6FD6);

  @override
  void paint(Canvas c, Size size) {
    _breadboard(c);
    for (var k = 0; k < y.ledler.length; k++) {
      _direnc(c, y.sutunlar[k]);
      _ledBacaklari(c, k);
    }
    _kablolar(c);
  }

  void _breadboard(Canvas c) {
    final p = y.p;
    final bb = y.bb;
    final govde = RRect.fromRectAndRadius(bb, Radius.circular(p * 0.35));
    c.drawRRect(
        govde.shift(Offset(0, p * 0.25)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.12)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p * 0.3));
    c.drawRRect(govde, Paint()..color = const Color(0xFFEDEEEF));
    c.drawRRect(
        govde,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFFC9CCD0));
    // Guc hatlarinin ayri seritleri hafif koyu.
    final ray = Paint()..color = const Color(0xFFE3E5E7);
    c.drawRect(
        Rect.fromLTRB(bb.left + 1, y.satirY(0.15), bb.right - 1,
            y.satirY(2.7)),
        ray);
    c.drawRect(
        Rect.fromLTRB(bb.left + 1, y.satirY(14.65), bb.right - 1,
            y.satirY(17.15)),
        ray);
    // Orta kanal.
    c.drawRect(
        Rect.fromLTRB(bb.left + p * 0.4, y.satirY(_Bb.kanal - 0.32),
            bb.right - p * 0.4, y.satirY(_Bb.kanal + 0.32)),
        Paint()..color = const Color(0xFFD5D8DB));

    // Kirmizi/mavi hat cizgileri.
    final x0 = y.sutunX(1) - p * 0.6;
    final x1 = y.sutunX(30) + p * 0.6;
    void cizgi(double sat, Color r) => c.drawLine(Offset(x0, y.satirY(sat)),
        Offset(x1, y.satirY(sat)), Paint()
          ..color = r
          ..strokeWidth = math.max(1, p * 0.1));
    cizgi(_Bb.maviUst, _mavi);
    cizgi(_Bb.kirmiziUst, _kirmizi);
    cizgi(_Bb.maviAlt, _mavi);
    cizgi(_Bb.kirmiziAlt, _kirmizi);
    // + / - isaretleri iki uca.
    for (final x in [bb.left + p * 0.7, bb.right - p * 0.7]) {
      _yazi(c, '−', Offset(x, y.satirY(_Bb.eksiUst)), p * 0.75, _mavi);
      _yazi(c, '+', Offset(x, y.satirY(_Bb.artiUst)), p * 0.75, _kirmizi);
      _yazi(c, '−', Offset(x, y.satirY(_Bb.eksiAlt)), p * 0.75, _mavi);
      _yazi(c, '+', Offset(x, y.satirY(_Bb.artiAlt)), p * 0.75, _kirmizi);
    }

    // Delikler.
    final kenar = Paint()..color = const Color(0xFF9EA2A8);
    final ic = Paint()..color = const Color(0xFF3E4146);
    void delik(Offset m) {
      c.drawRect(Rect.fromCenter(center: m, width: p * 0.46, height: p * 0.46),
          kenar);
      c.drawRect(Rect.fromCenter(center: m, width: p * 0.32, height: p * 0.32),
          ic);
    }

    for (var s = 1; s <= 30; s++) {
      final x = y.sutunX(s);
      for (var r = 0; r < 10; r++) {
        delik(Offset(x, y.satirY(r < 5 ? _Bb.j + r : _Bb.e + (r - 5))));
      }
      if (_Bb.rayDeligi(s)) {
        for (final sat in const [
          _Bb.eksiUst,
          _Bb.artiUst,
          _Bb.eksiAlt,
          _Bb.artiAlt
        ]) {
          delik(Offset(x, y.satirY(sat)));
        }
      }
    }

    // Sutun numaralari ve satir harfleri.
    final gri = const Color(0xFF8C9096);
    for (var s = 1; s <= 30; s++) {
      final x = y.sutunX(s);
      _yazi(c, '$s', Offset(x, y.satirY(_Bb.sayiUst)), p * 0.42, gri);
      _yazi(c, '$s', Offset(x, y.satirY(_Bb.sayiAlt)), p * 0.42, gri);
    }
    const harfler = 'jihgfedcba';
    for (var i = 0; i < 10; i++) {
      final sy = y.satirY(i < 5 ? _Bb.j + i : _Bb.e + (i - 5));
      _yazi(c, harfler[i], Offset(bb.left + p * 1.2, sy), p * 0.5, gri);
      _yazi(c, harfler[i], Offset(bb.right - p * 1.0, sy), p * 0.5, gri);
    }
  }

  /// 220 ohm direnc: h satirindan kanalin ustunden e satirina.
  void _direnc(Canvas c, int sutun) {
    final p = y.p;
    final x = y.sutunX(sutun);
    final ust = y.satirY(_Bb.satir('h'));
    final alt = y.satirY(_Bb.satir('e'));
    final orta = (ust + alt) / 2;
    c.drawLine(
        Offset(x, ust),
        Offset(x, alt),
        Paint()
          ..color = const Color(0xFF9DA3AA)
          ..strokeWidth = math.max(1.2, p * 0.14)
          ..strokeCap = StrokeCap.round);
    final govde = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(x, orta), width: p * 0.62, height: p * 2.1),
        Radius.circular(p * 0.3));
    c.drawRRect(govde.shift(Offset(p * 0.06, p * 0.08)),
        Paint()..color = Colors.black.withValues(alpha: 0.18));
    c.drawRRect(
        govde,
        Paint()
          ..shader = const LinearGradient(colors: [
            Color(0xFFF0DDB5),
            Color(0xFFD8BC88),
          ]).createShader(govde.outerRect));
    // Bantlar: kirmizi, kirmizi, kahverengi, altin (220 ohm).
    const bantlar = [
      Color(0xFFD12C2C),
      Color(0xFFD12C2C),
      Color(0xFF7A4A21),
      Color(0xFFC9A23A),
    ];
    final r = govde.outerRect;
    for (var i = 0; i < 4; i++) {
      final by = r.top + r.height * (i < 3 ? 0.2 + i * 0.17 : 0.8);
      c.drawRect(
          Rect.fromLTWH(r.left, by - p * 0.07, r.width, p * 0.14),
          Paint()..color = bantlar[i]);
    }
    c.drawRect(Rect.fromLTWH(r.left + r.width * 0.18, r.top + p * 0.15,
            r.width * 0.16, r.height - p * 0.3),
        Paint()..color = Colors.white.withValues(alpha: 0.25));
  }

  /// LED bacaklari: anot (uzun) b satirina, katot GND hattina kivrik.
  void _ledBacaklari(Canvas c, int k) {
    final p = y.p;
    final sutun = y.sutunlar[k];
    final taban = y.ledTaban(k);
    final bacak = Paint()
      ..color = const Color(0xFFA7ADB4)
      ..strokeWidth = math.max(1.2, p * 0.13)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final anot = Offset(y.sutunX(sutun), y.satirY(_Bb.satir('b')));
    c.drawLine(taban + Offset(-p * 0.3, 0), anot, bacak);
    final katot = Offset(y.sutunX(sutun + 1), y.satirY(_Bb.eksiAlt));
    c.drawPath(
        Path()
          ..moveTo(taban.dx + p * 0.3, taban.dy)
          ..lineTo(taban.dx + p * 0.3, taban.dy + p * 0.5)
          ..lineTo(katot.dx, katot.dy - p * 0.6)
          ..lineTo(katot.dx, katot.dy),
        bacak);
  }

  void _kablolar(Canvas c) {
    final n = y.ledler.length;
    final g = y.serit;
    final s = y.s;
    final kartUst = y.kartO.dy;
    final kartSag = y.kartO.dx + UnoOlcu.kartW * s;
    final kartAlt = y.kartO.dy + UnoOlcu.kartH * s;
    final kalinlik = math.max(2.2, g * 0.6);

    // GND: guc basligindaki ilk GND'den sola, breadboard'un alt GND
    // hattina (1. sutun).
    final gnd = y.kartO + UnoOlcu.gucPin(5) * s;
    final gx = y.sutunX(1);
    _kablo(c, [
      gnd,
      Offset(gnd.dx, kartAlt + g + 2),
      Offset(gx, kartAlt + g + 2),
      Offset(gx, y.satirY(_Bb.eksiAlt)),
    ], const Color(0xFF2B2D31), kalinlik, g);

    // Pinlerden LED sutunlarina: en soldaki baslik pini (en buyuk pin) en
    // distaki serit ve en sagdaki LED; kablolar birbirini kesmiyor.
    for (var k = 0; k < n; k++) {
      final bas = y.kartO + UnoOlcu.dijitalPin(y.ledler[k]) * s;
      final yUst = kartUst - (k + 1) * g;
      final xSag = kartSag + (k + 1) * g;
      final yAlt = y.bb.top - (n - k) * g - 2;
      final x = y.sutunX(y.sutunlar[k]);
      _kablo(c, [
        bas,
        Offset(bas.dx, yUst),
        Offset(xSag, yUst),
        Offset(xSag, yAlt),
        Offset(x, yAlt),
        Offset(x, y.satirY(_Bb.j)),
      ], const Color(0xFFE53935), kalinlik, g);
    }
  }

  void _kablo(Canvas c, List<Offset> n, Color renk, double w, double r) {
    final yol = _yuvarlakYol(n, r * 0.9);
    c.drawPath(
        yol,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w + 1.2
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(renk, Colors.black, 0.35)!);
    c.drawPath(
        yol,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = renk);
    // Uclar: kucuk koyu fis.
    for (final u in [n.first, n.last]) {
      c.drawRect(Rect.fromCenter(center: u, width: w * 1.3, height: w * 1.3),
          Paint()..color = const Color(0xFF3A3C40));
    }
  }

  static Path _yuvarlakYol(List<Offset> n, double r) {
    final yol = Path()..moveTo(n.first.dx, n.first.dy);
    for (var i = 1; i < n.length - 1; i++) {
      final a = n[i - 1], b = n[i], d = n[i + 1];
      final l1 = (b - a).distance, l2 = (d - b).distance;
      if (l1 < 0.01 || l2 < 0.01) {
        yol.lineTo(b.dx, b.dy);
        continue;
      }
      final rr = math.min(r, math.min(l1, l2) / 2);
      final p1 = b - (b - a) / l1 * rr;
      final p2 = b + (d - b) / l2 * rr;
      yol.lineTo(p1.dx, p1.dy);
      yol.quadraticBezierTo(b.dx, b.dy, p2.dx, p2.dy);
    }
    yol.lineTo(n.last.dx, n.last.dy);
    return yol;
  }

  void _yazi(Canvas c, String s, Offset m, double boy, Color renk) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: boy,
          fontWeight: FontWeight.w800,
          color: renk,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, m - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DevreBoyaci old) =>
      old.y.bb != y.bb ||
      old.y.kartO != y.kartO ||
      old.y.s != y.s ||
      old.y.serit != y.serit ||
      !_ayni(old.y.ledler, y.ledler) ||
      !_ayni(old.y.sutunlar, y.sutunlar);

  static bool _ayni(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Pine gore LED rengi.
Color unoLedRengi(int pin) => switch (pin) {
      13 => const Color(0xFFFFC21A),
      12 => const Color(0xFF2EDB5A),
      9 => const Color(0xFFFF3B3B),
      7 => const Color(0xFF1FD3E0),
      6 => const Color(0xFF3D8BFF),
      5 => const Color(0xFF2EDB5A),
      4 => const Color(0xFFFF6A2B),
      3 => const Color(0xFFFFC21A),
      2 => const Color(0xFFFF3B3B),
      10 => const Color(0xFFB45CFF),
      11 => const Color(0xFF1FD3E0),
      _ => const Color(0xFFFF6A2B),
    };

/// Breadboard'daki LED: kubbe, isik halesi. Bacaklari durgun katmanda.
class _LedBoyaci extends CustomPainter {
  _LedBoyaci({required this.kart, required this.pin, required this.p})
      : super(repaint: kart);
  final UnoKarti kart;
  final int pin;

  /// Breadboard delik araligi.
  final double p;

  @override
  void paint(Canvas c, Size s) {
    final isik = kart.parlaklik(pin).clamp(0.0, 1.0);
    final renk = unoLedRengi(pin);
    // Kutu: genislik 5p, kubbe ortada, tabani 3.8p'de.
    final taban = Offset(s.width / 2, 3.8 * p);
    final kw = 1.5 * p;
    final kh = 2.0 * p;
    final kubbe = Rect.fromLTWH(taban.dx - kw / 2, taban.dy - kh, kw, kh);

    if (isik > 0) {
      final m = kubbe.center;
      final r = 2.5 * p;
      c.drawCircle(
          m,
          r,
          Paint()
            ..shader = RadialGradient(colors: [
              renk.withValues(alpha: 0.75 * isik),
              renk.withValues(alpha: 0.28 * isik),
              renk.withValues(alpha: 0),
            ], stops: const [
              0,
              0.4,
              1
            ]).createShader(Rect.fromCircle(center: m, radius: r)));
    }
    final yol = Path()
      ..moveTo(kubbe.left, kubbe.bottom)
      ..lineTo(kubbe.left, kubbe.top + kw / 2)
      ..arcTo(Rect.fromLTWH(kubbe.left, kubbe.top, kw, kw), math.pi, math.pi,
          false)
      ..lineTo(kubbe.right, kubbe.bottom)
      ..close();
    final sonuk = Color.lerp(renk, const Color(0xFF3E4249), 0.55)!;
    final govde = Color.lerp(sonuk, renk, isik)!;
    c.drawPath(
        yol,
        Paint()
          ..shader = LinearGradient(colors: [
            Color.lerp(govde, Colors.white, 0.25 + 0.3 * isik)!,
            govde,
            Color.lerp(govde, Colors.black, 0.2)!,
          ], stops: const [
            0,
            0.45,
            1
          ]).createShader(kubbe));
    // Taban halkasi.
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(kubbe.left - p * 0.14, kubbe.bottom - p * 0.28,
                kw + p * 0.28, p * 0.3),
            Radius.circular(p * 0.08)),
        Paint()..color = Color.lerp(govde, Colors.black, 0.25)!);
    // Yanikken ic cekirdek.
    if (isik > 0) {
      c.drawOval(
          Rect.fromCenter(
              center: kubbe.center + Offset(0, p * 0.15),
              width: kw * 0.5,
              height: kh * 0.45),
          Paint()
            ..color = Color.lerp(renk, Colors.white, 0.75)!
                .withValues(alpha: 0.85 * isik));
    }
    // Parlama.
    c.drawOval(
        Rect.fromLTWH(kubbe.left + kw * 0.18, kubbe.top + kw * 0.22,
            kw * 0.2, kh * 0.32),
        Paint()..color = Colors.white.withValues(alpha: 0.4 + 0.4 * isik));
  }

  @override
  bool shouldRepaint(covariant _LedBoyaci old) =>
      old.pin != pin || old.kart != kart || old.p != p;
}

// ======================================================================
// Diger parcalar
// ======================================================================

/// Buzzer: pin 8 yuksekken ses dalgalari.
class UnoBuzzer extends StatelessWidget {
  const UnoBuzzer(
      {super.key, required this.kart, required this.lang, this.boy = 56});
  final UnoKarti kart;
  final String lang;
  final double boy;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: boy * 1.1,
          height: boy,
          child: CustomPaint(
            key: const ValueKey('uno_buzzer'),
            painter: _BuzzerBoyaci(kart),
          ),
        ),
        _etiket(AppLang.pick(lang,
            tr: 'buzzer 8', en: 'buzzer 8', de: 'Summer 8', es: 'zumbador 8')),
      ],
    );
  }
}

class _BuzzerBoyaci extends CustomPainter {
  _BuzzerBoyaci(this.kart) : super(repaint: kart);
  final UnoKarti kart;

  @override
  void paint(Canvas c, Size s) {
    final acik = kart.dijitalOku(UnoKarti.buzzerPini);
    final m = Offset(s.width * 0.42, s.height * 0.5);
    final r = s.height * 0.32;
    c.drawCircle(m, r, Paint()..color = const Color(0xFF22252B));
    c.drawCircle(
        m,
        r * 0.55,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF555B66));
    c.drawCircle(m, r * 0.15, Paint()..color = const Color(0xFF555B66));
    if (acik) {
      final dalga = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFF8C1A);
      for (var i = 1; i <= 2; i++) {
        c.drawArc(Rect.fromCircle(center: m, radius: r + i * 7.0), -0.6, 1.2,
            false, dalga);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BuzzerBoyaci old) => old.kart != kart;
}

/// Servo: govde ve aciya gore donen kol.
class UnoServo extends StatelessWidget {
  const UnoServo({super.key, required this.kart, required this.pin, this.boy = 60});
  final UnoKarti kart;
  final int pin;
  final double boy;

  @override
  Widget build(BuildContext context) {
    final azalt = Motion.reduced(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: kart,
          builder: (context, _) => TweenAnimationBuilder<double>(
            tween: Tween(end: (kart.servo[pin] ?? 90).toDouble()),
            duration: azalt ? Duration.zero : const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, aci, _) => SizedBox(
              width: boy * 1.2,
              height: boy,
              child: CustomPaint(
                key: ValueKey('uno_servo_$pin'),
                painter: _ServoBoyaci(aci),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: kart,
          builder: (context, _) =>
              _etiket('servo $pin · ${kart.servo[pin] ?? 90}°'),
        ),
      ],
    );
  }
}

class _ServoBoyaci extends CustomPainter {
  _ServoBoyaci(this.aci);
  final double aci;

  @override
  void paint(Canvas c, Size s) {
    final govde = Rect.fromLTWH(s.width * 0.15, s.height * 0.45,
        s.width * 0.7, s.height * 0.5);
    c.drawRRect(RRect.fromRectAndRadius(govde, const Radius.circular(4)),
        Paint()..color = const Color(0xFF2F64C8));
    final mil = Offset(s.width * 0.5, s.height * 0.55);
    // 0° saga, 90° yukari, 180° sola.
    final a = math.pi + aci * math.pi / 180;
    final uc = mil + Offset(math.cos(a), math.sin(a)) * s.height * 0.48;
    c.drawLine(
        mil,
        uc,
        Paint()
          ..color = Colors.white
          ..strokeWidth = s.height * 0.12
          ..strokeCap = StrokeCap.round);
    c.drawLine(
        mil,
        uc,
        Paint()
          ..color = const Color(0xFFDCE3EE)
          ..strokeWidth = s.height * 0.06
          ..strokeCap = StrokeCap.round);
    c.drawCircle(mil, s.height * 0.08, Paint()..color = const Color(0xFF9AA1AB));
  }

  @override
  bool shouldRepaint(covariant _ServoBoyaci old) => old.aci != aci;
}

/// Basilabilir buton (pin 2). Basili tutulunca "dijital oku pin 2" dogru.
class UnoButon extends StatelessWidget {
  const UnoButon(
      {super.key, required this.kart, required this.lang, this.boy = 56});
  final UnoKarti kart;
  final String lang;
  final double boy;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLang.pick(lang,
          tr: 'Buton, pin 2. Basılı tut.',
          en: 'Button, pin 2. Hold it down.',
          de: 'Taster, Pin 2. Gedrückt halten.',
          es: 'Botón, pin 2. Mantenlo pulsado.'),
      child: GestureDetector(
        key: const ValueKey('uno_buton'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => kart.butonBasili = true,
        onTapUp: (_) => kart.butonBasili = false,
        onTapCancel: () => kart.butonBasili = false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: math.max(48, boy),
              height: math.max(48, boy),
              child: CustomPaint(painter: _ButonBoyaci(kart)),
            ),
            _etiket(AppLang.pick(lang,
                tr: 'buton 2', en: 'button 2', de: 'Taster 2', es: 'botón 2')),
          ],
        ),
      ),
    );
  }
}

class _ButonBoyaci extends CustomPainter {
  _ButonBoyaci(this.kart) : super(repaint: kart);
  final UnoKarti kart;

  @override
  void paint(Canvas c, Size s) {
    final basili = kart.butonBasili;
    final taban = Rect.fromCenter(
        center: s.center(Offset.zero), width: s.width * 0.8, height: s.height * 0.8);
    c.drawRRect(RRect.fromRectAndRadius(taban, const Radius.circular(6)),
        Paint()..color = const Color(0xFF2A2D33));
    for (final k in [
      taban.topLeft + const Offset(5, 5),
      taban.topRight + const Offset(-5, 5),
      taban.bottomLeft + const Offset(5, -5),
      taban.bottomRight + const Offset(-5, -5),
    ]) {
      c.drawCircle(k, 2.2, Paint()..color = const Color(0xFF8A9099));
    }
    final r = s.width * (basili ? 0.21 : 0.25);
    final m = s.center(Offset(0, basili ? 1.5 : -1.5));
    if (!basili) {
      c.drawCircle(m + const Offset(0, 3), r,
          Paint()..color = const Color(0xFF8E1F1F));
    }
    c.drawCircle(
        m, r, Paint()..color = basili ? const Color(0xFFC62828) : const Color(0xFFE53935));
    c.drawCircle(m - Offset(r * 0.3, r * 0.3), r * 0.25,
        Paint()..color = Colors.white.withValues(alpha: 0.35));
  }

  @override
  bool shouldRepaint(covariant _ButonBoyaci old) => old.kart != kart;
}

Widget _etiket(String s) => Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        s,
        maxLines: 1,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF5B6070),
        ),
      ),
    );
