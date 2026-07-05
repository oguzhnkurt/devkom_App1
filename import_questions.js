const admin = require('firebase-admin');
const serviceAccount = require('./firebase-adminsdk-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const questions = [
  {
    question: "Bir algoritma nedir?",
    options: ["Bir müzik aleti", "Bir problemi çözmek için adım adım yapılan işlemler", "Bir yemek tarifi", "Bir oyun"],
    correctAnswerIndex: 1,
    difficulty: 1,
    prize: 1000
  },
  {
    question: "Hangisi bir programlama dili değildir?",
    options: ["Python", "Java", "Microsoft Word", "C++"],
    correctAnswerIndex: 2,
    difficulty: 2,
    prize: 2000
  },
  {
    question: "Bir döngü (loop) ne işe yarar?",
    options: ["Bilgisayarı kapatır", "Aynı işlemi tekrar tekrar yapar", "Programı siler", "İnternete bağlanır"],
    correctAnswerIndex: 1,
    difficulty: 3,
    prize: 3000
  },
  {
    question: "IF-ELSE yapısı ne için kullanılır?",
    options: ["Karar verme için", "Dosya kaydetmek için", "Ekrana yazdırmak için", "Değişken tanımlamak için"],
    correctAnswerIndex: 0,
    difficulty: 4,
    prize: 5000
  },
  {
    question: "Hangisi bir veri tipi değildir?",
    options: ["Integer", "String", "Boolean", "Calculator"],
    correctAnswerIndex: 3,
    difficulty: 5,
    prize: 10000
  },
  {
    question: "Array (dizi) nedir?",
    options: ["Tek bir değer saklayan yapı", "Birden fazla değer saklayan yapı", "Sadece metin saklayan yapı", "Hiçbir şey saklamayan yapı"],
    correctAnswerIndex: 1,
    difficulty: 6,
    prize: 20000
  },
  {
    question: "Fonksiyon (Function) ne işe yarar?",
    options: ["Sadece toplama işlemi yapar", "Kodları gruplar ve tekrar kullanılabilir hale getirir", "Sadece ekrana yazı yazar", "Programı başlatır"],
    correctAnswerIndex: 1,
    difficulty: 7,
    prize: 40000
  },
  {
    question: "Binary sistemde 1010 sayısının ondalık karşılığı nedir?",
    options: ["8", "10", "12", "14"],
    correctAnswerIndex: 1,
    difficulty: 8,
    prize: 80000
  },
  {
    question: "Hangisi bir sıralama algoritması değildir?",
    options: ["Bubble Sort", "Quick Sort", "Binary Search", "Merge Sort"],
    correctAnswerIndex: 2,
    difficulty: 9,
    prize: 160000
  },
  {
    question: "Object Oriented Programming (OOP) prensiplerinden biri hangisidir?",
    options: ["Döngü", "Kapsülleme (Encapsulation)", "Değişken", "Array"],
    correctAnswerIndex: 1,
    difficulty: 10,
    prize: 320000
  },
  {
    question: "Recursion (Özyineleme) ne demektir?",
    options: ["Bir fonksiyonun kendisini çağırması", "Bir değişkenin değerinin artması", "Bir döngünün sonsuza kadar devam etmesi", "Bir programın baştan başlaması"],
    correctAnswerIndex: 0,
    difficulty: 11,
    prize: 640000
  },
  {
    question: "Stack veri yapısında hangi prensip geçerlidir?",
    options: ["FIFO", "LIFO", "LILO", "FILO"],
    correctAnswerIndex: 1,
    difficulty: 12,
    prize: 1250000
  },
  {
    question: "Big O notasyonu neyi ifade eder?",
    options: ["Programın boyutunu", "Algoritmanın karmaşıklığını", "Değişken sayısını", "Satır sayısını"],
    correctAnswerIndex: 1,
    difficulty: 13,
    prize: 2500000
  },
  {
    question: "Polymorphism (Çok biçimlilik) ne anlama gelir?",
    options: ["Aynı metodun farklı davranışlar sergilemesi", "Birden fazla sınıf oluşturma", "Değişken türü değiştirme", "Program dilini değiştirme"],
    correctAnswerIndex: 0,
    difficulty: 14,
    prize: 5000000
  },
  {
    question: "Turing Complete bir sistem ne demektir?",
    options: ["Sadece toplama işlemi yapabilen sistem", "Herhangi bir hesaplanabilir fonksiyonu çalıştırabilen sistem", "Sadece web sayfası gösterebilen sistem", "Sadece oyun oynatabilen sistem"],
    correctAnswerIndex: 1,
    difficulty: 15,
    prize: 10000000
  }
];

async function importQuestions() {
  try {
    console.log('Starting import...');
    const batch = db.batch();

    questions.forEach((question) => {
      const docRef = db.collection('millionaire_questions').doc();
      batch.set(docRef, question);
    });

    await batch.commit();
    console.log(`Successfully imported ${questions.length} questions!`);
    process.exit(0);
  } catch (error) {
    console.error('Error importing questions:', error);
    process.exit(1);
  }
}

importQuestions();
