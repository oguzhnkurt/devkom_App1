import '../models/course_model.dart';

/// Sample lessons for all courses
class LessonsData {
  /// Get lessons for a specific course
  static List<Lesson> getLessonsForCourse(String courseId) {
    return _allLessons[courseId] ?? [];
  }

  /// All lessons organized by course ID
  static final Map<String, List<Lesson>> _allLessons = {
    // ==========================================
    // PYTHON LESSONS
    // ==========================================
    'python': [
      Lesson(
        id: 'python_01',
        courseId: 'python',
        title: 'Python\'a Giriş',
        titleEn: 'Introduction to Python',
        titleDe: 'Einführung in Python',
        titleEs: 'Introducción a Python',
        description: 'Python nedir, neden öğrenmeli?',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'py01_1',
            type: ContentType.heading,
            content: 'Python Nedir?',
          ),
          LessonContent(
            id: 'py01_2',
            type: ContentType.text,
            content: 'Python, okunması ve yazılması kolay, güçlü bir programlama dilidir. 1991\'de Guido van Rossum tarafından olusturulmustur.',
          ),
          LessonContent(
            id: 'py01_3',
            type: ContentType.note,
            content: 'Python ismi, Monty Python adlı komedi grubundan gelmektedir!',
          ),
          LessonContent(
            id: 'py01_4',
            type: ContentType.heading,
            content: 'Neden Python?',
          ),
          LessonContent(
            id: 'py01_5',
            type: ContentType.text,
            content: '• Öğrenmesi kolay\n• Güçlü kütüphaneler\n• Yapay zeka ve veri biliminde lider\n• Web, oyun, otomasyon her yerde',
          ),
        ],
      ),
      Lesson(
        id: 'python_02',
        courseId: 'python',
        title: 'İlk Python Kodun',
        titleEn: 'Your First Python Code',
        titleDe: 'Dein erster Python-Code',
        titleEs: 'Tu primer código Python',
        description: 'Hello World yazalım!',
        order: 2,
        estimatedMinutes: 8,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'py02_1',
            type: ContentType.heading,
            content: 'Hello World!',
          ),
          LessonContent(
            id: 'py02_2',
            type: ContentType.text,
            content: 'Her programcının ilk yazdığı kod: ekrana mesaj yazdirma.',
          ),
          LessonContent(
            id: 'py02_3',
            type: ContentType.code,
            content: 'print("Merhaba Dünya!")',
            language: 'python',
            isInteractive: true,
          ),
          LessonContent(
            id: 'py02_4',
            type: ContentType.output,
            content: 'Merhaba Dünya!',
          ),
          LessonContent(
            id: 'py02_5',
            type: ContentType.task,
            content: 'Şimdi sen dene! Kendi adını yazdıran bir kod yaz.',
            hint: 'print("Benim adım ...")',
          ),
        ],
      ),
      Lesson(
        id: 'python_03',
        courseId: 'python',
        title: 'Değişkenler',
        titleEn: 'Variables',
        titleDe: 'Variablen',
        titleEs: 'Variables',
        description: 'Verileri saklamayı öğren',
        order: 3,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'py03_1',
            type: ContentType.heading,
            content: 'Değişken Nedir?',
          ),
          LessonContent(
            id: 'py03_2',
            type: ContentType.text,
            content: 'Değişkenler, verileri sakladığımız kutular gibidir. Bir isim verip içine değer koyarız.',
          ),
          LessonContent(
            id: 'py03_3',
            type: ContentType.code,
            content: '''isim = "Ahmet"
yas = 12
boy = 1.45

print(isim)
print(yas)
print(boy)''',
            language: 'python',
            isInteractive: true,
          ),
          LessonContent(
            id: 'py03_4',
            type: ContentType.output,
            content: 'Ahmet\n12\n1.45',
          ),
        ],
      ),
      Lesson(
        id: 'python_04',
        courseId: 'python',
        title: 'Veri Tipleri',
        titleEn: 'Data Types',
        titleDe: 'Datentypen',
        titleEs: 'Tipos de datos',
        description: 'String, int, float, bool',
        order: 4,
        estimatedMinutes: 12,
        type: LessonType.theory,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'py04_1',
            type: ContentType.heading,
            content: 'Temel Veri Tipleri',
          ),
          LessonContent(
            id: 'py04_2',
            type: ContentType.text,
            content: 'Python\'da 4 temel veri tipi vardır:',
          ),
          LessonContent(
            id: 'py04_3',
            type: ContentType.code,
            content: '''# String (metin)
isim = "Python"

# Integer (tam sayi)
yas = 30

# Float (ondalikli sayi)
pi = 3.14

# Boolean (dogru/yanlis)
eglenceli = True''',
            language: 'python',
          ),
        ],
      ),
      Lesson(
        id: 'python_05',
        courseId: 'python',
        title: 'Matematik İşlemleri',
        titleEn: 'Maths Operations',
        titleDe: 'Rechenoperationen',
        titleEs: 'Operaciones matemáticas',
        description: 'Toplama, çıkarma, çarpma, bölme',
        order: 5,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'py05_1',
            type: ContentType.heading,
            content: 'Aritmetik Operatörler',
          ),
          LessonContent(
            id: 'py05_2',
            type: ContentType.code,
            content: '''a = 10
b = 3

print(a + b)   # Toplama: 13
print(a - b)   # Cikarma: 7
print(a * b)   # Carpma: 30
print(a / b)   # Bolme: 3.33...
print(a // b)  # Tam bolme: 3
print(a % b)   # Mod (kalan): 1
print(a ** b)  # Us alma: 1000''',
            language: 'python',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // HTML LESSONS
    // ==========================================
    'html': [
      Lesson(
        id: 'html_01',
        courseId: 'html',
        title: 'HTML\'e Giriş',
        titleEn: 'Introduction to HTML',
        titleDe: 'Einführung in HTML',
        titleEs: 'Introducción a HTML',
        description: 'HTML nedir, ne ise yarar?',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'html01_1',
            type: ContentType.heading,
            content: 'HTML Nedir?',
          ),
          LessonContent(
            id: 'html01_2',
            type: ContentType.text,
            content: 'HTML (HyperText Markup Language), web sayfalarının iskeletini oluşturan dildir. Tüm web siteleri HTML ile başlar.',
          ),
          LessonContent(
            id: 'html01_3',
            type: ContentType.note,
            content: 'HTML bir programlama dili değil, işaret dilidir (markup language).',
          ),
        ],
      ),
      Lesson(
        id: 'html_02',
        courseId: 'html',
        title: 'İlk HTML Sayfan',
        titleEn: 'Your First HTML Page',
        titleDe: 'Deine erste HTML-Seite',
        titleEs: 'Tu primera página HTML',
        description: 'Temel HTML yapısı',
        order: 2,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'html02_1',
            type: ContentType.heading,
            content: 'HTML Doküman Yapısı',
          ),
          LessonContent(
            id: 'html02_2',
            type: ContentType.code,
            content: '''<!DOCTYPE html>
<html>
<head>
    <title>Ilk Sayfam</title>
</head>
<body>
    <h1>Merhaba Dunya!</h1>
    <p>Bu benim ilk web sayfam.</p>
</body>
</html>''',
            language: 'html',
            isInteractive: true,
          ),
        ],
      ),
      Lesson(
        id: 'html_03',
        courseId: 'html',
        title: 'Başlıklar',
        description: 'h1, h2, h3... etiketleri',
        order: 3,
        estimatedMinutes: 8,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'html03_1',
            type: ContentType.heading,
            content: 'Başlık Etiketleri',
          ),
          LessonContent(
            id: 'html03_2',
            type: ContentType.text,
            content: 'HTML\'de 6 seviye başlık vardır: h1 en büyük, h6 en küçük.',
          ),
          LessonContent(
            id: 'html03_3',
            type: ContentType.code,
            content: '''<h1>En Buyuk Baslik</h1>
<h2>Ikinci Seviye</h2>
<h3>Ucuncu Seviye</h3>
<h4>Dorduncu Seviye</h4>
<h5>Besinci Seviye</h5>
<h6>En Kucuk Baslik</h6>''',
            language: 'html',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // JAVASCRIPT LESSONS
    // ==========================================
    'javascript': [
      Lesson(
        id: 'js_01',
        courseId: 'javascript',
        title: 'JavaScript\'e Giriş',
        titleEn: 'Introduction to JavaScript',
        titleDe: 'Einführung in JavaScript',
        titleEs: 'Introducción a JavaScript',
        description: 'Web\'in programlama dili',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'js01_1',
            type: ContentType.heading,
            content: 'JavaScript Nedir?',
          ),
          LessonContent(
            id: 'js01_2',
            type: ContentType.text,
            content: 'JavaScript, web sayfalarını canlandiran programlama dilidir. Butonlara tıklandığında, formlara yazıldığında JavaScript çalışır.',
          ),
        ],
      ),
      Lesson(
        id: 'js_02',
        courseId: 'javascript',
        title: 'Değişkenler: let ve const',
        description: 'Modern değişken tanımlama',
        order: 2,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'js02_1',
            type: ContentType.heading,
            content: 'let ve const',
          ),
          LessonContent(
            id: 'js02_2',
            type: ContentType.code,
            content: '''// Degisebilir deger icin let
let isim = "Ahmet";
isim = "Mehmet"; // degistirilebilir

// Sabit deger icin const
const PI = 3.14159;
// PI = 3; // HATA! const degistirilemez

console.log(isim);
console.log(PI);''',
            language: 'javascript',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // DART LESSONS
    // ==========================================
    'dart': [
      Lesson(
        id: 'dart_01',
        courseId: 'dart',
        title: 'Dart\'a Giriş',
        titleEn: 'Introduction to Dart',
        titleDe: 'Einführung in Dart',
        titleEs: 'Introducción a Dart',
        description: 'Flutter\'in dili Dart',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'dart01_1',
            type: ContentType.heading,
            content: 'Dart Nedir?',
          ),
          LessonContent(
            id: 'dart01_2',
            type: ContentType.text,
            content: 'Dart, Google tarafından geliştirilen modern bir programlama dilidir. Flutter ile mobil, web ve masaüstü uygulamalar gelistirilir.',
          ),
        ],
      ),
      Lesson(
        id: 'dart_02',
        courseId: 'dart',
        title: 'Hello World',
        description: 'İlk Dart programın',
        order: 2,
        estimatedMinutes: 8,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'dart02_1',
            type: ContentType.code,
            content: '''void main() {
  print('Merhaba Dunya!');

  String isim = 'DevEducation';
  int yas = 1;

  print('Uygulama: \$isim');
  print('Yas: \$yas');
}''',
            language: 'dart',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // ARDUINO LESSONS
    // ==========================================
    'arduino': [
      Lesson(
        id: 'arduino_01',
        courseId: 'arduino',
        title: 'Arduino\'ya Giriş',
        titleEn: 'Introduction to Arduino',
        titleDe: 'Einführung in Arduino',
        titleEs: 'Introducción a Arduino',
        description: 'Mikrodenetleyici dünyası',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'ard01_1',
            type: ContentType.heading,
            content: 'Arduino Nedir?',
          ),
          LessonContent(
            id: 'ard01_2',
            type: ContentType.text,
            content: 'Arduino, elektronik projeleri programlamanizi sağlayan açık kaynaklı bir platformdur. LED yakma, motor kontrolü, sensör okuma gibi işler yapabilirsiniz.',
          ),
        ],
      ),
      Lesson(
        id: 'arduino_02',
        courseId: 'arduino',
        title: 'LED Yakma',
        titleEn: 'Lighting an LED',
        titleDe: 'Eine LED zum Leuchten bringen',
        titleEs: 'Encender un LED',
        description: 'İlk Arduino projen',
        order: 2,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'ard02_1',
            type: ContentType.heading,
            content: 'Blink - LED Yakıp Söndürme',
          ),
          LessonContent(
            id: 'ard02_2',
            type: ContentType.code,
            content: '''void setup() {
  pinMode(13, OUTPUT);  // 13 numarali pini cikis yap
}

void loop() {
  digitalWrite(13, HIGH);  // LED yak
  delay(1000);             // 1 saniye bekle
  digitalWrite(13, LOW);   // LED sondur
  delay(1000);             // 1 saniye bekle
}''',
            language: 'cpp',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // SCRATCH LESSONS
    // ==========================================
    'scratch': [
      Lesson(
        id: 'scratch_01',
        courseId: 'scratch',
        title: 'Scratch\'a Giriş',
        titleEn: 'Introduction to Scratch',
        titleDe: 'Einführung in Scratch',
        titleEs: 'Introducción a Scratch',
        description: 'Blok tabanlı kodlama',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'scr01_1',
            type: ContentType.heading,
            content: 'Scratch Nedir?',
          ),
          LessonContent(
            id: 'scr01_2',
            type: ContentType.text,
            content: 'Scratch, MIT tarafından geliştirilen görsel programlama dilidir. Renkli blokları birleştirerek oyunlar ve animasyonlar yapabilirsin!',
          ),
          LessonContent(
            id: 'scr01_3',
            type: ContentType.note,
            content: 'Scratch, kodlamaya yeni başlayan herkes için tasarlanmistir.',
          ),
        ],
      ),
    ],

    // ==========================================
    // CSS LESSONS
    // ==========================================
    'css': [
      Lesson(
        id: 'css_01',
        courseId: 'css',
        title: 'CSS\'e Giriş',
        titleEn: 'Introduction to CSS',
        titleDe: 'Einführung in CSS',
        titleEs: 'Introducción a CSS',
        description: 'Web sayfalarını guzelleştir',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'css01_1',
            type: ContentType.heading,
            content: 'CSS Nedir?',
          ),
          LessonContent(
            id: 'css01_2',
            type: ContentType.text,
            content: 'CSS (Cascading Style Sheets), HTML elemanlarının görünümünü değiştiren dildir. Renkler, fontlar, boyutlar, yerleşim - hepsi CSS ile yapılır.',
          ),
        ],
      ),
      Lesson(
        id: 'css_02',
        courseId: 'css',
        title: 'Renkler ve Arka Plan',
        description: 'color ve background',
        order: 2,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'css02_1',
            type: ContentType.code,
            content: '''h1 {
  color: blue;
  background-color: yellow;
}

p {
  color: #333333;
  background-color: #f0f0f0;
}''',
            language: 'css',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // SQL LESSONS
    // ==========================================
    'sql': [
      Lesson(
        id: 'sql_01',
        courseId: 'sql',
        title: 'SQL\'e Giriş',
        titleEn: 'Introduction to SQL',
        titleDe: 'Einführung in SQL',
        titleEs: 'Introducción a SQL',
        description: 'Veritabani sorgulama',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'sql01_1',
            type: ContentType.heading,
            content: 'SQL Nedir?',
          ),
          LessonContent(
            id: 'sql01_2',
            type: ContentType.text,
            content: 'SQL (Structured Query Language), veritabanlarindaki verileri sorgulamak, eklemek, güncellemek ve silmek için kullanılan dildir.',
          ),
        ],
      ),
      Lesson(
        id: 'sql_02',
        courseId: 'sql',
        title: 'SELECT Sorgusu',
        description: 'Veri çekmeyi öğren',
        order: 2,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'sql02_1',
            type: ContentType.code,
            content: '''-- Tum verileri getir
SELECT * FROM ogrenciler;

-- Belirli sutunlari getir
SELECT isim, yas FROM ogrenciler;

-- Kosul ile filtrele
SELECT * FROM ogrenciler WHERE yas > 18;''',
            language: 'sql',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // C LESSONS
    // ==========================================
    'c': [
      Lesson(
        id: 'c_01',
        courseId: 'c',
        title: 'C Diline Giriş',
        titleEn: 'Introduction to C',
        titleDe: 'Einführung in C',
        titleEs: 'Introducción a C',
        description: 'Tüm dillerin atası',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'c01_1',
            type: ContentType.heading,
            content: 'C Dili Nedir?',
          ),
          LessonContent(
            id: 'c01_2',
            type: ContentType.text,
            content: 'C, 1972\'de Dennis Ritchie tarafından geliştirilmiş, sistem programlamanın temelini oluşturan dildir. Linux, Windows çekirdekleri C ile yazılmıştır.',
          ),
        ],
      ),
      Lesson(
        id: 'c_02',
        courseId: 'c',
        title: 'Hello World',
        description: 'İlk C programın',
        order: 2,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'c02_1',
            type: ContentType.code,
            content: '''#include <stdio.h>

int main() {
    printf("Merhaba Dunya!\\n");
    return 0;
}''',
            language: 'c',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // GO LESSONS
    // ==========================================
    'go': [
      Lesson(
        id: 'go_01',
        courseId: 'go',
        title: 'Go\'ya Giriş',
        titleEn: 'Introduction to Go',
        titleDe: 'Einführung in Go',
        titleEs: 'Introducción a Go',
        description: 'Google\'in basit dili',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'go01_1',
            type: ContentType.heading,
            content: 'Go (Golang) Nedir?',
          ),
          LessonContent(
            id: 'go01_2',
            type: ContentType.text,
            content: 'Go, Google\'da geliştirilen basit, hızlı ve verimli bir programlama dilidir. Özellikle sunucu uygulamaları ve mikroservisler için idealdir.',
          ),
        ],
      ),
      Lesson(
        id: 'go_02',
        courseId: 'go',
        title: 'Hello World',
        description: 'İlk Go programın',
        order: 2,
        estimatedMinutes: 8,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'go02_1',
            type: ContentType.code,
            content: '''package main

import "fmt"

func main() {
    fmt.Println("Merhaba Dunya!")
}''',
            language: 'go',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // RUST LESSONS
    // ==========================================
    'rust': [
      Lesson(
        id: 'rust_01',
        courseId: 'rust',
        title: 'Rust\'a Giriş',
        titleEn: 'Introduction to Rust',
        titleDe: 'Einführung in Rust',
        titleEs: 'Introducción a Rust',
        description: 'Güvenli sistem programlama',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'rust01_1',
            type: ContentType.heading,
            content: 'Rust Nedir?',
          ),
          LessonContent(
            id: 'rust01_2',
            type: ContentType.text,
            content: 'Rust, bellek güvenliğini garanti eden, yüksek performanslı bir sistem programlama dilidir. Mozilla tarafından geliştirilmiştir.',
          ),
          LessonContent(
            id: 'rust01_3',
            type: ContentType.note,
            content: 'Rust, Stack Overflow anketlerinde yıllardır "en sevilen dil" seçilmektedir!',
          ),
        ],
      ),
      Lesson(
        id: 'rust_02',
        courseId: 'rust',
        title: 'Hello World',
        description: 'İlk Rust programın',
        order: 2,
        estimatedMinutes: 8,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'rust02_1',
            type: ContentType.code,
            content: '''fn main() {
    println!("Merhaba Dunya!");

    let isim = "DevEducation";
    let yas: i32 = 1;

    println!("Uygulama: {}", isim);
    println!("Yas: {}", yas);
}''',
            language: 'rust',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // JAVA LESSONS
    // ==========================================
    'java': [
      Lesson(
        id: 'java_01',
        courseId: 'java',
        title: 'Java\'ya Giriş',
        description: 'Java nedir, nerede kullanılır?',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'java01_1',
            type: ContentType.heading,
            content: 'Java Nedir?',
          ),
          LessonContent(
            id: 'java01_2',
            type: ContentType.text,
            content: 'Java, 1995\'te Sun Microsystems tarafından geliştirilen, "bir kez yaz, her yerde çalıştır" felsefesine sahip güçlü bir programlama dilidir.',
          ),
          LessonContent(
            id: 'java01_3',
            type: ContentType.text,
            content: '• Android uygulamaları\n• Kurumsal yazılımlar\n• Web sunuculari\n• Büyük veri sistemleri',
          ),
          LessonContent(
            id: 'java01_4',
            type: ContentType.note,
            content: 'Minecraft oyunu Java ile yazılmıştır!',
          ),
        ],
      ),
      Lesson(
        id: 'java_02',
        courseId: 'java',
        title: 'Hello World',
        description: 'İlk Java programın',
        order: 2,
        estimatedMinutes: 8,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'java02_1',
            type: ContentType.text,
            content: 'Java\'da her program bir sınıf (class) içinde yazılır ve main metodundan başlar:',
          ),
          LessonContent(
            id: 'java02_2',
            type: ContentType.code,
            content: '''public class Merhaba {
    public static void main(String[] args) {
        System.out.println("Merhaba Dunya!");

        String isim = "DevEducation";
        int yas = 1;

        System.out.println("Uygulama: " + isim);
    }
}''',
            language: 'java',
            isInteractive: true,
          ),
        ],
      ),
    ],

    // ==========================================
    // C# LESSONS
    // ==========================================
    'csharp': [
      Lesson(
        id: 'csharp_01',
        courseId: 'csharp',
        title: 'C#\'a Giriş',
        description: 'C# nedir, nerede kullanılır?',
        order: 1,
        estimatedMinutes: 5,
        type: LessonType.theory,
        xpReward: 10,
        contents: [
          LessonContent(
            id: 'csharp01_1',
            type: ContentType.heading,
            content: 'C# Nedir?',
          ),
          LessonContent(
            id: 'csharp01_2',
            type: ContentType.text,
            content: 'C# (si-sarp okunur), Microsoft tarafından geliştirilen modern ve çok yonlu bir programlama dilidir.',
          ),
          LessonContent(
            id: 'csharp01_3',
            type: ContentType.text,
            content: '• Unity ile oyun geliştirme\n• Windows uygulamaları\n• Web siteleri (ASP.NET)\n• Mobil uygulamalar (MAUI)',
          ),
          LessonContent(
            id: 'csharp01_4',
            type: ContentType.note,
            content: 'Dünyadaki oyunların çoğu Unity + C# ile yapılıyor!',
          ),
        ],
      ),
      Lesson(
        id: 'csharp_02',
        courseId: 'csharp',
        title: 'Hello World',
        description: 'İlk C# programın',
        order: 2,
        estimatedMinutes: 8,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'csharp02_1',
            type: ContentType.text,
            content: 'C#\'ta program Main metodundan başlar:',
          ),
          LessonContent(
            id: 'csharp02_2',
            type: ContentType.code,
            content: '''using System;

class Merhaba {
    static void Main() {
        Console.WriteLine("Merhaba Dunya!");

        string isim = "DevEducation";
        int yas = 1;

        Console.WriteLine("Uygulama: " + isim);
    }
}''',
            language: 'csharp',
            isInteractive: true,
          ),
        ],
      ),
    ],
  };

  /// Get total lesson count for a course
  static int getLessonCount(String courseId) {
    return _allLessons[courseId]?.length ?? 0;
  }

  /// Get a specific lesson
  static Lesson? getLesson(String courseId, String lessonId) {
    final lessons = _allLessons[courseId];
    if (lessons == null) return null;
    try {
      return lessons.firstWhere((l) => l.id == lessonId);
    } catch (e) {
      return null;
    }
  }
}
