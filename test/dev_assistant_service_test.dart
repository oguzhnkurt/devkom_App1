import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/data/dev_assistant_knowledge.dart';
import 'package:devkom_app/services/dev_assistant_service.dart';

/// DevAI bilgi tabani testleri.
///
/// Bilgi tabani buyudukce genis anahtar kelimeli ust kayitlarin (ornegin
/// "arduino") daha ozel alt kayitlari (ornegin "breadboard") calmasi kolay.
/// Bu test, her sorunun dogru kayda dustugunu dogruluyor; yeni kayit eklerken
/// once bunu calistir.
///
/// Eslestirme dogrudan DevAssistantService.bestMatch uzerinden yapiliyor.
/// Daha once testin kendi puanlama kopyasi vardi; kopya asil koddan sessizce
/// ayrilabildigi icin kaldirildi.
void main() {
  final service = DevAssistantService.instance;

  String? matchedId(String message) => service.bestMatch(message)?.id;

  const diller = ['tr', 'en', 'de', 'es'];

  const expectationsTr = <String, String>{
    'Merhaba': 'greeting',
    'merhaba!': 'greeting',
    'SELAM': 'greeting',
    'Hey': 'greeting',
    'nasılsın?': 'how_are_you',
    'naber': 'how_are_you',
    'görüşürüz': 'goodbye',
    'iyi geceler': 'goodbye',
    'teşekkürler': 'thanks',
    'sağol': 'thanks',
    'sen kimsin': 'who_are_you',
    'robot musun': 'are_you_robot',
    'kaç yaşındasın': 'your_age',
    'sıkıldım': 'bored',
    'bana şaka yap': 'joke',
    'bana bilmece sor': 'riddle',
    'Scratch nedir': 'scratch',
    'kukla ve kostüm': 'scratch_sprite',
    'yeşil bayrak': 'scratch_events',
    'klon nedir': 'scratch_clone',
    'python nedir': 'python',
    'döngü nedir': 'loop',
    'for ve while farkı': 'loop_types',
    'değişkenler': 'variable',
    'koşul nedir': 'condition',
    'fonksiyon nedir': 'function',
    'return ne demek': 'python_return',
    'algoritma nedir': 'algorithm',
    'sıralama algoritması': 'sorting_searching',
    'akış şeması': 'flowchart',
    'kodum çalışmıyor': 'error',
    'hatayı nasıl bulurum': 'debug_how',
    'syntaxerror aldım': 'python_errors',
    'XP nasıl kazanırım': 'xp',
    'jeton ne işe yarar': 'coins',
    'market nedir': 'market',
    'rozet': 'badge',
    'günlük görevler': 'quest',
    'serim bozuldu': 'streak_lost',
    'seri nedir': 'streak',
    'liderlik tablosu': 'leaderboard',
    'hangi oyunlar var': 'games',
    'satranç': 'game_chess',
    'labirent': 'game_maze',
    'örüntü dedektifi': 'game_bug_pattern',
    'mblock nedir': 'mblock',
    'micro:bit': 'microbit',
    'javascript': 'javascript',
    'liste nedir': 'list_array',
    'sözlük nedir': 'python_dict',
    'turtle ile çizim': 'python_turtle',
    'kütüphane nedir': 'python_module',
    'print ve input': 'print_input',
    'veri tipleri': 'data_types',
    'operatörler': 'operators',
    'yorum satırı': 'comment_line',
    'html etiketleri': 'html_tags',
    'form nasıl yapılır': 'html_form',
    'css nedir': 'css',
    'flexbox': 'css_layout',
    'class ve id nedir': 'css_selector',
    'arduino nedir': 'arduino',
    'void setup': 'arduino_setup_loop',
    'breadboard': 'arduino_circuit',
    'sensör nedir': 'sensor',
    'led yakmak': 'motor_led',
    'robotik nedir': 'robotics',
    'çizgi izleyen robot': 'robot_projects',
    'internet yok': 'offline',
    'ilerlemem kaydediliyor mu': 'save_progress',
    'pro nedir': 'pro',
    'sertifika': 'certificate',
    'ilerleme raporu': 'report',
    'profil': 'profile',
    'video serisi': 'videos',
    'yapay zeka': 'ai',
    'veri tabanı': 'database',
    'oyun yapmak istiyorum': 'make_game',
    'web sitesi yapmak': 'website',
    'uygulama yapmak': 'make_app',
    'matematik gerekli mi': 'math_needed',
    'günde kaç saat': 'how_long',
    'yazılımcı olmak istiyorum': 'career',
    'şifre güvenliği': 'security',
    'bilgisayar nedir': 'computer_basics',
    'internet nedir': 'internet',
    'ödevimi yap': 'do_my_homework',
    'yapamıyorum': 'motivation',
    'nereden başlamalıyım': 'where_start',
    'ne yapabilirsin': 'what_can_you_do',
  };

  /// Almanca sorular. Anahtar kelimeler tek listede tutuldugu ve normalize()
  /// aksanlari ASCII'ye indirdigi icin "Schleife" ve "bucle" ayni kayitta
  /// yan yana durabiliyor; bu testler o kurulusun calistigini dogruluyor.
  const expectationsDe = <String, String>{
    'Hallo': 'greeting',
    'Guten Morgen': 'greeting',
    'Wer bist du?': 'who_are_you',
    'Wie geht es dir?': 'how_are_you',
    'Tschüss': 'goodbye',
    'Danke': 'thanks',
    'Was ist Scratch?': 'scratch',
    'Was ist eine Schleife?': 'loop',
    'Was ist eine Variable?': 'variable',
    'Was ist eine Bedingung?': 'condition',
    'Was ist eine Funktion?': 'function',
    'Was ist ein Algorithmus?': 'algorithm',
    'Mein Code geht nicht': 'error',
    'Wie bekomme ich XP?': 'xp',
    'Wofür sind Münzen da?': 'coins',
    'Was sind Abzeichen?': 'badge',
    'Was ist eine Serie?': 'streak',
    'Welche Spiele gibt es?': 'games',
    'Was ist Arduino?': 'arduino',
    'Was ist Robotik?': 'robotics',
    'Was ist ein Sensor?': 'sensor',
    'Was ist künstliche Intelligenz?': 'ai',
    'Was ist eine Datenbank?': 'database',
    'Erzähl mir einen Witz': 'joke',
    'Stell mir ein Rätsel': 'riddle',
    'Mir ist langweilig': 'bored',
    'Wie ziehen die Schachfiguren?': 'game_chess',
    'Was ist ein Steckbrett?': 'arduino_circuit',
    'Warum gibt es Werbung?': 'ads',
    'Wie ändere ich die Sprache?': 'app_language',
    'Was ist der Elternbereich?': 'parents',
    'Ich habe Angst vor Fehlern': 'fear_mistakes',
    'Wie zeichne ich mit Turtle?': 'python_turtle',
    'Was ist ein Flussdiagramm?': 'flowchart',
    'Was sind HTML Tags?': 'html_tags',
    'Was ist Flexbox?': 'css_layout',
  };

  const expectationsEs = <String, String>{
    'Hola': 'greeting',
    'Buenos días': 'greeting',
    '¿Quién eres?': 'who_are_you',
    '¿Cómo estás?': 'how_are_you',
    'Adiós': 'goodbye',
    'Gracias': 'thanks',
    '¿Qué es Scratch?': 'scratch',
    '¿Qué es un bucle?': 'loop',
    '¿Qué es una variable?': 'variable',
    '¿Qué es una condición?': 'condition',
    '¿Qué es una función?': 'function',
    '¿Qué es un algoritmo?': 'algorithm',
    'Mi código no funciona': 'error',
    '¿Cómo gano XP?': 'xp',
    '¿Para qué sirven las monedas?': 'coins',
    '¿Qué son las insignias?': 'badge',
    '¿Qué es una racha?': 'streak',
    '¿Qué juegos hay?': 'games',
    '¿Qué es Arduino?': 'arduino',
    '¿Qué es la robótica?': 'robotics',
    '¿Qué es un sensor?': 'sensor',
    '¿Qué es la inteligencia artificial?': 'ai',
    '¿Qué es una base de datos?': 'database',
    'Cuéntame un chiste': 'joke',
    'Ponme un acertijo': 'riddle',
    'Estoy aburrido': 'bored',
    '¿Cómo se mueven las piezas de ajedrez?': 'game_chess',
    '¿Por qué hay anuncios?': 'ads',
    '¿Cómo cambio el idioma?': 'app_language',
    '¿Qué es la Zona de Padres?': 'parents',
    'Me da miedo equivocarme': 'fear_mistakes',
    '¿Cómo dibujo con Turtle?': 'python_turtle',
    '¿Qué es un diagrama de flujo?': 'flowchart',
    '¿Qué son las etiquetas HTML?': 'html_tags',
    '¿Qué es flexbox?': 'css_layout',
    '¿Qué son las coordenadas?': 'game_coordinate',
  };

  const expectationsEn = <String, String>{
    'Hello': 'greeting',
    'Who are you?': 'who_are_you',
    'Thanks': 'thanks',
    'What is a loop?': 'loop',
    'What is a variable?': 'variable',
    'My code does not work': 'error',
    'How do I earn XP?': 'xp',
    'What are coins for?': 'coins',
    'Which games are there?': 'games',
    'What is a sensor?': 'sensor',
    'Tell me a joke': 'joke',
    'Why are there ads?': 'ads',
    'How do I change the language?': 'app_language',
    'What should I install?': 'which_program',
    'How do I work with text?': 'string_ops',
    'What are and, or and not?': 'boolean_logic',
    'How do I keep score in Scratch?': 'scratch_score',
    'How do I add sound in Scratch?': 'scratch_sound',
    'How does the Arduino Simulator work?': 'arduino_simulator',
    'How do the quizzes work?': 'quiz_how',
  };

  group('DevAI eslestirme (tr)', () {
    expectationsTr.forEach((question, expectedId) {
      test('"$question" -> $expectedId', () {
        expect(matchedId(question), expectedId);
      });
    });
  });

  group('DevAI eslestirme (de)', () {
    expectationsDe.forEach((question, expectedId) {
      test('"$question" -> $expectedId', () {
        expect(matchedId(question), expectedId);
      });
    });
  });

  group('DevAI eslestirme (es)', () {
    expectationsEs.forEach((question, expectedId) {
      test('"$question" -> $expectedId', () {
        expect(matchedId(question), expectedId);
      });
    });
  });

  group('DevAI eslestirme (en)', () {
    expectationsEn.forEach((question, expectedId) {
      test('"$question" -> $expectedId', () {
        expect(matchedId(question), expectedId);
      });
    });
  });

  group('DevAI yazim hatasi toleransi', () {
    // Cocuk yazarken harf atlar ya da iki kere basar. Alti harften uzun
    // anahtarlarda tek harflik fark hala eslesiyor.
    const hatalilar = <String, String>{
      'degiskn nedir': 'variable',
      'algoritmaa': 'algorithm',
      'fonksiyn nedir': 'function',
      'sensorr nedir': 'sensor',
      'was ist eine schleiffe': 'loop',
      'que es un algoritm': 'algorithm',
    };
    hatalilar.forEach((question, expectedId) {
      test('"$question" -> $expectedId', () {
        expect(matchedId(question), expectedId);
      });
    });
  });

  group('DevAI dort dil butunlugu', () {
    test('her kaydin dort dilde de cevabi var', () {
      for (final entry in kKnowledgeBase) {
        expect(entry.answerTr.trim(), isNotEmpty, reason: entry.id);
        expect(entry.answerEn.trim(), isNotEmpty, reason: entry.id);
        expect(entry.answerDe?.trim() ?? '', isNotEmpty, reason: entry.id);
        expect(entry.answerEs?.trim() ?? '', isNotEmpty, reason: entry.id);
      }
    });

    test('answerFor dort dilde de dolu cevap donuyor', () {
      for (final entry in kKnowledgeBase) {
        for (final lang in diller) {
          expect(entry.answerFor(lang).trim(), isNotEmpty,
              reason: '${entry.id} / $lang');
        }
      }
    });

    test('cevaplar diller arasinda ayni degil', () {
      // Bir dil unutulup Ingilizcesi kopyalanirsa bu test yakalar.
      // greeting/thanks gibi cok kisa kayitlarda dogal benzerlik olabilir,
      // o yuzden yalnizca 120 karakterden uzun cevaplara bakiyoruz.
      for (final entry in kKnowledgeBase) {
        if (entry.answerEn.length < 120) continue;
        expect(entry.answerDe, isNot(entry.answerEn), reason: entry.id);
        expect(entry.answerEs, isNot(entry.answerEn), reason: entry.id);
        expect(entry.answerDe, isNot(entry.answerEs), reason: entry.id);
      }
    });

    test('ornek soru listeleri dort dilde de dolu ve esit uzunlukta', () {
      final tr = kSuggestedQuestionsFor('tr');
      for (final lang in diller) {
        final liste = kSuggestedQuestionsFor(lang);
        expect(liste, isNotEmpty, reason: lang);
        expect(liste.length, tr.length, reason: lang);
      }
    });

    test('eslesme yoksa verilen cevap dort dilde de farkli', () {
      final metinler = diller.map(kNoMatchAnswerFor).toSet();
      expect(metinler.length, diller.length);
    });
  });

  group('DevAI sohbet akisi', () {
    test('bos mesaj eslesmez ama yine de cevap ve oneri doner', () {
      for (final lang in diller) {
        final reply = service.reply('   ', lang: lang);
        expect(reply.matched, isFalse, reason: lang);
        expect(reply.text, isNotEmpty, reason: lang);
        expect(reply.suggestions, isNotEmpty, reason: lang);
      }
    });

    test('anlamsiz mesaj eslesmez', () {
      expect(service.reply('asdfgh qwerty', lang: 'tr').matched, isFalse);
    });

    test('eslesen her kayit oneri dondurur', () {
      // Onerisi olmayan cevap sohbeti tikiyordu; artik iliskili kayit
      // tanimli degilse rastgele uc ornek soru veriliyor.
      for (final entry in kKnowledgeBase) {
        for (final lang in diller) {
          final reply = service.reply(entry.keywords.first, lang: lang);
          expect(reply.suggestions, isNotEmpty,
              reason: '${entry.id} / $lang');
        }
      }
    });

    test('cevap istenen dilde geliyor', () {
      for (final lang in diller) {
        final reply = service.reply('Scratch', lang: lang);
        expect(reply.matched, isTrue, reason: lang);
        final scratch =
            kKnowledgeBase.firstWhere((e) => e.id == 'scratch');
        expect(reply.text, scratch.answerFor(lang), reason: lang);
      }
    });
  });

  group('DevAI bilgi tabani tutarliligi', () {
    test('id ler benzersiz', () {
      final ids = kKnowledgeBase.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('anahtar kelimeler ASCII ve kucuk harf', () {
      // normalize() kullanicinin yazdigini ASCII kucuk harfe ceviriyor;
      // anahtar kelimede aksanli harf olursa o anahtar hic eslesmez.
      for (final entry in kKnowledgeBase) {
        for (final keyword in entry.keywords) {
          expect(
            DevAssistantService.normalize(keyword),
            keyword,
            reason: '${entry.id} -> "$keyword"',
          );
        }
      }
    });

    test('anahtar kelimeler kayit icinde tekrar etmiyor', () {
      for (final entry in kKnowledgeBase) {
        final k = entry.keywords;
        expect(k.toSet().length, k.length, reason: entry.id);
      }
    });

    test('relatedIds gercek kayitlari gosteriyor', () {
      final ids = kKnowledgeBase.map((e) => e.id).toSet();
      for (final entry in kKnowledgeBase) {
        for (final related in entry.relatedIds) {
          expect(ids.contains(related), isTrue,
              reason: '${entry.id} -> $related');
        }
      }
    });

    test('her relatedId nin dort dilde etiketi var', () {
      // Etiketi olmayan iliskili kayit, sohbette eksik oneri demek.
      for (final entry in kKnowledgeBase) {
        for (final related in entry.relatedIds) {
          for (final lang in diller) {
            expect(DevAssistantService.labelsByLang[lang]?[related], isNotNull,
                reason: '$related / $lang (${entry.id} icinden)');
          }
        }
      }
    });

    test('her oneri etiketi kendi kaydina dusuyor', () {
      // Oneri dugmesine basildiginda metin tekrar eslestirme motoruna
      // giriyor. Etiket baska bir kayda duserse cocuk butona bastigi
      // sorunun cevabini alamiyor - eskiden 69 etikette bu oluyordu.
      DevAssistantService.labelsByLang.forEach((lang, etiketler) {
        etiketler.forEach((id, metin) {
          expect(matchedId(metin), id, reason: '$lang / $id -> "$metin"');
        });
      });
    });

    test('ornek sorularin hepsi bir kayda dusuyor', () {
      for (final lang in diller) {
        for (final soru in kSuggestedQuestionsFor(lang)) {
          expect(matchedId(soru), isNotNull, reason: '$lang -> "$soru"');
        }
      }
    });

    test('etiketi olan her id gercekten bir kayit', () {
      final ids = kKnowledgeBase.map((e) => e.id).toSet();
      DevAssistantService.labelsByLang.forEach((lang, etiketler) {
        for (final id in etiketler.keys) {
          expect(ids.contains(id), isTrue, reason: '$lang -> $id');
        }
      });
    });
  });
}
