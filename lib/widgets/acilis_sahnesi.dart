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
/// Zemin, iOS acilis ekraninin rengi (#5A34E8) etrafinda kuruldu: yerel
/// acilis ekranindan Flutter'a geciste renk sicramasi olmasin.
///
/// Yazi tipi: "DevEducation" Baloo 2 ExtraBold (yuvarlak, cocuk dostu,
/// OFL); geri kalan her yer uygulamanin Nunito'su.
///
/// Hareketi azalt aciksa her sey dogrudan son halinde cizilir.
class AcilisSahnesi extends StatefulWidget {
  const AcilisSahnesi({super.key, this.giris = true});

  /// Giris animasyonu oynasin mi? Ikinci gosterimde (oturum yuklenirken)
  /// false: sahne son haliyle durur, yalnizca bekleme isigi akar.
  final bool giris;

  static const Color zemin = Color(0xFF5A34E8);

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
        renkler: const [
          Color(0xFF6E48F5),
          AcilisSahnesi.zemin,
          Color(0xFF341A9E)
        ],
        yogunluk: 1.1,
        child: AnimatedBuilder(
          animation: Listenable.merge([_giris, _dongu]),
          builder: (context, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _simge(),
                const SizedBox(height: 26),
                _yazi(),
                const SizedBox(height: 26),
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
                    border: Border.all(color: Colors.white, width: 2),
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

  static const _dev = Color(0xFFFFD54F);

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
              color: i < 3 ? _dev : Colors.white,
              shadows: const [
                Shadow(
                  color: Color(0x55000000),
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
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
          child: Row(mainAxisSize: MainAxisSize.min, children: harfler),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ bloklar

  Widget _bloklar(String lang) {
    final etiketler = [
      AppLang.pick(lang, tr: 'Kodla', en: 'Code', de: 'Coden', es: 'Programa'),
      AppLang.pick(lang, tr: 'Oyna', en: 'Play', de: 'Spielen', es: 'Juega'),
      AppLang.pick(lang,
          tr: 'Keşfet', en: 'Explore', de: 'Entdecken', es: 'Explora'),
    ];
    const renkler = [Color(0xFF4C97FF), Color(0xFFFF8C1A), Color(0xFF0FBD8C)];
    const simgeler = [
      Icons.code_rounded,
      Icons.sports_esports_rounded,
      Icons.explore_rounded
    ];

    // Bloklar 0.62-0.95 arasinda soldan ve sagdan gelip kenetleniyor.
    final bekleme = _giris.value >= 1;
    final isik = _dongu.value; // 0..1: hangi blok parliyor
    return Row(
      key: const ValueKey('acilis_bloklar'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          () {
            final bas = 0.62 + i * 0.08;
            final v = _aralik(bas, bas + 0.22, Curves.easeOutBack);
            final yon = i == 1 ? 0.0 : (i == 0 ? -1.0 : 1.0);
            final parla =
                bekleme ? (1 - ((isik * 3 - i).abs()).clamp(0.0, 1.0)) : 0.0;
            return Opacity(
              opacity: _aralik(bas, bas + 0.1),
              child: Transform.translate(
                offset: Offset(yon * (1 - v) * 60, (1 - v) * (i == 1 ? 30 : 0)),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
                  decoration: BoxDecoration(
                    color: Color.lerp(renkler[i], Colors.white, parla * 0.35),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(i == 0 ? 14 : 6),
                      right: Radius.circular(i == 2 ? 14 : 6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.lerp(renkler[i], Colors.black, 0.35)!,
                        offset: const Offset(0, 4),
                      ),
                      if (parla > 0.05)
                        BoxShadow(
                          color: renkler[i].withValues(alpha: 0.7 * parla),
                          blurRadius: 16,
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(simgeler[i], color: Colors.white, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        etiketler[i],
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }(),
      ],
    );
  }
}
