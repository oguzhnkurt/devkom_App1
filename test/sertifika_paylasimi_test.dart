// SERTIFIKAYI KAYDET / PAYLAS
//
// Kilitlenenler:
//  * Kapanis ekranindaki dugme dort secenegi (+ genel paylasim) dort dilde
//    gosteriyor.
//  * Her secenekten ONCE ebeveyn kapisi aciliyor; vazgecilirse platforma
//    hicbir sey gitmiyor (cocuk uygulamasi: dosya, galeri, sosyal ag).
//  * PDF gercek bir PDF (%PDF ile basliyor, icinde goruntu var), A4 yatay.
//  * Instagram 1080x1350, TikTok 1080x1920.
//  * Android'de Instagram/TikTok kanali dogru argumanlarla cagriliyor;
//    uygulama yoksa genel paylasim menusu aciliyor.
//  * Galeri izni yoksa aciklama + Ayarlar.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/tanitim/kurs_kapanis_ekrani.dart';
import 'package:devkom_app/courses/tanitim/sertifika_paylasimi.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';

final scratch = CoursesData.byId('scratch')!;
final hepsi = CourseModules.allLessons('scratch').map((l) => l.id).toSet();

SertifikaVerisi _veri([String lang = 'tr', String ad = 'Elif Şükrü']) =>
    SertifikaVerisi(
      course: scratch,
      ad: ad,
      tarih: DateTime(2026, 10, 15),
      dersSayisi: hepsi.length,
      lang: lang,
    );

/// Platformun sahtesi: ne cagrildiysa kaydediyor.
class _Sahte implements SertifikaPlatformu {
  _Sahte({this.android = true, this.izin = true, this.yuklu = true});

  @override
  final bool android;
  final bool izin;
  final bool yuklu;
  final cagrilar = <String>[];
  final paylasilan = <String>[];
  Uint8List? galeriye;
  late final Directory dizin =
      Directory.systemTemp.createTempSync('sertifika_test');

  @override
  Future<Directory> geciciDizin() async => dizin;

  @override
  Future<void> paylas(List<String> yollar, {String? metin, String? konu}) async {
    cagrilar.add('paylas');
    paylasilan.addAll(yollar);
  }

  @override
  Future<bool> galeriIzni() async {
    cagrilar.add('izin');
    return izin;
  }

  @override
  Future<void> galeriyeKaydet(Uint8List png, String ad) async {
    cagrilar.add('galeri:$ad');
    galeriye = png;
  }

  @override
  Future<void> ayarlariAc() async => cagrilar.add('ayarlar');

  @override
  Future<bool> uygulamayaGonder(String yol, List<String> paketler,
      {String? metin}) async {
    cagrilar.add('uygulama:${paketler.first}');
    return yuklu;
  }
}

Future<void> _kur(WidgetTester tester, {String lang = 'tr'}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'language_code': lang});
  final ayar = SettingsProvider();
  await ayar.setLocale(Locale(lang));
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: ayar,
    child: MaterialApp(
      locale: Locale(lang),
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('es')
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: KursKapanisEkrani(
        course: scratch,
        tamamlanan: hepsi,
        ad: 'Elif',
        tarih: DateTime(2026, 10, 15),
        tekrar: true,
      ),
    ),
  ));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _secenekleriAc(WidgetTester tester) async {
  final d = find.byKey(const ValueKey('kapanis_paylas'));
  await tester.scrollUntilVisible(d, 150,
      scrollable: find.byType(Scrollable).first);
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.tap(d);
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _sec(WidgetTester tester, SertifikaIslemi i) async {
  await tester.tap(find.byKey(ValueKey('sertifika_${i.name}')));
  for (var k = 0; k < 6; k++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _kapidanGec(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), '1984');
  await tester.tap(find.text('Devam'));
  await tester.pump();
}

/// Kapidan sonraki gercek isler (cizim, dosya) gercek zamanda bitsin.
Future<void> _isBitsin(WidgetTester tester, bool Function() bitti) async {
  for (var i = 0; i < 200 && !bitti(); i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// PNG'nin IHDR'sindan boyut.
Size _pngBoyutu(Uint8List b) {
  final d = ByteData.sublistView(b);
  expect(b.sublist(1, 4), utf8.encode('PNG'));
  return Size(d.getUint32(16).toDouble(), d.getUint32(20).toDouble());
}

void main() {
  setUpAll(() async {
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
  });
  tearDown(() =>
      SertifikaPaylasimi.platform = const VarsayilanSertifikaPlatformu());

  group('secenekler', () {
    const beklenen = {
      'tr': ['PDF olarak indir', "Instagram'da paylaş", "TikTok'ta paylaş",
        'Galeriye kaydet'],
      'en': ['Download as PDF', 'Share on Instagram', 'Share on TikTok',
        'Save to gallery'],
      'de': ['Als PDF herunterladen', 'Auf Instagram teilen',
        'Auf TikTok teilen', 'In der Galerie speichern'],
      'es': ['Descargar como PDF', 'Compartir en Instagram',
        'Compartir en TikTok', 'Guardar en la galería'],
    };
    for (final e in beklenen.entries) {
      testWidgets('dort secenek + genel paylasim (${e.key})', (tester) async {
        await _kur(tester, lang: e.key);
        await _secenekleriAc(tester);
        for (final i in SertifikaIslemi.values) {
          expect(find.byKey(ValueKey('sertifika_${i.name}')), findsOneWidget);
        }
        for (final m in e.value) {
          expect(find.text(m), findsOneWidget, reason: m);
        }
        expect(tester.takeException(), isNull);
      });
    }

    for (final i in SertifikaIslemi.values) {
      testWidgets('${i.name}: once ebeveyn kapisi; vazgecince hicbir sey yok',
          (tester) async {
        final p = _Sahte();
        SertifikaPaylasimi.platform = p;
        await _kur(tester);
        await _secenekleriAc(tester);
        await _sec(tester, i);
        expect(find.text('Bu bölüm ebeveynler için'), findsOneWidget,
            reason: 'Kapi acilmadan islem basladi.');
        expect(find.textContaining('çocuğunuzun adı'), findsOneWidget);
        await tester.tap(find.text('Vazgeç'));
        await tester.pump(const Duration(milliseconds: 300));
        await _isBitsin(tester, () => false);
        expect(p.cagrilar, isEmpty);
      });
    }
  });

  group('kapidan gecince', () {
    testWidgets('PDF: dosya paylasim menusune gidiyor', (tester) async {
      final p = _Sahte();
      SertifikaPaylasimi.platform = p;
      await _kur(tester);
      await _secenekleriAc(tester);
      await _sec(tester, SertifikaIslemi.pdf);
      await _kapidanGec(tester);
      await _isBitsin(tester, () => p.paylasilan.isNotEmpty);
      expect(p.paylasilan.single,
          endsWith('/DevEducation_Sertifika_Scratch_Elif.pdf'));
      final b = File(p.paylasilan.single).readAsBytesSync();
      expect(latin1.decode(b.sublist(0, 4)), '%PDF');
    });

    testWidgets('galeri: kaydedildi bildirimi', (tester) async {
      final p = _Sahte();
      SertifikaPaylasimi.platform = p;
      await _kur(tester);
      await _secenekleriAc(tester);
      await _sec(tester, SertifikaIslemi.galeri);
      await _kapidanGec(tester);
      await _isBitsin(tester, () => p.galeriye != null);
      await tester.pump(const Duration(milliseconds: 300));
      expect(p.cagrilar, ['izin', 'galeri:DevEducation_Sertifika_Scratch_Elif']);
      expect(_pngBoyutu(p.galeriye!), const Size(1684, 1190));
      expect(find.text('Sertifika galeriye kaydedildi.'), findsOneWidget);
    });

    testWidgets('galeri izni yok: aciklama ve Ayarlar', (tester) async {
      final p = _Sahte(izin: false);
      SertifikaPaylasimi.platform = p;
      await _kur(tester);
      await _secenekleriAc(tester);
      await _sec(tester, SertifikaIslemi.galeri);
      await _kapidanGec(tester);
      await _isBitsin(
          tester, () => find.byKey(const ValueKey('galeri_izni_yok')).evaluate().isNotEmpty);
      expect(find.byKey(const ValueKey('galeri_izni_yok')), findsOneWidget);
      await tester.tap(find.text('Ayarları aç'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(p.cagrilar, ['izin', 'ayarlar']);
    });

    testWidgets('Android: Instagram dogrudan, 4:5 gorsel', (tester) async {
      final p = _Sahte();
      SertifikaPaylasimi.platform = p;
      await _kur(tester);
      await _secenekleriAc(tester);
      await _sec(tester, SertifikaIslemi.instagram);
      await _kapidanGec(tester);
      await _isBitsin(tester, () => p.cagrilar.isNotEmpty);
      expect(p.cagrilar, ['uygulama:com.instagram.android']);
    });

    testWidgets('Android: TikTok yuklu degil -> genel paylasim + ipucu',
        (tester) async {
      final p = _Sahte(yuklu: false);
      SertifikaPaylasimi.platform = p;
      await _kur(tester);
      await _secenekleriAc(tester);
      await _sec(tester, SertifikaIslemi.tiktok);
      await _kapidanGec(tester);
      await _isBitsin(tester, () => p.paylasilan.isNotEmpty);
      await tester.pump(const Duration(milliseconds: 300));
      expect(p.cagrilar, ['uygulama:com.zhiliaoapp.musically', 'paylas']);
      expect(p.paylasilan.single, endsWith('_tiktok.png'));
      expect(find.textContaining('TikTok bu cihazda bulunamadı'),
          findsOneWidget);
    });

    testWidgets('iOS: once galeri, sonra paylasim menusu + ipucu',
        (tester) async {
      final p = _Sahte(android: false);
      SertifikaPaylasimi.platform = p;
      await _kur(tester);
      await _secenekleriAc(tester);
      await _sec(tester, SertifikaIslemi.instagram);
      await _kapidanGec(tester);
      await _isBitsin(tester, () => p.paylasilan.isNotEmpty);
      await tester.pump(const Duration(milliseconds: 300));
      expect(p.cagrilar, [
        'izin',
        'galeri:DevEducation_Sertifika_Scratch_Elif_instagram',
        'paylas'
      ]);
      expect(find.textContaining("Instagram'ı seç"), findsOneWidget);
    });
  });

  group('dosyalar', () {
    testWidgets('PDF: %PDF, goruntu var, A4 yatay', (tester) async {
      final b = (await tester.runAsync(() => SertifikaCizici.pdf(_veri())))!;
      final metin = latin1.decode(b);
      expect(metin.substring(0, 4), '%PDF');
      expect(metin, matches(RegExp(r'/Subtype\s*/Image')));
      // A4 yatay: 841.89 x 595.28 pt.
      expect(metin, matches(RegExp(r'/MediaBox\s*\[0 0 841\.8\d* 595\.2\d*\]')));
    });

    testWidgets('paylasim gorselleri: 1080x1350 ve 1080x1920',
        (tester) async {
      final insta = (await tester.runAsync(() =>
          SertifikaCizici.paylasimPng(_veri(), PaylasimBicimi.instagram)))!;
      final tiktok = (await tester.runAsync(() =>
          SertifikaCizici.paylasimPng(_veri('de'), PaylasimBicimi.tiktok)))!;
      expect(_pngBoyutu(insta), const Size(1080, 1350));
      expect(_pngBoyutu(tiktok), const Size(1080, 1920));
      expect(PaylasimBicimi.instagram.piksel, const Size(1080, 1350));
      expect(PaylasimBicimi.tiktok.piksel, const Size(1080, 1920));
    });

    test('dosya adi ASCII', () {
      expect(_veri('tr', 'Ayşe Gül Öztürk').dosyaAdi(),
          'DevEducation_Sertifika_Scratch_Ayse_Gul_Ozturk');
      expect(_veri('es', 'Íñigo').dosyaAdi('tiktok'),
          'DevEducation_Sertifika_Scratch_Inigo_tiktok');
      expect(SertifikaVerisi.asciiAd('Jürgen Groß'), 'Jurgen_Gross');
    });
  });

  group('varsayilan platform (kanallar taklit)', () {
    final mesajci =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() {
      mesajci.setMockMethodCallHandler(
          VarsayilanSertifikaPlatformu.kanal, null);
      mesajci.setMockMethodCallHandler(const MethodChannel('gal'), null);
      debugDefaultTargetPlatformOverride = null;
    });

    test('Android kanali: yol, paketler, tur', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      MethodCall? gelen;
      mesajci.setMockMethodCallHandler(VarsayilanSertifikaPlatformu.kanal,
          (c) async {
        gelen = c;
        return true;
      });
      final ok = await const VarsayilanSertifikaPlatformu()
          .uygulamayaGonder('/c/s.png', tiktokPaketleri, metin: 'x');
      expect(ok, isTrue);
      expect(gelen!.method, 'uygulamayaGonder');
      expect(gelen!.arguments, {
        'yol': '/c/s.png',
        'paketler': ['com.zhiliaoapp.musically', 'com.ss.android.ugc.trill'],
        'tur': 'image/png',
        'metin': 'x',
      });
    });

    test('iOS: Android kanali hic cagrilmiyor', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      var cagrildi = false;
      mesajci.setMockMethodCallHandler(VarsayilanSertifikaPlatformu.kanal,
          (c) async => cagrildi = true);
      expect(
          await const VarsayilanSertifikaPlatformu()
              .uygulamayaGonder('/c/s.png', instagramPaketleri),
          isFalse);
      expect(cagrildi, isFalse);
    });

    test('gal: izin yoksa isteniyor, sonra kaydediliyor', () async {
      final yontemler = <String>[];
      mesajci.setMockMethodCallHandler(const MethodChannel('gal'),
          (c) async {
        yontemler.add(c.method);
        return switch (c.method) {
          'hasAccess' => false,
          'requestAccess' => true,
          _ => null,
        };
      });
      const p = VarsayilanSertifikaPlatformu();
      expect(await p.galeriIzni(), isTrue);
      await p.galeriyeKaydet(Uint8List.fromList([1, 2, 3]), 'ad');
      expect(yontemler,
          ['hasAccess', 'requestAccess', 'requestAccess', 'putImageBytes']);
    });
  });
}
