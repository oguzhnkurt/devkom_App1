import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../ui/motion.dart';
import '../../widgets/scratch_blok_ikonlari.dart';

/// Acilis ve kapanis sahnelerinin ortak parcalari.

/// Harf harf beliren yazi (daktilo).
///
/// YERLESIM KAYMASI YOK: metnin tamami bastan yerlesiyor, henuz
/// "yazilmamis" kismi saydam. Balon ilk harfte de son harfte de ayni
/// boyda; satirlar yazildikca asagi kaymiyor.
///
/// Hareket azaltilmisken metin bir anda tam geliyor. Ekran okuyucu her
/// zaman metnin tamamini okuyor.
class DaktiloYazi extends StatefulWidget {
  const DaktiloYazi({
    super.key,
    required this.metin,
    required this.stil,
    this.hiz = const Duration(milliseconds: 26),
  });

  final String metin;
  final TextStyle stil;
  final Duration hiz;

  @override
  State<DaktiloYazi> createState() => DaktiloYaziState();
}

class DaktiloYaziState extends State<DaktiloYazi> {
  int _n = 0;
  Timer? _zaman;
  bool _basladi = false;

  bool get bitti => _n >= widget.metin.length;

  /// Yaziyi hemen tamamlar (balona dokununca).
  void tamamla() {
    _zaman?.cancel();
    if (mounted) setState(() => _n = widget.metin.length);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_basladi) {
      _basladi = true;
      _baslat();
    }
  }

  @override
  void didUpdateWidget(covariant DaktiloYazi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metin != widget.metin) _baslat();
  }

  void _baslat() {
    _zaman?.cancel();
    if (Motion.reduced(context)) {
      _n = widget.metin.length;
      return;
    }
    _n = 0;
    _zaman = Timer.periodic(widget.hiz, (t) {
      if (!mounted) return t.cancel();
      setState(() => _n = (_n + 1).clamp(0, widget.metin.length));
      if (_n >= widget.metin.length) t.cancel();
    });
  }

  @override
  void dispose() {
    _zaman?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.metin;
    final n = _n.clamp(0, m.length);
    return Semantics(
      label: m,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(children: [
            TextSpan(text: m.substring(0, n)),
            TextSpan(
              text: m.substring(n),
              style: const TextStyle(color: Colors.transparent),
            ),
          ]),
          style: widget.stil,
        ),
      ),
    );
  }
}

/// Devi'nin konusma balonu: soldaki kucuk kuyruk Devi'yi gosteriyor.
///
/// Yukseklik disaridan sabit veriliyor; metin uzun gelirse (Almanca)
/// yerlesimi itmek yerine olcekle kuculuyor.
class DeviBalonu extends StatelessWidget {
  const DeviBalonu({
    super.key,
    required this.metin,
    required this.vurgu,
    this.yaziAnahtari,
    this.onTap,
  });

  final String metin;
  final Color vurgu;
  final GlobalKey<DaktiloYaziState>? yaziAnahtari;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: _BalonKuyrugu(),
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(builder: (context, c) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: c.maxWidth,
                child: DaktiloYazi(
                  key: yaziAnahtari,
                  metin: metin,
                  stil: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15.5,
                    height: 1.38,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2430),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BalonKuyrugu extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.5;
    final p = Path()
      ..moveTo(0, y)
      ..lineTo(12, y - 9)
      ..lineTo(12, y + 9)
      ..close();
    canvas.drawPath(p, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _BalonKuyrugu old) => false;
}

/// Scratch'in kendi yesil bayrak simgesi (SVG yolu), dairesel zeminde.
class YesilBayrak extends StatelessWidget {
  const YesilBayrak({super.key, this.boyut = 22});
  final double boyut;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(boyut),
        painter: _BayrakBoyaci(),
      );
}

class _BayrakBoyaci extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final o = size.width / 24;
    scratchIkonCiz(canvas, ScratchIkon.bayrak, Offset.zero, o);
  }

  @override
  bool shouldRepaint(covariant _BayrakBoyaci old) => false;
}

/// Kesikli, yuvarlak koseli kutu: blogun oturacagi bos yer.
class KesikliYuva extends StatelessWidget {
  const KesikliYuva({
    super.key,
    required this.genislik,
    required this.yukseklik,
    required this.renk,
    this.parlaklik = 1,
  });

  final double genislik;
  final double yukseklik;
  final Color renk;
  final double parlaklik;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(genislik, yukseklik),
        painter: _KesikliBoyaci(renk, parlaklik),
      );
}

class _KesikliBoyaci extends CustomPainter {
  _KesikliBoyaci(this.renk, this.parlaklik);
  final Color renk;
  final double parlaklik;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
        Offset.zero & size, Radius.circular(size.height * 0.18));
    canvas.drawRRect(
        r, Paint()..color = renk.withValues(alpha: 0.07 + 0.08 * parlaklik));
    final yol = Path()..addRRect(r);
    final kalem = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = renk.withValues(alpha: 0.45 + 0.45 * parlaklik);
    for (final m in yol.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 7), kalem);
        d += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KesikliBoyaci old) =>
      old.renk != renk || old.parlaklik != parlaklik;
}

/// Ustteki "Atla" hapi.
class AtlaDugmesi extends StatelessWidget {
  const AtlaDugmesi({super.key, required this.etiket, required this.onTap});
  final String etiket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: etiket,
      child: Material(
        color: Colors.white.withValues(alpha: 0.22),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40, minWidth: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ExcludeSemantics(
                      child: Text(
                        etiket,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.skip_next_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
