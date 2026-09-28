import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/mblock_lessons_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_tezgahi.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';

/// mBlock tezgahi — gercek surukle-birak blok editoru.
///
/// Tezgahin kendisi bir WebView ve birim testinde acilmiyor. Ama asil
/// is WebView'da degil: cocugun kurdugu programin dogru sayilip
/// sayilmadigi saf Dart'ta karar veriliyor. Bu testler o karari,
/// paketin bulundugunu ve derslerin cozumlerini kilitliyor.
void main() {
  group('program karsilastirmasi', () {
    List<List<MBlockBlok>> yigin(List<MBlockBlok> b) => [b];

    test('dogru program kabul ediliyor', () {
      final kurulan = yigin([
        const MBlockBlok(tip: 'dev_kart_acilis'),
        const MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {
          'PIN': '9',
          'SEVIYE': 'HIGH',
        }),
      ]);
      expect(
        mblockCozumDogruMu(kurulan, const [
          MBlockBeklenen('dev_kart_acilis'),
          MBlockBeklenen('dev_dijital_yaz',
              alanlar: {'PIN': '9', 'SEVIYE': 'HIGH'}),
        ]),
        isTrue,
      );
    });

    test('yanlis pin kabul edilmiyor', () {
      final kurulan = yigin([
        const MBlockBlok(tip: 'dev_kart_acilis'),
        const MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {
          'PIN': '13',
          'SEVIYE': 'HIGH',
        }),
      ]);
      expect(
        mblockCozumDogruMu(kurulan, const [
          MBlockBeklenen('dev_kart_acilis'),
          MBlockBeklenen('dev_dijital_yaz', alanlar: {'PIN': '9'}),
        ]),
        isFalse,
      );
    });

    test('dersin yazmadigi alan serbest', () {
      // NEDEN: ders "pin 9 olsun" diyorsa cocugun SEVIYE secimi
      // denetlenmemeli. Bir dersin neyi olctugu tanimindan okunmali.
      final kurulan = yigin([
        const MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {
          'PIN': '9',
          'SEVIYE': 'LOW',
        }),
      ]);
      expect(
        mblockCozumDogruMu(kurulan,
            const [MBlockBeklenen('dev_dijital_yaz', alanlar: {'PIN': '9'})]),
        isTrue,
      );
    });

    test('C kutusunun ici de karsilastiriliyor', () {
      final dogru = yigin([
        const MBlockBlok(tip: 'dev_kart_acilis'),
        const MBlockBlok(tip: 'dev_surekli', icerik: [
          MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'SEVIYE': 'HIGH'}),
          MBlockBlok(tip: 'dev_bekle', alanlar: {'SANIYE': '1'}),
        ]),
      ]);
      const beklenen = [
        MBlockBeklenen('dev_kart_acilis'),
        MBlockBeklenen('dev_surekli', icerik: [
          MBlockBeklenen('dev_dijital_yaz', alanlar: {'SEVIYE': 'HIGH'}),
          MBlockBeklenen('dev_bekle', alanlar: {'SANIYE': '1'}),
        ]),
      ];
      expect(mblockCozumDogruMu(dogru, beklenen), isTrue);

      // Ayni bloklar, C kutusunun DISINDA: yanlis.
      final disarida = yigin([
        const MBlockBlok(tip: 'dev_kart_acilis'),
        const MBlockBlok(tip: 'dev_surekli'),
        const MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'SEVIYE': 'HIGH'}),
        const MBlockBlok(tip: 'dev_bekle', alanlar: {'SANIYE': '1'}),
      ]);
      expect(mblockCozumDogruMu(disarida, beklenen), isFalse);
    });

    test('tahtada iki ayri yigin varsa dogru sayilmiyor', () {
      // Yarim birakilmis bir parca tahtada dururken program "hazir"
      // degildir; cocuk onu ya baglamali ya silmeli.
      final iki = [
        [const MBlockBlok(tip: 'dev_kart_acilis')],
        [const MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'PIN': '9'})],
      ];
      expect(
        mblockCozumDogruMu(iki, const [MBlockBeklenen('dev_kart_acilis')]),
        isFalse,
      );
    });

    test('bos tahta dogru degil', () {
      expect(
        mblockCozumDogruMu(const [], const [MBlockBeklenen('dev_bayrak')]),
        isFalse,
      );
    });

    test('1 ile 1.0 ayni sayi', () {
      final kurulan = yigin([
        const MBlockBlok(tip: 'dev_bekle', alanlar: {'SANIYE': '1.0'}),
      ]);
      expect(
        mblockCozumDogruMu(kurulan,
            const [MBlockBeklenen('dev_bekle', alanlar: {'SANIYE': '1'})]),
        isTrue,
      );
    });
  });

  group('sayfadan gelen mesaj', () {
    test('durum mesaji yiginlara cevriliyor', () {
      final mesaj = jsonEncode({
        'tur': 'durum',
        'veri': {
          'yiginlar': [
            [
              {'tip': 'dev_kart_acilis', 'alanlar': {}},
              {
                'tip': 'dev_surekli',
                'alanlar': {},
                'icerik': [
                  {
                    'tip': 'dev_dijital_yaz',
                    'alanlar': {'PIN': 9, 'SEVIYE': 'HIGH'}
                  }
                ]
              }
            ]
          ]
        }
      });
      final yiginlar = MBlockBlok.mesajdanYiginlar(mesaj);
      expect(yiginlar.length, 1);
      expect(yiginlar.first.map((b) => b.tip),
          ['dev_kart_acilis', 'dev_surekli']);
      // Sayi olarak gelen alan da METNE cevriliyor: "9" ile 9 ayrimi
      // bir hata kaynagi olmamali.
      expect(yiginlar.first[1].icerik.first.alanlar['PIN'], '9');
    });

    test('bozuk mesaj dersi cokertmiyor', () {
      expect(MBlockBlok.mesajdanYiginlar('{bu json degil'), isEmpty);
      expect(MBlockBlok.mesajdanYiginlar('{"tur":"hazir"}'), isEmpty);
      expect(MBlockBlok.mesajdanYiginlar('[]'), isEmpty);
    });
  });

  group('paket', () {
    final kok = Directory('assets/mblock');

    test('scratch-blocks paketi ve sayfa yerinde', () {
      for (final ad in [
        'scratch_blocks.min.js',
        'mblock_bloklari.js',
        'tezgah.js',
        'index.html',
        'SCRATCH_BLOCKS_LICENSE',
        'NASIL_URETILDI.md',
      ]) {
        expect(File('${kok.path}/$ad').existsSync(), isTrue,
            reason: '$ad pakette yok — tezgah bos acilir.');
      }
      expect(File('${kok.path}/media/green-flag.svg').existsSync(), isTrue);
    });

    test('pubspec paketi bildiriyor', () {
      // Bildirilmezse dosyalar uygulamaya GIRMEZ ve tezgah bos acilir.
      // Ayni hata maskot gorselleriyle bir kez yasandi (1.0.8).
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec.contains('- assets/mblock/'), isTrue);
      expect(pubspec.contains('- assets/mblock/media/'), isTrue);
    });

    test('sayfa disariya cikmiyor', () {
      final html = File('${kok.path}/index.html').readAsStringSync();
      expect(html.contains("default-src 'none'"), isTrue,
          reason: 'Icerik Guvenligi Politikasi yok — sayfa uzaktan '
              'bir sey cekebilir.');
      expect(RegExp(r'(src|href)="https?:').hasMatch(html), isFalse,
          reason: 'Sayfa bir adrese bagli; cevrimdisi calismaz.');
    });

    test('katalogdaki renkler mblock_palette ile ayni', () {
      // Cocuk uygulamadaki blogu mBlock'u acinca AYNI renkte bulmali.
      final katalog = File('${kok.path}/mblock_bloklari.js')
          .readAsStringSync()
          .toUpperCase();
      final palet = File('lib/courses/data/mblock_palette.dart')
          .readAsStringSync()
          .toUpperCase();
      for (final renk in [
        '4A90E2', // Pin
        '7ED321', // seri port
        'BD10E0', // Veri
        '4CBFE6', // Sensor
        'FFBF00', // Olaylar
        'FFAB19', // Kontrol
        '59C059', // Islemler
        '4C97FF', // Hareket
        '9966FF', // Gorunum
      ]) {
        expect(katalog.contains(renk), isTrue,
            reason: '$renk katalogda yok');
        expect(palet.contains(renk), isTrue,
            reason: '$renk mblock_palette.dart ile ayrismis');
      }
    });
  });

  group('derslerin tezgah ayarlari', () {
    final adimlar = <BlockBuilderStep>[
      for (final ders in MBlockLessonsData.allLessons)
        for (final adim in ders.steps)
          if (adim is BlockBuilderStep && adim.mblock != null) adim,
    ];

    test('en az dort adim tezgaha bagli', () {
      expect(adimlar.length, greaterThanOrEqualTo(4));
    });

    test('her cozum yalnizca arac kutusundaki bloklari kullaniyor', () {
      // Cozumde olup arac kutusunda olmayan bir blok, cozulemez bir
      // adim demek.
      for (final adim in adimlar) {
        final kutu = adim.mblock!.bloklar.toSet();
        void gez(List<MBlockBeklenen> liste) {
          for (final b in liste) {
            expect(kutu, contains(b.tip),
                reason: '${adim.id}: cozum "${b.tip}" blogunu istiyor ama '
                    'arac kutusunda yok.');
            gez(b.icerik);
          }
        }

        gez(adim.mblock!.cozum);
      }
    });

    test('arac kutusundaki her blok katalogda tanimli', () {
      final katalog = File('${Directory('assets/mblock').path}'
              '/mblock_bloklari.js')
          .readAsStringSync();
      for (final adim in adimlar) {
        for (final id in adim.mblock!.bloklar) {
          expect(katalog.contains("id: '$id'"), isTrue,
              reason: '${adim.id}: "$id" katalogda yok — arac kutusunda '
                  'bos bir yer acilir.');
        }
      }
    });

    test('kurulum JSON\'u sayfanin bekledigi alanlari tasiyor', () {
      final json = jsonDecode(
        MBlockTezgahi.kurulumJson(adimlar.first.mblock!, 'de'),
      ) as Map<String, dynamic>;
      expect(json['dil'], 'de');
      expect(json['bloklar'], isA<List<dynamic>>());
      expect(json.containsKey('baslangic'), isTrue);
      expect(json['saltOkunur'], isFalse);
    });
  });
}
