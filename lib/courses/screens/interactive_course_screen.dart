import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ad_unlock_service.dart';
import '../../services/next_lesson_service.dart';
import '../../utils/lang.dart';
import '../../utils/pro_gate.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../data/course_modules.dart';
import 'interactive_lesson_screen.dart';
import '../tanitim/kurs_acilis_ekrani.dart';
import '../tanitim/kurs_kapanis_ekrani.dart';
import '../tanitim/kurs_tanitimi.dart';
import 'module_quiz_screen.dart';
import 'widgets/kurs_yol_haritasi.dart';
import '../../services/sound_service.dart';
import 'widgets/step_widgets.dart'
    show lessonLang, lessonLangRead, lessonText;

/// Genel Interaktif Kurs Ekrani
/// Tum kurslar icin kullanilabilir
class InteractiveCourseScreen extends StatefulWidget {
  final Course course;

  const InteractiveCourseScreen({super.key, required this.course});

  @override
  State<InteractiveCourseScreen> createState() => _InteractiveCourseScreenState();
}

class _InteractiveCourseScreenState extends State<InteractiveCourseScreen> {
  int _selectedModule = 0;
  late List<CourseModule> _modules;

  /// Modul sinavlarinin sorulari (modul basina bir kez secilir).
  final Map<CourseModule, List<MultipleChoiceStep>> _sinavSorulari = {};

  /// Dersin KURS icindeki sifir tabanli sirasi (moduller duzlestirilmis).
  ///
  /// Pro bir kursta ilk iki ders odullu reklamla aciliyor; hangi dersin
  /// "ilk iki" oldugunu bilmek icin modul ici sira degil, kurs geneli
  /// sira gerekiyor.
  final Map<String, int> _dersSirasi = {};

  /// Reklamla acilmis derslerin id'leri. Kart kilidini cizmek icin
  /// bellekte tutuluyor; kalici kayit [AdUnlockService] tarafinda.
  Set<String> _acilanDersler = {};

  @override
  void initState() {
    super.initState();
    _loadCourseModules();
    _acilanlariYukle();
  }

  void _loadCourseModules() {
    // Esleme artik CourseModules'te; ekran yalnizca okuyor. Boylece test de
    // ayni kaynagi dogrulayabiliyor (bkz. test/course_content_test.dart).
    _modules = CourseModules.forCourse(widget.course.id);

    var sira = 0;
    for (final modul in _modules) {
      for (final ders in modul.lessons) {
        _dersSirasi[ders.id] = sira++;
      }
    }
  }

  Future<void> _acilanlariYukle() async {
    if (!widget.course.isPremium) return;
    final acilan = <String>{};
    for (final modul in _modules) {
      for (final ders in modul.lessons) {
        if (await AdUnlockService.instance.acikMi(widget.course.id, ders.id)) {
          acilan.add(ders.id);
        }
      }
    }
    if (!mounted) return;
    setState(() => _acilanDersler = acilan);
  }

  /// Bu ders su an kilitli mi? (Pro uyede hicbir zaman.)
  ///
  /// [dinle] BUILD ICINDE true olmali: Pro olunca liste kendiliginden
  /// tazelensin diye `context.watch` kullaniyor. Ama bir dokunma
  /// isleyicisinden (onTap) cagrilirsa `watch` YASAK — provider
  /// "Tried to listen to a value exposed with provider, from outside of
  /// the widget tree" diye assertion atiyor ve o isleyici sessizce olup
  /// hicbir sey olmuyordu: kilitli derse dokunulunca Pro/Reklam sayfasi
  /// HIC ACILMIYORDU. Olay isleyicileri `dinle: false` geciyor.
  bool _kilitli(InteractiveLesson lesson, {bool dinle = true}) =>
      widget.course.isPremium &&
      !(dinle ? ProGate.watchIsPro(context) : ProGate.isPro(context)) &&
      !_acilanDersler.contains(lesson.id);

  /// Kilitliyse reklamla acilabilir mi, yoksa yalnizca Pro mu?
  bool _reklamlaAcilir(InteractiveLesson lesson) =>
      AdUnlockService.instance
          .reklamlaAcilabilir(_dersSirasi[lesson.id] ?? 1 << 30);


  /// Baslik arkasindaki konu sembolleri.
  ///
  /// Sabit bir tohumla uretiliyor: her acilista ayni yerde duruyorlar,
  /// sayfa "titremiyor". Opaklik 0.12-0.22 — degradenin uzerinde
  /// secilecek kadar var, basligi okumayi zorlastirmayacak kadar yok.
  List<Widget> _kursSembolleri() {
    const simgeler = <IconData>[
      Icons.view_module_rounded,      // kod blogu
      Icons.settings_rounded,         // dis / robotik
      Icons.hub_rounded,              // devre dugumu
      Icons.arrow_forward_rounded,    // akis yonu
      Icons.data_object_rounded,      // kod parantezi
      Icons.memory_rounded,           // yonga
    ];
    final rastgele = Random(widget.course.id.hashCode);
    return List.generate(9, (i) {
      final simge = simgeler[i % simgeler.length];
      return Positioned(
        left: rastgele.nextDouble() * 320,
        top: rastgele.nextDouble() * 160,
        child: Transform.rotate(
          angle: (rastgele.nextDouble() - 0.5) * 0.7,
          child: Icon(
            simge,
            size: 22 + rastgele.nextDouble() * 20,
            color: Colors.white
                .withValues(alpha: 0.12 + rastgele.nextDouble() * 0.10),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_modules.isEmpty) {
      return Scaffold(
        // Kurs adi da cevrilmeli: Ingilizce ekranda "mBlock ile
        // Kodlama" yaziyordu. Modelde nameEn/De/Es zaten vardi,
        // yalnizca okunmuyordu.
        appBar: AppBar(
            title: Text(widget.course.nameFor(lessonLang(context)))),
        body: Center(
          child: Text(lessonText(
              lessonLang(context),
              'Bu kurs için interaktif içerik henüz hazır değil.',
              'Interactive content for this course is not ready yet.',
              'Die interaktiven Inhalte für diesen Kurs sind noch nicht fertig.',
              'El contenido interactivo de este curso aún no está listo.')),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(isDark),
          SliverToBoxAdapter(child: _buildProgressCard(isDark)),
          if (_modules.length > 1)
            SliverToBoxAdapter(child: _buildYolHaritasi(isDark)),
          SliverToBoxAdapter(child: _buildModuleTabs(isDark)),
          SliverToBoxAdapter(child: _buildModuleContent(isDark)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: widget.course.primaryColor,
      // Serit kursun renginde ve yazisi BEYAZ. AppBar stili zeminin
      // parlakligindan tahmin ediyordu: Scratch turuncusunda koyu,
      // Python mavisinde acik ikon cikiyordu. Yazi hep beyaz oldugu icin
      // durum cubugu da hep acik.
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.course.nameFor(lessonLang(context)),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.course.primaryColor,
                    widget.course.secondaryColor,
                  ],
                ),
              ),
            ),
            // Course emoji
            Positioned(
              right: 20,
              bottom: 60,
              // TEK KAYNAK: kursun simgesi modelde duruyor.
              //
              // Burada ikinci bir liste vardi ve mBlock ona hic
              // yazilmamisti; kurs varsayilana dusup KITAP simgesiyle
              // aciliyordu. Blok kodlama ve robotik anlatan bir kursun
              // basinda kitap durmasi yanlis bir isaret. Liste
              // kaldirildi; her kurs kendi simgesini getiriyor.
              child: _AnimatedEmoji(emoji: widget.course.icon),
            ),
            // KONUYA AIT SEMBOLLER
            //
            // Burada beyaz, rastgele dondurulmus 8 dikdortgen vardi;
            // "dekorasyon" diye konulmus ama hicbir sey anlatmiyordu.
            // Uygulamanin konusu yazilim, robotik ve blok kodlama —
            // arka plan da bunu soylesin: kod blogu, dis, devre
            // dugumu, yon oku, kod parantezi.
            //
            // Semboller uygulamanin baska yerlerindeki `PlayfulBackground`
            // ile AYNI dagarcik; ekranlar birbirine yabanci durmasin.
            ..._kursSembolleri(),
          ],
        ),
      ),
    );
  }

  /// Bitirilen dersler: sunucu + cihazdaki kalici kayit.
  ///
  /// Saglayicisiz agacta (bazi testler) bos kume; ekran cokmesin.
  Set<String> get _bitenDersler {
    try {
      return context.watch<AuthProvider>().tamamlananDersler;
    } on ProviderNotFoundException {
      return const <String>{};
    }
  }

  bool get _kursAcildi {
    try {
      return context
          .watch<AuthProvider>()
          .baslananKurslar
          .contains(widget.course.id);
    } on ProviderNotFoundException {
      return false;
    }
  }

  Widget _buildProgressCard(bool isDark) {
    final totalLessons = _modules.fold<int>(0, (sum, m) => sum + m.lessons.length);
    // GERCEK ILERLEME. Burada `const completedLessons = 0; // TODO`
    // duruyordu: 3 dersi bitiren cocuk da %0 goruyordu ve alttaki tus
    // hep "Ogrenmeye Basla" deyip 1. dersi aciyordu.
    final biten = _bitenDersler;
    final completedLessons = _modules.fold<int>(
        0, (t, m) => t + m.lessons.where((l) => biten.contains(l.id)).length);
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    // XP, ders ekraninin GERCEKTEN verdigiyle ayni olcu: dersin bitis
    // odulu + adimlarin XP'si ([InteractiveLesson.tamXp]). Eskiden
    // yalnizca bitis odulu sayiliyordu; kart "120 / 800" derken cocugun
    // XP'si 300 artmis oluyordu.
    final totalXp = _modules.fold<int>(0, (sum, m) =>
      sum + m.lessons.fold<int>(0, (s, l) => s + l.tamXp));
    final earnedXp = _modules.fold<int>(0, (sum, m) =>
      sum + m.lessons
          .where((l) => biten.contains(l.id))
          .fold<int>(0, (s, l) => s + l.tamXp));
    final devam = KursDevam.hesapla(widget.course.id, biten,
        acildi: _kursAcildi);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.course.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Progress circle
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: widget.course.primaryColor.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(widget.course.primaryColor),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lessonText(lessonLang(context), 'İlerleme', 'Progress',
                          'Fortschritt', 'Progreso'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      icon: Icons.school,
                      label: lessonText(lessonLang(context), 'Ders',
                          'Lessons', 'Lektionen', 'Lecciones'),
                      value: '$completedLessons / $totalLessons',
                      color: widget.course.primaryColor,
                    ),
                    const SizedBox(height: 4),
                    _buildStatRow(
                      icon: Icons.star,
                      label: 'XP',
                      value: '$earnedXp / $totalXp',
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _kaldigiDersiAc(),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.course.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      devam?.durum == KursDurumu.bitti
                          ? Icons.replay_rounded
                          : Icons.play_arrow,
                      size: 24),
                  const SizedBox(width: 8),
                  // Etiket kursun durumundan: baslanmamis / kaldigin
                  // yerden devam / tekrar. Uzun Almanca etiket dar
                  // ekranda tasmasin diye Flexible + ellipsis.
                  Flexible(
                    child: Text(
                      (devam ?? _yedekDevam).etiket(lessonLang(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (KursTanitimi.acik(widget.course.id))
            _tanitimBaglantilari(devam?.durum == KursDurumu.bitti),
        ],
      ),
    );
  }

  /// Ana tusun altindaki kucuk baglantilar: acilisi tekrar izle; kurs
  /// bittiyse kapanisi (sertifika) tekrar ac. Yalnizca acilis/kapanis
  /// acik kurslarda (simdilik Scratch).
  Widget _tanitimBaglantilari(bool bitti) {
    final lang = lessonLang(context);
    final renk = widget.course.primaryColor;
    Widget baglanti(Key k, IconData ikon, String yazi, VoidCallback onTap) =>
        TextButton.icon(
          key: k,
          onPressed: onTap,
          icon: Icon(ikon, size: 18),
          label: Text(
            yazi,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          style: TextButton.styleFrom(
            foregroundColor: renk,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        children: [
          baglanti(
            const ValueKey('tanitimi_tekrar_izle'),
            Icons.play_circle_outline_rounded,
            lessonText(lang, 'Tanıtımı tekrar izle', 'Watch the intro again',
                'Intro noch einmal ansehen', 'Ver la introducción otra vez'),
            () => KursAcilisEkrani.ac(context, widget.course, tekrar: true),
          ),
          if (bitti)
            baglanti(
              const ValueKey('kapanisi_tekrar_ac'),
              Icons.workspace_premium_rounded,
              lessonText(lang, 'Sertifikan', 'Your certificate',
                  'Dein Zertifikat', 'Tu certificado'),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) =>
                      KursKapanisEkrani.kur(ctx, widget.course, tekrar: true),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        // Kurs bitince "XP: 1260 / 1260" dar ekranda tasiyordu; sigmazsa
        // kuculuyor.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Kurs ders listesi CourseModules.allLessons ile ayni kaynaktan
  /// geldigi icin [KursDevam.hesapla] burada null donmez; yine de bos
  /// bir etiket cizilmesin diye ilk dersle bir yedek.
  KursDevam get _yedekDevam => KursDevam(
        lesson: _modules.first.lessons.first,
        index: 0,
        completedInCourse: 0,
        lessonCount: _modules.fold<int>(0, (t, m) => t + m.lessons.length),
        durum: KursDurumu.baslanmadi,
      );

  /// KURSUN YOL HARITASI: moduller dugum dugum, bitenler parliyor,
  /// cocugun oldugu modulde Devi bekliyor. Dugume dokunmak o modulun
  /// derslerini asagida aciyor (sekmeyle ayni is).
  Widget _buildYolHaritasi(bool isDark) {
    final lang = lessonLang(context);
    final biten = _bitenDersler;
    final sayi = KursYolHaritasi.bitenModul(_modules, biten);
    return Container(
      key: const ValueKey('kurs_yol_haritasi'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.course.primaryColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(Icons.route_rounded,
                    size: 18, color: widget.course.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    lessonText(lang, 'Yol haritan', 'Your path', 'Dein Weg',
                        'Tu camino'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Text(
                  lessonText(
                      lang,
                      '$sayi/${_modules.length} modül',
                      '$sayi/${_modules.length} modules',
                      '$sayi/${_modules.length} Module',
                      '$sayi/${_modules.length} módulos'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: widget.course.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          KursYolHaritasi(
            moduller: _modules,
            biten: biten,
            renk: widget.course.primaryColor,
            renk2: widget.course.secondaryColor,
            lang: lang,
            koyu: isDark,
            secili: _selectedModule,
            onSec: (i) {
              HapticFeedback.selectionClick();
              setState(() => _selectedModule = i);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTabs(bool isDark) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _modules.length,
        itemBuilder: (context, index) {
          final module = _modules[index];
          final isSelected = _selectedModule == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedModule = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 130,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.course.primaryColor
                    : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: widget.course.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    module.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lessonText(lessonLang(context), 'Modül ${index + 1}',
                        'Module ${index + 1}', 'Modul ${index + 1}',
                        'Módulo ${index + 1}'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white70
                          : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                    ),
                  ),
                  Text(
                    module.titleFor(lessonLang(context)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModuleContent(bool isDark) {
    final module = _modules[_selectedModule];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module header
          Row(
            children: [
              Text(module.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.titleFor(lessonLang(context)),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      module.descriptionFor(lessonLang(context)),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.course.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lessonText(
                      lessonLang(context),
                      '${module.lessons.length} ders',
                      '${module.lessons.length} lessons',
                      '${module.lessons.length} Lektionen',
                      '${module.lessons.length} lecciones'),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.course.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Lessons list
          ...module.lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            return _buildLessonCard(lesson, index, isDark);
          }),

          // Modul Quizi - moduldeki derslerin icine gomulu coktan
          // secmeli sorulari toplayip ayri bir quiz deneyimi olarak sunar.
          _buildModuleQuizCard(module, isDark),
        ],
      ),
    );
  }

  Widget _buildModuleQuizCard(CourseModule module, bool isDark) {
    // Sorular BIR KEZ seciliyor: collectQuestions karistiriyor ve build
    // her calistiginda (ilerleme degisince, tema degisince) kartin
    // arkasindaki soru seti degisiyordu.
    final questions = _sinavSorulari.putIfAbsent(
        module, () => ModuleQuizScreen.collectQuestions(module.lessons));
    if (questions.length < 3) {
      return const SizedBox.shrink();
    }

    final lang = lessonLang(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModuleQuizScreen(
                course: widget.course,
                moduleTitle: module.title,
                moduleTitleEn: module.titleEn,
                moduleTitleDe: module.titleDe,
                moduleTitleEs: module.titleEs,
                questions: questions,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.course.primaryColor, widget.course.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.course.primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lessonText(lang, 'Modül Quizi', 'Module Quiz', 'Modul-Quiz',
                          'Quiz del módulo'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lessonText(
                          lang,
                          'Bu modüldeki ${questions.length} soruyla kendini test et',
                          'Test yourself with ${questions.length} questions from this module',
                          'Teste dich mit ${questions.length} Fragen aus diesem Modul',
                          'Ponte a prueba con ${questions.length} preguntas de este módulo'),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(InteractiveLesson lesson, int index, bool isDark) {
    // BİTEN DERSİN İŞARETİ GERÇEK VERİDEN GELİYOR.
    //
    // Burada `const isCompleted = false; // TODO` duruyordu: kurs
    // listesindeki HİÇBİR ders, bitirilmiş olsa bile bitmiş
    // görünmüyordu. Yeşil çerçeve, yeşil rozet ve tik hep ölü koddu —
    // analyzer da onları "erişilemez kod" diye işaretliyordu. Çocuğun
    // nerede kaldığını göremediği bir liste, listenin işini yapmıyor.
    //
    // Ders KİLİTLENMİYOR: yol bir öneri, bir kapı değil. (Apple 5.1.4(a)
    // uygulamanın yaştan bağımsız işe yarar olmasını istiyor; ayrıca
    // sırayı atlamak isteyen çocuğu durdurmak bu uygulamanın işi değil.)
    final completedIds = _bitenDersler;
    final isCompleted = completedIds.contains(lesson.id);

    return GestureDetector(
      onTap: () => _openLesson(lesson),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(color: Colors.green, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openLesson(lesson),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Lesson number
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? const LinearGradient(
                              colors: [Colors.green, Colors.teal],
                            )
                          : LinearGradient(
                              colors: [
                                widget.course.primaryColor,
                                widget.course.secondaryColor,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isCompleted
                                  ? Colors.green
                                  : widget.course.primaryColor)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                          : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Lesson info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.titleFor(lessonLang(context)),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.subtitleFor(lessonLang(context)),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Wrap: "12 Schritte +40 XP Abzeichen" dar
                        // ekranda ve buyuk yazi boyutunda tasiyordu
                        // (RenderFlex overflow); sigmayan alt satira iner.
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: 4,
                          children: [
                            _buildLessonStat(
                              Icons.flash_on,
                              lessonText(
                                  lessonLang(context),
                                  '${lesson.steps.length} adım',
                                  '${lesson.steps.length} steps',
                                  '${lesson.steps.length} Schritte',
                                  '${lesson.steps.length} pasos'),
                              Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            _buildLessonStat(
                              Icons.star,
                              '+${lesson.xpReward} XP',
                              Colors.amber,
                            ),
                            if (lesson.badge != null) ...[
                              const SizedBox(width: 16),
                              _buildLessonStat(
                                Icons.emoji_events,
                                lessonText(lessonLang(context), 'Rozet',
                                    'Badge', 'Abzeichen', 'Insignia'),
                                Colors.purple,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Kilit durumu: ya "reklamla ac" ya da PRO rozeti.
                  if (_kilitli(lesson)) ...[
                    if (_reklamlaAcilir(lesson))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C3CE0).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.play_circle_outline_rounded,
                            size: 18, color: Color(0xFF6C3CE0)),
                      )
                    else
                      ProGate.badge(),
                    const SizedBox(width: 6),
                  ],

                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonStat(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Dersi acar; gerekiyorsa once kilidi cozer.
  ///
  /// KILIT NEDEN BURADA
  /// ------------------
  /// Eskiden kilit KURS acilisindaydi: Pro olmayan cocuk Java kursunun
  /// icini hic goremiyordu. Simdi liste aciliyor, kilit ders basina:
  ///
  ///  - Kursun ilk IKI dersi: odullu reklamla acilir ve acik kalir.
  ///  - Ucuncu ders ve sonrasi: yalnizca Pro.
  ///
  /// Boylece cocuk icerigi gercekten gorup ailesine anlatabiliyor, ama
  /// kursun tamami reklamla bitirilemiyor — yani ilerlemek icin reklam
  /// izlemek ZORUNDA kalmiyor.
  /// DIKKAT: burasi bir onTap isleyicisi, BUILD DEGIL.
  ///
  /// Provider'i dinleyen hicbir cagri yapilamaz: `context.watch` build
  /// disinda assertion atiyor, istisna yutuluyor ve dokunus sessizce
  /// hicbir sey yapmiyor. Bu yuzden `_kilitli(dinle: false)` ve
  /// `lessonLangRead` kullaniliyor (`lessonLang` dinler).
  Future<void> _openLesson(InteractiveLesson lesson) async {
    if (_kilitli(lesson, dinle: false)) {
      final sira = _dersSirasi[lesson.id] ?? 1 << 30;
      final baslik = lesson.titleFor(lessonLangRead(context));

      if (!_reklamlaAcilir(lesson)) {
        final ok = await ProGate.ensure(
          context,
          featureName: baslik,
          explanation: lessonText(
            lessonLangRead(context),
            'Bu kursun ilk iki dersi herkese açık. Gerisi Pro üyelikte.',
            'The first two lessons of this course are open to everyone. '
                'The rest is part of Pro.',
            'Die ersten zwei Lektionen dieses Kurses sind für alle offen. '
                'Der Rest gehört zu Pro.',
            'Las dos primeras lecciones de este curso son para todos. '
                'El resto forma parte de Pro.',
          ),
        );
        if (!ok || !mounted) return;
      } else {
        final sonuc = await ProGate.ensureOrAd(
          context,
          featureName: baslik,
          explanation: lessonText(
            lessonLangRead(context),
            'Bu ileri seviye kursun ilk iki dersini deneyebilirsin.',
            'You can try the first two lessons of this advanced course.',
            'Du kannst die ersten zwei Lektionen dieses Kurses ausprobieren.',
            'Puedes probar las dos primeras lecciones de este curso.',
          ),
          reklamEtiketi: (lang) => AppLang.pick(
            lang,
            tr: 'Reklam izle, bu dersi aç',
            en: 'Watch an ad, open this lesson',
            de: 'Werbung ansehen, Lektion öffnen',
            es: 'Ver un anuncio y abrir la lección',
          ),
        );
        if (sonuc == ProUnlock.kapali || !mounted) return;
        if (sonuc == ProUnlock.reklam) {
          await AdUnlockService.instance.ac(widget.course.id, lesson.id, sira);
          SoundService.playKilitAcildi();
          if (!mounted) return;
          setState(() => _acilanDersler = {..._acilanDersler, lesson.id});
        }
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InteractiveLessonScreen(
          course: widget.course,
          lesson: lesson,
        ),
      ),
    );
  }

  /// Ana tus: ilk BITMEMIS dersi acar (1-3 bittiyse 4. ders).
  ///
  /// Eskiden her zaman `_modules[0].lessons.first` aciliyordu; ertesi
  /// gun gelen cocuk bitirdigi dersi bastan yapmak zorunda kaliyordu.
  /// Hepsi bittiyse tekrar icin ilk ders.
  ///
  /// onTap isleyicisi: `watch` degil `read` (bkz. [_openLesson] notu).
  Future<void> _kaldigiDersiAc() async {
    Set<String> biten = const <String>{};
    try {
      biten = context.read<AuthProvider>().tamamlananDersler;
    } on ProviderNotFoundException {
      // Saglayici yoksa ilerleme de yok: ilk ders.
    }
    final devam = KursDevam.hesapla(widget.course.id, biten);

    // ACILIS SAHNESI: kursa ilk kez baslayan cocuga, 1. dersten once bir
    // kez. Kursta tek ders bile bitmisse (guncellemeden once baslamis
    // cocuk) gosterilmiyor. Atlansa da bitse de ardindan 1. ders aciliyor;
    // geri tusuyla cikilirsa kurs sayfasinda kaliniyor.
    if (KursTanitimi.acik(widget.course.id) &&
        (devam?.completedInCourse ?? 0) == 0 &&
        !await KursTanitimDeposu.acilisGoruldu(widget.course.id)) {
      if (!mounted) return;
      final devamEt = await KursAcilisEkrani.ac(context, widget.course);
      if (!devamEt || !mounted) return;
    }

    final ders = devam?.lesson ??
        (_modules.isNotEmpty && _modules[0].lessons.isNotEmpty
            ? _modules[0].lessons.first
            : null);
    if (ders == null) return;
    // Secili modul sekmesi de o derse kaysin: geri donuldugunde liste
    // cocugun bulundugu modulu gostersin.
    final modul = _modules.indexWhere((m) => m.lessons.contains(ders));
    if (modul >= 0 && modul != _selectedModule) {
      setState(() => _selectedModule = modul);
    }
    await _openLesson(ders);
  }
}

/// Animated Emoji Widget
class _AnimatedEmoji extends StatefulWidget {
  final String emoji;

  const _AnimatedEmoji({required this.emoji});

  @override
  State<_AnimatedEmoji> createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<_AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: Text(
            widget.emoji,
            style: const TextStyle(fontSize: 80),
          ),
        );
      },
    );
  }
}
