import '../models/millionaire_question.dart';

class MillionaireQuestionsService {
  static List<MillionaireQuestion> getQuestions() {
    // Para ağacı: 1000, 2000, 3000, 5000, 10000, 20000, 30000, 50000, 100000, 250000, 500000, 1000000
    return [
      // Seviye 1 - 1000 TL
      MillionaireQuestion(
        question: 'Bir algoritma nedir?',
        options: [
          'Bir müzik aleti',
          'Bir problemi çözmek için adım adım yapılan işlemler',
          'Bir yemek tarifi',
          'Bir oyun'
        ],
        correctAnswerIndex: 1,
        difficulty: 1,
        prize: 1000,
      ),

      // Seviye 2 - 2000 TL
      MillionaireQuestion(
        question: 'Hangisi bir programlama dili değildir?',
        options: ['Python', 'Java', 'Microsoft Word', 'C++'],
        correctAnswerIndex: 2,
        difficulty: 2,
        prize: 2000,
      ),

      // Seviye 3 - 3000 TL
      MillionaireQuestion(
        question: 'Bir döngü (loop) ne işe yarar?',
        options: [
          'Bilgisayarı kapatır',
          'Aynı işlemi tekrar tekrar yapar',
          'Programı siler',
          'İnternete bağlanır'
        ],
        correctAnswerIndex: 1,
        difficulty: 3,
        prize: 3000,
      ),

      // Seviye 4 - 5000 TL
      MillionaireQuestion(
        question: 'IF-ELSE yapısı ne için kullanılır?',
        options: [
          'Karar verme için',
          'Dosya kaydetmek için',
          'Ekrana yazdırmak için',
          'Değişken tanımlamak için'
        ],
        correctAnswerIndex: 0,
        difficulty: 4,
        prize: 5000,
      ),

      // Seviye 5 - 10000 TL
      MillionaireQuestion(
        question: 'Hangisi bir veri tipi değildir?',
        options: ['Integer', 'String', 'Boolean', 'Calculator'],
        correctAnswerIndex: 3,
        difficulty: 5,
        prize: 10000,
      ),

      // Seviye 6 - 20000 TL
      MillionaireQuestion(
        question: 'Array (dizi) nedir?',
        options: [
          'Tek bir değer saklayan yapı',
          'Birden fazla değer saklayan yapı',
          'Sadece metin saklayan yapı',
          'Hiçbir şey saklamayan yapı'
        ],
        correctAnswerIndex: 1,
        difficulty: 6,
        prize: 20000,
      ),

      // Seviye 7 - 30000 TL
      MillionaireQuestion(
        question: 'Fonksiyon (Function) ne işe yarar?',
        options: [
          'Sadece toplama işlemi yapar',
          'Kodları gruplar ve tekrar kullanılabilir hale getirir',
          'Sadece ekrana yazı yazar',
          'Programı başlatır'
        ],
        correctAnswerIndex: 1,
        difficulty: 7,
        prize: 30000,
      ),

      // Seviye 8 - 50000 TL
      MillionaireQuestion(
        question: 'Binary sistemde 1010 sayısının ondalık karşılığı nedir?',
        options: ['8', '10', '12', '14'],
        correctAnswerIndex: 1,
        difficulty: 8,
        prize: 50000,
      ),

      // Seviye 9 - 100000 TL
      MillionaireQuestion(
        question: 'Hangisi bir sıralama algoritması değildir?',
        options: ['Bubble Sort', 'Quick Sort', 'Binary Search', 'Merge Sort'],
        correctAnswerIndex: 2,
        difficulty: 9,
        prize: 100000,
      ),

      // Seviye 10 - 250000 TL
      MillionaireQuestion(
        question: 'Object Oriented Programming (OOP) prensiplerinden biri hangisidir?',
        options: ['Döngü', 'Kapsülleme (Encapsulation)', 'Değişken', 'Array'],
        correctAnswerIndex: 1,
        difficulty: 10,
        prize: 250000,
      ),

      // Seviye 11 - 500000 TL
      MillionaireQuestion(
        question: 'Recursion (Özyineleme) ne demektir?',
        options: [
          'Bir fonksiyonun kendisini çağırması',
          'Bir değişkenin değerinin artması',
          'Bir döngünün sonsuza kadar devam etmesi',
          'Bir programın baştan başlaması'
        ],
        correctAnswerIndex: 0,
        difficulty: 11,
        prize: 500000,
      ),

      // Seviye 12 - 1.000.000 TL
      MillionaireQuestion(
        question: 'Turing Complete bir sistem ne demektir?',
        options: [
          'Sadece toplama işlemi yapabilen sistem',
          'Herhangi bir hesaplanabilir fonksiyonu çalıştırabilen sistem',
          'Sadece web sayfası gösterebilen sistem',
          'Sadece oyun oynatabilen sistem'
        ],
        correctAnswerIndex: 1,
        difficulty: 12,
        prize: 1000000,
      ),

      // ============ EK SORULAR (her seviye için alternatifler) ============

      // Seviye 1 - 1000 TL
      MillionaireQuestion(
        question: 'Bilgisayara ne yapacağını söyleyen komut dizisine ne denir?',
        options: ['Program', 'Klavye', 'Ekran', 'Hoparlör'],
        correctAnswerIndex: 0,
        difficulty: 1,
        prize: 1000,
      ),
      MillionaireQuestion(
        question: 'Scratch\'te kod yazmak için ne kullanılır?',
        options: ['Renkli bloklar', 'Kalem ve kağıt', 'Ses komutları', 'Fotoğraflar'],
        correctAnswerIndex: 0,
        difficulty: 1,
        prize: 1000,
      ),

      // Seviye 2 - 2000 TL
      MillionaireQuestion(
        question: 'Python programlama dilinin sembolü hangi hayvandır?',
        options: ['Kedi', 'Yılan', 'Köpek', 'Fil'],
        correctAnswerIndex: 1,
        difficulty: 2,
        prize: 2000,
      ),
      MillionaireQuestion(
        question: 'Hangisi bir çıktı (output) cihazıdır?',
        options: ['Klavye', 'Fare', 'Monitör', 'Mikrofon'],
        correctAnswerIndex: 2,
        difficulty: 2,
        prize: 2000,
      ),

      // Seviye 3 - 3000 TL
      MillionaireQuestion(
        question: 'Python\'da ekrana yazı yazdırmak için hangi komut kullanılır?',
        options: ['write()', 'print()', 'show()', 'display()'],
        correctAnswerIndex: 1,
        difficulty: 3,
        prize: 3000,
      ),
      MillionaireQuestion(
        question: 'Arduino ile hangisini yapabilirsin?',
        options: ['LED yakmak', 'Yemek pişirmek', 'Çamaşır yıkamak', 'Uçmak'],
        correctAnswerIndex: 0,
        difficulty: 3,
        prize: 3000,
      ),

      // Seviye 4 - 5000 TL
      MillionaireQuestion(
        question: 'Değişken (variable) ne işe yarar?',
        options: [
          'Veri saklamak için',
          'Bilgisayarı hızlandırmak için',
          'Ekranı temizlemek için',
          'İnternete bağlanmak için'
        ],
        correctAnswerIndex: 0,
        difficulty: 4,
        prize: 5000,
      ),
      MillionaireQuestion(
        question: 'Bir programdaki hataya ne ad verilir?',
        options: ['Bug', 'Virus', 'Spam', 'Cookie'],
        correctAnswerIndex: 0,
        difficulty: 4,
        prize: 5000,
      ),

      // Seviye 5 - 10000 TL
      MillionaireQuestion(
        question: 'HTML ne için kullanılır?',
        options: [
          'Web sayfası yapısı oluşturmak',
          'Robot programlamak',
          'Oyun motoru yazmak',
          'Veritabanı yönetmek'
        ],
        correctAnswerIndex: 0,
        difficulty: 5,
        prize: 10000,
      ),
      MillionaireQuestion(
        question: 'Python\'da "5" + "3" işleminin sonucu nedir?',
        options: ['8', '53', 'Hata verir', '15'],
        correctAnswerIndex: 1,
        difficulty: 5,
        prize: 10000,
      ),

      // Seviye 6 - 20000 TL
      MillionaireQuestion(
        question: 'CSS ne işe yarar?',
        options: [
          'Web sayfasına stil ve tasarım verir',
          'Veritabanı oluşturur',
          'Oyun karakteri çizer',
          'E-posta gönderir'
        ],
        correctAnswerIndex: 0,
        difficulty: 6,
        prize: 20000,
      ),
      MillionaireQuestion(
        question: 'Arduino\'da analog pinler hangi değer aralığını okur?',
        options: ['0-1', '0-100', '0-1023', '0-9999'],
        correctAnswerIndex: 2,
        difficulty: 6,
        prize: 20000,
      ),

      // Seviye 7 - 30000 TL
      MillionaireQuestion(
        question: 'Python\'da bir listenin uzunluğunu hangi fonksiyon verir?',
        options: ['size()', 'count()', 'len()', 'length()'],
        correctAnswerIndex: 2,
        difficulty: 7,
        prize: 30000,
      ),
      MillionaireQuestion(
        question: 'Sonsuz döngü (infinite loop) nedir?',
        options: [
          'Hiç çalışmayan döngü',
          'Bitiş koşulu sağlanmadığı için hiç durmayan döngü',
          'Sadece bir kez çalışan döngü',
          'Geriye doğru sayan döngü'
        ],
        correctAnswerIndex: 1,
        difficulty: 7,
        prize: 30000,
      ),

      // Seviye 8 - 50000 TL
      MillionaireQuestion(
        question: 'Binary sistemde 1111 sayısının ondalık karşılığı nedir?',
        options: ['15', '11', '16', '31'],
        correctAnswerIndex: 0,
        difficulty: 8,
        prize: 50000,
      ),
      MillionaireQuestion(
        question: 'RAM\'in görevi nedir?',
        options: [
          'Verileri kalıcı olarak saklar',
          'Çalışan programların geçici verilerini tutar',
          'Ekrana görüntü verir',
          'İnternete bağlanır'
        ],
        correctAnswerIndex: 1,
        difficulty: 8,
        prize: 50000,
      ),

      // Seviye 9 - 100000 TL
      MillionaireQuestion(
        question: 'Binary Search algoritması nasıl çalışır?',
        options: [
          'Tüm elemanları tek tek kontrol eder',
          'Sıralı listeyi her adımda ikiye bölerek arar',
          'Rastgele eleman seçer',
          'Listeyi ters çevirir'
        ],
        correctAnswerIndex: 1,
        difficulty: 9,
        prize: 100000,
      ),
      MillionaireQuestion(
        question: 'Git nedir?',
        options: [
          'Bir oyun motoru',
          'Bir versiyon kontrol sistemi',
          'Bir web tarayıcısı',
          'Bir işletim sistemi'
        ],
        correctAnswerIndex: 1,
        difficulty: 9,
        prize: 100000,
      ),

      // Seviye 10 - 250000 TL
      MillionaireQuestion(
        question: 'OOP\'de "kalıtım" (inheritance) ne anlama gelir?',
        options: [
          'Bir sınıfın başka bir sınıfın özelliklerini devralması',
          'Değişkenlerin silinmesi',
          'Kodun şifrelenmesi',
          'Programın iki kez çalışması'
        ],
        correctAnswerIndex: 0,
        difficulty: 10,
        prize: 250000,
      ),
      MillionaireQuestion(
        question: 'HTTP ve HTTPS arasındaki temel fark nedir?',
        options: [
          'HTTPS şifreli iletişim kullanır',
          'HTTP daha yenidir',
          'HTTPS sadece video gösterir',
          'Aralarında fark yoktur'
        ],
        correctAnswerIndex: 0,
        difficulty: 10,
        prize: 250000,
      ),

      // Seviye 11 - 500000 TL
      MillionaireQuestion(
        question: 'Big-O notasyonu neyi ifade eder?',
        options: [
          'Algoritmanın karmaşıklığını (performansını)',
          'Programın dosya boyutunu',
          'Ekran çözünürlüğünü',
          'İnternet hızını'
        ],
        correctAnswerIndex: 0,
        difficulty: 11,
        prize: 500000,
      ),
      MillionaireQuestion(
        question: 'Stack (yığın) veri yapısı hangi prensiple çalışır?',
        options: [
          'FIFO - İlk giren ilk çıkar',
          'LIFO - Son giren ilk çıkar',
          'Rastgele erişim',
          'Alfabetik sıralama'
        ],
        correctAnswerIndex: 1,
        difficulty: 11,
        prize: 500000,
      ),

      // Seviye 12 - 1.000.000 TL
      MillionaireQuestion(
        question: 'Halting Problem (Durma Problemi) neden önemlidir?',
        options: [
          'Her programın durup durmayacağını belirleyen genel bir algoritmanın olamayacağını kanıtlar',
          'Bilgisayarların ne zaman kapanacağını hesaplar',
          'İnternet hızını ölçer',
          'Pil ömrünü uzatır'
        ],
        correctAnswerIndex: 0,
        difficulty: 12,
        prize: 1000000,
      ),
      MillionaireQuestion(
        question: 'Kuantum bilgisayarlarda bilginin temel birimi nedir?',
        options: ['Bit', 'Byte', 'Qubit', 'Pixel'],
        correctAnswerIndex: 2,
        difficulty: 12,
        prize: 1000000,
      ),
    ];
  }

  /// Oyun için soru seti: her seviyeden rastgele 1 soru, seviye sırasına göre
  static List<MillionaireQuestion> getGameQuestions() {
    final all = getQuestions();
    final byDifficulty = <int, List<MillionaireQuestion>>{};
    for (final q in all) {
      byDifficulty.putIfAbsent(q.difficulty, () => []).add(q);
    }
    final result = <MillionaireQuestion>[];
    final levels = byDifficulty.keys.toList()..sort();
    for (final level in levels) {
      final pool = byDifficulty[level]!..shuffle();
      result.add(pool.first);
    }
    return result;
  }

  static List<int> getPrizeTree() {
    return [
      1000,
      2000,
      3000,
      5000,
      10000,
      20000,
      30000,
      50000,
      100000,
      250000,
      500000,
      1000000,
    ];
  }

  static String formatPrize(int prize) {
    if (prize >= 1000000) {
      return '${(prize / 1000000).toStringAsFixed(prize % 1000000 == 0 ? 0 : 3)} Milyon ₺';
    } else if (prize >= 1000) {
      return '${(prize / 1000).toStringAsFixed(prize % 1000 == 0 ? 0 : 3)} Bin ₺';
    } else {
      return '$prize ₺';
    }
  }
}
