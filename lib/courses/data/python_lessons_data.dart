import '../models/interactive_lesson_model.dart';

/// Python Course - Interactive lessons for beginners
/// Modern, engaging, practical Python programming
class PythonLessonsData {
  // ==========================================
  // MODULE 1: PYTHON'A MERHABA
  // ==========================================
  static final List<InteractiveLesson> module1 = [
    // LESSON 1.1: Python Nedir ve print()
    InteractiveLesson(
      id: 'python_1_1',
      courseId: 'python',
      title: 'Python\'a Hos Geldin!',
      subtitle: 'Ilk Python programin',
      order: 1,
      xpReward: 50,
      badge: 'python_starter',
      steps: [
        IntroStep(
          id: 'p1_1_intro',
          mascotEmoji: '🐍',
          mascotMessage: 'Merhaba! Ben Python yilani! Seninle birlikte harika programlar yapacagiz. Hazir misin?',
          highlights: [
            'Basit ve anlasilir kod',
            'Guclu programlama dili',
            'Cok yonlu kullanim',
          ],
        ),

        ExplanationStep(
          id: 'p1_1_exp1',
          title: 'Python Nedir?',
          content: 'Python, kolay ogrenilebilen ama cok guclu bir programlama dilidir. Web siteleri, oyunlar, yapay zeka ve daha fazlasini yapmak icin kullanilir!',
          tipEmoji: '💡',
          tip: 'Google, YouTube, Instagram gibi buyuk siteler Python kullanir!',
        ),

        ExplanationStep(
          id: 'p1_1_exp2',
          title: 'Ilk Komutun: print()',
          content: 'print() komutu ekrana yazı yazdırır. Python\'da en çok kullanılan komutlardan biri!',
        ),

        MultipleChoiceStep(
          id: 'p1_1_q1',
          question: 'print("Python") komutu ne yapar?',
          options: [
            ChoiceOption(text: 'Python kelimesini ekrana yazar', emoji: '✅'),
            ChoiceOption(text: 'Hata verir', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey yapmaz', emoji: '🤷'),
            ChoiceOption(text: 'Bilgisayari kapatir', emoji: '💻'),
          ],
          correctIndex: 0,
          explanation: 'Dogru! print() ekrana metin yazdirmak icindir.',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p1_1_exp3',
          title: 'Tirnak Isaretleri',
          content: 'Metinleri (string) cift tirnak " " veya tek tirnak \' \' icinde yazariz.\n\nOrnek:\nprint("Merhaba")\nprint(\'Selam\')\n\nHer ikisi de calisir!',
        ),

        MultipleChoiceStep(
          id: 'p1_1_q2',
          question: 'Hangisi YANLIS kullanim?',
          options: [
            ChoiceOption(text: 'print("Merhaba")', emoji: '1️⃣'),
            ChoiceOption(text: 'print(\'Merhaba\')', emoji: '2️⃣'),
            ChoiceOption(text: 'print(Merhaba)', emoji: '3️⃣'),
            ChoiceOption(text: 'print("Merhaba Dunya")', emoji: '4️⃣'),
          ],
          correctIndex: 2,
          explanation: 'print(Merhaba) yanlis! Metin tirnak icinde olmali: print("Merhaba")',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p1_1_summary',
          title: 'Tebrikler!',
          content: '🎉 Ilk Python dersini tamamladin!\n\n✓ Python\'i tandin\n✓ print() komutunu ogrendin\n✓ String (metin) kullandın\n\nSonraki ders: Degiskenler!',
          tipEmoji: '🏆',
          tip: 'Python Baslangic rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.2: Degiskenler
    InteractiveLesson(
      id: 'python_1_2',
      courseId: 'python',
      title: 'Degiskenler',
      subtitle: 'Bilgiyi sakla ve kullan',
      order: 2,
      xpReward: 60,
      badge: 'variable_master',
      steps: [
        IntroStep(
          id: 'p1_2_intro',
          mascotEmoji: '📦',
          mascotMessage: 'Degiskenler, bilgiyi saklayan kutular gibidir. Ismini yaz, icine ne koyarsan koy!',
        ),

        ExplanationStep(
          id: 'p1_2_exp1',
          title: 'Degisken Nedir?',
          content: 'Degisken, bir isim ve bir degerdir. Bilgiyi saklar ve istedigin zaman kullanirsin.',
        ),

        ExplanationStep(
          id: 'p1_2_exp2',
          title: 'Degisken Kullanimi',
          content: 'Degiskeni olustur (=) ve kullan:',
          tipEmoji: '📝',
          tip: '# ile baslayan satirlar yorumdur, calistirilmaz!',
        ),

        MultipleChoiceStep(
          id: 'p1_2_q1',
          question: 'x = 10\nprint(x)\nBu kod ne yapar?',
          options: [
            ChoiceOption(text: '10 yazdirir', emoji: '🔟'),
            ChoiceOption(text: 'x yazdirir', emoji: '❌'),
            ChoiceOption(text: 'Hata verir', emoji: '⚠️'),
            ChoiceOption(text: 'Hicbir sey yapmaz', emoji: '🤷'),
          ],
          correctIndex: 0,
          explanation: 'x degiskeninin degeri 10 oldugu icin, ekrana 10 yazdirir.',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p1_2_exp3',
          title: 'Degisken Turleri',
          content: 'Python\'da farkli tur degiskenler var:\n\n• Sayi (int): 10, 42, -5\n• Ondalikli (float): 3.14, 2.5\n• Metin (string): "Merhaba"\n• Mantiksal (bool): True, False',
        ),

        MatchingStep(
          id: 'p1_2_match1',
          instruction: 'Degiskenleri turleriyle esle!',
          pairs: [
            MatchPair(id: '1', left: 'sayi = 100', right: 'int'),
            MatchPair(id: '2', left: 'isim = "Ahmet"', right: 'string'),
            MatchPair(id: '3', left: 'fiyat = 19.99', right: 'float'),
            MatchPair(id: '4', left: 'aktif = True', right: 'bool'),
          ],
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'p1_2_summary',
          title: 'Degisken Ustasi!',
          content: '🎊 Degiskenleri ogrendin!\n\n✓ Degisken olusturma\n✓ Degisken kullanimi\n✓ Farkli turler\n\nSonraki: Matematik islemleri!',
          tipEmoji: '🏅',
          tip: 'Degisken Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.3: Matematik
    InteractiveLesson(
      id: 'python_1_3',
      courseId: 'python',
      title: 'Matematik Islemleri',
      subtitle: 'Python ile hesap yap',
      order: 3,
      xpReward: 65,
      badge: 'math_wizard',
      steps: [
        IntroStep(
          id: 'p1_3_intro',
          mascotEmoji: '🔢',
          mascotMessage: 'Python mukemmel bir hesap makinesi! Toplama, cikarma, carpma ve daha fazlasi!',
        ),

        ExplanationStep(
          id: 'p1_3_exp1',
          title: 'Temel Islemler',
          content: 'Python\'da matematik islemleri cok kolay:\n\n+ Toplama\n- Cikarma\n* Carpma\n/ Bolme',
        ),

        MultipleChoiceStep(
          id: 'p1_3_q1',
          question: 'print(7 * 6) ne yazdirir?',
          options: [
            ChoiceOption(text: '13', emoji: '❌'),
            ChoiceOption(text: '42', emoji: '✅'),
            ChoiceOption(text: '76', emoji: '❌'),
            ChoiceOption(text: 'Hata', emoji: '⚠️'),
          ],
          correctIndex: 1,
          explanation: '7 carpı 6 = 42',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p1_3_exp2',
          title: 'Degiskenlerle Matematik',
          content: 'Degiskenlerle de islem yapabilirsin:',
        ),

        ExplanationStep(
          id: 'p1_3_exp3',
          title: 'Ozel Islemler',
          content: 'Bazi ozel matematik islemleri:\n\n** Us alma (2**3 = 8)\n// Tam bolme (17//5 = 3)\n% Mod (kalan) (17%5 = 2)',
        ),

        MultipleChoiceStep(
          id: 'p1_3_q2',
          question: 'print(2 ** 4) ne yazdirir?',
          options: [
            ChoiceOption(text: '8', emoji: '❌'),
            ChoiceOption(text: '16', emoji: '✅'),
            ChoiceOption(text: '24', emoji: '❌'),
            ChoiceOption(text: '6', emoji: '❌'),
          ],
          correctIndex: 1,
          explanation: '2 uzeri 4 = 2*2*2*2 = 16',
          xpReward: 10,
        ),

        MatchingStep(
          id: 'p1_3_match1',
          instruction: 'Islemleri sonuclariyla esle!',
          pairs: [
            MatchPair(id: '1', left: '10 + 5', right: '15'),
            MatchPair(id: '2', left: '8 * 2', right: '16'),
            MatchPair(id: '3', left: '20 - 7', right: '13'),
            MatchPair(id: '4', left: '9 / 3', right: '3.0'),
          ],
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'p1_3_summary',
          title: 'Matematik Buyucusu!',
          content: '🧮 Python ile matematik artik kolay!\n\n✓ Temel islemler\n✓ Degiskenle hesap\n✓ Ozel operatorler\n\nSonraki modul: Kullanici girisi!',
          tipEmoji: '🏆',
          tip: 'Matematik Buyucusu rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 2: KULLANICI ETKILESIMI
  // ==========================================
  static final List<InteractiveLesson> module2 = [
    InteractiveLesson(
      id: 'python_2_1',
      courseId: 'python',
      title: 'input() ile Veri Al',
      subtitle: 'Kullanicidan bilgi iste',
      order: 4,
      xpReward: 70,
      badge: 'input_master',
      steps: [
        IntroStep(
          id: 'p2_1_intro',
          mascotEmoji: '⌨️',
          mascotMessage: 'Simdi kullaniciyla konusacagiz! input() ile soru sor, cevap al!',
        ),

        ExplanationStep(
          id: 'p2_1_exp1',
          title: 'input() Nedir?',
          content: 'input() kullanicidan bilgi almak icindir. Soru sorar, cevabi bekler.',
        ),

        ExplanationStep(
          id: 'p2_1_exp2',
          title: 'input() Nasil Calisir?',
          content: '1. Soru ekrana yazilir\n2. Kullanici cevap yazar\n3. Cevap degiskene kaydedilir\n4. Programa devam edilir',
          tipEmoji: '⏸️',
          tip: 'input() kullanici Enter\'a basana kadar bekler!',
        ),

        MultipleChoiceStep(
          id: 'p2_1_q1',
          question: 'yas = input("Kac yasindasin? ")\nBu kod ne yapar?',
          options: [
            ChoiceOption(text: 'Soru sorar ve cevabi yas\'a yazar', emoji: '✅'),
            ChoiceOption(text: 'Sadece soru sorar', emoji: '❌'),
            ChoiceOption(text: 'Hata verir', emoji: '⚠️'),
            ChoiceOption(text: 'Yas yazdirir', emoji: '📝'),
          ],
          correctIndex: 0,
          explanation: 'input() soru sorar ve kullanicinin cevabini yas degiskenine kaydeder.',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p2_1_exp3',
          title: 'String Birlestirme',
          content: 'Metinleri + ile birlestirebilirsin:',
        ),

        MultipleChoiceStep(
          id: 'p2_1_q2',
          question: 'print("Python" + " " + "Harika") ne yazdirir?',
          options: [
            ChoiceOption(text: 'Python Harika', emoji: '✅'),
            ChoiceOption(text: 'PythonHarika', emoji: '❌'),
            ChoiceOption(text: 'Python+Harika', emoji: '❌'),
            ChoiceOption(text: 'Hata', emoji: '⚠️'),
          ],
          correctIndex: 0,
          explanation: '+ metinleri yan yana koyar. Aradaki bosluk da eklenir.',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p2_1_summary',
          title: 'Input Ustasi!',
          content: '⌨️ Kullaniciyla etkilesim artik senin elinde!\n\n✓ input() kullanimi\n✓ Veri alma\n✓ String birlestirme\n\nSonraki: Tip donusumu!',
          tipEmoji: '🏅',
          tip: 'Input Ustasi rozetini kazandin!',
        ),
      ],
    ),

    InteractiveLesson(
      id: 'python_2_2',
      courseId: 'python',
      title: 'Tip Donusumu',
      subtitle: 'String\'i sayiya cevir',
      order: 5,
      xpReward: 75,
      badge: 'converter_pro',
      steps: [
        IntroStep(
          id: 'p2_2_intro',
          mascotEmoji: '🔄',
          mascotMessage: 'input() her zaman string doner. Ama sayilarla islem yapmak istersen?',
        ),

        ExplanationStep(
          id: 'p2_2_exp1',
          title: 'Problem: input() = String',
          content: 'input() her zaman metin (string) doner, sayi degil!',
        ),

        ExplanationStep(
          id: 'p2_2_exp2',
          title: 'Cozum: int() ve float()',
          content: 'Tip donusumu ile string\'i sayiya cevir:\n\nint() -> Tam sayi\nfloat() -> Ondalikli sayi',
        ),

        MultipleChoiceStep(
          id: 'p2_2_q1',
          question: 'sayi = int("42")\nprint(sayi + 8) ne yazdirir?',
          options: [
            ChoiceOption(text: '50', emoji: '✅'),
            ChoiceOption(text: '428', emoji: '❌'),
            ChoiceOption(text: '"428"', emoji: '❌'),
            ChoiceOption(text: 'Hata', emoji: '⚠️'),
          ],
          correctIndex: 0,
          explanation: 'int("42") stringi sayiya cevirir: 42. Sonra 42 + 8 = 50',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p2_2_exp3',
          title: 'Kisa Yol',
          content: 'Direkt input() icinde cevirebilirsin:',
        ),

        MatchingStep(
          id: 'p2_2_match1',
          instruction: 'Fonksiyonlari islevleriyle esle!',
          pairs: [
            MatchPair(id: '1', left: 'int()', right: 'Tam sayiya cevir'),
            MatchPair(id: '2', left: 'float()', right: 'Ondalikli sayiya cevir'),
            MatchPair(id: '3', left: 'str()', right: 'Metne cevir'),
            MatchPair(id: '4', left: 'input()', right: 'Kullanicidan veri al'),
          ],
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'p2_2_summary',
          title: 'Donusturucu Pro!',
          content: '🔄 Artik her tur veriyi kullanabilirsin!\n\n✓ int() kullanimi\n✓ float() kullanimi\n✓ Tip donusumu mantigi\n\nSonraki modul: Kosullar!',
          tipEmoji: '🏆',
          tip: 'Donusturucu Pro rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 3: IF-ELSE KOSULLARI
  // ==========================================
  static final List<InteractiveLesson> module3 = [
    InteractiveLesson(
      id: 'python_3_1',
      courseId: 'python',
      title: 'if Kosulu',
      subtitle: 'Programina karar verdirme',
      order: 6,
      xpReward: 80,
      badge: 'decision_maker',
      steps: [
        IntroStep(
          id: 'p3_1_intro',
          mascotEmoji: '🤔',
          mascotMessage: 'Programlar karar verebilir! if ile kosullu mantik ogrenecegin!',
        ),

        ExplanationStep(
          id: 'p3_1_exp1',
          title: 'if Nedir?',
          content: 'if = "eger" demektir. Bir kosulu kontrol eder, dogruysa kod calisir.',
        ),

        ExplanationStep(
          id: 'p3_1_exp2',
          title: 'Girintiler (Indentation)',
          content: 'Python\'da girinti cok onemli! if\'in icindeki kod girintili olmali (4 bosluk veya Tab).',
          tipEmoji: '⚠️',
          tip: 'Python\'da girinti hatasi en sik yapilan hatalardan!',
        ),

        MultipleChoiceStep(
          id: 'p3_1_q1',
          question: 'puan = 85\nif puan > 50:\n    print("Gectim!")\nNe olur?',
          options: [
            ChoiceOption(text: '"Gectim!" yazdirir', emoji: '✅'),
            ChoiceOption(text: 'Hicbir sey yazmaz', emoji: '❌'),
            ChoiceOption(text: 'Hata verir', emoji: '⚠️'),
            ChoiceOption(text: '85 yazdirir', emoji: '🔢'),
          ],
          correctIndex: 0,
          explanation: '85 > 50 dogru oldugu icin, if blogu calisir ve "Gectim!" yazdirir.',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p3_1_exp3',
          title: 'Karsilastirma Operatorleri',
          content: 'Kosul kontrolleri:\n\n== Esit mi?\n!= Esit degil mi?\n> Buyuk mu?\n< Kucuk mu?\n>= Buyuk veya esit mi?\n<= Kucuk veya esit mi?',
        ),

        MatchingStep(
          id: 'p3_1_match1',
          instruction: 'Operatorleri anlamlariyla esle!',
          pairs: [
            MatchPair(id: '1', left: '==', right: 'Esit mi?'),
            MatchPair(id: '2', left: '!=', right: 'Esit degil mi?'),
            MatchPair(id: '3', left: '>', right: 'Buyuk mu?'),
            MatchPair(id: '4', left: '<=', right: 'Kucuk veya esit mi?'),
          ],
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'p3_1_summary',
          title: 'Karar Verici!',
          content: '🤔 Programlarin artik dusunebilir!\n\n✓ if kullanimi\n✓ Girintiler\n✓ Karsilastirma operatorleri\n\nSonraki: else ve elif!',
          tipEmoji: '🏅',
          tip: 'Karar Verici rozetini kazandin!',
        ),
      ],
    ),

    InteractiveLesson(
      id: 'python_3_2',
      courseId: 'python',
      title: 'else ve elif',
      subtitle: 'Alternatif kosullar',
      order: 7,
      xpReward: 85,
      badge: 'logic_expert',
      steps: [
        IntroStep(
          id: 'p3_2_intro',
          mascotEmoji: '↔️',
          mascotMessage: 'if\'e ek olarak else ve elif var! Daha fazla secenekle daha akilli programlar!',
        ),

        ExplanationStep(
          id: 'p3_2_exp1',
          title: 'else = Degilse',
          content: 'if kosulu yanlis ise, else blogu calisir:',
        ),

        MultipleChoiceStep(
          id: 'p3_2_q1',
          question: 'sayi = 10\nif sayi > 20:\n    print("A")\nelse:\n    print("B")\nNe yazdirir?',
          options: [
            ChoiceOption(text: 'A', emoji: '❌'),
            ChoiceOption(text: 'B', emoji: '✅'),
            ChoiceOption(text: 'A B', emoji: '❌'),
            ChoiceOption(text: 'Hicbiri', emoji: '❌'),
          ],
          correctIndex: 1,
          explanation: '10 > 20 yanlis oldugu icin else blogu calisir, B yazdirir.',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p3_2_exp2',
          title: 'elif = Yoksa Eger',
          content: 'elif (else if) baska kosullar kontrol eder:',
        ),

        MultipleChoiceStep(
          id: 'p3_2_q2',
          question: 'elif ne zaman kullanilir?',
          options: [
            ChoiceOption(text: 'Birden fazla kosul kontrol etmek icin', emoji: '✅'),
            ChoiceOption(text: 'Sadece 2 kosul varsa', emoji: '❌'),
            ChoiceOption(text: 'else yerine', emoji: '❌'),
            ChoiceOption(text: 'Hicbir zaman', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'elif ile birden fazla kosulu sirayla kontrol edebilirsin!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p3_2_exp3',
          title: 'Tam Yapilandirma',
          content: 'if-elif-else yapisi:\n\n1. if: Ilk kosul\n2. elif: Diger kosullar (istersen birden fazla)\n3. else: Hicbiri degilse',
        ),

        ExplanationStep(
          id: 'p3_2_summary',
          title: 'Mantik Uzmani!',
          content: '↔️ Artik her durumu halledebilirsin!\n\n✓ else kullanimi\n✓ elif kullanimi\n✓ Coklu kosul kontrol\n\nSonraki modul: Donguler!',
          tipEmoji: '🏆',
          tip: 'Mantik Uzmani rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 4: DÖNGÜLER
  // ==========================================
  static final List<InteractiveLesson> module4 = [
    InteractiveLesson(
      id: 'python_4_1',
      courseId: 'python',
      title: 'while Dongusu',
      subtitle: 'Tekrar et, tekrar et!',
      order: 8,
      xpReward: 90,
      badge: 'loop_starter',
      steps: [
        IntroStep(
          id: 'p4_1_intro',
          mascotEmoji: '🔄',
          mascotMessage: 'Ayni kodu 100 kere yazmak istemezsin! while dongusu ile bir kere yaz, istedigin kadar tekrarla!',
        ),

        ExplanationStep(
          id: 'p4_1_exp1',
          title: 'while Nedir?',
          content: 'while = "iken" demektir. Kosul dogru oldugu surece kod tekrarlanir.',
        ),

        ExplanationStep(
          id: 'p4_1_exp2',
          title: 'Dikkat: Sonsuz Dongu!',
          content: 'Kosul hep dogru kalirsa, dongu hic bitmez!',
          tipEmoji: '⚠️',
          tip: 'Her dongu bir cikis kosuluna ihtiyac duyar!',
        ),

        MultipleChoiceStep(
          id: 'p4_1_q1',
          question: 'x = 0\nwhile x < 3:\n    x = x + 1\nprint(x)\nNe yazdirir?',
          options: [
            ChoiceOption(text: '0 1 2', emoji: '❌'),
            ChoiceOption(text: '3', emoji: '✅'),
            ChoiceOption(text: '0', emoji: '❌'),
            ChoiceOption(text: 'Sonsuz dongu', emoji: '♾️'),
          ],
          correctIndex: 1,
          explanation: 'Dongu 3 kere donunce x=3 olur, kosul yanlis olur, cikti: 3',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p4_1_summary',
          title: 'Dongu Baslangici!',
          content: '🔄 while dongusuyle tekrar artik kolay!\n\n✓ while kullanimi\n✓ Kosul kontrolu\n✓ Sonsuz dongulerden kacinma\n\nSonraki: for dongusu!',
          tipEmoji: '🏅',
          tip: 'Dongu Baslangici rozetini kazandin!',
        ),
      ],
    ),

    InteractiveLesson(
      id: 'python_4_2',
      courseId: 'python',
      title: 'for Dongusu',
      subtitle: 'Liste uzerinde gezin',
      order: 9,
      xpReward: 95,
      badge: 'for_master',
      steps: [
        IntroStep(
          id: 'p4_2_intro',
          mascotEmoji: '📜',
          mascotMessage: 'for dongusu bir liste uzerinde dolasir. Her elemani tek tek isler!',
        ),

        ExplanationStep(
          id: 'p4_2_exp1',
          title: 'for Dongusu',
          content: 'for dongusunde bir dizi uzerinde doner:',
        ),

        ExplanationStep(
          id: 'p4_2_exp2',
          title: 'range() Fonksiyonu',
          content: 'range() sayi dizisi olusturur:\n\nOrnek:\nfor i in range(5):\n    print(i)\n\nCikti: 0, 1, 2, 3, 4\n\nrange(5) = 0\'dan 4\'e kadar',
          tipEmoji: '💡',
          tip: 'range(5) 0\'dan baslar, 5 dahil degil!',
        ),

        MultipleChoiceStep(
          id: 'p4_2_q1',
          question: 'for i in range(3):\n    print("Hi")\nKac kere "Hi" yazdirir?',
          options: [
            ChoiceOption(text: '2 kere', emoji: '❌'),
            ChoiceOption(text: '3 kere', emoji: '✅'),
            ChoiceOption(text: '4 kere', emoji: '❌'),
            ChoiceOption(text: '1 kere', emoji: '❌'),
          ],
          correctIndex: 1,
          explanation: 'range(3) = [0, 1, 2], yani 3 eleman. 3 kere yazdirir.',
          xpReward: 10,
        ),

        MatchingStep(
          id: 'p4_2_match1',
          instruction: 'Dongu turlerini kullanim alanlariyla esle!',
          pairs: [
            MatchPair(id: '1', left: 'while', right: 'Kosul varken tekrarla'),
            MatchPair(id: '2', left: 'for', right: 'Liste uzerinde dolas'),
            MatchPair(id: '3', left: 'range()', right: 'Sayi dizisi olustur'),
            MatchPair(id: '4', left: 'if', right: 'Kosul kontrol et'),
          ],
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'p4_2_summary',
          title: 'For Dongu Ustasi!',
          content: '📜 for dongusuyle artik uzmansin!\n\n✓ for kullanimi\n✓ range() fonksiyonu\n✓ Liste uzerinde dolaşma\n\nSonraki modul: Listeler!',
          tipEmoji: '🏆',
          tip: 'For Dongu Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 5: LİSTELER
  // ==========================================
  static final List<InteractiveLesson> module5 = [
    InteractiveLesson(
      id: 'python_5_1',
      courseId: 'python',
      title: 'Liste Temelleri',
      subtitle: 'Cok veriyi bir arada sakla',
      order: 10,
      xpReward: 100,
      badge: 'list_beginner',
      steps: [
        IntroStep(
          id: 'p5_1_intro',
          mascotEmoji: '📋',
          mascotMessage: 'Listeler birden fazla degeri tek bir yerde saklar! Cok kullanisli!',
        ),

        ExplanationStep(
          id: 'p5_1_exp1',
          title: 'Liste Nedir?',
          content: 'Liste, birden fazla degeri saklayan yapidir. Koseli parantez [ ] ile olusturulur.',
        ),

        ExplanationStep(
          id: 'p5_1_exp2',
          title: 'Listeye Erisme',
          content: 'Index (sira numarasi) ile elemana ulas. 0\'dan baslar!',
          tipEmoji: '0️⃣',
          tip: 'Python\'da index 0\'dan baslar, 1\'den degil!',
        ),

        MultipleChoiceStep(
          id: 'p5_1_q1',
          question: 'liste = [10, 20, 30]\nprint(liste[1]) ne yazdirir?',
          options: [
            ChoiceOption(text: '10', emoji: '❌'),
            ChoiceOption(text: '20', emoji: '✅'),
            ChoiceOption(text: '30', emoji: '❌'),
            ChoiceOption(text: 'Hata', emoji: '⚠️'),
          ],
          correctIndex: 1,
          explanation: 'Index 1 = ikinci eleman = 20',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p5_1_exp3',
          title: 'Liste Metodlari',
          content: 'Listeyi degistirme komutlari:\n\nappend() - Sona ekle\nremove() - Cikar\nlen() - Uzunluk',
        ),

        ExplanationStep(
          id: 'p5_1_summary',
          title: 'Liste Baslangici!',
          content: '📋 Listelerle artik cok veriyi yonetebilirsin!\n\n✓ Liste olusturma\n✓ Index kullanimi\n✓ Liste metodlari\n\nTebrikler, Python temelleri tamamlandi!',
          tipEmoji: '🎉',
          tip: 'Liste Baslangici rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 6: FONKSİYONLAR
  // ==========================================
  static final List<InteractiveLesson> module6 = [
    // LESSON 6.1: Fonksiyon Nedir?
    InteractiveLesson(
      id: 'python_6_1',
      courseId: 'python',
      title: 'Fonksiyonlar',
      subtitle: 'Kodunu tekrar kullan!',
      order: 11,
      xpReward: 100,
      badge: 'function_creator',
      steps: [
        IntroStep(
          id: 'p6_1_intro',
          mascotEmoji: '🔧',
          mascotMessage: 'Fonksiyonlar kodunu organize etmenin en iyi yolu! Bir kez yaz, istedigin kadar kullan!',
          highlights: [
            'Kod tekrarini onle',
            'Daha okunaklı kod',
            'Kolayca bakım',
          ],
        ),

        ExplanationStep(
          id: 'p6_1_exp1',
          title: 'Fonksiyon Nedir?',
          content: 'Fonksiyon, belirli bir isi yapan kod blogunun adini koyup saklamamiz demek.\n\nOrnek:\ndef selamla():\n    print("Merhaba!")\n\n# Simdi istedigimiz kadar kullanabiliriz:\nselamla()  # Merhaba!\nselamla()  # Merhaba!',
          tipEmoji: '💡',
          tip: 'def kelimesi "define" (tanimla) kelimesinden gelir!',
        ),

        MultipleChoiceStep(
          id: 'p6_1_q1',
          question: 'Fonksiyon tanimlamak icin hangi kelime kullanilir?',
          options: [
            ChoiceOption(text: 'def', emoji: '✅'),
            ChoiceOption(text: 'function', emoji: '❌'),
            ChoiceOption(text: 'func', emoji: '❌'),
            ChoiceOption(text: 'define', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Python\'da fonksiyon tanimlamak icin "def" kelimesi kullanilir.',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p6_1_exp2',
          title: 'Parametreli Fonksiyonlar',
          content: 'Fonksiyonlara veri gonderebiliriz:\n\ndef selamla(isim):\n    print("Merhaba " + isim + "!")\n\nselamla("Ali")     # Merhaba Ali!\nselamla("Ayse")    # Merhaba Ayse!',
          tipEmoji: '📥',
          tip: 'Parantez icindeki isim "parametre" oluyor!',
        ),

        MultipleChoiceStep(
          id: 'p6_1_q2',
          question: 'Bu kod ne yapar?\n\ndef topla(a, b):\n    print(a + b)\n\ntopla(5, 3)',
          options: [
            ChoiceOption(text: 'Ekrana 8 yazar', emoji: '✅'),
            ChoiceOption(text: 'Ekrana 53 yazar', emoji: '❌'),
            ChoiceOption(text: 'Hata verir', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey yapmaz', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'topla(5, 3) fonksiyonu 5 + 3 = 8 sonucunu ekrana yazdirir.',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p6_1_exp3',
          title: 'Return - Geri Donus',
          content: 'Fonksiyonlar sonuc dondurebilir:\n\ndef topla(a, b):\n    return a + b\n\nsonuc = topla(5, 3)\nprint(sonuc)  # 8',
          tipEmoji: '↩️',
          tip: 'return deger dondurur ve fonksiyonu bitirir!',
        ),

        MultipleChoiceStep(
          id: 'p6_1_q3',
          question: 'return ve print arasindaki fark nedir?',
          options: [
            ChoiceOption(text: 'return deger dondurur, print ekrana yazar', emoji: '✅'),
            ChoiceOption(text: 'Ikisi de ayni seyi yapar', emoji: '❌'),
            ChoiceOption(text: 'print deger dondurur, return ekrana yazar', emoji: '❌'),
            ChoiceOption(text: 'Hicbir fark yok', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'return fonksiyondan deger dondurur, print ise sadece ekrana yazar.',
          xpReward: 10,
        ),

        TypeCodeStep(
          id: 'p6_1_type1',
          instruction: 'Iki sayiyi carpan bir fonksiyon yaz:',
          targetCode: 'def carp(a, b):\n    return a * b',
          language: 'python',
          hints: [
            'def ile basla',
            'Parametre olarak a ve b al',
            'return ile a * b dondur',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'p6_1_summary',
          title: 'Fonksiyon Yaratici!',
          content: '🔧 Artik kendi fonksiyonlarini yazabilirsin!\n\n✓ def ile fonksiyon tanimla\n✓ Parametre kullan\n✓ return ile deger dondur\n\nKodun cok daha duzenli olacak!',
          tipEmoji: '🏆',
          tip: 'Fonksiyon Yaratici rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 6.2: Ileri Fonksiyonlar
    InteractiveLesson(
      id: 'python_6_2',
      courseId: 'python',
      title: 'Ileri Fonksiyonlar',
      subtitle: 'Varsayilan degerler ve daha fazlasi',
      order: 12,
      xpReward: 110,
      badge: 'function_master',
      steps: [
        IntroStep(
          id: 'p6_2_intro',
          mascotEmoji: '⚙️',
          mascotMessage: 'Fonksiyonlarda daha fazla ozellik ogrenelim! Varsayilan degerler, coklu parametreler...',
        ),

        ExplanationStep(
          id: 'p6_2_exp1',
          title: 'Varsayilan Degerler',
          content: 'Parametrelere varsayilan deger verebiliriz:\n\ndef selamla(isim="Dunya"):\n    print("Merhaba " + isim + "!")\n\nselamla()         # Merhaba Dunya!\nselamla("Ali")    # Merhaba Ali!',
          tipEmoji: '🎯',
          tip: 'Varsayilan degerle parametre opsiyonel olur!',
        ),

        MultipleChoiceStep(
          id: 'p6_2_q1',
          question: 'Bu kod ne yazar?\n\ndef say(mesaj="Merhaba", tekrar=2):\n    for i in range(tekrar):\n        print(mesaj)\n\nsay()',
          options: [
            ChoiceOption(text: 'Merhaba\\nMerhaba', emoji: '✅'),
            ChoiceOption(text: 'Hata verir', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey yazmaz', emoji: '❌'),
            ChoiceOption(text: 'Sadece bir kez Merhaba yazar', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Varsayilan degerler kullanilir: "Merhaba" 2 kez yazilir.',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p6_2_exp2',
          title: 'Coklu Return',
          content: 'Fonksiyon birden fazla deger dondurebilir:\n\ndef hesapla(a, b):\n    toplam = a + b\n    fark = a - b\n    return toplam, fark\n\nsonuc1, sonuc2 = hesapla(10, 3)\nprint(sonuc1)  # 13\nprint(sonuc2)  # 7',
        ),

        TypeCodeStep(
          id: 'p6_2_type1',
          instruction: 'Bir sayinin karesini ve kupunu donduren fonksiyon yaz:',
          targetCode: 'def kare_kup(sayi):\n    return sayi * sayi, sayi * sayi * sayi',
          language: 'python',
          hints: [
            'def kare_kup(sayi): ile basla',
            'kare = sayi * sayi',
            'kup = sayi * sayi * sayi',
            'Iki degeri return et',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'p6_2_summary',
          title: 'Fonksiyon Ustasi!',
          content: '⚙️ Fonksiyonlarda uzmanlaştin!\n\n✓ Varsayilan degerler\n✓ Coklu return\n✓ Esnek parametreler\n\nArtik profesyonel fonksiyonlar yazabilirsin!',
          tipEmoji: '🏆',
          tip: 'Fonksiyon Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 7: SÖZLÜKLER (Dictionaries)
  // ==========================================
  static final List<InteractiveLesson> module7 = [
    // LESSON 7.1: Sözlük Nedir?
    InteractiveLesson(
      id: 'python_7_1',
      courseId: 'python',
      title: 'Sözlükler',
      subtitle: 'Anahtar-deger ciftleri!',
      order: 13,
      xpReward: 110,
      badge: 'dict_master',
      steps: [
        IntroStep(
          id: 'p7_1_intro',
          mascotEmoji: '📖',
          mascotMessage: 'Sözlükler gerçek hayattaki sözlükler gibi! Kelime (anahtar) yazarsın, karşılığını (değeri) bulursun!',
          highlights: [
            'Anahtar-deger ciftleri',
            'Hizli erisim',
            'Esnek veri yapisi',
          ],
        ),

        ExplanationStep(
          id: 'p7_1_exp1',
          title: 'Sözlük Nedir?',
          content: 'Sözlük, anahtar-deger ciftlerini saklar:\n\nogrenci = {\n    "isim": "Ali",\n    "yas": 15,\n    "sinif": 9\n}\n\nprint(ogrenci["isim"])  # Ali\nprint(ogrenci["yas"])   # 15',
          tipEmoji: '🔑',
          tip: 'Anahtar unique olmalı, ama degerler tekrar edebilir!',
        ),

        MultipleChoiceStep(
          id: 'p7_1_q1',
          question: 'Sözlük nasil olusturulur?',
          options: [
            ChoiceOption(text: 'sozluk = {"a": 1, "b": 2}', emoji: '✅', isCode: true),
            ChoiceOption(text: 'sozluk = ["a": 1, "b": 2]', emoji: '❌', isCode: true),
            ChoiceOption(text: 'sozluk = ("a": 1, "b": 2)', emoji: '❌', isCode: true),
            ChoiceOption(text: 'sozluk = <"a": 1, "b": 2>', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'Sözlükler süslü parantez {} ile oluşturulur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p7_1_exp2',
          title: 'Sözlüğe Erisim',
          content: 'Anahtarla degere ulasiriz:\n\nnotlar = {\n    "mat": 85,\n    "fen": 90,\n    "ing": 78\n}\n\nprint(notlar["mat"])  # 85\nnotlar["fen"] = 95    # Degistir\nnotlar["tur"] = 88    # Yeni ekle',
          tipEmoji: '📝',
          tip: 'Köşeli parantez [] ile hem okur hem yazarız!',
        ),

        MultipleChoiceStep(
          id: 'p7_1_q2',
          question: 'Bu kod ne yapar?\n\nkisi = {"ad": "Ayse", "soyad": "Yilmaz"}\nkisi["yas"] = 16',
          options: [
            ChoiceOption(text: 'Sözlüğe yeni "yas" anahtari ekler', emoji: '✅'),
            ChoiceOption(text: 'Hata verir', emoji: '❌'),
            ChoiceOption(text: 'Hiçbir sey yapmaz', emoji: '❌'),
            ChoiceOption(text: 'Sözlüğü siler', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Olmayan bir anahtara atama yaparsak, yeni key-value çifti eklenir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p7_1_exp3',
          title: 'Sözlük Metodlari',
          content: 'Faydali metodlar:\n\nmenu = {"pizza": 50, "burger": 35}\n\nprint(menu.keys())    # Anahtarlar\nprint(menu.values())  # Degerler\nprint(menu.items())   # Ciftler\n\nif "pizza" in menu:\n    print("Pizza var!")',
          tipEmoji: '🛠️',
          tip: 'in operatoru anahtarlarda arama yapar!',
        ),

        TypeCodeStep(
          id: 'p7_1_type1',
          instruction: 'Bir telefon rehberi sözlüğü olustur ve bir kisi ekle:',
          targetCode: 'rehber = {}\nrehber["Ali"] = "555-1234"',
          language: 'python',
          hints: [
            'Bos sözlük: {}',
            'Anahtar olarak isim kullan',
            'Deger olarak telefon numarasi',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'p7_1_summary',
          title: 'Sözlük Ustasi!',
          content: '📖 Artik sözlüklerle çalışabilirsin!\n\n✓ Anahtar-deger ciftleri\n✓ Hizli erisim\n✓ Ekleme, silme, degistirme\n\nSözlükler çok güçlü veri yapilari!',
          tipEmoji: '🏆',
          tip: 'Sözlük Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 7.2: İleri Sözlük İşlemleri
    InteractiveLesson(
      id: 'python_7_2',
      courseId: 'python',
      title: 'Ileri Sözlük Işlemleri',
      subtitle: 'İç içe sözlükler ve daha fazlasi',
      order: 14,
      xpReward: 120,
      badge: 'dict_wizard',
      steps: [
        IntroStep(
          id: 'p7_2_intro',
          mascotEmoji: '🧙',
          mascotMessage: 'Sözlüklerle daha karmaşık veri yapilari oluşturabiliriz! İç içe sözlükler, döngüler...',
        ),

        ExplanationStep(
          id: 'p7_2_exp1',
          title: 'İç İçe Sözlükler',
          content: 'Sözlük içinde sözlük:\n\nokullar = {\n    "lise1": {\n        "ad": "Atatürk Lisesi",\n        "ogrenci": 500\n    },\n    "lise2": {\n        "ad": "Fen Lisesi",\n        "ogrenci": 300\n    }\n}\n\nprint(okullar["lise1"]["ad"])',
          tipEmoji: '🎯',
          tip: 'İç içe sözlüklerle kompleks veri organize edebiliriz!',
        ),

        MultipleChoiceStep(
          id: 'p7_2_q1',
          question: 'Bu kod ne yazdirir?\n\ndata = {"a": {"b": {"c": 42}}}\nprint(data["a"]["b"]["c"])',
          options: [
            ChoiceOption(text: '42', emoji: '✅'),
            ChoiceOption(text: '{"c": 42}', emoji: '❌'),
            ChoiceOption(text: 'Hata verir', emoji: '❌'),
            ChoiceOption(text: 'None', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'İç içe anahtarlarla derinlere inebiliriz!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p7_2_exp2',
          title: 'Sözlükte Döngü',
          content: 'Sözlükleri döngüyle dolaşabiliriz:\n\nnotlar = {"Ali": 85, "Ayse": 90}\n\nfor isim in notlar:\n    print(isim, notlar[isim])\n\n# Ya da:\nfor isim, not in notlar.items():\n    print(isim, not)',
        ),

        TypeCodeStep(
          id: 'p7_2_type1',
          instruction: 'Sözlükteki tüm degerleri toplayan kod yaz:',
          targetCode: 'toplam = 0\nfor deger in notlar.values():\n    toplam += deger',
          language: 'python',
          hints: [
            'toplam = 0 ile başla',
            '.values() ile degerleri al',
            'for döngüsü kullan',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'p7_2_summary',
          title: 'Sözlük Sihirbazi!',
          content: '🧙 Sözlüklerde uzmanlaştin!\n\n✓ İç içe sözlükler\n✓ Döngülerle dolaşma\n✓ Kompleks veri yapilari\n\nArtik gerçek projelerde kullanabilirsin!',
          tipEmoji: '🏆',
          tip: 'Sözlük Sihirbazi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 8: DOSYA İŞLEMLERİ (File I/O)
  // ==========================================
  static final List<InteractiveLesson> module8 = [
    // LESSON 8.1: Dosya Okuma
    InteractiveLesson(
      id: 'python_8_1',
      courseId: 'python',
      title: 'Dosya Okuma',
      subtitle: 'Dosyalardan veri oku!',
      order: 15,
      xpReward: 120,
      badge: 'file_reader',
      steps: [
        IntroStep(
          id: 'p8_1_intro',
          mascotEmoji: '📂',
          mascotMessage: 'Programlar dosyalardan veri okuyabilir! Metin dosyalari, CSV, JSON ve daha fazlasi...',
          highlights: [
            'Dosya açma/kapama',
            'Satir satir okuma',
            'Güvenli dosya islemi',
          ],
        ),

        ExplanationStep(
          id: 'p8_1_exp1',
          title: 'Dosya Nasil Açilir?',
          content: 'open() fonksiyonu ile dosya açariz:\n\nwith open("dosya.txt", "r") as f:\n    icerik = f.read()\n    print(icerik)\n\n# with otomatik kapatir!',
          tipEmoji: '🔐',
          tip: 'with kullanmak en güvenli yöntem! Dosya otomatik kapanir.',
        ),

        MultipleChoiceStep(
          id: 'p8_1_q1',
          question: 'Dosya okumak icin hangi mod kullanilir?',
          options: [
            ChoiceOption(text: '"r" (read - okuma)', emoji: '✅'),
            ChoiceOption(text: '"w" (write - yazma)', emoji: '❌'),
            ChoiceOption(text: '"a" (append - ekleme)', emoji: '❌'),
            ChoiceOption(text: '"x" (create - olusturma)', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '"r" modu dosyayi okuma modunda açar!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p8_1_exp2',
          title: 'Satir Satir Okuma',
          content: 'Büyük dosyalari satir satir oku:\n\nwith open("liste.txt", "r") as f:\n    for satir in f:\n        print(satir.strip())\n\n# .strip() bosluk/satir sonunu siler',
          tipEmoji: '📄',
          tip: 'Büyük dosyalar için .read() yerine for döngüsü kullan!',
        ),

        MultipleChoiceStep(
          id: 'p8_1_q2',
          question: 'strip() ne işe yarar?',
          options: [
            ChoiceOption(text: 'Baştaki ve sondaki boşluklari siler', emoji: '✅'),
            ChoiceOption(text: 'Dosyayi kapatir', emoji: '❌'),
            ChoiceOption(text: 'Dosyayi açar', emoji: '❌'),
            ChoiceOption(text: 'Dosyayi siler', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '.strip() satir başi/sonu boşluklarini temizler!',
          xpReward: 10,
        ),

        TypeCodeStep(
          id: 'p8_1_type1',
          instruction: 'Dosyadaki satir sayisini sayan kod yaz:',
          targetCode: 'with open("dosya.txt", "r") as f:\n    satir_sayisi = len(f.readlines())',
          language: 'python',
          hints: [
            'with open(...) kullan',
            'readlines() tüm satirlari liste yapar',
            'len() ile uzunlugu bul',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'p8_1_summary',
          title: 'Dosya Okuyucu!',
          content: '📂 Artik dosyalari okuyabilirsin!\n\n✓ open() ile açma\n✓ with ile güvenli kullanim\n✓ Satir satir okuma\n\nVerileri dosyalardan almak artik kolay!',
          tipEmoji: '🏆',
          tip: 'Dosya Okuyucu rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 8.2: Dosya Yazma
    InteractiveLesson(
      id: 'python_8_2',
      courseId: 'python',
      title: 'Dosya Yazma',
      subtitle: 'Dosyalara veri yaz!',
      order: 16,
      xpReward: 130,
      badge: 'file_writer',
      steps: [
        IntroStep(
          id: 'p8_2_intro',
          mascotEmoji: '✍️',
          mascotMessage: 'Programin ürettigi verileri dosyalara kaydedebiliriz! Log tutma, rapor olusturma...',
        ),

        ExplanationStep(
          id: 'p8_2_exp1',
          title: 'Dosyaya Yazma',
          content: 'write() ile dosyaya yaziriz:\n\nwith open("cikti.txt", "w") as f:\n    f.write("Merhaba Dunya!\\n")\n    f.write("Python harika!\\n")\n\n# "w" modu: yeni dosya ya da üzerine yaz',
          tipEmoji: '⚠️',
          tip: '"w" modu eski içeriği siler! Dikkatli ol!',
        ),

        MultipleChoiceStep(
          id: 'p8_2_q1',
          question: '"w" ve "a" modu arasindaki fark nedir?',
          options: [
            ChoiceOption(text: '"w" üzerine yazar, "a" sonuna ekler', emoji: '✅'),
            ChoiceOption(text: 'Ikisi de ayni', emoji: '❌'),
            ChoiceOption(text: '"w" ekler, "a" üzerine yazar', emoji: '❌'),
            ChoiceOption(text: 'Ikisi de dosyayi siler', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '"w" (write) eski içeriği siler, "a" (append) sonuna ekler!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p8_2_exp2',
          title: 'Listeyi Dosyaya Kaydet',
          content: 'Liste verilerini dosyaya yazmak:\n\nisimler = ["Ali", "Ayse", "Mehmet"]\n\nwith open("liste.txt", "w") as f:\n    for isim in isimler:\n        f.write(isim + "\\n")',
          tipEmoji: '📝',
          tip: '\\n satir sonu ekler, yoksa hersey birbirine yapışir!',
        ),

        TypeCodeStep(
          id: 'p8_2_type1',
          instruction: 'Sözlüğü dosyaya yazan kod (anahtar: deger formatinda):',
          targetCode: 'with open("notlar.txt", "w") as f:\n    for isim, not in notlar.items():\n        f.write(f"{isim}: {not}\\n")',
          language: 'python',
          hints: [
            'with open(..., "w") kullan',
            '.items() ile anahtar-deger al',
            'f-string ile formatla',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'p8_2_exp3',
          title: 'JSON ile Çalişma',
          content: 'JSON formatinda veri kaydetme:\n\nimport json\n\ndata = {"ad": "Ali", "yas": 15}\n\nwith open("data.json", "w") as f:\n    json.dump(data, f)\n\n# JSON okunabilir ve popüler!',
          tipEmoji: '🌐',
          tip: 'JSON web servisleri için standart format!',
        ),

        ExplanationStep(
          id: 'p8_2_summary',
          title: 'Dosya Yazici!',
          content: '✍️ Dosyalara veri yazmada uzmanlaştin!\n\n✓ Yazma modlari (w, a)\n✓ Liste ve sözlük kaydetme\n✓ JSON formatinda veri\n\nVerileri kalici olarak saklayabilirsin!',
          tipEmoji: '🏆',
          tip: 'Dosya Yazici rozetini kazandin!',
        ),
      ],
    ),
  ];

  /// Get all Python lessons by module
  static List<InteractiveLesson> getPythonInteractiveLessons() {
    return [
      ...module1,
      ...module2,
      ...module3,
      ...module4,
      ...module5,
      ...module6,
      ...module7,
      ...module8,
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
      case 5:
        return module5;
      case 6:
        return module6;
      case 7:
        return module7;
      case 8:
        return module8;
      default:
        return [];
    }
  }
}

/// Python badges
class PythonBadges {
  static const List<LessonBadge> all = [
    LessonBadge(
      id: 'python_starter',
      name: 'Python Baslangic',
      description: 'Python\'a ilk adimini attin!',
      emoji: '🐍',
      rarity: BadgeRarity.common,
      category: BadgeCategory.lesson,
    ),
    LessonBadge(
      id: 'variable_master',
      name: 'Degisken Ustasi',
      description: 'Degiskenleri ogrendin!',
      emoji: '📦',
      rarity: BadgeRarity.common,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'math_wizard',
      name: 'Matematik Buyucusu',
      description: 'Python ile matematik artik kolay!',
      emoji: '🧮',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'input_master',
      name: 'Input Ustasi',
      description: 'Kullanicidan veri almayı ogrendin!',
      emoji: '⌨️',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'converter_pro',
      name: 'Donusturucu Pro',
      description: 'Tip donusumunde ustalaştin!',
      emoji: '🔄',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'decision_maker',
      name: 'Karar Verici',
      description: 'if kosulunu ogrendin!',
      emoji: '🤔',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'logic_expert',
      name: 'Mantik Uzmani',
      description: 'else ve elif\'i fethettin!',
      emoji: '↔️',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'loop_starter',
      name: 'Dongu Baslangici',
      description: 'while dongusuyle tanistin!',
      emoji: '🔄',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'for_master',
      name: 'For Dongu Ustasi',
      description: 'for dongusunde uzmanlaştin!',
      emoji: '📜',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'list_beginner',
      name: 'Liste Baslangici',
      description: 'Listeyi kesfettin!',
      emoji: '📋',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.course,
    ),
    LessonBadge(
      id: 'function_creator',
      name: 'Fonksiyon Yaratici',
      description: 'Ilk fonksiyonunu yazdin!',
      emoji: '🔧',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'function_master',
      name: 'Fonksiyon Ustasi',
      description: 'Fonksiyonlarda uzmanlaştin!',
      emoji: '⚙️',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'dict_master',
      name: 'Sözlük Ustasi',
      description: 'Anahtar-deger ciftlerini ogrendin!',
      emoji: '📖',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'dict_wizard',
      name: 'Sözlük Sihirbazi',
      description: 'İç içe sözlüklerle uzmanlaştin!',
      emoji: '🧙',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'file_reader',
      name: 'Dosya Okuyucu',
      description: 'Dosyalardan veri okumayı ogrendin!',
      emoji: '📂',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'file_writer',
      name: 'Dosya Yazici',
      description: 'Dosyalara veri yazmada ustalaştin!',
      emoji: '✍️',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.skill,
    ),
  ];
}
