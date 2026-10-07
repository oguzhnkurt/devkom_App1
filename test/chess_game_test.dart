// Satranc ekrani icin kaynak okuyan koruma testleri.
//
// Uc kusur da sessizdi: ne derlemede ne calisirken hata veriyorlardi,
// ama cocuk acisindan oyunu bozuyorlardi.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const ekran = 'lib/screens/games/chess_game_screen.dart';
  const servis = 'lib/services/chess_ai_service.dart';

  test('sira bilgisayardayken cocuk oynayamiyor', () {
    // `enableUserMoves: true` sabitti: bilgisayar dusunurken ya da
    // hamle uretemeyip sira siyahta kalinca cocuk BILGISAYARIN
    // taslarini oynatabiliyordu.
    final s = File(ekran).readAsStringSync();
    expect(s.contains('enableUserMoves: true'), isFalse);
    expect(s.contains('enableUserMoves: _cocukOynayabilir'), isTrue);
    expect(s.contains('bool get _cocukOynayabilir'), isTrue);
    // Uc kosulun ucu de yerinde mi?
    final i = s.indexOf('bool get _cocukOynayabilir');
    final govde = s.substring(i, i + 260);
    expect(govde.contains('GameResult.ongoing'), isTrue);
    expect(govde.contains('!_isAIThinking'), isTrue);
    expect(govde.contains('chess_lib.Color.WHITE'), isTrue);
  });

  test('Stockfish ekran kapaninca durduruluyor', () {
    final s = File(ekran).readAsStringSync();
    final i = s.indexOf('void dispose()');
    expect(i, greaterThan(0));
    expect(s.substring(i, i + 400).contains('_aiService.dispose()'), isTrue,
        reason: 'Ayri surec arka planda calismaya devam ediyordu.');
  });

  test('motor sessiz kalirsa basit rakibe dusuluyor', () {
    // Zaman asimi ve cevrilemeyen hamle null donuyordu; ekran null
    // gelince hicbir sey yapmiyor, tahta kilitleniyordu.
    final s = File(servis).readAsStringSync();
    expect(
        RegExp(r"debugPrint\('❌ No valid move from Stockfish'\);\s*\n\s*return null;")
            .hasMatch(s),
        isFalse);
    expect(s.contains('return _getSimpleAIMove(game, difficulty);'), isTrue);
    expect(s.contains('return sanMove ?? _getSimpleAIMove(game, difficulty);'),
        isTrue);
  });

  test('ham istisna metni cocuga gosterilmiyor', () {
    final s = File(ekran).readAsStringSync();
    expect(s.contains(r'AI hareketi başarısız: $e'), isFalse);
    expect(s.contains('Bilgisayar bu hamlede takıldı'), isTrue);
  });

  test('oyun sonu tahtayi ortmuyor: acilir-kapanir panel', () {
    // Sonuc eskiden tahtanin ustune acilan bir pencereydi; cocuk nasil
    // mat oldugunu goremiyordu (Ekim 2026 geri bildirimi).
    final s = File(ekran).readAsStringSync();
    expect(s.contains('_showResultDialog'), isFalse);
    expect(s.contains('Widget _buildSonucPaneli()'), isTrue);
    expect(s.contains('_sonucAcik = !_sonucAcik'), isTrue,
        reason: 'Panel basligina dokununca kapanip acilmali.');
    // Mat olan sah tahtada isaretli.
    expect(s.contains('_tehditAltindakiSah()'), isTrue);
  });

  test('tasa dokununca gidebilecegi kareler gosteriliyor', () {
    final s = File(ekran).readAsStringSync();
    expect(s.contains("generate_moves({'square': kare})"), isTrue);
    expect(s.contains('_buildIpucuKatmani(maxWidth)'), isTrue);
    // Noktaya dokununca hamle yapiliyor.
    expect(s.contains('onTapUp: (d) => _kareyeDokunuldu('), isTrue);
  });

  test('iki tahta secenegi', () {
    final s = File(ekran).readAsStringSync();
    expect(RegExp(r'_buildThemeOption\(\s*BoardColor\.').allMatches(s).length,
        2);
  });

  test('kolay seviye Stockfish kullanmiyor, orta seviye yumusatildi', () {
    final s = File(servis).readAsStringSync();
    final i = s.indexOf('if (difficulty == ChessDifficulty.beginner) {');
    expect(i, greaterThan(0));
    expect(s.indexOf('_rakip.kolayHamle(game)', i), greaterThan(i));
    expect(i, lessThan(s.indexOf("_stockfish!.stdin = 'ucinewgame'")),
        reason: 'Kolay seviye motora hic ulasmamali.');
    // Orta seviye eskiden Skill 10'du.
    final orta = s.substring(s.indexOf('int get stockfishSkillLevel'));
    expect(orta.contains('return 10;'), isFalse);
    expect(orta.contains('return 20;'), isTrue,
        reason: 'Zor seviye oldugu gibi kalmali.');
  });
}
