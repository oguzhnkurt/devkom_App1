// mBLOCK ATOLYESI v2 — WebView yerine Scratch atolyesinin kategorili
// tezgahi, mBlock bloklariyla.
//
// Kilitlenenler:
//  * Kategori sekmesine dokununca palet o bolume kayiyor.
//  * Dokunarak ekleme; C bloguna (surekli tekrarla) blok giriyor; oval /
//    altigen blok imlecin ustundeki blogun yuvasina takiliyor.
//  * Pin listesi kucuk seciciyle, sayi tus takimiyla degisiyor.
//  * "when Arduino Uno starts up" programi sanal Uno'da pin 13 LED'ini
//    yakiyor (sahnedeki bayrakla da, alttaki dugmeyle de); yesil bayrak
//    programi Devi'yi yurutuyor.
//  * 360x640, 375x667, 390x844, 430x932 — yazi 1.0 ve 1.3 — tasma yok;
//    sayfa kisa (tezgah sinirli, kendi icinde kayiyor).
//  * Dart yuva tablosu JS katalogundaki yuva turleriyle ayni.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/sahne/kategorili_tezgah.dart';
import 'package:devkom_app/courses/sahne/mblock_sahnesi.dart';
import 'package:devkom_app/courses/screens/mblock_atolye_ekrani.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_atolye_tezgahi.dart';
import 'package:devkom_app/courses/yurutme/mblock_blok_adlari.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/courses/yurutme/mblock_kod.dart';
import 'package:devkom_app/courses/yurutme/mblock_yuvalari.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/ui/press_button.dart';
import 'package:devkom_app/widgets/mascot.dart';
import 'package:devkom_app/widgets/scratch_blok.dart';

final _mblock = CoursesData.byId('mblock')!;
late SettingsProvider _ayar;

Future<void> _nunito() async {
  final n = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    n.addFont(Future.value(File('assets/fonts/Nunito-$w.ttf')
        .readAsBytesSync()
        .buffer
        .asByteData()));
  }
  await n.load();
}

Future<void> _ac(WidgetTester tester,
    {Size boy = const Size(430, 932), double yazi = 1.0}) async {
  tester.view.physicalSize = boy * 3;
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = yazi;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: _ayar,
    child: MaterialApp(
      theme: ThemeData(fontFamily: 'Nunito'),
      home: MBlockAtolyeEkrani(course: _mblock),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
}

Future<void> _bekle(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

MBlockAtolyeEkraniState _ekran(WidgetTester tester) =>
    tester.state<MBlockAtolyeEkraniState>(find.byType(MBlockAtolyeEkrani));

MBlockAtolyeTezgahiState _tezgah(WidgetTester tester) =>
    tester.state<MBlockAtolyeTezgahiState>(find.byType(MBlockAtolyeTezgahi));

MBlockSahnesiState _sahne(WidgetTester tester) =>
    tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));

/// Kategori seridinde (yana kayan) sekmeye dokunur.
Future<void> _kategori(WidgetTester tester, ScratchKategori k) async {
  final f = find.byKey(ValueKey('palet_kategori_${k.name}'));
  final serit = find.descendant(
      of: find.byKey(const ValueKey('palet_kategori_seridi')),
      matching: find.byType(Scrollable));
  for (var i = 0; i < 18 && f.evaluate().isEmpty; i++) {
    await tester.drag(serit.first, Offset(i < 6 ? -150 : 150, 0));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.tap(f);
  await _bekle(tester, 700);
}

/// Paletteki blok (once kategorisine gidip) dokunarak eklenir.
Future<void> _ekle(WidgetTester tester, String tip) async {
  await _kategori(
      tester, MBlockKod.kategori(mblockBlokTanimlari[tip]!.kategori));
  final f = find.byKey(ValueKey('mblock_palet_$tip'));
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 200));
}

/// Kod alanindaki [sira]daki blogun [n]. dokunulabilir parcasina
/// (pin listesi, sayi ovali, yuva) dokunur.
Future<void> _parcayaDokun(WidgetTester tester, int sira, int n) async {
  final blok = find.byKey(ValueKey('ic_ice_blok_$sira'));
  final cizim = tester.widget<ScratchBlok>(
      find.descendant(of: blok, matching: find.byType(ScratchBlok)).first);
  final kutular =
      ScratchBlokOlcer.parcaKutulari(cizim.tanim, cizim.olcek, silme: true);
  final hedef = tester.getTopLeft(blok) + kutular[n].kutu.center;
  await tester.tapAt(hedef);
  // Alttan acilan secici yerine otursun.
  await _bekle(tester, 900);
}

String _program(WidgetTester tester) =>
    _tezgah(tester).program.map((y) => y.join(' ')).join(' | ');

void main() {
  setUpAll(() async {
    await _nunito();
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    _ayar = SettingsProvider();
    await _ayar.setLocale(const Locale('tr'));
  });

  testWidgets('kategori sekmesi paleti o bolume kaydiriyor', (tester) async {
    await _ac(tester);
    final kt = tester.state<KategoriliTezgahState>(find.byType(KategoriliTezgah));
    expect(kt.etkinKategori, ScratchKategori.olaylar);
    await _kategori(tester, ScratchKategori.mblockPin);
    expect(kt.etkinKategori, ScratchKategori.mblockPin);
    expect(kt.paletKaydirma.offset, greaterThan(0));
    expect(find.byKey(const ValueKey('mblock_palet_dev_dijital_yaz')),
        findsOneWidget);
    await _kategori(tester, ScratchKategori.hareket);
    expect(kt.etkinKategori, ScratchKategori.hareket);
    expect(find.byKey(const ValueKey('mblock_palet_dev_git')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _kapat(tester);
  });

  testWidgets(
      'dokunarak Uno programi: C blogunun icine, pin secici, sayi tus '
      'takimi; bayrak pin 13 LED\'ini yakiyor', (tester) async {
    await _ac(tester);
    final calistir = find.byKey(const ValueKey('mblock_atolye_calistir'));
    expect(tester.widget<PressButton>(calistir).onPressed, isNull,
        reason: 'bos tahtada calistir pasif');

    await _ekle(tester, 'dev_kart_acilis');
    await _ekle(tester, 'dev_surekli');
    await _ekle(tester, 'dev_dijital_yaz');
    await _ekle(tester, 'dev_bekle');
    // surekli tekrarla'nin ICINE girdi (imlec agizda kaldi).
    expect(_program(tester),
        'dev_kart_acilis dev_surekli[dev_dijital_yaz{PIN: 9, SEVIYE: HIGH}, '
        'dev_bekle{SANIYE: 1}]');
    expect(find.byKey(const ValueKey('ic_ice_agiz_2')), findsNothing);

    // Pin listesi (dijital ayarla, 1. parca): kucuk secici -> 13.
    await _parcayaDokun(tester, 2, 0);
    expect(find.byKey(const ValueKey('mblock_secenek_13')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('mblock_secenek_13')));
    await tester.pumpAndSettle();
    // Seviye listesi: yuksek / dusuk.
    await _parcayaDokun(tester, 2, 1);
    expect(find.text('düşük'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('mblock_secenek_HIGH')));
    await tester.pumpAndSettle();
    // Bekle: sayi tus takimi 1 -> 2.
    await _parcayaDokun(tester, 3, 0);
    await tester.tap(find.byKey(const ValueKey('sayi_tus_2')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('sayi_tamam')));
    await tester.pumpAndSettle();
    expect(_program(tester),
        'dev_kart_acilis dev_surekli[dev_dijital_yaz{PIN: 13, SEVIYE: HIGH}, '
        'dev_bekle{SANIYE: 2}]');

    // Sahne Uno karti oldu; sahnedeki bayrak calistiriyor.
    expect(find.byKey(const ValueKey('mblock_kart_sahnesi')), findsOneWidget);
    final bayrak = find.byKey(const ValueKey('mblock_sahne_bayragi'));
    await tester.ensureVisible(bayrak);
    await tester.pump();
    await tester.tap(bayrak);
    var yandi = false;
    for (var i = 0; i < 20 && !yandi; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      yandi = _sahne(tester).unoKarti.dijital[13] == true;
    }
    expect(yandi, isTrue, reason: 'pin 13 LED yanmadi');
    expect(_ekran(tester).calisiyor, isTrue);
    expect(tester.widget<PressButton>(calistir).label, 'Durdur');

    // Alttaki dugme durduruyor.
    await tester.ensureVisible(calistir);
    await tester.pump();
    await tester.tap(calistir);
    await _bekle(tester, 400);
    expect(_ekran(tester).calisiyor, isFalse);
    expect(tester.widget<PressButton>(calistir).label, 'Çalıştır');

    // Alttaki dugme de calistiriyor.
    await tester.tap(calistir);
    await _bekle(tester, 200);
    expect(_sahne(tester).calisiyor, isTrue);
    _sahne(tester).durdur();
    await _bekle(tester, 300);
    expect(tester.takeException(), isNull);
    await _kapat(tester);
  });

  testWidgets('eger: altigen blok yuvaya takiliyor, takili blogun pini '
      'degisiyor, dokununca cikiyor', (tester) async {
    await _ac(tester);
    await _ekle(tester, 'dev_kart_acilis');
    await _ekle(tester, 'dev_surekli');
    await _ekle(tester, 'dev_eger');
    // Imlec "eger"in agzinda: dijital oku bir USTTEKI blogun (eger)
    // kosul yuvasina takiliyor.
    await _ekle(tester, 'dev_dijital_oku');
    expect(_program(tester),
        'dev_kart_acilis dev_surekli[dev_eger]');
    final eger = _tezgah(tester).program.first[1].icerik.first;
    expect(eger.girdiler['KOSUL']?.tip, 'dev_dijital_oku');

    // Takili blogun pin listesi (eger: 0 = takili blok, 1 = onun pini).
    await _parcayaDokun(tester, 2, 1);
    await tester.tap(find.byKey(const ValueKey('mblock_secenek_7')));
    await tester.pumpAndSettle();
    expect(_tezgah(tester).program.first[1].icerik.first.girdiler['KOSUL']
        ?.alanlar['PIN'], '7');

    // Agza bir blok: dijital ayarla eger'in ICINE.
    await _ekle(tester, 'dev_dijital_yaz');
    expect(_tezgah(tester).program.first[1].icerik.first.icerik.single.tip,
        'dev_dijital_yaz');

    // Takili bloga dokun: cikiyor; bos altigene dokun: kosul secici.
    await _parcayaDokun(tester, 2, 0);
    expect(_tezgah(tester).program.first[1].icerik.first.girdiler, isEmpty);
    await _parcayaDokun(tester, 2, 0);
    await tester.tap(find.byKey(const ValueKey('mblock_kosul_dev_degil')));
    await tester.pumpAndSettle();
    expect(_tezgah(tester).program.first[1].icerik.first.girdiler['KOSUL']
        ?.tip, 'dev_degil');

    // Oval blok tahtada yeri olmayinca ipucu veriyor, eklenmiyor.
    _tezgah(tester).temizle();
    await tester.pump();
    await _ekle(tester, 'dev_mesafe');
    expect(_tezgah(tester).blokSayisi, 0);
    expect(find.byKey(const ValueKey('mblock_tezgah_ipucu')), findsOneWidget);
    await _kapat(tester);
  });

  testWidgets('yesil bayrak programi Devi\'yi yurutuyor; x blogu cikariyor',
      (tester) async {
    await _ac(tester);
    await _ekle(tester, 'dev_bayrak');
    await _ekle(tester, 'dev_tekrarla');
    await _ekle(tester, 'dev_git');
    expect(_program(tester),
        'dev_bayrak dev_tekrarla{KERE: 10}[dev_git{ADIM: 10}]');
    expect(find.byKey(const ValueKey('mblock_kukla_sahnesi')), findsOneWidget);
    final devi = find.descendant(
        of: find.byKey(const ValueKey('mblock_kukla_sahnesi')),
        matching: find.byType(Mascot));
    final bayrak = find.byKey(const ValueKey('mblock_sahne_bayragi'));
    await tester.ensureVisible(bayrak);
    await tester.pump();
    await tester.tap(bayrak);
    await _bekle(tester, 900);
    final once = tester.getCenter(devi.first).dx;
    await _bekle(tester, 2500);
    expect(_sahne(tester).calisiyor, isTrue);
    expect(tester.getCenter(devi.first).dx, greaterThan(once + 20),
        reason: 'Devi yurumedi');
    await tester.tap(find.byKey(const ValueKey('mblock_sahne_dur')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_sahne(tester).calisiyor, isFalse);

    // git blogunun sagindaki x: blok cikiyor.
    final git = find.byKey(const ValueKey('ic_ice_blok_2'));
    await tester.ensureVisible(git);
    await tester.pump();
    await tester.tapAt(tester.getTopRight(git) + const Offset(-8, 12));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_program(tester), 'dev_bayrak dev_tekrarla{KERE: 10}');
    await _kapat(tester);
  });

  group('tasma yok, sayfa kisa', () {
    final park = CourseModules.allLessons('mblock')
        .expand((l) => l.steps)
        .whereType<BlockBuilderStep>()
        .firstWhere((s) => s.id == 'm4_1_build1');
    for (final boy in const [
      Size(360, 640),
      Size(375, 667),
      Size(390, 844),
      Size(430, 932),
    ]) {
      for (final yazi in const [1.0, 1.3]) {
        testWidgets('${boy.width.toInt()}x${boy.height.toInt()} x$yazi',
            (tester) async {
          await _ac(tester, boy: boy, yazi: yazi);
          expect(tester.takeException(), isNull);
          _ekran(tester)
              .durumVer([mblockCozumProgrami(park.mblock!.cozum, 'tr')]);
          await tester.pump();
          await _bekle(tester, 300);
          expect(tester.takeException(), isNull);
          final kart = tester.getRect(find.byType(KategoriliTezgah));
          expect(kart.right, lessThanOrEqualTo(boy.width));
          expect(kart.height, inInclusiveRange(319.5, 560.5));
          final sayfa = tester
              .state<ScrollableState>(find.descendant(
                  of: find.byKey(const ValueKey('mblock_atolye_sayfasi')),
                  matching: find.byType(Scrollable)).first)
              .position;
          expect(sayfa.maxScrollExtent, lessThan(boy.height * 0.5),
              reason: 'sayfa cok uzun');
          if (boy.height >= 900 && yazi == 1.0) {
            expect(sayfa.maxScrollExtent, lessThan(60),
                reason: '430x932: sahne + tezgah + dugmeler neredeyse '
                    'tek ekranda');
          }
          // Calistir: yine tasma yok.
          _ekran(tester).calistir();
          await _bekle(tester, 600);
          expect(tester.takeException(), isNull);
          _sahne(tester).durdur();
          await _bekle(tester, 300);
          await _kapat(tester);
        });
      }
    }
  });

  test('yuva tablosu JS katalogundaki yuva turleriyle ayni', () {
    final js = File('assets/mblock/mblock_bloklari.js').readAsStringSync();
    final bloklar = RegExp(r"id: '(dev_\w+)'").allMatches(js).toList();
    expect(bloklar.length, mblockBlokTanimlari.length);
    for (var i = 0; i < bloklar.length; i++) {
      final id = bloklar[i].group(1)!;
      final bitis = i + 1 < bloklar.length ? bloklar[i + 1].start : js.length;
      final govde = js.substring(bloklar[i].start, bitis);
      final jsYuvalar = [
        for (final m in RegExp(r"yuva\('(\w+)', '(\w+)'").allMatches(govde))
          '${m.group(1)}:${m.group(2)}'
      ];
      final dart = [
        for (final y in mblockYuvalari[id]!) '${y.ad}:${y.tur.name}'
      ];
      expect(dart, jsYuvalar, reason: id);
      expect([for (final y in mblockYuvalari[id]!) y.ad],
          mblockBlokTanimlari[id]!.yuvalar,
          reason: '$id yuva sirasi');
    }
  });

  test('duz liste <-> yiginlar gidip geliyor', () {
    for (final adim in CourseModules.allLessons('mblock')
        .expand((l) => l.steps)
        .whereType<BlockBuilderStep>()
        .where((s) => s.mblock != null)) {
      final p = [mblockCozumProgrami(adim.mblock!.cozum, 'tr')];
      final geri = MBlockKod.program(MBlockKod.duzle(p));
      expect(mblockXml(geri), mblockXml(p), reason: adim.id);
    }
  });
}
