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
        titleDe: 'Schach',
        descriptionDe: 'Spiel Schach gegen die KI! Trainiere dein strategisches Denken.',
        titleEs: 'Ajedrez',
        descriptionEs: '¡Juega al ajedrez contra la IA! Desarrolla tu pensamiento estratégico.',
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
        titleDe: 'Wissensquiz',
        descriptionDe: '🎯 Teste dein Wissen über Robotik und Programmieren! Lerne mit Multiple-Choice-Fragen.',
        titleEs: 'Concurso de conocimiento',
        descriptionEs: '🎯 ¡Pon a prueba lo que sabes de robótica y programación! Aprende con preguntas de opción múltiple.',
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
        titleDe: 'Roboter-Simulator',
        descriptionDe: 'Programmiere einen virtuellen Roboter! Simuliere echte Bewegungen und steuere sie mit Code.',
        titleEs: 'Simulador de robots',
        descriptionEs: '¡Programa un robot virtual! Simula movimientos reales y contrólalo con código.',
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
        titleDe: 'Links-Rechts-Coding',
        descriptionDe: '⚡ Denk schnell, spiel schnell! Bring deinen Roboter ins Ziel.',
        titleEs: 'Código izquierda-derecha',
        descriptionEs: '⚡ ¡Piensa rápido, juega rápido! Lleva tu robot hasta la meta.',
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
        titleDe: 'Koordinaten-Abenteuer',
        descriptionDe: 'Lerne die X- und Y-Achse! Führe deinen Roboter zu den richtigen Koordinaten.',
        titleEs: 'Aventura de coordenadas',
        descriptionEs: '¡Aprende los ejes X e Y! Lleva tu robot a las coordenadas correctas.',
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
        titleDe: 'Code-Blöcke',
        descriptionDe: 'Schreibe Code per Drag-and-drop! Programmiere deinen Roboter und überwinde Hindernisse.',
        titleEs: 'Bloques de código',
        descriptionEs: '¡Escribe código arrastrando bloques! Programa tu robot y supera los obstáculos.',
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
        titleDe: 'Befehlsfolge',
        descriptionDe: 'Bring die Befehle in die richtige Reihenfolge! Löse Aufgaben mit Schleifen und Bedingungen.',
        titleEs: 'Secuencia de comandos',
        descriptionEs: '¡Ordena los comandos! Resuelve problemas con bucles y condiciones.',
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
        description: 'İngilizce kodlama terimlerini anlamlarıyla eşleştir! Sürükle-bırak ile öğren.',
        titleEn: 'Word Hunt',
        descriptionEn: 'Match English coding terms with what they mean! Learn with drag-and-drop.',
        titleDe: 'Wortjagd',
        descriptionDe: 'Ordne englische Fachwörter ihrer Bedeutung zu! Lernen per Drag-and-drop.',
        titleEs: 'Caza de palabras',
        descriptionEs: '¡Une los términos en inglés con su significado! Aprende arrastrando y soltando.',
        category: GameCategory.age4to6,
        type: GameType.wordMatch,
        thumbnailUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400',
        difficulty: 1,
        estimatedMinutes: 10,
        tags: ['ingilizce', 'kelime', 'eşleştirme'],
        isActive: true,
        createdAt: now,
        gameData: {
          'categories': ['robotics', 'scratch', 'arduino', 'python', 'coding'],
          'wordCount': 75,
          'description': 'İngilizce terim-anlam eşleştirme oyunu',
        },
      ),

      // 8. BORU BULMACASI (Pipes Puzzle)
      GameModel(
        id: 'embedded_pipes_puzzle',
        title: 'Boru Bulmacası',
        description: 'Boruları döndürerek su yolunu tamamla! Mantık ve problem çözme yeteneğini geliştir.',
        titleEn: 'Pipes Puzzle',
        descriptionEn: 'Rotate the pipes to complete the water path! Develop your logic and problem-solving skills.',
        titleDe: 'Rohr-Puzzle',
        descriptionDe: 'Dreh die Rohre und schließe den Wasserweg! Trainiere Logik und Problemlösen.',
        titleEs: 'Rompecabezas de tuberías',
        descriptionEs: '¡Gira las tuberías y completa el recorrido del agua! Practica lógica y resolución de problemas.',
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
        titleDe: 'Labyrinth-Forscher',
        descriptionDe: 'Finde mit algorithmischem Denken aus dem Labyrinth! Nimm den kürzesten Weg zum Schatz.',
        titleEs: 'Explorador del laberinto',
        descriptionEs: '¡Sal del laberinto con pensamiento algorítmico! Encuentra el camino más corto al tesoro.',
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
        titleDe: 'Farbcodes',
        descriptionDe: 'Lerne Programmieren mit Farbcodes! Jede Farbe ist ein Befehl, die Reihe ein Programm.',
        titleEs: 'Códigos de colores',
        descriptionEs: '¡Aprende a programar con códigos de colores! Cada color es un comando y la combinación, un programa.',
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
        titleDe: 'Arduino-Zuordnung',
        descriptionDe: 'Ordne Arduino-Codeschnipsel, Befehle und Bauteile der richtigen Erklärung zu!',
        titleEs: 'Emparejar Arduino',
        descriptionEs: '¡Une fragmentos de código, comandos y componentes de Arduino con su descripción correcta!',
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


      // 13. KOD DEDEKTIFI — oruntu tanima
      // Bu dort oyunun ekranlari uzun suredir yazilmisti ama listeye hic
      // eklenmemisti: game_play_screen yonlendirmeyi biliyordu, oyunlar
      // ekraninda gorunmuyorlardi. Paywall'da "13 ek oyun" yaziyor olmasina
      // ragmen ulasilamiyorlardi.
      GameModel(
        id: 'embedded_pattern_detective',
        title: 'Kod Dedektifi',
        description: 'Dizideki kuralı bul ve devamını getir. Örüntü tanıma, programcının en çok kullandığı beceri.',
        titleEn: 'Pattern Detective',
        descriptionEn: 'Find the rule in the sequence and continue it. Pattern recognition is a coder\'s core skill.',
        titleDe: 'Muster-Detektiv',
        descriptionDe: 'Finde die Regel in der Reihe und setz sie fort. Muster erkennen ist die wichtigste Fähigkeit beim Programmieren.',
        titleEs: 'Detective de patrones',
        descriptionEs: 'Encuentra la regla de la serie y continúala. Reconocer patrones es la destreza clave al programar.',
        category: GameCategory.age7to9,
        type: GameType.patternDetective,
        thumbnailUrl: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400',
        difficulty: 2,
        estimatedMinutes: 10,
        tags: ['örüntü', 'mantık', 'dikkat'],
        isActive: true,
        createdAt: now,
        gameData: {'levels': 15},
      ),

      // 14. DEGISKEN USTASI
      GameModel(
        id: 'embedded_variable_master',
        title: 'Değişken Ustası',
        description: 'Kutulara değer koy, değiştir, takas et. Değişken kavramını oynayarak ogren.',
        titleEn: 'Variable Master',
        descriptionEn: 'Put values in boxes, change them, swap them. Learn variables by playing.',
        titleDe: 'Variablen-Meister',
        descriptionDe: 'Leg Werte in Kisten, ändere sie, tausche sie. Lerne Variablen im Spiel.',
        titleEs: 'Maestro de variables',
        descriptionEs: 'Pon valores en cajas, cámbialos, intercámbialos. Aprende las variables jugando.',
        category: GameCategory.software,
        type: GameType.variableMaster,
        thumbnailUrl: 'https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=400',
        difficulty: 2,
        estimatedMinutes: 12,
        tags: ['değişken', 'temel kavram', 'mantık'],
        isActive: true,
        createdAt: now,
        gameData: {'levels': 12},
      ),

      // 15. HATA AVCISI
      GameModel(
        id: 'embedded_bug_hunter',
        title: 'Hata Avcısı',
        description: 'Çalışmayan kodu incele, bozuk satırı bul. Gerçek programcılık burada basliyor.',
        titleEn: 'Bug Hunter',
        descriptionEn: 'Inspect broken code and find the faulty line. This is where real programming starts.',
        titleDe: 'Fehlerjäger',
        descriptionDe: 'Untersuche den kaputten Code und finde die fehlerhafte Zeile. Hier fängt echtes Programmieren an.',
        titleEs: 'Cazador de errores',
        descriptionEs: 'Examina el código roto y encuentra la línea con el fallo. Aquí empieza la programación de verdad.',
        category: GameCategory.software,
        type: GameType.bugHunter,
        thumbnailUrl: 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=400',
        difficulty: 3,
        estimatedMinutes: 15,
        tags: ['hata ayıklama', 'debug', 'dikkat', 'kod okuma'],
        isActive: true,
        createdAt: now,
        gameData: {'levels': 15},
      ),

      // 16. ARDUINO DEVRE SIMULATORU
      GameModel(
        id: 'embedded_arduino_simulator',
        title: 'Arduino Atölyesi',
        description: 'mBlock bloklarıyla kodu kur, sanal kartta LED yansın, buzzer ötsün, servo dönsün. Aradaki görevlerde devredeki eksik parçayı bul.',
        titleEn: 'Arduino Workshop',
        descriptionEn: 'Build the code with mBlock blocks and watch the virtual board light up, buzz and turn. In between, find the missing part in the circuit.',
        titleDe: 'Arduino-Werkstatt',
        descriptionDe: 'Bau den Code mit mBlock-Blöcken und sieh zu, wie die virtuelle Platine leuchtet, summt und dreht. Dazwischen: finde das fehlende Teil in der Schaltung.',
        titleEs: 'Taller de Arduino',
        descriptionEs: 'Monta el código con bloques de mBlock y mira cómo la placa virtual se enciende, suena y gira. Entre medias, encuentra la pieza que falta en el circuito.',
        category: GameCategory.arduino,
        type: GameType.arduinoSimulator,
        thumbnailUrl: 'https://images.unsplash.com/photo-1553406830-ef2513450d76?w=400',
        difficulty: 3,
        estimatedMinutes: 20,
        tags: ['arduino', 'elektronik', 'devre', 'blok', 'robotik'],
        isActive: true,
        createdAt: now,
        gameData: {'components': ['led', 'buzzer', 'servo'], 'levels': 8},
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
