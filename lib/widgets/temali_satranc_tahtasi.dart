import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' as fcb;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/lang.dart';

/// Satranc tahtasinin renk temasi.
///
/// NEDEN KENDI TAHTAMIZ (Ekim 2026)
/// --------------------------------
/// `flutter_chess_board` tahtayi paketin icindeki dort hazir RESIMDEN
/// ciziyordu (kahverengi, koyu kahverengi, turuncu, yesil). Yeni renk
/// eklemenin yolu yoktu; oyuncu "eski" gorunen iki kahverengi arasinda
/// seciyordu. Tahta artik kareleri kendisi boyuyor: tema yalnizca iki
/// renkten ibaret ve yeni bir tane eklemek bu enum'a bir satir.
enum SatrancTemasi {
  devMavi(Color(0xFFE6ECFF), Color(0xFF5B7BFF), Color(0xFF1445FC)),
  klasik(Color(0xFFF0D9B5), Color(0xFFB58863), Color(0xFF8B5A2B)),
  orman(Color(0xFFEEEED2), Color(0xFF769656), Color(0xFF4E7A3A)),
  gece(Color(0xFFB9C1D9), Color(0xFF4A5378), Color(0xFF2B3150));

  const SatrancTemasi(this.acik, this.koyu, this.vurgu);

  /// Acik kare.
  final Color acik;

  /// Koyu kare.
  final Color koyu;

  /// Secim cercevesi ve kenar rengi.
  final Color vurgu;

  String adi(String dil) {
    switch (this) {
      case SatrancTemasi.devMavi:
        return 'DevEducation';
      case SatrancTemasi.klasik:
        return AppLang.pick(dil,
            tr: 'Klasik Ahşap',
            en: 'Classic Wood',
            de: 'Klassisches Holz',
            es: 'Madera clásica');
      case SatrancTemasi.orman:
        return AppLang.pick(dil,
            tr: 'Orman', en: 'Forest', de: 'Wald', es: 'Bosque');
      case SatrancTemasi.gece:
        return AppLang.pick(dil,
            tr: 'Gece', en: 'Night', de: 'Nacht', es: 'Noche');
    }
  }

  static const _anahtar = 'satranc_tahta_temasi';

  /// Son secilen tema (ilk acilista DevEducation mavisi).
  static Future<SatrancTemasi> kayitli() async {
    try {
      final p = await SharedPreferences.getInstance();
      final ad = p.getString(_anahtar);
      return SatrancTemasi.values
          .firstWhere((t) => t.name == ad, orElse: () => SatrancTemasi.devMavi);
    } catch (_) {
      return SatrancTemasi.devMavi;
    }
  }

  Future<void> kaydet() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_anahtar, name);
    } catch (_) {
      // Tercih kaydedilemezse oyun yine oynanir; sadece bir dahaki
      // acilista varsayilan tema gelir.
    }
  }
}

/// Cocugun hangi renkle oynayacagi (oyun basinda soruluyor).
///
/// RENK SECIMI (Ekim 2026): cocuk eskiden HEP beyaz oynuyordu. Artik
/// Beyaz, Siyah ya da Rastgele seciyor; son secim hatirlaniyor. Hangi
/// renk secilirse secilsin cocugun taslari tahtanin ALTINDA (siyahta
/// tahta 180 derece donuyor).
enum SatrancRenkSecimi {
  beyaz,
  siyah,
  rastgele;

  String adi(String dil) {
    switch (this) {
      case SatrancRenkSecimi.beyaz:
        return AppLang.pick(dil,
            tr: 'Beyaz', en: 'White', de: 'Weiß', es: 'Blancas');
      case SatrancRenkSecimi.siyah:
        return AppLang.pick(dil,
            tr: 'Siyah', en: 'Black', de: 'Schwarz', es: 'Negras');
      case SatrancRenkSecimi.rastgele:
        return AppLang.pick(dil,
            tr: 'Rastgele', en: 'Random', de: 'Zufall', es: 'Al azar');
    }
  }

  /// Secimi gercek bir renge cevirir ("Rastgele" burada zar atiyor).
  chess_lib.Color coz([Random? r]) {
    switch (this) {
      case SatrancRenkSecimi.beyaz:
        return chess_lib.Color.WHITE;
      case SatrancRenkSecimi.siyah:
        return chess_lib.Color.BLACK;
      case SatrancRenkSecimi.rastgele:
        return (r ?? Random()).nextBool()
            ? chess_lib.Color.WHITE
            : chess_lib.Color.BLACK;
    }
  }

  static const _anahtar = 'satranc_oyuncu_rengi';

  /// Son secilen renk (ilk acilista Beyaz).
  static Future<SatrancRenkSecimi> kayitli() async {
    try {
      final p = await SharedPreferences.getInstance();
      final ad = p.getString(_anahtar);
      return SatrancRenkSecimi.values.firstWhere((t) => t.name == ad,
          orElse: () => SatrancRenkSecimi.beyaz);
    } catch (_) {
      return SatrancRenkSecimi.beyaz;
    }
  }

  Future<void> kaydet() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_anahtar, name);
    } catch (_) {
      // Kaydedilemezse bir dahaki oyunda varsayilan (Beyaz) gelir.
    }
  }
}

/// Tahtadaki (sutun, satir) hucresinin karesi. (0,0) sol ust kose.
///
/// [beyazAltta] false ise tahta cocugun gozunden siyah tarafa donuk:
/// sol ust h1, sag alt a8.
String konumdanKare(int sutun, int satir, {bool beyazAltta = true}) {
  return beyazAltta
      ? '${'abcdefgh'[sutun]}${8 - satir}'
      : '${'abcdefgh'[7 - sutun]}${satir + 1}';
}

/// [konumdanKare]'nin tersi: "e2" -> (4, 6) beyaz altta, (3, 1) siyah
/// altta.
({int sutun, int satir}) kareKonumu(String kare, {bool beyazAltta = true}) {
  final dosya = kare.toLowerCase().codeUnitAt(0) - 97;
  final sira = int.parse(kare[1]) - 1;
  return beyazAltta
      ? (sutun: dosya, satir: 7 - sira)
      : (sutun: 7 - dosya, satir: sira);
}

/// Kareleri temaya gore boyayan satranc tahtasi.
///
/// Davranis `fcb.ChessBoard` ile birebir ayni (surukle-birak, terfi
/// penceresi, `enableUserMoves`, `onMove`); yalnizca zemin resim degil
/// boyama. Taslar paketin kendi vektor cizimleri (`fcb.BoardPiece`).
class TemaliSatrancTahtasi extends StatelessWidget {
  const TemaliSatrancTahtasi({
    super.key,
    required this.controller,
    required this.tema,
    this.enableUserMoves = true,
    this.onMove,
    this.beyazAltta = true,
  });

  final fcb.ChessBoardController controller;
  final SatrancTemasi tema;
  final bool enableUserMoves;
  final VoidCallback? onMove;

  /// false: tahta siyah taraftan gorunuyor (cocuk siyah oynuyor).
  /// Kare renkleri donmede degismiyor: sol alt hep koyu kare.
  final bool beyazAltta;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<chess_lib.Chess>(
      valueListenable: controller,
      builder: (context, game, _) {
        return AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(builder: (context, kutu) {
            final hucre = kutu.maxWidth / 8;
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _KarePainter(tema)),
                ),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemCount: 64,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final row = index ~/ 8;
                    final column = index % 8;
                    final kare =
                        konumdanKare(column, row, beyazAltta: beyazAltta);
                    return _kareHucresi(context, game, kare, hucre);
                  },
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _kareHucresi(
      BuildContext context, chess_lib.Chess game, String kare, double hucre) {
    final tas = game.get(kare);
    final gorunum = fcb.BoardPiece(squareName: kare, game: game);
    final surukle = tas != null
        ? Draggable<fcb.PieceMoveData>(
            feedback: SizedBox(width: hucre, height: hucre, child: gorunum),
            childWhenDragging: const SizedBox(),
            data: fcb.PieceMoveData(
              squareName: kare,
              pieceType: tas.type.toUpperCase(),
              pieceColor: tas.color,
            ),
            child: gorunum,
          )
        : const SizedBox();

    return DragTarget<fcb.PieceMoveData>(
      onWillAcceptWithDetails: (_) => enableUserMoves,
      onAcceptWithDetails: (details) async {
        final veri = details.data;
        final siraOnce = game.turn;
        final terfi = veri.pieceType == 'P' &&
            ((veri.squareName[1] == '7' &&
                    kare[1] == '8' &&
                    veri.pieceColor == chess_lib.Color.WHITE) ||
                (veri.squareName[1] == '2' &&
                    kare[1] == '1' &&
                    veri.pieceColor == chess_lib.Color.BLACK));
        if (terfi) {
          final secim = await terfiSor(context);
          if (secim == null) return;
          controller.makeMoveWithPromotion(
              from: veri.squareName, to: kare, pieceToPromoteTo: secim);
        } else {
          controller.makeMove(from: veri.squareName, to: kare);
        }
        if (game.turn != siraOnce) onMove?.call();
      },
      builder: (context, _, __) => surukle,
    );
  }
}

/// Piyon son siraya ulasinca hangi tasa donusecegini sorar.
///
/// Paketteki pencere yalnizca Ingilizce bir baslik gosteriyordu
/// ("Choose promotion"); baslik artik oyuncunun dilinde.
Future<String?> terfiSor(BuildContext context, {String? dil}) {
  final d = dil ?? Localizations.localeOf(context).languageCode;
  // Taslari paketin kendi cizimiyle gostermek icin kucuk bir konum.
  final ornek = chess_lib.Chess.fromFEN('k7/8/8/8/8/8/8/QRBN3K w - - 0 1');
  Widget secenek(String kare, String harf) => InkWell(
        onTap: () => Navigator.of(context).pop(harf),
        child: SizedBox(
            width: 52,
            height: 52,
            child: fcb.BoardPiece(squareName: kare, game: ornek)),
      );
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(AppLang.pick(d,
          tr: 'Piyon neye dönüşsün?',
          en: 'Promote the pawn to?',
          de: 'Bauer umwandeln in?',
          es: '¿En qué se convierte el peón?')),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          secenek('a1', 'q'),
          secenek('b1', 'r'),
          secenek('c1', 'b'),
          secenek('d1', 'n'),
        ],
      ),
    ),
  );
}

class _KarePainter extends CustomPainter {
  _KarePainter(this.tema);

  final SatrancTemasi tema;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 8;
    final acik = Paint()..color = tema.acik;
    final koyu = Paint()..color = tema.koyu;
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        canvas.drawRect(
          Rect.fromLTWH(c * k, r * k, k + 0.5, k + 0.5),
          (r + c).isEven ? acik : koyu,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KarePainter old) => old.tema != tema;
}
