import 'package:flutter_test/flutter_test.dart';
import 'package:devkom_app/screens/games/word_match_words.dart';

/// Kelime Avi eslestirmesi cocugun diline uymak zorunda.
///
/// Hata buydu: arayuz almanca secildiginde bile oyun ingilizce-turkce
/// eslestirme veriyordu. Alman bir cocuk "Sensor -> Sensör" kartini
/// goruyordu.
void main() {
  const langs = ['tr', 'en', 'de', 'es'];

  // Turkceye ozel harfler. a-umlaut almanca/ispanyolcada da var,
  // o yuzden listede yok.
  final turkishOnly = RegExp(r'[ğĞıİşŞ]');

  test('her seviye dolu ve besten fazla kelime var', () {
    expect(wordMatchWords.keys.toList()..sort(), [1, 2, 3, 4, 5]);
    for (final entry in wordMatchWords.entries) {
      expect(entry.value.length, greaterThanOrEqualTo(5),
          reason: 'seviye ${entry.key} bir tahtayi dolduramiyor');
    }
  });

  test('her kelimenin dort dilde de karsiligi var', () {
    for (final entry in wordMatchWords.entries) {
      for (final w in entry.value) {
        expect(w['term'], isNotNull, reason: 'seviye ${entry.key}: term yok');
        for (final lang in langs) {
          final v = w[lang];
          expect(v, isNotNull,
              reason: 'seviye ${entry.key} / ${w['term']}: $lang yok');
          expect(v!.trim(), isNotEmpty,
              reason: 'seviye ${entry.key} / ${w['term']}: $lang bos');
        }
      }
    }
  });

  test('almanca ve ispanyolca karsiliklar turkce degil', () {
    for (final entry in wordMatchWords.entries) {
      for (final w in entry.value) {
        for (final lang in ['de', 'es']) {
          expect(turkishOnly.hasMatch(w[lang]!), isFalse,
              reason: 'seviye ${entry.key} / ${w['term']}: '
                  '$lang karsiligi "${w[lang]}" turkce harf iceriyor');
        }
      }
    }
  });

  test('almanca/ispanyolca listeler turkcenin kopyasi degil', () {
    // "Robot", "Motor", "LED" gibi bir avuc kelime dillerde ayni yazilir;
    // asil yakalamak istedigimiz sey bir dilin listesinin toptan turkce
    // birakilmis olmasi.
    for (final entry in wordMatchWords.entries) {
      for (final lang in ['de', 'es']) {
        final same = entry.value.where((w) => w[lang] == w['tr']).length;
        expect(same / entry.value.length, lessThan(0.5),
            reason: 'seviye ${entry.key}: "$lang" listesinin '
                'buyuk bolumu turkceyle ayni');
      }
    }
  });

  test('ingilizce tarafta terimin kendisi tekrar edilmiyor', () {
    for (final entry in wordMatchWords.entries) {
      for (final w in entry.value) {
        expect(w['en']!.toLowerCase(), isNot(equals(w['term']!.toLowerCase())),
            reason: 'seviye ${entry.key} / ${w['term']}: '
                'ingilizce arayuzde kelime kendisiyle eslesiyor');
      }
    }
  });

  test('bir tahtada ayni karsilik iki kez cikmiyor', () {
    for (final entry in wordMatchWords.entries) {
      for (final lang in langs) {
        final seen = <String>{};
        for (final w in entry.value) {
          expect(seen.add(w[lang]!.toLowerCase()), isTrue,
              reason: 'seviye ${entry.key}: "$lang" tarafinda '
                  '"${w[lang]}" tekrar ediyor');
        }
      }
    }
  });
}
