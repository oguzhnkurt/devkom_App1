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

    // LESSON 5.2: Liste Metotlari
    InteractiveLesson(
      id: 'python_5_2',
      courseId: 'python',
      title: 'Liste Metotlari',
      subtitle: 'Ekle, cikar, sirala!',
      order: 17,
      xpReward: 100,
      steps: [
        IntroStep(
          id: 'p5_2_intro',
          mascotEmoji: '🛠️',
          mascotMessage: 'Listeleri ogrendin, simdi onlari yonetmeyi ogren! Ekleme, cikarma, siralama...',
          highlights: [
            'append() ile ekle',
            'remove() ile cikar',
            'sort() ile sirala',
          ],
        ),

        ExplanationStep(
          id: 'p5_2_exp1',
          title: 'Listeye Eleman Ekleme',
          content: 'append() listenin SONUNA ekler:\n\nmeyveler = ["elma", "armut"]\nmeyveler.append("muz")\n# ["elma", "armut", "muz"]\n\ninsert() istedigin YERE ekler:\n\nmeyveler.insert(0, "kiraz")\n# ["kiraz", "elma", "armut", "muz"]',
          tipEmoji: '💡',
          tip: 'append her zaman sona ekler, insert ile yeri sen secersin!',
        ),

        MultipleChoiceStep(
          id: 'p5_2_q1',
          question: 'sayilar = [1, 2, 3]\nsayilar.append(4)\nprint(sayilar) ne yazdirir?',
          options: [
            ChoiceOption(text: '[1, 2, 3, 4]', isCode: true),
            ChoiceOption(text: '[4, 1, 2, 3]', isCode: true),
            ChoiceOption(text: '[1, 2, 3]', isCode: true),
            ChoiceOption(text: 'Hata verir'),
          ],
          correctIndex: 0,
          explanation: 'append() elemani listenin sonuna ekler: [1, 2, 3, 4]',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p5_2_exp2',
          title: 'Eleman Cikarma',
          content: 'remove() degere gore cikarir:\n\nmeyveler.remove("elma")\n\npop() index\'e gore cikarir:\n\nmeyveler.pop(0)  # ilk elemani cikar\nmeyveler.pop()   # son elemani cikar',
        ),

        CodeCompleteStep(
          id: 'p5_2_code1',
          instruction: 'Listeye "kalem" ekle ve listeyi yazdir',
          codeTemplate: 'canta = ["defter", "silgi"]\ncanta.___("kalem")\nprint(canta)',
          blanks: [
            CodeBlank(
              index: 0,
              correctAnswer: 'append',
              hint: 'Sona eklemek icin kullanilan metot',
            ),
          ],
          language: 'python',
          expectedOutput: "['defter', 'silgi', 'kalem']",
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'p5_2_exp3',
          title: 'Siralama',
          content: 'sort() listeyi kucukten buyuge siralar:\n\nsayilar = [3, 1, 2]\nsayilar.sort()\n# [1, 2, 3]\n\nTersten siralamak icin:\n\nsayilar.sort(reverse=True)\n# [3, 2, 1]',
          tipEmoji: '🔤',
          tip: 'sort() metinleri de alfabetik siralar!',
        ),

        MultipleChoiceStep(
          id: 'p5_2_q2',
          question: 'Bir listede kac eleman oldugunu nasil ogrenirsin?',
          options: [
            ChoiceOption(text: 'len(liste)', isCode: true),
            ChoiceOption(text: 'liste.uzunluk()', isCode: true),
            ChoiceOption(text: 'count(liste)', isCode: true),
            ChoiceOption(text: 'liste.size', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'len() fonksiyonu listenin eleman sayisini verir.',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'p5_2_summary',
          title: 'Liste Ustasi!',
          content: '🛠️ Artik listeleri tam kontrol edebiliyorsun!\n\n✓ append() ve insert() ile ekleme\n✓ remove() ve pop() ile cikarma\n✓ sort() ile siralama\n✓ len() ile sayma\n\nSonraki modul: Fonksiyonlar!',
          tipEmoji: '🏆',
          tip: 'Listeler Python\'un en cok kullanilan veri yapisidir!',
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

  // ==========================================
  // MODUL 9: ILERI SEVIYE PYTHON
  // Gercek Python projelerinde gunluk kullanilan konular:
  // try/except, moduller/kutuphaneler, list/dict comprehension
  // ve nesne yonelimli programlamaya (OOP) giris.
  // ==========================================
  static final List<InteractiveLesson> module9 = [
    // LESSON 9.1: Hatalarla Basa Cikmak (try/except)
    InteractiveLesson(
      id: 'python_9_1',
      courseId: 'python',
      title: 'Hatalarla Basa Cikmak',
      subtitle: 'try/except ile programini cokertme',
      titleEn: 'Handling Errors Gracefully',
      subtitleEn: 'Use try/except so your program never crashes',
      order: 17,
      xpReward: 130,
      badge: 'error_handler',
      category: LessonCategory.learn,
      steps: [
        IntroStep(
          id: 'p9_1_intro',
          mascotEmoji: '🚨',
          mascotMessage: 'Simdiye kadar bir hata olunca programin durdu, degil mi? Gercek yazilimcilar hatalari ONCEDEN tahmin edip programlarinin cokmesini engeller. Buna "hata yakalama" (exception handling) denir!',
          highlights: [
            'try/except blogu nedir',
            'Hangi hata turleri olusabilir',
            'Kullanicidan gelen kotu veriyi yonetmek',
          ],
          mascotMessageEn: 'Until now, an error would stop your whole program, right? Real developers anticipate errors in advance so their programs never crash. This is called "exception handling"!',
          highlightsEn: [
            'What a try/except block is',
            'What kinds of errors can happen',
            'Handling bad input from a user',
          ],
        ),
        ExplanationStep(
          id: 'p9_1_exp1',
          title: 'try/except Nasil Calisir?',
          content: 'try:\n    sayi = int(input("Bir sayi gir: "))\n    print(100 / sayi)\nexcept ValueError:\n    print("Bu bir sayi degil!")\nexcept ZeroDivisionError:\n    print("Sifira bolemezsin!")\n\nPython once try blogunu dener. Hata olursa, uygun except blogu calisir ve program COKMEZ, kaldigi yerden devam eder.',
          tipEmoji: '🛡️',
          tip: 'try/except\'i bir "guvenlik agi" gibi dusun - asagi dusersen seni yakalar!',
          titleEn: 'How try/except Works',
          contentEn: 'try:\n    number = int(input("Enter a number: "))\n    print(100 / number)\nexcept ValueError:\n    print("That is not a number!")\nexcept ZeroDivisionError:\n    print("You cannot divide by zero!")\n\nPython first tries the try block. If an error happens, the matching except block runs and the program does NOT crash - it keeps going.',
          tipEn: 'Think of try/except as a "safety net" - if you fall, it catches you!',
        ),
        MultipleChoiceStep(
          id: 'p9_1_q1',
          question: 'Kullanici sayi yerine harf girerse hangi hata olusur?',
          options: [
            ChoiceOption(text: 'ValueError', emoji: '✅'),
            ChoiceOption(text: 'ZeroDivisionError', emoji: '❌'),
            ChoiceOption(text: 'SyntaxError', emoji: '❌'),
            ChoiceOption(text: 'Hicbir hata olmaz', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'int() fonksiyonu bir harfi sayiya cevirmeye calisirken basarisiz olursa ValueError firlatir.',
          questionEn: 'What error occurs if the user types a letter instead of a number?',
          explanationEn: 'When int() fails to convert a letter into a number, it raises a ValueError.',
          xpReward: 10,
        ),
        ExplanationStep(
          id: 'p9_1_exp2',
          title: 'else ve finally',
          content: 'try/except\'e iki opsiyonel blok daha eklenebilir:\n\ntry:\n    sonuc = 10 / 2\nexcept ZeroDivisionError:\n    print("Hata!")\nelse:\n    print("Hata olmadi, sonuc:", sonuc)\nfinally:\n    print("Bu her turlu calisir")\n\nelse: sadece hata OLMAZSA calisir.\nfinally: hata olsa da olmasa da HER ZAMAN calisir (ornegin dosya kapatmak icin idealdir).',
          tipEmoji: '🔁',
          tip: 'finally, "ne olursa olsun bu isi yap" demenin yolu - bir dosyayi kapatmak gibi.',
          titleEn: 'else and finally',
          contentEn: 'Two optional blocks can be added to try/except:\n\ntry:\n    result = 10 / 2\nexcept ZeroDivisionError:\n    print("Error!")\nelse:\n    print("No error, result:", result)\nfinally:\n    print("This always runs")\n\nelse: runs only if NO error happened.\nfinally: ALWAYS runs whether there was an error or not (ideal for closing a file, for example).',
          tipEn: 'finally is how you say "do this no matter what" - like closing a file.',
        ),
        CodeCompleteStep(
          id: 'p9_1_complete1',
          instruction: 'Kullanicidan yas alip, hatali girilirse uyari veren kodu tamamla.',
          codeTemplate: '___:\n    yas = int(input("Yasini gir: "))\n    print("Yasin:", yas)\n___ ValueError:\n    print("Gecerli bir sayi gir!")',
          language: 'python',
          blanks: [
            CodeBlank(index: 0, correctAnswer: 'try', hint: 'Denenecek kodu baslatan anahtar kelime', hintEn: 'The keyword that starts the code to attempt'),
            CodeBlank(index: 1, correctAnswer: 'except', hint: 'Hatayi yakalayan anahtar kelime', hintEn: 'The keyword that catches the error'),
          ],
          instructionEn: 'Complete the code that asks for the user\'s age and warns if the input is invalid.',
          xpReward: 20,
        ),
        ExplanationStep(
          id: 'p9_1_summary',
          title: 'Artik Programin Cokmuyor!',
          content: '🛡️ Hatalari yonetmeyi ogrendin!\n\n✓ try/except ile hatalari yakalayabiliyorsun\n✓ ValueError, ZeroDivisionError gibi hata turlerini taniyorsun\n✓ else ve finally bloklarini kullanabiliyorsun\n\nSirada: Python\'un hazir kutuphanelerini kullanmak var!',
          tipEmoji: '🏆',
          tip: 'Hata Yoneticisi rozetini kazandin!',
          titleEn: 'Your Program No Longer Crashes!',
          contentEn: '🛡️ You learned to handle errors!\n\n✓ You can catch errors with try/except\n✓ You recognize error types like ValueError and ZeroDivisionError\n✓ You can use else and finally blocks\n\nNext up: using Python\'s built-in libraries!',
          tipEn: 'You earned the Error Handler badge!',
        ),
      ],
    ),

    // LESSON 9.2: Moduller ve Kutuphaneler
    InteractiveLesson(
      id: 'python_9_2',
      courseId: 'python',
      title: 'Moduller ve Kutuphaneler',
      subtitle: 'Baskalarinin yazdigi kodu kullan',
      titleEn: 'Modules and Libraries',
      subtitleEn: 'Reuse code other people already wrote',
      order: 18,
      xpReward: 120,
      badge: 'module_master',
      category: LessonCategory.learn,
      steps: [
        IntroStep(
          id: 'p9_2_intro',
          mascotEmoji: '📦',
          mascotMessage: 'Her seyi sifirdan yazmana gerek yok! Python\'un icinde hazir binlerce arac var - "modul" denen kutuphaneler. import komutuyla onlari projene ekleyebilirsin.',
          highlights: [
            'import komutu',
            'random, math, datetime moduller',
            'Neden kod tekrar yazmayiz',
          ],
          mascotMessageEn: 'You don\'t need to write everything from scratch! Python comes with thousands of ready-made tools - "modules" you can add to your project with the import command.',
          highlightsEn: [
            'The import statement',
            'The random, math, and datetime modules',
            'Why we don\'t rewrite code that already exists',
          ],
        ),
        ExplanationStep(
          id: 'p9_2_exp1',
          title: 'import ile Modul Eklemek',
          content: 'import random\n\nzar = random.randint(1, 6)\nprint("Zar sonucu:", zar)\n\nimport math\nprint(math.sqrt(16))  # 4.0\n\nHer modul, icinde hazir fonksiyonlar barindiran bir "arac kutusu" gibidir. random modulu rastgele sayilar, math modulu matematik islemleri icin kullanilir.',
          tipEmoji: '🧰',
          tip: 'Python\'un "standart kutuphanesi" 200\'den fazla hazir modul icerir - hepsini import ile kullanabilirsin!',
          titleEn: 'Adding a Module with import',
          contentEn: 'import random\n\ndice = random.randint(1, 6)\nprint("Dice result:", dice)\n\nimport math\nprint(math.sqrt(16))  # 4.0\n\nEvery module is like a "toolbox" full of ready-made functions. The random module is for random numbers, the math module is for math operations.',
          tipEn: 'Python\'s "standard library" has over 200 ready-made modules - you can use any of them with import!',
        ),
        ExplanationStep(
          id: 'p9_2_exp2',
          title: 'datetime ile Tarih ve Saat',
          content: 'import datetime\n\nsimdi = datetime.datetime.now()\nprint("Su an:", simdi)\nprint("Yil:", simdi.year)\n\nBu, ornegin bir gorev listesi uygulamasinda "olusturulma tarihi" kaydetmek icin cok kullanilir!',
          tipEmoji: '📅',
          tip: 'datetime.now() her calistirdiginda o anin gercek tarih/saatini verir.',
          titleEn: 'Dates and Times with datetime',
          contentEn: 'import datetime\n\nnow = datetime.datetime.now()\nprint("Right now:", now)\nprint("Year:", now.year)\n\nThis is commonly used, for example, to record a "created at" timestamp in a to-do list app!',
          tipEn: 'datetime.now() gives you the real current date/time every time you run it.',
        ),
        MultipleChoiceStep(
          id: 'p9_2_q1',
          question: '1 ile 100 arasinda rastgele bir sayi uretmek icin ne yazarsin?',
          options: [
            ChoiceOption(text: 'random.randint(1, 100)', emoji: '✅'),
            ChoiceOption(text: 'math.random(1, 100)', emoji: '❌'),
            ChoiceOption(text: 'datetime.random(1, 100)', emoji: '❌'),
            ChoiceOption(text: 'randint.random(1, 100)', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'random modulunun randint(alt, ust) fonksiyonu, iki sinir arasinda (dahil) rastgele bir tam sayi uretir.',
          questionEn: 'What do you write to generate a random number between 1 and 100?',
          explanationEn: 'The random module\'s randint(low, high) function generates a random whole number between the two bounds (inclusive).',
          xpReward: 10,
        ),
        TypeCodeStep(
          id: 'p9_2_type1',
          instruction: 'random modulunu kullanarak 1-10 arasi rastgele bir sayi uretip yazdiran kodu yaz.',
          targetCode: 'import random\n\nsayi = random.randint(1, 10)\nprint(sayi)',
          language: 'python',
          starterCode: '\n\nsayi = \nprint(sayi)',
          hints: [
            'En basa import random yazmalisin',
            'random.randint(1, 10) rastgele sayi uretir',
          ],
          hintsEn: [
            'Start with import random',
            'random.randint(1, 10) generates the random number',
          ],
          instructionEn: 'Use the random module to generate and print a random number between 1 and 10.',
          xpReward: 20,
        ),
        ExplanationStep(
          id: 'p9_2_summary',
          title: 'Kutuphane Ustasisin!',
          content: '📦 Artik Python\'un gucunden faydalaniyorsun!\n\n✓ import ile modul eklemeyi ogrendin\n✓ random ile rastgelelik uretebiliyorsun\n✓ math ve datetime modullerini taniyorsun\n\nSirada: kod yazmayi kisaltan comprehension\'lar var!',
          tipEmoji: '🏆',
          tip: 'Kutuphane Ustasi rozetini kazandin!',
          titleEn: 'You\'re a Library Master!',
          contentEn: '📦 You\'re now using the power of Python!\n\n✓ You learned to add modules with import\n✓ You can generate randomness with random\n✓ You know the math and datetime modules\n\nNext up: comprehensions that shorten your code!',
          tipEn: 'You earned the Library Master badge!',
        ),
      ],
    ),

    // LESSON 9.3: Liste ve Sozluk Kisayollari (Comprehensions)
    InteractiveLesson(
      id: 'python_9_3',
      courseId: 'python',
      title: 'Liste ve Sozluk Kisayollari',
      subtitle: 'Tek satirda liste olusturmak',
      titleEn: 'List and Dict Shortcuts',
      subtitleEn: 'Build a list in a single line',
      order: 19,
      xpReward: 140,
      badge: 'comprehension_pro',
      category: LessonCategory.learn,
      steps: [
        IntroStep(
          id: 'p9_3_intro',
          mascotEmoji: '⚡',
          mascotMessage: 'for donguleriyle liste doldurmayi biliyorsun. Ama Python\'da bunu TEK SATIRDA yapmanin cok sik kullanilan bir yolu var: "list comprehension"! Profesyonel Python kodlarinda her yerde karsina cikacak.',
          highlights: [
            'List comprehension sozdizimi',
            'Kosullu comprehension (if ile)',
            'Dict comprehension',
          ],
          mascotMessageEn: 'You already know how to fill a list with a for loop. But Python has a very popular way to do it in ONE LINE: "list comprehension"! You\'ll see it everywhere in professional Python code.',
          highlightsEn: [
            'List comprehension syntax',
            'Conditional comprehension (with if)',
            'Dict comprehension',
          ],
        ),
        ExplanationStep(
          id: 'p9_3_exp1',
          title: 'Klasik Yontem vs Comprehension',
          content: 'Klasik yontem:\nkareler = []\nfor sayi in range(1, 6):\n    kareler.append(sayi ** 2)\n\nComprehension ile (tek satir!):\nkareler = [sayi ** 2 for sayi in range(1, 6)]\n\nIkisi de ayni sonucu verir: [1, 4, 9, 16, 25]. Comprehension, "her eleman icin bir islem yap ve yeni listeye koy" demenin kisa yoludur.',
          tipEmoji: '⚡',
          tip: 'Format sunun gibidir: [ifade for eleman in liste]',
          titleEn: 'Classic Method vs Comprehension',
          contentEn: 'Classic method:\nsquares = []\nfor number in range(1, 6):\n    squares.append(number ** 2)\n\nWith comprehension (one line!):\nsquares = [number ** 2 for number in range(1, 6)]\n\nBoth give the same result: [1, 4, 9, 16, 25]. Comprehension is a short way of saying "do something to each item and put it in a new list".',
          tipEn: 'The format looks like this: [expression for item in list]',
        ),
        ExplanationStep(
          id: 'p9_3_exp2',
          title: 'Kosullu Comprehension',
          content: 'Sadece belirli elemanlari almak icin if ekleyebilirsin:\n\ncift_sayilar = [x for x in range(1, 11) if x % 2 == 0]\n# [2, 4, 6, 8, 10]\n\nDict comprehension da benzer sekilde calisir:\n\nkareler_sozluk = {x: x**2 for x in range(1, 6)}\n# {1: 1, 2: 4, 3: 9, 4: 16, 5: 25}',
          tipEmoji: '🔍',
          tip: 'if kosulu, comprehension\'in sonuna eklenir: [ifade for eleman in liste if kosul]',
          titleEn: 'Conditional Comprehension',
          contentEn: 'You can add an if to keep only certain items:\n\neven_numbers = [x for x in range(1, 11) if x % 2 == 0]\n# [2, 4, 6, 8, 10]\n\nDict comprehension works similarly:\n\nsquares_dict = {x: x**2 for x in range(1, 6)}\n# {1: 1, 2: 4, 3: 9, 4: 16, 5: 25}',
          tipEn: 'The if condition goes at the end of the comprehension: [expression for item in list if condition]',
        ),
        MultipleChoiceStep(
          id: 'p9_3_q1',
          question: '[x * 2 for x in range(1, 4)] ifadesinin sonucu nedir?',
          options: [
            ChoiceOption(text: '[2, 4, 6]', emoji: '✅'),
            ChoiceOption(text: '[1, 2, 3]', emoji: '❌'),
            ChoiceOption(text: '[2, 4, 6, 8]', emoji: '❌'),
            ChoiceOption(text: 'Hata verir', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'range(1, 4) sirasiyla 1, 2, 3 uretir; her biri 2 ile carpilir: [2, 4, 6]',
          questionEn: 'What is the result of [x * 2 for x in range(1, 4)]?',
          explanationEn: 'range(1, 4) produces 1, 2, 3 in order; each is multiplied by 2, giving [2, 4, 6]',
          xpReward: 15,
        ),
        TypeCodeStep(
          id: 'p9_3_type1',
          instruction: '1-20 arasindaki 3\'e bolunebilen sayilarin listesini comprehension ile yaz.',
          targetCode: 'sayilar = [x for x in range(1, 21) if x % 3 == 0]',
          language: 'python',
          hints: [
            'range(1, 21) 1\'den 20\'ye kadar sayilari verir',
            'x % 3 == 0 kosulu 3\'e tam bolunmeyi kontrol eder',
          ],
          hintsEn: [
            'range(1, 21) gives numbers from 1 to 20',
            'The condition x % 3 == 0 checks divisibility by 3',
          ],
          instructionEn: 'Write a comprehension that lists numbers between 1-20 divisible by 3.',
          xpReward: 25,
        ),
        ExplanationStep(
          id: 'p9_3_summary',
          title: 'Kisayollari Ogrendin!',
          content: '⚡ Artik daha kisa ve okunakli kod yaziyorsun!\n\n✓ List comprehension yazabiliyorsun\n✓ Kosullu comprehension kullanabiliyorsun\n✓ Dict comprehension\'i taniyorsun\n\nSirada: Python\'un en guclu konusu - Nesne Yonelimli Programlama!',
          tipEmoji: '🏆',
          tip: 'Comprehension Ustasi rozetini kazandin!',
          titleEn: 'You Learned the Shortcuts!',
          contentEn: '⚡ You now write shorter, more readable code!\n\n✓ You can write list comprehensions\n✓ You can use conditional comprehensions\n✓ You know dict comprehension\n\nNext up: Python\'s most powerful topic - Object-Oriented Programming!',
          tipEn: 'You earned the Comprehension Pro badge!',
        ),
      ],
    ),

    // LESSON 9.4: Nesne Yonelimli Programlamaya Giris (OOP)
    InteractiveLesson(
      id: 'python_9_4',
      courseId: 'python',
      title: 'Nesne Yonelimli Programlamaya Giris',
      subtitle: 'Kendi veri turlerini tasarla',
      titleEn: 'Intro to Object-Oriented Programming',
      subtitleEn: 'Design your own data types',
      order: 20,
      xpReward: 150,
      badge: 'oop_beginner',
      category: LessonCategory.learn,
      steps: [
        IntroStep(
          id: 'p9_4_intro',
          mascotEmoji: '🏗️',
          mascotMessage: 'Simdiye kadar sayilar, metinler, listeler kullandik. Simdi KENDI veri turlerini yaratmayi ogreneceksin! Buna "sinif" (class) denir - gercek dunyadaki bir "ogrenci" ya da "araba" gibi seyleri kodda temsil etmenin yolu.',
          highlights: [
            'class ve nesne (object) kavrami',
            '__init__ ile baslangic degerleri',
            'Metodlar (sinifin fonksiyonlari)',
          ],
          mascotMessageEn: 'So far we\'ve used numbers, text, and lists. Now you\'ll learn to create your OWN data types! This is called a "class" - a way to represent real-world things like a "student" or a "car" in code.',
          highlightsEn: [
            'The concept of a class and an object',
            'Setting starting values with __init__',
            'Methods (functions that belong to a class)',
          ],
        ),
        ExplanationStep(
          id: 'p9_4_exp1',
          title: 'Ilk Sinifin (class)',
          content: 'class Ogrenci:\n    def __init__(self, isim, yas):\n        self.isim = isim\n        self.yas = yas\n\nogrenci1 = Ogrenci("Ali", 14)\nprint(ogrenci1.isim)  # Ali\n\n__init__, bir Ogrenci NESNESI olusturuldugunda otomatik calisan ozel bir fonksiyondur. self, "bu nesnenin kendisi" demektir - her ogrencinin kendi isim ve yasi olur.',
          tipEmoji: '🏗️',
          tip: 'class = plan/sablon (ornek: "araba" kavrami), nesne = o plandan uretilen gercek sey (ornek: senin arabana)',
          titleEn: 'Your First Class',
          contentEn: 'class Student:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n\nstudent1 = Student("Alex", 14)\nprint(student1.name)  # Alex\n\n__init__ is a special function that runs automatically whenever a Student OBJECT is created. self means "this specific object" - each student gets their own name and age.',
          tipEn: 'class = a blueprint (e.g. the idea of "a car"), object = a real thing made from that blueprint (e.g. your specific car)',
        ),
        ExplanationStep(
          id: 'p9_4_exp2',
          title: 'Metodlar: Sinifin Yapabildikleri',
          content: 'Bir sinifin icine, o sinifa ozel fonksiyonlar (metod) ekleyebilirsin:\n\nclass Ogrenci:\n    def __init__(self, isim, notlar):\n        self.isim = isim\n        self.notlar = notlar\n\n    def ortalama_hesapla(self):\n        return sum(self.notlar) / len(self.notlar)\n\nali = Ogrenci("Ali", [80, 90, 70])\nprint(ali.ortalama_hesapla())  # 80.0\n\nHer Ogrenci nesnesi kendi notlarina gore ortalama hesaplayabilir!',
          tipEmoji: '⚙️',
          tip: 'Metod, bir nesnenin "yapabildigi seyler" listesidir - print() gibi hazir fonksiyonlarin senin sinifina ozel hali.',
          titleEn: 'Methods: What a Class Can Do',
          contentEn: 'You can add functions (methods) specific to a class:\n\nclass Student:\n    def __init__(self, name, grades):\n        self.name = name\n        self.grades = grades\n\n    def calculate_average(self):\n        return sum(self.grades) / len(self.grades)\n\nalex = Student("Alex", [80, 90, 70])\nprint(alex.calculate_average())  # 80.0\n\nEvery Student object can calculate its own average from its own grades!',
          tipEn: 'A method is the list of things an object "can do" - your class\'s own version of a built-in function like print().',
        ),
        MultipleChoiceStep(
          id: 'p9_4_q1',
          question: '__init__ fonksiyonu ne zaman calisir?',
          options: [
            ChoiceOption(text: 'Yeni bir nesne olusturuldugunda otomatik olarak', emoji: '✅'),
            ChoiceOption(text: 'Program bittiginde', emoji: '❌'),
            ChoiceOption(text: 'Hicbir zaman otomatik calismaz', emoji: '❌'),
            ChoiceOption(text: 'Sadece cagirilirsa', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '__init__, bir sinifin nesnesi (ornegi) olusturulur olusturulmaz otomatik olarak calisir ve baslangic degerlerini ayarlar.',
          questionEn: 'When does the __init__ function run?',
          explanationEn: '__init__ runs automatically the moment an object (instance) of a class is created, and sets up its starting values.',
          xpReward: 15,
        ),
        OrderingStep(
          id: 'p9_4_order1',
          instruction: 'Bir Kitap sinifinin dogru satir sirasini olustur.',
          items: [
            OrderItem(id: 'l1', content: 'class Kitap:', isCode: true),
            OrderItem(id: 'l2', content: '    def __init__(self, baslik, yazar):', isCode: true),
            OrderItem(id: 'l3', content: '        self.baslik = baslik', isCode: true),
            OrderItem(id: 'l4', content: '        self.yazar = yazar', isCode: true),
          ],
          correctOrder: ['l1', 'l2', 'l3', 'l4'],
          context: 'Python sinifi (class) tanimi',
          instructionEn: 'Put the Book class lines in the correct order.',
          contextEn: 'A Python class definition',
          xpReward: 20,
        ),
        ExplanationStep(
          id: 'p9_4_summary',
          title: 'OOP Dunyasina Ilk Adimini Attin!',
          content: '🏗️ Artik kendi veri turlerini tasarlayabiliyorsun!\n\n✓ class ile sablon olusturmayi ogrendin\n✓ __init__ ile baslangic degerleri atayabiliyorsun\n✓ Metod yazip nesnenin "yapabildikleri"ni tanimliyorsun\n\nSirada: HER SEYI birlestiren final proje - Ogrenci Not Sistemi!',
          tipEmoji: '🏆',
          tip: 'OOP Cirak rozetini kazandin!',
          titleEn: 'You Took Your First Step into OOP!',
          contentEn: '🏗️ You can now design your own data types!\n\n✓ You learned to build a blueprint with class\n✓ You can set starting values with __init__\n✓ You can write methods that define what an object "can do"\n\nNext up: the final project that combines EVERYTHING - a Student Grade System!',
          tipEn: 'You earned the OOP Apprentice badge!',
        ),
      ],
    ),

    // LESSON 9.5: Final Proje - Ogrenci Not Sistemi
    InteractiveLesson(
      id: 'python_9_5',
      courseId: 'python',
      title: 'Final Proje: Ogrenci Not Sistemi',
      subtitle: 'OOP + hata yonetimi + dosya islemlerini birlestir',
      titleEn: 'Final Project: Student Grade System',
      subtitleEn: 'Combine OOP + error handling + file I/O',
      order: 21,
      xpReward: 180,
      badge: 'python_advanced_engineer',
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'p9_5_intro',
          mascotEmoji: '🎓',
          mascotMessage: 'Ileri Seviye Python modulunun final projesindesin! Bu modulde ogrendigin HER SEYI birlestirecegiz: class, try/except, comprehension ve JSON dosya islemleri. Gercek bir okul notu takip sistemi yazacaksin!',
          highlights: [
            'Ogrenci sinifi tasarlama',
            'Hatali not girisini yonetme',
            'Sonuclari JSON dosyaya kaydetme',
          ],
          mascotMessageEn: 'You\'ve reached the final project of the Advanced Python module! We\'ll combine EVERYTHING you learned here: classes, try/except, comprehensions, and JSON file operations. You\'ll build a real school grade-tracking system!',
          highlightsEn: [
            'Designing a Student class',
            'Handling invalid grade input',
            'Saving results to a JSON file',
          ],
        ),
        ExplanationStep(
          id: 'p9_5_exp1',
          title: 'Projenin Plani',
          content: 'Ogrenci Not Sistemi 3 parcadan olusuyor:\n\n1. Ogrenci sinifi (isim, notlar listesi, ortalama_hesapla() metodu)\n2. Notlari isaretlerken try/except ile hatali girisleri yonetmek (harf girilirse ValueError yakalanmali)\n3. Sonuclari json.dump() ile bir dosyaya kaydetmek\n\nclass Ogrenci:\n    def __init__(self, isim):\n        self.isim = isim\n        self.notlar = []\n\n    def not_ekle(self, not_degeri):\n        self.notlar.append(not_degeri)\n\n    def ortalama_hesapla(self):\n        if len(self.notlar) == 0:\n            return 0\n        return sum(self.notlar) / len(self.notlar)',
          tipEmoji: '🧩',
          tip: 'Buyuk projeleri her zaman kucuk, test edilebilir parcalara bol - once sinifi yaz, sonra hata yonetimini ekle, en son dosyaya kaydet.',
          titleEn: 'The Project Plan',
          contentEn: 'The Student Grade System has 3 parts:\n\n1. A Student class (name, list of grades, calculate_average() method)\n2. Handling invalid input with try/except while entering grades (catch ValueError if a letter is typed)\n3. Saving the results to a file with json.dump()\n\nclass Student:\n    def __init__(self, name):\n        self.name = name\n        self.grades = []\n\n    def add_grade(self, grade):\n        self.grades.append(grade)\n\n    def calculate_average(self):\n        if len(self.grades) == 0:\n            return 0\n        return sum(self.grades) / len(self.grades)',
          tipEn: 'Always break big projects into small, testable pieces - write the class first, then add error handling, then save to a file.',
        ),
        MultipleChoiceStep(
          id: 'p9_5_q1',
          question: 'Kullanicidan not alirken neden try/except kullanmaliyiz?',
          options: [
            ChoiceOption(text: 'Kullanici yanlislikla harf girerse program cokmesin diye', emoji: '✅'),
            ChoiceOption(text: 'Programi hizlandirmak icin', emoji: '❌'),
            ChoiceOption(text: 'Zorunlu oldugu icin, baska sebep yok', emoji: '❌'),
            ChoiceOption(text: 'JSON dosyasi olusturmak icin', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Kullanici girisi her zaman guvenilmezdir - try/except sayesinde beklenmedik bir giris programi cokertmez, kullaniciyi bilgilendirir.',
          questionEn: 'Why should we use try/except when taking a grade from the user?',
          explanationEn: 'User input is never fully trustworthy - try/except means an unexpected input informs the user instead of crashing the program.',
          xpReward: 15,
        ),
        ProjectStep(
          id: 'p9_5_project',
          title: 'Ogrenci Not Sistemi',
          description: 'Bir Ogrenci sinifi tasarla (isim, notlar, ortalama_hesapla metodu). Kullanicidan try/except ile guvenli sekilde notlar al, ortalamayi hesapla ve sonucu bir JSON dosyasina kaydet.',
          requirements: [
            '__init__ ile isim ve bos bir notlar listesi olan bir Ogrenci sinifi olustur',
            'not_ekle(not_degeri) metodu ile notlar listesine ekleme yap',
            'ortalama_hesapla() metodu ile notlarin ortalamasini dondur',
            'Kullanicidan not alirken try/except ile ValueError\'i yakala',
            'Ogrencinin isim ve ortalamasini json.dump() ile bir dosyaya kaydet',
          ],
          hints: [
            'self.notlar = [] ile bos liste baslat, sonra append() ile ekle',
            'ortalama_hesapla icinde notlar bos ise 0 dondurmeyi unutma (sifira bolme hatasini onler)',
            'json.dump(veri, dosya) ile bir sozlugu direkt dosyaya yazabilirsin',
          ],
          requirementsEn: [
            'Create a Student class with __init__ setting a name and an empty grades list',
            'Add an add_grade(grade) method that appends to the grades list',
            'Add a calculate_average() method that returns the average of the grades',
            'Use try/except to catch a ValueError while reading grade input from the user',
            'Save the student\'s name and average to a file using json.dump()',
          ],
          hintsEn: [
            'Start with self.grades = [] and add to it with append()',
            'Remember to return 0 from calculate_average if grades is empty (avoids division by zero)',
            'json.dump(data, file) writes a dictionary straight to a file',
          ],
          starterCode: 'import json\n\nclass Ogrenci:\n    def __init__(self, isim):\n        self.isim = isim\n        self.notlar = []\n\n    def not_ekle(self, not_degeri):\n        self.notlar.append(not_degeri)\n\n    def ortalama_hesapla(self):\n        # Buraya kodunu yaz\n        pass\n\n# Kullanicidan not al (try/except ile)\n# Sonucu JSON dosyaya kaydet',
          language: 'python',
          validation: ProjectValidation(
            mustContain: ['class Ogrenci', 'def ortalama_hesapla', 'try', 'except', 'json.dump'],
          ),
          descriptionEn: 'Design a Student class (name, grades, calculate_average method). Safely read grades from the user with try/except, calculate the average, and save the result to a JSON file.',
          titleEn: 'Student Grade System',
          xpReward: 90,
        ),
        ExplanationStep(
          id: 'p9_5_summary',
          title: '🎓 ILERI SEVIYE PYTHON\'U TAMAMLADIN!',
          content: '🐍🏆🐍 Temel Python\'dan gercek dunya yazilim tekniklerine gectin ve profesyonel bir proje tamamladin!\n\n✓ try/except ile hata yonetimi\n✓ Hazir kutuphaneleri (random, math, datetime) kullanma\n✓ List/dict comprehension ile kisa kod yazma\n✓ Sinif (class) ve nesne (object) tasarlama\n✓ Hepsini birlestiren bir OOP + dosya projesi\n\nBu becerilerle artik kendi oyunlarini, veri analiz araclarini ya da otomasyon scriptlerini yazabilirsin. Yazilim muhendisligi yolculugun cok daha ileri bir seviyede devam ediyor!',
          tipEmoji: '🏆',
          tip: 'Ileri Seviye Python Muhendisi rozetini kazandin - bir sonraki hedefin kendi ozgun projeni tasarlamak!',
          titleEn: '🎓 YOU COMPLETED ADVANCED PYTHON!',
          contentEn: '🐍🏆🐍 You went from basic Python to real-world software techniques and finished a professional project!\n\n✓ Handling errors with try/except\n✓ Using built-in libraries (random, math, datetime)\n✓ Writing shorter code with list/dict comprehension\n✓ Designing classes and objects\n✓ An OOP + file project that combines it all\n\nWith these skills you can now write your own games, data analysis tools, or automation scripts. Your software engineering journey continues at a much more advanced level!',
          tipEn: 'You earned the Advanced Python Engineer badge - your next goal is designing your own original project!',
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
      ...module9,
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
      case 9:
        return module9;
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
    LessonBadge(
      id: 'error_handler',
      name: 'Hata Yoneticisi',
      description: 'try/except ile programini cokmekten korudun!',
      emoji: '🛡️',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
      nameEn: 'Error Handler',
      descriptionEn: 'You protected your program from crashing with try/except!',
    ),
    LessonBadge(
      id: 'module_master',
      name: 'Kutuphane Ustasi',
      description: 'import ile Python\'un hazir kutuphanelerini kullandin!',
      emoji: '📦',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
      nameEn: 'Library Master',
      descriptionEn: 'You used Python\'s built-in libraries with import!',
    ),
    LessonBadge(
      id: 'comprehension_pro',
      name: 'Comprehension Ustasi',
      description: 'List ve dict comprehension ile kisa kod yazdin!',
      emoji: '⚡',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
      nameEn: 'Comprehension Pro',
      descriptionEn: 'You wrote shorter code with list and dict comprehensions!',
    ),
    LessonBadge(
      id: 'oop_beginner',
      name: 'OOP Cirak',
      description: 'class ve nesne kavramlarini ogrenip ilk sinifini yazdin!',
      emoji: '🏗️',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
      nameEn: 'OOP Apprentice',
      descriptionEn: 'You learned classes and objects and wrote your first class!',
    ),
    LessonBadge(
      id: 'python_advanced_engineer',
      name: 'Ileri Seviye Python Muhendisi',
      description: 'OOP + hata yonetimi + dosya islemlerini birlestiren final projeyi tamamladin!',
      emoji: '🐍',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.course,
      nameEn: 'Advanced Python Engineer',
      descriptionEn: 'You completed a final project combining OOP, error handling, and file I/O!',
    ),
  ];
}
