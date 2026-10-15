import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../ui/motion.dart';
import '../../../widgets/mascot.dart';

/// Ders ekraninin ilerleme cubugu: tek parca, yumusak bir yol.
///
/// ONCEDEN: adim sayisi kadar ayri turuncu parca ("4/10" gibi doluyordu).
/// Cocuga bir form cubugu gibi geliyordu. Simdi:
///
/// * Hafif renkli tek bir yol; uzerinde kursun renginde, parlak bir
///   degrade dolgu yumusakca ilerliyor (ileri de geri de).
/// * Dolgunun ucunda kucuk bir Devi rozeti "biniyor"; adim degisince
///   ileri dogru bir kez zipliyor.
/// * Yolun uzerinde adim noktalari: gecilenler dolgunun icinde parliyor,
///   gelecekler soluk. Cok adimli derslerde (16'dan fazla) noktalar
///   seyreltiliyor ki yol bir noktali cizgiye donmesin.
/// * Yolun sonunda bir kupa: son adimlara gelince kipirdiyor, son adimda
///   altin rengine donuyor.
///
/// Ekran okuyucu tek bir etiket duyuyor: "Adim 5/10". Hareketi azalt
/// acikken dolgu aninda yerine geciyor, ziplama ve kipirdama yok.
class DersIlerlemeCubugu extends StatefulWidget {
  const DersIlerlemeCubugu({
    super.key,
    required this.adim,
    required this.toplam,
    required this.renk,
    required this.renk2,
    required this.etiket,
    this.koyu = false,
  });

  /// Simdiki adim (0'dan).
  final int adim;

  /// Toplam adim sayisi.
  final int toplam;

  final Color renk;
  final Color renk2;

  /// Ekran okuyucu etiketi ("Adım 5/10").
  final String etiket;

  final bool koyu;

  /// Cubugun toplam yuksekligi (Devi rozeti dahil).
  static const double yukseklik = 32;

  /// Bu kadar adima kadar her adimin noktasi ciziliyor; fazlasinda
  /// noktalar seyreltiliyor.
  static const int tamNoktaSiniri = 16;

  /// [toplam] adimli bir derste hangi adimlarin noktasi cizilir.
  static List<int> noktalar(int toplam) {
    if (toplam < 2) return const [];
    final aralik =
        toplam <= tamNoktaSiniri ? 1 : (toplam / 10).ceil();
    return [
      for (var k = 0; k < toplam; k++)
        if ((k + 1) % aralik == 0 || k == toplam - 1) k,
    ];
  }

  @override
  State<DersIlerlemeCubugu> createState() => _DersIlerlemeCubuguState();
}

class _DersIlerlemeCubuguState extends State<DersIlerlemeCubugu>
    with TickerProviderStateMixin {
  /// Dolgu orani (0..1). Adim degisince yumusakca hedefe gidiyor.
  late final AnimationController _dolgu =
      AnimationController(vsync: this, value: _hedef);

  /// Devi'nin ziplamasi (0..1, bir kez).
  late final AnimationController _zipla = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 560));

  /// Kupanin kipirdamasi (son adimlarda dongu).
  late final AnimationController _kupa = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200));

  double get _hedef =>
      widget.toplam <= 0 ? 0 : (widget.adim + 1) / widget.toplam;

  /// Son iki adim (ya da son %20): kupa kipirdiyor.
  bool get _sonaYakin =>
      widget.toplam > 1 &&
      (widget.toplam - 1 - widget.adim <= 1 || _hedef >= 0.8);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _kupayiAyarla();
  }

  @override
  void didUpdateWidget(DersIlerlemeCubugu old) {
    super.didUpdateWidget(old);
    if (old.adim != widget.adim || old.toplam != widget.toplam) {
      if (Motion.reduced(context)) {
        _dolgu.value = _hedef;
      } else {
        _dolgu.animateTo(_hedef,
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic);
        if (widget.adim > old.adim) _zipla.forward(from: 0);
      }
    }
    _kupayiAyarla();
  }

  void _kupayiAyarla() {
    if (_sonaYakin && !Motion.reduced(context)) {
      if (!_kupa.isAnimating) _kupa.repeat();
    } else {
      _kupa.stop();
      _kupa.value = 0;
    }
  }

  @override
  void dispose() {
    _dolgu.dispose();
    _zipla.dispose();
    _kupa.dispose();
    super.dispose();
  }

  static const double _kupaGenisligi = 26;
  static const double _yolYuksekligi = 12;
  static const double _binici = 28;

  @override
  Widget build(BuildContext context) {
    final bitti = widget.adim >= widget.toplam - 1;
    return Semantics(
      key: const ValueKey('ders_ilerleme_cubugu'),
      label: widget.etiket,
      container: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: DersIlerlemeCubugu.yukseklik,
          child: LayoutBuilder(builder: (context, c) {
            // Yol, kupaya yer birakarak bitiyor. Binici yarisi kadar
            // soldan iceri: ilk adimda yolun disina tasmasin.
            const bas = _binici / 2 - 4;
            final yolGenisligi =
                math.max(0.0, c.maxWidth - _kupaGenisligi - _binici / 2 - 8 - bas);
            return AnimatedBuilder(
              animation: Listenable.merge([_dolgu, _zipla, _kupa]),
              builder: (context, _) {
                final oran = _dolgu.value.clamp(0.0, 1.0);
                final uc = bas + yolGenisligi * oran;
                final z = _zipla.value;
                final yukari = math.sin(z * math.pi) * 7;
                final egik = math.sin(z * math.pi * 2) * 0.12;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: bas,
                      width: yolGenisligi,
                      top: (DersIlerlemeCubugu.yukseklik - _yolYuksekligi) / 2,
                      height: _yolYuksekligi,
                      child: CustomPaint(
                        painter: _YolBoyaci(
                          oran: oran,
                          toplam: widget.toplam,
                          adim: widget.adim,
                          renk: widget.renk,
                          renk2: widget.renk2,
                          koyu: widget.koyu,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: (DersIlerlemeCubugu.yukseklik - _kupaGenisligi) / 2,
                      width: _kupaGenisligi,
                      height: _kupaGenisligi,
                      child: _kupaCiz(bitti),
                    ),
                    Positioned(
                      key: const ValueKey('ders_ilerleme_binici'),
                      left: uc - _binici / 2,
                      top: (DersIlerlemeCubugu.yukseklik - _binici) / 2 - yukari,
                      width: _binici,
                      height: _binici,
                      child: Transform.rotate(
                        angle: egik,
                        child: _BiniciRozeti(renk: widget.renk, koyu: widget.koyu),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _kupaCiz(bool bitti) {
    // Kipirdama: dongunun ilk %30'unda sag-sol sallanma, sonra dinlenme.
    final t = _kupa.value;
    final aci = t < 0.3 ? math.sin(t / 0.3 * math.pi * 3) * 0.22 : 0.0;
    final altin = const Color(0xFFF5B301);
    final renk = bitti
        ? altin
        : _sonaYakin
            ? altin.withValues(alpha: 0.85)
            : (widget.koyu
                ? Colors.white.withValues(alpha: 0.28)
                : widget.renk.withValues(alpha: 0.32));
    return Transform.rotate(
      angle: aci,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            if (bitti || _sonaYakin)
              BoxShadow(
                color: altin.withValues(alpha: bitti ? 0.45 : 0.25),
                blurRadius: bitti ? 12 : 8,
              ),
          ],
        ),
        child: Icon(Icons.emoji_events_rounded, size: _kupaGenisligi, color: renk),
      ),
    );
  }
}

/// Dolgunun ucundaki kucuk Devi rozeti.
class _BiniciRozeti extends StatelessWidget {
  const _BiniciRozeti({required this.renk, required this.koyu});

  final Color renk;
  final bool koyu;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: koyu ? const Color(0xFF26263A) : Colors.white,
        border: Border.all(color: renk, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: renk.withValues(alpha: 0.40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Yalnizca Devi'nin BASI: tam boy render (kalpleriyle birlikte)
      // 28 pt'lik rozette karmasa oluyordu. Gorselin bas kismi daireye
      // kirpiliyor.
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: ClipOval(
        child: LayoutBuilder(builder: (context, c) {
          final d = c.biggest.shortestSide;
          // Basin gorseldeki yeri (512x512 uzerinde oran): merkez
          // (0.33, 0.51), genislik ~0.40 (sagdaki kalp disarida kalsin).
          final s = d / 0.38;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: d / 2 - s * 0.33,
                top: d / 2 - s * 0.51,
                width: s,
                height: s,
                child: Image.asset(
                  Mascot.durgunGorsel,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  excludeFromSemantics: true,
                  errorBuilder: (context, _, __) =>
                      Icon(Icons.smart_toy_rounded, color: renk, size: d),
                ),
              ),
            ],
          );
        }),
      ),
      ),
    );
  }
}

/// Yol, dolgu, parlaklik ve adim noktalari.
class _YolBoyaci extends CustomPainter {
  _YolBoyaci({
    required this.oran,
    required this.toplam,
    required this.adim,
    required this.renk,
    required this.renk2,
    required this.koyu,
  });

  final double oran;
  final int toplam;
  final int adim;
  final Color renk;
  final Color renk2;
  final bool koyu;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    final yol = RRect.fromRectAndRadius(Offset.zero & size, r);

    // Yol: yumusak, kursun renginde soluk bir zemin; ustte ince bir ic
    // golge hissi (cukur bir oluk gibi).
    canvas.drawRRect(
      yol,
      Paint()
        ..color = koyu
            ? Colors.white.withValues(alpha: 0.09)
            : renk.withValues(alpha: 0.14),
    );
    canvas.drawRRect(
      yol.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = koyu
            ? Colors.white.withValues(alpha: 0.06)
            : renk.withValues(alpha: 0.10),
    );

    final dolguGenisligi = (size.width * oran).clamp(0.0, size.width);
    if (dolguGenisligi > 0) {
      final w = math.max(dolguGenisligi, size.height);
      final dolguRect = Rect.fromLTWH(0, 0, w, size.height);
      final dolgu = RRect.fromRectAndRadius(dolguRect, r);
      // Hafif parlama (dolgunun altinda).
      canvas.drawRRect(
        dolgu.shift(const Offset(0, 1.5)),
        Paint()
          ..color = renk.withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawRRect(
        dolgu,
        Paint()
          ..shader = LinearGradient(
            colors: [renk2, renk],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
      // Parlak ust serit: dolgu "cam gibi" dursun.
      final parlak = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.height * 0.35, size.height * 0.16,
            math.max(0, w - size.height * 0.7), size.height * 0.30),
        Radius.circular(size.height * 0.15),
      );
      canvas.drawRRect(
        parlak,
        Paint()..color = Colors.white.withValues(alpha: 0.42),
      );
    }

    // Adim noktalari.
    final noktalar = DersIlerlemeCubugu.noktalar(toplam);
    if (noktalar.isEmpty) return;
    final cy = size.height / 2;
    final yaricap = size.height * (toplam > 24 ? 0.14 : 0.18);
    for (final k in noktalar) {
      if (k == adim) continue; // Devi'nin altinda kaliyor.
      if (k == toplam - 1) continue; // Son nokta kupanin yaninda; gereksiz.
      final x = size.width * (k + 1) / toplam;
      final ic = x <= dolguGenisligi + 0.5;
      if (ic) {
        canvas.drawCircle(
          Offset(x - yaricap, cy),
          yaricap + 1.6,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
        canvas.drawCircle(Offset(x - yaricap, cy), yaricap,
            Paint()..color = Colors.white.withValues(alpha: 0.95));
      } else {
        canvas.drawCircle(
          Offset(x - yaricap, cy),
          yaricap,
          Paint()
            ..color = koyu
                ? Colors.white.withValues(alpha: 0.22)
                : renk.withValues(alpha: 0.30),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_YolBoyaci old) =>
      old.oran != oran ||
      old.toplam != toplam ||
      old.adim != adim ||
      old.renk != renk ||
      old.renk2 != renk2 ||
      old.koyu != koyu;
}
