import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Service to fetch interactive lessons from Supabase
class InteractiveLessonsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _tableName = 'interactive_lessons';

  /// Get all interactive lessons for a course
  Future<List<Map<String, dynamic>>> getCourseLessons(String courseId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('course_id', courseId)
          .eq('is_active', true)
          .order('lesson_order');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching course lessons: $e');
      return [];
    }
  }

  /// Get single interactive lesson
  Future<Map<String, dynamic>?> getLesson(String lessonId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', lessonId)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching lesson: $e');
      return null;
    }
  }

  /// Get lessons by type
  Future<List<Map<String, dynamic>>> getLessonsByType({
    required String courseId,
    required String lessonType,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('course_id', courseId)
          .eq('lesson_type', lessonType)
          .eq('is_active', true)
          .order('lesson_order');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching lessons by type: $e');
      return [];
    }
  }

  /// Get code challenges (Python, HTML, CSS)
  Future<List<Map<String, dynamic>>> getCodeChallenges(String courseId) async {
    return getLessonsByType(courseId: courseId, lessonType: 'code_challenge');
  }

  /// Get drag-drop challenges (Scratch)
  Future<List<Map<String, dynamic>>> getDragDropChallenges(String courseId) async {
    return getLessonsByType(courseId: courseId, lessonType: 'drag_drop');
  }

  /// Get lessons with prerequisites
  Future<List<Map<String, dynamic>>> getNextLessons({
    required String courseId,
    required List<String> completedLessonIds,
  }) async {
    try {
      // Get all lessons for the course
      final allLessons = await getCourseLessons(courseId);

      // Filter lessons where all prerequisites are completed
      final availableLessons = allLessons.where((lesson) {
        final prerequisites = lesson['prerequisites'] as List<dynamic>?;
        if (prerequisites == null || prerequisites.isEmpty) {
          return true; // No prerequisites
        }

        // Check if all prerequisites are completed
        return prerequisites.every((prereq) => completedLessonIds.contains(prereq));
      }).toList();

      return availableLessons;
    } catch (e) {
      print('Error fetching next lessons: $e');
      return [];
    }
  }

  /// Get lesson stats
  Future<Map<String, dynamic>> getCourseStats(String courseId) async {
    try {
      final lessons = await getCourseLessons(courseId);

      int totalXP = 0;
      int totalMinutes = 0;
      int difficultySum = 0;
      Map<String, int> typeCount = {};

      for (final lesson in lessons) {
        totalXP += (lesson['xp_reward'] as int? ?? 0);
        totalMinutes += (lesson['estimated_minutes'] as int? ?? 0);
        difficultySum += (lesson['difficulty'] as int? ?? 1);

        final type = lesson['lesson_type'] as String?;
        if (type != null) {
          typeCount[type] = (typeCount[type] ?? 0) + 1;
        }
      }

      return {
        'total_lessons': lessons.length,
        'total_xp': totalXP,
        'estimated_minutes': totalMinutes,
        'avg_difficulty': lessons.isNotEmpty ? difficultySum / lessons.length : 0,
        'lesson_types': typeCount,
      };
    } catch (e) {
      print('Error fetching course stats: $e');
      return {};
    }
  }

  /// Stream interactive lessons
  Stream<List<Map<String, dynamic>>> streamCourseLessons(String courseId) {
    try {
      return _supabase
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .map((data) {
            final filtered = data
                .where((item) => item['course_id'] == courseId && item['is_active'] == true)
                .toList();
            filtered.sort((a, b) => (a['lesson_order'] as int? ?? 0).compareTo(b['lesson_order'] as int? ?? 0));
            return List<Map<String, dynamic>>.from(filtered);
          });
    } catch (e) {
      print('Error streaming lessons: $e');
      return Stream.value([]);
    }
  }

  /// Get challenge config
  Map<String, dynamic>? getChallengeConfig(Map<String, dynamic> lesson) {
    return lesson['challenge_config'] as Map<String, dynamic>?;
  }

  /// Get workspace config
  Map<String, dynamic>? getWorkspaceConfig(Map<String, dynamic> lesson) {
    return lesson['workspace_config'] as Map<String, dynamic>?;
  }

  /// Get success criteria
  Map<String, dynamic>? getSuccessCriteria(Map<String, dynamic> lesson) {
    return lesson['success_criteria'] as Map<String, dynamic>?;
  }

  /// Get hints
  List<String> getHints(Map<String, dynamic> lesson) {
    final hints = lesson['hints'] as List<dynamic>?;
    if (hints == null) return [];
    return hints.map((h) => h.toString()).toList();
  }

  /// Get starter code
  String? getStarterCode(Map<String, dynamic> lesson) {
    final config = getChallengeConfig(lesson);
    return config?['starterCode'] as String?;
  }

  /// Get instructions
  List<String> getInstructions(Map<String, dynamic> lesson) {
    final config = getChallengeConfig(lesson);
    final instructions = config?['instructions'] as List<dynamic>?;
    if (instructions == null) return [];
    return instructions.map((i) => i.toString()).toList();
  }

  /// Get test cases
  List<Map<String, dynamic>> getTestCases(Map<String, dynamic> lesson) {
    final config = getChallengeConfig(lesson);
    final testCases = config?['testCases'] as List<dynamic>?;
    if (testCases == null) return [];
    return testCases.map((tc) => tc as Map<String, dynamic>).toList();
  }

  /// Get available blocks (for Scratch)
  List<Map<String, dynamic>> getAvailableBlocks(Map<String, dynamic> lesson) {
    final config = getChallengeConfig(lesson);
    final blocks = config?['availableBlocks'] as List<dynamic>?;
    if (blocks == null) return [];
    return blocks.map((b) => b as Map<String, dynamic>).toList();
  }

  /// Check if lesson is code challenge
  bool isCodeChallenge(Map<String, dynamic> lesson) {
    return lesson['lesson_type'] == 'code_challenge';
  }

  /// Check if lesson is drag-drop
  bool isDragDrop(Map<String, dynamic> lesson) {
    return lesson['lesson_type'] == 'drag_drop';
  }

  /// Get difficulty label
  String getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Kolay';
      case 2:
        return 'Orta';
      case 3:
        return 'Zor';
      case 4:
        return 'Çok Zor';
      case 5:
        return 'Expert';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Get type icon
  String getTypeIcon(String lessonType) {
    switch (lessonType) {
      case 'code_challenge':
        return '💻';
      case 'drag_drop':
        return '🧩';
      case 'quiz':
        return '❓';
      case 'fill_blank':
        return '✏️';
      case 'match_pairs':
        return '🔗';
      case 'sort_order':
        return '📊';
      case 'project':
        return '🚀';
      default:
        return '📚';
    }
  }

  /// Get type label
  String getTypeLabel(String lessonType) {
    switch (lessonType) {
      case 'code_challenge':
        return 'Kod Challenge';
      case 'drag_drop':
        return 'Blok Kodlama';
      case 'quiz':
        return 'Quiz';
      case 'fill_blank':
        return 'Boşluk Doldur';
      case 'match_pairs':
        return 'Eşleştir';
      case 'sort_order':
        return 'Sırala';
      case 'project':
        return 'Proje';
      default:
        return 'Ders';
    }
  }
}
