import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/lesson_model.dart';
import 'lesson_detail_screen.dart';

/// Professional Worksheets Screen
/// Comprehensive learning system with topics, quizzes, and daily goals
class WorksheetsScreen extends StatefulWidget {
  const WorksheetsScreen({super.key});

  @override
  State<WorksheetsScreen> createState() => _WorksheetsScreenState();
}

class _WorksheetsScreenState extends State<WorksheetsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> categories = [
    'Tumunu',
    'Python',
    'Java',
    'ASP.NET Core',
    'Yapay Zeka',
    'Web',
  ];

  // Daily goal
  final DailyGoal todayGoal = DailyGoal(
    date: DateTime.now().toString().split(' ')[0],
    targetLessons: 3,
    completedLessons: 1,
    targetMinutes: 60,
    completedMinutes: 25,
    completedLessonIds: ['python_basics_1'],
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildDailyGoal(),
            _buildCategoryTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: categories.map((category) {
                  return _buildLessonsList(category);
                }).toList(),
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Profesyonel Egitim',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Konu Anlatimi & Test Sistemi',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.book, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${todayGoal.completedLessons}/${todayGoal.targetLessons}',
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
        ],
      ),
    );
  }

  Widget _buildDailyGoal() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.track_changes, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Gunluk Hedef',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(todayGoal.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: todayGoal.isCompleted ? Colors.green : AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: todayGoal.progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                todayGoal.isCompleted ? Colors.green : AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGoalStat(
                  Icons.school,
                  '${todayGoal.completedLessons} / ${todayGoal.targetLessons}',
                  'Ders',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGoalStat(
                  Icons.access_time,
                  '${todayGoal.completedMinutes} / ${todayGoal.targetMinutes}',
                  'Dakika',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppTheme.primaryBlue,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: Colors.grey,
        indicatorWeight: 3,
        tabs: categories.map((category) {
          return Tab(
            child: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLessonsList(String category) {
    final lessons = _getLessonsForCategory(category);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _buildLessonCard(lesson);
      },
    );
  }

  Widget _buildLessonCard(LessonModel lesson) {
    final isCompleted = lesson.isCompleted;
    final progress = lesson.userScore != null ? lesson.userScore! / 100 : 0.0;

    Color getCategoryColor(String category) {
      switch (category) {
        case 'Python':
          return const Color(0xFF3776AB);
        case 'Java':
          return const Color(0xFFF89820);
        case 'ASP.NET Core':
          return const Color(0xFF512BD4);
        case 'Yapay Zeka':
          return const Color(0xFFFF6B6B);
        case 'Web':
          return const Color(0xFF4CAF50);
        default:
          return AppTheme.primaryBlue;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonDetailScreen(lesson: lesson),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          getCategoryColor(lesson.category),
                          getCategoryColor(lesson.category).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(lesson.category),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Lesson Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: getCategoryColor(lesson.category).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                lesson.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: getCategoryColor(lesson.category),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getLevelColor(lesson.level).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                lesson.level,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getLevelColor(lesson.level),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.menu_book, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${lesson.sections.length} Bolum',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.quiz, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${lesson.quiz.length} Soru',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${lesson.estimatedMinutes} dk',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Completion Status
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            // Progress Bar
            if (progress > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ilerleme',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${lesson.userScore}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Python':
        return Icons.code;
      case 'Java':
        return Icons.coffee;
      case 'ASP.NET Core':
        return Icons.cloud;
      case 'Yapay Zeka':
        return Icons.psychology;
      case 'Web':
        return Icons.language;
      default:
        return Icons.school;
    }
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<LessonModel> _getLessonsForCategory(String category) {
    final allLessons = _getAllLessons();

    if (category == 'Tumunu') {
      return allLessons;
    }

    return allLessons.where((lesson) => lesson.category == category).toList();
  }

  List<LessonModel> _getAllLessons() {
    return [
      // Python Lessons
      LessonModel(
        id: 'python_basics_1',
        title: 'Python Temelleri: Degiskenler ve Veri Tipleri',
        category: 'Python',
        level: 'Beginner',
        description: 'Python programlamaya giris, degiskenler ve temel veri tipleri',
        estimatedMinutes: 25,
        isCompleted: true,
        userScore: 85,
        sections: [],
        quiz: [],
      ),
      LessonModel(
        id: 'python_basics_2',
        title: 'Python: Donguler ve Kosullar',
        category: 'Python',
        level: 'Beginner',
        description: 'For, while donguleri ve if-else yapilari',
        estimatedMinutes: 30,
        sections: [],
        quiz: [],
      ),
      LessonModel(
        id: 'python_oop',
        title: 'Python: Nesne Yonelimli Programlama',
        category: 'Python',
        level: 'Intermediate',
        description: 'Class, object, inheritance ve polymorphism',
        estimatedMinutes: 45,
        sections: [],
        quiz: [],
      ),

      // Java Lessons
      LessonModel(
        id: 'java_basics',
        title: 'Java Temelleri: Degiskenler ve Metodlar',
        category: 'Java',
        level: 'Beginner',
        description: 'Java syntax, degiskenler, metodlar ve veri tipleri',
        estimatedMinutes: 30,
        sections: [],
        quiz: [],
      ),
      LessonModel(
        id: 'java_oop',
        title: 'Java: OOP Prensipleri',
        category: 'Java',
        level: 'Intermediate',
        description: 'Encapsulation, inheritance, polymorphism, abstraction',
        estimatedMinutes: 50,
        sections: [],
        quiz: [],
      ),

      // ASP.NET Core Lessons
      LessonModel(
        id: 'aspnet_intro',
        title: 'ASP.NET Core: Web API Gelistirme',
        category: 'ASP.NET Core',
        level: 'Intermediate',
        description: 'RESTful API, MVC pattern, routing ve controllers',
        estimatedMinutes: 40,
        sections: [],
        quiz: [],
      ),
      LessonModel(
        id: 'aspnet_ef',
        title: 'ASP.NET Core: Entity Framework',
        category: 'ASP.NET Core',
        level: 'Advanced',
        description: 'ORM, LINQ, migrations ve database operations',
        estimatedMinutes: 55,
        sections: [],
        quiz: [],
      ),

      // AI Lessons
      LessonModel(
        id: 'ai_intro',
        title: 'Yapay Zeka: Makine Ogrenmesine Giris',
        category: 'Yapay Zeka',
        level: 'Beginner',
        description: 'ML algoritmalar, supervised vs unsupervised learning',
        estimatedMinutes: 35,
        sections: [],
        quiz: [],
      ),
      LessonModel(
        id: 'ai_neural',
        title: 'Yapay Zeka: Neural Networks',
        category: 'Yapay Zeka',
        level: 'Advanced',
        description: 'Deep learning, CNN, RNN ve transformers',
        estimatedMinutes: 60,
        sections: [],
        quiz: [],
      ),

      // Web Lessons
      LessonModel(
        id: 'web_html_css',
        title: 'Web: HTML ve CSS Temelleri',
        category: 'Web',
        level: 'Beginner',
        description: 'HTML5 semantic tags, CSS3, flexbox ve grid',
        estimatedMinutes: 30,
        sections: [],
        quiz: [],
      ),
      LessonModel(
        id: 'web_javascript',
        title: 'Web: JavaScript ve DOM Manipulasyonu',
        category: 'Web',
        level: 'Intermediate',
        description: 'ES6+, async/await, DOM, event handling',
        estimatedMinutes: 40,
        sections: [],
        quiz: [],
      ),
    ];
  }
}
