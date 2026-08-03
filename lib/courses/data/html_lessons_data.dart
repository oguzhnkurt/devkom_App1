import '../models/interactive_lesson_model.dart';

/// HTML Course - Interactive lessons for web development
/// Learn HTML from scratch - structure, tags, and semantic markup
class HtmlLessonsData {
  // ==========================================
  // MODULE 1: HTML'E GİRİŞ
  // ==========================================
  static final List<InteractiveLesson> module1 = [
    // LESSON 1.1: HTML Nedir?
    InteractiveLesson(
      id: 'html_1_1',
      courseId: 'html',
      title: 'HTML\'e Hos Geldin!',
      subtitle: 'Web sayfalarinin iskelet yapisi',
      order: 1,
      xpReward: 50,
      badge: 'html_starter',
      steps: [
        IntroStep(
          id: 'h1_1_intro',
          mascotEmoji: '🌐',
          mascotMessage: 'Merhaba! HTML ile web sayfalarinin temelini olusturacaksin!',
          highlights: [
            'Web sayfalarinin temeli',
            'Etiketlerle calis',
            'Anlamli icerikyap',
          ],
        ),

        ExplanationStep(
          id: 'h1_1_exp1',
          title: 'HTML Nedir?',
          content: 'HTML (HyperText Markup Language), web sayfalarinin iskelet yapisini olusturur.\n\nHer web sayfasi HTML ile yapilir!\n\nHTML etiketlerle calisir:\n<h1>Baslik</h1>\n<p>Paragraf</p>',
          tipEmoji: '💡',
          tip: 'HTML bir programlama dili degil, isaretleme dilidir!',
        ),

        MultipleChoiceStep(
          id: 'h1_1_q1',
          question: 'HTML ne anlama gelir?',
          options: [
            ChoiceOption(text: 'HyperText Markup Language', emoji: '✅'),
            ChoiceOption(text: 'High Tech Modern Language', emoji: '❌'),
            ChoiceOption(text: 'Home Tool Markup Language', emoji: '❌'),
            ChoiceOption(text: 'HyperText Making Language', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'HTML = HyperText Markup Language (Hiper Metin Isaretleme Dili)',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'h1_1_exp2',
          title: 'Etiketler (Tags)',
          content: 'HTML etiketlerle calisir:\n\n<etiket>icerik</etiket>\n\nAcilis etiketi: <p>\nKapanis etiketi: </p>\n\nOrnek:\n<h1>Merhaba Dunya!</h1>\n<p>Bu bir paragraf.</p>',
        ),

        MultipleChoiceStep(
          id: 'h1_1_q2',
          question: 'Dogru HTML etiketi hangisi?',
          options: [
            ChoiceOption(text: '<p>Metin</p>', emoji: '✅'),
            ChoiceOption(text: '<p>Metin<p>', emoji: '❌'),
            ChoiceOption(text: '(p)Metin(/p)', emoji: '❌'),
            ChoiceOption(text: '[p]Metin[/p]', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'HTML etiketleri < > isaretleri icinde yazilir ve / ile kapatilir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'h1_1_summary',
          title: 'HTML Baslangic!',
          content: '🌐 HTML\'e ilk adimi attin!\n\n✓ HTML nedir ogrendin\n✓ Etiketleri tandin\n✓ Temel yapiy bildin\n\nSonraki: Ilk HTML sayfan!',
          tipEmoji: '🏆',
          tip: 'HTML Baslangic rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.2: İlk HTML Sayfası
    InteractiveLesson(
      id: 'html_1_2',
      courseId: 'html',
      title: 'Ilk HTML Sayfan',
      subtitle: 'Temel HTML yapisini olustur',
      order: 2,
      xpReward: 60,
      badge: 'first_page',
      steps: [
        IntroStep(
          id: 'h1_2_intro',
          mascotEmoji: '📄',
          mascotMessage: 'Simdi ilk web sayfani olusturacagiz! Her HTML sayfasinin olmasi gereken temel yapiyi ogreneceksin.',
        ),

        ExplanationStep(
          id: 'h1_2_exp1',
          title: 'HTML Belgesi Yapisi',
          content: 'Her HTML sayfasi su yapiyla baslar:\n\n<!DOCTYPE html>\n<html>\n  <head>\n    <title>Baslik</title>\n  </head>\n  <body>\n    Icerik buraya\n  </body>\n</html>',
          tipEmoji: '📐',
          tip: 'DOCTYPE tarayiciya HTML5 kullanildigini soyler!',
        ),

        MultipleChoiceStep(
          id: 'h1_2_q1',
          question: 'Sayfanin gornen icerigi nerede yer alir?',
          options: [
            ChoiceOption(text: '<body> etiketi icinde', emoji: '✅'),
            ChoiceOption(text: '<head> etiketi icinde', emoji: '❌'),
            ChoiceOption(text: '<title> etiketi icinde', emoji: '❌'),
            ChoiceOption(text: '<!DOCTYPE> icinde', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '<body> etiketi sayfada gorunen tum icerigi barindirir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'h1_2_exp2',
          title: '<head> vs <body>',
          content: '<head>: Sayfa hakkinda bilgiler (baslik, meta vb.)\n<body>: Sayfanin gornen icerigi\n\nOrnek:\n<head>\n  <title>Benim Sitem</title>\n</head>\n<body>\n  <h1>Hosgeldiniz!</h1>\n  <p>Bu benim siteim.</p>\n</body>',
        ),

        TypeCodeStep(
          id: 'h1_2_type1',
          instruction: 'Baslik "Merhaba" olan basit bir HTML sayfasi yaz:',
          targetCode: '<!DOCTYPE html>\n<html>\n  <head>\n    <title>Merhaba</title>\n  </head>\n  <body>\n    <h1>Merhaba Dunya!</h1>\n  </body>\n</html>',
          language: 'html',
          hints: [
            '<!DOCTYPE html> ile basla',
            '<html>, <head>, <body> etiketlerini kullan',
            '<title> ve <h1> ekle',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'h1_2_summary',
          title: 'Ilk Sayfa Tamamlandi!',
          content: '📄 Ilk HTML sayfani olusturdun!\n\n✓ Temel yapi ogrendin\n✓ head ve body ayirdin\n✓ Baslik ekledin\n\nArtik web gelistiricisin!',
          tipEmoji: '🏆',
          tip: 'Ilk Sayfa rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 2: METİN ETİKETLERİ
  // ==========================================
  static final List<InteractiveLesson> module2 = [
    // LESSON 2.1: Başlıklar ve Paragraflar
    InteractiveLesson(
      id: 'html_2_1',
      courseId: 'html',
      title: 'Basliklar ve Paragraflar',
      subtitle: 'Metin yapisini olustur',
      order: 3,
      xpReward: 70,
      badge: 'text_master',
      steps: [
        IntroStep(
          id: 'h2_1_intro',
          mascotEmoji: '📝',
          mascotMessage: 'Web sayfalarinda metin olusturmak icin ozel etiketler var! Basliklardan paragraflara kadar hepsini ogrenelim!',
        ),

        ExplanationStep(
          id: 'h2_1_exp1',
          title: 'Baslik Etiketleri',
          content: 'HTML\'de 6 seviye baslik var:\n\n<h1>En buyuk baslik</h1>\n<h2>Ikinci seviye</h2>\n<h3>Ucuncu seviye</h3>\n<h4>Dorduncu seviye</h4>\n<h5>Besinci seviye</h5>\n<h6>En kucuk baslik</h6>\n\nh1 en buyuk, h6 en kucuk!',
          tipEmoji: '📏',
          tip: 'Her sayfada sadece bir <h1> kullanmalisin!',
        ),

        MultipleChoiceStep(
          id: 'h2_1_q1',
          question: 'En buyuk baslik etiketi hangisi?',
          options: [
            ChoiceOption(text: '<h1>', emoji: '✅'),
            ChoiceOption(text: '<h6>', emoji: '❌'),
            ChoiceOption(text: '<heading>', emoji: '❌'),
            ChoiceOption(text: '<title>', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '<h1> en buyuk baslik etiketidir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'h2_1_exp2',
          title: 'Paragraf Etiketi',
          content: 'Metin paragraflari icin <p> etiketi kullanilir:\n\n<p>Bu bir paragraf.</p>\n<p>Bu baska bir paragraf.</p>\n\nHer <p> yeni bir paragraf olusturur!',
        ),

        TypeCodeStep(
          id: 'h2_1_type1',
          instruction: 'h1 baslik ve iki paragraf iceren HTML kodu yaz:',
          targetCode: '<h1>Benim Blogum</h1>\n<p>Birinci paragraf.</p>\n<p>Ikinci paragraf.</p>',
          language: 'html',
          hints: [
            '<h1> ile baslik yaz',
            'Iki adet <p> paragraf ekle',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'h2_1_summary',
          title: 'Metin Ustasi!',
          content: '📝 Metin etiketlerini ogrendin!\n\n✓ 6 baslik seviyesi\n✓ Paragraf olusturma\n✓ Yapisal metin\n\nSonraki: Metin bicmlendirme!',
          tipEmoji: '🏆',
          tip: 'Metin Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 3: BAĞLANTI VE GÖRSELLER
  // ==========================================
  static final List<InteractiveLesson> module3 = [
    // LESSON 3.1: Bağlantılar
    InteractiveLesson(
      id: 'html_3_1',
      courseId: 'html',
      title: 'Baglantilar (Linkler)',
      titleEn: 'Links',
      subtitle: 'Sayfalari birbirine bagla',
      subtitleEn: 'Connect pages to each other',
      order: 4,
      xpReward: 70,
      badge: 'link_master',
      steps: [
        IntroStep(
          id: 'h3_1_intro',
          mascotEmoji: '🔗',
          mascotMessage: 'Web\'i "web" yapan sey baglantilardir! Simdi sayfalari birbirine baglamayi ogrenelim.',
          mascotMessageEn: 'Links are what make the web a "web"! Let\'s learn how to connect pages together.',
          highlights: [
            '<a> etiketi',
            'href ozelligi',
            'Yeni sekmede acma',
          ],
          highlightsEn: [
            'The <a> tag',
            'The href attribute',
            'Opening in a new tab',
          ],
        ),

        ExplanationStep(
          id: 'h3_1_exp1',
          title: 'Baglanti Etiketi <a>',
          titleEn: 'The Link Tag <a>',
          content: 'Baglanti olusturmak icin <a> etiketi kullanilir:\n\n<a href="https://devkom.com.tr">DevKom</a>\n\nhref: Gidilecek adres\nEtiket icindeki metin: Tiklanabilir yazi',
          contentEn: 'Use the <a> tag to create a link:\n\n<a href="https://devkom.com.tr">DevKom</a>\n\nhref: the destination address\nThe text inside the tag: the clickable text',
          tipEmoji: '💡',
          tip: '"a" kelimesi "anchor" (capa) anlamina gelir!',
          tipEn: 'The letter "a" stands for "anchor"!',
        ),

        MultipleChoiceStep(
          id: 'h3_1_q1',
          question: 'Baglantinin gidecegi adresi hangi ozellik belirler?',
          questionEn: 'Which attribute defines where a link goes?',
          options: [
            ChoiceOption(text: 'href', textEn: 'href', emoji: '✅'),
            ChoiceOption(text: 'src', textEn: 'src', emoji: '❌'),
            ChoiceOption(text: 'link', textEn: 'link', emoji: '❌'),
            ChoiceOption(text: 'url', textEn: 'url', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'href (hypertext reference) baglantinin hedef adresini belirtir!',
          explanationEn: 'href (hypertext reference) specifies the link\'s target address!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'h3_1_exp2',
          title: 'Yeni Sekmede Acma',
          titleEn: 'Opening in a New Tab',
          content: 'Baglantinin yeni sekmede acilmasi icin target="_blank" eklenir:\n\n<a href="https://devkom.com.tr" target="_blank">DevKom</a>\n\nBoylece kullanici senin sitenden ayrilmaz!',
          contentEn: 'Add target="_blank" to open a link in a new tab:\n\n<a href="https://devkom.com.tr" target="_blank">DevKom</a>\n\nThis way the user does not leave your site!',
        ),

        MultipleChoiceStep(
          id: 'h3_1_q2',
          question: 'Baglantiyi yeni sekmede acmak icin ne eklenir?',
          questionEn: 'What do you add to open a link in a new tab?',
          options: [
            ChoiceOption(text: 'target="_blank"', textEn: 'target="_blank"', emoji: '✅'),
            ChoiceOption(text: 'new="tab"', textEn: 'new="tab"', emoji: '❌'),
            ChoiceOption(text: 'open="new"', textEn: 'open="new"', emoji: '❌'),
            ChoiceOption(text: 'window="new"', textEn: 'window="new"', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'target="_blank" baglantiyi yeni bir sekmede acar!',
          explanationEn: 'target="_blank" opens the link in a new tab!',
          xpReward: 10,
        ),

        TypeCodeStep(
          id: 'h3_1_type1',
          instruction: 'Yeni sekmede acilan, "DevKom" yazan bir baglanti yaz:',
          instructionEn: 'Write a link that says "DevKom" and opens in a new tab:',
          targetCode: '<a href="https://devkom.com.tr" target="_blank">DevKom</a>',
          language: 'html',
          hints: [
            '<a> etiketi ile basla',
            'href ozelligine adresi yaz',
            'target="_blank" ekle',
          ],
          hintsEn: [
            'Start with the <a> tag',
            'Put the address in the href attribute',
            'Add target="_blank"',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'h3_1_summary',
          title: 'Baglanti Ustasi!',
          titleEn: 'Link Master!',
          content: '🔗 Baglantilari ogrendin!\n\n✓ <a> etiketi\n✓ href ozelligi\n✓ Yeni sekmede acma\n\nSonraki: Gorseller!',
          contentEn: '🔗 You have learned links!\n\n✓ The <a> tag\n✓ The href attribute\n✓ Opening in a new tab\n\nNext: Images!',
          tipEmoji: '🏆',
          tip: 'Baglanti Ustasi rozetini kazandin!',
          tipEn: 'You earned the Link Master badge!',
        ),
      ],
    ),

    // LESSON 3.2: Görseller
    InteractiveLesson(
      id: 'html_3_2',
      courseId: 'html',
      title: 'Gorseller',
      titleEn: 'Images',
      subtitle: 'Sayfana resim ekle',
      subtitleEn: 'Add pictures to your page',
      order: 5,
      xpReward: 70,
      badge: 'image_master',
      steps: [
        IntroStep(
          id: 'h3_2_intro',
          mascotEmoji: '🖼️',
          mascotMessage: 'Bir resim bin kelimeye bedeldir! Sayfana gorsel eklemeyi ogrenelim.',
          mascotMessageEn: 'A picture is worth a thousand words! Let\'s learn how to add images to your page.',
        ),

        ExplanationStep(
          id: 'h3_2_exp1',
          title: 'Gorsel Etiketi <img>',
          titleEn: 'The Image Tag <img>',
          content: 'Gorsel eklemek icin <img> etiketi kullanilir:\n\n<img src="kedi.jpg" alt="Sevimli kedi">\n\nsrc: Gorselin adresi\nalt: Gorsel yuklenmezse gosterilecek metin\n\n<img> etiketinin kapanisi yoktur!',
          contentEn: 'Use the <img> tag to add an image:\n\n<img src="cat.jpg" alt="A cute cat">\n\nsrc: the image address\nalt: text shown if the image does not load\n\nThe <img> tag has no closing tag!',
          tipEmoji: '♿',
          tip: 'alt ozelligi gorme engelli kullanicilar icin cok onemlidir!',
          tipEn: 'The alt attribute is very important for visually impaired users!',
        ),

        MultipleChoiceStep(
          id: 'h3_2_q1',
          question: 'Gorselin dosya adresini hangi ozellik belirtir?',
          questionEn: 'Which attribute specifies the image file address?',
          options: [
            ChoiceOption(text: 'src', textEn: 'src', emoji: '✅'),
            ChoiceOption(text: 'href', textEn: 'href', emoji: '❌'),
            ChoiceOption(text: 'alt', textEn: 'alt', emoji: '❌'),
            ChoiceOption(text: 'file', textEn: 'file', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'src (source = kaynak) gorselin nerede oldugunu belirtir!',
          explanationEn: 'src (source) specifies where the image is located!',
          xpReward: 10,
        ),

        MultipleChoiceStep(
          id: 'h3_2_q2',
          question: 'alt ozelligi ne ise yarar?',
          questionEn: 'What is the alt attribute for?',
          options: [
            ChoiceOption(text: 'Gorsel yuklenmezse metin gosterir ve erisilebilirlik saglar', textEn: 'Shows text if the image fails to load and provides accessibility', emoji: '✅'),
            ChoiceOption(text: 'Gorseli buyutur', textEn: 'Enlarges the image', emoji: '❌'),
            ChoiceOption(text: 'Gorseli renklendirir', textEn: 'Colors the image', emoji: '❌'),
            ChoiceOption(text: 'Gorseli siler', textEn: 'Deletes the image', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'alt metni hem hata durumunda hem de ekran okuyucular icin kullanilir!',
          explanationEn: 'The alt text is used both on error and by screen readers!',
          xpReward: 10,
        ),

        TypeCodeStep(
          id: 'h3_2_type1',
          instruction: 'robot.png dosyasini "Robot resmi" alt metniyle ekle:',
          instructionEn: 'Add the file robot.png with the alt text "Robot picture":',
          targetCode: '<img src="robot.png" alt="Robot resmi">',
          language: 'html',
          hints: [
            '<img etiketi ile basla',
            'src ve alt ozelliklerini kullan',
            'Kapanis etiketi gerekmez',
          ],
          hintsEn: [
            'Start with the <img tag',
            'Use the src and alt attributes',
            'No closing tag is needed',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'h3_2_summary',
          title: 'Gorsel Ustasi!',
          titleEn: 'Image Master!',
          content: '🖼️ Gorselleri ogrendin!\n\n✓ <img> etiketi\n✓ src ve alt\n✓ Erisilebilirlik\n\nSonraki: Listeler!',
          contentEn: '🖼️ You have learned images!\n\n✓ The <img> tag\n✓ src and alt\n✓ Accessibility\n\nNext: Lists!',
          tipEmoji: '🏆',
          tip: 'Gorsel Ustasi rozetini kazandin!',
          tipEn: 'You earned the Image Master badge!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 4: LİSTELER VE TABLOLAR
  // ==========================================
  static final List<InteractiveLesson> module4 = [
    // LESSON 4.1: Listeler
    InteractiveLesson(
      id: 'html_4_1',
      courseId: 'html',
      title: 'Listeler',
      titleEn: 'Lists',
      subtitle: 'Sirali ve sirasiz listeler',
      subtitleEn: 'Ordered and unordered lists',
      order: 6,
      xpReward: 70,
      badge: 'list_master',
      steps: [
        IntroStep(
          id: 'h4_1_intro',
          mascotEmoji: '📋',
          mascotMessage: 'Alisveris listesi, yemek tarifi, siralamalar... Listeler her yerde! HTML\'de nasil yapildigini ogrenelim.',
          mascotMessageEn: 'Shopping lists, recipes, rankings... Lists are everywhere! Let\'s learn how to build them in HTML.',
          highlights: [
            'Sirasiz liste <ul>',
            'Sirali liste <ol>',
            'Liste ogesi <li>',
          ],
          highlightsEn: [
            'Unordered list <ul>',
            'Ordered list <ol>',
            'List item <li>',
          ],
        ),

        ExplanationStep(
          id: 'h4_1_exp1',
          title: 'Sirasiz Liste <ul>',
          titleEn: 'Unordered List <ul>',
          content: 'Sira onemli degilse <ul> (unordered list) kullanilir:\n\n<ul>\n  <li>Elma</li>\n  <li>Armut</li>\n  <li>Muz</li>\n</ul>\n\nHer madde nokta (•) ile gosterilir.',
          contentEn: 'When order does not matter, use <ul> (unordered list):\n\n<ul>\n  <li>Apple</li>\n  <li>Pear</li>\n  <li>Banana</li>\n</ul>\n\nEach item is shown with a bullet (•).',
          tipEmoji: '💡',
          tip: 'li = list item (liste ogesi)',
          tipEn: 'li = list item',
        ),

        ExplanationStep(
          id: 'h4_1_exp2',
          title: 'Sirali Liste <ol>',
          titleEn: 'Ordered List <ol>',
          content: 'Sira onemliyse <ol> (ordered list) kullanilir:\n\n<ol>\n  <li>Suyu kaynat</li>\n  <li>Makarnayi at</li>\n  <li>10 dakika pisir</li>\n</ol>\n\nHer madde numarali gosterilir: 1, 2, 3...',
          contentEn: 'When order matters, use <ol> (ordered list):\n\n<ol>\n  <li>Boil the water</li>\n  <li>Add the pasta</li>\n  <li>Cook for 10 minutes</li>\n</ol>\n\nEach item is numbered: 1, 2, 3...',
        ),

        MultipleChoiceStep(
          id: 'h4_1_q1',
          question: 'Yemek tarifi adimlarini yazmak icin hangi etiket daha uygundur?',
          questionEn: 'Which tag is more suitable for writing recipe steps?',
          options: [
            ChoiceOption(text: '<ol> (sirali liste)', textEn: '<ol> (ordered list)', emoji: '✅'),
            ChoiceOption(text: '<ul> (sirasiz liste)', textEn: '<ul> (unordered list)', emoji: '❌'),
            ChoiceOption(text: '<p> (paragraf)', textEn: '<p> (paragraph)', emoji: '❌'),
            ChoiceOption(text: '<h1> (baslik)', textEn: '<h1> (heading)', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Tarifte sira onemlidir, bu yuzden numarali <ol> kullanilir!',
          explanationEn: 'Order matters in a recipe, so the numbered <ol> is used!',
          xpReward: 10,
        ),

        MultipleChoiceStep(
          id: 'h4_1_q2',
          question: 'Liste icindeki her bir madde hangi etiketle yazilir?',
          questionEn: 'Which tag is used for each item inside a list?',
          options: [
            ChoiceOption(text: '<li>', textEn: '<li>', emoji: '✅'),
            ChoiceOption(text: '<item>', textEn: '<item>', emoji: '❌'),
            ChoiceOption(text: '<list>', textEn: '<list>', emoji: '❌'),
            ChoiceOption(text: '<p>', textEn: '<p>', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Hem <ul> hem <ol> icinde maddeler <li> ile yazilir!',
          explanationEn: 'Items inside both <ul> and <ol> are written with <li>!',
          xpReward: 10,
        ),

        TypeCodeStep(
          id: 'h4_1_type1',
          instruction: 'Uc favori renginden olusan sirasiz bir liste yaz:',
          instructionEn: 'Write an unordered list of your three favorite colors:',
          targetCode: '<ul>\n  <li>Mavi</li>\n  <li>Kirmizi</li>\n  <li>Yesil</li>\n</ul>',
          language: 'html',
          hints: [
            '<ul> ile basla',
            'Her renk icin bir <li> ekle',
            '</ul> ile kapat',
          ],
          hintsEn: [
            'Start with <ul>',
            'Add one <li> per color',
            'Close with </ul>',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'h4_1_summary',
          title: 'Liste Ustasi!',
          titleEn: 'List Master!',
          content: '📋 Listeleri ogrendin!\n\n✓ <ul> sirasiz liste\n✓ <ol> sirali liste\n✓ <li> liste ogesi\n\nSonraki: Tablolar!',
          contentEn: '📋 You have learned lists!\n\n✓ <ul> unordered list\n✓ <ol> ordered list\n✓ <li> list item\n\nNext: Tables!',
          tipEmoji: '🏆',
          tip: 'Liste Ustasi rozetini kazandin!',
          tipEn: 'You earned the List Master badge!',
        ),
      ],
    ),

    // LESSON 4.2: Tablolar
    InteractiveLesson(
      id: 'html_4_2',
      courseId: 'html',
      title: 'Tablolar',
      titleEn: 'Tables',
      subtitle: 'Satir ve sutunlarla veri goster',
      subtitleEn: 'Show data in rows and columns',
      order: 7,
      xpReward: 80,
      badge: 'table_master',
      steps: [
        IntroStep(
          id: 'h4_2_intro',
          mascotEmoji: '📊',
          mascotMessage: 'Ders programi, fiyat listesi, puan tablosu... Tablolar veriyi duzenli gostermenin en iyi yoludur!',
          mascotMessageEn: 'Class schedules, price lists, score tables... Tables are the best way to present data neatly!',
        ),

        ExplanationStep(
          id: 'h4_2_exp1',
          title: 'Tablo Yapisi',
          titleEn: 'Table Structure',
          content: 'Bir tablo su etiketlerden olusur:\n\n<table>  : Tablonun kendisi\n<tr>     : Satir (table row)\n<th>     : Baslik hucresi (table header)\n<td>     : Veri hucresi (table data)\n\nOrnek:\n<table>\n  <tr>\n    <th>Ad</th>\n    <th>Yas</th>\n  </tr>\n  <tr>\n    <td>Ali</td>\n    <td>12</td>\n  </tr>\n</table>',
          contentEn: 'A table is made of these tags:\n\n<table>  : the table itself\n<tr>     : table row\n<th>     : table header cell\n<td>     : table data cell\n\nExample:\n<table>\n  <tr>\n    <th>Name</th>\n    <th>Age</th>\n  </tr>\n  <tr>\n    <td>Ali</td>\n    <td>12</td>\n  </tr>\n</table>',
          tipEmoji: '📐',
          tip: 'Her satir <tr> ile baslar, icine hucreler yazilir!',
          tipEn: 'Every row starts with <tr>, and cells go inside it!',
        ),

        MultipleChoiceStep(
          id: 'h4_2_q1',
          question: 'Tablodaki bir satiri hangi etiket olusturur?',
          questionEn: 'Which tag creates a row in a table?',
          options: [
            ChoiceOption(text: '<tr>', textEn: '<tr>', emoji: '✅'),
            ChoiceOption(text: '<td>', textEn: '<td>', emoji: '❌'),
            ChoiceOption(text: '<th>', textEn: '<th>', emoji: '❌'),
            ChoiceOption(text: '<row>', textEn: '<row>', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '<tr> = table row (tablo satiri)!',
          explanationEn: '<tr> = table row!',
          xpReward: 10,
        ),

        MultipleChoiceStep(
          id: 'h4_2_q2',
          question: '<th> ile <td> arasindaki fark nedir?',
          questionEn: 'What is the difference between <th> and <td>?',
          options: [
            ChoiceOption(text: '<th> baslik hucresi, <td> normal veri hucresidir', textEn: '<th> is a header cell, <td> is a normal data cell', emoji: '✅'),
            ChoiceOption(text: 'Ikisi tamamen aynidir', textEn: 'They are exactly the same', emoji: '❌'),
            ChoiceOption(text: '<th> sadece sayilar icindir', textEn: '<th> is only for numbers', emoji: '❌'),
            ChoiceOption(text: '<td> tablo disinda kullanilir', textEn: '<td> is used outside tables', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '<th> icerigi genelde kalin ve ortali gosterilir, cunku basliktir!',
          explanationEn: 'The content of <th> is usually bold and centered because it is a header!',
          xpReward: 10,
        ),

        OrderingStep(
          id: 'h4_2_order1',
          instruction: 'Tablo etiketlerini ic ice olacak sekilde dogru sirala (distan ice):',
          instructionEn: 'Order the table tags correctly from outermost to innermost:',
          context: 'Bir tablonun yapisi',
          contextEn: 'The structure of a table',
          items: [
            OrderItem(id: 'o1', content: '<table>', contentEn: '<table>', isCode: true),
            OrderItem(id: 'o2', content: '<tr>', contentEn: '<tr>', isCode: true),
            OrderItem(id: 'o3', content: '<td>', contentEn: '<td>', isCode: true),
          ],
          correctOrder: ['o1', 'o2', 'o3'],
          xpReward: 15,
        ),

        TypeCodeStep(
          id: 'h4_2_type1',
          instruction: 'Baslik satiri "Ad" ve "Yas" olan basit bir tablo yaz:',
          instructionEn: 'Write a simple table with a header row of "Name" and "Age":',
          targetCode: '<table>\n  <tr>\n    <th>Ad</th>\n    <th>Yas</th>\n  </tr>\n</table>',
          language: 'html',
          hints: [
            '<table> ile basla',
            'Icine bir <tr> satiri koy',
            'Satirin icine iki <th> ekle',
          ],
          hintsEn: [
            'Start with <table>',
            'Put a <tr> row inside it',
            'Add two <th> cells inside the row',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'h4_2_summary',
          title: 'Tablo Ustasi!',
          titleEn: 'Table Master!',
          content: '📊 Tablolari ogrendin!\n\n✓ <table>, <tr>\n✓ <th> ve <td>\n✓ Ic ice yapi\n\nSonraki: Formlar!',
          contentEn: '📊 You have learned tables!\n\n✓ <table>, <tr>\n✓ <th> and <td>\n✓ Nested structure\n\nNext: Forms!',
          tipEmoji: '🏆',
          tip: 'Tablo Ustasi rozetini kazandin!',
          tipEn: 'You earned the Table Master badge!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 5: FORMLAR
  // ==========================================
  static final List<InteractiveLesson> module5 = [
    // LESSON 5.1: Form Temelleri
    InteractiveLesson(
      id: 'html_5_1',
      courseId: 'html',
      title: 'Form Temelleri',
      titleEn: 'Form Basics',
      subtitle: 'Kullanicidan veri al',
      subtitleEn: 'Collect data from the user',
      order: 8,
      xpReward: 80,
      badge: 'form_starter',
      steps: [
        IntroStep(
          id: 'h5_1_intro',
          mascotEmoji: '📮',
          mascotMessage: 'Giris ekranlari, arama kutulari, anketler... Hepsi form! Simdi kullanicidan veri almayi ogrenelim.',
          mascotMessageEn: 'Login screens, search boxes, surveys... They are all forms! Let\'s learn how to collect data from users.',
          highlights: [
            '<form> etiketi',
            '<input> alanlari',
            '<label> etiketleri',
          ],
          highlightsEn: [
            'The <form> tag',
            '<input> fields',
            '<label> tags',
          ],
        ),

        ExplanationStep(
          id: 'h5_1_exp1',
          title: 'Form ve Input',
          titleEn: 'Form and Input',
          content: 'Form, kullanicidan veri toplayan alandir:\n\n<form>\n  <input type="text" name="ad">\n  <button type="submit">Gonder</button>\n</form>\n\ntype: Girisin turu (text, email, password, number...)\nname: Verinin adi',
          contentEn: 'A form is an area that collects data from the user:\n\n<form>\n  <input type="text" name="name">\n  <button type="submit">Send</button>\n</form>\n\ntype: the kind of input (text, email, password, number...)\nname: the name of the data',
          tipEmoji: '💡',
          tip: '<input> etiketinin de kapanisi yoktur!',
          tipEn: 'The <input> tag also has no closing tag!',
        ),

        MultipleChoiceStep(
          id: 'h5_1_q1',
          question: 'Sifre girisi icin hangi input turu kullanilir?',
          questionEn: 'Which input type is used for a password field?',
          options: [
            ChoiceOption(text: 'type="password"', textEn: 'type="password"', emoji: '✅'),
            ChoiceOption(text: 'type="text"', textEn: 'type="text"', emoji: '❌'),
            ChoiceOption(text: 'type="secret"', textEn: 'type="secret"', emoji: '❌'),
            ChoiceOption(text: 'type="hidden"', textEn: 'type="hidden"', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'type="password" yazilanlari nokta olarak gizler!',
          explanationEn: 'type="password" hides what is typed as dots!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'h5_1_exp2',
          title: 'Etiketler <label>',
          titleEn: 'Labels <label>',
          content: 'Her input\'un ne icin oldugunu <label> ile aciklariz:\n\n<label for="eposta">E-posta:</label>\n<input type="email" id="eposta" name="eposta">\n\nlabel\'in for degeri, input\'un id degeriyle ayni olmalidir!',
          contentEn: 'We explain what each input is for using <label>:\n\n<label for="email">Email:</label>\n<input type="email" id="email" name="email">\n\nThe label\'s for value must match the input\'s id value!',
          tipEmoji: '♿',
          tip: 'label kullanmak erisilebilirlik icin cok onemlidir!',
          tipEn: 'Using labels is very important for accessibility!',
        ),

        MultipleChoiceStep(
          id: 'h5_1_q2',
          question: '<label> etiketinin for degeri neyle eslesmelidir?',
          questionEn: 'What should the for value of a <label> match?',
          options: [
            ChoiceOption(text: 'Input\'un id degeri', textEn: 'The input\'s id value', emoji: '✅'),
            ChoiceOption(text: 'Input\'un type degeri', textEn: 'The input\'s type value', emoji: '❌'),
            ChoiceOption(text: 'Form\'un adi', textEn: 'The form\'s name', emoji: '❌'),
            ChoiceOption(text: 'Sayfanin basligi', textEn: 'The page title', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'for="x" ile id="x" eslesince label\'a tiklaninca input secilir!',
          explanationEn: 'When for="x" matches id="x", clicking the label focuses the input!',
          xpReward: 10,
        ),

        MatchingStep(
          id: 'h5_1_match1',
          instruction: 'Her input turunu dogru kullanim alaniyla eslestir:',
          instructionEn: 'Match each input type with its correct use:',
          pairs: [
            MatchPair(id: 'm1', left: 'type="email"', leftEn: 'type="email"', right: 'E-posta adresi', rightEn: 'Email address', isLeftCode: true),
            MatchPair(id: 'm2', left: 'type="number"', leftEn: 'type="number"', right: 'Sayi girisi', rightEn: 'Number input', isLeftCode: true),
            MatchPair(id: 'm3', left: 'type="checkbox"', leftEn: 'type="checkbox"', right: 'Coktan secim', rightEn: 'Multiple selection', isLeftCode: true),
          ],
          xpReward: 15,
        ),

        TypeCodeStep(
          id: 'h5_1_type1',
          instruction: 'Etiketi "E-posta:" olan bir e-posta giris alani yaz:',
          instructionEn: 'Write an email input field with the label "Email:":',
          targetCode: '<label for="eposta">E-posta:</label>\n<input type="email" id="eposta" name="eposta">',
          language: 'html',
          hints: [
            'Once <label for="..."> yaz',
            'Sonra <input type="email"> ekle',
            'label\'in for degeri ile input\'un id degeri ayni olsun',
          ],
          hintsEn: [
            'First write <label for="...">',
            'Then add <input type="email">',
            'Make the label\'s for match the input\'s id',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'h5_1_summary',
          title: 'Form Baslangic!',
          titleEn: 'Form Starter!',
          content: '📮 Formlari ogrendin!\n\n✓ <form> ve <input>\n✓ input turleri\n✓ <label> ile erisilebilirlik\n\nSonraki: Semantik HTML!',
          contentEn: '📮 You have learned forms!\n\n✓ <form> and <input>\n✓ input types\n✓ Accessibility with <label>\n\nNext: Semantic HTML!',
          tipEmoji: '🏆',
          tip: 'Form Baslangic rozetini kazandin!',
          tipEn: 'You earned the Form Starter badge!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 6: SEMANTİK HTML VE PROJE
  // ==========================================
  static final List<InteractiveLesson> module6 = [
    // LESSON 6.1: Semantik HTML
    InteractiveLesson(
      id: 'html_6_1',
      courseId: 'html',
      title: 'Semantik HTML',
      titleEn: 'Semantic HTML',
      subtitle: 'Anlamli etiketler kullan',
      subtitleEn: 'Use meaningful tags',
      order: 9,
      xpReward: 80,
      badge: 'semantic_master',
      steps: [
        IntroStep(
          id: 'h6_1_intro',
          mascotEmoji: '🏛️',
          mascotMessage: 'Iyi HTML sadece calisan degil, ANLAMLI HTML\'dir! Simdi profesyonellerin kullandigi etiketleri ogrenelim.',
          mascotMessageEn: 'Good HTML is not just working HTML, it is MEANINGFUL HTML! Let\'s learn the tags professionals use.',
        ),

        ExplanationStep(
          id: 'h6_1_exp1',
          title: 'Semantik Nedir?',
          titleEn: 'What Is Semantic?',
          content: 'Semantik = anlamli.\n\nHer seyi <div> ile yapmak yerine, icerigi anlatan etiketler kullaniriz:\n\n<header>  : Sayfa ustu\n<nav>     : Menu / gezinme\n<main>    : Ana icerik\n<article> : Bagimsiz icerik (blog yazisi)\n<footer>  : Sayfa alti\n\nBoylece hem tarayici hem arama motoru hem de ekran okuyucular sayfayi anlar!',
          contentEn: 'Semantic = meaningful.\n\nInstead of building everything with <div>, we use tags that describe the content:\n\n<header>  : top of the page\n<nav>     : menu / navigation\n<main>    : main content\n<article> : standalone content (a blog post)\n<footer>  : bottom of the page\n\nThis way browsers, search engines and screen readers all understand the page!',
          tipEmoji: '🔍',
          tip: 'Semantik HTML, Google aramalarinda daha iyi siralama saglar (SEO)!',
          tipEn: 'Semantic HTML gives better ranking in Google search (SEO)!',
        ),

        MultipleChoiceStep(
          id: 'h6_1_q1',
          question: 'Sayfanin ana menusu icin hangi etiket en uygundur?',
          questionEn: 'Which tag is most suitable for a page\'s main menu?',
          options: [
            ChoiceOption(text: '<nav>', textEn: '<nav>', emoji: '✅'),
            ChoiceOption(text: '<div>', textEn: '<div>', emoji: '❌'),
            ChoiceOption(text: '<menu-bar>', textEn: '<menu-bar>', emoji: '❌'),
            ChoiceOption(text: '<span>', textEn: '<span>', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '<nav> gezinme baglantilari icin ozel olarak tasarlanmistir!',
          explanationEn: '<nav> is specifically designed for navigation links!',
          xpReward: 10,
        ),

        MultipleChoiceStep(
          id: 'h6_1_q2',
          question: 'Neden her sey icin <div> kullanmak kotu bir fikirdir?',
          questionEn: 'Why is using <div> for everything a bad idea?',
          options: [
            ChoiceOption(text: '<div> anlam tasimaz; arama motorlari ve ekran okuyucular icerigi anlayamaz', textEn: '<div> carries no meaning; search engines and screen readers cannot understand the content', emoji: '✅'),
            ChoiceOption(text: '<div> cok yavas calisir', textEn: '<div> is very slow', emoji: '❌'),
            ChoiceOption(text: '<div> artik desteklenmiyor', textEn: '<div> is no longer supported', emoji: '❌'),
            ChoiceOption(text: '<div> sadece resimler icindir', textEn: '<div> is only for images', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '<div> notr bir kutudur. Semantik etiketler ise iceriğin ne oldugunu anlatir!',
          explanationEn: '<div> is a neutral box. Semantic tags describe what the content actually is!',
          xpReward: 10,
        ),

        MatchingStep(
          id: 'h6_1_match1',
          instruction: 'Her semantik etiketi gorevine eslestir:',
          instructionEn: 'Match each semantic tag with its purpose:',
          pairs: [
            MatchPair(id: 's1', left: '<header>', leftEn: '<header>', right: 'Sayfa ustu', rightEn: 'Top of the page', isLeftCode: true),
            MatchPair(id: 's2', left: '<main>', leftEn: '<main>', right: 'Ana icerik', rightEn: 'Main content', isLeftCode: true),
            MatchPair(id: 's3', left: '<footer>', leftEn: '<footer>', right: 'Sayfa alti', rightEn: 'Bottom of the page', isLeftCode: true),
            MatchPair(id: 's4', left: '<nav>', leftEn: '<nav>', right: 'Gezinme menusu', rightEn: 'Navigation menu', isLeftCode: true),
          ],
          xpReward: 20,
        ),

        SpotErrorStep(
          id: 'h6_1_spot1',
          instruction: 'Bu kodda semantik acidan yanlis olan satiri bul:',
          instructionEn: 'Find the semantically incorrect line in this code:',
          code: '<header>\n  <div>Ana Menu</div>\n</header>\n<main>\n  <p>Icerik</p>\n</main>',
          language: 'html',
          errorLine: 2,
          errorDescription: 'Menu icin <div> yerine <nav> kullanilmali',
          errorDescriptionEn: 'A <nav> should be used for the menu instead of <div>',
          correctCode: '<header>\n  <nav>Ana Menu</nav>\n</header>\n<main>\n  <p>Icerik</p>\n</main>',
          explanation: 'Gezinme menusu semantik olarak <nav> etiketiyle isaretlenmelidir!',
          explanationEn: 'A navigation menu should be semantically marked with the <nav> tag!',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'h6_1_summary',
          title: 'Semantik Usta!',
          titleEn: 'Semantic Master!',
          content: '🏛️ Semantik HTML ogrendin!\n\n✓ header, nav, main, footer\n✓ Neden onemli oldugu\n✓ SEO ve erisilebilirlik\n\nSonraki: Final proje!',
          contentEn: '🏛️ You have learned semantic HTML!\n\n✓ header, nav, main, footer\n✓ Why it matters\n✓ SEO and accessibility\n\nNext: The final project!',
          tipEmoji: '🏆',
          tip: 'Semantik Usta rozetini kazandin!',
          tipEn: 'You earned the Semantic Master badge!',
        ),
      ],
    ),

    // LESSON 6.2: Final Proje
    InteractiveLesson(
      id: 'html_6_2',
      courseId: 'html',
      title: 'Final Proje: Kisisel Sayfa',
      titleEn: 'Final Project: Personal Page',
      subtitle: 'Ogrendiklerini birlestir',
      subtitleEn: 'Bring everything together',
      order: 10,
      xpReward: 150,
      badge: 'html_graduate',
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'h6_2_intro',
          mascotEmoji: '🚀',
          mascotMessage: 'Simdi ogrendigin her seyi kullanarak kendi tanitim sayfani yapacaksin! Hazir misin?',
          mascotMessageEn: 'Now you will build your own profile page using everything you have learned! Ready?',
          highlights: [
            'Semantik yapi',
            'Baslik, paragraf, liste',
            'Baglanti ve gorsel',
          ],
          highlightsEn: [
            'Semantic structure',
            'Headings, paragraphs, lists',
            'Links and images',
          ],
        ),

        ExplanationStep(
          id: 'h6_2_exp1',
          title: 'Proje Plani',
          titleEn: 'Project Plan',
          content: 'Kisisel tanitim sayfan su bolumlerden olusacak:\n\n1. <header> : Adin ve kisa tanitim\n2. <nav>    : Bolumlere baglantilar\n3. <main>   : Hakkimda + hobiler listesi\n4. <footer> : Iletisim bilgisi\n\nHer bolumu tek tek yazacagiz!',
          contentEn: 'Your personal page will have these sections:\n\n1. <header> : your name and a short intro\n2. <nav>    : links to sections\n3. <main>   : about me + a hobbies list\n4. <footer> : contact info\n\nWe will write each section one by one!',
        ),

        ProjectStep(
          id: 'h6_2_project',
          title: 'Kisisel Tanitim Sayfasi',
          titleEn: 'Personal Profile Page',
          description: 'Ogrendigin tum HTML etiketlerini kullanarak kendini tanitan bir sayfa olustur. Semantik etiketler kullanmayi unutma!',
          descriptionEn: 'Create a page that introduces yourself using all the HTML tags you have learned. Do not forget to use semantic tags!',
          requirements: [
            '<!DOCTYPE html> ile baslayan tam bir sayfa yapisi',
            '<header> icinde <h1> ile adin',
            '<nav> icinde en az 2 baglanti',
            '<main> icinde bir paragraf ve bir <ul> hobi listesi',
            'En az bir <img> (alt metniyle birlikte)',
            '<footer> icinde iletisim bilgisi',
          ],
          requirementsEn: [
            'A complete page structure starting with <!DOCTYPE html>',
            'Your name in an <h1> inside <header>',
            'At least 2 links inside <nav>',
            'A paragraph and a <ul> hobby list inside <main>',
            'At least one <img> (with alt text)',
            'Contact info inside <footer>',
          ],
          hints: [
            'Once iskeleti kur: html, head, body',
            'Sonra header, nav, main, footer bolumlerini ekle',
            'En son icerikleri doldur',
            'Her gorsele alt metni yazmayi unutma!',
          ],
          hintsEn: [
            'First set up the skeleton: html, head, body',
            'Then add the header, nav, main and footer sections',
            'Fill in the content last',
            'Do not forget alt text on every image!',
          ],
          starterCode: '<!DOCTYPE html>\n<html>\n  <head>\n    <title>Benim Sayfam</title>\n  </head>\n  <body>\n    <!-- Buraya yaz -->\n  </body>\n</html>',
          language: 'html',
          validation: ProjectValidation(
            mustContain: ['<header', '<nav', '<main', '<footer', '<ul', '<img', '<h1'],
          ),
          xpReward: 100,
        ),

        ExplanationStep(
          id: 'h6_2_summary',
          title: 'HTML Kursunu Tamamladin!',
          titleEn: 'You Completed the HTML Course!',
          content: '🎓 Tebrikler! Artik HTML biliyorsun!\n\n✓ Etiketler ve yapi\n✓ Metin, baglanti, gorsel\n✓ Liste, tablo, form\n✓ Semantik HTML\n✓ Gercek bir proje\n\nSonraki adim: CSS ile bu sayfayi guzellestir!',
          contentEn: '🎓 Congratulations! You now know HTML!\n\n✓ Tags and structure\n✓ Text, links, images\n✓ Lists, tables, forms\n✓ Semantic HTML\n✓ A real project\n\nNext step: make this page beautiful with CSS!',
          tipEmoji: '🏆',
          tip: 'HTML Mezunu rozetini kazandin!',
          tipEn: 'You earned the HTML Graduate badge!',
        ),
      ],
    ),
  ];

  /// Get all HTML lessons
  static List<InteractiveLesson> getHtmlInteractiveLessons() {
    return [
      ...module1,
      ...module2,
      ...module3,
      ...module4,
      ...module5,
      ...module6,
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
      default:
        return [];
    }
  }
}

/// HTML badges
class HtmlBadges {
  static const List<LessonBadge> all = [
    LessonBadge(
      id: 'html_starter',
      name: 'HTML Baslangic',
      description: 'HTML dunyasina adim attin!',
      emoji: '🌐',
      rarity: BadgeRarity.common,
      category: BadgeCategory.lesson,
    ),
    LessonBadge(
      id: 'first_page',
      name: 'Ilk Sayfa',
      description: 'Ilk HTML sayfani olusturdun!',
      emoji: '📄',
      rarity: BadgeRarity.common,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'text_master',
      name: 'Metin Ustasi',
      nameEn: 'Text Master',
      description: 'Baslik ve paragrafta uzmanlaştin!',
      descriptionEn: 'You mastered headings and paragraphs!',
      emoji: '📝',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'link_master',
      name: 'Baglanti Ustasi',
      nameEn: 'Link Master',
      description: 'Sayfalari birbirine baglamayi ogrendin!',
      descriptionEn: 'You learned how to connect pages together!',
      emoji: '🔗',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'image_master',
      name: 'Gorsel Ustasi',
      nameEn: 'Image Master',
      description: 'Sayfana gorsel eklemeyi ogrendin!',
      descriptionEn: 'You learned how to add images to your page!',
      emoji: '🖼️',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'list_master',
      name: 'Liste Ustasi',
      nameEn: 'List Master',
      description: 'Sirali ve sirasiz listeleri ogrendin!',
      descriptionEn: 'You learned ordered and unordered lists!',
      emoji: '📋',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'table_master',
      name: 'Tablo Ustasi',
      nameEn: 'Table Master',
      description: 'Veriyi tablolarla duzenlemeyi ogrendin!',
      descriptionEn: 'You learned how to organize data with tables!',
      emoji: '📊',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'form_starter',
      name: 'Form Baslangic',
      nameEn: 'Form Starter',
      description: 'Kullanicidan veri almayi ogrendin!',
      descriptionEn: 'You learned how to collect data from users!',
      emoji: '📮',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'semantic_master',
      name: 'Semantik Usta',
      nameEn: 'Semantic Master',
      description: 'Anlamli HTML yazmayi ogrendin!',
      descriptionEn: 'You learned to write meaningful HTML!',
      emoji: '🏛️',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'html_graduate',
      name: 'HTML Mezunu',
      nameEn: 'HTML Graduate',
      description: 'HTML kursunu bastan sona tamamladin!',
      descriptionEn: 'You completed the entire HTML course!',
      emoji: '🎓',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.course,
    ),
  ];
}
