// Bilgi Yarismasi, Koordinat oyunu ve Modul Quizi icin kaynak okuyan
// koruma testleri.
//
// Uc sikayet de "oyun bana yanlis seyi ogretiyor" turunden: widget
// testiyle yakalanmasi zor, sessizce geri gelmesi kolay.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const yarisma = 'lib/screens/games/millionaire_game_screen.dart';
  const koordinat = 'lib/screens/games/coordinates_game_screen.dart';
  const quiz = 'lib/courses/screens/module_quiz_screen.dart';
  const odulServisi = 'lib/services/millionaire_questions_service.dart';

  group('Bilgi Yarismasi', () {
    late String s;
    setUpAll(() => s = File(yarisma).readAsStringSync());

    test('odul merdiveni dogru sayisina gore yukseliyor', () {
      // Merdiven `_currentQuestionIndex`e bakinca yanlis cevaplayan cocuk
      // da basamak atliyor, sonraki soruyu bilince bilemedigi basamagin
      // parasini aliyordu.
      expect(s.contains('_correctCount'), isTrue);
      expect(RegExp(r'final isPast = index < _currentQuestionIndex').hasMatch(s),
          isFalse);
      expect(s.contains('final isPast = index < _correctCount'), isTrue);
      expect(RegExp(r'_currentPrize = _currentQuestion\.prize').hasMatch(s),
          isFalse,
          reason: 'Odul sorunun kendi degeri degil, merdivendeki basamak.');
    });

    test('XP ve jeton yalnizca dogrular icin veriliyor', () {
      expect(s.contains('questionsAnswered'), isFalse,
          reason: 'Cevaplanan degil, dogru bilinen soru sayisi.');
      expect(s.contains('dogruSayisi * 5'), isTrue);
      expect(s.contains('dogruSayisi * 8'), isTrue);
    });

    test('ucretsiz soru siniri cevabin dogrulugundan bagimsiz', () {
      // Sinir yalnizca dogru cevap dalinda kontrol ediliyordu: soruyu
      // bilen 3 soruda duruyor, bilemeyen 12 soru oynuyordu.
      final i = s.indexOf('kMillionaireFreeQuestionLimit - 1');
      expect(i, greaterThan(0));
      final oncesi = s.substring((i - 400).clamp(0, i), i);
      expect(oncesi.contains('if (!isCorrect)'), isFalse,
          reason: 'Sinir kontrolu yine dogru/yanlis dalina girmis.');
      expect(s.contains('final ucretsizSinir ='), isTrue);
    });

    test('dogru sik cevap acilinca gosteriliyor', () {
      expect(s.contains('final isCorrectOption ='), isTrue);
      expect(s.contains('if (_showingResult && isCorrectOption)'), isTrue);
      expect(
          RegExp(r'buttonColor = _isCorrect \? Colors\.green : Colors\.red')
              .hasMatch(s),
          isFalse,
          reason: 'Yalnizca secilen sikki boyamak dogruyu gizler.');
      expect(s.contains('Icons.check_circle_rounded'), isTrue,
          reason: 'Renk korlugu icin isaret de olmali.');
    });

    test('kupa dali ulasilabilir', () {
      // Esik 10.000.000'du; merdivenin tepesi 1.000.000. Kupa hic
      // gosterilmiyordu.
      expect(s.contains('_currentPrize >= 10000000'), isFalse);
      expect(s.contains('_hepsiDogru'), isTrue);
    });

    test('odul tutari dort dilde biciminlendiriliyor', () {
      final o = File(odulServisi).readAsStringSync();
      expect(o.contains("final isEn = lang == 'en';"), isFalse);
      expect(o.contains('AppLang.pick'), isTrue);
    });
  });

  group('Koordinat oyunu', () {
    late String s;
    setUpAll(() => s = File(koordinat).readAsStringSync());

    test('secilen koordinat kontrolden once yaziyla gosterilmiyor', () {
      // Hedef zaten ustte yaziliydi; secim de altta yazinca cocuk iki
      // sayiyi karsilastirip "Kontrol Et"e hic ihtiyac duymuyordu.
      expect(s.contains('answerRevealed'), isTrue);
      final i = s.indexOf(r"'($selectedX, $selectedY)'");
      expect(i, greaterThan(0));
      final oncesi = s.substring((i - 600).clamp(0, i), i);
      expect(oncesi.contains('if (answerRevealed)'), isTrue,
          reason: 'Koordinat yine kontrolden once gorunuyor.');
    });

    test('yanlis cevapta secim aciliyor', () {
      expect(s.contains('setState(() => answerRevealed = true);'), isTrue);
    });
  });

  group('Modul Quizi', () {
    late String s;
    setUpAll(() => s = File(quiz).readAsStringSync());

    test('yanlis cevaplar sonuc ekraninda gosteriliyor', () {
      expect(s.contains('_buildYanlisInceleme'), isTrue);
      expect(s.contains('_yanlisSorular'), isTrue);
      expect(s.contains('explanationFor(_lang)'), isTrue,
          reason: 'Aciklama varsa cocuk onu da gormeli.');
    });

    test('dogru sayisi yuzdeden geri hesaplanmiyor', () {
      expect(
          RegExp(r'\(_score \* widget\.questions\.length / 100\)').hasMatch(s),
          isFalse,
          reason: 'Yuvarlama 7 dogruyu 8 gosterebiliyordu.');
    });

    test('arayuz dort dilde', () {
      final kod = s
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//') && !l.trimLeft().startsWith('///'))
          .join('\n');
      expect(kod.contains("_lang == 'en' ?"), isFalse);
      expect(s.contains('AppLang.pick(_lang'), isTrue);
    });
  });
}
