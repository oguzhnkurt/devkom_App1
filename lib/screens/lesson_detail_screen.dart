import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/lesson_model.dart';
import '../theme.dart';
import '../widgets/interactive_quiz_widgets.dart';

/// Modern Interactive Lesson Detail Screen - Duolingo/Codecademy Style
/// Features: XP System, Interactive Widgets, Smooth Animations, Engaging UI
class LessonDetailScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonDetailScreen({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  late LessonModel _lesson;
  late PageController _quizPageController;
  late AnimationController _correctAnswerController;
  late AnimationController _wrongAnswerController;
  late AnimationController _celebrationController;
  late AnimationController _streakPulseController;

  // Quiz state
  int _currentQuestionIndex = 0;
  Map<int, dynamic> _userAnswers = {};
  bool _showResults = false;
  int _correctAnswers = 0;
  bool _showFeedback = false;
  bool _isCorrectAnswer = false;

  // XP System
  int _currentXP = 0;
  int _sessionXP = 0;
  int _level = 1;
  final int _xpPerCorrectAnswer = 10;
  final int _requiredXP = 100;

  // Streak & Achievements
  int _currentStreak = 0;
  List<String> _earnedBadges = [];

  // Expandable sections
  Map<int, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _quizPageController = PageController();

    // Animation controllers
    _correctAnswerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _wrongAnswerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _streakPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _loadLesson();
    _loadUserProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    _quizPageController.dispose();
    _correctAnswerController.dispose();
    _wrongAnswerController.dispose();
    _celebrationController.dispose();
    _streakPulseController.dispose();
    super.dispose();
  }

  void _loadUserProgress() {
    // TODO: Load from local storage or API
    setState(() {
      _currentXP = 45;
      _level = 1;
      _currentStreak = 3;
    });
  }

  void _loadLesson() {
    _lesson = widget.lesson;
    if (_lesson.id == 'python_basics_1') {
      _lesson = _getSamplePythonLesson();
    } else {
      _lesson = _getSamplePythonLesson();
    }

    // Initialize expanded sections
    for (int i = 0; i < _lesson.sections.length; i++) {
      _expandedSections[i] = i == 0; // First section expanded by default
    }
  }

  LessonModel _getSamplePythonLesson() {
    return LessonModel(
      id: 'python_basics_1',
      title: 'Python\'a Giris ve Temel Kavramlar',
      category: 'Python',
      level: 'Beginner',
      description: 'Python programlama diline giris, degiskenler ve veri tipleri',
      estimatedMinutes: 45,
      sections: [
        LessonSection(
          title: '1. Python Nedir?',
          content:
              'Python, yuksek seviyeli, genel amacli bir programlama dilidir. Guido van Rossum tarafindan 1991 yilinda gelistirilmistir. Python, okunabilir ve anlasilir soz dizimi ile bilinir.\n\nPython\'un populer olmasi bir cok nedene dayanir:\n- Basit ve ogrenmesi kolay soz dizimi\n- Genis kutuhane destegi\n- Platformdan bagimsiz calisma\n- Guclu topluluk destegi',
          codeExample: '''# Python'da ilk programimiz
print("Merhaba Dunya!")
print("Python ogreniyorum")

# Bu bir yorum satirdir
# Yorumlar # isareti ile baslar''',
          language: 'python',
          keyPoints: [
            'Python yuksek seviyeli bir dildir',
            'Okunabilir ve temiz soz dizimi',
            'Genis kutuhane ve framework destegi',
            'Veri bilimi, web, yapay zeka gibi alanlarda kullanilir',
          ],
        ),
        LessonSection(
          title: '2. Degiskenler ve Atama',
          content:
              'Degiskenler, verileri bellekte saklamak icin kullanilan isimli alanllardir. Python\'da degisken tanimlama icin veri tipi belirtmeye gerek yoktur (dinamik tipleme).\n\nDegisken isimlendirme kurallari:\n- Harf veya alt cizgi ile baslayabilir\n- Rakam, harf ve alt cizgi icerebilir\n- Buyuk-kucuk harf duyarlidir\n- Python anahtar kelimeleri kullanilamaz',
          codeExample: '''# Degisken tanimlama
isim = "Ahmet"
yas = 25
boy = 1.75
ogrenci_mi = True

# Coklu atama
x, y, z = 10, 20, 30

# Ayni degeri birden fazla degiskene atama
a = b = c = 100

# Degisken degerini degistirme
yas = 26
print(yas)  # Cikti: 26''',
          language: 'python',
          keyPoints: [
            'Degiskenler veri saklamak icin kullanilir',
            'Python dinamik tipleme kullanir',
            'Degisken isimleri anlamli olmalidir',
            'Atama operatoru = ile yapilir',
          ],
        ),
        LessonSection(
          title: '3. Temel Veri Tipleri',
          content:
              'Python\'da dort temel veri tipi vardir:\n\n1. Sayisal Tipler (int, float, complex)\n2. Metin Tipi (str)\n3. Mantiksal Tip (bool)\n4. None Tipi (NoneType)\n\nHer veri tipinin kendine has ozellikleri ve metodlari vardir. type() fonksiyonu ile bir degiskenin tipini ogrenebiliriz.',
          codeExample: '''# Sayisal tipler
tamsayi = 42          # int
ondalikli = 3.14      # float
karmasik = 2 + 3j     # complex

# Metin tipi
mesaj = "Python ogreniyorum"
harf = 'A'

# Mantiksal tip
dogru = True
yanlis = False

# None tipi
bos_deger = None

# Tip kontrolu
print(type(tamsayi))   # <class 'int'>
print(type(mesaj))     # <class 'str'>
print(type(dogru))     # <class 'bool'>''',
          language: 'python',
          keyPoints: [
            'int: Tam sayi degerleri',
            'float: Ondalikli sayi degerleri',
            'str: Metin degerleri',
            'bool: True veya False degerleri',
            'type() fonksiyonu ile tip kontrolu',
          ],
        ),
      ],
      quiz: [
        QuizQuestion(
          id: 'q1',
          type: QuestionType.multipleChoice,
          question: 'Python programlama dilini kim gelistirmistir?',
          options: [
            'Guido van Rossum',
            'James Gosling',
            'Dennis Ritchie',
            'Bjarne Stroustrup',
          ],
          correctAnswer: 'Guido van Rossum',
          explanation:
              'Python, Guido van Rossum tarafindan 1991 yilinda gelistirilmistir. James Gosling Java\'yi, Dennis Ritchie C\'yi, Bjarne Stroustrup ise C++\'i gelistirmistir.',
        ),
        QuizQuestion(
          id: 'q2',
          type: QuestionType.trueFalse,
          question: 'Python\'da degisken tanimlama icin veri tipi belirtmek zorunludur.',
          options: ['Dogru', 'Yanlis'],
          correctAnswer: 'Yanlis',
          explanation:
              'Python dinamik tipleme kullanir, bu nedenle degisken tanimlama icin veri tipi belirtmeye gerek yoktur. Python degiskenin tipini otomatik olarak belirler.',
        ),
        QuizQuestion(
          id: 'q3',
          type: QuestionType.multipleChoice,
          question: 'Asagidaki kodun ciktisi nedir?\n\nx = 10\ny = 20\nx, y = y, x\nprint(x)',
          options: ['10', '20', '30', 'Hata verir'],
          correctAnswer: '20',
          explanation:
              'x, y = y, x ifadesi degiskenlerin degerlerini takas eder. x\'in degeri 20, y\'nin degeri 10 olur.',
        ),
        QuizQuestion(
          id: 'q4',
          type: QuestionType.fillInBlank,
          question: 'Python\'da bir degiskenin tipini ogrenmek icin _____ fonksiyonu kullanilir.',
          correctAnswer: 'type',
          explanation:
              'type() fonksiyonu bir degiskenin veri tipini dondurur. Ornek: type(42) sonucu <class \'int\'>',
        ),
        QuizQuestion(
          id: 'q5',
          type: QuestionType.multipleChoice,
          question: 'Asagidaki veri tiplerinden hangisi mantiksal degerleri temsil eder?',
          options: ['int', 'str', 'bool', 'float'],
          correctAnswer: 'bool',
          explanation:
              'bool (boolean) veri tipi True veya False mantiksal degerlerini temsil eder. Kosullu ifadelerde ve mantiksal islemlerde kullanilir.',
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'python':
        return const Color(0xFF3776AB);
      case 'java':
        return const Color(0xFFF89820);
      case 'asp.net core':
      case 'asp.net':
        return const Color(0xFF512BD4);
      case 'ai':
      case 'yapay zeka':
        return const Color(0xFFFF6B6B);
      case 'web':
        return const Color(0xFF4CAF50);
      default:
        return AppTheme.primaryBlue;
    }
  }

  void _handleAnswerSelection(dynamic answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _checkAnswerAndProceed() {
    final question = _lesson.quiz[_currentQuestionIndex];
    final userAnswer = _userAnswers[_currentQuestionIndex];

    bool isCorrect = false;
    if (userAnswer != null) {
      if (question.type == QuestionType.fillInBlank) {
        isCorrect = userAnswer.toString().toLowerCase().trim() ==
            question.correctAnswer?.toLowerCase().trim();
      } else {
        isCorrect = userAnswer == question.correctAnswer;
      }
    }

    setState(() {
      _showFeedback = true;
      _isCorrectAnswer = isCorrect;
    });

    if (isCorrect) {
      // TODO: Play success sound
      _correctAnswerController.forward().then((_) {
        _correctAnswerController.reverse();
      });

      // Add XP
      setState(() {
        _currentXP += _xpPerCorrectAnswer;
        _sessionXP += _xpPerCorrectAnswer;

        // Level up check
        if (_currentXP >= _requiredXP) {
          _currentXP -= _requiredXP;
          _level++;
          _showLevelUpDialog();
        }
      });
    } else {
      // TODO: Play error sound
      _wrongAnswerController.forward().then((_) {
        _wrongAnswerController.reverse();
      });
    }

    // Auto proceed after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _showFeedback = false;
    });

    if (_currentQuestionIndex < _lesson.quiz.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _quizPageController.animateToPage(
        _currentQuestionIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _showQuizResults();
    }
  }

  void _showQuizResults() {
    int correct = 0;
    for (int i = 0; i < _lesson.quiz.length; i++) {
      final question = _lesson.quiz[i];
      final userAnswer = _userAnswers[i];

      if (userAnswer != null) {
        if (question.type == QuestionType.fillInBlank) {
          if (userAnswer.toString().toLowerCase().trim() ==
              question.correctAnswer?.toLowerCase().trim()) {
            correct++;
          }
        } else {
          if (userAnswer == question.correctAnswer) {
            correct++;
          }
        }
      }
    }

    setState(() {
      _correctAnswers = correct;
      _showResults = true;
    });

    // Enhanced celebration
    final percentage = (correct / _lesson.quiz.length) * 100;
    if (percentage >= 70) {
      _confettiController.play();
      _celebrationController.forward();
      _currentStreak++;

      // Award badges
      if (percentage == 100) {
        _earnedBadges.add('Perfect Score');
      }
      if (_currentStreak >= 5) {
        _earnedBadges.add('5 Day Streak');
      }
    }
  }

  void _showLevelUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Level Up!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seviye $_level\'e yükseldiniz!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  void _retryQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _showResults = false;
      _correctAnswers = 0;
      _showFeedback = false;
      _sessionXP = 0;
    });
    _quizPageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(_lesson.category);

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  backgroundColor: categoryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3.0,
                            color: Color.fromARGB(128, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            categoryColor,
                            categoryColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            // XP Progress Widget
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: XPProgressWidget(
                                currentXP: _currentXP,
                                requiredXP: _requiredXP,
                                level: _level,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Streak indicator
                            _buildStreakIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.book, size: 20),
                            text: 'Konu Anlatimi',
                          ),
                          Tab(
                            icon: Icon(Icons.quiz, size: 20),
                            text: 'Test',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildContentTab(),
                _buildQuizTab(),
              ],
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
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
    );
  }

  Widget _buildStreakIndicator() {
    return AnimatedBuilder(
      animation: _streakPulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_streakPulseController.value * 0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$_currentStreak günlük seri',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'python':
        return Icons.code;
      case 'java':
        return Icons.coffee;
      case 'asp.net core':
      case 'asp.net':
        return Icons.web;
      case 'ai':
      case 'yapay zeka':
        return Icons.psychology;
      case 'web':
        return Icons.language;
      default:
        return Icons.school;
    }
  }

  Widget _buildContentTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lesson.sections.length + 1, // +1 for achievements section
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAchievementsSection();
        }
        return _buildSectionCard(_lesson.sections[index - 1], index - 1);
      },
    );
  }

  Widget _buildAchievementsSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.amber.shade50],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Başarılarınız',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildAchievementBadge('Başlangıç', Icons.star, true),
                _buildAchievementBadge('İlk Seri', Icons.local_fire_department, _currentStreak > 0),
                _buildAchievementBadge('Mükemmel Puan', Icons.celebration, _earnedBadges.contains('Perfect Score')),
                _buildAchievementBadge('5 Günlük Seri', Icons.whatshot, _earnedBadges.contains('5 Day Streak')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon, bool earned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: earned ? Colors.amber : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
        boxShadow: earned
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: earned ? Colors.white : Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: earned ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(LessonSection section, int index) {
    final isExpanded = _expandedSections[index] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: isExpanded ? 8 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _expandedSections[index] = !isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header with expand/collapse
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        section.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _getCategoryColor(_lesson.category),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _getCategoryColor(_lesson.category),
                      ),
                    ),
                  ],
                ),

                // Expandable content
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Content text
                      Text(
                        section.content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              fontSize: 15,
                            ),
                      ),

                      // Code example with "Try it" button
                      if (section.codeExample != null) ...[
                        const SizedBox(height: 20),
                        _buildInteractiveCodeBlock(section),
                      ],

                      // Key points
                      if (section.keyPoints != null && section.keyPoints!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildKeyPointsSection(section),
                      ],
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCodeBlock(LessonSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF212121),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCategoryColor(_lesson.category),
                      _getCategoryColor(_lesson.category).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  section.language?.toUpperCase() ?? 'CODE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Code text with line-by-line animation
              Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  section.codeExample!,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 13,
                    color: Color(0xFFE0E0E0),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Interactive "Try it" button
        ElevatedButton.icon(
          onPressed: () {
            _showInteractiveCodeDialog(section);
          },
          icon: const Icon(Icons.play_circle_outline, color: Colors.white),
          label: const Text(
            'Dene',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  void _showInteractiveCodeDialog(LessonSection section) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kodu Deneyin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LiveCodeEditor(
                initialCode: section.codeExample ?? '',
                expectedOutput: 'Merhaba Dunya!\nPython ogreniyorum',
                onValidate: (isCorrect) {
                  // TODO: Handle validation
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyPointsSection(LessonSection section) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor(_lesson.category).withOpacity(0.1),
            _getCategoryColor(_lesson.category).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getCategoryColor(_lesson.category).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: _getCategoryColor(_lesson.category),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Onemli Noktalar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _getCategoryColor(_lesson.category),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...section.keyPoints!.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final point = entry.value;
              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 300 + (index * 100)),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6, right: 12),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(_lesson.category),
                              _getCategoryColor(_lesson.category).withOpacity(0.6),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    if (_showResults) {
      return _buildResultsScreen();
    }

    final totalQuestions = _lesson.quiz.length;
    final progress = (_currentQuestionIndex + 1) / totalQuestions;

    return Column(
      children: [
        // Enhanced progress bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soru ${_currentQuestionIndex + 1}/$totalQuestions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCategoryColor(_lesson.category),
                          _getCategoryColor(_lesson.category).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCategoryColor(_lesson.category),
                          ),
                        ),
                      ),
                      // Shimmer effect
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: -1, end: 1),
                            duration: const Duration(seconds: 2),
                            builder: (context, double shimmerValue, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: [
                                      (shimmerValue - 0.3).clamp(0.0, 1.0),
                                      shimmerValue.clamp(0.0, 1.0),
                                      (shimmerValue + 0.3).clamp(0.0, 1.0),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // Quiz questions with PageView
        Expanded(
          child: PageView.builder(
            controller: _quizPageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalQuestions,
            itemBuilder: (context, index) {
              return _buildQuestionCard(_lesson.quiz[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question card with animation
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      _getCategoryColor(_lesson.category).withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getCategoryColor(_lesson.category),
                            _getCategoryColor(_lesson.category).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getCategoryColor(_lesson.category).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _getQuestionTypeName(question.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Question text
                    Text(
                      question.question,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 28),

                    // Answer options based on question type
                    _buildAnswerOptions(question),

                    // Feedback section
                    if (_showFeedback) ...[
                      const SizedBox(height: 24),
                      _buildFeedbackWidget(question),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Submit/Next button
          if (_userAnswers.containsKey(_currentQuestionIndex) && !_showFeedback) ...[
            const SizedBox(height: 20),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: ElevatedButton(
                onPressed: _checkAnswerAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getCategoryColor(_lesson.category),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  'Kontrol Et',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackWidget(QuizQuestion question) {
    return AnimatedBuilder(
      animation: _isCorrectAnswer ? _correctAnswerController : _wrongAnswerController,
      builder: (context, child) {
        final animation = _isCorrectAnswer ? _correctAnswerController : _wrongAnswerController;

        // Shake animation for wrong answer
        double offset = 0;
        if (!_isCorrectAnswer) {
          offset = animation.value * 10 * (animation.value < 0.5 ? 1 : -1);
        }

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isCorrectAnswer
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.red.shade400, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_isCorrectAnswer ? Colors.green : Colors.red).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isCorrectAnswer ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isCorrectAnswer ? 'Dogru!' : 'Yanlis!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isCorrectAnswer)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+$_xpPerCorrectAnswer XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.explanation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getQuestionTypeName(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'COKTAN SECMELI';
      case QuestionType.trueFalse:
        return 'DOGRU/YANLIS';
      case QuestionType.fillInBlank:
        return 'BOSUK DOLDURMA';
      default:
        return 'SORU';
    }
  }

  Widget _buildAnswerOptions(QuizQuestion question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions(question);
      case QuestionType.trueFalse:
        return _buildTrueFalseOptions(question);
      case QuestionType.fillInBlank:
        return _buildFillInBlankOption(question);
      default:
        return const SizedBox();
    }
  }

  Widget _buildMultipleChoiceOptions(QuizQuestion question) {
    final userAnswer = _userAnswers[_currentQuestionIndex];

    return Column(
      children: question.options!.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = userAnswer == option;

        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: _showFeedback ? null : () => _handleAnswerSelection(option),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            _getCategoryColor(_lesson.category).withOpacity(0.2),
                            _getCategoryColor(_lesson.category).withOpacity(0.1),
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.grey[50],
                  border: Border.all(
                    color: isSelected
                        ? _getCategoryColor(_lesson.category)
                        : Colors.grey[300]!,
                    width: isSelected ? 3 : 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _getCategoryColor(_lesson.category).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? _getCategoryColor(_lesson.category)
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: isSelected
                            ? _getCategoryColor(_lesson.category)
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 16,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions(QuizQuestion question) {
    final userAnswer = _userAnswers[_currentQuestionIndex];

    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseButton(
            'Dogru',
            Icons.check_circle,
            Colors.green,
            userAnswer == 'Dogru',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTrueFalseButton(
            'Yanlis',
            Icons.cancel,
            Colors.red,
            userAnswer == 'Yanlis',
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseButton(String label, IconData icon, Color color, bool isSelected) {
    return InkWell(
      onTap: _showFeedback ? null : () => _handleAnswerSelection(label),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillInBlankOption(QuizQuestion question) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor(_lesson.category).withOpacity(0.1),
            _getCategoryColor(_lesson.category).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        enabled: !_showFeedback,
        onChanged: (value) => _handleAnswerSelection(value),
        decoration: InputDecoration(
          hintText: 'Cevabinizi buraya yazin...',
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(
            Icons.edit,
            color: _getCategoryColor(_lesson.category),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _getCategoryColor(_lesson.category),
              width: 2,
            ),
          ),
        ),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final totalQuestions = _lesson.quiz.length;
    final percentage = (_correctAnswers / totalQuestions * 100).round();
    final isPassed = percentage >= 70;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Enhanced results card with celebration
          AnimatedBuilder(
            animation: _celebrationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_celebrationController.value * 0.1),
                child: child,
              );
            },
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPassed
                        ? [Colors.green[400]!, Colors.green[700]!]
                        : [Colors.orange[400]!, Colors.orange[700]!],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isPassed ? Icons.emoji_events : Icons.refresh,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isPassed ? 'Muhteşem!' : 'İyi Deneme!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPassed
                          ? 'Testi başarıyla tamamladınız!'
                          : 'Biraz daha pratikle başaracaksın!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Score display
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Basari Orani',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Dogru', '$_correctAnswers', Icons.check_circle),
                        _buildStatItem('Yanlis', '${totalQuestions - _correctAnswers}', Icons.cancel),
                        _buildStatItem('Toplam', '$totalQuestions', Icons.quiz),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // XP earned
                    if (_sessionXP > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              '+$_sessionXP XP Kazandınız!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _retryQuiz,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Tekrar Dene',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCategoryColor(_lesson.category),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(0),
                  icon: Icon(Icons.book, color: _getCategoryColor(_lesson.category)),
                  label: Text(
                    'Konuya Dön',
                    style: TextStyle(
                      color: _getCategoryColor(_lesson.category),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(
                      color: _getCategoryColor(_lesson.category),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Answers review
          Text(
            'Cevap Detaylari',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),

          ..._lesson.quiz.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final userAnswer = _userAnswers[index];

            bool isCorrect;
            if (question.type == QuestionType.fillInBlank) {
              isCorrect = userAnswer?.toString().toLowerCase().trim() ==
                  question.correctAnswer?.toLowerCase().trim();
            } else {
              isCorrect = userAnswer == question.correctAnswer;
            }

            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (index * 100)),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isCorrect ? Colors.green : Colors.red,
                    width: 3,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCorrect ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCorrect ? Icons.check : Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Soru ${index + 1}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.question,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sizin Cevabınız: ${userAnswer ?? "Cevaplanmadi"}',
                              style: TextStyle(
                                color: isCorrect ? Colors.green[700] : Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (!isCorrect) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Dogru Cevap: ${question.correctAnswer}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[50]!, Colors.blue[100]!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb, size: 20, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.explanation,
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
