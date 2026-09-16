import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Quiz ile dersin AYNI konuyu anlatmasini kontrol eder.
///
/// NEDEN
/// -----
/// python_04 dersinin konusu "Veri Tipleri" idi ama quizi girinti,
/// if/else ve elif soruyordu. python_05 "Matematik Islemleri" idi,
/// quizi range() ve while soruyordu. Kursta kosul ve dongu dersi HIC
/// yok — Python bes derste bitiyor. Yani cocuk hic gormedigi bir
/// konudan sinava giriyordu ve "anlamadim" demesi kendi hatasi gibi
/// gorunuyordu.
///
/// Tam otomatik bir konu esleme mumkun degil; bu test bilinen tuzak
/// kelimeleri tariyor: veri tipleri dersinin quizinde dongu sormak
/// gibi. Yeni bir ders eklenince buraya da bir satir eklenir.
void main() {
  final quizler =
      File('lib/courses/data/quizzes_data.dart').readAsStringSync();

  /// Bir quiz blogunun govdesini dondurur.
  ///
  /// YORUM SATIRLARI ATILIYOR: blok bir sonraki quizin basina kadar
  /// uzaniyor ve arada o quizin ACIKLAMA YORUMU var. Yorumlarda
  /// "range(", "while" gibi kelimeler gecebiliyor (nitekim geciyor:
  /// python_05'in yorumu bu degisikligin neden yapildigini anlatiyor)
  /// ve bu, komsu quizin testini yanlis yere dusuruyordu.
  String govde(String lessonId) {
    final bas = quizler.indexOf("'$lessonId': Quiz(");
    expect(bas, isNot(-1), reason: '$lessonId quizi yok');
    final sonraki = quizler.indexOf("': Quiz(", bas + 20);
    final ham = sonraki == -1
        ? quizler.substring(bas)
        : quizler.substring(bas, sonraki);
    return ham
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
  }

  group('Python quizleri dersin konusunda', () {
    test('python_04 (Veri Tipleri) veri tipi soruyor', () {
      final q = govde('python_04');
      expect(q.contains('float'), isTrue);
      expect(q.contains('int'), isTrue);
      // Kosul/dongu konusu bu derste YOK.
      for (final yasak in ['elif', 'range(', 'while']) {
        expect(q.contains(yasak), isFalse,
            reason: 'Veri tipleri dersinin quizinde "$yasak" sorulamaz — '
                'o konu kursta hic anlatilmiyor.');
      }
    });

    test('python_05 (Matematik Islemleri) islem soruyor', () {
      final q = govde('python_05');
      expect(q.contains('%'), isTrue);
      expect(q.contains('**'), isTrue);
      for (final yasak in ['range(', 'while', 'elif']) {
        expect(q.contains(yasak), isFalse,
            reason: 'Matematik islemleri dersinin quizinde "$yasak" '
                'sorulamaz — o konu kursta hic anlatilmiyor.');
      }
    });
  });

  test('her quiz kendi dersine bagli', () {
    // lessonId ile anahtar ayni olmali; biri degistirilip digeri
    // unutulursa quiz yanlis derse asiliyor.
    final eslesmeler = RegExp(r"'(\w+)': Quiz\(\s*\n\s*id: '[^']*',\s*\n\s*lessonId: '(\w+)'")
        .allMatches(quizler);
    expect(eslesmeler, isNotEmpty);
    for (final m in eslesmeler) {
      expect(m.group(2), m.group(1),
          reason: '${m.group(1)} quizinin lessonId alani ${m.group(2)}');
    }
  });
}
