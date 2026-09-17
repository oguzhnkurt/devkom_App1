import 'dart:async';
import '../../../ui/ekran_olcusu.dart';
import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/interactive_lesson_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/sound_service.dart';
import 'catch_block_game.dart';
import 'kod_tezgahi.dart';
import 'coordinate_tap_game.dart';
import '../../../widgets/scratch_block_widget.dart';
import '../../../widgets/block_animation_player.dart';
import '../../../theme.dart';
import '../../../utils/lang.dart';
import '../../../ui/answer_feedback.dart';
import '../../../ui/motion.dart';
import '../../../ui/appear_in.dart';
import '../../../ui/press_button.dart';
import 'calisma_izi.dart';

/// Current app language code ('tr' | 'en') for lesson content.
/// Listens so that switching the language rebuilds lesson content in place.
/// Call this from build().
String lessonLang(BuildContext context) =>
    context.watch<SettingsProvider>().locale.languageCode;

/// Same value without subscribing - safe to call from helper methods that are
/// invoked during build (the enclosing build() already subscribes via
/// [lessonLang], so rebuilds still propagate).
String lessonLangRead(BuildContext context) =>
    Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

/// Adim widget'larindaki kisa arayuz metinleri ("Kontrol Et" gibi).
/// Almanca/Ispanyolca verilmezse Ingilizceye duser — ders icerigiyle
/// ayni kural (bkz. pickLang).
String lessonText(String lang, String tr, String en, [String? de, String? es]) =>
    AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

// ==========================================
// INTRO STEP WIDGET
// ==========================================

class IntroStepWidget extends StatefulWidget {
  final IntroStep step;
  final Course course;
  final bool isDark;
  final VoidCallback onComplete;

  const IntroStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.onComplete,
    this.isDark = false,
  });

  @override
  State<IntroStepWidget> createState() => _IntroStepWidgetState();
}

class _IntroStepWidgetState extends State<IntroStepWidget>
    with TickerProviderStateMixin {
  late final AnimationController _float;
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      duration: const Duration(milliseconds: 2600),
      vsync: this,
    );
    _orbit = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hareket azaltilmisken tik bile atmiyor.
    if (Motion.reduced(context)) {
      _float.stop();
      _orbit.stop();
    } else {
      if (!_float.isAnimating) _float.repeat(reverse: true);
      if (!_orbit.isAnimating) _orbit.repeat();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final highlights = widget.step.highlightsFor(lang);
    final accent = widget.course.primaryColor;
    final second = widget.course.secondaryColor;
    final reduced = Motion.reduced(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- Sahne: kursun konusuyla ilgili simgeler maskotun etrafinda
        //     donuyor, arkada yumusak bir isik var.
        AppearIn(
          child: SizedBox(
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _IntroHalo(accent: accent, second: second, listenable: _float),
                if (!reduced)
                  _IntroOrbit(
                    listenable: _orbit,
                    accent: accent,
                    icons: _courseIcons(widget.course.id),
                  ),
                AnimatedBuilder(
                  animation: _float,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      0,
                      -10 * Curves.easeInOut.transform(_float.value),
                    ),
                    child: child,
                  ),
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.alphaBlend(
                              accent.withValues(alpha: 0.16), Colors.white),
                          Color.alphaBlend(
                              second.withValues(alpha: 0.30), Colors.white),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.28),
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.step.mascotEmoji ?? widget.course.icon,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // --- Konusma balonu
        AppearIn(
          delay: const Duration(milliseconds: 90),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withValues(alpha: 0.14)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  widget.step.mascotMessageFor(lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // ONCEDEN fontFamily verilmiyordu: ders acilis ekrani
                    // uygulamanin geri kalanindan baska bir yazi tipiyle
                    // aciliyordu.
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 17.5,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
                  ),
                ),
                if (highlights.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Divider(
                    height: 1,
                    color: accent.withValues(alpha: 0.14),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      lessonText(lang, 'Bu derste', 'In this lesson',
                          'In dieser Lektion', 'En esta lección'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Maddeler sirayla beliriyor: hepsi birden gelince bir
                  // liste, sirayla gelince bir anlatim oluyor.
                  ...List.generate(highlights.length, (i) {
                    return AppearIn(
                      delay: Duration(milliseconds: 180 + i * 110),
                      offset: 10,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  highlights[i],
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 15,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isDark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Kursun konusuna gore maskotun etrafinda donen simgeler.
///
/// Her kurs kendi simgelerini aliyor: Scratch'ta bloklar ve bayrak,
/// Arduino'da ampul, dalga ve pil, Python'da terminal ve liste...
/// Ayni sahne her derste tekrar ediyor ama icerigi dersin konusunu
/// soyluyor — cocuk hangi kursta oldugunu okumadan once anliyor.
List<IconData> _courseIcons(String courseId) {
  switch (courseId) {
    case 'scratch':
      return const [
        Icons.extension_rounded,
        Icons.flag_rounded,
        Icons.repeat_rounded,
        Icons.pets_rounded,
      ];
    case 'arduino':
    case 'arduino_ide':
      return const [
        Icons.lightbulb_rounded,
        Icons.memory_rounded,
        Icons.graphic_eq_rounded,
        Icons.battery_charging_full_rounded,
      ];
    case 'html':
      return const [
        Icons.code_rounded,
        Icons.title_rounded,
        Icons.link_rounded,
        Icons.image_rounded,
      ];
    case 'css':
      return const [
        Icons.palette_rounded,
        Icons.format_paint_rounded,
        Icons.crop_square_rounded,
        Icons.animation_rounded,
      ];
    case 'python':
      return const [
        Icons.terminal_rounded,
        Icons.data_array_rounded,
        Icons.functions_rounded,
        Icons.description_rounded,
      ];
    case 'java':
    case 'csharp':
      return const [
        Icons.account_tree_rounded,
        Icons.widgets_rounded,
        Icons.settings_ethernet_rounded,
        Icons.calculate_rounded,
      ];
    default:
      return const [
        Icons.code_rounded,
        Icons.lightbulb_rounded,
        Icons.extension_rounded,
        Icons.star_rounded,
      ];
  }
}

/// Maskotun arkasindaki nefes alan isik halkasi.
class _IntroHalo extends StatelessWidget {
  const _IntroHalo({
    required this.accent,
    required this.second,
    required this.listenable,
  });

  final Color accent;
  final Color second;
  final Listenable listenable;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) {
      return _ring(0.5);
    }
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final t = (listenable as AnimationController).value;
        return _ring(t);
      },
    );
  }

  Widget _ring(double t) {
    final scale = 0.94 + 0.10 * t;
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 186,
        height: 186,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              accent.withValues(alpha: 0.16),
              second.withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.62, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Simgeleri sabit bir yorunge uzerinde yavasca dondurur.
class _IntroOrbit extends StatelessWidget {
  const _IntroOrbit({
    required this.listenable,
    required this.accent,
    required this.icons,
  });

  final Listenable listenable;
  final Color accent;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final t = (listenable as AnimationController).value;
        return SizedBox(
          width: 230,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(icons.length, (i) {
              final angle =
                  (t + i / icons.length) * 2 * math.pi;
              // Hafif elips: dairesel bir yorunge duz ve mekanik duruyor.
              final dx = math.cos(angle) * 96;
              final dy = math.sin(angle) * 62;
              // Arkadakiler kuculup soluyor -> derinlik hissi.
              final depth = (math.sin(angle) + 1) / 2;
              return Transform.translate(
                offset: Offset(dx, dy),
                child: Transform.scale(
                  scale: 0.78 + depth * 0.30,
                  child: Opacity(
                    opacity: 0.35 + depth * 0.45,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.20),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icons[i], size: 19, color: accent),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ==========================================
// EXPLANATION STEP WIDGET
// ==========================================

/// Anlatim adimi: metin PARAGRAF PARAGRAF aciliyor.
///
/// NEDEN
///
/// Anlatim ekrani bir duvar metniydi: butun paragraflar bir anda
/// ekranda duruyordu ve altta DEVAM tusu hazir bekliyordu. Cocuk
/// tek dokunusla geciyor, okumuyordu — ders anlatimi ekranda var ama
/// kimsenin gozunden gecmiyordu.
///
/// Simdi ekrana her dokunusta bir paragraf daha aciliyor ve DEVAM tusu
/// ancak metnin sonuna gelindiginde etkinlesiyor. Bu bir tuzak degil:
/// hicbir sey gizlenmiyor, yalnizca sirayla veriliyor ve tek dokunus
/// bir sonrakini getiriyor. "Devam etmek icin dokun" ipucu her zaman
/// ekranda.
///
/// ERISILEBILIRLIK: ekran okuyucu acikken (accessibleNavigation)
/// metnin tamami bir anda gosteriliyor — ekran okuyucu kullanan
/// birine "dokun ve biraz daha oku" demek, metni parcalayip
/// gezinmeyi zorlastirmak demek.
class ExplanationStepWidget extends StatefulWidget {
  final ExplanationStep step;
  final Course course;
  final bool isDark;
  final VoidCallback onComplete;

  /// Araclar (magaza ekran goruntuleri, tasma olcumu) metnin tamamini
  /// gormek zorunda: orada dokunacak kimse yok.
  final bool tumunuGoster;

  const ExplanationStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
    this.tumunuGoster = false,
  });

  @override
  State<ExplanationStepWidget> createState() => _ExplanationStepWidgetState();
}

class _ExplanationStepWidgetState extends State<ExplanationStepWidget> {
  /// Kac paragraf acildi.
  int _gorunen = 1;

  /// Bitti bilgisi bir kez gonderiliyor.
  bool _bildirildi = false;

  /// Bir sonraki paragrafi getiren sayac.
  ///
  /// Paragraflar KENDILIGINDEN aciliyor: cocugun ekrana dokunmasi
  /// gerekmiyor, yalnizca DEVAM tusu metnin sonuna gelene kadar
  /// kapali kaliyor. "Devam etmek icin dokun" ipucu kaldirildi —
  /// okumasi gereken cocuktan ayrica bir is istemek, okumanin
  /// onune bir engel koymak demekti.
  Timer? _sayac;

  /// Paragraf araligi. Bir paragrafi gozle taramak icin yeterli,
  /// bekleme hissi verecek kadar uzun degil.
  static const Duration _aralik = Duration(milliseconds: 1500);

  /// Metni paragraflara ayirir. Bos satirla ayrilmis bloklar bir
  /// paragraf; tek satirlik metinlerde liste tek elemanli olur.
  List<String> _paragraflar(String metin) => metin
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  @override
  void dispose() {
    _sayac?.cancel();
    super.dispose();
  }

  void _bildir() {
    if (_bildirildi) return;
    _bildirildi = true;
    // Cizim sirasinda setState cagirmamak icin bir kare sonra.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onComplete();
    });
  }

  /// Sayaci kurar: her araligda bir paragraf daha.
  void _sayaciKur(int toplam) {
    if (_sayac != null || _gorunen >= toplam) return;
    _sayac = Timer.periodic(_aralik, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _gorunen++);
      if (_gorunen >= toplam) t.cancel();
    });
  }

  /// Hizli okuyan cocuk beklemesin: ekrana dokunmak kalan paragraflari
  /// hemen getiriyor. Zorunlu degil — sayac zaten getirecek.
  void _hepsiniAc(int toplam) {
    if (_gorunen >= toplam) return;
    _sayac?.cancel();
    _sayac = null;
    setState(() => _gorunen = toplam);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final tipText = widget.step.tipFor(lang);
    final paragraflar = _paragraflar(widget.step.contentFor(lang));

    // Ekran okuyucu acikken ya da arac modunda hepsi birden.
    final hepsi = widget.tumunuGoster ||
        MediaQuery.accessibleNavigationOf(context) ||
        paragraflar.length <= 1;

    final gorunen =
        hepsi ? paragraflar.length : _gorunen.clamp(1, paragraflar.length);
    final bitti = gorunen >= paragraflar.length;
    if (bitti) {
      _bildir();
    } else {
      _sayaciKur(paragraflar.length);
    }

    return GestureDetector(
      // Dokunmak ZORUNLU DEGIL: sayac zaten getiriyor. Dokunus yalnizca
      // hizli okuyan cocuk beklemesin diye kalanini hemen aciyor.
      onTap: bitti ? null : () => _hepsiniAc(paragraflar.length),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.step.titleFor(lang),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          for (var i = 0; i < gorunen; i++)
            AppearIn(
              // Yeni gelen paragraf asagidan suzulerek giriyor: goz
              // degisikligi fark etsin, metin aniden zipllamasin.
              key: ValueKey('p$i-${paragraflar[i].hashCode}'),
              offset: 14,
              child: Padding(
                padding: EdgeInsets.only(bottom: i == gorunen - 1 ? 0 : 14),
                child: Text(
                  paragraflar[i],
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    color: widget.isDark
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),

          if (!bitti) ...[
            const SizedBox(height: 16),
            // Devaminin GELDIGINI soyleyen sade bir isaret: uc nokta
            // sirayla yaniyor. Yazi yok — cocuktan bir sey istemiyoruz,
            // yalnizca metnin bitmedigini soyluyoruz.
            _DevamiGeliyor(renk: widget.course.primaryColor),
          ],

          if (bitti) ...[
            const SizedBox(height: 24),
            if (widget.step.visuals.isNotEmpty)
              ...widget.step.visuals.map((visual) => _buildVisual(visual, lang)),
            if (tipText != null) ...[
              const SizedBox(height: 24),
              _buildTipBox(tipText),
            ],
          ],
        ],
      ),
    );
  }

  /// Görsel öğe.
  ///
  /// `visual.content` ve `visual.label` DOĞRUDAN okunmuyor — çeviriye
  /// düşen `contentFor(lang)` / `labelFor(lang)` kullanılıyor. Model'e
  /// bu alanlar sonradan eklendi; doğrudan okunursa Ingilizce ekranda
  /// blok görsellerinin üstünde Türkçe yazılar kalıyor.
  Widget _buildVisual(VisualElement visual, String lang) {
    // Çözülmüş metinler AŞAĞIYA GEÇİRİLİYOR.
    //
    // Daha önce burada `contentFor(lang)` çağrılıyor, sonuç bir yerel
    // değişkene yazılıyor ve KULLANILMADAN bırakılıyordu; çizim yapan
    // yardımcılar hâlâ ham `visual.content`'i okuyordu. Yani model
    // alanları da, bu çağrı da vardı ama İngilizce ekranda blokların
    // üstünde Türkçe yazı görünmeye devam ediyordu. Analyzer bunu
    // "kullanılmayan değişken" uyarısı olarak söylüyordu.
    final vContent = visual.contentFor(lang);
    final vLabel = visual.labelFor(lang);
    switch (visual.type) {
      case VisualType.scratchBlock:
        return _buildScratchBlock(visual, vContent, vLabel);
      case VisualType.codeSnippet:
        return _buildCodeSnippet(vContent);
      default:
        return const SizedBox();
    }
  }

  Widget _buildScratchBlock(
    VisualElement visual,
    String content,
    String? label,
  ) {
    // Yeşil bayrak yalnızca Scratch'in başlangıç bloğunda çizilir.
    //
    // Karşılaştırma ÇEVİRİDEN ÖNCEKİ Türkçe metne bakıyor: dil değişince
    // bayrak kaybolmasın diye. Arduino/mBlock derslerinin başlangıç
    // bloğu "when Arduino Uno starts up" ve ona bayrak çizilmemeli —
    // yükleme modunda yeşil bayrak gridir, tıklanacak bir bayrak yoktur.
    final bool isGreenFlag = visual.content == 'tıklandığında';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TAŞMAYA KARŞI: blok da, yanındaki açıklama da esnek.
          //
          // Blok kutusu sabit genişlikteydi ve açıklama Row'un kalanına
          // yayılıyordu. Türkçe etiketler kısa olduğu için sorun
          // görünmüyordu; İngilizce etiketler ("set digital pin 9 output
          // as high") ekrandan 55-95 piksel taşıyor ve çocuk sarı-siyah
          // taşma şeridini görüyordu. Ekran görüntüsü üreten araç
          // (test/appstore_shots_test.dart) bunu yakaladı.
          Flexible(
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: visual.color ?? widget.course.primaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: (visual.color ?? widget.course.primaryColor).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isGreenFlag
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.flag,
                        color: Color(0xFF0FBD8C),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      // Bayraklı blokta da esnek: "when green flag
                      // clicked" Türkçesinden ("tıklandığında") çok
                      // daha uzun ve dar ekranda taşıyordu.
                      Flexible(
                        child: Text(
                          content,
                          softWrap: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
          ),
          if (label != null) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeSnippet(String content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontFamily: 'monospace',
          color: Color(0xFFD4D4D4),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTipBox(String tipText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF2D2A1A) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.step.tipEmoji ?? '💡', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tipText,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: widget.isDark ? Colors.amber.shade200 : Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Devamı geliyor" işareti: sırayla yanan üç nokta.
///
/// Burada önce "Devam etmek için ekrana dokun" yazan bir ipucu vardı.
/// Okuması gereken çocuktan ayrıca bir iş istemek, okumanın önüne bir
/// engel koymak demekti — paragraflar artık kendiliğinden geliyor ve bu
/// işaret yalnızca metnin BİTMEDİĞİNİ söylüyor.
///
/// Hareket azaltma ayarında noktalar sabit duruyor: işaret kalıyor,
/// hareket gidiyor.
class _DevamiGeliyor extends StatefulWidget {
  const _DevamiGeliyor({required this.renk});

  final Color renk;

  @override
  State<_DevamiGeliyor> createState() => _DevamiGeliyorState();
}

class _DevamiGeliyorState extends State<_DevamiGeliyor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        children: List.generate(3, (i) {
          // Her nokta kendi sirasinda parliyor.
          final faz = (_c.value * 3 - i).clamp(0.0, 1.0);
          final parlak = (1 - (faz - 0.5).abs() * 2).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.renk
                    .withValues(alpha: 0.25 + 0.55 * (Motion.reduced(context) ? 0.4 : parlak)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ==========================================
// MULTIPLE CHOICE STEP WIDGET
// ==========================================

class MultipleChoiceStepWidget extends StatefulWidget {
  final MultipleChoiceStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const MultipleChoiceStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<MultipleChoiceStepWidget> createState() => _MultipleChoiceStepWidgetState();
}

/// Sabit tohumlu karistirma — cozume esit olmadan.
///
/// NEDEN SABIT TOHUM: cocuk adimdan cikip geri gelince listeyi bambaska
/// bir sirada bulmamali; "az once ustteydi" diye aradigi blok yerinde
/// durmali. Tohum adimin kimliginden geliyor, yani her acilista ayni
/// dizilim.
///
/// NEDEN COZUME ESIT OLMAMALI: iki ya da uc ogeli bir listede rastgele
/// karistirma ciddi bir olasilikla dogru sirayi veriyor (uc ogede 1/6) ve
/// gorev kendiliginden cozulmus oluyor. Esitse bir kaydirma uygulaniyor.
List<T> karistir<T>(List<T> ogeler, String tohum, List<String> cozum,
    String Function(T) kimlik) {
  if (ogeler.length < 2) return List<T>.from(ogeler);
  final liste = List<T>.from(ogeler)..shuffle(Random(tohum.hashCode));
  if (liste.map(kimlik).join('|') == cozum.join('|')) {
    liste.add(liste.removeAt(0));
  }
  return liste;
}

/// Cevap anahtari sizdiran emojiler.
///
/// Icerik dosyalarinda dogru secenege `emoji: '✅'`, yanlislara `'❌'`
/// yazilmis. Bu emojiler seceneklerin YANINDA, cocuk cevabi vermeden
/// once ciziliyordu — yani her coktan secmeli soru cevabini ekranda
/// gosteriyordu. Modul sinavi ekrani bunu zaten bastiriyordu
/// (module_quiz_screen.dart), ders ekrani bastirmiyordu.
const Set<String> _answerKeyEmojis = {'✅', '❌', '✔️', '✔', '❎', '✖️'};

class _MultipleChoiceStepWidgetState extends State<MultipleChoiceStepWidget> {
  int? _selectedIndex;
  bool _answered = false;
  bool get _isCorrect => _selectedIndex == widget.step.correctIndex;

  /// Seceneklerin gosterim sirasi.
  ///
  /// Icerikte dogru cevap neredeyse her zaman ILK secenek: modul 3-4'teki
  /// 18 sorunun 18'inde `correctIndex: 0`. Cocuk bunu iki soruda fark
  /// ediyor ve soruyu okumayi birakiyor. Sirayi burada, ders kimligine
  /// bagli SABIT bir tohumla karistiriyoruz: dizilim her acilista ayni
  /// (cocuk "az once A idi" diye kafasi karismiyor) ama artik dogru
  /// cevabin yeri sorudan soruya degisiyor. Icerik dosyalarindaki
  /// `correctIndex` degerlerine dokunmadan tum kurslarda duzeliyor.
  late final List<int> _order;

  @override
  void initState() {
    super.initState();
    _order = List<int>.generate(widget.step.options.length, (i) => i)
      ..shuffle(Random(widget.step.id.hashCode));
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    // DOGRU CEVAPTA SES YOKTU.
    //
    // Coktan secmeli adim yalnizca titresim veriyordu; dogru ve yanlis
    // cevap ayni his. Ders sorularinin sesi oyunlarinkinden ayri
    // (bkz. SoundService.playSoruDogru).
    if (_isCorrect) {
      SoundService.playSoruDogru();
    } else {
      HapticFeedback.mediumImpact();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onComplete(_isCorrect);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              const Text('🤔', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 16),
              Text(
                widget.step.questionFor(lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Code context if any
        if (widget.step.codeContext != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.step.codeContext!,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFFD4D4D4),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Options
        ...List.generate(widget.step.options.length, (slot) {
          final index = _order[slot];
          final option = widget.step.options[index];
          final isSelected = _selectedIndex == index;
          final isCorrectAnswer = widget.step.correctIndex == index;

          Color backgroundColor;
          Color borderColor;

          if (_answered) {
            if (isCorrectAnswer) {
              backgroundColor = Colors.green.withValues(alpha: 0.15);
              borderColor = Colors.green;
            } else if (isSelected && !isCorrectAnswer) {
              backgroundColor = Colors.red.withValues(alpha: 0.15);
              borderColor = Colors.red;
            } else {
              backgroundColor = widget.isDark ? const Color(0xFF1E1E2E) : Colors.white;
              borderColor = widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
            }
          } else {
            backgroundColor = isSelected
                ? widget.course.primaryColor.withValues(alpha: 0.1)
                : (widget.isDark ? const Color(0xFF1E1E2E) : Colors.white);
            borderColor = isSelected
                ? widget.course.primaryColor
                : (widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300);
          }

          return GestureDetector(
            onTap: () => _selectAnswer(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  // Emoji yalnizca ANLAMLI ise gosteriliyor; cevap
                  // anahtari emojileri (✅/❌) hic cizilmiyor.
                  if (option.emoji != null &&
                      !_answerKeyEmojis.contains(option.emoji)) ...[
                    Text(option.emoji!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                  ] else ...[
                    // Yerine notr bir harf rozeti: secenekleri konusurken
                    // isaret etmeyi kolaylastiriyor, hicbir sey ele vermiyor.
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: borderColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        String.fromCharCode(65 + slot),
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      option.textFor(lang),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontFamily: option.isCode ? 'monospace' : null,
                        color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  if (_answered && isCorrectAnswer)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (_answered && isSelected && !isCorrectAnswer)
                    const Icon(Icons.cancel, color: Colors.red),
                ],
              ),
            ),
          );
        }),

        // Explanation after answering
        if (_answered) ...[
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCorrect
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isCorrect ? '✅' : '💡',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCorrect
                            ? lessonText(lang, 'Doğru!', 'Correct!', 'Richtig!', '¡Correcto!')
                            : lessonText(lang, 'Yanlış!', 'Wrong!', 'Falsch!', '¡Incorrecto!'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isCorrect ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.step.explanationFor(lang),
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ==========================================
// DRAG & DROP STEP WIDGET
// ==========================================

class DragDropStepWidget extends StatefulWidget {
  final DragDropStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const DragDropStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<DragDropStepWidget> createState() => _DragDropStepWidgetState();
}

class _DragDropStepWidgetState extends State<DragDropStepWidget> {
  final Map<String, String?> _placements = {};

  /// Butun parcalar yerlesti ama dizilim yanlis.
  bool _yanlisYerlesim = false; // itemId -> zoneId
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    for (var item in widget.step.items) {
      _placements[item.id] = null;
    }
  }

  void _checkCompletion() {
    // Check if all items are placed
    if (_placements.values.any((v) => v == null)) return;

    // Check if all placements are correct
    bool allCorrect = true;
    for (var entry in _placements.entries) {
      if (widget.step.correctMapping[entry.key] != entry.value) {
        allCorrect = false;
        break;
      }
    }

    // YANLIS YERLESTIRMEDE DE GERI BILDIRIM VAR.
    //
    // Eskiden yalnizca dogru dalda bir sey oluyordu: yanlis dizilimde ne
    // yazi, ne renk, ne titresim. Cocuk parcalari yesil kutu cikana kadar
    // bedavaya deneyebiliyordu.
    setState(() {
      _completed = allCorrect;
      _yanlisYerlesim = !allCorrect;
    });

    if (allCorrect) {
      HapticFeedback.heavyImpact();
      SoundService.playSoruDogru();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete(true);
      });
    } else {
      SoundService.playWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction
        Text(
          widget.step.instructionFor(lang),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 24),

        // Drop zones
        Row(
          children: widget.step.dropZones.map((zone) {
            return Expanded(
              child: _buildDropZone(zone),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Draggable items
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.step.items
              .where((item) => _placements[item.id] == null)
              .map((item) => _buildDraggableItem(item))
              .toList(),
        ),

        // Yanlis dizilim uyarisi. Cevabi SOYLEMIYOR — yalnizca
        // "burada bir sey yanlis" diyor ki cocuk tekrar baksin.
        if (_yanlisYerlesim) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.refresh_rounded,
                    color: Colors.orange, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lessonText(
                        lang,
                        'Hepsi yerlesti ama bir yeri yanlis. Bir daha bak.',
                        'Everything is placed, but one is in the wrong spot. Take another look.',
                        'Alles liegt, aber eins ist am falschen Platz. Schau noch mal.',
                        'Están todos colocados, pero uno está en el sitio equivocado. Míralo otra vez.'),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Success message
        if (_completed) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.step.successMessageFor(lang),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropZone(DropZone zone) {
    final itemsInZone = widget.step.items
        .where((item) => _placements[item.id] == zone.id)
        .toList();

    return DragTarget<DraggableItem>(
      onAcceptWithDetails: (details) {
        setState(() {
          _placements[details.data.id] = zone.id;
        });
        HapticFeedback.lightImpact();
        _checkCompletion();
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(minHeight: 150),
          decoration: BoxDecoration(
            color: isHovering
                ? widget.course.primaryColor.withValues(alpha: 0.1)
                : (widget.isDark ? const Color(0xFF1E1E2E) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering
                  ? widget.course.primaryColor
                  : (widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              width: 2,
              style: isHovering ? BorderStyle.solid : BorderStyle.none,
            ),
          ),
          child: Column(
            children: [
              Text(
                zone.labelFor(lessonLangRead(context)),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.course.primaryColor,
                ),
              ),
              if (zone.hintFor(lessonLangRead(context)) != null) ...[
                const SizedBox(height: 4),
                Text(
                  zone.hintFor(lessonLangRead(context))!,
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ...itemsInZone.map((item) => _buildPlacedItem(item)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(DraggableItem item) {
    return Draggable<DraggableItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: _buildItemContent(item, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildItemContent(item),
      ),
      child: _buildItemContent(item),
    );
  }

  Widget _buildItemContent(DraggableItem item, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: item.color ?? widget.course.primaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Text(
        item.contentFor(lessonLangRead(context)),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlacedItem(DraggableItem item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _placements[item.id] = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: item.color ?? widget.course.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                item.contentFor(lessonLangRead(context)),
                style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.close, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// BLOCK BUILDER STEP WIDGET
// ==========================================

class BlockBuilderStepWidget extends StatefulWidget {
  final BlockBuilderStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const BlockBuilderStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<BlockBuilderStepWidget> createState() => _BlockBuilderStepWidgetState();
}

class _BlockBuilderStepWidgetState extends State<BlockBuilderStepWidget> {
  final List<String> _placedBlocks = [];

  /// Paletin gosterim sirasi.
  ///
  /// ONCEDEN palet `availableBlocks` sirasindaydi ve yirmi blok kurma
  /// adiminin YIRMISINDE de o sira cozumun ta kendisiydi: fazladan blok
  /// yok, sira dogru sira. Cocuk yukaridan asagi dokunup gecebiliyordu ve
  /// adim siralama hakkinda hicbir sey ogretmiyordu.
  late final List<ScratchBlock> _palet;

  @override
  void initState() {
    super.initState();
    _palet = karistir(widget.step.availableBlocks, widget.step.id,
        widget.step.correctSequence, (b) => b.id);
  }
  bool _completed = false;

  /// Dizi TAMAM ama sirasi yanlis. Yalnizca bu durumda uyari gosteriliyor;
  /// yarim dizide cocugu erken uyarmanin anlami yok.
  bool _yanlisDizi = false;

  /// Bastan kacinci bloga kadar dogru dizilmis.
  ///
  /// Tek bir "sira yanlis" cumlesi cocuga NEREYE bakacagini soylemiyordu;
  /// dort blokluk bir dizide bu, blok yerlerini rastgele degistirmekten
  /// farksiz. Bu sayi ise cevabi ELE VERMIYOR — yalnizca "ilk iki blok
  /// yerinde, ucuncuye bir daha bak" demeyi mumkun kiliyor.
  int _dogruOnEk = 0;
  bool _showAnimation = false;

  /// Calisma izi ekranda mi.
  ///
  /// Kodu calistirmak ODUL DEGIL OGRENME ARACIDIR: yanlis kod da calisir
  /// ve yanlis sonuc verir; ogretici olan da budur. Bu yuzden iz, dogru
  /// cevap beklemeden her an acilabiliyor.
  bool _izGoster = false;

  void _addBlock(ScratchBlock block) {
    setState(() {
      _placedBlocks.add(block.id);
      _izGoster = false;
      _showAnimation = false;
    });
    HapticFeedback.lightImpact();
    _checkAnswer();
  }

  void _removeBlock(int index) {
    setState(() {
      _placedBlocks.removeAt(index);
      _completed = false;
      _yanlisDizi = false;
      _izGoster = false;
      _showAnimation = false;
    });
  }

  void _checkAnswer() {
    if (_placedBlocks.length != widget.step.correctSequence.length) {
      setState(() {
        _completed = false;
        _yanlisDizi = false;
      });
      return;
    }

    var onEk = 0;
    while (onEk < _placedBlocks.length &&
        _placedBlocks[onEk] == widget.step.correctSequence[onEk]) {
      onEk++;
    }
    final correct = onEk == _placedBlocks.length;

    // TAM AMA YANLIS DIZIDE ARTIK GERI BILDIRIM VAR.
    //
    // Eskiden yanlis dizi hicbir sey uretmiyordu: ne yazi, ne renk, ne
    // titresim. Cocuk blok ekleyip cikararak yesil cerceve cikana kadar
    // deniyordu — uc dort blokla kaba kuvvet birkac saniye suruyor ve
    // hicbir sey ogretmiyor.
    setState(() {
      _yanlisDizi = !correct;
      _dogruOnEk = onEk;
      if (correct) {
        _completed = true;
        HapticFeedback.heavyImpact();
      }
    });
    if (correct) {
      SoundService.playSoruDogru();
    } else {
      SoundService.playWrong();
    }
  }

  /// Kod alanindaki kimlikleri bloklarin kendisine cevirir.
  List<ScratchBlock> _kodBloklari() => _placedBlocks
      .map((id) => widget.step.availableBlocks.firstWhere((b) => b.id == id))
      .toList();

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final goalLabel = lessonText(lang, 'Hedef', 'Goal', 'Ziel', 'Objetivo');
    // Araliklar ekran boyuna gore. iPhone SE'de yonerge + hedef + kod
    // alani + palet birlikte ekrana sigmiyordu.
    final ara = EkranOlcusu.bosluk(context, 24);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction
        Text(
          widget.step.instructionFor(lang),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),

        // Goal
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$goalLabel: ${widget.step.goalFor(lang)}',
                  style: TextStyle(
                    color: widget.isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ara),

        // Code area
        Container(
          padding: EdgeInsets.all(EkranOlcusu.kisa(context) ? 12 : 16),
          constraints: BoxConstraints(minHeight: EkranOlcusu.kisa(context) ? 110 : 150),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            border: _completed
                ? Border.all(color: Colors.green, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lessonText(lang, 'Kod Alanı:', 'Code area:', 'Codebereich:', 'Zona de código:'),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              if (_placedBlocks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      lessonText(lang, 'Blokları buraya sürükle',
                          'Drag the blocks here', 'Zieh die Blöcke hierher', 'Arrastra los bloques aquí'),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                ..._buildPlacedList(lang),
            ],
          ),
        ),
        // GERI BILDIRIM ARTIK KOD ALANININ HEMEN ALTINDA.
        //
        // Uyari, basari kutusu ve DEVAM tusu sayfanin EN ALTINDA, blok
        // paletinin de altindaydi. Telefonda bunlar ekranin disinda
        // kaliyordu: cocuk siralamayi yanlis yapiyor, hicbir sey
        // olmuyor sanip "kodu yazdim ama devam gelmiyor" diyordu.
        // Yanlis dizilim uyarisi. Cevabi SOYLEMIYOR — yalnizca
        // "burada bir sey yanlis" diyor ki cocuk tekrar baksin.
        if (_yanlisDizi) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.refresh_rounded,
                    color: Colors.orange, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    // NEREYE bakacagini soyluyor, CEVABI soylemiyor.
                    _dogruOnEk == 0
                        ? lessonText(
                            lang,
                            'Daha ilk bloktan sıra bozuluyor. En baştan bir daha düşün.',
                            'The order goes wrong at the very first block. Think again from the start.',
                            'Schon der erste Block steht falsch. Denk noch mal von vorne.',
                            'El orden falla desde el primer bloque. Piénsalo otra vez desde el principio.')
                        : lessonText(
                            lang,
                            'İlk $_dogruOnEk blok yerinde. ${_dogruOnEk + 1}. bloğa bir daha bak.',
                            'The first $_dogruOnEk blocks are in place. Look at block ${_dogruOnEk + 1} again.',
                            'Die ersten $_dogruOnEk Blöcke sitzen richtig. Schau dir Block ${_dogruOnEk + 1} noch einmal an.',
                            'Los primeros $_dogruOnEk bloques están bien. Mira otra vez el bloque ${_dogruOnEk + 1}.'),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // CALISTIRMA TUSU ARTIK HER ZAMAN BURADA.
        //
        // Eskiden bu tus `if (_completed)` blogunun icindeydi: cocuk
        // ancak DOGRU cevabi bulduktan sonra kodunu calistirabiliyordu.
        // Yani kendi yanlis kodunun ne yaptigini hicbir zaman goremiyor,
        // sadece dogru sirayi arayip buluyordu. Simdi tek blok koysa
        // bile calistirip sonucu gorebiliyor.
        if (_placedBlocks.isNotEmpty) ...[
          SizedBox(height: ara),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _izGoster = true;
                _showAnimation = _completed;
              });
            },
            icon: const Icon(Icons.play_arrow),
            label: Text(lessonText(lang, 'KODU ÇALIŞTIR', 'RUN THE CODE',
                'CODE AUSFÜHREN', 'EJECUTAR EL CÓDIGO')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_izGoster) ...[
            const SizedBox(height: 12),
            CalismaIzi(bloklar: _kodBloklari(), lang: lang),
          ],
        ],

        // Success indicator
        if (_completed) ...[
          SizedBox(height: ara),

          // Kedi animasyonu göster
          if (_showAnimation)
            // Oynaticiya artik yalnizca kimlikler degil BLOKLARIN KENDISI
            // gidiyor: her adimda calisan blogun yazisini gosterebilmesi
            // ve konusma metnini blogun kendi etiketinden cikarabilmesi
            // icin. Dili de gecirmek zorunda; eskiden sahnedeki metinler
            // Turkce sabitti.
            BlockAnimationPlayer(
              key: UniqueKey(), // Her seferinde yeni widget oluştur
              blocks: _placedBlocks
                  .map((id) => widget.step.availableBlocks
                      .firstWhere((b) => b.id == id))
                  .toList(),
              lang: lang,
              size: 50,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lessonText(lang, 'Mükemmel! Doğru sıralamayı buldun!',
                          'Perfect! You found the right order!', 'Perfekt! Du hast die richtige Reihenfolge gefunden!', '¡Perfecto! ¡Has encontrado el orden correcto!'),
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Calistirma tusu yukari tasindi; burada yalnizca DEVAM kaldi.
          ElevatedButton(
            onPressed: () => widget.onComplete(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.course.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              lessonText(lang, 'DEVAM', 'CONTINUE', 'WEITER', 'CONTINUAR'),
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],

        SizedBox(height: ara),

        // Available blocks
        Text(
          lessonText(lang, 'Kullanılabilir Bloklar:', 'Available blocks:', 'Verfügbare Blöcke:', 'Bloques disponibles:'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _palet.map((block) {
            return GestureDetector(
              onTap: () => _addBlock(block),
              child: _buildBlockWidget(block, lang),
            );
          }).toList(),
        ),

      ],
    );
  }

  Widget _buildBlockWidget(ScratchBlock block, String lang) {
    return ScratchBlockWidget(
      block: block,
      lang: lang,
      onTap: null, // Zaten tap handler dışarıda
    );
  }

  /// Yerlestirilen bloklari C-blogunun ICINI gosterecek sekilde cizer.
  ///
  /// Onceki surumde kod alani duz bir listeydi: `4 kere tekrarla` ile
  /// `Miyav! de` alt alta iki blok olarak duruyordu. Cocuk acisindan
  /// "once soyle, sonra tekrarla" ile "tekrarlanin icinde soyle"
  /// arasinda gorsel hicbir fark yoktu — ders tam da bu farki ogretmeye
  /// calisiyorken. Artik C-blogundan sonraki bloklar iceri giriyor,
  /// solunda dongunun renginde bir ray ve altinda dongunun ayagi var.
  List<Widget> _buildPlacedList(String lang) {
    final ogeler = <Widget>[];
    var girinti = 0;
    Color? rayRengi;

    for (var i = 0; i < _placedBlocks.length; i++) {
      final block = widget.step.availableBlocks
          .firstWhere((b) => b.id == _placedBlocks[i]);

      Widget blokWidget = _buildPlacedBlock(block, i, lang);
      if (girinti > 0 && rayRengi != null) {
        // Sol sirt: C blogunun govdesi. Genisligi painter'daki
        // `indent` ile ayni (16) ki ust cubukla hizali gorunsun.
        blokWidget = Container(
          margin: EdgeInsets.only(left: (girinti - 1) * 16.0),
          padding: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: rayRengi, width: 16),
            ),
          ),
          child: blokWidget,
        );
      }
      ogeler.add(blokWidget);

      if (block.shape == ScratchBlockShape.cBlock) {
        girinti++;
        rayRengi = block.color;
      }
    }

    if (girinti > 0 && rayRengi != null) {
      // Dongunun ici bos mu? Oyleyse bos yuvayi gosteriyoruz: cocuk
      // "tekrarla" blogunu koyup icine bir sey koymadigini boylece
      // goruyor. Cevabi soylemiyor, eksigi gosteriyor.
      final sonuncuCBlok = widget.step.availableBlocks
              .firstWhere((b) => b.id == _placedBlocks.last)
              .shape ==
          ScratchBlockShape.cBlock;

      if (sonuncuCBlok) {
        ogeler.add(
          Container(
            margin: EdgeInsets.only(left: (girinti - 1) * 16.0),
            padding: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: rayRengi, width: 16)),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Text(
                lessonText(
                    lang,
                    'Bu döngünün içi boş',
                    'This loop is empty',
                    'Diese Schleife ist leer',
                    'Este bucle está vacío'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        );
      }

      // Dongunun ayagi.
      ogeler.add(
        Container(
          margin: EdgeInsets.only(left: (girinti - 1) * 16.0),
          width: 120,
          height: 20,
          decoration: BoxDecoration(
            color: rayRengi,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
      );
    }

    return ogeler;
  }

  Widget _buildPlacedBlock(ScratchBlock block, int index, String lang) {
    // ARALIK YOK.
    //
    // Bloklarin arasinda 4 piksel bosluk vardi: yapboz tirnagi bir
    // sonraki blogun centigine oturmuyor, bloklar birbirine takilmis
    // gibi degil ayri ayri kartlar gibi duruyordu. Scratch'te bloklar
    // birbirine DEGER; cocuk "bunlar tek bir program" fikrini bundan
    // aliyor.
    return ScratchBlockWidget(
      block: block,
      lang: lang,
      isPlaced: true,
      showRemoveIcon: true,
      cHeadOnly: block.shape == ScratchBlockShape.cBlock,
      onTap: () => _removeBlock(index),
    );
  }
}

// ==========================================
// ORDERING STEP WIDGET
// ==========================================

class OrderingStepWidget extends StatefulWidget {
  final OrderingStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const OrderingStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<OrderingStepWidget> createState() => _OrderingStepWidgetState();
}

class _OrderingStepWidgetState extends State<OrderingStepWidget> {
  late List<OrderItem> _orderedItems;

  /// Kontrol edildikten sonra dolu; her satirin dogru yerde olup olmadigi.
  List<bool>? _correctness;
  AnswerResult? _result;

  /// Her yanlis denemede artiyor; listeyi sallamak icin.
  int _wrongTick = 0;

  @override
  void initState() {
    super.initState();
    _orderedItems = karistir(widget.step.items, widget.step.id,
        widget.step.correctOrder, (e) => e.id);
  }

  /// ONCEDEN: her surukleme sonrasi sira sessizce kontrol ediliyor, dogru
  /// olunca yesil kutu beliriyordu. Yanlista hicbir sey olmuyordu — cocuk
  /// dogruyu bulana kadar rastgele deniyordu ve hangi satirin yanlis
  /// oldugunu ogrenmiyordu. Artik kontrol acik bir eylem ve sonuc satir
  /// satir gosteriliyor.
  void _check() {
    final current = _orderedItems.map((e) => e.id).toList();
    final flags = [
      for (int i = 0; i < current.length; i++)
        i < widget.step.correctOrder.length &&
            current[i] == widget.step.correctOrder[i],
    ];
    final ok = !flags.contains(false) &&
        current.length == widget.step.correctOrder.length;

    setState(() {
      _correctness = flags;
      _result = ok ? AnswerResult.correct : AnswerResult.wrong;
      if (!ok) _wrongTick++;
    });
    AnswerFeedbackBar.haptic(_result!);
    if (ok) {
      SoundService.playSoruDogru();
    } else {
      SoundService.playWrong();
    }
  }

  void _retry() {
    setState(() {
      _correctness = null;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final locked = _result == AnswerResult.correct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.step.instructionFor(lang),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.step.contextFor(lang),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            height: 1.45,
            color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),

        ShakeOnChange(
          trigger: _wrongTick,
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _orderedItems.length,
            onReorder: (oldIndex, newIndex) {
              if (locked) return;
              setState(() {
                if (oldIndex < newIndex) newIndex--;
                final item = _orderedItems.removeAt(oldIndex);
                _orderedItems.insert(newIndex, item);
                // Sira degisti: onceki kontrolun rengi artik gecersiz.
                _correctness = null;
                _result = null;
              });
              HapticFeedback.selectionClick();
            },
            itemBuilder: (context, index) =>
                _buildRow(context, index, lang, locked),
          ),
        ),

        if (_result != null) ...[
          const SizedBox(height: 18),
          AnswerFeedbackBar(
            inline: true,
            result: _result!,
            detail: _result == AnswerResult.correct
                ? lessonText(lang, 'Sıralama doğru.', 'That is the right order.', 'Die Reihenfolge stimmt.', 'El orden es correcto.')
                : lessonText(
                    lang,
                    'Kırmızı işaretli satırlar yanlış yerde. Onları taşıyıp tekrar dene.',
                    'The rows with a red mark are in the wrong place. Move them and check again.',
                    'Die rot markierten Zeilen stehen falsch. Verschieb sie und prüf noch mal.',
                    'Las filas marcadas en rojo están mal colocadas. Muévelas y comprueba otra vez.'),
            continueLabel: _result == AnswerResult.correct
                ? lessonText(lang, 'Devam', 'Continue', 'Weiter', 'Continuar')
                : lessonText(lang, 'Tekrar dene', 'Try again', 'Noch mal versuchen', 'Inténtalo otra vez'),
            onContinue: _result == AnswerResult.correct
                ? () => widget.onComplete(true)
                : _retry,
          ),
        ] else ...[
          const SizedBox(height: 18),
          PressButton(
            label: lessonText(lang, 'Kontrol Et', 'Check', 'Prüfen', 'Comprobar'),
            color: widget.course.primaryColor,
            onPressed: _check,
            height: 52,
          ),
        ],
      ],
    );
  }

  Widget _buildRow(
      BuildContext context, int index, String lang, bool locked) {
    final item = _orderedItems[index];
    final ok = _correctness != null && index < _correctness!.length
        ? _correctness![index]
        : null;

    // Renk tek basina anlam tasimiyor: dogru/yanlis satirin ayrica bir ikonu
    // var (renk korlugu icin gereklilik).
    late final Color border;
    late final Color? tint;
    if (ok == null) {
      border = widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
      tint = null;
    } else if (ok) {
      border = const Color(0xFF2E7D32);
      tint = const Color(0xFF2E7D32).withValues(alpha: 0.08);
    } else {
      border = const Color(0xFFC62828);
      tint = const Color(0xFFC62828).withValues(alpha: 0.08);
    }

    final row = AnimatedContainer(
      duration: Motion.short3,
      curve: Motion.emphasized,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: tint ??
            (widget.isDark ? const Color(0xFF1E1E2E) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: ok == null ? 1 : 1.6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.drag_indicator_rounded,
            color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            size: 22,
          ),
          const SizedBox(width: 10),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.course.primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: AppTheme.number(
                fontSize: 13,
                color: widget.course.primaryColor,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.contentFor(lang),
              style: TextStyle(
                // Kod satirlari tek genislikte yazi ile: girintiler ve
                // hizalama ancak oyle okunuyor.
                fontFamily: item.isCode ? 'monospace' : AppTheme.fontFamily,
                fontSize: item.isCode ? 13.5 : 14.5,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
          if (ok != null) ...[
            const SizedBox(width: 8),
            Icon(
              ok ? Icons.check_rounded : Icons.close_rounded,
              size: 19,
              color: border,
            ),
          ],
        ],
      ),
    );

    // Dogru cevaptan sonra siraya dokunulmasin: satirlar artik salt okunur.
    if (locked) {
      return KeyedSubtree(key: ValueKey(item.id), child: row);
    }
    return ReorderableDragStartListener(
      key: ValueKey(item.id),
      index: index,
      child: row,
    );
  }
}

// ==========================================
// MATCHING STEP WIDGET
// ==========================================

class MatchingStepWidget extends StatefulWidget {
  final MatchingStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const MatchingStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<MatchingStepWidget> createState() => _MatchingStepWidgetState();
}

class _MatchingStepWidgetState extends State<MatchingStepWidget> {
  String? _selectedLeft;
  final Map<String, String> _matches = {}; // leftId -> rightId
  final Map<String, bool> _matchCorrectness = {}; // leftId -> isCorrect
  bool _completed = false;

  /// Butun ciftler eslesmeden once hicbir sey notlanmaz.
  ///
  /// Eskiden her eslestirme aninda yesil/kirmiz oluyordu. Dort ciftlik bir
  /// adimda bu, dusunmeyi tamamen gereksiz kiliyordu: cocuk rastgele
  /// dokunuyor, kirmiziysa geri aliyor, birkac denemede garanti
  /// tamamliyordu. Artik geri bildirim tahtanin tamami dolunca geliyor;
  /// geri alma yine serbest ve yanlista puan kesilmiyor, ama karar bir
  /// kerede veriliyor.
  bool _kontrolEdildi = false;

  /// Notlanmadiysa `null` (notr goster), notlandiysa dogru/yanlis.
  bool? _durum(String leftId) =>
      _kontrolEdildi ? (_matchCorrectness[leftId] ?? false) : null;
  late List<MatchPair> _shuffledPairs;

  /// Sag sutunun sirasi.
  ///
  /// Eskiden `build()` icinde `..shuffle()` ile uretiliyordu. Her
  /// `setState` yeni bir sira demekti: cocuk soldaki karta dokunuyor,
  /// sag taraftaki secenekler ve A/B/C rozetleri parmagi oraya
  /// varmadan yer degistiriyordu. Bir kez, adima bagli sabit bir
  /// tohumla karistiriliyor.
  late List<MatchPair> _rightItems;

  @override
  void initState() {
    super.initState();
    _shuffledPairs = List.from(widget.step.pairs)
      ..shuffle(Random(widget.step.id.hashCode));
    _rightItems = List.from(widget.step.pairs)
      ..shuffle(Random(widget.step.id.hashCode ^ 0x5A17));
  }

  void _selectLeft(String id) {
    // If already matched, allow unmatch
    if (_matches.containsKey(id)) {
      setState(() {
        _matches.remove(id);
        _matchCorrectness.clear();
        _kontrolEdildi = false;
        _selectedLeft = null;
      });
      return;
    }

    setState(() => _selectedLeft = id);
  }

  void _selectRight(String rightId) {
    if (_selectedLeft == null) return;

    setState(() {
      _matches[_selectedLeft!] = rightId;
      _selectedLeft = null;
    });

    HapticFeedback.lightImpact();
    _checkCompletion();
  }

  void _checkCompletion() {
    if (_matches.length != widget.step.pairs.length) return;

    // Tahta doldu: simdi hepsini birden notluyoruz.
    setState(() {
      _matchCorrectness
        ..clear()
        ..addEntries(
          _matches.entries.map((e) => MapEntry(e.key, e.key == e.value)),
        );
      _kontrolEdildi = true;
    });

    final allCorrect = _matchCorrectness.values.every((correct) => correct);

    if (allCorrect) {
      setState(() => _completed = true);
      HapticFeedback.heavyImpact();
      SoundService.playSoruDogru();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete(true);
      });
    } else {
      // Puan KESILMEZ. Yanlis eslesmeler kirmizi isaretlenir, cocuk
      // uzerine dokunup cozer.
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final rightItems = _rightItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.step.instructionFor(lang),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 24),

        // Matching cards with improved design
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Conditions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    // FittedBox: kucuk ekranda hap KIRPILMIYOR, kuculuyor.
                    //
                    // Sutun iPhone SE'de 140 piksel; "Bedingungen" hapi
                    // 12 punto kalin yaziyla 159 piksel istiyor ve Row
                    // 19 piksel tasiyordu (Almanca ve Ingilizcede; Turkce
                    // "Kosullar" sigiyordu, o yuzden yalnizca Turkce cizen
                    // eski tasma testi bunu hic gormedi). Kelimeyi ucu
                    // noktali kesmek bir kategori etiketinde okunaksiz
                    // olurdu; oran korunarak kuculuyor. Genis ekranda
                    // olcek 1, yani hicbir sey degismiyor.
                    child: Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.course.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lessonText(lang, 'Koşullar', 'Conditions', 'Bedingungen', 'Condiciones'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.course.primaryColor,
                            ),
                          ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(_shuffledPairs.length, (index) {
                    final pair = _shuffledPairs[index];
                    final isSelected = _selectedLeft == pair.id;
                    final isMatched = _matches.containsKey(pair.id);
                    final isCorrect = _durum(pair.id);
                    final vurgu = isCorrect == null
                        ? widget.course.primaryColor
                        : (isCorrect ? Colors.green : Colors.red);

                    return AnimatedContainer(
                      duration: Motion.adapt(context, Motion.short4),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        elevation: isSelected ? 4 : (isMatched ? 2 : 0),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _selectLeft(pair.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? vurgu.withValues(alpha: 0.1)
                                  : (isSelected
                                      ? widget.course.primaryColor.withValues(alpha: 0.1)
                                      : (widget.isDark ? const Color(0xFF1E1E2E) : Colors.white)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMatched
                                    ? vurgu
                                    : (isSelected
                                        ? widget.course.primaryColor
                                        : Colors.grey.shade300),
                                width: isMatched || isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isMatched
                                        ? vurgu
                                        : (isSelected
                                            ? widget.course.primaryColor
                                            : Colors.grey.shade400),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pair.leftFor(lang),
                                    style: TextStyle(
                                      fontFamily: pair.isLeftCode ? 'monospace' : null,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                if (isMatched && isCorrect != null)
                                  Icon(
                                    isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: isCorrect ? Colors.green : Colors.red,
                                    size: 20,
                                  )
                                else if (isMatched)
                                  Icon(Icons.link_rounded,
                                      color: widget.course.primaryColor,
                                      size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Right column - Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    // FittedBox: kucuk ekranda hap KIRPILMIYOR, kuculuyor.
                    //
                    // Sutun iPhone SE'de 140 piksel; "Bedingungen" hapi
                    // 12 punto kalin yaziyla 159 piksel istiyor ve Row
                    // 19 piksel tasiyordu (Almanca ve Ingilizcede; Turkce
                    // "Kosullar" sigiyordu, o yuzden yalnizca Turkce cizen
                    // eski tasma testi bunu hic gormedi). Kelimeyi ucu
                    // noktali kesmek bir kategori etiketinde okunaksiz
                    // olurdu; oran korunarak kuculuyor. Genis ekranda
                    // olcek 1, yani hicbir sey degismiyor.
                    child: Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.course.secondaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lessonText(lang, 'Sonuçlar', 'Results', 'Ergebnisse', 'Resultados'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.course.secondaryColor,
                            ),
                          ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(rightItems.length, (index) {
                    final pair = rightItems[index];
                    final isMatched = _matches.values.contains(pair.id);
                    bool? isCorrect;
                    for (var entry in _matches.entries) {
                      if (entry.value == pair.id) {
                        isCorrect = _durum(entry.key);
                        break;
                      }
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        elevation: isMatched ? 2 : 0,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: isMatched ? null : () => _selectRight(pair.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? (isCorrect == true
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : (isCorrect == false
                                          ? Colors.red.withValues(alpha: 0.1)
                                          : (widget.isDark ? const Color(0xFF1E1E2E) : Colors.white)))
                                  : (widget.isDark ? const Color(0xFF1E1E2E) : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMatched
                                    ? (isCorrect == true
                                        ? Colors.green
                                        : (isCorrect == false ? Colors.red : Colors.grey.shade300))
                                    : (_selectedLeft != null && !isMatched
                                        ? widget.course.primaryColor.withValues(alpha: 0.3)
                                        : Colors.grey.shade300),
                                width: isMatched ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isMatched
                                        ? (isCorrect == true
                                            ? Colors.green
                                            : (isCorrect == false
                                                ? Colors.red
                                                : Colors.grey.shade400))
                                        : Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pair.rightFor(lang),
                                    style: TextStyle(
                                      fontFamily: pair.isRightCode ? 'monospace' : null,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                if (isMatched && isCorrect != null)
                                  Icon(
                                    isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: isCorrect ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),

        if (_selectedLeft != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.course.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.course.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app, color: widget.course.primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lessonText(
                    lang,
                    'Şimdi sağ taraftan uygun sonucu seç',
                    'Now pick the matching result on the right',
                    'Wähle jetzt rechts das passende Ergebnis',
                    'Ahora elige a la derecha el resultado que corresponde'),
                    style: TextStyle(
                      color: widget.course.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_completed) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.2),
                  Colors.green.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lessonText(
                          lang,
                          'Harika! Tüm eşleştirmeler doğru!',
                          'Great! Every match is correct!',
                          'Super! Alle Zuordnungen stimmen!',
                          '¡Genial! ¡Todas las parejas son correctas!'),
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        lessonText(
                            lang,
                            'Tebrikler, devam edebilirsin!',
                            'Well done, you can carry on!',
                            'Gut gemacht, du kannst weitermachen!',
                            '¡Muy bien, puedes continuar!'),
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}


// ==========================================
// MINI GAME STEP WIDGET
// ==========================================

class MiniGameStepWidget extends StatefulWidget {
  final MiniGameStep step;
  final Course course;
  final bool isDark;
  final Function(int score) onComplete;

  const MiniGameStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<MiniGameStepWidget> createState() => _MiniGameStepWidgetState();
}

class _MiniGameStepWidgetState extends State<MiniGameStepWidget> {
  bool _gameStarted = false;

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    if (!_gameStarted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎮', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            widget.step.titleFor(lang),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.step.instructionFor(lang),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _gameStarted = true;
              });
            },
            icon: const Icon(Icons.play_arrow),
            label: Text(lessonText(lang, 'Oyunu Başlat', 'Start Game',
                'Spiel starten', 'Empezar el juego')),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.course.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      );
    }

    // Show the actual game based on gameType
    if (widget.step.gameType == MiniGameType.catchTheBlock) {
      return CatchBlockGame(
        step: widget.step,
        course: widget.course,
        isDark: widget.isDark,
        onComplete: (score) {
          widget.onComplete(score);
        },
      );
    }

    if (widget.step.gameType == MiniGameType.blockPuzzle) {
      // Check the config type for blockPuzzle games
      final configType = widget.step.gameConfig['type'] as String?;

      if (configType == 'loop_calculator') {
        return LoopCalculatorGame(
          step: widget.step,
          course: widget.course,
          isDark: widget.isDark,
          onComplete: (score) {
            widget.onComplete(score);
          },
        );
      }

      if (configType == 'coordinate_tap') {
        return CoordinateTapGame(
          step: widget.step,
          course: widget.course,
          isDark: widget.isDark,
          onComplete: (score) {
            widget.onComplete(score);
          },
        );
      }

      // Fall through to placeholder for other blockPuzzle types
    }

    // Placeholder for other game types (to be implemented)

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videogame_asset,
              size: 80,
              color: widget.course.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              widget.step.titleFor(lang),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.step.instructionFor(lang),
              style: TextStyle(
                fontSize: 16,
                color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lessonText(
                    lang,
                    'Oyun yakında eklenecek! Şimdilik devam edebilirsin.',
                    'This game is coming soon! You can continue for now.',
                    'Dieses Spiel kommt bald! Du kannst erst mal weitermachen.',
                    'Este juego llegará pronto. De momento puedes continuar.'),
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // PUAN VERMIYOR.
                  //
                  // Eskiden burasi `targetScore` veriyordu: henuz
                  // yazilmamis bir oyun, tek bir dokunusla TAM PUAN
                  // demekti. Su an bu dala hicbir ders girmiyor ama
                  // yeni bir MiniGameType eklendiginde sessizce
                  // bedava puan dagitmaya baslardi.
                  widget.onComplete(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.course.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                    lessonText(lang, 'Devam Et', 'Continue', 'Weiter',
                        'Continuar'),
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PROJECT STEP WIDGET
// ==========================================

/// Projenin NEREDE yapilacagi.
///
/// Bu ekranin en uzun suren kusuru buydu: gereksinimler yaziyor,
/// ipuclari yaziyor, altta "Projeyi Tamamladim!" dugmesi duruyordu —
/// ama arada calisma alani yoktu. `starterCode` ve `validation`
/// alanlari modelde vardi ve HICBIR YERDEN okunmuyordu, yani
/// dogrulama diye bir sey de yoktu. Cocuk hicbir sey yapmadan dugmeye
/// basiyor, 40 XP aliyordu. Ekranda duran cumle yalandi.
///
/// Uygulama ici editor yazilana kadar dogru olan sey bunu SAKLAMAK
/// degil, DOGRU SOYLEMEK: proje bilgisayarda yapiliyor, adresi burada
/// yaziyor, gereksinimleri cocuk kendi isaretliyor.
///
/// Adres BAGLANTI DEGIL, duz yazi. 4+ derecelendirmeli bir cocuk
/// uygulamasindan disari acilan bir baglanti, ancak bir ebeveyn
/// kapisinin arkasinda olabilir; adresi yazmak hem yeterli hem risksiz.
String _nerede(String language, String lang) {
  switch (language) {
    case 'scratch':
      return lessonText(lang,
          'Bilgisayarında Scratch\'i aç: scratch.mit.edu — tarayıcıda '
              'açılır, kurulum gerekmez.',
          'Open Scratch on a computer: scratch.mit.edu — it runs in the '
              'browser, nothing to install.',
          'Öffne Scratch am Computer: scratch.mit.edu — läuft im Browser, '
              'keine Installation nötig.',
          'Abre Scratch en un ordenador: scratch.mit.edu — funciona en el '
              'navegador, sin instalar nada.');
    case 'mblock':
      return lessonText(lang,
          'Bilgisayarında mBlock 5\'i aç: mblock.cc adresinden indiriliyor.',
          'Open mBlock 5 on a computer: you can download it from mblock.cc.',
          'Öffne mBlock 5 am Computer: Download unter mblock.cc.',
          'Abre mBlock 5 en un ordenador: se descarga desde mblock.cc.');
    case 'cpp':
      return lessonText(lang,
          'Bilgisayarında mBlock 5 ya da Arduino IDE\'yi aç, kartını bağla.',
          'Open mBlock 5 or the Arduino IDE on a computer and plug in your '
              'board.',
          'Öffne mBlock 5 oder die Arduino IDE am Computer und schließe dein '
              'Board an.',
          'Abre mBlock 5 o el IDE de Arduino en un ordenador y conecta tu '
              'placa.');
    case 'html':
    case 'css':
      return lessonText(lang,
          'Bilgisayarında bir metin düzenleyicide yaz, dosyayı tarayıcıda aç.',
          'Write it in a text editor on a computer, then open the file in a '
              'browser.',
          'Schreib es am Computer in einem Texteditor und öffne die Datei '
              'im Browser.',
          'Escríbelo en un editor de texto en el ordenador y abre el archivo '
              'en un navegador.');
    case 'python':
      return lessonText(lang,
          'Bilgisayarında Python\'la yaz: python.org adresinden kuruluyor.',
          'Write it in Python on a computer: you can install it from '
              'python.org.',
          'Schreib es am Computer in Python: Installation über python.org.',
          'Escríbelo en Python en un ordenador: se instala desde python.org.');
    default:
      return lessonText(lang,
          'Bilgisayarında bir kod düzenleyicide yaz ve çalıştır.',
          'Write and run it in a code editor on a computer.',
          'Schreib und starte es am Computer in einem Code-Editor.',
          'Escríbelo y ejecútalo en un editor de código en un ordenador.');
  }
}

class ProjectStepWidget extends StatefulWidget {
  final ProjectStep step;
  final Course course;
  final bool isDark;

  /// `true` — cocuk projeyi yaptigini soyluyor (XP kazanir).
  /// `false` — "sonra yaparim" (ilerler, XP yok, azar da yok).
  final ValueChanged<bool> onComplete;

  const ProjectStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<ProjectStepWidget> createState() => _ProjectStepWidgetState();
}

class _ProjectStepWidgetState extends State<ProjectStepWidget> {
  /// Tezgahtaki kodun son hali (yalnizca html/css adimlarinda).
  String _kod = '';

  /// Bu adim uygulama icinde yapilabiliyor mu?
  bool get _tezgahliDil =>
      widget.step.language == 'html' || widget.step.language == 'css';

  /// Bos bir alani bos birakmak, cocugu bos bir sayfayla bas basa
  /// birakmak demek. Iskelet bir cevap DEGIL: yalnizca baslangic.
  String _iskelet(String dil) => dil == 'css'
      ? '<div class="kart">\n  <h2>Başlık</h2>\n  <p>Bir şeyler yaz.</p>\n</div>\n\n'
          '<style>\n.kart {\n  \n}\n</style>'
      : '<h1>Merhaba</h1>\n<p>Buraya yaz.</p>';

  /// Cocugun kendi isaretledigi gereksinimler.
  ///
  /// Bu bir SINAV degil, bir kontrol listesi. Uygulama projeyi goremiyor
  /// ve gordugunu iddia etmiyor; isaretlemenin isi cocugun kendi isini
  /// gozden gecirmesi.
  final Set<int> _isaretli = {};

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final hints = widget.step.hintsFor(lang);
    final gereksinimler = widget.step.requirementsFor(lang);
    // "Yaptim" iki sart istiyor: gereksinimlerin hepsi isaretli VE —
    // tezgahli bir adimsa — cocuk iskelete gercekten dokunmus olsun.
    // Ikincisi bir dogrulama degil, bir durustluk sarti: uygulama
    // tasarimin dogru olup olmadigini goremiyor ama hicbir sey
    // yazilmadigini gorebiliyor.
    final dokunuldu = !_tezgahliDil ||
        (_kod.trim().isNotEmpty &&
            _kod.trim() != _iskelet(widget.step.language).trim());
    final hepsiIsaretli =
        _isaretli.length == gereksinimler.length && dokunuldu;
    final metinRengi =
        widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baslik
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.course.primaryColor, widget.course.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lessonText(
                          lang, 'PROJE', 'PROJECT', 'PROJEKT', 'PROYECTO'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      widget.step.titleFor(lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          widget.step.descriptionFor(lang),
          style: TextStyle(fontSize: 16, height: 1.6, color: metinRengi),
        ),
        const SizedBox(height: 20),

        // HTML ve CSS PROJELERI UYGULAMA ICINDE YAPILIYOR.
        //
        // Editorun ilk asamasi bilerek burasi: HTML/CSS'i calistirmak
        // icin yorumlayiciya gerek yok, tarayicinin kendisi zaten
        // calistiriyor. Scratch ve Arduino projeleri (Blockly +
        // JS-Interpreter) sonraki asamalar; onlar hala "bilgisayarinda
        // yap" kartini goruyor.
        if (_tezgahliDil) ...[
          KodTezgahi(
            adimId: widget.step.id,
            baslangicKodu: widget.step.starterCode.trim().isEmpty
                ? _iskelet(widget.step.language)
                : widget.step.starterCode,
            onDegisti: (kod) => setState(() => _kod = kod),
          ),
          const SizedBox(height: 20),
        ] else
        // NEREDE YAPILACAK
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.course.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.course.primaryColor.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.computer_rounded,
                  color: widget.course.primaryColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lessonText(lang, 'Bunu bilgisayarında yapacaksın',
                          'You will do this on a computer',
                          'Das machst du am Computer',
                          'Esto lo harás en un ordenador'),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: widget.course.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nerede(widget.step.language, lang),
                      style: TextStyle(height: 1.45, color: metinRengi),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          lessonText(lang, 'Gereksinimler:', 'Requirements:', 'Anforderungen:',
              'Requisitos:'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),

        // Gereksinimler: cocugun kendi isaretledigi liste.
        for (var i = 0; i < gereksinimler.length; i++)
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() {
              if (!_isaretli.remove(i)) _isaretli.add(i);
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _isaretli.contains(i)
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked,
                    color: _isaretli.contains(i)
                        ? widget.course.primaryColor
                        : Colors.grey.shade400,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(gereksinimler[i],
                        style: TextStyle(color: metinRengi, height: 1.35)),
                  ),
                ],
              ),
            ),
          ),

        if (hints.isNotEmpty) ...[
          const SizedBox(height: 12),
          ExpansionTile(
            title:
                Text(lessonText(lang, 'İpuçları', 'Hints', 'Tipps', 'Pistas')),
            leading: const Icon(Icons.lightbulb_outline),
            children: hints
                .map((hint) => ListTile(
                      leading: const Text('💡'),
                      title: Text(hint),
                    ))
                .toList(),
          ),
        ],

        const SizedBox(height: 24),

        // Iki cikis: yaptim / sonra yaparim.
        //
        // "Sonra yaparim" bir basarisizlik degil ve oyle gosterilmiyor:
        // cocuk bilgisayar basinda olmayabilir ve dersin geri kalani
        // buna kilitlenmemeli. Tek fark XP: yapilmayan is odullenmiyor,
        // ama cocuk da azarlanmiyor.
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: hepsiIsaretli ? () => widget.onComplete(true) : null,
            icon: const Icon(Icons.check),
            label: Text(lessonText(
                lang,
                'Yaptım',
                'I did it',
                'Hab ich gemacht',
                'Lo hice')),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.course.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  widget.course.primaryColor.withValues(alpha: 0.35),
              disabledForegroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: () => widget.onComplete(false),
            child: Text(
              lessonText(lang, 'Sonra yaparım', 'I will do it later',
                  'Mache ich später', 'Lo haré más tarde'),
              style: TextStyle(color: metinRengi, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}


// ==========================================
// ANIMATION STEP WIDGET
// ==========================================

class AnimationStepWidget extends StatelessWidget {
  final AnimationStep step;
  final Course course;
  final bool isDark;
  final VoidCallback onComplete;

  const AnimationStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          step.titleFor(lang),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          step.descriptionFor(lang),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 24),

        // Animation based on type
        if (step.animationType == AnimationType.comparison)
          _buildComparisonAnimation(lang),

        const SizedBox(height: 32),

        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: course.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
                lessonText(lang, 'Devam', 'Continue', 'Weiter', 'Continuar'),
                style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonAnimation(String lang) {
    final beforeItems = step.animationData['before'] as List<dynamic>? ?? [];
    final afterItems = step.animationData['after'] as List<dynamic>? ?? [];

    return Row(
      children: [
        // Before (Without loop)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.close,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    // Iki kusur birden: metin dort dilde DEGILDI (ders
                    // Almanca calisirken burada Turkce yaziyordu) ve
                    // aksanlari soyulmustu. Ustune Row, iPhone SE'de 36
                    // piksel tasiyordu — Expanded olmadan uzun bir etiket
                    // ikonla birlikte sutuna sigmiyor.
                    Expanded(
                      child: Text(
                      lessonText(lang, 'Döngüsüz', 'Without a loop',
                          'Ohne Schleife', 'Sin bucle'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...beforeItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C97FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // After (With loop)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: course.primaryColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: course.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                      lessonText(lang, 'Döngülü', 'With a loop',
                          'Mit Schleife', 'Con bucle'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...afterItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFAB19),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// ==========================================
// Loop Calculator Game - Mini Game for Loop Lesson
// ==========================================

class LoopCalculatorGame extends StatefulWidget {
  final MiniGameStep step;
  final Course course;
  final bool isDark;
  final Function(int score) onComplete;

  const LoopCalculatorGame({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<LoopCalculatorGame> createState() => _LoopCalculatorGameState();
}

class _LoopCalculatorGameState extends State<LoopCalculatorGame> {
  int currentLevel = 0;
  int score = 0;
  int? selectedAnswer;
  bool? isCorrect;

  final List<Map<String, int>> levels = [
    {'stepSize': 10, 'target': 30},
    {'stepSize': 5, 'target': 25},
    {'stepSize': 15, 'target': 45},
    {'stepSize': 8, 'target': 40},
    {'stepSize': 12, 'target': 60},
  ];

  /// Bu seviyenin siklari.
  ///
  /// Eskiden `build()` icinde uretiliyordu: cocuk bir sikka dokundugu
  /// anda setState calisiyor, YANLIS siklar yeni degerler aliyor ve
  /// dortu birden yer degistiriyordu. Yesil "dogru" isareti de o an
  /// dogru sayinin bulundugu karonun uzerine duruyordu — geri bildirim
  /// karesi tamamen tutarsizdi. Seviye basina bir kez uretiliyor.
  late List<int> _siklar;

  @override
  void initState() {
    super.initState();
    _siklar = _generateAnswers();
  }

  int _getCorrectAnswer() {
    final level = levels[currentLevel];
    return level['target']! ~/ level['stepSize']!;
  }

  List<int> _generateAnswers() {
    final correct = _getCorrectAnswer();
    final answers = <int>{correct};

    final random = Random();
    while (answers.length < 4) {
      final offset = random.nextInt(5) - 2;
      final candidate = correct + offset;
      if (candidate > 0 && candidate != correct) {
        answers.add(candidate);
      }
    }

    final list = answers.toList()..shuffle();
    return list;
  }

  void _selectAnswer(int answer) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = answer;
      isCorrect = answer == _getCorrectAnswer();
      if (isCorrect!) {
        score += 20;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentLevel < levels.length - 1) {
        setState(() {
          currentLevel++;
          selectedAnswer = null;
          isCorrect = null;
          _siklar = _generateAnswers();
        });
      } else {
        widget.onComplete(score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final level = levels[currentLevel];
    final answers = _siklar;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Score header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.course.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seviye ${currentLevel + 1}/${levels.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '$score puan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Question
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.course.primaryColor,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  lessonText(
                  lang,
                  '🐱 Kediyi yürütmek için:',
                  '🐱 To make the cat walk:',
                  '🐱 Damit die Katze läuft:',
                  '🐱 Para que el gato camine:'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C97FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    lessonText(
                        lang,
                        '"${level['stepSize']} adım git" bloğunu',
                        'the "move ${level['stepSize']} steps" block',
                        'den Block "gehe ${level['stepSize']} er Schritt"',
                        'el bloque "mover ${level['stepSize']} pasos"'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lessonText(
                      lang,
                      'Toplam ${level['target']} adım gitmek için',
                      'to travel ${level['target']} steps in total',
                      'um insgesamt ${level['target']} Schritte zu gehen',
                      'para recorrer ${level['target']} pasos en total'),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  lessonText(
                  lang,
                  'kaç kere tekrarlamalıyız?',
                  'how many times should we repeat it?',
                  'wie oft müssen wir das wiederholen?',
                  '¿cuántas veces hay que repetirlo?'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.course.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Answer options (2x2 grid)
          SizedBox(
            height: 400,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: answers.map((answer) {
                final isSelected = selectedAnswer == answer;
                final isThisCorrect = answer == _getCorrectAnswer();

                Color? backgroundColor;
                if (isSelected) {
                  backgroundColor = isCorrect! ? Colors.green : Colors.red;
                } else if (selectedAnswer != null && isThisCorrect) {
                  backgroundColor = Colors.green;
                }

                return InkWell(
                  onTap: () => _selectAnswer(answer),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor ?? const Color(0xFFFFAB19),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$answer',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            // Dort dilde de ayni karonun altinda duruyor;
                            // `const` oldugu icin Almancada da "kere"
                            // yaziyordu.
                            lessonText(lang, 'kere', 'times', 'mal', 'veces'),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CODE COMPLETE / TYPE CODE / SPOT ERROR
// ==========================================
//
// Bu uc adim tipi icerikte VARDI ama ekranda hicbir karsiligi yoktu:
// interactive_lesson_screen.dart'in `default` dali "Step tipi henüz
// desteklenmiyor: StepType.typeTheCode" yaziyordu. Python, Arduino ve
// HTML derslerinde toplam 24 adim boyle bir hata metnine dusuyordu —
// yani ders ortasinda cocuk bos bir ekranla karsilasip devam ediyordu.

/// Ortak kod govdesi: koyu zeminli, tek aralikli, kaydirilabilir.
class _CodeSurface extends StatelessWidget {
  const _CodeSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: child,
      ),
    );
  }
}

/// Adimin basindaki yonerge kartı.
class _StepPrompt extends StatelessWidget {
  const _StepPrompt({
    required this.emoji,
    required this.text,
    required this.isDark,
  });

  final String emoji;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 17,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kodu tamamla: sablondaki `___` yerlerine dogru parcayi sec.
///
/// Yazdirmak yerine SECTIRIYORUZ. 7-14 yas araligindaki bir cocuk icin
/// telefon klavyesinde `range(` yazmak dersin konusu degil, engeli;
/// yanlislarin cogu yazim hatasi oluyor ve cocuk neyi bilmedigini degil
/// nereye dokunacagini ogreniyor. Secenekler dogru cevap + diger
/// bosluklarin cevaplari + kabul edilen alternatiflerden uretiliyor,
/// yani sasirtici ama ilgili.
class CodeCompleteStepWidget extends StatefulWidget {
  final CodeCompleteStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const CodeCompleteStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<CodeCompleteStepWidget> createState() => _CodeCompleteStepWidgetState();
}

class _CodeCompleteStepWidgetState extends State<CodeCompleteStepWidget> {
  /// Bosluk sirasina gore secilen cevaplar.
  late List<String?> _filled;
  bool _answered = false;

  List<CodeBlank> get _blanks {
    final list = [...widget.step.blanks]..sort((a, b) => a.index.compareTo(b.index));
    return list;
  }

  @override
  void initState() {
    super.initState();
    _filled = List<String?>.filled(_blanks.length, null);
  }

  /// Bir bosluk icin secenekler.
  List<String> _choicesFor(int i) {
    final blank = _blanks[i];
    final set = <String>{blank.correctAnswer};
    for (final alt in blank.acceptableAlternatives ?? const <String>[]) {
      set.add(alt);
    }
    for (var j = 0; j < _blanks.length; j++) {
      if (j != i) set.add(_blanks[j].correctAnswer);
    }
    final list = set.toList()..shuffle(Random('${widget.step.id}_$i'.hashCode));
    return list;
  }

  bool _isRight(int i, String value) {
    final blank = _blanks[i];
    if (value == blank.correctAnswer) return true;
    return (blank.acceptableAlternatives ?? const <String>[]).contains(value);
  }

  bool get _allFilled => !_filled.contains(null);
  bool get _allRight {
    for (var i = 0; i < _filled.length; i++) {
      if (_filled[i] == null || !_isRight(i, _filled[i]!)) return false;
    }
    return true;
  }

  /// Sablonu `___` isaretlerinden bolup boslukları gomulu rozet yapiyor.
  Widget _template(String lang) {
    final parts = widget.step.codeTemplate.split('___');
    final spans = <InlineSpan>[];
    for (var i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: const TextStyle(
          fontFamily: 'monospace',
          color: Color(0xFFD4D4D4),
          fontSize: 14,
          height: 1.55,
        ),
      ));
      if (i < parts.length - 1 && i < _filled.length) {
        final value = _filled[i];
        final ok = value != null && _isRight(i, value);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: value == null
                  ? Colors.white.withValues(alpha: 0.10)
                  : (_answered
                          ? (ok
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828))
                          : widget.course.primaryColor)
                      .withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              value ?? '?',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ));
      }
    }
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final blanks = _blanks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepPrompt(
          emoji: '🧩',
          text: widget.step.instructionFor(lang),
          isDark: widget.isDark,
        ),
        const SizedBox(height: 20),
        _CodeSurface(child: _template(lang)),
        const SizedBox(height: 20),

        for (var i = 0; i < blanks.length; i++) ...[
          Text(
            '${i + 1}. ${blanks[i].hintFor(lang)}',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _choicesFor(i).map((choice) {
              final selected = _filled[i] == choice;
              return GestureDetector(
                onTap: _answered
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        setState(() => _filled[i] = choice);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? widget.course.primaryColor.withValues(alpha: 0.14)
                        : (widget.isDark
                            ? const Color(0xFF1E1E2E)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? widget.course.primaryColor
                          : (widget.isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    choice,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.normal,
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        if (!_answered)
          PressButton(
            label: lessonText(lang, 'Kontrol Et', 'Check', 'Prüfen', 'Comprobar'),
            icon: Icons.check_rounded,
            color: widget.course.primaryColor,
            onPressed: _allFilled
                ? () {
                    setState(() => _answered = true);
                    if (_allRight) {
                      SoundService.playSoruDogru();
                    } else {
                      SoundService.playWrong();
                    }
                  }
                : null,
          )
        else
          AnswerFeedbackBar(
            inline: true,
            result: _allRight ? AnswerResult.correct : AnswerResult.wrong,
            detail: _allRight
                ? widget.step.expectedOutput
                : blanks
                    .map((b) => b.correctAnswer)
                    .join('  •  '),
            onContinue: () => widget.onComplete(_allRight),
          ),
      ],
    );
  }
}

/// Kodu kendin yaz.
///
/// Karsilastirma bilerek TOLERANSLI: bastaki/sondaki bosluklar, satir
/// sonlari ve satir aralarindaki fazla bosluk yok sayiliyor. Tek nokta
/// virgul farkindan dolayi "yanlis" demek, dersin ogretmek istedigi seyi
/// degil klavye kullanimini olcer.
class TypeCodeStepWidget extends StatefulWidget {
  final TypeCodeStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const TypeCodeStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<TypeCodeStepWidget> createState() => _TypeCodeStepWidgetState();
}

class _TypeCodeStepWidgetState extends State<TypeCodeStepWidget> {
  late final TextEditingController _controller;
  bool _answered = false;
  bool _correct = false;
  int _hintsShown = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.step.starterCode ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Bosluk ve satir sonu farklarini yok sayan karsilastirma.
  String _normalise(String code) => code
      .split('\n')
      .map((line) => line.trim().replaceAll(RegExp(r'\s+'), ' '))
      .where((line) => line.isNotEmpty)
      .join('\n');

  void _check() {
    final ok = _normalise(_controller.text) == _normalise(widget.step.targetCode);
    setState(() {
      _answered = true;
      _correct = ok;
    });
    if (ok) {
      SoundService.playSoruDogru();
    } else {
      SoundService.playWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final hints = widget.step.hintsFor(lang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepPrompt(
          emoji: '⌨️',
          text: widget.step.instructionFor(lang),
          isDark: widget.isDark,
        ),
        const SizedBox(height: 20),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _answered
                  ? (_correct ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                  : Colors.white.withValues(alpha: 0.10),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: TextField(
            controller: _controller,
            enabled: !_answered,
            maxLines: null,
            minLines: 4,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.multiline,
            // KONTROL ET TUSU YAZI YAZILINCA ACILIYOR.
            //
            // Tusun `onPressed`'i `_controller.text` bos mu diye
            // bakiyor, ama bu yalnizca build sirasinda olculuyordu ve
            // denetleyicinin degismesi tek basina yeniden cizim
            // baslatmiyor. Sonuc: cocuk kodu yaziyor, tus GRI kaliyor
            // ve adimi hic tamamlayamiyordu (klavye acilirken olan
            // yeniden cizim metin daha bosken gerceklesiyor).
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              height: 1.5,
              color: Color(0xFFD4D4D4),
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: lessonText(lang, 'Kodu buraya yaz...', 'Type the code here...', 'Schreib den Code hierher …', 'Escribe el código aquí…'),
              hintStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Ipuclari tek tek aciliyor: hepsi birden acilirsa cevap bedava.
        if (hints.isNotEmpty && !_answered) ...[
          for (var i = 0; i < _hintsShown && i < hints.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hints[i],
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13.5,
                        height: 1.4,
                        color: widget.isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_hintsShown < hints.length)
            TextButton.icon(
              onPressed: () => setState(() => _hintsShown++),
              icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
              label: Text(
                lessonText(lang, 'İpucu ver', 'Give me a hint', 'Gib mir einen Tipp', 'Dame una pista'),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: widget.course.primaryColor,
              ),
            ),
          const SizedBox(height: 8),
        ],

        if (!_answered)
          PressButton(
            label: lessonText(lang, 'Kontrol Et', 'Check', 'Prüfen', 'Comprobar'),
            icon: Icons.play_arrow_rounded,
            color: widget.course.primaryColor,
            onPressed: _controller.text.trim().isEmpty ? null : _check,
          )
        else ...[
          if (!_correct) ...[
            Text(
              lessonText(lang, 'Doğrusu:', 'The answer:', 'Die Antwort:', 'La respuesta:'),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            _CodeSurface(
              child: Text(
                widget.step.targetCode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13.5,
                  height: 1.5,
                  color: Color(0xFFD4D4D4),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          AnswerFeedbackBar(
            inline: true,
            result: _correct ? AnswerResult.correct : AnswerResult.wrong,
            detail: _correct ? widget.step.expectedOutput : null,
            onContinue: () => widget.onComplete(_correct),
          ),
        ],
      ],
    );
  }
}

/// Hatayi bul: kod satir satir, dokunulan satir secim.
class SpotErrorStepWidget extends StatefulWidget {
  final SpotErrorStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const SpotErrorStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<SpotErrorStepWidget> createState() => _SpotErrorStepWidgetState();
}

class _SpotErrorStepWidgetState extends State<SpotErrorStepWidget> {
  int? _picked;
  bool get _answered => _picked != null;

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final lines = widget.step.code.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepPrompt(
          emoji: '🔍',
          text: widget.step.instructionFor(lang),
          isDark: widget.isDark,
        ),
        const SizedBox(height: 20),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: List.generate(lines.length, (i) {
              final lineNo = i + 1;
              final isError = lineNo == widget.step.errorLine;
              final isPicked = _picked == lineNo;

              Color background = Colors.transparent;
              if (_answered) {
                if (isError) {
                  background = const Color(0xFF2E7D32).withValues(alpha: 0.35);
                } else if (isPicked) {
                  background = const Color(0xFFC62828).withValues(alpha: 0.35);
                }
              }

              return GestureDetector(
                onTap: _answered
                    ? null
                    : () {
                        // Hatali satiri bulmak da bir soru: dogru satira
                        // dokunmak ayni sesi veriyor.
                        if (lineNo == widget.step.errorLine) {
                          SoundService.playSoruDogru();
                        } else {
                          SoundService.playWrong();
                        }
                        setState(() => _picked = lineNo);
                      },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: background,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '$lineNo',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          lines[i].isEmpty ? ' ' : lines[i],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13.5,
                            height: 1.45,
                            color: Color(0xFFD4D4D4),
                          ),
                        ),
                      ),
                      if (_answered && isError)
                        const Icon(Icons.bug_report_rounded,
                            size: 18, color: Colors.white),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        if (_answered) ...[
          Text(
            lessonText(lang, 'Düzeltilmiş hâli:', 'The fix:', 'So ist es richtig:', 'Así queda bien:'),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          _CodeSurface(
            child: Text(
              widget.step.correctCode,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFFD4D4D4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnswerFeedbackBar(
            inline: true,
            result: _picked == widget.step.errorLine
                ? AnswerResult.correct
                : AnswerResult.wrong,
            detail: widget.step.explanationFor(lang),
            onContinue: () =>
                widget.onComplete(_picked == widget.step.errorLine),
          ),
        ] else
          Text(
            lessonText(lang, 'Hatalı satıra dokun.', 'Tap the line with the bug.', 'Tippe auf die Zeile mit dem Fehler.', 'Toca la línea que tiene el fallo.'),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13.5,
              color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
      ],
    );
  }
}
