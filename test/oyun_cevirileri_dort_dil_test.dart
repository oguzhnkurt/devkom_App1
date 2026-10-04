// Oyun ekranlarinda kullanicinin gordugu ceviri hatalari (4 Ekim 2026):
//  * Bilgi Yarismasi: Almanca/Ispanyolca'da sorular ve siklar Turkce kaliyordu
//    (model yalnizca 'en' biliyordu).
//  * Boru Bulmacasi: ust satirdaki Seviye/Skor/Hamle Almanca/Ispanyolca'da
//    Turkceydi (oyun yalnizca "Ingilizce mi" diye bakiyordu).
//  * Arduino Atolyesi: Turkce ekranda baslangic blogu Ingilizceydi
//    ("when Arduino Uno starts up"); ipucu ise "Arduino acilinca" diyordu.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:devkom_app/data/arduino_gorev_data.dart';
import 'package:devkom_app/services/millionaire_questions_service.dart';

void main() {
  group('Bilgi Yarismasi dort dilde', () {
    final sorular = MillionaireQuestionsService.getQuestions();

    test('her sorunun Almancasi ve Ispanyolcasi var', () {
      for (final q in sorular) {
        expect(q.questionDe, isNotNull, reason: q.question);
        expect(q.questionEs, isNotNull, reason: q.question);
        expect(q.optionsDe!.length, q.options.length, reason: q.question);
        expect(q.optionsEs!.length, q.options.length, reason: q.question);
      }
    });

    test('de/es secilince soru Turkce gelmiyor', () {
      for (final q in sorular) {
        expect(q.questionFor('de'), isNot(q.question), reason: q.question);
        expect(q.questionFor('es'), isNot(q.question), reason: q.question);
        expect(q.questionFor('tr'), q.question);
        expect(q.optionsFor('tr'), q.options);
      }
    });

    test('siklar eksikse yanlis sira kullanilmiyor, Ingilizceye dusuyor', () {
      final q = sorular.first;
      expect(q.optionsFor('de'), hasLength(q.options.length));
      expect(q.optionsFor('xx'), q.optionsEn);
    });
  });

  group('Boru Bulmacasi dort dilde', () {
    final kaynak =
        File('lib/screens/games/pipes_game_screen.dart').readAsStringSync();

    test('yalnizca Ingilizce/Turkce ayrimi kalmadi', () {
      expect(kaynak.contains('isEnglish'), isFalse);
      expect(kaynak.contains('isEn '), isFalse);
    });

    test('ust satir Almanca ve Ispanyolca yaziliyor', () {
      for (final s in ['Punkte:', 'Puntos:', 'Nivel:', 'Züge:', 'Movimientos:']) {
        expect(kaynak.contains(s), isTrue, reason: s);
      }
    });
  });

  group('Arduino Atolyesi baslangic blogu', () {
    test('Turkcede blok Turkce ve ipucuyla ayni adda', () {
      final ilk = ArduinoGorevleri.seviyeler.first;
      final blok = ilk.havuz.firstWhere((b) => b.id == 'board_launch');
      expect(blok.labelFor('tr'), 'Arduino Uno açılınca');
      expect(blok.labelFor('en'), 'when Arduino Uno starts up');
      expect(ilk.ipucuTr, contains('Arduino Uno açılınca'));
    });
  });
}
