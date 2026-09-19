/// DevAI Chat asistanının sabit bilgi tabanı.
///
/// Neden sabit: uygulama 4-12 yaş aralığındaki çocuklara yönelik ve App Store'da
/// 4+ derecelendirmesiyle Eğitim kategorisinde. Serbest metinli bir dil modeli
/// (LLM) ne üreteceği önceden bilinemeyen içerik anlamına geliyor; Apple'ın
/// güncellenmiş yaş derecelendirme rehberi chatbot/AI çıktılarının derecelendirmeyi
/// etkilediğini söylüyor ve 4.7.5 chatbot içeren uygulamalardan yaş kısıtlama
/// mekanizması istiyor. Ayrıca çocuğun yazdığı metnin üçüncü tarafa gönderilmesi
/// gizlilik açısından ek yük getiriyordu.
///
/// Bu yüzden asistan, elle yazılmış ve gözden geçirilmiş cevaplardan oluşuyor.
/// Yeni cevap eklemek için aşağıdaki listeye bir [KnowledgeEntry] eklemek yeterli.
///
/// Dört dil: her kaydın Türkçe, İngilizce, Almanca ve İspanyolca cevabı var.
/// Anahtar kelimeler tek listede tutuluyor ve dördünün terimlerini birlikte
/// içeriyor; `DevAssistantService.normalize` tüm aksanları ASCII'ye indirdiği
/// için "Schleife", "bucle" ve "dongu" aynı listede yan yana durabiliyor.
///
/// Yeni kayıt eklerken iki kural:
///  1. Anahtar kelimeler ASCII küçük harf olmalı (aksanlı anahtar hiç eşleşmez).
///  2. `relatedIds` ile gösterdiğin her kaydın `dev_assistant_service.dart`
///     içindeki dört etiket haritasında da karşılığı olmalı; yoksa öneri
///     düğmesi boş kalır. `test/dev_assistant_service_test.dart` ikisini de
///     kontrol ediyor.
library;

/// Tek bir soru-cevap kaydı.
class KnowledgeEntry {
  /// Kaydı tanımlayan benzersiz anahtar (loglama/test için).
  final String id;

  /// Bu kaydı tetikleyen anahtar kelimeler.
  ///
  /// ÖNEMLİ: Bunlar bilerek Türkçe karaktersiz (ASCII) yazılıyor. Kullanıcının
  /// yazdığı metin de DevAssistantService.normalize ile aynı biçime çevriliyor,
  /// böylece "döngü", "dongu" ve "DÖNGÜ" hepsi eşleşiyor. Buraya "döngü" yazmak
  /// eşleşmeyi bozar.
  final List<String> keywords;

  /// Kullanıcıya gösterilecek cevap.
  ///
  /// Türkçe ve İngilizce zorunlu; Almanca ve İspanyolca eklendikçe doldurulur.
  /// Eksik bir dil istenirse İngilizce, o da yoksa Türkçe cevap dönüyor —
  /// böylece çeviri sırasında ekran hiçbir zaman boş kalmıyor.
  final String answerTr;
  final String answerEn;
  final String? answerDe;
  final String? answerEs;

  /// Cevabın altında önerilecek devam soruları (id listesi).
  final List<String> relatedIds;

  const KnowledgeEntry({
    required this.id,
    required this.keywords,
    required this.answerTr,
    required this.answerEn,
    this.answerDe,
    this.answerEs,
    this.relatedIds = const [],
  });

  /// İstenen dildeki cevabı verir.
  String answerFor(String lang) {
    switch (lang) {
      case 'en':
        return answerEn;
      case 'de':
        return answerDe ?? answerEn;
      case 'es':
        return answerEs ?? answerEn;
      default:
        return answerTr;
    }
  }
}

/// Sohbet başında ve cevap bulunamadığında gösterilen örnek sorular.
const List<String> kSuggestedQuestionsTr = [
  'Scratch nedir?',
  'Python\'a nasıl başlarım?',
  'Arduino ile ne yapabilirim?',
  'XP nasıl kazanırım?',
  'Jetonlar ne işe yarıyor?',
  'Kodum çalışmıyor, ne yapmalıyım?',
  'Nereden başlamalıyım?',
  'Nasıl oyun yaparım?',
  'Yapay zekâ nedir?',
  'Döngü nedir?',
  'Değişken nedir?',
  'mBlock nedir?',
  'Sensör nedir?',
  'Hangi video serileri var?',
  'Bana bilmece sor',
  'Bana şaka yap',
  'Sıkıldım, ne yapsam?',
  'Günde ne kadar çalışmalıyım?',
  'Matematik gerekli mi?',
  'Yazılımcı nasıl olunur?',
  'Satranç taşları nasıl gider?',
  'Turtle ile nasıl çizerim?',
  'Kütüphane nedir?',
  'HTML etiketleri nelerdir?',
  'Akış şeması nedir?',
  'Hangi robot projesini yapayım?',
  'İlerlemem kaydediliyor mu?',
  'Serim bozuldu, ne olur?',
  'Neden reklam çıkıyor?',
  'Quizler nasıl çalışır?',
  'Arduino Atölyesi nasıl kullanılır?',
  'Hata yapmaktan korkuyorum',
  'Bu uygulama nedir?',
  'Bu uygulamayı kim yaptı?',
  'Blok kodlama ne işe yarar?',
  'Yazılım nedir?',
  'Robot nedir?',
  '12 + 7 kaç eder?',
  'Videolar nereden geliyor?',
  'Bilgilerim güvende mi?',
];

const List<String> kSuggestedQuestionsEn = [
  'What is Scratch?',
  'How do I start with Python?',
  'What can I build with Arduino?',
  'How do I earn XP?',
  'What are coins for?',
  'My code does not work, what should I do?',
  'Where do I start?',
  'How do I make a game?',
  'What is artificial intelligence?',
  'What is a loop?',
  'What is a variable?',
  'What is mBlock?',
  'What is a sensor?',
  'Which video series are there?',
  'Ask me a riddle',
  'Tell me a joke',
  'I am bored, what now?',
  'How long should I practise?',
  'Do I need maths?',
  'How do I become a developer?',
  'How do chess pieces move?',
  'How do I draw with turtle?',
  'What is a library?',
  'What are HTML tags?',
  'What is a flowchart?',
  'Which robot project should I build?',
  'Is my progress saved?',
  'I lost my streak, now what?',
  'Why are there ads?',
  'How do the quizzes work?',
  'How does the Arduino Workshop work?',
  'I am afraid of making mistakes',
  'What is this app?',
  'Who made this app?',
  'What is block coding for?',
  'What is software?',
  'What is a robot?',
  'How much is 12 + 7?',
  'Where do the videos come from?',
  'Is my data safe?',
];

const List<String> kSuggestedQuestionsDe = [
  'Was ist Scratch?',
  'Wie fange ich mit Python an?',
  'Was kann ich mit Arduino bauen?',
  'Wie bekomme ich XP?',
  'Wofür sind Münzen da?',
  'Mein Code geht nicht, was soll ich tun?',
  'Womit soll ich anfangen?',
  'Wie baue ich ein Spiel?',
  'Was ist künstliche Intelligenz?',
  'Was ist eine Schleife?',
  'Was ist eine Variable?',
  'Was ist mBlock?',
  'Was ist ein Sensor?',
  'Welche Videoreihen gibt es?',
  'Stell mir ein Rätsel',
  'Erzähl mir einen Witz',
  'Mir ist langweilig, was nun?',
  'Wie lange soll ich täglich üben?',
  'Brauche ich Mathe?',
  'Wie werde ich Programmiererin?',
  'Wie ziehen die Schachfiguren?',
  'Wie zeichne ich mit Turtle?',
  'Was ist eine Bibliothek?',
  'Was sind HTML Tags?',
  'Was ist ein Flussdiagramm?',
  'Welches Roboterprojekt soll ich bauen?',
  'Wird mein Fortschritt gespeichert?',
  'Meine Serie ist weg, was jetzt?',
  'Warum gibt es Werbung?',
  'Wie funktionieren die Quiz?',
  'Wie funktioniert die Arduino-Werkstatt?',
  'Ich habe Angst vor Fehlern',
  'Was ist diese App?',
  'Wer hat diese App gemacht?',
  'Wozu Blockprogrammierung?',
  'Was ist Software?',
  'Was ist ein Roboter?',
  'Wie viel ist 12 + 7?',
  'Woher kommen die Videos?',
  'Sind meine Daten sicher?',
];

const List<String> kSuggestedQuestionsEs = [
  '¿Qué es Scratch?',
  '¿Cómo empiezo con Python?',
  '¿Qué puedo construir con Arduino?',
  '¿Cómo gano XP?',
  '¿Para qué sirven las monedas?',
  'Mi código no funciona, ¿qué hago?',
  '¿Por dónde empiezo?',
  '¿Cómo hago un juego?',
  '¿Qué es la inteligencia artificial?',
  '¿Qué es un bucle?',
  '¿Qué es una variable?',
  '¿Qué es mBlock?',
  '¿Qué es un sensor?',
  '¿Qué series de vídeo hay?',
  'Ponme un acertijo',
  'Cuéntame un chiste',
  'Estoy aburrido, ¿qué hago?',
  '¿Cuánto debo practicar al día?',
  '¿Necesito matemáticas?',
  '¿Cómo llego a ser programadora?',
  '¿Cómo se mueven las piezas de ajedrez?',
  '¿Cómo dibujo con Turtle?',
  '¿Qué es una biblioteca?',
  '¿Qué son las etiquetas HTML?',
  '¿Qué es un diagrama de flujo?',
  '¿Qué proyecto de robot hago?',
  '¿Se guarda mi progreso?',
  'Perdí mi racha, ¿y ahora?',
  '¿Por qué hay anuncios?',
  '¿Cómo funcionan los cuestionarios?',
  '¿Cómo funciona el Taller de Arduino?',
  'Me da miedo equivocarme',
  '¿Qué es esta aplicación?',
  '¿Quién hizo esta app?',
  '¿Para qué sirve programar por bloques?',
  '¿Qué es el software?',
  '¿Qué es un robot?',
  '¿Cuánto es 12 + 7?',
  '¿De dónde vienen los vídeos?',
  '¿Están seguros mis datos?',
];

/// Hiçbir kayıt eşleşmediğinde verilen cevap.
const String kNoMatchAnswerTr =
    'Bunu tam anlayamadım. Sana şu konularda yardımcı olabilirim: Scratch, '
    'Python, HTML, Arduino, robotik, oyunlar, XP ve jetonlar.\n\n'
    'Aşağıdaki önerilerden birine dokunabilir ya da sorunu daha kısa yazabilirsin.';

const String kNoMatchAnswerEn =
    'I could not quite understand that. I can help you with: Scratch, Python, '
    'HTML, Arduino, robotics, games, XP and coins.\n\n'
    'Tap one of the suggestions below, or try asking in a shorter way.';

const String kNoMatchAnswerDe =
    'Das habe ich nicht ganz verstanden. Ich kann dir helfen bei: Scratch, Python, '
    'HTML, Arduino, Robotik, Spielen, XP und Münzen.\n\n'
    'Tippe unten auf einen Vorschlag oder frag mit kürzeren Worten.';

const String kNoMatchAnswerEs =
    'No he entendido eso del todo. Puedo ayudarte con: Scratch, Python, HTML, '
    'Arduino, robótica, juegos, XP y monedas.\n\n'
    'Toca una de las sugerencias de abajo o pregunta con menos palabras.';

/// Eşleşme bulunamadığında verilecek cevabı dile göre seçer.
String kNoMatchAnswerFor(String lang) {
  switch (lang) {
    case 'en':
      return kNoMatchAnswerEn;
    case 'de':
      return kNoMatchAnswerDe;
    case 'es':
      return kNoMatchAnswerEs;
    default:
      return kNoMatchAnswerTr;
  }
}

/// Örnek soru listesini dile göre seçer.
List<String> kSuggestedQuestionsFor(String lang) {
  switch (lang) {
    case 'en':
      return kSuggestedQuestionsEn;
    case 'de':
      return kSuggestedQuestionsDe;
    case 'es':
      return kSuggestedQuestionsEs;
    default:
      return kSuggestedQuestionsTr;
  }
}

/// Bilgi tabanı.
const List<KnowledgeEntry> kKnowledgeBase = [
  // ---------------------------------------------------------------- selamlama
  KnowledgeEntry(
    id: 'greeting',
    keywords: [
      'merhaba',
      'selam',
      'hey',
      'gunaydin',
      'iyi aksamlar',
      'hello',
      'hi',
      'hallo',
      'guten tag',
      'guten morgen',
      'hola',
      'buenos dias',
      'buenas',
    ],
    answerTr:
        'Merhaba! Ben DevAI. Kodlama derslerin, oyunlar ve robotik hakkındaki '
        'sorularında sana yardım ederim. Ne öğrenmek istersin?',
    answerEn:
        'Hi! I am DevAI. I help you with your coding lessons, games and robotics '
        'questions. What would you like to learn?',
    answerDe:
        'Hallo! Ich bin DevAI. Ich helfe dir bei deinen Programmierstunden, '
        'bei Spielen und bei Fragen zur Robotik. Was möchtest du lernen?',
    answerEs:
        '¡Hola! Soy DevAI. Te ayudo con tus lecciones de programación, con '
        'los juegos y con la robótica. ¿Qué te gustaría aprender?',
    relatedIds: ['scratch', 'python', 'arduino'],
  ),
  KnowledgeEntry(
    id: 'who_are_you',
    keywords: [
      'kimsin',
      'nesin',
      'adin ne',
      'sen kimsin',
      'who are you',
      'what are you',
      'wer bist du',
      'quien eres',
      'was bist du',
      'que eres',
    ],
    answerTr:
        'Ben DevAI, DevEducation uygulamasının yardım asistanıyım. Derslerdeki konuları '
        'açıklarım, takıldığın yerlerde ipucu veririm. Cevaplarım uygulamanın '
        'eğitmenleri tarafından hazırlandı.',
    answerEn:
        'I am DevAI, the help assistant inside DevEducation. I explain lesson topics and '
        'give you hints when you get stuck. My answers were written by the app\'s '
        'teachers.',
    answerDe:
        'Ich bin DevAI, der Lernhelfer in DevEducation. Ich erkläre die '
        'Themen aus den Lektionen und gebe dir Tipps, wenn du stecken '
        'bleibst. Meine Antworten haben die Lehrerinnen und Lehrer der App '
        'geschrieben.',
    answerEs:
        'Soy DevAI, el asistente de ayuda dentro de DevEducation. Explico los '
        'temas de las lecciones y te doy pistas cuando te atascas. Mis '
        'respuestas las escribieron los profesores de la app.',
    relatedIds: ['what_can_you_do'],
  ),
  KnowledgeEntry(
    id: 'what_can_you_do',
    keywords: [
      'ne yapabilirsin',
      'nasil yardim',
      'yardim et',
      'ne biliyorsun',
      'help',
      'what can you do',
      'was kannst du',
      'wie kannst du mir helfen',
      'que puedes hacer',
      'como me puedes ayudar',
      'hilfe',
      'ayuda',
      'bana nasil yardim edebilirsin',
      'how can you help me',
      'como puedes ayudarme',
      'ne ogretirsin',
      'bana ne ogreteceksin',
      'ne ogrenecegim',
      'what will you teach me',
      'what can you teach me',
      'was bringst du mir bei',
      'was kannst du mir beibringen',
      'que me vas a ensenar',
      'que puedes ensenarme',
    ],
    answerTr:
        'Sana şu konularda yardım edebilirim:\n\n'
        '- Scratch, Python, HTML ve CSS dersleri\n'
        '- Arduino ve robotik\n'
        '- Oyunlar ve quizler\n'
        '- XP, seviye, jeton ve rozetler\n'
        '- Kodun çalışmadığında ne yapacağın\n\n'
        'Merak ettiğin konuyu yazman yeterli.',
    answerEn:
        'I can help you with:\n\n'
        '- Scratch, Python, HTML and CSS lessons\n'
        '- Arduino and robotics\n'
        '- Games and quizzes\n'
        '- XP, levels, coins and badges\n'
        '- What to do when your code does not work\n\n'
        'Just type the topic you are curious about.',
    answerDe:
        'Ich kann dir helfen bei:\n\n- Scratch, Python, HTML und CSS\n- '
        'Arduino und Robotik\n- Spielen und Quiz\n- XP, Level, Münzen und '
        'Abzeichen\n- Was tun, wenn dein Code nicht läuft\n\nSchreib einfach '
        'das Thema, das dich interessiert.',
    answerEs:
        'Puedo ayudarte con:\n\n- Scratch, Python, HTML y CSS\n- Arduino y '
        'robótica\n- Juegos y cuestionarios\n- XP, niveles, monedas e '
        'insignias\n- Qué hacer cuando tu código no funciona\n\nSolo escribe '
        'el tema que te interese.',
    relatedIds: ['scratch', 'python', 'xp'],
  ),

  // ------------------------------------------------------------------ scratch
  KnowledgeEntry(
    id: 'scratch',
    keywords: [
      'scratch',
      'blok',
      'blok kodlama',
      'suruklebirak',
      'surukle birak',
      'block coding',
      'blockprogrammierung',
      'blocke',
      'bloques',
      'programacion por bloques',
      'scratch nedir',
      'what is scratch',
      'was ist scratch',
      'que es scratch',
    ],
    answerTr:
        'Scratch, kodlamaya başlamanın en kolay yolu. Yazı yazmak yerine renkli '
        'blokları sürükleyip birleştirirsin; her blok bir komuttur.\n\n'
        'Blok renkleri ne işe yarar:\n'
        '- Mavi: hareket (git, dön)\n'
        '- Mor: görünüm (söyle, boyut değiştir)\n'
        '- Sarı: kontrol (tekrarla, eğer)\n'
        '- Turuncu: değişkenler\n\n'
        'Uygulamada Kurslar > Scratch bölümünden adım adım başlayabilirsin.',
    answerEn:
        'Scratch is the easiest way to start coding. Instead of typing, you drag '
        'and snap colourful blocks together; each block is a command.\n\n'
        'What the block colours mean:\n'
        '- Blue: motion (move, turn)\n'
        '- Purple: looks (say, change size)\n'
        '- Yellow: control (repeat, if)\n'
        '- Orange: variables\n\n'
        'Open Courses > Scratch in the app to start step by step.',
    answerDe:
        'Scratch ist der einfachste Weg, mit dem Programmieren anzufangen. '
        'Statt zu tippen ziehst du bunte Blöcke zusammen; jeder Block ist ein '
        'Befehl.\n\nWas die Farben bedeuten:\n- Blau: Bewegung (gehe, drehe '
        'dich)\n- Lila: Aussehen (sage, ändere Größe)\n- Gelb: Steuerung '
        '(wiederhole, falls)\n- Orange: Variablen\n\nÖffne Kurse > Scratch in '
        'der App und fang Schritt für Schritt an.',
    answerEs:
        'Scratch es la forma más fácil de empezar a programar. En lugar de '
        'escribir, arrastras bloques de colores y los encajas; cada bloque es '
        'una orden.\n\nQué significan los colores:\n- Azul: movimiento '
        '(mover, girar)\n- Morado: apariencia (decir, cambiar tamaño)\n- '
        'Amarillo: control (repetir, si)\n- Naranja: variables\n\nAbre Cursos '
        '> Scratch en la app para empezar paso a paso.',
    relatedIds: ['loop', 'variable', 'condition'],
  ),

  // ------------------------------------------------------------------- python
  KnowledgeEntry(
    id: 'python',
    keywords: [
      'python',
      'piton',
      'python nedir',
      'python a nasil baslarim',
      'how do i start with python',
      'wie fange ich mit python an',
      'como empiezo con python',
    ],
    answerTr:
        'Python, gerçek programcıların kullandığı ama öğrenmesi kolay bir dil. '
        'İlk programın genelde şudur:\n\n'
        'print("Merhaba dünya!")\n\n'
        'print komutu ekrana yazı yazar. Tırnak içine ne yazarsan onu gösterir.\n\n'
        'Kurslar > Python bölümünde adım adım ilerleyebilirsin.',
    answerEn:
        'Python is a real programming language that is still easy to learn. Your '
        'first program is usually:\n\n'
        'print("Hello world!")\n\n'
        'The print command writes text on the screen. Whatever you put inside the '
        'quotes gets shown.\n\n'
        'Go to Courses > Python to work through it step by step.',
    answerDe:
        'Python ist eine echte Programmiersprache und trotzdem leicht zu '
        'lernen. Dein erstes Programm ist meistens:\n\nprint("Hallo '
        'Welt!")\n\nDer Befehl print schreibt Text auf den Bildschirm. Was '
        'zwischen den Anführungszeichen steht, wird angezeigt.\n\nGeh zu '
        'Kurse > Python und arbeite dich Schritt für Schritt durch.',
    answerEs:
        'Python es un lenguaje de programación de verdad y aun así es fácil '
        'de aprender. Tu primer programa suele ser:\n\nprint("¡Hola '
        'mundo!")\n\nLa orden print escribe texto en la pantalla. Se muestra '
        'lo que pongas entre comillas.\n\nVe a Cursos > Python para avanzar '
        'paso a paso.',
    relatedIds: ['variable', 'loop', 'error'],
  ),

  // --------------------------------------------------------------- html / css
  KnowledgeEntry(
    id: 'html',
    keywords: [
      'html',
      'web sayfasi',
      'site yapma',
      'html nedir',
      'seite bauen',
      'what is html',
      'was ist html',
      'que es html',
    ],
    answerTr:
        'HTML, web sayfalarının iskeletidir. Etiketlerle yazılır ve etiketler '
        '< > işaretleri arasına konur.\n\n'
        'En çok kullanılanlar:\n'
        '- <h1> başlık\n'
        '- <p> paragraf\n'
        '- <img> resim\n'
        '- <a> bağlantı\n\n'
        'Çoğu etiketin bir de kapanışı vardır: <p>merhaba</p>',
    answerEn:
        'HTML is the skeleton of web pages. It is written with tags, and tags go '
        'between < > signs.\n\n'
        'The most common ones:\n'
        '- <h1> heading\n'
        '- <p> paragraph\n'
        '- <img> image\n'
        '- <a> link\n\n'
        'Most tags also have a closing tag: <p>hello</p>',
    answerDe:
        'HTML ist das Skelett von Webseiten. Es besteht aus Tags, und Tags '
        'stehen zwischen < >.\n\nDie häufigsten:\n- <h1> Überschrift\n- <p> '
        'Absatz\n- <img> Bild\n- <a> Link\n\nDie meisten Tags haben auch ein '
        'Ende: <p>hallo</p>',
    answerEs:
        'HTML es el esqueleto de las páginas web. Se escribe con etiquetas, y '
        'las etiquetas van entre < >.\n\nLas más comunes:\n- <h1> título\n- '
        '<p> párrafo\n- <img> imagen\n- <a> enlace\n\nCasi todas las '
        'etiquetas también se cierran: <p>hola</p>',
    relatedIds: ['css'],
  ),
  KnowledgeEntry(
    id: 'css',
    keywords: [
      'css',
      'stil',
      'renk verme',
      'tasarim',
      'style',
      'estilo',
      'estilos',
      'farben',
      'diseno',
      'css ne ise yarar',
      'what is css for',
      'wofur ist css da',
      'para que sirve css',
    ],
    answerTr:
        'CSS, HTML ile yaptığın sayfayı güzelleştirir: renk, yazı büyüklüğü, '
        'boşluklar, arka plan.\n\n'
        'Örnek:\n'
        'h1 { color: blue; font-size: 32px; }\n\n'
        'Burada h1 başlıklarının rengini mavi, boyutunu 32 piksel yaptık.',
    answerEn:
        'CSS makes the page you built with HTML look good: colours, text size, '
        'spacing, background.\n\n'
        'Example:\n'
        'h1 { color: blue; font-size: 32px; }\n\n'
        'This makes h1 headings blue and 32 pixels big.',
    answerDe:
        'CSS macht die Seite schön, die du mit HTML gebaut hast: Farben, '
        'Schriftgröße, Abstände, Hintergrund.\n\nBeispiel:\nh1 { color: blue; '
        'font-size: 32px; }\n\nDamit werden h1 Überschriften blau und 32 '
        'Pixel groß.',
    answerEs:
        'CSS hace que la página que construiste con HTML se vea bien: '
        'colores, tamaño de letra, espacios, fondo.\n\nEjemplo:\nh1 { color: '
        'blue; font-size: 32px; }\n\nAsí los títulos h1 se ven azules y de 32 '
        'píxeles.',
    relatedIds: ['html'],
  ),

  // ------------------------------------------------------- arduino / robotics
  KnowledgeEntry(
    id: 'arduino',
    keywords: [
      'arduino',
      'devre',
      'arduino kart',
      'arduino uno',
      'platine',
      'placa arduino',
      'arduino nedir',
      'what is arduino',
      'was ist arduino',
      'que es arduino',
    ],
    answerTr:
        'Arduino, küçük bir bilgisayar kartı. Ona kod yazarak LED yakabilir, motor '
        'döndürebilir, sensörlerden veri okuyabilirsin.\n\n'
        'Her Arduino programında iki bölüm vardır:\n'
        '- setup(): bir kere çalışır, hazırlık yapar\n'
        '- loop(): sürekli tekrar eder\n\n'
        'Uygulamadaki Arduino Atölyesi ile gerçek karta ihtiyaç duymadan '
        'deneyebilirsin.',
    answerEn:
        'Arduino is a small computer board. By writing code for it you can light '
        'up LEDs, spin motors and read sensors.\n\n'
        'Every Arduino program has two parts:\n'
        '- setup(): runs once, prepares things\n'
        '- loop(): repeats forever\n\n'
        'Try the Arduino Simulator in the app - you do not need a real board.',
    answerDe:
        'Arduino ist eine kleine Computerplatine. Mit Code lässt du LEDs '
        'leuchten, Motoren drehen und liest Sensoren aus.\n\nJedes Arduino '
        'Programm hat zwei Teile:\n- setup(): läuft einmal und bereitet alles '
        'vor\n- loop(): wiederholt sich immer wieder\n\nProbier den Arduino '
        'Simulator in der App aus - du brauchst keine echte Platine.',
    answerEs:
        'Arduino es una placa pequeña con un ordenador dentro. Escribiendo '
        'código puedes encender LED, mover motores y leer sensores.\n\nTodo '
        'programa de Arduino tiene dos partes:\n- setup(): se ejecuta una vez '
        'y prepara todo\n- loop(): se repite sin parar\n\nPrueba el Simulador '
        'de Arduino de la app: no necesitas una placa real.',
    relatedIds: ['robotics', 'loop'],
  ),
  KnowledgeEntry(
    id: 'robotics',
    keywords: [
      'robot',
      'robotik',
      'motor',
      'servo',
      'robotics',
      'robotica',
      'roboter',
      'robotik nedir',
      'what is robotics',
      'was ist robotik',
      'que es la robotica',
    ],
    answerTr:
        'Robotik, kod ile hareket eden makineler yapmaktır. Bir robotun üç parçası '
        'vardır:\n\n'
        '1. Sensörler: çevreyi algılar (mesafe, ışık, ses)\n'
        '2. Beyin: karar verir (Arduino gibi bir kart)\n'
        '3. Motorlar: hareketi yapar\n\n'
        'Sen beynin ne düşüneceğini kodla yazarsın: sensörden oku, karar '
        'ver, motoru çalıştır. Robot süpürgeden otonom arabaya kadar hepsi '
        'aynı üç adım.',
    answerEn:
        'Robotics is building machines that move using code. A robot has three '
        'parts:\n\n'
        '1. Sensors: sense the world (distance, light, sound)\n'
        '2. Brain: makes decisions (a board like Arduino)\n'
        '3. Motors: create movement\n\n'
        'You write the code that tells the brain what to think.',
    answerDe:
        'Robotik heißt, Maschinen zu bauen, die sich durch Code bewegen. Ein '
        'Roboter hat drei Teile:\n\n1. Sensoren: nehmen die Umgebung wahr '
        '(Abstand, Licht, Ton)\n2. Gehirn: trifft Entscheidungen (eine '
        'Platine wie Arduino)\n3. Motoren: erzeugen die Bewegung\n\nDu '
        'schreibst den Code, der dem Gehirn sagt, was es denken soll.',
    answerEs:
        'La robótica consiste en construir máquinas que se mueven con código. '
        'Un robot tiene tres partes:\n\n1. Sensores: perciben el entorno '
        '(distancia, luz, sonido)\n2. Cerebro: toma decisiones (una placa '
        'como Arduino)\n3. Motores: producen el movimiento\n\nTú escribes el '
        'código que le dice al cerebro qué pensar.',
    relatedIds: ['arduino'],
  ),

  // ---------------------------------------------------------- temel kavramlar
  KnowledgeEntry(
    id: 'loop',
    keywords: [
      'dongu',
      'tekrar',
      'for',
      'while',
      'loop',
      'repeat',
      'schleife',
      'schleifen',
      'bucle',
      'bucles',
      'wiederholung',
      'ciclo',
      'dongu nedir',
      'what is a loop',
      'was ist eine schleife',
      'que es un bucle',
    ],
    answerTr:
        'Döngü, aynı işi tekrar tekrar yaptırmanın yoludur. Aynı satırı 10 kez '
        'yazmak yerine bilgisayara "bunu 10 kez yap" dersin.\n\n'
        'Python örneği:\n'
        'for i in range(10):\n'
        '    print("Merhaba")\n\n'
        'Scratch\'te aynı işi sarı "tekrarla" bloğu yapar.',
    answerEn:
        'A loop is how you make the same work happen again and again. Instead of '
        'writing the same line 10 times, you tell the computer "do this 10 times".\n\n'
        'Python example:\n'
        'for i in range(10):\n'
        '    print("Hello")\n\n'
        'In Scratch the yellow "repeat" block does the same job.',
    answerDe:
        'Eine Schleife wiederholt dieselbe Arbeit immer wieder. Statt '
        'dieselbe Zeile zehnmal zu schreiben, sagst du dem Computer "mach das '
        'zehnmal".\n\nBeispiel in Python:\nfor i in range(10):\n    '
        'print("Hallo")\n\nIn Scratch macht der gelbe Block "wiederhole" '
        'genau dasselbe.',
    answerEs:
        'Un bucle repite el mismo trabajo una y otra vez. En lugar de '
        'escribir la misma línea diez veces, le dices al ordenador "haz esto '
        'diez veces".\n\nEjemplo en Python:\nfor i in range(10):\n    '
        'print("Hola")\n\nEn Scratch, el bloque amarillo "repetir" hace lo '
        'mismo.',
    relatedIds: ['condition', 'variable'],
  ),
  KnowledgeEntry(
    id: 'variable',
    keywords: [
      'degisken',
      'variable',
      'deger',
      'atama',
      'variablen',
      'variables',
      'degisken nedir',
      'what is a variable',
      'was ist eine variable',
      'que es una variable',
    ],
    answerTr:
        'Değişken, içine bir şey koyduğun etiketli bir kutudur. Sayıları, yazıları '
        'veya puanları saklarsın.\n\n'
        'Python örneği:\n'
        'puan = 0\n'
        'puan = puan + 10\n\n'
        'Şimdi puan kutusunun içinde 10 var. Oyunlarda skor tutmak tam olarak '
        'böyle yapılır.',
    answerEn:
        'A variable is a labelled box you put something into. You store numbers, '
        'text or scores in it.\n\n'
        'Python example:\n'
        'score = 0\n'
        'score = score + 10\n\n'
        'Now the score box holds 10. This is exactly how games keep score.',
    answerDe:
        'Eine Variable ist eine beschriftete Kiste, in die du etwas '
        'hineinlegst: Zahlen, Text oder Punkte.\n\nBeispiel in '
        'Python:\npunkte = 0\npunkte = punkte + 10\n\nJetzt liegen 10 in der '
        'Kiste punkte. Genau so merken sich Spiele deinen Punktestand.',
    answerEs:
        'Una variable es una caja con etiqueta donde guardas algo: números, '
        'texto o puntos.\n\nEjemplo en Python:\npuntos = 0\npuntos = puntos + '
        '10\n\nAhora la caja puntos guarda 10. Así es exactamente como los '
        'juegos llevan la puntuación.',
    relatedIds: ['loop', 'python'],
  ),
  KnowledgeEntry(
    id: 'condition',
    keywords: [
      'eger',
      'if',
      'kosul',
      'else',
      'condition',
      'sart',
      'bedingung',
      'bedingungen',
      'condicion',
      'condiciones',
      'falls',
      'si entonces',
      'kosul nedir',
      'what is a condition',
      'was ist eine bedingung',
      'que es una condicion',
    ],
    answerTr:
        'Koşul, bilgisayarın karar vermesini sağlar: "eğer şu olursa bunu yap".\n\n'
        'Python örneği:\n'
        'if puan > 100:\n'
        '    print("Kazandın!")\n'
        'else:\n'
        '    print("Devam et")\n\n'
        'Scratch\'te bunu sarı "eğer ... ise" bloğu yapar.',
    answerEn:
        'A condition lets the computer decide: "if this happens, do that".\n\n'
        'Python example:\n'
        'if score > 100:\n'
        '    print("You won!")\n'
        'else:\n'
        '    print("Keep going")\n\n'
        'In Scratch the yellow "if ... then" block does this.',
    answerDe:
        'Eine Bedingung lässt den Computer entscheiden: "wenn das passiert, '
        'mach jenes".\n\nBeispiel in Python:\nif punkte > 100:\n    '
        'print("Gewonnen!")\nelse:\n    print("Weiter so")\n\nIn Scratch '
        'macht das der gelbe Block "falls ... dann".',
    answerEs:
        'Una condición deja que el ordenador decida: "si pasa esto, haz '
        'aquello".\n\nEjemplo en Python:\nif puntos > 100:\n    print("¡Has '
        'ganado!")\nelse:\n    print("Sigue así")\n\nEn Scratch lo hace el '
        'bloque amarillo "si ... entonces".',
    relatedIds: ['loop', 'variable'],
  ),
  KnowledgeEntry(
    id: 'function',
    keywords: [
      'fonksiyon',
      'function',
      'def',
      'metod',
      'method',
      'funktion',
      'funktionen',
      'funcion',
      'funciones',
      'fonksiyon nedir',
      'what is a function',
      'was ist eine funktion',
      'que es una funcion',
    ],
    answerTr:
        'Fonksiyon, bir işe isim vermektir. Aynı işlemi tekrar tekrar yazmak yerine '
        'bir kere tanımlar, adıyla çağırırsın.\n\n'
        'Python örneği:\n'
        'def selamla(isim):\n'
        '    print("Merhaba " + isim)\n\n'
        'selamla("Ali")\n\n'
        'Scratch\'te buna "kendi bloğunu yap" denir.',
    answerEn:
        'A function is giving a name to a job. Instead of writing the same steps '
        'again and again, you define it once and call it by name.\n\n'
        'Python example:\n'
        'def greet(name):\n'
        '    print("Hello " + name)\n\n'
        'greet("Ali")\n\n'
        'In Scratch this is called "make a block".',
    answerDe:
        'Eine Funktion heißt, einer Aufgabe einen Namen zu geben. Statt '
        'dieselben Schritte immer wieder zu schreiben, definierst du sie '
        'einmal und rufst sie beim Namen auf.\n\nBeispiel in Python:\ndef '
        'gruesse(name):\n    print("Hallo " + name)\n\ngruesse("Ali")\n\nIn '
        'Scratch heißt das "Neuer Block".',
    answerEs:
        'Una función es ponerle nombre a una tarea. En lugar de escribir los '
        'mismos pasos una y otra vez, la defines una vez y la llamas por su '
        'nombre.\n\nEjemplo en Python:\ndef saludar(nombre):\n    print("Hola '
        '" + nombre)\n\nsaludar("Ali")\n\nEn Scratch esto se llama "Crear un '
        'bloque".',
    relatedIds: ['python', 'loop'],
  ),
  KnowledgeEntry(
    id: 'algorithm',
    keywords: [
      'algoritma',
      'algorithm',
      'adim adim',
      'algorithmus',
      'algoritmo',
      'algoritmos',
      'schritt fur schritt',
      'algoritma nedir',
      'what is an algorithm',
      'was ist ein algorithmus',
      'que es un algoritmo',
    ],
    answerTr:
        'Algoritma, bir işi bitirmek için izlenecek adımların sırasıdır. Yemek '
        'tarifi gibi düşün: önce şunu yap, sonra şunu.\n\n'
        'İyi bir algoritmanın özelliği: adımlar net, sıralı ve bir sonu var.',
    answerEn:
        'An algorithm is the ordered list of steps to finish a job. Think of a '
        'recipe: first do this, then that.\n\n'
        'A good algorithm has clear steps, in order, with an ending.',
    answerDe:
        'Ein Algorithmus ist die geordnete Liste der Schritte, mit denen du '
        'eine Aufgabe erledigst. Denk an ein Rezept: erst das, dann '
        'jenes.\n\nEin guter Algorithmus hat klare Schritte, eine feste '
        'Reihenfolge und ein Ende.',
    answerEs:
        'Un algoritmo es la lista ordenada de pasos para terminar una tarea. '
        'Piensa en una receta: primero esto, luego aquello.\n\nUn buen '
        'algoritmo tiene pasos claros, en orden y con un final.',
    relatedIds: ['loop', 'condition'],
  ),
  KnowledgeEntry(
    id: 'debug',
    keywords: [
      'hata ayikla',
      'debug',
      'bug',
      'bocek',
      'hatayi bul',
      'debuggen',
      'fehlersuche',
      'depurar',
      'depuracion',
      'hata nasil ayiklanir',
      'how do i debug',
      'wie debugge ich',
      'como depuro el codigo',
    ],
    answerTr:
        'Hata ayıklama (debug), koddaki hatayı bulup düzeltmektir. Sırayla dene:\n\n'
        '1. Hata mesajını oku, hangi satırı söylüyor?\n'
        '2. O satırı ve bir üstünü kontrol et\n'
        '3. Yazım hatası var mı? (parantez, tırnak, iki nokta)\n'
        '4. Küçük parçalar hâlinde çalıştır\n\n'
        'Her programcı hata yapar - önemli olan bulmayı öğrenmek.',
    answerEn:
        'Debugging means finding and fixing the mistake in your code. Try in order:\n\n'
        '1. Read the error message - which line does it point to?\n'
        '2. Check that line and the one above it\n'
        '3. Any typos? (brackets, quotes, colons)\n'
        '4. Run it in small pieces\n\n'
        'Every programmer makes mistakes - learning to find them is the skill.',
    answerDe:
        'Debuggen heißt, den Fehler im Code zu finden und zu beheben. Geh der '
        'Reihe nach vor:\n\n1. Lies die Fehlermeldung - auf welche Zeile '
        'zeigt sie?\n2. Prüfe diese Zeile und die darüber\n3. Tippfehler? '
        '(Klammern, Anführungszeichen, Doppelpunkte)\n4. Führe den Code in '
        'kleinen Stücken aus\n\nJede Programmiererin macht Fehler - die Kunst '
        'ist, sie zu finden.',
    answerEs:
        'Depurar significa encontrar y arreglar el fallo de tu código. Prueba '
        'en este orden:\n\n1. Lee el mensaje de error: ¿a qué línea '
        'apunta?\n2. Revisa esa línea y la de arriba\n3. ¿Hay erratas? '
        '(paréntesis, comillas, dos puntos)\n4. Ejecútalo en trozos '
        'pequeños\n\nTodos los programadores cometen errores; la habilidad '
        'está en encontrarlos.',
    relatedIds: ['error'],
  ),
  KnowledgeEntry(
    id: 'error',
    keywords: [
      'kodum calismiyor',
      'hata veriyor',
      'calismiyor',
      'error',
      'not working',
      'bozuk',
      'mein code geht nicht',
      'geht nicht',
      'funktioniert nicht',
      'mi codigo no funciona',
      'no funciona',
      'no me funciona',
      'my code does not work',
    ],
    answerTr:
        'Kodun çalışmıyorsa paniğe gerek yok. Şu sırayı dene:\n\n'
        '1. Yazım hatası: eksik parantez, tırnak veya iki nokta var mı?\n'
        '2. Büyük/küçük harf: Print ile print farklıdır\n'
        '3. Girinti (Python): satırlar düzgün hizalanmış mı?\n'
        '4. Sırası: değişkeni kullanmadan önce tanımladın mı?\n\n'
        'Hâlâ olmuyorsa dersteki örnekle satır satır karşılaştır.',
    answerEn:
        'If your code does not run, do not panic. Try this order:\n\n'
        '1. Typos: missing bracket, quote or colon?\n'
        '2. Capitals: Print and print are different\n'
        '3. Indentation (Python): are the lines lined up properly?\n'
        '4. Order: did you define the variable before using it?\n\n'
        'Still stuck? Compare it line by line with the lesson example.',
    answerDe:
        'Wenn dein Code nicht läuft, keine Panik. Probier diese '
        'Reihenfolge:\n\n1. Tippfehler: fehlt eine Klammer, ein '
        'Anführungszeichen oder ein Doppelpunkt?\n2. Groß und klein: Print '
        'und print sind verschieden\n3. Einrückung (Python): sind die Zeilen '
        'sauber ausgerichtet?\n4. Reihenfolge: hast du die Variable vor dem '
        'Benutzen angelegt?\n\nGeht es immer noch nicht? Vergleiche Zeile für '
        'Zeile mit dem Beispiel aus der Lektion.',
    answerEs:
        'Si tu código no funciona, no te agobies. Prueba en este orden:\n\n1. '
        'Erratas: ¿falta un paréntesis, una comilla o dos puntos?\n2. '
        'Mayúsculas: Print y print no son lo mismo\n3. Sangría (Python): '
        '¿están las líneas bien alineadas?\n4. Orden: ¿creaste la variable '
        'antes de usarla?\n\n¿Sigue sin ir? Compáralo línea por línea con el '
        'ejemplo de la lección.',
    relatedIds: ['debug'],
  ),

  // ----------------------------------------------------- uygulama içi konular
  KnowledgeEntry(
    id: 'xp',
    keywords: [
      'xp',
      'puan',
      'seviye',
      'level',
      'tecrube',
      'erfahrungspunkte',
      'nivel',
      'puntos de experiencia',
      'xp nasil kazanirim',
      'how do i earn xp',
      'wie bekomme ich xp',
      'como gano xp',
    ],
    answerTr:
        'XP, öğrendikçe kazandığın tecrübe puanıdır. Ders bitirince, quiz çözünce '
        've oyun oynayınca artar.\n\n'
        'Yeterli XP toplayınca seviyen yükselir. Seviyeni ve kalan XP\'ni Ana '
        'Sayfa\'daki çubuktan görebilirsin.',
    answerEn:
        'XP is the experience you earn as you learn. It grows when you finish a '
        'lesson, solve a quiz or play a game.\n\n'
        'Collect enough XP and your level goes up. You can see your level and '
        'remaining XP on the bar on the Home screen.',
    answerDe:
        'XP sind die Erfahrungspunkte, die du beim Lernen sammelst. Sie '
        'wachsen, wenn du eine Lektion beendest, ein Quiz löst oder ein Spiel '
        'spielst.\n\nGenug XP und dein Level steigt. Level und restliche XP '
        'siehst du auf dem Balken auf der Startseite.',
    answerEs:
        'Los XP son la experiencia que ganas mientras aprendes. Suben cuando '
        'terminas una lección, resuelves un cuestionario o juegas.\n\nCon '
        'suficientes XP subes de nivel. Puedes ver tu nivel y los XP que te '
        'faltan en la barra de la pantalla de inicio.',
    relatedIds: ['coins', 'badge'],
  ),
  KnowledgeEntry(
    id: 'coins',
    keywords: [
      'jeton',
      'coin',
      'para',
      'satin al',
      'munzen',
      'monedas',
      'dinero',
      'jetonlar ne ise yarar',
      'what are coins for',
      'wofur sind munzen da',
      'para que sirven las monedas',
    ],
    answerTr:
        'Jetonlar, uygulama içi para birimidir. Dersleri ve görevleri tamamlayarak '
        'kazanırsın.\n\n'
        'Market bölümünden jetonlarınla profil çerçevesi alabilirsin; '
        'çerçeven profilinde görünür. Gerçek para gerekmez.',
    answerEn:
        'Coins are the in-app currency. You earn them by finishing lessons and '
        'quests.\n\n'
        'In the Market you can spend coins on profile frames; your frame '
        'shows on your profile. No real money needed.',
    answerDe:
        'Münzen sind die Währung in der App. Du verdienst sie, indem du '
        'Lektionen und Tagesaufgaben abschließt.\n\nIm Markt gibst du Münzen '
        'für Profilrahmen aus; dein Rahmen erscheint in deinem Profil. '
        'Echtes Geld brauchst du dafür nicht.',
    answerEs:
        'Las monedas son la moneda dentro de la app. Las ganas terminando '
        'lecciones y misiones.\n\nEn la Tienda puedes gastarlas en marcos de '
        'perfil; tu marco aparece en tu perfil. No hace falta dinero real.',
    relatedIds: ['xp', 'quest'],
  ),
  KnowledgeEntry(
    id: 'badge',
    keywords: [
      'rozet',
      'badge',
      'basari',
      'achievement',
      'odul',
      'abzeichen',
      'insignia',
      'insignias',
      'erfolge',
      'logros',
      'rozetler nedir',
      'what are badges',
      'was sind abzeichen',
      'que son las insignias',
    ],
    answerTr:
        'Rozetler, belirli başarıları tamamlayınca kazandığın nişanlardır: ilk '
        'dersini bitirmek, üst üste gün girmek, bir oyunu kusursuz oynamak gibi.\n\n'
        'Kazandığın rozetleri profilinde görebilirsin.',
    answerEn:
        'Badges are awards you unlock for certain achievements: finishing your '
        'first lesson, keeping a daily streak, playing a game perfectly.\n\n'
        'You can see the badges you have earned on your profile.',
    answerDe:
        'Abzeichen bekommst du für bestimmte Erfolge: die erste Lektion '
        'beenden, eine Tagesserie halten, ein Spiel fehlerfrei '
        'spielen.\n\nDeine Abzeichen siehst du in deinem Profil.',
    answerEs:
        'Las insignias se desbloquean con ciertos logros: terminar tu primera '
        'lección, mantener una racha diaria o jugar una partida '
        'perfecta.\n\nPuedes ver las que has ganado en tu perfil.',
    relatedIds: ['xp', 'streak'],
  ),
  KnowledgeEntry(
    id: 'quest',
    keywords: [
      'gorev',
      'gunluk gorev',
      'quest',
      'hedef',
      'daily',
      'tagesaufgabe',
      'tagesaufgaben',
      'mision diaria',
      'misiones diarias',
      'misiones',
      'gunluk gorevler nedir',
      'what are daily quests',
      'was sind tagesaufgaben',
      'que son las misiones diarias',
    ],
    answerTr:
        'Günlük görevler, her gün yenilenen küçük hedeflerdir: bir ders bitir, bir '
        'oyun oyna, bir quiz çöz.\n\n'
        'Tamamladıkça XP ve jeton kazanırsın. Ana Sayfa\'daki görev kartından '
        'takip edebilirsin.',
    answerEn:
        'Daily quests are small goals that refresh every day: finish a lesson, '
        'play a game, solve a quiz.\n\n'
        'Completing them earns you XP and coins. Track them from the quest card on '
        'the Home screen.',
    answerDe:
        'Tagesaufgaben sind kleine Ziele, die sich jeden Tag erneuern: eine '
        'Lektion beenden, ein Spiel spielen, ein Quiz lösen.\n\nWenn du sie '
        'schaffst, bekommst du XP und Münzen. Du findest sie auf der '
        'Aufgabenkarte auf der Startseite.',
    answerEs:
        'Las misiones diarias son pequeños objetivos que se renuevan cada '
        'día: terminar una lección, jugar una partida, resolver un '
        'cuestionario.\n\nAl completarlas ganas XP y monedas. Las sigues '
        'desde la tarjeta de misiones en la pantalla de inicio.',
    relatedIds: ['xp', 'coins'],
  ),
  KnowledgeEntry(
    id: 'streak',
    keywords: [
      'seri',
      'streak',
      'ust uste',
      'gun serisi',
      'serie',
      'racha',
      'tagesserie',
      'seri nedir',
      'what is a streak',
      'was ist eine serie',
      'que es una racha',
    ],
    answerTr:
        'Seri, üst üste kaç gün uygulamaya girip bir şey öğrendiğini gösterir. '
        'Her gün devam ettikçe seri büyür; bir gün atlarsan sıfırlanır.\n\n'
        'Kısa da olsa her gün bir şeyler yapmak, haftada bir uzun oturumdan daha '
        'iyi öğretir.',
    answerEn:
        'Your streak shows how many days in a row you have opened the app and '
        'learned something. It grows each day and resets if you skip a day.\n\n'
        'Doing a little every day teaches you more than one long session a week.',
    answerDe:
        'Deine Serie zeigt, an wie vielen Tagen hintereinander du die App '
        'geöffnet und etwas gelernt hast. Sie wächst jeden Tag und fängt '
        'wieder bei null an, wenn du einen Tag auslässt.\n\nJeden Tag ein '
        'bisschen bringt mehr als eine lange Einheit pro Woche.',
    answerEs:
        'Tu racha muestra cuántos días seguidos has abierto la app y has '
        'aprendido algo. Crece cada día y se reinicia si te saltas '
        'uno.\n\nHacer un poco cada día enseña más que una sesión larga a la '
        'semana.',
    relatedIds: ['quest', 'xp'],
  ),
  KnowledgeEntry(
    id: 'leaderboard',
    keywords: [
      'liderlik',
      'siralama',
      'leaderboard',
      'birinci',
      'tablo',
      'bestenliste',
      'rangliste',
      'clasificacion',
      'tabla de clasificacion',
      'liderlik tablosu nedir',
      'what is the leaderboard',
      'was ist die bestenliste',
      'que es la tabla de clasificacion',
    ],
    answerTr:
        'Liderlik tablosu, XP\'ye göre sıralamayı gösterir. Ders bitirdikçe, quiz '
        'çözdükçe ve oyun oynadıkça yükselirsin.\n\n'
        'Unutma: yarışmak güzel ama asıl amaç öğrenmek.',
    answerEn:
        'The leaderboard ranks everyone by XP. You climb it by finishing lessons, '
        'solving quizzes and playing games.\n\n'
        'Remember: competing is fun, but learning is the real goal.',
    answerDe:
        'Die Bestenliste sortiert alle nach XP. Du kletterst nach oben, indem '
        'du Lektionen beendest, Quiz löst und spielst.\n\nDenk dran: '
        'Wettbewerb macht Spaß, aber das eigentliche Ziel ist das Lernen.',
    answerEs:
        'La tabla de clasificación ordena a todos por XP. Subes terminando '
        'lecciones, resolviendo cuestionarios y jugando.\n\nRecuerda: '
        'competir es divertido, pero el objetivo de verdad es aprender.',
    relatedIds: ['xp'],
  ),
  KnowledgeEntry(
    id: 'games',
    keywords: [
      'oyun',
      'game',
      'oyunlar',
      'hangi oyunlar',
      'spiele',
      'juegos',
      'welche spiele',
      'que juegos hay',
      'hangi oyunlar var',
      'which games are there',
      'welche spiele gibt es',
    ],
    answerTr:
        'Oyunlar, öğrendiklerini pekiştirmek için var. Uygulamada satranç, Maze '
        'Explorer, Bug Hunter, Block Coding, Pattern Detective ve daha fazlası var.\n\n'
        'Her oyun farklı bir beceri çalıştırır: strateji, sıra takibi, hata bulma, '
        'örüntü tanıma.',
    answerEn:
        'Games are here to reinforce what you learn. The app has chess, Maze '
        'Explorer, Bug Hunter, Block Coding, Pattern Detective and more.\n\n'
        'Each game trains a different skill: strategy, sequencing, finding bugs, '
        'spotting patterns.',
    answerDe:
        'Die Spiele sind da, um das Gelernte zu festigen. In der App gibt es '
        'Schach, Maze Explorer, Bug Hunter, Block Coding, Muster-Detektiv und '
        'mehr.\n\nJedes Spiel trainiert eine andere Fähigkeit: Strategie, '
        'Reihenfolge, Fehlersuche, Muster erkennen.',
    answerEs:
        'Los juegos están para reforzar lo que aprendes. La app tiene '
        'ajedrez, Maze Explorer, Bug Hunter, Block Coding, Detective de '
        'Patrones y más.\n\nCada juego entrena una habilidad distinta: '
        'estrategia, secuencias, buscar errores, detectar patrones.',
    relatedIds: ['xp'],
  ),
  KnowledgeEntry(
    id: 'where_start',
    keywords: [
      'nereden baslamaliyim',
      'nasil baslarim',
      'ilk ne',
      'where do i start',
      'how do i start',
      'womit soll ich anfangen',
      'wo fange ich an',
      'anfangen',
      'por donde empiezo',
      'como empiezo',
      'empezar',
    ],
    answerTr:
        'Hiç kodlama bilmiyorsan Scratch ile başla - blok sürükleyerek öğrenirsin, '
        'yazı yazmak gerekmez.\n\n'
        'Scratch\'i rahat kullanıyorsan Python\'a geç. Web sayfası yapmak istiyorsan '
        'HTML, robotlarla ilgileniyorsan Arduino iyi bir başlangıç.',
    answerEn:
        'If you have never coded before, start with Scratch - you learn by dragging '
        'blocks, no typing needed.\n\n'
        'Once Scratch feels easy, move to Python. If you want to build a web page, '
        'go with HTML; if robots interest you, Arduino is a good start.',
    answerDe:
        'Wenn du noch nie programmiert hast, fang mit Scratch an - du lernst '
        'durch Ziehen von Blöcken, ganz ohne Tippen.\n\nWenn dir Scratch '
        'leicht fällt, wechsle zu Python. Willst du eine Webseite bauen, nimm '
        'HTML; interessieren dich Roboter, ist Arduino ein guter Start.',
    answerEs:
        'Si nunca has programado, empieza con Scratch: aprendes arrastrando '
        'bloques, sin escribir nada.\n\nCuando Scratch te resulte fácil, pasa '
        'a Python. Si quieres hacer una página web, ve con HTML; si te '
        'interesan los robots, Arduino es un buen comienzo.',
    relatedIds: ['scratch', 'python', 'arduino'],
  ),
  KnowledgeEntry(
    id: 'thanks',
    keywords: [
      'tesekkur',
      'sagol',
      'tesekkurler',
      'thanks',
      'thank you',
      'danke',
      'vielen dank',
      'gracias',
    ],
    answerTr: 'Rica ederim! Başka bir sorun olursa buradayım.',
    answerEn: 'You are welcome! I am here if you have another question.',
    answerDe:
        'Gern geschehen! Ich bin da, wenn du noch eine Frage hast.',
    answerEs:
        '¡De nada! Aquí estoy si tienes otra pregunta.',
  ),

  // ------------------------------------------------------- gunluk sohbet (ek)
  KnowledgeEntry(
    id: 'how_are_you',
    keywords: [
      'nasilsin',
      'naber',
      'ne haber',
      'iyi misin',
      'nasil gidiyor',
      'how are you',
      'wie geht es dir',
      'wie gehts',
      'como estas',
      'que tal',
    ],
    answerTr:
        'Ben iyiyim, sorduğun için teşekkürler! Kod yazmaya her zaman hazırım. '
        'Sen nasılsın? Bugün ne öğrenmek istersin?',
    answerEn:
        'I am good, thanks for asking! I am always ready to code. How about you? '
        'What would you like to learn today?',
    answerDe:
        'Mir geht es gut, danke der Nachfrage! Ich bin immer bereit zu '
        'programmieren. Und dir? Was möchtest du heute lernen?',
    answerEs:
        '¡Estoy bien, gracias por preguntar! Siempre tengo ganas de '
        'programar. ¿Y tú? ¿Qué te gustaría aprender hoy?',
    relatedIds: ['where_start', 'games'],
  ),
  KnowledgeEntry(
    id: 'goodbye',
    keywords: [
      'gorusuruz',
      'hoscakal',
      'iyi geceler',
      'gule gule',
      'bay bay',
      'goodbye',
      'bye',
      'good night',
      'tschuss',
      'auf wiedersehen',
      'bis bald',
      'gute nacht',
      'adios',
      'hasta luego',
      'buenas noches',
    ],
    answerTr:
        'Görüşürüz! Bugün öğrendiklerini unutma, yarın seriyi bozmamak için tekrar '
        'uğra. Kolay gelsin!',
    answerEn:
        'See you! Do not forget what you learned today, and come back tomorrow to '
        'keep your streak alive. Good luck!',
    answerDe:
        'Bis bald! Vergiss nicht, was du heute gelernt hast, und komm morgen '
        'wieder, damit deine Serie weiterläuft. Viel Erfolg!',
    answerEs:
        '¡Hasta luego! No olvides lo que aprendiste hoy y vuelve mañana para '
        'mantener tu racha. ¡Mucha suerte!',
    relatedIds: ['streak'],
  ),
  KnowledgeEntry(
    id: 'your_age',
    keywords: [
      'kac yasindasin',
      'yasin kac',
      'how old are you',
      'dogum gunun',
      'wie alt bist du',
      'cuantos anos tienes',
    ],
    answerTr:
        'Benim yaşım yok, ben bir yardım asistanıyım. Ama uygulamadaki her dersi '
        'biliyorum diyebilirim. Sen kaç yaşındasın? Sana uygun dersleri önerebilirim.',
    answerEn:
        'I do not have an age, I am a help assistant. But I know every lesson in the '
        'app. How old are you? I can suggest lessons that fit you.',
    answerDe:
        'Ich habe kein Alter, ich bin ein Lernhelfer. Aber ich kenne jede '
        'Lektion in der App. Wie alt bist du? Dann schlage ich dir passende '
        'Lektionen vor.',
    answerEs:
        'No tengo edad, soy un asistente de ayuda. Pero conozco todas las '
        'lecciones de la app. ¿Cuántos años tienes? Así te sugiero lecciones '
        'que te vayan bien.',
    relatedIds: ['where_start'],
  ),
  KnowledgeEntry(
    id: 'are_you_robot',
    keywords: [
      'robot musun',
      'insan misin',
      'gercek misin',
      'canli misin',
      'are you a robot',
      'are you real',
      'bist du ein roboter',
      'bist du echt',
      'eres un robot',
      'eres real',
    ],
    answerTr:
        'Ben bir bilgisayar programıyım, insan değilim. Cevaplarımı DevEducation '
        'eğitmenleri önceden yazdı, ben de sorununa en uygun olanı buluyorum. '
        'Yani sihir yok, sadece kod!',
    answerEn:
        'I am a computer program, not a human. My answers were written in advance by '
        'DevEducation teachers, and I find the one that fits your question. '
        'No magic here, just code!',
    answerDe:
        'Ich bin ein Computerprogramm, kein Mensch. Meine Antworten haben die '
        'Lehrkräfte von DevEducation vorher geschrieben, und ich suche die '
        'passende zu deiner Frage heraus. Keine Zauberei, nur Code!',
    answerEs:
        'Soy un programa de ordenador, no una persona. Mis respuestas las '
        'escribieron antes los profesores de DevEducation y yo busco la que '
        'encaja con tu pregunta. Nada de magia: solo código.',
    relatedIds: ['who_are_you', 'ai'],
  ),
  KnowledgeEntry(
    id: 'bored',
    keywords: [
      'sikildim',
      'canim sikkin',
      'sikiliyorum',
      'ne yapsam',
      'i am bored',
      'bored',
      'mir ist langweilig',
      'langweilig',
      'estoy aburrido',
      'aburrido',
      'me aburro',
      'sikildim ne yapsam',
      'i am bored what now',
      'mir ist langweilig was nun',
      'estoy aburrido que hago',
    ],
    answerTr:
        'O zaman kısa bir şey deneyelim! Şunlardan biri iyi gelir:\n\n'
        '- Oyunlar > Labirent Kaşifi ile 5 dakikalık bir tur\n'
        '- Günlük görevlerinden birini tamamla, XP kazan\n'
        '- Scratch\'te kedi karakterine dans ettiren küçük bir proje yap\n\n'
        'Hangisini istersin?',
    answerEn:
        'Then let us try something short! One of these usually helps:\n\n'
        '- A five minute round of Games > Maze Explorer\n'
        '- Finish one of your daily quests and earn XP\n'
        '- Build a small Scratch project that makes the cat dance\n\n'
        'Which one sounds good?',
    answerDe:
        'Dann probieren wir etwas Kurzes! Eines davon hilft meistens:\n\n- '
        'Fünf Minuten Spiele > Maze Explorer\n- Eine Tagesaufgabe abschließen '
        'und XP sammeln\n- Ein kleines Scratch Projekt, in dem die Katze '
        'tanzt\n\nWas klingt gut?',
    answerEs:
        '¡Entonces probemos algo corto! Una de estas suele funcionar:\n\n- '
        'Cinco minutos de Juegos > Maze Explorer\n- Terminar una misión '
        'diaria y ganar XP\n- Un proyecto pequeño en Scratch donde el gato '
        'baile\n\n¿Cuál te apetece?',
    relatedIds: ['games', 'quest', 'scratch'],
  ),
  KnowledgeEntry(
    id: 'joke',
    keywords: [
      'saka',
      'komik',
      'fikra',
      'guldur',
      'joke',
      'make me laugh',
      'witz',
      'erzahl mir einen witz',
      'chiste',
      'cuentame un chiste',
      'bana saka yap',
      'tell me a joke',
    ],
    answerTr:
        'Bir tane var: Programcı neden karanlıktan korkmaz? Çünkü hep "light mode" '
        'kullanır. 😄\n\n'
        'Bir tanesi daha: Kodun neden çalışmıyor? Bilmiyorum. Peki neden çalışıyor? '
        'Onu da bilmiyorum!',
    answerEn:
        'Here is one: Why do programmers prefer dark mode? Because light attracts '
        'bugs. 😄\n\n'
        'One more: Why does the code not work? No idea. Why does it work? Also no idea!',
    answerDe:
        'Hier ist einer: Warum mögen Programmierer den Dark Mode? Weil Licht '
        'die Bugs anzieht. 😄\n\nUnd noch einer: Warum läuft der Code nicht? '
        'Keine Ahnung. Und warum läuft er? Auch keine Ahnung!',
    answerEs:
        'Aquí va uno: ¿por qué los programadores prefieren el modo oscuro? '
        'Porque la luz atrae a los bichos. 😄\n\nY otro más: ¿por qué no '
        'funciona el código? Ni idea. ¿Y por qué funciona? Tampoco.',
    relatedIds: ['debug'],
  ),
  KnowledgeEntry(
    id: 'riddle',
    keywords: [
      'bilmece',
      'bulmaca',
      'bana soru sor',
      'soru sor',
      'riddle',
      'ask me',
      'ratsel',
      'stell mir ein ratsel',
      'acertijo',
      'ponme un acertijo',
      'adivinanza',
      'bana bilmece sor',
      'ask me a riddle',
    ],
    answerTr:
        'Hazırsan başlıyorum: Bir listede 1\'den 10\'a kadar sayılar var ama biri '
        'eksik. Toplamları 50. Eksik olan sayı kaç?\n\n'
        'İpucu: 1\'den 10\'a kadar tüm sayıların toplamı 55.\n\n'
        'Daha fazlası için Oyunlar > Quiz bölümüne bak.',
    answerEn:
        'Here we go: A list holds the numbers 1 to 10, but one is missing. They add '
        'up to 50. Which number is missing?\n\n'
        'Hint: the numbers 1 to 10 add up to 55.\n\n'
        'For more, check Games > Quiz.',
    answerDe:
        'Los geht es: In einer Liste stehen die Zahlen 1 bis 10, aber eine '
        'fehlt. Zusammen ergeben sie 50. Welche Zahl fehlt?\n\nTipp: Die '
        'Zahlen 1 bis 10 ergeben zusammen 55.\n\nMehr davon findest du unter '
        'Spiele > Quiz.',
    answerEs:
        'Allá va: una lista tiene los números del 1 al 10, pero falta uno. '
        'Suman 50. ¿Qué número falta?\n\nPista: del 1 al 10 suman 55.\n\nHay '
        'más en Juegos > Quiz.',
    relatedIds: ['games', 'algorithm'],
  ),
  KnowledgeEntry(
    id: 'do_my_homework',
    keywords: [
      'odevimi yap',
      'benim yerime yap',
      'cevabi ver',
      'cevabi soyle',
      'do my homework',
      'mach meine hausaufgaben',
      'hausaufgaben',
      'haz mi tarea',
      'dame la respuesta',
    ],
    answerTr:
        'Cevabı doğrudan vermem, çünkü asıl öğrenme sen denerken oluyor. Ama ipucu '
        'veririm: probleminin ilk adımını bana anlat, oradan birlikte ilerleyelim.\n\n'
        'Takıldığın satırı yazarsan neyin ters gittiğini birlikte bulabiliriz.',
    answerEn:
        'I will not just hand over the answer, because the learning happens while you '
        'try. But I will give hints: tell me the first step of your problem and we '
        'will work forward together.\n\n'
        'Paste the line you are stuck on and we can find what goes wrong.',
    answerDe:
        'Ich gebe dir die Lösung nicht einfach, denn das Lernen passiert beim '
        'Versuchen. Aber Tipps gebe ich gern: Erzähl mir den ersten Schritt '
        'deiner Aufgabe, dann gehen wir gemeinsam weiter.\n\nSchreib die '
        'Zeile auf, bei der du feststeckst, und wir finden zusammen, was '
        'schiefgeht.',
    answerEs:
        'No te doy la respuesta directamente, porque se aprende al '
        'intentarlo. Pero sí te doy pistas: cuéntame el primer paso de tu '
        'problema y seguimos juntos desde ahí.\n\nEscribe la línea en la que '
        'te has atascado y buscamos qué falla.',
    relatedIds: ['debug', 'error'],
  ),
  KnowledgeEntry(
    id: 'motivation',
    keywords: [
      'yapamiyorum',
      'zor geliyor',
      'pes ediyorum',
      'anlamiyorum hicbir sey',
      'too hard',
      'i give up',
      'ich schaffe es nicht',
      'zu schwer',
      'ich gebe auf',
      'es muy dificil',
      'me rindo',
      'no puedo',
      'zorlaniyorum ne yapmaliyim',
      'i am finding it hard',
      'es fallt mir schwer',
      'me esta costando',
    ],
    answerTr:
        'Zorlanman normal, kodlama öğrenirken herkes takılır. Küçük bir öneri: '
        'konuyu bir seferde bitirmeye çalışma, günde 15 dakika yeter.\n\n'
        'Şu an takıldığın konuyu yaz, daha kolay bir parçaya bölelim. İstersen bir '
        'adım geriye gidip Scratch ile pekiştirebiliriz.',
    answerEn:
        'It is normal to struggle; everyone gets stuck while learning to code. A small '
        'tip: do not try to finish a topic in one sitting, 15 minutes a day is enough.\n\n'
        'Tell me what you are stuck on and we will split it into a smaller piece. We '
        'can also step back and practise it in Scratch.',
    answerDe:
        'Dass es schwer ist, ist normal; beim Programmieren lernen bleibt '
        'jede und jeder mal stecken. Ein kleiner Tipp: Versuch nicht, ein '
        'Thema in einem Rutsch zu schaffen, 15 Minuten am Tag '
        'reichen.\n\nSchreib mir, wobei du feststeckst, und wir zerlegen es '
        'in ein kleineres Stück. Wir können auch einen Schritt zurückgehen '
        'und es in Scratch üben.',
    answerEs:
        'Es normal que cueste; todo el mundo se atasca aprendiendo a '
        'programar. Un consejo: no intentes terminar un tema de una sentada, '
        '15 minutos al día bastan.\n\nDime en qué te has atascado y lo '
        'partimos en un trozo más pequeño. También podemos dar un paso atrás '
        'y practicarlo en Scratch.',
    relatedIds: ['where_start', 'streak'],
  ),

  // ------------------------------------------------------ programlama (ek)
  KnowledgeEntry(
    id: 'javascript',
    keywords: [
      'javascript',
      'js dili',
      'node js',
      'js',
      'javascript nedir',
      'what is javascript',
      'was ist javascript',
      'que es javascript',
    ],
    answerTr:
        'JavaScript, web sayfalarını hareketlendiren dildir. HTML sayfanın iskeleti, '
        'CSS görünümü, JavaScript ise davranışıdır: butona basınca ne olacağını o '
        'belirler.\n\n'
        'Küçük bir örnek:\n'
        'alert("Merhaba!");\n\n'
        'HTML ve CSS derslerini bitirdikten sonra JavaScript sırada.',
    answerEn:
        'JavaScript is the language that makes web pages move. HTML is the skeleton, '
        'CSS is the look, and JavaScript is the behaviour: it decides what happens '
        'when you press a button.\n\n'
        'A tiny example:\n'
        'alert("Hello!");\n\n'
        'JavaScript comes right after the HTML and CSS lessons.',
    answerDe:
        'JavaScript ist die Sprache, die Webseiten lebendig macht. HTML ist '
        'das Skelett, CSS das Aussehen und JavaScript das Verhalten: Es '
        'entscheidet, was beim Klick auf einen Knopf passiert.\n\nEin '
        'winziges Beispiel:\nalert("Hallo!");\n\nJavaScript kommt direkt nach '
        'den HTML und CSS Lektionen.',
    answerEs:
        'JavaScript es el lenguaje que hace que las páginas web se muevan. '
        'HTML es el esqueleto, CSS el aspecto y JavaScript el comportamiento: '
        'decide qué pasa cuando pulsas un botón.\n\nUn ejemplo muy '
        'pequeño:\nalert("¡Hola!");\n\nJavaScript viene justo después de las '
        'lecciones de HTML y CSS.',
    relatedIds: ['html', 'css'],
  ),
  KnowledgeEntry(
    id: 'mblock',
    keywords: [
      'mblock',
      'mbot',
      'makeblock',
      'mblock nedir',
      'what is mblock',
      'was ist mblock',
      'que es mblock',
    ],
    answerTr:
        'mBlock, Scratch tabanlı bir blok kodlama programıdır; farkı gerçek robotları '
        'da kontrol edebilmesi. mBot gibi robotlara sürükle-bırak bloklarla komut '
        'verirsin.\n\n'
        'Uygulamada mBlock video serisi temel seviyeden başlayıp ileri projelere '
        'kadar gidiyor: çizgi izleyen robot, engelden kaçan robot gibi.',
    answerEn:
        'mBlock is a Scratch based block coding tool; the difference is that it can '
        'also control real robots. You command robots like mBot with drag and drop '
        'blocks.\n\n'
        'The app has an mBlock video series that starts at the basics and goes up to '
        'advanced projects: line following robots, obstacle avoiding robots and more.',
    answerDe:
        'mBlock ist ein Block-Programmierwerkzeug auf Scratch Basis; der '
        'Unterschied ist, dass es auch echte Roboter steuern kann. Roboter '
        'wie den mBot steuerst du mit Blöcken per Ziehen und Ablegen.\n\nIn '
        'der App gibt es eine mBlock Videoreihe, die bei den Grundlagen '
        'anfängt und bis zu größeren Projekten geht: Linienfolger, '
        'Hindernisvermeider und mehr.',
    answerEs:
        'mBlock es una herramienta de programación por bloques basada en '
        'Scratch; la diferencia es que también controla robots reales. A '
        'robots como mBot les das órdenes arrastrando bloques.\n\nLa app '
        'tiene una serie de vídeos de mBlock que empieza por lo básico y '
        'llega a proyectos avanzados: robots siguelíneas, robots que esquivan '
        'obstáculos y más.',
    relatedIds: ['scratch', 'robotics'],
  ),
  KnowledgeEntry(
    id: 'microbit',
    keywords: [
      'micro bit',
      'microbit',
      'mikrobit',
      'micro bit nedir',
      'what is a micro bit',
      'was ist ein micro bit',
      'que es un micro bit',
    ],
    answerTr:
        'micro:bit, avuç içi büyüklüğünde bir kartlı bilgisayardır. Üzerinde 25 LED, '
        'iki buton, ivmeölçer ve pusula vardır.\n\n'
        'Blok kodlama ya da Python ile programlanır; sallayınca zar atan, kalp '
        'çizen ya da adım sayan projeler yapabilirsin.',
    answerEn:
        'The micro:bit is a palm sized single board computer. It has 25 LEDs, two '
        'buttons, an accelerometer and a compass.\n\n'
        'You program it with blocks or Python; you can build projects that roll a dice '
        'when shaken, draw a heart, or count your steps.',
    answerDe:
        'Der micro:bit ist ein handtellergroßer Einplatinencomputer. Er hat '
        '25 LEDs, zwei Knöpfe, einen Beschleunigungssensor und einen '
        'Kompass.\n\nDu programmierst ihn mit Blöcken oder mit Python; du '
        'kannst Projekte bauen, die beim Schütteln würfeln, ein Herz zeichnen '
        'oder deine Schritte zählen.',
    answerEs:
        'El micro:bit es un ordenador de una sola placa del tamaño de la '
        'palma de la mano. Tiene 25 LED, dos botones, un acelerómetro y una '
        'brújula.\n\nSe programa con bloques o con Python; puedes hacer '
        'proyectos que tiran un dado al agitarlo, dibujan un corazón o '
        'cuentan tus pasos.',
    relatedIds: ['arduino', 'robotics'],
  ),
  KnowledgeEntry(
    id: 'list_array',
    keywords: [
      'liste',
      'dizi',
      'array',
      'list yapisi',
      'listen',
      'lista',
      'listas',
      'arreglo',
      'liste dizi nedir',
      'what is a list array',
      'was ist eine liste',
      'que es una lista',
    ],
    answerTr:
        'Liste (dizi), birden çok değeri tek bir isim altında tutmanı sağlar. Tek tek '
        'değişken açmak yerine hepsini bir arada saklarsın.\n\n'
        'Python\'da:\n'
        'notlar = [80, 95, 70]\n'
        'print(notlar[0])  # 80\n\n'
        'Sayma 0\'dan başlar: ilk eleman notlar[0]\'dır.',
    answerEn:
        'A list (array) holds many values under a single name, instead of creating a '
        'separate variable for each one.\n\n'
        'In Python:\n'
        'grades = [80, 95, 70]\n'
        'print(grades[0])  # 80\n\n'
        'Counting starts at 0, so the first item is grades[0].',
    answerDe:
        'Eine Liste (Array) hält viele Werte unter einem einzigen Namen, '
        'statt für jeden eine eigene Variable anzulegen.\n\nIn Python:\nnoten '
        '= [80, 95, 70]\nprint(noten[0])  # 80\n\nGezählt wird ab 0, das '
        'erste Element ist also noten[0].',
    answerEs:
        'Una lista (array) guarda muchos valores bajo un mismo nombre, en vez '
        'de crear una variable para cada uno.\n\nEn Python:\nnotas = [80, 95, '
        '70]\nprint(notas[0])  # 80\n\nSe cuenta desde 0, así que el primer '
        'elemento es notas[0].',
    relatedIds: ['variable', 'loop'],
  ),
  KnowledgeEntry(
    id: 'data_types',
    keywords: [
      'veri tipi',
      'veri turu',
      'veri tipleri',
      'veri turleri',
      'string nedir',
      'metin tipi',
      'tam sayi',
      'integer',
      'data type',
      'datentyp',
      'datentypen',
      'tipos de datos',
      'tipo de dato',
      'zeichenkette',
      'cadena',
      'veri tipleri nelerdir',
      'what are data types',
      'was sind datentypen',
      'que son los tipos de datos',
    ],
    answerTr:
        'Programlar farklı türde veriler tutar:\n\n'
        '- Metin (string): "Merhaba" - tırnak içinde yazılır\n'
        '- Tam sayı (integer): 42\n'
        '- Ondalıklı sayı (float): 3.14\n'
        '- Doğru/yanlış (boolean): True ya da False\n\n'
        'Dikkat: "5" bir metindir, 5 ise sayıdır. "5" + "5" sonucu "55" olur!',
    answerEn:
        'Programs store different kinds of data:\n\n'
        '- Text (string): "Hello" - written inside quotes\n'
        '- Whole number (integer): 42\n'
        '- Decimal number (float): 3.14\n'
        '- True or false (boolean): True or False\n\n'
        'Careful: "5" is text while 5 is a number. "5" + "5" gives "55"!',
    answerDe:
        'Programme speichern verschiedene Arten von Daten:\n\n- Text '
        '(string): "Hallo" - steht in Anführungszeichen\n- Ganze Zahl '
        '(integer): 42\n- Kommazahl (float): 3.14\n- Wahr oder falsch '
        '(boolean): True oder False\n\nVorsicht: "5" ist Text, 5 ist eine '
        'Zahl. "5" + "5" ergibt "55"!',
    answerEs:
        'Los programas guardan distintos tipos de datos:\n\n- Texto (string): '
        '"Hola" - se escribe entre comillas\n- Número entero (integer): 42\n- '
        'Número decimal (float): 3.14\n- Verdadero o falso (boolean): True o '
        'False\n\nOjo: "5" es texto y 5 es un número. "5" + "5" da "55".',
    relatedIds: ['variable', 'error'],
  ),
  KnowledgeEntry(
    id: 'operators',
    keywords: [
      'operator',
      'islem isareti',
      'toplama isareti',
      'mod alma',
      'bolme islemi',
      'operatoren',
      'operadores',
      'modulo',
      'rechenzeichen',
      'resto',
      'operatorler nedir',
      'what are operators',
      'was sind operatoren',
      'que son los operadores',
    ],
    answerTr:
        'Operatörler sayılarla ve değerlerle işlem yapmanı sağlar:\n\n'
        '+ toplama, - çıkarma, * çarpma, / bölme\n'
        '% kalan (mod): 7 % 2 = 1\n'
        '== eşit mi, != eşit değil mi, > büyük mü\n\n'
        'Sık yapılan hata: = değer atar, == karşılaştırır. Koşul yazarken == kullan.',
    answerEn:
        'Operators let you work with numbers and values:\n\n'
        '+ add, - subtract, * multiply, / divide\n'
        '% remainder (mod): 7 % 2 = 1\n'
        '== is equal, != is not equal, > is greater\n\n'
        'A common mistake: = assigns a value while == compares. Use == inside conditions.',
    answerDe:
        'Mit Operatoren rechnest du mit Zahlen und Werten:\n\n+ plus, - '
        'minus, * mal, / geteilt\n% Rest (Modulo): 7 % 2 = 1\n== ist gleich, '
        '!= ist ungleich, > ist größer\n\nHäufiger Fehler: = weist einen Wert '
        'zu, == vergleicht. In Bedingungen nimmst du ==.',
    answerEs:
        'Los operadores te dejan trabajar con números y valores:\n\n+ sumar, '
        '- restar, * multiplicar, / dividir\n% resto (módulo): 7 % 2 = 1\n== '
        'es igual, != no es igual, > es mayor\n\nError típico: = asigna un '
        'valor y == compara. Dentro de una condición usa ==.',
    relatedIds: ['condition', 'variable'],
  ),
  KnowledgeEntry(
    id: 'comment_line',
    keywords: [
      'yorum satiri',
      'aciklama satiri',
      'comment',
      'kod aciklamasi',
      'kommentar',
      'kommentare',
      'comentario',
      'comentarios',
      'yorum satiri nedir',
      'what is a comment',
      'was ist ein kommentar',
      'que es un comentario',
    ],
    answerTr:
        'Yorum satırı, bilgisayarın çalıştırmadığı ama insanların okuduğu nottur. '
        'Kodun ne yaptığını hatırlamak için yazılır.\n\n'
        'Python\'da # ile başlar:\n'
        '# Bu satır çalışmaz\n'
        'print("Merhaba")\n\n'
        'İyi bir alışkanlık: karışık bir bölümün üstüne bir cümlelik açıklama yaz.',
    answerEn:
        'A comment is a note the computer ignores but people read. You write it to '
        'remember what the code does.\n\n'
        'In Python it starts with #:\n'
        '# This line does not run\n'
        'print("Hello")\n\n'
        'A good habit: write a one sentence note above any tricky part.',
    answerDe:
        'Ein Kommentar ist eine Notiz, die der Computer ignoriert und die '
        'Menschen lesen. Du schreibst sie, um dich zu erinnern, was der Code '
        'tut.\n\nIn Python beginnt sie mit #:\n# Diese Zeile laeuft '
        'nicht\nprint("Hallo")\n\nGute Gewohnheit: Schreib einen Satz über '
        'jeden kniffligen Abschnitt.',
    answerEs:
        'Un comentario es una nota que el ordenador ignora y las personas '
        'leen. La escribes para recordar qué hace el código.\n\nEn Python '
        'empieza con #:\n# Esta linea no se ejecuta\nprint("Hola")\n\nBuena '
        'costumbre: escribe una frase encima de cada parte complicada.',
    relatedIds: ['python', 'debug'],
  ),
  KnowledgeEntry(
    id: 'print_input',
    keywords: [
      'print',
      'ekrana yaz',
      'ekrana yazdir',
      'input',
      'kullanicidan al',
      'veri alma',
      'eingabe',
      'ausgabe',
      'entrada',
      'print ve input nedir',
      'what are print and input',
      'was sind print und input',
      'que son print e input',
    ],
    answerTr:
        'print ekrana yazı basar, input ise kullanıcıdan bilgi alır.\n\n'
        'isim = input("Adin ne? ")\n'
        'print("Merhaba " + isim)\n\n'
        'Önemli: input her zaman metin döndürür. Sayı olarak kullanacaksan '
        'int(input(...)) yazmalısın.',
    answerEn:
        'print writes to the screen, and input asks the user for information.\n\n'
        'name = input("What is your name? ")\n'
        'print("Hello " + name)\n\n'
        'Important: input always returns text. If you need a number, write '
        'int(input(...)).',
    answerDe:
        'print schreibt auf den Bildschirm, input fragt die Benutzerin nach '
        'einer Eingabe.\n\nname = input("Wie heisst du? ")\nprint("Hallo " + '
        'name)\n\nWichtig: input gibt immer Text zurück. Wenn du eine Zahl '
        'brauchst, schreib int(input(...)).',
    answerEs:
        'print escribe en la pantalla e input pide información a quien usa el '
        'programa.\n\nnombre = input("¿Cómo te llamas? ")\nprint("Hola " + '
        'nombre)\n\nImportante: input siempre devuelve texto. Si necesitas un '
        'número, escribe int(input(...)).',
    relatedIds: ['python', 'data_types'],
  ),
  KnowledgeEntry(
    id: 'loop_types',
    keywords: [
      'for dongusu',
      'while dongusu',
      'ic ice dongu',
      'sonsuz dongu',
      'for while farki',
      'for ve while',
      'while farki',
      'nested loop',
      'unterschied zwischen for und while',
      'verschachtelte schleife',
      'endlosschleife',
      'diferencia entre for y while',
      'bucle anidado',
      'bucle infinito',
      'for ve while farki ne',
      'for vs while what is the difference',
      'was ist der unterschied zwischen for und while',
      'que diferencia hay entre for y while',
      'for vs while',
      'for and while',
      'entre for y while',
      'for oder while',
    ],
    answerTr:
        'İki tür döngü vardır:\n\n'
        '- for: kaç kere tekrarlayacağını biliyorsan (for i in range(5))\n'
        '- while: bir koşul doğru olduğu sürece (while can > 0)\n\n'
        'İç içe döngü, bir döngünün içinde başka bir döngüdür; tablo ya da ızgara '
        'çizerken kullanılır.\n\n'
        'Dikkat: while içinde koşulu değiştirmezsen sonsuz döngüye girersin.',
    answerEn:
        'There are two kinds of loops:\n\n'
        '- for: when you know how many repeats you need (for i in range(5))\n'
        '- while: as long as a condition stays true (while lives > 0)\n\n'
        'A nested loop is a loop inside another loop; you use it to draw tables or grids.\n\n'
        'Careful: if you never change the condition inside a while, you get an infinite loop.',
    answerDe:
        'Es gibt zwei Arten von Schleifen:\n\n- for: wenn du weißt, wie oft '
        'wiederholt wird (for i in range(5))\n- while: solange eine Bedingung '
        'wahr bleibt (while leben > 0)\n\nEine verschachtelte Schleife ist '
        'eine Schleife in einer Schleife; damit zeichnest du Tabellen oder '
        'Raster.\n\nVorsicht: Änderst du die Bedingung im while nie, bekommst '
        'du eine Endlosschleife.',
    answerEs:
        'Hay dos tipos de bucles:\n\n- for: cuando sabes cuántas repeticiones '
        'necesitas (for i in range(5))\n- while: mientras una condición siga '
        'siendo verdadera (while vidas > 0)\n\nUn bucle anidado es un bucle '
        'dentro de otro; se usa para dibujar tablas o cuadrículas.\n\nOjo: si '
        'nunca cambias la condición del while, tendrás un bucle infinito.',
    relatedIds: ['loop', 'condition'],
  ),
  KnowledgeEntry(
    id: 'ai',
    keywords: [
      'yapay zeka',
      'makine ogrenmesi',
      'machine learning',
      'chatgpt',
      'artificial intelligence',
      'kunstliche intelligenz',
      'ki',
      'inteligencia artificial',
      'ia',
      'maschinelles lernen',
      'aprendizaje automatico',
      'yapay zeka nedir',
      'what is artificial intelligence',
      'was ist kunstliche intelligenz',
      'que es la inteligencia artificial',
    ],
    answerTr:
        'Yapay zekâ, bilgisayarın örneklerden öğrenip tahmin yapmasıdır. Kediyi '
        'tanıması için binlerce kedi fotoğrafı gösterirsin, o da ortak özellikleri '
        'çıkarır.\n\n'
        'Sihirli değil: arkasında matematik ve çok fazla veri var. Yapay zekâ '
        'öğrenmek istiyorsan önce Python ve matematik iyi bir temel.',
    answerEn:
        'Artificial intelligence is a computer learning from examples and making '
        'predictions. To teach it what a cat is, you show thousands of cat photos and '
        'it works out the shared features.\n\n'
        'It is not magic: there is maths and a lot of data behind it. If you want to '
        'learn AI, Python and maths are the right base to start from.',
    answerDe:
        'Künstliche Intelligenz heißt, dass ein Computer aus Beispielen lernt '
        'und Vorhersagen trifft. Damit er weiß, was eine Katze ist, zeigst du '
        'ihm tausende Katzenfotos, und er findet die gemeinsamen Merkmale '
        'heraus.\n\nDas ist keine Zauberei: Dahinter stecken Mathematik und '
        'sehr viele Daten. Wenn du KI lernen willst, sind Python und Mathe '
        'die richtige Grundlage.',
    answerEs:
        'La inteligencia artificial es un ordenador que aprende de ejemplos y '
        'hace predicciones. Para enseñarle qué es un gato, le muestras miles '
        'de fotos de gatos y él deduce los rasgos comunes.\n\nNo es magia: '
        'detrás hay matemáticas y muchísimos datos. Si quieres aprender IA, '
        'Python y matemáticas son la base adecuada.',
    relatedIds: ['python', 'math_needed'],
  ),
  KnowledgeEntry(
    id: 'internet',
    keywords: [
      'internet nedir',
      'web nedir',
      'tarayici',
      'sunucu',
      'ip adresi',
      'browser',
      'wie funktioniert das internet',
      'como funciona internet',
      'server',
      'servidor',
      'navegador',
      'internet nasil calisir',
      'how does the internet work',
    ],
    answerTr:
        'İnternet, dünyadaki bilgisayarların birbirine bağlandığı devasa bir ağdır. '
        'Bir siteye girdiğinde tarayıcın, o sitenin dosyalarını tutan sunucuya istek '
        'gönderir; sunucu da HTML dosyasını geri yollar.\n\n'
        'Her cihazın adresi vardır, buna IP adresi denir. Alan adları (devkom.com.tr '
        'gibi) bu adresleri akılda tutmayı kolaylaştırır.',
    answerEn:
        'The internet is a huge network where computers around the world connect. When '
        'you open a site, your browser sends a request to the server that holds its '
        'files, and the server sends the HTML back.\n\n'
        'Every device has an address called an IP address. Domain names (like '
        'devkom.com.tr) make those addresses easy to remember.',
    answerDe:
        'Das Internet ist ein riesiges Netz, in dem Computer auf der ganzen '
        'Welt verbunden sind. Wenn du eine Seite öffnest, schickt dein '
        'Browser eine Anfrage an den Server, auf dem die Dateien liegen, und '
        'der Server schickt das HTML zurück.\n\nJedes Gerät hat eine Adresse, '
        'die IP Adresse heißt. Domainnamen (wie devkom.com.tr) machen diese '
        'Adressen leicht merkbar.',
    answerEs:
        'Internet es una red enorme donde se conectan ordenadores de todo el '
        'mundo. Cuando abres un sitio, tu navegador envía una petición al '
        'servidor que guarda sus archivos y el servidor devuelve el '
        'HTML.\n\nCada dispositivo tiene una dirección llamada dirección IP. '
        'Los nombres de dominio (como devkom.com.tr) hacen que esas '
        'direcciones sean fáciles de recordar.',
    relatedIds: ['html', 'website'],
  ),
  KnowledgeEntry(
    id: 'computer_basics',
    keywords: [
      'bilgisayar nedir',
      'donanim',
      'yazilim',
      'islemci',
      'ram nedir',
      'isletim sistemi',
      'wie funktioniert ein computer',
      'como funciona un ordenador',
      'hardware',
      'software',
      'prozessor',
      'procesador',
      'ordenador',
      'bilgisayar nasil calisir',
      'how does a computer work',
    ],
    answerTr:
        'Bilgisayarın iki yanı vardır: donanım (elle tuttuğun parçalar) ve yazılım '
        '(çalışan programlar).\n\n'
        '- İşlemci (CPU): hesapları yapar, beyin gibidir\n'
        '- RAM: açık programları geçici tutar, masa gibidir\n'
        '- Disk: dosyaları kalıcı saklar, dolap gibidir\n\n'
        'Yazdığın kod da sonunda işlemcinin anladığı komutlara çevrilir.',
    answerEn:
        'A computer has two sides: hardware (the parts you can touch) and software '
        '(the programs that run).\n\n'
        '- Processor (CPU): does the calculations, like a brain\n'
        '- RAM: holds open programs temporarily, like a desk\n'
        '- Disk: stores files permanently, like a cupboard\n\n'
        'The code you write is eventually turned into commands the processor understands.',
    answerDe:
        'Ein Computer hat zwei Seiten: Hardware (die Teile, die du anfassen '
        'kannst) und Software (die Programme, die laufen).\n\n- Prozessor '
        '(CPU): rechnet, wie ein Gehirn\n- RAM: hält offene Programme '
        'kurzzeitig, wie ein Schreibtisch\n- Festplatte: speichert Dateien '
        'dauerhaft, wie ein Schrank\n\nDer Code, den du schreibst, wird am '
        'Ende in Befehle übersetzt, die der Prozessor versteht.',
    answerEs:
        'Un ordenador tiene dos caras: el hardware (las piezas que puedes '
        'tocar) y el software (los programas que se ejecutan).\n\n- '
        'Procesador (CPU): hace los cálculos, como un cerebro\n- RAM: guarda '
        'los programas abiertos de forma temporal, como un escritorio\n- '
        'Disco: guarda los archivos de forma permanente, como un '
        'armario\n\nEl código que escribes acaba convertido en órdenes que el '
        'procesador entiende.',
    relatedIds: ['algorithm'],
  ),
  KnowledgeEntry(
    id: 'make_game',
    keywords: [
      'oyun yapmak',
      'oyun nasil yapilir',
      'oyun gelistirme',
      'make a game',
      'wie baue ich ein spiel',
      'spiel bauen',
      'como hago un juego',
      'hacer un juego',
      'crear un juego',
      'nasil oyun yaparim',
      'how do i make a game',
    ],
    answerTr:
        'Oyun yapmak sandığından kolay başlıyor. Sıra şöyle:\n\n'
        '1. Scratch\'te basit bir yakalama oyunu (karakter, puan, süre)\n'
        '2. Python + Pygame ile klavyeyle kontrol edilen bir oyun\n'
        '3. Daha büyük projeler için Unity ya da Godot\n\n'
        'İlk oyunun küçük olsun: tek ekran, tek kural. Bitirdiğin küçük oyun, '
        'bitiremediğin büyük oyundan iyidir.',
    answerEn:
        'Making a game starts easier than you think. The order is:\n\n'
        '1. A simple catch game in Scratch (character, score, timer)\n'
        '2. A keyboard controlled game with Python and Pygame\n'
        '3. Unity or Godot for bigger projects\n\n'
        'Keep your first game small: one screen, one rule. A small finished game beats '
        'a big unfinished one.',
    answerDe:
        'Ein Spiel zu bauen fängt leichter an, als du denkst. Die '
        'Reihenfolge:\n\n1. Ein einfaches Fangspiel in Scratch (Figur, '
        'Punkte, Zeit)\n2. Ein Spiel mit Tastatursteuerung in Python und '
        'Pygame\n3. Unity oder Godot für größere Projekte\n\nHalte dein '
        'erstes Spiel klein: ein Bildschirm, eine Regel. Ein kleines fertiges '
        'Spiel ist mehr wert als ein großes unfertiges.',
    answerEs:
        'Hacer un juego empieza más fácil de lo que crees. El orden es:\n\n1. '
        'Un juego sencillo de atrapar en Scratch (personaje, puntos, '
        'tiempo)\n2. Un juego con teclado usando Python y Pygame\n3. Unity o '
        'Godot para proyectos más grandes\n\nQue tu primer juego sea pequeño: '
        'una pantalla, una regla. Un juego pequeño terminado vale más que uno '
        'grande sin acabar.',
    relatedIds: ['scratch', 'python', 'games'],
  ),
  KnowledgeEntry(
    id: 'make_app',
    keywords: [
      'uygulama yapmak',
      'mobil uygulama',
      'app yapmak',
      'flutter',
      'telefon uygulamasi',
      'wie baue ich eine app',
      'app bauen',
      'como hago una aplicacion',
      'crear una app',
      'aplicacion movil',
      'nasil uygulama yaparim',
      'how do i make an app',
    ],
    answerTr:
        'Telefon uygulaması yapmak için bir arayüz aracı ve bir dil gerekir. '
        'Kullandığın bu uygulama Flutter ile yazıldı; Flutter, Dart dilini kullanır ve '
        'tek koddan hem Android hem iPhone uygulaması çıkarır.\n\n'
        'Yol haritası: önce Python ya da JavaScript ile programlama mantığını öğren, '
        'sonra Flutter\'a geç.',
    answerEn:
        'To build a phone app you need an interface toolkit and a language. The app you '
        'are using was written with Flutter; Flutter uses the Dart language and builds '
        'both Android and iPhone apps from one codebase.\n\n'
        'Roadmap: learn programming logic with Python or JavaScript first, then move to '
        'Flutter.',
    answerDe:
        'Für eine Handy App brauchst du ein Werkzeug für die Oberfläche und '
        'eine Sprache. Die App, die du gerade benutzt, wurde mit Flutter '
        'gebaut; Flutter nutzt die Sprache Dart und macht aus einem Code '
        'sowohl eine Android als auch eine iPhone App.\n\nFahrplan: Lerne die '
        'Programmierlogik zuerst mit Python oder JavaScript, dann wechsle zu '
        'Flutter.',
    answerEs:
        'Para hacer una aplicación de móvil necesitas una herramienta de '
        'interfaz y un lenguaje. La app que estás usando se hizo con Flutter; '
        'Flutter usa el lenguaje Dart y crea aplicaciones de Android y de '
        'iPhone con un solo código.\n\nHoja de ruta: aprende la lógica de '
        'programación con Python o JavaScript y luego pasa a Flutter.',
    relatedIds: ['python', 'javascript'],
  ),
  KnowledgeEntry(
    id: 'website',
    keywords: [
      'web sitesi yapmak',
      'site yapmak',
      'internet sitesi',
      'sayfa yapmak',
      'webseite bauen',
      'wie baue ich eine webseite',
      'hacer una pagina web',
      'crear una web',
      'nasil web sitesi yaparim',
      'how do i build a website',
      'como hago una pagina web',
    ],
    answerTr:
        'Bir web sitesi üç parçadan oluşur:\n\n'
        '- HTML: içerik ve yapı (başlık, paragraf, resim)\n'
        '- CSS: renkler, yazı tipleri, yerleşim\n'
        '- JavaScript: tıklama, animasyon, form kontrolü\n\n'
        'Uygulamadaki HTML dersinden başla, tek bir sayfa yapmak bile birkaç saat '
        'sürer. Sonra CSS ile güzelleştir.',
    answerEn:
        'A website has three parts:\n\n'
        '- HTML: content and structure (headings, paragraphs, images)\n'
        '- CSS: colours, fonts, layout\n'
        '- JavaScript: clicks, animation, form checks\n\n'
        'Start with the HTML lesson in the app; even a single page takes a couple of '
        'hours. Then make it pretty with CSS.',
    answerDe:
        'Eine Webseite besteht aus drei Teilen:\n\n- HTML: Inhalt und Aufbau '
        '(Überschriften, Absätze, Bilder)\n- CSS: Farben, Schriften, '
        'Anordnung\n- JavaScript: Klicks, Animation, Formularprüfung\n\nFang '
        'mit der HTML Lektion in der App an; schon eine einzige Seite dauert '
        'ein paar Stunden. Danach machst du sie mit CSS schön.',
    answerEs:
        'Una página web tiene tres partes:\n\n- HTML: contenido y estructura '
        '(títulos, párrafos, imágenes)\n- CSS: colores, tipografías, '
        'distribución\n- JavaScript: clics, animación, validación de '
        'formularios\n\nEmpieza por la lección de HTML de la app; incluso una '
        'sola página lleva un par de horas. Después la embelleces con CSS.',
    relatedIds: ['html', 'css', 'javascript'],
  ),
  KnowledgeEntry(
    id: 'database',
    keywords: [
      'veri tabani',
      'veritabani',
      'database',
      'sql nedir',
      'datenbank',
      'base de datos',
      'veri tabani nedir',
      'what is a database',
      'was ist eine datenbank',
      'que es una base de datos',
    ],
    answerTr:
        'Veri tabanı, bilgilerin düzenli saklandığı yerdir. Kullanıcı adları, puanlar, '
        'ders ilerlemesi hep orada tutulur.\n\n'
        'Excel tablosu gibi düşün: satırlar kayıtlar, sütunlar özellikler. SQL ise bu '
        'tablolara soru sorma dilidir: "puanı 100\'den büyük olanları getir" gibi.',
    answerEn:
        'A database is where information is stored in an organised way: usernames, '
        'scores and lesson progress all live there.\n\n'
        'Think of a spreadsheet: rows are records and columns are properties. SQL is '
        'the language for asking those tables questions, like "give me everyone with a '
        'score above 100".',
    answerDe:
        'Eine Datenbank ist der Ort, an dem Informationen geordnet '
        'gespeichert werden: Benutzernamen, Punkte und Lernfortschritt liegen '
        'alle dort.\n\nStell dir eine Tabelle vor: Zeilen sind Einträge, '
        'Spalten sind Eigenschaften. SQL ist die Sprache, mit der man diesen '
        'Tabellen Fragen stellt, etwa "gib mir alle mit mehr als 100 '
        'Punkten".',
    answerEs:
        'Una base de datos es donde se guarda la información de forma '
        'ordenada: nombres de usuario, puntuaciones y progreso de las '
        'lecciones viven ahí.\n\nPiensa en una hoja de cálculo: las filas son '
        'registros y las columnas son propiedades. SQL es el lenguaje para '
        'hacerle preguntas a esas tablas, como "dame todos los que tengan más '
        'de 100 puntos".',
    relatedIds: ['computer_basics'],
  ),
  KnowledgeEntry(
    id: 'sensor',
    keywords: [
      'sensor',
      'mesafe sensoru',
      'isik sensoru',
      'sicaklik sensoru',
      'algilayici',
      'sensoren',
      'sensores',
      'abstandssensor',
      'sensor de distancia',
      'sensor nedir',
      'what is a sensor',
      'was ist ein sensor',
      'que es un sensor',
    ],
    answerTr:
        'Sensör, robotun duyu organıdır: çevredeki bilgiyi ölçüp sayıya çevirir.\n\n'
        '- Ultrasonik: önündeki engelin uzaklığını ölçer\n'
        '- Işık (LDR): ortam aydınlık mı karanlık mı\n'
        '- Sıcaklık: derece ölçer\n'
        '- Çizgi sensörü: zeminin siyah mı beyaz mı olduğunu anlar\n\n'
        'Kodun bu sayıyı okur, koşulla karar verir: "engel 10 cm\'den yakınsa dur".',
    answerEn:
        'A sensor is a robot\'s sense organ: it measures the world and turns it into a '
        'number.\n\n'
        '- Ultrasonic: distance to the obstacle ahead\n'
        '- Light (LDR): whether the room is bright or dark\n'
        '- Temperature: degrees\n'
        '- Line sensor: whether the floor is black or white\n\n'
        'Your code reads that number and decides with a condition: "if the obstacle is '
        'closer than 10 cm, stop".',
    answerDe:
        'Ein Sensor ist das Sinnesorgan eines Roboters: Er misst die Umgebung '
        'und macht daraus eine Zahl.\n\n- Ultraschall: Abstand zum Hindernis '
        'davor\n- Licht (LDR): ob es hell oder dunkel ist\n- Temperatur: '
        'Grad\n- Liniensensor: ob der Boden schwarz oder weiß ist\n\nDein '
        'Code liest diese Zahl und entscheidet mit einer Bedingung: "wenn das '
        'Hindernis näher als 10 cm ist, halte an".',
    answerEs:
        'Un sensor es el órgano de los sentidos de un robot: mide el mundo y '
        'lo convierte en un número.\n\n- Ultrasonido: la distancia al '
        'obstáculo de delante\n- Luz (LDR): si hay claridad u oscuridad\n- '
        'Temperatura: grados\n- Sensor de línea: si el suelo es negro o '
        'blanco\n\nTu código lee ese número y decide con una condición: "si '
        'el obstáculo está a menos de 10 cm, para".',
    relatedIds: ['arduino', 'robotics', 'condition'],
  ),
  KnowledgeEntry(
    id: 'motor_led',
    keywords: [
      'motor',
      'servo',
      'led yakmak',
      'lamba yakmak',
      'buton',
      'dugme',
      'motoren',
      'motores',
      'lampe',
      'knopf',
      'taster',
      'boton',
      'led ve motor nasil calisir',
      'how do leds and motors work',
      'wie funktionieren leds und motoren',
      'como funcionan los led y los motores',
    ],
    answerTr:
        'Robotun hareket eden ve ışık veren parçaları:\n\n'
        '- LED: küçük ışık. Arduino\'da digitalWrite(13, HIGH) ile yakılır\n'
        '- Buton: basılı mı diye digitalRead ile okunur\n'
        '- DC motor: sürekli döner, tekerlek için\n'
        '- Servo motor: belirli bir açıya döner (0-180), kol ya da direksiyon için\n\n'
        'İlk projen "Blink" olsun: bir LED\'i saniyede bir yakıp söndür.',
    answerEn:
        'The parts of a robot that move and light up:\n\n'
        '- LED: a small light, turned on with digitalWrite(13, HIGH) on Arduino\n'
        '- Button: read with digitalRead to see if it is pressed\n'
        '- DC motor: spins continuously, good for wheels\n'
        '- Servo motor: turns to a set angle (0-180), good for arms or steering\n\n'
        'Make "Blink" your first project: turn an LED on and off once a second.',
    answerDe:
        'Die Teile eines Roboters, die sich bewegen und leuchten:\n\n- LED: '
        'ein kleines Licht, auf dem Arduino mit digitalWrite(13, HIGH) '
        'eingeschaltet\n- Knopf: mit digitalRead auslesen, ob er gedrückt '
        'ist\n- DC Motor: dreht sich dauerhaft, gut für Räder\n- Servomotor: '
        'dreht auf einen festen Winkel (0-180), gut für Arme oder '
        'Lenkung\n\nMach "Blink" zu deinem ersten Projekt: eine LED einmal '
        'pro Sekunde an und aus.',
    answerEs:
        'Las partes de un robot que se mueven y se encienden:\n\n- LED: una '
        'luz pequeña, se enciende con digitalWrite(13, HIGH) en Arduino\n- '
        'Botón: se lee con digitalRead para saber si está pulsado\n- Motor '
        'DC: gira sin parar, va bien para ruedas\n- Servomotor: gira hasta un '
        'ángulo concreto (0-180), va bien para brazos o dirección\n\nQue '
        '"Blink" sea tu primer proyecto: encender y apagar un LED una vez por '
        'segundo.',
    relatedIds: ['arduino', 'sensor'],
  ),
  KnowledgeEntry(
    id: 'security',
    keywords: [
      'sifre guvenligi',
      'guvenli sifre',
      'hacker',
      'virus',
      'siber guvenlik',
      'passwort',
      'sicherheit',
      'contrasena',
      'seguridad',
      'internette nasil guvende olurum',
      'how do i stay safe online',
      'wie bleibe ich online sicher',
      'como me mantengo seguro en internet',
    ],
    answerTr:
        'Birkaç kural seni güvende tutar:\n\n'
        '- Şifreni kimseyle paylaşma, aileni bile uygulamaya kaydederken yanında iste\n'
        '- Şifre uzun olsun ve doğum tarihin olmasın\n'
        '- Tanımadığın bağlantılara tıklama, bilinmeyen dosya indirme\n'
        '- İnternette gerçek adını, adresini, okulunu yazma\n\n'
        'Kötü bir şeyle karşılaşırsan hemen bir büyüğüne söyle.',
    answerEn:
        'A few rules keep you safe:\n\n'
        '- Never share your password; ask a parent to be with you when you sign up\n'
        '- Make passwords long and never use your birthday\n'
        '- Do not click unknown links or download unknown files\n'
        '- Do not post your real name, address or school online\n\n'
        'If something bad happens, tell a grown up straight away.',
    answerDe:
        'Ein paar Regeln halten dich sicher:\n\n- Teile dein Passwort mit '
        'niemandem; bitte ein Elternteil, beim Anmelden dabei zu sein\n- Mach '
        'Passwörter lang und nimm nie deinen Geburtstag\n- Klicke keine '
        'unbekannten Links an und lade keine unbekannten Dateien herunter\n- '
        'Schreib deinen echten Namen, deine Adresse oder deine Schule nicht '
        'ins Internet\n\nWenn etwas Unangenehmes passiert, sag sofort einem '
        'Erwachsenen Bescheid.',
    answerEs:
        'Unas pocas reglas te mantienen a salvo:\n\n- No compartas tu '
        'contraseña con nadie; pide a un adulto que te acompañe al '
        'registrarte\n- Que las contraseñas sean largas y nunca uses tu fecha '
        'de nacimiento\n- No pulses enlaces desconocidos ni descargues '
        'archivos desconocidos\n- No publiques tu nombre real, tu dirección '
        'ni tu colegio\n\nSi pasa algo desagradable, díselo enseguida a una '
        'persona adulta.',
  ),
  KnowledgeEntry(
    id: 'career',
    keywords: [
      'yazilimci olmak',
      'muhendis olmak',
      'meslek',
      'kariyer',
      'buyuyunce',
      'programmierer werden',
      'programmierer',
      'programmiererin',
      'programador',
      'programadora',
      'beruf',
      'profesion',
      'yazilimci nasil olunur',
      'how do i become a developer',
      'wie werde ich programmiererin',
      'como llego a ser programadora',
    ],
    answerTr:
        'Yazılımcı olmak için üniversite şart değil ama matematik ve İngilizce çok '
        'işine yarar. Önemli olan proje yapmak.\n\n'
        'Yol: Scratch ile mantığı öğren, Python ile gerçek kod yaz, sonra ilgini çeken '
        'alanı seç - oyun, web, mobil, yapay zekâ ya da robotik. Yaptığın her projeyi '
        'sakla, zamanla portfolyon olur.',
    answerEn:
        'You do not strictly need a university degree to become a developer, but maths '
        'and English help a lot. What matters most is building projects.\n\n'
        'The path: learn the logic in Scratch, write real code in Python, then pick the '
        'area you like - games, web, mobile, AI or robotics. Keep every project you '
        'make; over time it becomes your portfolio.',
    answerDe:
        'Für den Beruf Programmiererin brauchst du nicht zwingend ein '
        'Studium, aber Mathe und Englisch helfen sehr. Am meisten zählt, '
        'Projekte zu bauen.\n\nDer Weg: Lerne die Logik in Scratch, schreib '
        'echten Code in Python, und such dir dann den Bereich aus, der dich '
        'interessiert - Spiele, Web, Mobile, KI oder Robotik. Heb jedes '
        'Projekt auf; mit der Zeit wird daraus dein Portfolio.',
    answerEs:
        'No hace falta una carrera universitaria para ser programadora, pero '
        'las matemáticas y el inglés ayudan mucho. Lo que más cuenta es hacer '
        'proyectos.\n\nEl camino: aprende la lógica en Scratch, escribe '
        'código de verdad en Python y luego elige el área que te guste: '
        'juegos, web, móvil, IA o robótica. Guarda todos tus proyectos; con '
        'el tiempo se convierten en tu portafolio.',
    relatedIds: ['where_start', 'make_game'],
  ),
  KnowledgeEntry(
    id: 'math_needed',
    keywords: [
      'matematik gerekli',
      'matematik lazim',
      'matematik bilmek',
      'ingilizce gerekli',
      'ingilizce lazim',
      'brauche ich mathe',
      'mathe',
      'matematicas',
      'necesito matematicas',
      'englisch',
      'ingles',
      'matematik gerekli mi',
      'do i need maths',
    ],
    answerTr:
        'Başlamak için ikisi de şart değil.\n\n'
        'Matematik: temel dört işlem yeter. Oyun ve yapay zekaya girersen geometri ve '
        'olasılık işine yarar.\n\n'
        'İngilizce: komutlar İngilizce (print, if, while) ama bunlar 20-30 kelime. '
        'Zamanla kendiliğinden öğreniyorsun.',
    answerEn:
        'Neither is required to start.\n\n'
        'Maths: basic arithmetic is enough. If you move into games or AI, geometry and '
        'probability become useful.\n\n'
        'English: the commands are English (print, if, while) but that is only 20-30 '
        'words, and you pick them up as you go.',
    answerDe:
        'Zum Anfangen brauchst du beides nicht.\n\nMathe: Die '
        'Grundrechenarten reichen. Wenn du zu Spielen oder KI gehst, werden '
        'Geometrie und Wahrscheinlichkeit nützlich.\n\nEnglisch: Die Befehle '
        'sind englisch (print, if, while), aber das sind nur 20-30 Wörter, '
        'und die lernst du ganz nebenbei.',
    answerEs:
        'Para empezar no necesitas ninguna de las dos.\n\nMatemáticas: con '
        'las operaciones básicas basta. Si te metes en juegos o en IA, la '
        'geometría y la probabilidad vienen bien.\n\nInglés: las órdenes '
        'están en inglés (print, if, while), pero son solo 20 o 30 palabras y '
        'se aprenden sobre la marcha.',
    relatedIds: ['where_start'],
  ),
  KnowledgeEntry(
    id: 'how_long',
    keywords: [
      'ne kadar calismaliyim',
      'gunde kac saat',
      'ne kadar surer',
      'kac gunde ogrenirim',
      'wie lange',
      'taglich uben',
      'cuanto debo practicar',
      'cuanto tiempo',
      'gunde ne kadar calismaliyim',
      'how long should i practise',
      'wie lange soll ich uben',
    ],
    answerTr:
        'Günde 15-20 dakika, haftanın 5 günü. Uzun ama seyrek çalışmaktan çok daha '
        'iyi sonuç verir.\n\n'
        'Kaba bir tahmin: Scratch\'in temelleri 2-3 hafta, Python\'un temelleri 1-2 ay. '
        'Ama asıl ölçü süre değil, bitirdiğin proje sayısı.',
    answerEn:
        'Fifteen to twenty minutes a day, five days a week. That beats long but rare '
        'sessions by a wide margin.\n\n'
        'A rough estimate: the basics of Scratch take 2-3 weeks, the basics of Python '
        '1-2 months. But the real measure is how many projects you finish, not hours.',
    answerDe:
        'Fünfzehn bis zwanzig Minuten am Tag, an fünf Tagen die Woche. Das '
        'bringt viel mehr als lange, aber seltene Einheiten.\n\nGrober '
        'Richtwert: Die Grundlagen von Scratch dauern 2-3 Wochen, die '
        'Grundlagen von Python 1-2 Monate. Der echte Maßstab ist aber nicht '
        'die Zeit, sondern wie viele Projekte du fertig bekommst.',
    answerEs:
        'Quince o veinte minutos al día, cinco días a la semana. Eso funciona '
        'mucho mejor que sesiones largas y espaciadas.\n\nUn cálculo '
        'aproximado: lo básico de Scratch lleva 2 o 3 semanas y lo básico de '
        'Python 1 o 2 meses. Pero la medida de verdad no son las horas, sino '
        'cuántos proyectos terminas.',
    relatedIds: ['streak', 'quest'],
  ),

  // ------------------------------------------------------------ uygulama (ek)
  KnowledgeEntry(
    id: 'pro',
    keywords: [
      'pro nedir',
      'pro uyelik',
      'premium',
      'abonelik',
      'pro ne ise yarar',
      'pro mitgliedschaft',
      'abo',
      'suscripcion',
      'pro ne sunuyor',
      'what does pro offer',
      'was bietet pro',
      'que ofrece pro',
    ],
    answerTr:
        'Pro üyelik, uygulamanın kilitli bölümlerini açar:\n\n'
        '- Pro kurslar ve ileri seviye oyunlar\n'
        '- Pro görev kademesi (daha yüksek XP)\n'
        '- İlerleme raporu ve sertifika\n\n'
        'Video serileri ve temel dersler herkese açık, onlar için Pro gerekmiyor. '
        'Satın alma işlemini bir büyüğünle birlikte yapmalısın.',
    answerEn:
        'Pro membership unlocks the locked parts of the app:\n\n'
        '- Pro courses and advanced games\n'
        '- The Pro quest tier with higher XP\n'
        '- The progress report and the certificate\n\n'
        'Video series and the core lessons are free for everyone. Ask a grown up to be '
        'with you for any purchase.',
    answerDe:
        'Die Pro Mitgliedschaft schaltet die gesperrten Bereiche der App '
        'frei:\n\n- Pro Kurse und fortgeschrittene Spiele\n- Die Pro '
        'Aufgabenstufe mit mehr XP\n- Den Fortschrittsbericht und das '
        'Zertifikat\n\nDie Videoreihen und die Grundlektionen sind für alle '
        'kostenlos. Bitte einen Erwachsenen, bei jedem Kauf dabei zu sein.',
    answerEs:
        'La suscripción Pro desbloquea las partes cerradas de la app:\n\n- '
        'Cursos Pro y juegos avanzados\n- El nivel de misiones Pro, con más '
        'XP\n- El informe de progreso y el certificado\n\nLas series de vídeo '
        'y las lecciones básicas son gratis para todos. Pide a una persona '
        'adulta que te acompañe en cualquier compra.',
    relatedIds: ['certificate', 'report'],
  ),
  KnowledgeEntry(
    id: 'certificate',
    keywords: [
      'sertifika',
      'certificate',
      'belge alma',
      'zertifikat',
      'certificado',
      'sertifika nedir',
      'what is the certificate',
      'was ist das zertifikat',
      'que es el certificado',
    ],
    answerTr:
        'Sertifika, tamamladığın kursları ve topladığın XP\'yi gösteren bir belgedir. '
        'Adın, seviyeni ve tarihi taşır; görsel olarak kaydedip paylaşabilirsin.\n\n'
        'Profil ekranından ulaşabilirsin. Yeterli ilerlemeyi tamamladığında açılır.',
    answerEn:
        'The certificate is a document showing the courses you finished and the XP you '
        'collected. It carries your name, your level and the date, and you can save it '
        'as an image and share it.\n\n'
        'You reach it from the Profile screen; it unlocks once you have made enough '
        'progress.',
    answerDe:
        'Das Zertifikat ist ein Dokument, das die abgeschlossenen Kurse und '
        'die gesammelten XP zeigt. Es trägt deinen Namen, dein Level und das '
        'Datum; du kannst es als Bild speichern und teilen.\n\nDu erreichst '
        'es über den Profil Bildschirm; es wird freigeschaltet, sobald du '
        'genug Fortschritt gemacht hast.',
    answerEs:
        'El certificado es un documento que muestra los cursos que has '
        'terminado y los XP que has reunido. Lleva tu nombre, tu nivel y la '
        'fecha, y puedes guardarlo como imagen y compartirlo.\n\nSe abre '
        'desde la pantalla de Perfil y se desbloquea cuando has avanzado lo '
        'suficiente.',
    relatedIds: ['report', 'xp'],
  ),
  KnowledgeEntry(
    id: 'report',
    keywords: [
      'ilerleme raporu',
      'gelisim raporu',
      'rapor',
      'progress report',
      'fortschrittsbericht',
      'bericht',
      'informe',
      'informe de progreso',
      'ilerleme raporu nedir',
      'what is the progress report',
      'was ist der fortschrittsbericht',
      'que es el informe de progreso',
    ],
    answerTr:
        'İlerleme raporu; kaç ders bitirdiğini, hangi oyunlarda ne kadar ilerlediğini, '
        'toplam XP ve seri gününü tek sayfada gösterir.\n\n'
        'Profil ekranından açılır. Aileye göstermek için pratik bir özet.',
    answerEn:
        'The progress report shows how many lessons you finished, how far you got in '
        'each game, your total XP and your streak, all on one page.\n\n'
        'You open it from the Profile screen. It is a handy summary to show your family.',
    answerDe:
        'Der Fortschrittsbericht zeigt auf einer Seite, wie viele Lektionen '
        'du beendet hast, wie weit du in jedem Spiel gekommen bist, deine '
        'gesamten XP und deine Serie.\n\nDu öffnest ihn über den Profil '
        'Bildschirm. Eine praktische Übersicht, um sie deiner Familie zu '
        'zeigen.',
    answerEs:
        'El informe de progreso muestra en una sola página cuántas lecciones '
        'has terminado, hasta dónde has llegado en cada juego, tus XP totales '
        'y tu racha.\n\nSe abre desde la pantalla de Perfil. Es un resumen '
        'práctico para enseñárselo a tu familia.',
    relatedIds: ['certificate', 'xp'],
  ),
  KnowledgeEntry(
    id: 'profile',
    keywords: [
      'profil',
      'nickname',
      'takma ad',
      'isim degistir',
      'avatar',
      'karakter',
      'perfil',
      'spitzname',
      'apodo',
      'profilimi nasil degistiririm',
      'how do i change my profile',
      'wie andere ich mein profil',
      'como cambio mi perfil',
    ],
    answerTr:
        'Profil ekranında karakterin en üstte görünür, altında takma adın yazar. '
        'Adının yanındaki kalem simgesine dokunarak takma adını değiştirebilirsin.\n\n'
        'Aynı ekranda seviyen, XP\'n, rozetlerin ve raporun da bulunur.',
    answerEn:
        'On the Profile screen your character appears at the top with your nickname '
        'below it. Tap the pencil next to your name to change the nickname.\n\n'
        'The same screen shows your level, XP, badges and your report.',
    answerDe:
        'Auf dem Profil Bildschirm steht deine Figur oben und darunter dein '
        'Spitzname. Tippe auf den Stift neben deinem Namen, um den Spitznamen '
        'zu ändern.\n\nDerselbe Bildschirm zeigt dein Level, deine XP, deine '
        'Abzeichen und deinen Bericht.',
    answerEs:
        'En la pantalla de Perfil tu personaje aparece arriba y debajo está '
        'tu apodo. Toca el lápiz que hay al lado del nombre para '
        'cambiarlo.\n\nEsa misma pantalla muestra tu nivel, tus XP, tus '
        'insignias y tu informe.',
    relatedIds: ['xp', 'badge'],
  ),
  KnowledgeEntry(
    id: 'videos',
    keywords: [
      'video serisi',
      'ders videosu',
      'video izle',
      'videolar',
      'videos',
      'videoreihe',
      'videoreihen',
      'serie de videos',
      'series de video',
      'hangi video serileri var',
      'which video series are there',
      'welche videoreihen gibt es',
      'que series de video hay',
    ],
    answerTr:
        'Video bölümünde Scratch, Python, HTML, Arduino ve mBlock serileri var; her '
        'seri temelden başlayıp zorlaşıyor.\n\n'
        'Bir bölümü bitirdiğinde otomatik olarak izlendi işaretlenir, XP ve jeton '
        'kazanırsın, sonraki bölüme geçer. Videolar herkese açık, Pro gerekmiyor.',
    answerEn:
        'The video section has Scratch, Python, HTML, Arduino and mBlock series; each '
        'one starts at the basics and gets harder.\n\n'
        'When an episode ends it is marked as watched automatically, you earn XP and '
        'coins, and the next episode starts. Videos are free for everyone.',
    answerDe:
        'Im Videobereich gibt es Reihen zu Scratch, Python, HTML, Arduino und '
        'mBlock; jede fängt bei den Grundlagen an und wird schwerer.\n\nWenn '
        'eine Folge endet, wird sie automatisch als gesehen markiert, du '
        'bekommst XP und Münzen, und die nächste Folge startet. Die Videos '
        'sind für alle kostenlos.',
    answerEs:
        'En la sección de vídeos hay series de Scratch, Python, HTML, Arduino '
        'y mBlock; cada una empieza por lo básico y va subiendo de '
        'dificultad.\n\nCuando termina un episodio se marca como visto '
        'automáticamente, ganas XP y monedas, y empieza el siguiente. Los '
        'vídeos son gratis para todos.',
    relatedIds: ['scratch', 'python', 'mblock'],
  ),

  // ---------------------------------------------------- scratch alt konulari
  KnowledgeEntry(
    id: 'scratch_sprite',
    keywords: [
      'sprite',
      'kukla',
      'karakter ekleme',
      'kostum',
      'kilik',
      'sahne',
      'dekor',
      'figur',
      'figuren',
      'buhne',
      'objeto',
      'disfraz',
      'disfraces',
      'escenario',
      'fondo',
      'kukla ve kostum nedir',
      'what are sprites and costumes',
      'was sind figuren und kostume',
      'que son los objetos y disfraces',
    ],
    answerTr:
        'Scratch\'te üç temel parça vardır:\n\n'
        '- Kukla (sprite): hareket eden karakter. Sağ alttaki kedi simgesinden yeni '
        'kukla eklersin.\n'
        '- Kostüm: aynı kuklanın farklı görünümleri. Kostümleri sırayla değiştirince '
        'yürüme animasyonu olur.\n'
        '- Sahne (dekor): arka plan. Orman, uzay, sınıf gibi hazır dekorlar var.\n\n'
        'Her kuklanın kendi kod alanı vardır; birinde yazdığın kod diğerini etkilemez.',
    answerEn:
        'Scratch has three basic pieces:\n\n'
        '- Sprite: the character that moves. Add a new one from the cat icon at the '
        'bottom right.\n'
        '- Costume: different looks of the same sprite. Switching costumes in order '
        'creates a walking animation.\n'
        '- Stage (backdrop): the background. Forest, space and classroom are ready to use.\n\n'
        'Each sprite has its own code area; code in one does not affect another.',
    answerDe:
        'Scratch hat drei Grundbausteine:\n\n- Figur (Sprite): die Gestalt, '
        'die sich bewegt. Neue fügst du über das Katzensymbol unten rechts '
        'hinzu.\n- Kostüm: verschiedene Aussehen derselben Figur. Wechselst '
        'du Kostüme der Reihe nach, entsteht eine Laufanimation.\n- Bühne '
        '(Bühnenbild): der Hintergrund. Wald, Weltraum und Klassenzimmer sind '
        'schon fertig da.\n\nJede Figur hat ihren eigenen Codebereich; Code '
        'in der einen wirkt nicht auf die andere.',
    answerEs:
        'Scratch tiene tres piezas básicas:\n\n- Objeto (sprite): el '
        'personaje que se mueve. Añades uno nuevo desde el icono del gato de '
        'abajo a la derecha.\n- Disfraz: distintos aspectos del mismo objeto. '
        'Cambiarlos en orden crea una animación de caminar.\n- Escenario '
        '(fondo): el fondo. Bosque, espacio y aula vienen listos para '
        'usar.\n\nCada objeto tiene su propia zona de código; lo que '
        'programas en uno no afecta a otro.',
    relatedIds: ['scratch', 'scratch_events'],
  ),
  KnowledgeEntry(
    id: 'scratch_events',
    keywords: [
      'yesil bayrak',
      'tiklandiginda',
      'mesaj yayinla',
      'haber gonder',
      'olay blogu',
      'when clicked',
      'grune flagge',
      'ereignisblocke',
      'nachricht senden',
      'bandera verde',
      'bloques de eventos',
      'enviar mensaje',
      'olay bloklari ne ise yarar',
      'what do event blocks do',
      'was machen ereignisblocke',
      'que hacen los bloques de eventos',
    ],
    answerTr:
        'Sarı "Olaylar" blokları kodun ne zaman başlayacağını söyler:\n\n'
        '- Yeşil bayrak tıklandığında: projeyi başlatır\n'
        '- Bu kukla tıklandığında: karaktere basınca çalışır\n'
        '- Boşluk tuşuna basıldığında: klavyeyle tetikler\n'
        '- Mesaj yayınla / mesajı aldığımda: iki kukla arasında haberleşme sağlar\n\n'
        'Mesaj yayınla çok işine yarar: kedi "başla" mesajı yollar, top da onu duyup '
        'harekete geçer.',
    answerEn:
        'The yellow Events blocks say when your code starts:\n\n'
        '- When green flag clicked: starts the project\n'
        '- When this sprite clicked: runs when you tap the character\n'
        '- When space key pressed: triggers from the keyboard\n'
        '- Broadcast / when I receive: lets two sprites talk to each other\n\n'
        'Broadcast is very handy: the cat sends a "start" message and the ball hears '
        'it and moves.',
    answerDe:
        'Die gelben Ereignisblöcke sagen, wann dein Code startet:\n\n- Wenn '
        'die grüne Flagge angeklickt: startet das Projekt\n- Wenn diese Figur '
        'angeklickt wird: läuft, wenn du die Figur antippst\n- Wenn Taste '
        'Leertaste gedrückt: löst über die Tastatur aus\n- Sende Nachricht / '
        'Wenn ich Nachricht empfange: lässt zwei Figuren miteinander '
        'reden\n\nNachrichten sind sehr praktisch: Die Katze sendet "Start" '
        'und der Ball hört es und bewegt sich.',
    answerEs:
        'Los bloques amarillos de Eventos dicen cuándo empieza tu '
        'código:\n\n- Al hacer clic en la bandera verde: arranca el '
        'proyecto\n- Al hacer clic en este objeto: se ejecuta cuando tocas el '
        'personaje\n- Al presionar la tecla espacio: se dispara desde el '
        'teclado\n- Enviar mensaje / Al recibir mensaje: deja que dos objetos '
        'hablen entre sí\n\nLos mensajes vienen muy bien: el gato envía '
        '"empezar" y la pelota lo oye y se mueve.',
    relatedIds: ['scratch_sprite', 'scratch'],
  ),
  KnowledgeEntry(
    id: 'scratch_clone',
    keywords: [
      'klon',
      'kopyasini olustur',
      'clone',
      'coklu mermi',
      'kalem blogu',
      'pen',
      'klone',
      'stift',
      'clon',
      'clones',
      'lapiz',
      'klon ve kalem bloklari nedir',
      'what are clone and pen blocks',
      'was sind klon und stift blocke',
      'que son los clones y el lapiz',
    ],
    answerTr:
        'İki ileri Scratch özelliği:\n\n'
        'Klon: aynı kuklanın kopyalarını çalışırken üretir. Yağmur damlası, mermi ya '
        'da düşman sürüsü yapmanın en kolay yolu. "kendimin kopyasını oluştur" ve '
        '"kopya oluşturulduğunda" bloklarını birlikte kullanırsın.\n\n'
        'Kalem: kuklanın arkasında çizgi bırakır. Kare, yıldız ya da spiral çizdirmek '
        'için döngüyle birleştir: 4 kez tekrarla (100 adım git, 90 derece dön).',
    answerEn:
        'Two more advanced Scratch features:\n\n'
        'Clones: create copies of a sprite while the project runs. It is the easiest '
        'way to make raindrops, bullets or a swarm of enemies. Use "create clone of '
        'myself" together with "when I start as a clone".\n\n'
        'Pen: leaves a line behind the sprite. Combine it with a loop to draw a square, '
        'star or spiral: repeat 4 (move 100 steps, turn 90 degrees).',
    answerDe:
        'Zwei fortgeschrittene Scratch Funktionen:\n\nKlone: erzeugen Kopien '
        'einer Figur, während das Projekt läuft. Das ist der einfachste Weg '
        'für Regentropfen, Schüsse oder einen Schwarm von Gegnern. Nutze '
        '"erzeuge Klon von mir selbst" zusammen mit "wenn ich als Klon '
        'entstehe".\n\nStift: hinterlässt eine Linie hinter der Figur. '
        'Kombiniere ihn mit einer Schleife, um ein Quadrat, einen Stern oder '
        'eine Spirale zu zeichnen: wiederhole 4 (gehe 100 Schritte, drehe '
        'dich um 90 Grad).',
    answerEs:
        'Dos funciones avanzadas de Scratch:\n\nClones: crean copias de un '
        'objeto mientras el proyecto se ejecuta. Es la forma más fácil de '
        'hacer gotas de lluvia, disparos o un enjambre de enemigos. Usa '
        '"crear clon de mí mismo" junto con "al empezar como clon".\n\nLápiz: '
        'deja una línea detrás del objeto. Combínalo con un bucle para '
        'dibujar un cuadrado, una estrella o una espiral: repetir 4 (mover '
        '100 pasos, girar 90 grados).',
    relatedIds: ['scratch', 'loop'],
  ),

  // ----------------------------------------------------- python alt konulari
  KnowledgeEntry(
    id: 'python_module',
    keywords: [
      'kutuphane',
      'modul',
      'import',
      'library',
      'paket yukleme',
      'pip',
      'bibliothek',
      'bibliotheken',
      'biblioteca',
      'importar',
      'kutuphane nedir',
      'what is a library',
      'was ist eine bibliothek',
      'que es una biblioteca',
    ],
    answerTr:
        'Kütüphane, başkalarının yazdığı hazır kod paketidir. Her şeyi sıfırdan '
        'yazmak yerine kullanırsın.\n\n'
        'import random\n'
        'print(random.randint(1, 6))  # zar atar\n\n'
        'Sık kullanılanlar: random (rastgele), math (matematik), time (bekleme), '
        'turtle (çizim), pygame (oyun). Bazıları hazır gelir, bazıları pip ile kurulur.',
    answerEn:
        'A library is a ready made package of code someone else wrote, so you do not '
        'have to write everything from scratch.\n\n'
        'import random\n'
        'print(random.randint(1, 6))  # rolls a dice\n\n'
        'Common ones: random, math, time, turtle (drawing) and pygame (games). Some '
        'come built in, others are installed with pip.',
    answerDe:
        'Eine Bibliothek ist ein fertiges Codepaket, das jemand anderes '
        'geschrieben hat, damit du nicht alles von Grund auf schreiben '
        'musst.\n\nimport random\nprint(random.randint(1, 6))  # '
        'wuerfelt\n\nHäufige: random, math, time, turtle (Zeichnen) und '
        'pygame (Spiele). Manche sind schon dabei, andere installierst du mit '
        'pip.',
    answerEs:
        'Una biblioteca es un paquete de código ya hecho que escribió otra '
        'persona, para que no tengas que escribirlo todo desde '
        'cero.\n\nimport random\nprint(random.randint(1, 6))  # tira un '
        'dado\n\nLas más habituales: random, math, time, turtle (dibujo) y '
        'pygame (juegos). Algunas vienen incluidas y otras se instalan con '
        'pip.',
    relatedIds: ['python', 'python_turtle'],
  ),
  KnowledgeEntry(
    id: 'python_turtle',
    keywords: [
      'turtle',
      'kaplumbaga',
      'sekil cizdirme',
      'python cizim',
      'schildkrote',
      'tortuga',
      'zeichnen mit turtle',
      'dibujar con turtle',
      'turtle ile nasil cizerim',
      'how do i draw with turtle',
      'wie zeichne ich mit turtle',
      'como dibujo con turtle',
    ],
    answerTr:
        'Turtle, ekranda bir kaplumbağayı gezdirip çizim yaptıran kütüphanedir. '
        'Scratch\'ten Python\'a geçişte en eğlenceli köprü.\n\n'
        'import turtle\n'
        't = turtle.Turtle()\n'
        'for i in range(4):\n'
        '    t.forward(100)\n'
        '    t.right(90)\n\n'
        'Bu kod bir kare çizer. range(4) yerine range(6) ve 90 yerine 60 yazarsan '
        'altıgen olur.',
    answerEn:
        'Turtle is a library that moves a turtle around the screen and draws with it. '
        'It is the most fun bridge from Scratch to Python.\n\n'
        'import turtle\n'
        't = turtle.Turtle()\n'
        'for i in range(4):\n'
        '    t.forward(100)\n'
        '    t.right(90)\n\n'
        'That draws a square. Change range(4) to range(6) and 90 to 60 for a hexagon.',
    answerDe:
        'Turtle ist eine Bibliothek, die eine Schildkröte über den Bildschirm '
        'bewegt und dabei zeichnet. Sie ist die schönste Brücke von Scratch '
        'zu Python.\n\nimport turtle\nt = turtle.Turtle()\nfor i in '
        'range(4):\n    t.forward(100)\n    t.right(90)\n\nDas zeichnet ein '
        'Quadrat. Nimm range(6) statt range(4) und 60 statt 90, dann wird ein '
        'Sechseck daraus.',
    answerEs:
        'Turtle es una biblioteca que mueve una tortuga por la pantalla y '
        'dibuja con ella. Es el puente más divertido de Scratch a '
        'Python.\n\nimport turtle\nt = turtle.Turtle()\nfor i in range(4):\n    '
        't.forward(100)\n    t.right(90)\n\nEso dibuja un cuadrado. Cambia '
        'range(4) por range(6) y 90 por 60 y saldrá un hexágono.',
    relatedIds: ['python_module', 'loop_types'],
  ),
  KnowledgeEntry(
    id: 'python_dict',
    keywords: [
      'sozluk',
      'dictionary',
      'anahtar deger',
      'key value',
      'worterbuch',
      'diccionario',
      'schlussel wert',
      'clave valor',
      'sozluk nedir',
      'what is a dictionary',
      'was ist ein dictionary',
      'que es un diccionario',
    ],
    answerTr:
        'Sözlük, her değere bir isim (anahtar) veren yapıdır. Listede sıra numarası '
        'kullanırsın, sözlükte anlamlı bir kelime.\n\n'
        'oyuncu = {"ad": "Ada", "puan": 120, "seviye": 3}\n'
        'print(oyuncu["puan"])  # 120\n'
        'oyuncu["puan"] = 150   # değeri değiştirir\n\n'
        'Oyun kaydı, kullanıcı bilgisi gibi şeyleri tutmak için ideal.',
    answerEn:
        'A dictionary gives every value a name (a key). In a list you use an index '
        'number; in a dictionary you use a meaningful word.\n\n'
        'player = {"name": "Ada", "score": 120, "level": 3}\n'
        'print(player["score"])  # 120\n'
        'player["score"] = 150   # changes the value\n\n'
        'It is ideal for game saves or user information.',
    answerDe:
        'Ein Dictionary gibt jedem Wert einen Namen (einen Schlüssel). In '
        'einer Liste benutzt du eine Positionsnummer, im Dictionary ein '
        'sinnvolles Wort.\n\nspieler = {"name": "Ada", "punkte": 120, '
        '"level": 3}\nprint(spieler["punkte"])  # 120\nspieler["punkte"] = '
        '150   # aendert den Wert\n\nIdeal für Spielstände oder Nutzerdaten.',
    answerEs:
        'Un diccionario le pone un nombre (una clave) a cada valor. En una '
        'lista usas un número de posición; en un diccionario, una palabra con '
        'significado.\n\njugador = {"nombre": "Ada", "puntos": 120, "nivel": '
        '3}\nprint(jugador["puntos"])  # 120\njugador["puntos"] = 150   # '
        'cambia el valor\n\nEs ideal para partidas guardadas o datos de '
        'usuario.',
    relatedIds: ['list_array', 'variable'],
  ),
  KnowledgeEntry(
    id: 'python_return',
    keywords: [
      'return',
      'geri dondur',
      'parametre',
      'arguman',
      'fonksiyon yazma',
      'ruckgabewert',
      'parametro',
      'devolver',
      'valor de retorno',
      'return ne demek',
      'what does return mean',
      'was bedeutet return',
      'que significa return',
    ],
    answerTr:
        'Fonksiyona dışarıdan bilgi vermeye parametre, fonksiyondan sonuç almaya '
        'return denir.\n\n'
        'def topla(a, b):\n'
        '    return a + b\n\n'
        'sonuc = topla(3, 5)   # 8\n\n'
        'return olmazsa fonksiyon iş yapar ama sana bir değer vermez. print ile '
        'karıştırma: print ekrana yazar, return değeri geri verir.',
    answerEn:
        'Information you pass into a function is a parameter; the result it gives back '
        'is a return value.\n\n'
        'def add(a, b):\n'
        '    return a + b\n\n'
        'result = add(3, 5)   # 8\n\n'
        'Without return the function does its job but hands you nothing. Do not confuse '
        'it with print: print writes to the screen, return gives back a value.',
    answerDe:
        'Was du einer Funktion mitgibst, heißt Parameter; das Ergebnis, das '
        'sie zurückgibt, heißt Rückgabewert (return).\n\ndef addiere(a, b):\n    '
        'return a + b\n\nergebnis = addiere(3, 5)   # 8\n\nOhne return macht '
        'die Funktion ihre Arbeit, gibt dir aber nichts zurück. Nicht mit '
        'print verwechseln: print schreibt auf den Bildschirm, return liefert '
        'einen Wert zurück.',
    answerEs:
        'Lo que le pasas a una función es un parámetro; el resultado que te '
        'devuelve es el valor de retorno (return).\n\ndef sumar(a, b):\n    '
        'return a + b\n\nresultado = sumar(3, 5)   # 8\n\nSin return la '
        'función hace su trabajo pero no te entrega nada. No lo confundas con '
        'print: print escribe en la pantalla y return devuelve un valor.',
    relatedIds: ['function', 'python'],
  ),
  KnowledgeEntry(
    id: 'python_errors',
    keywords: [
      'syntaxerror',
      'indentationerror',
      'nameerror',
      'typeerror',
      'indexerror',
      'hata mesaji',
      'python fehler',
      'fehlermeldung',
      'mensaje de error',
      'errores de python',
      'python hatalari ne anlama gelir',
      'what do python errors mean',
      'was bedeuten die python fehler',
      'que significan los errores de python',
    ],
    answerTr:
        'Python\'un sık verdiği hatalar ve anlamları:\n\n'
        '- SyntaxError: yazım hatası. Genelde eksik parantez, tırnak ya da iki nokta.\n'
        '- IndentationError: girinti hatası. Alt satırların 4 boşluk içeride olması lazım.\n'
        '- NameError: tanımlanmamış isim. Değişkeni yazmadan kullandın ya da yanlış yazdın.\n'
        '- TypeError: uyumsuz tip. "5" + 5 gibi, metinle sayıyı topladın.\n'
        '- IndexError: listede olmayan sıra numarası istedin.\n\n'
        'Hata mesajının son satırını oku, hangi satırda olduğunu orada yazar.',
    answerEn:
        'Python\'s most common errors and what they mean:\n\n'
        '- SyntaxError: a typo, usually a missing bracket, quote or colon.\n'
        '- IndentationError: wrong indentation; inner lines need 4 spaces.\n'
        '- NameError: a name that does not exist, misspelled or never defined.\n'
        '- TypeError: mismatched types, like adding "5" + 5.\n'
        '- IndexError: you asked for a position the list does not have.\n\n'
        'Read the last line of the error message; it tells you the line number.',
    answerDe:
        'Die häufigsten Python Fehler und was sie bedeuten:\n\n- SyntaxError: '
        'ein Tippfehler, meist eine fehlende Klammer, ein Anführungszeichen '
        'oder ein Doppelpunkt.\n- IndentationError: falsche Einrückung; '
        'innere Zeilen brauchen 4 Leerzeichen.\n- NameError: ein Name, den es '
        'nicht gibt, falsch geschrieben oder nie angelegt.\n- TypeError: '
        'unpassende Typen, etwa "5" + 5.\n- IndexError: du hast eine Position '
        'verlangt, die die Liste nicht hat.\n\nLies die letzte Zeile der '
        'Fehlermeldung; dort steht die Zeilennummer.',
    answerEs:
        'Los errores más comunes de Python y qué significan:\n\n- '
        'SyntaxError: una errata, normalmente un paréntesis, una comilla o '
        'dos puntos que faltan.\n- IndentationError: sangría incorrecta; las '
        'líneas interiores necesitan 4 espacios.\n- NameError: un nombre que '
        'no existe, mal escrito o nunca definido.\n- TypeError: tipos que no '
        'encajan, como "5" + 5.\n- IndexError: has pedido una posición que la '
        'lista no tiene.\n\nLee la última línea del mensaje de error; ahí '
        'está el número de línea.',
    relatedIds: ['error', 'debug'],
  ),

  // -------------------------------------------------------- html alt konulari
  KnowledgeEntry(
    id: 'html_tags',
    keywords: [
      'etiket',
      'tag',
      'html etiket',
      'baslik etiketi',
      'paragraf etiketi',
      'div nedir',
      'tags',
      'html tags',
      'etiquetas',
      'etiquetas html',
      'uberschrift',
      'html etiketleri nelerdir',
      'what are html tags',
      'was sind html tags',
      'que son las etiquetas html',
    ],
    answerTr:
        'HTML etiketleri açılır ve kapanır: <p>Merhaba</p>\n\n'
        'En çok kullanılanlar:\n'
        '- <h1> ... <h6>: başlıklar, h1 en büyüğü\n'
        '- <p>: paragraf\n'
        '- <a href="...">: bağlantı\n'
        '- <img src="..." alt="...">: resim (kapanmaz)\n'
        '- <ul><li>: madde listesi\n'
        '- <div>: kutu, içine başka etiketler koyarsın\n\n'
        'Kapatmayı unutursan sayfa bozulur; en sık yapılan hata budur.',
    answerEn:
        'HTML tags open and close: <p>Hello</p>\n\n'
        'The most used ones:\n'
        '- <h1> to <h6>: headings, h1 is the biggest\n'
        '- <p>: paragraph\n'
        '- <a href="...">: link\n'
        '- <img src="..." alt="...">: image (no closing tag)\n'
        '- <ul><li>: bullet list\n'
        '- <div>: a box you put other tags inside\n\n'
        'Forgetting to close a tag breaks the page; it is the most common mistake.',
    answerDe:
        'HTML Tags öffnen und schließen: <p>Hallo</p>\n\nDie '
        'meistgenutzten:\n- <h1> bis <h6>: Überschriften, h1 ist die '
        'größte\n- <p>: Absatz\n- <a href="...">: Link\n- <img src="..." '
        'alt="...">: Bild (ohne schließendes Tag)\n- <ul><li>: Aufzählung\n- '
        '<div>: eine Box, in die du andere Tags legst\n\nEin vergessenes '
        'schließendes Tag zerlegt die Seite; das ist der häufigste Fehler.',
    answerEs:
        'Las etiquetas HTML se abren y se cierran: <p>Hola</p>\n\nLas más '
        'usadas:\n- <h1> a <h6>: títulos, h1 es el más grande\n- <p>: '
        'párrafo\n- <a href="...">: enlace\n- <img src="..." alt="...">: '
        'imagen (no se cierra)\n- <ul><li>: lista con viñetas\n- <div>: una '
        'caja donde metes otras etiquetas\n\nOlvidar cerrar una etiqueta '
        'rompe la página; es el error más común.',
    relatedIds: ['html', 'html_form'],
  ),
  KnowledgeEntry(
    id: 'html_form',
    keywords: [
      'form',
      'input etiketi',
      'buton ekleme',
      'tablo yapma',
      'table etiketi',
      'formular',
      'formulario',
      'tabelle',
      'tabla',
      'form ve tablo nasil yapilir',
      'how do i make forms and tables',
      'wie baue ich formulare und tabellen',
      'como hago formularios y tablas',
    ],
    answerTr:
        'Form, kullanıcıdan bilgi almanı sağlar:\n\n'
        '<form>\n'
        '  <input type="text" placeholder="Adin">\n'
        '  <input type="number">\n'
        '  <button>Gonder</button>\n'
        '</form>\n\n'
        'Tablo ise <table>, satır <tr>, hücre <td> ile yapılır. Başlık hücresi <th>.\n\n'
        'Formun gerçekten çalışması için arkada JavaScript ya da bir sunucu gerekir.',
    answerEn:
        'A form lets you collect information from the user:\n\n'
        '<form>\n'
        '  <input type="text" placeholder="Your name">\n'
        '  <input type="number">\n'
        '  <button>Send</button>\n'
        '</form>\n\n'
        'Tables use <table>, rows use <tr> and cells use <td>. Header cells are <th>.\n\n'
        'To make the form actually do something you need JavaScript or a server behind it.',
    answerDe:
        'Mit einem Formular sammelst du Informationen von der '
        'Benutzerin:\n\n<form>\n  <input type="text" placeholder="Dein '
        'Name">\n  <input type="number">\n  '
        '<button>Senden</button>\n</form>\n\nTabellen nutzen <table>, Zeilen '
        '<tr> und Zellen <td>. Kopfzellen sind <th>.\n\nDamit das Formular '
        'wirklich etwas tut, brauchst du JavaScript oder einen Server '
        'dahinter.',
    answerEs:
        'Un formulario te permite recoger información de quien usa la '
        'página:\n\n<form>\n  <input type="text" placeholder="Tu nombre">\n  '
        '<input type="number">\n  <button>Enviar</button>\n</form>\n\nLas '
        'tablas usan <table>, las filas <tr> y las celdas <td>. Las celdas de '
        'cabecera son <th>.\n\nPara que el formulario haga algo de verdad '
        'necesitas JavaScript o un servidor detrás.',
    relatedIds: ['html_tags', 'javascript'],
  ),
  KnowledgeEntry(
    id: 'css_selector',
    keywords: [
      'secici',
      'selector',
      'class nedir',
      'id nedir',
      'css baglama',
      'selektor',
      'klasse',
      'clase',
      'class ve id nedir',
      'what are class and id',
      'was sind class und id',
      'que son class e id',
    ],
    answerTr:
        'Seçici, CSS\'in hangi öğeyi boyayacağını söyler:\n\n'
        'p { color: blue; }          /* tum paragraflar */\n'
        '.kutu { color: red; }       /* class="kutu" olanlar */\n'
        '#basoyuncu { color: gold; } /* id="basoyuncu" olan tek oge */\n\n'
        'class birden çok öğede kullanılabilir, id sayfada tek olmalıdır. CSS\'i '
        'sayfaya bağlamak için <head> içine:\n'
        '<link rel="stylesheet" href="style.css">',
    answerEn:
        'A selector tells CSS which element to style:\n\n'
        'p { color: blue; }        /* every paragraph */\n'
        '.box { color: red; }      /* elements with class="box" */\n'
        '#hero { color: gold; }    /* the single element with id="hero" */\n\n'
        'A class can be reused; an id must be unique on the page. To attach CSS, put '
        'this inside <head>:\n'
        '<link rel="stylesheet" href="style.css">',
    answerDe:
        'Ein Selektor sagt CSS, welches Element gestaltet wird:\n\np { color: '
        'blue; }        /* jeder Absatz */\n.box { color: red; }      /* '
        'Elemente mit class="box" */\n#hero { color: gold; }    /* das eine '
        'Element mit id="hero" */\n\nEine class darfst du mehrfach verwenden, '
        'eine id muss auf der Seite einmalig sein. Damit CSS greift, kommt '
        'das hier in den <head>:\n<link rel="stylesheet" href="style.css">',
    answerEs:
        'Un selector le dice a CSS qué elemento debe pintar:\n\np { color: '
        'blue; }        /* todos los párrafos */\n.caja { color: red; }     '
        '/* los elementos con class="caja" */\n#heroe { color: gold; }   /* '
        'el único elemento con id="heroe" */\n\nUna class se puede repetir; '
        'un id debe ser único en la página. Para enlazar el CSS, pon esto '
        'dentro de <head>:\n<link rel="stylesheet" href="style.css">',
    relatedIds: ['css', 'html_tags'],
  ),
  KnowledgeEntry(
    id: 'css_layout',
    keywords: [
      'flexbox',
      'yerlesim',
      'ortalama',
      'kenar bosluk',
      'margin',
      'padding',
      'responsive',
      'layout',
      'anordnung',
      'abstand',
      'margen',
      'relleno',
      'disposicion',
      'flexbox nedir',
      'what is flexbox',
      'was ist flexbox',
      'que es flexbox',
    ],
    answerTr:
        'CSS\'te yerleşimin temeli kutu modelidir: her öğenin içeriği, iç boşluğu '
        '(padding), kenarlığı (border) ve dış boşluğu (margin) vardır.\n\n'
        'Yan yana dizmek için flexbox:\n'
        '.satir { display: flex; gap: 12px; justify-content: center; }\n\n'
        'Telefonda da düzgün görünmesi için sabit piksel yerine yüzde ya da max-width '
        'kullan; buna duyarlı (responsive) tasarım denir.',
    answerEn:
        'Layout in CSS starts with the box model: every element has content, padding, '
        'a border and a margin.\n\n'
        'To place things side by side, use flexbox:\n'
        '.row { display: flex; gap: 12px; justify-content: center; }\n\n'
        'For it to look right on phones, use percentages or max-width instead of fixed '
        'pixels; that is called responsive design.',
    answerDe:
        'Layout in CSS beginnt mit dem Boxmodell: Jedes Element hat Inhalt, '
        'Innenabstand (padding), einen Rahmen (border) und Außenabstand '
        '(margin).\n\nUm Dinge nebeneinander zu setzen, nimm Flexbox:\n.zeile '
        '{ display: flex; gap: 12px; justify-content: center; }\n\nDamit es '
        'auf dem Handy gut aussieht, benutze Prozent oder max-width statt '
        'fester Pixel; das nennt man responsives Design.',
    answerEs:
        'La distribución en CSS empieza por el modelo de caja: cada elemento '
        'tiene contenido, relleno (padding), borde y margen.\n\nPara poner '
        'cosas una al lado de otra, usa flexbox:\n.fila { display: flex; gap: '
        '12px; justify-content: center; }\n\nPara que se vea bien en el '
        'móvil, usa porcentajes o max-width en vez de píxeles fijos; eso se '
        'llama diseño adaptable.',
    relatedIds: ['css', 'website'],
  ),

  // ----------------------------------------------------- arduino alt konulari
  KnowledgeEntry(
    id: 'arduino_setup_loop',
    keywords: [
      'setup loop',
      'void setup',
      'void loop',
      'pinmode',
      'digitalwrite',
      'delay komutu',
      'setup ve loop nedir',
      'what are setup and loop',
      'was sind setup und loop',
      'que son setup y loop',
    ],
    answerTr:
        'Her Arduino kodunda iki bölüm vardır:\n\n'
        'void setup() { }  - bir kez çalışır, ayarları yaparsın\n'
        'void loop()  { }  - sonsuza kadar tekrar eder\n\n'
        'Klasik Blink örneği:\n'
        'void setup() { pinMode(13, OUTPUT); }\n'
        'void loop() {\n'
        '  digitalWrite(13, HIGH); delay(1000);\n'
        '  digitalWrite(13, LOW);  delay(1000);\n'
        '}\n\n'
        'delay milisaniye cinsindendir: 1000 = 1 saniye.',
    answerEn:
        'Every Arduino sketch has two parts:\n\n'
        'void setup() { }  - runs once, for your settings\n'
        'void loop()  { }  - repeats forever\n\n'
        'The classic Blink example:\n'
        'void setup() { pinMode(13, OUTPUT); }\n'
        'void loop() {\n'
        '  digitalWrite(13, HIGH); delay(1000);\n'
        '  digitalWrite(13, LOW);  delay(1000);\n'
        '}\n\n'
        'delay is in milliseconds: 1000 equals one second.',
    answerDe:
        'Jeder Arduino Sketch hat zwei Teile:\n\nvoid setup() { }  - läuft '
        'einmal, für deine Einstellungen\nvoid loop()  { }  - wiederholt sich '
        'endlos\n\nDas klassische Blink Beispiel:\nvoid setup() { pinMode(13, '
        'OUTPUT); }\nvoid loop() {\n  digitalWrite(13, HIGH); delay(1000);\n  '
        'digitalWrite(13, LOW);  delay(1000);\n}\n\ndelay rechnet in '
        'Millisekunden: 1000 ist eine Sekunde.',
    answerEs:
        'Todo programa de Arduino tiene dos partes:\n\nvoid setup() { }  - se '
        'ejecuta una vez, para tus ajustes\nvoid loop()  { }  - se repite '
        'para siempre\n\nEl clásico ejemplo Blink:\nvoid setup() { '
        'pinMode(13, OUTPUT); }\nvoid loop() {\n  digitalWrite(13, HIGH); '
        'delay(1000);\n  digitalWrite(13, LOW);  delay(1000);\n}\n\ndelay se '
        'mide en milisegundos: 1000 es un segundo.',
    relatedIds: ['arduino', 'motor_led'],
  ),
  KnowledgeEntry(
    id: 'arduino_circuit',
    keywords: [
      'breadboard',
      'devre tahtasi',
      'direnc',
      'jumper kablo',
      'analog pin',
      'dijital pin',
      'steckbrett',
      'placa de pruebas',
      'widerstand',
      'resistencia',
      'schaltung',
      'circuito',
      'breadboard nasil kullanilir',
      'how do i use a breadboard',
      'wie benutze ich ein breadboard',
      'como uso una placa de pruebas',
    ],
    answerTr:
        'Devre kurarken bilmen gerekenler:\n\n'
        '- Breadboard (devre tahtası): lehim yapmadan parça bağlarsın. Ortadaki '
        'sütunlar dikey, kenardaki kırmızı-mavi hatlar yatay bağlıdır.\n'
        '- Direnç: akımı sınırlar. LED\'i doğrudan bağlarsan yanar, 220 ohm direnç '
        'kullan.\n'
        '- Dijital pin (0-13): sadece açık/kapalı okur ve yazar.\n'
        '- Analog pin (A0-A5): 0-1023 arası değer okur, sensörler için.\n\n'
        'Kırmızı kablo artı (5V), siyah kablo eksi (GND) olsun; karışıklığı önler.',
    answerEn:
        'What you need to know when building a circuit:\n\n'
        '- Breadboard: connect parts without soldering. The middle columns are linked '
        'vertically, the red and blue rails horizontally.\n'
        '- Resistor: limits current. Wire an LED directly and it burns out; use a 220 '
        'ohm resistor.\n'
        '- Digital pins (0-13): only read and write on/off.\n'
        '- Analog pins (A0-A5): read values from 0 to 1023, used for sensors.\n\n'
        'Keep red wires on plus (5V) and black on minus (GND) to avoid confusion.',
    answerDe:
        'Was du beim Aufbau einer Schaltung wissen musst:\n\n- Breadboard: '
        'Teile verbinden ohne Löten. Die mittleren Spalten sind senkrecht '
        'verbunden, die roten und blauen Schienen waagerecht.\n- Widerstand: '
        'begrenzt den Strom. Schließt du eine LED direkt an, brennt sie '
        'durch; nimm 220 Ohm.\n- Digitale Pins (0-13): lesen und schreiben '
        'nur an/aus.\n- Analoge Pins (A0-A5): lesen Werte von 0 bis 1023, für '
        'Sensoren.\n\nRote Kabel an Plus (5V), schwarze an Minus (GND) - so '
        'verhedderst du dich nicht.',
    answerEs:
        'Lo que hay que saber al montar un circuito:\n\n- Placa de pruebas: '
        'conecta piezas sin soldar. Las columnas del centro están unidas en '
        'vertical y los raíles rojo y azul en horizontal.\n- Resistencia: '
        'limita la corriente. Si conectas un LED directamente se quema; usa '
        'una de 220 ohmios.\n- Pines digitales (0-13): solo leen y escriben '
        'encendido/apagado.\n- Pines analógicos (A0-A5): leen valores de 0 a '
        '1023, para sensores.\n\nCables rojos al positivo (5V) y negros al '
        'negativo (GND): así no te lías.',
    relatedIds: ['arduino', 'sensor'],
  ),
  KnowledgeEntry(
    id: 'robot_projects',
    keywords: [
      'cizgi izleyen',
      'engelden kacan',
      'robot kolu',
      'robot projesi',
      'line follower',
      'linienfolger',
      'roboterprojekt',
      'proyecto de robot',
      'siguelineas',
      'hangi robot projesini yapayim',
      'which robot project should i build',
      'welches roboterprojekt soll ich bauen',
      'que proyecto de robot hago',
    ],
    answerTr:
        'Kolaydan zora robot projeleri:\n\n'
        '1. Yanıp sönen LED (Blink) - ilk adım\n'
        '2. Butonla ışık yakma - giriş/çıkış mantığı\n'
        '3. Mesafe sensörüyle park sensörü - sayı okuma\n'
        '4. Engelden kaçan robot - sensör + motor birlikte\n'
        '5. Çizgi izleyen robot - iki çizgi sensörüyle yön düzeltme\n'
        '6. Servo motorlu robot kol - açı kontrolü\n\n'
        'Her projede bir önceki adımın bilgisini kullanırsın, sırayı atlama.',
    answerEn:
        'Robot projects from easy to hard:\n\n'
        '1. Blinking LED - the first step\n'
        '2. Light controlled by a button - input and output logic\n'
        '3. A parking sensor with a distance sensor - reading numbers\n'
        '4. An obstacle avoiding robot - sensor plus motor together\n'
        '5. A line following robot - two line sensors correcting direction\n'
        '6. A servo robot arm - angle control\n\n'
        'Each project builds on the previous one, so do not skip ahead.',
    answerDe:
        'Roboterprojekte von leicht nach schwer:\n\n1. Blinkende LED - der '
        'erste Schritt\n2. Licht per Knopf steuern - Eingabe und Ausgabe\n3. '
        'Ein Einparkhelfer mit Abstandssensor - Zahlen lesen\n4. Ein Roboter, '
        'der Hindernissen ausweicht - Sensor und Motor zusammen\n5. Ein '
        'Linienfolger - zwei Liniensensoren korrigieren die Richtung\n6. Ein '
        'Roboterarm mit Servo - Winkelsteuerung\n\nJedes Projekt baut auf dem '
        'vorigen auf, überspring also nichts.',
    answerEs:
        'Proyectos de robot de fácil a difícil:\n\n1. LED que parpadea: el '
        'primer paso\n2. Luz controlada por un botón: lógica de entrada y '
        'salida\n3. Un sensor de aparcamiento con sensor de distancia: leer '
        'números\n4. Un robot que esquiva obstáculos: sensor y motor '
        'juntos\n5. Un robot siguelíneas: dos sensores de línea corrigiendo '
        'la dirección\n6. Un brazo robótico con servo: control de '
        'ángulos\n\nCada proyecto se apoya en el anterior, así que no te '
        'saltes ninguno.',
    relatedIds: ['robotics', 'sensor', 'motor_led'],
  ),

  // ---------------------------------------------------- algoritma alt konulari
  KnowledgeEntry(
    id: 'flowchart',
    keywords: [
      'akis semasi',
      'akis diyagrami',
      'sozde kod',
      'pseudocode',
      'flowchart',
      'flussdiagramm',
      'diagrama de flujo',
      'pseudocodigo',
      'akis semasi nedir',
      'what is a flowchart',
      'was ist ein flussdiagramm',
      'que es un diagrama de flujo',
    ],
    answerTr:
        'Kod yazmadan önce planı çizmek işi kolaylaştırır.\n\n'
        'Akış şeması şekilleri:\n'
        '- Oval: başla / bitir\n'
        '- Dikdörtgen: işlem\n'
        '- Eşkenar dörtgen: karar (evet/hayır)\n'
        '- Paralelkenar: giriş/çıkış\n\n'
        'Sözde kod ise adımları günlük dille yazmaktır: "sayıyı al, çift ise ekrana '
        'yaz, değilse bir sonrakine geç". Sonra bunu koda çevirirsin.',
    answerEn:
        'Drawing the plan before writing code makes the job easier.\n\n'
        'Flowchart shapes:\n'
        '- Oval: start / end\n'
        '- Rectangle: a step\n'
        '- Diamond: a decision (yes/no)\n'
        '- Parallelogram: input/output\n\n'
        'Pseudocode is writing the steps in plain language: "take the number, if it is '
        'even print it, otherwise move on". Then you translate that into code.',
    answerDe:
        'Den Plan zu zeichnen, bevor du Code schreibst, macht die Arbeit '
        'leichter.\n\nFormen im Flussdiagramm:\n- Oval: Start / Ende\n- '
        'Rechteck: ein Schritt\n- Raute: eine Entscheidung (ja/nein)\n- '
        'Parallelogramm: Eingabe/Ausgabe\n\nPseudocode heißt, die Schritte in '
        'Alltagssprache zu schreiben: "nimm die Zahl, wenn sie gerade ist, '
        'gib sie aus, sonst geh weiter". Danach übersetzt du das in Code.',
    answerEs:
        'Dibujar el plan antes de escribir código facilita el '
        'trabajo.\n\nFormas del diagrama de flujo:\n- Óvalo: inicio / fin\n- '
        'Rectángulo: un paso\n- Rombo: una decisión (sí/no)\n- Paralelogramo: '
        'entrada/salida\n\nEl pseudocódigo es escribir los pasos en lenguaje '
        'normal: "coge el número, si es par escríbelo, si no pasa al '
        'siguiente". Luego lo traduces a código.',
    relatedIds: ['algorithm', 'condition'],
  ),
  KnowledgeEntry(
    id: 'sorting_searching',
    keywords: [
      'siralama algoritmasi',
      'arama algoritmasi',
      'balon siralama',
      'ikili arama',
      'sorting',
      'sortieren',
      'sortieralgorithmus',
      'suchalgorithmus',
      'ordenacion',
      'busqueda binaria',
      'algoritmo de ordenacion',
      'siralama ve arama algoritmalari',
      'sorting and searching algorithms',
      'sortier und suchalgorithmen',
      'algoritmos de ordenacion y busqueda',
    ],
    answerTr:
        'İki klasik algoritma ailesi:\n\n'
        'Sıralama - kabarcık sıralaması (bubble sort): yan yana iki sayıyı karşılaştır, '
        'yanlış sıradaysa yer değiştir, liste düzelene kadar tekrarla.\n\n'
        'Arama - ikili arama (binary search): sıralı bir listede ortadaki sayıya bak, '
        'aradığın küçükse sol yarıya, büyükse sağ yarıya geç. 1000 sayıda en fazla '
        '10 adımda bulursun.\n\n'
        'Kilit fikir: doğru algoritma, aynı işi çok daha az adımda yapar.',
    answerEn:
        'Two classic families of algorithms:\n\n'
        'Sorting - bubble sort: compare two neighbouring numbers, swap them if they are '
        'in the wrong order, and repeat until the list is tidy.\n\n'
        'Searching - binary search: in a sorted list look at the middle number; if your '
        'target is smaller go left, if bigger go right. Among 1000 numbers you find it '
        'in at most 10 steps.\n\n'
        'The key idea: the right algorithm does the same job in far fewer steps.',
    answerDe:
        'Zwei klassische Familien von Algorithmen:\n\nSortieren - Bubblesort: '
        'Vergleiche zwei benachbarte Zahlen, tausche sie, wenn sie falsch '
        'herum stehen, und wiederhole, bis die Liste ordentlich '
        'ist.\n\nSuchen - binäre Suche: Schau in einer sortierten Liste auf '
        'die mittlere Zahl; ist dein Ziel kleiner, geh nach links, ist es '
        'größer, nach rechts. Unter 1000 Zahlen findest du sie in höchstens '
        '10 Schritten.\n\nDie Kernidee: Der richtige Algorithmus erledigt '
        'dieselbe Arbeit mit weit weniger Schritten.',
    answerEs:
        'Dos familias clásicas de algoritmos:\n\nOrdenación - ordenamiento de '
        'burbuja: compara dos números vecinos, intercámbialos si están al '
        'revés y repite hasta que la lista esté ordenada.\n\nBúsqueda - '
        'búsqueda binaria: en una lista ordenada mira el número del medio; si '
        'el que buscas es menor ve a la izquierda, si es mayor a la derecha. '
        'Entre 1000 números lo encuentras en 10 pasos como mucho.\n\nLa idea '
        'clave: el algoritmo adecuado hace el mismo trabajo con muchos menos '
        'pasos.',
    relatedIds: ['algorithm', 'list_array'],
  ),
  KnowledgeEntry(
    id: 'debug_how',
    keywords: [
      'print ile hata',
      'adim adim calistir',
      'nerede hata var',
      'kodu test etme',
      'lastik ordek',
      'hatayi nasil bulurum',
      'hata nasil bulunur',
      'hatayi bulmak',
      'wie finde ich den fehler',
      'fehler finden',
      'como encuentro el error',
      'encontrar el error',
      'how do i find the bug',
    ],
    answerTr:
        'Hatayı bulmanın pratik yolları:\n\n'
        '1. Hata mesajının son satırını oku, satır numarası orada.\n'
        '2. Şüphelendiğin yerlere print koy: print("buraya geldi", x)\n'
        '3. Kodu ikiye böl, hangi yarıda bozulduğunu bul, sonra o yarıyı ikiye böl.\n'
        '4. Kodu yüksek sesle birine (ya da oyuncağına) anlat; anlatırken çoğu hata '
        'kendiliğinden görünür.\n'
        '5. Son çalışan hâle geri dön, değişiklikleri tek tek geri ekle.',
    answerEn:
        'Practical ways to find a bug:\n\n'
        '1. Read the last line of the error message; it has the line number.\n'
        '2. Add prints where you are suspicious: print("got here", x)\n'
        '3. Split the code in half, find which half breaks, then split that half again.\n'
        '4. Explain the code out loud to someone (or to a toy); most bugs show '
        'themselves while you explain.\n'
        '5. Go back to the last working version and re-add your changes one at a time.',
    answerDe:
        'Praktische Wege, einen Fehler zu finden:\n\n1. Lies die letzte Zeile '
        'der Fehlermeldung; dort steht die Zeilennummer.\n2. Setz prints an '
        'die verdächtigen Stellen: print("bis hier", x)\n3. Teile den Code in '
        'zwei Hälften, finde die kaputte Hälfte, und teile die wieder.\n4. '
        'Erklär den Code laut jemandem (oder deinem Kuscheltier); die meisten '
        'Fehler zeigen sich beim Erklären von selbst.\n5. Geh zur letzten '
        'funktionierenden Fassung zurück und füge deine Änderungen einzeln '
        'wieder ein.',
    answerEs:
        'Formas prácticas de encontrar un error:\n\n1. Lee la última línea '
        'del mensaje de error; ahí está el número de línea.\n2. Pon prints '
        'donde sospeches: print("he llegado aqui", x)\n3. Parte el código por '
        'la mitad, busca en qué mitad falla y vuelve a partirla.\n4. Explica '
        'el código en voz alta a alguien (o a un peluche); la mayoría de '
        'errores se hacen visibles al explicarlos.\n5. Vuelve a la última '
        'versión que funcionaba y añade tus cambios uno a uno.',
    relatedIds: ['debug', 'python_errors'],
  ),

  // ----------------------------------------------------- oyunlar alt konulari
  KnowledgeEntry(
    id: 'game_chess',
    keywords: [
      'satranc',
      'chess',
      'at nasil gider',
      'sah mat',
      'piyon',
      'schach',
      'schachfiguren',
      'ajedrez',
      'piezas de ajedrez',
      'springer',
      'caballo',
      'bauer',
      'peon',
      'satranc taslari nasil gider',
      'how do chess pieces move',
      'wie ziehen die schachfiguren',
      'como se mueven las piezas de ajedrez',
    ],
    answerTr:
        'Satranç, uygulamadaki en iyi strateji antrenmanı. Taşların gidişi:\n\n'
        '- Piyon: bir kare ileri (ilk hamlede iki), çaprazda yer\n'
        '- Kale: düz, istediği kadar\n'
        '- Fil: çapraz, istediği kadar\n'
        '- Vezir: hem düz hem çapraz\n'
        '- At: L şeklinde, tek taş üstünden atlayabilen\n'
        '- Şah: her yöne bir kare\n\n'
        'Amaç rakip şahı kaçamayacağı şekilde tehdit etmek: şah mat. Başlangıçta '
        'merkezi tut ve taşlarını geliştir.',
    answerEn:
        'Chess is the best strategy training in the app. How the pieces move:\n\n'
        '- Pawn: one square forward (two on its first move), captures diagonally\n'
        '- Rook: straight, any distance\n'
        '- Bishop: diagonally, any distance\n'
        '- Queen: straight and diagonally\n'
        '- Knight: in an L shape, the only piece that jumps over others\n'
        '- King: one square in any direction\n\n'
        'The goal is to threaten the enemy king with no escape: checkmate. Early on, '
        'control the centre and develop your pieces.',
    answerDe:
        'Schach ist das beste Strategietraining in der App. So ziehen die '
        'Figuren:\n\n- Bauer: ein Feld vorwärts (zwei beim ersten Zug), '
        'schlägt diagonal\n- Turm: gerade, beliebig weit\n- Läufer: diagonal, '
        'beliebig weit\n- Dame: gerade und diagonal\n- Springer: im L, die '
        'einzige Figur, die über andere springt\n- König: ein Feld in jede '
        'Richtung\n\nZiel ist, den gegnerischen König so zu bedrohen, dass er '
        'nicht entkommt: Schachmatt. Am Anfang das Zentrum beherrschen und '
        'die Figuren entwickeln.',
    answerEs:
        'El ajedrez es el mejor entrenamiento de estrategia de la app. Así se '
        'mueven las piezas:\n\n- Peón: una casilla hacia delante (dos en su '
        'primer movimiento), captura en diagonal\n- Torre: en línea recta, '
        'cualquier distancia\n- Alfil: en diagonal, cualquier distancia\n- '
        'Dama: recta y diagonal\n- Caballo: en forma de L, la única pieza que '
        'salta por encima de otras\n- Rey: una casilla en cualquier '
        'dirección\n\nEl objetivo es amenazar al rey contrario sin que pueda '
        'escapar: jaque mate. Al principio, controla el centro y desarrolla '
        'tus piezas.',
    relatedIds: ['games', 'algorithm'],
  ),
  KnowledgeEntry(
    id: 'game_maze',
    keywords: [
      'labirent',
      'maze',
      'yon komutu',
      'sag sol kodlama',
      'sirali komut',
      'labyrinth',
      'laberinto',
      'richtungen',
      'direcciones',
      'labirent oyununda ipucu',
      'a hint for the maze game',
      'ein tipp fur das labyrinth',
      'una pista para el laberinto',
    ],
    answerTr:
        'Labirent ve yön oyunları sıralama (sequencing) becerisini çalıştırır: '
        'komutları doğru sırayla dizmen gerekir.\n\n'
        'İpucu: karakterin baktığı yöne göre düşün. "Sağa dön" ekranın sağı değil, '
        'karakterin sağıdır. Kâğıda çizip parmağınla takip et.\n\n'
        'Aynı komutu üst üste yazacaksan döngü kullan; adım sayın azalır, puanın artar.',
    answerEn:
        'Maze and direction games train sequencing: you have to put the commands in the '
        'right order.\n\n'
        'A tip: think from the character\'s point of view. "Turn right" means the '
        'character\'s right, not the screen\'s. Draw it on paper and trace with a finger.\n\n'
        'If you repeat the same command, use a loop; fewer steps means a higher score.',
    answerDe:
        'Labyrinth und Richtungsspiele trainieren das Ordnen von Schritten: '
        'Du musst die Befehle in die richtige Reihenfolge bringen.\n\nEin '
        'Tipp: Denk aus Sicht der Figur. "Nach rechts drehen" heißt rechts '
        'von der Figur aus, nicht rechts vom Bildschirm. Zeichne es auf '
        'Papier und fahr es mit dem Finger nach.\n\nWenn du denselben Befehl '
        'wiederholst, nimm eine Schleife; weniger Schritte bedeuten mehr '
        'Punkte.',
    answerEs:
        'Los juegos de laberinto y direcciones entrenan las secuencias: '
        'tienes que poner las órdenes en el orden correcto.\n\nUn consejo: '
        'piensa desde el punto de vista del personaje. "Gira a la derecha" es '
        'la derecha del personaje, no la de la pantalla. Dibújalo en papel y '
        'síguelo con el dedo.\n\nSi repites la misma orden, usa un bucle; '
        'menos pasos significan más puntos.',
    relatedIds: ['games', 'loop'],
  ),
  KnowledgeEntry(
    id: 'game_bug_pattern',
    keywords: [
      'hata avcisi',
      'bug hunter',
      'oruntu',
      'pattern',
      'oruntu dedektifi',
      'muster',
      'muster detektiv',
      'patron',
      'patrones',
      'detective de patrones',
      'hata avcisi ve oruntu dedektifi',
      'bug hunter and pattern detective',
      'bug hunter und muster detektiv',
      'bug hunter y detective de patrones',
    ],
    answerTr:
        'Hata Avcısı: sana çalışmayan bir kod verilir, bozuk satırı bulman istenir. '
        'Yöntem: kodu satır satır oku ve "bu satır ne yapmalı, ne yapıyor?" diye sor.\n\n'
        'Örüntü Dedektifi: dizideki kuralı bulup devamını getirirsin. Önce iki komşu '
        'arasındaki farka bak (2, 4, 6 → +2), olmazsa çarpana bak (2, 4, 8 → x2).\n\n'
        'İkisi de gerçek programcılıkta en çok kullandığın iki beceri.',
    answerEn:
        'Bug Hunter: you get code that does not work and have to find the broken line. '
        'The method is to read line by line asking "what should this do, what does it do?"\n\n'
        'Pattern Detective: you find the rule in a sequence and continue it. First look '
        'at the gap between neighbours (2, 4, 6 is +2); if that fails look for a '
        'multiplier (2, 4, 8 is x2).\n\n'
        'Both are the skills you use most in real programming.',
    answerDe:
        'Bug Hunter: Du bekommst Code, der nicht läuft, und musst die kaputte '
        'Zeile finden. Die Methode: Zeile für Zeile lesen und fragen "was '
        'soll das tun, was tut es?"\n\nMuster-Detektiv: Du findest die Regel '
        'in einer Reihe und setzt sie fort. Schau zuerst auf den Abstand '
        'zwischen Nachbarn (2, 4, 6 ist +2); klappt das nicht, such einen '
        'Faktor (2, 4, 8 ist x2).\n\nBeides sind genau die Fähigkeiten, die '
        'du beim echten Programmieren am meisten brauchst.',
    answerEs:
        'Bug Hunter: te dan un código que no funciona y tienes que encontrar '
        'la línea rota. El método es leer línea por línea preguntando "¿qué '
        'debería hacer esto y qué hace?"\n\nDetective de Patrones: encuentras '
        'la regla de una secuencia y la continúas. Mira primero la diferencia '
        'entre vecinos (2, 4, 6 es +2); si eso no encaja, busca un '
        'multiplicador (2, 4, 8 es x2).\n\nLas dos son las habilidades que '
        'más usas al programar de verdad.',
    relatedIds: ['games', 'debug'],
  ),

  // --------------------------------------------------- uygulama alt konulari
  KnowledgeEntry(
    id: 'market',
    keywords: [
      'market nedir',
      'magazadan ne alinir',
      'jeton harcama',
      'esya satin alma',
      'markt',
      'tienda',
      'munzen ausgeben',
      'gastar monedas',
      'market ne ise yarar',
      'what is the market for',
      'wofur ist der markt da',
      'para que sirve la tienda',
    ],
    answerTr:
        'Market, topladığın jetonları harcadığın yerdir. Karakterine kıyafet, '
        'aksesuar ve arka plan alabilirsin.\n\n'
        'Jetonu ders bitirerek, oyun oynayarak ve günlük görevleri tamamlayarak '
        'kazanırsın. Jeton harcamak seviyeni düşürmez; XP ayrı, jeton ayrıdır.',
    answerEn:
        'The Market is where you spend the coins you collect: clothes, accessories and '
        'backgrounds for your character.\n\n'
        'You earn coins by finishing lessons, playing games and completing daily quests. '
        'Spending coins never lowers your level; XP and coins are separate.',
    answerDe:
        'Im Markt gibst du die gesammelten Münzen aus: Kleidung, Zubehör und '
        'Hintergründe für deine Figur.\n\nMünzen verdienst du, indem du '
        'Lektionen beendest, spielst und Tagesaufgaben abschließt. Münzen '
        'ausgeben senkt dein Level nie; XP und Münzen sind getrennt.',
    answerEs:
        'La Tienda es donde gastas las monedas que reúnes: ropa, accesorios y '
        'fondos para tu personaje.\n\nGanas monedas terminando lecciones, '
        'jugando y completando misiones diarias. Gastar monedas nunca baja tu '
        'nivel; los XP y las monedas van por separado.',
    relatedIds: ['coins', 'xp'],
  ),
  KnowledgeEntry(
    id: 'streak_lost',
    keywords: [
      'serim bozuldu',
      'seri kaybettim',
      'seri sifirlandi',
      'gun kacirdim',
      'meine serie ist weg',
      'serie verloren',
      'perdi mi racha',
      'racha perdida',
      'serim bozuldu ne olur',
      'i lost my streak now what',
      'meine serie ist weg was jetzt',
      'perdi mi racha y ahora',
    ],
    answerTr:
        'Bir gün girmezsen seri sıfırlanır, kazandığın XP ve rozetler ise durur - '
        'onları kaybetmezsin.\n\n'
        'Seriyi korumanın en kolay yolu: her gün tek bir küçük görev yap. Beş dakikalık '
        'bir oyun bile günü kurtarır. Aynı saatte hatırlatıcı kurmak da işe yarıyor.',
    answerEn:
        'If you miss a day your streak resets, but your XP and badges stay - you do not '
        'lose those.\n\n'
        'The easiest way to protect a streak: do one small task every day. Even a five '
        'minute game saves the day. Setting a reminder at the same hour helps too.',
    answerDe:
        'Wenn du einen Tag auslässt, fängt deine Serie wieder bei null an, '
        'aber deine XP und Abzeichen bleiben - die verlierst du nicht.\n\nDer '
        'einfachste Weg, eine Serie zu schützen: Mach jeden Tag eine kleine '
        'Aufgabe. Schon ein fünfminütiges Spiel rettet den Tag. Eine '
        'Erinnerung zur gleichen Uhrzeit hilft auch.',
    answerEs:
        'Si te saltas un día tu racha se reinicia, pero tus XP y tus '
        'insignias se quedan: eso no lo pierdes.\n\nLa forma más fácil de '
        'proteger una racha es hacer una tarea pequeña cada día. Hasta una '
        'partida de cinco minutos salva el día. Poner un recordatorio a la '
        'misma hora también ayuda.',
    relatedIds: ['streak', 'quest'],
  ),
  KnowledgeEntry(
    id: 'offline',
    keywords: [
      'internet yok',
      'cevrimdisi',
      'baglanti hatasi',
      'yuklenmiyor',
      'acilmiyor',
      'kein internet',
      'ohne internet',
      'ladt nicht',
      'sin conexion',
      'sin internet',
      'no carga',
      'internetsiz calisir mi',
      'does it work offline',
      'geht es auch offline',
      'funciona sin conexion',
    ],
    answerTr:
        'Uygulama internetsiz kısmen çalışır: bazı oyunlar açılır ama videolar, '
        'liderlik tablosu ve ilerleme kaydı internet ister.\n\n'
        'Ekran boş kalıyorsa: bağlantını kontrol et, uygulamayı tamamen kapatıp yeniden '
        'aç. İlerlemen bulutta tutulduğu için tekrar bağlandığında kaybolmaz.',
    answerEn:
        'The app partly works offline: some games open, but videos, the leaderboard and '
        'progress saving need a connection.\n\n'
        'If a screen stays empty, check your connection and fully close and reopen the '
        'app. Your progress is stored in the cloud, so it is not lost when you come back.',
    answerDe:
        'Die App funktioniert teilweise ohne Internet: Manche Spiele öffnen '
        'sich, aber Videos, die Bestenliste und das Speichern des '
        'Fortschritts brauchen eine Verbindung.\n\nWenn ein Bildschirm leer '
        'bleibt, prüf deine Verbindung und schließ die App ganz und öffne sie '
        'neu. Dein Fortschritt liegt in der Cloud, er geht also nicht '
        'verloren, wenn du zurückkommst.',
    answerEs:
        'La app funciona en parte sin conexión: algunos juegos se abren, pero '
        'los vídeos, la tabla de clasificación y el guardado del progreso '
        'necesitan internet.\n\nSi una pantalla se queda vacía, revisa tu '
        'conexión y cierra la app del todo antes de volver a abrirla. Tu '
        'progreso está en la nube, así que no se pierde cuando vuelvas.',
    relatedIds: ['videos'],
  ),
  KnowledgeEntry(
    id: 'save_progress',
    keywords: [
      'ilerlemem kaydediliyor mu',
      'hesap olusturma',
      'kayit olmak',
      'telefon degistirme',
      'ilerleme kaybolur mu',
      'wird mein fortschritt gespeichert',
      'fortschritt gespeichert',
      'se guarda mi progreso',
      'progreso guardado',
      'konto',
      'cuenta',
      'is my progress saved',
    ],
    answerTr:
        'İlerlemen otomatik kaydediliyor, uygulamayı ilk açtığında senin için sessizce '
        'bir hesap oluşturuluyor.\n\n'
        'Ama telefonu değiştirirsen ya da uygulamayı silersen, bu hesaba geri dönmek '
        'için e-posta eklemen gerekir. Profil ekranındaki "İlerlemeni kaydet" kartından '
        'yapabilirsin; XP\'n, rozetlerin ve serilerin aynen kalır.',
    answerEn:
        'Your progress is saved automatically; an account is created quietly for you the '
        'first time you open the app.\n\n'
        'But if you change phones or delete the app, you need an email to get back into '
        'that account. Use the "Save your progress" card on the Profile screen; your XP, '
        'badges and streaks all carry over.',
    answerDe:
        'Dein Fortschritt wird automatisch gespeichert; beim ersten Öffnen '
        'der App wird still ein Konto für dich angelegt.\n\nWenn du aber das '
        'Handy wechselst oder die App löschst, brauchst du eine E-Mail, um '
        'wieder in dieses Konto zu kommen. Nutze dafür die Karte "Fortschritt '
        'sichern" auf dem Profil Bildschirm; deine XP, Abzeichen und Serien '
        'bleiben alle erhalten.',
    answerEs:
        'Tu progreso se guarda automáticamente; la primera vez que abres la '
        'app se crea una cuenta para ti en segundo plano.\n\nPero si cambias '
        'de móvil o borras la app, necesitas un correo electrónico para '
        'volver a entrar en esa cuenta. Usa la tarjeta "Guarda tu progreso" '
        'de la pantalla de Perfil; tus XP, insignias y rachas se mantienen '
        'igual.',
    relatedIds: ['profile', 'xp'],
  ),
  KnowledgeEntry(
    id: 'app_language',
    keywords: [
      'dil degistir',
      'dili degistir',
      'uygulama dili',
      'hangi diller var',
      'change language',
      'which languages',
      'sprache andern',
      'sprache wechseln',
      'welche sprachen',
      'cambiar idioma',
      'idioma',
      'que idiomas',
      'uygulamanin dilini nasil degistiririm',
      'how do i change the language',
      'wie andere ich die sprache',
      'como cambio el idioma',
    ],
    answerTr:
        'Ayarlar > Dil ve Bölge bölümünden değiştirebilirsin. Şu an dört dil '
        'var: Türkçe, İngilizce, Almanca ve İspanyolca.\n\nDili '
        'değiştirdiğinde dersler, oyunlar ve ben de o dile geçeriz. '
        'İlerlemen, XP\'n ve rozetlerin aynen kalır.',
    answerEn:
        'Open Settings > Language and Region. There are four languages right '
        'now: Turkish, English, German and Spanish.\n\nWhen you switch, the '
        'lessons, the games and I change language too. Your progress, XP and '
        'badges stay exactly the same.',
    answerDe:
        'Geh zu Einstellungen > Sprache und Region. Es gibt zurzeit vier '
        'Sprachen: Türkisch, Englisch, Deutsch und Spanisch.\n\nWenn du '
        'wechselst, wechseln die Lektionen, die Spiele und ich mit. Dein '
        'Fortschritt, deine XP und deine Abzeichen bleiben gleich.',
    answerEs:
        'Ve a Ajustes > Idioma y región. Ahora mismo hay cuatro idiomas: '
        'turco, inglés, alemán y español.\n\nAl cambiarlo, las lecciones, los '
        'juegos y yo también cambiamos de idioma. Tu progreso, tus XP y tus '
        'insignias se quedan igual.',
    relatedIds: ['videos', 'profile'],
  ),
  KnowledgeEntry(
    id: 'notifications',
    keywords: [
      'bildirim',
      'bildirimler',
      'hatirlatici',
      'notification',
      'notifications',
      'reminder',
      'benachrichtigungen',
      'erinnerung',
      'notificaciones',
      'recordatorio',
      'bildirimleri nasil kapatirim',
      'how do i turn notifications off',
      'wie schalte ich benachrichtigungen aus',
      'como desactivo las notificaciones',
    ],
    answerTr:
        'Bildirimleri Ayarlar > Bildirimler bölümünden açıp '
        'kapatabilirsin.\n\nAçıkken günde birkaç kez kısa bir hatırlatma '
        'gelir; seriyi bozmamana yardım eder. Sesi ve titreşimi ayrı ayrı '
        'kapatabilirsin.\n\nHepsini kapatsan da uygulamanın geri kalanı aynı '
        'çalışır.',
    answerEn:
        'You can turn notifications on and off in Settings > '
        'Notifications.\n\nWhen they are on you get a short reminder a few '
        'times a day; it helps you keep your streak. Sound and vibration can '
        'be switched off separately.\n\nEven with all of them off, the rest '
        'of the app works exactly the same.',
    answerDe:
        'Benachrichtigungen schaltest du unter Einstellungen > '
        'Benachrichtigungen ein und aus.\n\nWenn sie an sind, bekommst du ein '
        'paar Mal am Tag eine kurze Erinnerung; das hilft dir, deine Serie zu '
        'halten. Ton und Vibration kannst du einzeln ausschalten.\n\nAuch '
        'wenn alles aus ist, funktioniert der Rest der App genauso.',
    answerEs:
        'Puedes activar y desactivar las notificaciones en Ajustes > '
        'Notificaciones.\n\nCuando están activadas recibes un recordatorio '
        'corto varias veces al día; te ayuda a mantener tu racha. El sonido y '
        'la vibración se apagan por separado.\n\nAunque las apagues todas, el '
        'resto de la app funciona igual.',
    relatedIds: ['streak', 'quest'],
  ),
  KnowledgeEntry(
    id: 'parents',
    keywords: [
      'ebeveyn',
      'ailem',
      'anne baba',
      'veli',
      'ebeveyn alani',
      'parent',
      'parents',
      'my parents',
      'eltern',
      'elternbereich',
      'meine eltern',
      'padres',
      'mis padres',
      'zona de padres',
      'ebeveyn alani nedir',
      'what is the parent area',
      'was ist der elternbereich',
      'que es la zona de padres',
    ],
    answerTr:
        'Ailen için Ebeveyn Alanı var: ne kadar ilerlediğini, hangi kursları '
        'bitirdiğini ve haftalık özetini oradan görebilirler.\n\nGirişte kısa '
        'bir ebeveyn kapısı var (doğum yılını soran bir soru). Bu, ayarların '
        'yanlışlıkla değişmesini engellemek için.\n\nSatın alma yapacaksan da '
        'bunu bir büyüğünle birlikte yapmalısın.',
    answerEn:
        'There is a Parent Area for your family: they can see how far you '
        'have come, which courses you finished and a weekly summary.\n\nThere '
        'is a short parent gate at the entrance (a question about a birth '
        'year). It is there so settings do not get changed by accident.\n\nIf '
        'you want to buy anything, do it together with a grown up.',
    answerDe:
        'Für deine Familie gibt es den Elternbereich: Dort sehen sie, wie '
        'weit du gekommen bist, welche Kurse du beendet hast und eine '
        'Wochenübersicht.\n\nAm Eingang gibt es eine kurze Elternsperre (eine '
        'Frage nach einem Geburtsjahr). Sie sorgt dafür, dass Einstellungen '
        'nicht aus Versehen geändert werden.\n\nWenn du etwas kaufen willst, '
        'mach das zusammen mit einem Erwachsenen.',
    answerEs:
        'Hay una Zona de Padres para tu familia: allí pueden ver cuánto has '
        'avanzado, qué cursos has terminado y un resumen semanal.\n\nEn la '
        'entrada hay un control parental corto (una pregunta sobre un año de '
        'nacimiento). Sirve para que los ajustes no se cambien sin '
        'querer.\n\nSi quieres comprar algo, hazlo junto a una persona '
        'adulta.',
    relatedIds: ['report', 'pro', 'security'],
  ),
  KnowledgeEntry(
    id: 'ads',
    keywords: [
      'reklam',
      'reklamlar',
      'neden reklam',
      'ads',
      'why ads',
      'advertising',
      'werbung',
      'warum werbung',
      'anuncios',
      'publicidad',
      'por que hay anuncios',
      'neden reklam cikiyor',
      'why are there ads',
      'warum gibt es werbung',
    ],
    answerTr:
        'Uygulamada iki tür reklam var:\n\n- Ödüllü video: Market\'te '
        'izlemeyi kendin seçersin, her biri 5 jeton kazandırır ve günde en '
        'fazla 5 tane izlenebilir.\n- Kısa geçiş reklamları: arada bir çıkar, '
        'ilk derslerinde hiç çıkmaz.\n\nReklamlar seni tanıyan türden değil; '
        'senin hakkında bilgi toplanmadan, yaşına uygun olarak seçiliyor. Pro '
        'üyelikte hiç reklam çıkmaz.',
    answerEn:
        'There are two kinds of ads in the app:\n\n- Rewarded video: you '
        'choose to watch it in the Market, each one gives you 5 coins, up to '
        '5 a day.\n- Short interstitial ads: they appear now and then, and '
        'never during your first lessons.\n\nThe ads are not the kind that '
        'know who you are; nothing is collected about you and they are picked '
        'to suit your age. With Pro there are no ads at all.',
    answerDe:
        'Es gibt zwei Arten von Werbung in der App:\n\n- Belohntes Video: Du '
        'entscheidest im Markt selbst, ob du es ansiehst. Jedes bringt 5 '
        'Münzen, höchstens 5 am Tag.\n- Kurze Zwischenwerbung: taucht ab und '
        'zu auf, aber nie in deinen ersten Lektionen.\n\nDie Werbung ist '
        'nicht die Art, die dich kennt; über dich wird nichts gesammelt und '
        'die Anzeigen passen zu deinem Alter. Mit Pro gibt es gar keine '
        'Werbung.',
    answerEs:
        'En la app hay dos tipos de anuncios:\n\n- Vídeo con recompensa: '
        'eliges verlo tú en la Tienda, cada uno te da 5 monedas y puedes ver '
        '5 al día como máximo.\n- Anuncios cortos entre pantallas: salen de '
        'vez en cuando y nunca en tus primeras lecciones.\n\nLos anuncios no '
        'son de los que te conocen; no se recoge nada sobre ti y se eligen '
        'según tu edad. Con Pro no aparece ningún anuncio.',
    relatedIds: ['coins', 'pro', 'market'],
  ),
  KnowledgeEntry(
    id: 'screen_time',
    keywords: [
      'mola',
      'ara vermek',
      'ekran suresi',
      'gozlerim yoruldu',
      'take a break',
      'screen time',
      'my eyes hurt',
      'pause machen',
      'bildschirmzeit',
      'augen tun weh',
      'descanso',
      'tiempo de pantalla',
      'me duelen los ojos',
      'ne zaman mola vermeliyim',
      'when should i take a break',
      'wann soll ich eine pause machen',
      'cuando debo descansar',
    ],
    answerTr:
        'Uzun oturmak yerine kısa ve düzenli çalış: yaklaşık 20 dakikada bir '
        '5 dakika ara ver, uzağa bak, biraz hareket et.\n\nGözlerin yanıyorsa '
        'ya da aynı satırı üçüncü kez okuyorsan bu bir mola işareti - kod '
        'kaçmıyor.\n\nZaten günde 15-20 dakika düzenli çalışmak, üç saatlik '
        'tek bir oturumdan daha çok öğretiyor.',
    answerEn:
        'Work in short, regular sessions instead of one long one: take a 5 '
        'minute break every 20 minutes or so, look into the distance, move '
        'around a bit.\n\nIf your eyes sting or you are reading the same line '
        'for the third time, that is your cue for a break - the code is not '
        'going anywhere.\n\nAnd 15-20 regular minutes a day already teaches '
        'you more than one three hour sitting.',
    answerDe:
        'Arbeite lieber kurz und regelmäßig als einmal lang: Mach etwa alle '
        '20 Minuten 5 Minuten Pause, schau in die Ferne, beweg dich ein '
        'bisschen.\n\nWenn deine Augen brennen oder du dieselbe Zeile zum '
        'dritten Mal liest, ist das dein Zeichen für eine Pause - der Code '
        'läuft nicht weg.\n\nUnd 15-20 regelmäßige Minuten am Tag bringen dir '
        'mehr als eine dreistündige Sitzung.',
    answerEs:
        'Trabaja en ratos cortos y regulares en vez de una sesión larga: '
        'descansa 5 minutos cada 20 minutos más o menos, mira a lo lejos y '
        'muévete un poco.\n\nSi te escuecen los ojos o estás leyendo la misma '
        'línea por tercera vez, es la señal para parar: el código no se va a '
        'ninguna parte.\n\nAdemás, 15 o 20 minutos regulares al día enseñan '
        'más que una sesión de tres horas.',
    relatedIds: ['how_long', 'streak'],
  ),
  KnowledgeEntry(
    id: 'no_computer',
    keywords: [
      'bilgisayarim yok',
      'telefonla olur mu',
      'tabletle',
      'no computer',
      'only a phone',
      'kein computer',
      'nur ein handy',
      'no tengo ordenador',
      'solo tengo movil',
      'bilgisayarim yok telefonla olur mu',
      'i have no computer is a phone enough',
      'ich habe keinen computer reicht ein handy',
      'no tengo ordenador me vale el movil',
    ],
    answerTr:
        'Telefonla da öğrenebilirsin: bu uygulamadaki bütün dersler, oyunlar '
        've Arduino Atölyesi telefonda çalışıyor.\n\nAma gerçek projeler '
        'yazarken bilgisayar daha rahat: klavye hızlı, ekran geniş, hatayı '
        'görmek kolay.\n\nOkulda ya da kütüphanede bilgisayara '
        'erişebiliyorsan haftada bir kez bile iyi gelir. O güne kadar '
        'telefonda çalışmaya devam et, kaybettiğin bir şey yok.',
    answerEn:
        'You can learn on a phone: every lesson, game and the Arduino '
        'Simulator in this app work on one.\n\nA computer is more comfortable '
        'once you write real projects: the keyboard is faster, the screen is '
        'wider, mistakes are easier to spot.\n\nIf you can use a computer at '
        'school or the library, even once a week helps. Until then keep going '
        'on the phone - you are not missing anything.',
    answerDe:
        'Du kannst auch mit dem Handy lernen: Alle Lektionen, Spiele und der '
        'Arduino Simulator in dieser App laufen darauf.\n\nSobald du echte '
        'Projekte schreibst, ist ein Computer bequemer: Die Tastatur ist '
        'schneller, der Bildschirm größer, Fehler sind leichter zu '
        'sehen.\n\nWenn du in der Schule oder Bücherei an einen Computer '
        'kommst, hilft schon einmal pro Woche. Bis dahin mach am Handy weiter '
        '- dir entgeht nichts.',
    answerEs:
        'Puedes aprender con el móvil: todas las lecciones, los juegos y el '
        'Simulador de Arduino de esta app funcionan ahí.\n\nUn ordenador es '
        'más cómodo cuando escribes proyectos de verdad: el teclado va más '
        'rápido, la pantalla es más ancha y los errores se ven mejor.\n\nSi '
        'puedes usar un ordenador en el colegio o en la biblioteca, aunque '
        'sea una vez por semana ya ayuda. Mientras tanto sigue en el móvil: '
        'no te estás perdiendo nada.',
    relatedIds: ['which_program', 'where_start'],
  ),
  KnowledgeEntry(
    id: 'which_program',
    keywords: [
      'hangi program',
      'ne kurmaliyim',
      'program kurmak',
      'which program',
      'what should i install',
      'welches programm',
      'was muss ich installieren',
      'que programa',
      'que necesito instalar',
      'hangi programi kurmaliyim',
      'que programa necesito instalar',
    ],
    answerTr:
        'Bu uygulamada hiçbir şey kurmana gerek yok; Python, Arduino ve blok '
        'derslerini doğrudan burada yapabilirsin.\n\nBilgisayarda çalışmak '
        'istersen:\n- Scratch: scratch.mit.edu, tarayıcıda açılır, kurulum '
        'yok\n- Python: python.org, yanına Thonny (yeni başlayanlar için en '
        'kolay editör)\n- Arduino: Arduino IDE\n\nHepsi ücretsiz. Kurulumu '
        'bir büyüğünle birlikte yap.',
    answerEn:
        'You do not need to install anything for this app; the Python, '
        'Arduino and block lessons all run right here.\n\nIf you want to work '
        'on a computer:\n- Scratch: scratch.mit.edu, opens in the browser, '
        'nothing to install\n- Python: python.org, plus Thonny (the easiest '
        'editor for beginners)\n- Arduino: the Arduino IDE\n\nThey are all '
        'free. Do the installing together with a grown up.',
    answerDe:
        'Für diese App musst du nichts installieren; die Python, Arduino und '
        'Block Lektionen laufen alle direkt hier.\n\nWenn du am Computer '
        'arbeiten willst:\n- Scratch: scratch.mit.edu, läuft im Browser, '
        'nichts zu installieren\n- Python: python.org, dazu Thonny (der '
        'einfachste Editor für Anfänger)\n- Arduino: die Arduino IDE\n\nAlles '
        'kostenlos. Installier es zusammen mit einem Erwachsenen.',
    answerEs:
        'Para esta app no necesitas instalar nada; las lecciones de Python, '
        'Arduino y bloques funcionan aquí mismo.\n\nSi quieres trabajar en un '
        'ordenador:\n- Scratch: scratch.mit.edu, se abre en el navegador, sin '
        'instalar nada\n- Python: python.org, junto con Thonny (el editor más '
        'fácil para empezar)\n- Arduino: el IDE de Arduino\n\nTodo es gratis. '
        'Haz la instalación con una persona adulta.',
    relatedIds: ['python', 'scratch', 'arduino'],
  ),
  KnowledgeEntry(
    id: 'string_ops',
    keywords: [
      'metin islemleri',
      'string islemleri',
      'metin birlestirme',
      'text operations',
      'string operations',
      'join text',
      'zeichenketten',
      'text verbinden',
      'operaciones con texto',
      'unir texto',
      'metinlerle nasil calisirim',
      'how do i work with text',
      'wie arbeite ich mit text',
      'como trabajo con texto',
    ],
    answerTr:
        'Metinlerle (string) çalışırken en çok bunları kullanırsın:\n\nad = '
        '"Ada"\nprint(ad + " merhaba")   # birlestirme\nprint(len(ad))           '
        '# 3, uzunluk\nprint(ad.upper())        # ADA\nprint(ad[0])             '
        '# A, ilk harf\n\nDikkat: sayıyla metni doğrudan toplayamazsın. "yas: '
        '" + 10 hata verir; doğrusu "yas: " + str(10).',
    answerEn:
        'These are the ones you use most when working with text '
        '(strings):\n\nname = "Ada"\nprint(name + " hello")   # '
        'joining\nprint(len(name))         # 3, the '
        'length\nprint(name.upper())      # ADA\nprint(name[0])           # '
        'A, the first letter\n\nCareful: you cannot add a number to text '
        'directly. "age: " + 10 fails; write "age: " + str(10).',
    answerDe:
        'Beim Arbeiten mit Text (Strings) brauchst du meistens diese '
        'hier:\n\nname = "Ada"\nprint(name + " hallo")   # '
        'verbinden\nprint(len(name))         # 3, die '
        'Laenge\nprint(name.upper())      # ADA\nprint(name[0])           # '
        'A, der erste Buchstabe\n\nVorsicht: Du kannst eine Zahl nicht direkt '
        'an Text hängen. "alter: " + 10 geht schief; richtig ist "alter: " + '
        'str(10).',
    answerEs:
        'Estas son las que más usarás al trabajar con texto '
        '(strings):\n\nnombre = "Ada"\nprint(nombre + " hola")   # '
        'unir\nprint(len(nombre))        # 3, la '
        'longitud\nprint(nombre.upper())     # ADA\nprint(nombre[0])          '
        '# A, la primera letra\n\nOjo: no puedes sumar un número al texto '
        'directamente. "edad: " + 10 da error; lo correcto es "edad: " + '
        'str(10).',
    relatedIds: ['data_types', 'python', 'print_input'],
  ),
  KnowledgeEntry(
    id: 'boolean_logic',
    keywords: [
      'and or not',
      'mantik operatoru',
      'mantiksal operator',
      've veya degil',
      'boolean',
      'logical operators',
      'und oder nicht',
      'logische operatoren',
      'operadores logicos',
      'and or ve not nedir',
      'what are and or and not',
      'was sind and or und not',
      'que son and or y not',
    ],
    answerTr:
        'Mantık operatörleri birden çok koşulu birleştirir:\n\n- and (ve): '
        'ikisi de doğruysa\n- or (veya): en az biri doğruysa\n- not (değil): '
        'doğruyu yanlışa çevirir\n\nif can > 0 and puan > 100:\n    '
        'print("Devam")\n\nScratch\'te bunlar yeşil "ve", "veya", "değil" '
        'bloklarıdır. Sonuç her zaman iki değerden biridir: doğru ya da '
        'yanlış.',
    answerEn:
        'Logical operators join several conditions together:\n\n- and: both '
        'must be true\n- or: at least one must be true\n- not: flips true '
        'into false\n\nif lives > 0 and score > 100:\n    print("Keep '
        'going")\n\nIn Scratch these are the green "and", "or" and "not" '
        'blocks. The result is always one of two values: true or false.',
    answerDe:
        'Logische Operatoren verbinden mehrere Bedingungen:\n\n- and (und): '
        'beide müssen wahr sein\n- or (oder): mindestens eine muss wahr '
        'sein\n- not (nicht): macht aus wahr falsch\n\nif leben > 0 and '
        'punkte > 100:\n    print("Weiter so")\n\nIn Scratch sind das die '
        'grünen Blöcke "und", "oder" und "nicht". Das Ergebnis ist immer '
        'einer von zwei Werten: wahr oder falsch.',
    answerEs:
        'Los operadores lógicos juntan varias condiciones:\n\n- and (y): las '
        'dos tienen que ser verdaderas\n- or (o): al menos una tiene que ser '
        'verdadera\n- not (no): convierte verdadero en falso\n\nif vidas > 0 '
        'and puntos > 100:\n    print("Sigue asi")\n\nEn Scratch son los '
        'bloques verdes "y", "o" y "no". El resultado siempre es uno de dos '
        'valores: verdadero o falso.',
    relatedIds: ['condition', 'data_types'],
  ),
  KnowledgeEntry(
    id: 'scratch_score',
    keywords: [
      'scratch skor',
      'skor tutmak',
      'puan tutmak',
      'keep score',
      'score in scratch',
      'punktestand',
      'punkte zaehlen',
      'llevar la puntuacion',
      'marcador',
      'scratch te skor nasil tutulur',
      'how do i keep score in scratch',
      'wie zahle ich punkte in scratch',
      'como llevo la puntuacion en scratch',
    ],
    answerTr:
        'Scratch\'te skor tutmak için önce bir değişken oluştur: Değişkenler '
        '> Bir değişken oluştur > adını "skor" koy.\n\nSonra iki blok '
        'yeter:\n- Oyun başlarken: "skor\'u 0 yap"\n- Puan kazanınca: '
        '"skor\'u 1 artır"\n\nDeğişkenin yanındaki kutuyu işaretlersen skor '
        'sahnede görünür. Aynı mantıkla can, süre ve seviye de tutulur - '
        'sadece değişkenin adı değişir.',
    answerEn:
        'To keep score in Scratch, first make a variable: Variables > Make a '
        'Variable > call it "score".\n\nThen two blocks are enough:\n- When '
        'the game starts: "set score to 0"\n- When you earn a point: "change '
        'score by 1"\n\nTick the box next to the variable and the score shows '
        'on the stage. Lives, time and level work the same way - only the '
        'variable name changes.',
    answerDe:
        'Um in Scratch Punkte zu zählen, leg zuerst eine Variable an: '
        'Variablen > Neue Variable > nenn sie "punkte".\n\nDann reichen zwei '
        'Blöcke:\n- Beim Spielstart: "setze punkte auf 0"\n- Wenn du '
        'punktest: "ändere punkte um 1"\n\nSetz das Häkchen neben der '
        'Variable, dann erscheinen die Punkte auf der Bühne. Leben, Zeit und '
        'Level gehen genauso - nur der Name der Variable ändert sich.',
    answerEs:
        'Para llevar la puntuación en Scratch, primero crea una variable: '
        'Variables > Crear una variable > llámala "puntos".\n\nLuego bastan '
        'dos bloques:\n- Al empezar la partida: "fijar puntos a 0"\n- Al '
        'ganar un punto: "cambiar puntos en 1"\n\nMarca la casilla al lado de '
        'la variable y la puntuación aparece en el escenario. Las vidas, el '
        'tiempo y el nivel funcionan igual: solo cambia el nombre de la '
        'variable.',
    relatedIds: ['scratch', 'variable', 'scratch_events'],
  ),
  KnowledgeEntry(
    id: 'scratch_sound',
    keywords: [
      'ses eklemek',
      'muzik yapmak',
      'nota calmak',
      'sound in scratch',
      'add sound',
      'klang',
      'gerausch',
      'musik machen',
      'anadir sonido',
      'poner musica',
      'scratch e ses nasil eklerim',
      'how do i add sound in scratch',
      'wie fuge ich in scratch klang hinzu',
      'como anado sonido en scratch',
    ],
    answerTr:
        'Scratch\'te pembe "Ses" blokları var:\n\n- "ses çal" hemen geçer, '
        '"sesi bitene kadar çal" bekler\n- "nota çal" ile basit bir melodi '
        'kurabilirsin\n- Sesler sekmesinden hazır ses eklersin ya da '
        'mikrofonla kendi sesini kaydedersin\n\nKüçük bir alıştırma: kedi bir '
        'engele değdiğinde "miyav" çalsın. Olaylar bloğuyla birleştir, oyunun '
        'bir anda canlanır.',
    answerEn:
        'Scratch has pink "Sound" blocks:\n\n- "start sound" moves on right '
        'away, "play sound until done" waits\n- "play note" lets you build a '
        'simple melody\n- In the Sounds tab you add a ready made sound or '
        'record your own with the microphone\n\nA small exercise: make the '
        'cat play "meow" when it touches an obstacle. Combine it with an '
        'Events block and your game comes alive.',
    answerDe:
        'Scratch hat rosa "Klang" Blöcke:\n\n- "spiele Klang" läuft sofort '
        'weiter, "spiele Klang ganz" wartet ab\n- Mit "spiele Ton" baust du '
        'eine einfache Melodie\n- Im Reiter Klänge fügst du einen fertigen '
        'Klang ein oder nimmst mit dem Mikrofon deinen eigenen auf\n\nEine '
        'kleine Übung: Lass die Katze "miau" abspielen, wenn sie ein '
        'Hindernis berührt. Kombiniere das mit einem Ereignisblock und dein '
        'Spiel wird lebendig.',
    answerEs:
        'Scratch tiene bloques rosas de "Sonido":\n\n- "iniciar sonido" sigue '
        'enseguida, "tocar sonido hasta que termine" espera\n- Con "tocar '
        'nota" puedes montar una melodía sencilla\n- En la pestaña Sonidos '
        'añades un sonido ya hecho o grabas el tuyo con el micrófono\n\nUn '
        'ejercicio pequeño: que el gato haga "miau" cuando toque un '
        'obstáculo. Combínalo con un bloque de Eventos y tu juego cobra vida.',
    relatedIds: ['scratch', 'scratch_events', 'scratch_sprite'],
  ),
  KnowledgeEntry(
    id: 'arduino_simulator',
    keywords: [
      'arduino atolyesi',
      'arduino workshop',
      'arduino werkstatt',
      'taller de arduino',
      'arduino oyunu',
      'arduino simulator',
      'simulatoru',
      'simulador',
      'arduino atolyesi nasil kullanilir',
      'how does the arduino workshop work',
      'wie funktioniert die arduino werkstatt',
      'como funciona el taller de arduino',
    ],
    answerTr:
        'Arduino Atölyesi\'nde gerçek karta ihtiyaç duymadan Arduino '
        'öğrenirsin. İki tür görev var:\n\n'
        '- Kod görevi: mBlock bloklarına dokunup kodu kurarsın, Çalıştır\'a '
        'basınca sanal kartta LED gerçekten yanar, buzzer öter, servo döner.\n'
        '- Devre görevi: çizili bir devrede bir parça eksiktir, üç seçenekten '
        'doğrusunu seçersin.\n\n'
        'Kablo çekmek yok; parçalar karta zaten bağlı. Bloklar mBlock\'takilerle '
        'birebir aynı, o yüzden gerçek kartta da aynısını kurabilirsin.',
    answerEn:
        'The Arduino Workshop teaches you Arduino without a real board. There '
        'are two kinds of tasks:\n\n'
        '- Code tasks: tap mBlock blocks to build the code, press Run, and the '
        'LED on the virtual board really lights up, the buzzer sounds and the '
        'servo turns.\n'
        '- Circuit tasks: a part is missing from a drawn circuit and you pick '
        'the right one out of three.\n\n'
        'There is no wiring; the parts are already connected. The blocks match '
        'mBlock exactly, so you can build the same thing on a real board.',
    answerDe:
        'In der Arduino-Werkstatt lernst du Arduino ohne echte Platine. Es gibt '
        'zwei Arten von Aufgaben:\n\n'
        '- Code-Aufgaben: Tippe auf mBlock-Blöcke, bau den Code, drück Start - '
        'und auf der virtuellen Platine leuchtet die LED wirklich, der Summer '
        'klingt, der Servo dreht sich.\n'
        '- Schaltungsaufgaben: In einer gezeichneten Schaltung fehlt ein Teil '
        'und du wählst aus drei Möglichkeiten das richtige.\n\n'
        'Kein Verkabeln; die Teile sind schon angeschlossen. Die Blöcke sind '
        'genau die von mBlock, du kannst dasselbe also auf einer echten '
        'Platine bauen.',
    answerEs:
        'En el Taller de Arduino aprendes Arduino sin tener una placa real. Hay '
        'dos tipos de tareas:\n\n'
        '- Tareas de código: tocas bloques de mBlock para montar el código, '
        'pulsas Ejecutar y en la placa virtual el LED se enciende de verdad, el '
        'zumbador suena y el servo gira.\n'
        '- Tareas de circuito: falta una pieza en un circuito dibujado y eliges '
        'la correcta entre tres.\n\n'
        'No hay que cablear; las piezas ya están conectadas. Los bloques son los '
        'de mBlock, así que puedes montar lo mismo en una placa real.',
    relatedIds: ['arduino', 'arduino_setup_loop', 'motor_led', 'arduino_circuit'],
  ),
  KnowledgeEntry(
    id: 'quiz_how',
    keywords: [
      'quiz',
      'quizler',
      'bilgi yarismasi',
      'how does the quiz work',
      'millionaire',
      'wie funktioniert das quiz',
      'quizspiel',
      'como funciona el cuestionario',
      'cuestionario',
      'concurso',
      'quizler nasil calisir',
      'how do the quizzes work',
      'wie funktionieren die quiz',
      'como funcionan los cuestionarios',
    ],
    answerTr:
        'İki tür soru var:\n\n- Modül quizleri: bir kursu bitirince çıkar. '
        'Sonunda yanlış cevapladığın soruları doğrusuyla birlikte görürsün, '
        'böylece nerede eksik kaldığın belli olur.\n- Bilgi Yarışması oyunu: '
        'sırayla zorlaşan sorular, doğru cevapladıkça ilerlersin.\n\nYanlış '
        'cevap puanını düşürmez; sadece doğru cevap puan ekler. O yüzden emin '
        'olmasan da dene.',
    answerEn:
        'There are two kinds of questions:\n\n- Module quizzes: they appear '
        'when you finish a course. At the end you see the questions you got '
        'wrong together with the right answer, so you know what to go back '
        'to.\n- The quiz game: questions that get harder as you go, and you '
        'advance with each correct answer.\n\nA wrong answer never lowers '
        'your score; only a correct one adds to it. So have a go even when '
        'you are not sure.',
    answerDe:
        'Es gibt zwei Arten von Fragen:\n\n- Modul Quiz: erscheint, wenn du '
        'einen Kurs beendest. Am Ende siehst du die falsch beantworteten '
        'Fragen zusammen mit der richtigen Antwort, so weißt du, wo du '
        'nachschauen musst.\n- Das Quizspiel: Die Fragen werden Schritt für '
        'Schritt schwerer, und mit jeder richtigen Antwort kommst du '
        'weiter.\n\nEine falsche Antwort zieht dir nie Punkte ab; nur eine '
        'richtige bringt welche. Probier es also auch, wenn du unsicher bist.',
    answerEs:
        'Hay dos tipos de preguntas:\n\n- Cuestionarios de módulo: aparecen '
        'al terminar un curso. Al final ves las preguntas que fallaste junto '
        'con la respuesta correcta, así sabes qué repasar.\n- El juego de '
        'preguntas: van subiendo de dificultad y avanzas con cada '
        'acierto.\n\nUna respuesta incorrecta nunca te quita puntos; solo la '
        'correcta suma. Así que inténtalo aunque no estés seguro.',
    relatedIds: ['games', 'xp', 'fear_mistakes'],
  ),
  KnowledgeEntry(
    id: 'game_coordinate',
    keywords: [
      'koordinat',
      'koordinat oyunu',
      'izgara',
      'coordinate',
      'coordinates',
      'koordinaten',
      'gitter',
      'coordenadas',
      'cuadricula',
      'koordinat oyununda ipucu',
      'a hint for the coordinate game',
      'ein tipp fur das koordinatenspiel',
      'una pista para el juego de coordenadas',
    ],
    answerTr:
        'Koordinat oyununda ızgaradaki bir noktayı bulman isteniyor. '
        'Koordinat her zaman (x, y) sırasıyla yazılır: önce sağa doğru olan '
        'sayı, sonra yukarı doğru olan.\n\nİpucu: parmağını önce yatay '
        'eksende kaydır, sonra yukarı çık. (3, 2) demek "3 sağa, 2 '
        'yukarı".\n\nAynı mantığı Scratch\'te "x: ... y: ... konumuna git" '
        'bloğunda kullanıyorsun; orada ızgaranın ortası (0, 0).',
    answerEn:
        'In the coordinate game you have to find a point on the grid. A '
        'coordinate is always written in the order (x, y): first the number '
        'going right, then the one going up.\n\nA tip: slide your finger '
        'along the horizontal axis first, then go up. (3, 2) means "3 to the '
        'right, 2 up".\n\nYou use the same idea in the Scratch block "go to '
        'x: ... y: ..."; there the middle of the grid is (0, 0).',
    answerDe:
        'Im Koordinatenspiel sollst du einen Punkt im Gitter finden. Eine '
        'Koordinate schreibt man immer in der Reihenfolge (x, y): erst die '
        'Zahl nach rechts, dann die nach oben.\n\nEin Tipp: Fahr mit dem '
        'Finger zuerst die waagerechte Achse entlang und geh dann nach oben. '
        '(3, 2) heißt "3 nach rechts, 2 nach oben".\n\nDieselbe Idee nutzt du '
        'im Scratch Block "gehe zu x: ... y: ..."; dort ist die Mitte des '
        'Gitters (0, 0).',
    answerEs:
        'En el juego de coordenadas tienes que encontrar un punto en la '
        'cuadrícula. Una coordenada siempre se escribe en el orden (x, y): '
        'primero el número hacia la derecha y luego el que sube.\n\nUn '
        'consejo: desliza el dedo primero por el eje horizontal y después '
        'sube. (3, 2) significa "3 a la derecha, 2 arriba".\n\nUsas la misma '
        'idea en el bloque de Scratch "ir a x: ... y: ..."; ahí el centro de '
        'la cuadrícula es (0, 0).',
    relatedIds: ['games', 'scratch', 'game_maze'],
  ),
  KnowledgeEntry(
    id: 'fear_mistakes',
    keywords: [
      'hata yapmaktan korkuyorum',
      'yanlis yaparsam',
      'bozarsam',
      'afraid of mistakes',
      'what if i get it wrong',
      'angst vor fehlern',
      'was wenn ich es falsch mache',
      'miedo a equivocarme',
      'y si me equivoco',
      'i am afraid of making mistakes',
      'ich habe angst vor fehlern',
      'me da miedo equivocarme',
    ],
    answerTr:
        'Hata yapmak kodlamanın bir parçası; hatasız kod yazan kimse yok. '
        'Hata mesajı seni azarlamıyor, sadece nerede takıldığını söylüyor - '
        'aslında yardım ediyor.\n\nBurada hiçbir yanlış cevap puanını '
        'düşürmez, seviyeni geri almaz, seriyi bozmaz. İstediğin kadar '
        'deneyebilirsin.\n\nBir şeyi bozarsan geri alabilir ya da baştan '
        'başlayabilirsin. Kırılacak bir şey yok.',
    answerEn:
        'Making mistakes is part of coding; nobody writes code without them. '
        'An error message is not telling you off, it is telling you where you '
        'got stuck - it is actually helping.\n\nHere a wrong answer never '
        'lowers your score, never takes back your level and never breaks your '
        'streak. You can try as many times as you like.\n\nIf you break '
        'something you can undo it or start again. There is nothing here you '
        'can damage.',
    answerDe:
        'Fehler zu machen gehört zum Programmieren; niemand schreibt Code '
        'ohne sie. Eine Fehlermeldung schimpft nicht mit dir, sie sagt dir, '
        'wo du hängst - sie hilft dir sogar.\n\nHier zieht eine falsche '
        'Antwort nie Punkte ab, nimmt dir nie dein Level weg und zerstört '
        'auch deine Serie nicht. Du darfst so oft probieren, wie du '
        'willst.\n\nWenn du etwas kaputt machst, kannst du es rückgängig '
        'machen oder neu anfangen. Hier kann nichts zu Bruch gehen.',
    answerEs:
        'Equivocarse forma parte de programar; nadie escribe código sin '
        'errores. Un mensaje de error no te está regañando, te está diciendo '
        'dónde te has atascado: en realidad te ayuda.\n\nAquí una respuesta '
        'incorrecta nunca te baja la puntuación, nunca te quita el nivel y '
        'nunca rompe tu racha. Puedes intentarlo las veces que quieras.\n\nSi '
        'rompes algo, puedes deshacerlo o empezar de nuevo. No hay nada que '
        'puedas estropear.',
    relatedIds: ['debug', 'motivation', 'quiz_how'],
  ),
  KnowledgeEntry(
    id: 'english_terms',
    keywords: [
      'ingilizce kelimeler',
      'ingilizce terimler',
      'kod ingilizcesi',
      'coding words',
      'coding terms',
      'englische begriffe',
      'was heissen die befehle',
      'palabras en ingles',
      'terminos en ingles',
      'koddaki ingilizce kelimeler ne demek',
      'what do the english coding words mean',
      'was heissen die englischen begriffe',
      'que significan las palabras en ingles',
    ],
    answerTr:
        'Kodlamada sık geçen İngilizce kelimeler ve anlamları:\n\n- print: '
        'yazdır\n- input: girdi, kullanıcıdan al\n- if / else: eğer / '
        'değilse\n- for / while: döngü kur\n- true / false: doğru / yanlış\n- '
        'variable: değişken\n- function: fonksiyon\n- return: geri döndür\n- '
        'error: hata\n- run: çalıştır, save: kaydet\n\nHepsi bu kadar. 20-30 '
        'kelimeyi tanıdığında çoğu kodu okuyabilirsin.',
    answerEn:
        'The English words you meet most while coding, in plain '
        'language:\n\n- print: show it on the screen\n- input: ask the person '
        'using the program\n- if / else: when this / otherwise\n- for / '
        'while: repeat\n- true / false: yes / no for the computer\n- '
        'variable: a named box that holds a value\n- function: a job with a '
        'name\n- return: hand the answer back\n- error: something went '
        'wrong\n- run: start it, save: keep it\n\nThat is about it. Once you '
        'know 20-30 words you can read most code.',
    answerDe:
        'Die englischen Wörter, die dir beim Programmieren am häufigsten '
        'begegnen:\n\n- print: ausgeben, auf den Bildschirm schreiben\n- '
        'input: Eingabe, von der Benutzerin holen\n- if / else: falls / '
        'sonst\n- for / while: wiederholen\n- true / false: wahr / falsch\n- '
        'variable: Variable\n- function: Funktion\n- return: zurückgeben\n- '
        'error: Fehler\n- run: ausführen, save: speichern\n\nMehr ist es '
        'nicht. Mit 20-30 Wörtern kannst du den meisten Code lesen.',
    answerEs:
        'Las palabras en inglés que más aparecen al programar y qué '
        'significan:\n\n- print: imprimir, mostrar en pantalla\n- input: '
        'entrada, pedir a la persona\n- if / else: si / si no\n- for / while: '
        'repetir\n- true / false: verdadero / falso\n- variable: variable\n- '
        'function: función\n- return: devolver\n- error: error\n- run: '
        'ejecutar, save: guardar\n\nY poco más. Con 20 o 30 palabras ya '
        'puedes leer casi cualquier código.',
    relatedIds: ['math_needed', 'print_input', 'condition'],
  ),
  // ------------------------------------------------------- uygulamanin kendisi
  //
  // Bu bolumdeki kayitlar cocugun "bu nedir, kim yapti, nereden geliyor"
  // sorularina cevap veriyor. Hicbiri tahmin degil: sirket bilgisi
  // yayincinin kendi bilgisi, videolarin kaynagi ise katalogdaki gercek
  // durum (YouTube serileri, kanal adi ve orijinal baglantiyla).
  KnowledgeEntry(
    id: 'app_what',
    keywords: [
      'bu uygulama nedir',
      'uygulama nedir',
      'deveducation nedir',
      'devkom nedir',
      'ne ise yarar bu',
      'burasi nedir',
      'what is this app',
      'what is deveducation',
      'what does this app do',
      'was ist diese app',
      'was macht diese app',
      'que es esta aplicacion',
      'que es esta app',
      'para que sirve esta aplicacion',
    ],
    answerTr:
        'Burası DevEducation: kodlamayı ve robotiği sıfırdan öğreten bir '
        'uygulama.\n\n'
        'İçinde dört şey var:\n'
        '- Dersler: Scratch ile bloklardan başlayıp Python, HTML, CSS ve '
        'Arduino gibi gerçek kod yazmaya kadar gidiyor.\n'
        '- Oyunlar: labirent, hata avı, satranç gibi düşünme oyunları.\n'
        '- Videolar: her konu için sıraya dizilmiş ders serileri.\n'
        '- Ben: takıldığın yerde soru sorabileceğin yardımcı.\n\n'
        'Ders bitirdikçe XP ve jeton kazanıyorsun.',
    answerEn:
        'This is DevEducation: an app that teaches coding and robotics from '
        'zero.\n\n'
        'It has four parts:\n'
        '- Lessons: start with Scratch blocks and go all the way to real code '
        'in Python, HTML, CSS and Arduino.\n'
        '- Games: mazes, bug hunts, chess and other thinking games.\n'
        '- Videos: lesson series put in order for each topic.\n'
        '- Me: someone to ask when you get stuck.\n\n'
        'You earn XP and coins as you finish lessons.',
    answerDe:
        'Das hier ist DevEducation: eine App, die Programmieren und Robotik '
        'von Null an beibringt.\n\n'
        'Es gibt vier Teile:\n'
        '- Lektionen: von Scratch-Blöcken bis zu echtem Code in Python, HTML, '
        'CSS und Arduino.\n'
        '- Spiele: Labyrinthe, Fehlersuche, Schach und andere Denkspiele.\n'
        '- Videos: geordnete Lernreihen zu jedem Thema.\n'
        '- Ich: jemand, den du fragen kannst, wenn du nicht weiterkommst.\n\n'
        'Für fertige Lektionen bekommst du XP und Münzen.',
    answerEs:
        'Esto es DevEducation: una app que enseña programación y robótica '
        'desde cero.\n\n'
        'Tiene cuatro partes:\n'
        '- Lecciones: empiezas con bloques de Scratch y llegas a escribir '
        'código real en Python, HTML, CSS y Arduino.\n'
        '- Juegos: laberintos, caza de errores, ajedrez y otros juegos de '
        'pensar.\n'
        '- Vídeos: series de clases ordenadas para cada tema.\n'
        '- Yo: alguien a quien preguntar cuando te atascas.\n\n'
        'Ganas XP y monedas cuando terminas lecciones.',
    relatedIds: ['maker', 'where_start', 'videos'],
  ),
  KnowledgeEntry(
    id: 'maker',
    keywords: [
      'kim yapti',
      'kim gelistirdi',
      'yapimcisi kim',
      'gelistirici kim',
      'sahibi kim',
      'hangi sirket',
      'nerede yapildi',
      'devkom yazilim',
      'who made this',
      'who made this app',
      'who created this app',
      'who developed this app',
      'which company',
      'wer hat diese app gemacht',
      'wer hat das entwickelt',
      'welche firma',
      'quien hizo esta aplicacion',
      'quien hizo esta app',
      'quien creo esta app',
      'quien la hizo',
      'que empresa',
    ],
    answerTr:
        'DevEducation, Türkiye\'nin Konya şehrindeki Devkom Yazılım tarafından '
        'geliştiriliyor ve yayınlanıyor.\n\n'
        'Derslerin içeriğini, oyunları ve benim cevaplarımı da aynı ekip '
        'yazıyor — bu yüzden cevaplarım her zaman elle yazılmış ve gözden '
        'geçirilmiş oluyor.',
    answerEn:
        'DevEducation is developed and published by Devkom Yazılım, a company '
        'based in Konya, Türkiye.\n\n'
        'The same team writes the lessons, the games and my answers — that is '
        'why everything I say was written and checked by a person.',
    answerDe:
        'DevEducation wird von Devkom Yazılım entwickelt und veröffentlicht, '
        'einer Firma aus Konya in der Türkei.\n\n'
        'Dasselbe Team schreibt die Lektionen, die Spiele und meine '
        'Antworten — deshalb ist alles, was ich sage, von Menschen '
        'geschrieben und geprüft.',
    answerEs:
        'DevEducation está desarrollada y publicada por Devkom Yazılım, una '
        'empresa de Konya, Turquía.\n\n'
        'El mismo equipo escribe las lecciones, los juegos y mis respuestas: '
        'por eso todo lo que digo lo ha escrito y revisado una persona.',
    relatedIds: ['app_what', 'who_are_you', 'contact_support'],
  ),
  KnowledgeEntry(
    id: 'contact_support',
    keywords: [
      'hata bildir',
      'hata nasil bildiririm',
      'nasil bildiririm',
      'bildirmek istiyorum',
      'sorun bildir',
      'iletisim',
      'nasil ulasirim',
      'destek',
      'sikayet',
      'oneri gonder',
      'report a bug',
      'report a problem',
      'contact you',
      'support',
      'fehler melden',
      'wie melde ich einen fehler',
      'problem melden',
      'kontakt',
      'reportar un error',
      'como informo de un error',
      'informar de un error',
      'contacto',
      'soporte',
    ],
    answerTr:
        'Bir hata bulduysan ya da bir şey önereceksen velinden yardım iste: '
        'App Store\'daki uygulama sayfasında geliştiriciye yazma bağlantısı '
        'var.\n\n'
        'Yazarken üç şey çok işe yarıyor: hangi ekrandaydın, ne yaptın, ne '
        'oldu. Bu üç cümle bir hatayı bulmayı çok kolaylaştırıyor — gerçek '
        'yazılımcılar da hata raporlarını böyle yazar.',
    answerEn:
        'If you found a bug or have an idea, ask a grown-up for help: the '
        'app\'s App Store page has a link for writing to the developer.\n\n'
        'Three things help a lot: which screen you were on, what you did, and '
        'what happened. Those three sentences make a bug much easier to find '
        '— real developers write bug reports the same way.',
    answerDe:
        'Wenn du einen Fehler gefunden hast oder eine Idee hast, frag eine '
        'erwachsene Person: Auf der App-Store-Seite der App gibt es einen '
        'Link, um den Entwicklern zu schreiben.\n\n'
        'Drei Dinge helfen sehr: auf welchem Bildschirm du warst, was du '
        'gemacht hast und was passiert ist. Genau so schreiben auch echte '
        'Entwicklerinnen Fehlerberichte.',
    answerEs:
        'Si has encontrado un error o tienes una idea, pide ayuda a una '
        'persona adulta: la página de la app en la App Store tiene un enlace '
        'para escribir a quienes la desarrollan.\n\n'
        'Tres cosas ayudan mucho: en qué pantalla estabas, qué hiciste y qué '
        'pasó. Así escriben los informes de errores los programadores de '
        'verdad.',
    relatedIds: ['maker', 'debug', 'error'],
  ),
  KnowledgeEntry(
    id: 'video_source',
    keywords: [
      'videolar nereden',
      'videolar nereden geliyor',
      'video nereden',
      'videoyu kim cekiyor',
      'videolari kim yapiyor',
      'where do the videos come from',
      'who makes the videos',
      'woher kommen die videos',
      'wer macht die videos',
      'de donde vienen los videos',
      'quien hace los videos',
    ],
    answerTr:
        'Videolar YouTube\'da yayınlanan ders serileri. Ekip her seriyi tek '
        'tek izleyip sıraya diziyor; uygulama da onları burada oynatıyor.\n\n'
        'Her bölümün altında videoyu çeken kanalın adı ve orijinal bağlantısı '
        'yazıyor — emeği kimin olduğu her zaman görünür. Seriler ücretsiz, '
        'Pro gerekmiyor.',
    answerEn:
        'The videos are lesson series published on YouTube. The team watches '
        'each series and puts the episodes in order; the app plays them '
        'here.\n\n'
        'Under every episode you see the name of the channel that made it and '
        'a link to the original — whose work it is always stays visible. The '
        'series are free, no Pro needed.',
    answerDe:
        'Die Videos sind Lernreihen, die auf YouTube veröffentlicht sind. Das '
        'Team schaut jede Reihe an und bringt die Folgen in eine Reihenfolge; '
        'die App spielt sie hier ab.\n\n'
        'Unter jeder Folge stehen der Name des Kanals und der Link zum '
        'Original — man sieht immer, von wem die Arbeit ist. Die Reihen sind '
        'kostenlos, du brauchst kein Pro.',
    answerEs:
        'Los vídeos son series de clases publicadas en YouTube. El equipo ve '
        'cada serie y ordena los episodios; la app los reproduce aquí.\n\n'
        'Debajo de cada episodio aparece el nombre del canal que lo hizo y el '
        'enlace al original: siempre se ve de quién es el trabajo. Las series '
        'son gratis, no hace falta Pro.',
    relatedIds: ['videos', 'app_what'],
  ),
  KnowledgeEntry(
    id: 'software_what',
    keywords: [
      'yazilim nedir',
      'program nedir',
      'uygulama nasil yapilir',
      'kod nedir',
      'what is software',
      'what is a program',
      'what is code',
      'was ist software',
      'was ist ein programm',
      'que es el software',
      'que es un programa',
      'que es el codigo',
    ],
    answerTr:
        'Yazılım, bilgisayara ne yapacağını söyleyen yazılı talimatların '
        'tamamı. Telefonundaki her uygulama bir yazılım — bu uygulama da.\n\n'
        'Talimatları yazmaya kod yazmak diyoruz. Bilgisayar kendi başına '
        'hiçbir şey bilmez: "şu resmi göster", "bu sayıyı topla", "düğmeye '
        'basılınca şunu yap" diye tek tek söylemek gerekir.\n\n'
        'Donanım ise elle tutabildiğin kısım: ekran, işlemci, kablo. Yazılım '
        'olmadan donanım kıpırdamaz; donanım olmadan yazılımın çalışacağı bir '
        'yer olmaz.',
    answerEn:
        'Software is all the written instructions that tell a computer what '
        'to do. Every app on your phone is software — including this one.\n\n'
        'Writing those instructions is called coding. A computer knows '
        'nothing by itself: you have to say "show this picture", "add these '
        'numbers", "when the button is pressed, do this".\n\n'
        'Hardware is the part you can touch: screen, processor, cables. '
        'Without software the hardware does nothing; without hardware the '
        'software has nowhere to run.',
    answerDe:
        'Software sind alle geschriebenen Anweisungen, die dem Computer '
        'sagen, was er tun soll. Jede App auf deinem Handy ist Software — '
        'auch diese hier.\n\n'
        'Diese Anweisungen zu schreiben nennt man Programmieren. Ein Computer '
        'weiß von allein gar nichts: Man muss ihm sagen "zeig dieses Bild", '
        '"addiere diese Zahlen", "wenn der Knopf gedrückt wird, mach das".\n\n'
        'Hardware ist der Teil, den du anfassen kannst: Bildschirm, '
        'Prozessor, Kabel. Ohne Software tut die Hardware nichts; ohne '
        'Hardware hat die Software keinen Ort zum Laufen.',
    answerEs:
        'El software son todas las instrucciones escritas que le dicen al '
        'ordenador qué hacer. Cada app de tu teléfono es software, también '
        'esta.\n\n'
        'Escribir esas instrucciones se llama programar. Un ordenador no sabe '
        'nada por sí solo: hay que decirle "muestra esta imagen", "suma estos '
        'números", "cuando se pulse el botón, haz esto".\n\n'
        'El hardware es la parte que puedes tocar: pantalla, procesador, '
        'cables. Sin software el hardware no hace nada; sin hardware el '
        'software no tiene dónde funcionar.',
    relatedIds: ['computer_basics', 'block_coding', 'which_program'],
  ),
  KnowledgeEntry(
    id: 'block_coding',
    keywords: [
      'blok kodlama',
      'blok kodlama nedir',
      'blok kodlama ne ise yarar',
      'bloklu kodlama',
      'neden blok',
      'block coding',
      'block based coding',
      'what is block coding',
      'blockbasiertes programmieren',
      'blockprogrammierung',
      'wozu blockprogrammierung',
      'was bringt blockprogrammierung',
      'programacion con bloques',
      'programacion por bloques',
      'para que sirve la programacion por bloques',
      'para que sirve programar por bloques',
      'programar por bloques',
      'bloques',
    ],
    answerTr:
        'Blok kodlama, kod satırlarını yazmak yerine yapboz parçası gibi '
        'blokları birleştirmek demek. Scratch ve mBlock böyle çalışıyor.\n\n'
        'Ne işe yarıyor: kodlamanın zor kısmı yazım değil, DÜŞÜNME kısmı — '
        'hangi adım önce gelir, ne zaman tekrar eder, hangi durumda ne olur. '
        'Bloklar yazım hatasını ortadan kaldırıyor (noktalı virgül unutmak '
        'yok) ve sen sadece sırayı düşünüyorsun.\n\n'
        'Aynı fikirler yazılı kodda birebir var: "10 defa tekrarla" bloğu '
        'Python\'da `for i in range(10):` oluyor. Yani blokla öğrendiğin şey '
        'boşa gitmiyor, sadece görünüşü değişiyor.',
    answerEn:
        'Block coding means snapping blocks together like puzzle pieces '
        'instead of typing lines of code. Scratch and mBlock work this way.\n\n'
        'Why it helps: the hard part of coding is not the typing, it is the '
        'THINKING — which step comes first, what repeats, what happens in '
        'each case. Blocks remove typing mistakes (no forgotten semicolons) '
        'so you only think about the order.\n\n'
        'The same ideas exist in written code: the "repeat 10 times" block is '
        '`for i in range(10):` in Python. What you learn with blocks is not '
        'wasted, it just looks different later.',
    answerDe:
        'Blockprogrammierung heißt, Blöcke wie Puzzleteile zusammenzustecken, '
        'statt Codezeilen zu tippen. Scratch und mBlock funktionieren so.\n\n'
        'Warum das hilft: Das Schwere am Programmieren ist nicht das Tippen, '
        'sondern das DENKEN — welcher Schritt kommt zuerst, was wiederholt '
        'sich, was passiert in welchem Fall. Blöcke nehmen die Tippfehler weg '
        '(kein vergessenes Semikolon), du denkst nur über die Reihenfolge '
        'nach.\n\n'
        'Dieselben Ideen gibt es im geschriebenen Code: Der Block '
        '"wiederhole 10 mal" ist in Python `for i in range(10):`. Was du mit '
        'Blöcken lernst, ist also nicht verloren, es sieht später nur anders '
        'aus.',
    answerEs:
        'La programación por bloques consiste en encajar bloques como piezas '
        'de puzle en vez de escribir líneas de código. Scratch y mBlock '
        'funcionan así.\n\n'
        'Para qué sirve: lo difícil de programar no es escribir, es PENSAR: '
        'qué paso va primero, qué se repite, qué pasa en cada caso. Los '
        'bloques quitan los errores de escritura (no hay puntos y comas '
        'olvidados) y solo piensas en el orden.\n\n'
        'Las mismas ideas están en el código escrito: el bloque "repetir 10 '
        'veces" es `for i in range(10):` en Python. Lo que aprendes con '
        'bloques no se pierde, solo cambia de aspecto.',
    relatedIds: ['scratch', 'mblock', 'loop'],
  ),
  KnowledgeEntry(
    id: 'why_coding',
    keywords: [
      'neden kodlama',
      'neden kod ogrenmeliyim',
      'kodlama ne ise yarar',
      'ne ise yarayacak',
      'why learn coding',
      'why should i code',
      'why should i learn to code',
      'why learn to code',
      'warum soll ich programmieren lernen',
      'por que deberia aprender a programar',
      'what is coding good for',
      'warum programmieren lernen',
      'wozu programmieren',
      'por que aprender a programar',
      'para que sirve programar',
    ],
    answerTr:
        'İki sebep var ve ikisi de gerçek.\n\n'
        'Birincisi: kod yazmak, bir işi bilgisayarın anlayacağı kadar küçük '
        'adımlara bölmeyi öğretiyor. Bu beceri ödevde de, oyun kurarken de, '
        'bir şeyi tamir ederken de işe yarıyor.\n\n'
        'İkincisi: kendi şeylerini yapabiliyorsun. Oyun, site, çizim yapan '
        'bir program, ışığı yanıp sönen bir robot. Kullanan değil YAPAN taraf '
        'olmak, bilgisayarla kurduğun ilişkiyi değiştiriyor.\n\n'
        'Ve iyi haber: kimse ilk denemede doğru yazmıyor. Yazılımcıların '
        'işinin büyük kısmı hata bulup düzeltmek.',
    answerEn:
        'Two reasons, and both are real.\n\n'
        'First: writing code teaches you to break a job into steps small '
        'enough for a computer to understand. That skill helps with homework, '
        'with building a game, with fixing things.\n\n'
        'Second: you can make your own things. A game, a website, a program '
        'that draws, a robot that blinks. Being the one who MAKES instead of '
        'only using changes how you see computers.\n\n'
        'And good news: nobody gets it right the first time. Most of a '
        'developer\'s job is finding and fixing mistakes.',
    answerDe:
        'Zwei Gründe, und beide sind echt.\n\n'
        'Erstens: Programmieren bringt dir bei, eine Aufgabe in Schritte zu '
        'zerlegen, die klein genug für einen Computer sind. Das hilft bei '
        'Hausaufgaben, beim Bauen eines Spiels und beim Reparieren von '
        'Sachen.\n\n'
        'Zweitens: Du kannst eigene Dinge bauen. Ein Spiel, eine Website, ein '
        'Programm, das zeichnet, einen Roboter, der blinkt. Selbst zu MACHEN '
        'statt nur zu benutzen verändert dein Verhältnis zum Computer.\n\n'
        'Und die gute Nachricht: Niemand schafft es beim ersten Versuch. Der '
        'größte Teil der Arbeit von Entwicklerinnen ist Fehler finden und '
        'beheben.',
    answerEs:
        'Dos razones, y las dos son de verdad.\n\n'
        'Primera: programar te enseña a dividir una tarea en pasos lo '
        'bastante pequeños para que un ordenador los entienda. Eso sirve para '
        'los deberes, para montar un juego y para arreglar cosas.\n\n'
        'Segunda: puedes crear cosas tuyas. Un juego, una web, un programa '
        'que dibuja, un robot que parpadea. Ser quien CREA y no solo quien usa '
        'cambia tu relación con el ordenador.\n\n'
        'Y una buena noticia: nadie lo hace bien a la primera. La mayor parte '
        'del trabajo de programar es encontrar y corregir errores.',
    relatedIds: ['career', 'where_start', 'fear_mistakes'],
  ),
  KnowledgeEntry(
    id: 'binary_what',
    keywords: [
      'ikili sayi',
      'ikilik sistem',
      '0 ve 1',
      'sifir ve bir',
      'bilgisayar nasil sayar',
      'binary',
      'zeros and ones',
      'why does a computer use 0 and 1',
      '0 and 1',
      'warum 0 und 1',
      'por que 0 y 1',
      'por que un ordenador usa 0 y 1',
      'binaer',
      'nullen und einsen',
      'binario',
      'ceros y unos',
    ],
    answerTr:
        'Bilgisayarın içinde milyonlarca minik anahtar var ve her biri ya '
        'AÇIK ya KAPALI. Açık = 1, kapalı = 0. Başka bir şey yok.\n\n'
        'Sayıları böyle yazıyor: 1, 10, 11, 100 — yani 1, 2, 3, 4. Harfleri '
        'de sayıya çeviriyor (A = 65), resmi de: her piksel için üç sayı, '
        'kırmızı-yeşil-mavi.\n\n'
        'Yani ekranındaki her şey, sonunda 0 ve 1 dizisi. Kod yazmak, o '
        'dizileri elle yazmak zorunda kalmamak için var.',
    answerEn:
        'Inside a computer there are millions of tiny switches, and each one '
        'is either ON or OFF. On = 1, off = 0. Nothing else.\n\n'
        'It writes numbers that way: 1, 10, 11, 100 means 1, 2, 3, 4. Letters '
        'become numbers too (A = 65), and so do pictures: three numbers per '
        'pixel, red-green-blue.\n\n'
        'So everything on your screen is a row of 0s and 1s in the end. Code '
        'exists so you never have to write those rows by hand.',
    answerDe:
        'In einem Computer stecken Millionen winziger Schalter, und jeder ist '
        'entweder AN oder AUS. An = 1, aus = 0. Mehr gibt es nicht.\n\n'
        'So schreibt er Zahlen: 1, 10, 11, 100 bedeutet 1, 2, 3, 4. Auch '
        'Buchstaben werden zu Zahlen (A = 65) und Bilder ebenso: drei Zahlen '
        'pro Pixel, Rot-Grün-Blau.\n\n'
        'Alles auf deinem Bildschirm ist am Ende eine Reihe aus 0 und 1. Code '
        'gibt es, damit du diese Reihen nie von Hand schreiben musst.',
    answerEs:
        'Dentro de un ordenador hay millones de interruptores diminutos, y '
        'cada uno está ENCENDIDO o APAGADO. Encendido = 1, apagado = 0. Nada '
        'más.\n\n'
        'Así escribe los números: 1, 10, 11, 100 significa 1, 2, 3, 4. Las '
        'letras también se convierten en números (A = 65), y las imágenes '
        'igual: tres números por píxel, rojo-verde-azul.\n\n'
        'Todo lo que ves en la pantalla acaba siendo una fila de ceros y '
        'unos. El código existe para que nunca tengas que escribir esas filas '
        'a mano.',
    relatedIds: ['computer_basics', 'data_types'],
  ),
  KnowledgeEntry(
    id: 'math_examples',
    keywords: [
      'matematik sorusu',
      'bana bir islem sor',
      'islem sor',
      'bir islem sor',
      'give me a sum',
      'gib mir eine rechnung',
      'ponme una operacion',
      'una operacion',
      'toplama',
      'cikarma',
      'carpma',
      'bolme',
      'islem yapar misin',
      'hesapla',
      'kac eder',
      'math question',
      'can you do math',
      'calculate',
      'addition',
      'multiplication',
      'rechnen',
      'kannst du rechnen',
      'matheaufgabe',
      'puedes calcular',
      'suma',
      'multiplicacion',
      'cuanto es',
    ],
    answerTr:
        'Basit işlemleri hesaplayabiliyorum. Şöyle yaz: "12 + 7", "9 x 8", '
        '"100 - 37", "144 / 12".\n\n'
        'Aynı işlemi Python\'da da yaptırabilirsin:\n'
        'print(12 + 7)\n\n'
        'Bilgisayarların ilk işi zaten hesap yapmaktı; "computer" kelimesi '
        '"hesaplayan" demek.',
    answerEn:
        'I can work out simple sums. Write them like this: "12 + 7", "9 x 8", '
        '"100 - 37", "144 / 12".\n\n'
        'You can make Python do the same thing:\n'
        'print(12 + 7)\n\n'
        'Calculating was the very first job computers had — the word '
        '"computer" means "the one who computes".',
    answerDe:
        'Einfache Rechnungen kann ich ausrechnen. Schreib sie so: "12 + 7", '
        '"9 x 8", "100 - 37", "144 / 12".\n\n'
        'Dasselbe kann auch Python für dich machen:\n'
        'print(12 + 7)\n\n'
        'Rechnen war die allererste Aufgabe von Computern — das Wort '
        '"computer" heißt "der Rechnende".',
    answerEs:
        'Puedo resolver operaciones sencillas. Escríbelas así: "12 + 7", '
        '"9 x 8", "100 - 37", "144 / 12".\n\n'
        'Python puede hacer lo mismo:\n'
        'print(12 + 7)\n\n'
        'Calcular fue el primer trabajo de los ordenadores: la palabra '
        '"computer" significa "el que calcula".',
    relatedIds: ['math_needed', 'python', 'operators'],
  ),
  KnowledgeEntry(
    id: 'times_table',
    keywords: [
      'carpim tablosu',
      'carpim tablosunu',
      'times table',
      'multiplication table',
      'einmaleins',
      'tabla de multiplicar',
      'tablas de multiplicar',
      'carpim tablosu ogret',
    ],
    answerTr:
        'Çarpım tablosunu ezberlemenin en kolay yolu onu bir DÖNGÜ olarak '
        'görmek. 7\'nin tablosu şu:\n\n'
        '7, 14, 21, 28, 35, 42, 49, 56, 63, 70\n\n'
        'Her adımda 7 ekliyorsun — yani aslında bir tekrar bloğu. Python\'da '
        'tam olarak böyle yazılır:\n\n'
        'for i in range(1, 11):\n'
        '    print(7 * i)\n\n'
        'Sen de "9 x 8" gibi bir işlem yazarsan cevabını hesaplarım.',
    answerEn:
        'The easiest way to learn a times table is to see it as a LOOP. The '
        '7 table is:\n\n'
        '7, 14, 21, 28, 35, 42, 49, 56, 63, 70\n\n'
        'Each step adds 7 — that is a repeat block. In Python it is written '
        'exactly like that:\n\n'
        'for i in range(1, 11):\n'
        '    print(7 * i)\n\n'
        'And if you type something like "9 x 8" I will work it out for you.',
    answerDe:
        'Am leichtesten lernst du das Einmaleins, wenn du es als SCHLEIFE '
        'siehst. Die 7er-Reihe:\n\n'
        '7, 14, 21, 28, 35, 42, 49, 56, 63, 70\n\n'
        'Jeder Schritt addiert 7 — das ist ein Wiederholungsblock. In Python '
        'schreibt man genau das:\n\n'
        'for i in range(1, 11):\n'
        '    print(7 * i)\n\n'
        'Und wenn du "9 x 8" schreibst, rechne ich es dir aus.',
    answerEs:
        'La forma más fácil de aprender una tabla es verla como un BUCLE. La '
        'tabla del 7 es:\n\n'
        '7, 14, 21, 28, 35, 42, 49, 56, 63, 70\n\n'
        'Cada paso suma 7: eso es un bloque de repetición. En Python se '
        'escribe justo así:\n\n'
        'for i in range(1, 11):\n'
        '    print(7 * i)\n\n'
        'Y si escribes algo como "9 x 8", te lo calculo.',
    relatedIds: ['math_examples', 'loop', 'python'],
  ),
  KnowledgeEntry(
    id: 'data_privacy',
    keywords: [
      'bilgilerim nerede',
      'verilerim',
      'gizlilik',
      'bilgilerim guvende mi',
      'kim goruyor',
      'my data',
      'privacy',
      'is my data safe',
      'meine daten',
      'datenschutz',
      'mis datos',
      'privacidad',
      'estan seguros mis datos',
    ],
    answerTr:
        'Uygulama senden ad, adres, telefon ya da doğum tarihi istemiyor. '
        'Takma adını sen seçiyorsun ve gerçek adın olmaması daha iyi.\n\n'
        'Saklanan şeyler: hangi dersleri bitirdiğin, XP\'n, jetonun ve '
        'rozetlerin. Bunlar ilerlemeni kaybetmemen için var.\n\n'
        'Sohbetimiz cihazında kalıyor: sorularını hiçbir yere göndermiyorum, '
        'cevaplarım zaten uygulamanın içinde yazılı duruyor.\n\n'
        'Merak eden bir velin varsa gizlilik politikasını App Store '
        'sayfasından okuyabilir.',
    answerEn:
        'The app does not ask for your name, address, phone number or date of '
        'birth. You pick a nickname yourself, and it is better if it is not '
        'your real name.\n\n'
        'What is saved: which lessons you finished, your XP, your coins and '
        'your badges. That exists so you do not lose your progress.\n\n'
        'Our chat stays on your device: I do not send your questions '
        'anywhere, and my answers are already written inside the app.\n\n'
        'If a grown-up is curious, they can read the privacy policy from the '
        'App Store page.',
    answerDe:
        'Die App fragt nicht nach Namen, Adresse, Telefonnummer oder '
        'Geburtsdatum. Deinen Spitznamen suchst du selbst aus, und es ist '
        'besser, wenn es nicht dein echter Name ist.\n\n'
        'Gespeichert wird: welche Lektionen du fertig hast, deine XP, deine '
        'Münzen und deine Abzeichen. Das gibt es, damit dein Fortschritt '
        'nicht verloren geht.\n\n'
        'Unser Chat bleibt auf deinem Gerät: Ich schicke deine Fragen '
        'nirgendwohin, meine Antworten stehen schon in der App.\n\n'
        'Wenn eine erwachsene Person es genau wissen will, kann sie die '
        'Datenschutzerklärung auf der App-Store-Seite lesen.',
    answerEs:
        'La app no te pide el nombre, la dirección, el teléfono ni la fecha '
        'de nacimiento. El apodo lo eliges tú, y es mejor que no sea tu '
        'nombre real.\n\n'
        'Lo que se guarda: qué lecciones has terminado, tus XP, tus monedas y '
        'tus insignias. Eso está para que no pierdas tu progreso.\n\n'
        'Nuestro chat se queda en tu dispositivo: no envío tus preguntas a '
        'ningún sitio y mis respuestas ya están escritas dentro de la app.\n\n'
        'Si una persona adulta quiere saber más, puede leer la política de '
        'privacidad desde la página de la App Store.',
    relatedIds: ['parents', 'save_progress', 'security'],
  ),
  KnowledgeEntry(
    id: 'how_use_app',
    keywords: [
      'nasil kullanilir',
      'bu uygulamayi nasil kullanirim',
      'ne yapmaliyim burada',
      'nasil ilerliyorum',
      'how do i use this app',
      'how does this app work',
      'wie benutze ich diese app',
      'wie funktioniert diese app',
      'como se usa esta aplicacion',
      'como se usa esta app',
      'como funciona esta app',
      'como uso esta app',
    ],
    answerTr:
        'Sıra şöyle işliyor:\n\n'
        '1. Ana sayfada "Kaldığın yer" kartı var — orada tek bir ders '
        'gösteriliyor, hangisini yapacağını düşünmene gerek yok.\n'
        '2. Derse gir, adımları sırayla bitir. Her adım küçük: bir anlatım, '
        'bir soru, bir sürükle-bırak.\n'
        '3. Ders bitince XP ve jeton kazanırsın, yol şeridinde bir adım '
        'ilerlersin.\n'
        '4. Yorulduysan Oyunlar bölümüne geç — onlar da aynı düşünme '
        'becerisini çalıştırıyor.\n\n'
        'Takıldığın her yerde bana sorabilirsin.',
    answerEn:
        'Here is how it goes:\n\n'
        '1. The home screen has a "where you left off" card — it shows one '
        'lesson, so you do not have to decide what to do.\n'
        '2. Open it and finish the steps in order. Each step is small: a '
        'short explanation, a question, a drag-and-drop.\n'
        '3. When the lesson ends you earn XP and coins and move one step '
        'along the path.\n'
        '4. If you get tired, go to Games — they train the same thinking.\n\n'
        'Whenever you get stuck, ask me.',
    answerDe:
        'So läuft es ab:\n\n'
        '1. Auf der Startseite gibt es die Karte "Wo du aufgehört hast" — sie '
        'zeigt genau eine Lektion, du musst dich nicht entscheiden.\n'
        '2. Öffne sie und mach die Schritte der Reihe nach. Jeder Schritt ist '
        'klein: eine kurze Erklärung, eine Frage, ein Ziehen-und-Ablegen.\n'
        '3. Am Ende der Lektion bekommst du XP und Münzen und rückst auf dem '
        'Lernpfad einen Schritt vor.\n'
        '4. Wenn du müde bist, geh zu den Spielen — sie trainieren dasselbe '
        'Denken.\n\n'
        'Wenn du irgendwo stecken bleibst, frag mich.',
    answerEs:
        'Funciona así:\n\n'
        '1. En la pantalla de inicio está la tarjeta "Donde lo dejaste": '
        'muestra una sola lección, así no tienes que decidir.\n'
        '2. Ábrela y termina los pasos en orden. Cada paso es pequeño: una '
        'explicación corta, una pregunta, un arrastrar y soltar.\n'
        '3. Al acabar la lección ganas XP y monedas y avanzas un paso en la '
        'ruta.\n'
        '4. Si te cansas, ve a Juegos: entrenan el mismo tipo de '
        'pensamiento.\n\n'
        'Cuando te atasques, pregúntame.',
    relatedIds: ['where_start', 'xp', 'games'],
  ),
];
