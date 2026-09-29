import 'dart:io';
import 'dart:math' as math;
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
    for (final v in voices) 'wrong_$v',
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

  test('her oyun rengi icin yanlis sesi var', () {
    // Bir renk eksik kalirsa o oyunda yanlis cevap sessiz gecer.
    for (final v in voices) {
      expect(File('assets/sounds/wrong_$v.wav').existsSync(), isTrue,
          reason: 'wrong/$v eksik');
    }
  });

  test('sentezlenmis dogru/bitis sesleri geri gelmedi', () {
    // correct_* ve complete_* kulaga ucuz geliyordu ve bir turda
    // onlarca kez duyuluyordu. Yerlerini gercek kayitlar aldi
    // (oyun_dogru, bolum_bitti); dosyalar silindi.
    for (final v in voices) {
      for (final kind in ['correct', 'complete']) {
        expect(File('assets/sounds/${kind}_$v.wav').existsSync(), isFalse,
            reason: '$kind/$v geri gelmis');
      }
    }
    final servis = File('lib/services/sound_service.dart').readAsStringSync();
    expect(servis.contains("_play('oyun_dogru'"), isTrue);
    expect(servis.contains("_play('bolum_bitti'"), isTrue);
    expect(servis.contains("_play('correct_"), isFalse);
    expect(servis.contains("_play('complete_"), isFalse);
  });

  group('gercek kayitlar', () {
    // Sentezlenmis sinus ailesinin yaninda satin alinan ses paketinden
    // kirpilmis gercek kayitlar. Ust sinir her sesin KAC KERE duyuldugu
    // ile belirlendi: her soruda calan ses kisa olmali, bir kere
    // duyulan biraz uzun olabilir.
    const yeniler = {
      'dogru_cevap': 1.0, // her soruda caliyor: kisa olmali
      'odul': 2.0, // ders sonu
      'ilk_basari': 3.0, // bir kere duyuluyor
      'jeton': 1.5, // gorev odulu, oyunda puan
      'buyuk_basari': 3.0, // modul sinavi
      'oyun_bitti': 2.0,
      'kilit_acildi': 1.0,
      'oyun_dogru': 1.0, // her dogru cevapta: en kisasi olmali
      'bolum_bitti': 2.0,
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

    test('her ses dosyasi servis tarafindan CALINIYOR', () {
      // Kullanilmayan bir ses dosyasi pakete agirlik katiyor ve "bu ses
      // nereye baglanmisti?" sorusunu doguruyor. Klasordeki her dosya
      // serviste bir yerde gecmek zorunda. (correct.wav, wrong.wav ve
      // level_complete.wav bu denetimle bulundu: ton rengi ailesi
      // gelince kimse onlari calmiyordu, silindiler.)
      final servis =
          File('lib/services/sound_service.dart').readAsStringSync();
      final sahipsiz = <String>[];
      for (final f in Directory('assets/sounds')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.wav'))) {
        final ad = f.uri.pathSegments.last.replaceAll('.wav', '');
        // Ton rengi eki calisma aninda ekleniyor:
        // correct_bright -> _play('correct_' + suffix)
        final govde = ad.replaceAll(RegExp(r'_(bright|warm|soft|deep)$'), '');
        final aranan = "'$ad'";
        final arananAile = "'${govde}_";
        if (!servis.contains(aranan) && !servis.contains(arananAile)) {
          sahipsiz.add(ad);
        }
      }
      expect(sahipsiz, isEmpty,
          reason: 'Bu sesler hicbir yerde calinmiyor: $sahipsiz');
    });

    test('kayitlar ne kisik ne de tavana vurmus', () {
      // Paketten cikan sesler sentezlenmis ailenin ustune cikmasin diye
      // RMS -14..-24 dB araligina normallendi; tepe -1 dB'nin altinda
      // kalmali, yoksa hoparlorde kirilma duyuluyor.
      double desibel(double oran) => 20 * math.log(oran) / math.ln10;
      for (final ad in yeniler.keys) {
        final bytes = File('assets/sounds/$ad.wav').readAsBytesSync();
        final v = bytes.buffer.asByteData();
        final n = v.getUint32(40, Endian.little) ~/ 2;
        var kareToplam = 0.0;
        var tepe = 1;
        for (var i = 0; i < n; i++) {
          final ornek = v.getInt16(44 + i * 2, Endian.little).abs();
          if (ornek > tepe) tepe = ornek;
          kareToplam += ornek * ornek;
        }
        final rms = desibel(math.sqrt(kareToplam / n) / 32768);
        final tepeDb = desibel(tepe / 32768);
        expect(tepeDb, lessThan(-1.0), reason: '$ad tepesi cok yuksek');
        expect(rms, inInclusiveRange(-24.0, -14.0),
            reason: '$ad ses seviyesi aileden kopuk: $rms dB');
      }
    });

    test('yeni sesler gercekten baglandi', () {
      String oku(String yol) => File(yol).readAsStringSync();
      expect(oku('lib/courses/screens/module_quiz_screen.dart')
          .contains('playBuyukBasari()'), isTrue,
          reason: 'Modul sinavi hala ders sonu sesini caliyor.');
      expect(oku('lib/courses/screens/interactive_course_screen.dart')
          .contains('playKilitAcildi()'), isTrue,
          reason: 'Reklam izlenip ders acildiginda ses yok.');
      expect(oku('lib/screens/quests/quests_screen.dart')
          .contains('playJeton()'), isTrue,
          reason: 'Gorev odulu sessiz.');
      final servis = oku('lib/services/sound_service.dart');
      expect(servis.contains("_play('oyun_bitti'"), isTrue,
          reason: 'Oyun bitti hala yanlis cevap sesini caliyor.');
      expect(servis.contains('playScore() => playJeton()'), isTrue);
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
