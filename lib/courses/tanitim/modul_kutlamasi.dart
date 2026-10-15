import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/sound_service.dart';
import '../../theme.dart';
import '../../ui/appear_in.dart';
import '../../ui/motion.dart';
import '../../ui/press_button.dart';
import '../../widgets/mascot.dart';
import '../data/course_modules.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../screens/widgets/kurs_yol_haritasi.dart';
import '../screens/widgets/step_widgets.dart' show lessonLang;
import 'kurs_tanitimi.dart';

/// Modul kutlamasi "goruldu" isaretleri (cihazda, kurs + modul basina).
class ModulKutlamaDeposu {
  ModulKutlamaDeposu._();

  static String anahtar(String courseId, int modul) =>
      'modul_kutlama_goruldu_v1_${courseId}_$modul';

  static Future<bool> goruldu(String courseId, int modul) async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(anahtar(courseId, modul)) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> isaretle(String courseId, int modul) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(anahtar(courseId, modul), true);
    } catch (_) {}
  }
}

/// MODUL KUTLAMASI — bir modulun butun dersleri bitince, bir kez.
///
/// Ders bitis penceresinden sonra tam ekran: modulun kupasi ve Devi,
/// "Modul X tamamlandi", kursun yol haritasinda kac modul bittigi
/// (5/11), ve siradaki modulun kucuk bir tanitimi ("Sirada: Kalem ve
/// Cizim — ..."), ardindan dogrudan siradaki ders.
///
/// Neden ayri bir an: ders bitisi her gun oluyor; modul bitisi bir
/// donum noktasi. Iki kutlama ayni boyutta olursa ikisi de siradanlasir.
///
/// Kurs bittiginde gosterilmiyor: o an kapanis toreninin
/// (KursKapanisEkrani).
class ModulKutlamaEkrani extends StatefulWidget {
  const ModulKutlamaEkrani({
    super.key,
    required this.course,
    required this.modulNo,
    required this.biten,
    this.sonrakiDers,
    this.onSonrakiDers,
    this.tekrar = false,
  });

  final Course course;

  /// Biten modulun sirasi (0'dan).
  final int modulNo;

  /// Bitirilen ders kimlikleri (yol haritasi ve sayac icin).
  final Set<String> biten;

  /// Siradaki ders (cogu zaman siradaki modulun ilk dersi). Yoksa ya da
  /// kilitliyse null; o zaman yalnizca "Listeye don" var.
  final InteractiveLesson? sonrakiDers;

  /// "Siradaki ders"e basilinca. Verilmezse dugme yok.
  final VoidCallback? onSonrakiDers;

  /// Isaret yazilmiyor (onizleme / test).
  final bool tekrar;

  /// [lessonId] dersi bitince bir modul kutlamasi gerekiyor mu?
  /// Gerekiyorsa modulun sirasini, gerekmiyorsa null dondurur.
  ///
  /// Kosullar: dersin modulunun BUTUN dersleri bitmis, kurs bitmemis
  /// (o an kapanis toreninin), ve bu modulun kutlamasi daha once
  /// gosterilmemis. Modulun "son dersi" degil "butun dersleri" — cocuk
  /// dersleri sirasiz yapmis olabilir; kutlama, eksik kalan son ders
  /// bitince geliyor.
  static Future<int?> gosterilmeli(
      String courseId, String lessonId, Set<String> biten) async {
    final moduller = CourseModules.forCourse(courseId);
    final m = moduller.indexWhere((x) => x.lessons.any((l) => l.id == lessonId));
    if (m < 0) return null;
    if (!moduller[m].lessons.every((l) => biten.contains(l.id))) return null;
    if (moduller.every((x) => x.lessons.every((l) => biten.contains(l.id)))) {
      return null;
    }
    if (await ModulKutlamaDeposu.goruldu(courseId, m)) return null;
    return m;
  }

  @override
  State<ModulKutlamaEkrani> createState() => _ModulKutlamaEkraniState();
}

class _ModulKutlamaEkraniState extends State<ModulKutlamaEkrani> {
  late final ConfettiController _konfeti =
      ConfettiController(duration: const Duration(milliseconds: 1000));

  late final List<CourseModule> _moduller =
      CourseModules.forCourse(widget.course.id);

  CourseModule get _modul => _moduller[widget.modulNo];

  @override
  void initState() {
    super.initState();
    if (!widget.tekrar) {
      ModulKutlamaDeposu.isaretle(widget.course.id, widget.modulNo);
    }
    SoundService.playBuyukBasari();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !Motion.reduced(context)) _konfeti.play();
    });
  }

  @override
  void dispose() {
    _konfeti.dispose();
    super.dispose();
  }

  String _t(String lang, String tr, String en, String de, String es) =>
      tanitimMetni(lang, tr, en, de, es);

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final c = widget.course;
    final kisa = MediaQuery.sizeOf(context).height < 640;
    final no = widget.modulNo + 1;
    final toplam = _moduller.length;
    final bitenModul = KursYolHaritasi.bitenModul(_moduller, widget.biten);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: c.primaryColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.08), c.primaryColor),
                c.secondaryColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          key: const ValueKey('modul_kutlama_kapat'),
                          tooltip:
                              _t(lang, 'Kapat', 'Close', 'Schließen', 'Cerrar'),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      _kahraman(kisa),
                      SizedBox(height: kisa ? 8 : 14),
                      AppearIn(
                        child: Text(
                          _t(lang, 'Modül $no tamamlandı!',
                              'Module $no complete!', 'Modul $no geschafft!',
                              '¡Módulo $no completado!'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: kisa ? 25 : 29,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppearIn(
                        delay: const Duration(milliseconds: 80),
                        child: Text(
                          _modul.titleFor(lang),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                      SizedBox(height: kisa ? 12 : 18),
                      AppearIn(
                        delay: const Duration(milliseconds: 160),
                        child: _ilerlemeKarti(lang, bitenModul, toplam),
                      ),
                      SizedBox(height: kisa ? 14 : 20),
                      if (widget.sonrakiDers != null &&
                          widget.onSonrakiDers != null)
                        PressButton(
                          key: const ValueKey('modul_sonraki_ders'),
                          ustYazi: _t(lang, 'SIRADAKİ DERS', 'NEXT LESSON',
                              'NÄCHSTE LEKTION', 'SIGUIENTE LECCIÓN'),
                          label: widget.sonrakiDers!.titleFor(lang),
                          icon: Icons.arrow_forward_rounded,
                          color: Colors.white,
                          foreground: c.primaryColor,
                          height: 58,
                          onPressed: widget.onSonrakiDers,
                        ),
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton(
                          key: const ValueKey('modul_listeye_don'),
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white),
                          child: Text(
                            _t(lang, 'Listeye dön', 'Back to the list',
                                'Zurück zur Liste', 'Volver a la lista'),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: IgnorePointer(
                  child: ConfettiWidget(
                    confettiController: _konfeti,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 14,
                    maxBlastForce: 22,
                    minBlastForce: 8,
                    gravity: 0.24,
                    colors: [
                      Colors.white,
                      const Color(0xFFFFD54F),
                      AppTheme.successGreen,
                      c.secondaryColor,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kupa (modulun simgesiyle) ve yaninda Devi.
  Widget _kahraman(bool kisa) {
    final boy = kisa ? 120.0 : 150.0;
    final lang = lessonLang(context);
    final kupa = ModulKupasi(
      no: widget.modulNo + 1,
      etiket: _t(lang, 'MODÜL', 'MODULE', 'MODUL', 'MÓDULO'),
      boyut: boy,
      renk: const Color(0xFF4A3FC9),
      renk2: const Color(0xFF7C6CF2),
    );
    final azalt = Motion.reduced(context);
    return SizedBox(
      height: boy + 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          azalt
              ? kupa
              : TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.3, end: 1),
                  duration: Motion.extraLong2,
                  curve: Motion.overshoot,
                  builder: (context, v, child) => Transform.scale(
                    scale: v,
                    child: Transform.rotate(
                        angle: (1 - v) * -0.5, child: child),
                  ),
                  child: kupa,
                ),
          const SizedBox(width: 4),
          Mascot(
            size: boy * 0.78,
            mood: MascotMood.happy,
            showShadow: false,
          ),
        ],
      ),
    );
  }

  Widget _beyazKart({required Widget child, Key? key}) => Container(
        key: key,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
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
        child: child,
      );

  Widget _ilerlemeKarti(String lang, int biten, int toplam) {
    final c = widget.course;
    return _beyazKart(
      key: const ValueKey('modul_ilerleme_karti'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.map_rounded, color: c.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _t(lang, 'Yolculuğun', 'Your journey', 'Deine Reise',
                      'Tu viaje'),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: Color(0xFF5B6070),
                  ),
                ),
              ),
              Text(
                _t(lang, '$biten/$toplam modül', '$biten/$toplam modules',
                    '$biten/$toplam Module', '$biten/$toplam módulos'),
                key: const ValueKey('modul_sayaci'),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: c.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          KursYolHaritasi(
            moduller: _moduller,
            biten: widget.biten,
            renk: c.primaryColor,
            renk2: c.secondaryColor,
            lang: lang,
            kompakt: true,
            yeniBiten: widget.modulNo,
          ),
        ],
      ),
    );
  }
}

/// Modul rozeti: altin cerceveli altigen amblem, ustunde uc yildiz,
/// ortasinda buyuk modul numarasi, altta "MODUL" kurdelesi. Bir kez
/// uzerinden parlama geciyor. Tamamen kendi cizimimiz (emoji yok; her
/// cihazda ayni gorunur).
class ModulKupasi extends StatefulWidget {
  const ModulKupasi({
    super.key,
    required this.no,
    this.etiket = 'MODÜL',
    this.boyut = 140,
    this.renk = const Color(0xFF5B4BDB),
    this.renk2 = const Color(0xFF2E86DE),
  });

  final int no;
  final String etiket;
  final double boyut;
  final Color renk;
  final Color renk2;

  @override
  State<ModulKupasi> createState() => _ModulKupasiState();
}

class _ModulKupasiState extends State<ModulKupasi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _parilti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_parilti.isAnimating && _parilti.value == 0) {
      if (Motion.reduced(context)) {
        _parilti.value = 1;
      } else {
        Future.delayed(const Duration(milliseconds: 650), () {
          if (mounted) _parilti.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _parilti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.boyut;
    return RepaintBoundary(
      child: SizedBox(
        width: b,
        height: b,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _parilti,
                builder: (context, _) => CustomPaint(
                  painter: _AmblemBoyaci(
                    renk: widget.renk,
                    renk2: widget.renk2,
                    parilti: _parilti.value,
                  ),
                ),
              ),
            ),
            // Numara (altigenin ortasi).
            Align(
              alignment: const Alignment(0, -0.06),
              child: Text(
                '${widget.no}',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: b * 0.30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      offset: Offset(0, b * 0.015),
                      blurRadius: b * 0.02,
                    ),
                  ],
                ),
              ),
            ),
            // Kurdele yazisi.
            Align(
              alignment: const Alignment(0, 0.39),
              child: Text(
                widget.etiket,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: b * 0.085,
                  fontWeight: FontWeight.w900,
                  letterSpacing: b * 0.012,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmblemBoyaci extends CustomPainter {
  _AmblemBoyaci({
    required this.renk,
    required this.renk2,
    required this.parilti,
  });

  final Color renk;
  final Color renk2;
  final double parilti;

  static const _altin1 = Color(0xFFFFE89A);
  static const _altin2 = Color(0xFFFFC233);
  static const _altin3 = Color(0xFFE08A00);

  Path _altigen(Offset m, double r) {
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = -math.pi / 2 + i * math.pi / 3;
      final n = m + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? p.moveTo(n.dx, n.dy) : p.lineTo(n.dx, n.dy);
    }
    return p..close();
  }

  Path _yildiz(Offset m, double r) {
    final p = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final rr = i.isEven ? r : r * 0.46;
      final n = m + Offset(math.cos(a) * rr, math.sin(a) * rr);
      i == 0 ? p.moveTo(n.dx, n.dy) : p.lineTo(n.dx, n.dy);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final m = Offset(w / 2, h * 0.47);
    final r = w * 0.36;

    // Arkadaki yumusak hale.
    canvas.drawCircle(
      m,
      r * 1.32,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: m, radius: r * 1.32)),
    );

    // Golge.
    canvas.drawPath(
      _altigen(m + Offset(0, r * 0.07), r),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.08),
    );

    // Altin cerceve (dis altigen) + ince koyu kenar.
    final dis = _altigen(m, r);
    final kutu = Rect.fromCircle(center: m, radius: r);
    canvas.drawPath(
      dis,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_altin1, _altin2, _altin3],
          stops: [0, 0.5, 1],
        ).createShader(kutu),
    );
    canvas.drawPath(
      dis,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03
        ..color = _altin3.withValues(alpha: 0.8),
    );

    // Ic altigen: kursun renkleri, ustte hafif parlak bant.
    final ic = _altigen(m, r * 0.8);
    final icKutu = Rect.fromCircle(center: m, radius: r * 0.8);
    canvas.drawPath(
      ic,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [renk2, renk],
        ).createShader(icKutu),
    );
    canvas.save();
    canvas.clipPath(ic);
    canvas.drawOval(
      Rect.fromCenter(
          center: m - Offset(0, r * 0.62), width: r * 2.2, height: r * 1.0),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
    // Gecen parilti (bir kez).
    if (parilti > 0 && parilti < 1) {
      final x = m.dx - r * 1.6 + parilti * r * 3.2;
      final bant = Path()
        ..moveTo(x - r * 0.18, m.dy - r)
        ..lineTo(x + r * 0.10, m.dy - r)
        ..lineTo(x - r * 0.30, m.dy + r)
        ..lineTo(x - r * 0.58, m.dy + r)
        ..close();
      canvas.drawPath(
          bant, Paint()..color = Colors.white.withValues(alpha: 0.38));
    }
    canvas.restore();
    canvas.drawPath(
      ic,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.025
        ..color = Colors.white.withValues(alpha: 0.55),
    );

    // Ustte uc yildiz (ortadaki buyuk).
    final yildizBoya = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_altin1, _altin2],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.3));
    final kenar = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.025
      ..strokeJoin = StrokeJoin.round
      ..color = _altin3;
    for (final y in [
      (Offset(m.dx - r * 0.55, m.dy - r * 0.98), r * 0.15),
      (Offset(m.dx + r * 0.55, m.dy - r * 0.98), r * 0.15),
      (Offset(m.dx, m.dy - r * 1.1), r * 0.21),
    ]) {
      final p = _yildiz(y.$1, y.$2);
      canvas.drawPath(p, yildizBoya);
      canvas.drawPath(p, kenar);
    }

    // Kurdele: altigenin altini kesen serit, uclari katlanmis.
    final ky = m.dy + r * 0.62;
    final kh = r * 0.30;
    final ust = ky - kh / 2;
    final alt = ky + kh / 2;
    const koyu = Color(0xFFB71C1C);
    const acik = Color(0xFFE53935);
    for (final s in [-1.0, 1.0]) {
      final uc = Path()
        ..moveTo(m.dx + s * r * 0.86, ust + kh * 0.25)
        ..lineTo(m.dx + s * r * 1.22, ust + kh * 0.25)
        ..lineTo(m.dx + s * r * 1.10, ky + kh * 0.25)
        ..lineTo(m.dx + s * r * 1.22, alt + kh * 0.25)
        ..lineTo(m.dx + s * r * 0.86, alt + kh * 0.25)
        ..close();
      canvas.drawPath(uc, Paint()..color = koyu);
    }
    final serit = RRect.fromRectAndRadius(
      Rect.fromLTRB(m.dx - r * 0.95, ust, m.dx + r * 0.95, alt),
      Radius.circular(kh * 0.18),
    );
    canvas.drawRRect(
      serit.shift(Offset(0, r * 0.03)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRRect(
      serit,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [acik, koyu],
        ).createShader(serit.outerRect),
    );
  }

  @override
  bool shouldRepaint(covariant _AmblemBoyaci old) =>
      old.parilti != parilti || old.renk != renk || old.renk2 != renk2;
}
