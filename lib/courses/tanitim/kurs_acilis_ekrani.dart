import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/sound_service.dart';
import '../../theme.dart';
import '../../ui/motion.dart';
import '../../ui/press_button.dart';
import '../../widgets/mascot.dart';
import '../../widgets/scratch_blok.dart';
import '../models/course_model.dart';
import '../screens/widgets/step_widgets.dart' show lessonLang;
import 'kurs_tanitimi.dart';
import 'tanitim_parcalari.dart';

/// Acilis sahnesinin evreleri.
enum AcilisEvresi { selam, yerlestir, calistir, kutlama, hazir }

/// KURSUN ACILIS SAHNESI — "kursa basla"ya ilk basista bir kez.
///
/// 20-30 saniyelik bir sahne: Devi selam veriyor, bir sahne ve kod alani
/// beliriyor, cocuk TEK bir gercek Scratch blogunu yerine koyuyor, yesil
/// bayraga basiyor, kukla (Devi) yuruyor, kucuk bir kutlama ve "Hazirsin!"
/// — ardindan dogrudan 1. ders.
///
/// Kurallar:
///  * Her an atlanabilir (sag ustte "Atla"); atlamak da derse goturuyor.
///  * Yanlis yapmak diye bir sey yok: blok tek, yuva tek; dokunmak da
///    surüklemek de yerine koyuyor.
///  * Yerlesim kaymasi yok: sahne ve kod alani bastan yerinde, yalnizca
///    saydamligi aciliyor; balon ve alttaki dugme sabit yukseklikte.
///  * Hareket azaltilmisken: daktilo yok, yuruyus yok (kukla hedefe
///    aniden geciyor), konfeti yok.
///
/// Sonuc: `true` = derse gec. Geri tusuyla cikilirsa `null`.
class KursAcilisEkrani extends StatefulWidget {
  const KursAcilisEkrani({
    super.key,
    required this.course,
    required this.tanitim,
    this.tekrar = false,
  });

  final Course course;
  final KursTanitimi tanitim;

  /// Kurs sayfasindaki "Tanitimi tekrar izle": isaret degismiyor, sonda
  /// derse gecilmiyor, sayfaya donuluyor.
  final bool tekrar;

  /// Sahneyi acar. Ilk gosterimde (tekrar degilse) bittiginde ya da
  /// atlandiginda isaret kaydediliyor. `true` donerse cagiran derse
  /// gecer.
  static Future<bool> ac(BuildContext context, Course course,
      {bool tekrar = false}) async {
    final t = KursTanitimi.forCourse(course.id);
    if (t == null) return true;
    final sonuc = await Navigator.of(context).push<bool>(PageRouteBuilder(
      settings: const RouteSettings(name: 'kurs_acilis'),
      transitionDuration: Motion.medium4,
      reverseTransitionDuration: Motion.medium2,
      pageBuilder: (_, __, ___) =>
          KursAcilisEkrani(course: course, tanitim: t, tekrar: tekrar),
      transitionsBuilder: (context, a, _, child) =>
          FadeTransition(opacity: a, child: child),
    ));
    return sonuc ?? false;
  }

  @override
  State<KursAcilisEkrani> createState() => KursAcilisEkraniState();
}

class KursAcilisEkraniState extends State<KursAcilisEkrani>
    with TickerProviderStateMixin {
  AcilisEvresi _evre = AcilisEvresi.selam;
  AcilisEvresi get evre => _evre;

  bool _yerlesti = false;
  bool _bitti = false;

  /// Kuklanin yuruyusu.
  late final AnimationController _kosu = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500));

  /// Yuvanin / bayragin "buraya" nabzi.
  late final AnimationController _nabiz = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));

  late final ConfettiController _konfeti =
      ConfettiController(duration: const Duration(milliseconds: 700));

  final _yazi = GlobalKey<DaktiloYaziState>();
  Timer? _hazirZamani;

  Color get _renk => widget.course.primaryColor;
  Color get _renk2 => widget.course.secondaryColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _nabiz.stop();
      _nabiz.value = 1;
    } else if (!_nabiz.isAnimating) {
      _nabiz.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _hazirZamani?.cancel();
    _kosu.dispose();
    _nabiz.dispose();
    _konfeti.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Akis
  // ------------------------------------------------------------------

  void _git(AcilisEvresi e) {
    if (!mounted) return;
    setState(() => _evre = e);
  }

  /// Blok yuvaya kondu (dokunarak ya da surukleyerek).
  void blokuYerlestir() {
    if (_yerlesti || _evre != AcilisEvresi.yerlestir) return;
    HapticFeedback.mediumImpact();
    SoundService.playDrop();
    setState(() {
      _yerlesti = true;
      _evre = AcilisEvresi.calistir;
    });
  }

  /// Yesil bayrak.
  Future<void> calistir() async {
    if (_evre != AcilisEvresi.calistir) return;
    HapticFeedback.lightImpact();
    _git(AcilisEvresi.kutlama);
    final azalt = Motion.reduced(context);
    if (azalt) {
      _kosu.value = 1;
    } else {
      await _kosu.forward(from: 0);
    }
    if (!mounted) return;
    SoundService.playOdul();
    if (!azalt) _konfeti.play();
    setState(() {});
    _hazirZamani = Timer(
      Duration(milliseconds: azalt ? 900 : 1900),
      () => _git(AcilisEvresi.hazir),
    );
  }

  Future<void> _kapat({required bool atlandi}) async {
    if (_bitti) return;
    _bitti = true;
    _hazirZamani?.cancel();
    if (!widget.tekrar) {
      await KursTanitimDeposu.acilisIsaretle(widget.course.id);
    }
    if (!mounted) return;
    Navigator.of(context).pop(!widget.tekrar);
  }

  // ------------------------------------------------------------------
  // Metinler
  // ------------------------------------------------------------------

  String _t(String lang, String tr, String en, String de, String es) =>
      tanitimMetni(lang, tr, en, de, es);

  String _balon(String lang) {
    final n = widget.tanitim.adimSayisi;
    return switch (_evre) {
      AcilisEvresi.selam => _t(
          lang,
          'Merhaba, ben Devi! Bu kursta bloklarla kod yazacağız. '
              'İlk kodunu hemen birlikte deneyelim mi?',
          "Hi, I'm Devi! In this course we'll code with blocks. "
              'Shall we try your first code together right now?',
          'Hallo, ich bin Devi! In diesem Kurs programmieren wir mit '
              'Blöcken. Probieren wir gleich deinen ersten Code aus?',
          '¡Hola, soy Devi! En este curso programaremos con bloques. '
              '¿Probamos juntos tu primer código ahora mismo?'),
      AcilisEvresi.yerlestir => _t(
          lang,
          'Mavi bloğu sarı bloğun altına sürükle. İstersen ona sadece dokun!',
          'Drag the blue block under the yellow one. Or just tap it!',
          'Zieh den blauen Block unter den gelben. Oder tipp ihn einfach an!',
          'Arrastra el bloque azul debajo del amarillo. ¡O solo tócalo!'),
      AcilisEvresi.calistir => _t(
          lang,
          'Süper, bloklar birleşti! Şimdi yeşil bayrağa bas ve izle.',
          'Great, the blocks snapped together! Now press the green flag '
              'and watch.',
          'Super, die Blöcke sind verbunden! Drück jetzt die grüne Flagge '
              'und schau zu.',
          '¡Genial, los bloques se unieron! Ahora pulsa la bandera verde '
              'y mira.'),
      AcilisEvresi.kutlama => _t(
          lang,
          'Yaşasın! Kodun çalıştı: tam $n adım yürüdüm.',
          'Hooray! Your code worked: I walked exactly $n steps.',
          'Juhu! Dein Code hat funktioniert: Ich bin genau $n Schritte '
              'gegangen.',
          '¡Bien! Tu código funcionó: caminé exactamente $n pasos.'),
      AcilisEvresi.hazir => _t(
          lang,
          'Bloklar birleşince kod olur. Gerisi derslerde, birlikte!',
          'Blocks snapped together make code. The rest is in the '
              'lessons, together!',
          'Verbundene Blöcke ergeben Code. Der Rest kommt in den '
              'Lektionen, zusammen!',
          'Los bloques unidos forman código. ¡Lo demás, en las '
              'lecciones, juntos!'),
    };
  }

  // ------------------------------------------------------------------
  // Cizim
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final kisa = MediaQuery.sizeOf(context).height < 640;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _renk,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(Colors.black.withValues(alpha: 0.06), _renk),
                _renk2,
              ],
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _ustCubuk(lang),
                      SizedBox(height: kisa ? 6 : 12),
                      _deviSatiri(lang, kisa),
                      SizedBox(height: kisa ? 8 : 14),
                      Expanded(child: _calismaAlani(lang, kisa)),
                      SizedBox(height: kisa ? 10 : 14),
                      SizedBox(height: 56, child: _altDugme(lang)),
                      SizedBox(height: kisa ? 10 : 14),
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
                    emissionFrequency: 0,
                    numberOfParticles: 22,
                    maxBlastForce: 20,
                    minBlastForce: 8,
                    gravity: 0.3,
                    colors: [
                      Colors.white,
                      AppTheme.successGreen,
                      const Color(0xFF4C97FF),
                      const Color(0xFFFFBF00),
                      _renk2,
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

  Widget _ustCubuk(String lang) {
    // Ilerleme noktalari: selam, yerlestir, calistir(+kutlama), hazir.
    final sira = switch (_evre) {
      AcilisEvresi.selam => 0,
      AcilisEvresi.yerlestir => 1,
      AcilisEvresi.calistir || AcilisEvresi.kutlama => 2,
      AcilisEvresi.hazir => 3,
    };
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < 4; i++)
              AnimatedContainer(
                duration: Motion.medium2,
                curve: Motion.emphasized,
                margin: const EdgeInsets.only(right: 6),
                width: i == sira ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      Colors.white.withValues(alpha: i <= sira ? 0.95 : 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ]),
          const SizedBox(width: 12),
          Flexible(
            child: AtlaDugmesi(
              etiket: _t(lang, 'Atla', 'Skip', 'Überspringen', 'Saltar'),
              onTap: () => _kapat(atlandi: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviSatiri(String lang, bool kisa) {
    final boy = kisa ? 70.0 : 86.0;
    final mutlu = _evre == AcilisEvresi.kutlama || _evre == AcilisEvresi.hazir;
    return SizedBox(
      height: kisa ? 92 : 108,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Mascot(
            size: boy,
            mood: mutlu ? MascotMood.happy : MascotMood.idle,
            showShadow: false,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: DeviBalonu(
              metin: _balon(lang),
              vurgu: _renk,
              yaziAnahtari: _yazi,
              onTap: () => _yazi.currentState?.tamamla(),
            ),
          ),
        ],
      ),
    );
  }

  /// Sahne + kod alani. Bastan yerinde; "selam" evresinde saydam.
  Widget _calismaAlani(String lang, bool kisa) {
    final gorunur = _evre != AcilisEvresi.selam;
    final azalt = Motion.reduced(context);
    return AnimatedOpacity(
      opacity: gorunur ? 1 : 0,
      duration: azalt ? Duration.zero : Motion.long2,
      curve: Motion.emphasizedDecelerate,
      child: AnimatedSlide(
        offset: gorunur ? Offset.zero : const Offset(0, 0.04),
        duration: azalt ? Duration.zero : Motion.long2,
        curve: Motion.emphasizedDecelerate,
        child: IgnorePointer(
          ignoring: !gorunur,
          // Kod alani icerigi kadar (sinirli); kalan yukseklik sahnenin.
          child: LayoutBuilder(builder: (context, k) {
            final kodH = (k.maxHeight * 0.4).clamp(116.0, 172.0);
            return Column(
              children: [
                Expanded(child: _sahne(lang)),
                SizedBox(height: kisa ? 8 : 12),
                SizedBox(height: kodH, child: _kodAlani(lang)),
              ],
            );
          }),
        ),
      ),
    );
  }

  // --- Sahne ---------------------------------------------------------

  Widget _sahne(String lang) {
    final hazir = _evre == AcilisEvresi.hazir;
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
          // Scratch'teki gibi: sahnenin ustunde bayrak ve dur.
          SizedBox(
            height: 38,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _bayrakDugmesi(lang, kucuk: true),
                  const SizedBox(width: 8),
                  const _DurIsareti(),
                  const Spacer(),
                  Text(
                    _t(lang, 'Sahne', 'Stage', 'Bühne', 'Escenario'),
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
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE9F4FF), Color(0xFFF7FBFF)],
                ),
              ),
              child: LayoutBuilder(builder: (context, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;
                final kukla = math.min(h * 0.5, 96.0);
                final zemin = h - math.max(18.0, h * 0.16);
                final bas = w * 0.08;
                final son = w * 0.92 - kukla;
                final n = widget.tanitim.adimSayisi;
                return AnimatedBuilder(
                  animation: _kosu,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(_kosu.value);
                    final x = bas + (son - bas) * t;
                    // Yururken hafif zipliyor: her adimda bir.
                    final zip = Motion.reduced(context)
                        ? 0.0
                        : (math.sin(_kosu.value * math.pi * n)).abs() *
                            kukla *
                            0.07;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Dekor: bulutlar ve yumusak bir tepe. Sabit
                        // yerlerde; sahne "bos bir kutu" gibi durmasin.
                        Positioned.fill(
                          child:
                              CustomPaint(painter: _SahneDekoru(zemin: zemin)),
                        ),
                        // Zemin cizgisi
                        Positioned(
                          left: 12,
                          right: 12,
                          top: zemin,
                          child: Container(
                            height: 2,
                            color: const Color(0xFFB9DDB0),
                          ),
                        ),
                        // Adim noktalari: kukla gectikce yaniyor.
                        for (var i = 0; i < n; i++)
                          Positioned(
                            left: bas +
                                kukla / 2 +
                                (son - bas) * (i / (n - 1)) -
                                4,
                            top: zemin - 3,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: t >= i / (n - 1) && _kosu.value > 0
                                    ? const Color(0xFF4C97FF)
                                    : Colors.white,
                                border: Border.all(
                                    color: const Color(0xFF9CC8F5), width: 1.4),
                              ),
                            ),
                          ),
                        Positioned(
                          left: x,
                          top: zemin - kukla - zip + 4,
                          child: Image.asset(
                            Mascot.durgunGorsel,
                            width: kukla,
                            height: kukla,
                            filterQuality: FilterQuality.medium,
                            excludeFromSemantics: true,
                            errorBuilder: (_, __, ___) => Icon(
                                Icons.smart_toy_rounded,
                                size: kukla * 0.8,
                                color: Mascot.tone),
                          ),
                        ),
                        // "Hazirsin!" — sahnenin USTUNE biniyor, yerlesimi
                        // itmiyor.
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedOpacity(
                              opacity: hazir ? 1 : 0,
                              duration: Motion.reduced(context)
                                  ? Duration.zero
                                  : Motion.medium4,
                              child: AnimatedScale(
                                scale: hazir ? 1 : 0.85,
                                duration: Motion.reduced(context)
                                    ? Duration.zero
                                    : Motion.long2,
                                curve: Motion.overshoot,
                                child: Align(
                                  alignment: const Alignment(0, -0.45),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: _hazirsinRozeti(lang),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hazirsinRozeti(String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_renk, _renk2]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _renk.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(
            _t(lang, 'Hazırsın!', "You're ready!", 'Du bist bereit!',
                '¡Estás listo!'),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bayrakDugmesi(String lang, {bool kucuk = false}) {
    final aktif = _evre == AcilisEvresi.calistir;
    final boy = kucuk ? 30.0 : 40.0;
    return Semantics(
      button: true,
      enabled: aktif,
      label: _t(
          lang, 'Yeşil bayrak', 'Green flag', 'Grüne Flagge', 'Bandera verde'),
      child: GestureDetector(
        onTap: aktif ? calistir : null,
        child: AnimatedBuilder(
          animation: _nabiz,
          builder: (context, child) {
            final p = aktif ? _nabiz.value : 0.0;
            return Container(
              width: boy,
              height: boy,
              decoration: BoxDecoration(
                color:
                    aktif ? const Color(0xFFE6F4E4) : const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: aktif
                      ? const Color(0xFF45993D).withValues(alpha: 0.4 + 0.6 * p)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: YesilBayrak(boyut: boy * 0.62),
        ),
      ),
    );
  }

  // --- Kod alani -----------------------------------------------------

  Widget _kodAlani(String lang) {
    final sapka = widget.tanitim.sapka(lang);
    final blok = widget.tanitim.blok(lang);
    const s = 0.8;
    final blokW = ScratchBlokOlcer.genislik(blok, s);
    final blokH = ScratchBlokOlcer.yukseklik(blok, s);
    final yerlestirmede = _evre == AcilisEvresi.yerlestir;

    Widget baslik(String metin) => Text(
          metin,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
            letterSpacing: 0.4,
          ),
        );

    final paletBlogu = ScratchBlok(
      tanim: blok,
      olcek: s,
      sigdir: false,
      kimlik: widget.tanitim.yerlesecekBlokId,
    );

    // Palet: tek blok. Dokun ya da surukle.
    final palet = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        baslik(_t(lang, 'Bloklar', 'Blocks', 'Blöcke', 'Bloques')),
        const SizedBox(height: 10),
        SizedBox(
          width: blokW,
          height: blokH + ScratchBlokOlcer.tirnakPayi(s),
          child: _yerlesti
              ? Opacity(opacity: 0.22, child: paletBlogu)
              : Draggable<String>(
                  data: widget.tanitim.yerlesecekBlokId,
                  maxSimultaneousDrags: yerlestirmede ? 1 : 0,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Transform.scale(scale: 1.06, child: paletBlogu),
                  ),
                  childWhenDragging: Opacity(opacity: 0.3, child: paletBlogu),
                  child: Semantics(
                    button: true,
                    label: blok.duzMetin,
                    child: GestureDetector(
                      key: const ValueKey('acilis_palet_blogu'),
                      onTap: blokuYerlestir,
                      child: AnimatedBuilder(
                        animation: _nabiz,
                        builder: (context, child) => ScratchBlok(
                          tanim: blok,
                          olcek: s,
                          sigdir: false,
                          vurgu: yerlestirmede
                              ? Colors.white
                                  .withValues(alpha: 0.35 + 0.65 * _nabiz.value)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );

    // Kod: hazir sapka + yuva.
    final kod = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        baslik(_t(
            lang, 'Kod alanı', 'Code area', 'Codebereich', 'Área de código')),
        const SizedBox(height: 10),
        ScratchBlok(tanim: sapka, olcek: s, sigdir: false),
        DragTarget<String>(
          onWillAcceptWithDetails: (d) =>
              d.data == widget.tanitim.yerlesecekBlokId && !_yerlesti,
          onAcceptWithDetails: (_) => blokuYerlestir(),
          builder: (context, aday, _) {
            return SizedBox(
              key: const ValueKey('acilis_yuva'),
              width: blokW,
              height: blokH + ScratchBlokOlcer.tirnakPayi(s),
              child: _yerlesti
                  ? _OturanBlok(
                      child: ScratchBlok(
                        tanim: blok,
                        olcek: s,
                        sigdir: false,
                        vurgu:
                            _evre == AcilisEvresi.kutlama && _kosu.isAnimating
                                ? ScratchBlok.calisanRengi
                                : null,
                      ),
                    )
                  : Align(
                      alignment: Alignment.topLeft,
                      child: AnimatedBuilder(
                        animation: _nabiz,
                        builder: (context, _) => KesikliYuva(
                          genislik: blokW,
                          yukseklik: blokH,
                          renk: const Color(0xFF4C97FF),
                          parlaklik: aday.isNotEmpty
                              ? 1
                              : (yerlestirmede ? _nabiz.value : 0.3),
                        ),
                      ),
                    ),
            );
          },
        ),
      ],
    );

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
      child: Row(
        children: [
          // Palet seridi: Scratch'teki gibi solda, hafif gri.
          Expanded(
            flex: 9,
            child: Container(
              color: const Color(0xFFF4F6FA),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.topLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: palet,
              ),
            ),
          ),
          Container(width: 1, color: const Color(0xFFE3E7EE)),
          Expanded(
            flex: 11,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: kod,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Alt dugme -----------------------------------------------------

  Widget _altDugme(String lang) {
    switch (_evre) {
      case AcilisEvresi.selam:
        return PressButton(
          key: const ValueKey('acilis_basla'),
          label: _t(lang, 'Hadi deneyelim', "Let's try it",
              'Los, probieren wir', '¡Vamos a probar!'),
          icon: Icons.play_arrow_rounded,
          color: Colors.white,
          foreground: _renk,
          onPressed: () => _git(AcilisEvresi.yerlestir),
        );
      case AcilisEvresi.yerlestir:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.touch_app_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _t(lang, 'Mavi bloğa dokun', 'Tap the blue block',
                      'Tipp auf den blauen Block', 'Toca el bloque azul'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                  ),
                ),
              ),
            ],
          ),
        );
      case AcilisEvresi.calistir:
      case AcilisEvresi.kutlama:
        final aktif = _evre == AcilisEvresi.calistir;
        return PressButton(
          key: const ValueKey('acilis_bayrak'),
          label: aktif
              ? _t(lang, 'Yeşil bayrağa bas', 'Press the green flag',
                  'Grüne Flagge drücken', 'Pulsa la bandera verde')
              : _t(lang, 'Kod çalışıyor', 'Code is running', 'Code läuft',
                  'El código se ejecuta'),
          icon: Icons.flag_rounded,
          color: const Color(0xFF4CBF56),
          onPressed: aktif ? calistir : null,
        );
      case AcilisEvresi.hazir:
        return PressButton(
          key: const ValueKey('acilis_bitir'),
          label: widget.tekrar
              ? _t(lang, 'Bitir', 'Done', 'Fertig', 'Terminar')
              : _t(lang, 'Derse başla', 'Start the lesson', 'Lektion starten',
                  'Empezar la lección'),
          icon:
              widget.tekrar ? Icons.check_rounded : Icons.arrow_forward_rounded,
          color: Colors.white,
          foreground: _renk,
          onPressed: () => _kapat(atlandi: false),
        );
    }
  }
}

/// Yuvaya oturan blogun kucuk "klik" sicramasi.
class _OturanBlok extends StatelessWidget {
  const _OturanBlok({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.86, end: 1),
      duration: Motion.long2,
      curve: Motion.overshoot,
      builder: (context, v, c) => Transform.scale(
        scale: v,
        alignment: Alignment.topLeft,
        child: c,
      ),
      child: child,
    );
  }
}

/// Sahnenin arka plani: iki bulut ve zeminde yumusak bir tepe.
class _SahneDekoru extends CustomPainter {
  _SahneDekoru({required this.zemin});
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
  bool shouldRepaint(covariant _SahneDekoru old) => old.zemin != zemin;
}

/// Scratch'in kirmizi "dur" sekizgeni.
class _DurIsareti extends StatelessWidget {
  const _DurIsareti();

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size.square(20),
        painter: _SekizgenBoyaci(),
      );
}

class _SekizgenBoyaci extends CustomPainter {
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
    canvas.drawPath(p, Paint()..color = const Color(0xFFEC5959));
    canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFFB84848));
  }

  @override
  bool shouldRepaint(covariant _SekizgenBoyaci old) => false;
}
