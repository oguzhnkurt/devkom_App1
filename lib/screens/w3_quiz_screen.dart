/// W3Schools-style Quiz Screen
/// Quiz at the end of lessons with instant feedback
import 'package:flutter/material.dart';
import '../models/w3_lesson_model.dart';
import '../widgets/w3_widgets.dart';

class W3QuizScreen extends StatefulWidget {
  final W3Lesson lesson;
  final W3Quiz quiz;
  final Function(int score, int earnedXP) onQuizComplete;

  const W3QuizScreen({
    Key? key,
    required this.lesson,
    required this.quiz,
    required this.onQuizComplete,
  }) : super(key: key);

  @override
  State<W3QuizScreen> createState() => _W3QuizScreenState();
}

class _W3QuizScreenState extends State<W3QuizScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  int _correctAnswers = 0;
  final Map<int, String> _userAnswers = {};

  W3Question get _currentQuestion {
    return widget.quiz.questions[_currentQuestionIndex];
  }

  bool get _isLastQuestion {
    return _currentQuestionIndex >= widget.quiz.questions.length - 1;
  }

  int get _score {
    return (_correctAnswers / widget.quiz.questions.length * 100).round();
  }

  int get _earnedXP {
    // Base XP for quiz
    int baseXP = 50;
    // Bonus for high scores
    if (_score >= 90) {
      return baseXP + 30;
    } else if (_score >= 70) {
      return baseXP + 20;
    } else if (_score >= 50) {
      return baseXP + 10;
    }
    return baseXP;
  }

  void _checkAnswer() {
    if (_selectedAnswer == null) return;

    setState(() {
      _hasAnswered = true;
      _userAnswers[_currentQuestionIndex] = _selectedAnswer!;

      if (_selectedAnswer == _currentQuestion.correctAnswer) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _showResults();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
      });
    }
  }

  void _showResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QuizResultScreen(
          quiz: widget.quiz,
          score: _score,
          correctAnswers: _correctAnswers,
          totalQuestions: widget.quiz.questions.length,
          earnedXP: _earnedXP,
          onComplete: () {
            widget.onQuizComplete(_score, _earnedXP);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = _hasAnswered &&
        _selectedAnswer == _currentQuestion.correctAnswer;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.quiz.title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soru ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_currentQuestion.points} puan',
                      style: const TextStyle(
                        fontSize: 14,
                        color: W3Colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                W3ProgressBar(
                  progress: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
                ),
              ],
            ),
          ),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question text
                  Text(
                    _currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Code snippet if exists
                  if (_currentQuestion.code != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: W3Colors.codeBackground,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(
                        _currentQuestion.code!,
                        style: const TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Answer options
                  if (_currentQuestion.options != null)
                    ..._currentQuestion.options!.map((option) {
                      final isSelected = _selectedAnswer == option;
                      final isCorrectOption = option == _currentQuestion.correctAnswer;

                      Color? backgroundColor;
                      Color? borderColor;

                      if (_hasAnswered) {
                        if (isCorrectOption) {
                          backgroundColor = W3Colors.successGreen.withOpacity(0.1);
                          borderColor = W3Colors.successGreen;
                        } else if (isSelected && !isCorrectOption) {
                          backgroundColor = W3Colors.errorRed.withOpacity(0.1);
                          borderColor = W3Colors.errorRed;
                        }
                      } else if (isSelected) {
                        backgroundColor = W3Colors.primary.withOpacity(0.1);
                        borderColor = W3Colors.primary;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: _hasAnswered
                              ? null
                              : () {
                                  setState(() {
                                    _selectedAnswer = option;
                                  });
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: backgroundColor ?? Colors.white,
                              border: Border.all(
                                color: borderColor ?? Colors.grey.shade300,
                                width: borderColor != null ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                if (_hasAnswered && isCorrectOption)
                                  const Icon(
                                    Icons.check_circle,
                                    color: W3Colors.successGreen,
                                  )
                                else if (_hasAnswered && isSelected && !isCorrectOption)
                                  const Icon(
                                    Icons.cancel,
                                    color: W3Colors.errorRed,
                                  )
                                else if (isSelected)
                                  const Icon(
                                    Icons.radio_button_checked,
                                    color: W3Colors.primary,
                                  )
                                else
                                  Icon(
                                    Icons.radio_button_unchecked,
                                    color: Colors.grey.shade400,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                  // Explanation (shown after answering)
                  if (_hasAnswered) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? W3Colors.successGreen.withOpacity(0.1)
                            : W3Colors.warningBackground,
                        border: Border(
                          left: BorderSide(
                            color: isCorrect
                                ? W3Colors.successGreen
                                : W3Colors.warningBorder,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect ? '✓' : '✗',
                            style: TextStyle(
                              fontSize: 24,
                              color: isCorrect
                                  ? W3Colors.successGreen
                                  : W3Colors.errorRed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCorrect ? 'Doğru!' : 'Yanlış',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect
                                        ? W3Colors.successGreen
                                        : W3Colors.errorRed,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentQuestion.explanation,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
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
              ),
            ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: ElevatedButton(
              onPressed: _hasAnswered
                  ? _nextQuestion
                  : (_selectedAnswer != null ? _checkAnswer : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: W3Colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                _hasAnswered
                    ? (_isLastQuestion ? 'Sonuçları Gör' : 'Sonraki Soru »')
                    : 'Cevapla',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Quiz Result Screen
class _QuizResultScreen extends StatelessWidget {
  final W3Quiz quiz;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int earnedXP;
  final VoidCallback onComplete;

  const _QuizResultScreen({
    Key? key,
    required this.quiz,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.earnedXP,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPassed = score >= quiz.passingScore;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isPassed ? '🎉' : '💪',
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              Text(
                isPassed ? 'Harika!' : 'İyi Deneme!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isPassed
                    ? 'Quiz\'i başarıyla tamamladın!'
                    : 'Dersi tekrar gözden geçir ve tekrar dene.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 40),

              // Score card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score/100',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? W3Colors.successGreen : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$correctAnswers/$totalQuestions doğru cevap',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: W3Colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star,
                            color: W3Colors.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '+$earnedXP XP',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: W3Colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Complete button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close results
                  onComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: W3Colors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Dersi Tamamla',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
