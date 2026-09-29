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

    test('yuvaya takilan blok karsilastiriliyor', () {
      // "eger <dijital oku pin 2> ise" ile "eger <analog oku pin 0> ise"
      // ayni blok degil: fark yuvadaki blokta. Bu okunmazsa ders
      // yanlis cozumu dogru sayar.
      final dogru = yigin([
        const MBlockBlok(tip: 'dev_eger', girdiler: {
          'KOSUL': MBlockBlok(tip: 'dev_dijital_oku', alanlar: {'PIN': '2'}),
        }),
      ]);
      const beklenen = [
        MBlockBeklenen('dev_eger', girdiler: {
          'KOSUL':
              MBlockBeklenen('dev_dijital_oku', alanlar: {'PIN': '2'}),
        }),
      ];
      expect(mblockCozumDogruMu(dogru, beklenen), isTrue);

      final yanlisPin = yigin([
        const MBlockBlok(tip: 'dev_eger', girdiler: {
          'KOSUL': MBlockBlok(tip: 'dev_dijital_oku', alanlar: {'PIN': '7'}),
        }),
      ]);
      expect(mblockCozumDogruMu(yanlisPin, beklenen), isFalse);

      final yuvaBos = yigin([const MBlockBlok(tip: 'dev_eger')]);
      expect(mblockCozumDogruMu(yuvaBos, beklenen), isFalse,
          reason: 'Bos kosul yuvasi dogru sayilamaz');
    });

    test('ic ice yuvalar okunuyor (degil blogu)', () {
      final kurulan = yigin([
        const MBlockBlok(tip: 'dev_eger', girdiler: {
          'KOSUL': MBlockBlok(tip: 'dev_degil', girdiler: {
            'KOSUL':
                MBlockBlok(tip: 'dev_dijital_oku', alanlar: {'PIN': '2'}),
          }),
        }),
      ]);
      expect(
        mblockCozumDogruMu(kurulan, const [
          MBlockBeklenen('dev_eger', girdiler: {
            'KOSUL': MBlockBeklenen('dev_degil', girdiler: {
              'KOSUL':
                  MBlockBeklenen('dev_dijital_oku', alanlar: {'PIN': '2'}),
            }),
          }),
        ]),
        isTrue,
      );

      // "değil" unutulursa program tersini yapar; dogru sayilmamali.
      expect(
        mblockCozumDogruMu(kurulan, const [
          MBlockBeklenen('dev_eger', girdiler: {
            'KOSUL':
                MBlockBeklenen('dev_dijital_oku', alanlar: {'PIN': '2'}),
          }),
        ]),
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
                    'tip': 'dev_eger',
                    'alanlar': {},
                    'girdiler': {
                      'KOSUL': {
                        'tip': 'dev_dijital_oku',
                        'alanlar': {'PIN': 2}
                      }
                    },
                    'icerik': [
                      {
                        'tip': 'dev_dijital_yaz',
                        'alanlar': {'PIN': 9, 'SEVIYE': 'HIGH'}
                      }
                    ]
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
      expect(
        yiginlar.first[1].icerik.first.girdiler['KOSUL']!.alanlar['PIN'],
        '2',
      );
      expect(
        yiginlar.first[1].icerik.first.icerik.first.alanlar['PIN'],
        '9',
      );
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
      final csp = RegExp(r'Content-Security-Policy"\s*\n?\s*content="([^"]*)"')
          .firstMatch(html)
          ?.group(1);
      expect(csp, isNotNull,
          reason: 'Icerik Guvenligi Politikasi yok — sayfa uzaktan bir sey '
              'cekebilir.');

      // ASIL KORUMA BUNLAR. Politikada `'self'` YAZMIYORUZ: sayfa
      // file:// uzerinden aciliyor ve WKWebView'da file: belgesinin
      // kaynagi opak sayildigi icin `'self'` kendi betiklerimizi bile
      // engelliyor (iOS'ta tezgah bos aciliyordu). Semalari acikca
      // yazmak ayni korumayi veriyor, asagidaki iki kural da onu
      // sabitliyor.
      expect(csp!.contains('http'), isFalse,
          reason: 'Politikada http/https gecmemeli — uzaktan kaynak '
              'cekilebilir hale gelir.');
      expect(csp.contains("connect-src 'none'"), isTrue,
          reason: 'Ag istekleri kapali olmali.');
      expect(csp.contains("default-src 'none'"), isTrue,
          reason: 'Izin verilmeyen her sey kapali kalmali.');

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
        'FF8C1A', // Degiskenler
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

  group('katlanir palet', () {
    // GERCEK OLAY: "Bubbles sesini bitene kadar cal" gibi uzun yazili
    // bir blok paletteyken palet o blok kadar genisliyor, 362 piksellik
    // tezgahin 256 pikselini kapliyordu. Cocugun kurdugu kodun yarisi
    // sagdan tasiyor, bir kismi paletin altinda kaliyordu.
    //
    // Cozum gercek tarayicida (Chromium, 362x300) denendi: surukleme
    // BASLARKEN kod gizliyse palet cekiliyor, kod tam genislige
    // yayiliyor, blok yine yigina takilabiliyor. Kisa kodlarda palet
    // hic kapanmiyor.
    late String js;
    late String html;
    setUpAll(() {
      js = File('assets/mblock/tezgah.js').readAsStringSync();
      html = File('assets/mblock/index.html').readAsStringSync();
    });

    test('palet genisligi tavanli', () {
      expect(js.contains('PALET_TAVANI'), isTrue);
      expect(js.contains('paletiSinirla('), isTrue);
      // Okunaklilik icin bir taban var; palet sonsuza kadar kuculmez.
      expect(js.contains('PALET_OLCEK_TABANI'), isTrue);
    });

    test('surukleme basinda kod gizliyse palet cekiliyor', () {
      expect(js.contains("olay.type === 'drag'"), isTrue,
          reason: 'Surukleme olayi dinlenmiyor.');
      expect(js.contains('suruklemeBasladi(olay.blockId)'), isTrue);
      expect(js.contains('kodGizli('), isTrue);
      // Surukleme olayi bir UI olayi; filtre ONCE gelirse hic gorulmez.
      final surukleme = js.indexOf("olay.type === 'drag'");
      final filtre = js.indexOf('if (olay && olay.isUiEvent) return;');
      expect(surukleme, lessThan(filtre),
          reason: 'UI olaylari surukleme dinlenmeden once eleniyor.');
    });

    test('parmagin altindaki blok oynatilmiyor', () {
      expect(js.contains('function koduSolaYasla(solKenar, haricId)'),
          isTrue);
      expect(js.contains('b.id !== haricId'), isTrue);
    });

    test('palete geri donus sekmesi dort dilde ve paletin ustunde', () {
      for (final yazi in const [
        "tr: 'Bloklar'",
        "en: 'Blocks'",
        "de: 'Blöcke'",
        "es: 'Bloques'",
      ]) {
        expect(js.contains(yazi), isTrue, reason: 'eksik: $yazi');
      }
      expect(html.contains('id="paletSekmesi"'), isTrue);
      expect(html.contains('id="paletKapat"'), isTrue);
      // Blockly paleti z-index 20'ye koyuyor; dugmeler altta kalirsa
      // gorunmez. Ilk denemede tam olarak bu oldu.
      expect(html.contains('z-index: 30'), isTrue);
    });

    test('temizleyince palet geri aciliyor', () {
      final bas = js.indexOf('temizle: function');
      final govde = js.substring(bas, js.indexOf('},', bas));
      expect(govde.contains('paletiAc()'), isTrue,
          reason: 'Tahta bosken palet kapali kalirsa cocuk blok bulamaz.');
    });
  });

  group('derslerin tezgah ayarlari', () {
    final adimlar = <BlockBuilderStep>[
      for (final ders in MBlockLessonsData.allLessons)
        for (final adim in ders.steps)
          if (adim is BlockBuilderStep && adim.mblock != null) adim,
    ];

    test('mBlock kursunun butun blok kurma adimlari tezgaha bagli', () {
      // Yarisinin gercek tezgahta, yarisinin kart dizme ekraninda
      // olmasi cocuk icin iki ayri oyun demek olurdu.
      final tumu = <BlockBuilderStep>[
        for (final ders in MBlockLessonsData.allLessons)
          for (final adim in ders.steps)
            if (adim is BlockBuilderStep) adim,
      ];
      expect(adimlar.length, tumu.length,
          reason: 'Tezgaha baglanmamis blok kurma adimi var: '
              '${tumu.where((a) => a.mblock == null).map((a) => a.id)}');
      expect(adimlar.length, greaterThanOrEqualTo(6));
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
        MBlockTezgahi.kurulumJson(adimlar.first.mblock!, 'de', olcek: 0.55),
      ) as Map<String, dynamic>;
      expect(json['dil'], 'de');
      expect(json['bloklar'], isA<List<dynamic>>());
      expect(json.containsKey('baslangic'), isTrue);
      expect(json['saltOkunur'], isFalse);
      expect(json['olcek'], 0.55);
    });
  });

  group('kucuk ekran', () {
    test('dar telefonda bloklar kuculuyor', () {
      // Tek olcek iki sekilde de yaniliyor: buyuk olcekte arac kutusu
      // calisma alanini yiyor, cok kucukte bloklar cocuk parmagina
      // gore ufaliyor.
      expect(MBlockTezgahi.olcekIcin(320),
          lessThan(MBlockTezgahi.olcekIcin(430)));
      expect(MBlockTezgahi.olcekIcin(320), greaterThanOrEqualTo(0.5),
          reason: 'Bloklar cocuk parmagina gore fazla kuculmemeli.');
      expect(MBlockTezgahi.olcekIcin(430), lessThanOrEqualTo(0.75));
    });

    test('tezgah yuksekligi ekrana uyuyor ama sinirlari var', () {
      // Sabit 420 piksel kucuk telefonda ekranin neredeyse tamamini
      // kapliyor, hedef ve dugmeler disarida kaliyordu.
      final kucuk = MBlockTezgahi.yukseklikIcin(667); // iPhone SE
      final buyuk = MBlockTezgahi.yukseklikIcin(956); // Pro Max
      expect(kucuk, lessThan(buyuk));
      expect(kucuk, greaterThanOrEqualTo(300),
          reason: 'Cok kisa bir tezgahta blok kurulamaz.');
      expect(kucuk, lessThan(667 * 0.55),
          reason: 'Tezgah kucuk ekranda hedefe ve dugmelere yer '
              'birakmali.');
      expect(buyuk, lessThanOrEqualTo(520));
    });
  });

  group('sayfa kucuk ekrani gozetiyor', () {
    final tezgahJs =
        File('assets/mblock/tezgah.js').readAsStringSync();

    test('arac kutusunun sabit genisligi ve olcegi geciliyor', () {
      // scratch-blocks arac kutusu, bloklar ne kadar dar olursa olsun
      // 250 piksel donduruyor ve kendi sabit olcegini kullaniyor.
      // Ikisi de gecilmezse 320 piksellik telefonda calisma alanina
      // 70 piksel kaliyor.
      expect(tezgahJs.contains('getFlyoutScale'), isTrue);
      expect(tezgahJs.contains('kutu.getWidth = function'), isTrue);
    });

    test('dar ekranda yakinlastirma ve cop kutusu kapaniyor', () {
      expect(tezgahJs.contains('trashcan: dar'), isTrue);
      expect(tezgahJs.contains('controls: !dar'), isTrue);
    });

    test('arac kutusunun altina kacan blok geri itiliyor', () {
      // GERCEK OLAY: cocuk blogu arac kutusunun hemen sagina birakiyor
      // ve blogun sol yarisi kutunun arkasinda kaliyordu. Silinmis de
      // degil, tasinmis da degil — oldugu yerde yarisi gorunmez. Bir
      // cocuk icin bu "blogum kayboldu" demek. Blockly bunu
      // kendiliginden yapmiyor: arac kutusu calisma alaninin USTUNE
      // ciziliyor.
      expect(tezgahJs.contains('bloklariGorunurYap'), isTrue);
      expect(tezgahJs.contains("olay.type === 'move'"), isTrue,
          reason: 'Duzeltme her tasima sonrasi calismali.');
    });

    test('ayirac cizgisi olculerek konuluyor', () {
      // Genislik sabit degil: blok yazilari dile gore uzuyor.
      expect(tezgahJs.contains('ayiraciYerlestir'), isTrue);
      final html = File('assets/mblock/index.html').readAsStringSync();
      expect(html.contains("id=\"ayirac\""), isTrue);
      expect(html.contains('fill-opacity: 1'), isTrue,
          reason: 'Arac kutusunun arkasi yari saydam kalirsa ortada '
              'puslu bir serit goruluyor.');
    });
  });
}
