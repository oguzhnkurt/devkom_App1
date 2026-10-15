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

  CourseModule? get _sonrakiModul {
    // Bitmemis ILK modul (yol haritasindaki "su an" dugumu): cocuk
    // sirasiz gittiyse siradaki modul bir sonraki indeks olmayabilir.
    for (var i = 0; i < _moduller.length; i++) {
      final m = _moduller[i];
      if (!m.lessons.every((l) => widget.biten.contains(l.id))) return m;
    }
    return null;
  }

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
    final sonraki = _sonrakiModul;

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
                          '${_modul.emoji}  ${_modul.titleFor(lang)}',
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
                      if (sonraki != null) ...[
                        const SizedBox(height: 12),
                        AppearIn(
                          delay: const Duration(milliseconds: 240),
                          child: _siradakiKarti(lang, sonraki),
                        ),
                      ],
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
    final kupa = ModulKupasi(
      emoji: _modul.emoji,
      no: widget.modulNo + 1,
      boyut: boy,
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

  Widget _siradakiKarti(String lang, CourseModule m) {
    final c = widget.course;
    return _beyazKart(
      key: const ValueKey('modul_siradaki'),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(m.emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(lang, 'SIRADA', 'UP NEXT', 'ALS NÄCHSTES', 'A CONTINUACIÓN'),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: c.primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${m.titleFor(lang)} — ${m.descriptionFor(lang)}',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2430),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modulun kupasi: altin madalya, ortasinda modulun simgesi, altinda
/// kurdele ve modul numarasi. Kendi cizimimiz (CustomPainter + emoji).
class ModulKupasi extends StatelessWidget {
  const ModulKupasi({
    super.key,
    required this.emoji,
    required this.no,
    this.boyut = 140,
  });

  final String emoji;
  final int no;
  final double boyut;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boyut,
      height: boyut,
      child: CustomPaint(
        painter: _KupaBoyaci(),
        child: Align(
          alignment: const Alignment(0, -0.18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: boyut * 0.24)),
              Text(
                '$no',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: boyut * 0.12,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF8A5A00),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KupaBoyaci extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final merkez = Offset(w / 2, h * 0.42);
    final r = w * 0.34;

    // Kurdeleler (madalyanin arkasinda, asagi dogru).
    for (final s in [-1.0, 1.0]) {
      final p = Path()
        ..moveTo(merkez.dx + s * r * 0.35, merkez.dy + r * 0.6)
        ..lineTo(merkez.dx + s * r * 0.95, h * 0.98)
        ..lineTo(merkez.dx + s * r * 0.55, h * 0.88)
        ..lineTo(merkez.dx + s * r * 0.2, h * 0.98)
        ..lineTo(merkez.dx - s * r * 0.05, merkez.dy + r * 0.6)
        ..close();
      canvas.drawPath(
          p, Paint()..color = s < 0 ? const Color(0xFFE53935) : const Color(0xFF1E88E5));
    }

    // Isinlar.
    final isin = Paint()..color = Colors.white.withValues(alpha: 0.28);
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final p = Path()
        ..moveTo(merkez.dx, merkez.dy)
        ..lineTo(merkez.dx + math.cos(a - 0.12) * r * 1.45,
            merkez.dy + math.sin(a - 0.12) * r * 1.45)
        ..lineTo(merkez.dx + math.cos(a + 0.12) * r * 1.45,
            merkez.dy + math.sin(a + 0.12) * r * 1.45)
        ..close();
      canvas.drawPath(p, isin);
    }

    // Madalya: altin dis halka, acik ic daire.
    canvas.drawCircle(
        merkez + const Offset(0, 4),
        r,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(
      merkez,
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFF57F17)],
        ).createShader(Rect.fromCircle(center: merkez, radius: r)),
    );
    canvas.drawCircle(merkez, r * 0.8, Paint()..color = const Color(0xFFFFF4D1));
    canvas.drawCircle(
        merkez,
        r * 0.8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFFC107));
  }

  @override
  bool shouldRepaint(covariant _KupaBoyaci oldDelegate) => false;
}
