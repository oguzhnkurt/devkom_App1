import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme.dart';

/// Worksheet Detail Screen
/// Shows the content and questions for a specific worksheet
class WorksheetDetailScreen extends StatefulWidget {
  final Map<String, dynamic> worksheet;

  const WorksheetDetailScreen({
    super.key,
    required this.worksheet,
  });

  @override
  State<WorksheetDetailScreen> createState() => _WorksheetDetailScreenState();
}

class _WorksheetDetailScreenState extends State<WorksheetDetailScreen> {
  late ConfettiController _confettiController;
  int _currentQuestionIndex = 0;
  final Map<int, String> _userAnswers = {};
  bool _isCompleted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _questions => _getQuestionsForWorksheet();

  @override
  Widget build(BuildContext context) {
    final category = widget.worksheet['category'] ?? '';

    Color getCategoryColor() {
      switch (category) {
        case 'AI':
          return const Color(0xFF667eea);
        case 'Robotik':
          return const Color(0xFFFF9800);
        case 'Kodlama':
          return const Color(0xFF4CAF50);
        case 'Yazılım':
          return const Color(0xFFE91E63);
        default:
          return AppTheme.primaryBlue;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(getCategoryColor()),
                Expanded(
                  child: _isCompleted
                      ? _buildCompletionScreen(getCategoryColor())
                      : _buildQuestionScreen(getCategoryColor()),
                ),
              ],
            ),
            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.worksheet['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.worksheet['difficulty'] ?? 'Orta',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.worksheet['duration'] ?? 15}dk',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_isCompleted) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Soru ${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(Color color) {
    if (_questions.isEmpty) {
      return const Center(
        child: Text('Sorular yükleniyor...'),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final options = question['options'] as List<String>;
    final userAnswer = _userAnswers[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question card
          Container(
            padding: const EdgeInsets.all(24),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SORU ${_currentQuestionIndex + 1}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question['question'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Options
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
            final isSelected = userAnswer == option;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _userAnswers[_currentQuestionIndex] = option;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            optionLetter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                            color: isSelected ? color : Colors.grey.shade800,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: color, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Önceki',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: userAnswer != null
                      ? () {
                          if (_currentQuestionIndex < _questions.length - 1) {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          } else {
                            _completeWorksheet();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentQuestionIndex < _questions.length - 1
                        ? 'Sonraki'
                        : 'Tamamla',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(Color color) {
    final percentage = (_score / _questions.length * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$_score/${_questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            percentage >= 80
                ? 'Harika İş! 🎉'
                : percentage >= 60
                    ? 'İyi Gidiyorsun! 👍'
                    : 'Tekrar Dene! 💪',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            percentage >= 80
                ? 'Mükemmel bir performans sergilediğin!'
                : percentage >= 60
                    ? 'İyi bir başlangıç, biraz daha pratik yaparsan harika olacak!'
                    : 'Pes etme! Biraz daha çalışarak başaracaksın!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
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
                _buildStatRow(Icons.check_circle, 'Doğru', '$_score', Colors.green),
                const SizedBox(height: 16),
                _buildStatRow(
                  Icons.cancel,
                  'Yanlış',
                  '${_questions.length - _score}',
                  Colors.red,
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  Icons.percent,
                  'Başarı Oranı',
                  '$percentage%',
                  color,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Ana Sayfa'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex = 0;
                      _userAnswers.clear();
                      _isCompleted = false;
                      _score = 0;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _completeWorksheet() {
    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i]['correct']) {
        correctAnswers++;
      }
    }

    setState(() {
      _score = correctAnswers;
      _isCompleted = true;
    });

    // Show confetti
    _confettiController.play();

    // TODO: Save progress to Firebase
  }

  List<Map<String, dynamic>> _getQuestionsForWorksheet() {
    final category = widget.worksheet['category'] ?? '';

    switch (category) {
      case 'AI':
        return [
          {
            'question': 'Yapay zeka nedir?',
            'options': [
              'Bilgisayarların insan gibi düşünmesi',
              'Sadece hesaplama yapan program',
              'Robot üretim teknolojisi',
              'Oyun oynayan cihaz',
            ],
            'correct': 'Bilgisayarların insan gibi düşünmesi',
          },
          {
            'question': 'Makine öğrenmesi nasıl çalışır?',
            'options': [
              'Verilerden öğrenir',
              'Kendiliğinden gelişir',
              'İnsan kontrolü ile',
              'Elektrik ile çalışır',
            ],
            'correct': 'Verilerden öğrenir',
          },
          {
            'question': 'Chatbot ne işe yarar?',
            'options': [
              'İnsanlarla sohbet eder',
              'Oyun oynar',
              'Müzik çalar',
              'Fotoğraf çeker',
            ],
            'correct': 'İnsanlarla sohbet eder',
          },
        ];

      case 'Robotik':
        return [
          {
            'question': 'Robot hareket için neye ihtiyaç duyar?',
            'options': [
              'Motor ve güç kaynağı',
              'Sadece batarya',
              'İnternet bağlantısı',
              'Ekran',
            ],
            'correct': 'Motor ve güç kaynağı',
          },
          {
            'question': 'Sensörler ne için kullanılır?',
            'options': [
              'Çevreyi algılamak için',
              'Işık yakmak için',
              'Ses çıkarmak için',
              'Batarya doldurmak için',
            ],
            'correct': 'Çevreyi algılamak için',
          },
          {
            'question': 'Arduino nedir?',
            'options': [
              'Programlanabilir elektronik kart',
              'Bir oyun konsolu',
              'Telefon markası',
              'Robot oyuncak',
            ],
            'correct': 'Programlanabilir elektronik kart',
          },
        ];

      case 'Kodlama':
        return [
          {
            'question': 'Python hangi tür bir programlama dilidir?',
            'options': [
              'Yüksek seviyeli, yorumlanan',
              'Düşük seviyeli, derlenmiş',
              'Sadece web için',
              'Sadece oyun için',
            ],
            'correct': 'Yüksek seviyeli, yorumlanan',
          },
          {
            'question': 'Döngüler ne işe yarar?',
            'options': [
              'Kodu tekrarlamak için',
              'Program durdurmak için',
              'Hata bulmak için',
              'Dosya kaydetmek için',
            ],
            'correct': 'Kodu tekrarlamak için',
          },
          {
            'question': 'Fonksiyon ne demektir?',
            'options': [
              'Yeniden kullanılabilir kod bloğu',
              'Hata mesajı',
              'Değişken türü',
              'Dosya formatı',
            ],
            'correct': 'Yeniden kullanılabilir kod bloğu',
          },
        ];

      case 'Yazılım':
        return [
          {
            'question': 'Mobil uygulama hangi platformlarda çalışır?',
            'options': [
              'iOS ve Android',
              'Sadece bilgisayarda',
              'Sadece tablette',
              'Sadece telefonda',
            ],
            'correct': 'iOS ve Android',
          },
          {
            'question': 'Web sayfası hangi dil ile yapılır?',
            'options': [
              'HTML, CSS, JavaScript',
              'Sadece Python',
              'Sadece Java',
              'Sadece C++',
            ],
            'correct': 'HTML, CSS, JavaScript',
          },
          {
            'question': 'Veritabanı ne için kullanılır?',
            'options': [
              'Veri depolamak ve yönetmek',
              'Oyun oynamak',
              'Fotoğraf düzenlemek',
              'Video izlemek',
            ],
            'correct': 'Veri depolamak ve yönetmek',
          },
        ];

      default:
        return [];
    }
  }
}
