import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/services/satranc_rakip.dart';

/// Satranc zorluk seviyeleri.
///
/// "Kolay gercekten kolay olsun, AI biraz kaybetmeye oynasin" (Ekim
/// 2026). Eskiden kolay seviye Stockfish'in en zayif ayariydi ve yeni
/// baslayan bir cocugu rahatca yeniyordu. Burada kolay rakibin GERCEKTEN
/// kaybedilebilir oldugunu oynatarak olcuyoruz.
void main() {
  /// Beyaz [beyaz], siyah [siyah] oynuyor; sonucu doner: 1 beyaz kazandi,
  /// -1 siyah kazandi, 0 berabere/bitmedi.
  int oynat(String? Function(chess_lib.Chess) beyaz,
      String? Function(chess_lib.Chess) siyah,
      {int enFazla = 160}) {
    final oyun = chess_lib.Chess();
    for (var i = 0; i < enFazla && !oyun.game_over; i++) {
      final h = (oyun.turn == chess_lib.Color.WHITE ? beyaz : siyah)(oyun);
      if (h == null) break;
      expect(oyun.move(h), isTrue, reason: 'gecersiz hamle: $h');
    }
    if (oyun.in_checkmate) {
      return oyun.turn == chess_lib.Color.WHITE ? -1 : 1;
    }
    return 0;
  }

  test('kolay rakip, dikkatli oynayan bir oyuncuya cogunlukla kaybediyor', () {
    final r = Random(7);
    final kolay = SatrancRakip(r);
    final oyuncu = SatrancRakip(r);
    var beyazKazandi = 0, siyahKazandi = 0;
    const oyunSayisi = 12;
    for (var i = 0; i < oyunSayisi; i++) {
      final s = oynat((g) => oyuncu.dikkatliHamle(g, gurultu: 120),
          kolay.kolayHamle);
      if (s == 1) beyazKazandi++;
      if (s == -1) siyahKazandi++;
    }
    expect(siyahKazandi, lessThanOrEqualTo(1),
        reason: 'Kolay rakip $siyahKazandi/$oyunSayisi oyun kazandi.');
    expect(beyazKazandi, greaterThanOrEqualTo(oyunSayisi ~/ 2),
        reason: 'Oyuncu yalnizca $beyazKazandi/$oyunSayisi oyun kazandi.');
  });

  test('kolay rakip tek hamlelik mati cogu zaman kaciriyor', () {
    // Siyah oynar, Qh4# (aptal mati) tahtada.
    const fen =
        'rnbqkbnr/pppp1ppp/8/4p3/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq g3 0 2';
    final rakip = SatrancRakip(Random(3));
    var mat = 0;
    const deneme = 400;
    for (var i = 0; i < deneme; i++) {
      if (rakip.kolayHamle(chess_lib.Chess.fromFEN(fen)) == 'Qh4#') mat++;
    }
    final oran = mat / deneme;
    expect(oran, lessThan(0.4), reason: 'Mati %${(oran * 100).round()} gordu');
    expect(oran, greaterThan(0.1),
        reason: 'Hic mat etmeyen rakip de yapay gorunur');
  });

  test('dikkatli rakip tek hamlelik mati hep goruyor', () {
    const fen =
        'rnbqkbnr/pppp1ppp/8/4p3/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq g3 0 2';
    final rakip = SatrancRakip(Random(5));
    for (var i = 0; i < 30; i++) {
      expect(rakip.dikkatliHamle(chess_lib.Chess.fromFEN(fen), gurultu: 120),
          'Qh4#');
    }
  });

  test('rakipler oyunu degistirmiyor (kopya uzerinde dusunuyor)', () {
    final oyun = chess_lib.Chess();
    final fen = oyun.fen;
    SatrancRakip(Random(1)).kolayHamle(oyun);
    SatrancRakip(Random(1)).dikkatliHamle(oyun);
    expect(oyun.fen, fen);
  });
}
