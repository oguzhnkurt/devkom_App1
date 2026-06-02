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

      // 2. SAĞIM-SOLUM KODLAMA
      GameModel(
        id: 'embedded_left_right',
        title: 'Sağım-Solum',
        description: '⚡ Hızlı düşün, hızlı oyna! Robotunu hedefe ulaştır. Wordwall tarzı eğlenceli oyun!',
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

      // 7. QUIZ OYUNU (Robotik ve Kodlama Bilgisi)
      GameModel(
        id: 'embedded_quiz',
        title: 'Bilgi Yarışması',
        description: '🎯 Robotik ve kodlama bilgini test et! Çoktan seçmeli sorularla öğren ve eğlen.',
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
        },
      ),

      // 8. BORU BULMACASI (Pipes Puzzle)
      GameModel(
        id: 'embedded_pipes_puzzle',
        title: 'Boru Bulmacası',
        description: 'Boruları döndürerek su yolunu tamamla! Mantık ve problem çözme yeteneğini geliştir.',
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

      // 9. ROBOT SİMÜLATÖRÜ
      GameModel(
        id: 'embedded_robot_simulator',
        title: 'Robot Simülatörü',
        description: 'Sanal robot programla! Gerçek robot hareketlerini simüle et ve kodla kontrol et.',
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

      // 10. LABİRENT KAŞİFİ
      GameModel(
        id: 'embedded_maze_explorer',
        title: 'Labirent Kaşifi',
        description: 'Algoritmik düşünme ile labirentten çık! En kısa yolu bul ve hazineye ulaş.',
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
