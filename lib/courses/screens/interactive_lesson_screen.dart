import 'dart:async';
import 'package:flutter/material.dart';
import '../../ui/ekran_olcusu.dart';
import '../../widgets/playful_background.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../../providers/auth_provider.dart';
import 'widgets/ders_arkadasi.dart';
import 'widgets/ders_ilerleme_cubugu.dart';
import 'widgets/devi_tepkisi.dart';
import 'widgets/mblock_blok_adimi.dart';
import 'widgets/mblock_tezgahi.dart' show MBlockWebHavuzu;
import 'widgets/proje_atolyesi.dart';
import 'widgets/step_widgets.dart';
import 'package:confetti/confetti.dart';
import '../../theme.dart';
import '../../ui/count_up.dart';
import '../../ui/motion.dart';
import '../../ui/press_button.dart';
import '../../widgets/cikis_penceresi.dart';
import '../../services/sound_service.dart';
import '../../widgets/mascot.dart';
import '../data/course_modules.dart';
import '../data/rozet_katalogu.dart';
import '../../services/user_progress_service.dart';
import '../../services/ad_unlock_service.dart';
import '../../services/ders_ilerleme_deposu.dart';
import '../../utils/pro_gate.dart';
import '../tanitim/kurs_kapanis_ekrani.dart';
import '../tanitim/modul_kutlamasi.dart';

/// Modern, Interactive Lesson Screen
/// FreeCodeCamp-inspired step-by-step learning experience
class InteractiveLessonScreen extends StatefulWidget {
  final Course course;
  final InteractiveLesson lesson;

  const InteractiveLessonScreen({
    super.key,
    required this.course,
    required this.lesson,
  });

  @override
  State<InteractiveLessonScreen> createState() => _InteractiveLessonScreenState();
}

class _InteractiveLessonScreenState extends State<InteractiveLessonScreen>
    with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  int _earnedXp = 0;
  bool _currentStepCompleted = false;
  final Map<String, bool> _completedSteps = {};

  /// XP'si verilmis adimlar. Bir adim tekrar tamamlaninca (geri gelip
  /// yeniden cevaplamak, blok kurma adiminin ic DEVAM tusu, "Yaptim"a
  /// iki kez basmak) XP yeniden eklenmiyordu degil — EKLENIYORDU; ust
  /// cubuktaki XP ve dersin toplam XP'si boylece sisiyordu.
  final Set<String> _xpVerilenAdimlar = {};

  /// Ders bitiriliyor: "Tamamla"ya ikinci kez basmak dersi iki kez
  /// kaydetmesin (iki kez XP, iki kutlama penceresi).
  bool _bitiriliyor = false;

  late AnimationController _celebrationController;

  LessonStep get _currentStep => widget.lesson.steps[_currentStepIndex];
  bool get _isLastStep => _currentStepIndex == widget.lesson.steps.length - 1;
  bool get _isFirstStep => _currentStepIndex == 0;

  @override
  void initState() {
    super.initState();
    // mBlock: tezgah sayfasi (2,1 MB scratch-blocks) tanitim adiminda
    // arka planda yukleniyor; ilk blok kurma adiminda hazir bekliyor.
    if (_mblockTezgahli) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => MBlockWebHavuzu.isit());
    }
    // Kurs "baslanmis" sayilsin: ders bitirilmeden cikilsa bile kurs
    // sayfasi ve ana sayfa artik "basla" degil "kaldigin yerden devam
    // et" diyor. Saglayicisiz agaclarda (bazi testler) sessizce geciyor.
    try {
      unawaited(Provider.of<AuthProvider>(context, listen: false)
          .kursAcildi(widget.course.id));
    } on ProviderNotFoundException {
      // Saglayici yoksa kaydedecek yer de yok.
    }
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _adimKaydirma?.dispose();
    // mBlock tezgahinin paylasilan WebView'i ders boyunca yasiyor; ders
    // kapaninca bellek geri veriliyor.
    if (_mblockTezgahli) MBlockWebHavuzu.serbestBirak();
    super.dispose();
  }

  /// Derste gercek mBlock tezgahi kullanan bir adim var mi?
  late final bool _mblockTezgahli = widget.lesson.steps
      .any((s) => s is BlockBuilderStep && s.mblock != null);

  /// [stepId] adimi tamamlandi.
  ///
  /// Kimlik ACIKCA veriliyor: adimlarin bazilari tamamlanmayi gecikmeyle
  /// bildiriyor (coktan secmeli 500 ms sonra). O arada cocuk baska bir
  /// adima gectiyse "su anki adim" baska bir adim oluyordu.
  ///
  /// XP her adim icin YALNIZCA ILK tamamlanista veriliyor.
  void _onStepCompleted(String stepId, {int xpEarned = 0}) {
    if (!mounted) return;
    final ilkKez = _xpVerilenAdimlar.add(stepId);
    setState(() {
      _completedSteps[stepId] = true;
      if (stepId == _currentStep.id) _currentStepCompleted = true;
      if (ilkKez) _earnedXp += xpEarned;
    });
    HapticFeedback.mediumImpact();
  }

  void _nextStep() {
    if (_isLastStep) {
      _completeLesson();
      return;
    }

    setState(() {
      _currentStepIndex++;
      _currentStepCompleted = _completedSteps[_currentStep.id] ?? false;
    });
    HapticFeedback.lightImpact();
  }

  void _previousStep() {
    if (_isFirstStep) return;

    setState(() {
      _currentStepIndex--;
      _currentStepCompleted = _completedSteps[_currentStep.id] ?? false;
    });
  }

  Future<void> _completeLesson() async {
    if (_bitiriliyor) return;
    setState(() => _bitiriliyor = true);
    // Add XP
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tamXp = _earnedXp + widget.lesson.xpReward;

    // TEKRAR: biten bir ders yeniden bitirilince XP'nin dortte biri,
    // jeton yok (bkz. UserProgressService.dersiKaydet). Pencere de
    // gercekten verileni gosteriyor.
    final tekrar = authProvider.tamamlananDersler.contains(widget.lesson.id);
    final totalXp = tekrar ? UserProgressService.tekrarXp(tamXp) : tamXp;

    // ROZET: yalnizca ILK bitiste ve daha once kazanilmamissa "YENI".
    final rozet = widget.lesson.badge;
    final yeniRozet =
        rozet != null && !tekrar && !authProvider.rozetVar(rozet);

    // XP + 8 jeton + dersin kimligi tek yerde. Eskiden yalnizca XP ve
    // jeton veriliyordu, ders "bitti" diye hic yazilmiyordu; kurs
    // ilerlemesi ve veli raporu bu yuzden sifirda kaliyordu.
    //
    // Oturum kontrolu YOK: ders once cihaza yaziliyor (oturum henuz
    // acilmamis olsa bile), sunucu kismini dersTamamlandi kendisi atliyor.
    await authProvider.dersTamamlandi(widget.lesson.id, tamXp, rozet: rozet);

    // SERI: bugun bir ders bitti. Gunler cihazda (bkz. DersSerisi).
    final seri = await DersSerisi.bugunuIsle();

    // KURS BITTI MI? Son ders bittiyse ve kapanis daha once
    // gosterilmediyse, "Harika!"dan sonra kurs sayfasina degil kapanis
    // torenine gidiliyor. Kontrol burada (kurs sayfasinda degil), cunku
    // son ders ana sayfadan ya da yol seridinden de acilabiliyor.
    final kapanis = await KursKapanisEkrani.gosterilmeli(
        widget.course.id, authProvider.tamamlananDersler);

    // MODUL BITTI MI? Kurs bitmediyse ve bu dersle modulun butun dersleri
    // tamamlandiysa (ilk kez), pencereden sonra modul kutlamasi.
    final modulNo = kapanis
        ? null
        : await ModulKutlamaEkrani.gosterilmeli(widget.course.id,
            widget.lesson.id, authProvider.tamamlananDersler);

    final sonraki = await _sonrakiDers();

    // Show completion dialog
    if (mounted) {
      _showCompletionDialog(totalXp,
          kapanis: kapanis,
          yeniRozet: yeniRozet ? rozet : null,
          seri: seri,
          sonraki: sonraki,
          modulNo: modulNo);
    }
  }

  /// Kursta bu dersten sonra gelen ders; kurs bittiyse ya da o ders
  /// kilitliyse (Pro kurs, Pro degil, reklamla acilmamis) null.
  ///
  /// KILIT ATLANMIYOR: "Siradaki ders" dugmesi dersi dogrudan aciyor;
  /// kilitli bir derse kapidan gecmeden girilmesin diye kilitliyse dugme
  /// hic cikmiyor (cocuk listeden acar, kapi orada).
  Future<InteractiveLesson?> _sonrakiDers() async {
    final dersler = CourseModules.allLessons(widget.course.id);
    final i = dersler.indexWhere((l) => l.id == widget.lesson.id);
    if (i < 0 || i + 1 >= dersler.length) return null;
    final sonraki = dersler[i + 1];
    if (!widget.course.isPremium) return sonraki;
    try {
      if (ProGate.isPro(context)) return sonraki;
    } on ProviderNotFoundException {
      return null;
    }
    final acik =
        await AdUnlockService.instance.acikMi(widget.course.id, sonraki.id);
    return acik ? sonraki : null;
  }

  void _showCompletionDialog(int totalXp,
      {bool kapanis = false,
      String? yeniRozet,
      int seri = 0,
      InteractiveLesson? sonraki,
      int? modulNo}) {
    final nav = Navigator.of(context);
    final biten = () {
      try {
        return Provider.of<AuthProvider>(context, listen: false)
            .tamamlananDersler;
      } on ProviderNotFoundException {
        return <String>{};
      }
    }();

    Route<void> dersRotasi(InteractiveLesson l) => MaterialPageRoute(
          builder: (_) =>
              InteractiveLessonScreen(course: widget.course, lesson: l),
        );

    // Modul bittiyse iki dugme de once kutlamaya gidiyor; kutlamanin
    // kendi "Siradaki ders" ve "Listeye don" dugmeleri var.
    void kutlamayaGec(BuildContext dialogContext) {
      Navigator.pop(dialogContext);
      nav.pushReplacement(MaterialPageRoute(
        settings: const RouteSettings(name: 'modul_kutlamasi'),
        builder: (_) => ModulKutlamaEkrani(
          course: widget.course,
          modulNo: modulNo!,
          biten: biten,
          sonrakiDers: sonraki,
          onSonrakiDers:
              sonraki == null ? null : () => nav.pushReplacement(dersRotasi(sonraki)),
        ),
      ));
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _LessonCompleteDialog(
        course: widget.course,
        lesson: widget.lesson,
        totalXp: totalXp,
        badge: yeniRozet,
        seri: seri,
        sonrakiDers: kapanis ? null : sonraki,
        onSonraki: kapanis || sonraki == null
            ? null
            : () {
                if (modulNo != null) {
                  kutlamayaGec(dialogContext);
                  return;
                }
                Navigator.pop(dialogContext);
                nav.pushReplacement(dersRotasi(sonraki));
              },
        onListe: () {
          if (modulNo != null) {
            kutlamayaGec(dialogContext);
            return;
          }
          Navigator.pop(dialogContext);
          nav.pop();
        },
        onDevam: kapanis
            ? () {
                Navigator.pop(dialogContext);
                nav.pushReplacement(MaterialPageRoute(
                  builder: (ctx) => KursKapanisEkrani.kur(ctx, widget.course),
                ));
              }
            : null,
      ),
    );
  }

  /// Dersin kurs icindeki sirasi (1'den). Kursta yoksa null.
  late final int? _dersNo = () {
    final i = CourseModules.allLessons(widget.course.id)
        .indexWhere((l) => l.id == widget.lesson.id);
    return i < 0 ? null : i + 1;
  }();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // DURUM CUBUGU STILI ACIKCA VERILIYOR.
    //
    // Bu ekranda AppBar yok; Flutter da ust bolgede bir stil bulamayinca
    // bir onceki ekraninkini birakiyordu. Kurs sayfasinin basligi kursun
    // renginde: Python'un koyu mavisinde beyaz yazi secilmisti, ders
    // ekraninin acik zemininde saat ve pil neredeyse gorunmuyordu
    // (Scratch'in turuncusunda koyu yazi secildigi icin orada sorun
    // yoktu). Zemin acik/koyu temaya gore sabit, stil de ona gore.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FB),
      // Ders ekraninin zemini duz griydi. Artik kursun renginde, cok
      // yavas suzulen kodlama sembolleri var (blok, disli, ok, dugum,
      // parantez). Dikkat calmiyor — metin hala en belirgin sey — ama
      // ekran "bos bir form" gibi durmuyor. "Hareketi azalt" acikken
      // PlayfulBackground hicbir sey cizmiyor.
      body: PlayfulBackground(
        baseColor:
            isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FB),
        tint: widget.course.primaryColor,
        symbolCount: 14,
        child: SafeArea(
        child: Column(
          children: [
            // Top bar with progress
            _buildTopBar(isDark),

            // Progress indicator
            _buildProgressBar(isDark),

            // Step content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                // Icerik USTE hizali: varsayilan ortalama, kisa adimlari
                // ekranin ortasina itip ustte bos bir alan birakiyordu.
                layoutBuilder: (simdiki, oncekiler) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...oncekiler, if (simdiki != null) simdiki],
                ),
                child: _buildStepContent(isDark),
              ),
            ),

            // Bottom navigation
            _buildBottomBar(isDark),
          ],
        ),
        ),
      ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    final lang = lessonLang(context);
    final n = widget.lesson.steps.length;
    final renk = widget.course.primaryColor;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 10),
      child: Row(
        children: [
          // Kapat: beyaz, hafif golgeli bir daire (onceden gri zemin
          // uzerinde gri bir daireydi, desenin icinde kayboluyordu).
          IconButton(
            tooltip: lessonText(lang, 'Kapat', 'Close', 'Schließen', 'Cerrar'),
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Icon(
                Icons.close_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF4B5068),
                size: 20,
              ),
            ),
            onPressed: () => _showExitConfirmation(),
          ),

          const SizedBox(width: 6),

          // Ders adi ve adim sayaci.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lesson.titleFor(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1B2140),
                  ),
                ),
                const SizedBox(height: 1),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: lessonText(lang, 'Adım ', 'Step ', 'Schritt ',
                          'Paso '),
                    ),
                    TextSpan(
                      text: '${_currentStepIndex + 1}',
                      style: TextStyle(
                        color: isDark ? Colors.white : renk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(text: ' / $n'),
                  ]),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey.shade500 : const Color(0xFF7A8098),
                  ),
                ),
              ],
            ),
          ),

          // Kazanilan XP. Yazi onceden sari zemin uzerinde sariydi
          // (Colors.amber): okunmuyordu. Koyu altin rengi.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.amber.withValues(alpha: 0.15)
                  : const Color(0xFFFFF1C7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFF5B92E).withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF2A91E), size: 18),
                const SizedBox(width: 3),
                Text(
                  '+$_earnedXp',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: isDark ? Colors.amber.shade200 : const Color(0xFF8A5A00),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    // TEK PARCA YOL: parca parca dolan cubugun yerine yumusak bir dolgu,
    // ucunda Devi ve sonunda kupa (bkz. DersIlerlemeCubugu).
    final n = widget.lesson.steps.length;
    final lang = lessonLang(context);
    final no = _currentStepIndex + 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 14, 2),
      child: DersIlerlemeCubugu(
        adim: _currentStepIndex,
        toplam: n,
        renk: widget.course.primaryColor,
        renk2: widget.course.secondaryColor,
        koyu: isDark,
        etiket: lessonText(lang, 'Adım $no/$n', 'Step $no/$n',
            'Schritt $no/$n', 'Paso $no/$n'),
      ),
    );
  }

  /// Alttaki Devi arkadasi olan adim turleri ve arkadasin konusma turu.
  ///
  /// Kendi Devi'si olan (giris, blok kurma, mBlock, atolye) ya da ekrani
  /// kendisi dolduran (mini oyun, proje) adimlarda arkadas YOK.
  static const Map<StepType, DersArkadasiTuru> _arkadasTurleri = {
    StepType.explanation: DersArkadasiTuru.anlatim,
    StepType.animation: DersArkadasiTuru.anlatim,
    StepType.multipleChoice: DersArkadasiTuru.soru,
    StepType.dragAndDrop: DersArkadasiTuru.uygulama,
    StepType.ordering: DersArkadasiTuru.uygulama,
    StepType.matching: DersArkadasiTuru.uygulama,
    StepType.codeComplete: DersArkadasiTuru.uygulama,
    StepType.typeTheCode: DersArkadasiTuru.uygulama,
    StepType.spotTheError: DersArkadasiTuru.uygulama,
  };

  /// Adimlara verilen cevaplar (dogru mu). Devi arkadasi buna tepki
  /// veriyor; geri gelinince tepki yerinde duruyor.
  final Map<String, bool> _cevaplar = {};

  /// Her yeni cevapta artiyor: Devi yeniden zipliyor.
  int _tepkiNo = 0;

  /// Simdiki adimin kaydirma denetleyicisi (arkadasa kaydirmak icin).
  ScrollController? _adimKaydirma;
  String? _adimKaydirmaId;

  void _cevapVerildi(String stepId, bool dogru) {
    if (!mounted) return;
    setState(() {
      _cevaplar[stepId] = dogru;
      _tepkiNo++;
    });
    // Cevap ve aciklama ekranin altinda kaldiysa (kucuk ekran) Devi'nin
    // tepkisi gorunsun diye sona kaydiriliyor; aciklama hemen ustunde.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final k = _adimKaydirma;
      if (!mounted || k == null || !k.hasClients) return;
      final p = k.position;
      if (p.maxScrollExtent <= p.pixels + 1) return;
      if (Motion.reduced(context)) {
        k.jumpTo(p.maxScrollExtent);
      } else {
        k.animateTo(p.maxScrollExtent,
            duration: Motion.long2, curve: Motion.emphasized);
      }
    });
  }

  /// Uygulama adimi (surukle-birak, kod...) bitti: XP ve Devi'nin tepkisi.
  void _uygulamaBitti(String stepId, bool dogru, int xp) {
    _cevapVerildi(stepId, dogru);
    _onStepCompleted(stepId, xpEarned: dogru ? xp : 0);
  }

  Widget _buildStepContent(bool isDark) {
    final step = _currentStep;

    // Dolgu ekran boyuna gore: iPhone SE'de her kenardan 20 pt,
    // ustelik adimlarin kendi ic araliklariyla birlikte, icerigi
    // gereksiz yere ekranin disina itiyordu.
    final dolgu = EkranOlcusu.kisa(context) ? 12.0 : 20.0;
    final arkadasTuru = _arkadasTurleri[step.type];
    if (arkadasTuru == null) {
      return SingleChildScrollView(
        key: ValueKey(step.id),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(dolgu, dolgu, dolgu, dolgu + 8),
        child: _buildStepWidget(step, isDark),
      );
    }

    // BOS ALANI DEVI DOLDURUYOR.
    //
    // Kisa adimlar ekranin ust yarisinda bitiyor, alt yari bos kaliyordu.
    // Icerik ustte; kalan yeri SliverFillRemaining dolduruyor ve Devi
    // arkadasi orada, alta yakin duruyor. Icerik uzunsa arkadas icerigin
    // ALTINDA kaliyor ve kaydirilarak goruluyor — hicbir sey tasmiyor.
    if (_adimKaydirmaId != step.id) {
      _adimKaydirma?.dispose();
      _adimKaydirma = ScrollController();
      _adimKaydirmaId = step.id;
    }
    final lang = lessonLang(context);
    final cevap = _cevaplar[step.id];
    final uzun = MediaQuery.sizeOf(context).height >= 800;
    return CustomScrollView(
      key: ValueKey(step.id),
      controller: _adimKaydirma,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(dolgu, dolgu, dolgu, 0),
          sliver: SliverToBoxAdapter(child: _buildStepWidget(step, isDark)),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(dolgu + 4, 18, dolgu, dolgu + 6),
            child: Align(
              alignment: const Alignment(-0.2, 0.55),
              child: DersArkadasi(
                tur: arkadasTuru,
                lang: lang,
                renk: widget.course.primaryColor,
                koyu: isDark,
                tohum: step.id.hashCode,
                tepki: cevap == null
                    ? null
                    : (cevap ? DeviTepkiTuru.dogru : DeviTepkiTuru.yanlis),
                coktanSecmeli: step.type == StepType.multipleChoice,
                tepkiNo: _tepkiNo,
                boyut: uzun ? 88 : 68,
                sonAdim: _isLastStep,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepWidget(LessonStep step, bool isDark) {
    switch (step.type) {
      case StepType.intro:
        return IntroStepWidget(
          step: step as IntroStep,
          course: widget.course,
          isDark: isDark,
          lesson: widget.lesson,
          dersNo: _dersNo,
          onComplete: () => _onStepCompleted(step.id),
        );

      case StepType.explanation:
        return ExplanationStepWidget(
          step: step as ExplanationStep,
          course: widget.course,
          isDark: isDark,
          onComplete: () => _onStepCompleted(step.id, xpEarned: step.xpReward),
        );

      case StepType.multipleChoice:
        return MultipleChoiceStepWidget(
          step: step as MultipleChoiceStep,
          course: widget.course,
          isDark: isDark,
          // Tepkiyi alttaki Devi arkadasi veriyor (tek Devi).
          deviTepkisi: false,
          onCevap: (dogru) => _cevapVerildi(step.id, dogru),
          onComplete: (correct) => _onStepCompleted(
            step.id,
            xpEarned: correct ? step.xpReward : 0,
          ),
        );

      case StepType.dragAndDrop:
        return DragDropStepWidget(
          step: step as DragDropStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) =>
              _uygulamaBitti(step.id, correct, step.xpReward),
        );

      case StepType.blockBuilder:
        final blokAdimi = step as BlockBuilderStep;
        // mBlock dersleri gercek tezgahi kullaniyor: kartlari siraya
        // dizmek yerine surukleyip yapistirmak. Ayar yoksa (Scratch,
        // Arduino) eski ekran aynen calisiyor.
        final tezgahAyari = blokAdimi.mblock;
        if (tezgahAyari != null) {
          return MBlockBlokAdimi(
            step: blokAdimi,
            ayar: tezgahAyari,
            course: widget.course,
            isDark: isDark,
            onComplete: (correct) => _onStepCompleted(
              step.id,
              xpEarned: correct ? step.xpReward : 0,
            ),
            // Tezgah acilmazsa yedek ekranin ic DEVAM tusu.
            onDevam: _nextStep,
          );
        }
        return BlockBuilderStepWidget(
          step: blokAdimi,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) => _onStepCompleted(
            step.id,
            xpEarned: correct ? step.xpReward : 0,
          ),
          // Ic DEVAM tusu alt cubuktaki "Devam" ile ayni isi yapiyor.
          onDevam: _nextStep,
        );

      case StepType.ordering:
        return OrderingStepWidget(
          step: step as OrderingStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) =>
              _uygulamaBitti(step.id, correct, step.xpReward),
        );

      case StepType.matching:
        return MatchingStepWidget(
          step: step as MatchingStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) =>
              _uygulamaBitti(step.id, correct, step.xpReward),
        );

      case StepType.miniGame:
        return MiniGameStepWidget(
          step: step as MiniGameStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (score) => _onStepCompleted(
            step.id,
            xpEarned: score >= step.targetScore ? step.xpReward : step.xpReward ~/ 2,
          ),
        );

      case StepType.project:
        return ProjectStepWidget(
          step: step as ProjectStep,
          course: widget.course,
          isDark: isDark,
          // Proje adimi artik iki cikisli: "Yaptim" (XP var) ve
          // "Sonra yaparim" (ilerler, XP yok). Uygulama projeyi
          // goremiyor; gordugunu iddia etmiyoruz.
          onComplete: (yapti) =>
              _onStepCompleted(step.id, xpEarned: yapti ? step.xpReward : 0),
        );


      // Bu uc tip icerikte VARDI ama ekranda karsiligi yoktu: Python,
      // Arduino ve HTML derslerinde 24 adim "Step tipi henüz
      // desteklenmiyor" yazisina dusuyordu.
      case StepType.codeComplete:
        return CodeCompleteStepWidget(
          step: step as CodeCompleteStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) =>
              _uygulamaBitti(step.id, correct, step.xpReward),
        );

      case StepType.typeTheCode:
        return TypeCodeStepWidget(
          step: step as TypeCodeStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) =>
              _uygulamaBitti(step.id, correct, step.xpReward),
        );

      case StepType.spotTheError:
        return SpotErrorStepWidget(
          step: step as SpotErrorStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) =>
              _uygulamaBitti(step.id, correct, step.xpReward),
        );

      case StepType.atolye:
        return ProjeAtolyesiWidget(
          step: step as ProjeAtolyesiStep,
          course: widget.course,
          isDark: isDark,
          lang: lessonLang(context),
          // Butun hedefler saglaninca XP (bir kez); "Sonra devam
          // ederim" ilerletir ama XP vermez.
          onComplete: (tamam) =>
              _onStepCompleted(step.id, xpEarned: tamam ? step.xpReward : 0),
          onDevam: _nextStep,
        );

      case StepType.animation:
        return AnimationStepWidget(
          step: step as AnimationStep,
          course: widget.course,
          isDark: isDark,
          onComplete: () => _onStepCompleted(step.id, xpEarned: step.xpReward),
        );
default:
        return Center(
          child: Text(
            lessonText(
              lessonLang(context),
              'Bu adım tipi henüz desteklenmiyor: ${step.type}',
              'This step type is not supported yet: ${step.type}',
              'Dieser Schritttyp wird noch nicht unterstützt: ${step.type}',
              'Este tipo de paso aún no es compatible: ${step.type}',
            ),
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
        );
    }
  }

  Widget _buildBottomBar(bool isDark) {
    final lang = lessonLang(context);
    final hazir = _canProceed() && !_bitiriliyor;
    final renk = widget.course.primaryColor;
    const yazi = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontWeight: FontWeight.w800,
      fontSize: 16,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (!_isFirstStep)
            OutlinedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(lessonText(lang, 'Önceki', 'Back', 'Zurück', 'Atrás')),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isDark ? Colors.white70 : const Color(0xFF4B5068),
                side: BorderSide(
                    color: isDark
                        ? Colors.white24
                        : const Color(0xFFDDE1EC),
                    width: 1.5),
                textStyle: yazi,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            )
          else
            const SizedBox(width: 100),

          const Spacer(),

          // Next/Complete button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (hazir)
                  BoxShadow(
                    color: renk.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: hazir ? _nextStep : null,
              icon: Icon(
                _isLastStep ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                size: 20,
              ),
              // Eskiden sabit Turkceydi: Ingilizce ekranda "Back" cevriliyor,
              // ana tus "Devam" kaliyordu.
              label: Text(_isLastStep
                  ? lessonText(lang, 'Tamamla', 'Finish', 'Fertig', 'Terminar')
                  : lessonText(lang, 'Devam', 'Continue', 'Weiter', 'Continuar')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceed() ? renk : Colors.grey.shade400,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    isDark ? Colors.white12 : const Color(0xFFE3E6EE),
                disabledForegroundColor:
                    isDark ? Colors.white38 : const Color(0xFF9AA0B4),
                textStyle: yazi,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    // ANLATIM ADIMI ARTIK KENDILIGINDEN GECMIYOR.
    //
    // Metnin tamami bir anda ekranda duruyor ve DEVAM tusu hazir
    // bekliyordu; cocuk tek dokunusla geciyordu. Anlatim artik paragraf
    // paragraf aciliyor (bkz. ExplanationStepWidget) ve son paragraf
    // gorununce adim tamamlanmis sayiliyor. Tek paragrafli metinlerde
    // ve ekran okuyucu acikken bu ilk karede oluyor, yani kimse
    // beklemiyor.
    if (_currentStep.type == StepType.intro) return true;
    return _currentStepCompleted;
  }

  void _showExitConfirmation() async {
    // Dil build disinda okunuyor: `lessonLang` (context.watch) burada
    // provider assertion atar ve diyalog SESSIZCE acilmaz.
    // Bkz. nickname_button_test.dart — ayni hata "Baska bir tane oner"
    // dugmesini calismaz hale getirmisti.
    final lang = lessonLangRead(context);
    final cik = await CikisPenceresi.dersten(context, lang,
        renk: widget.course.primaryColor);
    if (cik && mounted) Navigator.pop(context);
  }
}

/// Lesson completion dialog
class _LessonCompleteDialog extends StatefulWidget {
  final Course course;
  final InteractiveLesson lesson;
  final int totalXp;

  /// YENI kazanilan rozet; daha once kazanilmissa (ders tekrari) null ve
  /// "YENI ROZET!" kutusu cikmiyor.
  final String? badge;

  /// Ust uste ders bitirilen gun sayisi (bkz. DersSerisi). 0 ise
  /// gosterilmiyor.
  final int seri;

  /// Siradaki ders; varsa ana dugme "Siradaki ders: ..." ve dersi
  /// dogrudan aciyor.
  final InteractiveLesson? sonrakiDers;
  final VoidCallback? onSonraki;

  /// "Listeye don": pencere ve ders ekrani kapanir (kurs sayfasi).
  final VoidCallback? onListe;

  /// Kurs bitti: tek dugme ("Harika!") kapanis torenine gidiyor.
  final VoidCallback? onDevam;

  const _LessonCompleteDialog({
    required this.course,
    required this.lesson,
    required this.totalXp,
    this.badge,
    this.seri = 0,
    this.sonrakiDers,
    this.onSonraki,
    this.onListe,
    this.onDevam,
  });

  @override
  State<_LessonCompleteDialog> createState() => _LessonCompleteDialogState();
}

class _LessonCompleteDialogState extends State<_LessonCompleteDialog>
    with SingleTickerProviderStateMixin {
  /// Tek bir denetleyici, birden cok gecikmeli parca.
  ///
  /// ONCEDEN tum pencere birlikte `elasticOut` ile zipliyordu: bilgiler ayni
  /// anda geldigi icin goz nereye bakacagini bilmiyor, kazanc (XP, rozet)
  /// kutlamanin icinde kayboluyordu. Simdi parcalar 80 ms arayla sirayla
  /// giriyor — once "tebrikler", sonra XP, sonra rozet — ve XP sayarak
  /// yukseliyor.
  late final AnimationController _controller = AnimationController(
    duration: Motion.extraLong2,
    vsync: this,
  );

  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    // Ders bitti: soru sesinin buyugu. Tek tek dogrularin ustune
    // binmesin diye yalnizca bu anda caliyor.
    SoundService.playOdul();
    // MediaQuery'yi initState icinde okumak dogru degil (inherited widget
    // henuz baglanmamis olabiliyor); ilk kareden sonra bakiyoruz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !Motion.reduced(context)) _confetti.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confetti.dispose();
    super.dispose();
  }

  /// [order]. parcanin 0..1 ilerlemesi. Her parca bir oncekinden 80 ms sonra
  /// basliyor.
  Animation<double> _step(int order) {
    const stagger = 0.14;
    final begin = (order * stagger).clamp(0.0, 0.7);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, (begin + 0.45).clamp(0.0, 1.0),
          curve: Motion.emphasizedDecelerate),
    );
  }

  Widget _enter(int order, Widget child) {
    final a = _step(order);
    return AnimatedBuilder(
      animation: a,
      builder: (context, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - a.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  Widget _xpRozeti() {
    return Container(
      key: const ValueKey('ders_xp'),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 6),
          // Sayarak yukselen XP: kazanc bir olay haline geliyor. Sayi
          // GERCEKTEN verilen XP (tekrarda dortte biri).
          CountUpText(
            value: widget.totalXp,
            prefix: '+',
            suffix: ' XP',
            fontSize: 22,
            color: Colors.white,
            duration: Motion.extraLong2,
          ),
        ],
      ),
    );
  }

  /// "🔥 3 gun ust uste" — seri 1 ise "Serin basladi!".
  Widget _seriRozeti(String lang) {
    final n = widget.seri;
    final yazi = n >= 2
        ? lessonText(lang, '$n gün üst üste', '$n days in a row',
            '$n Tage in Folge', '$n días seguidos')
        : lessonText(lang, 'Serin başladı!', 'Streak started!',
            'Serie gestartet!', '¡Racha iniciada!');
    return Container(
      key: const ValueKey('ders_serisi'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDE0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF7A1A), width: 1.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: Color(0xFFFF6A00), size: 22),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              yazi,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFFD9530B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ana dugme ("Siradaki ders: ..." ya da "Harika!") ve altinda
  /// "Listeye don".
  Widget _dugmeler(String lang) {
    final renk = widget.course.primaryColor;
    if (widget.onDevam != null) {
      return PressButton(
        key: const ValueKey('ders_harika'),
        label: lessonText(lang, 'Harika!', 'Awesome!', 'Super!', '¡Genial!'),
        color: renk,
        height: 52,
        onPressed: widget.onDevam,
      );
    }
    final sonraki = widget.sonrakiDers;
    final liste = widget.onListe ??
        () {
          Navigator.pop(context);
          Navigator.pop(context);
        };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sonraki != null && widget.onSonraki != null)
          PressButton(
            key: const ValueKey('ders_sonraki'),
            ustYazi: lessonText(lang, 'SIRADAKİ DERS', 'NEXT LESSON',
                'NÄCHSTE LEKTION', 'SIGUIENTE LECCIÓN'),
            label: sonraki.titleFor(lang),
            icon: Icons.arrow_forward_rounded,
            color: renk,
            height: 58,
            onPressed: widget.onSonraki,
          )
        else
          PressButton(
            key: const ValueKey('ders_harika'),
            label:
                lessonText(lang, 'Harika!', 'Awesome!', 'Super!', '¡Genial!'),
            color: renk,
            height: 52,
            onPressed: liste,
          ),
        if (sonraki != null && widget.onSonraki != null)
          TextButton(
            key: const ValueKey('ders_listeye_don'),
            onPressed: liste,
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
            child: Text(
              lessonText(lang, 'Listeye dön', 'Back to the list',
                  'Zurück zur Liste', 'Volver a la lista'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kutlamayi Devi yapiyor (emoji degil): uygulamanin her
              // yerinde ayni karakter.
              _enter(
                  0,
                  const Mascot(
                      size: 84, mood: MascotMood.happy, showShadow: false)),
              const SizedBox(height: 14),
              _enter(
                1,
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      widget.course.primaryColor,
                      widget.course.secondaryColor
                    ],
                  ).createShader(bounds),
                  child: Text(
                    lessonText(lang, 'TEBRİKLER!', 'CONGRATULATIONS!',
                        'GLÜCKWUNSCH!', '¡ENHORABUENA!'),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _enter(
                2,
                Text(
                  lessonText(
                      lang,
                      '"${widget.lesson.titleFor(lang)}" tamamlandı!',
                      '"${widget.lesson.titleFor(lang)}" completed!',
                      '"${widget.lesson.titleFor(lang)}" geschafft!',
                      '¡"${widget.lesson.titleFor(lang)}" completada!'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _enter(
                3,
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _xpRozeti(),
                    if (widget.seri > 0) _seriRozeti(lang),
                  ],
                ),
              ),
              if (widget.badge != null) ...[
                const SizedBox(height: 20),
                _enter(
                  4,
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.course.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            widget.course.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          lessonText(lang, 'YENİ ROZET!', 'NEW BADGE!',
                              'NEUES ABZEICHEN!', '¡NUEVA INSIGNIA!'),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Ad ve simge TEK katalogdan (bkz. RozetKatalogu):
                        // eskiden yalnizca alti Scratch rozeti biliniyordu,
                        // gerisi "Rozet" / 🏆 cikiyordu.
                        Text(
                          RozetKatalogu.of(widget.badge!).simge,
                          style: const TextStyle(fontSize: 46),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          RozetKatalogu.of(widget.badge!).adi(lang),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.w700,
                            color: widget.course.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          actions: [
            _enter(5, _dugmeler(lang)),
          ],
        ),
        // Konfeti pencerenin ustunden dokuluyor; dokunuslari engellemesin
        // diye IgnorePointer icinde.
        IgnorePointer(
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0,
            numberOfParticles: 26,
            maxBlastForce: 22,
            minBlastForce: 9,
            gravity: 0.28,
            colors: [
              widget.course.primaryColor,
              widget.course.secondaryColor,
              Colors.amber,
              AppTheme.successGreen,
            ],
          ),
        ),
      ],
    );
  }
}
