import '../models/interactive_lesson_model.dart';
import 'scratch_lessons_data.dart';
import 'python_lessons_data.dart';
import 'arduino_lessons_data.dart';
import 'mblock_lessons_data.dart';
import 'html_lessons_data.dart';
import 'css_lessons_data.dart';
import 'java_lessons_data.dart';
import 'csharp_lessons_data.dart';

/// Bir kursun modulu: baslik, aciklama ve o modulun dersleri.
class CourseModule {
  const CourseModule({
    required this.title,
    required this.description,
    required this.emoji,
    required this.lessons,
    this.titleEn,
    this.titleDe,
    this.titleEs,
    this.descriptionEn,
    this.descriptionDe,
    this.descriptionEs,
  });

  final String title;
  final String description;
  final String emoji;
  final List<InteractiveLesson> lessons;

  /// Ceviriler opsiyonel; kendi dili yoksa Ingilizceye, o da yoksa
  /// Turkceye dusulur (bkz. [pickLang]).
  final String? titleEn;
  final String? titleDe;
  final String? titleEs;
  final String? descriptionEn;
  final String? descriptionDe;
  final String? descriptionEs;

  String titleFor(String lang) =>
      pickLang(title, titleEn, lang, titleDe, titleEs);
  String descriptionFor(String lang) =>
      pickLang(description, descriptionEn, lang, descriptionDe, descriptionEs);
}

/// Kurs -> modul eslemesi.
///
/// Bu esleme eskiden InteractiveCourseScreen'in icinde, State sinifinin
/// private bir metodunda duruyordu. Oradan cikarildi cunku:
///  * Bir kursun modulleri hic baglanmazsa ekran sessizce bos aciliyordu,
///    kimse fark etmiyordu (katalogda kurs gorunuyor, tiklayinca hicbir sey
///    yok). Artik test bunu yakaliyor - bkz. test/course_content_test.dart.
///  * Katalogdaki `totalLessons` ile gercek ders sayisi birbirinden
///    bagimsiz yaziliyordu ve zamanla ayrisiyordu.
class CourseModules {
  CourseModules._();

  /// Modulleri ekrana baglanmis kurslarin id listesi.
  ///
  /// DİKKAT: bu liste aynı zamanda KATALOĞUN YÖNLENDİRMESİ. Bir kurs
  /// buraya yazılmazsa katalogda görünür, modülleri de vardır, ama
  /// tıklayınca interaktif derslerin ekranı yerine tanıtım ekranı açılır
  /// — yani dersler yazılmıştır ve çocuk onlara ulaşamaz. mBlock kursu
  /// tam olarak bunu yaşadı. `test/course_content_test.dart` artık
  /// listeyi modüllerle karşılaştırıyor.
  static const List<String> wiredCourseIds = [
    'scratch',
    'mblock',
    'html',
    'css',
    'python',
    'arduino',
    'arduino_ide',
    'java',
    'csharp',
  ];

  /// Verilen kursun modulleri. Tanimsiz kurs icin bos liste doner.
  static List<CourseModule> forCourse(String courseId) {
    switch (courseId) {
      case 'scratch':
        return [
          CourseModule(
            title: 'Scratch\'a Merhaba',
            description: 'Blok programlamaya ilk adım',
            emoji: '👋',
            lessons: ScratchLessonsData.module1,
          ),
          CourseModule(
            title: 'Etkileşim & Kontrol',
            description: 'Koşullar ve hareket',
            emoji: '🎮',
            lessons: ScratchLessonsData.module2,
          ),
          CourseModule(
            title: 'Ilk Oyunun',
            description: 'Gerçek bir oyun yap!',
            emoji: '🚀',
            lessons: ScratchLessonsData.module3,
          ),
          CourseModule(
            title: 'Değişkenler & Puan',
            description: 'Bilgiyi sakla, puan tut',
            emoji: '🔢',
            lessons: ScratchLessonsData.module4,
          ),
          CourseModule(
            title: 'Klonlar',
            description: 'Kuklaları çoğalt',
            emoji: '👯',
            lessons: ScratchLessonsData.module5,
          ),
          CourseModule(
            title: 'Mesajlar & Yayınlar',
            description: 'Kuklalar arası iletişim',
            emoji: '📢',
            lessons: ScratchLessonsData.module6,
          ),
          CourseModule(
            title: 'Ses & Müzik',
            description: 'Oyununa ses ekle',
            emoji: '🎵',
            lessons: ScratchLessonsData.module7,
          ),
        ];
      case 'html':
        return [
          CourseModule(
            title: 'HTML\'e Giriş',
            titleEn: 'Getting Started with HTML',
            titleDe: 'Erste Schritte mit HTML',
            titleEs: 'Primeros pasos con HTML',
            description: 'Web sayfalarının iskeleti',
            descriptionEn: 'The skeleton of web pages',
            descriptionDe: 'Das Gerüst von Webseiten',
            descriptionEs: 'El esqueleto de las páginas web',
            emoji: '🌐',
            lessons: HtmlLessonsData.module1,
          ),
          CourseModule(
            title: 'Metin Etiketleri',
            titleEn: 'Text Tags',
            titleDe: 'Text-Tags',
            titleEs: 'Etiquetas de texto',
            description: 'Başlık ve paragraflar',
            descriptionEn: 'Headings and paragraphs',
            descriptionDe: 'Überschriften und Absätze',
            descriptionEs: 'Títulos y párrafos',
            emoji: '📝',
            lessons: HtmlLessonsData.module2,
          ),
          CourseModule(
            title: 'Bağlantı ve Görseller',
            titleEn: 'Links and Images',
            titleDe: 'Links und Bilder',
            titleEs: 'Enlaces e imágenes',
            description: 'Sayfaları birbirine bağla',
            descriptionEn: 'Connect pages together',
            descriptionDe: 'Seiten miteinander verbinden',
            descriptionEs: 'Conectar páginas entre sí',
            emoji: '🔗',
            lessons: HtmlLessonsData.module3,
          ),
          CourseModule(
            title: 'Listeler ve Tablolar',
            titleEn: 'Lists and Tables',
            titleDe: 'Listen und Tabellen',
            titleEs: 'Listas y tablas',
            description: 'Veriyi düzenli göster',
            descriptionEn: 'Present data in an organized way',
            descriptionDe: 'Daten geordnet darstellen',
            descriptionEs: 'Presentar datos de forma ordenada',
            emoji: '📋',
            lessons: HtmlLessonsData.module4,
          ),
          CourseModule(
            title: 'Formlar',
            titleEn: 'Forms',
            titleDe: 'Formulare',
            titleEs: 'Formularios',
            description: 'Kullanıcıdan veri al',
            descriptionEn: 'Collect data from users',
            descriptionDe: 'Daten von Nutzern sammeln',
            descriptionEs: 'Recoger datos de los usuarios',
            emoji: '📮',
            lessons: HtmlLessonsData.module5,
          ),
          CourseModule(
            title: 'Semantik HTML ve Proje',
            titleEn: 'Semantic HTML and Project',
            titleDe: 'Semantisches HTML und Projekt',
            titleEs: 'HTML semántico y proyecto',
            description: 'Anlamlı yapı ve final proje',
            descriptionEn: 'Meaningful structure and a final project',
            descriptionDe: 'Sinnvolle Struktur und ein Abschlussprojekt',
            descriptionEs: 'Estructura con sentido y un proyecto final',
            emoji: '🚀',
            lessons: HtmlLessonsData.module6,
          ),
        ];
      case 'css':
        return [
          CourseModule(
            title: 'CSS\'e Giriş',
            description: 'Renkler, yazı tipleri, seçiciler',
            emoji: '🎨',
            lessons: CssLessonsData.module1,
          ),
          CourseModule(
            title: 'Kutu Modeli',
            description: 'Boyut, kenarlık, gölge',
            emoji: '📦',
            lessons: CssLessonsData.module2,
          ),
          CourseModule(
            title: 'Yerleşim (Layout)',
            description: 'Flexbox ile modern tasarım',
            emoji: '📐',
            lessons: CssLessonsData.module3,
          ),
          CourseModule(
            title: 'Tasarım ve Proje',
            description: 'Hover, animasyon, final proje',
            emoji: '🚀',
            lessons: CssLessonsData.module4,
          ),
        ];
      case 'java':
        return [
          CourseModule(
            title: 'Java\'ya Giriş',
            description: 'Değişkenler ve ilk programın',
            emoji: '☕',
            lessons: JavaLessonsData.module1,
          ),
          CourseModule(
            title: 'Kontrol Yapıları',
            description: 'if-else, döngüler, diziler',
            emoji: '🔀',
            lessons: JavaLessonsData.module2,
          ),
          CourseModule(
            title: 'Nesne Yönelimi',
            description: 'Sınıf, metod, kalıtım',
            emoji: '🏗️',
            lessons: JavaLessonsData.module3,
          ),
          CourseModule(
            title: 'Projeler',
            description: 'Gerçek programlar yaz',
            emoji: '🚀',
            lessons: JavaLessonsData.module4,
          ),
        ];
      case 'csharp':
        return [
          CourseModule(
            title: 'C#\'a Giriş',
            description: 'Değişkenler ve ilk programın',
            emoji: '💜',
            lessons: CSharpLessonsData.module1,
          ),
          CourseModule(
            title: 'Kontrol Yapıları',
            description: 'if-else, döngüler, diziler',
            emoji: '🔀',
            lessons: CSharpLessonsData.module2,
          ),
          CourseModule(
            title: 'Nesne Yönelimi',
            description: 'Sınıf, metod, kalıtım',
            emoji: '🏗️',
            lessons: CSharpLessonsData.module3,
          ),
          CourseModule(
            title: 'Projeler',
            description: 'Gerçek programlar yaz',
            emoji: '🚀',
            lessons: CSharpLessonsData.module4,
          ),
        ];
      case 'python':
        return [
          CourseModule(
            title: 'Python Temelleri',
            description: 'print, değişkenler, matematik',
            emoji: '🐍',
            lessons: PythonLessonsData.module1,
          ),
          CourseModule(
            title: 'Kullanıcı Etkileşimi',
            description: 'input() ile veri al',
            emoji: '⌨️',
            lessons: PythonLessonsData.module2,
          ),
          CourseModule(
            title: 'If-Else Koşullar',
            description: 'Programın karar vermesi',
            emoji: '🔀',
            lessons: PythonLessonsData.module3,
          ),
          CourseModule(
            title: 'Döngüler',
            description: 'for ve while döngüsü',
            emoji: '🔁',
            lessons: PythonLessonsData.module4,
          ),
          CourseModule(
            title: 'Listeler',
            description: 'Birden fazla veri',
            emoji: '📋',
            lessons: PythonLessonsData.module5,
          ),
          CourseModule(
            title: 'Fonksiyonlar',
            description: 'Kendi komutların',
            emoji: '⚡',
            lessons: PythonLessonsData.module6,
          ),
          CourseModule(
            title: 'Sözlükler',
            description: 'Anahtar-değer çiftleri',
            emoji: '📖',
            lessons: PythonLessonsData.module7,
          ),
          CourseModule(
            title: 'Dosya İşlemleri',
            description: 'Dosya oku ve yaz',
            emoji: '📂',
            lessons: PythonLessonsData.module8,
          ),
          CourseModule(
            title: 'İleri Seviye Python',
            titleEn: 'Advanced Python',
            titleDe: 'Python für Fortgeschrittene',
            titleEs: 'Python avanzado',
            description: 'Hata yönetimi, kütüphaneler, comprehension, OOP',
            descriptionEn: 'Error handling, libraries, comprehensions, OOP',
            descriptionDe: 'Fehlerbehandlung, Bibliotheken, Comprehensions, OOP',
            descriptionEs: 'Manejo de errores, bibliotecas, comprensiones, POO',
            emoji: '🎓',
            lessons: PythonLessonsData.module9,
          ),
        ];
      case 'mblock':
        return [
          CourseModule(
            title: 'mBlock Nedir, Nerede Ne Var',
            titleEn: 'What mBlock Is, and What Is Where',
            titleDe: 'Was mBlock ist und was wo liegt',
            titleEs: 'Qué es mBlock y dónde está cada cosa',
            description: 'Editör, iki mod ve dokuz kategorilik palet',
            descriptionEn: 'The editor, the two modes, the nine categories',
            descriptionDe: 'Der Editor, die zwei Modi, die neun Kategorien',
            descriptionEs: 'El editor, los dos modos, las nueve categorías',
            emoji: '🧩',
            lessons: MBlockLessonsData.module1,
          ),
          CourseModule(
            title: 'İlk Programlar',
            titleEn: 'First Programs',
            titleDe: 'Erste Programme',
            titleEs: 'Primeros programas',
            description: 'Başlangıç bloğu, dijital çıkış, döngü',
            descriptionEn: 'The start block, digital output, the loop',
            descriptionDe: 'Der Startblock, der Digitalausgang, die Schleife',
            descriptionEs: 'El bloque de inicio, la salida digital, el bucle',
            emoji: '💡',
            lessons: MBlockLessonsData.module2,
          ),
          CourseModule(
            title: 'Kart Seni Dinliyor',
            titleEn: 'The Board Listens',
            titleDe: 'Die Platine hört zu',
            titleEs: 'La placa te escucha',
            description: 'Buton, potansiyometre, PWM ve harita',
            descriptionEn: 'Button, potentiometer, PWM and map',
            descriptionDe: 'Taster, Potentiometer, PWM und Karte',
            descriptionEs: 'Botón, potenciómetro, PWM y mapear',
            emoji: '🎛️',
            lessons: MBlockLessonsData.module3,
          ),
          CourseModule(
            title: 'Büyük Projeler',
            titleEn: 'Bigger Projects',
            titleDe: 'Größere Projekte',
            titleEs: 'Proyectos más grandes',
            description: 'Mesafe sensörü, servo, park sensörü, bariyer',
            descriptionEn: 'Distance sensor, servo, parking sensor, barrier',
            descriptionDe: 'Abstandssensor, Servo, Einparkhilfe, Schranke',
            descriptionEs: 'Sensor de distancia, servo, sensor de aparcamiento, barrera',
            emoji: '🚧',
            lessons: MBlockLessonsData.module4,
          ),
        ];
      case 'arduino':
        return [
          CourseModule(
            title: 'Arduino\'ya Giriş',
            description: 'Elektronik + kod dünyası',
            emoji: '🤖',
            lessons: ArduinoLessonsData.module1,
          ),
          CourseModule(
            title: 'Butonlar',
            description: 'Sayaç ve aç/kapa düğmesi',
            emoji: '🔘',
            lessons: ArduinoLessonsData.module2,
          ),
          CourseModule(
            title: 'Trafik Işığı & Potansiyometre',
            description: 'Çoklu LED ve analog giriş',
            emoji: '🚦',
            lessons: ArduinoLessonsData.module3,
          ),
          CourseModule(
            title: 'Buzzer & LDR',
            description: 'Melodi ve gece lambası',
            emoji: '🔊',
            lessons: ArduinoLessonsData.module4,
          ),
          CourseModule(
            title: 'Sensorler & Final Proje',
            description: 'Park sensörü ve cam sileceği',
            emoji: '📏',
            lessons: ArduinoLessonsData.module5,
          ),
        ];
      case 'arduino_ide':
        // Eskiden Arduino kursunun 6. modulu olan "gercek kod" icerigi ayri
        // bir kursa tasindi; blok kodlamayi bitiren cocuk buraya geciyor.
        return [
          CourseModule(
            title: 'Bloklardan Koda',
            titleEn: 'From Blocks to Code',
            titleDe: 'Von Blöcken zu Code',
            titleEs: 'De los bloques al código',
            description: 'Arduino IDE, ilk C++ programın ve seri port',
            descriptionEn: 'Arduino IDE, your first C++ program and the serial monitor',
            descriptionDe: 'Arduino IDE, dein erstes C++-Programm und der serielle Monitor',
            descriptionEs: 'Arduino IDE, tu primer programa en C++ y el monitor serie',
            emoji: '💻',
            lessons: ArduinoLessonsData.ideModule1,
          ),
          CourseModule(
            title: 'Fonksiyonlar',
            titleEn: 'Functions',
            titleDe: 'Funktionen',
            titleEs: 'Funciones',
            description: 'Kod tekrarını azalt, kendi fonksiyonlarını yaz',
            descriptionEn: 'Reduce repetition, write your own functions',
            descriptionDe: 'Wiederholungen verringern, eigene Funktionen schreiben',
            descriptionEs: 'Reducir repeticiones, escribir tus propias funciones',
            emoji: '🧩',
            lessons: ArduinoLessonsData.ideModule2,
          ),
          CourseModule(
            title: 'LCD Ekran & Final Proje',
            titleEn: 'LCD Screen & Final Project',
            titleDe: 'LCD-Display & Abschlussprojekt',
            titleEs: 'Pantalla LCD y proyecto final',
            description: 'I2C LCD ekran ve akıllı bitki sulama sistemi',
            descriptionEn: 'I2C LCD screens and a smart plant watering system',
            descriptionDe: 'I2C-LCD-Displays und eine smarte Pflanzenbewässerung',
            descriptionEs: 'Pantallas LCD I2C y un sistema inteligente de riego de plantas',
            emoji: '🌱',
            lessons: ArduinoLessonsData.ideModule3,
          ),
        ];
      default:
        return const [];
    }
  }

  /// Kursun gercek ders sayisi (modullerdeki derslerin toplami).
  static int lessonCount(String courseId) =>
      forCourse(courseId).fold(0, (sum, m) => sum + m.lessons.length);

  /// Kursun butun dersleri, modul sirasiyla duz liste halinde.
  static List<InteractiveLesson> allLessons(String courseId) =>
      forCourse(courseId).expand((m) => m.lessons).toList();
}
