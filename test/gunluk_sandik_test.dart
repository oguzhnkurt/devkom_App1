// Ana sayfanin gunluk sandigi: gunde bir odul, gune bagli jeton, gunun
// oyunu gun boyu ayni (Ekim 2026, uygulama sahibinin istegi).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/services/gunluk_sandik_deposu.dart';
import 'package:devkom_app/widgets/surpriz_sandik.dart';

const _anahtarlar = GunlukSandikDeposu.anahtarBekleyen;

void main() {
  group('GunlukSandikDeposu', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('odul gune bagli: 5, 6 ... 10 ve sabit', () {
      expect([for (var g = 1; g <= 8; g++) GunlukSandikDeposu.odul(g)],
          [5, 6, 7, 8, 9, 10, 10, 10]);
      expect(GunlukSandikDeposu.odul(0), 5);
    });

    test('gunde bir kez; ertesi gun seri artiyor, bir gun kacarsa sifirlaniyor',
        () async {
      final g1 = DateTime(2026, 10, 16, 9);
      var d = await GunlukSandikDeposu.oku(g1);
      expect(d.hazir, isTrue);
      expect(d.gun, 1);
      expect(d.odul, 5);

      final a = await GunlukSandikDeposu.talepEt(g1, oyunId: 'x');
      expect(a!.odul, 5);
      // Ayni gun (gece 23:59 dahil) ikinci talep yok.
      expect(
          await GunlukSandikDeposu.talepEt(
              DateTime(2026, 10, 16, 23, 59), oyunId: 'y'),
          isNull);
      d = await GunlukSandikDeposu.oku(DateTime(2026, 10, 16, 23, 59));
      expect(d.hazir, isFalse);
      expect(d.oyunId, 'x');
      expect(d.odul, 5);

      // Ertesi gun gece yarisindan hemen sonra: 2. gun, 6 jeton.
      final g2 = DateTime(2026, 10, 17, 0, 0, 5);
      d = await GunlukSandikDeposu.oku(g2);
      expect(d.hazir, isTrue);
      expect(d.gun, 2);
      expect((await GunlukSandikDeposu.talepEt(g2, oyunId: 'z'))!.odul, 6);

      // Bir gun atlandi: 1. gune donuyor.
      d = await GunlukSandikDeposu.oku(DateTime(2026, 10, 19, 12));
      expect(d.hazir, isTrue);
      expect(d.gun, 1);
      expect(d.odul, 5);
    });

    test('ay ve yil sinirinda seri devam ediyor', () async {
      await GunlukSandikDeposu.talepEt(DateTime(2026, 12, 31, 20), oyunId: 'a');
      final d = await GunlukSandikDeposu.oku(DateTime(2027, 1, 1, 8));
      expect(d.hazir, isTrue);
      expect(d.gun, 2);
    });

    test('saat geri alinirsa sandik yeniden acilmiyor', () async {
      await GunlukSandikDeposu.talepEt(DateTime(2026, 10, 16, 10), oyunId: 'a');
      final d = await GunlukSandikDeposu.oku(DateTime(2026, 10, 15, 10));
      expect(d.hazir, isFalse);
      expect(
          await GunlukSandikDeposu.talepEt(DateTime(2026, 10, 15, 10),
              oyunId: 'b'),
          isNull);
    });

    test('odul once bekleyene giriyor; gonderilince dusuyor, olmazsa kaliyor',
        () async {
      await GunlukSandikDeposu.talepEt(DateTime(2026, 10, 16), oyunId: 'a');
      final p = await SharedPreferences.getInstance();
      expect(p.getInt(_anahtarlar), 5);

      // Ag yok: kaybolmuyor.
      expect(await GunlukSandikDeposu.bekleyeniGonder((_) async => false), 0);
      expect(p.getInt(_anahtarlar), 5);
      // Hata da ayni.
      expect(
          await GunlukSandikDeposu.bekleyeniGonder(
              (_) async => throw Exception('ag')),
          0);
      expect(p.getInt(_anahtarlar), 5);

      final gidenler = <int>[];
      expect(
          await GunlukSandikDeposu.bekleyeniGonder((n) async {
            gidenler.add(n);
            return true;
          }),
          5);
      expect(p.getInt(_anahtarlar), 0);
      // Ikinci gonderim bir sey yollamiyor.
      await GunlukSandikDeposu.bekleyeniGonder((n) async {
        gidenler.add(n);
        return true;
      });
      expect(gidenler, [5]);
    });

    test('ayni anda iki gonderim tek odul', () async {
      await GunlukSandikDeposu.talepEt(DateTime(2026, 10, 16), oyunId: 'a');
      final gidenler = <int>[];
      Future<bool> gonder(int n) async {
        gidenler.add(n);
        await Future<void>.delayed(const Duration(milliseconds: 5));
        return true;
      }

      await Future.wait([
        GunlukSandikDeposu.bekleyeniGonder(gonder),
        GunlukSandikDeposu.bekleyeniGonder(gonder),
      ]);
      expect(gidenler, [5]);
    });
  });

  group('SurprizSandik gunluk odul', () {
    late DateTime simdi;
    late List<int> verilen;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      simdi = DateTime(2026, 10, 16, 10);
      verilen = [];
    });

    Widget sandik(
            {String lang = 'tr',
            Key? key,
            Size boy = const Size(390, 844),
            double yazi = 1,
            bool azalt = false}) =>
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
                size: boy,
                disableAnimations: azalt,
                textScaler: TextScaler.linear(yazi)),
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: SurprizSandik(
                  key: key,
                  lang: lang,
                  onOyna: (_) {},
                  reklamSorgusu: () async => false,
                  saat: () => simdi,
                  onOdul: (n) async {
                    verilen.add(n);
                    return true;
                  },
                ),
              ),
            ),
          ),
        );

    Future<void> kareler(WidgetTester t, int ms) async {
      for (var i = 0; i < ms; i += 50) {
        await t.pump(const Duration(milliseconds: 50));
      }
    }

    String oyunAdi(WidgetTester t) =>
        t.widget<Text>(find.byKey(const ValueKey('gunluk_sandik_oyun'))).data!;

    testWidgets('hazir -> ac -> odul bir kez, oyun gun boyu ayni, ertesi gun yine',
        (tester) async {
      await tester.pumpWidget(sandik());
      await kareler(tester, 200);
      expect(find.text('Günlük ödülün hazır!'), findsOneWidget);
      expect(find.text('🔥 1. gün'), findsOneWidget);
      expect(find.byKey(const ValueKey('gunluk_sandik_ac')), findsOneWidget);

      // Iki hizli dokunus: tek talep.
      await tester.tap(find.byKey(const ValueKey('gunluk_sandik')));
      await tester.tap(find.byKey(const ValueKey('gunluk_sandik')),
          warnIfMissed: false);
      await tester.pump();
      await kareler(tester, 900);
      // Acilirken jeton ucuyor.
      expect(find.byKey(const ValueKey('gunluk_sandik_ucan_jeton')),
          findsOneWidget);
      await kareler(tester, 6000);
      expect(find.byKey(const ValueKey('gunluk_sandik_oyna')), findsOneWidget);
      expect(find.text('🪙 +5 jeton'), findsOneWidget);
      expect(find.textContaining('Bugünkü ödülünü aldın'), findsOneWidget);
      expect(verilen, [5]);
      final oyun = oyunAdi(tester);

      // Acik sandiga dokunmak bir sey yapmiyor.
      await tester.tap(find.byKey(const ValueKey('gunluk_sandik')),
          warnIfMissed: false);
      await kareler(tester, 2000);
      expect(verilen, [5]);

      // Yeniden kurulum (uygulama yeniden acildi): ayni gun, ayni oyun.
      await tester.pumpWidget(sandik(key: UniqueKey()));
      await kareler(tester, 300);
      expect(find.text('Günlük ödülün hazır!'), findsNothing);
      expect(oyunAdi(tester), oyun);
      expect(find.text('🔥 1. gün'), findsOneWidget);
      simdi = DateTime(2026, 10, 16, 23, 30);
      await tester.pumpWidget(sandik(key: UniqueKey()));
      await kareler(tester, 300);
      expect(oyunAdi(tester), oyun);
      expect(verilen, [5]);

      // Ertesi gun: yine hazir, 2. gun, 6 jeton.
      simdi = DateTime(2026, 10, 17, 8);
      await tester.pumpWidget(sandik(key: UniqueKey()));
      await kareler(tester, 300);
      expect(find.text('Günlük ödülün hazır!'), findsOneWidget);
      expect(find.text('🔥 2. gün'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('gunluk_sandik_ac')));
      await kareler(tester, 7000);
      expect(verilen, [5, 6]);
      expect(find.text('🪙 +6 jeton'), findsOneWidget);

      // Iki gun atlandi: seri sifirlandi.
      simdi = DateTime(2026, 10, 20, 8);
      await tester.pumpWidget(sandik(key: UniqueKey()));
      await kareler(tester, 300);
      expect(find.text('🔥 1. gün'), findsOneWidget);
      expect(find.textContaining('Bugün +5 jeton'), findsOneWidget);
    });

    testWidgets('acikken gece yarisi gecince sandik kendiliginden hazir',
        (tester) async {
      simdi = DateTime(2026, 10, 16, 23, 59, 50);
      await tester.pumpWidget(sandik(azalt: true));
      await kareler(tester, 200);
      await tester.tap(find.byKey(const ValueKey('gunluk_sandik_ac')));
      await kareler(tester, 200);
      expect(find.byKey(const ValueKey('gunluk_sandik_oyna')), findsOneWidget);
      simdi = DateTime(2026, 10, 17, 0, 0, 2);
      await tester.pump(const Duration(seconds: 12));
      await kareler(tester, 200);
      expect(find.text('Günlük ödülün hazır!'), findsOneWidget);
      expect(find.text('🔥 2. gün'), findsOneWidget);
    });

    testWidgets('hareketi azalt: animasyonsuz, odul ve oyun hemen',
        (tester) async {
      await tester.pumpWidget(sandik(azalt: true, lang: 'en'));
      await kareler(tester, 200);
      expect(find.text('Your daily reward is ready!'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('gunluk_sandik_ac')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('gunluk_sandik_oyna')), findsOneWidget);
      expect(find.text('🪙 +5 coins'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 50));
      expect(verilen, [5]);
    });

    testWidgets('sunucu yazamazsa odul bekliyor, sonraki acilista gidiyor',
        (tester) async {
      var basarili = false;
      Widget w(Key k) => MaterialApp(
            home: Scaffold(
              body: SurprizSandik(
                key: k,
                lang: 'tr',
                onOyna: (_) {},
                reklamSorgusu: () async => false,
                saat: () => simdi,
                onOdul: (n) async {
                  if (basarili) verilen.add(n);
                  return basarili;
                },
              ),
            ),
          );
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(
              size: Size(390, 844), disableAnimations: true),
          child: w(UniqueKey())));
      await kareler(tester, 200);
      await tester.tap(find.byKey(const ValueKey('gunluk_sandik_ac')));
      await kareler(tester, 200);
      expect(verilen, isEmpty);
      final p = await SharedPreferences.getInstance();
      expect(p.getInt(GunlukSandikDeposu.anahtarBekleyen), 5);

      basarili = true;
      await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(
              size: Size(390, 844), disableAnimations: true),
          child: w(UniqueKey())));
      await kareler(tester, 200);
      expect(verilen, [5]);
      expect(p.getInt(GunlukSandikDeposu.anahtarBekleyen), 0);
    });

    for (final boy in const [Size(360, 640), Size(430, 932)]) {
      for (final lang in ['tr', 'en', 'de', 'es']) {
        testWidgets('tasma yok ${boy.width.toInt()} $lang yazi 1.3',
            (tester) async {
          tester.view.physicalSize = boy;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(sandik(lang: lang, boy: boy, yazi: 1.3));
          await kareler(tester, 300);
          expect(tester.takeException(), isNull);
          await tester.tap(find.byKey(const ValueKey('gunluk_sandik')));
          for (var i = 0; i < 70; i++) {
            await tester.pump(const Duration(milliseconds: 100));
            expect(tester.takeException(), isNull);
          }
          expect(find.byKey(const ValueKey('gunluk_sandik_oyna')),
              findsOneWidget);
        });
      }
    }
  });

  test('sandigi acmak icin reklam ya da satin alma yok, jeton rastgele degil',
      () {
    // Kaynak denetimi: sandik dosyasi reklam gostermiyor, odulu rastgele
    // uretmiyor (yalnizca oyun secimi rastgele).
    final kaynak = File('lib/widgets/surpriz_sandik.dart').readAsStringSync();
    expect(kaynak.contains('showRewarded'), isFalse);
    expect(kaynak.contains('ProGate.ensure'), isFalse);
    final depo = File('lib/services/gunluk_sandik_deposu.dart').readAsStringSync();
    expect(depo.contains('Random'), isFalse);
  });
}
