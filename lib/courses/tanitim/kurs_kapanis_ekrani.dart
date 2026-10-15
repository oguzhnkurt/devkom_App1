import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/sound_service.dart';
import '../../theme.dart';
import '../../ui/appear_in.dart';
import '../../ui/motion.dart';
import '../../ui/press_button.dart';
import '../../widgets/mascot.dart';
import '../models/course_model.dart';
import '../screens/interactive_course_screen.dart';
import '../screens/widgets/step_widgets.dart' show lessonLang, lessonLangRead;
import 'kurs_tanitimi.dart';
import 'sertifika_paylasimi.dart';

/// KURSUN KAPANIS TORENI — son ders bitince bir kez.
///
/// Konfeti, Devi'nin tebrigi, gercek veriden kisa bir ozet (ders, farkli
/// blok, XP), cocugun adiyla bir sertifika (PDF / galeri / Instagram / TikTok,
/// hepsi ebeveyn kapisinin arkasinda),
/// bir rozet ve ogrenme yolundaki siradaki kursun karti.
///
/// Uydurma sayi yok: ozet [KursOzeti] ile ders verisinden ve cocugun
/// bitirdigi derslerden hesaplaniyor.
class KursKapanisEkrani extends StatefulWidget {
  const KursKapanisEkrani({
    super.key,
    required this.course,
    required this.tamamlanan,
    this.ad,
    this.tarih,
    this.tekrar = false,
  });

  final Course course;

  /// Cocugun bitirdigi derslerin kimlikleri (ozet buradan).
  final Set<String> tamamlanan;

  /// Sertifikadaki ad. Bossa dile gore genel bir hitap.
  final String? ad;

  /// Sertifika tarihi (verilmezse bugun).
  final DateTime? tarih;

  /// Kurs sayfasindan tekrar izleniyor: isaret yazilmiyor.
  final bool tekrar;

  /// Kapanis ilk kez mi gosterilmeli? Kurs acik + butun dersler bitti +
  /// daha once gosterilmedi.
  static Future<bool> gosterilmeli(
      String courseId, Set<String> tamamlanan) async {
    if (!KursTanitimi.acik(courseId)) return false;
    if (!KursOzeti.hesapla(courseId, tamamlanan).kursBitti) return false;
    return !(await KursTanitimDeposu.kapanisGoruldu(courseId));
  }

  /// Saglayicidan adi ve biten dersleri okuyup ekrani kurar.
  static Widget kur(BuildContext context, Course course,
      {bool tekrar = false}) {
    Set<String> biten = const {};
    String? ad;
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      biten = auth.tamamlananDersler;
      ad = auth.currentUser?.displayName;
    } on ProviderNotFoundException {
      // Saglayicisiz agac: bos ozet, genel hitap.
    }
    return KursKapanisEkrani(
        course: course, tamamlanan: biten, ad: ad, tekrar: tekrar);
  }

  @override
  State<KursKapanisEkrani> createState() => _KursKapanisEkraniState();
}

class _KursKapanisEkraniState extends State<KursKapanisEkrani> {
  late final ConfettiController _konfeti =
      ConfettiController(duration: const Duration(milliseconds: 1200));
  late final KursOzeti _ozet =
      KursOzeti.hesapla(widget.course.id, widget.tamamlanan);
  late final DateTime _tarih = widget.tarih ?? DateTime.now();
  bool _paylasiliyor = false;

  @override
  void initState() {
    super.initState();
    if (!widget.tekrar) {
      KursTanitimDeposu.kapanisIsaretle(widget.course.id);
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

  String _ad(String lang) {
    final a = widget.ad?.trim() ?? '';
    if (a.isNotEmpty) return a;
    return _t(lang, 'Genç Kodcu', 'Young Coder', 'Junges Code-Talent',
        'Joven programador');
  }

  // ------------------------------------------------------------------
  // Kaydet / paylas — secenekler ve ebeveyn kapisi sertifika_paylasimi.dart
  // ------------------------------------------------------------------

  SertifikaVerisi _veri(String lang) => SertifikaVerisi(
        course: widget.course,
        ad: _ad(lang),
        tarih: _tarih,
        dersSayisi: _ozet.bitenDers,
        lang: lang,
      );

  Future<void> _secenekler() async {
    if (_paylasiliyor) return;
    final lang = lessonLangRead(context);
    setState(() => _paylasiliyor = true);
    try {
      await SertifikaPaylasimi.secenekleriAc(context, _veri(lang));
    } finally {
      if (mounted) setState(() => _paylasiliyor = false);
    }
  }

  void _sonrakiKursuAc(Course sonraki) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => InteractiveCourseScreen(course: sonraki),
    ));
  }

  // ------------------------------------------------------------------
  // Cizim
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final c = widget.course;
    final sonraki = KursTanitimi.sonrakiKurs(c.id);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: c.primaryColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                c.primaryColor,
                c.secondaryColor,
                Color.alphaBlend(
                    Colors.white.withValues(alpha: 0.82), c.secondaryColor),
              ],
              stops: const [0, 0.38, 0.62],
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _ust(lang)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.list(children: [
                        AppearIn(child: _kahraman(lang)),
                        const SizedBox(height: 18),
                        AppearIn(
                            delay: const Duration(milliseconds: 120),
                            child: _ozetKarti(lang)),
                        const SizedBox(height: 14),
                        AppearIn(
                            delay: const Duration(milliseconds: 220),
                            child: _rozetKarti(lang)),
                        const SizedBox(height: 18),
                        AppearIn(
                          delay: const Duration(milliseconds: 320),
                          child: _veri(lang).sertifika(),
                        ),
                        const SizedBox(height: 12),
                        PressButton(
                          key: const ValueKey('kapanis_paylas'),
                          label: _t(
                              lang,
                              'Kaydet ya da paylaş',
                              'Save or share',
                              'Speichern oder teilen',
                              'Guardar o compartir'),
                          icon: Icons.ios_share_rounded,
                          color: c.primaryColor,
                          loading: _paylasiliyor,
                          onPressed: _secenekler,
                        ),
                        if (sonraki != null) ...[
                          const SizedBox(height: 22),
                          _sonrakiKart(lang, sonraki),
                        ],
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF4A4F5C)),
                            child: Text(
                              _t(
                                  lang,
                                  'Kurs sayfasına dön',
                                  'Back to the course',
                                  'Zurück zum Kurs',
                                  'Volver al curso'),
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: IgnorePointer(
                  child: ConfettiWidget(
                    confettiController: _konfeti,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.04,
                    numberOfParticles: 14,
                    maxBlastForce: 24,
                    minBlastForce: 8,
                    gravity: 0.22,
                    colors: [
                      Colors.white,
                      const Color(0xFFFFD54F),
                      AppTheme.successGreen,
                      const Color(0xFF4C97FF),
                      const Color(0xFF9966FF),
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

  Widget _ust(String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: _t(lang, 'Kapat', 'Close', 'Schließen', 'Cerrar'),
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
        ],
      ),
    );
  }

  Widget _kahraman(String lang) {
    final ad = widget.course.nameFor(lang);
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    Colors.white.withValues(alpha: 0.42),
                    Colors.white.withValues(alpha: 0.0),
                  ]),
                ),
              ),
              const Mascot(
                  size: 128, mood: MascotMood.happy, showShadow: false),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _t(lang, 'Kursu bitirdin!', 'You finished the course!',
              'Kurs geschafft!', '¡Terminaste el curso!'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _t(
              lang,
              '$ad kursunun bütün derslerini tamamladın. '
                  'Seninle gurur duyuyorum! — Devi',
              'You completed every lesson of the $ad course. '
                  "I'm so proud of you! — Devi",
              'Du hast alle Lektionen im Kurs $ad abgeschlossen. '
                  'Ich bin so stolz auf dich! — Devi',
              'Completaste todas las lecciones del curso de $ad. '
                  '¡Estoy muy orgulloso de ti! — Devi'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 15.5,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
      ],
    );
  }

  Widget _ozetKarti(String lang) {
    Widget kutu(IconData ikon, Color renk, int sayi, String etiket, Key k) {
      return Expanded(
        child: Container(
          key: k,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: renk.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(ikon, color: renk, size: 24),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$sayi',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: renk,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Iki satirlik yer hep ayrilmis: tek satirlik etiketli
              // kutular iki satirliyla ayni boyda dursun.
              SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    etiket,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5B6070),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _beyazKart(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kartBasligi(_t(lang, 'Neler yaptın', 'What you did',
              'Das hast du geschafft', 'Lo que hiciste')),
          const SizedBox(height: 12),
          Row(
            children: [
              kutu(
                  Icons.school_rounded,
                  widget.course.primaryColor,
                  _ozet.bitenDers,
                  _t(lang, 'ders bitirdin', 'lessons finished',
                      'Lektionen geschafft', 'lecciones terminadas'),
                  const ValueKey('ozet_ders')),
              const SizedBox(width: 8),
              kutu(
                  Icons.extension_rounded,
                  const Color(0xFF4C97FF),
                  _ozet.farkliBlok,
                  _t(
                      lang,
                      'farklı blok kullandın',
                      'different blocks used',
                      'verschiedene Blöcke benutzt',
                      'bloques distintos usados'),
                  const ValueKey('ozet_blok')),
              const SizedBox(width: 8),
              kutu(
                  Icons.star_rounded,
                  const Color(0xFFF2A100),
                  _ozet.xp,
                  _t(lang, 'ders XP\'si', 'lesson XP', 'Lektions-XP',
                      'XP de lecciones'),
                  const ValueKey('ozet_xp')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rozetKarti(String lang) {
    final ad = widget.course.nameFor(lang);
    return _beyazKart(
      child: Row(
        children: [
          KursRozeti(
              renk: widget.course.primaryColor,
              renk2: widget.course.secondaryColor,
              boyut: 64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kartBasligi(_t(lang, 'Yeni rozet', 'New badge',
                    'Neues Abzeichen', 'Nueva insignia')),
                const SizedBox(height: 4),
                Text(
                  _t(lang, '$ad Mezunu', '$ad Graduate', '$ad-Absolvent',
                      'Graduado en $ad'),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2430),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _t(
                      lang,
                      'Kursun tamamını bitirenlere.',
                      'For finishing the whole course.',
                      'Für den ganzen Kurs.',
                      'Por terminar todo el curso.'),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sonrakiKart(String lang, Course s) {
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('kapanis_sonraki_kurs'),
          borderRadius: BorderRadius.circular(20),
          onTap: () => _sonrakiKursuAc(s),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [s.primaryColor, s.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: s.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(lang, 'SIRADAKİ', 'UP NEXT', 'ALS NÄCHSTES',
                            'SIGUIENTE'),
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11.5,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.nameFor(lang),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.descriptionFor(lang),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _beyazKart({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );

  Widget _kartBasligi(String m) => Text(
        m.toUpperCase(),
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 11.5,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w900,
          color: widget.course.primaryColor,
        ),
      );
}

/// Kurs rozeti: kurdeleli madalyon (vektor; emoji degil).
class KursRozeti extends StatelessWidget {
  const KursRozeti(
      {super.key, required this.renk, required this.renk2, this.boyut = 64});
  final Color renk;
  final Color renk2;
  final double boyut;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boyut,
      height: boyut,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [renk2, renk],
              ),
              boxShadow: [
                BoxShadow(
                  color: renk.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(boyut * 0.09),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.75),
                  width: boyut * 0.035),
            ),
          ),
          Icon(Icons.extension_rounded,
              color: Colors.white, size: boyut * 0.46),
        ],
      ),
    );
  }
}

/// Paylasilabilir kurs sertifikasi (yatay A oranli).
class KursSertifikasi extends StatelessWidget {
  const KursSertifikasi({
    super.key,
    required this.course,
    required this.ad,
    required this.tarih,
    required this.dersSayisi,
    required this.lang,
    this.baski = false,
  });

  final Course course;
  final String ad;
  final DateTime tarih;
  final int dersSayisi;
  final String lang;

  /// PDF / galeri icin: golge ve yuvarlak kose yok (kagit kenarina kadar).
  final bool baski;

  static const _aylar = {
    'tr': [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ],
    'en': [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ],
    'de': [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember'
    ],
    'es': [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ],
  };

  static String tarihYazisi(DateTime d, String lang) {
    final ay = (_aylar[lang] ?? _aylar['en']!)[d.month - 1];
    return switch (lang) {
      'en' => '$ay ${d.day}, ${d.year}',
      'de' => '${d.day}. $ay ${d.year}',
      'es' => '${d.day} de $ay de ${d.year}',
      _ => '${d.day} $ay ${d.year}',
    };
  }

  String _t(String tr, String en, String de, String es) =>
      tanitimMetni(lang, tr, en, de, es);

  @override
  Widget build(BuildContext context) {
    final r = course.primaryColor;
    final r2 = course.secondaryColor;
    final kurs = course.nameFor(lang);
    const koyu = Color(0xFF1F2430);

    return AspectRatio(
      aspectRatio: 1.414,
      child: LayoutBuilder(builder: (context, c) {
        // Butun olculer genislige oranli: 288 pt'lik telefonda da,
        // 3x paylasim goruntusunde de ayni duzen.
        final u = c.maxWidth / 100;
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF6),
            borderRadius: baski ? null : BorderRadius.circular(u * 3),
            boxShadow: baski
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Cerceve
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(u * 2.2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(u * 2),
                    border: Border.all(
                        color: r.withValues(alpha: 0.55), width: u * 0.45),
                  ),
                ),
              ),
              // Sol kose seridi
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: u * 1.6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [r, r2],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(u * 7, u * 5.5, u * 7, u * 5),
                child: Column(
                  children: [
                    Text(
                      'DEVEDUCATION',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: u * 3.2,
                        letterSpacing: u * 0.9,
                        fontWeight: FontWeight.w900,
                        color: r,
                      ),
                    ),
                    SizedBox(height: u * 1.2),
                    Text(
                      _t('BAŞARI SERTİFİKASI', 'CERTIFICATE OF ACHIEVEMENT',
                          'URKUNDE', 'CERTIFICADO DE LOGRO'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: u * 4.6,
                        letterSpacing: u * 0.3,
                        fontWeight: FontWeight.w900,
                        color: koyu,
                      ),
                    ),
                    const Spacer(flex: 2),
                    Text(
                      _t('Bu sertifika', 'This certifies that',
                          'Hiermit wird bestätigt, dass', 'Se certifica que'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: u * 2.9,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: u * 0.8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        ad,
                        key: const ValueKey('sertifika_ad'),
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: u * 7.4,
                          fontWeight: FontWeight.w900,
                          color: r,
                        ),
                      ),
                    ),
                    Container(
                      width: u * 30,
                      height: u * 0.35,
                      margin: EdgeInsets.symmetric(vertical: u * 1.2),
                      color: r.withValues(alpha: 0.35),
                    ),
                    Text(
                      _t(
                          '$kurs kursunun $dersSayisi dersinin tamamını bitirdiğini gösterir.',
                          'has completed all $dersSayisi lessons of the $kurs course.',
                          'alle $dersSayisi Lektionen des Kurses $kurs abgeschlossen hat.',
                          'completó las $dersSayisi lecciones del curso de $kurs.'),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: u * 3.1,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A4F5C),
                      ),
                    ),
                    const Spacer(flex: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _altSatir(
                              u,
                              _t('Tarih', 'Date', 'Datum', 'Fecha'),
                              tarihYazisi(tarih, lang),
                              CrossAxisAlignment.start),
                        ),
                        KursRozeti(renk: r, renk2: r2, boyut: u * 11),
                        Expanded(
                          child: _altSatir(
                              u,
                              _t('Kurs', 'Course', 'Kurs', 'Curso'),
                              kurs,
                              CrossAxisAlignment.end),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _altSatir(
      double u, String baslik, String deger, CrossAxisAlignment h) {
    return Column(
      crossAxisAlignment: h,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: u * 18, height: u * 0.25, color: Colors.grey.shade400),
        SizedBox(height: u * 0.8),
        Text(baslik,
            style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: u * 2.3,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500)),
        Text(deger,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: u * 2.8,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F2430))),
      ],
    );
  }
}
