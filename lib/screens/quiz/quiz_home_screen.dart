import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../courses/data/quiz_categories.dart';
import '../../courses/data/courses_data.dart';
import '../../courses/data/lessons_data.dart';
import '../../courses/data/quizzes_data.dart';
import '../../courses/screens/quiz_screen.dart';
import '../../models/game_model.dart';
import '../../models/leaderboard_model.dart';
import '../../core/service_locator.dart';
import '../leaderboard/leaderboard_screen.dart';

/// Quiz Merkezi — Quizo tasarımından ilham alan ama devkom'un mor kimliğini
/// kullanan bağımsız quiz bölümü. Üç iç sekme: Quiz (konu seçimi), Sıralama
/// (mevcut lider tablosu, GameType.quiz), Profilim (quiz istatistikleri).
///
/// Quiz sorularının kaynağı: courses/data/quizzes_data.dart (17 quiz, 5
/// gerçek kursa bağlı 11'i oynanabilir) — yeni bir içerik sistemi icat
/// etmek yerine derslerin sonunda zaten var olan quiz altyapısı burada da
/// kullanılıyor (bkz. courses/screens/quiz_screen.dart).
class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key});

  static const purple = Color(0xFF6C3CE0);

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tabIndex,
          children: const [
            _QuizCategoriesTab(),
            LeaderboardScreen(initialGameType: GameType.quiz),
            _QuizStatsTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (_QuizTab.quiz, Icons.quiz_rounded, 'Quiz'),
      (_QuizTab.rank, Icons.emoji_events_rounded, 'Sıralama'),
      (_QuizTab.profile, Icons.person_rounded, 'Profilim'),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final (_, icon, label) = items[index];
              final selected = index == _tabIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tabIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: selected ? QuizHomeScreen.purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: selected ? Colors.white : Colors.grey.shade400, size: 22),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

enum _QuizTab { quiz, rank, profile }

class _QuizCategoriesTab extends StatefulWidget {
  const _QuizCategoriesTab();

  @override
  State<_QuizCategoriesTab> createState() => _QuizCategoriesTabState();
}

class _QuizCategoriesTabState extends State<_QuizCategoriesTab> {
  String _search = '';

  void _playCategory(QuizCategory category) {
    final lessonId = category.quizKeys.first;
    final quiz = QuizzesData.all[lessonId];
    final lesson = LessonsData.getLesson(category.courseId, lessonId);
    final course = CoursesData.allCourses.firstWhere((c) => c.id == category.courseId);

    if (quiz == null || lesson == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(course: course, lesson: lesson, quiz: quiz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jetonBalance = context.watch<AuthProvider>().userProgress?.jetonBalance ?? 0;
    final userName = context.watch<AuthProvider>().currentUser?.displayName ?? 'Kaşif';
    final categories = QuizCategoriesData.all
        .where((c) => c.title.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: QuizHomeScreen.purple.withValues(alpha: 0.15),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(color: QuizHomeScreen.purple, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text('$jetonBalance', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Quiz konusu ara',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Konunu Seç',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
          ),
          const SizedBox(height: 6),
          Text('Binlerce soru, sınırsız kazanım!', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('Bu aramaya uygun konu bulunamadı.', style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else
            ...categories.map((category) => _buildCategoryCard(category)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(QuizCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [category.color, category.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: category.color.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(category.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.quizKeys.length} quiz seti • ${category.questionCount} soru',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _playCategory(category),
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Oyna'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: category.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizStatsTab extends StatefulWidget {
  const _QuizStatsTab();

  @override
  State<_QuizStatsTab> createState() => _QuizStatsTabState();
}

class _QuizStatsTabState extends State<_QuizStatsTab> {
  bool _isLoading = true;
  List<LeaderboardEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final entries = await leaderboardService.getUserEntriesPaginated(userId, gameType: GameType.quiz);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final totalQuizzes = _entries.length;
    final avgSuccess = _entries.isEmpty
        ? 0.0
        : _entries
                .map((e) => (e.totalQuestions ?? 0) == 0 ? 0.0 : (e.correctCount ?? 0) / e.totalQuestions! * 100)
                .fold<double>(0, (a, b) => a + b) /
            _entries.length;
    final bestCorrect = _entries.isEmpty
        ? 0
        : _entries.map((e) => e.correctCount ?? 0).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: QuizHomeScreen.purple.withValues(alpha: 0.15),
                  child: Text(
                    (user?.displayName.isNotEmpty ?? false) ? user!.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: QuizHomeScreen.purple),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?.displayName ?? 'Kaşif', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.5,
              children: [
                _statCard('📝', '$totalQuizzes', 'Tamamlanan Quiz'),
                _statCard('🎯', '%${avgSuccess.round()}', 'Ortalama Başarı'),
                _statCard('🏆', '$bestCorrect', 'En Yüksek Doğru'),
                _statCard('🪙', '${context.watch<AuthProvider>().userProgress?.jetonBalance ?? 0}', 'Jeton Bakiyesi'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
