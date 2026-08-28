import '../models/course_model.dart';

/// Quiz data for all courses
class QuizzesData {
  static Quiz? getQuizForLesson(String lessonId) {
    return _quizzes[lessonId];
  }

  /// Tüm quizler (Quiz Merkezi kategorileri için) — read-only.
  static Map<String, Quiz> get all => Map.unmodifiable(_quizzes);

  static final Map<String, Quiz> _quizzes = {
    // HTML Quizzes
    'html_01': Quiz(
      id: 'quiz_html_1',
      lessonId: 'html_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'HTML ne anlama gelir?',
          type: QuestionType.multipleChoice,
          options: [
            'Hyper Text Markup Language',
            'High Tech Modern Language',
            'Home Tool Markup Language',
            'Hyperlinks and Text Markup Language',
          ],
          correctAnswer: 0,
          explanation: 'HTML, HyperText Markup Language anlamina gelir ve web sayfalarinin temel yapi tasini olusturur.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'HTML bir programlama dilidir.',
          type: QuestionType.trueFalse,
          correctAnswer: false,
          explanation: 'HTML bir isaret (markup) dilidir, programlama dili degildir. Mantiksal islemler yapamaz.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'Asagidaki kodun ciktisi ne olur?\n<h1>Merhaba</h1>',
          type: QuestionType.codeOutput,
          options: [
            'Buyuk baslik olarak "Merhaba" yazar',
            'Kucuk yazi olarak "Merhaba" yazar',
            'Hata verir',
            '<h1>Merhaba</h1> olarak gosterir',
          ],
          correctAnswer: 0,
          explanation: '<h1> etiketi en buyuk baslik etiketidir.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    'html_02': Quiz(
      id: 'quiz_html_2',
      lessonId: 'html_02',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'HTML dosyalarinin uzantisi nedir?',
          type: QuestionType.fillInBlank,
          correctAnswer: '.html',
          explanation: 'HTML dosyalari .html veya .htm uzantisi ile kaydedilir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Asagidaki kodda hata nerededir?\n<p>Merhaba Dunya<p>',
          type: QuestionType.findError,
          options: [
            'Kapanıs etiketi yanlis (</p> olmali)',
            'p etiketi yok',
            'Hata yok',
            'Merhaba yazilmamali',
          ],
          correctAnswer: 0,
          explanation: 'HTML etiketleri acilis <tag> ve kapanis </tag> seklinde yazilmalidir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: '<html>, <head> ve <body> etiketleri her HTML sayfasinda olmalidir.',
          type: QuestionType.trueFalse,
          correctAnswer: true,
          explanation: 'Bu uc etiket bir HTML sayfasinin temel yapisini olusturur.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // Python Quizzes
    'python_01': Quiz(
      id: 'quiz_python_1',
      lessonId: 'python_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'Python\'da ekrana yazi yazdirmak icin hangi fonksiyon kullanilir?',
          type: QuestionType.fillInBlank,
          correctAnswer: 'print',
          explanation: 'Python\'da print() fonksiyonu ekrana cikti vermek icin kullanilir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Asagidaki kodun ciktisi ne olur?\nprint("Merhaba " + "Dunya")',
          type: QuestionType.codeOutput,
          options: [
            'Merhaba Dunya',
            'Merhaba + Dunya',
            'Hata verir',
            '"Merhaba " + "Dunya"',
          ],
          correctAnswer: 0,
          explanation: 'Python\'da + operatoru string\'leri birlestirmek icin kullanilir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'Python kodlarinda girintiler (indentation) onemlidir.',
          type: QuestionType.trueFalse,
          correctAnswer: true,
          explanation: 'Python\'da girintiler kod bloklarini belirler ve zorunludur.',
        ),
        const QuizQuestion(
          id: 'q4',
          question: 'Python\'da yorum satiri hangi karakterle baslar?',
          type: QuestionType.multipleChoice,
          options: ['#', '//', '/*', '--'],
          correctAnswer: 0,
          explanation: 'Python\'da tek satirlik yorumlar # karakteri ile baslar.',
        ),
      ],
      passingScore: 70,
      xpReward: 20,
    ),

    'python_02': Quiz(
      id: 'quiz_python_2',
      lessonId: 'python_02',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'Asagidaki kodun ciktisi ne olur?\nx = 5\ny = 3\nprint(x + y)',
          type: QuestionType.codeOutput,
          options: ['8', '53', 'x + y', 'Hata'],
          correctAnswer: 0,
          explanation: 'x ve y sayisal degiskenler oldugu icin toplama islemi yapilir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Python\'da string veri tipi hangi karakterlerle tanilanir?',
          type: QuestionType.multipleChoice,
          options: [
            'Tirnak isaretleri (" veya \')',
            'Koseli parantez []',
            'Parantez ()',
            'Suslu parantez {}',
          ],
          correctAnswer: 0,
          explanation: 'String\'ler tek veya cift tirnak icinde yazilir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'int("5") ifadesinin sonucu nedir?',
          type: QuestionType.multipleChoice,
          options: ['5 (sayi)', '"5" (string)', 'Hata', 'None'],
          correctAnswer: 0,
          explanation: 'int() fonksiyonu string\'i tam sayiya cevirir.',
        ),
      ],
      passingScore: 70,
      xpReward: 20,
    ),

    // JavaScript Quizzes
    'js_01': Quiz(
      id: 'quiz_javascript_1',
      lessonId: 'js_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'JavaScript\'te degisken tanimlamak icin hangi anahtar kelime kullanilir?',
          type: QuestionType.multipleChoice,
          options: ['let / const / var', 'def', 'dim', 'variable'],
          correctAnswer: 0,
          explanation: 'JavaScript\'te let, const ve var anahtar kelimeleri degisken tanimlamak icin kullanilir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'console.log("Merhaba"); kodunun ciktisi konsola yazilir.',
          type: QuestionType.trueFalse,
          correctAnswer: true,
          explanation: 'console.log() fonksiyonu tarayici konsoluna cikti verir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'JavaScript sadece web tarayicilarinda calisir.',
          type: QuestionType.trueFalse,
          correctAnswer: false,
          explanation: 'Node.js sayesinde JavaScript sunucu tarafinda da calisabilir.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // CSS Quizzes
    'css_01': Quiz(
      id: 'quiz_css_1',
      lessonId: 'css_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'CSS ne anlama gelir?',
          type: QuestionType.multipleChoice,
          options: [
            'Cascading Style Sheets',
            'Computer Style Sheets',
            'Creative Style System',
            'Colorful Style Sheets',
          ],
          correctAnswer: 0,
          explanation: 'CSS, Cascading Style Sheets anlamina gelir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'CSS\'te yazi rengini degistirmek icin hangi ozellik kullanilir?',
          type: QuestionType.fillInBlank,
          correctAnswer: 'color',
          explanation: 'color ozelligi yazi rengini belirler.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'Asagidaki CSS kodundaki hata nedir?\np { color red; }',
          type: QuestionType.findError,
          options: [
            'Iki nokta eksik (color: red olmali)',
            'p yanlis secici',
            'red yanlis renk',
            'Hata yok',
          ],
          correctAnswer: 0,
          explanation: 'CSS ozellik ve degerleri arasinda : (iki nokta) kullanilmalidir.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // Dart Quizzes
    'dart_01': Quiz(
      id: 'quiz_dart_1',
      lessonId: 'dart_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'Dart hangi platform icin gelistirilmistir?',
          type: QuestionType.multipleChoice,
          options: [
            'Flutter (mobil, web, masaustu)',
            'Sadece Android',
            'Sadece iOS',
            'Sadece Web',
          ],
          correctAnswer: 0,
          explanation: 'Dart, Flutter framework\'u ile birlikte coklu platform gelistirme icin kullanilir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Dart\'ta ana fonksiyon nasil tanimlanir?',
          type: QuestionType.fillInBlank,
          correctAnswer: 'main',
          explanation: 'Dart programlari main() fonksiyonu ile baslar.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'Dart hem statik hem dinamik tip destekler.',
          type: QuestionType.trueFalse,
          correctAnswer: true,
          explanation: 'Dart sound null safety ile guclü tip sistemine sahiptir ancak var ile dinamik tip de kullanilabilir.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // Scratch Quizzes
    'scratch_01': Quiz(
      id: 'quiz_scratch_1',
      lessonId: 'scratch_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'Scratch\'te karakterlere ne denir?',
          type: QuestionType.multipleChoice,
          options: ['Sprite', 'Actor', 'Player', 'Object'],
          correctAnswer: 0,
          explanation: 'Scratch\'te tum karakterler ve nesneler Sprite olarak adlandirilir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Scratch gorsel blok tabanli bir programlama araci.',
          type: QuestionType.trueFalse,
          correctAnswer: true,
          explanation: 'Scratch, kod yazmak yerine bloklari surukleyerek programlama ogretir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'Scratch hangi yas grubu icin tasarlanmistir?',
          type: QuestionType.multipleChoice,
          options: ['8-16 yas', 'Sadece yetiskinler', '0-3 yas', '50+ yas'],
          correctAnswer: 0,
          explanation: 'Scratch ozellikle kodlamaya yeni baslayanlar icin tasarlanmis bir egitim aracidir.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // Arduino Quizzes
    'arduino_01': Quiz(
      id: 'quiz_arduino_1',
      lessonId: 'arduino_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'Arduino kodunda setup() fonksiyonu kac kere calisir?',
          type: QuestionType.multipleChoice,
          options: ['Bir kere (baslangicta)', 'Surekli', 'Hic', 'Iki kere'],
          correctAnswer: 0,
          explanation: 'setup() fonksiyonu Arduino acildiginda sadece bir kez calisir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'loop() fonksiyonu surekli tekrar eder.',
          type: QuestionType.trueFalse,
          correctAnswer: true,
          explanation: 'loop() fonksiyonu Arduino calistiği surece surekli tekrarlanir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'LED yakmak icin hangi fonksiyon kullanilir?',
          type: QuestionType.multipleChoice,
          options: ['digitalWrite()', 'print()', 'show()', 'light()'],
          correctAnswer: 0,
          explanation: 'digitalWrite() fonksiyonu dijital pinlere HIGH veya LOW sinyal gonderir.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // SQL Quizzes
    'sql_01': Quiz(
      id: 'quiz_sql_1',
      lessonId: 'sql_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'SQL ne anlama gelir?',
          type: QuestionType.multipleChoice,
          options: [
            'Structured Query Language',
            'Simple Question Language',
            'System Query List',
            'Standard Quick Language',
          ],
          correctAnswer: 0,
          explanation: 'SQL, Structured Query Language (Yapilandirilmis Sorgu Dili) anlamina gelir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Veritabanindan veri cekmek icin hangi komut kullanilir?',
          type: QuestionType.fillInBlank,
          correctAnswer: 'SELECT',
          explanation: 'SELECT komutu veritabanindan veri sorgulamak icin kullanilir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'SQL buyuk/kucuk harf duyarlidir (case-sensitive).',
          type: QuestionType.trueFalse,
          correctAnswer: false,
          explanation: 'SQL komutlari buyuk/kucuk harf duyarsizdir. SELECT ve select aynidir.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // C Quizzes
    'c_01': Quiz(
      id: 'quiz_c_1',
      lessonId: 'c_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'C dilinde main fonksiyonu nasil tanimlanir?',
          type: QuestionType.multipleChoice,
          options: [
            'int main()',
            'void main()',
            'function main()',
            'def main()',
          ],
          correctAnswer: 0,
          explanation: 'C dilinde standart main fonksiyonu int main() seklinde tanimlanir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'printf() fonksiyonu icin hangi header dosyasi gereklidir?',
          type: QuestionType.fillInBlank,
          correctAnswer: 'stdio.h',
          explanation: 'printf() fonksiyonu stdio.h (standard input/output) header dosyasinda tanimlidir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'C dili derlenmeden calistirilabilir (interpreted).',
          type: QuestionType.trueFalse,
          correctAnswer: false,
          explanation: 'C dili derleyici (compiler) ile makine koduna cevrilmesi gereken bir dildir.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // Go Quizzes
    'go_01': Quiz(
      id: 'quiz_go_1',
      lessonId: 'go_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'Go dili hangi sirket tarafindan gelistirilmistir?',
          type: QuestionType.multipleChoice,
          options: ['Google', 'Microsoft', 'Apple', 'Facebook'],
          correctAnswer: 0,
          explanation: 'Go (Golang), Google muhendisleri tarafindan gelistirilmistir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Go dilinde ekrana yazdirma icin hangi paket kullanilir?',
          type: QuestionType.fillInBlank,
          correctAnswer: 'fmt',
          explanation: 'fmt paketi format isleri icin kullanilir, fmt.Println() ile ekrana yazdirilir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'Go dilinde kullanilmayan degiskenler derleme hatasina neden olur.',
          type: QuestionType.trueFalse,
          correctAnswer: true,
          explanation: 'Go, temiz kod icin kullanilmayan degiskenlere izin vermez.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // Rust Quizzes
    'rust_01': Quiz(
      id: 'quiz_rust_1',
      lessonId: 'rust_01',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'Rust\'in en onemli ozelligi nedir?',
          type: QuestionType.multipleChoice,
          options: [
            'Bellek guvenligi (Memory Safety)',
            'Hizli web gelistirme',
            'Kolay ogrenme',
            'Dinamik tipleme',
          ],
          correctAnswer: 0,
          explanation: 'Rust, ownership sistemi sayesinde bellek guvenligini derleme zamaninda garanti eder.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Rust\'ta degismez (immutable) degisken tanimlamak icin hangi anahtar kelime kullanilir?',
          type: QuestionType.fillInBlank,
          correctAnswer: 'let',
          explanation: 'let ile tanimlanan degiskenler varsayilan olarak degismezdir. Degisken icin let mut kullanilir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'Rust\'ta garbage collector (cop toplayici) vardir.',
          type: QuestionType.trueFalse,
          correctAnswer: false,
          explanation: 'Rust, ownership sistemi sayesinde garbage collector olmadan bellek yonetimi yapar.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // Python Quiz 3 - Degiskenler
    'python_03': Quiz(
      id: 'quiz_python_3',
      lessonId: 'python_03',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'Python\'da degisken tanimlarken hangi isaret kullanilir?',
          type: QuestionType.multipleChoice,
          options: ['=', '==', ':=', '->'],
          correctAnswer: 0,
          explanation: '= isareti ile degiskene deger atanir. == ise karsilastirma icindir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Asagidaki kodun ciktisi ne olur?',
          codeSnippet: 'isim = "Ali"\nyas = 12\nprint(isim, yas)',
          type: QuestionType.codeOutput,
          options: ['Ali 12', 'isim yas', 'Ali12', 'Hata verir'],
          correctAnswer: 0,
          explanation: 'print() birden fazla degeri aralarina bosluk koyarak yazdirir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'Python\'da degisken adi rakamla baslayabilir.',
          type: QuestionType.trueFalse,
          correctAnswer: false,
          explanation: 'Degisken adlari harf veya alt cizgi (_) ile baslamalidir. 1sayi gecersiz, sayi1 gecerlidir.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // Python Quiz 4 - If-Else
    'python_04': Quiz(
      id: 'quiz_python_4',
      lessonId: 'python_04',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'Python\'da kosul bloklarini belirlemek icin ne kullanilir?',
          type: QuestionType.multipleChoice,
          options: [
            'Girinti (indentation)',
            'Suslu parantez { }',
            'Noktali virgul ;',
            'Koseli parantez [ ]',
          ],
          correctAnswer: 0,
          explanation: 'Python\'da bloklar girinti (bosluk) ile belirlenir, suslu parantez kullanilmaz.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Asagidaki kodun ciktisi ne olur?',
          codeSnippet: 'yas = 10\nif yas >= 18:\n    print("Yetiskin")\nelse:\n    print("Cocuk")',
          type: QuestionType.codeOutput,
          options: ['Cocuk', 'Yetiskin', 'Hicbir sey', 'Hata verir'],
          correctAnswer: 0,
          explanation: '10 >= 18 kosulu yanlis oldugu icin else blogu calisir ve "Cocuk" yazdirilir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'Birden fazla kosulu kontrol etmek icin if\'ten sonra hangi anahtar kelime kullanilir?',
          type: QuestionType.fillInBlank,
          correctAnswer: 'elif',
          explanation: 'elif (else if), ilk kosul saglanmazsa yeni bir kosul kontrol eder.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // Python Quiz 5 - Donguler
    'python_05': Quiz(
      id: 'quiz_python_5',
      lessonId: 'python_05',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'range(5) hangi sayilari uretir?',
          type: QuestionType.multipleChoice,
          options: [
            '0, 1, 2, 3, 4',
            '1, 2, 3, 4, 5',
            '0, 1, 2, 3, 4, 5',
            '5, 4, 3, 2, 1',
          ],
          correctAnswer: 0,
          explanation: 'range(5), 0\'dan baslar ve 5\'e kadar (5 dahil degil) sayilari uretir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'Asagidaki kod kac kez "Merhaba" yazdirir?',
          codeSnippet: 'for i in range(3):\n    print("Merhaba")',
          type: QuestionType.codeOutput,
          options: ['3', '2', '4', 'Sonsuz'],
          correctAnswer: 0,
          explanation: 'range(3) uc deger uretir (0, 1, 2), dongu 3 kez calisir.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'while dongusu, kosul dogru oldugu surece calisir.',
          type: QuestionType.trueFalse,
          correctAnswer: true,
          explanation: 'while dongusu kosul True oldugu surece tekrar eder. Kosul False olunca durur.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),

    // Arduino Quiz 2 - LED Devresi
    'arduino_02': Quiz(
      id: 'quiz_arduino_2',
      lessonId: 'arduino_02',
      questions: [
        const QuizQuestion(
          id: 'q1',
          question: 'LED\'i Arduino\'ya baglarken neden direnc kullanilir?',
          type: QuestionType.multipleChoice,
          options: [
            'LED\'in bozulmasini onlemek icin',
            'LED\'i daha parlak yapmak icin',
            'Kablo tasarrufu icin',
            'Direnc gerekli degildir',
          ],
          correctAnswer: 0,
          explanation: 'Direnc, LED\'den gecen akimi sinirlar ve LED\'in zarar gormesini onler. Genelde 220 ohm kullanilir.',
        ),
        const QuizQuestion(
          id: 'q2',
          question: 'digitalWrite(13, HIGH) komutu ne yapar?',
          type: QuestionType.multipleChoice,
          options: [
            '13 numarali pine elektrik verir (LED yanar)',
            '13 numarali pini kapatir',
            '13 saniye bekler',
            'Pin 13\'u okur',
          ],
          correctAnswer: 0,
          explanation: 'digitalWrite ile pin HIGH (5V) yapilir, bagli LED yanar. LOW ile soner.',
        ),
        const QuizQuestion(
          id: 'q3',
          question: 'delay(1000) komutu 1 saniye bekler.',
          type: QuestionType.trueFalse,
          correctAnswer: true,
          explanation: 'delay() milisaniye cinsinden calisir. 1000 milisaniye = 1 saniye.',
        ),
      ],
      passingScore: 60,
      xpReward: 15,
    ),
  };
}
