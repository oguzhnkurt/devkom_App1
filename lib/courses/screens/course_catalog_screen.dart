import 'dart:math';
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../data/courses_data.dart';
import 'course_detail_screen.dart';
import '../data/course_modules.dart';
import 'interactive_course_screen.dart';
import '../../utils/pro_gate.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../ui/appear_in.dart';
import '../../ui/motion.dart';
import '../../widgets/mascot.dart';
import 'widgets/step_widgets.dart'
    show lessonLang, lessonText;

/// Course Catalog Screen - Main course listing
class CourseCatalogScreen extends StatefulWidget {
  const CourseCatalogScreen({super.key});

  @override
  State<CourseCatalogScreen> createState() => _CourseCatalogScreenState();
}

class _CourseCatalogScreenState extends State<CourseCatalogScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  /// KATEGORI SERIDI KALDIRILDI.
  ///
  /// Katalogun ustunde yatay kayan bir filtre bandi vardi: Tumu,
  /// Baslangic, Web, Mobil, Sistem, Robotik, Veri/AI, Script. Cocuga
  /// hitap eden bir ayrim degil, yetiskin bir kurs sitesinin
  /// kategorileriydi — "Sistem" ya da "Script" bir cocuk icin hicbir sey
  /// ifade etmiyor. Ustelik katalog zaten kolaydan zora siralanmis bir
  /// OGRENME YOLU olarak gosteriliyor; filtre bandi o yolu bolen ikinci
  /// bir gezinme bicimiydi.
  ///
  /// Arama duruyor: bir kursu adiyla aramak isteyen yine bulabiliyor.

  /// Arama yokken kurslar duz bir izgara yerine "ogrenme yolu" olarak
  /// gosteriliyor: kolaydan zora, adim adim.
  bool get _isBrowsingPath => _searchQuery.isEmpty;

  List<Course> get filteredCourses => _searchQuery.isEmpty
      ? CoursesData.allCourses
      : CoursesData.search(_searchQuery);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark),
          SliverToBoxAdapter(child: _buildSearchBar(isDark)),
          if (_isBrowsingPath) ...[
            SliverToBoxAdapter(child: _buildPathIntro(isDark)),
            _buildLearningPath(isDark),
          ] else ...[
            SliverToBoxAdapter(child: _buildCourseCount(isDark)),
            _buildCourseGrid(isDark),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚀 ', style: TextStyle(fontSize: 20)),
            Text(
              lessonText(lessonLang(context), 'Kurslar', 'Courses',
                  'Kurse', 'Cursos'),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Space background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A1A2E), const Color(0xFF0A0A0F)]
                      : [const Color(0xFFE8EAF6), const Color(0xFFF5F7FA)],
                ),
              ),
            ),
            // Yildizlar yavasca suzuluyor ve sonup yaniyor: baslik
            // bandi "resim" degil "gokyuzu" gibi duruyor. Hareket
            // azaltma ayarinda duruyor (bkz. _CanliYildizlar).
            _CanliYildizlar(isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            hintText: lessonText(lessonLang(context),
                'Kurs ara... (örneğin: Python, Web)',
                'Search courses (Python, Web...)'),
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCount(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bu iki yazi Turkce sabitti.
          Text(
            lessonText(
                lessonLang(context),
                '${filteredCourses.length} kurs bulundu',
                '${filteredCourses.length} courses found',
                '${filteredCourses.length} Kurse gefunden',
                '${filteredCourses.length} cursos encontrados'),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              child: Text(
                lessonText(lessonLang(context), 'Temizle', 'Clear', 'Löschen',
                    'Borrar'),
                style: const TextStyle(color: Color(0xFF667eea)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPathIntro(bool isDark) {
    final lang = lessonLang(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lessonText(lang, 'Öğrenme Yolu', 'Learning path', 'Lernpfad',
                'Ruta de aprendizaje'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1F1D36),
            ),
          ),
          const SizedBox(height: 10),
          // MASKOT BURADA, CUNKU BURADA SOYLEYECEK BIR SEYI VAR.
          //
          // Devi'yi sayfanin basina sus olarak koymak, ekrana bakan
          // cocuga bir sey anlatmiyordu. Yolu ANLATAN cumleyi ona
          // soyletince maskot bir karakter oluyor: kurslar listesi bir
          // katalog degil, birinin gosterdigi bir yol gibi duruyor.
          MascotSays(
            size: 58,
            mood: MascotMood.curious,
            text: lessonText(
                lang,
                'Bloklardan gerçek koda, adım adım. Her kurs bir öncekinin '
                    'üstüne biner.',
                'From blocks to real code, step by step. Each course builds '
                    'on the one before it.',
                'Von Blöcken zu echtem Code, Schritt für Schritt. Jeder Kurs '
                    'baut auf dem vorherigen auf.',
                'De los bloques al código real, paso a paso. Cada curso se '
                    'apoya en el anterior.'),
          ),
        ],
      ),
    );
  }

  /// Cocugun tamamladigi ders kimlikleri.
  ///
  /// Saglayici olmayan bir agacta (ekran goruntusu araclari, bazi
  /// testler) ekran cokmemeli: bos kume donuyor, yol ilerlemesiz
  /// ciziliyor.
  Set<String> get _bitmisDersler {
    try {
      return context
              .watch<AuthProvider>()
              .userProgress
              ?.completedLessonIds
              .toSet() ??
          <String>{};
    } on ProviderNotFoundException {
      return <String>{};
    }
  }

  /// Kurslari zorluk seviyesine gore gruplayip adim numaralariyla listeler.
  Widget _buildLearningPath(bool isDark) {
    final path = CoursesData.learningPath;
    final bitmis = _bitmisDersler;

    // ILERLEME GERCEK VERIDEN GELIYOR.
    //
    // Liste eskiden yalnizca "12 ders / 4 saat" diyordu: cocugun nerede
    // oldugunu ekranda hicbir sey soylemiyordu, dolayisiyla kurslar
    // birbirinin ayni duruyordu. Artik her kursun kac dersinin bittigi
    // ve hangisinin SIRADAKI kurs oldugu goruluyor.
    String? siradaki;
    final Map<String, (int, int)> ilerleme = {};
    for (final course in path) {
      final dersler = CourseModules.allLessons(course.id);
      final yapilan = dersler.where((l) => bitmis.contains(l.id)).length;
      ilerleme[course.id] = (yapilan, dersler.length);
      if (siradaki == null && (dersler.isEmpty || yapilan < dersler.length)) {
        siradaki = course.id;
      }
    }

    // Seviye basliklari, ilk kez o seviyeye gecildiginde araya giriyor.
    final items = <Widget>[];
    DifficultyLevel? lastLevel;
    var sira = 0;
    for (final course in path) {
      if (course.difficulty != lastLevel) {
        items.add(_buildLevelHeader(course.difficulty, isDark));
        lastLevel = course.difficulty;
      }
      final (yapilan, toplam) = ilerleme[course.id] ?? (0, 0);
      items.add(AppearIn(
        delay: Duration(milliseconds: 40 * (sira++).clamp(0, 8)),
        child: _PathCourseTile(
          course: course,
          isDark: isDark,
          isLast: course == path.last,
          bitenDers: yapilan,
          toplamDers: toplam,
          simdiBurada: course.id == siradaki,
        ),
      ));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => items[index],
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildLevelHeader(DifficultyLevel level, bool isDark) {
    final lang = lessonLang(context);
    final (label, subtitle, color) = switch (level) {
      DifficultyLevel.beginner => (
          lessonText(lang, 'Kolay', 'Easy', 'Leicht', 'Fácil'),
          lessonText(lang, 'Yazı yazmadan başla', 'Start without typing',
              'Ohne Tippen anfangen', 'Empieza sin teclado'),
          const Color(0xFF2E7D32),
        ),
      DifficultyLevel.intermediate => (
          lessonText(lang, 'Orta', 'Medium', 'Mittel', 'Medio'),
          lessonText(lang, 'Artık gerçek kod yazıyorsun',
              'Now you are writing real code',
              'Jetzt schreibst du echten Code',
              'Ahora escribes código de verdad'),
          const Color(0xFFEF6C00),
        ),
      DifficultyLevel.advanced => (
          lessonText(lang, 'Zor', 'Hard', 'Schwer', 'Difícil'),
          lessonText(lang, 'Büyük projelerin dilleri',
              'The languages of big projects',
              'Die Sprachen großer Projekte',
              'Los lenguajes de los grandes proyectos'),
          const Color(0xFFC62828),
        ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 22, 0, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          // SEVIYE ALT YAZISI TASIYORDU.
          //
          // Sutun sinirsiz genislikteydi: "Artik gercek kod yaziyorsun"
          // dar ekranda satira sigmayip saga tasiyordu (RenderFlex
          // overflow). Expanded, yaziyi kendi alanina hapsediyor.
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGrid(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = filteredCourses[index];
            return _CourseCard(course: course, isDark: isDark);
          },
          childCount: filteredCourses.length,
        ),
      ),
    );
  }
}

/// Ogrenme yolundaki tek bir kurs satiri.
///
/// Sol tarafta adim numarasi ve alt kursa uzanan baglanti cizgisi var; boylece
/// kurslar bagimsiz kutular degil, birbirini takip eden adimlar gibi okunuyor.
class _PathCourseTile extends StatelessWidget {
  final Course course;
  final bool isDark;
  final bool isLast;

  /// Bu kursta bitirilen ders sayisi ve toplam ders sayisi.
  final int bitenDers;
  final int toplamDers;

  /// Yoldaki ilk bitmemis kurs: cocugun su an durdugu yer.
  final bool simdiBurada;

  const _PathCourseTile({
    required this.course,
    required this.isDark,
    required this.isLast,
    this.bitenDers = 0,
    this.toplamDers = 0,
    this.simdiBurada = false,
  });

  bool get _tamamlandi => toplamDers > 0 && bitenDers >= toplamDers;
  double get _oran => toplamDers == 0 ? 0 : bitenDers / toplamDers;

  Future<void> _open(BuildContext context) async {
    // KURS KAPISI ARTIK KILITLI DEGIL.
    //
    // Pro kurslarda (Arduino IDE, Java, C#) eskiden liste bile
    // acilmiyordu: cocuk icerigi hic goremeden paywall ile karsilasiyordu.
    // Kilit ders basina tasindi — ilk iki ders odullu reklamla acilabiliyor,
    // ucuncuden itibaren Pro isteniyor (bkz. InteractiveCourseScreen).

    // Hangi kursun interaktif dersleri var? Tek kaynak: CourseModules.
    // Burada elle yazılan bir liste vardı ve mBlock eklendiğinde
    // güncellenmedi; kurs katalogda görünüyor, dersleri de yazılmış ama
    // tıklayınca tanıtım ekranı açılıyordu.
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CourseModules.wiredCourseIds.contains(course.id)
                ? InteractiveCourseScreen(course: course)
                : CourseDetailScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prerequisite =
        course.prerequisiteId == null ? null : CoursesData.byId(course.prerequisiteId!);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adim numarasi + baglanti cizgisi
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: simdiBurada ? 34 : 30,
                  height: simdiBurada ? 34 : 30,
                  decoration: BoxDecoration(
                    color: _tamamlandi
                        ? const Color(0xFF3BA55C)
                        : course.primaryColor,
                    shape: BoxShape.circle,
                    // SIRADAKI KURS BUYUK VE HALKALI: goz once oraya
                    // gitsin. Once butun adimlar ayni boyuttaydi ve
                    // "nereden devam ediyorum" sorusunun cevabi yoktu.
                    border: simdiBurada
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: (_tamamlandi
                                ? const Color(0xFF3BA55C)
                                : course.primaryColor)
                            .withValues(alpha: simdiBurada ? 0.55 : 0.35),
                        blurRadius: simdiBurada ? 14 : 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _tamamlandi
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : Text(
                            '${course.pathStep}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      // Bitmis kursun cizgisi YESIL: yol doluyor.
                      color: _tamamlandi
                          ? const Color(0xFF3BA55C).withValues(alpha: 0.55)
                          : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: GestureDetector(
                onTap: () => _open(context),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: course.primaryColor
                          .withValues(alpha: simdiBurada ? 0.75 : 0.25),
                      width: simdiBurada ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: simdiBurada
                            ? course.primaryColor.withValues(alpha: 0.22)
                            : Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.05),
                        blurRadius: simdiBurada ? 18 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: course.primaryColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: Text(course.icon, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    course.nameFor(lessonLang(context)),
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF1F1D36),
                                    ),
                                  ),
                                ),
                                if (course.isPremium &&
                                    !ProGate.watchIsPro(context)) ...[
                                  const SizedBox(width: 8),
                                  ProGate.badge(size: 9),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              course.descriptionFor(lessonLang(context)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.3,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // CIPLER TASIYORDU. Row sabit genislikte iki
                            // cip tutuyordu; "2 saat 40 dk" gibi uzun bir
                            // sure dar ekranda saga tasiyor ve sari-siyah
                            // seritler cikiyordu (RenderFlex overflow).
                            // Wrap, sigmayani alt satira aliyor.
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _chip(
                                    course.lessonCountTextFor(
                                        lessonLang(context)),
                                    course.primaryColor,
                                    isDark),
                                _chip(
                                    course.estimatedTimeTextFor(
                                        lessonLang(context)),
                                    course.primaryColor,
                                    isDark),
                              ],
                            ),
                            // ILERLEME: SAYI DEGIL, DOLAN BIR CIZGI.
                            //
                            // Bir cocuk "3/12" ifadesini okumadan once
                            // dolan cizgiyi goruyor. Yuzde YAZMIYORUZ —
                            // bitirilen ders sayisi gercek veri, uydurma
                            // bir "ustalik yuzdesi" degil.
                            if (toplamDers > 0 && bitenDers > 0) ...[
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: _oran),
                                        duration: const Duration(
                                            milliseconds: 650),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, v, _) =>
                                            LinearProgressIndicator(
                                          value: v,
                                          minHeight: 6,
                                          backgroundColor: isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade200,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            _tamamlandi
                                                ? const Color(0xFF3BA55C)
                                                : course.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$bitenDers/$toplamDers',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _tamamlandi
                                          ? const Color(0xFF3BA55C)
                                          : course.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (simdiBurada) ...[
                              const SizedBox(height: 9),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: course.primaryColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_arrow_rounded,
                                        size: 14, color: course.primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      bitenDers > 0
                                          ? lessonText(
                                              lessonLang(context),
                                              'Kaldığın yer',
                                              'Where you left off',
                                              'Wo du aufgehört hast',
                                              'Donde lo dejaste')
                                          : lessonText(
                                              lessonLang(context),
                                              'Buradan başla',
                                              'Start here',
                                              'Hier starten',
                                              'Empieza aquí'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: course.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (prerequisite != null) ...[
                              const SizedBox(height: 7),
                              Text(
                                lessonText(
                lessonLang(context),
                'Önce ${prerequisite.name} önerilir',
                '${prerequisite.nameFor('en')} first is recommended',
                '${prerequisite.nameFor('de')} zuerst empfohlen',
                'Se recomienda ${prerequisite.nameFor('es')} antes'),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
        ],
      ),
    );
  }

  Widget _chip(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? color.withValues(alpha: 0.95) : color,
        ),
      ),
    );
  }
}

/// Individual Course Card
class _CourseCard extends StatelessWidget {
  final Course course;
  final bool isDark;

  const _CourseCard({required this.course, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Pro kursun kapisi acik; kilit ders basina (bkz. _open).
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CourseModules.wiredCourseIds.contains(course.id)
                    ? InteractiveCourseScreen(course: course)
                    : CourseDetailScreen(course: course),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              course.primaryColor.withValues(alpha: 0.9),
              course.secondaryColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: course.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Stars overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: _MiniStarsPainter(),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      course.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    course.nameFor(lessonLang(context)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Difficulty badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      course.difficultyText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Stats
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        course.lessonCountTextFor(lessonLang(context)),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        course.estimatedTimeText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Premium badge
            if (course.isPremium)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Stars painter for app bar background
/// Baslik bandindaki yildizlar.
///
/// Once tamamen durgundu ve bant bir ekran goruntusu gibi duruyordu.
/// Simdi her yildiz kendi hizinda cok yavas yukari suzuluyor ve kendi
/// ritminde sonup yaniyor — 90 saniyelik tam tur, yani goz onu takip
/// etmiyor, yalnizca ekranin "canli" oldugunu hissediyor.
class _CanliYildizlar extends StatefulWidget {
  const _CanliYildizlar({required this.isDark});

  final bool isDark;

  @override
  State<_CanliYildizlar> createState() => _CanliYildizlarState();
}

class _CanliYildizlarState extends State<_CanliYildizlar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 90),
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _StarsPainter(isDark: widget.isDark, t: _c.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final bool isDark;

  /// 0..1 arasi tur konumu.
  final double t;

  _StarsPainter({required this.isDark, this.t = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    // Sabit tohum: yildizlar her acilista ayni yerde baslasin.
    final random = Random(42);

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y0 = random.nextDouble();
      final starSize = random.nextDouble() * 2 + 0.5;
      final taban = random.nextDouble() * 0.5 + 0.2;
      final hiz = 0.4 + random.nextDouble() * 0.8;
      final faz = random.nextDouble();

      // Yukari suzulme: alt kenardan cikan yildiz ustten giriyor.
      final y = ((y0 - t * hiz) % 1.0) * size.height;
      // Sonup yanma: her yildiz kendi fazinda.
      final parlaklik =
          (taban * (0.55 + 0.45 * sin((t * 4 + faz) * 2 * pi))).clamp(0.05, 1.0);

      paint.color = (isDark ? Colors.white : const Color(0xFF667eea))
          .withValues(alpha: parlaklik);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) =>
      old.t != t || old.isDark != isDark;
}

/// Mini stars for course cards
class _MiniStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    final random = Random(42);

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 1.5 + 0.3;

      paint.color = Colors.white.withValues(alpha: random.nextDouble() * 0.3 + 0.1);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
