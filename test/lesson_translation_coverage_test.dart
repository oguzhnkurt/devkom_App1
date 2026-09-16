// Cevrilmis kurslarda Almanca/Ispanyolca ALAN ALAN tam mi?
//
// NEDEN: magaza sayfasinda "Almanca / Ispanyolca" yaziyorsa, o dili secen
// cocuk dersin ortasinda birden Ingilizceye dusmemeli. `pickLang` sessizce
// Ingilizceye dustugu icin eksik ceviri derlemede de, calisirken de hata
// vermez - yalnizca bu test yakalar.
//
// Bir kurs bitince listeye ekle. Henuz cevrilmemis kurslar (python, html,
// css, java, csharp, arduino) BILEREK listede degil: onlar icin Ingilizce
// yedek dogru davranis.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ceviri BEKLENEN dosyalar.
const bitmisDosyalar = [
  'lib/courses/data/scratch_lessons_data.dart',
  'lib/courses/data/mblock_lessons_data.dart',
  'lib/courses/data/html_lessons_data.dart',
  'lib/courses/data/python_lessons_data.dart',
  'lib/courses/data/css_lessons_data.dart',
  'lib/courses/data/java_lessons_data.dart',
  'lib/courses/data/csharp_lessons_data.dart',
  'lib/courses/data/arduino_lessons_data.dart',
  'lib/courses/data/course_modules.dart',
];

/// Ceviri BEKLENMEYEN alan degerleri.
///
/// Bunlar metin degil, widget'in cizecegi diyagramin anahtari. Almancasi
/// olamaz; `pickLang` Ingilizce degeri aynen dondurur, istenen de bu.
const diyagramAnahtarlari = {
  'stage_diagram',
  'coordinate_grid',
  'arrow_movement',
  'broadcast_vs_wait',
  'box_model_diagram',
};

void main() {
  test('bitmis kurslarda De/Es olmayan alan yok', () {
    final eksikler = <String>[];

    for (final yol in bitmisDosyalar) {
      final src = File(yol).readAsStringSync();
      for (final m in RegExp(r'\n(\s*)([a-zA-Z]+)En:').allMatches(src)) {
        final ad = m.group(2)!;
        final son = _degerBitisi(src, m.end);
        if (son == null) continue;
        final deger = src.substring(m.end, son);
        final icerik = RegExp(r"'((?:[^'\\]|\\.)*)'", dotAll: true)
            .allMatches(deger)
            .map((x) => x.group(1)!)
            .join();
        if (icerik.isEmpty) continue;
        if (diyagramAnahtarlari.contains(icerik)) continue;

        final kuyruk = src.substring(son, (son + 200).clamp(0, src.length));
        if (!RegExp('^\\s*,\\s*${ad}De:').hasMatch(kuyruk)) {
          final kisa = icerik.length > 60 ? '${icerik.substring(0, 60)}...' : icerik;
          eksikler.add('$yol -> $ad: $kisa');
        }
      }
    }

    expect(eksikler, isEmpty,
        reason: 'Bu alanlarda Almanca/Ispanyolca yok, dil Ingilizceye '
            'dusecek:\n${eksikler.join('\n')}');
  });

  // SATIR ICI ALANLAR — bir kez atlandiklari icin ayri bir test.
  //
  // Yukaridaki test `xEn:` alanini yalnizca SATIR BASINDA ariyor. Icerikte
  // ise tek satira sigdirilmis yapilar var:
  //
  //     ChoiceOption(text: 'Hata verir', textEn: 'It gives an error')
  //
  // Burada `textEn:` satirin ortasinda kaldigi icin hem ceviri araci hem
  // de yukaridaki test onu atliyordu: sekiz kursun ders ANLATIMI dort
  // dildeydi ama SIKLARI Ingilizce kalmisti — 874 alan. Cocugun ekranda
  // en cok okudugu sey de tam olarak sik metinleri.
  test('satir ici alanlarda da De/Es var', () {
    final eksikler = <String>[];
    final alan =
        RegExp(r"(?<![A-Za-z0-9_])([A-Za-z0-9_]+)En:\s*('(?:[^'\\]|\\.)*')");

    for (final yol in bitmisDosyalar) {
      for (final satir in File(yol).readAsLinesSync()) {
        final bas = satir.length - satir.trimLeft().length;
        for (final m in alan.allMatches(satir)) {
          if (m.start == bas) continue; // satir basi: obur testin isi
          final ad = m.group(1)!;
          if (RegExp('(?<![A-Za-z0-9_])${ad}De:').hasMatch(satir)) continue;
          final deger = m.group(2)!;
          eksikler.add('$yol -> $ad: $deger');
        }
      }
    }

    expect(eksikler, isEmpty,
        reason: 'Satir ici alanlarda Almanca/Ispanyolca yok:\n'
            '${eksikler.take(20).join('\n')}');
  });
}

/// `xEn:` sonrasindaki degerin bittigi indeks. Bitisik literalleri ve
/// listeleri tek deger sayar; degisken referansi gibi seylerde null doner.
int? _degerBitisi(String src, int i) {
  while (src[i] == ' ' || src[i] == '\n' || src[i] == '\t' || src[i] == '\r') {
    i++;
  }
  if (src[i] == '[') {
    var derin = 0;
    while (i < src.length) {
      if (src[i] == "'") {
        i = _literalBitisi(src, i);
        continue;
      }
      if (src[i] == '[') derin++;
      if (src[i] == ']') {
        derin--;
        if (derin == 0) return i + 1;
      }
      i++;
    }
    return null;
  }
  if (src[i] != "'") return null;
  while (true) {
    i = _literalBitisi(src, i);
    var j = i;
    while (j < src.length &&
        (src[j] == ' ' || src[j] == '\n' || src[j] == '\t' || src[j] == '\r')) {
      j++;
    }
    if (j < src.length && src[j] == "'") {
      i = j;
      continue;
    }
    return i;
  }
}

int _literalBitisi(String src, int i) {
  var q = i + 1;
  while (q < src.length) {
    if (src[q] == r'\') {
      q += 2;
      continue;
    }
    if (src[q] == "'") return q + 1;
    q++;
  }
  throw StateError('kapanmamis literal');
}
