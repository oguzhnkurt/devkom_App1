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
///    halkalari dalgalanir, "DevEducation" harf harf yerine duser ("Dev"
///    Devi'nin turuncusunda), sonra uc renkli kod blogu ("Kodla · Oyna ·
///    Kesfet") Scratch bloklari gibi birbirine kenetlenir.
///  * Oturum hala yukleniyorsa ayni sahne SON HALIYLE kalir; yukleniyor
///    isareti donen bir halka degil, bloklarin uzerinden gecen isik.
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
    required this.blok,
    required this.blokYazi,
    this.isik = Colors.white,
    this.yildiz = 1.0,
    this.yaziGolgesi = true,
  });

  final String ad;
  final List<Color> zemin;
  final Color dev;
  final Color yazi;
  final Color blok;
  final Color blokYazi;

  /// Halkalarin rengi.
  final Color isik;

  /// Takimyildiz parlakligi (0 = yok).
  final double yildiz;
  final bool yaziGolgesi;

  /// Secilen tema (Ekim 2026): gece uzayi. "DevEducation" TEK RENK beyaz;
  /// bloklar mBlock'un camgobegi ailesinde.
  static const uzay = AcilisTema(
    ad: 'Gece Uzayı',
    zemin: [Color(0xFF0A0D1F), Color(0xFF111833), Color(0xFF1A2550)],
    dev: Colors.white,
    yazi: Colors.white,
    blok: Color(0xFF1BA3B8),
    blokYazi: Colors.white,
    isik: Color(0xFF5CE1E6),
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
    if (!azHareket) _dongu.repeat();
  }

  @override
  void dispose() {
    _giris.dispose();
    _dongu.dispose();
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
        child: AnimatedBuilder(
          animation: Listenable.merge([_giris, _dongu]),
          builder: (context, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _simge(),
                const SizedBox(height: 26),
                _yazi(),
                // Bloklar yazidan biraz uzakta: yazi nefes alsin.
                const SizedBox(height: 64),
                _bloklar(lang),
              ],
            ),
          ),
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

  // ------------------------------------------------------------ bloklar

  /// "Kodla · Oyna · Kesfet": mBlock tarzi, ust uste kenetlenen bloklar.
  ///
  /// Her blok mBlock'taki gibi: solda koyu bir simge hucresi (ayrac
  /// cizgisiyle), ortada komut, sagda beyaz oval bir deger kutusu. Tek
  /// renk; en ustteki sapkali "olay" blogu. Bloklar sirayla yukaridan dusup
  /// bir oncekinin altina oturuyor; beklerken isik yukaridan asagi akiyor.
  Widget _bloklar(String lang) {
    String t(String tr, String en, String de, String es) =>
        AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
    final satirlar = [
      (Icons.code_rounded, t('Kodla', 'Code', 'Coden', 'Programa'), 'Scratch'),
      (
        Icons.sports_esports_rounded,
        t('Oyna', 'Play', 'Spielen', 'Juega'),
        t('Robot', 'Robot', 'Roboter', 'Robot')
      ),
      (
        Icons.explore_rounded,
        t('Keşfet', 'Explore', 'Entdecken', 'Explora'),
        t('YZ', 'AI', 'KI', 'IA')
      ),
    ];
    final tema = widget.tema;
    final bekleme = _giris.value >= 1;
    final isik = _dongu.value;
    final koyu = Color.lerp(tema.blok, Colors.black, 0.28)!;
    return Column(
      key: const ValueKey('acilis_bloklar'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 3; i++)
          () {
            final bas = 0.60 + i * 0.09;
            final v = _aralik(bas, bas + 0.2, Curves.bounceOut);
            final parla =
                bekleme ? (1 - ((isik * 3 - i).abs()).clamp(0.0, 1.0)) : 0.0;
            final renk = Color.lerp(tema.blok, Colors.white, parla * 0.25)!;
            final sapka = i == 0;
            final (simge, komut, deger) = satirlar[i];
            return Opacity(
              opacity: _aralik(bas, bas + 0.06),
              child: Transform.translate(
                offset: Offset(0, (1 - v) * -46),
                child: CustomPaint(
                  painter: _ScratchBlokRessami(
                    renk: renk,
                    sapka: sapka,
                    parla: parla,
                  ),
                  child: SizedBox(
                    width: 214,
                    height: sapka ? 58 : 46,
                    child: Padding(
                      padding: EdgeInsets.only(top: sapka ? 12 : 0),
                      child: Row(
                        children: [
                          // mBlock simge hucresi + ayrac.
                          Container(
                            width: 44,
                            height: double.infinity,
                            margin: const EdgeInsets.only(left: 1),
                            decoration: BoxDecoration(
                              color: koyu.withValues(alpha: 0.35),
                              border: Border(
                                right: BorderSide(
                                    color: koyu.withValues(alpha: 0.7),
                                    width: 1.2),
                              ),
                            ),
                            child: Icon(simge, color: tema.blokYazi, size: 21),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                komut,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: tema.blokYazi,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Beyaz oval deger kutusu (mBlock girdisi).
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: koyu, width: 1),
                            ),
                            child: Text(
                              deger,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                color: Color(0xFF1A2550),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }(),
      ],
    );
  }
}

/// Scratch komut blogu: ustte centik, altta cikinti; ilki sapkali.
class _ScratchBlokRessami extends CustomPainter {
  _ScratchBlokRessami({
    required this.renk,
    required this.sapka,
    required this.parla,
  });

  final Color renk;
  final bool sapka;
  final double parla;

  @override
  void paint(Canvas canvas, Size s) {
    const r = 6.0, n1 = 16.0, n2 = 20.0, n3 = 32.0, n4 = 36.0, d = 5.0;
    final ust = sapka ? 14.0 : 0.0;
    final w = s.width, h = s.height;
    final yol = Path();
    if (sapka) {
      yol
        ..moveTo(0, ust + 4)
        ..cubicTo(14, -6, 70, -6, 86, ust)
        ..lineTo(w - r, ust)
        ..quadraticBezierTo(w, ust, w, ust + r);
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

    final koyu = Color.lerp(renk, Colors.black, 0.22)!;
    canvas.drawShadow(yol, Colors.black, 3, false);
    if (parla > 0.05) {
      canvas.drawPath(
        yol,
        Paint()
          ..color = renk.withValues(alpha: 0.6 * parla)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    canvas.drawPath(yol, Paint()..color = renk);
    canvas.drawPath(
      yol,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = koyu,
    );
  }

  @override
  bool shouldRepaint(_ScratchBlokRessami o) =>
      o.renk != renk || o.parla != parla || o.sapka != sapka;
}
