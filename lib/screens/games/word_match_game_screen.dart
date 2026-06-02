import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../../services/score_cache_service.dart';
import '../../models/leaderboard_model.dart';
import '../../models/game_model.dart';
import '../../services/leaderboard_service.dart';
import '../../widgets/animated_rank_display.dart';

class WordMatchGameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const WordMatchGameScreen({
    Key? key,
    required this.gameData,
  }) : super(key: key);

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  List<Map<String, String>> _wordPairs = [];
  List<Map<String, String>> _leftWords = [];
  List<Map<String, String>> _rightWords = [];

  // Connection tracking
  Map<String, String> _userMatches = {}; // english -> turkish
  Map<String, GlobalKey> _leftKeys = {};
  Map<String, GlobalKey> _rightKeys = {};
  String? _selectedLeft;
  String? _selectedRight;

  int _score = 0;
  int _attempts = 0;
  int _currentLevel = 1;
  final int _totalLevels = 5;
  DateTime? _startTime;
  DateTime? _levelStartTime;

  // Color palette
  final List<Color> _colors = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _levelStartTime = DateTime.now();
    _loadWords();
  }

  void _loadWords() {
    List<Map<String, String>> wordsList = _getWordsForLevel(_currentLevel);

    // Her seviyede 8 kelime göster
    wordsList.shuffle();
    _wordPairs = wordsList.take(8).toList();
    _leftWords = List.from(_wordPairs);
    _rightWords = List.from(_wordPairs)..shuffle();

    // Create keys for position tracking
    _leftKeys.clear();
    _rightKeys.clear();
    for (var word in _leftWords) {
      _leftKeys[word['english']!] = GlobalKey();
    }
    for (var word in _rightWords) {
      _rightKeys[word['turkish']!] = GlobalKey();
    }

    setState(() {});
  }

  List<Map<String, String>> _getWordsForLevel(int level) {
    switch (level) {
      case 1:
        return _getRoboticWords();
      case 2:
        return _getScratchWords();
      case 3:
        return _getArduinoWords();
      case 4:
        return _getPythonWords();
      case 5:
        return _getCodingWords();
      default:
        return _getRoboticWords();
    }
  }

  List<Map<String, String>> _getRoboticWords() {
    return [
      {'english': 'Robot', 'turkish': 'Robot'},
      {'english': 'Code', 'turkish': 'Kod'},
      {'english': 'Sensor', 'turkish': 'Sensör'},
      {'english': 'Motor', 'turkish': 'Motor'},
      {'english': 'Light', 'turkish': 'Işık'},
      {'english': 'Sound', 'turkish': 'Ses'},
      {'english': 'Move', 'turkish': 'Hareket'},
      {'english': 'Turn', 'turkish': 'Dön'},
      {'english': 'Forward', 'turkish': 'İleri'},
      {'english': 'Backward', 'turkish': 'Geri'},
      {'english': 'Speed', 'turkish': 'Hız'},
      {'english': 'Distance', 'turkish': 'Mesafe'},
      {'english': 'Button', 'turkish': 'Buton'},
      {'english': 'Battery', 'turkish': 'Pil'},
      {'english': 'Program', 'turkish': 'Program'},
    ];
  }

  List<Map<String, String>> _getScratchWords() {
    return [
      {'english': 'Sprite', 'turkish': 'Karakter'},
      {'english': 'Backdrop', 'turkish': 'Fon'},
      {'english': 'Block', 'turkish': 'Blok'},
      {'english': 'Script', 'turkish': 'Kukla'},
      {'english': 'Costume', 'turkish': 'Kostüm'},
      {'english': 'Stage', 'turkish': 'Sahne'},
      {'english': 'Loop', 'turkish': 'Döngü'},
      {'english': 'Broadcast', 'turkish': 'Yayın'},
      {'english': 'Variable', 'turkish': 'Değişken'},
      {'english': 'Event', 'turkish': 'Olay'},
      {'english': 'Motion', 'turkish': 'Hareket'},
      {'english': 'Looks', 'turkish': 'Görünüm'},
      {'english': 'Control', 'turkish': 'Kontrol'},
      {'english': 'Sensing', 'turkish': 'Algılama'},
      {'english': 'Operators', 'turkish': 'İşlemler'},
    ];
  }

  List<Map<String, String>> _getArduinoWords() {
    return [
      {'english': 'Arduino', 'turkish': 'Arduino'},
      {'english': 'Pin', 'turkish': 'Pin'},
      {'english': 'Digital', 'turkish': 'Dijital'},
      {'english': 'Analog', 'turkish': 'Analog'},
      {'english': 'Input', 'turkish': 'Giriş'},
      {'english': 'Output', 'turkish': 'Çıkış'},
      {'english': 'Voltage', 'turkish': 'Voltaj'},
      {'english': 'Current', 'turkish': 'Akım'},
      {'english': 'Circuit', 'turkish': 'Devre'},
      {'english': 'LED', 'turkish': 'LED'},
      {'english': 'Resistor', 'turkish': 'Direnç'},
      {'english': 'Breadboard', 'turkish': 'Breadboard'},
      {'english': 'Sensor', 'turkish': 'Sensör'},
      {'english': 'Wire', 'turkish': 'Kablo'},
      {'english': 'Ground', 'turkish': 'Toprak'},
    ];
  }

  List<Map<String, String>> _getPythonWords() {
    return [
      {'english': 'Print', 'turkish': 'Yazdır'},
      {'english': 'Function', 'turkish': 'Fonksiyon'},
      {'english': 'Variable', 'turkish': 'Değişken'},
      {'english': 'List', 'turkish': 'Liste'},
      {'english': 'String', 'turkish': 'Metin'},
      {'english': 'Integer', 'turkish': 'Tam Sayı'},
      {'english': 'Boolean', 'turkish': 'Mantıksal'},
      {'english': 'If', 'turkish': 'Eğer'},
      {'english': 'Else', 'turkish': 'Değilse'},
      {'english': 'While', 'turkish': 'İken'},
      {'english': 'For', 'turkish': 'Her'},
      {'english': 'Import', 'turkish': 'İçe Aktar'},
      {'english': 'Class', 'turkish': 'Sınıf'},
      {'english': 'Return', 'turkish': 'Döndür'},
      {'english': 'Try', 'turkish': 'Dene'},
    ];
  }

  List<Map<String, String>> _getCodingWords() {
    return [
      {'english': 'Algorithm', 'turkish': 'Algoritma'},
      {'english': 'Debug', 'turkish': 'Hata Ayıklama'},
      {'english': 'Compile', 'turkish': 'Derle'},
      {'english': 'Execute', 'turkish': 'Çalıştır'},
      {'english': 'Array', 'turkish': 'Dizi'},
      {'english': 'Object', 'turkish': 'Nesne'},
      {'english': 'Method', 'turkish': 'Metot'},
      {'english': 'Property', 'turkish': 'Özellik'},
      {'english': 'Parameter', 'turkish': 'Parametre'},
      {'english': 'Condition', 'turkish': 'Koşul'},
      {'english': 'Iteration', 'turkish': 'Tekrar'},
      {'english': 'Syntax', 'turkish': 'Söz Dizimi'},
      {'english': 'Comment', 'turkish': 'Yorum'},
      {'english': 'Error', 'turkish': 'Hata'},
      {'english': 'Logic', 'turkish': 'Mantık'},
    ];
  }

  void _onLeftCircleTap(String englishWord) {
    setState(() {
      if (_selectedLeft == englishWord) {
        _selectedLeft = null;
      } else {
        _selectedLeft = englishWord;
        _selectedRight = null;
      }
    });
  }

  void _onRightCircleTap(String turkishWord) {
    if (_selectedLeft == null) {
      setState(() {
        _selectedLeft = null;
        _selectedRight = turkishWord;
      });
      return;
    }

    setState(() {
      _attempts++;

      // Find correct pair
      final correctPair = _wordPairs.firstWhere(
        (pair) => pair['english'] == _selectedLeft,
      );

      if (correctPair['turkish'] == turkishWord) {
        // Correct match!
        _userMatches[_selectedLeft!] = turkishWord;
        _score += 10;
        _showFeedback(true);

        // Remove matched words
        _leftWords.removeWhere((w) => w['english'] == _selectedLeft);
        _rightWords.removeWhere((w) => w['turkish'] == turkishWord);
        _leftKeys.remove(_selectedLeft);
        _rightKeys.remove(turkishWord);

        if (_leftWords.isEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _showCompletionDialog();
          });
        }
      } else {
        // Wrong match - deduct 3 points
        _score = (_score - 3).clamp(0, 999999);
        _showFeedback(false);
      }

      _selectedLeft = null;
      _selectedRight = null;
    });
  }

  void _showFeedback(bool isCorrect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? '✅ Doğru eşleştirme! +10 puan' : '❌ Yanlış eşleştirme! -3 puan',
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showCompletionDialog() {
    final isLastLevel = _currentLevel >= _totalLevels;
    final levelName = _getLevelName(_currentLevel);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isLastLevel ? '🏆 Oyunu Tamamladın!' : '🎉 Seviye Tamamlandı!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLastLevel
                  ? 'Tüm seviyeleri başarıyla tamamladın!'
                  : '$levelName seviyesini tamamladın!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Puan: $_score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text('Deneme Sayısı: $_attempts'),
            if (!isLastLevel) ...[
              const SizedBox(height: 16),
              Text(
                'Sonraki: ${_getLevelName(_currentLevel + 1)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!isLastLevel) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text('Bu Seviyeyi Tekrar Oyna'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _advanceToNextLevel();
              },
              child: const Text('Sonraki Seviye'),
            ),
          ] else ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetToFirstLevel();
              },
              child: const Text('Baştan Oyna'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _saveScoreAndShowRank();
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                });
              },
              child: const Text('Skoru Kaydet'),
            ),
          ],
        ],
      ),
    );
  }

  String _getLevelName(int level) {
    switch (level) {
      case 1:
        return 'Robotik';
      case 2:
        return 'Scratch';
      case 3:
        return 'Arduino';
      default:
        return 'Seviye $level';
    }
  }

  void _advanceToNextLevel() {
    setState(() {
      _currentLevel++;
      _userMatches.clear();
      _selectedLeft = null;
      _selectedRight = null;
      _attempts = 0;
      _levelStartTime = DateTime.now();
      _loadWords();
    });
  }

  void _resetToFirstLevel() {
    setState(() {
      _currentLevel = 1;
      _userMatches.clear();
      _selectedLeft = null;
      _selectedRight = null;
      _score = 0;
      _attempts = 0;
      _startTime = DateTime.now();
      _levelStartTime = DateTime.now();
      _loadWords();
    });
  }

  void _resetGame() {
    setState(() {
      _userMatches.clear();
      _selectedLeft = null;
      _selectedRight = null;
      _score = 0;
      _attempts = 0;
      _levelStartTime = DateTime.now();
      _loadWords();
    });
  }

  Color _getColorForMatch(String englishWord) {
    final index = _wordPairs.indexWhere((pair) => pair['english'] == englishWord);
    return _colors[index % _colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kelime Eşleştirme'),
            Text(
              '${_getLevelName(_currentLevel)} - Seviye $_currentLevel/$_totalLevels',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Puan: $_score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _leftWords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Seviye ${_currentLevel} yükleniyor...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sol taraftaki yuvarlağa tıkla, sonra sağ taraftaki doğru kelimeyi eşleştir!',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Game area with arrows
                  _buildGameArea(),

                  const SizedBox(height: 24),

                  // Reset button
                  OutlinedButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yeniden Başlat'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGameArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Draw arrows first (behind words)
            CustomPaint(
              size: Size(constraints.maxWidth, 600),
              painter: ArrowPainter(
                userMatches: _userMatches,
                leftKeys: _leftKeys,
                rightKeys: _rightKeys,
                getColorForMatch: _getColorForMatch,
              ),
            ),

            // Words on top
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English words (left)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'İngilizce',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._leftWords.map((word) => _buildLeftWord(word['english']!)),
                    ],
                  ),
                ),
                const SizedBox(width: 80),

                // Turkish words (right)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Türkçe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._rightWords.map((word) => _buildRightWord(word['turkish']!)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeftWord(String word) {
    final isMatched = _userMatches.containsKey(word);
    final isSelected = _selectedLeft == word;
    final color = isMatched ? _getColorForMatch(word) : Colors.purple;

    return Container(
      key: _leftKeys[word],
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Circle button
          GestureDetector(
            onTap: isMatched ? null : () => _onLeftCircleTap(word),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMatched ? color : (isSelected ? Colors.purple.shade400 : Colors.purple.shade200),
                border: Border.all(
                  color: isMatched ? color.withOpacity(0.8) : Colors.purple.shade700,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  isMatched ? Icons.check : Icons.circle,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Word card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMatched ? color.withOpacity(0.2) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMatched ? color : Colors.purple.shade200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                word,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isMatched ? color : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightWord(String word) {
    // Find if this word is matched
    final matchedEnglish = _userMatches.entries
        .where((entry) => entry.value == word)
        .map((entry) => entry.key)
        .firstOrNull;
    final isMatched = matchedEnglish != null;
    final isSelected = _selectedRight == word;
    final color = isMatched ? _getColorForMatch(matchedEnglish!) : Colors.orange;

    return Container(
      key: _rightKeys[word],
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Word card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMatched ? color.withOpacity(0.2) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMatched ? color : Colors.orange.shade200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                word,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isMatched ? color : Colors.black87,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Circle button
          GestureDetector(
            onTap: isMatched ? null : () => _onRightCircleTap(word),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMatched ? color : (isSelected ? Colors.orange.shade400 : Colors.orange.shade200),
                border: Border.all(
                  color: isMatched ? color.withOpacity(0.8) : Colors.orange.shade700,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  isMatched ? Icons.check : Icons.circle,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveScoreAndShowRank() async {
    try {
      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        return;
      }

      final totalDuration = DateTime.now().difference(_startTime!).inSeconds;

      final entry = LeaderboardEntry(
        id: '',
        userId: user.id!,
        userName: user.name ?? 'Oyuncu',
        userPhotoUrl: user.profilePictureUrl,
        gameType: GameType.wordMatch,
        score: _score,
        timeSeconds: totalDuration,
        correctCount: _wordPairs.length * _totalLevels,
        totalQuestions: _wordPairs.length * _totalLevels,
        difficulty: _totalLevels,
        completedAt: DateTime.now(),
        metadata: {
          'attempts': _attempts,
          'levelsCompleted': _currentLevel,
        },
      );

      // Save to leaderboard
      await ScoreCacheService().saveScore(entry);

      // Get user rank
      final leaderboardService = LeaderboardService();
      final topEntries = await leaderboardService.getTopEntries(
        gameType: GameType.wordMatch,
        limit: 100,
      );

      final userRank = topEntries.indexWhere((e) => e.userId == user.id) + 1;

      if (mounted && userRank > 0) {
        // Show animated rank display
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AnimatedRankDisplay(
            rank: userRank,
            totalScore: _score,
            userName: user.name ?? 'Oyuncu',
            isNewRecord: false,
            onClose: () {
              Navigator.pop(context);
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving score: $e');
    }
  }

  Future<void> _showLoginRequiredDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Devam Etmek İçin Giriş Yapın',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'İlk seviyeyi tamamladınız!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor: $_score',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Devam etmek ve tüm seviyelere erişmek için giriş yapın.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Ana Sayfa'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
              await authProvider.signOut();

              if (!mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('Giriş Yap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to draw arrows between matched words
class ArrowPainter extends CustomPainter {
  final Map<String, String> userMatches;
  final Map<String, GlobalKey> leftKeys;
  final Map<String, GlobalKey> rightKeys;
  final Color Function(String) getColorForMatch;

  ArrowPainter({
    required this.userMatches,
    required this.leftKeys,
    required this.rightKeys,
    required this.getColorForMatch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var entry in userMatches.entries) {
      final englishWord = entry.key;
      final turkishWord = entry.value;

      final leftKey = leftKeys[englishWord];
      final rightKey = rightKeys[turkishWord];

      if (leftKey?.currentContext == null || rightKey?.currentContext == null) {
        continue;
      }

      final leftBox = leftKey!.currentContext!.findRenderObject() as RenderBox?;
      final rightBox = rightKey!.currentContext!.findRenderObject() as RenderBox?;

      if (leftBox == null || rightBox == null) continue;

      // Get positions
      final leftPos = leftBox.localToGlobal(Offset.zero);
      final rightPos = rightBox.localToGlobal(Offset.zero);

      // Calculate circle centers (adjusted for circle position)
      final startX = leftPos.dx + 16; // Circle is 32px wide, center at 16
      final startY = leftPos.dy + 16; // Circle is 32px tall, center at 16
      final endX = rightPos.dx + 16;
      final endY = rightPos.dy + 16;

      final color = getColorForMatch(englishWord);

      // Draw line
      final paint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Draw arrowhead
      _drawArrowHead(canvas, Offset(startX, startY), Offset(endX, endY), color);
    }
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Color color) {
    const arrowSize = 12.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final angle = atan2(end.dy - start.dy, end.dx - start.dx);

    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowSize * cos(angle - pi / 6),
      end.dy - arrowSize * sin(angle - pi / 6),
    );
    path.lineTo(
      end.dx - arrowSize * cos(angle + pi / 6),
      end.dy - arrowSize * sin(angle + pi / 6),
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) {
    return oldDelegate.userMatches != userMatches;
  }
}
