import '../models/interactive_lesson_model.dart';
import 'modul_tekrar_sorulari.dart';
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
    this.tekrarSorulari = const [],
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

  /// Yalnizca modul sinavinda sorulan tekrar sorulari (bkz.
  /// ModulTekrarSorulari). Sinav bunlari derslerin icindeki sorularla
  /// birlikte topluyor.
  final List<MultipleChoiceStep> tekrarSorulari;

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
  ///
  /// Kurs basina BIR KEZ kuruluyor: ders verisinin bir kismi getter ile
  /// her cagrida yeniden olusturuluyordu ve bu fonksiyon kurs sayfasinin
  /// her build'inde (ilerleme karti, ders listesi, yol seridi) tekrar
  /// tekrar cagriliyor. Liste degistirilemez: paylasilan bir onbellek.
  static List<CourseModule> forCourse(String courseId) =>
      _onbellek.putIfAbsent(
          courseId, () => List.unmodifiable(_kur(courseId)));

  static final Map<String, List<CourseModule>> _onbellek = {};

  static List<CourseModule> _kur(String courseId) {
    switch (courseId) {
      case 'scratch':
        return [
          CourseModule(
            title: 'Scratch\'a Merhaba',
            description: 'Blok programlamaya ilk adım',
            titleEn: 'Hello, Scratch',
            titleDe: 'Hallo, Scratch',
            titleEs: 'Hola, Scratch',
            descriptionEn: 'Your first step into block coding',
            descriptionDe: 'Dein erster Schritt ins Blockprogrammieren',
            descriptionEs: 'Tu primer paso en la programación con bloques',
            emoji: '👋',
            lessons: ScratchLessonsData.module1,
          ),
          CourseModule(
            title: 'Etkileşim & Kontrol',
            description: 'Koşullar ve hareket',
            titleEn: 'Interaction & Control',
            titleDe: 'Interaktion & Steuerung',
            titleEs: 'Interacción y control',
            descriptionEn: 'Conditions and motion',
            descriptionDe: 'Bedingungen und Bewegung',
            descriptionEs: 'Condiciones y movimiento',
            emoji: '🎮',
            lessons: ScratchLessonsData.module2,
            tekrarSorulari: ModulTekrarSorulari.scratch2,
          ),
          CourseModule(
            title: 'İlk Oyunun',
            description: 'Gerçek bir oyun yap!',
            titleEn: 'Your First Game',
            titleDe: 'Dein erstes Spiel',
            titleEs: 'Tu primer juego',
            descriptionEn: 'Make a real game!',
            descriptionDe: 'Mach ein echtes Spiel!',
            descriptionEs: '¡Haz un juego de verdad!',
            emoji: '🚀',
            lessons: ScratchLessonsData.module3,
            tekrarSorulari: ModulTekrarSorulari.scratch3,
          ),
          CourseModule(
            title: 'Değişkenler & Puan',
            description: 'Bilgiyi sakla, puan tut',
            titleEn: 'Variables & Score',
            titleDe: 'Variablen & Punkte',
            titleEs: 'Variables y puntos',
            descriptionEn: 'Store information, keep score',
            descriptionDe: 'Infos speichern, Punkte zählen',
            descriptionEs: 'Guarda datos, lleva la puntuación',
            emoji: '🔢',
            lessons: ScratchLessonsData.module4,
          ),
          CourseModule(
            title: 'Klonlar',
            description: 'Kuklaları çoğalt',
            titleEn: 'Clones',
            titleDe: 'Klone',
            titleEs: 'Clones',
            descriptionEn: 'Multiply your sprites',
            descriptionDe: 'Figuren vervielfältigen',
            descriptionEs: 'Multiplica tus objetos',
            emoji: '👯',
            lessons: ScratchLessonsData.module5,
            tekrarSorulari: ModulTekrarSorulari.scratch5,
          ),
          CourseModule(
            title: 'Mesajlar & Yayınlar',
            description: 'Kuklalar arası iletişim',
            titleEn: 'Messages & Broadcasts',
            titleDe: 'Nachrichten & Senden',
            titleEs: 'Mensajes y envíos',
            descriptionEn: 'Sprites talking to each other',
            descriptionDe: 'Figuren reden miteinander',
            descriptionEs: 'Objetos que se comunican',
            emoji: '📢',
            lessons: ScratchLessonsData.module6,
            tekrarSorulari: ModulTekrarSorulari.scratch6,
          ),
          CourseModule(
            title: 'Ses & Müzik',
            description: 'Oyununa ses ekle',
            titleEn: 'Sound & Music',
            titleDe: 'Klang & Musik',
            titleEs: 'Sonido y música',
            descriptionEn: 'Add sound to your game',
            descriptionDe: 'Bring Klang in dein Spiel',
            descriptionEs: 'Añade sonido a tu juego',
            emoji: '🎵',
            lessons: ScratchLessonsData.module7,
            tekrarSorulari: ModulTekrarSorulari.scratch7,
          ),
          CourseModule(
            title: 'Kalem ve Çizim',
            titleEn: 'The Pen and Drawing',
            titleDe: 'Stift und Zeichnen',
            titleEs: 'El lápiz y el dibujo',
            description: 'Kalem indir, döngüyle şekil çiz, 360 kuralı',
            descriptionEn: 'Pen down, draw shapes with a loop, the rule of 360',
            descriptionDe: 'Stift ein, Formen mit Schleifen, die 360-Regel',
            descriptionEs: 'Bajar lápiz, figuras con bucles, la regla del 360',
            emoji: '✏️',
            lessons: ScratchLessonsData.module8,
            tekrarSorulari: ModulTekrarSorulari.scratch8,
          ),
          CourseModule(
            title: 'Operatörler ve Şans',
            titleEn: 'Operators and Chance',
            titleDe: 'Operatoren und Zufall',
            titleEs: 'Operadores y azar',
            description: 'Rastgele sayı, karşılaştırma, ve / veya',
            descriptionEn: 'Random numbers, comparisons, and / or',
            descriptionDe: 'Zufallszahlen, Vergleiche, und / oder',
            descriptionEs: 'Números aleatorios, comparaciones, y / o',
            emoji: '🎲',
            lessons: ScratchLessonsData.module9,
            tekrarSorulari: ModulTekrarSorulari.scratch9,
          ),
          CourseModule(
            title: 'Listeler',
            titleEn: 'Lists',
            titleDe: 'Listen',
            titleEs: 'Listas',
            description: 'Liste oluştur, öğe ekle, rastgele öğe çek',
            descriptionEn: 'Make a list, add items, pull a random one',
            descriptionDe: 'Liste anlegen, Elemente hinzufügen, zufällig ziehen',
            descriptionEs: 'Crea una lista, añade elementos, saca uno al azar',
            emoji: '📋',
            lessons: ScratchLessonsData.module10,
            tekrarSorulari: ModulTekrarSorulari.scratch10,
          ),
          CourseModule(
            title: 'Kendi Bloğun',
            titleEn: 'Your Own Block',
            titleDe: 'Dein eigener Block',
            titleEs: 'Tu propio bloque',
            description: 'Blok tanımla, çağır, girdi ver',
            descriptionEn: 'Define a block, call it, give it an input',
            descriptionDe: 'Block definieren, aufrufen, Eingabe geben',
            descriptionEs: 'Define un bloque, llámalo, dale una entrada',
            emoji: '🧱',
            lessons: ScratchLessonsData.module11,
            tekrarSorulari: ModulTekrarSorulari.scratch11,
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
            titleEn: 'Intro to CSS',
            titleDe: 'Einstieg in CSS',
            titleEs: 'Introducción a CSS',
            descriptionEn: 'Colours, fonts, selectors',
            descriptionDe: 'Farben, Schriften, Selektoren',
            descriptionEs: 'Colores, fuentes, selectores',
            emoji: '🎨',
            lessons: CssLessonsData.module1,
          ),
          CourseModule(
            title: 'Kutu Modeli',
            description: 'Boyut, kenarlık, gölge',
            titleEn: 'The Box Model',
            titleDe: 'Das Box-Modell',
            titleEs: 'El modelo de caja',
            descriptionEn: 'Size, border, shadow',
            descriptionDe: 'Größe, Rahmen, Schatten',
            descriptionEs: 'Tamaño, borde, sombra',
            emoji: '📦',
            lessons: CssLessonsData.module2,
          ),
          CourseModule(
            title: 'Yerleşim (Layout)',
            description: 'Flexbox ile modern tasarım',
            titleEn: 'Layout',
            titleDe: 'Layout',
            titleEs: 'Maquetación',
            descriptionEn: 'Modern design with Flexbox',
            descriptionDe: 'Modernes Design mit Flexbox',
            descriptionEs: 'Diseño moderno con Flexbox',
            emoji: '📐',
            lessons: CssLessonsData.module3,
          ),
          CourseModule(
            title: 'Tasarım ve Proje',
            description: 'Hover, animasyon, final proje',
            titleEn: 'Design and Project',
            titleDe: 'Design und Projekt',
            titleEs: 'Diseño y proyecto',
            descriptionEn: 'Hover, animation, final project',
            descriptionDe: 'Hover, Animation, Abschlussprojekt',
            descriptionEs: 'Hover, animación, proyecto final',
            emoji: '🚀',
            lessons: CssLessonsData.module4,
          ),
        ];
      case 'java':
        return [
          CourseModule(
            title: 'Java\'ya Giriş',
            description: 'Değişkenler ve ilk programın',
            titleEn: 'Intro to Java',
            titleDe: 'Einstieg in Java',
            titleEs: 'Introducción a Java',
            descriptionEn: 'Variables and your first program',
            descriptionDe: 'Variablen und dein erstes Programm',
            descriptionEs: 'Variables y tu primer programa',
            emoji: '☕',
            lessons: JavaLessonsData.module1,
          ),
          CourseModule(
            title: 'Kontrol Yapıları',
            description: 'if-else, döngüler, diziler',
            titleEn: 'Control Structures',
            titleDe: 'Kontrollstrukturen',
            titleEs: 'Estructuras de control',
            descriptionEn: 'if-else, loops, arrays',
            descriptionDe: 'if-else, Schleifen, Arrays',
            descriptionEs: 'if-else, bucles, arrays',
            emoji: '🔀',
            lessons: JavaLessonsData.module2,
          ),
          CourseModule(
            title: 'Nesne Yönelimi',
            description: 'Sınıf, metod, kalıtım',
            titleEn: 'Object Orientation',
            titleDe: 'Objektorientierung',
            titleEs: 'Orientación a objetos',
            descriptionEn: 'Classes, methods, inheritance',
            descriptionDe: 'Klassen, Methoden, Vererbung',
            descriptionEs: 'Clases, métodos, herencia',
            emoji: '🏗️',
            lessons: JavaLessonsData.module3,
          ),
          CourseModule(
            title: 'Projeler',
            description: 'Gerçek programlar yaz',
            titleEn: 'Projects',
            titleDe: 'Projekte',
            titleEs: 'Proyectos',
            descriptionEn: 'Write real programs',
            descriptionDe: 'Schreib echte Programme',
            descriptionEs: 'Escribe programas de verdad',
            emoji: '🚀',
            lessons: JavaLessonsData.module4,
          ),
        ];
      case 'csharp':
        return [
          CourseModule(
            title: 'C#\'a Giriş',
            description: 'Değişkenler ve ilk programın',
            titleEn: 'Intro to C#',
            titleDe: 'Einstieg in C#',
            titleEs: 'Introducción a C#',
            descriptionEn: 'Variables and your first program',
            descriptionDe: 'Variablen und dein erstes Programm',
            descriptionEs: 'Variables y tu primer programa',
            emoji: '💜',
            lessons: CSharpLessonsData.module1,
          ),
          CourseModule(
            title: 'Kontrol Yapıları',
            description: 'if-else, döngüler, diziler',
            titleEn: 'Control Structures',
            titleDe: 'Kontrollstrukturen',
            titleEs: 'Estructuras de control',
            descriptionEn: 'if-else, loops, arrays',
            descriptionDe: 'if-else, Schleifen, Arrays',
            descriptionEs: 'if-else, bucles, arrays',
            emoji: '🔀',
            lessons: CSharpLessonsData.module2,
          ),
          CourseModule(
            title: 'Nesne Yönelimi',
            description: 'Sınıf, metod, kalıtım',
            titleEn: 'Object Orientation',
            titleDe: 'Objektorientierung',
            titleEs: 'Orientación a objetos',
            descriptionEn: 'Classes, methods, inheritance',
            descriptionDe: 'Klassen, Methoden, Vererbung',
            descriptionEs: 'Clases, métodos, herencia',
            emoji: '🏗️',
            lessons: CSharpLessonsData.module3,
          ),
          CourseModule(
            title: 'Projeler',
            description: 'Gerçek programlar yaz',
            titleEn: 'Projects',
            titleDe: 'Projekte',
            titleEs: 'Proyectos',
            descriptionEn: 'Write real programs',
            descriptionDe: 'Schreib echte Programme',
            descriptionEs: 'Escribe programas de verdad',
            emoji: '🚀',
            lessons: CSharpLessonsData.module4,
          ),
        ];
      case 'python':
        return [
          CourseModule(
            title: 'Python Temelleri',
            description: 'print, değişkenler, matematik',
            titleEn: 'Python Basics',
            titleDe: 'Python-Grundlagen',
            titleEs: 'Fundamentos de Python',
            descriptionEn: 'print, variables, maths',
            descriptionDe: 'print, Variablen, Mathe',
            descriptionEs: 'print, variables, matemáticas',
            emoji: '🐍',
            lessons: PythonLessonsData.module1,
          ),
          CourseModule(
            title: 'Kullanıcı Etkileşimi',
            description: 'input() ile veri al',
            titleEn: 'User Input',
            titleDe: 'Benutzereingaben',
            titleEs: 'Interacción con el usuario',
            descriptionEn: 'Get data with input()',
            descriptionDe: 'Daten mit input() holen',
            descriptionEs: 'Recibe datos con input()',
            emoji: '⌨️',
            lessons: PythonLessonsData.module2,
          ),
          CourseModule(
            title: 'If-Else Koşullar',
            description: 'Programın karar vermesi',
            titleEn: 'If-Else Conditions',
            titleDe: 'If-Else-Bedingungen',
            titleEs: 'Condiciones if-else',
            descriptionEn: 'Letting the program decide',
            descriptionDe: 'Das Programm entscheidet',
            descriptionEs: 'El programa toma decisiones',
            emoji: '🔀',
            lessons: PythonLessonsData.module3,
          ),
          CourseModule(
            title: 'Döngüler',
            description: 'for ve while döngüsü',
            titleEn: 'Loops',
            titleDe: 'Schleifen',
            titleEs: 'Bucles',
            descriptionEn: 'for and while loops',
            descriptionDe: 'for- und while-Schleifen',
            descriptionEs: 'Bucles for y while',
            emoji: '🔁',
            lessons: PythonLessonsData.module4,
          ),
          CourseModule(
            title: 'Listeler',
            description: 'Birden fazla veri',
            titleEn: 'Lists',
            titleDe: 'Listen',
            titleEs: 'Listas',
            descriptionEn: 'Many values at once',
            descriptionDe: 'Mehrere Werte auf einmal',
            descriptionEs: 'Varios datos a la vez',
            emoji: '📋',
            lessons: PythonLessonsData.module5,
          ),
          CourseModule(
            title: 'Fonksiyonlar',
            description: 'Kendi komutların',
            titleEn: 'Functions',
            titleDe: 'Funktionen',
            titleEs: 'Funciones',
            descriptionEn: 'Your own commands',
            descriptionDe: 'Deine eigenen Befehle',
            descriptionEs: 'Tus propios comandos',
            emoji: '⚡',
            lessons: PythonLessonsData.module6,
          ),
          CourseModule(
            title: 'Sözlükler',
            description: 'Anahtar-değer çiftleri',
            titleEn: 'Dictionaries',
            titleDe: 'Dictionaries',
            titleEs: 'Diccionarios',
            descriptionEn: 'Key-value pairs',
            descriptionDe: 'Schlüssel-Wert-Paare',
            descriptionEs: 'Pares clave-valor',
            emoji: '📖',
            lessons: PythonLessonsData.module7,
          ),
          CourseModule(
            title: 'Dosya İşlemleri',
            description: 'Dosya oku ve yaz',
            titleEn: 'Working with Files',
            titleDe: 'Arbeiten mit Dateien',
            titleEs: 'Trabajar con archivos',
            descriptionEn: 'Read and write files',
            descriptionDe: 'Dateien lesen und schreiben',
            descriptionEs: 'Lee y escribe archivos',
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
          // Kart takmadan geçen ilk modül. Eskiden kurs doğrudan cihaz
          // sekmesi ve yükleme modu anlatımıyla başlıyordu; çocuk tek blok
          // sürüklememişken bunlar havada kalıyordu. mBlock Scratch 3.0
          // üzerine kurulu olduğu için ilk gün kukla tarafında kablosuz
          // program yazılabiliyor — donanım harmanı bir sonraki modülde
          // başlıyor ve orada anlam kazanıyor.
          CourseModule(
            title: 'Bloklarla Başla',
            titleEn: 'Start with Blocks',
            titleDe: 'Fang mit Blöcken an',
            titleEs: 'Empieza con bloques',
            description: 'Kablosuz ilk üç ders: palet, sıra, tekrar',
            descriptionEn: 'Three cable-free lessons: palette, order, repeat',
            descriptionDe: 'Drei Lektionen ohne Kabel: Palette, Reihenfolge, Wiederholung',
            descriptionEs: 'Tres lecciones sin cables: paleta, orden, repetición',
            emoji: '🟩',
            lessons: MBlockLessonsData.module0,
          ),
          CourseModule(
            title: 'Karta Geçiş: Cihaz Sekmesi',
            titleEn: 'Moving to the Board: the Devices Tab',
            titleDe: 'Ab zur Platine: der Reiter Geräte',
            titleEs: 'Pasar a la placa: la pestaña Dispositivos',
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
            tekrarSorulari: ModulTekrarSorulari.mblock3,
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
            tekrarSorulari: ModulTekrarSorulari.mblock5,
          ),
          // Projeler en sonda: derslerde öğrenilen parçaları birleştirip
          // bitmiş bir şey çıkarmak, parçaları öğrendikten sonra anlam
          // kazanıyor. Proje mBlock 5'te kuruluyor, uygulama rehber.
          CourseModule(
            title: 'Projeler',
            titleEn: 'Projects',
            titleDe: 'Projekte',
            titleEs: 'Proyectos',
            description: 'Akvaryum, Dans Partisi, Elma Toplama Oyunu',
            descriptionEn: 'Aquarium, Dance Party, Apple Catcher game',
            descriptionDe: 'Aquarium, Tanzparty, Spiel Äpfel fangen',
            descriptionEs: 'Acuario, Fiesta de baile, juego Atrapa manzanas',
            emoji: '🐠',
            lessons: MBlockLessonsData.module5,
          ),
        ];
      case 'arduino':
        return [
          CourseModule(
            title: 'Arduino\'ya Giriş',
            description: 'Elektronik + kod dünyası',
            titleEn: 'Intro to Arduino',
            titleDe: 'Einstieg in Arduino',
            titleEs: 'Introducción a Arduino',
            descriptionEn: 'Electronics meets code',
            descriptionDe: 'Elektronik trifft Code',
            descriptionEs: 'Electrónica y código',
            emoji: '🤖',
            lessons: ArduinoLessonsData.module1,
          ),
          CourseModule(
            title: 'Butonlar',
            description: 'Sayaç ve aç/kapa düğmesi',
            titleEn: 'Buttons',
            titleDe: 'Taster',
            titleEs: 'Botones',
            descriptionEn: 'A counter and an on/off switch',
            descriptionDe: 'Zähler und Ein-/Aus-Schalter',
            descriptionEs: 'Un contador y un interruptor',
            emoji: '🔘',
            lessons: ArduinoLessonsData.module2,
          ),
          CourseModule(
            title: 'Trafik Işığı & Potansiyometre',
            description: 'Çoklu LED ve analog giriş',
            titleEn: 'Traffic Light & Potentiometer',
            titleDe: 'Ampel & Potentiometer',
            titleEs: 'Semáforo y potenciómetro',
            descriptionEn: 'Several LEDs and analog input',
            descriptionDe: 'Mehrere LEDs und analoger Eingang',
            descriptionEs: 'Varios LED y entrada analógica',
            emoji: '🚦',
            lessons: ArduinoLessonsData.module3,
          ),
          CourseModule(
            title: 'Buzzer & LDR',
            description: 'Melodi ve gece lambası',
            titleEn: 'Buzzer & LDR',
            titleDe: 'Summer & LDR',
            titleEs: 'Zumbador y LDR',
            descriptionEn: 'A melody and a night light',
            descriptionDe: 'Melodie und Nachtlicht',
            descriptionEs: 'Una melodía y una luz nocturna',
            emoji: '🔊',
            lessons: ArduinoLessonsData.module4,
          ),
          CourseModule(
            title: 'Sensörler & Final Proje',
            description: 'Park sensörü ve cam sileceği',
            titleEn: 'Sensors & Final Project',
            titleDe: 'Sensoren & Abschlussprojekt',
            titleEs: 'Sensores y proyecto final',
            descriptionEn: 'Parking sensor and wiper',
            descriptionDe: 'Parksensor und Scheibenwischer',
            descriptionEs: 'Sensor de aparcamiento y limpiaparabrisas',
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
