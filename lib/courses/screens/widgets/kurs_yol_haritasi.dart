import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../../ui/motion.dart';
import '../../../utils/lang.dart';
import '../../../widgets/mascot.dart';
import '../../data/course_modules.dart';

/// Bir modulun yol haritasindaki hali.
enum ModulDurumu {
  /// Butun dersleri bitti: parlayan dolu dugum, tik.
  tamam,

  /// Cocugun su an bulundugu modul (bitmemis ILK modul): nabiz atan
  /// halka, icinde Devi.
  simdiki,

  /// Henuz sirasi gelmedi: soluk dugum. KILITLI DEGIL — dersler hicbir
  /// kursta sirayla kilitlenmiyor; soluk yalnizca "daha sonra" demek.
  sirada,
}

/// KURSUN YOL HARITASI — modulleri birbirine bagli dugumler olarak
/// gosteren yatay, kivrimli serit.
///
/// Kurs sayfasinda modul sekmelerinin ustunde; modul kutlamasinda
/// "5/11 modul" ilerlemesinin kendisi. Cocuk kursu bir YOL olarak
/// goruyor: nereden geldi, neredesin (Devi orada), sirada ne var.
///
/// Performans: dugumler sabit; yalnizca SU ANKI dugumun nabzi bir
/// AnimatedBuilder ile ciziliyor, butun serit RepaintBoundary icinde.
/// Hareket azaltilmisken nabiz yok.
class KursYolHaritasi extends StatefulWidget {
  const KursYolHaritasi({
    super.key,
    required this.moduller,
    required this.biten,
    required this.renk,
    required this.renk2,
    required this.lang,
    this.secili,
    this.onSec,
    this.kompakt = false,
    this.koyu = false,
    this.yeniBiten,
  });

  final List<CourseModule> moduller;

  /// Bitirilen ders kimlikleri.
  final Set<String> biten;

  final Color renk;
  final Color renk2;
  final String lang;

  /// Kurs sayfasinda secili modul sekmesi (dugumun altinda cizgi).
  final int? secili;

  /// Dugume dokununca (kurs sayfasinda o modulun dersleri acilir).
  final ValueChanged<int>? onSec;

  /// Kutlama ekranindaki kucuk hali: daha kucuk dugum, tek satir etiket.
  final bool kompakt;

  final bool koyu;

  /// Az once biten modul: kutlamada bir kez "parlayarak" giriyor.
  final int? yeniBiten;

  /// Modullerin durumu. Ayri bir islev: ekran goruntusu olmadan
  /// sinanabilsin.
  static List<ModulDurumu> durumlar(
      List<CourseModule> moduller, Set<String> biten) {
    var simdikiVerildi = false;
    final out = <ModulDurumu>[];
    for (final m in moduller) {
      final bitti =
          m.lessons.isNotEmpty && m.lessons.every((l) => biten.contains(l.id));
      if (bitti) {
        out.add(ModulDurumu.tamam);
      } else if (!simdikiVerildi) {
        simdikiVerildi = true;
        out.add(ModulDurumu.simdiki);
      } else {
        out.add(ModulDurumu.sirada);
      }
    }
    return out;
  }

  /// Bitmis modul sayisi.
  static int bitenModul(List<CourseModule> moduller, Set<String> biten) =>
      durumlar(moduller, biten).where((d) => d == ModulDurumu.tamam).length;

  @override
  State<KursYolHaritasi> createState() => _KursYolHaritasiState();
}

class _KursYolHaritasiState extends State<KursYolHaritasi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _nabiz = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300));
  final ScrollController _kaydirma = ScrollController();
  bool _kaydirildi = false;

  double get _aralik => widget.kompakt ? 70 : 96;
  double get _cap => widget.kompakt ? 34 : 48;
  double get _zikzak => widget.kompakt ? 10 : 16;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _nabiz.stop();
      _nabiz.value = 0.5;
    } else if (!_nabiz.isAnimating) {
      _nabiz.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _nabiz.dispose();
    _kaydirma.dispose();
    super.dispose();
  }

  /// Son cizimdeki genislik (secim degisince kaydirmak icin).
  double _genislik = 0;

  /// Ilk cizimden sonra secili (yoksa su anki) dugum ekranin ortasina
  /// gelsin.
  void _ortala(int hedef, double genislik) {
    _genislik = genislik;
    if (_kaydirildi) return;
    _kaydirildi = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _kaydir(hedef));
  }

  void _kaydir(int hedef, {bool yumusak = false}) {
    if (!mounted || !_kaydirma.hasClients) return;
    final p = _kaydirma.position;
    final x = (16 + hedef * _aralik + _aralik / 2 - _genislik / 2)
        .clamp(p.minScrollExtent, p.maxScrollExtent);
    if (yumusak && !Motion.reduced(context)) {
      _kaydirma.animateTo(x,
          duration: Motion.long2, curve: Motion.emphasized);
    } else {
      _kaydirma.jumpTo(x);
    }
  }

  @override
  void didUpdateWidget(KursYolHaritasi old) {
    super.didUpdateWidget(old);
    // Secim degisti: secili dugum ortaya kaysin.
    final s = widget.secili;
    if (s != null && s != old.secili) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _kaydir(s, yumusak: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final durumlar = KursYolHaritasi.durumlar(widget.moduller, widget.biten);
    final n = durumlar.length;
    final simdiki = durumlar.indexOf(ModulDurumu.simdiki);
    final etiketH = widget.kompakt ? 16.0 : 34.0;
    final yukseklik = _cap + _zikzak + 10 + etiketH + 6;
    final genislik = 32 + n * _aralik;

    return RepaintBoundary(
      child: SizedBox(
        height: yukseklik,
        child: LayoutBuilder(builder: (context, c) {
          _ortala(widget.secili ?? (simdiki < 0 ? n - 1 : simdiki),
              c.maxWidth);
          return SingleChildScrollView(
            controller: _kaydirma,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: math.max(genislik, c.maxWidth),
              height: yukseklik,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _YolBoyaci(
                        merkezler: [for (var i = 0; i < n; i++) _merkez(i)],
                        durumlar: durumlar,
                        renk: widget.renk,
                        soluk: widget.koyu
                            ? Colors.white24
                            : const Color(0xFFD5DAE3),
                        kalinlik: widget.kompakt ? 4 : 6,
                      ),
                    ),
                  ),
                  for (var i = 0; i < n; i++) _dugum(i, durumlar[i], etiketH),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Offset _merkez(int i) => Offset(
        16 + i * _aralik + _aralik / 2,
        5 + _cap / 2 + (i.isOdd ? _zikzak : 0),
      );

  Widget _dugum(int i, ModulDurumu d, double etiketH) {
    final m = widget.moduller[i];
    final merkez = _merkez(i);
    final cap = _cap;
    final secili = widget.secili == i;
    final yaziRengi = widget.koyu ? Colors.white : const Color(0xFF1F2430);
    final baslik = m.titleFor(widget.lang);
    final durumAdi = switch (d) {
      ModulDurumu.tamam => AppLang.pick(widget.lang,
          tr: 'tamamlandı', en: 'completed', de: 'geschafft', es: 'completado'),
      ModulDurumu.simdiki => AppLang.pick(widget.lang,
          tr: 'şu an buradasın',
          en: 'you are here',
          de: 'du bist hier',
          es: 'estás aquí'),
      ModulDurumu.sirada => AppLang.pick(widget.lang,
          tr: 'sırada', en: 'coming up', de: 'als Nächstes', es: 'próximo'),
    };

    Widget govde;
    switch (d) {
      case ModulDurumu.tamam:
        final parla = widget.yeniBiten == i;
        govde = Container(
          width: cap,
          height: cap,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.renk, widget.renk2],
            ),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: widget.renk.withValues(alpha: parla ? 0.75 : 0.45),
                blurRadius: parla ? 18 : 10,
                spreadRadius: parla ? 3 : 1,
              ),
            ],
          ),
          child: Icon(Icons.check_rounded,
              color: Colors.white, size: cap * 0.56),
        );
        if (parla && !Motion.reduced(context)) {
          govde = TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.4, end: 1),
            duration: Motion.extraLong2,
            curve: Motion.overshoot,
            builder: (context, v, child) =>
                Transform.scale(scale: v, child: child),
            child: govde,
          );
        }
      case ModulDurumu.simdiki:
        final ic = Container(
          width: cap,
          height: cap,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: widget.renk, width: 3),
          ),
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: Image.asset(
              Mascot.durgunGorsel,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              excludeFromSemantics: true,
              errorBuilder: (_, __, ___) =>
                  Text(m.emoji, style: TextStyle(fontSize: cap * 0.45)),
            ),
          ),
        );
        govde = AnimatedBuilder(
          animation: _nabiz,
          builder: (context, child) {
            final t = _nabiz.value;
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: cap + 10 + 8 * t,
                  height: cap + 10 + 8 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.renk.withValues(alpha: 0.10 + 0.14 * (1 - t)),
                  ),
                ),
                child!,
              ],
            );
          },
          child: ic,
        );
      case ModulDurumu.sirada:
        govde = Container(
          width: cap,
          height: cap,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.koyu ? const Color(0xFF2A2A3A) : const Color(0xFFF1F3F7),
            border: Border.all(
                color: widget.koyu ? Colors.white24 : const Color(0xFFD5DAE3),
                width: 2),
          ),
          child: Opacity(
            opacity: 0.55,
            child: Text(m.emoji, style: TextStyle(fontSize: cap * 0.42)),
          ),
        );
    }

    // SECILI AMA SU ANKI DEGIL: dugumun cevresinde kursun renginde bir
    // halka ve altinda kucuk bir ok. Su anki dugum (Devi) kendi nabziyla
    // zaten belli; ikisi farkliyken cocuk hangisinin derslerine
    // baktigini halkadan goruyor.
    if (secili && d != ModulDurumu.simdiki && widget.onSec != null) {
      govde = Container(
        key: ValueKey('yol_secili_$i'),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: widget.renk, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: widget.renk.withValues(alpha: 0.28),
              blurRadius: 10,
            ),
          ],
        ),
        child: govde,
      );
    }

    final etiket = widget.kompakt
        ? Text(
            '${i + 1}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: yaziRengi.withValues(
                  alpha: d == ModulDurumu.sirada ? 0.5 : 0.9),
            ),
          )
        : Text(
            baslik,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              height: 1.15,
              fontWeight: d == ModulDurumu.simdiki || secili
                  ? FontWeight.w900
                  : FontWeight.w700,
              color: secili
                  ? (widget.koyu ? Colors.white : yaziRengi)
                  : yaziRengi.withValues(
                      alpha: d == ModulDurumu.sirada ? 0.5 : 0.92),
              decoration: secili ? TextDecoration.underline : null,
              decorationColor: widget.renk,
              decorationThickness: 2,
            ),
          );

    return Positioned(
      left: merkez.dx - _aralik / 2,
      top: merkez.dy - cap / 2 - 5,
      width: _aralik,
      child: Semantics(
        button: widget.onSec != null,
        label: '${i + 1}. $baslik — $durumAdi',
        child: GestureDetector(
          key: ValueKey('yol_${d.name}_$i'),
          behavior: HitTestBehavior.opaque,
          onTap: widget.onSec == null ? null : () => widget.onSec!(i),
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: cap + 10,
                  child: OverflowBox(
                    maxWidth: cap + 20,
                    maxHeight: cap + 20,
                    child: Center(child: govde),
                  ),
                ),
                SizedBox(height: etiketH, child: etiket),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dugumleri birlestiren yol: bitmis kisimlar kursun renginde dolu,
/// gerisi soluk kesikli.
class _YolBoyaci extends CustomPainter {
  _YolBoyaci({
    required this.merkezler,
    required this.durumlar,
    required this.renk,
    required this.soluk,
    required this.kalinlik,
  });

  final List<Offset> merkezler;
  final List<ModulDurumu> durumlar;
  final Color renk;
  final Color soluk;
  final double kalinlik;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i + 1 < merkezler.length; i++) {
      final a = merkezler[i];
      final b = merkezler[i + 1];
      final dolu = durumlar[i] == ModulDurumu.tamam;
      final yol = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo((a.dx + b.dx) / 2, a.dy, (a.dx + b.dx) / 2, b.dy, b.dx, b.dy);
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = kalinlik
        ..color = dolu ? renk : soluk;
      if (dolu) {
        canvas.drawPath(yol, p);
      } else {
        // Kesikli: yolun uzunlugu boyunca kisa parcalar.
        for (final m in yol.computeMetrics()) {
          var t = 0.0;
          while (t < m.length) {
            canvas.drawPath(
                m.extractPath(t, math.min(t + kalinlik * 1.4, m.length)), p);
            t += kalinlik * 3;
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _YolBoyaci old) =>
      old.renk != renk ||
      old.soluk != soluk ||
      old.kalinlik != kalinlik ||
      !_esit(old.durumlar, durumlar) ||
      !_esit(old.merkezler, merkezler);

  static bool _esit<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
