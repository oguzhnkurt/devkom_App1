import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../../providers/auth_provider.dart';

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

  QuizQuestion get _currentQuestion => widget.quiz.questions[_currentQuestionIndex];
  bool get _isLastQuestion => _currentQuestionIndex == widget.quiz.questions.length - 1;
  bool get _hasAnswered => _answers.containsKey(_currentQuestionIndex);

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
          'Quiz: ${widget.lesson.title}',
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
      body: _showResult ? _buildResultScreen(isDark) : _buildQuestionScreen(isDark),
    );
  }

  Widget _buildQuestionScreen(bool isDark) {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
          backgroundColor: widget.course.primaryColor.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(widget.course.primaryColor),
          minHeight: 6,
        ),
        // Question content
        Expanded(
          child: SingleChildScrollView(
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
              ],
            ),
          ),
        ),
        // Bottom navigation
        _buildBottomBar(isDark),
      ],
    );
  }

  Widget _buildQuestionHeader(bool isDark) {
    IconData icon;
    String typeText;
    Color typeColor;

    switch (_currentQuestion.type) {
      case QuestionType.multipleChoice:
        icon = Icons.check_circle_outline;
        typeText = 'Coktan Secmeli';
        typeColor = Colors.blue;
        break;
      case QuestionType.trueFalse:
        icon = Icons.thumbs_up_down_outlined;
        typeText = 'Dogru/Yanlis';
        typeColor = Colors.purple;
        break;
      case QuestionType.fillInBlank:
        icon = Icons.edit_outlined;
        typeText = 'Bosluk Doldur';
        typeColor = Colors.orange;
        break;
      case QuestionType.codeOutput:
        icon = Icons.code;
        typeText = 'Kod Ciktisi';
        typeColor = Colors.green;
        break;
      case QuestionType.findError:
        icon = Icons.bug_report_outlined;
        typeText = 'Hata Bul';
        typeColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withOpacity(0.3)),
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
          _currentQuestion.question,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.4,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        if (_currentQuestion.codeSnippet != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.course.primaryColor.withOpacity(0.3),
              ),
            ),
            child: SelectableText(
              _currentQuestion.codeSnippet!,
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
      children: List.generate(_currentQuestion.options.length, (index) {
        final isSelected = selectedIndex == index;
        final option = _currentQuestion.options[index];

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
                    ? widget.course.primaryColor.withOpacity(0.1)
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
            'Dogru',
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
            'Yanlis',
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
              ? color.withOpacity(0.1)
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
        hintText: 'Cevabinizi yazin...',
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentQuestionIndex > 0)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _currentQuestionIndex--);
                },
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Onceki'),
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
              label: Text(_isLastQuestion ? 'Bitir' : 'Sonraki'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.course.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextQuestion() {
    setState(() => _currentQuestionIndex++);
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

    // Award XP if passed
    if (_score >= widget.quiz.passingScore) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        await authProvider.addXP(widget.quiz.xpReward);
      }
    }

    setState(() {
      _showResult = true;
      _isSubmitting = false;
    });
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
              color: (passed ? Colors.green : Colors.orange).withOpacity(0.1),
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
                ? 'Quizi basariyla tamamladin!'
                : 'Biraz daha calisarak basarabilirsin!',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          // Score circle
          Container(
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
                    'Basari',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
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
                  color: Colors.black.withOpacity(0.05),
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
                  'Dogru',
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
              'Cevaplari Incele',
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
          color: isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
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
                'Soru ${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          if (!isCorrect && question.explanation != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation!,
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
        title: const Text('Quiz\'den Cik'),
        content: const Text('Ilerlemen kaydedilmeyecek. Cikmak istediginize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit quiz
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cik'),
          ),
        ],
      ),
    );
  }
}
