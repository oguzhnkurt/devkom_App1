import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'devi_gokyuzu.dart';
import '../utils/lang.dart';

/// Uygulamanin acilis sahnesi (Ekim 2026).
///
/// NEDEN YENIDEN YAZILDI
/// ---------------------
/// Acilista arka arkaya IKI ayri ekran geliyordu: once mavi-mor bir
/// gecis ustunde ince "Yazilim • Robotik • Yapay Zeka" yazisi ve bir
/// donen halka, sonra oturum yuklenirken baska renkte, baska yerlesimde
/// ve yalnizca Turkce "Yazilim ve Robotik Ogren" yazan ikinci bir ekran.
/// Ikisi birbirini tutmuyordu; ikincisi her dilde Turkce'ydi.
///
/// Simdi tek bir sahne var ve iki yerde de o kullaniliyor:
///
///  * Ilk acilista [giris] acik: simge yaylanarak gelir, arkasinda isik
///    halkalari dalgalanir, "DevEducation" harf harf yerine duser (tek renk
///    beyaz), altinda "Yazilim • Robotik • Yapay Zeka" belirir. Arka planda
///    saydam, silik Scratch/mBlock bloklari yavasca suzulur.
///  * Oturum hala yukleniyorsa ayni sahne SON HALIYLE kalir; yukleniyor
///    isareti donen bir halka degil, yazinin altinda nabiz atan bir cizgi.
///    Gecis fark edilmez.
///
/// Zemin "gece uzayi" (#111833); iOS ve Android yerel acilis ekrani da ayni
/// renkte, boylece yerel
/// acilis ekranindan Flutter'a geciste renk sicramasi olmasin.
///
/// Yazi tipi: "DevEducation" Baloo 2 ExtraBold (yuvarlak, cocuk dostu,
/// OFL); geri kalan her yer uygulamanin Nunito'su.
///
/// Hareketi azalt aciksa her sey dogrudan son halinde cizilir.
/// Acilis sahnesinin renk takimi.
class AcilisTema {
  const AcilisTema({
    required this.ad,
    required this.zemin,
    required this.dev,
    required this.yazi,
    this.isik = Colors.white,
    this.yildiz = 1.0,
    this.yaziGolgesi = true,
  });

  final String ad;
  final List<Color> zemin;
  final Color dev;
  final Color yazi;

  /// Halkalarin rengi.
  final Color isik;

  /// Takimyildiz parlakligi (0 = yok).
  final double yildiz;
  final bool yaziGolgesi;

  /// Secilen tema (Ekim 2026): gece uzayi, "DevEducation" tek renk beyaz.
  static const uzay = AcilisTema(
    ad: 'Gece Uzayı',
    zemin: [Color(0xFF0A0D1F), Color(0xFF111833), Color(0xFF1A2550)],
    dev: Colors.white,
    yazi: Colors.white,
    isik: Colors.white,
    yildiz: 1.4,
  );
}

class AcilisSahnesi extends StatefulWidget {
  const AcilisSahnesi({
    super.key,
    this.giris = true,
    this.tema = AcilisTema.uzay,
  });

  final AcilisTema tema;

  /// Giris animasyonu oynasin mi? Ikinci gosterimde (oturum yuklenirken)
  /// false: sahne son haliyle durur, yalnizca bekleme isigi akar.
  final bool giris;

  /// Yerel acilis ekraninin rengiyle ayni (iOS storyboard, Android
  /// launch_background).
  static const Color zemin = Color(0xFF111833);

  @override
  State<AcilisSahnesi> createState() => _AcilisSahnesiState();
}

class _AcilisSahnesiState extends State<AcilisSahnesi>
    with TickerProviderStateMixin {
  late final AnimationController _giris = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2100),
  );

  /// Surekli donen: halkalar, yorunge, bekleme isigi, parilti.
  late final AnimationController _dongu = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  /// Arka planda suzulen bloklar icin yavas dongu.
  late final AnimationController _ucus = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  );

  bool _ayarlandi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ayarlandi) return;
    _ayarlandi = true;
    final azHareket = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!widget.giris || azHareket) {
      _giris.value = 1;
    } else {
      _giris.forward();
    }
    if (!azHareket) {
      _dongu.repeat();
      _ucus.repeat();
    }
  }

  @override
  void dispose() {
    _giris.dispose();
    _dongu.dispose();
    _ucus.dispose();
    super.dispose();
  }

  /// [a]-[b] araligini 0..1'e cevirir (egriyle).
  double _aralik(double a, double b, [Curve egri = Curves.easeOutCubic]) {
    final v = ((_giris.value - a) / (b - a)).clamp(0.0, 1.0);
    return egri.transform(v);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.maybeLocaleOf(context)?.languageCode ?? 'tr';
    return Material(
      type: MaterialType.transparency,
      child: DeviGokyuzu(
        renkler: widget.tema.zemin,
        yogunluk: widget.tema.yildiz,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Arka planda saydam, silik suzulen kod bloklari.
            IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  key: const ValueKey('acilis_ucusan_bloklar'),
                  painter: _UcusanBloklar(_ucus, _giris),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: Listenable.merge([_giris, _dongu]),
              builder: (context, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _simge(),
                    const SizedBox(height: 26),
                    _yazi(),
                    const SizedBox(height: 14),
                    _altYazi(lang),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- simge

  Widget _simge() {
    final gel = _aralik(0.0, 0.42, Curves.elasticOut);
    final gorun = _aralik(0.0, 0.15);
    final t = _dongu.value;
    const boy = 128.0;
    return SizedBox(
      width: 230,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Disari dogru yayilan isik halkalari.
          for (var i = 0; i < 2; i++)
            () {
              final v = (t + i * 0.5) % 1.0;
              return Opacity(
                opacity: (1 - v) * 0.45 * gorun,
                child: Container(
                  width: boy + v * 90,
                  height: boy + v * 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40 + v * 30),
                    border: Border.all(color: widget.tema.isik, width: 2),
                  ),
                ),
              );
            }(),
          // Simgenin etrafinda donen kucuk isaretler.
          for (var i = 0; i < 3; i++)
            () {
              final aci = t * math.pi * 2 + i * math.pi * 2 / 3;
              return Opacity(
                opacity: _aralik(0.35, 0.6),
                child: Transform.translate(
                  offset: Offset(math.cos(aci) * 100, math.sin(aci) * 78),
                  child: i == 0
                      ? const Text(
                          '</>',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7FF6FF),
                          ),
                        )
                      : Icon(
                          i == 1 ? Icons.star_rounded : Icons.settings_rounded,
                          size: 22,
                          color: i == 1
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFFFF9EC7),
                        ),
                ),
              );
            }(),
          Opacity(
            opacity: gorun,
            child: Transform.scale(
              scale: 0.3 + 0.7 * gel,
              child: Transform.rotate(
                angle: (1 - _aralik(0.0, 0.42)) * -0.5,
                child: Container(
                  width: boy,
                  height: boy,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                        blurRadius: 34,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white24,
                        child: const Icon(Icons.smart_toy_rounded,
                            color: Colors.white, size: 64),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- yazi

  Widget _yazi() {
    const kelime = 'DevEducation';
    // Harfler 0.30 ile 0.75 arasinda sirayla dusuyor.
    final harfler = <Widget>[];
    for (var i = 0; i < kelime.length; i++) {
      final bas = 0.30 + i * 0.03;
      final v = _aralik(bas, bas + 0.22, Curves.elasticOut);
      final o = _aralik(bas, bas + 0.08);
      harfler.add(Opacity(
        opacity: o,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * -34),
          child: Text(
            kelime[i],
            style: TextStyle(
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w800,
              fontSize: 48,
              height: 1.0,
              color: i < 3 ? widget.tema.dev : widget.tema.yazi,
              shadows: widget.tema.yaziGolgesi
                  ? const [
                      Shadow(
                        color: Color(0x55000000),
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ));
    }
    // Harfler yerine oturunca bir parilti soldan saga geciyor (her turda).
    final p = _giris.value < 1 ? -1.0 : (_dongu.value * 2.2 - 0.6);
    return ShaderMask(
      key: const ValueKey('acilis_yazi'),
      blendMode: BlendMode.srcATop,
      shaderCallback: (r) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0),
        ],
        stops: [
          (p - 0.12).clamp(0.0, 1.0),
          p.clamp(0.0, 1.0),
          (p + 0.12).clamp(0.0, 1.0),
        ],
      ).createShader(r),
      child: Semantics(
        label: kelime,
        child: ExcludeSemantics(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(mainAxisSize: MainAxisSize.min, children: harfler),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------- alt yazi

  /// "Yazilim • Robotik • Yapay Zeka" — ilk acilis ekranindaki yazi geri
  /// geldi (Ekim 2026). Harfler yerine oturduktan sonra yumusakca beliriyor;
  /// altinda ince bir isik cizgisi bekleme isareti olarak nabiz atiyor.
  Widget _altYazi(String lang) {
    final o = _aralik(0.72, 0.95);
    final nabiz =
        0.35 + 0.65 * (0.5 + 0.5 * math.sin(_dongu.value * math.pi * 2));
    return Opacity(
      opacity: o,
      child: Transform.translate(
        offset: Offset(0, (1 - o) * 10),
        child: Column(
          children: [
            Text(
              AppLang.pick(lang,
                  tr: 'Yazılım • Robotik • Yapay Zekâ',
                  en: 'Coding • Robotics • AI',
                  de: 'Programmieren • Robotik • KI',
                  es: 'Programación • Robótica • IA'),
              key: const ValueKey('acilis_alt_yazi'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: 46,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25 + 0.5 * nabiz),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4 * nabiz),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Arka planda saydam, silik suzulen Scratch/mBlock bloklari.
///
/// One cikan bir yazi degil, dokudur: opaklik %8-14, yavasca yukari
/// suzuluyor, hafif donuyor. Giris basinda yavasca beliriyor.
class _UcusanBloklar extends CustomPainter {
  _UcusanBloklar(this.t, this.giris)
      : super(repaint: Listenable.merge([t, giris]));

  final Animation<double> t;
  final Animation<double> giris;

  static const _renkler = [
    Color(0xFFFF8C1A),
    Color(0xFF4C97FF),
    Color(0xFF9966FF),
    Color(0xFF0FBD8C),
    Color(0xFFFFAB19),
    Color(0xFFFF6680),
  ];

  static final List<List<double>> _bloklar = () {
    final r = math.Random(21);
    // x, y0, hiz, genislik, aci, renk, sapka, opaklik
    return List.generate(
        11,
        (i) => [
              r.nextDouble(),
              r.nextDouble(),
              0.6 + r.nextDouble() * 0.9,
              70 + r.nextDouble() * 70,
              (r.nextDouble() - 0.5) * 0.5,
              (i % _renkler.length).toDouble(),
              r.nextDouble() < 0.3 ? 1.0 : 0.0,
              0.08 + r.nextDouble() * 0.06,
            ]);
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final belir = giris.value.clamp(0.0, 1.0);
    if (belir == 0) return;
    for (final b in _bloklar) {
      final y = ((b[1] - t.value * b[2]) % 1.0) * (size.height + 160) - 80;
      final x = b[0] * size.width;
      final w = b[3];
      final h = w * 0.32;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(b[4] + math.sin(t.value * math.pi * 2 + b[0] * 6) * 0.06);
      final yol = _blokYolu(w, h, b[6] == 1);
      final renk = _renkler[b[5].toInt()];
      canvas.drawPath(
          yol, Paint()..color = renk.withValues(alpha: b[7] * belir));
      canvas.drawPath(
          yol,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = Colors.white.withValues(alpha: 0.06 * belir));
      canvas.restore();
    }
  }

  static Path _blokYolu(double w, double h, bool sapka) {
    const r = 5.0, n1 = 12.0, n2 = 15.0, n3 = 25.0, n4 = 28.0, d = 4.0;
    final yol = Path();
    if (sapka) {
      yol
        ..moveTo(0, 6)
        ..cubicTo(10, -6, w * 0.35, -6, w * 0.45, 4)
        ..lineTo(w - r, 4)
        ..quadraticBezierTo(w, 4, w, 4 + r);
    } else {
      yol
        ..moveTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(n1, 0)
        ..lineTo(n2, d)
        ..lineTo(n3, d)
        ..lineTo(n4, 0)
        ..lineTo(w - r, 0)
        ..quadraticBezierTo(w, 0, w, r);
    }
    yol
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(n4, h)
      ..lineTo(n3, h + d)
      ..lineTo(n2, h + d)
      ..lineTo(n1, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..close();
    return yol;
  }

  @override
  bool shouldRepaint(_UcusanBloklar o) => false;
}
