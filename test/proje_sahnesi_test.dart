// PROJE SAHNESI ekranda: canli motor, sanal tuslar, hazir kodlu kuklalar,
// 3.1 ve 5.1 oyunlari hedeflerini yakiyor.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/scratch_atolyeleri.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/sahne/proje_sahnesi.dart';
import 'package:devkom_app/courses/screens/widgets/proje_atolyesi.dart';
import 'package:devkom_app/courses/screens/widgets/scratch_tezgahi.dart';
import 'package:devkom_app/courses/yurutme/blok_yorumlayici.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/proje_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';

final _scratch = CoursesData.byId('scratch')!;
late SettingsProvider _ayar;

Future<void> _ac(WidgetTester tester, ProjeAtolyesiStep a,
    {String? kod, List<bool>? sonuclar, String lang = 'tr'}) async {
  tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: _ayar,
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ProjeAtolyesiWidget(
            step: a,
            course: _scratch,
            isDark: false,
            lang: lang,
            onComplete: sonuclar?.add,
            kayitli: KayitliProje(
              id: 'p',
              ad: 'Oyun',
              kursId: 'scratch',
              adimId: a.id,
              kod: KodYapisi.coz(kod ?? a.ornekCozum),
              tarih: DateTime(2026, 10, 15),
            ),
          ),
        ),
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

ProjeMotoru _motor(WidgetTester tester) =>
    tester.widget<ProjeSahnesi>(find.byType(ProjeSahnesi)).motor;

void main() {
  setUpAll(() async {
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    _ayar = SettingsProvider();
    await _ayar.setLocale(const Locale('tr'));
  });

  testWidgets('5.1: oklar sahnenin altinda, otomatik oyuncu oynuyor, '
      'hedefler yaniyor', (tester) async {
    final sonuclar = <bool>[];
    await _ac(tester, ScratchAtolyeleri.elmaYagmuru, sonuclar: sonuclar);
    // Bayraktan once de tuslar gorunuyor (pasif).
    expect(find.byKey(const ValueKey('tus_left')), findsOneWidget);
    expect(find.byKey(const ValueKey('tus_right')), findsOneWidget);
    expect(find.byKey(const ValueKey('kukla_cipi_Kase')), findsOneWidget);

    tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi)).calistir();
    await _bekle(tester, 3000);
    expect(find.byKey(const ValueKey('otomatik_oyuncu')), findsOneWidget);
    expect(find.text('Otomatik oyuncu · tuşlara bas, sen oyna!'),
        findsOneWidget);
    expect(_motor(tester).canliIkiz, greaterThan(0),
        reason: 'elma ikizleri sahnede');
    expect(find.text('0/4'), findsOneWidget);

    await _bekle(tester, 16000);
    expect(find.text('4/4'), findsOneWidget);
    expect(sonuclar, [true]);
    expect(find.byKey(const ValueKey('proje_sonuc')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sanal tusa basmak tus betigini baslatiyor ve otomatik '
      'oyuncuyu susturuyor', (tester) async {
    await _ac(tester, ScratchAtolyeleri.tuslarlaDevi,
        kod: 'green_flag say_hello when_key_space change_y_up=50');
    tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi)).calistir();
    await _bekle(tester, 600);
    final m = _motor(tester);
    expect(m.otomatikOynuyor, isFalse, reason: 'cocuga once firsat');
    final g = await tester
        .startGesture(tester.getCenter(find.byKey(const ValueKey('tus_space'))));
    await tester.pump(const Duration(milliseconds: 100));
    expect(m.basili, contains('space'));
    await g.up();
    await tester.pump(const Duration(milliseconds: 100));
    expect(m.elleOynandi, isTrue);
    expect(m.sonuc().calisanOlaylar, contains('tus:space'));
    expect(m.sonuc().sonSahne.y, 50);
    await _bekle(tester, 6000);
    expect(m.bitti, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('3.1: Fare\'nin hazir kodu okunuyor; Devi yakaliyor', (tester) async {
    final sonuclar = <bool>[];
    await _ac(tester, ScratchAtolyeleri.yakalaOyunu, sonuclar: sonuclar);
    expect(find.byKey(const ValueKey('tus_left')), findsNothing,
        reason: 'tus kullanmayan programda tus seridi yok');
    await tester.tap(find.byKey(const ValueKey('kukla_cipi_Fare')));
    await _bekle(tester, 600);
    expect(find.text('Fare kuklasının kodu'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await _bekle(tester, 600);

    tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi)).calistir();
    await _bekle(tester, 42000);
    expect(find.text('4/4'), findsOneWidget);
    expect(sonuclar, [true]);
    expect(_motor(tester).durduruldu, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('kirmizi dur yurutmeyi o anda bitiriyor', (tester) async {
    await _ac(tester, ScratchAtolyeleri.elmaYagmuru, lang: 'en');
    final st = tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));
    st.calistir();
    await _bekle(tester, 1500);
    st.durdur();
    await tester.pump();
    final m = _motor(tester);
    expect(m.bitti, isTrue);
    expect(m.elleDurdu, isTrue);
    expect(find.text('You stopped the code.'), findsOneWidget);
    expect(st.calisiyor, isFalse);
    await tester.pumpWidget(const SizedBox());
  });
}
