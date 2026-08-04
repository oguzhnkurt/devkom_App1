import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';

/// Math Games Screen
/// Collection of interactive math games for students
class MathGamesScreen extends StatelessWidget {
  const MathGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {
        'title': 'Toplama Yarışması',
        'description': 'Hızlı toplama yaparak puan kazan!',
        'icon': Icons.add_circle,
        'color': const Color(0xFF4CAF50),
        'difficulty': 'Kolay',
        'type': 'addition',
      },
      {
        'title': 'Çıkarma Ustası',
        'description': 'Çıkarma işlemlerinde ustalaş!',
        'icon': Icons.remove_circle,
        'color': const Color(0xFFFF9800),
        'difficulty': 'Kolay',
        'type': 'subtraction',
      },
      {
        'title': 'Çarpma Çarkı',
        'description': 'Çarpım tablosunu öğren!',
        'icon': Icons.clear,
        'color': const Color(0xFF2196F3),
        'difficulty': 'Orta',
        'type': 'multiplication',
      },
      {
        'title': 'Bölme Şampiyonu',
        'description': 'Bölme işlemlerini çöz!',
        'icon': Icons.calculate,
        'color': const Color(0xFF9C27B0),
        'difficulty': 'Zor',
        'type': 'division',
      },
      {
        'title': 'Karışık Matematik',
        'description': 'Tüm işlemleri karıştır!',
        'icon': Icons.shuffle,
        'color': const Color(0xFFE91E63),
        'difficulty': 'Zor',
        'type': 'mixed',
      },
      {
        'title': 'Zaman Yarışı',
        'description': '60 saniyede ne kadar soru çözebilirsin?',
        'icon': Icons.timer,
        'color': const Color(0xFFFF5722),
        'difficulty': 'Orta',
        'type': 'timed',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return _buildGameCard(context, game);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matematik Oyunları',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Eğlenerek öğren!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.functions,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MathGamePlayScreen(
              title: game['title'],
              type: game['type'],
              color: game['color'],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    game['color'] as Color,
                    (game['color'] as Color).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  game['icon'] as IconData,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (game['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        game['difficulty'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: game['color'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Math Game Play Screen
class MathGamePlayScreen extends StatefulWidget {
  final String title;
  final String type;
  final Color color;

  const MathGamePlayScreen({
    super.key,
    required this.title,
    required this.type,
    required this.color,
  });

  @override
  State<MathGamePlayScreen> createState() => _MathGamePlayScreenState();
}

class _MathGamePlayScreenState extends State<MathGamePlayScreen> {
  late ConfettiController _confettiController;
  final Random _random = Random();
  int _score = 0;
  int _questionCount = 0;
  int _currentNum1 = 0;
  int _currentNum2 = 0;
  String _currentOperation = '+';
  int _correctAnswer = 0;
  List<int> _options = [];
  int? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _generateQuestion();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    setState(() {
      _selectedAnswer = null;
      _showFeedback = false;
      _questionCount++;

      switch (widget.type) {
        case 'addition':
          _currentOperation = '+';
          _currentNum1 = _random.nextInt(20) + 1;
          _currentNum2 = _random.nextInt(20) + 1;
          _correctAnswer = _currentNum1 + _currentNum2;
          break;

        case 'subtraction':
          _currentOperation = '-';
          _currentNum1 = _random.nextInt(30) + 10;
          _currentNum2 = _random.nextInt(_currentNum1);
          _correctAnswer = _currentNum1 - _currentNum2;
          break;

        case 'multiplication':
          _currentOperation = '×';
          _currentNum1 = _random.nextInt(10) + 1;
          _currentNum2 = _random.nextInt(10) + 1;
          _correctAnswer = _currentNum1 * _currentNum2;
          break;

        case 'division':
          _currentOperation = '÷';
          _currentNum2 = _random.nextInt(9) + 2;
          final multiplier = _random.nextInt(10) + 1;
          _currentNum1 = _currentNum2 * multiplier;
          _correctAnswer = _currentNum1 ~/ _currentNum2;
          break;

        case 'mixed':
        case 'timed':
          final operations = ['+', '-', '×'];
          _currentOperation = operations[_random.nextInt(operations.length)];

          if (_currentOperation == '+') {
            _currentNum1 = _random.nextInt(20) + 1;
            _currentNum2 = _random.nextInt(20) + 1;
            _correctAnswer = _currentNum1 + _currentNum2;
          } else if (_currentOperation == '-') {
            _currentNum1 = _random.nextInt(30) + 10;
            _currentNum2 = _random.nextInt(_currentNum1);
            _correctAnswer = _currentNum1 - _currentNum2;
          } else {
            _currentNum1 = _random.nextInt(10) + 1;
            _currentNum2 = _random.nextInt(10) + 1;
            _correctAnswer = _currentNum1 * _currentNum2;
          }
          break;
      }

      // Generate options
      _options = [_correctAnswer];
      while (_options.length < 4) {
        final offset = _random.nextInt(10) - 5;
        final option = _correctAnswer + offset;
        if (option > 0 && !_options.contains(option)) {
          _options.add(option);
        }
      }
      _options.shuffle();
    });
  }

  void _checkAnswer(int answer) {
    setState(() {
      _selectedAnswer = answer;
      _isCorrect = answer == _correctAnswer;
      _showFeedback = true;

      if (_isCorrect) {
        _score++;
        _confettiController.play();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (_questionCount >= 10) {
          _showResults();
        } else {
          _generateQuestion();
        }
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color, widget.color.withValues(alpha: 0.7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$_score',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _score >= 8
                    ? 'Mükemmel! 🌟'
                    : _score >= 6
                        ? 'Harika! 👍'
                        : 'İyi Deneme! 💪',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '10 sorudan $_score tanesini doğru bildin!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Ana Sayfa'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _score = 0;
                          _questionCount = 0;
                          _generateQuestion();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.color,
                      ),
                      child: const Text('Tekrar Oyna'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildQuestionCard(),
                        const SizedBox(height: 24),
                        _buildOptionsGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.1,
                shouldLoop: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.color, widget.color.withValues(alpha: 0.7)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$_score / $_questionCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _questionCount / 10,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return TweenAnimationBuilder(
      key: ValueKey(_questionCount),
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Soru $_questionCount / 10',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_currentNum1',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _currentOperation,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$_currentNum2',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '=',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '?',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            if (_showFeedback) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _isCorrect
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isCorrect ? 'Doğru! 🎉' : 'Yanlış. Doğru cevap: $_correctAnswer',
                      style: TextStyle(
                        color: _isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _options.length,
      itemBuilder: (context, index) {
        final option = _options[index];
        final isSelected = _selectedAnswer == option;
        final isCorrectOption = option == _correctAnswer;
        final shouldHighlight = _showFeedback && (isSelected || isCorrectOption);

        Color getColor() {
          if (!shouldHighlight) return Colors.white;
          if (isCorrectOption) return Colors.green.withValues(alpha: 0.1);
          if (isSelected && !isCorrectOption) return Colors.red.withValues(alpha: 0.1);
          return Colors.white;
        }

        Color getBorderColor() {
          if (!shouldHighlight) return Colors.grey.shade300;
          if (isCorrectOption) return Colors.green;
          if (isSelected && !isCorrectOption) return Colors.red;
          return Colors.grey.shade300;
        }

        return InkWell(
          onTap: _showFeedback ? null : () => _checkAnswer(option),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: getColor(),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: getBorderColor(),
                width: 2,
              ),
              boxShadow: [
                if (!shouldHighlight)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                '$option',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: shouldHighlight
                      ? (isCorrectOption ? Colors.green : Colors.red)
                      : widget.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
// Hot reload trigger
