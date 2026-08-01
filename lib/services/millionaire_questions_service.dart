import '../models/millionaire_question.dart';

class MillionaireQuestionsService {
  static List<MillionaireQuestion> getQuestions() {
    // Para ağacı: 1000, 2000, 3000, 5000, 10000, 20000, 30000, 50000, 100000, 250000, 500000, 1000000
    return [
      // ==================== SEVİYE 1 - 1000 TL ====================
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
        questionEn: 'What is an algorithm?',
        optionsEn: [
          'A musical instrument',
          'A step-by-step set of instructions to solve a problem',
          'A recipe',
          'A game',
        ],
      ),
      MillionaireQuestion(
        question: 'Bilgisayara ne yapacağını söyleyen komut dizisine ne denir?',
        options: ['Program', 'Klavye', 'Ekran', 'Hoparlör'],
        correctAnswerIndex: 0,
        difficulty: 1,
        prize: 1000,
        questionEn: 'What is the sequence of commands that tells a computer what to do called?',
        optionsEn: ['Program', 'Keyboard', 'Screen', 'Speaker'],
      ),
      MillionaireQuestion(
        question: 'Scratch\'te kod yazmak için ne kullanılır?',
        options: ['Renkli bloklar', 'Kalem ve kağıt', 'Ses komutları', 'Fotoğraflar'],
        correctAnswerIndex: 0,
        difficulty: 1,
        prize: 1000,
        questionEn: 'What do you use to write code in Scratch?',
        optionsEn: ['Colorful blocks', 'Pen and paper', 'Voice commands', 'Photos'],
      ),
      MillionaireQuestion(
        question: 'Ekrana bir mesaj yazdırmak için kullanılan temel komuta genellikle ne ad verilir?',
        options: ['Yazdır/Print', 'Sil', 'Kaydet', 'Kapat'],
        correctAnswerIndex: 0,
        difficulty: 1,
        prize: 1000,
        questionEn: 'What is the basic command used to display a message on the screen usually called?',
        optionsEn: ['Print', 'Delete', 'Save', 'Close'],
      ),
      MillionaireQuestion(
        question: 'Bir robotu hareket ettiren parçaya ne denir?',
        options: ['Motor', 'Ekran', 'Hoparlör', 'Anten'],
        correctAnswerIndex: 0,
        difficulty: 1,
        prize: 1000,
        questionEn: 'What is the part that moves a robot called?',
        optionsEn: ['Motor', 'Screen', 'Speaker', 'Antenna'],
      ),
      MillionaireQuestion(
        question: 'Bilgisayarda kullanılan \'0\' ve \'1\' rakamlarına ne denir?',
        options: ['Harf', 'Bit', 'Piksel', 'Byte'],
        correctAnswerIndex: 1,
        difficulty: 1,
        prize: 1000,
        questionEn: 'What are the digits \'0\' and \'1\' used in computers called?',
        optionsEn: ['Letter', 'Bit', 'Pixel', 'Byte'],
      ),

      // ==================== SEVİYE 2 - 2000 TL ====================
      MillionaireQuestion(
        question: 'Hangisi bir programlama dili değildir?',
        options: ['Python', 'Java', 'Microsoft Word', 'C++'],
        correctAnswerIndex: 2,
        difficulty: 2,
        prize: 2000,
        questionEn: 'Which of these is not a programming language?',
        optionsEn: ['Python', 'Java', 'Microsoft Word', 'C++'],
      ),
      MillionaireQuestion(
        question: 'Python programlama dilinin sembolü hangi hayvandır?',
        options: ['Kedi', 'Yılan', 'Köpek', 'Fil'],
        correctAnswerIndex: 1,
        difficulty: 2,
        prize: 2000,
        questionEn: 'Which animal is the symbol of the Python programming language?',
        optionsEn: ['Cat', 'Snake', 'Dog', 'Elephant'],
      ),
      MillionaireQuestion(
        question: 'Hangisi bir çıktı (output) cihazıdır?',
        options: ['Klavye', 'Fare', 'Monitör', 'Mikrofon'],
        correctAnswerIndex: 2,
        difficulty: 2,
        prize: 2000,
        questionEn: 'Which of these is an output device?',
        optionsEn: ['Keyboard', 'Mouse', 'Monitor', 'Microphone'],
      ),
      MillionaireQuestion(
        question: 'Aşağıdakilerden hangisi bir işletim sistemi değildir?',
        options: ['Windows', 'Android', 'Spotify', 'Linux'],
        correctAnswerIndex: 2,
        difficulty: 2,
        prize: 2000,
        questionEn: 'Which of the following is not an operating system?',
        optionsEn: ['Windows', 'Android', 'Spotify', 'Linux'],
      ),
      MillionaireQuestion(
        question: 'Bir bilgisayar dosyasının türünü gösteren kısma ne denir?',
        options: ['Uzantı', 'Başlık', 'Boyut', 'Ad'],
        correctAnswerIndex: 0,
        difficulty: 2,
        prize: 2000,
        questionEn: 'What is the part that shows the type of a computer file called?',
        optionsEn: ['Extension', 'Title', 'Size', 'Name'],
      ),
      MillionaireQuestion(
        question: 'Scratch programlama ortamı hangi yaş grubu için tasarlanmıştır?',
        options: ['Yetişkinler', 'Çocuklar ve yeni başlayanlar', 'Sadece mühendisler', 'Sadece öğretmenler'],
        correctAnswerIndex: 1,
        difficulty: 2,
        prize: 2000,
        questionEn: 'Which age group is the Scratch programming environment designed for?',
        optionsEn: ['Adults', 'Children and beginners', 'Only engineers', 'Only teachers'],
      ),

      // ==================== SEVİYE 3 - 3000 TL ====================
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
        questionEn: 'What does a loop do?',
        optionsEn: [
          'Shuts down the computer',
          'Repeats the same action over and over',
          'Deletes the program',
          'Connects to the internet',
        ],
      ),
      MillionaireQuestion(
        question: 'Python\'da ekrana yazı yazdırmak için hangi komut kullanılır?',
        options: ['write()', 'print()', 'show()', 'display()'],
        correctAnswerIndex: 1,
        difficulty: 3,
        prize: 3000,
        questionEn: 'Which command is used to print text to the screen in Python?',
        optionsEn: ['write()', 'print()', 'show()', 'display()'],
      ),
      MillionaireQuestion(
        question: 'Arduino ile hangisini yapabilirsin?',
        options: ['LED yakmak', 'Yemek pişirmek', 'Çamaşır yıkamak', 'Uçmak'],
        correctAnswerIndex: 0,
        difficulty: 3,
        prize: 3000,
        questionEn: 'Which of these can you do with Arduino?',
        optionsEn: ['Light up an LED', 'Cook food', 'Wash clothes', 'Fly'],
      ),
      MillionaireQuestion(
        question: 'Bir döngüyü erken sonlandırmak için genellikle hangi komut kullanılır?',
        options: ['break', 'start', 'print', 'input'],
        correctAnswerIndex: 0,
        difficulty: 3,
        prize: 3000,
        questionEn: 'Which command is usually used to end a loop early?',
        optionsEn: ['break', 'start', 'print', 'input'],
      ),
      MillionaireQuestion(
        question: 'For döngüsü genellikle ne zaman tercih edilir?',
        options: ['Tekrar sayısı belliyken', 'Hiç tekrar yokken', 'Sadece hata varken', 'Ekran kapalıyken'],
        correctAnswerIndex: 0,
        difficulty: 3,
        prize: 3000,
        questionEn: 'When is a for loop usually preferred?',
        optionsEn: ['When the number of repeats is known', 'When there is no repetition', 'Only when there is an error', 'When the screen is off'],
      ),
      MillionaireQuestion(
        question: 'Bir robotun ileri gitmesini sağlayan basit komut hangisidir?',
        options: ['dur()', 'ileriGit()', 'sil()', 'bekle()'],
        correctAnswerIndex: 1,
        difficulty: 3,
        prize: 3000,
        questionEn: 'Which simple command makes a robot move forward?',
        optionsEn: ['stop()', 'moveForward()', 'delete()', 'wait()'],
      ),

      // ==================== SEVİYE 4 - 5000 TL ====================
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
        questionEn: 'What is the IF-ELSE structure used for?',
        optionsEn: [
          'Making decisions',
          'Saving files',
          'Printing to the screen',
          'Defining variables',
        ],
      ),
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
        questionEn: 'What is a variable used for?',
        optionsEn: [
          'Storing data',
          'Speeding up the computer',
          'Clearing the screen',
          'Connecting to the internet',
        ],
      ),
      MillionaireQuestion(
        question: 'Bir programdaki hataya ne ad verilir?',
        options: ['Bug', 'Virus', 'Spam', 'Cookie'],
        correctAnswerIndex: 0,
        difficulty: 4,
        prize: 5000,
        questionEn: 'What is an error in a program called?',
        optionsEn: ['Bug', 'Virus', 'Spam', 'Cookie'],
      ),
      MillionaireQuestion(
        question: 'IF-ELSE yapısında koşul sağlanmazsa hangi blok çalışır?',
        options: ['IF bloğu', 'ELSE bloğu', 'Hiçbiri', 'İkisi birden'],
        correctAnswerIndex: 1,
        difficulty: 4,
        prize: 5000,
        questionEn: 'In an IF-ELSE structure, which block runs if the condition is not met?',
        optionsEn: ['The IF block', 'The ELSE block', 'Neither', 'Both'],
      ),
      MillionaireQuestion(
        question: 'Mantıksal \'VE\' (AND) operatörü ne zaman TRUE (doğru) sonucu verir?',
        options: ['Her iki koşul da doğruysa', 'Sadece biri doğruysa', 'Hiçbiri doğru değilse', 'Her zaman'],
        correctAnswerIndex: 0,
        difficulty: 4,
        prize: 5000,
        questionEn: 'When does the logical AND operator return TRUE?',
        optionsEn: ['When both conditions are true', 'When only one is true', 'When neither is true', 'Always'],
      ),
      MillionaireQuestion(
        question: 'Bir \'bug\' (hata) bulup düzeltme işlemine ne denir?',
        options: ['Compile', 'Debug', 'Deploy', 'Design'],
        correctAnswerIndex: 1,
        difficulty: 4,
        prize: 5000,
        questionEn: 'What is the process of finding and fixing a bug called?',
        optionsEn: ['Compile', 'Debug', 'Deploy', 'Design'],
      ),

      // ==================== SEVİYE 5 - 10000 TL ====================
      MillionaireQuestion(
        question: 'Hangisi bir veri tipi değildir?',
        options: ['Integer', 'String', 'Boolean', 'Calculator'],
        correctAnswerIndex: 3,
        difficulty: 5,
        prize: 10000,
        questionEn: 'Which of these is not a data type?',
        optionsEn: ['Integer', 'String', 'Boolean', 'Calculator'],
      ),
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
        questionEn: 'What is HTML used for?',
        optionsEn: [
          'Building the structure of a web page',
          'Programming robots',
          'Writing a game engine',
          'Managing databases',
        ],
      ),
      MillionaireQuestion(
        question: 'Python\'da "5" + "3" işleminin sonucu nedir?',
        options: ['8', '53', 'Hata verir', '15'],
        correctAnswerIndex: 1,
        difficulty: 5,
        prize: 10000,
        questionEn: 'What is the result of "5" + "3" in Python?',
        optionsEn: ['8', '53', 'It gives an error', '15'],
      ),
      MillionaireQuestion(
        question: 'Bir dizinin (array) ilk elemanının index numarası genellikle kaçtır?',
        options: ['1', '0', '-1', '10'],
        correctAnswerIndex: 1,
        difficulty: 5,
        prize: 10000,
        questionEn: 'What is the index number of the first element of an array usually?',
        optionsEn: ['1', '0', '-1', '10'],
      ),
      MillionaireQuestion(
        question: 'CPU\'nun açılımı nedir?',
        options: ['Central Processing Unit', 'Computer Program Utility', 'Central Program Unit', 'Central Processor Utility'],
        correctAnswerIndex: 0,
        difficulty: 5,
        prize: 10000,
        questionEn: 'What does CPU stand for?',
        optionsEn: ['Central Processing Unit', 'Computer Program Utility', 'Central Program Unit', 'Central Processor Utility'],
      ),
      MillionaireQuestion(
        question: 'Bir web sayfasının adresini yazdığımız çubuğa ne denir?',
        options: ['Konsol', 'URL çubuğu', 'Terminal', 'Bellek'],
        correctAnswerIndex: 1,
        difficulty: 5,
        prize: 10000,
        questionEn: 'What is the bar where you type a website address called?',
        optionsEn: ['Console', 'URL bar', 'Terminal', 'Memory'],
      ),

      // ==================== SEVİYE 6 - 20000 TL ====================
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
        questionEn: 'What is an array?',
        optionsEn: [
          'A structure that stores a single value',
          'A structure that stores multiple values',
          'A structure that only stores text',
          'A structure that stores nothing',
        ],
      ),
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
        questionEn: 'What does CSS do?',
        optionsEn: [
          'Gives style and design to a web page',
          'Creates a database',
          'Draws a game character',
          'Sends email',
        ],
      ),
      MillionaireQuestion(
        question: 'Arduino\'da analog pinler hangi değer aralığını okur?',
        options: ['0-1', '0-100', '0-1023', '0-9999'],
        correctAnswerIndex: 2,
        difficulty: 6,
        prize: 20000,
        questionEn: 'What range of values do analog pins read on Arduino?',
        optionsEn: ['0-1', '0-100', '0-1023', '0-9999'],
      ),
      MillionaireQuestion(
        question: 'Bir \'while\' döngüsü ne zaman durur?',
        options: ['Koşul yanlış olduğunda', 'Hiçbir zaman', 'Program başladığında', 'Ekran kapandığında'],
        correctAnswerIndex: 0,
        difficulty: 6,
        prize: 20000,
        questionEn: 'When does a while loop stop?',
        optionsEn: ['When the condition becomes false', 'Never', 'When the program starts', 'When the screen turns off'],
      ),
      MillionaireQuestion(
        question: 'İki boyutlu bir diziye (matrix) genellikle ne denir?',
        options: ['Liste', 'Tablo/Matris', 'Yığın', 'Kuyruk'],
        correctAnswerIndex: 1,
        difficulty: 6,
        prize: 20000,
        questionEn: 'What is a two-dimensional array usually called?',
        optionsEn: ['List', 'Table/Matrix', 'Stack', 'Queue'],
      ),
      MillionaireQuestion(
        question: 'Arduino\'da dijital bir pin sadece hangi iki değeri okuyabilir?',
        options: ['0 ve 1', '0 ve 1023', '-1 ve 1', '1 ve 100'],
        correctAnswerIndex: 0,
        difficulty: 6,
        prize: 20000,
        questionEn: 'Which two values can a digital pin on Arduino read?',
        optionsEn: ['0 and 1', '0 and 1023', '-1 and 1', '1 and 100'],
      ),

      // ==================== SEVİYE 7 - 30000 TL ====================
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
        questionEn: 'What does a function do?',
        optionsEn: [
          'Only performs addition',
          'Groups code and makes it reusable',
          'Only prints to the screen',
          'Starts the program',
        ],
      ),
      MillionaireQuestion(
        question: 'Python\'da bir listenin uzunluğunu hangi fonksiyon verir?',
        options: ['size()', 'count()', 'len()', 'length()'],
        correctAnswerIndex: 2,
        difficulty: 7,
        prize: 30000,
        questionEn: 'Which function returns the length of a list in Python?',
        optionsEn: ['size()', 'count()', 'len()', 'length()'],
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
        questionEn: 'What is an infinite loop?',
        optionsEn: [
          'A loop that never runs',
          'A loop that never stops because its end condition is never met',
          'A loop that runs only once',
          'A loop that counts backwards',
        ],
      ),
      MillionaireQuestion(
        question: 'Aynı kodu birden fazla dosyada tekrar kullanmak için hangi yöntem tercih edilir?',
        options: ['Kopyala-yapıştır', 'Fonksiyon/Modül oluşturma', 'Silme', 'Yeniden yazma'],
        correctAnswerIndex: 1,
        difficulty: 7,
        prize: 30000,
        questionEn: 'Which method is preferred to reuse the same code across multiple files?',
        optionsEn: ['Copy-paste', 'Creating a function/module', 'Deleting it', 'Rewriting it'],
      ),
      MillionaireQuestion(
        question: 'Bir \'array\' (dizi) içindeki elemanları küçükten büyüğe dizmeye ne denir?',
        options: ['Filtreleme', 'Sıralama (Sort)', 'Arama', 'Silme'],
        correctAnswerIndex: 1,
        difficulty: 7,
        prize: 30000,
        questionEn: 'What is arranging the elements of an array from smallest to largest called?',
        optionsEn: ['Filtering', 'Sorting', 'Searching', 'Deleting'],
      ),
      MillionaireQuestion(
        question: 'Stack Overflow hatası genellikle neyin sonucunda oluşur?',
        options: ['Çok fazla döngü', 'Sonsuz veya çok derin özyineleme (recursion)', 'Yanlış renk seçimi', 'İnternet kesilmesi'],
        correctAnswerIndex: 1,
        difficulty: 7,
        prize: 30000,
        questionEn: 'A Stack Overflow error usually occurs as a result of what?',
        optionsEn: ['Too many loops', 'Infinite or very deep recursion', 'Choosing the wrong color', 'Internet disconnecting'],
      ),

      // ==================== SEVİYE 8 - 50000 TL ====================
      MillionaireQuestion(
        question: 'Binary sistemde 1010 sayısının ondalık karşılığı nedir?',
        options: ['8', '10', '12', '14'],
        correctAnswerIndex: 1,
        difficulty: 8,
        prize: 50000,
        questionEn: 'What is the decimal equivalent of binary 1010?',
        optionsEn: ['8', '10', '12', '14'],
      ),
      MillionaireQuestion(
        question: 'Binary sistemde 1111 sayısının ondalık karşılığı nedir?',
        options: ['15', '11', '16', '31'],
        correctAnswerIndex: 0,
        difficulty: 8,
        prize: 50000,
        questionEn: 'What is the decimal equivalent of binary 1111?',
        optionsEn: ['15', '11', '16', '31'],
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
        questionEn: 'What is the role of RAM?',
        optionsEn: [
          'Stores data permanently',
          'Holds temporary data of running programs',
          'Displays images on screen',
          'Connects to the internet',
        ],
      ),
      MillionaireQuestion(
        question: 'Hexadecimal (16\'lık) sayı sisteminde kaç farklı sembol kullanılır?',
        options: ['8', '10', '16', '2'],
        correctAnswerIndex: 2,
        difficulty: 8,
        prize: 50000,
        questionEn: 'How many different symbols are used in the hexadecimal number system?',
        optionsEn: ['8', '10', '16', '2'],
      ),
      MillionaireQuestion(
        question: 'Bir bilgisayarın ROM belleği için ne söylenebilir?',
        options: ['Kalıcıdır, genelde değiştirilemez', 'Geçicidir, kapanınca silinir', 'Sadece resim saklar', 'Sadece internet için kullanılır'],
        correctAnswerIndex: 0,
        difficulty: 8,
        prize: 50000,
        questionEn: 'What can be said about a computer\'s ROM memory?',
        optionsEn: ['It is permanent, usually cannot be changed', 'It is temporary, erased when powered off', 'It only stores images', 'It is only used for the internet'],
      ),
      MillionaireQuestion(
        question: 'İki sayının toplamını hesaplayan basit bir devrede hangi bileşen mantık işlemi yapar?',
        options: ['Direnç', 'Logic Gate (Mantık Kapısı)', 'LED', 'Anten'],
        correctAnswerIndex: 1,
        difficulty: 8,
        prize: 50000,
        questionEn: 'In a simple circuit that adds two numbers, which component performs the logic operation?',
        optionsEn: ['Resistor', 'Logic Gate', 'LED', 'Antenna'],
      ),

      // ==================== SEVİYE 9 - 100000 TL ====================
      MillionaireQuestion(
        question: 'Hangisi bir sıralama algoritması değildir?',
        options: ['Bubble Sort', 'Quick Sort', 'Binary Search', 'Merge Sort'],
        correctAnswerIndex: 2,
        difficulty: 9,
        prize: 100000,
        questionEn: 'Which of these is not a sorting algorithm?',
        optionsEn: ['Bubble Sort', 'Quick Sort', 'Binary Search', 'Merge Sort'],
      ),
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
        questionEn: 'How does the Binary Search algorithm work?',
        optionsEn: [
          'It checks every element one by one',
          'It searches a sorted list by halving it at each step',
          'It picks a random element',
          'It reverses the list',
        ],
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
        questionEn: 'What is Git?',
        optionsEn: [
          'A game engine',
          'A version control system',
          'A web browser',
          'An operating system',
        ],
      ),
      MillionaireQuestion(
        question: 'Hangi veri yapısı \'ilk giren ilk çıkar\' (FIFO) prensibiyle çalışır?',
        options: ['Stack', 'Queue (Kuyruk)', 'Tree', 'Graph'],
        correctAnswerIndex: 1,
        difficulty: 9,
        prize: 100000,
        questionEn: 'Which data structure works on the "first in, first out" (FIFO) principle?',
        optionsEn: ['Stack', 'Queue', 'Tree', 'Graph'],
      ),
      MillionaireQuestion(
        question: 'Bir algoritmanın en kötü durum performansını ifade eden gösterime ne denir?',
        options: ['Big-O notasyonu', 'Pi sayısı', 'Byte oranı', 'Pixel yoğunluğu'],
        correctAnswerIndex: 0,
        difficulty: 9,
        prize: 100000,
        questionEn: 'What is the notation that expresses the worst-case performance of an algorithm called?',
        optionsEn: ['Big-O notation', 'Pi number', 'Byte ratio', 'Pixel density'],
      ),
      MillionaireQuestion(
        question: 'API kısaltması neyi ifade eder?',
        options: ['Application Programming Interface', 'Automatic Program Installer', 'Advanced Python Index', 'App Protocol Internet'],
        correctAnswerIndex: 0,
        difficulty: 9,
        prize: 100000,
        questionEn: 'What does the abbreviation API stand for?',
        optionsEn: ['Application Programming Interface', 'Automatic Program Installer', 'Advanced Python Index', 'App Protocol Internet'],
      ),

      // ==================== SEVİYE 10 - 250000 TL ====================
      MillionaireQuestion(
        question: 'Object Oriented Programming (OOP) prensiplerinden biri hangisidir?',
        options: ['Döngü', 'Kapsülleme (Encapsulation)', 'Değişken', 'Array'],
        correctAnswerIndex: 1,
        difficulty: 10,
        prize: 250000,
        questionEn: 'Which of these is a principle of Object Oriented Programming (OOP)?',
        optionsEn: ['Loop', 'Encapsulation', 'Variable', 'Array'],
      ),
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
        questionEn: 'What does "inheritance" mean in OOP?',
        optionsEn: [
          'A class taking on the properties of another class',
          'Deleting variables',
          'Encrypting code',
          'A program running twice',
        ],
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
        questionEn: 'What is the main difference between HTTP and HTTPS?',
        optionsEn: [
          'HTTPS uses encrypted communication',
          'HTTP is newer',
          'HTTPS only shows videos',
          'There is no difference',
        ],
      ),
      MillionaireQuestion(
        question: 'Bir sınıftan (class) türetilen nesneye ne denir?',
        options: ['Metod', 'Instance/Nesne', 'Fonksiyon', 'Kütüphane'],
        correctAnswerIndex: 1,
        difficulty: 10,
        prize: 250000,
        questionEn: 'What is an object created from a class called?',
        optionsEn: ['Method', 'Instance/Object', 'Function', 'Library'],
      ),
      MillionaireQuestion(
        question: 'Bir programın çalışırken bellekte kapladığı alanı optimize etmeye ne denir?',
        options: ['Bellek yönetimi (Memory management)', 'Ekran yönetimi', 'Ses yönetimi', 'Renk yönetimi'],
        correctAnswerIndex: 0,
        difficulty: 10,
        prize: 250000,
        questionEn: 'What is optimizing the memory space a program uses while running called?',
        optionsEn: ['Memory management', 'Screen management', 'Sound management', 'Color management'],
      ),
      MillionaireQuestion(
        question: 'SQL genellikle ne için kullanılır?',
        options: ['Veritabanı sorgulamak', 'Web sayfası tasarlamak', 'Resim düzenlemek', 'Video oynatmak'],
        correctAnswerIndex: 0,
        difficulty: 10,
        prize: 250000,
        questionEn: 'What is SQL usually used for?',
        optionsEn: ['Querying databases', 'Designing web pages', 'Editing images', 'Playing videos'],
      ),

      // ==================== SEVİYE 11 - 500000 TL ====================
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
        questionEn: 'What does recursion mean?',
        optionsEn: [
          'A function calling itself',
          'A variable\'s value increasing',
          'A loop continuing forever',
          'A program restarting from the beginning',
        ],
      ),
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
        questionEn: 'What does Big-O notation express?',
        optionsEn: [
          'The complexity (performance) of an algorithm',
          'The file size of a program',
          'Screen resolution',
          'Internet speed',
        ],
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
        questionEn: 'Which principle does the Stack data structure work on?',
        optionsEn: [
          'FIFO - First in, first out',
          'LIFO - Last in, first out',
          'Random access',
          'Alphabetical order',
        ],
      ),
      MillionaireQuestion(
        question: 'Polimorfizm (Polymorphism) OOP\'de ne anlama gelir?',
        options: ['Bir nesnenin birden fazla biçimde davranabilmesi', 'Bir değişkenin silinmesi', 'Bir döngünün durması', 'Bir dosyanın kopyalanması'],
        correctAnswerIndex: 0,
        difficulty: 11,
        prize: 500000,
        questionEn: 'What does polymorphism mean in OOP?',
        optionsEn: ['An object being able to behave in multiple forms', 'Deleting a variable', 'A loop stopping', 'Copying a file'],
      ),
      MillionaireQuestion(
        question: 'NP-Complete problemler hakkında ne söylenebilir?',
        options: ['Çok hızlı çözülürler', 'Çözümü hızlı doğrulanabilir ama bulmak zordur', 'Hiç çözümü yoktur', 'Sadece insanlar çözebilir'],
        correctAnswerIndex: 1,
        difficulty: 11,
        prize: 500000,
        questionEn: 'What can be said about NP-Complete problems?',
        optionsEn: ['They are solved very quickly', 'Their solution is quick to verify but hard to find', 'They have no solution at all', 'Only humans can solve them'],
      ),
      MillionaireQuestion(
        question: 'Bir hash fonksiyonunun temel özelliği nedir?',
        options: ['Aynı girdi için farklı çıktı üretir', 'Girdiyi sabit uzunlukta bir çıktıya dönüştürür', 'Sadece sayı kabul eder', 'Hiçbir zaman çakışma olmaz'],
        correctAnswerIndex: 1,
        difficulty: 11,
        prize: 500000,
        questionEn: 'What is the basic property of a hash function?',
        optionsEn: ['It produces different output for the same input', 'It converts input into a fixed-length output', 'It only accepts numbers', 'Collisions never happen'],
      ),

      // ==================== SEVİYE 12 - 1.000.000 TL ====================
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
        questionEn: 'What does it mean for a system to be Turing Complete?',
        optionsEn: [
          'A system that can only do addition',
          'A system that can run any computable function',
          'A system that can only display web pages',
          'A system that can only run games',
        ],
      ),
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
        questionEn: 'Why is the Halting Problem important?',
        optionsEn: [
          'It proves that no general algorithm can determine whether every program will halt',
          'It calculates when computers will shut down',
          'It measures internet speed',
          'It extends battery life',
        ],
      ),
      MillionaireQuestion(
        question: 'Kuantum bilgisayarlarda bilginin temel birimi nedir?',
        options: ['Bit', 'Byte', 'Qubit', 'Pixel'],
        correctAnswerIndex: 2,
        difficulty: 12,
        prize: 1000000,
        questionEn: 'What is the basic unit of information in quantum computers?',
        optionsEn: ['Bit', 'Byte', 'Qubit', 'Pixel'],
      ),
      MillionaireQuestion(
        question: 'P=NP problemi bilgisayar biliminde neyi sorgular?',
        options: ['Her hızlı doğrulanabilen problemin hızlı çözülüp çözülemeyeceğini', 'İnternetin hızını', 'Ekran çözünürlüğünü', 'Pil ömrünü'],
        correctAnswerIndex: 0,
        difficulty: 12,
        prize: 1000000,
        questionEn: 'What does the P=NP problem question in computer science?',
        optionsEn: ['Whether every quickly verifiable problem can also be quickly solved', 'Internet speed', 'Screen resolution', 'Battery life'],
      ),
      MillionaireQuestion(
        question: 'Yapay sinir ağları (Neural Networks) hangi biyolojik yapıdan ilham alır?',
        options: ['Kalp', 'Beyin/Nöronlar', 'Akciğer', 'Kas yapısı'],
        correctAnswerIndex: 1,
        difficulty: 12,
        prize: 1000000,
        questionEn: 'What biological structure inspires artificial neural networks?',
        optionsEn: ['Heart', 'Brain/Neurons', 'Lungs', 'Muscle structure'],
      ),
      MillionaireQuestion(
        question: 'Kuantum üstünlüğü (Quantum Supremacy) ne anlama gelir?',
        options: [
          'Bir kuantum bilgisayarın klasik bilgisayarların çözemeyeceği kadar hızlı bir problemi çözmesi',
          'İnternetin çok hızlı olması',
          'Bir oyunun çok popüler olması',
          'Bir telefonun çok pil vermesi'
        ],
        correctAnswerIndex: 0,
        difficulty: 12,
        prize: 1000000,
        questionEn: 'What does Quantum Supremacy mean?',
        optionsEn: [
          'A quantum computer solving a problem faster than classical computers can',
          'The internet being very fast',
          'A game being very popular',
          'A phone having great battery life',
        ],
      ),
    ];
  }

  /// Oyun için soru seti: her seviyeden rastgele 1 soru, seviye sırasına göre
  /// (kolaydan zora doğru, Seviye 1 -> Seviye 12).
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

  /// Ödül tutarını dile göre biçimlendirir (varsayılan Türkçe).
  static String formatPrize(int prize, {String lang = 'tr'}) {
    final isEn = lang == 'en';
    if (prize >= 1000000) {
      final value = (prize / 1000000).toStringAsFixed(prize % 1000000 == 0 ? 0 : 3);
      return isEn ? '₺$value Million' : '$value Milyon ₺';
    } else if (prize >= 1000) {
      final value = (prize / 1000).toStringAsFixed(prize % 1000 == 0 ? 0 : 3);
      return isEn ? '₺$value Thousand' : '$value Bin ₺';
    } else {
      return isEn ? '₺$prize' : '$prize ₺';
    }
  }
}
