import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../ui/motion.dart';
import '../../utils/lang.dart';
import '../yurutme/mblock_uno.dart';

/// SANAL ARDUINO UNO — kartin cizimi ve cevresindeki parcalar.
///
/// Kart kendi cizimimiz (CustomPainter): fotograf ya da baska bir
/// kaynaktan kopya degil. Arduino'nun turkuaz rengi, ust kenarda dijital
/// pinler, altta guc ve analog pinler, USB ve guc girisi, ortada islemci,
/// pin 13'un yanindaki "L" ledi ve yesil "ON" ledi.
///
/// Cevresindeki parcalar programdan geliyor ([UnoParcalari]): program
/// pin 9'a yaziyorsa pin 9'da bir LED, "dijital oku pin 2" varsa
/// basilabilir bir buton, "analog oku" varsa potansiyometre surgusu,
/// mesafe sensoru, servo, buzzer ve seri port monitoru.
///
/// Performans: her parca [UnoKarti]'yi kendi AnimatedBuilder'iyla
/// dinliyor; kart degisince yalnizca boyanan parcalar yeniden ciziliyor,
/// butun sahne RepaintBoundary icinde.
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

  /// Gorunumun yuksekligi (sahne karti sabit boyda kalsin, yerlesim
  /// kaymasin).
  static double yukseklik(UnoParcalari p, double genislik) {
    var h = 10 + _kartYuksekligi(genislik) + 10;
    if (p.pot) h += 46;
    if (p.mesafe) h += 46;
    if (p.seri) h += 84;
    return h;
  }

  static double _kartYuksekligi(double genislik) =>
      math.min(150.0, (genislik - 24) * 0.42);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(builder: (context, c) {
        final kartH = _kartYuksekligi(c.maxWidth);
        final kartW = kartH * 1.36;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: kartH,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: kartW,
                      height: kartH,
                      child: CustomPaint(
                        key: const ValueKey('uno_karti'),
                        painter: UnoKartBoyaci(kart: kart, lang: lang),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _parcalar(kartH)),
                  ],
                ),
              ),
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
    );
  }

  Widget _parcalar(double h) {
    final ogeler = <Widget>[
      for (final p in parcalar.ledler) UnoLed(kart: kart, pin: p, boy: h * 0.42),
      if (parcalar.buzzer) UnoBuzzer(kart: kart, boy: h * 0.42, lang: lang),
      for (final p in parcalar.servolar)
        UnoServo(kart: kart, pin: p, boy: h * 0.46),
      if (parcalar.buton) UnoButon(kart: kart, boy: h * 0.42, lang: lang),
    ];
    if (ogeler.isEmpty) {
      return Center(
        child: Text(
          _t('Bloklarını kur, kart burada çalışacak.',
              'Build your blocks, the board runs here.',
              'Bau deine Blöcke, die Platine läuft hier.',
              'Construye tus bloques, la placa funciona aquí.'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }
    return Center(
      child: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 10,
          runSpacing: 6,
          children: ogeler,
        ),
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
          Icon(ikon, size: 18, color: const Color(0xFF00878F)),
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
                activeColor: const Color(0xFF00979D),
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
                  color: Color(0xFF00878F),
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

/// Kartin kendisi.
class UnoKartBoyaci extends CustomPainter {
  UnoKartBoyaci({required this.kart, required this.lang}) : super(repaint: kart);

  final UnoKarti kart;
  final String lang;

  static const Color turkuaz = Color(0xFF00979D);
  static const Color koyuTurkuaz = Color(0xFF006468);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.04, 0, w * 0.96, h), Radius.circular(h * 0.06));

    // Golge + kart.
    canvas.drawRRect(
        r.shift(const Offset(0, 3)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawRRect(r, Paint()..color = turkuaz);
    canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = koyuTurkuaz);

    // Vida delikleri.
    final delik = Paint()..color = Colors.white;
    for (final o in [
      Offset(w * 0.12, h * 0.1),
      Offset(w * 0.93, h * 0.12),
      Offset(w * 0.93, h * 0.88),
      Offset(w * 0.2, h * 0.9),
    ]) {
      canvas.drawCircle(o, h * 0.035, delik);
      canvas.drawCircle(
          o,
          h * 0.035,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = const Color(0xFFB8C4C6));
    }

    // USB (gumus) ve guc girisi (siyah), sol kenarda tasiyor.
    final usb = Rect.fromLTWH(0, h * 0.14, w * 0.2, h * 0.26);
    canvas.drawRRect(RRect.fromRectAndRadius(usb, const Radius.circular(2)),
        Paint()..color = const Color(0xFFC9CED6));
    canvas.drawRect(usb.deflate(h * 0.035),
        Paint()..color = const Color(0xFF9AA1AB));
    final guc = Rect.fromLTWH(0, h * 0.66, w * 0.17, h * 0.2);
    canvas.drawRRect(RRect.fromRectAndRadius(guc, const Radius.circular(2)),
        Paint()..color = const Color(0xFF202327));

    // Ust pin seridi: 14 dijital pin (sagdan sola 0..13 gibi; 13 solda).
    final ustY = h * 0.05;
    final pinW = w * 0.042;
    final ustX0 = w * 0.36;
    canvas.drawRect(
        Rect.fromLTWH(ustX0 - pinW * 0.3, ustY, pinW * 14.6, pinW * 1.4),
        Paint()..color = const Color(0xFF1B1E22));
    for (var i = 0; i < 14; i++) {
      final pin = 13 - i;
      final x = ustX0 + i * pinW;
      final aktif = kart.parlaklik(pin) > 0 || kart.servo.containsKey(pin);
      canvas.drawRect(
          Rect.fromLTWH(x + pinW * 0.2, ustY + pinW * 0.3, pinW * 0.6, pinW * 0.8),
          Paint()
            ..color = aktif ? const Color(0xFFFFE066) : const Color(0xFF4A4F57));
    }
    _yazi(canvas, 'DIGITAL (PWM~)', Offset(ustX0 + pinW * 7, ustY + pinW * 2.4),
        h * 0.06);

    // Alt pin seridi: guc + analog.
    final altY = h * 0.95 - pinW * 1.4;
    final altX0 = w * 0.42;
    canvas.drawRect(Rect.fromLTWH(altX0, altY, pinW * 12.4, pinW * 1.4),
        Paint()..color = const Color(0xFF1B1E22));
    for (var i = 0; i < 12; i++) {
      final analog = i >= 6;
      final aktif = analog && i == 6 && kart.pot > 0;
      canvas.drawRect(
          Rect.fromLTWH(altX0 + i * pinW + pinW * 0.4, altY + pinW * 0.3,
              pinW * 0.6, pinW * 0.8),
          Paint()
            ..color = aktif ? const Color(0xFF9EE6FF) : const Color(0xFF4A4F57));
    }
    _yazi(canvas, 'POWER', Offset(altX0 + pinW * 3, altY - h * 0.05), h * 0.055);
    _yazi(canvas, 'ANALOG IN', Offset(altX0 + pinW * 9.2, altY - h * 0.05),
        h * 0.055);

    // Islemci.
    final cip = Rect.fromLTWH(w * 0.5, h * 0.52, w * 0.4, h * 0.14);
    final bacak = Paint()..color = const Color(0xFFBFC5CC);
    for (var i = 0; i < 12; i++) {
      final x = cip.left + cip.width * (i + 0.5) / 12;
      canvas.drawRect(Rect.fromLTWH(x - 1, cip.top - 3, 2, 3), bacak);
      canvas.drawRect(Rect.fromLTWH(x - 1, cip.bottom, 2, 3), bacak);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(cip, const Radius.circular(2)),
        Paint()..color = const Color(0xFF1F2226));

    // Logo: sonsuzluk isareti ve UNO yazisi.
    _sonsuzluk(canvas, Offset(w * 0.5, h * 0.36), h * 0.07);
    _yazi(canvas, 'UNO', Offset(w * 0.72, h * 0.36), h * 0.13,
        kalin: true, italik: true);

    // ON (yesil, hep yanik) ve L (pin 13) ledleri.
    _kucukLed(canvas, Offset(w * 0.27, h * 0.33), h, const Color(0xFF3CE05B), 1,
        'ON');
    _kucukLed(canvas, Offset(w * 0.27, h * 0.47), h, const Color(0xFFFFB300),
        kart.parlaklik(13), 'L');
  }

  void _kucukLed(Canvas c, Offset o, double h, Color renk, double p, String ad) {
    if (p > 0) {
      c.drawCircle(
          o,
          h * 0.09,
          Paint()
            ..color = renk.withValues(alpha: 0.55 * p)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.05));
    }
    final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: o, width: h * 0.07, height: h * 0.045),
        const Radius.circular(1.5));
    c.drawRRect(
        rr,
        Paint()
          ..color = Color.lerp(const Color(0xFF6E7A7B), renk, p.clamp(0, 1))!);
    _yazi(c, ad, o + Offset(h * 0.1, 0), h * 0.055);
  }

  void _sonsuzluk(Canvas c, Offset m, double r) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.32
      ..color = Colors.white;
    c.drawCircle(m - Offset(r * 0.95, 0), r, p);
    c.drawCircle(m + Offset(r * 0.95, 0), r, p);
  }

  void _yazi(Canvas c, String s, Offset merkez, double boy,
      {bool kalin = false, bool italik = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: boy,
          fontWeight: kalin ? FontWeight.w900 : FontWeight.w700,
          fontStyle: italik ? FontStyle.italic : FontStyle.normal,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, merkez - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant UnoKartBoyaci old) =>
      old.kart != kart || old.lang != lang;
}

/// Pine gore LED rengi.
Color unoLedRengi(int pin) => switch (pin) {
      13 => const Color(0xFFFFC21A),
      9 => const Color(0xFFFF3B3B),
      5 => const Color(0xFF2EDB5A),
      6 => const Color(0xFF3D8BFF),
      10 => const Color(0xFFB45CFF),
      11 => const Color(0xFF1FD3E0),
      _ => const Color(0xFFFF6A2B),
    };

/// Harici LED: kubbe, isik halesi, bacaklar, altinda pin yazisi.
class UnoLed extends StatelessWidget {
  const UnoLed({super.key, required this.kart, required this.pin, this.boy = 56});

  final UnoKarti kart;
  final int pin;
  final double boy;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: boy * 0.8,
          height: boy,
          child: CustomPaint(
            key: ValueKey('uno_led_$pin'),
            painter: _LedBoyaci(kart: kart, pin: pin),
          ),
        ),
        _etiket('pin $pin'),
      ],
    );
  }
}

class _LedBoyaci extends CustomPainter {
  _LedBoyaci({required this.kart, required this.pin}) : super(repaint: kart);
  final UnoKarti kart;
  final int pin;

  @override
  void paint(Canvas c, Size s) {
    final p = kart.parlaklik(pin);
    final renk = unoLedRengi(pin);
    final w = s.width;
    final h = s.height;
    final kubbe = Rect.fromLTWH(w * 0.2, h * 0.06, w * 0.6, h * 0.56);
    if (p > 0) {
      c.drawCircle(
          kubbe.center,
          w * 0.62,
          Paint()
            ..shader = RadialGradient(colors: [
              renk.withValues(alpha: 0.75 * p),
              renk.withValues(alpha: 0),
            ]).createShader(Rect.fromCircle(center: kubbe.center, radius: w * 0.62)));
    }
    // Bacaklar (uzun olan +).
    final bacak = Paint()
      ..color = const Color(0xFF9AA1AB)
      ..strokeWidth = 2;
    c.drawLine(Offset(w * 0.38, kubbe.bottom), Offset(w * 0.38, h), bacak);
    c.drawLine(Offset(w * 0.62, kubbe.bottom), Offset(w * 0.62, h * 0.88), bacak);
    // Kubbe.
    final yol = Path()
      ..moveTo(kubbe.left, kubbe.bottom)
      ..lineTo(kubbe.left, kubbe.top + kubbe.width / 2)
      ..arcTo(Rect.fromLTWH(kubbe.left, kubbe.top, kubbe.width, kubbe.width),
          math.pi, math.pi, false)
      ..lineTo(kubbe.right, kubbe.bottom)
      ..close();
    final sonuk = Color.lerp(renk, const Color(0xFF555A63), 0.62)!;
    c.drawPath(yol, Paint()..color = Color.lerp(sonuk, renk, p)!);
    c.drawRect(
        Rect.fromLTWH(kubbe.left - 2, kubbe.bottom - 3, kubbe.width + 4, 4),
        Paint()..color = Color.lerp(sonuk, renk, p * 0.8)!);
    // Parlama.
    c.drawOval(
        Rect.fromLTWH(kubbe.left + kubbe.width * 0.2, kubbe.top + kubbe.width * 0.2,
            kubbe.width * 0.22, kubbe.height * 0.32),
        Paint()..color = Colors.white.withValues(alpha: 0.35 + 0.5 * p));
  }

  @override
  bool shouldRepaint(covariant _LedBoyaci old) => old.pin != pin || old.kart != kart;
}

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
              width: boy,
              height: boy,
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
