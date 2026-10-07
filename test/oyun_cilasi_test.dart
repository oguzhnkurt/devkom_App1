// Komut Dizilimi ve Kod Bloklari cilasi (Ekim 2026).
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/games/block_coding_game_screen.dart';
import 'package:devkom_app/screens/games/sequencing_game_screen.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _ac(WidgetTester t, Widget ekran) async {
  SoundService.configure(sound: false, vibration: false);
  SharedPreferences.setMockInitialValues({
    'language_code': 'tr',
    'howto_seen_block_coding': true,
    'howto_seen_sequencing': true,
  });
  final ayar = SettingsProvider();
  await ayar.setLocale(const Locale('tr'));
  t.view.physicalSize = const Size(430 * 3, 932 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: ayar),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ],
    child: MaterialApp(home: ekran),
  ));
  for (var i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _kapat(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 5));
}

void main() {
  testWidgets('Kod Bloklari: bloga DOKUNMAK kodu ekliyor', (tester) async {
    await _ac(tester, const BlockCodingGameScreen());
    expect(find.byKey(const ValueKey('blok_robot')), findsOneWidget);
    expect(find.text('1 Adım Git'), findsOneWidget); // yalnizca palette
    await tester.tap(find.byKey(const ValueKey('blok_paleti_moveForward')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('1 Adım Git'), findsNWidgets(2)); // palette + kod
    expect(find.byKey(const ValueKey('blok_yildiz_sayaci')), findsOneWidget);
    await _kapat(tester);
  });

  testWidgets('Komut Dizilimi: gorev karti ve numarali bos yuvalar', (tester) async {
    await _ac(tester, const SequencingGameScreen(gameData: {}));
    expect(find.byKey(const ValueKey('komut_gorev_karti')), findsOneWidget);
    expect(find.text('Görev 1/5'), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);
    // Bes bos yuva: 1..5
    for (final n in ['1', '2', '3', '4', '5']) {
      expect(find.text(n), findsWidgets);
    }
    await tester.tap(find.text('Uyan'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('1/5'), findsOneWidget);
    await _kapat(tester);
  });
}
