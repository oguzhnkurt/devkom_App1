import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../ui/motion.dart';
import '../../utils/lang.dart';
import '../tanitim/tanitim_parcalari.dart' show YesilBayrak;

/// SCRATCH SAHNESI — kursun acilis sahnesindeki ve butun Scratch ders
/// adimlarindaki "Sahne" karti.
///
/// Beyaz kart; ustte Scratch'teki gibi yesil bayrak, kirmizi dur ve
/// "Sahne" yazisi; altta gokyuzu, iki bulut ve yesil bir tepe. Acilis
/// sahnesi (kurs_acilis_ekrani.dart) ve blok kurma adimi
/// (step_widgets.dart + BlockAnimationPlayer) AYNI widget'i kullaniyor:
/// cocuk acilista gordugu sahneyi derste de goruyor.
class ScratchSahneKarti extends StatelessWidget {
  const ScratchSahneKarti({
    super.key,
    required this.lang,
    required this.child,
    this.onBayrak,
    this.onDur,
    this.nabiz,
    this.bayrakAnahtari,
    this.durAnahtari,
    this.baslik,
    this.calisiyor = false,
  });

  final String lang;

  /// Sag ustteki yazi; verilmezse "Sahne" (mBlock kartinda "Arduino Uno").
  final String? baslik;

  /// Sahnenin govdesi (gokyuzu zemininin ustunde). Genelde
  /// [ScratchSahneZemini] ile.
  final Widget child;

  /// Yesil bayrak; null ise pasif.
  final VoidCallback? onBayrak;

  /// Dur; null ise pasif.
  final VoidCallback? onDur;

  /// Verilirse aktif bayrak bu degerle "buraya" diye nabiz atiyor.
  final Animation<double>? nabiz;

  final Key? bayrakAnahtari;
  final Key? durAnahtari;

  /// Kod calisiyor: bayrak "basili" (Scratch'teki gibi vurgulu) gorunuyor.
  final bool calisiyor;

  /// Baslik 44 pt: bayrak ve dur dugmelerinin dokunma alani tam 44x44.
  static const double baslikYuksekligi = 44;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: baslikYuksekligi,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 12),
              child: Row(
                children: [
                  SahneBayrakDugmesi(
                    key: bayrakAnahtari,
                    lang: lang,
                    onTap: onBayrak,
                    nabiz: nabiz,
                    calisiyor: calisiyor,
                  ),
                  SahneDurDugmesi(key: durAnahtari, lang: lang, onTap: onDur),
                  const Spacer(),
                  Text(
                    baslik ??
                        AppLang.pick(lang,
                            tr: 'Sahne',
                            en: 'Stage',
                            de: 'Bühne',
                            es: 'Escenario'),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Sahnenin zemini: gokyuzu gradyani, bulutlar, tepe ve zemin cizgisi.
/// [builder] ayni kutunun boyutunu ve zemin cizgisinin yuksekligini alir;
/// kukla, adim noktalari, kalem izi onun ustune konuyor.
class ScratchSahneZemini extends StatelessWidget {
  const ScratchSahneZemini({super.key, required this.builder});

  final Widget Function(BuildContext context, Size boyut, double zemin) builder;

  /// Zemin cizgisinin yuksekligi (kutunun ustunden).
  static double zeminOf(double h) => h - math.max(18.0, h * 0.16);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE9F4FF), Color(0xFFF7FBFF)],
        ),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final boyut = Size(c.maxWidth, c.maxHeight);
        final zemin = zeminOf(c.maxHeight);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: SahneDekoru(zemin: zemin)),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: zemin,
              child: Container(height: 2, color: const Color(0xFFB9DDB0)),
            ),
            Positioned.fill(child: builder(context, boyut, zemin)),
          ],
        );
      }),
    );
  }
}

/// Sahnenin arka plani: iki bulut ve zeminde yumusak bir tepe.
class SahneDekoru extends CustomPainter {
  SahneDekoru({required this.zemin});
  final double zemin;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final bulut = Paint()..color = Colors.white.withValues(alpha: 0.95);
    void bulutCiz(double x, double y, double r) {
      canvas.drawCircle(Offset(x, y), r, bulut);
      canvas.drawCircle(Offset(x + r * 0.9, y + r * 0.15), r * 0.8, bulut);
      canvas.drawCircle(Offset(x - r * 0.9, y + r * 0.2), r * 0.7, bulut);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x - r * 1.5, y, r * 3.1, r * 0.9),
              Radius.circular(r * 0.45)),
          bulut);
    }

    final r = math.max(10.0, math.min(w, zemin) * 0.07);
    bulutCiz(w * 0.22, zemin * 0.22, r);
    bulutCiz(w * 0.74, zemin * 0.34, r * 0.8);

    // Zemin: hafif yesil tepe.
    final tepe = Path()
      ..moveTo(0, zemin + 1)
      ..quadraticBezierTo(w * 0.3, zemin - 10, w * 0.55, zemin - 2)
      ..quadraticBezierTo(w * 0.8, zemin + 6, w, zemin - 6)
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(tepe, Paint()..color = const Color(0xFFDDF1D6));
  }

  @override
  bool shouldRepaint(covariant SahneDekoru old) => old.zemin != zemin;
}

/// Yesil bayrak dugmesi (sahne basliginda).
///
/// Uc hal: PASIF (calisacak kod yok: gri, soluk), HAZIR (acik yesil
/// zemin, yesil kenar; [nabiz] verilirse "buraya bas" diye nabiz atar)
/// ve CALISIYOR (Scratch'teki gibi "basili": dolu zemin, koyu kenar,
/// hafif iceri gocmus). Dokunma alani 44x44; gorunen kutu 32.
class SahneBayrakDugmesi extends StatelessWidget {
  const SahneBayrakDugmesi({
    super.key,
    required this.lang,
    this.onTap,
    this.nabiz,
    this.calisiyor = false,
    this.boy = 32,
  });

  final String lang;
  final VoidCallback? onTap;
  final Animation<double>? nabiz;
  final bool calisiyor;
  final double boy;

  static const Color _yesil = Color(0xFF45993D);

  @override
  Widget build(BuildContext context) {
    final aktif = onTap != null;
    final azHareket = Motion.reduced(context);
    Widget kutu(double p) => AnimatedContainer(
          duration: azHareket ? Duration.zero : Motion.short3,
          width: boy,
          height: boy,
          decoration: BoxDecoration(
            color: calisiyor
                ? const Color(0xFFC9EBC4)
                : aktif
                    ? const Color(0xFFE6F4E4)
                    : const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: calisiyor
                  ? _yesil
                  : aktif
                      ? _yesil.withValues(alpha: 0.4 + 0.6 * p)
                      : const Color(0xFFDDE1E7),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Opacity(
            opacity: aktif || calisiyor ? 1 : 0.35,
            child: YesilBayrak(boyut: boy * 0.6),
          ),
        );
    final gorunum = AnimatedScale(
      scale: calisiyor ? 0.9 : 1,
      duration: azHareket ? Duration.zero : Motion.short3,
      child: nabiz == null || !aktif || calisiyor
          ? kutu(1)
          : AnimatedBuilder(
              animation: nabiz!,
              builder: (context, _) => kutu(nabiz!.value),
            ),
    );
    return Semantics(
      button: true,
      enabled: aktif,
      selected: calisiyor,
      label: AppLang.pick(lang,
          tr: 'Yeşil bayrak',
          en: 'Green flag',
          de: 'Grüne Flagge',
          es: 'Bandera verde'),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: gorunum),
        ),
      ),
    );
  }
}

/// Kirmizi "dur" sekizgeni; [onTap] verilince dugme (kod calisirken).
/// Pasifken gri ve soluk: cocuk "basinca bir sey olmadi" diye
/// sasirmasin. Dokunma alani 44x44.
class SahneDurDugmesi extends StatelessWidget {
  const SahneDurDugmesi({super.key, required this.lang, this.onTap});
  final String lang;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final aktif = onTap != null;
    final sure = Motion.reduced(context) ? Duration.zero : Motion.short3;
    return Semantics(
      button: true,
      enabled: aktif,
      label: AppLang.pick(lang,
          tr: 'Durdur', en: 'Stop', de: 'Stopp', es: 'Detener'),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: sure,
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: aktif ? const Color(0xFFFDE8E8) : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: AnimatedOpacity(
                opacity: aktif ? 1 : 0.4,
                duration: sure,
                child: DurIsareti(boyut: 20, pasif: !aktif),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Scratch'in kirmizi "dur" sekizgeni.
class DurIsareti extends StatelessWidget {
  const DurIsareti({super.key, this.boyut = 20, this.pasif = false});
  final double boyut;

  /// Gri sekizgen (durdurulacak bir sey yok).
  final bool pasif;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(boyut),
        painter: _SekizgenBoyaci(pasif),
      );
}

class _SekizgenBoyaci extends CustomPainter {
  _SekizgenBoyaci(this.pasif);
  final bool pasif;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = size.center(Offset.zero);
    final p = Path();
    for (var i = 0; i < 8; i++) {
      final a = math.pi / 8 + i * math.pi / 4;
      final o = c + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    p.close();
    canvas.drawPath(p,
        Paint()..color = pasif ? const Color(0xFFB4BAC4) : const Color(0xFFEC5959));
    canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = pasif ? const Color(0xFF8F96A3) : const Color(0xFFB84848));
  }

  @override
  bool shouldRepaint(covariant _SekizgenBoyaci old) => old.pasif != pasif;
}

/// Sahnede kuklanin ustunde konusma balonu (Scratch'teki gibi kuyruklu).
class SahneBalonu extends StatelessWidget {
  const SahneBalonu({super.key, required this.metin, this.kenar});
  final String metin;
  final Color? kenar;

  @override
  Widget build(BuildContext context) {
    final k = kenar ?? const Color(0xFFC9D3E3);
    return CustomPaint(
      painter: _BalonKuyrugu(k),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: k, width: 2),
        ),
        child: Text(
          metin,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2430),
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _BalonKuyrugu extends CustomPainter {
  _BalonKuyrugu(this.renk);
  final Color renk;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final y = size.height - 9;
    final p = Path()
      ..moveTo(x - 7, y)
      ..lineTo(x, size.height)
      ..lineTo(x + 7, y)
      ..close();
    canvas.drawPath(p, Paint()..color = Colors.white);
    canvas.drawPath(
        Path()
          ..moveTo(x - 7, y + 0.5)
          ..lineTo(x, size.height)
          ..lineTo(x + 7, y + 0.5),
        Paint()
          ..color = renk
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _BalonKuyrugu old) => old.renk != renk;
}
