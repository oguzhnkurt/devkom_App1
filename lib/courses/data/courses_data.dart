import 'package:flutter/material.dart';
import '../models/course_model.dart';

/// Aktif programlama kursları.
///
/// Liste **öğrenme yolu sırasında** tutuluyor: kolaydan zora, her adım bir
/// öncekinin üstüne biniyor. Katalog ekranı filtre uygulanmadığında kursları
/// bu sırayla, adım numaralarıyla gösteriyor.
///
/// Yol şu mantıkla kuruldu:
///  1-2  Yazı yazmadan, blok sürükleyerek (Scratch → mBlock ile Arduino)
///  3-4  İlk yazılı diller ama programlama değil, işaretleme (HTML → CSS)
///  5-6  İlk gerçek programlama (Python → Arduino IDE / C++)
///  7-8  Tip güvenli, nesne yönelimli diller (Java → C#)
class CoursesData {
  static const List<Course> allCourses = [
    // ==========================================
    // ADIM 1 — SCRATCH · Bloklarla ilk adım
    // ==========================================
    Course(
      id: 'scratch',
      nameEn: 'Scratch',
      nameDe: 'Scratch',
      nameEs: 'Scratch',
      descriptionEn:
          'Block-based visual programming. Your first step into coding!',
      descriptionDe:
          'Blockbasiertes visuelles Programmieren. Dein erster Schritt zum Code!',
      descriptionEs:
          '¡Programación visual con bloques. Tu primer paso en el código!',
      name: 'Scratch',
      slug: 'scratch',
      description: 'Blok tabanlı görsel programlama. Kodlamaya ilk adım!',
      icon: '🧩',
      primaryColor: Color(0xFFFF8C1A),
      secondaryColor: Color(0xFFFFAB40),
      category: CourseCategory.kids,
      difficulty: DifficultyLevel.beginner,
      tags: ['görsel', 'oyun', 'animasyon', 'başlangıç'],
      totalLessons: 12,
      estimatedMinutes: 240,
      sortOrder: 1,
      pathStep: 1,
    ),

    // ==========================================
    // ADIM 2 — mBLOCK · Editörü ve blokları tanı
    // ==========================================
    // Arduino kursu doğrudan devre kurmakla başlıyordu: çocuk mBlock'u hiç
    // tanımadan "şu bloğu sürükle" deniyordu. Ama mBlock'ta bir bloğu
    // sürüklemeden önce bilinmesi gereken şeyler var — cihaz mı kukla mı
    // seçili, yükleme modunda mı canlı modda mı, blok hangi kategoride.
    // Bu kurs önce editörü, sonra paleti, sonra ilk programı öğretiyor.
    Course(
      id: 'mblock',
      name: 'mBlock ile Kodlama',
      nameEn: 'Coding with mBlock',
      nameDe: 'Programmieren mit mBlock',
      nameEs: 'Programación con mBlock',
      slug: 'mblock',
      description:
          'mBlock editörünü sıfırdan öğren: palet, bloklar, ilk program ve '
          'küçükten büyüğe projeler.',
      descriptionEn:
          'Learn the mBlock editor from scratch: the palette, the blocks, '
          'your first program, then projects that grow.',
      descriptionDe:
          'Lerne den mBlock-Editor von Grund auf: Palette, Blöcke, dein '
          'erstes Programm und Projekte, die wachsen.',
      descriptionEs:
          'Aprende el editor mBlock desde cero: la paleta, los bloques, tu '
          'primer programa y proyectos que crecen.',
      icon: '🧩',
      primaryColor: Color(0xFF4A90E2),
      secondaryColor: Color(0xFF4CBFE6),
      category: CourseCategory.robotics,
      difficulty: DifficultyLevel.beginner,
      tags: ['mblock', 'blok', 'arduino', 'maker', 'robot'],
      totalLessons: 8,
      estimatedMinutes: 160,
      sortOrder: 2,
      pathStep: 2,
      prerequisiteId: 'scratch',
    ),

    // ==========================================
    // ADIM 3 — ARDUINO (mBLOCK) · Bloklar artık gerçek dünyayı kontrol ediyor
    // ==========================================
    // Scratch'ten hemen sonra geliyor: aynı sürükle-bırak mantığı, ama bu kez
    // LED, buton ve sensör gibi fiziksel parçaları kontrol ediyor. Çocuk yeni
    // bir dil öğrenmiyor, bildiği bloklarla yeni bir dünyaya geçiyor.
    Course(
      id: 'arduino',
      nameEn: 'Robotics with Arduino',
      nameDe: 'Robotik mit Arduino',
      nameEs: 'Robótica con Arduino',
      descriptionEn:
          'LEDs, buttons, sensors and motors with mBlock blocks. Robotics without typing code!',
      descriptionDe:
          'LEDs, Taster, Sensoren und Motoren mit mBlock-Blöcken. Robotik ohne Tippen!',
      descriptionEs:
          'LED, botones, sensores y motores con bloques de mBlock. ¡Robótica sin escribir código!',
      name: 'Arduino ile Robotik',
      slug: 'arduino',
      description:
          'mBlock bloklarıyla LED, buton, sensör ve motor. Kod yazmadan robotik!',
      icon: '🤖',
      primaryColor: Color(0xFF00979D),
      secondaryColor: Color(0xFF00BCD4),
      category: CourseCategory.robotics,
      difficulty: DifficultyLevel.beginner,
      tags: ['elektronik', 'robot', 'maker', 'mblock', 'blok'],
      totalLessons: 10,
      estimatedMinutes: 200,
      sortOrder: 3,
      pathStep: 3,
      prerequisiteId: 'mblock',
    ),

    // ==========================================
    // ADIM 4 — HTML · İlk kez klavyeyle yazmak
    // ==========================================
    Course(
      id: 'html',
      nameEn: 'HTML',
      nameDe: 'HTML',
      nameEs: 'HTML',
      descriptionEn:
          'The foundation of web pages. The language that structures content.',
      descriptionDe:
          'Die Grundlage von Webseiten. Die Sprache, die Inhalte strukturiert.',
      descriptionEs:
          'La base de las páginas web. El lenguaje que estructura el contenido.',
      name: 'HTML',
      slug: 'html',
      description: 'Web sayfalarının temeli. İçerik yapılandırma dili.',
      icon: '🌐',
      primaryColor: Color(0xFFE44D26),
      secondaryColor: Color(0xFFF16529),
      category: CourseCategory.web,
      difficulty: DifficultyLevel.beginner,
      tags: ['web', 'frontend', 'markup'],
      totalLessons: 10,
      estimatedMinutes: 220,
      sortOrder: 4,
      pathStep: 4,
      prerequisiteId: 'arduino',
    ),

    // ==========================================
    // ADIM 5 — CSS · HTML'in üstüne biner
    // ==========================================
    Course(
      id: 'css',
      nameEn: 'CSS',
      nameDe: 'CSS',
      nameEs: 'CSS',
      descriptionEn:
          'Make web pages look good. The language of style and design.',
      descriptionDe:
          'Bring Webseiten zum Strahlen. Die Sprache für Stil und Design.',
      descriptionEs:
          'Haz que las webs se vean bien. El lenguaje del estilo y el diseño.',
      name: 'CSS',
      slug: 'css',
      description: 'Web sayfalarını güzelleştir. Stil ve tasarım dili.',
      icon: '🎨',
      primaryColor: Color(0xFF264DE4),
      secondaryColor: Color(0xFF2965F1),
      category: CourseCategory.web,
      difficulty: DifficultyLevel.beginner,
      tags: ['web', 'frontend', 'stil', 'tasarım'],
      totalLessons: 12,
      estimatedMinutes: 240,
      sortOrder: 5,
      pathStep: 5,
      prerequisiteId: 'html',
    ),

    // ==========================================
    // ADIM 6 — PYTHON · İlk gerçek programlama dili
    // ==========================================
    Course(
      id: 'python',
      nameEn: 'Python',
      nameDe: 'Python',
      nameEs: 'Python',
      name: 'Python',
      slug: 'python',
      description:
          'İlk gerçek programlama dilin. Değişkenler, döngüler, fonksiyonlar.',
      icon: '🐍',
      primaryColor: Color(0xFF3776AB),
      secondaryColor: Color(0xFFFFD43B),
      category: CourseCategory.data,
      difficulty: DifficultyLevel.intermediate,
      tags: ['veri', 'ai', 'otomasyon', 'programlama'],
      // 9 modul, 22 ders. Katalog uzun sure 17 diyordu; modul 8 ve 9
      // eklendiginde bu sayi guncellenmemisti. Artik test kontrol ediyor
      // (test/course_content_test.dart).
      totalLessons: 22,
      estimatedMinutes: 640,
      sortOrder: 6,
      pathStep: 6,
      prerequisiteId: 'css',
    ),

    // ==========================================
    // ADIM 7 — ARDUINO IDE · Bloklardan gerçek koda
    // ==========================================
    // Adım 2'de blokla yaptığı projeleri bu kez C++ ile yazıyor. Python'dan
    // sonra geliyor çünkü değişken/döngü/fonksiyon kavramlarını orada öğrendi.
    Course(
      id: 'arduino_ide',
      nameEn: 'Arduino IDE',
      nameDe: 'Arduino IDE',
      nameEs: 'Arduino IDE',
      name: 'Arduino IDE',
      slug: 'arduino-ide',
      description:
          'Bloklardan gerçek C++ koduna geç. Seri port, fonksiyonlar, LCD ekran.',
      icon: '💻',
      primaryColor: Color(0xFF006064),
      secondaryColor: Color(0xFF0097A7),
      category: CourseCategory.robotics,
      difficulty: DifficultyLevel.intermediate,
      tags: ['elektronik', 'robot', 'cpp', 'kod', 'ileri'],
      totalLessons: 5,
      estimatedMinutes: 150,
      sortOrder: 7,
      isPremium: true,
      pathStep: 7,
      prerequisiteId: 'python',
    ),

    // ==========================================
    // ADIM 8 — JAVA · Tip güvenli, nesne yönelimli
    // ==========================================
    Course(
      id: 'java',
      nameEn: 'Java',
      nameDe: 'Java',
      nameEs: 'Java',
      name: 'Java',
      slug: 'java',
      description: 'Kurumsal standart. Her yerde çalışan güvenilir dil.',
      icon: '☕',
      primaryColor: Color(0xFFED8B00),
      secondaryColor: Color(0xFFFFA726),
      category: CourseCategory.mobile,
      difficulty: DifficultyLevel.advanced,
      tags: ['android', 'kurumsal', 'jvm', 'oop'],
      totalLessons: 12,
      estimatedMinutes: 240,
      sortOrder: 8,
      isPremium: true,
      pathStep: 8,
      prerequisiteId: 'arduino_ide',
    ),

    // ==========================================
    // ADIM 9 — C# · Oyun ve masaüstü
    // ==========================================
    Course(
      id: 'csharp',
      nameEn: 'C#',
      nameDe: 'C#',
      nameEs: 'C#',
      name: 'C#',
      slug: 'csharp',
      description: 'Microsoft\'un gücü. Oyun, web, masaüstü hepsi bir arada.',
      icon: '💜',
      primaryColor: Color(0xFF68217A),
      secondaryColor: Color(0xFF9B4DCA),
      category: CourseCategory.mobile,
      difficulty: DifficultyLevel.advanced,
      tags: ['unity', 'windows', 'microsoft', '.net', 'oyun'],
      totalLessons: 12,
      estimatedMinutes: 240,
      sortOrder: 9,
      isPremium: true,
      pathStep: 9,
      prerequisiteId: 'java',
    ),

    // ==========================================
    // GELECEK GÜNCELLEMELERDE EKLENECEK KURSLAR
    // ==========================================
    // JavaScript, TypeScript, PHP, SQL (Web)
    // Dart, Swift, Kotlin (Mobil)
    // C, C++, Go, Rust (Sistem)
    // MicroPython, Raspberry Pi (Robotik)
    // R, Julia, MATLAB (Veri Bilimi)
  ];

  /// Öğrenme yolundaki kurslar, adım sırasına göre.
  static List<Course> get learningPath {
    final path = allCourses.where((c) => c.pathStep > 0).toList();
    path.sort((a, b) => a.pathStep.compareTo(b.pathStep));
    return path;
  }

  /// Bir kursu id'sinden bulur (ön koşul adını göstermek için).
  static Course? byId(String id) {
    for (final c in allCourses) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Kurslarda arama yapar.
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
