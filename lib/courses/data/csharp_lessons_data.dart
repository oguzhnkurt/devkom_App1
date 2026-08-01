import '../models/interactive_lesson_model.dart';

/// C# Course - Interactive lessons for programming fundamentals
/// Scratch/CSS/Java dersleriyle ayni adim adim, kalite ve formatta
class CSharpLessonsData {
  // ==========================================
  // MODULE 1: C#'A GİRİŞ
  // ==========================================
  static final List<InteractiveLesson> module1 = [
    // LESSON 1.1: C# Nedir?
    InteractiveLesson(
      id: 'csharp_1_1',
      courseId: 'csharp',
      title: 'C#\'a Hos Geldin!',
      subtitle: 'Microsoft\'un gucu',
      order: 1,
      xpReward: 50,
      badge: 'csharp_starter',
      steps: [
        IntroStep(
          id: 'cs1_1_intro',
          mascotEmoji: '💜',
          mascotMessage: 'Merhaba! Ben C# (si-sarp okunur). Microsoft tarafindan gelistirildim ve oyunlardan masaustu uygulamalarina kadar her yerde kullanilirim!',
          highlights: [
            'Unity ile oyun yap',
            'Windows uygulamalari',
            'Web ve mobil',
          ],
        ),

        ExplanationStep(
          id: 'cs1_1_exp1',
          title: 'C# Nedir?',
          content: 'C# (C-Sharp), Microsoft tarafindan 2000\'de gelistirilen modern ve guclu bir programlama dilidir.\n\nJava\'ya cok benzer ama Microsoft\'un .NET platformu uzerinde calisir.\n\nOgrenmesi kolay, okumasi net bir dildir!',
          tipEmoji: '💜',
          tip: 'Dunyadaki oyunlarin cogu Unity oyun motoru + C# ile yapiliyor!',
        ),

        MultipleChoiceStep(
          id: 'cs1_1_q1',
          question: 'C# hangi sirket tarafindan gelistirilmistir?',
          options: [
            ChoiceOption(text: 'Microsoft', emoji: '✅'),
            ChoiceOption(text: 'Google', emoji: '❌'),
            ChoiceOption(text: 'Apple', emoji: '❌'),
            ChoiceOption(text: 'Amazon', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'C#, Microsoft tarafindan .NET platformu icin gelistirilmistir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'cs1_1_exp2',
          title: 'C# Nerede Kullanilir?',
          content: 'C# cok yonlu bir dildir:\n\n🎮 Unity ile oyun gelistirme\n🖥️ Windows masaustu uygulamalari\n🌐 Web siteleri (ASP.NET)\n📱 Mobil uygulamalar (MAUI)',
        ),

        MultipleChoiceStep(
          id: 'cs1_1_q2',
          question: 'Hangi oyun motoru C# ile birlikte en cok kullanilir?',
          options: [
            ChoiceOption(text: 'Unity', emoji: '✅'),
            ChoiceOption(text: 'Scratch', emoji: '❌'),
            ChoiceOption(text: 'Photoshop', emoji: '❌'),
            ChoiceOption(text: 'Excel', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Unity, dunyanin en populer oyun motorlarindan biridir ve C# kullanir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'cs1_1_exp3',
          title: '.NET Platformu Nedir?',
          content: '.NET, C# kodunu calistiran bir platformdur - tipki Java\'nin JVM\'i gibi.\n\n.NET sayesinde C# kodun Windows, Mac, Linux gibi farkli sistemlerde calisabilir!',
          tipEmoji: '🔄',
          tip: '.NET, C#\'in "her yerde calisma" gucunun arkasindaki teknolojidir!',
        ),

        ExplanationStep(
          id: 'cs1_1_summary',
          title: 'C# Baslangic!',
          content: '💜 C# dunyasina hosgeldin!\n\n✓ C#\'in ne oldugunu ogrendin\n✓ Nerede kullanildigini kesfettin\n✓ .NET kavramini tandin\n\nSonraki ders: Ilk C# programini yazacaksin!',
          tipEmoji: '🏆',
          tip: 'C# Baslangic rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.2: Ilk Programin
    InteractiveLesson(
      id: 'csharp_1_2',
      courseId: 'csharp',
      title: 'Ilk Programin',
      subtitle: 'Merhaba Dunya yaz!',
      order: 2,
      xpReward: 60,
      badge: 'first_csharp_code',
      steps: [
        IntroStep(
          id: 'cs1_2_intro',
          mascotEmoji: '💻',
          mascotMessage: 'Simdi ilk C# programini yazacagiz - klasik "Merhaba Dunya"!',
        ),

        ExplanationStep(
          id: 'cs1_2_exp1',
          title: 'C# Programinin Iskeleti',
          content: 'C# programlari da (Java gibi) bir sinif icinde yazilir:\n\nusing System;\n\nclass Merhaba {\n    static void Main() {\n        // kodun burada\n    }\n}\n\nusing System; en ustte yazilir - System kutuphanesini kullanmamizi saglar!',
          tipEmoji: '🏗️',
          tip: 'Main metodu buyuk M ile baslar - Java\'daki main\'den farkli!',
        ),

        MultipleChoiceStep(
          id: 'cs1_2_q1',
          question: 'C#\'ta program hangi metoddan baslar calismaya?',
          options: [
            ChoiceOption(text: 'Main() (buyuk M)', emoji: '✅'),
            ChoiceOption(text: 'main() (kucuk m)', emoji: '❌'),
            ChoiceOption(text: 'start()', emoji: '❌'),
            ChoiceOption(text: 'run()', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'C#\'ta metod isimleri buyuk harfle baslar - bu yuzden Main (kucuk main degil)!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'cs1_2_exp2',
          title: 'Console.WriteLine()',
          content: 'Ekrana yazi yazdirmak icin Console.WriteLine() kullanilir:\n\nConsole.WriteLine("Merhaba Dunya!");\n\nJava\'daki System.out.println() ile ayni ise yarar, sadece ismi farkli!',
        ),

        MultipleChoiceStep(
          id: 'cs1_2_q2',
          question: 'Ekrana "Selam!" yazdirmak icin dogru kod hangisi?',
          options: [
            ChoiceOption(text: 'Console.WriteLine("Selam!");', emoji: '✅', isCode: true),
            ChoiceOption(text: 'System.out.println("Selam!");', emoji: '❌', isCode: true),
            ChoiceOption(text: 'print("Selam!");', emoji: '❌', isCode: true),
            ChoiceOption(text: 'Console.print("Selam!");', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'Console.WriteLine(), C#\'ta ekrana yazi yazdirmanin standart yoludur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'cs1_2_exp3',
          title: 'Noktali Virgul ve Suslu Parantezler',
          content: 'C# da Java gibi noktali virgul (;) ve suslu parantez { } kullanir:\n\nConsole.WriteLine("Bir");\nConsole.WriteLine("Iki");\n\nHer komut ; ile biter, kod bloklari { } ile sarilir!',
          tipEmoji: '⚠️',
          tip: 'C#, Java ve JavaScript ayni "C-tarzi" sozdizimini paylasir - birini ogrenince digerleri kolaylasir!',
        ),

        OrderingStep(
          id: 'cs1_2_order',
          instruction: 'Basit bir C# programini dogru sirala',
          items: [
            OrderItem(id: 's1', content: 'class Merhaba {', isCode: true),
            OrderItem(id: 's2', content: 'static void Main() {', isCode: true),
            OrderItem(id: 's3', content: 'Console.WriteLine("Merhaba Dunya!");', isCode: true),
            OrderItem(id: 's4', content: '}', isCode: true),
            OrderItem(id: 's5', content: '}', isCode: true),
          ],
          correctOrder: ['s1', 's2', 's3', 's4', 's5'],
          context: 'Ekrana "Merhaba Dunya!" yazdiran tam bir C# programi',
          xpReward: 20,
        ),

        ProjectStep(
          id: 'cs1_2_project',
          title: 'Mini Proje: Kendini Tanit',
          description: 'Console.WriteLine() kullanarak kendini tanitan kucuk bir program yaz!',
          requirements: [
            'class ile bir sinif olustur',
            'Main metodunu yaz (buyuk M!)',
            'En az 3 Console.WriteLine() satiri kullan (isim, yas, hobi)',
          ],
          hints: [
            'Console.WriteLine("Adim: Ahmet");',
            'Console.WriteLine("Yasim: 12");',
            'Her satirin sonunda ; olmali',
          ],
          starterCode: 'class BenimHakkimda {\n    static void Main() {\n        // buraya kodunu yaz\n    }\n}',
          language: 'csharp',
          validation: ProjectValidation(
            mustContain: ['Console.WriteLine', 'class', 'Main'],
          ),
          xpReward: 30,
        ),

        ExplanationStep(
          id: 'cs1_2_summary',
          title: 'Ilk Kod Yazildi!',
          content: '🎊 Ilk C# programini yazdin!\n\n✓ class ve Main yapisini ogrendin\n✓ Console.WriteLine() kullandin\n✓ Noktali virgulu unutmadin\n\nSonraki: Degiskenler ve veri tipleri!',
          tipEmoji: '🎖️',
          tip: 'Ilk Kod rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.3: Degiskenler ve Veri Tipleri
    InteractiveLesson(
      id: 'csharp_1_3',
      courseId: 'csharp',
      title: 'Degiskenler ve Veri Tipleri',
      subtitle: 'Bilgiyi sakla',
      order: 3,
      xpReward: 70,
      badge: 'csharp_variable_master',
      steps: [
        IntroStep(
          id: 'cs1_3_intro',
          mascotEmoji: '📦',
          mascotMessage: 'Programlarin bilgiyi hatirlamasi gerekir. C#\'ta bunu DEGISKENLER ile yapiyoruz!',
        ),

        ExplanationStep(
          id: 'cs1_3_exp1',
          title: 'C#\'ta Degisken Tanimlama',
          content: 'C#\'ta bir degisken tanimlarken TIP belirtmen gerekir:\n\nint yas = 12;\nstring isim = "Ahmet";\ndouble boy = 1.45;\nbool ogrenciMi = true;\n\nDikkat: C#\'ta metin tipi "string" KUCUK harfle yazilir (Java\'da String buyuk harfti)!',
          tipEmoji: '📦',
          tip: 'bool, Java\'daki boolean\'in C#\'taki kisa adidir!',
        ),

        MultipleChoiceStep(
          id: 'cs1_3_q1',
          question: 'C#\'ta metin (string) veri tipi nasil yazilir?',
          options: [
            ChoiceOption(text: 'string (kucuk harf)', emoji: '✅', isCode: true),
            ChoiceOption(text: 'String (buyuk harf)', emoji: '❌', isCode: true),
            ChoiceOption(text: 'text', emoji: '❌', isCode: true),
            ChoiceOption(text: 'str', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'C#\'ta string kucuk harfle yazilir - Java\'dan farkli oldugu bir nokta!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'cs1_3_exp2',
          title: 'Temel Veri Tipleri',
          content: 'C#\'in temel veri tipleri:\n\nint: Tam sayi (12, -5, 100)\ndouble: Ondalikli sayi (3.14, 1.45)\nstring: Metin ("Merhaba", "Ahmet")\nbool: Dogru/yanlis (true, false)',
        ),

        MultipleChoiceStep(
          id: 'cs1_3_q2',
          question: 'true veya false degeri tutan veri tipi hangisi?',
          options: [
            ChoiceOption(text: 'bool', emoji: '✅', isCode: true),
            ChoiceOption(text: 'int', emoji: '❌', isCode: true),
            ChoiceOption(text: 'string', emoji: '❌', isCode: true),
            ChoiceOption(text: 'boolean', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'bool, C#\'ta true/false degerlerini tutan veri tipidir (Java\'da boolean idi)!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'cs1_3_exp3',
          title: 'String Interpolation ile Birlestirme',
          content: 'C#\'ta degiskenleri metinle birlestirmenin modern yolu \$ isaretidir:\n\nint yas = 12;\nConsole.WriteLine(\$"Yasim: {yas}");\n\nString basina \$ koy, degiskeni {} icine yaz - cok daha okunakli!',
          tipEmoji: '🔗',
          tip: 'Buna "string interpolation" denir - C#\'in en sevilen ozelliklerinden biri!',
        ),

        MultipleChoiceStep(
          id: 'cs1_3_q3',
          question: 'int puan = 90; iken Console.WriteLine(\$"Puan: {puan}"); ne yazdirir?',
          options: [
            ChoiceOption(text: 'Puan: 90', emoji: '✅'),
            ChoiceOption(text: 'Puan: puan', emoji: '❌'),
            ChoiceOption(text: 'Puan: {puan}', emoji: '❌'),
            ChoiceOption(text: 'Hata verir', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '\$"..." icindeki {puan}, puan degiskeninin DEGERI ile degistirilir!',
          xpReward: 15,
        ),

        DragDropStep(
          id: 'cs1_3_dd1',
          instruction: 'Degeri dogru veri tipiyle eslestir!',
          items: [
            DraggableItem(id: 'v1', content: '25'),
            DraggableItem(id: 'v2', content: '"Merhaba"'),
            DraggableItem(id: 'v3', content: '3.14'),
            DraggableItem(id: 'v4', content: 'true'),
          ],
          dropZones: [
            DropZone(id: 'int', label: 'int'),
            DropZone(id: 'string', label: 'string'),
            DropZone(id: 'double', label: 'double'),
            DropZone(id: 'bool', label: 'bool'),
          ],
          correctMapping: {
            'v1': 'int',
            'v2': 'string',
            'v3': 'double',
            'v4': 'bool',
          },
          successMessage: 'Veri tiplerini mukemmel ayirt ediyorsun!',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'cs1_3_summary',
          title: 'Degisken Ustasi!',
          content: '📦 Artik bilgiyi saklayabiliyorsun!\n\n✓ int, string, double, bool\n✓ Degisken tanimlama\n✓ String interpolation (\$"...")\n\nSonraki modul: Kontrol yapilari!',
          tipEmoji: '🏅',
          tip: 'Degisken Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 2: KONTROL YAPILARI
  // ==========================================
  static final List<InteractiveLesson> module2 = [
    // LESSON 2.1: If-Else
    InteractiveLesson(
      id: 'csharp_2_1',
      courseId: 'csharp',
      title: 'If-Else',
      subtitle: 'Programin karar vermesi',
      order: 4,
      xpReward: 75,
      badge: 'csharp_condition_master',
      steps: [
        IntroStep(
          id: 'cs2_1_intro',
          mascotEmoji: '🤔',
          mascotMessage: 'C#\'ta da programlar karar verebilir! if-else ile "eger boyle ise, sunu yap" mantigini kuracagiz.',
        ),

        ExplanationStep(
          id: 'cs2_1_exp1',
          title: 'if Yapisi',
          content: 'if, bir kosulun DOGRU olup olmadigini kontrol eder:\n\nint yas = 15;\nif (yas >= 18) {\n    Console.WriteLine("Yetiskinsin!");\n}\n\nBu yapi Java ile BIREBIR ayni!',
          tipEmoji: '🔍',
          tip: 'C# ve Java\'nin kontrol yapilari neredeyse ayni - biri Java\'yi bilirse C# cok kolay ogrenilir!',
        ),

        MultipleChoiceStep(
          id: 'cs2_1_q1',
          question: 'if (yas >= 18) satirinda >= ne anlama gelir?',
          options: [
            ChoiceOption(text: 'Buyuk veya esittir', emoji: '✅'),
            ChoiceOption(text: 'Sadece buyuktur', emoji: '❌'),
            ChoiceOption(text: 'Kucuktur', emoji: '❌'),
            ChoiceOption(text: 'Esit degildir', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '>= "buyuk esittir" anlamina gelir - yas 18 veya daha fazlaysa kosul dogrudur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'cs2_1_exp2',
          title: 'else ve else if',
          content: 'Birden fazla durumu kontrol etmek icin:\n\nint puan = 75;\nif (puan >= 90) {\n    Console.WriteLine("A");\n} else if (puan >= 70) {\n    Console.WriteLine("B");\n} else {\n    Console.WriteLine("C");\n}\n\nC# kosullari sirayla kontrol eder, ilk DOGRU olani calistirir!',
        ),

        MultipleChoiceStep(
          id: 'cs2_1_q2',
          question: 'C#\'ta esitlik kontrolu icin hangi operator kullanilir?',
          options: [
            ChoiceOption(text: '==', emoji: '✅', isCode: true),
            ChoiceOption(text: '=', emoji: '❌', isCode: true),
            ChoiceOption(text: '===', emoji: '❌', isCode: true),
            ChoiceOption(text: 'equals', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: '== karsilastirma yapar, tek = ise deger atamaktir!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs2_1_exp3',
          title: 'Mantiksal Operatorler: && ve ||',
          content: 'Birden fazla kosulu birlestirmek icin:\n\n&& (VE): Her iki kosul da dogru olmali\n|| (VEYA): En az bir kosul dogru olmali\n\nOrnek:\nif (yas >= 13 && yas <= 19) {\n    Console.WriteLine("Genclik cagindasin!");\n}',
          tipEmoji: '🔗',
          tip: '&& ve ||, birden fazla kosulu tek bir if icinde birlestirmeni saglar!',
        ),

        MultipleChoiceStep(
          id: 'cs2_1_q3',
          question: 'yas = 15 iken "yas >= 13 && yas <= 19" ifadesi ne dondurur?',
          options: [
            ChoiceOption(text: 'true (dogru)', emoji: '✅'),
            ChoiceOption(text: 'false (yanlis)', emoji: '❌'),
            ChoiceOption(text: '15', emoji: '❌'),
            ChoiceOption(text: 'Hata verir', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '15, hem 13\'ten buyuk esit hem 19\'dan kucuk esit oldugu icin her iki kosul da dogru - sonuc true!',
          xpReward: 15,
        ),

        OrderingStep(
          id: 'cs2_1_order',
          instruction: 'Not kontrolu yapan kodu dogru sirala',
          items: [
            OrderItem(id: 's1', content: 'if (puan >= 90) {', isCode: true),
            OrderItem(id: 's2', content: 'Console.WriteLine("A");', isCode: true),
            OrderItem(id: 's3', content: '} else {', isCode: true),
            OrderItem(id: 's4', content: 'Console.WriteLine("Gecemedi");', isCode: true),
            OrderItem(id: 's5', content: '}', isCode: true),
          ],
          correctOrder: ['s1', 's2', 's3', 's4', 's5'],
          context: 'Puan 90 ve uzeriyse A, degilse "Gecemedi" yazdiran kod',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'cs2_1_summary',
          title: 'Karar Verme Ustasi!',
          content: '🤔 Artik programlarin karar vermesini saglayabilirsin!\n\n✓ if / else / else if\n✓ && ve || mantiksal operatorler\n\nSonraki: Donguler ile tekrar eden isler!',
          tipEmoji: '🏅',
          tip: 'Karar Verme Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 2.2: Donguler
    InteractiveLesson(
      id: 'csharp_2_2',
      courseId: 'csharp',
      title: 'Donguler',
      subtitle: 'for ve while ile tekrar et',
      order: 5,
      xpReward: 75,
      badge: 'csharp_loop_master',
      steps: [
        IntroStep(
          id: 'cs2_2_intro',
          mascotEmoji: '🔁',
          mascotMessage: 'Ayni islemi defalarca tekrarlamak icin donguleri kullanacagiz - tam Java\'daki gibi!',
        ),

        ExplanationStep(
          id: 'cs2_2_exp1',
          title: 'for Dongusu',
          content: 'for dongusu, belirli bir sayida tekrar yapar:\n\nfor (int i = 0; i < 5; i++) {\n    Console.WriteLine(\$"Merhaba {i}");\n}\n\n3 parca: baslangic (i=0), kosul (i<5), artis (i++)\nBu kod 5 kere calisir!',
          tipEmoji: '🔢',
          tip: 'C#\'in for dongusu Java ile birebir ayni yazilir!',
        ),

        MultipleChoiceStep(
          id: 'cs2_2_q1',
          question: 'for (int i = 0; i < 5; i++) kac kere calisir?',
          options: [
            ChoiceOption(text: '5 kere', emoji: '✅'),
            ChoiceOption(text: '4 kere', emoji: '❌'),
            ChoiceOption(text: '6 kere', emoji: '❌'),
            ChoiceOption(text: 'Sonsuz kere', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'i 0\'dan baslar, 5\'ten kucuk oldugu surece devam eder: 0,1,2,3,4 - toplam 5 kere!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs2_2_exp2',
          title: 'while Dongusu',
          content: 'while dongusu, bir kosul dogru oldugu surece devam eder:\n\nint sayac = 0;\nwhile (sayac < 3) {\n    Console.WriteLine(\$"Sayac: {sayac}");\n    sayac++;\n}\n\nKac kere tekrar edecegini onceden bilmiyorsan while daha uygundur!',
        ),

        MultipleChoiceStep(
          id: 'cs2_2_q2',
          question: 'while dongusunde sayaci artirmayi unutursak ne olur?',
          options: [
            ChoiceOption(text: 'Sonsuz dongu olusur', emoji: '✅'),
            ChoiceOption(text: 'Program hemen biter', emoji: '❌'),
            ChoiceOption(text: 'Hata verir ve calismaz', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey degismez', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Sayac hic artmazsa kosul hep dogru kalir - buna sonsuz dongu denir!',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'cs2_2_exp3',
          title: 'foreach Dongusu',
          content: 'C#\'in ozel bir dongusu daha var: foreach! Bir listenin/dizinin TUM elemanlarini kolayca gezer:\n\nint[] sayilar = {10, 20, 30};\nforeach (int sayi in sayilar) {\n    Console.WriteLine(sayi);\n}\n\nIndex ile ugrasmana gerek yok - foreach her elemani otomatik sirayla verir!',
          tipEmoji: '✨',
          tip: 'foreach, "her biri icin" anlamina gelir - Java\'daki gelismis for dongusune benzer!',
        ),

        DragDropStep(
          id: 'cs2_2_dd1',
          instruction: 'Senaryoyu dogru dongu turuyle eslestir!',
          items: [
            DraggableItem(id: 'd1', content: '10 kere tekrar et (biliyorum)'),
            DraggableItem(id: 'd2', content: 'Bir dizinin tum elemanlarini gez'),
            DraggableItem(id: 'd3', content: 'Kullanici "dur" yazana kadar tekrarla'),
          ],
          dropZones: [
            DropZone(id: 'for', label: 'for dongusu'),
            DropZone(id: 'foreach', label: 'foreach dongusu'),
            DropZone(id: 'while', label: 'while dongusu'),
          ],
          correctMapping: {
            'd1': 'for',
            'd2': 'foreach',
            'd3': 'while',
          },
          successMessage: 'Hangi dongunun ne zaman kullanilacagini ogrendin!',
          xpReward: 20,
        ),

        ProjectStep(
          id: 'cs2_2_project',
          title: 'Mini Proje: Sayi Yazdirici',
          description: 'for dongusu kullanarak 1\'den 10\'a kadar sayilari ekrana yazdiran bir program yaz!',
          requirements: [
            'for dongusu kullan',
            '1\'den 10\'a kadar tum sayilari yazdir',
            'Console.WriteLine() kullan',
          ],
          hints: [
            'for (int i = 1; i <= 10; i++) {',
            'Console.WriteLine(i);',
          ],
          starterCode: 'class SayiYazdirici {\n    static void Main() {\n        // buraya donguyu yaz\n    }\n}',
          language: 'csharp',
          validation: ProjectValidation(
            mustContain: ['for', 'Console.WriteLine'],
          ),
          xpReward: 35,
        ),

        ExplanationStep(
          id: 'cs2_2_summary',
          title: 'Dongu Ustasi!',
          content: '🔁 Tekrar eden isleri otomatiklestirebiliyorsun!\n\n✓ for dongusu\n✓ while dongusu\n✓ foreach dongusu\n\nSonraki: Diziler ve listeler!',
          tipEmoji: '🏅',
          tip: 'Dongu Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 2.3: Diziler ve Listeler
    InteractiveLesson(
      id: 'csharp_2_3',
      courseId: 'csharp',
      title: 'Diziler ve Listeler',
      subtitle: 'Birden fazla veriyi sakla',
      order: 6,
      xpReward: 80,
      badge: 'csharp_array_master',
      steps: [
        IntroStep(
          id: 'cs2_3_intro',
          mascotEmoji: '📋',
          mascotMessage: 'Birden fazla veriyi tek yapida tutmak icin C#\'ta iki secenegin var: DIZILER ve LISTELER!',
        ),

        ExplanationStep(
          id: 'cs2_3_exp1',
          title: 'Dizi (Array) Tanimlama',
          content: 'Bir dizi, ayni tipteki birden fazla degeri tutar:\n\nint[] notlar = {85, 90, 78, 95};\nstring[] isimler = {"Ali", "Ayse", "Mehmet"};\n\nIndex 0\'dan baslar - notlar[0] ilk elemandir!',
          tipEmoji: '📋',
          tip: 'Dizinin boyutu sabittir - bir kere olusturunca eleman sayisi degismez!',
        ),

        MultipleChoiceStep(
          id: 'cs2_3_q1',
          question: 'int[] notlar = {85, 90, 78}; iken notlar[0] hangi degeri verir?',
          options: [
            ChoiceOption(text: '85', emoji: '✅'),
            ChoiceOption(text: '90', emoji: '❌'),
            ChoiceOption(text: '78', emoji: '❌'),
            ChoiceOption(text: '0', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Index 0\'dan baslar - notlar[0] dizideki ILK elemani (85) verir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'cs2_3_exp2',
          title: 'List<T>: Esnek Boyutlu Liste',
          content: 'Dizinin boyutu sabittir ama List<T> boyutu DEGISEBILEN bir yapidir:\n\nList<string> isimler = new List<string>();\nisimler.Add("Ali");\nisimler.Add("Ayse");\n\nAdd() ile istedigin kadar eleman ekleyebilirsin - dizide bu mumkun degildi!',
          tipEmoji: '📝',
          tip: '<string> icindeki tip, listenin HANGI TIP verileri tutacagini belirtir!',
        ),

        MultipleChoiceStep(
          id: 'cs2_3_q2',
          question: 'Bir List\'e yeni eleman eklemek icin hangi metod kullanilir?',
          options: [
            ChoiceOption(text: 'Add()', emoji: '✅', isCode: true),
            ChoiceOption(text: 'Insert()', emoji: '❌', isCode: true),
            ChoiceOption(text: 'Push()', emoji: '❌', isCode: true),
            ChoiceOption(text: 'Append()', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'Add() metodu, bir List\'in sonuna yeni bir eleman ekler!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs2_3_exp3',
          title: 'Diziyi/Listeyi foreach ile Gezmek',
          content: 'Diziyi veya listeyi tek tek gezmek icin foreach kullanilir:\n\nint[] notlar = {85, 90, 78};\nforeach (int not in notlar) {\n    Console.WriteLine(not);\n}\n\nBu kod, notlar dizisindeki HER elemani sirayla yazdirir!',
        ),

        OrderingStep(
          id: 'cs2_3_order',
          instruction: 'Bir diziyi baştan sona yazdiran kodu sirala',
          items: [
            OrderItem(id: 's1', content: 'int[] notlar = {70, 80, 90};', isCode: true),
            OrderItem(id: 's2', content: 'foreach (int not in notlar) {', isCode: true),
            OrderItem(id: 's3', content: 'Console.WriteLine(not);', isCode: true),
            OrderItem(id: 's4', content: '}', isCode: true),
          ],
          correctOrder: ['s1', 's2', 's3', 's4'],
          context: 'Notlar dizisindeki tum elemanlari tek tek yazdiran kod',
          xpReward: 20,
        ),

        ProjectStep(
          id: 'cs2_3_project',
          title: 'Mini Proje: Not Ortalamasi',
          description: 'Bir not dizisi olustur ve dongu kullanarak ortalamalarini hesapla!',
          requirements: [
            'int[] notlar dizisi olustur (en az 4 not)',
            'foreach veya for dongusu ile tum notlari topla',
            'Toplami eleman sayisina bolerek ortalamayi bul',
            'Ortalamayi yazdir',
          ],
          hints: [
            'int toplam = 0; foreach (int n in notlar) { toplam += n; }',
            'double ortalama = (double) toplam / notlar.Length;',
          ],
          starterCode: 'class NotOrtalamasi {\n    static void Main() {\n        int[] notlar = {80, 90, 75, 85};\n        // toplama ve ortalama hesabini yaz\n    }\n}',
          language: 'csharp',
          validation: ProjectValidation(
            mustContain: ['foreach', 'notlar', 'toplam'],
          ),
          xpReward: 40,
        ),

        ExplanationStep(
          id: 'cs2_3_summary',
          title: 'Dizi ve Liste Ustasi!',
          content: '📋 Birden fazla veriyi tek yapida yonetebiliyorsun!\n\n✓ Dizi (array) - sabit boyut\n✓ List<T> - esnek boyut\n✓ foreach ile gezme\n\nSonraki modul: Nesne yonelimli programlama!',
          tipEmoji: '🏅',
          tip: 'Dizi Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 3: NESNE YÖNELİMİ
  // ==========================================
  static final List<InteractiveLesson> module3 = [
    // LESSON 3.1: Siniflar
    InteractiveLesson(
      id: 'csharp_3_1',
      courseId: 'csharp',
      title: 'Siniflar',
      subtitle: 'Kendi veri tipini yarat',
      order: 7,
      xpReward: 85,
      badge: 'csharp_oop_starter',
      steps: [
        IntroStep(
          id: 'cs3_1_intro',
          mascotEmoji: '🏗️',
          mascotMessage: 'C# da nesne yonelimli bir dildir. Simdi kendi SINIFLARIMIZI yaratmayi ogrenecegiz!',
        ),

        ExplanationStep(
          id: 'cs3_1_exp1',
          title: 'Sinif (Class) Nedir?',
          content: 'Bir sinif, bir "sablon"dur. Ornegin bir Oyuncu sinifi:\n\nclass Oyuncu {\n    public string isim;\n    public int can;\n}\n\npublic kelimesi, bu ozelliklere disaridan erisilebilecegini belirtir!',
          tipEmoji: '📐',
          tip: 'Unity oyunlarinda her karakter, dusman, esya bir C# sinifidir!',
        ),

        MultipleChoiceStep(
          id: 'cs3_1_q1',
          question: 'Bir sinifin ozelliklerinin basina yazilan "public" ne anlama gelir?',
          options: [
            ChoiceOption(text: 'Disaridan erisilebilir', emoji: '✅'),
            ChoiceOption(text: 'Sadece o sinifin icinden erisilebilir', emoji: '❌'),
            ChoiceOption(text: 'Silinemez', emoji: '❌'),
            ChoiceOption(text: 'Sabit deger tasir', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'public, bir ozellik veya metodun sinif disindan da erisilebilir olmasini saglar!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'cs3_1_exp2',
          title: 'Nesne (Object) Olusturma',
          content: 'Siniftan gercek bir NESNE olusturmak icin new kullanilir:\n\nOyuncu oyuncu1 = new Oyuncu();\noyuncu1.isim = "Kahraman";\noyuncu1.can = 100;\n\nSimdi oyuncu1 GERCEK bir nesne - kendi degerlerine sahip!',
          tipEmoji: '✨',
          tip: 'Java\'daki new kullanimi ile birebir ayni!',
        ),

        MultipleChoiceStep(
          id: 'cs3_1_q2',
          question: 'Oyuncu sinifindan yeni bir nesne olusturmak icin ne yazariz?',
          options: [
            ChoiceOption(text: 'new Oyuncu();', emoji: '✅', isCode: true),
            ChoiceOption(text: 'create Oyuncu();', emoji: '❌', isCode: true),
            ChoiceOption(text: 'Oyuncu.new();', emoji: '❌', isCode: true),
            ChoiceOption(text: 'Oyuncu();', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'new anahtar kelimesi, bir siniftan yeni bir nesne yaratir!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs3_1_exp3',
          title: 'Ayni Siniftan Birden Fazla Nesne',
          content: 'Bir sinif kullanarak istedigin kadar nesne yaratabilirsin:\n\nOyuncu o1 = new Oyuncu();\no1.isim = "Kahraman1";\n\nOyuncu o2 = new Oyuncu();\no2.isim = "Kahraman2";\n\no1 ve o2 birbirinden BAGIMSIZDIR - kendi degerlerini tasirlar!',
        ),

        DragDropStep(
          id: 'cs3_1_dd1',
          instruction: 'Kavramlari dogru tanimlarla eslestir!',
          items: [
            DraggableItem(id: 'class', content: 'class Oyuncu { }'),
            DraggableItem(id: 'object', content: 'new Oyuncu()'),
          ],
          dropZones: [
            DropZone(id: 'template', label: 'Plan/Sablon'),
            DropZone(id: 'real', label: 'Gercek Nesne'),
          ],
          correctMapping: {
            'class': 'template',
            'object': 'real',
          },
          successMessage: 'Sinif ve nesne farkini anladin!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs3_1_summary',
          title: 'OOP Yolculugu Basladi!',
          content: '🏗️ Nesne yonelimli programlamanin temelini attin!\n\n✓ Sinif (class) = plan\n✓ Nesne (object) = gercek varlik\n✓ new ile nesne olusturma\n\nSonraki: Sinif icine METOD ekleme!',
          tipEmoji: '🏅',
          tip: 'OOP Baslangic rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 3.2: Metodlar
    InteractiveLesson(
      id: 'csharp_3_2',
      courseId: 'csharp',
      title: 'Metodlar',
      subtitle: 'Nesnelere davranis kazandir',
      order: 8,
      xpReward: 85,
      badge: 'csharp_method_master',
      steps: [
        IntroStep(
          id: 'cs3_2_intro',
          mascotEmoji: '⚡',
          mascotMessage: 'Nesnelerimize DAVRANIS kazandirmanin zamani geldi: METODLAR ile!',
        ),

        ExplanationStep(
          id: 'cs3_2_exp1',
          title: 'Metod Nedir?',
          content: 'Bir metod, bir sinifin YAPABILECEGI bir islemdir:\n\nclass Oyuncu {\n    public string isim;\n\n    public void SelamVer() {\n        Console.WriteLine(\$"Merhaba, ben {isim}");\n    }\n}\n\nC#\'ta metod isimleri genelde BUYUK harfle baslar (SelamVer)!',
          tipEmoji: '⚡',
          tip: 'Bu, C# ile Java arasindaki kucuk bir stil farki - C#\'ta metodlar buyuk harfle baslar!',
        ),

        MultipleChoiceStep(
          id: 'cs3_2_q1',
          question: 'C#\'ta metod isimleri genelde nasil baslar?',
          options: [
            ChoiceOption(text: 'Buyuk harfle (SelamVer)', emoji: '✅'),
            ChoiceOption(text: 'Kucuk harfle (selamVer)', emoji: '❌'),
            ChoiceOption(text: 'Alt cizgi ile (_selamVer)', emoji: '❌'),
            ChoiceOption(text: 'Sayi ile (1selamVer)', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'C# konvansiyonunda metod isimleri buyuk harfle baslar - buna PascalCase denir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'cs3_2_exp2',
          title: 'Parametre Alan Metodlar',
          content: 'Metodlar disaridan bilgi (parametre) alabilir:\n\npublic void SelamVer(string isim) {\n    Console.WriteLine(\$"Merhaba, {isim}!");\n}\n\n// Kullanimi:\nSelamVer("Ali"); // "Merhaba, Ali!"\nSelamVer("Ayse"); // "Merhaba, Ayse!"',
        ),

        MultipleChoiceStep(
          id: 'cs3_2_q2',
          question: 'int Topla(int a, int b) metodunda "a" ve "b" ye ne denir?',
          options: [
            ChoiceOption(text: 'Parametre', emoji: '✅'),
            ChoiceOption(text: 'Sinif', emoji: '❌'),
            ChoiceOption(text: 'Nesne', emoji: '❌'),
            ChoiceOption(text: 'Liste', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'a ve b, metodun disaridan aldigi degerler - yani parametrelerdir!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs3_2_exp3',
          title: 'return ile Deger Dondurme',
          content: 'Bir metod bir DEGER hesaplayip geri dondurebilir:\n\npublic int Topla(int a, int b) {\n    return a + b;\n}\n\n// Kullanimi:\nint sonuc = Topla(3, 5); // sonuc = 8\n\nvoid yerine int yazdik cunku artik bir sayi DONDURUYORUZ!',
          tipEmoji: '↩️',
          tip: 'void = "hicbir sey dondurmez", int/string/double = "bu tipte bir sey dondurur"',
        ),

        OrderingStep(
          id: 'cs3_2_order',
          instruction: 'Iki sayiyi toplayan bir metodu sirala',
          items: [
            OrderItem(id: 's1', content: 'public int Topla(int a, int b) {', isCode: true),
            OrderItem(id: 's2', content: 'return a + b;', isCode: true),
            OrderItem(id: 's3', content: '}', isCode: true),
          ],
          correctOrder: ['s1', 's2', 's3'],
          context: 'a ve b parametrelerini toplayip sonucu donduren metod',
          xpReward: 20,
        ),

        ProjectStep(
          id: 'cs3_2_project',
          title: 'Mini Proje: Oyuncu Sinifi',
          description: 'Isim ve can degerini tutan, hasar alan bir metodu olan Oyuncu sinifi yaz!',
          requirements: [
            'Oyuncu sinifi olustur (isim, can)',
            'HasarAl(int miktar) adinda bir metod yaz',
            'Metod, can degerini miktar kadar azaltsin',
            'main icinde bir Oyuncu nesnesi olustur ve metodu cagir',
          ],
          hints: [
            'public void HasarAl(int miktar) { can -= miktar; }',
            'Oyuncu o = new Oyuncu(); o.HasarAl(20);',
          ],
          starterCode: 'class Oyuncu {\n    public string isim;\n    public int can = 100;\n\n    public void HasarAl(int miktar) {\n        // buraya hesaplamayi yaz\n    }\n}',
          language: 'csharp',
          validation: ProjectValidation(
            mustContain: ['class Oyuncu', 'HasarAl', 'can'],
          ),
          xpReward: 45,
        ),

        ExplanationStep(
          id: 'cs3_2_summary',
          title: 'Metod Ustasi!',
          content: '⚡ Nesnelere davranis kazandirabiliyorsun!\n\n✓ Metod tanimlama\n✓ Parametre alma\n✓ return ile deger dondurme\n\nSonraki: Kalitim ile kod tekrarini azalt!',
          tipEmoji: '🏅',
          tip: 'Metod Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 3.3: Kalitim
    InteractiveLesson(
      id: 'csharp_3_3',
      courseId: 'csharp',
      title: 'Kalitim (Inheritance)',
      subtitle: 'Sinif ozelliklerini miras al',
      order: 9,
      xpReward: 90,
      badge: 'csharp_inheritance_master',
      steps: [
        IntroStep(
          id: 'cs3_3_intro',
          mascotEmoji: '👨‍👦',
          mascotMessage: 'Bir Dusman sinifi ile bir Oyuncu sinifi cok benzer olabilir - ikisi de "Karakter" degil mi? KALITIM ile kod tekrarini onleyecegiz!',
        ),

        ExplanationStep(
          id: 'cs3_3_exp1',
          title: 'Kalitim Nedir?',
          content: 'Kalitim, bir sinifin baska bir sinifin ozelliklerini "miras almasidir":\n\nclass Karakter {\n    public string isim;\n    public int can;\n}\n\nclass Oyuncu : Karakter {\n    public int puan;\n}\n\nDikkat: C#\'ta kalitim icin extends DEGIL, IKI NOKTA (:) kullanilir!',
          tipEmoji: '👨‍👦',
          tip: 'Java\'da "extends" kullanilirken, C#\'ta sadece ":" (iki nokta) yeterlidir!',
        ),

        MultipleChoiceStep(
          id: 'cs3_3_q1',
          question: 'C#\'ta kalitim (inheritance) icin hangi isaret kullanilir?',
          options: [
            ChoiceOption(text: ': (iki nokta)', emoji: '✅', isCode: true),
            ChoiceOption(text: 'extends', emoji: '❌', isCode: true),
            ChoiceOption(text: 'inherits', emoji: '❌', isCode: true),
            ChoiceOption(text: '->', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'C#\'ta kalitim icin sadece : (iki nokta) kullanilir - Java\'daki extends\'ten farkli!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs3_3_exp2',
          title: 'Ust Sinif ve Alt Sinif',
          content: 'Kalitimda iki taraf vardir:\n\nKarakter = Ust sinif (base class) - genel ozellikler\nOyuncu = Alt sinif (derived class) - ozel ozellikler + Karakter\'in hepsi\n\nOyuncu nesnesi hem isim/can (Karakter\'den) hem de puan (kendi) ozelliklerine sahiptir!',
        ),

        MultipleChoiceStep(
          id: 'cs3_3_q2',
          question: 'class Dusman : Karakter { } tanimlandiginda, Dusman nesnesi hangi ozelliklere sahip olur?',
          options: [
            ChoiceOption(text: 'Karakter\'in ozellikleri + kendi ozellikleri', emoji: '✅'),
            ChoiceOption(text: 'Sadece kendi ozellikleri', emoji: '❌'),
            ChoiceOption(text: 'Sadece Karakter\'in ozellikleri', emoji: '❌'),
            ChoiceOption(text: 'Hicbir ozellik', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Kalitim sayesinde Dusman, Karakter\'in tum ozelliklerini ALIR ve kendi ozelliklerini de EKLEYEBILIR!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs3_3_exp3',
          title: 'Neden Kalitim Kullanilir?',
          content: 'Kalitim olmadan Oyuncu ve Dusman siniflarinda isim ve can\'i AYRI AYRI yazman gerekirdi (kod tekrari!).\n\nUnity oyunlarinda bu cok kullanilir: MonoBehaviour adli temel sinifi TUM oyun nesneleri miras alir!',
          tipEmoji: '♻️',
          tip: 'Iyi programcilar kod tekrarindan kacinir - kalitim bunun icin harika bir arac!',
        ),

        DragDropStep(
          id: 'cs3_3_dd1',
          instruction: 'Sinif iliskisini dogru role surukle!',
          items: [
            DraggableItem(id: 'karakter', content: 'Karakter'),
            DraggableItem(id: 'oyuncu', content: 'Oyuncu : Karakter'),
          ],
          dropZones: [
            DropZone(id: 'parent', label: 'Ust Sinif (base)'),
            DropZone(id: 'child', label: 'Alt Sinif (derived)'),
          ],
          correctMapping: {
            'karakter': 'parent',
            'oyuncu': 'child',
          },
          successMessage: 'Ust sinif ve alt sinif iliskisini kavradin!',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'cs3_3_summary',
          title: 'Kalitim Ustasi!',
          content: '👨‍👦 Kod tekrarini onlemeyi ogrendin!\n\n✓ : (iki nokta) ile kalitim\n✓ Ust sinif / alt sinif iliskisi\n✓ Unity\'de bu mantigin kullanimi\n\nSonraki modul: Gercek projeler!',
          tipEmoji: '🏅',
          tip: 'Kalitim Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 4: PROJELER
  // ==========================================
  static final List<InteractiveLesson> module4 = [
    // LESSON 4.1: Mini Proje - Not Hesaplayici
    InteractiveLesson(
      id: 'csharp_4_1',
      courseId: 'csharp',
      title: 'Proje: Not Hesaplayici',
      subtitle: 'Ogrendiklerini birlestir',
      order: 10,
      xpReward: 90,
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'cs4_1_intro',
          mascotEmoji: '📊',
          mascotMessage: 'Simdi ogrendigin her seyi birlestirerek gercek bir program yapacagiz: harf notu hesaplayan bir sistem!',
        ),

        ExplanationStep(
          id: 'cs4_1_exp1',
          title: 'Proje Plani',
          content: '🎯 Hedef: Sayisal notu harf notuna cevirmek\n\n90-100: A\n80-89: B\n70-79: C\n70 alti: F (Kaldi)\n\nBunun icin if-else if zincirini kullanacagiz!',
        ),

        ExplanationStep(
          id: 'cs4_1_exp2',
          title: 'Adim 1: Notu Al ve Kontrol Et',
          content: 'if-else if zincirini yukaridan asagi DOGRU sirada yazmak onemlidir:\n\nint puan = 85;\nstring harfNotu;\n\nif (puan >= 90) {\n    harfNotu = "A";\n} else if (puan >= 80) {\n    harfNotu = "B";\n} else if (puan >= 70) {\n    harfNotu = "C";\n} else {\n    harfNotu = "F";\n}',
        ),

        MultipleChoiceStep(
          id: 'cs4_1_q1',
          question: 'Eger kosullari en yuksekten en dusuge SIRALI yazmazsak ne olur?',
          options: [
            ChoiceOption(text: 'Yanlis sonuclar alabiliriz', emoji: '✅'),
            ChoiceOption(text: 'Hicbir fark olmaz', emoji: '❌'),
            ChoiceOption(text: 'Program daha hizli calisir', emoji: '❌'),
            ChoiceOption(text: 'Derleme hatasi olur', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Kosullari sirayla kontrol ederiz ve ilk dogru olani kullaniriz - siralama yanlissa mantik hatasi olusur!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs4_1_exp3',
          title: 'Adim 2: Sonucu Yazdir',
          content: 'Son olarak sonucu kullaniciya gosterelim:\n\nConsole.WriteLine(\$"Puanin: {puan}");\nConsole.WriteLine(\$"Harf notun: {harfNotu}");\n\nString interpolation (\$"...") ile temiz bir gosterim yapiyoruz!',
        ),

        ProjectStep(
          id: 'cs4_1_project',
          title: 'Proje: Not Hesaplayici',
          description: 'Bir sayisal notu alip harf notuna ceviren tam bir program yaz!',
          requirements: [
            'int puan degiskeni tanimla',
            'if-else if-else zinciri ile harf notunu belirle (A/B/C/F)',
            'Hem puani hem harf notunu Console.WriteLine ile yazdir',
          ],
          hints: [
            'if (puan >= 90) { harfNotu = "A"; }',
            'Sirayla en yuksekten en dusuge kontrol et',
            'En son else ile "F" durumunu yakala',
          ],
          starterCode: 'class NotHesaplayici {\n    static void Main() {\n        int puan = 85;\n        string harfNotu;\n\n        // if-else if zincirini yaz\n\n        Console.WriteLine(\$"Harf notun: {harfNotu}");\n    }\n}',
          language: 'csharp',
          validation: ProjectValidation(
            mustContain: ['if', 'else', 'harfNotu'],
          ),
          xpReward: 45,
        ),

        ExplanationStep(
          id: 'cs4_1_summary',
          title: 'Ilk Gercek Proje Tamamlandi!',
          content: '📊 Kontrol yapilarini gercek bir problemde kullandin!\n\n✓ if-else if zinciri\n✓ Mantikli siralama\n✓ String interpolation ile gosterim\n\nSonraki: Bir Oyuncu sinifi ile daha buyuk bir proje!',
          tipEmoji: '🏆',
          tip: 'Not Hesaplayici projesini tamamladin!',
        ),
      ],
    ),

    // LESSON 4.2: Mini Proje - Basit Envanter Sistemi
    InteractiveLesson(
      id: 'csharp_4_2',
      courseId: 'csharp',
      title: 'Proje: Envanter Sistemi',
      subtitle: 'Siniflari gercek hayatta kullan',
      order: 11,
      xpReward: 100,
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'cs4_2_intro',
          mascotEmoji: '🎒',
          mascotMessage: 'Bir oyun envanteri (esya cantasi) sistemi yapacagiz - sinif, nesne ve List<T> kullanarak!',
        ),

        ExplanationStep(
          id: 'cs4_2_exp1',
          title: 'Proje Plani',
          content: '🎯 Hedef: Esyalari saklayan bir envanter sistemi\n\n1. Esya sinifi (isim, deger)\n2. Envanter listesi (List<Esya>)\n3. Esya ekleme\n4. Toplam degeri hesaplama',
        ),

        ExplanationStep(
          id: 'cs4_2_exp2',
          title: 'Adim 1: Esya Sinifi',
          content: 'Once esyamizin sinifini tanimlayalim:\n\nclass Esya {\n    public string isim;\n    public int deger;\n}\n\nSonra bir liste ile bircok esyayi tutalim:\n\nList<Esya> envanter = new List<Esya>();',
          visuals: [
            VisualElement(
              type: VisualType.codeSnippet,
              content: 'class Esya {\n  public string isim;\n  public int deger;\n}',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'cs4_2_q1',
          question: 'List<Esya> envanter = new List<Esya>(); satirinda <Esya> ne anlama gelir?',
          options: [
            ChoiceOption(text: 'Listenin sadece Esya tipi nesneler tutacagini belirtir', emoji: '✅'),
            ChoiceOption(text: 'Bir hata mesajidir', emoji: '❌'),
            ChoiceOption(text: 'Esya sinifini siler', emoji: '❌'),
            ChoiceOption(text: 'Rastgele bir isimdir', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '<Esya>, bu listenin ICINDE SADECE Esya tipi nesneler olacagini belirten "generic tip" kullanimidir!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs4_2_exp3',
          title: 'Adim 2: Esya Ekle ve Toplami Hesapla',
          content: 'Simdi envantere esya ekleyip toplam degerini hesaplayalim:\n\nEsya kilic = new Esya();\nkilic.isim = "Kilic";\nkilic.deger = 50;\nenvanter.Add(kilic);\n\nint toplamDeger = 0;\nforeach (Esya e in envanter) {\n    toplamDeger += e.deger;\n}\nConsole.WriteLine(\$"Toplam deger: {toplamDeger}");',
          tipEmoji: '🎒',
          tip: 'foreach ile listenin icindeki tum nesneleri kolayca gezebilirsin!',
        ),

        ProjectStep(
          id: 'cs4_2_project',
          title: 'Proje: Oyun Envanteri',
          description: 'Esyalari saklayan ve toplam degerini hesaplayan bir envanter sistemi yaz!',
          requirements: [
            'Esya sinifi tanimla (isim, deger)',
            'List<Esya> ile bir envanter listesi olustur',
            'En az 3 esya ekle (Add ile)',
            'foreach ile toplam degeri hesapla ve yazdir',
          ],
          hints: [
            'class Esya { public string isim; public int deger; }',
            'List<Esya> envanter = new List<Esya>();',
            'foreach (Esya e in envanter) { toplamDeger += e.deger; }',
          ],
          starterCode: 'class Esya {\n    public string isim;\n    public int deger;\n}\n\nclass Ana {\n    static void Main() {\n        List<Esya> envanter = new List<Esya>();\n        // esyalari ekle ve toplami hesapla\n    }\n}',
          language: 'csharp',
          validation: ProjectValidation(
            mustContain: ['class Esya', 'List<Esya>', 'Add'],
          ),
          xpReward: 50,
        ),

        ExplanationStep(
          id: 'cs4_2_summary',
          title: 'Sistem Gelistirici!',
          content: '🎒 Gercek bir OOP sistemi kurdun!\n\n✓ Sinif tasarimi\n✓ List<T> kullanimi\n✓ foreach ile toplama hesaplama\n\nSonraki: Kalitimi de kullanan final proje!',
          tipEmoji: '🏆',
          tip: 'Sistem Gelistirici rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 4.3: Final Proje - Basit Oyun Karakteri
    InteractiveLesson(
      id: 'csharp_4_3',
      courseId: 'csharp',
      title: 'Final Proje: Oyun Karakteri',
      subtitle: 'Ogrendigin her seyi birlestir!',
      order: 12,
      xpReward: 130,
      badge: 'csharp_graduate',
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'cs4_3_intro',
          mascotEmoji: '🎓',
          mascotMessage: 'Tebrikler, buraya kadar geldin! Simdi ogrendigin HER SEYI kullanarak basit bir oyun karakteri sistemi yapacagiz - tipki Unity\'de oldugu gibi!',
        ),

        ExplanationStep(
          id: 'cs4_3_exp1',
          title: 'Proje Plani',
          content: '🎯 Hedef: Can\'i olan, hasar alabilen, saldirabilen bir Karakter sistemi\n\n📦 Sinif ve metodlar\n🔀 Kontrol yapilari (can 0\'in altina inemez)\n👨‍👦 Kalitim (Oyuncu ve Dusman, Karakter\'den turer)\n\nHepsini birlestirecegiz!',
        ),

        ExplanationStep(
          id: 'cs4_3_exp2',
          title: 'Adim 1: Temel Karakter Sinifi',
          content: 'Once ortak Karakter sinifimizi tanimlayalim:\n\nclass Karakter {\n    public string isim;\n    public int can = 100;\n\n    public void HasarAl(int miktar) {\n        can -= miktar;\n        if (can < 0) {\n            can = 0;\n        }\n    }\n}',
        ),

        ExplanationStep(
          id: 'cs4_3_exp3',
          title: 'Adim 2: Can Sifirin Altina Inmesin',
          content: 'Gercekci bir oyunda can ASLA negatif olmamalidir!\n\npublic void HasarAl(int miktar) {\n    can -= miktar;\n    if (can < 0) {\n        can = 0;\n    }\n    if (can == 0) {\n        Console.WriteLine(\$"{isim} yenildi!");\n    }\n}\n\nIf kontrolu ile mantik hatalarini onceden onluyoruz!',
          tipEmoji: '⚠️',
          tip: 'Iyi programcilar "sinir durumlarini" (edge cases) her zaman dusunur!',
        ),

        MultipleChoiceStep(
          id: 'cs4_3_q1',
          question: 'HasarAl metodunda "if (can < 0) { can = 0; }" satiri neden onemlidir?',
          options: [
            ChoiceOption(text: 'Canin negatif bir sayi olmasini engeller', emoji: '✅'),
            ChoiceOption(text: 'Programi hizlandirir', emoji: '❌'),
            ChoiceOption(text: 'Hicbir onemi yok', emoji: '❌'),
            ChoiceOption(text: 'Sadece gorunum icin', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Mantiksal olarak can negatif olamaz (-20 can gibi bir sey mantiksiz) - bu kontrol bunu engeller!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'cs4_3_exp4',
          title: 'Adim 3: Kalitim ile Oyuncu ve Dusman',
          content: 'Simdi Karakter\'den tureyen iki alt sinif yapalim:\n\nclass Oyuncu : Karakter {\n    public int puan = 0;\n}\n\nclass Dusman : Karakter {\n    public int saldiriGucu = 10;\n}\n\nHer ikisi de Karakter\'in isim, can ve HasarAl() ozelliklerini miras alir, artı kendi ozel alanlarina sahiptir!',
        ),

        ProjectStep(
          id: 'cs4_3_project',
          title: 'Final Proje: Tam Karakter Sistemi',
          description: 'Ogrendigin her seyi birlestirerek eksiksiz bir oyun karakteri sistemi yap!',
          requirements: [
            'Karakter sinifi olustur (isim, can, HasarAl metodu)',
            'HasarAl metodunda can 0\'in altina inmesini engelle',
            'Oyuncu : Karakter ve Dusman : Karakter ile kalitim kullan',
            'main icinde bir Oyuncu ve bir Dusman nesnesi olustur',
            'HasarAl metodunu cagirarak test et ve sonuclari yazdir',
          ],
          hints: [
            'class Karakter { public string isim; public int can = 100; public void HasarAl(int m) {...} }',
            'class Oyuncu : Karakter { public int puan; }',
            'if (can < 0) { can = 0; }',
          ],
          starterCode: 'class Karakter {\n    public string isim;\n    public int can = 100;\n\n    public void HasarAl(int miktar) {\n        // hasar mantigini yaz\n    }\n}\n\nclass Oyuncu : Karakter {\n    public int puan = 0;\n}\n\nclass Dusman : Karakter {\n    public int saldiriGucu = 10;\n}\n\nclass Ana {\n    static void Main() {\n        // Oyuncu ve Dusman nesneleri olustur ve test et\n    }\n}',
          language: 'csharp',
          validation: ProjectValidation(
            mustContain: ['class Karakter', 'Oyuncu : Karakter', 'HasarAl'],
          ),
          xpReward: 65,
        ),

        ExplanationStep(
          id: 'cs4_3_summary',
          title: '🎓 C# MEZUNU OLDUN!',
          content: '🎉💜🎉 C# KURSUNU TAMAMLADIN!\n\n✓ Degiskenler ve veri tipleri\n✓ Kontrol yapilari (if-else, donguler)\n✓ Diziler ve List<T>\n✓ Nesne yonelimli programlama (sinif, nesne, metod, kalitim)\n✓ Gercek bir oyun karakteri sistemi yazdin\n\nArtik Unity ile kendi oyununu yapmaya baslayabilirsin!',
          tipEmoji: '🏆',
          tip: 'C# Mezunu rozetini kazandin! Bu becerilerle Unity oyun gelistirmeye adim atabilirsin.',
        ),
      ],
    ),
  ];

  /// Get all C# lessons
  static List<InteractiveLesson> getCSharpInteractiveLessons() {
    return [
      ...module1,
      ...module2,
      ...module3,
      ...module4,
    ];
  }

  /// Get lessons for a specific module
  static List<InteractiveLesson> getLessonsForModule(int moduleNumber) {
    switch (moduleNumber) {
      case 1:
        return module1;
      case 2:
        return module2;
      case 3:
        return module3;
      case 4:
        return module4;
      default:
        return [];
    }
  }
}

/// C# badges
class CSharpBadges {
  static const List<LessonBadge> all = [
    LessonBadge(
      id: 'csharp_starter',
      name: 'C# Baslangic',
      description: 'C# dunyasina adim attin!',
      emoji: '💜',
      rarity: BadgeRarity.common,
      category: BadgeCategory.lesson,
    ),
    LessonBadge(
      id: 'first_csharp_code',
      name: 'Ilk C# Kodu',
      description: 'Ilk C# programini yazdin!',
      emoji: '💻',
      rarity: BadgeRarity.common,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'csharp_variable_master',
      name: 'Degisken Ustasi',
      description: 'Veri tiplerinde uzmanlaştin!',
      emoji: '📦',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'csharp_condition_master',
      name: 'Karar Verme Ustasi',
      description: 'if-else ile programlarin karar vermesini sagladin!',
      emoji: '🤔',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'csharp_loop_master',
      name: 'Dongu Ustasi',
      description: 'for, while ve foreach dongulerinde uzmanlaştin!',
      emoji: '🔁',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'csharp_array_master',
      name: 'Dizi Ustasi',
      description: 'Diziler ve listelerle birden fazla veriyi yonettin!',
      emoji: '📋',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'csharp_oop_starter',
      name: 'OOP Baslangic',
      description: 'Sinif ve nesne kavramlarini ogrendin!',
      emoji: '🏗️',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'csharp_method_master',
      name: 'Metod Ustasi',
      description: 'Nesnelere davranis kazandirdin!',
      emoji: '⚡',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'csharp_inheritance_master',
      name: 'Kalitim Ustasi',
      description: ': ile kod tekrarini onledin!',
      emoji: '👨‍👦',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'csharp_graduate',
      name: 'C# Mezunu',
      description: 'Tum C# kursunu tamamladin ve final projeyi bitirdin!',
      emoji: '🎓',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.course,
    ),
  ];
}
