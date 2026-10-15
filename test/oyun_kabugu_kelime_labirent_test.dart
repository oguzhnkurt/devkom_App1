// Kelime Eslestirme ve 3B Labirent de diger oyunlarin ortak kabugunda:
// OyunBasligi + OyunZemini + OyunCevapKarti.
//
// Iki ekran eskiden kendi basligini (gri AppBar / 3B gorunumun ustunde
// yuzen geri tusu) ve kendi zeminini ciziyordu. Burada dort dilde, en dar
// (320x568) ve en buyuk (430x932) telefonda tasma olmadan cizildiklerine
// ve oyunun hala oynandigina bakiyoruz.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/games/maze_3d_game_screen.dart';
import 'package:devkom_app/screens/games/word_match_game_screen.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/learning/match_board.dart';
import 'package:devkom_app/widgets/oyun_basligi.dart';

const _boyutlar = [Size(320, 568), Size(430, 932)];

/// Tasma hatalarini toplar. Dondurdugu fonksiyon FlutterError.onError'i
/// geri aliyor; expect'lerden ONCE cagrilmali (yoksa test motoru
/// "onError geri alinmadi" diye asiliyor).
VoidCallback _tasmalariTopla(List<String> tasmalar) {
  final onceki = FlutterError.onError;
  FlutterError.onError = (d) {
    final t = d.exceptionAsString();
    if (t.contains('overflowed')) {
      tasmalar.add(t.split('\n').first);
    } else {
      onceki?.call(d);
    }
  };
  return () => FlutterError.onError = onceki;
}

Future<void> _ciz(
    WidgetTester tester, String dil, Size boyut, Widget ekran) async {
  SoundService.configure(sound: false, vibration: false);
  SharedPreferences.setMockInitialValues({
    'language_code': dil,
    'howto_seen_word_match': true,
  });
  final ayar = SettingsProvider();
  await ayar.setLocale(Locale(dil));
  tester.view.physicalSize = boyut * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: ayar),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ],
    child: MaterialApp(locale: Locale(dil), home: ekran),
  ));
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  for (final dil in const ['tr', 'en', 'de', 'es']) {
    for (final b in _boyutlar) {
      final ad = '$dil ${b.width.toInt()}x${b.height.toInt()}';

      testWidgets('Kelime Eslestirme ortak kabukta ($ad)', (tester) async {
        final tasma = <String>[];
        final geriAl = _tasmalariTopla(tasma);
        await _ciz(tester, dil, b, const WordMatchGameScreen(gameData: {}));
        geriAl();
        expect(find.byType(OyunBasligi), findsOneWidget);
        expect(find.byType(OyunZemini), findsOneWidget);
        expect(find.byType(OyunCevapKarti), findsWidgets);
        expect(find.byKey(const ValueKey('kelime_harita')), findsOneWidget);
        expect(find.byKey(const ValueKey('kelime_puan')), findsOneWidget);

        // Oyun ayni: dogru cift eslesince puan 10 artiyor.
        final board = tester.widget<MatchBoard>(find.byType(MatchBoard));
        final p = board.pairs.first;
        await tester.ensureVisible(find.text(p.left).first);
        await tester.tap(find.text(p.left).first);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.ensureVisible(find.text(p.right).last);
        await tester.tap(find.text(p.right).last);
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(
            find.descendant(
                of: find.byKey(const ValueKey('kelime_puan')),
                matching: find.text('10')),
            findsOneWidget);

        expect(tasma, isEmpty, reason: tasma.join(' | '));
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 2));
      });

      testWidgets('3B Labirent ortak kabukta ($ad)', (tester) async {
        final tasma = <String>[];
        final geriAl = _tasmalariTopla(tasma);
        await _ciz(tester, dil, b, const Maze3DGameScreen(gameData: {}));
        geriAl();
        expect(find.byType(OyunBasligi), findsOneWidget);
        expect(find.byType(OyunZemini), findsOneWidget);
        // Ileri + bes yon tusu.
        expect(find.byType(OyunCevapKarti), findsNWidgets(6));
        expect(find.byKey(const ValueKey('maze3d_altin')), findsOneWidget);
        expect(find.byKey(const ValueKey('maze3d_harita')), findsOneWidget);

        for (final k in tester
            .widgetList<OyunCevapKarti>(find.byType(OyunCevapKarti))
            .toList()) {
          expect(k.onTap, isNotNull);
        }
        await tester.tap(find.byType(OyunCevapKarti).first);
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);

        expect(tasma, isEmpty, reason: tasma.join(' | '));
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 2));
      });
    }
  }
}
