import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Pro (odeme) ekraninin animasyonlu parcalari.
///
/// Tasarim (6 Kasim 2026, kullanicinin gosterdigi ornek): mavi gokyuzu,
/// sari kurdele, degisen baslik, ucarak gelip bulutlara konan maskot; altta
/// UCRETSIZ / PRO karsilastirmasi (PRO tikleri tek tek beliriyor) ve sari,
/// parlayan bir dugme. Mesaj tek: Pro uygulamanin TAMAMINI aciyor.
///
/// Hareket azaltma acikken her sey son haliyle, animasyonsuz ciziliyor.
/// Dile duyarli buyuk harf: Turkcede i -> İ, ı -> I.
String proBuyukHarf(String s, String dil) {
  if (dil == 'tr') {
    return s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
  }
  return s.toUpperCase();
}

class ProRenk {
  ProRenk._();
  static const gokUst = Color(0xFF3E98EC);
  static const gokAlt = Color(0xFF9AD3FA);
  static const lacivert = Color(0xFF1D3557);
  static const lacivertYumusak = Color(0xFF4A5D78);
  static const sari = Color(0xFFFFCB3D);
  static const sariKoyu = Color(0xFFE9A800);
  static const proMavi = Color(0xFF2F80ED);
  static const proAcik = Color(0xFFEAF4FF);
}

/// Ust bolum: gokyuzu + kurdele + baslik + maskot + bulut kenari.
class ProGokyuzu extends StatefulWidget {
  const ProGokyuzu({
    super.key,
    required this.kurdele,
    required this.ilkBaslik,
    required this.baslik,
    required this.altBaslik,
    required this.maskot,
    required this.hareketsiz,
    this.ustBosluk = 0,
  });

  final String kurdele;

  /// Once gorunen, sonra [baslik]'a donusen cumle.
  final String ilkBaslik;
  final String baslik;
  final String altBaslik;
  final Widget maskot;
  final bool hareketsiz;

  /// Durum cubugu + ust dugmeler icin birakilan yer.
  final double ustBosluk;

  @override
  State<ProGokyuzu> createState() => _ProGokyuzuState();
}

class _ProGokyuzuState extends State<ProGokyuzu> with TickerProviderStateMixin {
  late final AnimationController _giris = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));
  late final AnimationController _suzulme = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600));

  /// Ortam: suzulen bulutlar, donen isinlar, parlayan yildizlar.
  late final AnimationController _ortam =
      AnimationController(vsync: this, duration: const Duration(seconds: 24));
  bool _ikinciBaslik = false;

  @override
  void initState() {
    super.initState();
    if (widget.hareketsiz) {
      _giris.value = 1;
      _ikinciBaslik = true;
      return;
    }
    _ortam.repeat();
    _giris.forward().whenComplete(() {
      if (mounted) _suzulme.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _ikinciBaslik = true);
    });
  }

  @override
  void dispose() {
    _giris.dispose();
    _suzulme.dispose();
    _ortam.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ProRenk.gokUst, ProRenk.gokAlt],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.topCenter,
        children: [
          // Arka plan: suzulen bulutlar ve parlayan yildizlar.
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _GokSahnesi(_ortam)),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, widget.ustBosluk, 20, 0),
            child: Column(
              children: [
                _Kurdele(metin: widget.kurdele),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 550),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position:
                          Tween(begin: const Offset(0, 0.12), end: Offset.zero)
                              .animate(a),
                      child: c,
                    ),
                  ),
                  child: Text(
                    _ikinciBaslik ? widget.baslik : widget.ilkBaslik,
                    key: ValueKey(_ikinciBaslik),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: t.headlineSmall?.copyWith(
                      color: ProRenk.lacivert,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.altBaslik,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: t.bodyMedium?.copyWith(
                      color: ProRenk.lacivertYumusak,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 138,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Devi'nin arkasinda yavasca donen gunes isinlari ve
                      // yumusak bir hale.
                      Positioned(
                        top: -6,
                        bottom: 0,
                        left: 20,
                        right: 20,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _IsinHale(_ortam, _giris),
                          ),
                        ),
                      ),
                      // Devi'nin uzerinde durdugu kabarik bulut.
                      const Positioned(
                        bottom: 0,
                        width: 210,
                        height: 46,
                        child: CustomPaint(painter: _BulutMinder()),
                      ),
                      Positioned(
                        bottom: 18,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_giris, _suzulme]),
                          child: widget.maskot,
                          builder: (context, child) {
                            // Ucarak gelis: buyuk ve egik baslayip bulutun
                            // ustune oturuyor, sonra hafifce suzuluyor.
                            final g =
                                Curves.easeOutBack.transform(_giris.value);
                            final olcek = 1.7 - 0.7 * g;
                            final dx = 70 * (1 - g);
                            final dy = -60 * (1 - g) +
                                math.sin(_suzulme.value * math.pi) * -6;
                            final aci = -0.35 * (1 - g);
                            return Opacity(
                              opacity: _giris.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(dx, dy),
                                child: Transform.rotate(
                                  angle: aci,
                                  child: Transform.scale(
                                      scale: olcek, child: child),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Bulut kenari: gokyuzunu beyaz govdeye baglar.
          const Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            height: 40,
            child: CustomPaint(painter: _BulutKenari()),
          ),
        ],
      ),
    );
  }
}

class _Kurdele extends StatelessWidget {
  const _Kurdele({required this.metin});
  final String metin;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _KurdeleUclari(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: ProRenk.sari,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
                color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Text(
          metin,
          maxLines: 1,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: ProRenk.lacivert,
          ),
        ),
      ),
    );
  }
}

class _KurdeleUclari extends CustomPainter {
  const _KurdeleUclari();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = ProRenk.sariKoyu;
    final h = size.height;
    final ust = h * 0.22;
    // Sol uc
    canvas.drawPath(
        Path()
          ..moveTo(18, ust)
          ..lineTo(0, ust)
          ..lineTo(8, h * 0.6)
          ..lineTo(0, h)
          ..lineTo(18, h)
          ..close(),
        p);
    // Sag uc
    final w = size.width;
    canvas.drawPath(
        Path()
          ..moveTo(w - 18, ust)
          ..lineTo(w, ust)
          ..lineTo(w - 8, h * 0.6)
          ..lineTo(w, h)
          ..lineTo(w - 18, h)
          ..close(),
        p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BulutKenari extends CustomPainter {
  const _BulutKenari();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final w = size.width;
    final h = size.height;
    final path = Path()..moveTo(0, h);
    // Yumuk bulut tepeleri.
    const tepeler = [0.0, 0.12, 0.26, 0.4, 0.54, 0.68, 0.82, 1.0];
    const yukseklik = [0.5, 0.15, 0.42, 0.1, 0.38, 0.08, 0.4, 0.45];
    path.lineTo(0, h * yukseklik[0]);
    for (var i = 1; i < tepeler.length; i++) {
      final x0 = w * tepeler[i - 1];
      final x1 = w * tepeler[i];
      path.quadraticBezierTo(
          (x0 + x1) / 2, h * yukseklik[i] - h * 0.55, x1, h * yukseklik[i]);
    }
    path
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gokyuzu sahnesi: yavasca kayan yumuk bulutlar ve goz kirpan yildizlar.
class _GokSahnesi extends CustomPainter {
  _GokSahnesi(this.t) : super(repaint: t);
  final Animation<double> t;

  static const _bulutlar = [
    // (y orani, olcek, hiz, baslangic, saydamlik)
    (0.20, 0.9, 1.0, 0.10, 0.55),
    (0.46, 0.65, 1.6, 0.55, 0.45),
    (0.66, 1.1, 0.7, 0.80, 0.5),
  ];

  static const _yildizlar = [
    (0.12, 0.30, 5.0, 0.0),
    (0.86, 0.24, 4.0, 0.3),
    (0.08, 0.62, 3.5, 0.6),
    (0.92, 0.56, 5.5, 0.15),
    (0.24, 0.80, 3.0, 0.45),
    (0.78, 0.82, 4.0, 0.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value;
    final w = size.width;
    final h = size.height;
    for (final b in _bulutlar) {
      final x = ((b.$4 + v * b.$3) % 1.0) * (w + 160) - 80;
      _bulut(canvas, Offset(x, h * b.$1), b.$2,
          Colors.white.withValues(alpha: b.$5));
    }
    for (final y in _yildizlar) {
      final parla =
          0.25 + 0.75 * (0.5 + 0.5 * math.sin((v * 12 + y.$4) * 2 * math.pi));
      _yildiz(canvas, Offset(w * y.$1, h * y.$2), y.$3,
          Colors.white.withValues(alpha: parla));
    }
  }

  void _bulut(Canvas c, Offset o, double k, Color renk) {
    final p = Paint()..color = renk;
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: o, width: 74 * k, height: 20 * k),
            Radius.circular(10 * k)),
        p);
    c.drawCircle(o.translate(-14 * k, -8 * k), 13 * k, p);
    c.drawCircle(o.translate(8 * k, -12 * k), 17 * k, p);
  }

  @override
  bool shouldRepaint(covariant _GokSahnesi old) => false;
}

void _yildiz(Canvas c, Offset o, double r, Color renk) {
  final p = Paint()..color = renk;
  final path = Path()
    ..moveTo(o.dx, o.dy - r)
    ..quadraticBezierTo(o.dx, o.dy, o.dx + r, o.dy)
    ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + r)
    ..quadraticBezierTo(o.dx, o.dy, o.dx - r, o.dy)
    ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - r)
    ..close();
  c.drawPath(path, p);
}

/// Devi'nin arkasindaki donen gunes isinlari + sicak hale.
class _IsinHale extends CustomPainter {
  _IsinHale(this.t, this.giris) : super(repaint: Listenable.merge([t, giris]));
  final Animation<double> t;
  final Animation<double> giris;

  @override
  void paint(Canvas canvas, Size size) {
    final g = giris.value.clamp(0.0, 1.0);
    if (g <= 0) return;
    final m = Offset(size.width / 2, size.height * 0.58);
    final r = size.height * 0.5;
    // Hale.
    canvas.drawCircle(
      m,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFF4C2).withValues(alpha: 0.75 * g),
          const Color(0xFFFFF4C2).withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: m, radius: r)),
    );
    // Isinlar.
    canvas.save();
    canvas.translate(m.dx, m.dy);
    canvas.rotate(t.value * 2 * math.pi);
    final p = Paint()..color = Colors.white.withValues(alpha: 0.16 * g);
    const n = 14;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      final yol = Path()
        ..moveTo(0, 0)
        ..lineTo(math.cos(a - 0.1) * r * 1.35, math.sin(a - 0.1) * r * 1.35)
        ..lineTo(math.cos(a + 0.1) * r * 1.35, math.sin(a + 0.1) * r * 1.35)
        ..close();
      canvas.drawPath(yol, p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IsinHale old) => false;
}

/// Devi'nin ayaklarinin altindaki kabarik bulut minderi.
class _BulutMinder extends CustomPainter {
  const _BulutMinder();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final golge = Paint()..color = const Color(0xFFD6ECFB);
    final beyaz = Paint()..color = Colors.white;
    void kabarcik(Paint p, double dy) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(w * 0.04, h * 0.42 + dy, w * 0.92, h * 0.5),
              Radius.circular(h * 0.25)),
          p);
      canvas.drawCircle(Offset(w * 0.24, h * 0.48 + dy), h * 0.3, p);
      canvas.drawCircle(Offset(w * 0.45, h * 0.36 + dy), h * 0.36, p);
      canvas.drawCircle(Offset(w * 0.66, h * 0.42 + dy), h * 0.32, p);
      canvas.drawCircle(Offset(w * 0.82, h * 0.55 + dy), h * 0.24, p);
    }

    kabarcik(golge, 3);
    kabarcik(beyaz, 0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bir karsilastirma satiri. [ucretsiz] null ise o sutunda tire.
class ProSatir {
  const ProSatir(this.metin, {this.ucretsiz, this.pro});
  final String metin;
  final String? ucretsiz;

  /// PRO sutununda tik yerine yazilacak kisa deger (ornegin "Sinirsiz").
  final String? pro;
}

/// UCRETSIZ / PRO karsilastirmasi. Satirlar sirayla kayarak geliyor,
/// PRO sutunundaki tikler tek tek "pop" ediyor.
class ProKarsilastirma extends StatefulWidget {
  const ProKarsilastirma({
    super.key,
    required this.satirlar,
    required this.ucretsizEtiket,
    required this.hareketsiz,
  });

  final List<ProSatir> satirlar;
  final String ucretsizEtiket;
  final bool hareketsiz;

  @override
  State<ProKarsilastirma> createState() => _ProKarsilastirmaState();
}

class _ProKarsilastirmaState extends State<ProKarsilastirma>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1900));

  static const double _sutun = 66;

  @override
  void initState() {
    super.initState();
    if (widget.hareketsiz) {
      _c.value = 1;
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _aralik(double bas, double son, Curve egri) {
    final v = ((_c.value - bas) / (son - bas)).clamp(0.0, 1.0);
    return egri.transform(v);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final n = widget.satirlar.length;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final sutunGor = _aralik(0.0, 0.25, Curves.easeOut);
        return Stack(
          children: [
            // PRO sutununun acik mavi zemini.
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: _sutun,
              child: Opacity(
                opacity: sutunGor,
                child: Container(
                  decoration: BoxDecoration(
                    color: ProRenk.proAcik,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: 34,
                  child: Row(
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: _sutun,
                        child: Center(
                          child: Text(
                            widget.ucretsizEtiket,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: t.labelSmall?.copyWith(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: _sutun,
                        child: Center(
                          child: Transform.scale(
                            scale: 0.6 +
                                0.4 * _aralik(0.05, 0.3, Curves.elasticOut),
                            child: const ProRozet(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (var i = 0; i < n; i++)
                  _satir(context, widget.satirlar[i], i, n),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _satir(BuildContext context, ProSatir s, int i, int n) {
    final t = Theme.of(context).textTheme;
    final bas = 0.12 + i * 0.1;
    final gir = _aralik(bas, bas + 0.25, Curves.easeOutCubic);
    final tikBas = 0.35 + i * 0.13;
    final tik = _aralik(tikBas, math.min(1.0, tikBas + 0.3), Curves.elasticOut);
    final deger = s.pro;
    return Opacity(
      opacity: gir,
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - gir)),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            border: i == n - 1
                ? null
                : Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  s.metin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(
                      color: ProRenk.lacivert, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: _sutun,
                child: Center(
                  child: s.ucretsiz == null
                      ? Text('—', style: TextStyle(color: Colors.grey.shade400))
                      : Text(s.ucretsiz!,
                          maxLines: 1,
                          style: t.labelMedium?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(
                width: _sutun,
                child: Center(
                  child: Transform.scale(
                    scale: tik,
                    child: deger == null
                        ? const Icon(Icons.check_circle_rounded,
                            color: ProRenk.proMavi, size: 22)
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(deger,
                                maxLines: 1,
                                style: t.labelMedium?.copyWith(
                                    color: ProRenk.proMavi,
                                    fontWeight: FontWeight.w900)),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Egik, gradyanli "PRO" rozeti.
class ProRozet extends StatelessWidget {
  const ProRozet({super.key, this.boyut = 13});
  final double boyut;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewX(-0.18),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)]),
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
                color: Color(0x332F80ED), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Text(
          'PRO',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: Colors.white,
            fontSize: boyut,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

/// Ana dugme: kabarik, parlayan "hap" seklinde sari-turuncu dugme.
/// Hafifce nefes aliyor (buyuyup kuculuyor), ustunden isik geciyor,
/// kenarlarinda yildizlar goz kirpiyor; basilinca 3B kenarina cokuyor.
class ProDugme extends StatefulWidget {
  const ProDugme({
    super.key,
    required this.etiket,
    required this.onPressed,
    required this.yukleniyor,
    required this.hareketsiz,
  });

  final String etiket;
  final VoidCallback? onPressed;
  final bool yukleniyor;
  final bool hareketsiz;

  @override
  State<ProDugme> createState() => _ProDugmeState();
}

class _ProDugmeState extends State<ProDugme> with TickerProviderStateMixin {
  late final AnimationController _isik = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800));
  late final AnimationController _nefes = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300));
  bool _basili = false;

  static const _ust = Color(0xFFFFE66D);
  static const _alt = Color(0xFFFFA62B);
  static const _kenar = Color(0xFFE07A00);

  @override
  void initState() {
    super.initState();
    if (!widget.hareketsiz) {
      _isik.repeat();
      _nefes.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _isik.dispose();
    _nefes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aktif = widget.onPressed != null && !widget.yukleniyor;
    const yukseklik = 60.0;
    final cokme = _basili ? 4.0 : 0.0;

    final govde = AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      height: yukseklik,
      width: double.infinity,
      transform: Matrix4.translationValues(0, cokme, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: aktif
              ? const [_ust, _alt]
              : [_ust.withValues(alpha: 0.5), _alt.withValues(alpha: 0.5)],
        ),
        borderRadius: BorderRadius.circular(yukseklik / 2),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(color: _kenar, offset: Offset(0, 5 - cokme)),
          BoxShadow(
            color: _alt.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: Offset(0, 9 - cokme),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(yukseklik / 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ust yarida parlak cizgi: "sekerli" gorunum.
            Positioned(
              top: 4,
              left: 18,
              right: 18,
              height: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.38),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (aktif && !widget.hareketsiz)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _isik,
                  builder: (context, _) {
                    final v = (_isik.value / 0.4).clamp(0.0, 1.0);
                    return Align(
                      alignment: Alignment(-1.6 + 3.2 * v, 0),
                      child: Transform.rotate(
                        angle: 0.35,
                        child: Container(
                          width: 30,
                          height: 120,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    );
                  },
                ),
              ),
            widget.yukleniyor
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.8, color: ProRenk.lacivert),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rocket_launch_rounded,
                            color: ProRenk.lacivert, size: 22),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.etiket,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: ProRenk.lacivert,
                              shadows: [
                                Shadow(
                                    color: Color(0x66FFFFFF),
                                    offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: ProRenk.lacivert,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: aktif,
      label: widget.etiket,
      child: GestureDetector(
        onTapDown: aktif ? (_) => setState(() => _basili = true) : null,
        onTapCancel: () => setState(() => _basili = false),
        onTapUp: aktif
            ? (_) {
                setState(() => _basili = false);
                widget.onPressed!();
              }
            : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_nefes, _isik]),
          child: govde,
          builder: (context, child) {
            final nefes = aktif && !_basili
                ? 1 + 0.03 * Curves.easeInOut.transform(_nefes.value)
                : 1.0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.scale(scale: nefes, child: child),
                if (aktif && !widget.hareketsiz) ...[
                  _kivilcim(left: -4, top: -8, faz: 0.0, r: 7),
                  _kivilcim(right: 6, top: -12, faz: 0.35, r: 9),
                  _kivilcim(right: -6, bottom: 2, faz: 0.7, r: 6),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _kivilcim({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double faz,
    required double r,
  }) {
    final v = 0.5 + 0.5 * math.sin((_isik.value * 2 + faz) * 2 * math.pi);
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: IgnorePointer(
        child: Transform.scale(
          scale: 0.5 + 0.5 * v,
          child: CustomPaint(
            size: Size(r * 2, r * 2),
            painter: _KivilcimBoya(
                r,
                Color.lerp(const Color(0xFFFFD84D), Colors.white, 0.3)!
                    .withValues(alpha: v)),
          ),
        ),
      ),
    );
  }
}

class _KivilcimBoya extends CustomPainter {
  _KivilcimBoya(this.r, this.renk);
  final double r;
  final Color renk;
  @override
  void paint(Canvas canvas, Size size) =>
      _yildiz(canvas, Offset(r, r), r, renk);
  @override
  bool shouldRepaint(covariant _KivilcimBoya old) =>
      old.renk != renk || old.r != r;
}
