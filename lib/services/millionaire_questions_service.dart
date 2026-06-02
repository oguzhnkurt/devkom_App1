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
    ];
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
