import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_progress_service.dart';
import '../../models/leaderboard_model.dart';
import '../../models/game_model.dart';
import '../../core/service_locator.dart';
import 'widgets/step_widgets.dart' show lessonLangRead;
import '../../utils/lang.dart';

/// Quiz Screen - Interactive quiz experience
class QuizScreen extends StatefulWidget {
  final Course course;
  final Lesson lesson;
  final Quiz quiz;

  const QuizScreen({
    super.key,
    required this.course,
    required this.lesson,
    required this.quiz,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, dynamic> _answers = {};
  bool _showResult = false;
  int _score = 0;
  bool _isSubmitting = false;
  bool _hintVisible = false;
  final DateTime _startTime = DateTime.now();
  late final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  QuizQuestion get _currentQuestion =>
      widget.quiz.questions[_currentQuestionIndex];

  /// Ekranin dili.
  ///
  /// `lessonLangRead` kullaniliyor, `context.watch` DEGIL: bu getter
  /// build disindan (onPressed, sonuc ekrani kurulumu) da cagriliyor;
  /// watch orada provider assertion firlatip islemi SESSIZCE iptal
  /// ediyor. Ayni hata daha once takma ad kaydini ve onboarding
  /// isaretini kaybettirmisti.
  String get _lang => lessonLangRead(context);
  bool get _isLastQuestion => _currentQuestionIndex == widget.quiz.questions.length - 1;
  bool get _hasAnswered => _answers.containsKey(_currentQuestionIndex);

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: widget.course.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(
          'Quiz: ${widget.lesson.titleFor(_lang)}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
        // Segmentli ilerleme çubuğu (her soru için ayrı bir segment)
        _buildSegmentedProgress(),
        // Question content — soru değiştikçe kayarak/solarak geçiş yapar
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
              key: ValueKey(_currentQuestionIndex),
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionHeader(isDark),
                  const SizedBox(height: 24),
                  _buildQuestion(isDark),
                  const SizedBox(height: 20),
                  _buildOptions(isDark),
                  if (_hintVisible && _currentQuestion.explanationFor(_lang) != null) ...[
                    const SizedBox(height: 16),
                    _buildHintCard(isDark),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Bottom navigation
        _buildBottomBar(isDark),
      ],
    );
  }

  Widget _buildSegmentedProgress() {
    final total = widget.quiz.questions.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: List.generate(total, (index) {
          final filled = index <= _currentQuestionIndex;
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
              _currentQuestion.explanationFor(_lang)!,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.amber.shade100 : Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(bool isDark) {
    IconData icon;
    String typeText;
    Color typeColor;

    switch (_currentQuestion.type) {
      case QuestionType.multipleChoice:
        icon = Icons.check_circle_outline;
        typeText = AppLang.pick(_lang,
            tr: 'Çoktan Seçmeli',
            en: 'Multiple choice',
            de: 'Multiple Choice',
            es: 'Opción múltiple');
        typeColor = Colors.blue;
        break;
      case QuestionType.trueFalse:
        icon = Icons.thumbs_up_down_outlined;
        typeText = AppLang.pick(_lang,
            tr: 'Doğru/Yanlış',
            en: 'True / False',
            de: 'Richtig / Falsch',
            es: 'Verdadero / Falso');
        typeColor = Colors.purple;
        break;
      case QuestionType.fillInBlank:
        icon = Icons.edit_outlined;
        typeText = AppLang.pick(_lang,
            tr: 'Boşluk Doldur',
            en: 'Fill in the blank',
            de: 'Lücke füllen',
            es: 'Completa el hueco');
        typeColor = Colors.orange;
        break;
      case QuestionType.codeOutput:
        icon = Icons.code;
        typeText = AppLang.pick(_lang,
            tr: 'Kod Çıktısı',
            en: 'Code output',
            de: 'Code-Ausgabe',
            es: 'Salida del código');
        typeColor = Colors.green;
        break;
      case QuestionType.findError:
        icon = Icons.bug_report_outlined;
        typeText = AppLang.pick(_lang,
            tr: 'Hatayı Bul',
            en: 'Find the error',
            de: 'Finde den Fehler',
            es: 'Encuentra el error');
        typeColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: typeColor),
          const SizedBox(width: 8),
          Text(
            typeText,
            style: TextStyle(
              color: typeColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentQuestion.questionFor(_lang),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.4,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        if (_currentQuestion.codeSnippetFor(_lang) != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.course.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: SelectableText(
              _currentQuestion.codeSnippetFor(_lang)!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Color(0xFFD4D4D4),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOptions(bool isDark) {
    switch (_currentQuestion.type) {
      case QuestionType.multipleChoice:
      case QuestionType.codeOutput:
      case QuestionType.findError:
        return _buildMultipleChoice(isDark);
      case QuestionType.trueFalse:
        return _buildTrueFalse(isDark);
      case QuestionType.fillInBlank:
        return _buildFillInBlank(isDark);
    }
  }

  Widget _buildMultipleChoice(bool isDark) {
    final selectedIndex = _answers[_currentQuestionIndex];

    return Column(
      children: List.generate(_currentQuestion.optionsFor(_lang).length, (index) {
        final isSelected = selectedIndex == index;
        final option = _currentQuestion.optionsFor(_lang)[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() => _answers[_currentQuestionIndex] = index);
            },
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
                              String.fromCharCode(65 + index), // A, B, C, D
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
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTrueFalse(bool isDark) {
    final selectedAnswer = _answers[_currentQuestionIndex];

    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseOption(
            isDark,
            AppLang.pick(_lang,
                tr: 'Doğru', en: 'True', de: 'Richtig', es: 'Verdadero'),
            Icons.check_circle,
            Colors.green,
            true,
            selectedAnswer == true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTrueFalseOption(
            isDark,
            AppLang.pick(_lang,
                tr: 'Yanlış', en: 'False', de: 'Falsch', es: 'Falso'),
            Icons.cancel,
            Colors.red,
            false,
            selectedAnswer == false,
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseOption(
    bool isDark,
    String label,
    IconData icon,
    Color color,
    bool value,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        setState(() => _answers[_currentQuestionIndex] = value);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillInBlank(bool isDark) {
    return TextField(
      onChanged: (value) {
        setState(() => _answers[_currentQuestionIndex] = value);
      },
      decoration: InputDecoration(
        hintText: AppLang.pick(_lang,
            tr: 'Cevabını yaz...',
            en: 'Type your answer...',
            de: 'Antwort eingeben...',
            es: 'Escribe tu respuesta...'),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.course.primaryColor, width: 2),
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _toggleHint,
                icon: const Icon(Icons.lightbulb, color: Colors.amber),
                tooltip: AppLang.pick(_lang,
                    tr: 'İpucu', en: 'Hint', de: 'Tipp', es: 'Pista'),
              ),
            ),
            const SizedBox(width: 8),
            if (_currentQuestionIndex > 0)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex--;
                    _hintVisible = false;
                  });
                },
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(AppLang.pick(_lang,
                    tr: 'Önceki',
                    en: 'Previous',
                    de: 'Zurück',
                    es: 'Anterior')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.grey.shade700,
                  side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                ),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _hasAnswered
                  ? (_isLastQuestion ? _submitQuiz : _nextQuestion)
                  : null,
              icon: Icon(
                _isLastQuestion ? Icons.check_circle : Icons.arrow_forward,
                size: 20,
              ),
              label: Text(_isLastQuestion
                  ? AppLang.pick(_lang,
                      tr: 'Bitir', en: 'Finish', de: 'Fertig', es: 'Terminar')
                  : AppLang.pick(_lang,
                      tr: 'Sonraki',
                      en: 'Next',
                      de: 'Weiter',
                      es: 'Siguiente')),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.course.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _hintVisible = false;
    });
  }

  void _toggleHint() {
    if (_currentQuestion.explanationFor(_lang) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLang.pick(_lang,
                tr: 'Bu soru için ipucu yok, ama tahmin etmekten çekinme!',
                en: "There's no hint for this one, but go ahead and guess!",
                de: 'Für diese Frage gibt es keinen Tipp — rate ruhig!',
                es: 'Esta pregunta no tiene pista, ¡pero anímate a probar!'))),
      );
      return;
    }
    setState(() => _hintVisible = !_hintVisible);
  }

  void _submitQuiz() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final question = widget.quiz.questions[i];
      final userAnswer = _answers[i];

      if (question.type == QuestionType.fillInBlank) {
        if (userAnswer.toString().toLowerCase().trim() ==
            question.correctAnswer.toString().toLowerCase().trim()) {
          correctAnswers++;
        }
      } else {
        if (userAnswer == question.correctAnswer) {
          correctAnswers++;
        }
      }
    }

    _score = ((correctAnswers / widget.quiz.questions.length) * 100).round();
    final timeSeconds = DateTime.now().difference(_startTime).inSeconds;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Lider tablosuna kaydet (geçse de kalsa da — Quiz Merkezi'ndeki
    // Sıralama sekmesinde görünür, bkz. GameType.quiz).
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      try {
        await leaderboardService.addEntry(LeaderboardEntry(
          id: '',
          userId: authProvider.currentUser!.uid,
          userName: authProvider.currentUser!.displayName,
          gameType: GameType.quiz,
          score: _score,
          timeSeconds: timeSeconds,
          correctCount: correctAnswers,
          totalQuestions: widget.quiz.questions.length,
          completedAt: DateTime.now(),
        ));
      } catch (_) {
        // Lider tablosu yazımı başarısız olsa da quiz sonucu kullanıcıya
        // gösterilmeye devam etmeli.
      }
    }

    // Award XP if passed
    if (_score >= widget.quiz.passingScore) {
      if (authProvider.isAuthenticated) {
        await authProvider.addXP(widget.quiz.xpReward);
        // Jeton ödülü: doğru cevap başına (Market'te harcanabilir)
        final userId = authProvider.currentUser?.uid;
        if (userId != null) {
          await UserProgressService().addJeton(userId, correctAnswers * 3, source: 'quiz');
          await authProvider.refreshProgress();
        }
      }
    }

    setState(() {
      _showResult = true;
      _isSubmitting = false;
    });

    if (_score >= widget.quiz.passingScore) {
      _confettiController.play();
    }
  }

  Widget _buildResultScreen(bool isDark) {
    final passed = _score >= widget.quiz.passingScore;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Result icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: (passed ? Colors.green : Colors.orange).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                passed ? '🎉' : '💪',
                style: const TextStyle(fontSize: 56),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            passed ? 'Tebrikler!' : 'Tekrar Dene!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            passed
                ? AppLang.pick(_lang,
                    tr: 'Quizi başarıyla tamamladın!',
                    en: 'You finished the quiz!',
                    de: 'Du hast das Quiz geschafft!',
                    es: '¡Has completado el cuestionario!')
                : AppLang.pick(_lang,
                    tr: 'Biraz daha çalışınca başaracaksın!',
                    en: "A little more practice and you've got this!",
                    de: 'Noch ein bisschen üben, dann klappt es!',
                    es: '¡Con un poco más de práctica lo consigues!'),
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          // Score circle — hafif bir "pop" animasyonuyla belirir
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
                  Text(
                    '$_score%',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    AppLang.pick(_lang,
                        tr: 'Başarı',
                        en: 'Score',
                        de: 'Ergebnis',
                        es: 'Resultado'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 24),
          // Stats
          Container(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  isDark,
                  Icons.help_outline,
                  '${widget.quiz.questions.length}',
                  'Soru',
                  Colors.blue,
                ),
                _buildStatItem(
                  isDark,
                  Icons.check_circle_outline,
                  '${(_score * widget.quiz.questions.length / 100).round()}',
                  AppLang.pick(_lang,
                      tr: 'Doğru',
                      en: 'Correct',
                      de: 'Richtig',
                      es: 'Aciertos'),
                  Colors.green,
                ),
                _buildStatItem(
                  isDark,
                  Icons.star_outline,
                  passed ? '+${widget.quiz.xpReward}' : '0',
                  'XP',
                  Colors.amber,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Review answers
          if (!passed) ...[
            Text(
              AppLang.pick(_lang,
                  tr: 'Cevapları İncele',
                  en: 'Review answers',
                  de: 'Antworten ansehen',
                  es: 'Revisar respuestas'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(widget.quiz.questions.length, (index) {
              return _buildAnswerReview(index, isDark);
            }),
          ],
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              if (!passed)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex = 0;
                        _answers.clear();
                        _showResult = false;
                        _score = 0;
                        _hintVisible = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
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
                  onPressed: () {
                    Navigator.pop(context, passed);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(passed ? 'Devam Et' : 'Kursa Don'),
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
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerReview(int index, bool isDark) {
    final question = widget.quiz.questions[index];
    final userAnswer = _answers[index];
    bool isCorrect;

    if (question.type == QuestionType.fillInBlank) {
      isCorrect = userAnswer.toString().toLowerCase().trim() ==
          question.correctAnswer.toString().toLowerCase().trim();
    } else {
      isCorrect = userAnswer == question.correctAnswer;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLang.pick(_lang,
                    tr: 'Soru ${index + 1}',
                    en: 'Question ${index + 1}',
                    de: 'Frage ${index + 1}',
                    es: 'Pregunta ${index + 1}'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.questionFor(_lang),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          if (!isCorrect && question.explanationFor(_lang) != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanationFor(_lang)!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLang.pick(_lang,
            tr: 'Quizden çık',
            en: 'Leave the quiz',
            de: 'Quiz verlassen',
            es: 'Salir del cuestionario')),
        content: Text(AppLang.pick(_lang,
            tr: 'İlerlemen kaydedilmeyecek. Çıkmak istediğine emin misin?',
            en: "Your progress won't be saved. Are you sure you want to quit?",
            de: 'Dein Fortschritt wird nicht gespeichert. Wirklich beenden?',
            es: 'Tu progreso no se guardará. ¿Seguro que quieres salir?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLang.pick(_lang,
                tr: 'İptal',
                en: 'Cancel',
                de: 'Abbrechen',
                es: 'Cancelar')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit quiz
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AppLang.pick(_lang,
                tr: 'Çık', en: 'Quit', de: 'Beenden', es: 'Salir')),
          ),
        ],
      ),
    );
  }
}
