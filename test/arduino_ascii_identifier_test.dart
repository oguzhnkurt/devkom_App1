// Arduino/C++ kod orneklerindeki tanimlayicilar ASCII olmali.
//
// Arduino IDE (avr-gcc) `int süre` ya da `Serial.println(değer)` yazan bir
// sketch'i DERLEMEZ. Cocuk dersteki kodu birebir kopyaladiginda hata
// aliyor ve hatanin kendisinde oldugunu saniyor.
//
// Python 3 Unicode tanimlayici kabul eder (python derslerindeki `sayı`,
// `içerik`, `Öğrenci` calisir) — bu yuzden yalnizca Arduino ve mBlock
// dosyalari taraniyor. Dize icindeki ("Mesafe: ") ve yorum satirindaki
// Turkce metin sorun degil.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _dosyalar = [
  'lib/courses/data/arduino_lessons_data.dart',
  'lib/courses/data/mblock_lessons_data.dart',
];

/// Satir gercekten kod mu?
///
/// Iki kosul birden: noktali virgul / susulu parantez ile BITECEK ve
/// icinde bir Arduino komutu ya da tip adi GECECEK. Tek kosul yetmiyor:
/// "Yani Scratch'te yaptigin sey bilgisayarin icinde kalir;" cumlesi de
/// noktali virgulle bitiyor, ama kod degil.
final _kodBitisi = RegExp(r'[;{}]$');
final _kodIsareti = RegExp(
    r'(Serial\.|digitalWrite|digitalRead|analogWrite|analogRead|pinMode|'
    r'delay\s*\(|lcd\.|servo\.|#include|#define|'
    r'\b(void|int|float|long|bool|char|const)\s+\w)');

bool _kodMu(String satir) {
  final t = satir.trim();
  return _kodBitisi.hasMatch(t) && _kodIsareti.hasMatch(t);
}

/// Dize literallerini ve yorumlari bosluga cevirir.
String _kodDisiTemizle(String t) {
  final b = StringBuffer();
  var i = 0;
  while (i < t.length) {
    if (t[i] == '"') {
      var j = i + 1;
      while (j < t.length && t[j] != '"') {
        j++;
      }
      b.write(' ' * (j - i + 1));
      i = j + 1;
      continue;
    }
    if (i + 1 < t.length && t.substring(i, i + 2) == '//') {
      b.write(' ' * (t.length - i));
      break;
    }
    b.write(t[i]);
    i++;
  }
  return b.toString();
}

void main() {
  test('Arduino kod orneklerinde Turkce karakterli tanimlayici yok', () {
    final tr = RegExp('[çğıöşüÇĞİÖŞÜ]');
    final dize = RegExp(r"'((?:[^'\\]|\\.)*)'");
    final kelime = RegExp(r'[A-Za-zçğıöşüÇĞİÖŞÜ_][A-Za-z0-9çğıöşüÇĞİÖŞÜ_]*');
    final bozuk = <String>[];

    for (final yol in _dosyalar) {
      final satirlar = File(yol).readAsLinesSync();
      for (var i = 0; i < satirlar.length; i++) {
        for (final m in dize.allMatches(satirlar[i])) {
          for (final kod in m.group(1)!.split(r'\n')) {
            if (!_kodMu(kod)) continue;
            for (final w in kelime.allMatches(_kodDisiTemizle(kod))) {
              if (tr.hasMatch(w.group(0)!)) {
                bozuk.add('$yol:${i + 1}  ${w.group(0)}  ||  ${kod.trim()}');
              }
            }
          }
        }
      }
    }

    expect(bozuk, isEmpty,
        reason: 'Arduino IDE bu tanimlayicilari derlemez:\n'
            '${bozuk.join('\n')}');
  });
}
