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

  /// Get all HTML lessons
  static List<InteractiveLesson> getHtmlInteractiveLessons() {
    return [
      ...module1,
      ...module2,
    ];
  }

  /// Get lessons for a specific module
  static List<InteractiveLesson> getLessonsForModule(int moduleNumber) {
    switch (moduleNumber) {
      case 1:
        return module1;
      case 2:
        return module2;
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
      description: 'Baslik ve paragrafta uzmanlaştin!',
      emoji: '📝',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
  ];
}
