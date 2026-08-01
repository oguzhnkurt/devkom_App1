import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/millionaire_question.dart';
import '../../services/millionaire_questions_service.dart';
import '../../services/millionaire_firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/user_progress_service.dart';
import '../../widgets/pro_paywall.dart';

/// Ücretsiz kullanıcıların Pro'ya geçmeden oynayabileceği soru sayısı.
/// Bu sayıya ulaşınca (doğru cevapladıktan sonra) oyunu devam ettirmek
/// için Pro paywall gösterilir.
const int kMillionaireFreeQuestionLimit = 3;

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

  /// Uygulamanın o an ayarlı dili ('tr' veya 'en').
  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

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
        _errorMessage = _isEn ? 'An error occurred while loading questions: $e' : 'Sorular yüklenirken hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          title: Text(_isEn ? 'Knowledge Quiz 🎯' : 'Bilgi Yarışması 🎯'),
          centerTitle: true,
          backgroundColor: const Color(0xFF1B263B),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                _isEn ? 'Loading questions...' : 'Sorular yükleniyor...',
                style: const TextStyle(color: Colors.white, fontSize: 18),
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
          title: Text(_isEn ? 'Knowledge Quiz 🎯' : 'Bilgi Yarışması 🎯'),
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
                child: Text(_isEn ? 'Try Again' : 'Tekrar Dene', style: const TextStyle(color: Colors.black)),
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
          title: Text(_isEn ? 'Knowledge Quiz 🎯' : 'Bilgi Yarışması 🎯'),
          centerTitle: true,
          backgroundColor: const Color(0xFF1B263B),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz, color: Colors.amber, size: 80),
              const SizedBox(height: 20),
              Text(
                _isEn ? 'No questions added yet' : 'Henüz soru eklenmemiş',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: Text(_isEn ? 'Go Back' : 'Geri Dön', style: const TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(_isEn ? 'Knowledge Quiz 🎯' : 'Bilgi Yarışması 🎯'),
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
                    MillionaireQuestionsService.formatPrize(prize, lang: _lang),
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
                        _isEn ? 'Question ${_currentQuestionIndex + 1}' : 'Soru ${_currentQuestionIndex + 1}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentQuestion.questionFor(_lang),
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
                  final option = _currentQuestion.optionsFor(_lang)[index];
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            _isEn ? 'FINAL ANSWER' : 'FİNAL CEVAP',
                            style: const TextStyle(
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
                      _isEn ? 'Phone' : 'Telefon',
                      Icons.phone,
                      Colors.blue,
                    ),
                    _buildJokerButton(
                      JokerType.audience,
                      _isEn ? 'Audience' : 'Seyirci',
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
                ? (_isEn ? 'CONGRATULATIONS!' : 'TEBRİKLER!')
                : (_isEn ? 'GAME OVER' : 'OYUN BİTTİ'),
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isEn ? 'Prize Won:' : 'Kazandığınız Para:',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              MillionaireQuestionsService.formatPrize(_currentPrize, lang: _lang),
              style: const TextStyle(
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
                  label: Text(_isEn ? 'Play Again' : 'Yeniden Oyna'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.exit_to_app),
                  label: Text(_isEn ? 'Exit' : 'Çıkış'),
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
      if (!mounted) return;
      if (!isCorrect) {
        // Yanlış cevap - Oyun bitti
        setState(() {
          _gameOver = true;
        });
        _awardProgress();
      } else if (_currentQuestionIndex >= _questions.length - 1) {
        // Son soruya doğru cevap - Oyunu kazandı!
        setState(() {
          _gameOver = true;
        });
        _awardProgress();
      } else if (!_isPro && _currentQuestionIndex >= kMillionaireFreeQuestionLimit - 1) {
        // Ücretsiz soru hakkı doldu (ilk 3 soru) - oyunu durdur ve Pro paywall göster
        setState(() {
          _gameOver = true;
        });
        _awardProgress();
        _showFreeLimitPaywall();
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

  bool get _isPro => Provider.of<AuthProvider>(context, listen: false).currentUser?.isPro ?? false;

  void _showFreeLimitPaywall() {
    ProPaywall.show(
      context: context,
      title: _isEn
          ? '🎉 You completed the first $kMillionaireFreeQuestionLimit questions!'
          : '🎉 İlk $kMillionaireFreeQuestionLimit Soruyu Tamamladın!',
      message: _isEn
          ? 'Go Pro to continue the Knowledge Quiz and win bigger prizes.'
          : 'Bilgi Yarışması\'na devam etmek ve daha büyük ödülleri kazanmak için Pro\'ya geç.',
      featureDescription: _isEn
          ? 'With Pro you get unlimited questions in the Knowledge Quiz, full access to all games, and more!'
          : 'Pro ile Bilgi Yarışması\'nda sınırsız soru, tüm oyunlarda tam erişim ve daha fazlası seni bekliyor!',
    );
  }

  /// Oyun bitince (kazanma/kaybetme/ücretsiz limit) ulaşılan seviyeye göre
  /// kalıcı XP ve jeton kazandırır (Market'te harcanabilir). Bilgi Yarışması
  /// skoru önceden hiç kaydedilmiyordu.
  Future<void> _awardProgress() async {
    final questionsAnswered = _currentQuestionIndex + (_isCorrect ? 1 : 0);
    if (questionsAnswered <= 0) return;
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.currentUser?.uid;
      if (userId == null) return;
      final jeton = questionsAnswered * 5;
      await auth.addXP(questionsAnswered * 8);
      await UserProgressService().addJeton(userId, jeton, source: 'millionaire_quiz');
      await auth.refreshProgress();
    } catch (e) {
      debugPrint('❌ Bilgi Yarışması ödül hatası: $e');
    }
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
      _phoneAnswer = _isEn
          ? 'Your friend: "I think the answer is $letter, I\'m ${willBeCorrect ? 80 : 50}% sure."'
          : 'Arkadaşınız: "Bence cevap $letter şıkkı olmalı, %${willBeCorrect ? 80 : 50} eminim."';
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
