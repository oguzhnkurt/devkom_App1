// mBlock bloklarının gerçekliği.
//
// Bu testin amacı estetik değil: çocuk uygulamada gördüğü bloğu mBlock'u
// açtığında BİREBİR aynı renkte, aynı şekilde ve aynı yazıyla bulmalı.
// "Yakın" olması yetmez — neredeyse aynı olan bir blok, çocuğun aradığını
// bulamaması demek.
//
// Buradaki değerlerin kaynağı Makeblock'un canlı yayındaki Arduino Uno
// cihaz paketi (arduino_uno v0.5.6) ve mBlock'un kendi Türkçe dil dosyası
// (res-cdn.makeblock.com/i18n-upload/mblock/web/tr/arduino_uno.json).
//
// Daha önce içerikte şunlar vardı ve hepsi yanlıştı:
//  * "9 sayısal pini YÜKSEK yap" — mBlock'ta böyle bir blok yok.
//    Gerçeği: "dijital ayarla pin 9 çıkış yüksek".
//  * Pin blokları Arduino turkuazıyla (#00979D) çiziliyordu; mBlock'ta
//    Pin kategorisi #4A90E2.
//  * Başlangıç bloğu "tıklandığında" (yeşil bayrak) idi. Yükleme modunda
//    yeşil bayrak GRİDİR; gerçek başlangıç bloğu
//    "when Arduino Uno starts up" ve Türkçesi yoktur.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/mblock_palette.dart';
import 'package:devkom_app/courses/data/mblock_lessons_data.dart';
import 'package:devkom_app/courses/data/arduino_lessons_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';

/// mBlock'un Arduino Uno paletindeki gerçek kategori renkleri.
const Map<String, int> realCategoryColors = {
  'Pin': 0xFF4A90E2,
  'seri port': 0xFF7ED321,
  'Veri': 0xFFBD10E0,
  'Sensör': 0xFF4CBFE6,
  'Olaylar': 0xFFFFBF00,
  'Kontrol': 0xFFFFAB19,
  'İşlemler': 0xFF59C059,
  'Değişkenler': 0xFFFF8C1A,
  'Bloklarım': 0xFFFF6680,
};

/// mBlock'ta OLMAYAN, uydurulmuş blok yazıları.
const List<String> fabricatedLabels = [
  'sayısal pini',      // gerçeği: "dijital ayarla pin _ çıkış _"
  'analog pini oku',   // gerçeği: "analog oku pin (A) _"
  'ses tonu pini',     // gerçeği: "pinde çal _ nota _ ile _ vuruş"
  'pwm pini',          // gerçeği: "PWM ayarla pin_ çıkış _"
  'pini ÇIKIŞ yap',    // mBlock'ta pin yönü bloğu yok
];

List<ScratchBlock> blocksOf(List<InteractiveLesson> lessons) => lessons
    .expand((l) => l.steps)
    .whereType<BlockBuilderStep>()
    .expand((s) => s.availableBlocks)
    .toList();

void main() {
  group('Palet renkleri', () {
    test('kategori renkleri mBlock ile birebir aynı', () {
      for (final (en, tr, color) in MBlockPalette.categories) {
        expect(realCategoryColors[tr], isNotNull,
            reason: 'Bilinmeyen kategori: $tr ($en)');
        expect(color.toARGB32(), realCategoryColors[tr],
            reason: '$tr kategorisinin rengi mBlock ile aynı değil');
      }
    });

    test('palette dokuz kategori var, eksik ya da fazla yok', () {
      // Arduino Uno cihazı seçiliyken palette Hareket, Görünüm, Ses ve
      // Algılama YOKTUR — onlar kuklaya ait.
      expect(MBlockPalette.categories.length, 9);
      final names = MBlockPalette.categories.map((c) => c.$2).toSet();
      expect(names, realCategoryColors.keys.toSet());
      for (final spriteOnly in ['Hareket', 'Görünüm', 'Ses', 'Algılama']) {
        expect(names.contains(spriteOnly), isFalse,
            reason: '$spriteOnly cihaz paletinde yok');
      }
    });
  });

  group('Blok yazıları', () {
    final all = [
      ...blocksOf(MBlockLessonsData.allLessons),
      ...blocksOf(ArduinoLessonsData.module1),
      ...blocksOf(ArduinoLessonsData.module2),
      ...blocksOf(ArduinoLessonsData.module3),
      ...blocksOf(ArduinoLessonsData.module4),
      ...blocksOf(ArduinoLessonsData.module5),
    ];

    test('uydurulmuş blok yazısı kalmadı', () {
      final bad = <String>[];
      for (final b in all) {
        for (final fake in fabricatedLabels) {
          if (b.label.toLowerCase().contains(fake.toLowerCase())) {
            bad.add('${b.id}: "${b.label}"  (yasak: "$fake")');
          }
        }
      }
      expect(bad, isEmpty,
          reason: 'mBlock\'ta olmayan blok yazıları:\n${bad.join('\n')}');
    });

    test('Ingilizce blok yazilarinda Turkce kelime kalmadi', () {
      // BU HATA STATIK ARAMAYLA GORUNMUYOR: etiket, yardimci
      // fonksiyonun ARGUMANLARIYLA calisma aninda kuruluyor.
      //  MBlockBlocks.digitalWrite('9', 'yüksek')
      // Ingilizce etiketi "set digital pin 9 output as yüksek" yapiyordu:
      // blok Ingilizce gorunuyor ama icinde Turkce bir kelime var ve
      // cocuk mBlock'ta o blogu ararken bulamiyor. Kursun tek amaci
      // uygulamadaki blogun mBlock'takiyle BIREBIR ayni olmasi.
      const trOnly = 'çğıöşüÇĞİÖŞÜ';
      final bad = <String>[];
      for (final b in all) {
        final en = b.labelFor('en');
        for (final ch in trOnly.split('')) {
          if (en.contains(ch)) {
            bad.add('${b.id}: "$en"  (Turkce harf: $ch)');
            break;
          }
        }
      }
      expect(bad, isEmpty,
          reason: 'Ingilizce etiketlerde Turkce kalinti:\n${bad.join('\n')}');
    });

    test('Arduino derslerinde yeşil bayrak başlangıç bloğu yok', () {
      // Yükleme modunda yeşil bayrak gridir. Widget, id\'si "green_flag"
      // olan bloğun yanına yeşil bayrak simgesi çiziyor — Arduino
      // derslerinde bu simge yanlış bir şey öğretir.
      final flags = all.where((b) => b.id == 'green_flag').toList();
      expect(flags, isEmpty,
          reason: 'Arduino/mBlock derslerinde green_flag: '
              '${flags.map((b) => b.label).join(", ")}');
    });

    test('başlangıç bloğunun Türkçesi uydurulmadı', () {
      // mBlock\'un Türkçe dosyasında bu anahtarın değeri İngilizce metnin
      // aynısı; Türkçe arayüzde bile blok İngilizce görünüyor.
      for (final b in all) {
        if (b.id != 'board_launch') continue;
        expect(b.label, 'when Arduino Uno starts up',
            reason: 'Başlangıç bloğuna uydurma bir Türkçe isim konmuş');
      }
    });
  });

  group('Blok şekilleri', () {
    final all = blocksOf(MBlockLessonsData.allLessons);

    test('dijital oku altıgen, analog oku oval', () {
      for (final b in all) {
        if (b.label.startsWith('dijital oku')) {
          expect(b.shape, ScratchBlockShape.boolean, reason: b.label);
        }
        if (b.label.startsWith('analog oku')) {
          expect(b.shape, ScratchBlockShape.reporter, reason: b.label);
        }
        if (b.label.startsWith('mesafe algılayıcı')) {
          expect(b.shape, ScratchBlockShape.reporter, reason: b.label);
        }
      }
    });

    test('sürekli tekrarla ve eğer/ise C bloğu', () {
      for (final b in all) {
        if (b.label == 'sürekli tekrarla' || b.label.startsWith('eğer ')) {
          expect(b.shape, ScratchBlockShape.cBlock, reason: b.label);
        }
      }
    });

    test('başlangıç bloğu şapka', () {
      for (final b in all.where((b) => b.id == 'board_launch')) {
        expect(b.shape, ScratchBlockShape.cap);
        expect(b.color, const Color(0xFFFFBF00));
      }
    });
  });

  group('Ders METİNLERİ', () {
    // NEDEN KAYNAK DOSYAYI OKUYORUZ
    // ------------------------------
    // Yukarıdaki testler yalnızca ScratchBlock NESNELERİNİN etiketlerine
    // bakıyor. Blok nesneleri düzeltildikten sonra bile düz anlatım
    // metinleri ("Robotlar sekmesinde ... bloğu vardır") aylarca eski
    // uydurma adları öğretmeye devam etti — çocuğun okuduğu cümle de en az
    // bloğun etiketi kadar öğretiyor. Bu yüzden burada ders veri
    // dosyalarının TAMAMINI, şık ve açıklama metinleri dahil tarıyoruz.
    final sources = [
      'lib/courses/data/arduino_lessons_data.dart',
      'lib/courses/data/mblock_lessons_data.dart',
    ];

    test('anlatım metinlerinde uydurma blok adı yok', () {
      // DİKKAT: burada düz alt dize araması YETMİYOR. "PWM pini sadece
      // 0-255 kabul eder" sıradan ve DOĞRU bir cümle; yasak olan
      // "5 pwm pini pot yap" biçimindeki uydurma ETİKET. Bu yüzden
      // etiketin şeklini arayan kalıplar kullanıyoruz.
      final patterns = <RegExp>[
        RegExp(r'sayısal pini', caseSensitive: false),
        RegExp(r'analog pini oku', caseSensitive: false),
        RegExp(r'ses tonu pini', caseSensitive: false),
        RegExp(r'\d\s*pwm pini', caseSensitive: false),
        RegExp(r'pini ÇIKIŞ yap', caseSensitive: false),
        RegExp(r'servo pinini', caseSensitive: false),
        RegExp(r'tetik pini', caseSensitive: false),
      ];
      final bad = <String>[];
      for (final path in sources) {
        final lines = File(path).readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          for (final re in patterns) {
            if (re.hasMatch(lines[i])) {
              bad.add('$path:${i + 1}  (yasak: "${re.pattern}")');
            }
          }
        }
      }
      expect(bad, isEmpty,
          reason: 'Ders metinlerinde mBlock\'ta olmayan blok adları:\n'
              '${bad.join('\n')}');
    });

    test('cihaz paletinde olmayan kategoriler öğretilmiyor', () {
      // Arduino Uno seçiliyken palette Robotlar/Hareket/Görünüm/Ses/
      // Algılama diye kategori YOK. "Robotlar sekmesindeki bloğu al"
      // diyen bir cümle, çocuğu var olmayan bir sekmede arattırır.
      const ghostTabs = [
        'Robotlar sekme',
        'Görünüm sekme',
        'Hareket sekme',
        'Ses sekme',
        'Algılama sekme',
        'Arduino Programı',
      ];
      final bad = <String>[];
      for (final path in sources) {
        final lines = File(path).readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          for (final ghost in ghostTabs) {
            if (lines[i].contains(ghost)) {
              bad.add('$path:${i + 1}  (yasak: "$ghost")');
            }
          }
        }
      }
      expect(bad, isEmpty, reason: 'Var olmayan palet göndermeleri:\n'
          '${bad.join('\n')}');
    });
  });

  test('PWM yalnızca PWM yapabilen pinlerde öğretiliyor', () {
    // Uno\'da PWM pinleri 3, 5, 6, 9, 10, 11 (kartta ~ işaretli).
    const pwmPins = {'3', '5', '6', '9', '10', '11'};
    final re = RegExp(r'PWM ayarla pin\s*(\d+)');
    for (final b in blocksOf(MBlockLessonsData.allLessons)) {
      final m = re.firstMatch(b.label);
      if (m == null) continue;
      expect(pwmPins.contains(m.group(1)), isTrue,
          reason: '${m.group(1)} numaralı pin PWM yapamaz: "${b.label}"');
    }
  });
}
