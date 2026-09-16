import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Ses dosyalari gercekten pakette mi?
///
/// Servis dosya bulamadiginda sessizce hata yutuyor (dogru davranis: ses
/// cikmamasi oyunu durdurmamali). Ama bu, eksik bir dosyanin hicbir yerde
/// FARK EDILMEMESI demek — uygulama calisir, sadece sessiz olur. Bu test
/// o sessiz basarisizligi yakaliyor.
void main() {
  // Her oyun ayni sesi calmasin diye sesler bir AILE: ayni muzikal
  // fikir, dort farkli ton rengi. Dosyalardan biri eksik olursa servis
  // sessizce hata yutuyor (dogru davranis: ses cikmamasi oyunu
  // durdurmamali) — yani eksiklik hicbir yerde fark edilmezdi.
  const voices = ['bright', 'warm', 'soft', 'deep'];
  final expected = <String>[
    'tap',
    'drop',
    for (final v in voices) ...['correct_$v', 'wrong_$v', 'complete_$v'],
  ];

  test('her ses dosyasi var ve bos degil', () {
    for (final name in expected) {
      final f = File('assets/sounds/$name.wav');
      expect(f.existsSync(), isTrue, reason: '$name.wav eksik');
      expect(f.lengthSync(), greaterThan(1000), reason: '$name.wav bos');
    }
  });

  test('sesler kisa: hicbiri 2 saniyeyi gecmiyor', () {
    // Uzun bir efekt oyunun akisini keser; cocuk bir sonraki hamlesini
    // ses bitene kadar bekliyormus gibi hisseder.
    for (final name in expected) {
      final bytes = File('assets/sounds/$name.wav').readAsBytesSync();
      // WAV basligi: 24. bayttan itibaren ornekleme hizi, 40. bayttan
      // itibaren veri uzunlugu (16-bit mono icin).
      final rate = bytes.buffer.asByteData().getUint32(24, Endian.little);
      final dataBytes = bytes.buffer.asByteData().getUint32(40, Endian.little);
      final seconds = dataBytes / (rate * 2);
      expect(seconds, lessThan(2.0), reason: '$name.wav cok uzun');
      expect(seconds, greaterThan(0.05), reason: '$name.wav cok kisa');
    }
  });

  test('her oyun rengi icin ucu de var', () {
    // Bir rengin "dogru" sesi olup "yanlis" sesi olmazsa, o oyunda
    // yanlis cevap sessiz kalir.
    for (final v in voices) {
      for (final kind in ['correct', 'wrong', 'complete']) {
        expect(File('assets/sounds/${kind}_$v.wav').existsSync(), isTrue,
            reason: '$kind/$v eksik');
      }
    }
  });

  test('pubspec ses klasorunu paketliyor', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('assets/sounds/'), isTrue);
  });
}
