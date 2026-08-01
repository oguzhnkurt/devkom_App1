import '../models/game_model.dart';

/// Gömülü oyunlar servisi
/// Bu oyunlar kod içinde tanımlıdır ve değiştirilemez
/// Admin sadece aktif/pasif yapabilir
class EmbeddedGamesService {

  /// Tüm gömülü oyunları döndürür
  static List<GameModel> getAllEmbeddedGames() {
    final now = DateTime.now();

    return [
      // 1. SATRANÇ OYUNU (EN ÖNEMLİ OYUN)
      GameModel(
        id: 'embedded_chess',
        title: 'Satranç',
        description: 'Yapay zeka ile satranç oyna! Stratejik düşünme becerilerini geliştir.',
        titleEn: 'Chess',
        descriptionEn: 'Play chess against AI! Develop your strategic thinking skills.',
        category: GameCategory.age7to9,
        type: GameType.chess,
        thumbnailUrl: 'https://images.unsplash.com/photo-1586165368502-1bad197a6461?w=400',
        difficulty: 3,
        estimatedMinutes: 20,
        tags: ['strateji', 'satranç', 'düşünme', 'yapay zeka'],
        isActive: true,
        createdAt: now,
        gameData: {
          'difficulties': ['beginner', 'intermediate', 'advanced'],
          'hasAI': true,
          'description': 'AI ile satranç oynama',
          'imageUrl': 'https://images.unsplash.com/photo-1586165368502-1bad197a6461?w=800',
        },
      ),

      // 2. QUIZ OYUNU (Robotik ve Kodlama Bilgisi) — öne alındı, Satranç'tan sonra ilk sırada
      GameModel(
        id: 'embedded_quiz',
        title: 'Bilgi Yarışması',
        description: '🎯 Robotik ve kodlama bilgini test et! Çoktan seçmeli sorularla öğren ve eğlen.',
        titleEn: 'Knowledge Quiz',
        descriptionEn: '🎯 Test your robotics and coding knowledge! Learn and have fun with multiple-choice questions.',
        category: GameCategory.quiz,
        type: GameType.quiz,
        thumbnailUrl: 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=400',
        difficulty: 2,
        estimatedMinutes: 15,
        tags: ['quiz', 'bilgi', 'robotik', 'kodlama', 'test'],
        isActive: true,
        createdAt: now,
        gameData: {
          'questionCount': 20,
          'categories': ['robotik', 'kodlama', 'elektronik', 'algoritma'],
          'difficulty_levels': ['kolay', 'orta', 'zor'],
          'description': 'Robotik ve kodlama konularında bilgi yarışması',
          'hasTimer': true,
          'timePerQuestion': 30,
          // Oyunun çalışabilmesi için gerçek soru verisi (önceden eksikti,
          // bu yüzden ekran hep "Bu oyun henüz hazırlanmamış" gösteriyordu).
          'questions': [
            {
              'question': 'Bir bilgisayar programındaki adım adım talimatlar dizisine ne denir?',
              'options': ['Algoritma', 'Veritabanı', 'Tarayıcı', 'Sunucu'],
              'correctAnswer': 0,
            },
            {
              'question': 'Robotların çevresini "görmesini" sağlayan parçaya ne denir?',
              'options': ['Motor', 'Sensör', 'Pil', 'Kablo'],
              'correctAnswer': 1,
            },
            {
              'question': 'Aşağıdakilerden hangisi bir programlama dili değildir?',
              'options': ['Python', 'Scratch', 'HTML5', 'Excel'],
              'correctAnswer': 3,
            },
            {
              'question': 'Bir işlemi belirli sayıda tekrar ettiren komut yapısına ne denir?',
              'options': ['Değişken', 'Döngü (Loop)', 'Fonksiyon', 'Değişmez (Sabit)'],
              'correctAnswer': 1,
            },
            {
              'question': 'Elektronik devrelerde akımın akmasını sağlayan güç kaynağı hangisidir?',
              'options': ['Direnç', 'Anahtar', 'Pil/Batarya', 'Kablo'],
              'correctAnswer': 2,
            },
            {
              'question': 'Bir programda "eğer... ise" şeklindeki karar yapılarına ne ad verilir?',
              'options': ['Koşul (If)', 'Döngü', 'Dizi', 'Sınıf'],
              'correctAnswer': 0,
            },
            {
              'question': 'Arduino gibi kartlarda kodları yazıp yüklemeye yarayan yazılıma ne denir?',
              'options': ['Tarayıcı', 'IDE (Geliştirme Ortamı)', 'İşletim Sistemi', 'Antivirüs'],
              'correctAnswer': 1,
            },
            {
              'question': 'Bir robotun engelleri fark edip durmasını sağlayan sensör türü hangisidir?',
              'options': ['Ses sensörü', 'Ultrasonik mesafe sensörü', 'Işık sensörü', 'Nem sensörü'],
              'correctAnswer': 1,
            },
            {
              'question': 'Programlamada bilgi saklamak için kullanılan kutucuklara ne denir?',
              'options': ['Değişken', 'Etiket', 'Simge', 'Bağlantı'],
              'correctAnswer': 0,
            },
            {
              'question': 'İkili sayı sisteminde kaç farklı rakam kullanılır?',
              'options': ['2', '8', '10', '16'],
              'correctAnswer': 0,
            },
            {
              'question': 'Bir algoritmanın adımlarını görsel olarak gösteren şemaya ne denir?',
              'options': ['Akış şeması', 'Pasta grafiği', 'Harita', 'Takvim'],
              'correctAnswer': 0,
            },
            {
              'question': 'Aşağıdakilerden hangisi bir çıktı (output) birimidir?',
              'options': ['Klavye', 'Fare', 'Ekran (Monitör)', 'Mikrofon'],
              'correctAnswer': 2,
            },
            {
              'question': 'Robotik kollarda hareketi sağlayan parçaya ne denir?',
              'options': ['Servo motor', 'Hoparlör', 'Anten', 'Ekran'],
              'correctAnswer': 0,
            },
            {
              'question': 'Bir kod bloğunu tekrar tekrar kullanmak için yazılan yapıya ne denir?',
              'options': ['Fonksiyon', 'Yorum satırı', 'Hata mesajı', 'Değişmez'],
              'correctAnswer': 0,
            },
            {
              'question': 'LED ışığının yanıp sönmesini kontrol eden temel elektronik bileşen çifti hangisidir?',
              'options': ['Direnç ve LED', 'Anten ve Mikrofon', 'Ekran ve Fare', 'Kamera ve Hoparlör'],
              'correctAnswer': 0,
            },
          ],
        },
      ),

      // 3. ROBOT SİMÜLATÖRÜ — öne alındı, Satranç'tan sonra ilk sırada
      GameModel(
        id: 'embedded_robot_simulator',
        title: 'Robot Simülatörü',
        description: 'Sanal robot programla! Gerçek robot hareketlerini simüle et ve kodla kontrol et.',
        titleEn: 'Robot Simulator',
        descriptionEn: 'Program a virtual robot! Simulate real robot movements and control it with code.',
        category: GameCategory.robotics,
        type: GameType.robotSimulator,
        thumbnailUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=400',
        difficulty: 3,
        estimatedMinutes: 25,
        tags: ['robot', 'simülasyon', 'kodlama', 'fizik'],
        isActive: true,
        createdAt: now,
        gameData: {
          'sensors': ['ultrasonic', 'ir', 'line_follower'],
          'movements': ['forward', 'backward', 'turn_left', 'turn_right'],
          'levels': 10,
          'description': 'Gerçekçi robot simülasyon ve programlama',
        },
      ),

      // 4. SAĞIM-SOLUM KODLAMA
      GameModel(
        id: 'embedded_left_right',
        title: 'Sağım-Solum',
        description: '⚡ Hızlı düşün, hızlı oyna! Robotunu hedefe ulaştır. Wordwall tarzı eğlenceli oyun!',
        titleEn: 'Left-Right Coding',
        descriptionEn: '⚡ Think fast, play fast! Get your robot to the goal. A fun Wordwall-style game!',
        category: GameCategory.age4to6,
        type: GameType.leftRightCoding,
        thumbnailUrl: 'https://images.unsplash.com/photo-1561557944-6e7860d1a7eb?w=400',
        difficulty: 1,
        estimatedMinutes: 10,
        tags: ['hızlı', 'yön', 'kodlama', 'sağ-sol', 'flame'],
        isActive: true,
        createdAt: now,
        gameData: {
          'levels': 10,
          'gridSizes': [5, 7, 9],
          'description': 'Sağ-Sol komutlarıyla robotunu hedefe ulaştır',
        },
      ),

      // 3. KOORDİNAT ÖĞRENİMİ
      GameModel(
        id: 'embedded_coordinates',
        title: 'Koordinat Macerası',
        description: 'X ve Y eksenlerini öğren! Robotunu doğru koordinatlara götürerek hedefe ulaş.',
        titleEn: 'Coordinate Adventure',
        descriptionEn: 'Learn the X and Y axes! Guide your robot to the target by moving to the right coordinates.',
        category: GameCategory.age4to6,
        type: GameType.coordinates,
        thumbnailUrl: 'https://images.unsplash.com/photo-1509228627152-72ae9ae6848d?w=400',
        difficulty: 1,
        estimatedMinutes: 10,
        tags: ['matematik', 'koordinat', 'x-y'],
        isActive: true,
        createdAt: now,
        gameData: {
          'gridSize': 8,
          'levels': 10,
          'description': 'X-Y koordinat sistemi öğrenme',
        },
      ),

      // 4. BLOK KODLAMA
      GameModel(
        id: 'embedded_block_coding',
        title: 'Kod Blokları',
        description: 'Blokları sürükleyip bırakarak kod yaz! Robotunu programla ve engelleri aş.',
        titleEn: 'Code Blocks',
        descriptionEn: 'Write code by dragging and dropping blocks! Program your robot and get past obstacles.',
        category: GameCategory.age7to9,
        type: GameType.blockCoding,
        thumbnailUrl: 'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=400',
        difficulty: 2,
        estimatedMinutes: 15,
        tags: ['kodlama', 'blok', 'programlama'],
        isActive: true,
        createdAt: now,
        gameData: {
          'availableBlocks': ['move_forward', 'turn_left', 'turn_right', 'repeat', 'if_obstacle'],
          'levels': 10,
          'description': 'Scratch tarzı blok kodlama oyunu',
        },
      ),

      // 5. KOMUT DİZİLİMİ (Döngüler ve Koşullar)
      GameModel(
        id: 'embedded_sequencing',
        title: 'Komut Dizilimi',
        description: 'Komutları doğru sırada yerleştir! Döngüler ve koşulları kullanarak problemleri çöz.',
        titleEn: 'Command Sequencing',
        descriptionEn: 'Put the commands in the right order! Solve problems using loops and conditions.',
        category: GameCategory.age7to9,
        type: GameType.sequencing,
        thumbnailUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400',
        difficulty: 3,
        estimatedMinutes: 15,
        tags: ['algoritma', 'döngü', 'koşul', 'sıralama'],
        isActive: true,
        createdAt: now,
        gameData: {
          'concepts': ['sequence', 'loop', 'condition'],
          'levels': 12,
          'description': 'Algoritma ve komut sıralama oyunu',
        },
      ),

      // 6. KELİME EŞLEŞTİRME (İngilizce)
      GameModel(
        id: 'embedded_word_match',
        title: 'Kelime Avı',
        description: 'İngilizce kelimeleri resimleriyle eşleştir! Sürükle-bırak ile kelime öğren.',
        titleEn: 'Word Hunt',
        descriptionEn: 'Match English words with their pictures! Learn vocabulary with drag-and-drop.',
        category: GameCategory.age4to6,
        type: GameType.wordMatch,
        thumbnailUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400',
        difficulty: 1,
        estimatedMinutes: 10,
        tags: ['ingilizce', 'kelime', 'eşleştirme'],
        isActive: true,
        createdAt: now,
        gameData: {
          'categories': ['animals', 'colors', 'numbers', 'shapes'],
          'wordCount': 20,
          'description': 'İngilizce kelime-resim eşleştirme oyunu',
        },
      ),

      // 8. BORU BULMACASI (Pipes Puzzle)
      GameModel(
        id: 'embedded_pipes_puzzle',
        title: 'Boru Bulmacası',
        description: 'Boruları döndürerek su yolunu tamamla! Mantık ve problem çözme yeteneğini geliştir.',
        titleEn: 'Pipes Puzzle',
        descriptionEn: 'Rotate the pipes to complete the water path! Develop your logic and problem-solving skills.',
        category: GameCategory.age7to9,
        type: GameType.pipesPuzzle,
        thumbnailUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400',
        difficulty: 2,
        estimatedMinutes: 12,
        tags: ['mantık', 'bulmaca', 'problem çözme', 'strateji'],
        isActive: true,
        createdAt: now,
        gameData: {
          'levels': 15,
          'gridSizes': [4, 5, 6, 7],
          'description': 'Boruları döndürerek su yolunu tamamlama oyunu',
        },
      ),

      // 10. LABİRENT KAŞİFİ
      GameModel(
        id: 'embedded_maze_explorer',
        title: 'Labirent Kaşifi',
        description: 'Algoritmik düşünme ile labirentten çık! En kısa yolu bul ve hazineye ulaş.',
        titleEn: 'Maze Explorer',
        descriptionEn: 'Escape the maze with algorithmic thinking! Find the shortest path and reach the treasure.',
        category: GameCategory.age7to9,
        type: GameType.mazeExplorer,
        thumbnailUrl: 'https://images.unsplash.com/photo-1515150144380-bca9f1650ed9?w=400',
        difficulty: 2,
        estimatedMinutes: 15,
        tags: ['algoritma', 'labirent', 'problem çözme', 'DFS', 'BFS'],
        isActive: true,
        createdAt: now,
        gameData: {
          'algorithms': ['manual', 'breadth_first', 'depth_first'],
          'mazeComplexity': ['easy', 'medium', 'hard'],
          'levels': 20,
          'description': 'Labirent çözme ve algoritma öğrenme oyunu',
        },
      ),

      // 11. RENKLİ KODLAR
      GameModel(
        id: 'embedded_color_coding',
        title: 'Renkli Kodlar',
        description: 'Renk kodları ile programlama öğren! Her renk bir komut, kombinasyonlar bir program.',
        titleEn: 'Color Codes',
        descriptionEn: 'Learn programming with color codes! Each color is a command, combinations make a program.',
        category: GameCategory.age4to6,
        type: GameType.colorCoding,
        thumbnailUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        difficulty: 1,
        estimatedMinutes: 10,
        tags: ['renk', 'kodlama', 'görsel', 'eğlence'],
        isActive: true,
        createdAt: now,
        gameData: {
          'colors': ['red', 'blue', 'green', 'yellow', 'purple'],
          'commands': ['move', 'turn', 'jump', 'collect', 'wait'],
          'levels': 12,
          'description': 'Renk tabanlı görsel programlama oyunu',
        },
      ),

      // 12. EŞLEŞTİRME OYUNU (Arduino/Elektronik - sürükle-bırak)
      GameModel(
        id: 'embedded_matching_arduino',
        title: 'Arduino Eşleştirme',
        description: 'Arduino kod parçalarını, komutlarını ve bileşenlerini doğru açıklamayla eşleştir!',
        titleEn: 'Arduino Matching',
        descriptionEn: 'Match Arduino code snippets, commands, and components with the correct description!',
        category: GameCategory.arduino,
        type: GameType.matchingGame,
        thumbnailUrl: 'https://images.unsplash.com/photo-1553406830-ef2513450d76?w=400',
        difficulty: 2,
        estimatedMinutes: 8,
        tags: ['arduino', 'eşleştirme', 'sürükle-bırak', 'elektronik'],
        isActive: true,
        createdAt: now,
        gameData: {
          'title': 'Arduino Eşleştirme',
          'titleEn': 'Arduino Matching',
          'timeSeconds': 90,
          'description': 'Sürükle-bırak ile Arduino kavramlarını eşleştirme oyunu',
          'descriptionEn': 'A drag-and-drop game for matching Arduino concepts',
          'levels': [
            {
              'title': 'Seviye 1: Kod ve Kavramlar',
              'titleEn': 'Level 1: Code and Concepts',
              'timeSeconds': 90,
              'mode': 'text',
              'pairs': [
                {'answer': 'Kütüphane Çağırma', 'answerEn': 'Library Include', 'prompt': '#include <Servo.h>', 'icon': 'code'},
                {'answer': 'Servo Kütüphane Çağırma', 'answerEn': 'Servo Library Include', 'prompt': '#include <xxx.h>', 'icon': 'code'},
                {'answer': 'Servo Motor', 'answerEn': 'Servo Motor', 'prompt': 'Servo Motor', 'icon': 'servo'},
                {'answer': 'Lcd Ekran', 'answerEn': 'LCD Screen', 'prompt': 'Lcd Ekran', 'promptEn': 'LCD Screen', 'icon': 'lcd'},
                {'answer': 'Mikro İşlemci', 'answerEn': 'Microcontroller', 'prompt': 'Arduino', 'icon': 'arduino'},
                {'answer': 'Digital Yazma', 'answerEn': 'Digital Write', 'prompt': 'digitalWrite(5, HIGH);', 'icon': 'code'},
                {'answer': 'Digital Okuma', 'answerEn': 'Digital Read', 'prompt': 'digitalRead(5);', 'icon': 'code'},
                {'answer': 'Input Metod', 'answerEn': 'Input Method', 'prompt': 'pinMode(button, INPUT);', 'icon': 'pin'},
                {'answer': '3,5,6,9,10,11', 'answerEn': '3,5,6,9,10,11', 'prompt': 'Anolog Pinler', 'promptEn': 'Analog Pins', 'icon': 'pin'},
              ],
            },
            {
              'title': 'Seviye 2: Bileşenleri Tanı',
              'titleEn': 'Level 2: Know the Components',
              'timeSeconds': 75,
              'mode': 'image',
              'pairs': [
                {'answer': 'Direnç', 'answerEn': 'Resistor', 'prompt': 'Direnç', 'promptEn': 'Resistor', 'icon': 'resistor'},
                {'answer': 'LDR (Işık Sensörü)', 'answerEn': 'LDR (Light Sensor)', 'prompt': 'LDR (Işık Sensörü)', 'promptEn': 'LDR (Light Sensor)', 'icon': 'ldr'},
                {'answer': 'Arduino', 'answerEn': 'Arduino', 'prompt': 'Arduino', 'promptEn': 'Arduino', 'icon': 'arduino'},
                {'answer': 'Su Sensörü', 'answerEn': 'Water Sensor', 'prompt': 'Su Sensörü', 'promptEn': 'Water Sensor', 'icon': 'water'},
                {'answer': 'Scratch', 'answerEn': 'Scratch', 'prompt': 'Scratch', 'promptEn': 'Scratch', 'icon': 'scratch'},
                {'answer': 'mBlock', 'answerEn': 'mBlock', 'prompt': 'mBlock', 'promptEn': 'mBlock', 'icon': 'mblock'},
                {'answer': 'Lcd Ekran', 'answerEn': 'LCD Screen', 'prompt': 'Lcd Ekran', 'promptEn': 'LCD Screen', 'icon': 'lcd'},
              ],
            },
          ],
        },
      ),

    ];
  }

  /// Belirli bir oyunu ID ile getirir
  static GameModel? getGameById(String id) {
    try {
      return getAllEmbeddedGames().firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Kategoriye göre oyunları filtreler
  static List<GameModel> getGamesByCategory(GameCategory category) {
    return getAllEmbeddedGames()
        .where((game) => game.category == category)
        .toList();
  }

  /// Oyun tipine göre filtreler
  static List<GameModel> getGamesByType(GameType type) {
    return getAllEmbeddedGames()
        .where((game) => game.type == type)
        .toList();
  }

  /// Aktif oyunları döndürür
  static List<GameModel> getActiveGames() {
    return getAllEmbeddedGames()
        .where((game) => game.isActive)
        .toList();
  }

  /// Zorluk seviyesine göre filtreler
  static List<GameModel> getGamesByDifficulty(int minDiff, int maxDiff) {
    return getAllEmbeddedGames()
        .where((game) =>
          game.difficulty >= minDiff && game.difficulty <= maxDiff)
        .toList();
  }

  /// Ziyaretçiler için erişilebilir oyunları döndürür
  /// Sadece Quiz ve Sağım-Solum oyunları
  static List<GameModel> getVisitorGames() {
    return getAllEmbeddedGames()
        .where((game) =>
          game.isActive &&
          (game.id == 'embedded_quiz' || game.id == 'embedded_left_right'))
        .toList();
  }
}
