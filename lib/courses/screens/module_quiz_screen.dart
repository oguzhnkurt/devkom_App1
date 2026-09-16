import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_progress_service.dart';
import '../../models/leaderboard_model.dart';
import '../../models/game_model.dart';
import '../../core/service_locator.dart';
import 'widgets/step_widgets.dart' show lessonLang;
import '../../ui/press_button.dart';
import '../../utils/lang.dart';

/// Modul Quizi - gercek kullanicilarin gordugu InteractiveLesson/System B
/// akisinda, bir modulun derslerinin icine gomulu MultipleChoiceStep
/// sorularini toplayip Quizo-ilhamli (segmentli ilerleme, konfeti, ipucu,
/// lider tablosu) bir quiz deneyimi olarak sunar.
///
/// Boylece "kurs sonunda quiz" istegi, System A'nin ayri/olu QuizScreen'i
/// yerine gercekten kullanicilarin gectigi yolda karsilanmis olur.
class ModuleQuizScreen extends StatefulWidget {
  final Course course;
  final String moduleTitle;
  final String? moduleTitleEn;
  final String? moduleTitleDe;
  final String? moduleTitleEs;
  final List<MultipleChoiceStep> questions;

  const ModuleQuizScreen({
    super.key,
    required this.course,
    required this.moduleTitle,
    this.moduleTitleEn,
    this.moduleTitleDe,
    this.moduleTitleEs,
    required this.questions,
  });

  /// Bir moduldeki tum derslerin icine gomulu MultipleChoiceStep'leri toplar.
  /// Cok uzun modullerde quiz'i makul tutmak icin en fazla [maxQuestions]
  /// soru alinir (karistirilarak).
  static List<MultipleChoiceStep> collectQuestions(
    List<InteractiveLesson> lessons, {
    int maxQuestions = 10,
  }) {
    final all = <MultipleChoiceStep>[];
    for (final lesson in lessons) {
      for (final step in lesson.steps) {
        if (step is MultipleChoiceStep) {
          all.add(step);
        }
      }
    }
    all.shuffle();
    if (all.length > maxQuestions) {
      return all.sublist(0, maxQuestions);
    }
    return all;
  }

  @override
  State<ModuleQuizScreen> createState() => _ModuleQuizScreenState();
}

class _ModuleQuizScreenState extends State<ModuleQuizScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  bool _showResult = false;
  int _score = 0;
  bool _isSubmitting = false;
  bool _hintVisible = false;
  final DateTime _startTime = DateTime.now();
  late final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  static const int passingScore = 60;
  static const int xpReward = 40;

  MultipleChoiceStep get _currentQuestion => widget.questions[_currentIndex];
  bool get _isLastQuestion => _currentIndex == widget.questions.length - 1;
  bool get _hasAnswered => _answers.containsKey(_currentIndex);
  String get _lang => lessonLang(context);

  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  ///
  /// Onceki surumde her yerde `_lang == 'en' ? ingilizce : turkce`
  /// vardi; almanca ya da ispanyolca secen cocuk quizin arayuzunu
  /// bastan sona Turkce goruyordu.
  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Modulun dort dilde basligi var (CourseModule.titleDe/titleEs);
    // eskiden bu ekran yalnizca tr/en aliyordu ve Almanca secen cocuga
    // modul adi Ingilizce gorunuyordu.
    final title = AppLang.pick(
      _lang,
      tr: widget.moduleTitle,
      en: widget.moduleTitleEn ?? widget.moduleTitle,
      de: widget.moduleTitleDe,
      es: widget.moduleTitleEs,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: widget.course.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(
          _t('Modül Quizi: $title', 'Module Quiz: $title', 'Modul-Quiz: $title', 'Cuestionario del módulo: $title'),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!_showResult)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1}/${widget.questions.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          _showResult ? _buildResultScreen(isDark) : _buildQuestionScreen(isDark),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 40,
              gravity: 0.15,
              shouldLoop: false,
              colors: [
                widget.course.primaryColor,
                widget.course.secondaryColor,
                Colors.amber,
                Colors.green,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(bool isDark) {
    return Column(
      children: [
        _buildSegmentedProgress(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
            ),
            child: SingleChildScrollView(
              key: ValueKey(_currentIndex),
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionHeader(),
                  const SizedBox(height: 24),
                  Text(
                    _currentQuestion.questionFor(_lang),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildOptions(isDark),
                  if (_hintVisible) ...[
                    const SizedBox(height: 16),
                    _buildHintCard(isDark),
                  ],
                ],
              ),
            ),
          ),
        ),
        _buildBottomBar(isDark),
      ],
    );
  }

  Widget _buildSegmentedProgress() {
    final total = widget.questions.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: List.generate(total, (index) {
          final filled = index <= _currentIndex;
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
              decoration: BoxDecoration(
                color: filled ? widget.course.primaryColor : widget.course.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            _t('Çoktan Seçmeli', 'Multiple Choice', 'Multiple Choice', 'Opción múltiple'),
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _currentQuestion.explanationFor(_lang),
              style: TextStyle(fontSize: 13, color: isDark ? Colors.amber.shade100 : Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(bool isDark) {
    final selectedIndex = _answers[_currentIndex];
    return Column(
      children: List.generate(_currentQuestion.options.length, (index) {
        final isSelected = selectedIndex == index;
        final option = _currentQuestion.options[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => setState(() => _answers[_currentIndex] = index),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.course.primaryColor.withValues(alpha: 0.1)
                    : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? widget.course.primaryColor
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.course.primaryColor
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.grey.shade700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option.textFor(_lang),
                      style: TextStyle(fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                    ),
                  ),
                  // Not: option.emoji derslerde genellikle ✅/❌ seklinde
                  // cevap anahtari tasir (bkz. ayni sorularin ders icindeki
                  // hali). Quiz modunda gercek bir "test" deneyimi olmasi
                  // icin bilerek gosterilmiyor - dogru/yanlis geri bildirimi
                  // yalnizca cevap verildikten sonra ipucu kartinda
                  // (aciklama metni) veriliyor.
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: IconButton(
                onPressed: _toggleHint,
                icon: const Icon(Icons.lightbulb, color: Colors.amber),
                tooltip: _t('İpucu', 'Hint', 'Tipp', 'Pista'),
              ),
            ),
            const SizedBox(width: 8),
            if (_currentIndex > 0)
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _currentIndex--;
                  _hintVisible = false;
                }),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(_t('Önceki', 'Previous', 'Zurück', 'Anterior')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.grey.shade700,
                  side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                ),
              ),
            const SizedBox(width: 12),
            // Ana eylem butonu her ekranda ayni davransin diye ortak
            // PressButton: basildiginda gercekten cokuyor, dokunusun
            // kaydedildigi ekrandan goruluyor.
            Expanded(
              child: PressButton(
                label: _isLastQuestion
                    ? (_t('Bitir', 'Finish', 'Fertig', 'Terminar'))
                    : (_t('Sonraki', 'Next', 'Weiter', 'Siguiente')),
                icon: _isLastQuestion
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
                color: widget.course.primaryColor,
                loading: _isSubmitting,
                onPressed: _hasAnswered
                    ? (_isLastQuestion ? _submitQuiz : _nextQuestion)
                    : null,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _hintVisible = false;
    });
  }

  void _toggleHint() {
    setState(() => _hintVisible = !_hintVisible);
  }

  void _submitQuiz() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    int correct = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (_answers[i] == widget.questions[i].correctIndex) correct++;
    }
    _score = ((correct / widget.questions.length) * 100).round();
    final timeSeconds = DateTime.now().difference(_startTime).inSeconds;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Lider tablosuna kaydet — Quiz Merkezi'ndeki Siralama sekmesinde de
    // gorunur (bkz. GameType.quiz), gecse de kalsa da yaziliyor.
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      try {
        await leaderboardService.addEntry(LeaderboardEntry(
          id: '',
          userId: authProvider.currentUser!.uid,
          userName: authProvider.currentUser!.displayName,
          gameType: GameType.quiz,
          score: _score,
          timeSeconds: timeSeconds,
          correctCount: correct,
          totalQuestions: widget.questions.length,
          completedAt: DateTime.now(),
        ));
      } catch (_) {
        // Lider tablosu yazimi basarisiz olsa da sonuc kullaniciya
        // gosterilmeye devam etmeli.
      }
    }

    if (_score >= passingScore) {
      if (authProvider.isAuthenticated) {
        await authProvider.addXP(xpReward);
        final userId = authProvider.currentUser?.uid;
        if (userId != null) {
          await UserProgressService().addJeton(userId, correct * 3, source: 'module_quiz');
          await authProvider.refreshProgress();
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _showResult = true;
      _isSubmitting = false;
    });

    if (_score >= passingScore) {
      _confettiController.play();
    }
  }

  /// Dogru cevaplanan soru sayisi.
  int get _yanlisOlmayanSayisi {
    var n = 0;
    for (var i = 0; i < widget.questions.length; i++) {
      if (_answers[i] == widget.questions[i].correctIndex) n++;
    }
    return n;
  }

  /// Yanlis (ya da hic cevaplanmamis) sorularin sira numaralari.
  List<int> get _yanlisSorular {
    final liste = <int>[];
    for (var i = 0; i < widget.questions.length; i++) {
      if (_answers[i] != widget.questions[i].correctIndex) liste.add(i);
    }
    return liste;
  }

  /// Sonuc ekranindaki "yanlislarini gozden gecir" bolumu.
  ///
  /// Quiz bitince yalnizca yuzde ve dogru sayisi gosteriliyordu: cocuk
  /// HANGI soruyu yanlis bildigini, dogrusunun ne oldugunu hic
  /// ogrenemiyordu. Quizin ogretici kismi burasi.
  Widget _buildYanlisInceleme(bool isDark) {
    final yanlislar = _yanlisSorular;
    final kartRengi = isDark ? const Color(0xFF1E1E2E) : Colors.white;

    if (yanlislar.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _t('Bütün soruları doğru bildin — gözden geçirecek bir şey yok.',
                    'You got every question right — nothing to review.',
                    'Du hast alle Fragen richtig — nichts zu wiederholen.',
                    'Acertaste todas las preguntas: no hay nada que repasar.'),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.fact_check_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              _t('Yanlış bildiklerin (${yanlislar.length})',
                  'What you missed (${yanlislar.length})',
                  'Was du verpasst hast (${yanlislar.length})',
                  'Lo que fallaste (${yanlislar.length})'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...yanlislar.map((i) {
          final soru = widget.questions[i];
          final verilen = _answers[i];
          final dogruMetin = soru.options[soru.correctIndex].textFor(_lang);
          final aciklama = soru.explanationFor(_lang);

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kartRengi,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}. ${soru.questionFor(_lang)}',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                // Cocugun verdigi cevap. Hic cevaplamadiysa onu soyluyoruz;
                // bos birakmak "yanlis bildim" ile ayni sey degil.
                _cevapSatiri(
                  isDark,
                  Icons.cancel_rounded,
                  Colors.red,
                  _t('Senin cevabın', 'Your answer', 'Deine Antwort',
                      'Tu respuesta'),
                  verilen == null
                      ? _t('Boş bıraktın', 'Left blank', 'Nicht beantwortet',
                          'Sin responder')
                      : soru.options[verilen].textFor(_lang),
                ),
                const SizedBox(height: 6),
                _cevapSatiri(
                  isDark,
                  Icons.check_circle_rounded,
                  Colors.green,
                  _t('Doğrusu', 'Correct answer', 'Richtige Antwort',
                      'Respuesta correcta'),
                  dogruMetin,
                ),
                if (aciklama.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    aciklama,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _cevapSatiri(bool isDark, IconData ikon, Color renk, String etiket,
      String metin) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(ikon, size: 18, color: renk),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
              children: [
                TextSpan(
                  text: '$etiket: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: metin),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen(bool isDark) {
    final passed = _score >= passingScore;
    // Eskiden dogru sayisi yuzdeden GERI hesaplaniyordu
    // ((_score * soru / 100).round()); yuvarlama yuzunden 7 dogruyu
    // 8 gosterebiliyordu. Artik dogrudan sayiliyor.
    final correct = _yanlisOlmayanSayisi;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: (passed ? Colors.green : Colors.orange).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(passed ? '🎉' : '💪', style: const TextStyle(fontSize: 56))),
          ),
          const SizedBox(height: 24),
          Text(
            passed
                ? (_t('Tebrikler!', 'Congratulations!', 'Glückwunsch!', '¡Felicidades!'))
                : (_t('Tekrar Dene!', 'Try Again!', 'Noch mal versuchen!', '¡Inténtalo otra vez!')),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          Text(
            passed
                ? (_t('Modül quizini başarıyla tamamladın!', 'You completed the module quiz!', 'Du hast das Modul-Quiz geschafft!', '¡Completaste el cuestionario del módulo!'))
                : (_t('Biraz daha çalışırsan başarırsın!', 'A bit more practice and you\'ll get it!', 'Mit etwas mehr Übung schaffst du es!', 'Con un poco más de práctica lo consigues!')),
            style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: passed
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.orange.shade400, Colors.orange.shade600],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$_score%', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(
                      _t('Başarı', 'Score', 'Ergebnis', 'Resultado'),
                      style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(isDark, Icons.help_outline, '${widget.questions.length}', _t('Soru', 'Questions', 'Fragen', 'Preguntas'), Colors.blue),
                _buildStatItem(isDark, Icons.check_circle_outline, '$correct', _t('Doğru', 'Correct', 'Richtig', 'Correctas'), Colors.green),
                _buildStatItem(isDark, Icons.star_outline, passed ? '+$xpReward' : '0', 'XP', Colors.amber),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildYanlisInceleme(isDark),
          const SizedBox(height: 32),
          Row(
            children: [
              if (!passed)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                        _answers.clear();
                        _showResult = false;
                        _score = 0;
                        _hintVisible = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(_t('Tekrar Dene', 'Try Again', 'Noch mal', 'Otra vez')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: widget.course.primaryColor,
                      side: BorderSide(color: widget.course.primaryColor),
                    ),
                  ),
                ),
              if (!passed) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, passed),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(passed
                      ? (_t('Devam Et', 'Continue', 'Weiter', 'Continuar'))
                      : (_t('Kursa Dön', 'Back to Course', 'Zurück zum Kurs', 'Volver al curso'))),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: widget.course.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(bool isDark, IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_t('Quizden çık', 'Exit quiz', 'Quiz verlassen', 'Salir del cuestionario')),
        content: Text(_t('İlerlemen kaybedilecek. Emin misin?', 'Your progress will be lost. Are you sure?', 'Dein Fortschritt geht verloren. Bist du sicher?', 'Perderás tu progreso. ¿Seguro?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('Devam Et', 'Continue', 'Weiter', 'Continuar')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: Text(_t('Çık', 'Exit', 'Verlassen', 'Salir')),
          ),
        ],
      ),
    );
  }
}
