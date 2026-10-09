// Satranc: dort seviye ve temali tahta.
import 'package:devkom_app/models/chess_game_model.dart';
import 'package:devkom_app/widgets/temali_satranc_tahtasi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' as fcb;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seviyeler sirasi ve adlari; eski kayitlarin index anlami degismedi', () {
    expect(ChessDifficulty.values.map((d) => d.name).toList(),
        ['beginner', 'intermediate', 'advanced', 'impossible']);
    expect(ChessDifficulty.values.map((d) => d.displayNameFor('tr')).toList(),
        ['Kolay', 'Orta', 'Zor', 'İmkânsız']);
    expect(ChessDifficulty.values.map((d) => d.displayNameFor('en')).toList(),
        ['Easy', 'Medium', 'Hard', 'Impossible']);
    // Zorluk arttikca tahmini guc artiyor.
    final elo = ChessDifficulty.values.map((d) => d.estimatedElo).toList();
    for (var i = 1; i < elo.length; i++) {
      expect(elo[i], greaterThan(elo[i - 1]));
    }
  });

  test('dort tema, her biri iki net ayrilan renk', () {
    expect(SatrancTemasi.values.length, 4);
    for (final t in SatrancTemasi.values) {
      expect(t.acik, isNot(t.koyu));
      for (final dil in ['tr', 'en', 'de', 'es']) {
        expect(t.adi(dil), isNotEmpty);
      }
    }
  });

  testWidgets('temali tahta 32 tasi ciziyor', (tester) async {
    final kontrol = fcb.ChessBoardController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: TemaliSatrancTahtasi(
              controller: kontrol, tema: SatrancTemasi.devMavi),
        ),
      ),
    ));
    final taslar = tester
        .widgetList<fcb.BoardPiece>(find.byType(fcb.BoardPiece))
        .where((b) => b.game.get(b.squareName) != null);
    expect(taslar.length, 32);
  });
}
