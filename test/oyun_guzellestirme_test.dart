// Boru Bulmacasi, Koordinat Macerasi ve Bilgi Yarismasi cilasi (Ekim 2026).
//
// Uc oyun yeniden cizildi (Flame tuvali / duz kartlar -> renkli cipler,
// kalin borular, eksenli izgara, renkli siklar). Bu dosya hem yeni
// gorunumun parcalarini hem de cila sirasinda duzeltilen kural
// hatalarini kilitliyor.
import 'dart:io';
import 'dart:math';

import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/games/millionaire_game_screen.dart';
import 'package:devkom_app/screens/games/pipes_game_screen.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _ac(WidgetTester t, Widget ekran) async {
  SoundService.configure(sound: false, vibration: false);
  SharedPreferences.setMockInitialValues({'language_code': 'tr'});
  final ayar = SettingsProvider();
  await ayar.setLocale(const Locale('tr'));
  t.view.physicalSize = const Size(390 * 3, 844 * 3);
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

/// Uretilen tahtadaki garantili yolu (kaynaktan asagi, sonra yana)
/// dogru yonlere cevirir.
void _coz(PipesBoard b) {
  final n = b.gridSize;
  for (var y = 1; y < n - 1; y++) {
    b.grid[y][b.sourceX].setRotation(1);
  }
  if (b.sourceX != b.sinkX) {
    b.grid[n - 1][b.sourceX].setRotation(b.sourceX < b.sinkX ? 2 : 1);
    for (var x = min(b.sourceX, b.sinkX) + 1; x < max(b.sourceX, b.sinkX); x++) {
      b.grid[n - 1][x].setRotation(0);
    }
  }
}

void main() {
  group('Boru Bulmacasi kurallari', () {
    test('tahta hic hazir cozulmus gelmiyor', () {
      // Rastgele dondurme yolu bazen tesaduf eseri dogru yone getiriyor,
      // seviye tek dokunusa gerek kalmadan "Tebrikler" diyordu.
      final r = Random(7);
      for (final n in [4, 5, 6, 7, 8]) {
        for (var i = 0; i < 150; i++) {
          final b = PipesBoard(n)..generate(decoyFillRate: 0.6, random: r);
          expect(b.checkConnections(), isFalse, reason: '${n}x$n hazir cozulmus');
        }
      }
    });

    test('her tahtanin cozumu var ve yakinlik cubugu doluyor', () {
      final r = Random(11);
      for (final n in [4, 6, 8]) {
        for (var i = 0; i < 50; i++) {
          final b = PipesBoard(n)..generate(decoyFillRate: 0.4, random: r);
          expect(b.yakinlik, lessThan(1));
          _coz(b);
          expect(b.checkConnections(), isTrue);
          expect(b.yakinlik, 1.0);
        }
      }
    });

    test('kose boru cizimi ile baglanti yonleri ayni', () {
      // Cizim 0 yonunde soldan asagi; baglanti listesi de [alt, sol].
      final k = PipeTile(type: PipeType.corner);
      expect(k.getConnections().toSet(), {0, 3});
      k.rotate();
      expect(k.getConnections().toSet(), {0, 1});
      // turns geriye sarmiyor: 3 -> 0 gecisinde de bir ceyrek ileri.
      k
        ..rotate()
        ..rotate()
        ..rotate();
      expect(k.rotation, 0);
      expect(k.turns, 4);
    });
  });

  testWidgets('Boru Bulmacasi: cipler, dokununca hamle, cozunce kutlama',
      (t) async {
    await _ac(t, const PipesGameScreen());
    expect(find.byKey(const ValueKey('boru_cip_seviye')), findsOneWidget);
    expect(find.byKey(const ValueKey('boru_cip_hamle')), findsOneWidget);
    expect(find.byKey(const ValueKey('boru_cip_skor')), findsOneWidget);
    expect(find.byKey(const ValueKey('boru_tahtasi')), findsOneWidget);

    PipeTile tl(int x, int y) =>
        (t.widget(find.byKey(ValueKey('boru_kare_${x}_$y'))) as dynamic).tile
            as PipeTile;
    const n = 4; // Seviye 1
    int sx = 0, kx = 0;
    for (var x = 0; x < n; x++) {
      if (tl(x, 0).type == PipeType.source) sx = x;
      if (tl(x, n - 1).type == PipeType.sink) kx = x;
    }
    var hamle = 0;
    Future<void> ayarla(int x, int y, bool Function(int) ok) async {
      while (!ok(tl(x, y).rotation)) {
        await t.tap(find.byKey(ValueKey('boru_kare_${x}_$y')));
        await t.pump(const Duration(milliseconds: 50));
        hamle++;
      }
    }

    for (var y = 1; y < n - 1; y++) {
      await ayarla(sx, y, (r) => r % 2 == 1);
    }
    if (sx != kx) {
      await ayarla(sx, n - 1, (r) => r == (sx < kx ? 2 : 1));
      for (var x = min(sx, kx) + 1; x < max(sx, kx); x++) {
        await ayarla(x, n - 1, (r) => r % 2 == 0);
      }
    }
    await t.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('boru_kutlama')), findsOneWidget);
    expect(find.text('$hamle'), findsWidgets);

    // Artik kendiliginden gecmiyor: cocuk dugmeye basinca seviye 2.
    await t.pump(const Duration(seconds: 3));
    expect(find.byKey(const ValueKey('boru_kutlama')), findsOneWidget);
    await t.tap(find.text('Sonraki seviye'));
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('boru_kutlama')), findsNothing);
    expect(
        find.descendant(
            of: find.byKey(const ValueKey('boru_cip_seviye')),
            matching: find.text('2')),
        findsOneWidget);
    await _kapat(t);
  });

  testWidgets('Boru Bulmacasi: 8x8 tahta ekrana sigiyor', (t) async {
    await _ac(t, const PipesGameScreen(baslangicSeviyesi: 13));
    expect(find.byKey(const ValueKey('boru_kare_7_7')), findsOneWidget);
    final kare = t.getSize(find.byKey(const ValueKey('boru_kare_0_0')));
    expect(kare.width, greaterThanOrEqualTo(40),
        reason: 'Buyuk izgarada kare parmakla basilamayacak kadar kuculdu.');
    await _kapat(t);
  });

  group('Koordinat Macerasi', () {
    final s =
        File('lib/screens/games/coordinates_game_screen.dart').readAsStringSync();

    test('dogru cevaptan sonra ikinci kontrol puan vermiyor', () {
      // Iki saniyelik kutlamada "Kontrol Et"e tekrar basmak ayni hedef
      // icin puani bir daha veriyor ve seviye atlatiyordu.
      final i = s.indexOf('void _checkAnswer()');
      final govde = s.substring(i, i + 900);
      expect(govde.contains('if (gameWon || timeExpired) return;'), isTrue);
      expect(s.contains('onPressed: gameWon ? null : _checkAnswer'), isTrue);
    });

    test('kutlama sirasinda sure sayaci duruyor', () {
      final i = s.indexOf('if (selectedX == targetX && selectedY == targetY)');
      final dal = s.substring(i, i + 900);
      expect(dal.contains('_levelTimer?.cancel();'), isTrue);
    });

    test('eksenler ve hedef ayni renkte, yanlis tahtayi salliyor', () {
      expect(s.contains('_xRenk'), isTrue);
      expect(s.contains('_yRenk'), isTrue);
      expect(s.contains('ShakeOnChange('), isTrue);
      expect(s.contains('trigger: _yanlisSayaci'), isTrue);
      expect(s.contains('SnackBar('), isFalse,
          reason: 'Geri bildirim tahtanin altinda; SnackBar dugmeleri kapatiyordu.');
    });
  });

  group('Bilgi Yarismasi', () {
    testWidgets('renkli siklar ve cevap seridi', (t) async {
      await _ac(t, const MillionaireGameScreen());
      expect(find.byKey(const ValueKey('yarisma_soru_karti')), findsOneWidget);
      expect(find.byKey(const ValueKey('yarisma_cip_soru')), findsOneWidget);
      for (var i = 0; i < 4; i++) {
        expect(find.byKey(ValueKey('yarisma_sik_$i')), findsOneWidget);
      }
      await t.tap(find.byKey(const ValueKey('yarisma_sik_0')));
      await t.pump(const Duration(milliseconds: 300));
      await t.ensureVisible(find.byKey(const ValueKey('yarisma_final')));
      await t.pump(const Duration(milliseconds: 100));
      await t.tap(find.byKey(const ValueKey('yarisma_final')));
      await t.pump(const Duration(milliseconds: 400));
      // Final tusunun yerinde sonuc seridi (dogru ya da yanlis).
      expect(
          find.byKey(const ValueKey('yarisma_sonuc_true')).evaluate().length +
              find.byKey(const ValueKey('yarisma_sonuc_false')).evaluate().length,
          1);
      // Sonraki soruya gecis Pro kontrolu icin Supabase istiyor; burada
      // ekrani kapatiyoruz (gecikmeli geri cagri `mounted` ile cikiyor).
      await _kapat(t);
    });

    test('telefon jokeri gizli ya da dogru sikki "yanlis" diye soylemiyor', () {
      final s =
          File('lib/screens/games/millionaire_game_screen.dart').readAsStringSync();
      expect(s.contains('!_hiddenOptions.contains(i)'), isTrue);
      expect(s.contains('willBeCorrect ? correctIndex : random.nextInt(4)'),
          isFalse);
    });

    test('baslik oyunun kimlik renginde', () {
      final s =
          File('lib/screens/games/millionaire_game_screen.dart').readAsStringSync();
      expect(s.contains('OyunBasligi.oyun('), isTrue);
      expect(s.contains('Color(0xFF0D1B2A)'), isFalse,
          reason: 'Koyu lacivert TV ekrani geri gelmis.');
    });
  });
}
