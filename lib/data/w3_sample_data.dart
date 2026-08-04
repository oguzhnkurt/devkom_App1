/// Sample data for W3Schools-style courses
library;

import '../models/w3_lesson_model.dart';

class W3SampleData {
  static List<W3Course> get allCourses => [
        pythonForKids,
        pythonForTeens,
        htmlForAll,
      ];

  /// Python course for kids (age 6-12)
  static final W3Course pythonForKids = W3Course(
    id: 'python_kids',
    title: 'Python - Başlangıç',
    description: 'Python\'a eğlenceli örneklerle başla! Oyunlar yap, hikayeler anlat.',
    icon: '🐍',
    color: '#3776AB',
    tags: ['Python', 'Başlangıç', 'Eğlenceli'],
    ageMin: 6,
    ageMax: 12,
    totalLessons: 7,
    estimatedHours: 3,
    chapters: [
      W3Chapter(
        id: 'ch1_intro',
        title: 'Python ile Tanışma',
        emoji: '👋',
        lessons: [
          _pythonKidsLesson1,
          _pythonKidsLesson2,
          _pythonKidsLesson3,
        ],
      ),
      W3Chapter(
        id: 'ch2_variables',
        title: 'Değişkenler ve Sayılar',
        emoji: '🔢',
        lessons: [
          _pythonKidsLesson4,
          _pythonKidsLesson5,
          _pythonKidsLesson6,
          _pythonKidsLesson7,
        ],
      ),
    ],
  );

  /// Lesson 1: İlk Python Programın
  static final W3Lesson _pythonKidsLesson1 = W3Lesson(
    id: 'pk_l1',
    title: 'Merhaba Dünya!',
    shortDescription: 'İlk Python programını yaz ve çalıştır',
    estimatedMinutes: 15,
    difficulty: 'Kolay',
    contents: [
      W3Content.text(
        'Python bir programlama dilidir. Tıpkı Türkçe veya İngilizce gibi! Ama Python bilgisayarlarla konuşmak için kullanılır.',
        title: 'Python Nedir?',
      ),
      W3Content.text(
        'Python ile oyunlar yapabilir, resimler çizebilir, hesaplamalar yapabilirsin. Hadi ilk programımızı yazalım!',
      ),
      W3Content.code(
        code: 'print("Merhaba Dünya!")',
        language: 'python',
        output: 'Merhaba Dünya!',
      ),
      W3Content.tip(
        'print() komutu ekrana yazı yazmak için kullanılır. Tırnaklar içindeki her şey aynen ekrana yazılır!',
      ),
      W3Content.code(
        code: 'print("Benim adım Ali")\nprint("Python öğreniyorum!")',
        language: 'python',
        output: 'Benim adım Ali\nPython öğreniyorum!',
      ),
      W3Content.text(
        'Gördün mü? İki satır yazdık, iki şey ekrana geldi. Şimdi sen dene!',
      ),
    ],
    quiz: W3Quiz(
      id: 'pk_l1_quiz',
      title: 'Merhaba Dünya Quiz',
      questions: [
        W3Question(
          id: 'q1',
          type: W3QuestionType.multipleChoice,
          question: 'Ekrana "Merhaba" yazmak için hangi komutu kullanırız?',
          options: ['print()', 'write()', 'show()', 'say()'],
          correctAnswer: 'print()',
          explanation: 'print() komutu Python\'da ekrana yazı yazmak için kullanılır.',
        ),
        W3Question(
          id: 'q2',
          type: W3QuestionType.codeOutput,
          question: 'Bu kod ne yazdırır?',
          code: 'print("Python eğlenceli!")',
          options: ['Python eğlenceli!', 'print', 'Hata verir', 'Hiçbir şey'],
          correctAnswer: 'Python eğlenceli!',
          explanation: 'print() tırnaklar içindeki yazıyı aynen ekrana yazar.',
        ),
        W3Question(
          id: 'q3',
          type: W3QuestionType.trueFalse,
          question: 'Python bir programlama dilidir.',
          options: ['Doğru', 'Yanlış'],
          correctAnswer: 'Doğru',
          explanation: 'Evet! Python güçlü bir programlama dilidir.',
        ),
        W3Question(
          id: 'q4',
          type: W3QuestionType.multipleChoice,
          question: 'Yazıları tırnaklar içine yazmak neden önemlidir?',
          options: [
            'Yazının başını ve sonunu gösterir',
            'Daha güzel görünür',
            'Zorunlu değil',
            'Bilgisayar böyle ister'
          ],
          correctAnswer: 'Yazının başını ve sonunu gösterir',
          explanation: 'Tırnaklar Python\'a "bu bir yazıdır" der.',
        ),
        W3Question(
          id: 'q5',
          type: W3QuestionType.findError,
          question: 'Bu kodda hata var mı?',
          code: 'print(Merhaba)',
          options: ['Evet, tırnak işareti eksik', 'Hayır, doğru', 'print yanlış yazılmış', 'Parantez eksik'],
          correctAnswer: 'Evet, tırnak işareti eksik',
          explanation: 'Merhaba kelimesi tırnaklar içinde olmalı: print("Merhaba")',
        ),
      ],
    ),
  );

  /// Lesson 2: Sayılarla Oynamak
  static final W3Lesson _pythonKidsLesson2 = W3Lesson(
    id: 'pk_l2',
    title: 'Sayılarla Oynamak',
    shortDescription: 'Python ile matematik yap!',
    estimatedMinutes: 20,
    difficulty: 'Kolay',
    contents: [
      W3Content.text(
        'Python harika bir hesap makinesidir! Toplama, çıkarma, çarpma ve bölme yapabilir.',
        title: 'Python Hesap Makinesi',
      ),
      W3Content.code(
        code: 'print(5 + 3)',
        language: 'python',
        output: '8',
      ),
      W3Content.code(
        code: 'print(10 - 4)\nprint(6 * 7)\nprint(20 / 5)',
        language: 'python',
        output: '6\n42\n4.0',
      ),
      W3Content.tip(
        '+ toplama, - çıkarma, * çarpma, / bölme için kullanılır. Tıpkı matematik dersindeki gibi!',
      ),
      W3Content.text(
        'Büyük hesaplamalar da yapabilirsin:',
      ),
      W3Content.code(
        code: 'print(100 + 50 - 25)\nprint((10 + 5) * 2)',
        language: 'python',
        output: '125\n30',
      ),
      W3Content.warning(
        'Parantezleri unutma! Parantez içindekiler önce hesaplanır, matematik kuralları gibi.',
      ),
    ],
    quiz: W3Quiz(
      id: 'pk_l2_quiz',
      title: 'Sayılar Quiz',
      questions: [
        W3Question(
          id: 'q1',
          type: W3QuestionType.codeOutput,
          question: 'Bu kod ne yazdırır?',
          code: 'print(15 + 10)',
          options: ['25', '1510', '15 + 10', 'Hata'],
          correctAnswer: '25',
          explanation: '15 + 10 = 25',
        ),
        W3Question(
          id: 'q2',
          type: W3QuestionType.multipleChoice,
          question: 'Çarpma işlemi için hangi sembol kullanılır?',
          options: ['*', 'x', '+', '/'],
          correctAnswer: '*',
          explanation: '* sembolü çarpma için kullanılır.',
        ),
        W3Question(
          id: 'q3',
          type: W3QuestionType.codeOutput,
          question: 'print(20 / 4) ne yazdırır?',
          options: ['5.0', '5', '20/4', '16'],
          correctAnswer: '5.0',
          explanation: 'Bölme işlemi sonucu ondalıklı sayı olur.',
        ),
        W3Question(
          id: 'q4',
          type: W3QuestionType.codeOutput,
          question: 'print((2 + 3) * 4) ne sonuç verir?',
          options: ['20', '14', '11', '9'],
          correctAnswer: '20',
          explanation: 'Önce parantez içi: 2+3=5, sonra 5*4=20',
        ),
        W3Question(
          id: 'q5',
          type: W3QuestionType.trueFalse,
          question: 'Python sadece toplama ve çıkarma yapabilir.',
          options: ['Doğru', 'Yanlış'],
          correctAnswer: 'Yanlış',
          explanation: 'Python tüm matematik işlemlerini yapabilir!',
        ),
      ],
    ),
  );

  /// Lesson 3: Renkli Yazılar
  static final W3Lesson _pythonKidsLesson3 = W3Lesson(
    id: 'pk_l3',
    title: 'İsimler ve Kelimeler',
    shortDescription: 'Yazılarla eğlen, birleştir!',
    estimatedMinutes: 18,
    difficulty: 'Kolay',
    contents: [
      W3Content.text(
        'Python ile yazıları birleştirebilir, tekrarlayabilirsin. Hadi deneyelim!',
        title: 'Yazılarla Sihir',
      ),
      W3Content.code(
        code: 'print("Merhaba" + " Dünya")',
        language: 'python',
        output: 'Merhaba Dünya',
      ),
      W3Content.tip(
        '+ işareti sayıları toplar, ama yazıları birleştirir!',
      ),
      W3Content.code(
        code: 'print("Ha" * 5)',
        language: 'python',
        output: 'HaHaHaHaHa',
      ),
      W3Content.text(
        'Bak ne kadar eğlenceli! * ile yazıyı tekrarlayabiliyoruz.',
      ),
      W3Content.code(
        code: 'print("Merhaba " + "Ali")\nprint("Python " * 3)',
        language: 'python',
        output: 'Merhaba Ali\nPython Python Python ',
      ),
    ],
    quiz: W3Quiz(
      id: 'pk_l3_quiz',
      title: 'Yazılar Quiz',
      questions: [
        W3Question(
          id: 'q1',
          type: W3QuestionType.codeOutput,
          question: 'print("Ho" * 3) ne yazdırır?',
          options: ['HoHoHo', 'Ho3', 'Ho * 3', 'Hata'],
          correctAnswer: 'HoHoHo',
          explanation: '* ile yazı tekrarlanır.',
        ),
        W3Question(
          id: 'q2',
          type: W3QuestionType.codeOutput,
          question: 'print("Ben " + "Ali") ne yazdırır?',
          options: ['Ben Ali', 'BenAli', 'Ben + Ali', 'Hata'],
          correctAnswer: 'Ben Ali',
          explanation: '+ ile yazılar birleştirilir.',
        ),
        W3Question(
          id: 'q3',
          type: W3QuestionType.multipleChoice,
          question: 'Yazıları birleştirmek için ne kullanırız?',
          options: ['+', '-', '*', '/'],
          correctAnswer: '+',
          explanation: '+ sembolü yazıları birleştirir.',
        ),
        W3Question(
          id: 'q4',
          type: W3QuestionType.codeOutput,
          question: 'print("Alo" + "Alo") sonucu nedir?',
          options: ['AloAlo', 'Alo Alo', 'Alo', 'Alo+Alo'],
          correctAnswer: 'AloAlo',
          explanation: 'Yazılar araya boşluk konmadan birleşir.',
        ),
        W3Question(
          id: 'q5',
          type: W3QuestionType.trueFalse,
          question: 'Yazıları * ile tekrarlayabiliriz.',
          options: ['Doğru', 'Yanlış'],
          correctAnswer: 'Doğru',
          explanation: 'Evet! "Ha" * 3 = "HaHaHa" yapar.',
        ),
      ],
    ),
  );

  /// Lesson 4: Değişken Kutuları
  static final W3Lesson _pythonKidsLesson4 = W3Lesson(
    id: 'pk_l4',
    title: 'Değişken Kutuları',
    shortDescription: 'Bilgileri sakla ve kullan',
    estimatedMinutes: 25,
    difficulty: 'Orta',
    contents: [
      W3Content.text(
        'Değişkenler bilgi saklayan kutular gibidir. İçine bir şey koyar, sonra kullanırsın!',
        title: 'Değişkenler Nedir?',
      ),
      W3Content.code(
        code: 'isim = "Ayşe"\nprint(isim)',
        language: 'python',
        output: 'Ayşe',
      ),
      W3Content.text(
        'Gördün mü? "Ayşe" yazısını isim kutusuna koyduk. Sonra yazdırdık.',
      ),
      W3Content.code(
        code: 'yas = 10\nprint("Benim yaşım:")\nprint(yas)',
        language: 'python',
        output: 'Benim yaşım:\n10',
      ),
      W3Content.tip(
        'Değişken isimleri türkçe karakter içermemeli. İngilizce harfler kullan!',
      ),
      W3Content.code(
        code: 'ad = "Mehmet"\nsoyad = "Yılmaz"\ntam_ad = ad + " " + soyad\nprint(tam_ad)',
        language: 'python',
        output: 'Mehmet Yılmaz',
      ),
      W3Content.warning(
        'Değişken ismi boşluk içeremez. "benim_yasim" olabilir ama "benim yasim" olmaz!',
      ),
    ],
    quiz: W3Quiz(
      id: 'pk_l4_quiz',
      title: 'Değişkenler Quiz',
      questions: [
        W3Question(
          id: 'q1',
          type: W3QuestionType.codeOutput,
          question: 'Bu kod ne yazdırır?',
          code: 'x = 5\nprint(x)',
          options: ['5', 'x', 'x = 5', 'Hata'],
          correctAnswer: '5',
          explanation: 'x değişkeninin değeri 5\'tir.',
        ),
        W3Question(
          id: 'q2',
          type: W3QuestionType.multipleChoice,
          question: 'Değişkenlere değer vermek için hangi sembol kullanılır?',
          options: ['=', ':', '+', '-'],
          correctAnswer: '=',
          explanation: '= sembolü değişkene değer atar.',
        ),
        W3Question(
          id: 'q3',
          type: W3QuestionType.findError,
          question: 'Bu kodda hata var mı?',
          code: 'benim yaşım = 10',
          options: ['Evet, boşluk olamaz', 'Hayır, doğru', 'Türkçe karakter var', 'Sayı yanlış'],
          correctAnswer: 'Evet, boşluk olamaz',
          explanation: 'Değişken isimleri boşluk içeremez.',
        ),
        W3Question(
          id: 'q4',
          type: W3QuestionType.codeOutput,
          question: 'Sonuç ne olur?',
          code: 'a = "Merhaba"\nb = "Dünya"\nprint(a + " " + b)',
          options: ['Merhaba Dünya', 'MerhabaDünya', 'a b', 'Hata'],
          correctAnswer: 'Merhaba Dünya',
          explanation: 'Değişkenler birleştirilerek yazılır.',
        ),
        W3Question(
          id: 'q5',
          type: W3QuestionType.trueFalse,
          question: 'Bir değişkene sadece bir kez değer atayabiliriz.',
          options: ['Doğru', 'Yanlış'],
          correctAnswer: 'Yanlış',
          explanation: 'Değişkenin değeri değiştirilebilir!',
        ),
      ],
    ),
  );

  /// Lessons 5-7 (simplified versions)
  static final W3Lesson _pythonKidsLesson5 = W3Lesson(
    id: 'pk_l5',
    title: 'Sayılarla Oynama Zamanı',
    shortDescription: 'Değişkenlerde sayıları sakla',
    estimatedMinutes: 20,
    difficulty: 'Orta',
    contents: [
      W3Content.text('Değişkenlere sayılar da koyabiliriz!', title: 'Sayı Kutuları'),
      W3Content.code(code: 'elma = 5\narmut = 3\ntoplam = elma + armut\nprint(toplam)', language: 'python', output: '8'),
    ],
    quiz: W3Quiz(id: 'pk_l5_quiz', title: 'Quiz', questions: [
      W3Question(id: 'q1', type: W3QuestionType.multipleChoice, question: 'Test', options: ['A', 'B'], correctAnswer: 'A', explanation: 'Test'),
    ]),
  );

  static final W3Lesson _pythonKidsLesson6 = W3Lesson(
    id: 'pk_l6',
    title: 'Kullanıcıdan Bilgi Al',
    shortDescription: 'input() ile soru sor',
    estimatedMinutes: 22,
    difficulty: 'Orta',
    contents: [
      W3Content.text('input() komutu kullanıcıya soru sorar!', title: 'Soru Sorma'),
      W3Content.code(code: 'isim = input("Adın ne? ")\nprint("Merhaba " + isim)', language: 'python', output: 'Adın ne? (kullanıcı yazar)\nMerhaba (girilen isim)'),
    ],
    quiz: W3Quiz(id: 'pk_l6_quiz', title: 'Quiz', questions: [
      W3Question(id: 'q1', type: W3QuestionType.multipleChoice, question: 'Test', options: ['A', 'B'], correctAnswer: 'A', explanation: 'Test'),
    ]),
  );

  static final W3Lesson _pythonKidsLesson7 = W3Lesson(
    id: 'pk_l7',
    title: 'Mini Proje: Selamlaşma',
    shortDescription: 'Öğrendiklerini birleştir',
    estimatedMinutes: 30,
    difficulty: 'Orta',
    contents: [
      W3Content.text('Şimdi bir program yapalım!', title: 'İlk Projen'),
      W3Content.code(
        code: 'ad = input("Adın: ")\nyas = input("Yaşın: ")\nprint("Merhaba " + ad + "!")\nprint("Sen " + yas + " yaşındasın.")',
        language: 'python',
        output: 'Adın: Ali\nYaşın: 10\nMerhaba Ali!\nSen 10 yaşındasın.',
      ),
    ],
    quiz: W3Quiz(id: 'pk_l7_quiz', title: 'Quiz', questions: [
      W3Question(id: 'q1', type: W3QuestionType.multipleChoice, question: 'Test', options: ['A', 'B'], correctAnswer: 'A', explanation: 'Test'),
    ]),
  );

  /// Python for Teens (age 13-17) - More advanced
  static final W3Course pythonForTeens = W3Course(
    id: 'python_teens',
    title: 'Python - Gençler İçin',
    description: 'Gerçek projeler yap! Oyunlar, uygulamalar, veri analizi.',
    icon: '🚀',
    color: '#FFD43B',
    tags: ['Python', 'Orta Seviye', 'Gençler'],
    ageMin: 13,
    ageMax: 17,
    totalLessons: 8,
    estimatedHours: 5,
    chapters: [
      W3Chapter(
        id: 'teen_ch1',
        title: 'Python Temelleri',
        emoji: '📚',
        lessons: [
          W3Lesson(
            id: 'teen_l1',
            title: 'Veri Tipleri ve Dönüşümler',
            shortDescription: 'String, int, float - hepsini öğren',
            estimatedMinutes: 25,
            difficulty: 'Orta',
            contents: [
              W3Content.text('Python\'da farklı veri tipleri var. Her birinin özellikleri farklı!', title: 'Veri Tipleri'),
              W3Content.code(code: 'x = 5        # int\ny = 3.14     # float\nz = "Merhaba"  # string\nprint(type(x))\nprint(type(y))\nprint(type(z))', language: 'python', output: '<class \'int\'>\n<class \'float\'>\n<class \'str\'>'),
            ],
            quiz: W3Quiz(id: 'teen_l1_quiz', title: 'Quiz', questions: [
              W3Question(id: 'q1', type: W3QuestionType.multipleChoice, question: 'Test', options: ['A', 'B'], correctAnswer: 'A', explanation: 'Test'),
            ]),
          ),
        ],
      ),
    ],
  );

  /// HTML course for all ages
  static final W3Course htmlForAll = W3Course(
    id: 'html_all',
    title: 'HTML - Web Sitesi Yap',
    description: 'Kendi web siteni oluştur! Renkli sayfalar, resimler, linkler.',
    icon: '🌐',
    color: '#E34F26',
    tags: ['HTML', 'Web', 'Başlangıç'],
    ageMin: 8,
    ageMax: 99,
    totalLessons: 6,
    estimatedHours: 2,
    chapters: [
      W3Chapter(
        id: 'html_ch1',
        title: 'HTML\'e Başlangıç',
        emoji: '🏁',
        lessons: [
          W3Lesson(
            id: 'html_l1',
            title: 'İlk Web Sayfan',
            shortDescription: 'HTML nedir? Nasıl çalışır?',
            estimatedMinutes: 20,
            difficulty: 'Kolay',
            contents: [
              W3Content.text('HTML web sayfalarının iskeletidir. Her web sitesi HTML ile yapılır!', title: 'HTML Nedir?'),
              W3Content.code(
                code: '<!DOCTYPE html>\n<html>\n<head>\n  <title>Benim Sayfam</title>\n</head>\n<body>\n  <h1>Merhaba Dünya!</h1>\n  <p>Bu benim ilk web sayfam.</p>\n</body>\n</html>',
                language: 'html',
                output: 'Tarayıcıda: Büyük başlık "Merhaba Dünya!" ve altında bir paragraf görünür.',
              ),
              W3Content.tip('HTML etiketleri < > işaretleri arasında yazılır. Çoğu etiketin bir açılış <tag> ve kapanış </tag> kısmı vardır.'),
            ],
            quiz: W3Quiz(id: 'html_l1_quiz', title: 'Quiz', questions: [
              W3Question(
                id: 'q1',
                type: W3QuestionType.multipleChoice,
                question: 'HTML neyin kısaltmasıdır?',
                options: ['HyperText Markup Language', 'High Tech Modern Language', 'Home Tool Markup Language', 'Hyperlinks and Text Markup Language'],
                correctAnswer: 'HyperText Markup Language',
                explanation: 'HTML = HyperText Markup Language',
              ),
            ]),
          ),
        ],
      ),
    ],
  );
}
