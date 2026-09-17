import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/dev_assistant_knowledge.dart';

/// Asistanin verdigi cevap.
class AssistantReply {
  final String text;

  /// Cevabin altinda gosterilecek devam sorulari (kullaniciya gosterilecek metin).
  final List<String> suggestions;

  /// Bilgi tabaninda eslesme bulundu mu (loglama/test icin).
  final bool matched;

  const AssistantReply({
    required this.text,
    this.suggestions = const [],
    required this.matched,
  });
}

/// Sabit bilgi tabani uzerinde calisan basit eslestirme motoru.
///
/// Dil modeli yok: kullanicinin yazdigi metin normalize edilir, bilgi
/// tabanindaki anahtar kelimelerle puanlanir ve en yuksek puanli kaydin
/// elle yazilmis cevabi dondurulur. Boylece uygulamanin uretebilecegi tum
/// metin onceden bilinir ve gozden gecirilmistir.
///
/// Dort dil destekleniyor: tr, en, de, es. Anahtar kelimeler tek bir listede
/// tutuluyor ve dort dilin terimlerini birlikte iceriyor; normalize() tum
/// aksanlari ASCII'ye indirdigi icin "Schleife", "schleife" ve "bucle" ayni
/// listede yan yana durabiliyor.
class DevAssistantService {
  DevAssistantService._();

  static final DevAssistantService instance = DevAssistantService._();

  /// Bir kaydin secilebilmesi icin gereken en dusuk puan.
  static const double _minScore = 1.0;

  /// Turkce, Almanca ve Ispanyolca aksanlari sadelestirip kucuk harfe cevirir.
  ///
  /// Not: Turkce'de 'I'.toLowerCase() Dart'ta 'i' verir, bu bizim icin yeterli;
  /// asagida zaten tum aksanli harfler ASCII karsiligina cevriliyor. Almanca
  /// 'ß' iki harfe ('ss') aciliyor, bu yuzden harita degeri tek karakter degil.
  static String normalize(String input) {
    const map = {
      // Turkce
      'ç': 'c', 'Ç': 'c',
      'ğ': 'g', 'Ğ': 'g',
      'ı': 'i', 'I': 'i', 'İ': 'i', 'i': 'i',
      'ö': 'o', 'Ö': 'o',
      'ş': 's', 'Ş': 's',
      'ü': 'u', 'Ü': 'u',
      'â': 'a', 'î': 'i', 'û': 'u',
      // Almanca
      'ä': 'a', 'Ä': 'a',
      'ß': 'ss',
      // Ispanyolca
      'á': 'a', 'Á': 'a',
      'é': 'e', 'É': 'e',
      'í': 'i', 'Í': 'i',
      'ó': 'o', 'Ó': 'o',
      'ú': 'u', 'Ú': 'u',
      'ñ': 'n', 'Ñ': 'n',
      // Diger yaygin aksanlar (kopyala-yapistir metinlerde cikabiliyor)
      'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u',
      'ê': 'e', 'ô': 'o', 'ë': 'e', 'ï': 'i',
    };
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(map[ch] ?? ch.toLowerCase());
    }
    // Harf ve rakam disindaki her sey bosluga donsun.
    final cleaned = buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned;
  }

  /// Kullanicinin mesajina karsilik gelen cevabi uretir.
  ///
  /// [lang] degeri 'tr', 'en', 'de' ya da 'es' olabilir; taninmayan bir deger
  /// Turkce kabul edilir.
  AssistantReply reply(String message, {required String lang}) {
    // ONCE HESAP: "12 + 7" gibi bir islem yazildiysa cevabi bilgi
    // tabaninda aramanin anlami yok, hesaplamak gerekiyor.
    final hesap = hesapla(message, lang);
    if (hesap != null) {
      return AssistantReply(
        text: hesap,
        suggestions: _relatedSuggestionsById(
            const ['math_examples', 'times_table', 'python'], lang),
        matched: true,
      );
    }

    final best = bestMatch(message);

    if (best == null) {
      return AssistantReply(
        text: kNoMatchAnswerFor(lang),
        suggestions: _defaultSuggestions(lang),
        matched: false,
      );
    }

    return AssistantReply(
      text: best.answerFor(lang),
      suggestions: _relatedSuggestions(best, lang),
      matched: true,
    );
  }

  /// Basit dort islem. Eslesme yoksa null.
  ///
  /// NEDEN ELLE BIR HESAPLAYICI
  ///
  /// Asistanin cevaplari elle yazilmis metinler; "12 + 7" gibi bir soruya
  /// onceden yazilmis bir cevap olamaz. Cocuklar da bunu ilk denedikleri
  /// seylerden biri olarak soruyor. Bu yuzden yalnizca DORT ISLEM icin,
  /// tek adimlik bir hesap yapiliyor.
  ///
  /// Bilerek DAR tutuldu: parantez, us alma, degisken yok. Genel bir ifade
  /// yorumlayicisi, cocugun yazdigi her seyi calistiran bir kapi demekti;
  /// burada yalnizca "sayi islec sayi" bicimi taniniyor.
  ///
  /// Sifira bolme hata degil, ogretilecek bir sey: bilgisayarlar da bu
  /// noktada durur.
  @visibleForTesting
  String? hesapla(String mesaj, String lang) {
    // Metindeki islemi ara: 12+7, 12 + 7, 9 x 8, 100 - 37, 144 / 12
    final m = RegExp(r'(-?\d+(?:[.,]\d+)?)\s*([+\-xX*×/÷:])\s*(-?\d+(?:[.,]\d+)?)')
        .firstMatch(mesaj);
    if (m == null) return null;

    final a = double.tryParse(m.group(1)!.replaceAll(',', '.'));
    final b = double.tryParse(m.group(3)!.replaceAll(',', '.'));
    if (a == null || b == null) return null;
    final islec = m.group(2)!;

    double? sonuc;
    String isaret;
    switch (islec) {
      case '+':
        sonuc = a + b;
        isaret = '+';
        break;
      case '-':
        sonuc = a - b;
        isaret = '-';
        break;
      case 'x':
      case 'X':
      case '*':
      case '×':
        sonuc = a * b;
        isaret = '×';
        break;
      default:
        isaret = '÷';
        if (b == 0) {
          return _sifiraBolme(lang);
        }
        sonuc = a / b;
    }

    return _hesapCevabi(_sayi(a), isaret, _sayi(b), _sayi(sonuc), lang);
  }

  /// Gereksiz ondaliklari atar: 19.0 -> "19", 4.5 -> "4.5".
  static String _sayi(double d) {
    if (d == d.roundToDouble() && d.abs() < 1e15) {
      return d.toInt().toString();
    }
    // Uc basamak yeter; 1/3 gibi sonuclarda ekrani doldurmasin.
    return d
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+\$'), '')
        .replaceAll(RegExp(r'\.\$'), '');
  }

  String _hesapCevabi(
      String a, String isaret, String b, String sonuc, String lang) {
    // Python'da carpma * ve bolme / ile yaziliyor; ekranda ise cocugun
    // defterinde gordugu × ve ÷ isaretleri duruyor.
    final py = isaret == '×' ? '*' : (isaret == '÷' ? '/' : isaret);
    final satir = '$a $isaret $b = $sonuc';
    final kod = 'print($a $py $b)';

    // Cevabin yaninda Python karsiligi da var: hesap makinesi olmak degil,
    // "bunu koda nasil yazarim" fikrini vermek istiyoruz.
    switch (lang) {
      case 'en':
        return '$satir\n\nIn Python you would write it like this:\n$kod';
      case 'de':
        return '$satir\n\nIn Python schreibst du das so:\n$kod';
      case 'es':
        return '$satir\n\nEn Python se escribe así:\n$kod';
      default:
        return '$satir\n\nPython\'da bunu şöyle yazardın:\n$kod';
    }
  }

  String _sifiraBolme(String lang) {
    switch (lang) {
      case 'en':
        return 'You cannot divide by zero — and that is not a rule someone '
            'invented, it simply has no answer. "How many times does 0 fit '
            'into 10?" has no end.\n\nComputers stop here too: Python says '
            'ZeroDivisionError. Seeing that error means your program tried to '
            'divide by zero.';
      case 'de':
        return 'Durch null kann man nicht teilen — das hat sich niemand '
            'ausgedacht, es gibt einfach keine Antwort. "Wie oft passt 0 in '
            '10?" hört nie auf.\n\nComputer halten hier auch an: Python sagt '
            'ZeroDivisionError. Wenn du diesen Fehler siehst, hat dein '
            'Programm durch null geteilt.';
      case 'es':
        return 'No se puede dividir entre cero, y no es una regla que alguien '
            'inventó: simplemente no tiene respuesta. "¿Cuántas veces cabe el '
            '0 en el 10?" no termina nunca.\n\nLos ordenadores también se '
            'paran aquí: Python dice ZeroDivisionError. Si ves ese error, tu '
            'programa ha dividido entre cero.';
      default:
        return 'Sıfıra bölme yapılamaz — bu birinin koyduğu bir kural değil, '
            'cevabı olmadığı için. "10\'un içinde kaç tane 0 var?" sorusunun '
            'sonu gelmez.\n\nBilgisayarlar da burada duruyor: Python '
            'ZeroDivisionError diyor. O hatayı gördüysen programın sıfıra '
            'bölmüş demektir.';
    }
  }

  /// Verilen kayit kimliklerinden oneri etiketleri uretir.
  List<String> _relatedSuggestionsById(List<String> ids, String lang) {
    final labels = <String>[];
    for (final id in ids) {
      final label = _labelFor(id, lang);
      if (label != null) labels.add(label);
    }
    return labels.isEmpty ? _defaultSuggestions(lang) : labels;
  }

  /// Mesajin dustugu kaydi dondurur; eslesme yoksa null.
  ///
  /// reply() bunu kullaniyor. Ayri bir metot olmasinin sebebi test:
  /// "bu soru hangi kayda dusuyor" sorusu cevap metnine bakmadan
  /// dogrulanabilsin diye. Testin puanlama mantigini kopyalamasi,
  /// kopyanin zamanla asil koddan ayrilmasi demekti.
  @visibleForTesting
  KnowledgeEntry? bestMatch(String message) {
    final text = normalize(message);
    if (text.isEmpty) return null;

    final words = text.split(' ').toSet();

    KnowledgeEntry? best;
    var bestScore = 0.0;

    for (final entry in kKnowledgeBase) {
      final score = _score(entry, text, words);
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }

    return bestScore < _minScore ? null : best;
  }

  /// Anahtar kelime eslesmesini puanlar.
  ///
  /// - Cok kelimeli anahtar tam olarak metinde geciyorsa 2 puan (daha guclu sinyal)
  /// - Tek kelimeli anahtar, kullanicinin kelimelerinden biriyle birebir esitse 1.5
  /// - Tek kelimeli anahtar bir kelimenin icinde geciyorsa (ek almis hali) 1 puan
  /// - Uzun bir anahtarda tek harflik yazim hatasi varsa 1.2 puan
  ///
  /// Son madde cocuklarin yazim hatalarini yakalamak icin: "dongu" yerine
  /// "donugu", "Schleife" yerine "Schleiffe" yazildiginda da cevap gelsin.
  double _score(KnowledgeEntry entry, String text, Set<String> words) {
    var score = 0.0;
    for (final keyword in entry.keywords) {
      if (keyword.contains(' ')) {
        if (text.contains(keyword)) score += 2.0;
        continue;
      }
      if (words.contains(keyword)) {
        score += 1.5;
        continue;
      }
      // "python'da", "döngüsü" gibi ek almis hallerini yakala. Cok kisa
      // anahtarlarda yanlis eslesmeyi onlemek icin 4 harf siniri koyduk.
      if (keyword.length >= 4 && words.any((w) => w.startsWith(keyword))) {
        score += 1.0;
        continue;
      }
      // Tek harflik yazim hatasi. Kisa kelimelerde "kod" / "kot" gibi gercek
      // farklari da yakalayacagi icin 6 harf siniri koyduk.
      if (keyword.length >= 6 && words.any((w) => _uzaklikBirMi(w, keyword))) {
        score += 1.2;
      }
    }
    return score;
  }

  /// Iki kelime arasinda en fazla bir harflik fark var mi (ekle/sil/degistir).
  ///
  /// Tam Levenshtein hesaplamiyoruz; mesafe 1'i asar asmaz cikiyoruz. Bilgi
  /// tabani her tusa basista taranmadigi icin bu maliyet sorun degil, ama yine
  /// de gereksiz is yapmayalim diye uzunluk farki 1'den buyukse hemen eleniyor.
  static bool _uzaklikBirMi(String a, String b) {
    final fark = a.length - b.length;
    if (fark > 1 || fark < -1) return false;
    if (a == b) return false;

    if (a.length == b.length) {
      var hata = 0;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i] && ++hata > 1) return false;
      }
      return hata == 1;
    }

    // Biri digerinden bir harf uzun: uzun olandan bir harf silinerek esitlenir mi?
    final uzun = a.length > b.length ? a : b;
    final kisa = a.length > b.length ? b : a;
    var i = 0, j = 0;
    var atlandi = false;
    while (i < uzun.length && j < kisa.length) {
      if (uzun[i] == kisa[j]) {
        i++;
        j++;
        continue;
      }
      if (atlandi) return false;
      atlandi = true;
      i++;
    }
    return true;
  }

  /// Eslesen kaydin devam sorulari. Kayitta devam sorusu tanimli degilse
  /// sohbet tikanmasin diye rastgele uc oneri donuyoruz.
  List<String> _relatedSuggestions(KnowledgeEntry entry, String lang) {
    if (entry.relatedIds.isEmpty) return _defaultSuggestions(lang);
    final labels = <String>[];
    for (final id in entry.relatedIds) {
      final label = _labelFor(id, lang);
      if (label != null) labels.add(label);
    }
    if (labels.isEmpty) return _defaultSuggestions(lang);
    return labels;
  }

  /// Oneri listesinden her seferinde farkli uc soru sec. Hep ayni ucunu
  /// gostermek sohbeti tekduze yapiyordu.
  List<String> _defaultSuggestions(String lang) {
    final all = List<String>.from(kSuggestedQuestionsFor(lang));
    all.shuffle(_random);
    return all.take(3).toList();
  }

  final Random _random = Random();

  /// Ilgili kayit icin oneri butonunda gosterilecek kisa soru metni.
  String? _labelFor(String id, String lang) {
    switch (lang) {
      case 'en':
        return _labelsEn[id];
      case 'de':
        return _labelsDe[id] ?? _labelsEn[id];
      case 'es':
        return _labelsEs[id] ?? _labelsEn[id];
      default:
        return _labelsTr[id];
    }
  }

  /// Oneri etiketleri, dile gore. Test bu haritayi tarayarak her etiketin
  /// kendi kaydina dustugunu dogruluyor.
  @visibleForTesting
  static const Map<String, Map<String, String>> labelsByLang = {
    'tr': _labelsTr,
    'en': _labelsEn,
    'de': _labelsDe,
    'es': _labelsEs,
  };

  static const Map<String, String> _labelsTr = {
    'scratch': 'Scratch nedir?',
    'python': 'Python\'a nasıl başlarım?',
    'html': 'HTML nedir?',
    'css': 'CSS ne işe yarar?',
    'arduino': 'Arduino nedir?',
    'robotics': 'Robotik nedir?',
    'loop': 'Döngü nedir?',
    'variable': 'Değişken nedir?',
    'condition': 'Koşul nedir?',
    'function': 'Fonksiyon nedir?',
    'algorithm': 'Algoritma nedir?',
    'debug': 'Hata nasıl ayıklanır?',
    'error': 'Kodum çalışmıyor',
    'xp': 'XP nasıl kazanırım?',
    'coins': 'Jetonlar ne işe yarar?',
    'badge': 'Rozetler nedir?',
    'quest': 'Günlük görevler nedir?',
    'streak': 'Seri nedir?',
    'leaderboard': 'Liderlik tablosu nedir?',
    'games': 'Hangi oyunlar var?',
    'what_can_you_do': 'Bana nasıl yardım edebilirsin?',
    'where_start': 'Nereden başlamalıyım?',
    'who_are_you': 'Sen kimsin?',
    'how_are_you': 'Nasılsın?',
    'javascript': 'JavaScript nedir?',
    'mblock': 'mBlock nedir?',
    'microbit': 'micro:bit nedir?',
    'list_array': 'Liste (dizi) nedir?',
    'data_types': 'Veri tipleri nelerdir?',
    'operators': 'Operatörler nedir?',
    'comment_line': 'Yorum satırı nedir?',
    'print_input': 'print ve input nedir?',
    'loop_types': 'for ve while farkı ne?',
    'ai': 'Yapay zeka nedir?',
    'internet': 'İnternet nasıl çalışır?',
    'computer_basics': 'Bilgisayar nasıl çalışır?',
    'make_game': 'Nasıl oyun yaparım?',
    'make_app': 'Nasıl uygulama yaparım?',
    'website': 'Nasıl web sitesi yaparım?',
    'database': 'Veri tabanı nedir?',
    'sensor': 'Sensör nedir?',
    'motor_led': 'LED ve motor nasıl çalışır?',
    'security': 'İnternette nasıl güvende olurum?',
    'career': 'Yazılımcı nasıl olunur?',
    'math_needed': 'Matematik gerekli mi?',
    'how_long': 'Günde ne kadar çalışmalıyım?',
    'pro': 'Pro ne sunuyor?',
    'certificate': 'Sertifika nedir?',
    'report': 'İlerleme raporu nedir?',
    'profile': 'Profilimi nasıl değiştiririm?',
    'videos': 'Hangi video serileri var?',
    'scratch_sprite': 'Kukla ve kostüm nedir?',
    'scratch_events': 'Olay blokları ne işe yarar?',
    'scratch_clone': 'Klon ve kalem blokları nedir?',
    'python_module': 'Kütüphane nedir?',
    'python_turtle': 'Turtle ile nasıl çizerim?',
    'python_dict': 'Sözlük nedir?',
    'python_return': 'return ne demek?',
    'python_errors': 'Python hataları ne anlama gelir?',
    'html_tags': 'HTML etiketleri nelerdir?',
    'html_form': 'Form ve tablo nasıl yapılır?',
    'css_selector': 'class ve id nedir?',
    'css_layout': 'Flexbox nedir?',
    'arduino_setup_loop': 'setup ve loop nedir?',
    'arduino_circuit': 'Breadboard nasıl kullanılır?',
    'robot_projects': 'Hangi robot projesini yapayım?',
    'flowchart': 'Akış şeması nedir?',
    'sorting_searching': 'Sıralama ve arama algoritmaları',
    'debug_how': 'Hatayı nasıl bulurum?',
    'game_chess': 'Satranç taşları nasıl gider?',
    'game_maze': 'Labirent oyununda ipucu',
    'game_bug_pattern': 'Hata Avcısı ve Örüntü Dedektifi',
    'market': 'Market ne işe yarar?',
    'streak_lost': 'Serim bozuldu, ne olur?',
    'offline': 'İnternetsiz çalışır mı?',
    'save_progress': 'İlerlemem kaydediliyor mu?',
    'joke': 'Bana şaka yap',
    'riddle': 'Bana bilmece sor',
    'bored': 'Sıkıldım, ne yapsam?',
    'app_language': 'Uygulamanın dilini nasıl değiştiririm?',
    'notifications': 'Bildirimleri nasıl kapatırım?',
    'parents': 'Ebeveyn Alanı nedir?',
    'ads': 'Neden reklam çıkıyor?',
    'screen_time': 'Ne zaman mola vermeliyim?',
    'no_computer': 'Bilgisayarım yok, telefonla olur mu?',
    'which_program': 'Hangi programı kurmalıyım?',
    'string_ops': 'Metinlerle nasıl çalışırım?',
    'boolean_logic': 'and, or ve not nedir?',
    'scratch_score': 'Scratch\'te skor nasıl tutulur?',
    'scratch_sound': 'Scratch\'e ses nasıl eklerim?',
    'arduino_simulator': 'Arduino Atölyesi nasıl kullanılır?',
    'quiz_how': 'Quizler nasıl çalışır?',
    'game_coordinate': 'Koordinat oyununda ipucu',
    'fear_mistakes': 'Hata yapmaktan korkuyorum',
    'english_terms': 'Koddaki İngilizce kelimeler ne demek?',
    'app_what': 'Bu uygulama nedir?',
    'maker': 'Bu uygulamayı kim yaptı?',
    'contact_support': 'Hata nasıl bildiririm?',
    'video_source': 'Videolar nereden geliyor?',
    'software_what': 'Yazılım nedir?',
    'block_coding': 'Blok kodlama ne işe yarar?',
    'why_coding': 'Neden kodlama öğrenmeliyim?',
    'binary_what': 'Bilgisayar neden 0 ve 1 kullanır?',
    'math_examples': 'Bana bir işlem sor',
    'times_table': 'Çarpım tablosu',
    'data_privacy': 'Bilgilerim güvende mi?',
    'how_use_app': 'Bu uygulamayı nasıl kullanırım?',
    'motivation': 'Zorlanıyorum, ne yapmalıyım?',
  };

  static const Map<String, String> _labelsEn = {
    'scratch': 'What is Scratch?',
    'python': 'How do I start with Python?',
    'html': 'What is HTML?',
    'css': 'What is CSS for?',
    'arduino': 'What is Arduino?',
    'robotics': 'What is robotics?',
    'loop': 'What is a loop?',
    'variable': 'What is a variable?',
    'condition': 'What is a condition?',
    'function': 'What is a function?',
    'algorithm': 'What is an algorithm?',
    'debug': 'How do I debug?',
    'error': 'My code does not work',
    'xp': 'How do I earn XP?',
    'coins': 'What are coins for?',
    'badge': 'What are badges?',
    'quest': 'What are daily quests?',
    'streak': 'What is a streak?',
    'leaderboard': 'What is the leaderboard?',
    'games': 'Which games are there?',
    'what_can_you_do': 'How can you help me?',
    'where_start': 'Where do I start?',
    'who_are_you': 'Who are you?',
    'how_are_you': 'How are you?',
    'javascript': 'What is JavaScript?',
    'mblock': 'What is mBlock?',
    'microbit': 'What is a micro:bit?',
    'list_array': 'What is a list (array)?',
    'data_types': 'What are data types?',
    'operators': 'What are operators?',
    'comment_line': 'What is a comment?',
    'print_input': 'What are print and input?',
    'loop_types': 'for vs while, what is the difference?',
    'ai': 'What is artificial intelligence?',
    'internet': 'How does the internet work?',
    'computer_basics': 'How does a computer work?',
    'make_game': 'How do I make a game?',
    'make_app': 'How do I make an app?',
    'website': 'How do I build a website?',
    'database': 'What is a database?',
    'sensor': 'What is a sensor?',
    'motor_led': 'How do LEDs and motors work?',
    'security': 'How do I stay safe online?',
    'career': 'How do I become a developer?',
    'math_needed': 'Do I need maths?',
    'how_long': 'How long should I practise?',
    'pro': 'What does Pro offer?',
    'certificate': 'What is the certificate?',
    'report': 'What is the progress report?',
    'profile': 'How do I change my profile?',
    'videos': 'Which video series are there?',
    'scratch_sprite': 'What are sprites and costumes?',
    'scratch_events': 'What do event blocks do?',
    'scratch_clone': 'What are clone and pen blocks?',
    'python_module': 'What is a library?',
    'python_turtle': 'How do I draw with turtle?',
    'python_dict': 'What is a dictionary?',
    'python_return': 'What does return mean?',
    'python_errors': 'What do Python errors mean?',
    'html_tags': 'What are HTML tags?',
    'html_form': 'How do I make forms and tables?',
    'css_selector': 'What are class and id?',
    'css_layout': 'What is flexbox?',
    'arduino_setup_loop': 'What are setup and loop?',
    'arduino_circuit': 'How do I use a breadboard?',
    'robot_projects': 'Which robot project should I build?',
    'flowchart': 'What is a flowchart?',
    'sorting_searching': 'Sorting and searching algorithms',
    'debug_how': 'How do I find the bug?',
    'game_chess': 'How do chess pieces move?',
    'game_maze': 'A hint for the maze game',
    'game_bug_pattern': 'Bug Hunter and Pattern Detective',
    'market': 'What is the Market for?',
    'streak_lost': 'I lost my streak, now what?',
    'offline': 'Does it work offline?',
    'save_progress': 'Is my progress saved?',
    'joke': 'Tell me a joke',
    'riddle': 'Ask me a riddle',
    'bored': 'I am bored, what now?',
    'app_language': 'How do I change the language?',
    'notifications': 'How do I turn notifications off?',
    'parents': 'What is the Parent Area?',
    'ads': 'Why are there ads?',
    'screen_time': 'When should I take a break?',
    'no_computer': 'I have no computer, is a phone enough?',
    'which_program': 'What should I install?',
    'string_ops': 'How do I work with text?',
    'boolean_logic': 'What are and, or and not?',
    'scratch_score': 'How do I keep score in Scratch?',
    'scratch_sound': 'How do I add sound in Scratch?',
    'arduino_simulator': 'How does the Arduino Workshop work?',
    'quiz_how': 'How do the quizzes work?',
    'game_coordinate': 'A hint for the coordinate game',
    'fear_mistakes': 'I am afraid of making mistakes',
    'english_terms': 'What do the English coding words mean?',
    'app_what': 'What is this app?',
    'maker': 'Who made this app?',
    'contact_support': 'How do I report a bug?',
    'video_source': 'Where do the videos come from?',
    'software_what': 'What is software?',
    'block_coding': 'What is block coding for?',
    'why_coding': 'Why should I learn to code?',
    'binary_what': 'Why does a computer use 0 and 1?',
    'math_examples': 'Give me a sum',
    'times_table': 'Times tables',
    'data_privacy': 'Is my data safe?',
    'how_use_app': 'How do I use this app?',
    'motivation': 'I am finding it hard',
  };

  static const Map<String, String> _labelsDe = {
    'scratch': 'Was ist Scratch?',
    'python': 'Wie fange ich mit Python an?',
    'html': 'Was ist HTML?',
    'css': 'Wofür ist CSS da?',
    'arduino': 'Was ist Arduino?',
    'robotics': 'Was ist Robotik?',
    'loop': 'Was ist eine Schleife?',
    'variable': 'Was ist eine Variable?',
    'condition': 'Was ist eine Bedingung?',
    'function': 'Was ist eine Funktion?',
    'algorithm': 'Was ist ein Algorithmus?',
    'debug': 'Wie debugge ich?',
    'error': 'Mein Code geht nicht',
    'xp': 'Wie bekomme ich XP?',
    'coins': 'Wofür sind Münzen da?',
    'badge': 'Was sind Abzeichen?',
    'quest': 'Was sind Tagesaufgaben?',
    'streak': 'Was ist eine Serie?',
    'leaderboard': 'Was ist die Bestenliste?',
    'games': 'Welche Spiele gibt es?',
    'what_can_you_do': 'Wie kannst du mir helfen?',
    'where_start': 'Womit soll ich anfangen?',
    'who_are_you': 'Wer bist du?',
    'how_are_you': 'Wie geht es dir?',
    'javascript': 'Was ist JavaScript?',
    'mblock': 'Was ist mBlock?',
    'microbit': 'Was ist ein micro:bit?',
    'list_array': 'Was ist eine Liste?',
    'data_types': 'Was sind Datentypen?',
    'operators': 'Was sind Operatoren?',
    'comment_line': 'Was ist ein Kommentar?',
    'print_input': 'Was sind print und input?',
    'loop_types': 'Was ist der Unterschied zwischen for und while?',
    'ai': 'Was ist künstliche Intelligenz?',
    'internet': 'Wie funktioniert das Internet?',
    'computer_basics': 'Wie funktioniert ein Computer?',
    'make_game': 'Wie baue ich ein Spiel?',
    'make_app': 'Wie baue ich eine App?',
    'website': 'Wie baue ich eine Webseite?',
    'database': 'Was ist eine Datenbank?',
    'sensor': 'Was ist ein Sensor?',
    'motor_led': 'Wie funktionieren LEDs und Motoren?',
    'security': 'Wie bleibe ich online sicher?',
    'career': 'Wie werde ich Programmiererin?',
    'math_needed': 'Brauche ich Mathe?',
    'how_long': 'Wie lange soll ich üben?',
    'pro': 'Was bietet Pro?',
    'certificate': 'Was ist das Zertifikat?',
    'report': 'Was ist der Fortschrittsbericht?',
    'profile': 'Wie ändere ich mein Profil?',
    'videos': 'Welche Videoreihen gibt es?',
    'scratch_sprite': 'Was sind Figuren und Kostüme?',
    'scratch_events': 'Was machen Ereignisblöcke?',
    'scratch_clone': 'Was sind Klon- und Stift-Blöcke?',
    'python_module': 'Was ist eine Bibliothek?',
    'python_turtle': 'Wie zeichne ich mit Turtle?',
    'python_dict': 'Was ist ein Dictionary?',
    'python_return': 'Was bedeutet return?',
    'python_errors': 'Was bedeuten die Python Fehler?',
    'html_tags': 'Was sind HTML Tags?',
    'html_form': 'Wie baue ich Formulare und Tabellen?',
    'css_selector': 'Was sind class und id?',
    'css_layout': 'Was ist Flexbox?',
    'arduino_setup_loop': 'Was sind setup und loop?',
    'arduino_circuit': 'Wie benutze ich ein Breadboard?',
    'robot_projects': 'Welches Roboterprojekt soll ich bauen?',
    'flowchart': 'Was ist ein Flussdiagramm?',
    'sorting_searching': 'Sortier- und Suchalgorithmen',
    'debug_how': 'Wie finde ich den Fehler?',
    'game_chess': 'Wie ziehen die Schachfiguren?',
    'game_maze': 'Ein Tipp für das Labyrinth',
    'game_bug_pattern': 'Bug Hunter und Muster-Detektiv',
    'market': 'Wofür ist der Markt da?',
    'streak_lost': 'Meine Serie ist weg, was jetzt?',
    'offline': 'Geht es auch offline?',
    'save_progress': 'Wird mein Fortschritt gespeichert?',
    'joke': 'Erzähl mir einen Witz',
    'riddle': 'Stell mir ein Rätsel',
    'bored': 'Mir ist langweilig, was nun?',
    'app_language': 'Wie ändere ich die Sprache?',
    'notifications': 'Wie schalte ich Benachrichtigungen aus?',
    'parents': 'Was ist der Elternbereich?',
    'ads': 'Warum gibt es Werbung?',
    'screen_time': 'Wann soll ich eine Pause machen?',
    'no_computer': 'Ich habe keinen Computer, reicht ein Handy?',
    'which_program': 'Was muss ich installieren?',
    'string_ops': 'Wie arbeite ich mit Text?',
    'boolean_logic': 'Was sind and, or und not?',
    'scratch_score': 'Wie zähle ich Punkte in Scratch?',
    'scratch_sound': 'Wie füge ich in Scratch Klang hinzu?',
    'arduino_simulator': 'Wie funktioniert die Arduino-Werkstatt?',
    'quiz_how': 'Wie funktionieren die Quiz?',
    'game_coordinate': 'Ein Tipp für das Koordinatenspiel',
    'fear_mistakes': 'Ich habe Angst vor Fehlern',
    'english_terms': 'Was heißen die englischen Begriffe?',
    'app_what': 'Was ist diese App?',
    'maker': 'Wer hat diese App gemacht?',
    'contact_support': 'Wie melde ich einen Fehler?',
    'video_source': 'Woher kommen die Videos?',
    'software_what': 'Was ist Software?',
    'block_coding': 'Wozu Blockprogrammierung?',
    'why_coding': 'Warum programmieren lernen?',
    'binary_what': 'Warum 0 und 1?',
    'math_examples': 'Gib mir eine Rechnung',
    'times_table': 'Einmaleins',
    'data_privacy': 'Sind meine Daten sicher?',
    'how_use_app': 'Wie benutze ich diese App?',
    'motivation': 'Es fällt mir schwer',
  };

  static const Map<String, String> _labelsEs = {
    'scratch': '¿Qué es Scratch?',
    'python': '¿Cómo empiezo con Python?',
    'html': '¿Qué es HTML?',
    'css': '¿Para qué sirve CSS?',
    'arduino': '¿Qué es Arduino?',
    'robotics': '¿Qué es la robótica?',
    'loop': '¿Qué es un bucle?',
    'variable': '¿Qué es una variable?',
    'condition': '¿Qué es una condición?',
    'function': '¿Qué es una función?',
    'algorithm': '¿Qué es un algoritmo?',
    'debug': '¿Cómo depuro el código?',
    'error': 'Mi código no funciona',
    'xp': '¿Cómo gano XP?',
    'coins': '¿Para qué sirven las monedas?',
    'badge': '¿Qué son las insignias?',
    'quest': '¿Qué son las misiones diarias?',
    'streak': '¿Qué es una racha?',
    'leaderboard': '¿Qué es la tabla de clasificación?',
    'games': '¿Qué juegos hay?',
    'what_can_you_do': '¿Cómo puedes ayudarme?',
    'where_start': '¿Por dónde empiezo?',
    'who_are_you': '¿Quién eres?',
    'how_are_you': '¿Cómo estás?',
    'javascript': '¿Qué es JavaScript?',
    'mblock': '¿Qué es mBlock?',
    'microbit': '¿Qué es un micro:bit?',
    'list_array': '¿Qué es una lista?',
    'data_types': '¿Qué son los tipos de datos?',
    'operators': '¿Qué son los operadores?',
    'comment_line': '¿Qué es un comentario?',
    'print_input': '¿Qué son print e input?',
    'loop_types': '¿Qué diferencia hay entre for y while?',
    'ai': '¿Qué es la inteligencia artificial?',
    'internet': '¿Cómo funciona internet?',
    'computer_basics': '¿Cómo funciona un ordenador?',
    'make_game': '¿Cómo hago un juego?',
    'make_app': '¿Cómo hago una aplicación?',
    'website': '¿Cómo hago una página web?',
    'database': '¿Qué es una base de datos?',
    'sensor': '¿Qué es un sensor?',
    'motor_led': '¿Cómo funcionan los LED y los motores?',
    'security': '¿Cómo me mantengo seguro en internet?',
    'career': '¿Cómo llego a ser programadora?',
    'math_needed': '¿Necesito matemáticas?',
    'how_long': '¿Cuánto debo practicar?',
    'pro': '¿Qué ofrece Pro?',
    'certificate': '¿Qué es el certificado?',
    'report': '¿Qué es el informe de progreso?',
    'profile': '¿Cómo cambio mi perfil?',
    'videos': '¿Qué series de vídeo hay?',
    'scratch_sprite': '¿Qué son los objetos y disfraces?',
    'scratch_events': '¿Qué hacen los bloques de eventos?',
    'scratch_clone': '¿Qué son los clones y el lápiz?',
    'python_module': '¿Qué es una biblioteca?',
    'python_turtle': '¿Cómo dibujo con Turtle?',
    'python_dict': '¿Qué es un diccionario?',
    'python_return': '¿Qué significa return?',
    'python_errors': '¿Qué significan los errores de Python?',
    'html_tags': '¿Qué son las etiquetas HTML?',
    'html_form': '¿Cómo hago formularios y tablas?',
    'css_selector': '¿Qué son class e id?',
    'css_layout': '¿Qué es flexbox?',
    'arduino_setup_loop': '¿Qué son setup y loop?',
    'arduino_circuit': '¿Cómo uso una placa de pruebas?',
    'robot_projects': '¿Qué proyecto de robot hago?',
    'flowchart': '¿Qué es un diagrama de flujo?',
    'sorting_searching': 'Algoritmos de ordenación y búsqueda',
    'debug_how': '¿Cómo encuentro el error?',
    'game_chess': '¿Cómo se mueven las piezas de ajedrez?',
    'game_maze': 'Una pista para el laberinto',
    'game_bug_pattern': 'Bug Hunter y Detective de Patrones',
    'market': '¿Para qué sirve la tienda?',
    'streak_lost': 'Perdí mi racha, ¿y ahora?',
    'offline': '¿Funciona sin conexión?',
    'save_progress': '¿Se guarda mi progreso?',
    'joke': 'Cuéntame un chiste',
    'riddle': 'Ponme un acertijo',
    'bored': 'Estoy aburrido, ¿qué hago?',
    'app_language': '¿Cómo cambio el idioma?',
    'notifications': '¿Cómo desactivo las notificaciones?',
    'parents': '¿Qué es la Zona de Padres?',
    'ads': '¿Por qué hay anuncios?',
    'screen_time': '¿Cuándo debo descansar?',
    'no_computer': 'No tengo ordenador, ¿me vale el móvil?',
    'which_program': '¿Qué programa necesito instalar?',
    'string_ops': '¿Cómo trabajo con texto?',
    'boolean_logic': '¿Qué son and, or y not?',
    'scratch_score': '¿Cómo llevo la puntuación en Scratch?',
    'scratch_sound': '¿Cómo añado sonido en Scratch?',
    'arduino_simulator': '¿Cómo funciona el Taller de Arduino?',
    'quiz_how': '¿Cómo funcionan los cuestionarios?',
    'game_coordinate': 'Una pista para el juego de coordenadas',
    'fear_mistakes': 'Me da miedo equivocarme',
    'english_terms': '¿Qué significan las palabras en inglés?',
    'app_what': '¿Qué es esta aplicación?',
    'maker': '¿Quién hizo esta app?',
    'contact_support': '¿Cómo informo de un error?',
    'video_source': '¿De dónde vienen los vídeos?',
    'software_what': '¿Qué es el software?',
    'block_coding': '¿Para qué sirve programar por bloques?',
    'why_coding': '¿Por qué aprender a programar?',
    'binary_what': '¿Por qué 0 y 1?',
    'math_examples': 'Ponme una operación',
    'times_table': 'Tablas de multiplicar',
    'data_privacy': '¿Están seguros mis datos?',
    'how_use_app': '¿Cómo se usa esta app?',
    'motivation': 'Me está costando',
  };
}
