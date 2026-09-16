import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Proje adimlarinin dort dilde eksiksiz olmasi.
///
/// ProjectStep modelinde `requirementsEn/De/Es` ve `hintsEn/De/Es`
/// alanlari bastan beri vardi ama 30 adimin 25'inde hic doldurulmamisti.
/// `pickLangList` dolu olmayan dilde TURKCESINE dusuyor: Almanca
/// calisan bir cocuk "Kedi dans_basladi haberini salsin" yaziyordu.
/// Ekranda gorunmeyen bir hata degil — yalnizca Turkce bakan kimse
/// gormuyordu.
///
/// Bu test dosyalari okuyor, uygulamayi calistirmiyor: eksik ceviri bir
/// davranis degil, bir veri eksigi.
void main() {
  final dosyalar = Directory('lib/courses/data')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('_lessons_data.dart'))
      .toList();

  test('ders verisi dosyalari bulunuyor', () {
    expect(dosyalar, isNotEmpty);
  });

  /// Bir ProjectStep blogundaki `ad: [ ... ]` listesinin oge sayisi.
  int? ogeSayisi(String blok, String ad) {
    final bas = blok.indexOf('          $ad: [\n');
    if (bas < 0) return null;
    final son = blok.indexOf('\n          ],', bas);
    if (son < 0) return null;
    final ic = blok.substring(bas, son);
    return RegExp(r"^\s{12}'", multiLine: true).allMatches(ic).length;
  }

  test('her proje adimi dort dilde eksiksiz', () {
    final eksikler = <String>[];
    var adimSayisi = 0;

    for (final dosya in dosyalar) {
      final kaynak = dosya.readAsStringSync();
      for (final m in RegExp('ProjectStep\\(').allMatches(kaynak)) {
        final son = kaynak.indexOf('\n        ),', m.start);
        final blok = kaynak.substring(m.start, son < 0 ? kaynak.length : son);
        final kimlik =
            RegExp(r"id:\s*'([^']+)'").firstMatch(blok)?.group(1) ?? '?';
        adimSayisi++;

        for (final alan in ['requirements', 'hints']) {
          final tr = ogeSayisi(blok, alan);
          if (tr == null) continue; // hints bos birakilabiliyor
          for (final ek in ['En', 'De', 'Es']) {
            final n = ogeSayisi(blok, '$alan$ek');
            if (n == null) {
              eksikler.add('$kimlik: $alan$ek yok');
            } else if (n != tr) {
              // Sayilar tutmuyorsa bir madde ceviride dusmus demektir;
              // cocuk o dilde bir gereksinimi hic gormuyor.
              eksikler.add('$kimlik: $alan$ek $n oge, Turkcesi $tr');
            }
          }
        }
      }
    }

    expect(adimSayisi, greaterThan(25),
        reason: 'Proje adimlari bulunamadiysa test bir sey sinamiyor.');
    expect(eksikler, isEmpty, reason: eksikler.join('\n'));
  });
}
