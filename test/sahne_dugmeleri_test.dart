// SAHNE KARTININ YESIL BAYRAGI ve KIRMIZI DURU
//
// Gercek iPhone'da sahnenin sol ustundeki bayrak ve dur "bir sey
// yapmiyor" gibiydi: dokunma alani 30 pt, dur hep etkin gorunuyordu,
// mBlock sahnesinde bos tahtada bile bayrak etkindi. Kilitlenenler:
//
//  * Bayrak ve dur 44x44 dokunma alani; pasifken soluk (Semantics
//    enabled=false), calisirken bayrak "basili" (selected).
//  * Ders adimi, Proje Atolyesi, mBlock kart ve kukla sahnesi: bayrak
//    alttaki buyuk dugmeyle ayni isi yapiyor, dur durduruyor.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/scratch_atolyeleri.dart';
import 'package:devkom_app/courses/sahne/mblock_sahnesi.dart';
import 'package:devkom_app/courses/sahne/scratch_sahnesi.dart';
import 'package:devkom_app/courses/screens/widgets/proje_atolyesi.dart';
import 'package:devkom_app/courses/screens/widgets/scratch_tezgahi.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/proje_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/ui/press_button.dart';

final _scratch = CoursesData.byId('scratch')!;
late SettingsProvider _ayar;

Future<void> _ac(WidgetTester tester, Widget w,
    {Size boy = const Size(430, 932)}) async {
  tester.view.physicalSize = boy * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: _ayar,
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: w,
        ),
      ),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _dokun(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 60));
}

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
}

SahneBayrakDugmesi _bayrakW(WidgetTester tester, String anahtar) =>
    tester.widget<SahneBayrakDugmesi>(find.byKey(ValueKey(anahtar)));

SahneDurDugmesi _durW(WidgetTester tester, String anahtar) =>
    tester.widget<SahneDurDugmesi>(find.byKey(ValueKey(anahtar)));

/// [ScratchSahneKarti] icin tek parca kart.
Widget _kart({VoidCallback? onBayrak, VoidCallback? onDur, bool c = false}) =>
    SizedBox(
      height: 200,
      child: ScratchSahneKarti(
        lang: 'tr',
        bayrakAnahtari: const ValueKey('b'),
        durAnahtari: const ValueKey('d'),
        onBayrak: onBayrak,
        onDur: onDur,
        calisiyor: c,
        child: const SizedBox.expand(),
      ),
    );

void main() {
  setUpAll(() async {
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    _ayar = SettingsProvider();
    await _ayar.setLocale(const Locale('tr'));
  });

  group('kart', () {
    testWidgets('44x44 dokunma alani; kenarina dokunmak da sayiliyor',
        (tester) async {
      var bayrak = 0, dur = 0;
      await _ac(tester, _kart(onBayrak: () => bayrak++, onDur: () => dur++));
      final b = tester.getRect(find.byKey(const ValueKey('b')));
      final d = tester.getRect(find.byKey(const ValueKey('d')));
      expect(b.width, greaterThanOrEqualTo(44));
      expect(b.height, greaterThanOrEqualTo(44));
      expect(d.width, greaterThanOrEqualTo(44));
      expect(d.height, greaterThanOrEqualTo(44));
      // Gorunen kutunun (32) disina, dokunma alaninin kenarina yakin.
      // (Kartin yuvarlak kosesi kirpiyor; sol ust kose degil.)
      await tester.tapAt(b.centerLeft + const Offset(3, 0));
      await tester.tapAt(d.bottomRight - const Offset(3, 3));
      await tester.pump();
      expect(bayrak, 1);
      expect(dur, 1);
    });

    testWidgets('pasif / hazir / calisiyor halleri', (tester) async {
      final sem = tester.ensureSemantics();
      await _ac(tester, _kart());
      expect(
          tester.getSemantics(find.byKey(const ValueKey('b'))),
          matchesSemantics(
              label: 'Yeşil bayrak',
              isButton: true,
              hasEnabledState: true,
              isEnabled: false,
              hasSelectedState: true));
      expect(
          tester.getSemantics(find.byKey(const ValueKey('d'))),
          matchesSemantics(
              label: 'Durdur',
              isButton: true,
              hasEnabledState: true,
              isEnabled: false));

      await _ac(tester, _kart(onDur: () {}, c: true));
      expect(
          tester.getSemantics(find.byKey(const ValueKey('b'))),
          matchesSemantics(
              label: 'Yeşil bayrak',
              isButton: true,
              hasEnabledState: true,
              isEnabled: false,
              hasSelectedState: true,
              isSelected: true));
      expect(
          tester.getSemantics(find.byKey(const ValueKey('d'))),
          matchesSemantics(
              label: 'Durdur',
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              hasTapAction: true));
      sem.dispose();
    });
  });

  testWidgets('Proje Atolyesi: sahnedeki bayrak calistirir, dur durdurur',
      (tester) async {
    final a = ScratchAtolyeleri.elmaYagmuru;
    await _ac(
        tester,
        ProjeAtolyesiWidget(
          step: a,
          course: _scratch,
          isDark: false,
          lang: 'tr',
          onComplete: (_) {},
          kayitli: KayitliProje(
            id: 'k',
            ad: 'Deneme',
            kursId: 'scratch',
            adimId: a.id,
            kod: KodYapisi.coz(a.ornekCozum),
            tarih: DateTime(2026, 10, 15),
          ),
        ));
    final st = tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));
    expect(st.calisiyor, isFalse);
    expect(_durW(tester, 'sahne_dur').onTap, isNull);

    await _dokun(tester, find.byKey(const ValueKey('sahne_bayragi')));
    expect(st.calisiyor, isTrue);
    expect(_bayrakW(tester, 'sahne_bayragi').calisiyor, isTrue);
    expect(tester.widget<PressButton>(find.byKey(const ValueKey('ders_bayrak')))
        .label, 'Durdur');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await _dokun(tester, find.byKey(const ValueKey('sahne_dur')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(st.calisiyor, isFalse);
    expect(_bayrakW(tester, 'sahne_bayragi').calisiyor, isFalse);
    expect(_bayrakW(tester, 'sahne_bayragi').onTap, isNotNull);
    expect(tester.takeException(), isNull);
    await _kapat(tester);
  });

  group('mBlock sahnesi', () {
    final ledProgrami = [
      const MBlockBlok(tip: 'dev_kart_acilis'),
      const MBlockBlok(tip: 'dev_surekli', icerik: [
        MBlockBlok(
            tip: 'dev_dijital_yaz', alanlar: {'PIN': '13', 'SEVIYE': 'HIGH'}),
        MBlockBlok(tip: 'dev_bekle', alanlar: {'SANIYE': '1'}),
        MBlockBlok(
            tip: 'dev_dijital_yaz', alanlar: {'PIN': '13', 'SEVIYE': 'LOW'}),
        MBlockBlok(tip: 'dev_bekle', alanlar: {'SANIYE': '1'}),
      ]),
    ];

    testWidgets('bos tahtada bayrak pasif; bayrak Uno\'yu calistirir, '
        'dur durdurur', (tester) async {
      final durumlar = <bool>[];
      Widget sahne(List<List<MBlockBlok>> p) => MBlockSahnesi(
            kart: true,
            program: p,
            lang: 'tr',
            renk: Colors.teal,
            zamanOlcegi: 0.2,
            onCalisma: durumlar.add,
          );
      await _ac(tester, sahne(const []));
      expect(_bayrakW(tester, 'mblock_sahne_bayragi').onTap, isNull);
      expect(_durW(tester, 'mblock_sahne_dur').onTap, isNull);

      await _ac(tester, sahne([ledProgrami]));
      final st = tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
      await _dokun(tester, find.byKey(const ValueKey('mblock_sahne_bayragi')));
      expect(st.calisiyor, isTrue);
      expect(_bayrakW(tester, 'mblock_sahne_bayragi').calisiyor, isTrue);
      var yandi = false;
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (st.unoKarti.dijital[13] == true) yandi = true;
      }
      expect(yandi, isTrue, reason: 'pin 13 LED yanmadi');

      await _dokun(tester, find.byKey(const ValueKey('mblock_sahne_dur')));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(st.calisiyor, isFalse);
      expect(durumlar, [true, false]);
      expect(find.text('Kodu durdurdun.'), findsOneWidget);
      await _kapat(tester);
    });

    testWidgets('kukla sahnesi: bayrak Devi\'yi yurutur, dur durdurur',
        (tester) async {
      await _ac(
          tester,
          MBlockSahnesi(
            kart: false,
            program: const [
              [
                MBlockBlok(tip: 'dev_bayrak'),
                MBlockBlok(
                    tip: 'dev_tekrarla',
                    alanlar: {'KERE': '10'},
                    icerik: [
                      MBlockBlok(tip: 'dev_git', alanlar: {'ADIM': '10'}),
                    ]),
              ]
            ],
            lang: 'tr',
            renk: Colors.teal,
          ));
      final st = tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
      await _dokun(tester, find.byKey(const ValueKey('mblock_sahne_bayragi')));
      expect(st.calisiyor, isTrue);
      expect(_bayrakW(tester, 'mblock_sahne_bayragi').calisiyor, isTrue);
      await tester.pump(const Duration(milliseconds: 800));
      await _dokun(tester, find.byKey(const ValueKey('mblock_sahne_dur')));
      expect(st.calisiyor, isFalse);
      expect(tester.takeException(), isNull);
      await _kapat(tester);
    });
  });
}
