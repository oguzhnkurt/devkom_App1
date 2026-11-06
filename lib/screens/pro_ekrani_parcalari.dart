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
  bool _ikinciBaslik = false;

  @override
  void initState() {
    super.initState();
    if (widget.hareketsiz) {
      _giris.value = 1;
      _ikinciBaslik = true;
      return;
    }
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
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
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
                  height: 126,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_giris, _suzulme]),
                    child: widget.maskot,
                    builder: (context, child) {
                      // Ucarak gelis: buyuk ve egik baslayip yerine oturuyor.
                      final g = Curves.easeOutBack.transform(_giris.value);
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
                            child: Transform.scale(scale: olcek, child: child),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          // Bulut kenari: gokyuzunu beyaz govdeye baglar.
          const Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            height: 34,
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
    const tepeler = [0.0, 0.16, 0.34, 0.52, 0.7, 0.86, 1.0];
    const yukseklik = [0.45, 0.1, 0.4, 0.05, 0.35, 0.15, 0.5];
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
          height: 38,
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

/// Sari ana dugme: basilinca coker, uzerinde ara ara isik gezer.
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

class _ProDugmeState extends State<ProDugme>
    with SingleTickerProviderStateMixin {
  late final AnimationController _isik = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800));
  bool _basili = false;

  @override
  void initState() {
    super.initState();
    if (!widget.hareketsiz) _isik.repeat();
  }

  @override
  void dispose() {
    _isik.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aktif = widget.onPressed != null && !widget.yukleniyor;
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          height: 54,
          width: double.infinity,
          transform: Matrix4.translationValues(0, _basili ? 3 : 0, 0),
          decoration: BoxDecoration(
            color: aktif ? ProRenk.sari : ProRenk.sari.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ProRenk.sariKoyu,
                offset: Offset(0, _basili ? 1 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (aktif && !widget.hareketsiz)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _isik,
                      builder: (context, _) {
                        // Isik yalniz dongunun ilk %40'inda geciyor.
                        final v = (_isik.value / 0.4).clamp(0.0, 1.0);
                        return Align(
                          alignment: Alignment(-1.6 + 3.2 * v, 0),
                          child: Transform.rotate(
                            angle: 0.35,
                            child: Container(
                              width: 34,
                              height: 120,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                widget.yukleniyor
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.6, color: ProRenk.lacivert),
                      )
                    : Text(
                        widget.etiket,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: ProRenk.lacivert,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
