import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/millionaire_question.dart';
import '../../services/millionaire_questions_service.dart';
import '../../services/millionaire_firestore_service.dart';

class MillionaireGameScreen extends StatefulWidget {
  const MillionaireGameScreen({super.key});

  @override
  State<MillionaireGameScreen> createState() => _MillionaireGameScreenState();
}

class _MillionaireGameScreenState extends State<MillionaireGameScreen> {
  final MillionaireFirestoreService _firestoreService = MillionaireFirestoreService();
  List<MillionaireQuestion> _questions = [];
  final List<int> _prizeTree = MillionaireQuestionsService.getPrizeTree();
  final JokerState _jokerState = JokerState();
  final ScrollController _prizeScrollController = ScrollController();

  bool _isLoading = true;
  String? _errorMessage;

  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showingResult = false;
  bool _isCorrect = false;
  bool _gameOver = false;
  int _currentPrize = 0;
  Set<int> _hiddenOptions = {};
  Map<int, int>? _audienceVotes;
  String? _phoneAnswer;

  MillionaireQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _prizeScrollController.dispose();
    super.dispose();
  }

  void _scrollToPrize() {
    if (_prizeScrollController.hasClients) {
      // Her öğe yaklaşık 120 piksel genişliğinde (margin + padding dahil)
      final offset = _currentQuestionIndex * 120.0;
      _prizeScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Rastgele soru çek (uzak sunucu boşsa yerel soru bankasını kullan)
      final questions = await _firestoreService.getRandomQuestions();

      setState(() {
        _questions = questions.isNotEmpty
            ? questions.cast<MillionaireQuestion>()
            : MillionaireQuestionsService.getGameQuestions();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sorular yüklenirken hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          title: const Text('Kim Milyoner Olmak İster?'),
          centerTitle: true,
          backgroundColor: const Color(0xFF1B263B),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.amber),
              SizedBox(height: 20),
              Text(
                'Sorular yükleniyor...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          title: const Text('Kim Milyoner Olmak İster?'),
          centerTitle: true,
          backgroundColor: const Color(0xFF1B263B),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadQuestions,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: const Text('Tekrar Dene', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          title: const Text('Kim Milyoner Olmak İster?'),
          centerTitle: true,
          backgroundColor: const Color(0xFF1B263B),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz, color: Colors.amber, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Henüz soru eklenmemiş',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: const Text('Geri Dön', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Kim Milyoner Olmak İster?'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B263B),
      ),
      body: SafeArea(
        child: _gameOver ? _buildGameOverScreen() : _buildGameScreen(),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        // Para Ağacı
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B263B), Color(0xFF0D1B2A)],
            ),
          ),
          child: ListView.builder(
            controller: _prizeScrollController,
            reverse: true,
            scrollDirection: Axis.horizontal,
            itemCount: _prizeTree.length,
            itemBuilder: (context, index) {
              final isPast = index < _currentQuestionIndex;
              final isCurrent = index == _currentQuestionIndex;
              final prize = _prizeTree[index];

              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent
                    ? Colors.amber
                    : isPast
                      ? Colors.grey[700]
                      : Colors.transparent,
                  border: Border.all(
                    color: isCurrent ? Colors.amber : Colors.grey[600]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    MillionaireQuestionsService.formatPrize(prize),
                    style: TextStyle(
                      color: isCurrent ? Colors.black : Colors.white,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      fontSize: isCurrent ? 16 : 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Soru
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Soru Numarası ve Metni
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B263B),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Soru ${_currentQuestionIndex + 1}',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentQuestion.question,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Soru Görseli
                      if (_currentQuestion.imageUrl != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: _currentQuestion.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.amber),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: Colors.grey[800],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Telefon Joker Cevabı
                if (_phoneAnswer != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _phoneAnswer!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                // Seçenekler
                ...List.generate(4, (index) {
                  final option = _currentQuestion.options[index];
                  final letter = String.fromCharCode(65 + index); // A, B, C, D
                  final isHidden = _hiddenOptions.contains(index);
                  final isSelected = _selectedAnswer == index;

                  if (isHidden) {
                    return const SizedBox(height: 60);
                  }

                  Color buttonColor = const Color(0xFF1B263B);
                  if (_showingResult && isSelected) {
                    buttonColor = _isCorrect ? Colors.green : Colors.red;
                  } else if (isSelected) {
                    buttonColor = Colors.amber[800]!;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Material(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: _showingResult ? null : () => _selectAnswer(index),
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? Colors.amber : Colors.grey[600]!,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Harf
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.amber : Colors.grey[800],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Seçenek
                              Expanded(
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              // Seyirci Oyu
                              if (_audienceVotes != null && _audienceVotes!.containsKey(index))
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    '%${_audienceVotes![index]}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Final Cevap Butonu
                if (_selectedAnswer != null && !_showingResult)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _confirmAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'FİNAL CEVAP',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Joker Butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildJokerButton(
                      JokerType.fiftyFifty,
                      '50:50',
                      Icons.pie_chart,
                      Colors.orange,
                    ),
                    _buildJokerButton(
                      JokerType.phone,
                      'Telefon',
                      Icons.phone,
                      Colors.blue,
                    ),
                    _buildJokerButton(
                      JokerType.audience,
                      'Seyirci',
                      Icons.people,
                      Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJokerButton(JokerType type, String label, IconData icon, Color color) {
    final isUsed = _jokerState.isUsed(type);

    return Opacity(
      opacity: isUsed ? 0.3 : 1.0,
      child: Column(
        children: [
          Material(
            color: isUsed ? Colors.grey : color,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: isUsed || _showingResult ? null : () => _useJoker(type),
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isUsed ? Colors.grey : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _currentPrize >= 10000000 ? Icons.emoji_events : Icons.star,
              color: Colors.amber,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              _currentPrize >= 10000000
                ? 'TEBRİKLER!'
                : 'OYUN BİTTİ',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kazandığınız Para:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              MillionaireQuestionsService.formatPrize(_currentPrize),
              style: TextStyle(
                color: Colors.amber,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _restartGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yeniden Oyna'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Çıkış'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(int index) {
    if (_showingResult) return;
    setState(() {
      _selectedAnswer = index;
    });
  }

  void _confirmAnswer() {
    final isCorrect = _selectedAnswer == _currentQuestion.correctAnswerIndex;

    setState(() {
      _showingResult = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _currentPrize = _currentQuestion.prize;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!isCorrect) {
        // Yanlış cevap - Oyun bitti
        setState(() {
          _gameOver = true;
        });
      } else if (_currentQuestionIndex >= _questions.length - 1) {
        // Son soruya doğru cevap - Oyunu kazandı!
        setState(() {
          _gameOver = true;
        });
      } else {
        // Sonraki soruya geç
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
          _showingResult = false;
          _hiddenOptions.clear();
          _audienceVotes = null;
          _phoneAnswer = null;
        });

        // Para ağacını otomatik olarak scroll et
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToPrize();
        });
      }
    });
  }

  void _useJoker(JokerType type) {
    if (_jokerState.isUsed(type)) return;

    setState(() {
      _jokerState.use(type);
    });

    switch (type) {
      case JokerType.fiftyFifty:
        _useFiftyFifty();
        break;
      case JokerType.phone:
        _usePhone();
        break;
      case JokerType.audience:
        _useAudience();
        break;
    }
  }

  void _useFiftyFifty() {
    // 2 yanlış şıkkı gizle
    final correctIndex = _currentQuestion.correctAnswerIndex;
    final wrongOptions = List.generate(4, (i) => i)
        .where((i) => i != correctIndex)
        .toList();

    wrongOptions.shuffle();

    setState(() {
      _hiddenOptions = {wrongOptions[0], wrongOptions[1]};
    });
  }

  void _usePhone() {
    // Random bir arkadaş tahmini (çoğunlukla doğru)
    final random = Random();
    final correctIndex = _currentQuestion.correctAnswerIndex;

    // %80 ihtimalle doğru cevabı söyler
    final willBeCorrect = random.nextInt(100) < 80;
    final suggestedIndex = willBeCorrect
        ? correctIndex
        : random.nextInt(4);

    final letter = String.fromCharCode(65 + suggestedIndex);

    setState(() {
      _phoneAnswer = 'Arkadaşınız: "Bence cevap $letter şıkkı olmalı, %${willBeCorrect ? 80 : 50} eminim."';
    });
  }

  void _useAudience() {
    // Seyirci oylaması - çoğunluk doğru cevaba yönelir
    final random = Random();
    final correctIndex = _currentQuestion.correctAnswerIndex;

    // Doğru cevaba %50-70 arası oy
    final correctVotes = 50 + random.nextInt(21);
    final remainingVotes = 100 - correctVotes;

    final votes = <int, int>{};
    votes[correctIndex] = correctVotes;

    // Kalan oyları diğer şıklara dağıt
    final otherIndices = List.generate(4, (i) => i)
        .where((i) => i != correctIndex)
        .toList();

    var remaining = remainingVotes;
    for (int i = 0; i < otherIndices.length - 1; i++) {
      final vote = random.nextInt(remaining + 1);
      votes[otherIndices[i]] = vote;
      remaining -= vote;
    }
    votes[otherIndices.last] = remaining;

    setState(() {
      _audienceVotes = votes;
    });
  }

  void _restartGame() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _showingResult = false;
      _isCorrect = false;
      _gameOver = false;
      _currentPrize = 0;
      _hiddenOptions.clear();
      _audienceVotes = null;
      _phoneAnswer = null;
      _jokerState.fiftyFiftyUsed = false;
      _jokerState.phoneUsed = false;
      _jokerState.audienceUsed = false;
    });
  }
}
