// Oyun ekranlarini ALMANCA ve ISPANYOLCA cizip iki seye bakiyoruz:
//
//  1. Turkce kalinti var mi. `_isEn ? ingilizce : turkce` kalibi 389
//     yerde vardi; almanca secen cocuk oyunun tamamini turkce goruyordu.
//  2. Tasma var mi. Almanca ve ispanyolca etiketler turkce/ingilizceden
//     belirgin uzun ("IZQUIERDA", "Nach rechts drehen"); sabit genislikli
//     dugmeler bunlari kirpiyordu.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/games/block_coding_game_screen.dart';
import 'package:devkom_app/screens/games/color_coding_screen.dart';
import 'package:devkom_app/screens/games/matching_game_screen.dart';
import 'package:devkom_app/screens/games/sequencing_game_screen.dart';

/// Turkce kalinti ararken hangi harflere bakilacagi DILE GORE degisir:
/// ä/ö/ü almancanin kendi harfleri, á/é/í/ó/ú/ñ/ü ispanyolcanin.
const _turkishOnly = {
  'de': 'çÇğĞıİşŞ',
  'es': 'ğĞıİşŞöÖ',
};

typedef ScreenBuilder = Widget Function();

// Buradaki liste, test ortaminda Supabase ornegi olmadan cizilebilen
// ekranlar. Disarida kalanlar ve nedenleri:
//   - Koordinat Macerasi: geri sayim zamanlayicisi testi asili birakiyor.
//   - Hata Avcisi / Kod Dedektifi / Degisken Ustasi: cizim sirasinda
//     Supabase.instance istiyorlar.
// Bunlar icin statik tarama (game_screens_localization_test.dart) devrede.
final _screens = <String, ScreenBuilder>{
  'Renkli Kodlar': () => const ColorCodingScreen(),
  'Kod Bloklari': () => const BlockCodingGameScreen(),
  'Komut Dizilimi': () => const SequencingGameScreen(gameData: {}),
  'Esleştirme': () => const MatchingGameScreen(),
};

Future<SettingsProvider> _settings(String lang) async {
  SharedPreferences.setMockInitialValues({'language_code': lang});
  final s = SettingsProvider();
  await s.setLocale(Locale(lang));
  return s;
}

void main() {
  for (final lang in ['de', 'es']) {
    for (final entry in _screens.entries) {
      testWidgets('${entry.key} — $lang dilinde turkce kalinti ve tasma yok',
          (tester) async {
        final settings = await _settings(lang);

        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        final overflows = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (details) {
          final text = details.exceptionAsString();
          if (text.contains('overflowed')) {
            overflows.add(text.split('\n').first);
          } else {
            previous?.call(details);
          }
        };
        addTearDown(() => FlutterError.onError = previous);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<SettingsProvider>.value(value: settings),
              // Bazi oyunlar oynama suresi kapisi icin AuthProvider ariyor.
              ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
            ],
            child: MaterialApp(
              locale: Locale(lang),
              home: entry.value(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));

        final letters = _turkishOnly[lang]!.split('');
        final leaks = <String>[];
        for (final t in tester.widgetList<Text>(find.byType(Text))) {
          final text = t.data ?? t.textSpan?.toPlainText() ?? '';
          if (letters.any(text.contains)) leaks.add('"$text"');
        }

        expect(leaks, isEmpty,
            reason: '${entry.key} ekraninda $lang dilinde turkce yazi: '
                '${leaks.join(", ")}');
        expect(overflows, isEmpty,
            reason: '${entry.key} ekraninda $lang dilinde tasma: '
                '${overflows.join(" | ")}');

        // Oyun ekranlari geri sayim/animasyon zamanlayicisi kuruyor;
        // agaci sokup zamanlayicilarin dolmasini bekliyoruz, yoksa test
        // "A Timer is still pending" ile patliyor.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 5));
      });
    }
  }
}
