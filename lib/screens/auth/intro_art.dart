import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../utils/lang.dart';
import '../../ui/count_up.dart';
import '../../ui/motion.dart';

/// Tanitim karuselinin ust panelindeki gorseller.
///
/// Bunlar hazir resim degil, cizilmis widget'lar. Sebebi pratik: hazir
/// gorsel her ekran boyunda kirpiliyor, karanlik/aydinlik temaya
/// uymuyor ve uygulama boyutunu buyutuyor. Cizilmis olanlar her boyuta
/// uyum sagliyor ve renkleri sayfanin rengini takip ediyor.
///
/// Ucu de ayni kompozisyonu paylasiyor: arkada buyuk ve soluk bir
/// eleman, onde net bir kart, kenarlarda serbest duran kucuk parcalar.
class IntroArt {
  IntroArt._();

  /// 1. sayfa — ders karti ve etrafinda dil rozetleri.
  static Widget lesson(Color accent) => _LessonArt(accent: accent);

  /// 2. sayfa — rozet/madalya.
  static Widget badge(Color accent) => _BadgeArt(accent: accent);

  /// 3. sayfa — siralama tablosu, puanlari sayarak.
  static Widget leaderboard(Color accent) => _LeaderboardArt(accent: accent);

  /// Sertifika sayfasi.
  static Widget certificate(Color accent) => _CertificateArt(accent: accent);

  /// Soru sayfalarinin kucuk gorseli.
  ///
  /// Soru sayfalarinda panel alcaliyor — seceneklerin yeri lazim — ama
  /// bos kalmiyor. Tek bir yuvarlak simge, sayfanin hangi bolume ait
  /// oldugunu soyluyor ve akisin gorsel dilini bozmuyor.
  static Widget small(Color accent, IconData icon) =>
      _SmallArt(accent: accent, icon: icon);
}

class _SmallArt extends StatelessWidget {
  const _SmallArt({required this.accent, required this.icon});

  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _Float(
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 34, color: accent),
        ),
      ),
    );
  }
}

/// Sertifika: adin yazdigi bir belge.
class _CertificateArt extends StatelessWidget {
  const _CertificateArt({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => Center(
        child: _Float(
          child: Container(
            width: (c.maxWidth * 0.62).clamp(200.0, 280.0),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: accent.withValues(alpha: 0.35), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded, size: 40, color: accent),
                const SizedBox(height: 12),
                Container(
                    height: 8,
                    width: 130,
                    decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(
                    height: 6,
                    width: 90,
                    decoration: BoxDecoration(
                        color: const Color(0xFFDDE1E6),
                        borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: 5,
                        width: 54,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE7EBEF),
                            borderRadius: BorderRadius.circular(3))),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.verified_rounded, size: 15, color: accent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 1 — Blok kodlama
// ---------------------------------------------------------------------

/// Ust uste gecmis Scratch tarzi bloklar ve kucuk bir robot.
///
/// Ilk surumde burada bir "ders karti" vardi: beyaz bir kart ve icinde
/// gri cizgiler. Dogruydu ama herhangi bir uygulamanin herhangi bir
/// kartiydi; kodlamaya dair hicbir sey soylemiyordu.
///
/// Cocuklarin kodlamayi tanidigi gorsel dil bu: tirnakli, birbirine
/// gecen, renkli bloklar. Bir cocuk bu ekrani okumadan da ne oldugunu
/// anliyor — Scratch'i gormus her cocuk aninda taniyor.
class _LessonArt extends StatelessWidget {
  const _LessonArt({required this.accent});

  final Color accent;

  static const _blocks = [
    (Color(0xFFF5A623), Icons.flag_rounded, 0.80),
    (Color(0xFF4A90D9), Icons.arrow_forward_rounded, 0.92),
    (Color(0xFF7ED321), Icons.rotate_right_rounded, 0.72),
    (Color(0xFF9B59D0), Icons.repeat_rounded, 0.86),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final blockW = (w * 0.46).clamp(130.0, 190.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: const Alignment(-0.25, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < _blocks.length; i++)
                    _Float(
                      seed: i * 3,
                      child: CustomPaint(
                        size: Size(blockW * _blocks[i].$3, 44),
                        painter: _BlockPainter(color: _blocks[i].$1),
                        child: SizedBox(
                          width: blockW * _blocks[i].$3,
                          height: 44,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 14, top: 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(_blocks[i].$2,
                                  size: 17, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bloklarin sagindaki kucuk robot: bloklarin ne ise
            // yaradigini soyleyen sey. Kod bir seyi HAREKET ETTIRIYOR.
            Align(
              alignment: const Alignment(0.86, 0.22),
              child: _Float(seed: 7, child: _robot(accent)),
            ),
          ],
        );
      },
    );
  }

  /// Kucuk robot.
  ///
  /// Yuksekligi SABIT VERILMIYORDU: parcalarin toplami (12+10+2+54+4+14)
  /// 96 piksel ama kutu 92 verilmisti, yani dort piksel tasiyordu.
  /// Sabit bir yukseklik yerine icerigi kadar buyuyor; parcalarin boyu
  /// degisince tekrar kirilmasin.
  Widget _robot(Color color) => SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Anten
            Container(width: 3, height: 12, color: color.withValues(alpha: .6)),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 2),
            // Kafa
            Container(
              width: 66,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _eye(color),
                  const SizedBox(width: 12),
                  _eye(color),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Govde
            Container(
              width: 44,
              height: 14,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      );

  Widget _eye(Color color) => Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// Tirnakli blok sekli.
///
/// Ustunde bir cukur, altinda ayni olcude bir cikinti var; bloklar
/// birbirine gecebilecek gibi duruyor. Bu tek detay, dizinin "sirali
/// komutlar" oldugunu anlatiyor — yan yana duran renkli dikdortgenler
/// bunu anlatmiyor.
class _BlockPainter extends CustomPainter {
  _BlockPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 8.0;
    const notchW = 22.0;
    const notchH = 6.0;
    final notchX = 18.0;

    final path = Path()
      ..moveTo(r, 0)
      // ust kenar, ortasinda cukur
      ..lineTo(notchX, 0)
      ..lineTo(notchX + 5, notchH)
      ..lineTo(notchX + notchW - 5, notchH)
      ..lineTo(notchX + notchW, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, size.height - r)
      ..arcToPoint(Offset(size.width - r, size.height),
          radius: const Radius.circular(r))
      // alt kenar, ortasinda cikinti
      ..lineTo(notchX + notchW, size.height)
      ..lineTo(notchX + notchW - 5, size.height + notchH)
      ..lineTo(notchX + 5, size.height + notchH)
      ..lineTo(notchX, size.height)
      ..lineTo(r, size.height)
      ..arcToPoint(Offset(0, size.height - r), radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..close();

    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BlockPainter old) => old.color != color;
}

Widget _card({
  required double width,
  required Color color,
  required Widget child,
  // Yukseklik artik istege bagli: siralama tablosunda dort satir sabit
  // 176 pikselin icine sigmiyordu ve alttan tasiyordu. Verilmezse kart
  // icerigi kadar uzuyor.
  double? height,
}) =>
    Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );

/// Parcalari cok yavas asagi yukari suzduren sarmalayici.
///
/// Genlik 4 piksel, tur 3-4 saniye: goz takip etmiyor ama sayfa
/// "duruyor" da hissettirmiyor.
class _Float extends StatefulWidget {
  const _Float({required this.child, this.seed = 0});

  final Widget child;
  final int seed;

  @override
  State<_Float> createState() => _FloatState();
}

class _FloatState extends State<_Float> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 3200 + widget.seed * 180),
  );

  @override
  void initState() {
    super.initState();
    if (!Motion.reducedRaw) _c.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // KLAVYE AÇIKKEN DURUYOR.
    //
    // Karşılama ekranının üst görselindeki simge sürekli süzülüyor.
    // Çocuk takma adını yazarken her tuşta metin alanı yeniden
    // çiziliyor; aynı anda dönen animasyonlar frame bütçesini yiyor ve
    // yazmak takılıyor. Kullanıcı bunu "9'u sildim sorun yok, 1'i de
    // silince kasmaya başlıyor" diye bildirdi.
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (Motion.reduced(context) || typing) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sürekli çizilen şey kendi katmanında: yoksa üstündeki her şey de
    // her karede yeniden rasterleniyor.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, math.sin(_c.value * math.pi * 2) * 4),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 2 — Rozet
// ---------------------------------------------------------------------

class _BadgeArt extends StatelessWidget {
  const _BadgeArt({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // "Başardın!" — arkadaki buyuk yazi.
        //
        // Onceden %55 saydam beyazdi ve acik zeminde neredeyse
        // okunmuyordu; ustelik panelin en tepesine yapisiktik. Artik
        // biraz asagida, rozetin hemen uzerinde duruyor ve rengini
        // sayfanin vurgu renginden aliyor — koyulastirilmis hali,
        // boylece acik turuncu zeminde de net okunuyor.
        Align(
          alignment: const Alignment(0, -0.58),
          child: Text(
            // Gorseldeki metinler de ceviriliyor. Ingilizce secili bir
            // ekranda buyuk puntoyla "Başardın!" yazmasi, dil secimini
            // yarim biraktigimizi gosteriyordu.
            AppLang.pick(
              Localizations.localeOf(context).languageCode,
              tr: 'Başardın!',
              en: 'You did it!',
              de: 'Geschafft!',
              es: '¡Lo lograste!',
            ),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              color: Color.lerp(accent, const Color(0xFF1A1300), 0.28)!
                  .withValues(alpha: 0.92),
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.55),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(-0.68, 0.34),
          child: _Float(seed: 2, child: _coin(accent, 62, Icons.bolt_rounded)),
        ),
        Align(
          alignment: const Alignment(0.72, 0.30),
          child:
              _Float(seed: 5, child: _coin(accent, 58, Icons.schedule_rounded)),
        ),
        _Float(
          seed: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _coin(accent, 108, Icons.star_rounded, elevated: true),
              // Kurdele.
              Transform.translate(
                offset: const Offset(0, -6),
                child: CustomPaint(
                  size: const Size(52, 46),
                  painter: _RibbonPainter(color: accent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _coin(Color color, double size, IconData icon,
          {bool elevated = false}) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(color, Colors.white, 0.35)!,
              color,
            ],
          ),
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: size * 0.045,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.38),
          ),
        ),
      );
}

class _RibbonPainter extends CustomPainter {
  _RibbonPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.85);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.72)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RibbonPainter old) => old.color != color;
}

// ---------------------------------------------------------------------
// 3 — Siralama tablosu
// ---------------------------------------------------------------------

class _LeaderboardArt extends StatelessWidget {
  const _LeaderboardArt({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: const Alignment(0, -0.86),
            child: Icon(Icons.emoji_events_rounded,
                size: 58, color: Colors.white.withValues(alpha: 0.85)),
          ),
          Align(
            alignment: const Alignment(0, 0.28),
            child: _card(
              width: c.maxWidth * 0.70,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLang.pick(
                        Localizations.localeOf(context).languageCode,
                        tr: 'Sıralama',
                        en: 'Leaderboard',
                        de: 'Rangliste',
                        es: 'Clasificación',
                      ),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.mediumGray.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Ornek isimler de dile gore degisiyor: Ispanyolca
                    // bir ekranda Turkce isimler, uygulamanin o dil icin
                    // yapilmadigini soyluyor.
                    ..._names(Localizations.localeOf(context).languageCode)
                        .indexed
                        .map((e) => _row(
                              e.$1 + 1,
                              e.$2,
                              [4820, 4310, 3975, 3540][e.$1],
                              accent,
                              highlight: e.$1 == 0,
                              faded: e.$1 == 3,
                            )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Siralamadaki ornek isimler.
  static List<String> _names(String lang) => AppLang.pick(
        lang,
        tr: 'Zeynep,Emir,Deniz,Ada',
        en: 'Emma,Liam,Noah,Ava',
        de: 'Emma,Ben,Mia,Leon',
        es: 'Lucía,Mateo,Sofía,Hugo',
      ).split(',');

  Widget _row(int rank, String name, int score, Color accent,
      {bool highlight = false, bool faded = false}) {
    final color =
        faded ? AppTheme.mediumGray.withValues(alpha: 0.5) : AppTheme.darkGray;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? accent.withValues(alpha: 0.13) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: faded ? color : AppTheme.mediumGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ),
          // Puanlar sayarak yukseliyor: tablo canli bir sey gibi
          // duruyor, ekran goruntusu gibi degil.
          CountUpText(
            value: score,
            fontSize: 11.5,
            color: faded ? color : accent,
            duration: const Duration(milliseconds: 1400),
          ),
        ],
      ),
    );
  }
}
