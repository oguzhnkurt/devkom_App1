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

  group('gercek kayitlar', () {
    // Sentezlenmis sinus ailesinin yanina ucu de satin alinmis gercek
    // kayit geldi: ders sorusu dogru cevabi, bolum odulu ve acilistaki
    // ilk gorevin sesi.
    const yeniler = {
      'dogru_cevap': 1.0, // her soruda caliyor: kisa olmali
      'odul': 2.0,
      'ilk_basari': 3.0, // bir kere duyuluyor, biraz uzun olabilir
    };

    test('dosyalar var, mono 44.1 kHz ve sinirdan kisa', () {
      for (final giris in yeniler.entries) {
        final f = File('assets/sounds/${giris.key}.wav');
        expect(f.existsSync(), isTrue, reason: '${giris.key}.wav eksik');
        final bytes = f.readAsBytesSync();
        final v = bytes.buffer.asByteData();
        expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
        final kanal = v.getUint16(22, Endian.little);
        final rate = v.getUint32(24, Endian.little);
        expect(kanal, 1, reason: '${giris.key} tek kanal degil');
        expect(rate, 44100);
        // ffmpeg'in LIST etiketi temizlendi: veri parcasi 36. bayttan
        // basliyor. Temizlenmezse bu satir kirilir — ve dosya da
        // gereksiz yere buyuk olur.
        expect(String.fromCharCodes(bytes.sublist(36, 40)), 'data');
        final saniye = v.getUint32(40, Endian.little) / (rate * 2);
        expect(saniye, lessThan(giris.value),
            reason: '${giris.key} cok uzun: $saniye sn');
        expect(saniye, greaterThan(0.1));
      }
    });

    test('ders sorulari oyunlarin sesini degil bu sesi caliyor', () {
      final adim = File('lib/courses/screens/widgets/step_widgets.dart')
          .readAsStringSync();
      expect(adim.contains('SoundService.playCorrect()'), isFalse,
          reason: 'Ders adimi yine oyun sesi ailesini caliyor.');
      expect(adim.contains('SoundService.playSoruDogru()'), isTrue);

      final servis =
          File('lib/services/sound_service.dart').readAsStringSync();
      expect(servis.contains("_play('dogru_cevap')"), isTrue);
      expect(servis.contains("_play('odul')"), isTrue);
      expect(servis.contains("_play('ilk_basari')"), isTrue);
    });

    test('ilk gorev ve ders sonu sesleri bagli', () {
      expect(
          File('lib/widgets/first_task.dart')
              .readAsStringSync()
              .contains('SoundService.playIlkBasari()'),
          isTrue,
          reason: 'Acilistaki ilk surukle-birak hala sessiz.');
      expect(
          File('lib/courses/screens/interactive_lesson_screen.dart')
              .readAsStringSync()
              .contains('SoundService.playOdul()'),
          isTrue);
    });
  });

  test('pubspec ses klasorunu paketliyor', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('assets/sounds/'), isTrue);
  });
}
