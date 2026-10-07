// Devi'nin yapay zeka dersi: hikaye bicimli, oyunlu ilk giris.
import 'dart:io';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/devai/devi_yz_dersi.dart';
import 'package:devkom_app/screens/devchat_screen.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _bekle(WidgetTester t, [int ms = 700]) async {
  for (var i = 0; i < 7; i++) {
    await t.pump(Duration(milliseconds: ms ~/ 7));
  }
}

Future<SettingsProvider> _ayar(String dil) async {
  final s = SettingsProvider();
  await s.setLocale(Locale(dil));
  return s;
}

Widget _uygulama(SettingsProvider s, Widget home) => ChangeNotifierProvider.value(
      value: s,
      child: MaterialApp(
        locale: s.locale,
        supportedLocales: const [Locale('tr'), Locale('en'), Locale('de'), Locale('es')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    );

void _telefon(WidgetTester t) {
  t.view.physicalSize = const Size(430 * 3, 932 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

Future<void> _devam(WidgetTester t) async {
  await t.tap(find.byKey(const ValueKey('yz_devam')));
  await _bekle(t);
}

void main() {
  setUpAll(() => SoundService.configure(sound: false, vibration: false));

  testWidgets('dersin bastan sona akisi ve sonucu', (tester) async {
    _telefon(tester);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final ayar = await _ayar('tr');
    String? sonuc = 'yok';
    await tester.pumpWidget(_uygulama(
      ayar,
      Builder(
        builder: (c) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async => sonuc = await DeviYzDersi.ac(c),
              child: const Text('ac'),
            ),
          ),
        ),
      ),
    ));
    await _bekle(tester);
    await tester.tap(find.text('ac'));
    await _bekle(tester);

    // 1 Merhaba
    expect(find.byKey(const ValueKey('yz_hazirim')), findsOneWidget);
    expect(find.text('🎮 5 mini oyun'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('yz_hazirim')));
    await _bekle(tester);

    // 2 Nedir (kendiliginden ilerleyen kart)
    expect(find.text('Yapay zekâ nedir?'), findsOneWidget);
    await _devam(tester);

    // 3 Ogret oyunu: bos yere dokunmak oyunun ortasinda ilerletmiyor.
    expect(find.text('Bilgisayara öğret!'), findsOneWidget);
    await tester.tapAt(const Offset(400, 300));
    await _bekle(tester);
    expect(find.text('Bilgisayara öğret!'), findsOneWidget);

    // Yanlis cevap: uyari, ilerleme yok.
    await tester.tap(find.byKey(const ValueKey('yz_kopek'))); // ilk ornek kedi
    await _bekle(tester);
    expect(find.textContaining('Yanlış örnek'), findsOneWidget);
    for (final kedi in [true, false, true, false]) {
      await tester.tap(find.byKey(ValueKey(kedi ? 'yz_kedi' : 'yz_kopek')));
      await _bekle(tester, 400);
    }
    await _bekle(tester, 1800);
    expect(find.byKey(const ValueKey('yz_ogret_sonuc')), findsOneWidget);
    // Bir hata yapildi: guven %89.
    expect(find.text('Bu bir KEDİ! · %89 emin'), findsOneWidget);
    await _devam(tester);

    // 4 Nerede: 3 kart cevrilince tamam.
    for (var k = 0; k < 3; k++) {
      await tester.tap(find.byKey(ValueKey('yz_nerede_$k')));
      await _bekle(tester, 500);
    }
    expect(find.text('3/6 ✨'), findsOneWidget);
    await _devam(tester);

    // 5 Antrenman: dogruluk %98'e cikiyor.
    for (var k = 0; k < 6; k++) {
      await tester.tap(find.byKey(const ValueKey('yz_antrenman')));
      await _bekle(tester, 300);
    }
    await _bekle(tester);
    expect(find.text('%98'), findsOneWidget);
    await _devam(tester);

    // 6 Kod
    expect(find.text('Sihir değil, kod! ✨'), findsOneWidget);
    await _devam(tester);

    // 7 Kurallar
    for (var k = 0; k < 3; k++) {
      await tester.tap(find.byKey(ValueKey('yz_kural_$k')));
      await _bekle(tester, 300);
    }
    expect(find.textContaining('güvenli bir kâşifsin'), findsOneWidget);
    await _devam(tester);

    // 8 Soru: yanlis, sonra dogru.
    await tester.tap(find.byKey(const ValueKey('yz_secenek_0')));
    await _bekle(tester);
    expect(find.text('Neredeyse! Bir daha dene 💪'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('yz_secenek_1')));
    await _bekle(tester);
    expect(find.textContaining('Doğru!'), findsOneWidget);
    await _devam(tester);

    // 9 Final: rozet, bitti isareti, sohbete donus.
    await _bekle(tester, 1400);
    expect(find.byKey(const ValueKey('yz_rozet')), findsOneWidget);
    expect(await DeviYzDersi.bitti(), isTrue);
    await tester.tap(find.byKey(const ValueKey('yz_sohbete_basla')));
    await _bekle(tester);
    expect(sonuc, '');
    expect(find.byType(DeviYzDersiScreen), findsNothing);
  });

  testWidgets('DevAI sekmesi ilk giriste dersi aciyor, kapatilinca bir daha acmiyor',
      (tester) async {
    _telefon(tester);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final ayar = await _ayar('tr');
    await tester.pumpWidget(_uygulama(
        ayar, const DevAiChatScreen(showBackButton: false, dersiOtomatikAc: true)));
    await _bekle(tester, 1200);
    expect(find.byType(DeviYzDersiScreen), findsOneWidget);
    expect(await DeviYzDersi.goruldu(), isTrue);

    await tester.tap(find.byKey(const ValueKey('yz_kapat')));
    await _bekle(tester);
    expect(find.byType(DeviYzDersiScreen), findsNothing);
    expect(await DeviYzDersi.bitti(), isFalse, reason: 'yarida kapatildi');

    // Yeniden kurulunca ders kendiliginden acilmiyor; dugmeyle aciliyor.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_uygulama(
        ayar, const DevAiChatScreen(showBackButton: false, dersiOtomatikAc: true)));
    await _bekle(tester, 1200);
    expect(find.byType(DeviYzDersiScreen), findsNothing);
    await tester.tap(find.byKey(const ValueKey('yz_dersi_dugmesi')));
    await _bekle(tester);
    expect(find.byType(DeviYzDersiScreen), findsOneWidget);
  });

  testWidgets('soruyla gelen cocuk derse sokulmuyor', (tester) async {
    _telefon(tester);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final ayar = await _ayar('tr');
    await tester.pumpWidget(_uygulama(
        ayar,
        const DevAiChatScreen(
            showBackButton: false, dersiOtomatikAc: true, ilkSoru: 'Döngü nedir?')));
    await _bekle(tester, 1200);
    expect(find.byType(DeviYzDersiScreen), findsNothing);
  });

  testWidgets('dort dilde hatasiz aciliyor', (tester) async {
    _telefon(tester);
    for (final dil in ['en', 'de', 'es', 'tr']) {
      SharedPreferences.setMockInitialValues({'language_code': dil});
      final ayar = await _ayar(dil);
      await tester.pumpWidget(_uygulama(ayar, const DeviYzDersiScreen()));
      await _bekle(tester);
      // Butun kartlari gez.
      for (var k = 0; k < 8; k++) {
        await tester.tap(find.byKey(const ValueKey('yz_devam')));
        await _bekle(tester);
        expect(tester.takeException(), isNull, reason: '$dil / kart ${k + 2}');
      }
      await tester.pumpWidget(const SizedBox());
      await _bekle(tester);
    }
  });

  test('ders Devi\'yi kendi kendine ogrenen bir model gibi tanitmiyor', () {
    final s = File('lib/screens/devai/devi_yz_dersi.dart').readAsStringSync();
    // Devi'nin cevaplari cihazda, elle yazilmis bir bilgi tabanindan.
    expect(s.contains('Bana yazdıkların bu telefonda kalır'), isTrue);
    for (final yasak in ['Devi öğreniyor', 'beni eğittiler', 'internetten öğren']) {
      expect(s.contains(yasak), isFalse, reason: yasak);
    }
  });
}
