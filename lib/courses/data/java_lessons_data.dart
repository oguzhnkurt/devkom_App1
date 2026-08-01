import '../models/interactive_lesson_model.dart';

/// Java Course - Interactive lessons for programming fundamentals
/// Scratch/CSS/HTML dersleriyle ayni adim adim, kalite ve formatta
class JavaLessonsData {
  // ==========================================
  // MODULE 1: JAVA'YA GİRİŞ
  // ==========================================
  static final List<InteractiveLesson> module1 = [
    // LESSON 1.1: Java Nedir?
    InteractiveLesson(
      id: 'java_1_1',
      courseId: 'java',
      title: 'Java\'ya Hos Geldin!',
      subtitle: 'Bir kere yaz, her yerde calistir',
      order: 1,
      xpReward: 50,
      badge: 'java_starter',
      steps: [
        IntroStep(
          id: 'j1_1_intro',
          mascotEmoji: '☕',
          mascotMessage: 'Merhaba! Ben Java. Dunyanin en cok kullanilan dillerinden biriyim - Android telefonundaki uygulamalarin cogu benimle yazildi!',
          highlights: [
            'Android uygulamalari yap',
            'Kurumsal yazilimlar',
            'Guclu ve guvenilir',
          ],
        ),

        ExplanationStep(
          id: 'j1_1_exp1',
          title: 'Java Nedir?',
          content: 'Java, 1995\'te Sun Microsystems tarafindan gelistirilen guclu bir programlama dilidir.\n\nSlogani: "Bir kere yaz, her yerde calistir!" (Write Once, Run Anywhere)\n\nBu ne demek? Java kodun, Windows\'ta, Mac\'te, Linux\'ta, hatta Android telefonlarda AYNI SEKILDE calisir!',
          tipEmoji: '☕',
          tip: 'Minecraft oyunu (orijinal surumu) tamamen Java ile yazilmistir!',
        ),

        MultipleChoiceStep(
          id: 'j1_1_q1',
          question: 'Java\'nin unlu slogani nedir?',
          options: [
            ChoiceOption(text: 'Bir kere yaz, her yerde calistir', emoji: '✅'),
            ChoiceOption(text: 'En hizli dil', emoji: '❌'),
            ChoiceOption(text: 'Sadece web icin', emoji: '❌'),
            ChoiceOption(text: 'Sadece oyunlar icin', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Java kodu, JVM (Java Virtual Machine) sayesinde her platformda calisabilir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'j1_1_exp2',
          title: 'Java Nerede Kullanilir?',
          content: 'Java her yerde karsina cikar:\n\n📱 Android uygulamalari\n🏢 Kurumsal yazilimlar (bankalar, sirketler)\n🌐 Web sunuculari\n🎮 Oyunlar (Minecraft!)\n💾 Buyuk veri sistemleri',
        ),

        MultipleChoiceStep(
          id: 'j1_1_q2',
          question: 'Hangi popular oyun Java ile yazilmistir?',
          options: [
            ChoiceOption(text: 'Minecraft', emoji: '✅'),
            ChoiceOption(text: 'Fortnite', emoji: '❌'),
            ChoiceOption(text: 'FIFA', emoji: '❌'),
            ChoiceOption(text: 'Tetris', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Minecraft\'in orijinal (Java Edition) surumu tamamen Java ile yazilmistir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'j1_1_exp3',
          title: 'JVM Nedir?',
          content: 'Java Virtual Machine (JVM), Java kodunu bilgisayarinin anlayacagi dile ceviren bir "cevirmen"dir.\n\nBu sayede ayni Java programi Windows\'ta da, Mac\'te de calisir - JVM her platform icin ayri ayri var, ama senin kodun ayni kalir!',
          tipEmoji: '🔄',
          tip: 'JVM, "Bir kere yaz, her yerde calistir" sihrinin arkasindaki gercek kahraman!',
        ),

        ExplanationStep(
          id: 'j1_1_summary',
          title: 'Java Baslangic!',
          content: '☕ Java dunyasina hosgeldin!\n\n✓ Java\'nin ne oldugunu ogrendin\n✓ Nerede kullanildigini kesfettin\n✓ JVM kavramini tandin\n\nSonraki ders: Ilk Java programini yazacaksin!',
          tipEmoji: '🏆',
          tip: 'Java Baslangic rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.2: Ilk Programin
    InteractiveLesson(
      id: 'java_1_2',
      courseId: 'java',
      title: 'Ilk Programin',
      subtitle: 'Merhaba Dunya yaz!',
      order: 2,
      xpReward: 60,
      badge: 'first_java_code',
      steps: [
        IntroStep(
          id: 'j1_2_intro',
          mascotEmoji: '💻',
          mascotMessage: 'Her programcinin efsanevi ilk adimi: "Merhaba Dunya" yazdirmak! Haydi sen de yap!',
        ),

        ExplanationStep(
          id: 'j1_2_exp1',
          title: 'Java Programinin Iskeleti',
          content: 'Java\'da HER SEY bir sinif (class) icinde yazilir:\n\npublic class Merhaba {\n    public static void main(String[] args) {\n        // kodun burada\n    }\n}\n\nProgram HER ZAMAN main metodundan baslar calismaya!',
          tipEmoji: '🏗️',
          tip: 'Dosya adi ile class adi AYNI olmalidir! (Merhaba.java -> class Merhaba)',
        ),

        MultipleChoiceStep(
          id: 'j1_2_q1',
          question: 'Bir Java programi calismaya nereden baslar?',
          options: [
            ChoiceOption(text: 'main metodundan', emoji: '✅'),
            ChoiceOption(text: 'class satirindan', emoji: '❌'),
            ChoiceOption(text: 'En son satirdan', emoji: '❌'),
            ChoiceOption(text: 'Rastgele bir yerden', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Her Java programi public static void main(String[] args) metodundan baslar!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'j1_2_exp2',
          title: 'System.out.println()',
          content: 'Ekrana yazi yazdirmak icin System.out.println() kullanilir:\n\nSystem.out.println("Merhaba Dunya!");\n\nBu satir, ekrana "Merhaba Dunya!" yazar ve alt satira geçer.\n\nDikkat: Her satir noktali virgul (;) ile biter!',
        ),

        MultipleChoiceStep(
          id: 'j1_2_q2',
          question: 'Ekrana "Selam!" yazdirmak icin dogru kod hangisi?',
          options: [
            ChoiceOption(text: 'System.out.println("Selam!");', emoji: '✅', isCode: true),
            ChoiceOption(text: 'print("Selam!")', emoji: '❌', isCode: true),
            ChoiceOption(text: 'System.print("Selam!");', emoji: '❌', isCode: true),
            ChoiceOption(text: 'echo "Selam!";', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'System.out.println() Java\'da ekrana yazi yazdirmak icin kullanilir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'j1_2_exp3',
          title: 'Her Satir Noktali Virgul ile Biter',
          content: 'Java\'da her komut satiri (statement) noktali virgul (;) ile bitmelidir:\n\nSystem.out.println("Bir");\nSystem.out.println("Iki");\nSystem.out.println("Uc");\n\nBunu unutursan Java hata verir!',
          tipEmoji: '⚠️',
          tip: 'Noktali virgulu unutmak, yeni baslayanlarin en sik yaptigi hatadir!',
        ),

        OrderingStep(
          id: 'j1_2_order',
          instruction: 'Basit bir Java programini dogru sirala',
          items: [
            OrderItem(id: 's1', content: 'public class Merhaba {', isCode: true),
            OrderItem(id: 's2', content: 'public static void main(String[] args) {', isCode: true),
            OrderItem(id: 's3', content: 'System.out.println("Merhaba Dunya!");', isCode: true),
            OrderItem(id: 's4', content: '}', isCode: true),
            OrderItem(id: 's5', content: '}', isCode: true),
          ],
          correctOrder: ['s1', 's2', 's3', 's4', 's5'],
          context: 'Ekrana "Merhaba Dunya!" yazdiran tam bir Java programi',
          xpReward: 20,
        ),

        ProjectStep(
          id: 'j1_2_project',
          title: 'Mini Proje: Kendini Tanit',
          description: 'System.out.println() kullanarak kendini tanitan kucuk bir program yaz!',
          requirements: [
            'public class ile bir sinif olustur',
            'main metodunu yaz',
            'En az 3 System.out.println() satiri kullan (isim, yas, hobi)',
          ],
          hints: [
            'System.out.println("Adim: Ahmet");',
            'System.out.println("Yasim: 12");',
            'Her satirin sonunda ; olmali',
          ],
          starterCode: 'public class BenimHakkimda {\n    public static void main(String[] args) {\n        // buraya kodunu yaz\n    }\n}',
          language: 'java',
          validation: ProjectValidation(
            mustContain: ['System.out.println', 'public class', 'main'],
          ),
          xpReward: 30,
        ),

        ExplanationStep(
          id: 'j1_2_summary',
          title: 'Ilk Kod Yazildi!',
          content: '🎊 Ilk Java programini yazdin!\n\n✓ class ve main yapisini ogrendin\n✓ System.out.println() kullandin\n✓ Noktali virgulu unutmadin\n\nSonraki: Degiskenler ve veri tipleri!',
          tipEmoji: '🎖️',
          tip: 'Ilk Kod rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.3: Degiskenler ve Veri Tipleri
    InteractiveLesson(
      id: 'java_1_3',
      courseId: 'java',
      title: 'Degiskenler ve Veri Tipleri',
      subtitle: 'Bilgiyi sakla',
      order: 3,
      xpReward: 70,
      badge: 'variable_master',
      steps: [
        IntroStep(
          id: 'j1_3_intro',
          mascotEmoji: '📦',
          mascotMessage: 'Programlarin bilgiyi hatirlamasi gerekir - isim, yas, puan gibi. Bunun icin DEGISKEN kullanacagiz!',
        ),

        ExplanationStep(
          id: 'j1_3_exp1',
          title: 'Java\'da Degisken Tanimlama',
          content: 'Java\'da bir degisken tanimlarken TIP belirtmen gerekir:\n\nint yas = 12;\nString isim = "Ahmet";\ndouble boy = 1.45;\nboolean ogrenciMi = true;\n\nTip + isim + = + deger + ;',
          tipEmoji: '📦',
          tip: 'Java "statik tipli" bir dildir - her degiskenin tipi bastan belli olmalidir!',
        ),

        MultipleChoiceStep(
          id: 'j1_3_q1',
          question: 'Bir tam sayi (12, 100, -5 gibi) icin hangi veri tipini kullaniriz?',
          options: [
            ChoiceOption(text: 'int', emoji: '✅', isCode: true),
            ChoiceOption(text: 'String', emoji: '❌', isCode: true),
            ChoiceOption(text: 'boolean', emoji: '❌', isCode: true),
            ChoiceOption(text: 'double', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'int (integer), tam sayilar icin kullanilir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'j1_3_exp2',
          title: 'Temel Veri Tipleri',
          content: 'Java\'nin 4 temel veri tipi:\n\nint: Tam sayi (12, -5, 100)\ndouble: Ondalikli sayi (3.14, 1.45)\nString: Metin ("Merhaba", "Ahmet")\nboolean: Dogru/yanlis (true, false)\n\nString buyuk S ile baslar, digerleri kucuk harfle!',
        ),

        MultipleChoiceStep(
          id: 'j1_3_q2',
          question: '"Merhaba" gibi bir metin icin hangi veri tipi kullanilir?',
          options: [
            ChoiceOption(text: 'String', emoji: '✅', isCode: true),
            ChoiceOption(text: 'int', emoji: '❌', isCode: true),
            ChoiceOption(text: 'text', emoji: '❌', isCode: true),
            ChoiceOption(text: 'char*', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'String, metin (yazi) verilerini tutmak icin kullanilir. Buyuk S ile yazilir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'j1_3_exp3',
          title: 'Degiskenleri Kullanma',
          content: 'Bir kere tanimladigin degiskeni istedigin yerde kullanabilirsin:\n\nint yas = 12;\nSystem.out.println("Yasim: " + yas);\n\n+ isareti, metin ile degiskeni BIRLESTIRMEK icin kullanilir!',
          tipEmoji: '🔗',
          tip: '"Yasim: " + yas gibi birlestirmeye "concatenation" (birlestirme) denir!',
        ),

        MultipleChoiceStep(
          id: 'j1_3_q3',
          question: 'int puan = 90; iken System.out.println("Puan: " + puan); ne yazdirir?',
          options: [
            ChoiceOption(text: 'Puan: 90', emoji: '✅'),
            ChoiceOption(text: 'Puan: puan', emoji: '❌'),
            ChoiceOption(text: '90', emoji: '❌'),
            ChoiceOption(text: 'Hata verir', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '+ isareti, "Puan: " metnini puan degiskeninin degeriyle (90) birlestirir!',
          xpReward: 15,
        ),

        DragDropStep(
          id: 'j1_3_dd1',
          instruction: 'Degeri dogru veri tipiyle eslestir!',
          items: [
            DraggableItem(id: 'v1', content: '25'),
            DraggableItem(id: 'v2', content: '"Merhaba"'),
            DraggableItem(id: 'v3', content: '3.14'),
            DraggableItem(id: 'v4', content: 'true'),
          ],
          dropZones: [
            DropZone(id: 'int', label: 'int'),
            DropZone(id: 'string', label: 'String'),
            DropZone(id: 'double', label: 'double'),
            DropZone(id: 'boolean', label: 'boolean'),
          ],
          correctMapping: {
            'v1': 'int',
            'v2': 'string',
            'v3': 'double',
            'v4': 'boolean',
          },
          successMessage: 'Veri tiplerini mukemmel ayirt ediyorsun!',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'j1_3_summary',
          title: 'Degisken Ustasi!',
          content: '📦 Artik bilgiyi saklayabiliyorsun!\n\n✓ int, String, double, boolean\n✓ Degisken tanimlama\n✓ + ile birlestirme\n\nSonraki modul: Kontrol yapilari (if-else, donguler)!',
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
    // LESSON 2.1: Eger-Degilse (if-else)
    InteractiveLesson(
      id: 'java_2_1',
      courseId: 'java',
      title: 'Eger-Degilse (if-else)',
      subtitle: 'Programin karar vermesi',
      order: 4,
      xpReward: 75,
      badge: 'condition_master',
      steps: [
        IntroStep(
          id: 'j2_1_intro',
          mascotEmoji: '🤔',
          mascotMessage: 'Programlar karar verebilir mi? EVET! if-else ile programina "eger boyle ise, sunu yap" mantigini ogretecegiz!',
        ),

        ExplanationStep(
          id: 'j2_1_exp1',
          title: 'if Yapisi',
          content: 'if, bir kosulun DOGRU olup olmadigini kontrol eder:\n\nint yas = 15;\nif (yas >= 18) {\n    System.out.println("Yetiskinsin!");\n}\n\nKosul dogruysa { } icindeki kod calisir!',
          tipEmoji: '🔍',
          tip: 'Kosul her zaman parantez ( ) icinde yazilir!',
        ),

        MultipleChoiceStep(
          id: 'j2_1_q1',
          question: 'if (yas >= 18) satiri ne anlama gelir?',
          options: [
            ChoiceOption(text: 'Yas 18 veya daha buyukse', emoji: '✅'),
            ChoiceOption(text: 'Yas tam olarak 18 ise', emoji: '❌'),
            ChoiceOption(text: 'Yas 18\'den kucukse', emoji: '❌'),
            ChoiceOption(text: 'Yas hicbir zaman 18 degilse', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '>= isareti "buyuk esittir" anlamina gelir - yas 18 veya daha fazlaysa kosul dogrudur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'j2_1_exp2',
          title: 'else: Degilse Ne Olacak?',
          content: 'Kosul yanlissa ne olacagini belirtmek icin else kullanilir:\n\nif (yas >= 18) {\n    System.out.println("Yetiskinsin!");\n} else {\n    System.out.println("Cocuksun!");\n}\n\nSadece BIRI calisir, ikisi asla ayni anda calismaz!',
        ),

        MultipleChoiceStep(
          id: 'j2_1_q2',
          question: 'Karsilastirma operatorlerinden hangisi "esit mi?" anlamina gelir?',
          options: [
            ChoiceOption(text: '==', emoji: '✅', isCode: true),
            ChoiceOption(text: '=', emoji: '❌', isCode: true),
            ChoiceOption(text: '!=', emoji: '❌', isCode: true),
            ChoiceOption(text: '<>', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'Java\'da == karsilastirma (esit mi?), tek = ise deger atama anlamina gelir. Karistirma!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'j2_1_exp3',
          title: 'else if: Birden Fazla Secenek',
          content: 'Ikiden fazla durum icin else if kullanilir:\n\nint puan = 75;\nif (puan >= 90) {\n    System.out.println("A");\n} else if (puan >= 70) {\n    System.out.println("B");\n} else {\n    System.out.println("C");\n}\n\nJava kosullari sirayla kontrol eder, ilk DOGRU olani calistirir!',
          tipEmoji: '🎯',
          tip: 'Istedigin kadar else if ekleyebilirsin!',
        ),

        MultipleChoiceStep(
          id: 'j2_1_q3',
          question: 'puan = 85 iken yukaridaki kod ne yazdirir?',
          options: [
            ChoiceOption(text: 'B', emoji: '✅'),
            ChoiceOption(text: 'A', emoji: '❌'),
            ChoiceOption(text: 'C', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '85 >= 90 yanlis, ama 85 >= 70 dogru - bu yuzden "B" yazdirilir!',
          xpReward: 15,
        ),

        OrderingStep(
          id: 'j2_1_order',
          instruction: 'Not kontrolu yapan kodu dogru sirala',
          items: [
            OrderItem(id: 's1', content: 'if (puan >= 90) {', isCode: true),
            OrderItem(id: 's2', content: 'System.out.println("A");', isCode: true),
            OrderItem(id: 's3', content: '} else {', isCode: true),
            OrderItem(id: 's4', content: 'System.out.println("Gecemedi");', isCode: true),
            OrderItem(id: 's5', content: '}', isCode: true),
          ],
          correctOrder: ['s1', 's2', 's3', 's4', 's5'],
          context: 'Puan 90 ve uzeriyse A, degilse "Gecemedi" yazdiran kod',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'j2_1_summary',
          title: 'Karar Verme Ustasi!',
          content: '🤔 Artik programlarin karar vermesini saglayabilirsin!\n\n✓ if ile kosul kontrolu\n✓ else ile alternatif\n✓ else if ile cok secenek\n\nSonraki: Donguler ile tekrar eden isler!',
          tipEmoji: '🏅',
          tip: 'Karar Verme Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 2.2: Donguler
    InteractiveLesson(
      id: 'java_2_2',
      courseId: 'java',
      title: 'Donguler',
      subtitle: 'for ve while ile tekrar et',
      order: 5,
      xpReward: 75,
      badge: 'loop_master',
      steps: [
        IntroStep(
          id: 'j2_2_intro',
          mascotEmoji: '🔁',
          mascotMessage: '"Merhaba" yazisini 100 kere yazmak ister misin? Tabii ki hayir! Donguler bu isi bizim yerimize yapacak.',
        ),

        ExplanationStep(
          id: 'j2_2_exp1',
          title: 'for Dongusu',
          content: 'for dongusu, belirli bir sayida tekrar yapar:\n\nfor (int i = 0; i < 5; i++) {\n    System.out.println("Merhaba " + i);\n}\n\n3 parca: baslangic (i=0), kosul (i<5), artis (i++)\nBu kod 5 kere calisir (0, 1, 2, 3, 4)!',
          tipEmoji: '🔢',
          tip: 'i++ demek "i\'yi bir arttir" demektir - i = i + 1 ile ayni!',
        ),

        MultipleChoiceStep(
          id: 'j2_2_q1',
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
          id: 'j2_2_exp2',
          title: 'while Dongusu',
          content: 'while dongusu, bir kosul dogru oldugu surece devam eder:\n\nint sayac = 0;\nwhile (sayac < 3) {\n    System.out.println("Sayac: " + sayac);\n    sayac++;\n}\n\nfor\'dan farki: kac kere tekrar edecegini onceden bilmiyorsan while daha uygun!',
        ),

        MultipleChoiceStep(
          id: 'j2_2_q2',
          question: 'while dongusunde sayac++ satirini unutursak ne olur?',
          options: [
            ChoiceOption(text: 'Sonsuz dongu olusur', emoji: '✅'),
            ChoiceOption(text: 'Program hemen biter', emoji: '❌'),
            ChoiceOption(text: 'Hata verir ve calismaz', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey degismez', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Sayac hic artmazsa kosul (sayac < 3) hep dogru kalir ve dongu hic durmaz - buna sonsuz dongu denir!',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'j2_2_exp3',
          title: 'Ic Ice Donguler',
          content: 'Donguler ic ice de yazilabilir - orn. bir carpim tablosu icin:\n\nfor (int i = 1; i <= 3; i++) {\n    for (int j = 1; j <= 3; j++) {\n        System.out.println(i + " x " + j);\n    }\n}\n\nDis dongu 3 kere, her seferinde ic dongu de 3 kere calisir - toplam 9 satir!',
          tipEmoji: '🎡',
          tip: 'Ic ice donguler biraz karmasik gorunebilir ama pratikle kolaylasir!',
        ),

        DragDropStep(
          id: 'j2_2_dd1',
          instruction: 'Senaryoyu dogru dongu turuyle eslestir!',
          items: [
            DraggableItem(id: 'd1', content: '10 kere tekrar et (biliyorum)'),
            DraggableItem(id: 'd2', content: 'Kullanici "dur" yazana kadar tekrarla'),
          ],
          dropZones: [
            DropZone(id: 'for', label: 'for dongusu', hint: 'Sayi belli oldugunda'),
            DropZone(id: 'while', label: 'while dongusu', hint: 'Ne zaman bitecegi belirsizken'),
          ],
          correctMapping: {
            'd1': 'for',
            'd2': 'while',
          },
          successMessage: 'Hangi dongunun ne zaman kullanilacagini ogrendin!',
          xpReward: 15,
        ),

        ProjectStep(
          id: 'j2_2_project',
          title: 'Mini Proje: Sayi Yazdirici',
          description: 'for dongusu kullanarak 1\'den 10\'a kadar sayilari ekrana yazdiran bir program yaz!',
          requirements: [
            'for dongusu kullan',
            '1\'den 10\'a kadar tum sayilari yazdir',
            'System.out.println() kullan',
          ],
          hints: [
            'for (int i = 1; i <= 10; i++) {',
            'System.out.println(i);',
          ],
          starterCode: 'public class SayiYazdirici {\n    public static void main(String[] args) {\n        // buraya donguyu yaz\n    }\n}',
          language: 'java',
          validation: ProjectValidation(
            mustContain: ['for', 'System.out.println'],
          ),
          xpReward: 35,
        ),

        ExplanationStep(
          id: 'j2_2_summary',
          title: 'Dongu Ustasi!',
          content: '🔁 Tekrar eden isleri otomatiklestirebiliyorsun!\n\n✓ for dongusu\n✓ while dongusu\n✓ Ic ice donguler\n\nSonraki: Diziler ile birden fazla veri!',
          tipEmoji: '🏅',
          tip: 'Dongu Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 2.3: Diziler
    InteractiveLesson(
      id: 'java_2_3',
      courseId: 'java',
      title: 'Diziler (Arrays)',
      subtitle: 'Birden fazla veriyi sakla',
      order: 6,
      xpReward: 80,
      badge: 'array_master',
      steps: [
        IntroStep(
          id: 'j2_3_intro',
          mascotEmoji: '📋',
          mascotMessage: '5 ogrencinin notunu ayri ayri degiskenlerde tutmak yorucu olur! Dizi (array) ile hepsini TEK bir yapida saklayabiliriz.',
        ),

        ExplanationStep(
          id: 'j2_3_exp1',
          title: 'Dizi Tanimlama',
          content: 'Bir dizi, ayni tipteki birden fazla degeri tutar:\n\nint[] notlar = {85, 90, 78, 95, 88};\nString[] isimler = {"Ali", "Ayse", "Mehmet"};\n\nKose parantez [] o degiskenin bir dizi oldugunu gosterir!',
          tipEmoji: '📋',
          tip: 'Bir diziyi bir raf gibi dusun - her goze bir deger koyarsin!',
        ),

        MultipleChoiceStep(
          id: 'j2_3_q1',
          question: 'int[] sayilar = {1, 2, 3}; satiri neyi tanimlar?',
          options: [
            ChoiceOption(text: '3 elemanli bir tam sayi dizisi', emoji: '✅'),
            ChoiceOption(text: 'Tek bir sayi', emoji: '❌'),
            ChoiceOption(text: 'Bir metin', emoji: '❌'),
            ChoiceOption(text: 'Bir hata', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '[] isareti bunun bir dizi oldugunu, {1,2,3} de icindeki 3 elemani gosterir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'j2_3_exp2',
          title: 'Dizi Elemanlarina Erisim (Index)',
          content: 'Bir dizinin elemanlarina INDEX (sira numarasi) ile erisilir. Java\'da index 0\'DAN baslar!\n\nint[] notlar = {85, 90, 78};\nSystem.out.println(notlar[0]); // 85 yazdirir\nSystem.out.println(notlar[1]); // 90 yazdirir\n\nIlk eleman index 0, ikinci eleman index 1\'dir!',
          tipEmoji: '🔢',
          tip: 'Bu en cok karistirilan konulardan biri - Java\'da SAYMAYA 0\'DAN BASLARIZ!',
        ),

        MultipleChoiceStep(
          id: 'j2_3_q2',
          question: 'int[] notlar = {85, 90, 78}; iken notlar[1] hangi degeri verir?',
          options: [
            ChoiceOption(text: '90', emoji: '✅'),
            ChoiceOption(text: '85', emoji: '❌'),
            ChoiceOption(text: '78', emoji: '❌'),
            ChoiceOption(text: 'Hata', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Index 0\'dan baslar: notlar[0]=85, notlar[1]=90, notlar[2]=78!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'j2_3_exp3',
          title: 'Diziyi Dongu ile Gezmek',
          content: 'Bir dizinin TUM elemanlarini gormek icin for dongusu kullanilir:\n\nint[] notlar = {85, 90, 78, 95};\nfor (int i = 0; i < notlar.length; i++) {\n    System.out.println(notlar[i]);\n}\n\nnotlar.length, dizideki eleman sayisini verir (burada 4)!',
          tipEmoji: '🔁',
          tip: '.length dizinin boyutunu ogrenmenin en kolay yolu!',
        ),

        OrderingStep(
          id: 'j2_3_order',
          instruction: 'Bir diziyi baştan sona yazdiran kodu sirala',
          items: [
            OrderItem(id: 's1', content: 'int[] notlar = {70, 80, 90};', isCode: true),
            OrderItem(id: 's2', content: 'for (int i = 0; i < notlar.length; i++) {', isCode: true),
            OrderItem(id: 's3', content: 'System.out.println(notlar[i]);', isCode: true),
            OrderItem(id: 's4', content: '}', isCode: true),
          ],
          correctOrder: ['s1', 's2', 's3', 's4'],
          context: 'Notlar dizisindeki tum elemanlari tek tek yazdiran kod',
          xpReward: 20,
        ),

        ProjectStep(
          id: 'j2_3_project',
          title: 'Mini Proje: Not Ortalamasi',
          description: 'Bir not dizisi olustur ve dongu kullanarak ortalamalarini hesapla!',
          requirements: [
            'int[] notlar dizisi olustur (en az 4 not)',
            'for dongusu ile tum notlari topla',
            'Toplami eleman sayisina bolerek ortalamayi bul',
            'Ortalamayi yazdir',
          ],
          hints: [
            'int toplam = 0; for (...) { toplam += notlar[i]; }',
            'double ortalama = toplam / (double) notlar.length;',
          ],
          starterCode: 'public class NotOrtalamasi {\n    public static void main(String[] args) {\n        int[] notlar = {80, 90, 75, 85};\n        // toplama ve ortalama hesabini yaz\n    }\n}',
          language: 'java',
          validation: ProjectValidation(
            mustContain: ['for', 'notlar', 'toplam'],
          ),
          xpReward: 40,
        ),

        ExplanationStep(
          id: 'j2_3_summary',
          title: 'Dizi Ustasi!',
          content: '📋 Birden fazla veriyi tek yapida yonetebiliyorsun!\n\n✓ Dizi tanimlama\n✓ Index ile erisim (0\'dan baslar!)\n✓ Dongu ile dizi gezme\n\nSonraki modul: Nesne yonelimli programlama!',
          tipEmoji: '🏅',
          tip: 'Dizi Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 3: NESNE YÖNELİMLİ PROGRAMLAMA
  // ==========================================
  static final List<InteractiveLesson> module3 = [
    // LESSON 3.1: Sinif ve Nesne
    InteractiveLesson(
      id: 'java_3_1',
      courseId: 'java',
      title: 'Sinif ve Nesne',
      subtitle: 'Kendi veri tipini yarat',
      order: 7,
      xpReward: 85,
      badge: 'oop_starter',
      steps: [
        IntroStep(
          id: 'j3_1_intro',
          mascotEmoji: '🏗️',
          mascotMessage: 'Java "nesne yonelimli" bir dildir. Simdi kendi ozel veri tiplerini yaratmayi ogrenecegiz: SINIFLAR ve NESNELER!',
        ),

        ExplanationStep(
          id: 'j3_1_exp1',
          title: 'Sinif (Class) Nedir?',
          content: 'Bir sinif, bir "sablon" veya "plan"dir. Ornegin bir Ogrenci sinifi:\n\nclass Ogrenci {\n    String isim;\n    int yas;\n}\n\nBu, her ogrencinin bir isim ve yas ozelligi olacagini soyler - ama henuz gercek bir ogrenci yok, sadece PLAN var!',
          tipEmoji: '📐',
          tip: 'Sinifi bir "kurabiye kalibi" gibi dusun - kaliptan istedigin kadar kurabiye (nesne) yapabilirsin!',
        ),

        MultipleChoiceStep(
          id: 'j3_1_q1',
          question: 'Bir sinif (class) ne ise yarar?',
          options: [
            ChoiceOption(text: 'Nesneler icin bir sablon/plan olusturur', emoji: '✅'),
            ChoiceOption(text: 'Sadece sayi saklar', emoji: '❌'),
            ChoiceOption(text: 'Programi baslatir', emoji: '❌'),
            ChoiceOption(text: 'Ekrana yazi yazdirir', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Sinif, gercek nesneler yaratmak icin kullanilan bir plan/saablondur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'j3_1_exp2',
          title: 'Nesne (Object) Olusturma',
          content: 'Siniftan gercek bir NESNE olusturmak icin new kullanilir:\n\nOgrenci ogrenci1 = new Ogrenci();\nogrenci1.isim = "Ali";\nogrenci1.yas = 12;\n\nSimdi ogrenci1 GERCEK bir nesne - kendi isim ve yas degerlerine sahip!',
          tipEmoji: '✨',
          tip: 'Ayni siniftan birden fazla nesne yaratabilirsin - her biri kendi degerlerini tutar!',
        ),

        MultipleChoiceStep(
          id: 'j3_1_q2',
          question: 'Ogrenci sinifindan yeni bir nesne olusturmak icin ne yazariz?',
          options: [
            ChoiceOption(text: 'new Ogrenci();', emoji: '✅', isCode: true),
            ChoiceOption(text: 'create Ogrenci();', emoji: '❌', isCode: true),
            ChoiceOption(text: 'Ogrenci.new();', emoji: '❌', isCode: true),
            ChoiceOption(text: 'make Ogrenci();', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'new anahtar kelimesi, bir siniftan yeni bir nesne yaratir!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'j3_1_exp3',
          title: 'Ayni Siniftan Birden Fazla Nesne',
          content: 'Bir sinif kullanarak istedigin kadar nesne yaratabilirsin:\n\nOgrenci o1 = new Ogrenci();\no1.isim = "Ali";\n\nOgrenci o2 = new Ogrenci();\no2.isim = "Ayse";\n\no1 ve o2 farkli nesnelerdir - her biri kendi isim degerini tasir, birbirini etkilemez!',
        ),

        DragDropStep(
          id: 'j3_1_dd1',
          instruction: 'Kavramlari dogru tanimlarla eslestir!',
          items: [
            DraggableItem(id: 'class', content: 'class Ogrenci { }'),
            DraggableItem(id: 'object', content: 'new Ogrenci()'),
          ],
          dropZones: [
            DropZone(id: 'template', label: 'Plan/Sablon', hint: 'Henuz gercek degil'),
            DropZone(id: 'real', label: 'Gercek Nesne', hint: 'Bellekte var olan'),
          ],
          correctMapping: {
            'class': 'template',
            'object': 'real',
          },
          successMessage: 'Sinif ve nesne farkini anladin!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'j3_1_summary',
          title: 'OOP Yolculugu Basladi!',
          content: '🏗️ Nesne yonelimli programlamanin temelini attin!\n\n✓ Sinif (class) = plan\n✓ Nesne (object) = plandan yaratilan gercek sey\n✓ new ile nesne olusturma\n\nSonraki: Sinif icine METOD ekleme!',
          tipEmoji: '🏅',
          tip: 'OOP Baslangic rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 3.2: Metodlar
    InteractiveLesson(
      id: 'java_3_2',
      courseId: 'java',
      title: 'Metodlar',
      subtitle: 'Nesnelere davranis kazandir',
      order: 8,
      xpReward: 85,
      badge: 'method_master',
      steps: [
        IntroStep(
          id: 'j3_2_intro',
          mascotEmoji: '⚡',
          mascotMessage: 'Nesnelerimiz simdiye kadar sadece veri tutuyordu. Simdi onlara DAVRANIS (yani islev) kazandiracagiz: METODLAR!',
        ),

        ExplanationStep(
          id: 'j3_2_exp1',
          title: 'Metod Nedir?',
          content: 'Bir metod, bir sinifin YAPABILECEGI bir islemdir:\n\nclass Ogrenci {\n    String isim;\n\n    void selamVer() {\n        System.out.println("Merhaba, ben " + isim);\n    }\n}\n\nselamVer(), Ogrenci sinifinin bir metodu - her ogrenci nesnesi bunu yapabilir!',
          tipEmoji: '⚡',
          tip: 'Metod isimleri genelde bir "eylem" bildirir: selamVer(), hesapla(), yazdır()',
        ),

        MultipleChoiceStep(
          id: 'j3_2_q1',
          question: 'Bir metod nedir?',
          options: [
            ChoiceOption(text: 'Bir sinifin yapabilecegi bir islem/davranis', emoji: '✅'),
            ChoiceOption(text: 'Bir veri tipi', emoji: '❌'),
            ChoiceOption(text: 'Bir dosya adi', emoji: '❌'),
            ChoiceOption(text: 'Bir hata mesaji', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Metod, bir sinifin sahip oldugu bir fonksiyon/davranistir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'j3_2_exp2',
          title: 'Parametre Alan Metodlar',
          content: 'Metodlar disaridan bilgi (parametre) alabilir:\n\nvoid selamVer(String isim) {\n    System.out.println("Merhaba, " + isim + "!");\n}\n\n// Kullanimi:\nselamVer("Ali"); // "Merhaba, Ali!" yazar\nselamVer("Ayse"); // "Merhaba, Ayse!" yazar\n\nAyni metodu farkli degerlerle defalarca cagirabilirsin!',
        ),

        MultipleChoiceStep(
          id: 'j3_2_q2',
          question: 'int topla(int a, int b) metodunda "a" ve "b" ye ne denir?',
          options: [
            ChoiceOption(text: 'Parametre', emoji: '✅'),
            ChoiceOption(text: 'Sinif', emoji: '❌'),
            ChoiceOption(text: 'Nesne', emoji: '❌'),
            ChoiceOption(text: 'Dizi', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'a ve b, metodun disaridan aldigi degerler - yani parametrelerdir!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'j3_2_exp3',
          title: 'return ile Deger Dondurme',
          content: 'Bir metod bir DEGER hesaplayip geri dondurebilir:\n\nint topla(int a, int b) {\n    return a + b;\n}\n\n// Kullanimi:\nint sonuc = topla(3, 5); // sonuc = 8\n\nvoid yerine int yazdik cunku artik bir sayi DONDURUYORUZ!',
          tipEmoji: '↩️',
          tip: 'void = "hicbir sey dondurmez", int/String/double = "bu tipte bir sey dondurur"',
        ),

        OrderingStep(
          id: 'j3_2_order',
          instruction: 'Iki sayiyi toplayan bir metodu sirala',
          items: [
            OrderItem(id: 's1', content: 'int topla(int a, int b) {', isCode: true),
            OrderItem(id: 's2', content: 'return a + b;', isCode: true),
            OrderItem(id: 's3', content: '}', isCode: true),
          ],
          correctOrder: ['s1', 's2', 's3'],
          context: 'a ve b parametrelerini toplayip sonucu donduren metod',
          xpReward: 20,
        ),

        ProjectStep(
          id: 'j3_2_project',
          title: 'Mini Proje: Ogrenci Sinifi',
          description: 'Isim ve notlari tutan, ortalama hesaplayan bir metodu olan Ogrenci sinifi yaz!',
          requirements: [
            'Ogrenci sinifi olustur (isim, notlar dizisi)',
            'ortalamaHesapla() adinda bir metod yaz',
            'Metod, notlarin ortalamasini return etsin',
            'main icinde bir Ogrenci nesnesi olustur ve metodu cagir',
          ],
          hints: [
            'double ortalamaHesapla() { ... return toplam / notlar.length; }',
            'Ogrenci o = new Ogrenci(); o.ortalamaHesapla();',
          ],
          starterCode: 'class Ogrenci {\n    String isim;\n    int[] notlar;\n\n    double ortalamaHesapla() {\n        // buraya hesaplamayi yaz\n    }\n}',
          language: 'java',
          validation: ProjectValidation(
            mustContain: ['class Ogrenci', 'return', 'notlar'],
          ),
          xpReward: 45,
        ),

        ExplanationStep(
          id: 'j3_2_summary',
          title: 'Metod Ustasi!',
          content: '⚡ Nesnelere davranis kazandirabiliyorsun!\n\n✓ Metod tanimlama\n✓ Parametre alma\n✓ return ile deger dondurme\n\nSonraki: Kalitim (inheritance) ile kod tekrarini azalt!',
          tipEmoji: '🏅',
          tip: 'Metod Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 3.3: Kalitim
    InteractiveLesson(
      id: 'java_3_3',
      courseId: 'java',
      title: 'Kalitim (Inheritance)',
      subtitle: 'Sinif ozelliklerini miras al',
      order: 9,
      xpReward: 90,
      badge: 'inheritance_master',
      steps: [
        IntroStep(
          id: 'j3_3_intro',
          mascotEmoji: '👨‍👦',
          mascotMessage: 'Bir Ogrenci sinifi ile bir Ogretmen sinifi çok benzer olabilir - ikisi de "Kisi" degil mi? KALITIM ile kod tekrarini onleyecegiz!',
        ),

        ExplanationStep(
          id: 'j3_3_exp1',
          title: 'Kalitim Nedir?',
          content: 'Kalitim, bir sinifin baska bir sinifin ozelliklerini "miras almasidir":\n\nclass Kisi {\n    String isim;\n    int yas;\n}\n\nclass Ogrenci extends Kisi {\n    String okulAdi;\n}\n\nOgrenci, Kisi\'nin TUM ozelliklerine (isim, yas) SAHIPTIR, artı kendi okulAdi\'na!',
          tipEmoji: '👨‍👦',
          tip: 'extends anahtar kelimesi "...den miras alir" anlamina gelir!',
        ),

        MultipleChoiceStep(
          id: 'j3_3_q1',
          question: 'class Ogrenci extends Kisi satirinda "extends" ne anlama gelir?',
          options: [
            ChoiceOption(text: 'Ogrenci, Kisi\'den miras alir', emoji: '✅'),
            ChoiceOption(text: 'Ogrenci, Kisi\'yi siler', emoji: '❌'),
            ChoiceOption(text: 'Ogrenci ile Kisi ayni seydir', emoji: '❌'),
            ChoiceOption(text: 'Bir hata mesajidir', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'extends, bir sinifin baska bir siniftan (ust/parent sinif) ozellik miras almasini saglar!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'j3_3_exp2',
          title: 'Ust Sinif ve Alt Sinif',
          content: 'Kalitimda iki taraf vardir:\n\nKisi = Ust sinif (superclass/parent) - genel ozellikler\nOgrenci = Alt sinif (subclass/child) - ozel ozellikler + Kisi\'nin hepsi\n\nOgrenci nesnesi hem isim/yas (Kisi\'den) hem de okulAdi (kendi) ozelliklerine sahiptir!',
        ),

        MultipleChoiceStep(
          id: 'j3_3_q2',
          question: 'class Ogretmen extends Kisi { } tanimlandiginda, Ogretmen nesnesi hangi ozelliklere sahip olur?',
          options: [
            ChoiceOption(text: 'Kisi\'nin ozellikleri + kendi ozellikleri', emoji: '✅'),
            ChoiceOption(text: 'Sadece kendi ozellikleri', emoji: '❌'),
            ChoiceOption(text: 'Sadece Kisi\'nin ozellikleri', emoji: '❌'),
            ChoiceOption(text: 'Hicbir ozellik', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Kalitim sayesinde Ogretmen, Kisi\'nin tum ozelliklerini ALIR ve kendi ozelliklerini de EKLEYEBILIR!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'j3_3_exp3',
          title: 'Neden Kalitim Kullanilir?',
          content: 'Kalitim olmadan Ogrenci ve Ogretmen siniflarinda isim ve yas\'i AYRI AYRI yazman gerekirdi (kod tekrari!).\n\nKalitim ile:\n1. Kisi sinifini bir kere yaz\n2. Ogrenci ve Ogretmen bunu miras alsin\n3. Kod tekrarindan kurtul!\n\nBuna "DRY" (Don\'t Repeat Yourself - Kendini Tekrar Etme) prensibi denir.',
          tipEmoji: '♻️',
          tip: 'Iyi programcilar kod tekrarindan kacinir - kalitim bunun icin harika bir arac!',
        ),

        DragDropStep(
          id: 'j3_3_dd1',
          instruction: 'Sinif iliskisini dogru role surukle!',
          items: [
            DraggableItem(id: 'kisi', content: 'Kisi'),
            DraggableItem(id: 'ogrenci', content: 'Ogrenci extends Kisi'),
          ],
          dropZones: [
            DropZone(id: 'parent', label: 'Ust Sinif (Parent)', hint: 'Genel ozellikler'),
            DropZone(id: 'child', label: 'Alt Sinif (Child)', hint: 'Miras alan + kendine ozgu'),
          ],
          correctMapping: {
            'kisi': 'parent',
            'ogrenci': 'child',
          },
          successMessage: 'Ust sinif ve alt sinif iliskisini kavradin!',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'j3_3_summary',
          title: 'Kalitim Ustasi!',
          content: '👨‍👦 Kod tekrarini onlemeyi ogrendin!\n\n✓ extends ile kalitim\n✓ Ust sinif / alt sinif iliskisi\n✓ DRY prensibi\n\nSonraki modul: Gercek projeler yapacagiz!',
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
    // LESSON 4.1: Mini Proje - Not Ortalamasi Hesaplayici
    InteractiveLesson(
      id: 'java_4_1',
      courseId: 'java',
      title: 'Proje: Not Hesaplayici',
      subtitle: 'Ogrendiklerini birlestir',
      order: 10,
      xpReward: 90,
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'j4_1_intro',
          mascotEmoji: '📊',
          mascotMessage: 'Simdi ogrendigin her seyi birlestirerek gercek bir program yapacagiz: harf notu hesaplayan bir sistem!',
        ),

        ExplanationStep(
          id: 'j4_1_exp1',
          title: 'Proje Plani',
          content: '🎯 Hedef: Sayisal notu harf notuna cevirmek\n\n90-100: A\n80-89: B\n70-79: C\n70 alti: F (Kaldi)\n\nBunun icin if-else if zincirini kullanacagiz!',
        ),

        ExplanationStep(
          id: 'j4_1_exp2',
          title: 'Adim 1: Notu Al ve Kontrol Et',
          content: 'if-else if zincirini yukaridan asagi DOGRU sirada yazmak onemlidir:\n\nint puan = 85;\nString harfNotu;\n\nif (puan >= 90) {\n    harfNotu = "A";\n} else if (puan >= 80) {\n    harfNotu = "B";\n} else if (puan >= 70) {\n    harfNotu = "C";\n} else {\n    harfNotu = "F";\n}',
        ),

        MultipleChoiceStep(
          id: 'j4_1_q1',
          question: 'Eger kosullari en yuksekten en dusuge SIRALI yazmazsak ne olur?',
          options: [
            ChoiceOption(text: 'Yanlis sonuclar alabiliriz', emoji: '✅'),
            ChoiceOption(text: 'Hicbir fark olmaz', emoji: '❌'),
            ChoiceOption(text: 'Program daha hizli calisir', emoji: '❌'),
            ChoiceOption(text: 'Derleme hatasi olur', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Java kosullari sirayla kontrol eder ve ilk dogru olani kullanir - siralama yanlissa mantik hatasi olusur!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'j4_1_exp3',
          title: 'Adim 2: Sonucu Yazdir',
          content: 'Son olarak sonucu kullaniciya gosterelim:\n\nSystem.out.println("Puanin: " + puan);\nSystem.out.println("Harf notun: " + harfNotu);\n\nBoylece kullanici hem sayisal hem harf notunu gorur!',
        ),

        ProjectStep(
          id: 'j4_1_project',
          title: 'Proje: Not Hesaplayici',
          description: 'Bir sayisal notu alip harf notuna ceviren tam bir program yaz!',
          requirements: [
            'int puan degiskeni tanimla',
            'if-else if-else zinciri ile harf notunu belirle (A/B/C/F)',
            'Hem puani hem harf notunu System.out.println ile yazdir',
          ],
          hints: [
            'if (puan >= 90) { harfNotu = "A"; }',
            'Sirayla en yuksekten en dusuge kontrol et',
            'En son else ile "F" durumunu yakala',
          ],
          starterCode: 'public class NotHesaplayici {\n    public static void main(String[] args) {\n        int puan = 85;\n        String harfNotu;\n\n        // if-else if zincirini yaz\n\n        System.out.println("Harf notun: " + harfNotu);\n    }\n}',
          language: 'java',
          validation: ProjectValidation(
            mustContain: ['if', 'else', 'harfNotu'],
          ),
          xpReward: 45,
        ),

        ExplanationStep(
          id: 'j4_1_summary',
          title: 'Ilk Gercek Proje Tamamlandi!',
          content: '📊 Kontrol yapilarini gercek bir problemde kullandin!\n\n✓ if-else if zinciri\n✓ Mantikli siralama\n✓ Kullaniciya sonuc gosterme\n\nSonraki: Bir Ogrenci sinifi ile daha buyuk bir proje!',
          tipEmoji: '🏆',
          tip: 'Not Hesaplayici projesini tamamladin!',
        ),
      ],
    ),

    // LESSON 4.2: Mini Proje - Basit Ogrenci Sistemi
    InteractiveLesson(
      id: 'java_4_2',
      courseId: 'java',
      title: 'Proje: Ogrenci Sistemi',
      subtitle: 'Siniflari gercek hayatta kullan',
      order: 11,
      xpReward: 100,
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'j4_2_intro',
          mascotEmoji: '🎒',
          mascotMessage: 'Ogrendigin sinif, nesne ve metod kavramlarini birlestirerek kucuk bir ogrenci yonetim sistemi yapacagiz!',
        ),

        ExplanationStep(
          id: 'j4_2_exp1',
          title: 'Proje Plani',
          content: '🎯 Hedef: Birden fazla ogrenciyi yonetebilen bir sistem\n\n1. Ogrenci sinifi (isim, notlar dizisi)\n2. ortalamaHesapla() metodu\n3. Birden fazla Ogrenci nesnesi olustur\n4. Her birinin ortalamasini yazdir',
        ),

        ExplanationStep(
          id: 'j4_2_exp2',
          title: 'Adim 1: Ogrenci Sinifi',
          content: 'Once sinifimizi tanimlayalim:\n\nclass Ogrenci {\n    String isim;\n    int[] notlar;\n\n    double ortalamaHesapla() {\n        int toplam = 0;\n        for (int i = 0; i < notlar.length; i++) {\n            toplam += notlar[i];\n        }\n        return (double) toplam / notlar.length;\n    }\n}',
          visuals: [
            VisualElement(
              type: VisualType.codeSnippet,
              content: 'class Ogrenci {\n  String isim;\n  int[] notlar;\n}',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'j4_2_q1',
          question: '(double) toplam / notlar.length satirindaki (double) ne ise yarar?',
          options: [
            ChoiceOption(text: 'Tam sayiyi ondalikli sayiya cevirir (dogru bolme icin)', emoji: '✅'),
            ChoiceOption(text: 'Sayiyi 2 ile carpar', emoji: '❌'),
            ChoiceOption(text: 'Bir hata mesajidir', emoji: '❌'),
            ChoiceOption(text: 'Sayiyi negatif yapar', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '(double), int bolmede kusuratlarin kaybolmamasi icin sayiyi ondalikliya cevirir - buna "type casting" denir!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'j4_2_exp3',
          title: 'Adim 2: Birden Fazla Nesne Olustur',
          content: 'Simdi main metodunda birden fazla ogrenci olusturalim:\n\nOgrenci o1 = new Ogrenci();\no1.isim = "Ali";\no1.notlar = new int[]{80, 90, 70};\n\nOgrenci o2 = new Ogrenci();\no2.isim = "Ayse";\no2.notlar = new int[]{95, 88, 92};\n\nSystem.out.println(o1.isim + ": " + o1.ortalamaHesapla());\nSystem.out.println(o2.isim + ": " + o2.ortalamaHesapla());',
          tipEmoji: '🎒',
          tip: 'Her ogrenci nesnesi kendi verilerini tasir - o1 ve o2 birbirini etkilemez!',
        ),

        ProjectStep(
          id: 'j4_2_project',
          title: 'Proje: Ogrenci Yonetim Sistemi',
          description: 'Birden fazla ogrenciyi yonetip ortalamalarini karsilastiran bir program yaz!',
          requirements: [
            'Ogrenci sinifi tanimla (isim, notlar[])',
            'ortalamaHesapla() metodu ekle',
            'En az 2 Ogrenci nesnesi olustur',
            'Her ikisinin de ismini ve ortalamasini yazdir',
          ],
          hints: [
            'class Ogrenci { String isim; int[] notlar; double ortalamaHesapla() {...} }',
            'Ogrenci o1 = new Ogrenci(); o1.isim = "Ali";',
            'Ortalamayi hesaplarken (double) casting yapmayi unutma',
          ],
          starterCode: 'class Ogrenci {\n    String isim;\n    int[] notlar;\n\n    double ortalamaHesapla() {\n        // hesaplama\n    }\n}\n\npublic class Ana {\n    public static void main(String[] args) {\n        // ogrenci nesnelerini olustur\n    }\n}',
          language: 'java',
          validation: ProjectValidation(
            mustContain: ['class Ogrenci', 'new Ogrenci', 'ortalamaHesapla'],
          ),
          xpReward: 50,
        ),

        ExplanationStep(
          id: 'j4_2_summary',
          title: 'Sistem Gelistirici!',
          content: '🎒 Gercek bir OOP sistemi kurdun!\n\n✓ Sinif tasarimi\n✓ Birden fazla nesne yonetimi\n✓ Metodlarla hesaplama\n\nSonraki: Kalitimi de kullanan final proje!',
          tipEmoji: '🏆',
          tip: 'Sistem Gelistirici rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 4.3: Final Proje - Hesap Makinesi
    InteractiveLesson(
      id: 'java_4_3',
      courseId: 'java',
      title: 'Final Proje: Hesap Makinesi',
      subtitle: 'Ogrendigin her seyi birlestir!',
      order: 12,
      xpReward: 130,
      badge: 'java_graduate',
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'j4_3_intro',
          mascotEmoji: '🎓',
          mascotMessage: 'Tebrikler, buraya kadar geldin! Simdi ogrendigin HER SEYI kullanarak basit bir hesap makinesi sinifi yapacagiz!',
        ),

        ExplanationStep(
          id: 'j4_3_exp1',
          title: 'Proje Plani',
          content: '🎯 Hedef: Toplama, cikarma, carpma, bolme yapabilen bir HesapMakinesi sinifi\n\n📦 Sinif ve metodlar\n🔀 Kontrol yapilari (bolme 0\'a karsi kontrol)\n🔁 Islem gecmisi icin dizi\n\nHepsini birlestirecegiz!',
        ),

        ExplanationStep(
          id: 'j4_3_exp2',
          title: 'Adim 1: Sinif ve Metodlar',
          content: 'HesapMakinesi sinifimizi tanimlayalim:\n\nclass HesapMakinesi {\n    double topla(double a, double b) {\n        return a + b;\n    }\n    double cikar(double a, double b) {\n        return a - b;\n    }\n    double carp(double a, double b) {\n        return a * b;\n    }\n}',
        ),

        ExplanationStep(
          id: 'j4_3_exp3',
          title: 'Adim 2: Sifira Bolme Kontrolu',
          content: 'Bolme islemi ozel dikkat ister - 0\'a bolmek HATA verir!\n\ndouble bol(double a, double b) {\n    if (b == 0) {\n        System.out.println("Hata: Sifira bolunemez!");\n        return 0;\n    }\n    return a / b;\n}\n\nIf kontrolu ile programimizi cokmekten koruyoruz!',
          tipEmoji: '⚠️',
          tip: 'Iyi programcilar her zaman "olabilecek hatalari" onceden dusunur!',
        ),

        MultipleChoiceStep(
          id: 'j4_3_q1',
          question: 'Bolme metodunda b == 0 kontrolu neden onemlidir?',
          options: [
            ChoiceOption(text: 'Sifira bolme hatasini onlemek icin', emoji: '✅'),
            ChoiceOption(text: 'Programi yavaslatmak icin', emoji: '❌'),
            ChoiceOption(text: 'Hicbir onemi yok', emoji: '❌'),
            ChoiceOption(text: 'Sadece gorunum icin', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Matematikte bir sayi sifira bolunemez - bu kontrolu yapmazsak program hataya duser!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'j4_3_exp4',
          title: 'Adim 3: Hesap Makinesini Kullan',
          content: 'Simdi main metodunda hesap makinemizi test edelim:\n\nHesapMakinesi hm = new HesapMakinesi();\nSystem.out.println("Toplam: " + hm.topla(5, 3));\nSystem.out.println("Fark: " + hm.cikar(5, 3));\nSystem.out.println("Carpim: " + hm.carp(5, 3));\nSystem.out.println("Bolum: " + hm.bol(5, 0));\n\nSon satir "Hata: Sifira bolunemez!" yazdiracak ve 0 dondurecek!',
        ),

        ProjectStep(
          id: 'j4_3_project',
          title: 'Final Proje: Tam Hesap Makinesi',
          description: 'Ogrendigin her seyi birlestirerek eksiksiz bir hesap makinesi sinifi yap!',
          requirements: [
            'HesapMakinesi sinifi olustur',
            'topla, cikar, carp, bol metodlarini yaz (hepsi double donsun)',
            'bol metodunda sifira bolme kontrolu yap (if ile)',
            'main icinde HesapMakinesi nesnesi olustur ve tum islemleri test et',
            'Sonuclari System.out.println ile yazdir',
          ],
          hints: [
            'class HesapMakinesi { double topla(double a, double b) { return a+b; } }',
            'bol metodunda: if (b == 0) { ... return 0; }',
            'HesapMakinesi hm = new HesapMakinesi(); hm.topla(2,3);',
          ],
          starterCode: 'class HesapMakinesi {\n    double topla(double a, double b) {\n        return a + b;\n    }\n\n    // cikar, carp, bol metodlarini ekle\n}\n\npublic class Ana {\n    public static void main(String[] args) {\n        HesapMakinesi hm = new HesapMakinesi();\n        // test islemlerini yaz\n    }\n}',
          language: 'java',
          validation: ProjectValidation(
            mustContain: ['class HesapMakinesi', 'if (b == 0)', 'return'],
          ),
          xpReward: 65,
        ),

        ExplanationStep(
          id: 'j4_3_summary',
          title: '🎓 JAVA MEZUNU OLDUN!',
          content: '🎉☕🎉 JAVA KURSUNU TAMAMLADIN!\n\n✓ Degiskenler ve veri tipleri\n✓ Kontrol yapilari (if-else, donguler)\n✓ Diziler\n✓ Nesne yonelimli programlama (sinif, nesne, metod, kalitim)\n✓ Gercek bir hesap makinesi yazdin\n\nArtik Java ile gercek programlar yazabilirsin!',
          tipEmoji: '🏆',
          tip: 'Java Mezunu rozetini kazandin! Bu becerilerle Android uygulamalarina bile adim atabilirsin.',
        ),
      ],
    ),
  ];

  /// Get all Java lessons
  static List<InteractiveLesson> getJavaInteractiveLessons() {
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

/// Java badges
class JavaBadges {
  static const List<LessonBadge> all = [
    LessonBadge(
      id: 'java_starter',
      name: 'Java Baslangic',
      description: 'Java dunyasina adim attin!',
      emoji: '☕',
      rarity: BadgeRarity.common,
      category: BadgeCategory.lesson,
    ),
    LessonBadge(
      id: 'first_java_code',
      name: 'Ilk Java Kodu',
      description: 'Ilk Java programini yazdin!',
      emoji: '💻',
      rarity: BadgeRarity.common,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'variable_master',
      name: 'Degisken Ustasi',
      description: 'Veri tiplerinde uzmanlaştin!',
      emoji: '📦',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'condition_master',
      name: 'Karar Verme Ustasi',
      description: 'if-else ile programlarin karar vermesini sagladin!',
      emoji: '🤔',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'loop_master',
      name: 'Dongu Ustasi',
      description: 'for ve while dongulerinde uzmanlaştin!',
      emoji: '🔁',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'array_master',
      name: 'Dizi Ustasi',
      description: 'Dizilerle birden fazla veriyi yonettin!',
      emoji: '📋',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'oop_starter',
      name: 'OOP Baslangic',
      description: 'Sinif ve nesne kavramlarini ogrendin!',
      emoji: '🏗️',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'method_master',
      name: 'Metod Ustasi',
      description: 'Nesnelere davranis kazandirdin!',
      emoji: '⚡',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'inheritance_master',
      name: 'Kalitim Ustasi',
      description: 'extends ile kod tekrarini onledin!',
      emoji: '👨‍👦',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'java_graduate',
      name: 'Java Mezunu',
      description: 'Tum Java kursunu tamamladin ve final projeyi bitirdin!',
      emoji: '🎓',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.course,
    ),
  ];
}
