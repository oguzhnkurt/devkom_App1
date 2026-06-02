import 'dart:convert';
import '../models/w3_lesson_model.dart';
import 'interactive_lessons_service.dart';

/// Converts Supabase interactive_lessons data to W3Lesson models
/// This allows us to use existing W3 UI components with new database content
class InteractiveLessonsConverter {
  final InteractiveLessonsService _service = InteractiveLessonsService();

  /// Convert course lessons from Supabase to W3Course
  Future<W3Course?> convertCourse(String courseId) async {
    try {
      final lessons = await _service.getCourseLessons(courseId);

      if (lessons.isEmpty) {
        print('⚠️  No lessons found for course: $courseId');
        return null;
      }

      final courseMetadata = _getCourseMetadata(courseId);
      final chapters = _groupLessonsIntoChapters(lessons);

      return W3Course(
        id: courseId,
        title: courseMetadata['title'],
        description: courseMetadata['description'],
        icon: courseMetadata['icon'],
        color: courseMetadata['color'],
        tags: List<String>.from(courseMetadata['tags']),
        ageMin: courseMetadata['ageMin'],
        ageMax: courseMetadata['ageMax'],
        chapters: chapters,
        totalLessons: lessons.length,
        estimatedHours: _calculateEstimatedHours(lessons),
      );
    } catch (e) {
      print('❌ Error converting course: $e');
      return null;
    }
  }

  /// Convert all courses
  Future<List<W3Course>> convertAllCourses() async {
    final courseIds = ['python', 'scratch', 'html', 'css', 'java', 'csharp'];
    final List<W3Course> courses = [];

    for (var courseId in courseIds) {
      final course = await convertCourse(courseId);
      if (course != null) {
        courses.add(course);
      }
    }

    return courses;
  }

  /// Group lessons into chapters by difficulty
  List<W3Chapter> _groupLessonsIntoChapters(List<Map<String, dynamic>> lessons) {
    final List<W3Chapter> chapters = [];

    // Group by difficulty
    final Map<int, List<Map<String, dynamic>>> difficultyGroups = {
      1: [],
      2: [],
      3: [],
      4: [],
    };

    for (var lesson in lessons) {
      final difficulty = lesson['difficulty'] as int? ?? 1;
      if (difficultyGroups.containsKey(difficulty)) {
        difficultyGroups[difficulty]!.add(lesson);
      } else {
        difficultyGroups[1]!.add(lesson);
      }
    }

    // Create chapters
    if (difficultyGroups[1]!.isNotEmpty) {
      chapters.add(W3Chapter(
        id: 'basics',
        title: 'Temel Konular',
        emoji: '🌱',
        lessons: difficultyGroups[1]!.map(_convertToW3Lesson).toList(),
      ));
    }

    if (difficultyGroups[2]!.isNotEmpty) {
      chapters.add(W3Chapter(
        id: 'intermediate',
        title: 'Orta Seviye',
        emoji: '🌿',
        lessons: difficultyGroups[2]!.map(_convertToW3Lesson).toList(),
      ));
    }

    if (difficultyGroups[3]!.isNotEmpty) {
      chapters.add(W3Chapter(
        id: 'advanced',
        title: 'İleri Seviye',
        emoji: '🌳',
        lessons: difficultyGroups[3]!.map(_convertToW3Lesson).toList(),
      ));
    }

    if (difficultyGroups[4]!.isNotEmpty) {
      chapters.add(W3Chapter(
        id: 'projects',
        title: 'Projeler',
        emoji: '🚀',
        lessons: difficultyGroups[4]!.map(_convertToW3Lesson).toList(),
      ));
    }

    return chapters;
  }

  /// Convert single lesson to W3Lesson
  W3Lesson _convertToW3Lesson(Map<String, dynamic> data) {
    final contents = _convertToW3Contents(data);
    final difficultyStr = _service.getDifficultyLabel(data['difficulty'] as int? ?? 1);

    return W3Lesson(
      id: data['id'] as String,
      title: data['title'] as String,
      shortDescription: data['description'] as String,
      contents: contents,
      estimatedMinutes: data['estimated_minutes'] as int? ?? 10,
      difficulty: difficultyStr,
      xpReward: data['xp_reward'] as int? ?? 0,
    );
  }

  /// Convert challenge data to W3Content list
  List<W3Content> _convertToW3Contents(Map<String, dynamic> data) {
    final List<W3Content> contents = [];
    final lessonType = data['lesson_type'] as String?;

    // 1. Introduction
    contents.add(W3Content.text(
      data['description'] as String,
      title: '📖 Görev',
    ));

    // 2. Instructions
    final instructions = _service.getInstructions(data);
    if (instructions.isNotEmpty) {
      final instructionsText = instructions
          .asMap()
          .entries
          .map((e) => '${e.key + 1}. ${e.value}')
          .join('\n');

      contents.add(W3Content.text(
        instructionsText,
        title: '📝 Adımlar',
      ));
    }

    // 3. Interactive Challenge
    if (lessonType == 'code_challenge') {
      contents.add(_createCodeChallenge(data));
    } else if (lessonType == 'drag_drop') {
      contents.add(_createDragDropChallenge(data));
    }

    // 4. Hints
    final hints = _service.getHints(data);
    for (int i = 0; i < hints.length; i++) {
      contents.add(W3Content.tip('💡 İpucu ${i + 1}: ${hints[i]}'));
    }

    return contents;
  }

  /// Create code challenge content
  W3Content _createCodeChallenge(Map<String, dynamic> data) {
    final config = _service.getChallengeConfig(data);
    final language = config?['language'] as String? ?? 'python';
    final starterCode = _service.getStarterCode(data) ?? '# Kodunuzu buraya yazın\n';

    return W3Content(
      type: W3ContentType.interactive,
      title: '💻 Kod Editörü',
      interactiveData: {
        'type': 'code_editor',
        'language': language,
        'starterCode': starterCode,
        'testCases': _service.getTestCases(data),
        'successCriteria': _service.getSuccessCriteria(data),
        'challengeId': data['id'],
        'xpReward': data['xp_reward'],
      },
    );
  }

  /// Create drag-drop challenge content
  W3Content _createDragDropChallenge(Map<String, dynamic> data) {
    final config = _service.getChallengeConfig(data);

    return W3Content(
      type: W3ContentType.interactive,
      title: '🧩 Blok Kodlama',
      interactiveData: {
        'type': 'scratch_workspace',
        'availableBlocks': _service.getAvailableBlocks(data),
        'expectedSequence': _parseJsonField(config?['expectedSequence']) ?? [],
        'stage': _parseJsonField(config?['stage']) ?? {},
        'challengeId': data['id'],
        'xpReward': data['xp_reward'],
      },
    );
  }

  /// Helper to parse JSON string fields
  dynamic _parseJsonField(dynamic field) {
    if (field == null) return null;
    if (field is String) {
      // Only attempt to parse if it looks like JSON (starts with { or [)
      final trimmed = field.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          return jsonDecode(field);
        } catch (e) {
          print('⚠️  Failed to parse JSON field: $e');
          return null;
        }
      }
      // Return plain strings as-is (like "blank", "maze_background")
      return field;
    }
    return field;
  }

  /// Get course metadata
  Map<String, dynamic> _getCourseMetadata(String courseId) {
    final metadata = {
      'python': {
        'title': 'Python Programlama',
        'description': 'Sıfırdan Python öğren - değişkenlerden OOP\'ye',
        'icon': '🐍',
        'color': '#3776AB',
        'tags': ['Python', 'Programlama', 'Başlangıç'],
        'ageMin': 10,
        'ageMax': 99,
      },
      'scratch': {
        'title': 'Scratch Programlama',
        'description': 'Blok tabanlı kodlama ile oyunlar yap',
        'icon': '🐱',
        'color': '#FF6B35',
        'tags': ['Scratch', 'Blok Kodlama', 'Çocuklar'],
        'ageMin': 6,
        'ageMax': 14,
      },
      'html': {
        'title': 'HTML Temelleri',
        'description': 'Web sayfaları oluşturmayı öğren',
        'icon': '🌐',
        'color': '#E34F26',
        'tags': ['HTML', 'Web', 'Başlangıç'],
        'ageMin': 10,
        'ageMax': 99,
      },
      'css': {
        'title': 'CSS Styling',
        'description': 'Web sitelerini güzelleştir',
        'icon': '🎨',
        'color': '#1572B6',
        'tags': ['CSS', 'Web', 'Tasarım'],
        'ageMin': 10,
        'ageMax': 99,
      },
      'java': {
        'title': 'Java Programlama',
        'description': 'Güçlü OOP dili Java\'yı öğren',
        'icon': '☕',
        'color': '#007396',
        'tags': ['Java', 'OOP', 'İleri'],
        'ageMin': 12,
        'ageMax': 99,
      },
      'csharp': {
        'title': 'C# Programlama',
        'description': 'Microsoft\'un güçlü dili C#',
        'icon': '🔷',
        'color': '#239120',
        'tags': ['C#', 'OOP', 'İleri'],
        'ageMin': 12,
        'ageMax': 99,
      },
    };

    return metadata[courseId] ?? {
      'title': courseId.toUpperCase(),
      'description': 'İnteraktif $courseId dersleri',
      'icon': '📚',
      'color': '#6B7280',
      'tags': [courseId],
      'ageMin': 10,
      'ageMax': 99,
    };
  }

  /// Calculate estimated hours
  int _calculateEstimatedHours(List<Map<String, dynamic>> lessons) {
    final totalMinutes = lessons.fold<int>(
      0,
      (sum, lesson) => sum + (lesson['estimated_minutes'] as int? ?? 10),
    );
    return (totalMinutes / 60).ceil();
  }
}
