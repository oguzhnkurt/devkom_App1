import 'package:flutter/material.dart';
import '../models/course_model.dart';

/// Active programming language courses
class CoursesData {
  static const List<Course> allCourses = [
    // ==========================================
    // 1. SCRATCH - Çocuklar İçin
    // ==========================================
    Course(
      id: 'scratch',
      name: 'Scratch',
      slug: 'scratch',
      description: 'Blok tabanli gorsel programlama. Kodlamaya ilk adim!',
      icon: '🧩',
      primaryColor: Color(0xFFFF8C1A),
      secondaryColor: Color(0xFFFFAB40),
      category: CourseCategory.kids,
      difficulty: DifficultyLevel.beginner,
      tags: ['gorsel', 'oyun', 'animasyon', 'baslangic'],
      totalLessons: 12,
      estimatedMinutes: 240,
      sortOrder: 1,
    ),

    // ==========================================
    // 2. ARDUINO - Robotik & IoT
    // ==========================================
    Course(
      id: 'arduino',
      name: 'Arduino',
      slug: 'arduino',
      description: 'Elektronik projelerin beyni. LED\'den robota!',
      icon: '🔌',
      primaryColor: Color(0xFF00979D),
      secondaryColor: Color(0xFF00BCD4),
      category: CourseCategory.robotics,
      difficulty: DifficultyLevel.beginner,
      tags: ['elektronik', 'robot', 'maker'],
      totalLessons: 8,
      estimatedMinutes: 200,
      sortOrder: 2,
    ),

    // ==========================================
    // 3. PYTHON - Veri & Yapay Zeka
    // ==========================================
    Course(
      id: 'python',
      name: 'Python',
      slug: 'python',
      description: 'En populer dil. Veri bilimi, AI, otomasyon.',
      icon: '🐍',
      primaryColor: Color(0xFF3776AB),
      secondaryColor: Color(0xFFFFD43B),
      category: CourseCategory.data,
      difficulty: DifficultyLevel.beginner,
      tags: ['veri', 'ai', 'otomasyon', 'baslangic'],
      totalLessons: 17,
      estimatedMinutes: 500,
      sortOrder: 3,
    ),

    // ==========================================
    // 4. JAVA - Mobil & Kurumsal
    // ==========================================
    Course(
      id: 'java',
      name: 'Java',
      slug: 'java',
      description: 'Kurumsal standart. Her yerde calisan guvenilir dil.',
      icon: '☕',
      primaryColor: Color(0xFFED8B00),
      secondaryColor: Color(0xFFFFA726),
      category: CourseCategory.mobile,
      difficulty: DifficultyLevel.intermediate,
      tags: ['android', 'kurumsal', 'jvm'],
      totalLessons: 12,
      estimatedMinutes: 240,
      sortOrder: 4,
    ),

    // ==========================================
    // 5. CSS - Web Tasarım
    // ==========================================
    Course(
      id: 'css',
      name: 'CSS',
      slug: 'css',
      description: 'Web sayfalarini guzelleştir. Stil ve tasarim dili.',
      icon: '🎨',
      primaryColor: Color(0xFF264DE4),
      secondaryColor: Color(0xFF2965F1),
      category: CourseCategory.web,
      difficulty: DifficultyLevel.beginner,
      tags: ['web', 'frontend', 'stil', 'tasarim'],
      totalLessons: 12,
      estimatedMinutes: 240,
      sortOrder: 5,
    ),

    // ==========================================
    // 6. HTML - Web Temeli
    // ==========================================
    Course(
      id: 'html',
      name: 'HTML',
      slug: 'html',
      description: 'Web sayfalarinin temeli. Icerik yapilandirma dili.',
      icon: '🌐',
      primaryColor: Color(0xFFE44D26),
      secondaryColor: Color(0xFFF16529),
      category: CourseCategory.web,
      difficulty: DifficultyLevel.beginner,
      tags: ['web', 'frontend', 'markup'],
      totalLessons: 3,
      estimatedMinutes: 45,
      sortOrder: 6,
    ),

    // ==========================================
    // 7. C# - Microsoft & Oyun
    // ==========================================
    Course(
      id: 'csharp',
      name: 'C#',
      slug: 'csharp',
      description: 'Microsoft\'un gucu. Oyun, web, masaustu hepsi bir arada.',
      icon: '💜',
      primaryColor: Color(0xFF68217A),
      secondaryColor: Color(0xFF9B4DCA),
      category: CourseCategory.mobile,
      difficulty: DifficultyLevel.intermediate,
      tags: ['unity', 'windows', 'microsoft', '.net'],
      totalLessons: 12,
      estimatedMinutes: 240,
      sortOrder: 7,
    ),

    // ==========================================
    // GELECEK GUNCELLEMELERDE EKLENECEK KURSLAR
    // ==========================================
    // JavaScript, TypeScript, PHP, SQL (Web)
    // Dart, Swift, Kotlin (Mobile)
    // C, C++, Go, Rust (Systems)
    // MicroPython, Raspberry Pi (Robotics)
    // R, Julia, MATLAB (Data Science)
    // Ruby, Perl, Lua, Assembly (Advanced)
  ];

  /// Search courses by query
  static List<Course> search(String query) {
    if (query.isEmpty) return allCourses;

    final lowerQuery = query.toLowerCase();
    return allCourses.where((course) {
      return course.name.toLowerCase().contains(lowerQuery) ||
             course.description.toLowerCase().contains(lowerQuery) ||
             course.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
