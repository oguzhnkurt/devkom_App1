import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../courses/data/quiz_categories.dart';
import '../../courses/data/courses_data.dart';
import '../../courses/data/lessons_data.dart';
import '../../courses/data/quizzes_data.dart';
import '../../courses/screens/quiz_screen.dart';
import '../../utils/lang.dart';

/// Quiz Merkezi — Quizo tasarımından ilham alan ama devkom'un mor kimliğini
/// kullanan bağımsız quiz bölümü. Tek ekran: konu seçimi.
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
  @override
  Widget build(BuildContext context) {
    // Quiz Merkezi tek ekran: sadece konu secimi. "Sıralama" (skor tabelasi)
    // ve "Profilim" sekmeleri kaldirildi - skor tabelasina zaten Oyunlar
    // tarafindan erisiliyor, burada gereksiz karmasiklik yaratiyordu.
    return const Scaffold(
      backgroundColor: Color(0xFFF6F3FF),
      body: SafeArea(
        bottom: false,
        child: _QuizCategoriesTab(),
      ),
    );
  }
}

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
    final lang = Localizations.localeOf(context).languageCode;
    final userName = context.watch<AuthProvider>().currentUser?.displayName ??
        AppLang.pick(lang,
            tr: 'Kaşif', en: 'Explorer', de: 'Entdecker', es: 'Explorador');
    final categories = QuizCategoriesData.all
        .where((c) => c.title.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Quiz Merkezi'nden ana uygulamaya dönüş. Bu ekran drawer'dan
                  // push ile aciliyor ve kendi AppBar'i yok; geri butonu
                  // olmadan kullanici burada kapana kisiliyordu.
                  if (Navigator.canPop(context))
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: QuizHomeScreen.purple,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Geri',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
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
          Text(
            AppLang.pick(lang,
                tr: 'Konunu Seç',
                en: 'Pick your topic',
                de: 'Wähle dein Thema',
                es: 'Elige tu tema'),
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
          ),
          const SizedBox(height: 6),
          Text(
              AppLang.pick(lang,
                  tr: 'Binlerce soru, sınırsız kazanım!',
                  en: 'Thousands of questions, endless rewards!',
                  de: 'Tausende Fragen, endlose Belohnungen!',
                  es: '¡Miles de preguntas, recompensas sin fin!'),
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                    AppLang.pick(lang,
                        tr: 'Bu aramaya uygun konu bulunamadı.',
                        en: 'No topic matches this search.',
                        de: 'Kein Thema passt zu dieser Suche.',
                        es: 'Ningún tema coincide con esta búsqueda.'),
                    style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else
            ...categories.map((category) => _buildCategoryCard(category)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(QuizCategory category) {
    final lang = Localizations.localeOf(context).languageCode;
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
                  category.titleFor(lang),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLang.pick(lang,
                      tr: '${category.quizKeys.length} quiz seti • '
                          '${category.questionCount} soru',
                      en: '${category.quizKeys.length} quiz sets • '
                          '${category.questionCount} questions',
                      de: '${category.quizKeys.length} Quiz-Sets • '
                          '${category.questionCount} Fragen',
                      es: '${category.quizKeys.length} sets • '
                          '${category.questionCount} preguntas'),
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

