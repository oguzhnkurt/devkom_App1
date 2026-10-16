// Serbest atolyede kuklayi sahnede surukleme: konum gostergesi, sinirlar,
// calistirmanin surukledigin yerden baslamasi, kaydet/ac, calisirken
// surukleme yok, sayfa kaydirmasiyla cakisma yok, mBlock atolyesi.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/scratch_atolyeleri.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/sahne/mblock_sahnesi.dart';
import 'package:devkom_app/courses/sahne/proje_sahnesi.dart';
import 'package:devkom_app/courses/screens/mblock_atolye_ekrani.dart';
import 'package:devkom_app/courses/screens/projelerim_ekrani.dart';
import 'package:devkom_app/courses/screens/widgets/proje_atolyesi.dart';
import 'package:devkom_app/courses/screens/widgets/scratch_tezgahi.dart';
import 'package:devkom_app/courses/yurutme/blok_yorumlayici.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/proje_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/mascot.dart';

final _scratch = CoursesData.byId('scratch')!;
final _mblock = CoursesData.byId('mblock')!;
late SettingsProvider _ayar;

Future<void> _ac(
  WidgetTester tester, {
  ProjeAtolyesiStep? adim,
  String? kod,
  KayitliProje? kayitli,
  Size boy = const Size(390, 2200),
  double yazi = 1.0,
}) async {
  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = yazi;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final a = adim ?? ScratchAtolyeleri.serbest;
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: _ayar,
    child: MaterialApp(
      home: AtolyeEkrani(
        course: _scratch,
        step: a,
        kayitli: kayitli ??
            (kod == null
                ? null
                : KayitliProje(
                    id: 'p1',
                    ad: 'Deneme',
                    kursId: 'scratch',
                    adimId: adim?.id,
                    kod: KodYapisi.coz(kod),
                    tarih: DateTime(2026, 10, 16),
                  )),
      ),
    ),
  ));
  await tester.pump();
}

Future<void> _bekle(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

ScratchTezgahiState _tezgah(WidgetTester tester) =>
    tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));

String _okuma(WidgetTester tester) => tester
    .widget<Text>(find.descendant(
        of: find.byKey(const ValueKey('kukla_konumu')),
        matching: find.byType(Text)))
    .data!;

Finder get _devi => find.descendant(
    of: find.byType(ProjeSahnesi), matching: find.byType(Mascot));

/// Sahnenin olcegi: ekran pikseli / Scratch birimi.
double _olcek(WidgetTester tester) {
  final s = tester.getSize(find.byType(ProjeSahnesi));
  return (s.width / 480) < (s.height / 360) ? s.width / 480 : s.height / 360;
}

Future<void> _surukle(WidgetTester tester, Finder f, Offset d,
    {Offset tut = Offset.zero}) async {
  await tester.ensureVisible(find.byType(ProjeSahnesi));
  await tester.pump();
  final g = await tester.startGesture(tester.getCenter(f.first) + tut);
  await g.moveBy(d / 2);
  await tester.pump();
  await g.moveBy(d / 2);
  await tester.pump();
  await g.up();
  await tester.pump();
}

SahneKuklasi _kukla(ProjeMotoru m, String ad) =>
    m.kuklalar.firstWhere((k) => k.tanim.ad == ad && !k.klon);

void main() {
  setUpAll(() async {
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    _ayar = SettingsProvider();
    await _ayar.setLocale(const Locale('tr'));
  });

  setUp(() => SharedPreferences.setMockInitialValues({'language_code': 'tr'}));

  testWidgets('Devi surukleniyor; gosterge canli, birakinca yer kaliyor',
      (tester) async {
    await _ac(tester, kod: 'green_flag say_hello');
    expect(_okuma(tester), 'x: 0  y: 0');
    final o = _olcek(tester);
    await tester.ensureVisible(find.byType(ProjeSahnesi));
    await tester.pump();
    final g = await tester.startGesture(tester.getCenter(_devi.first));
    await g.moveBy(Offset(60 * o, -20 * o));
    await tester.pump();
    await g.moveBy(Offset(60 * o, -20 * o));
    await tester.pump();
    // Surerken de canli.
    expect(_okuma(tester), 'x: 120  y: 40');
    await g.up();
    await tester.pump();
    expect(_okuma(tester), 'x: 120  y: 40');
    expect(_tezgah(tester).konumlar['Devi'], const Offset(120, 40));
    expect(_kukla(_tezgah(tester).motor, 'Devi').sahne.x, 120);
    // Tek kukla: ad ve secim halkasi yok.
    expect(find.byKey(const ValueKey('kukla_secim_halkasi')), findsNothing);
  });

  testWidgets('sahne sinirlarinda kaliyor (480 x 360)', (tester) async {
    await _ac(tester, kod: 'green_flag say_hello');
    await _surukle(tester, _devi, const Offset(3000, 3000));
    expect(_okuma(tester), 'x: 240  y: -180');
    // Kose sahnenin tam kenarinda: biraz iceriden tut.
    await _surukle(tester, _devi, const Offset(-6000, -6000),
        tut: const Offset(-10, -10));
    expect(_okuma(tester), 'x: -240  y: 180');
    expect(_tezgah(tester).konumlar['Devi'], const Offset(-240, 180));
  });

  testWidgets('bayrak surukledigin yerden basliyor; git bloku ustune yaziyor',
      (tester) async {
    await _ac(tester, kod: 'green_flag move_10');
    final o = _olcek(tester);
    await _surukle(tester, _devi, Offset(-100 * o, 50 * o));
    expect(_okuma(tester), 'x: -100  y: -50');
    _tezgah(tester).calistir();
    await tester.pump();
    final m = _tezgah(tester).motor;
    // Calismadan once motorun ilk hali: surukledigin yer.
    expect(m.sonuc().adimlar.length, lessThan(3));
    await _bekle(tester, 3000);
    expect(m.bitti, isTrue);
    expect(m.sonuc().sonSahne.x, -90, reason: '-100 + 10 adim');
    expect(m.sonuc().sonSahne.y, -50);
    expect(_okuma(tester), 'x: -90  y: -50');

    // Kod degisince de yer kaliyor; "ortaya git" ustune yaziyor.
    _tezgah(tester).kodYukle(KodYapisi.coz('green_flag goto_center'));
    await tester.pump();
    expect(_okuma(tester), 'x: -100  y: -50');
    _tezgah(tester).calistir();
    await _bekle(tester, 3000);
    expect(_tezgah(tester).motor.sonuc().sonSahne.x, 0);
    expect(_tezgah(tester).motor.sonuc().sonSahne.y, 0);
  });

  testWidgets('bitmis yurutmeden sonra kukla durdugu yerden tutuluyor',
      (tester) async {
    await _ac(tester, kod: 'green_flag move_100');
    _tezgah(tester).calistir();
    await _bekle(tester, 3000);
    expect(_okuma(tester), 'x: 100  y: 0');
    final o = _olcek(tester);
    await _surukle(tester, _devi, Offset(0, -30 * o));
    expect(_okuma(tester), 'x: 100  y: 30');
    expect(_tezgah(tester).konumlar['Devi'], const Offset(100, 30));
  });

  testWidgets('calisirken surukleme yok', (tester) async {
    await _ac(tester, kod: 'green_flag forever turn_90 }');
    _tezgah(tester).calistir();
    await _bekle(tester, 800);
    expect(_tezgah(tester).calisiyor, isTrue);
    final once = _tezgah(tester).konumlar;
    await _surukle(tester, _devi, const Offset(0, -80));
    expect(_tezgah(tester).konumlar, once);
    final s = _kukla(_tezgah(tester).motor, 'Devi').sahne;
    expect(s.y, 0, reason: 'parmak kuklayi yukari cekmedi');
    // Gosterge calisirken de var ve canli.
    expect(_okuma(tester), startsWith('x: '));
    _tezgah(tester).durdur();
    await tester.pump();
  });

  testWidgets('kuklanin disindan surukleme sayfayi kaydiriyor, kukladan '
      'surukleme kaydirmiyor', (tester) async {
    await _ac(tester, kod: 'green_flag say_hello', boy: const Size(390, 700));
    final kaydirma = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    await tester.ensureVisible(find.byType(ProjeSahnesi));
    await _bekle(tester, 600);
    final bas = kaydirma.pixels;
    // Kukladan yukari: sayfa yerinde, kukla yukarida.
    final g = await tester.startGesture(tester.getCenter(_devi.first));
    for (var i = 0; i < 5; i++) {
      await g.moveBy(const Offset(0, -12));
      await tester.pump();
    }
    await g.up();
    await _bekle(tester, 600);
    expect(kaydirma.pixels, bas);
    expect(_tezgah(tester).konumlar['Devi']!.dy, greaterThan(20));
    // Sahnenin bos kosesinden yukari: sayfa kayiyor, kukla yerinde.
    final yer = _tezgah(tester).konumlar['Devi'];
    final kose = tester.getTopLeft(find.byType(ProjeSahnesi)) +
        const Offset(30, 60);
    await tester.dragFrom(kose, const Offset(0, -150));
    await _bekle(tester, 600);
    expect(kaydirma.pixels, greaterThan(bas));
    expect(_tezgah(tester).konumlar['Devi'], yer);
  });

  testWidgets('birden cok kukla: dokunulan seciliyor, gostergede adi var',
      (tester) async {
    await _ac(tester,
        adim: ScratchAtolyeleri.yakalaOyunu,
        kod: ScratchAtolyeleri.yakalaOyunu.ornekCozum);
    expect(_okuma(tester), 'Devi  x: -120  y: -40');
    expect(find.byKey(const ValueKey('kukla_secim_halkasi')), findsOneWidget);
    // Fare (100, 50) — sahnenin ortasina gore.
    final o = _olcek(tester);
    await tester.ensureVisible(find.byType(ProjeSahnesi));
    await tester.pump();
    final fare = tester.getCenter(find.byType(ProjeSahnesi)) +
        Offset(100 * o, -50 * o);
    await tester.tapAt(fare);
    await tester.pump();
    expect(_okuma(tester), 'Fare  x: 100  y: 50');
    expect(
        tester.state<ProjeSahnesiState>(find.byType(ProjeSahnesi)).seciliKukla,
        'Fare');
    // Dokunmak yer degistirmiyor.
    expect(_tezgah(tester).konumlar, isEmpty);
    final g = await tester.startGesture(fare);
    await g.moveBy(Offset(-50 * o, 0));
    await tester.pump();
    await g.moveBy(Offset(-50 * o, 0));
    await g.up();
    await tester.pump();
    expect(_okuma(tester), 'Fare  x: 0  y: 50');
    expect(_tezgah(tester).konumlar, {'Fare': const Offset(0, 50)});
    // Calisinca Fare oradan basliyor (hazir kodunun "git"i yine yaziyor).
    expect(_kukla(_tezgah(tester).motor, 'Fare').sahne.x, 0);
  });

  testWidgets('kaydet ve ac: yer projeyle geliyor', (tester) async {
    await _ac(tester, kod: 'green_flag say_hello');
    final o = _olcek(tester);
    await _surukle(tester, _devi, Offset(80 * o, -60 * o));
    expect(_okuma(tester), 'x: 80  y: 60');
    await tester.ensureVisible(find.byKey(const ValueKey('atolye_kaydet')));
    await tester.tap(find.byKey(const ValueKey('atolye_kaydet')));
    await _bekle(tester, 600);
    await tester.tap(find.byKey(const ValueKey('proje_kaydet_onay')));
    await _bekle(tester, 600);
    final kayitli = (await ProjeDeposu.tumu()).single;
    expect(kayitli.konumlar, {'Devi': const Offset(80, 60)});

    await tester.pumpWidget(const SizedBox());
    await _ac(tester, kayitli: kayitli);
    expect(_okuma(tester), 'x: 80  y: 60');
    _tezgah(tester).calistir();
    await _bekle(tester, 2500);
    expect(_tezgah(tester).motor.sonuc().sonSahne.x, 80);
    expect(_tezgah(tester).motor.sonuc().sonSahne.y, 60);
  });

  test('kayit JSON: konum yaziliyor, eski kayit varsayilanla aciliyor', () {
    final p = KayitliProje(
      id: 'a',
      ad: 'A',
      kursId: 'scratch',
      kod: KodYapisi.coz('green_flag say_hello'),
      tarih: DateTime(2026, 10, 16),
      konumlar: const {'Devi': Offset(12.4, -40), 'Fare': Offset(0, 50)},
    );
    final j = jsonDecode(jsonEncode(p.toJson())) as Map<String, Object?>;
    expect(j['konum'], {
      'Devi': [12, -40],
      'Fare': [0, 50],
    });
    final geri = KayitliProje.fromJson(j)!;
    expect(geri.konumlar, {
      'Devi': const Offset(12, -40),
      'Fare': const Offset(0, 50),
    });
    // Eski kayit (konum yok) ve bozuk konum: proje yine aciliyor.
    final eski = Map<String, Object?>.from(j)..remove('konum');
    expect(KayitliProje.fromJson(eski)!.konumlar, isEmpty);
    expect(
        KayitliProje.fromJson({...j, 'konum': 'bozuk'})!.konumlar, isEmpty);
    expect(
        KayitliProje.fromJson({
          ...j,
          'konum': {
            'Devi': [1],
            'Fare': [3, 4],
          }
        })!
            .konumlar,
        {'Fare': const Offset(3, 4)});
    // Konumsuz proje JSON'a "konum" yazmiyor (eski bicimle ayni).
    expect(p.copyWith(konumlar: const {}).toJson().containsKey('konum'),
        isFalse);
  });

  test('motor baslangic yeri KuklaTanimi.konumlarla', () {
    final m = ProjeMotoru(
      yorumlayici: BlokYorumlayici(dil: 'tr'),
      bloklar: const [],
      ana: KuklaTanimi.devi.konumlarla(const {'Devi': Offset(-30, 70)}),
    );
    expect(m.kuklalar.single.sahne.x, -30);
    expect(m.kuklalar.single.sahne.y, 70);
    expect(KuklaTanimi.devi.konumlarla(const {}), same(KuklaTanimi.devi));
  });

  group('tasma yok', () {
    for (final boy in const [Size(360, 640), Size(375, 667), Size(430, 932)]) {
      for (final yazi in const [1.0, 1.3]) {
        testWidgets('${boy.width.toInt()}x${boy.height.toInt()} x$yazi',
            (tester) async {
          await _ac(tester,
              adim: ScratchAtolyeleri.yakalaOyunu,
              kod: ScratchAtolyeleri.yakalaOyunu.ornekCozum,
              boy: boy,
              yazi: yazi);
          expect(tester.takeException(), isNull);
          await _surukle(tester, _devi, const Offset(400, 400));
          expect(tester.takeException(), isNull);
          expect(_okuma(tester), 'Devi  x: 240  y: -180');
          final g = tester.getRect(find.byKey(const ValueKey('kukla_konumu')));
          final s = tester.getRect(find.byType(ProjeSahnesi));
          expect(s.contains(g.topLeft) && s.contains(g.bottomRight), isTrue);
          _tezgah(tester).calistir();
          await _bekle(tester, 1500);
          expect(tester.takeException(), isNull);
          _tezgah(tester).durdur();
          await tester.pump();
        });
      }
    }
  });

  testWidgets('mBlock atolyesi: Devi surukleniyor, kod oradan basliyor',
      (tester) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
      value: _ayar,
      child: MaterialApp(home: MBlockAtolyeEkrani(course: _mblock)),
    ));
    await tester.pump();
    expect(_okuma(tester), 'x: 0  y: 0');
    final o = _olcek(tester);
    await _surukle(tester, _devi, Offset(-150 * o, -50 * o));
    expect(_okuma(tester), 'x: -150  y: 50');
    final sahne = tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
    expect(sahne.deviKonumu, const Offset(-150, 50));
    // "Merhaba! de" + 10 adim git.
    tester
        .state<MBlockAtolyeEkraniState>(find.byType(MBlockAtolyeEkrani))
        .durumVer([
      [
        const MBlockBlok(tip: 'dev_bayrak'),
        const MBlockBlok(tip: 'dev_git', alanlar: {'ADIM': '10'}),
      ]
    ]);
    await tester.pump();
    expect(_okuma(tester), 'x: -150  y: 50');
    await tester.tap(find.byKey(const ValueKey('mblock_sahne_bayragi')));
    await _bekle(tester, 3000);
    expect(sahne.calisiyor, isFalse);
    expect(sahne.motor.sonuc().sonSahne.x, -140);
    expect(_okuma(tester), 'x: -140  y: 50');
    expect(tester.takeException(), isNull);
  });
}
