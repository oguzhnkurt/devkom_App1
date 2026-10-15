// mBlock: kod kartta / sahnede GERCEKTEN calisiyor; ipucu; yedek tezgah.
//
// Bu dosya kilitliyor:
//  * Sanal Uno yorumlayicisi: blink dongusu LED'i yakip sonduruyor (1 sn
//    arayla), PWM parlakligi potansiyometreden map ile, buton okumasi,
//    servo ve seri port; sonsuz dongu butceye takiliyor; Durdur bekleyen
//    zamanlayiciyi kesiyor.
//  * Kukla programlari Scratch yorumlayicisina dogru ceviriliyor.
//  * Ilk fark (ipucu) dogru yeri gosteriyor.
//  * Dart blok tablosu JS katalogundan ayrismamis.
//  * Her mBlock blok kurma adiminin yedek verisi (availableBlocks +
//    correctSequence) tam.
//  * Ekran: WebView yoksa yedek tezgah; Kontrol et programi calistiriyor;
//    3 yanlista ipucu, 5 yanlista "Cozumu goster" (XP'siz).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/devi_tepkisi.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_blok_adimi.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_tezgahi.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/courses/sahne/mblock_sahnesi.dart';
import 'package:devkom_app/courses/yurutme/blok_anlami.dart';
import 'package:devkom_app/courses/yurutme/blok_yorumlayici.dart';
import 'package:devkom_app/courses/yurutme/mblock_blok_adlari.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/courses/yurutme/mblock_kukla.dart';
import 'package:devkom_app/courses/yurutme/mblock_uno.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';

const _blink = [
  MBlockBlok(tip: 'dev_kart_acilis'),
  MBlockBlok(tip: 'dev_surekli', icerik: [
    MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'PIN': '9', 'SEVIYE': 'HIGH'}),
    MBlockBlok(tip: 'dev_bekle', alanlar: {'SANIYE': '1'}),
    MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'PIN': '9', 'SEVIYE': 'LOW'}),
    MBlockBlok(tip: 'dev_bekle', alanlar: {'SANIYE': '1'}),
  ]),
];

final _mblockAdimlari = CourseModules.allLessons('mblock')
    .expand((l) => l.steps)
    .whereType<BlockBuilderStep>()
    .where((s) => s.mblock != null)
    .toList();

BlockBuilderStep _adim(String id) => _mblockAdimlari.firstWhere((s) => s.id == id);

/// Sahte saat: hicbir sey gercekten beklemiyor.
class _Saat {
  Duration simdi = Duration.zero;
  Future<void> uyu(Duration d) async => simdi += d;
}

void main() {
  group('sanal Uno', () {
    test('blink: LED pin 9 bir saniye arayla yanip sonuyor; butce', () async {
      final kart = UnoKarti();
      final saat = _Saat();
      final iz = <(Duration, double)>[];
      kart.addListener(() => iz.add((saat.simdi, kart.parlaklik(9))));
      final y = UnoYorumlayici(kart: kart, uyku: saat.uyu, butce: 60);
      final bitis = await y.calistir([_blink]);
      expect(bitis, UnoBitis.butceBitti);
      final degerler = iz.map((e) => e.$2).toList();
      // Sifirlama (0) sonra 1,0,1,0...
      final yanma = degerler.skipWhile((v) => v == 0).toList();
      expect(yanma.length, greaterThanOrEqualTo(6));
      for (var i = 0; i < yanma.length; i++) {
        expect(yanma[i], i.isEven ? 1.0 : 0.0, reason: 'adim $i');
      }
      // Yanma ile sonme arasi 1 sn.
      final yan = iz.firstWhere((e) => e.$2 == 1);
      final son = iz.firstWhere((e) => e.$1 > yan.$1 && e.$2 == 0);
      expect(son.$1 - yan.$1, const Duration(seconds: 1));
    });

    test('PWM: potansiyometre map ile parlakliga donusuyor', () async {
      final adim = _adim('m3_2_build1');
      final program = [mblockCozumProgrami(adim.mblock!.cozum, 'tr')];
      for (final (pot, beklenen) in [(1023, 255), (512, 127), (0, 0)]) {
        final kart = UnoKarti()..pot = pot;
        await UnoYorumlayici(kart: kart, uyku: _Saat().uyu, butce: 40)
            .calistir(program);
        expect(kart.pwm[5], beklenen, reason: 'pot $pot');
        expect(kart.parlaklik(5), closeTo(beklenen / 255, 1e-9));
      }
      expect(UnoYorumlayici.harita(512, 0, 1023, 0, 255), 127);
    });

    test('buton: dijital oku pin 2 LED pin 9u yonetiyor', () async {
      final adim = _adim('m3_1_build1');
      final program = [mblockCozumProgrami(adim.mblock!.cozum, 'tr')];
      final kart = UnoKarti();
      final p = UnoYorumlayici.parcalar(program);
      expect(p.buton, isTrue);
      expect(p.ledler, [9]);

      kart.butonBasili = true;
      await UnoYorumlayici(kart: kart, uyku: _Saat().uyu, butce: 30)
          .calistir(program);
      expect(kart.dijital[9], isTrue);

      kart.butonBasili = false;
      await UnoYorumlayici(kart: kart, uyku: _Saat().uyu, butce: 30)
          .calistir(program);
      expect(kart.dijital[9], isFalse);
    });

    test('servo, seri port, degil ve baslangicsiz program', () async {
      final kart = UnoKarti()..mesafe = 42;
      await UnoYorumlayici(kart: kart, uyku: _Saat().uyu).calistir([
        const [
          MBlockBlok(tip: 'dev_kart_acilis'),
          MBlockBlok(tip: 'dev_servo', alanlar: {'PIN': '9', 'ACI': '200'}),
          MBlockBlok(
              tip: 'dev_seri_yaz',
              girdiler: {'METIN': MBlockBlok(tip: 'dev_mesafe')}),
          MBlockBlok(tip: 'dev_eger', girdiler: {
            'KOSUL': MBlockBlok(
                tip: 'dev_degil',
                girdiler: {
                  'KOSUL':
                      MBlockBlok(tip: 'dev_dijital_oku', alanlar: {'PIN': '2'})
                }),
          }, icerik: [
            MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'PIN': '8', 'SEVIYE': 'HIGH'}),
          ]),
        ]
      ]);
      expect(kart.servo[9], 180, reason: 'aci 0-180 araliginda');
      expect(kart.seri, ['42']);
      expect(kart.dijital[UnoKarti.buzzerPini], isTrue);

      expect(
          await UnoYorumlayici(kart: kart, uyku: _Saat().uyu).calistir([
            const [MBlockBlok(tip: 'dev_dijital_yaz')]
          ]),
          UnoBitis.baslangicYok);
    });

    test('bos govdeli surekli dongu de butceye takiliyor', () async {
      final y = UnoYorumlayici(
          kart: UnoKarti(), uyku: _Saat().uyu, butce: 25);
      expect(
          await y.calistir([
            const [
              MBlockBlok(tip: 'dev_kart_acilis'),
              MBlockBlok(tip: 'dev_surekli'),
            ]
          ]),
          UnoBitis.butceBitti);
    });

    testWidgets('gercek zaman: yanar, 1 sn sonra soner; Durdur zamanlayiciyi kesiyor',
        (tester) async {
      final kart = UnoKarti();
      final y = UnoYorumlayici(kart: kart);
      UnoBitis? bitis;
      y.calistir([_blink]).then((b) => bitis = b);
      await tester.pump(const Duration(milliseconds: 100));
      expect(kart.parlaklik(9), 1);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(kart.parlaklik(9), 0);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(kart.parlaklik(9), 1);
      y.durdur();
      await tester.pump();
      expect(bitis, UnoBitis.durduruldu);
      // Asili zamanlayici kalmadi (kalsaydi test bitiste duserdi).
    });
  });

  group('kukla programi', () {
    test('Merhaba de + 50 adim: konusuyor ve yuruyor', () {
      final adim = _adim('m0_2_build1');
      final p = MBlockKuklaProgrami.cevir(
          [mblockCozumProgrami(adim.mblock!.cozum, 'en')], 'en');
      expect(p.bloklar.length, 3);
      expect(p.yaklasik, isFalse);
      final y = BlokYorumlayici(dil: 'en').yurut(p.bloklar);
      expect(y.sonSahne.x, 50);
      expect(BlokYorumlayici.anlamOf(p.bloklar[1]).komut, BlokKomutu.soyle);
      expect(p.bloklar[1].labelFor('en'), 'say Hello!');
    });

    test('10 kez 36 derece: kukla tam tur atip ayni yone bakiyor', () {
      final adim = _adim('m0_3_build1');
      final p = MBlockKuklaProgrami.cevir(
          [mblockCozumProgrami(adim.mblock!.cozum, 'tr')], 'tr');
      final y = BlokYorumlayici().yurut(p.bloklar);
      expect(y.sonSahne.yon, 90);
      expect(y.adimlar.where((a) => a.tekrarNo == 10), isNotEmpty);
    });

    test('her kukla cozumu cevriliyor ve calisiyor', () {
      for (final s in _mblockAdimlari
          .where((s) => !mblockKartProgramiMi(s.mblock!.cozum))) {
        final p = MBlockKuklaProgrami.cevir(
            [mblockCozumProgrami(s.mblock!.cozum, 'tr')], 'tr');
        expect(p.bos, isFalse, reason: s.id);
        expect(() => BlokYorumlayici().yurut(p.bloklar), returnsNormally);
      }
    });
  });

  group('ipucu: ilk fark', () {
    const cozum = [
      MBlockBeklenen('dev_kart_acilis'),
      MBlockBeklenen('dev_surekli', icerik: [
        MBlockBeklenen('dev_dijital_yaz', alanlar: {'PIN': '9'}),
        MBlockBeklenen('dev_bekle'),
      ]),
    ];

    test('farkli, eksik, fazla, deger, kopuk', () {
      MBlockFark? f(List<MBlockBlok> y) => mblockIlkFark([y], cozum);
      expect(
          f(const [
            MBlockBlok(tip: 'dev_kart_acilis'),
            MBlockBlok(tip: 'dev_surekli', icerik: [
              MBlockBlok(tip: 'dev_bekle'),
            ]),
          ]),
          isA<MBlockFark>()
              .having((x) => x.tur, 'tur', MBlockFarkTuru.farkliBlok)
              .having((x) => x.sira, 'sira', 3)
              .having((x) => x.beklenenTip, 'tip', 'dev_dijital_yaz'));
      expect(
          f(const [
            MBlockBlok(tip: 'dev_kart_acilis'),
            MBlockBlok(tip: 'dev_surekli', icerik: [
              MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'PIN': '9'}),
            ]),
          ])!
              .tur,
          MBlockFarkTuru.eksikBlok);
      expect(
          f(const [
            MBlockBlok(tip: 'dev_kart_acilis'),
            MBlockBlok(tip: 'dev_surekli', icerik: [
              MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'PIN': '13'}),
              MBlockBlok(tip: 'dev_bekle'),
            ]),
          ]),
          isA<MBlockFark>()
              .having((x) => x.tur, 'tur', MBlockFarkTuru.deger)
              .having((x) => x.sira, 'sira', 3));
      expect(
          f(const [
            MBlockBlok(tip: 'dev_kart_acilis'),
            MBlockBlok(tip: 'dev_surekli', icerik: [
              MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'PIN': '9'}),
              MBlockBlok(tip: 'dev_bekle'),
              MBlockBlok(tip: 'dev_bekle'),
            ]),
          ])!
              .tur,
          MBlockFarkTuru.fazlaBlok);
      expect(mblockIlkFark([const [MBlockBlok(tip: 'dev_kart_acilis')], const [MBlockBlok(tip: 'dev_bekle')]], cozum)!.tur,
          MBlockFarkTuru.cokYigin);
      expect(
          mblockIlkFark([mblockCozumProgrami(cozum, 'tr')], cozum), isNull);
    });

    test('ipucu metni dort dilde blogun adini soyluyor, degeri soylemiyor', () {
      const fark =
          MBlockFark(MBlockFarkTuru.farkliBlok, sira: 3, beklenenTip: 'dev_dijital_yaz');
      expect(MBlockBlokAdimiState.ipucuMetni(fark, 'tr'),
          '3. bloğa bak: orada "dijital ayarla pin … çıkış …" olmalı.');
      for (final l in ['en', 'de', 'es']) {
        final m = MBlockBlokAdimiState.ipucuMetni(fark, l);
        expect(m, contains('3'));
        expect(m, contains(mblockBlokAdi('dev_dijital_yaz', l)));
      }
    });
  });

  test('Dart blok tablosu JS katalogundaki etiketlerle ayni', () {
    final js = File('assets/mblock/mblock_bloklari.js').readAsStringSync();
    for (final e in mblockBlokTanimlari.entries) {
      expect(js, contains("id: '${e.key}'"), reason: e.key);
      final parca = js.substring(js.indexOf("id: '${e.key}'"));
      final blok = parca.substring(0, parca.indexOf('\n    }'));
      for (final l in ['tr', 'en', 'de', 'es']) {
        if (e.key == 'dev_de') continue; // yuva degeri de dile gore
        expect(blok, contains("$l: '${e.value.etiket[l]!.replaceAll("'", "\\'")}'"),
            reason: '${e.key} $l');
      }
    }
    final idler = RegExp(r"id: '(dev_\w+)'").allMatches(js).map((m) => m.group(1));
    expect(mblockBlokTanimlari.keys.toSet(), idler.toSet());
  });

  test('her mBlock blok kurma adiminin yedek verisi tam', () {
    expect(_mblockAdimlari.length, greaterThanOrEqualTo(11));
    for (final s in _mblockAdimlari) {
      expect(s.availableBlocks, isNotEmpty, reason: s.id);
      expect(s.correctSequence, isNotEmpty, reason: s.id);
      final ids = s.availableBlocks.map((b) => b.id).toSet();
      expect(ids.length, s.availableBlocks.length,
          reason: '${s.id}: kimlikler tekil');
      for (final id in s.correctSequence) {
        expect(ids, contains(id), reason: '${s.id}: $id');
      }
      // Cozum calisabilir bir program.
      final p = mblockCozumProgrami(s.mblock!.cozum, 'tr');
      expect(p.first.tip, s.mblock!.cozum.first.tip);
    }
  });

  group('ekran', () {
    final mblock = CoursesData.byId('mblock')!;
    late SettingsProvider ayar;

    setUpAll(() async {
      SoundService.configure(sound: false);
      SharedPreferences.setMockInitialValues({'language_code': 'tr'});
      ayar = SettingsProvider();
      await ayar.setLocale(const Locale('tr'));
    });

    Widget kabuk(Widget w) => ChangeNotifierProvider<SettingsProvider>.value(
          value: ayar,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: w,
              ),
            ),
          ),
        );

    testWidgets('WebView yoksa yedek tezgah (kart dizme) cikiyor',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final adim = _adim('m2_1_build1');
      bool? tamam;
      await tester.pumpWidget(kabuk(MBlockBlokAdimi(
        step: adim,
        ayar: adim.mblock!,
        course: mblock,
        isDark: false,
        onComplete: (c) => tamam = c,
      )));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('mblock_yedek')), findsOneWidget);
      expect(find.byType(BlockBuilderStepWidget), findsOneWidget);

      // Yedekte dogru dizi: adim tamamlaniyor, sahne cozumu calistiriyor.
      final palet = adim.availableBlocks;
      for (final id in adim.correctSequence) {
        final b = palet.firstWhere((x) => x.id == id);
        final f = find.text(b.labelFor('tr')).last;
        await tester.ensureVisible(f);
        await tester.tap(f);
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(tamam, isTrue);
      expect(find.byType(MBlockSahnesi), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      final s = tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
      expect(s.unoKarti.parlaklik(9), 1);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Kontrol et calistiriyor; 3 yanlista ipucu, 5te cozum (XP yok)',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      MBlockTezgahi.webviewsiz = true;
      addTearDown(() => MBlockTezgahi.webviewsiz = false);

      final adim = _adim('m2_2_build1');
      final sonuclar = <bool>[];
      await tester.pumpWidget(kabuk(MBlockBlokAdimi(
        step: adim,
        ayar: adim.mblock!,
        course: mblock,
        isDark: false,
        onComplete: sonuclar.add,
      )));
      await tester.pump();
      expect(find.byKey(const ValueKey('mblock_yedek')), findsNothing);
      expect(find.byKey(const ValueKey('mblock_kart_sahnesi')), findsOneWidget);
      final durum = tester.state<MBlockBlokAdimiState>(find.byType(MBlockBlokAdimi));

      // Yanlis: LED yalnizca yaniyor (sonmuyor). Yine de CALISIYOR.
      durum.durumVer(const [
        [
          MBlockBlok(tip: 'dev_kart_acilis'),
          MBlockBlok(tip: 'dev_dijital_yaz', alanlar: {'PIN': '9', 'SEVIYE': 'HIGH'}),
        ]
      ]);
      await tester.pump();
      final kontrol = find.byKey(const ValueKey('mblock_kontrol'));
      for (var i = 1; i <= 5; i++) {
        await tester.ensureVisible(kontrol);
        await tester.tap(kontrol);
        await tester.pump(const Duration(milliseconds: 100));
        final sahne = tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
        expect(sahne.unoKarti.parlaklik(9), 1, reason: 'deneme $i calisti');
        expect(find.byType(DeviTepkisi), findsOneWidget);
        expect(find.byKey(const ValueKey('mblock_ipucu')),
            i >= MBlockBlokAdimi.ipucuEsigi ? findsOneWidget : findsNothing);
        expect(find.byKey(const ValueKey('mblock_cozumu_goster')),
            i >= MBlockBlokAdimi.cozumEsigi ? findsOneWidget : findsNothing);
        await tester.pump(const Duration(milliseconds: 400));
      }
      // Ipucu: 2. blok "surekli tekrarla" olmali.
      expect(find.textContaining('2. bloğa bak'), findsOneWidget);
      expect(sonuclar, isEmpty);

      await tester.tap(find.byKey(const ValueKey('mblock_cozumu_goster')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(sonuclar, [false], reason: 'Cozum gosterilince XP yok.');
      expect(find.byKey(const ValueKey('mblock_cozum_karti')), findsOneWidget);
      final sahne = tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
      expect(sahne.calisiyor, isTrue, reason: 'Cozum sahnede calisiyor');
      expect(sahne.unoKarti.parlaklik(9), 1);
      await tester.pump(const Duration(milliseconds: 1100));
      expect(sahne.unoKarti.parlaklik(9), 0, reason: 'blink: 1 sn sonra soner');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('dogru kukla programi sahnede calisiyor', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 2000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      MBlockTezgahi.webviewsiz = true;
      addTearDown(() => MBlockTezgahi.webviewsiz = false);
      final adim = _adim('m0_2_build1');
      final sonuclar = <bool>[];
      await tester.pumpWidget(kabuk(MBlockBlokAdimi(
        step: adim,
        ayar: adim.mblock!,
        course: mblock,
        isDark: false,
        onComplete: sonuclar.add,
      )));
      await tester.pump();
      expect(find.byKey(const ValueKey('mblock_kukla_sahnesi')), findsOneWidget);
      tester
          .state<MBlockBlokAdimiState>(find.byType(MBlockBlokAdimi))
          .durumVer([mblockCozumProgrami(adim.mblock!.cozum, 'tr')]);
      await tester.pump();
      await tester.ensureVisible(find.byKey(const ValueKey('mblock_kontrol')));
      await tester.tap(find.byKey(const ValueKey('mblock_kontrol')));
      await tester.pump(const Duration(milliseconds: 700));
      expect(sonuclar, [true]);
      expect(find.text('Program doğru!'), findsOneWidget);
      expect(find.byType(DeviTepkisi), findsOneWidget);
      // "Merhaba!" balonu sahnede.
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.text('Merhaba!'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });

  test('Devi tepkisi: dort dilde, cesitli', () {
    for (final l in ['tr', 'en', 'de', 'es']) {
      expect(DeviTepkisi.butunSozler(l).length, 12, reason: l);
      final dogru = {
        for (var i = 0; i < 10; i++) DeviTepkisi.soz(DeviTepkiTuru.dogru, l, i)
      };
      expect(dogru.length, greaterThan(3));
    }
    expect(DeviTepkisi.soz(DeviTepkiTuru.tekrarDene, 'tr', 0),
        'Neredeyse! Bir daha dene');
  });
}
