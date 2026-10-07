import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;

/// Stockfish'siz satranc rakipleri: KOLAY seviye ve motorun olmadigi
/// yerlerdeki yedek.
///
/// NEDEN KOLAY SEVIYE STOCKFISH DEGIL
/// ----------------------------------
/// "Baslangic" eskiden Stockfish'in Skill Level 1'iydi. Bu ayar motorun
/// EN ZAYIF hali ama yine de yaklasik kulup oyuncusu seviyesinde: tas
/// birakmiyor, cocugun biraktigi tasi hemen aliyor, mati kacirmiyor.
/// Yeni baslayan bir cocuk icin "kolay" degildi (Ekim 2026 kullanici
/// geri bildirimi: "Kolay gercekten kolay olsun, AI biraz kaybetmeye
/// oynasin").
///
/// Kolay rakip bilerek hata yapiyor:
///  * Hamlelerinin cogu RASTGELE — tasini korumayi dusunmuyor.
///  * Tek hamlede mat varsa cogu zaman GORMUYOR.
///  * Bazen tas aliyor ama hep en degerlisini degil.
class SatrancRakip {
  SatrancRakip([Random? rastgele]) : _r = rastgele ?? Random();

  final Random _r;

  /// Kolay seviyenin mati gorme olasiligi.
  static const double kolayMatGorme = 0.25;

  /// Kolay seviyenin tamamen rastgele oynama olasiligi.
  static const double kolayRastgele = 0.55;

  static int tasDegeri(chess_lib.PieceType? t) {
    if (t == chess_lib.PieceType.PAWN) return 100;
    if (t == chess_lib.PieceType.KNIGHT) return 300;
    if (t == chess_lib.PieceType.BISHOP) return 300;
    if (t == chess_lib.PieceType.ROOK) return 500;
    if (t == chess_lib.PieceType.QUEEN) return 900;
    if (t == chess_lib.PieceType.KING) return 10000;
    return 0;
  }

  bool _matMi(chess_lib.Chess oyun, chess_lib.Move m) {
    oyun.move(m);
    final mat = oyun.in_checkmate;
    oyun.undo_move();
    return mat;
  }

  /// KOLAY: cocugun kazanabilecegi rakip. SAN hamle doner.
  String? kolayHamle(chess_lib.Chess asil) {
    final oyun = chess_lib.Chess.fromFEN(asil.fen);
    final hamleler = oyun.generate_moves();
    if (hamleler.isEmpty) return null;

    // Mat ediyorsa cogu zaman gormuyor: mat hamleleri listeden cikiyor.
    final matlar = hamleler.where((m) => _matMi(oyun, m)).toList();
    if (matlar.isNotEmpty && _r.nextDouble() < kolayMatGorme) {
      return asil.move_to_san(matlar[_r.nextInt(matlar.length)]);
    }
    var aday = hamleler.where((m) => !matlar.contains(m)).toList();
    if (aday.isEmpty) aday = hamleler; // yalnizca mat var: oynamak zorunda

    if (_r.nextDouble() < kolayRastgele) {
      return asil.move_to_san(aday[_r.nextInt(aday.length)]);
    }

    // Kalan durumda acgozlu ama dikkatsiz: rastgele bir tas almayi
    // seviyor, karsiligi dusunmuyor.
    final alanlar = aday.where((m) => m.captured != null).toList();
    if (alanlar.isNotEmpty && _r.nextBool()) {
      return asil.move_to_san(alanlar[_r.nextInt(alanlar.length)]);
    }
    return asil.move_to_san(aday[_r.nextInt(aday.length)]);
  }

  /// Iki yarim hamle bakan acgozlu rakip (orta seviyenin yedegi ve
  /// motor yokken ileri seviye).
  ///
  /// Puan = aldigi tasin degeri − karsi tarafin hemen alabilecegi en
  /// degerli tas + kucuk konum bonuslari + gurultu. [gurultu] arttikca
  /// rakip daha sik "ikinci en iyi" hamleyi oynuyor.
  String? dikkatliHamle(chess_lib.Chess asil, {int gurultu = 60}) {
    final oyun = chess_lib.Chess.fromFEN(asil.fen);
    final hamleler = oyun.generate_moves();
    if (hamleler.isEmpty) return null;

    chess_lib.Move? en;
    var enPuan = -1 << 30;
    for (final m in hamleler) {
      var puan = tasDegeri(m.captured);
      if (m.promotion != null) puan += tasDegeri(m.promotion) - 100;

      oyun.move(m);
      if (oyun.in_checkmate) {
        puan += 100000;
      } else {
        if (oyun.in_check) puan += 30;
        // Karsi tarafin en iyi alisi: biraktigimiz tas.
        var kayip = 0;
        for (final c in oyun.generate_moves()) {
          if (c.captured == null) continue;
          final v = tasDegeri(c.captured);
          if (v > kayip) kayip = v;
        }
        puan -= kayip;
        if (oyun.in_draw) puan -= 50;
      }
      oyun.undo_move();

      if (const ['d4', 'e4', 'd5', 'e5'].contains(m.toAlgebraic)) puan += 15;
      if (gurultu > 0) puan += _r.nextInt(gurultu);

      if (puan > enPuan) {
        enPuan = puan;
        en = m;
      }
    }
    return en == null ? null : asil.move_to_san(en);
  }
}
