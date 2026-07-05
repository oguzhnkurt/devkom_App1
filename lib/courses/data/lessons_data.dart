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
        title: 'Python\'a Giris',
        description: 'Python nedir, neden ogrenmeli?',
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
            content: 'Python, okunmasi ve yazilmasi kolay, guclu bir programlama dilidir. 1991\'de Guido van Rossum tarafindan olusturulmustur.',
          ),
          LessonContent(
            id: 'py01_3',
            type: ContentType.note,
            content: 'Python ismi, Monty Python adli komedi grubundan gelmektedir!',
          ),
          LessonContent(
            id: 'py01_4',
            type: ContentType.heading,
            content: 'Neden Python?',
          ),
          LessonContent(
            id: 'py01_5',
            type: ContentType.text,
            content: '• Ogrenmesi kolay\n• Guclu kutuphaneler\n• Yapay zeka ve veri biliminde lider\n• Web, oyun, otomasyon her yerde',
          ),
        ],
      ),
      Lesson(
        id: 'python_02',
        courseId: 'python',
        title: 'Ilk Python Kodun',
        description: 'Hello World yazalim!',
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
            content: 'Her programcinin ilk yazdigi kod: ekrana mesaj yazdirma.',
          ),
          LessonContent(
            id: 'py02_3',
            type: ContentType.code,
            content: 'print("Merhaba Dunya!")',
            language: 'python',
            isInteractive: true,
          ),
          LessonContent(
            id: 'py02_4',
            type: ContentType.output,
            content: 'Merhaba Dunya!',
          ),
          LessonContent(
            id: 'py02_5',
            type: ContentType.task,
            content: 'Simdi sen dene! Kendi adini yazdiran bir kod yaz.',
            hint: 'print("Benim adim ...")',
          ),
        ],
      ),
      Lesson(
        id: 'python_03',
        courseId: 'python',
        title: 'Degiskenler',
        description: 'Verileri saklamayi ogren',
        order: 3,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'py03_1',
            type: ContentType.heading,
            content: 'Degisken Nedir?',
          ),
          LessonContent(
            id: 'py03_2',
            type: ContentType.text,
            content: 'Degiskenler, verileri sakladigimiz kutular gibidir. Bir isim verip icine deger koyariz.',
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
            content: 'Python\'da 4 temel veri tipi vardir:',
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
        title: 'Matematik Islemleri',
        description: 'Toplama, cikarma, carpma, bolme',
        order: 5,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'py05_1',
            type: ContentType.heading,
            content: 'Aritmetik Operatorler',
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
        title: 'HTML\'e Giris',
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
            content: 'HTML (HyperText Markup Language), web sayfalarinin iskeletini olusturan dildir. Tum web siteleri HTML ile baslar.',
          ),
          LessonContent(
            id: 'html01_3',
            type: ContentType.note,
            content: 'HTML bir programlama dili degil, isaret dilidir (markup language).',
          ),
        ],
      ),
      Lesson(
        id: 'html_02',
        courseId: 'html',
        title: 'Ilk HTML Sayfan',
        description: 'Temel HTML yapisi',
        order: 2,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'html02_1',
            type: ContentType.heading,
            content: 'HTML Dokuman Yapisi',
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
        title: 'Basliklar',
        description: 'h1, h2, h3... etiketleri',
        order: 3,
        estimatedMinutes: 8,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'html03_1',
            type: ContentType.heading,
            content: 'Baslik Etiketleri',
          ),
          LessonContent(
            id: 'html03_2',
            type: ContentType.text,
            content: 'HTML\'de 6 seviye baslik vardir: h1 en buyuk, h6 en kucuk.',
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
        title: 'JavaScript\'e Giris',
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
            content: 'JavaScript, web sayfalarini canlandiran programlama dilidir. Butonlara tiklandiginda, formlara yazildiginda JavaScript calisir.',
          ),
        ],
      ),
      Lesson(
        id: 'js_02',
        courseId: 'javascript',
        title: 'Degiskenler: let ve const',
        description: 'Modern degisken tanimlama',
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
        title: 'Dart\'a Giris',
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
            content: 'Dart, Google tarafindan gelistirilen modern bir programlama dilidir. Flutter ile mobil, web ve masaustu uygulamalar gelistirilir.',
          ),
        ],
      ),
      Lesson(
        id: 'dart_02',
        courseId: 'dart',
        title: 'Hello World',
        description: 'Ilk Dart programin',
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

  String isim = 'DevKom';
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
        title: 'Arduino\'ya Giris',
        description: 'Mikrodenetleyici dunyasi',
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
            content: 'Arduino, elektronik projeleri programlamanizi saglayan acik kaynakli bir platformdur. LED yakma, motor kontrolu, sensor okuma gibi isler yapabilirsiniz.',
          ),
        ],
      ),
      Lesson(
        id: 'arduino_02',
        courseId: 'arduino',
        title: 'LED Yakma',
        description: 'Ilk Arduino projen',
        order: 2,
        estimatedMinutes: 10,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'ard02_1',
            type: ContentType.heading,
            content: 'Blink - LED Yakip Sondurme',
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
        title: 'Scratch\'a Giris',
        description: 'Blok tabanli kodlama',
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
            content: 'Scratch, MIT tarafindan gelistirilen gorsel programlama dilidir. Renkli bloklari birlestirerek oyunlar ve animasyonlar yapabilirsin!',
          ),
          LessonContent(
            id: 'scr01_3',
            type: ContentType.note,
            content: 'Scratch, kodlamaya yeni baslayan herkes icin tasarlanmistir.',
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
        title: 'CSS\'e Giris',
        description: 'Web sayfalarini guzelleştir',
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
            content: 'CSS (Cascading Style Sheets), HTML elemanlarinin gorunumunu degistiren dildir. Renkler, fontlar, boyutlar, yerlesim - hepsi CSS ile yapilir.',
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
        title: 'SQL\'e Giris',
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
            content: 'SQL (Structured Query Language), veritabanlarindaki verileri sorgulamak, eklemek, guncellemek ve silmek icin kullanilan dildir.',
          ),
        ],
      ),
      Lesson(
        id: 'sql_02',
        courseId: 'sql',
        title: 'SELECT Sorgusu',
        description: 'Veri cekmeyi ogren',
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
        title: 'C Diline Giris',
        description: 'Tum dillerin atasi',
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
            content: 'C, 1972\'de Dennis Ritchie tarafindan gelistirilmis, sistem programlamanin temelini olusturan dildir. Linux, Windows cekirdekleri C ile yazilmistir.',
          ),
        ],
      ),
      Lesson(
        id: 'c_02',
        courseId: 'c',
        title: 'Hello World',
        description: 'Ilk C programin',
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
        title: 'Go\'ya Giris',
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
            content: 'Go, Google\'da gelistirilen basit, hizli ve verimli bir programlama dilidir. Ozellikle sunucu uygulamalari ve mikroservisler icin idealdir.',
          ),
        ],
      ),
      Lesson(
        id: 'go_02',
        courseId: 'go',
        title: 'Hello World',
        description: 'Ilk Go programin',
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
        title: 'Rust\'a Giris',
        description: 'Guvenli sistem programlama',
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
            content: 'Rust, bellek guvenligini garanti eden, yuksek performansli bir sistem programlama dilidir. Mozilla tarafindan gelistirilmistir.',
          ),
          LessonContent(
            id: 'rust01_3',
            type: ContentType.note,
            content: 'Rust, Stack Overflow anketlerinde yillardir "en sevilen dil" secilmektedir!',
          ),
        ],
      ),
      Lesson(
        id: 'rust_02',
        courseId: 'rust',
        title: 'Hello World',
        description: 'Ilk Rust programin',
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

    let isim = "DevKom";
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
        title: 'Java\'ya Giris',
        description: 'Java nedir, nerede kullanilir?',
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
            content: 'Java, 1995\'te Sun Microsystems tarafindan gelistirilen, "bir kez yaz, her yerde calistir" felsefesine sahip guclu bir programlama dilidir.',
          ),
          LessonContent(
            id: 'java01_3',
            type: ContentType.text,
            content: '• Android uygulamalari\n• Kurumsal yazilimlar\n• Web sunuculari\n• Buyuk veri sistemleri',
          ),
          LessonContent(
            id: 'java01_4',
            type: ContentType.note,
            content: 'Minecraft oyunu Java ile yazilmistir!',
          ),
        ],
      ),
      Lesson(
        id: 'java_02',
        courseId: 'java',
        title: 'Hello World',
        description: 'Ilk Java programin',
        order: 2,
        estimatedMinutes: 8,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'java02_1',
            type: ContentType.text,
            content: 'Java\'da her program bir sinif (class) icinde yazilir ve main metodundan baslar:',
          ),
          LessonContent(
            id: 'java02_2',
            type: ContentType.code,
            content: '''public class Merhaba {
    public static void main(String[] args) {
        System.out.println("Merhaba Dunya!");

        String isim = "DevKom";
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
        title: 'C#\'a Giris',
        description: 'C# nedir, nerede kullanilir?',
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
            content: 'C# (si-sarp okunur), Microsoft tarafindan gelistirilen modern ve cok yonlu bir programlama dilidir.',
          ),
          LessonContent(
            id: 'csharp01_3',
            type: ContentType.text,
            content: '• Unity ile oyun gelistirme\n• Windows uygulamalari\n• Web siteleri (ASP.NET)\n• Mobil uygulamalar (MAUI)',
          ),
          LessonContent(
            id: 'csharp01_4',
            type: ContentType.note,
            content: 'Dunyadaki oyunlarin cogu Unity + C# ile yapiliyor!',
          ),
        ],
      ),
      Lesson(
        id: 'csharp_02',
        courseId: 'csharp',
        title: 'Hello World',
        description: 'Ilk C# programin',
        order: 2,
        estimatedMinutes: 8,
        type: LessonType.practice,
        xpReward: 15,
        contents: [
          LessonContent(
            id: 'csharp02_1',
            type: ContentType.text,
            content: 'C#\'ta program Main metodundan baslar:',
          ),
          LessonContent(
            id: 'csharp02_2',
            type: ContentType.code,
            content: '''using System;

class Merhaba {
    static void Main() {
        Console.WriteLine("Merhaba Dunya!");

        string isim = "DevKom";
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
