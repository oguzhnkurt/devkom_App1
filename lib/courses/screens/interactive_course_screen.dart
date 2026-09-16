import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ad_unlock_service.dart';
import '../../utils/lang.dart';
import '../../utils/pro_gate.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../data/course_modules.dart';
import 'interactive_lesson_screen.dart';
import 'module_quiz_screen.dart';
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

  String _getCourseEmoji() {
    switch (widget.course.id) {
      case 'scratch':
        return '🐱';
      case 'scratch_junior':
        return '🌟';
      case 'html':
        return '🌐';
      case 'css':
        return '🎨';
      case 'javascript':
        return '⚡';
      case 'python':
        return '🐍';
      case 'arduino':
        return '🤖';
      case 'arduino_ide':
        return '💻';
      case 'java':
        return '☕';
      case 'csharp':
        return '💜';
      default:
        return '📚';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_modules.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.course.name)),
        body: Center(
          child: Text(lessonLang(context) == 'en'
              ? 'Interactive content for this course is not ready yet.'
              : 'Bu kurs için interaktif içerik henüz hazır değil.'),
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
          widget.course.name,
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
              child: _AnimatedEmoji(emoji: _getCourseEmoji()),
            ),
            // Decorative elements
            ...List.generate(8, (i) {
              final random = Random(i);
              return Positioned(
                left: random.nextDouble() * 300,
                top: random.nextDouble() * 150,
                child: Opacity(
                  opacity: 0.15,
                  child: Transform.rotate(
                    angle: random.nextDouble() * 0.5,
                    child: Container(
                      width: 40 + random.nextDouble() * 30,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(bool isDark) {
    final totalLessons = _modules.fold<int>(0, (sum, m) => sum + m.lessons.length);
    const completedLessons = 0; // TODO: Get from user data
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    final totalXp = _modules.fold<int>(0, (sum, m) =>
      sum + m.lessons.fold<int>(0, (s, l) => s + l.xpReward));

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
                      lessonText(lessonLang(context), 'İlerleme', 'Progress'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      icon: Icons.school,
                      label: 'Ders',
                      value: '$completedLessons / $totalLessons',
                      color: widget.course.primaryColor,
                    ),
                    const SizedBox(height: 4),
                    _buildStatRow(
                      icon: Icons.star,
                      label: 'XP',
                      value: '0 / $totalXp',
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
              onPressed: () => _startFirstAvailableLesson(),
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
                  const Icon(Icons.play_arrow, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    lessonText(lessonLang(context), 'Öğrenmeye Başla',
                        'Start learning'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
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
                    lessonLang(context) == 'en' ? 'Module ${index + 1}' : 'Modül ${index + 1}',
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
                  '${module.lessons.length} ders',
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
    final questions = ModuleQuizScreen.collectQuestions(module.lessons);
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
                      lang == 'en' ? 'Module Quiz' : 'Modül Quizi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lang == 'en'
                          ? 'Test yourself with ${questions.length} questions from this module'
                          : 'Bu moduldeki ${questions.length} soruyla kendini test et',
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
    final completedIds = context
            .watch<AuthProvider>()
            .userProgress
            ?.completedLessonIds
            .toSet() ??
        const <String>{};
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
                        Row(
                          children: [
                            _buildLessonStat(
                              Icons.flash_on,
                              lessonText(
                                  lessonLang(context),
                                  '${lesson.steps.length} adım',
                                  '${lesson.steps.length} steps'),
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
                                'Rozet',
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

  Future<void> _startFirstAvailableLesson() async {
    if (_modules.isNotEmpty && _modules[0].lessons.isNotEmpty) {
      await _openLesson(_modules[0].lessons.first);
    }
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
