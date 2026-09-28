import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/store_item_model.dart';

/// Profil avatarının etrafındaki çerçeve.
///
/// NEDEN VAR
/// ---------
/// Market, jetonla "avatar çerçevesi" satıyordu ama çerçeve HİÇBİR YERDE
/// görünmüyordu: çocuk jetonunu veriyor, ekranda hiçbir şey değişmiyordu.
/// Karşılığı olmayan bir vaat, mağazanın kendisini anlamsız kılar.
///
/// NEDEN ANIMASYONLU VE NEDEN ÇİZİMLE
/// ----------------------------------
/// İlk sürümde her çerçeve AYNI şekilde çiziliyordu: ürünün rengiyle
/// boyanmış bir halka ve köşesinde emojisi. Yani "Alev Çerçevesi" ile
/// "Buz Çerçevesi" arasındaki tek fark renkti. Çocuk 120 jeton biriktirip
/// aldığında gördüğü şey, elindekinin turuncusuydu. Koleksiyon hissi
/// oluşmuyordu — oysa marketin bütün amacı o his.
///
/// Artık her çerçevenin kendi ÇİZİMİ ve kendi HAREKETİ var: alev
/// dalgalanıyor, devrede ışık dolaşıyor, yaprak sallanıyor, galakside
/// yıldızlar dönüyor. Hepsi `CustomPainter` ile çiziliyor, tek bir PNG
/// bile eklenmedi:
///
///   * Her boyutta net — 40 piksellik sıralama avatarında da, 160
///     piksellik profil avatarında da aynı çizim.
///   * Uygulama boyutu büyümüyor. Yirmi çerçevenin yirmi görseli
///     olsaydı paket megabaytlarca şişerdi.
///   * Yeni çerçeve eklemek bir satır: katalogda `item_key`, burada
///     stil eşlemesi.
///
/// ERİŞİLEBİLİRLİK: cihazda "hareketi azalt" açıksa animasyon durur,
/// çerçeve sabit bir karesinde kalır. Süsleme uğruna kimsenin başı
/// dönmemeli.
class AvatarCercevesi extends StatefulWidget {
  const AvatarCercevesi({
    super.key,
    required this.boyut,
    required this.child,
    this.cerceve,
    this.rozetGoster = true,
  });

  final double boyut;

  /// Halkanın içindeki şey (maskot, baş harf...).
  final Widget child;

  /// Kuşanılmış çerçeve. null ise sade beyaz halka.
  final StoreItem? cerceve;

  /// Sağ alttaki emoji rozeti. Küçük boyutlarda kapatmak için.
  final bool rozetGoster;

  static Color renk(String hex) {
    final t = hex.replaceFirst('#', '');
    final v = int.tryParse(t.length == 6 ? '0xFF$t' : '0x$t');
    return v == null ? const Color(0xFF6C3CE0) : Color(v);
  }

  @override
  State<AvatarCercevesi> createState() => _AvatarCercevesiState();
}

class _AvatarCercevesiState extends State<AvatarCercevesi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    // Tek bir uzun dongu: her stil bunun icinden kendi hizini turetiyor.
    // Stil basina ayri controller acmak, market izgarasinda yirmi
    // controller demekti.
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cerceve;
    final boyut = widget.boyut;

    if (c == null) {
      return Container(
        width: boyut,
        height: boyut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.85), width: 3),
        ),
        child: Center(child: widget.child),
      );
    }

    final ana = AvatarCercevesi.renk(c.colorHex);
    final stil = cerceveStili(c.itemKey);
    final kalinlik = boyut * 0.055;

    // Hareketi azalt acikken animasyon durur.
    final hareketsiz =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return SizedBox(
      width: boyut,
      height: boyut,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                size: Size(boyut, boyut),
                painter: _CercevePainter(
                  stil: stil,
                  ana: ana,
                  kalinlik: kalinlik,
                  t: hareketsiz ? 0.0 : _c.value,
                ),
              ),
            ),
          ),
          // Icerik, cizimin en dar yerinden de tasmasin diye halkanin
          // ic capinin biraz altinda tutuluyor.
          ClipOval(
            child: SizedBox(
              width: boyut - kalinlik * 2.6,
              height: boyut - kalinlik * 2.6,
              child: Container(
                color: Colors.white,
                child: Center(child: widget.child),
              ),
            ),
          ),
          if (widget.rozetGoster && c.iconEmoji.isNotEmpty)
            Positioned(
              bottom: 0,
              right: boyut * 0.02,
              child: Container(
                padding: EdgeInsets.all(boyut * 0.025),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child:
                    Text(c.iconEmoji, style: TextStyle(fontSize: boyut * 0.12)),
              ),
            ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- stiller

/// Çerçevenin çizim ailesi.
///
/// Yirmi çerçeve için yirmi ayrı çizici yazmak yerine dokuz aile var;
/// ürünün rengi aileyi başka bir çerçeveye çeviriyor. "Alev" ile "Lav"
/// aynı aileden ama biri turuncu biri kırmızı, ve ikisi de "Buz"a hiç
/// benzemiyor. Çeşitlilik bu ikisinin çarpımından geliyor.
enum CerceveStili {
  duz,
  sweep,
  yorunge,
  alev,
  nabiz,
  kristal,
  yaprak,
  serit,
  civata,
}

/// `item_key` → stil. Bilinmeyen anahtar `sweep`e düşüyor: katalogda
/// yeni bir çerçeve belirirse çirkin değil, sade görünsün.
CerceveStili cerceveStili(String itemKey) {
  switch (itemKey) {
    case 'frame_simple':
      return CerceveStili.duz;

    case 'frame_star':
    case 'frame_galaxy':
    case 'frame_comet':
    case 'frame_aurora':
      return CerceveStili.yorunge;

    case 'frame_fire':
    case 'frame_flame':
    case 'frame_lava':
      return CerceveStili.alev;

    case 'frame_circuit':
    case 'frame_neon':
    case 'frame_thunder':
      return CerceveStili.nabiz;

    case 'frame_ice':
    case 'frame_diamond':
    case 'frame_crystal':
      return CerceveStili.kristal;

    case 'frame_forest':
    case 'frame_sakura':
    case 'frame_ocean':
      return CerceveStili.yaprak;

    case 'frame_candy':
    case 'frame_rainbow':
      return CerceveStili.serit;

    case 'frame_robot':
    case 'frame_pixel':
    case 'frame_bolt':
      return CerceveStili.civata;

    case 'frame_gold':
    case 'frame_bronze':
    case 'frame_royal':
      return CerceveStili.sweep;

    default:
      return CerceveStili.sweep;
  }
}

class _CercevePainter extends CustomPainter {
  _CercevePainter({
    required this.stil,
    required this.ana,
    required this.kalinlik,
    required this.t,
  });

  final CerceveStili stil;
  final Color ana;
  final double kalinlik;

  /// 0..1 arası dönen zaman.
  final double t;

  static const _tau = math.pi * 2;

  Color get _acik => Color.lerp(ana, Colors.white, 0.6)!;
  Color get _koyu => Color.lerp(ana, Colors.black, 0.35)!;

  @override
  void paint(Canvas canvas, Size size) {
    final merkez = size.center(Offset.zero);
    final r = size.width / 2 - kalinlik / 2;

    _hale(canvas, merkez, r);

    switch (stil) {
      case CerceveStili.duz:
        _duz(canvas, merkez, r);
        break;
      case CerceveStili.sweep:
        _sweep(canvas, merkez, r);
        break;
      case CerceveStili.yorunge:
        _yorunge(canvas, merkez, r);
        break;
      case CerceveStili.alev:
        _alev(canvas, merkez, r);
        break;
      case CerceveStili.nabiz:
        _nabiz(canvas, merkez, r);
        break;
      case CerceveStili.kristal:
        _kristal(canvas, merkez, r);
        break;
      case CerceveStili.yaprak:
        _yaprak(canvas, merkez, r);
        break;
      case CerceveStili.serit:
        _serit(canvas, merkez, r);
        break;
      case CerceveStili.civata:
        _civata(canvas, merkez, r);
        break;
    }
  }

  /// Halkanin disina tasan yumusak isik. Cerceveyi arka plandan ayirir.
  void _hale(Canvas canvas, Offset m, double r) {
    final p = Paint()
      ..color = ana.withValues(alpha: 0.30)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, kalinlik * 1.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = kalinlik;
    canvas.drawCircle(m, r, p);
  }

  Paint get _halkaKalem => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = kalinlik
    ..strokeCap = StrokeCap.round;

  void _duz(Canvas canvas, Offset m, double r) {
    canvas.drawCircle(m, r, _halkaKalem..color = ana);
    canvas.drawCircle(
        m,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = kalinlik * 0.35
          ..color = _acik.withValues(alpha: 0.7));
  }

  /// Donen parlaklik. Altin, elmas, varsayilan.
  void _sweep(Canvas canvas, Offset m, double r) {
    final rect = Rect.fromCircle(center: m, radius: r);
    final shader = SweepGradient(
      transform: GradientRotation(t * _tau),
      colors: [ana, _acik, ana, _koyu, ana],
      stops: const [0.0, 0.18, 0.5, 0.72, 1.0],
    ).createShader(rect);
    canvas.drawCircle(m, r, _halkaKalem..shader = shader);

    // Kisa, keskin bir parilti: metal hissi buradan geliyor.
    final aci = t * _tau;
    final parilti = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = kalinlik * 0.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.85)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, kalinlik * 0.3);
    canvas.drawArc(rect, aci, 0.5, false, parilti);
  }

  /// Halkanin uzerinde donen isik noktalari. Yildiz, galaksi.
  void _yorunge(Canvas canvas, Offset m, double r) {
    canvas.drawCircle(m, r, _halkaKalem..color = _koyu.withValues(alpha: 0.9));
    canvas.drawCircle(
        m,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = kalinlik * 0.3
          ..color = _acik.withValues(alpha: 0.5));

    const adet = 7;
    for (var i = 0; i < adet; i++) {
      // Her nokta farkli hizda: hepsi ayni hizda donerse halka
      // doniyormus gibi durur, yildizlar gibi degil.
      final hiz = 1.0 + (i % 3) * 0.35;
      final aci = (t * hiz + i / adet) * _tau;
      final nabiz = 0.6 + 0.4 * math.sin((t * 2 + i * 0.3) * _tau);
      final nokta = m + Offset(math.cos(aci), math.sin(aci)) * r;
      canvas.drawCircle(
          nokta,
          kalinlik * 0.42 * nabiz,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.95)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, kalinlik * 0.25));
    }
  }

  /// Disa dogru dalgalanan diller. Ates, alev, lav.
  void _alev(Canvas canvas, Offset m, double r) {
    canvas.drawCircle(m, r, _halkaKalem..color = _koyu);

    const dil = 14;
    final yol = Path();
    for (var i = 0; i < dil; i++) {
      final taban = i / dil * _tau;
      final yukseklik = kalinlik *
          (1.1 + 0.9 * math.sin((t * 2.2 + i * 0.7) * _tau).abs());
      final genislik = _tau / dil * 0.42;

      final a = m + Offset(math.cos(taban - genislik), math.sin(taban - genislik)) * r;
      final b = m + Offset(math.cos(taban + genislik), math.sin(taban + genislik)) * r;
      final uc = m + Offset(math.cos(taban), math.sin(taban)) * (r + yukseklik);

      yol
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(
            m.dx + math.cos(taban - genislik * 0.3) * (r + yukseklik * 0.5),
            m.dy + math.sin(taban - genislik * 0.3) * (r + yukseklik * 0.5),
            uc.dx,
            uc.dy)
        ..quadraticBezierTo(
            m.dx + math.cos(taban + genislik * 0.3) * (r + yukseklik * 0.5),
            m.dy + math.sin(taban + genislik * 0.3) * (r + yukseklik * 0.5),
            b.dx,
            b.dy)
        ..close();
    }
    canvas.drawPath(
        yol,
        Paint()
          ..shader = RadialGradient(
            colors: [_acik, ana, ana.withValues(alpha: 0.0)],
            stops: const [0.55, 0.8, 1.0],
          ).createShader(Rect.fromCircle(center: m, radius: r + kalinlik * 2)));

    canvas.drawCircle(
        m,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = kalinlik * 0.45
          ..color = _acik.withValues(alpha: 0.9));
  }

  /// Halkada dolasan isik ve dugum noktalari. Devre, neon, simsek.
  void _nabiz(Canvas canvas, Offset m, double r) {
    final rect = Rect.fromCircle(center: m, radius: r);
    canvas.drawCircle(m, r, _halkaKalem..color = _koyu);

    // Dolasan parlak yay.
    final shader = SweepGradient(
      transform: GradientRotation(t * _tau),
      colors: [
        ana.withValues(alpha: 0.0),
        ana.withValues(alpha: 0.0),
        _acik,
        Colors.white,
        _acik,
        ana.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.55, 0.78, 0.85, 0.92, 1.0],
    ).createShader(rect);
    canvas.drawCircle(
        m,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = kalinlik
          ..strokeCap = StrokeCap.round
          ..shader = shader);

    // Devre dugumleri: kare lehim noktalari.
    const adet = 8;
    for (var i = 0; i < adet; i++) {
      final aci = i / adet * _tau;
      final p = m + Offset(math.cos(aci), math.sin(aci)) * r;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(aci);
      final k = kalinlik * 0.5;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: k, height: k),
              Radius.circular(k * 0.25)),
          Paint()..color = _acik);
      canvas.restore();
    }
  }

  /// Disa bakan sivri kristaller. Buz, elmas.
  void _kristal(Canvas canvas, Offset m, double r) {
    canvas.drawCircle(m, r, _halkaKalem..color = ana);

    const adet = 10;
    final buyume = 0.85 + 0.15 * math.sin(t * _tau);
    for (var i = 0; i < adet; i++) {
      final aci = i / adet * _tau + t * 0.25 * _tau;
      final uzun = i.isEven ? 1.7 : 1.05;
      final uc = m + Offset(math.cos(aci), math.sin(aci)) * (r + kalinlik * uzun * buyume);
      final yan = _tau / adet * 0.3;
      final a = m + Offset(math.cos(aci - yan), math.sin(aci - yan)) * r;
      final b = m + Offset(math.cos(aci + yan), math.sin(aci + yan)) * r;
      final ic = m + Offset(math.cos(aci), math.sin(aci)) * (r - kalinlik * 0.5);

      final yol = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(uc.dx, uc.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(ic.dx, ic.dy)
        ..close();
      canvas.drawPath(
          yol,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withValues(alpha: 0.95), ana],
            ).createShader(yol.getBounds()));
    }

    // Kayan parilti.
    final aci = t * _tau;
    canvas.drawArc(
        Rect.fromCircle(center: m, radius: r),
        aci,
        0.7,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = kalinlik * 0.45
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.9)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, kalinlik * 0.35));
  }

  /// Halkaya dizilmis, hafifce sallanan yapraklar. Orman, sakura.
  void _yaprak(Canvas canvas, Offset m, double r) {
    canvas.drawCircle(m, r, _halkaKalem..color = _koyu);

    const adet = 9;
    for (var i = 0; i < adet; i++) {
      final taban = i / adet * _tau;
      final salinim = 0.18 * math.sin((t + i / adet) * _tau);
      final aci = taban + salinim;
      final p = m + Offset(math.cos(aci), math.sin(aci)) * r;

      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(aci + math.pi / 2);
      final u = kalinlik * 1.5;
      final g = kalinlik * 0.8;
      final yol = Path()
        ..moveTo(0, -u * 0.55)
        ..quadraticBezierTo(g, 0, 0, u * 0.55)
        ..quadraticBezierTo(-g, 0, 0, -u * 0.55)
        ..close();
      canvas.drawPath(
          yol,
          Paint()
            ..shader = LinearGradient(
              colors: [_acik, ana],
            ).createShader(yol.getBounds()));
      canvas.drawLine(
          Offset(0, -u * 0.45),
          Offset(0, u * 0.45),
          Paint()
            ..color = _koyu.withValues(alpha: 0.6)
            ..strokeWidth = kalinlik * 0.09);
      canvas.restore();
    }
  }

  /// Donen renkli seritler. Seker, gokkusagi.
  void _serit(Canvas canvas, Offset m, double r) {
    final rect = Rect.fromCircle(center: m, radius: r);
    const dilim = 12;
    final ikinci = Color.lerp(ana, Colors.white, 0.75)!;

    for (var i = 0; i < dilim; i++) {
      final basla = (i / dilim) * _tau + t * _tau;
      canvas.drawArc(
          rect,
          basla,
          _tau / dilim,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = kalinlik
            ..color = i.isEven ? ana : ikinci);
    }
    // Serit uclari sert kalmasin diye ustune yumusak bir parlaklik.
    canvas.drawCircle(
        m,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = kalinlik * 0.28
          ..color = Colors.white.withValues(alpha: 0.45));
  }

  /// Civatali metal halka ve tarama cizgisi. Robot, piksel.
  void _civata(Canvas canvas, Offset m, double r) {
    canvas.drawCircle(
        m,
        r,
        _halkaKalem
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_acik, ana, _koyu, ana],
          ).createShader(Rect.fromCircle(center: m, radius: r)));

    const adet = 6;
    for (var i = 0; i < adet; i++) {
      final aci = i / adet * _tau;
      final p = m + Offset(math.cos(aci), math.sin(aci)) * r;
      canvas.drawCircle(p, kalinlik * 0.36, Paint()..color = _koyu);
      canvas.drawCircle(
          p,
          kalinlik * 0.36,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = kalinlik * 0.1
            ..color = _acik);
      // Civata yarigi.
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(aci + t * _tau * 0.5);
      canvas.drawLine(
          Offset(-kalinlik * 0.2, 0),
          Offset(kalinlik * 0.2, 0),
          Paint()
            ..color = _acik
            ..strokeWidth = kalinlik * 0.1);
      canvas.restore();
    }

    // Asagi yukari gezen tarama cizgisi.
    final tarama = (math.sin(t * _tau) + 1) / 2;
    final y = m.dy - r + 2 * r * tarama;
    final yari = math.sqrt(math.max(0, r * r - (y - m.dy) * (y - m.dy)));
    canvas.drawLine(
        Offset(m.dx - yari, y),
        Offset(m.dx + yari, y),
        Paint()
          ..color = _acik.withValues(alpha: 0.55)
          ..strokeWidth = kalinlik * 0.22
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, kalinlik * 0.2));
  }

  @override
  bool shouldRepaint(covariant _CercevePainter old) =>
      old.t != t || old.ana != ana || old.stil != stil ||
      old.kalinlik != kalinlik;
}
