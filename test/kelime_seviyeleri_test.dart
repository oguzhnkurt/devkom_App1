// Kelime Eslestirme: 24 seviye, yavas yavas zorlasiyor.
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/games/word_match_game_screen.dart';
import 'package:devkom_app/screens/games/word_match_levels.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/learning/match_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devkom_app/screens/games/word_match_words.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final s = KelimeSeviyeleri.hepsi;

  test('en az 20 seviye, numaralar sirali', () {
    expect(s.length, greaterThanOrEqualTo(20));
    for (var i = 0; i < s.length; i++) {
      expect(s[i].no, i + 1);
    }
  });

  test('zorluk hicbir adimda geri gitmiyor', () {
    for (var i = 1; i < s.length; i++) {
      final a = s[i - 1], b = s[i];
      expect(b.cift, greaterThanOrEqualTo(a.cift), reason: 'cift ${b.no}');
      expect(b.dunya, greaterThanOrEqualTo(a.dunya), reason: 'dunya ${b.no}');
      // Can bir kez gelince gitmiyor ve artmiyor.
      if (a.can != null) {
        expect(b.can, isNotNull, reason: 'can ${b.no}');
        expect(b.can!, lessThanOrEqualTo(a.can!), reason: 'can ${b.no}');
      }
      if (a.sure != null) {
        expect(b.sure, isNotNull, reason: 'sure ${b.no}');
        expect(b.sure!, lessThanOrEqualTo(a.sure!), reason: 'sure ${b.no}');
      }
    }
    expect(s.first.cift, 3);
    expect(s.last.cift, 6);
    expect(s.last.can, 2);
  });

  test('ilk on seviyede ne can ne sure var', () {
    for (final sv in s.take(10)) {
      expect(sv.can, isNull, reason: '${sv.no}');
      expect(sv.sure, isNull, reason: '${sv.no}');
    }
  });

  test('her seviyenin havuzu tahtayi dolduruyor', () {
    for (final sv in s) {
      final terimler = {
        for (final t in sv.temalar) ...wordMatchWords[t]!.map((w) => w['term']),
      };
      expect(terimler.length, greaterThanOrEqualTo(sv.cift), reason: '${sv.no}');
    }
  });

  test('alti dunyanin dort dilde adi var', () {
    for (var d = 1; d <= 6; d++) {
      for (final l in ['tr', 'en', 'de', 'es']) {
        expect(KelimeSeviyeleri.dunyaAdi(d, l), isNotEmpty);
      }
    }
  });

  test('yildiz: hatasiz 3, iki hataya kadar 2', () {
    expect(KelimeSeviyeleri.yildiz(0), 3);
    expect(KelimeSeviyeleri.yildiz(2), 2);
    expect(KelimeSeviyeleri.yildiz(3), 1);
  });

  test('ilerleme: seviye bitince sonraki aciliyor, iyi yildiz korunuyor', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await KelimeIlerlemesi.acik(), 1);
    await KelimeIlerlemesi.bitti(1, 3);
    expect(await KelimeIlerlemesi.acik(), 2);
    await KelimeIlerlemesi.bitti(1, 1); // daha kotu tekrar
    expect((await KelimeIlerlemesi.yildizlar())[1], 3);
    await KelimeIlerlemesi.bitti(24, 2);
    expect(await KelimeIlerlemesi.acik(), 24, reason: '24 sinir');
  });

  testWidgets('11. seviyede can var; yanlis eslesme can goturuyor', (tester) async {
    SoundService.configure(sound: false, vibration: false);
    SharedPreferences.setMockInitialValues({
      'language_code': 'tr',
      'howto_seen_word_match': true,
      'kelime_eslestirme_acik_seviye': 11,
    });
    final ayar = SettingsProvider();
    await ayar.setLocale(const Locale('tr'));
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: ayar),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: const MaterialApp(home: WordMatchGameScreen(gameData: {})),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('Arduino · Seviye 11/24'), findsOneWidget);
    expect(find.text('❤️'), findsNWidgets(3));

    final board = tester.widget<MatchBoard>(find.byType(MatchBoard));
    expect(board.pairs.length, 5);
    await tester.tap(find.text(board.pairs[0].left).first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text(board.pairs[1].right).last);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('❤️'), findsNWidgets(2));
    expect(find.text('🤍'), findsOneWidget);

    // Harita: 12. seviye kilitli, 11 acik.
    await tester.tap(find.byKey(const ValueKey('kelime_harita')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const ValueKey('kelime_seviye_11')), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsNWidgets(13));
  });
}
