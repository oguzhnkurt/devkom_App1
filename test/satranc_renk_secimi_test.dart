// Satranc: cocuk Beyaz, Siyah ya da Rastgele secebiliyor (Ekim 2026).
//
// Eskiden cocuk hep beyazdi ve ekranin bircok yeri bunu varsayiyordu:
// tahta yonu, dokunulan karenin hesabi, hamle noktalari, son hamle
// isareti, koordinat harfleri, "sira kimde" kontrolu ve mat sonucu.
import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:devkom_app/core/service_locator.dart';
import 'package:devkom_app/models/chess_game_model.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/games/chess_game_screen.dart';
import 'package:devkom_app/services/auth_service_supabase.dart';
import 'package:devkom_app/services/satranc_rakip.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/temali_satranc_tahtasi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' as fcb;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('tahta yonu: kare <-> konum', () {
    test('beyaz altta: e2 -> (4,6), a8 sol ust', () {
      expect(kareKonumu('e2'), (sutun: 4, satir: 6));
      expect(konumdanKare(0, 0), 'a8');
      expect(konumdanKare(7, 7), 'h1');
    });

    test('siyah altta: e2 -> (3,1), h1 sol ust, a8 sag alt', () {
      expect(kareKonumu('e2', beyazAltta: false), (sutun: 3, satir: 1));
      expect(konumdanKare(0, 0, beyazAltta: false), 'h1');
      expect(konumdanKare(7, 7, beyazAltta: false), 'a8');
      // Siyahin sahi (e8) cocugun tarafinda: alt sira.
      expect(kareKonumu('e8', beyazAltta: false).satir, 7);
    });

    test('64 karenin hepsi iki yonde de gidip geliyor', () {
      for (final beyaz in [true, false]) {
        final gorulen = <String>{};
        for (var r = 0; r < 8; r++) {
          for (var c = 0; c < 8; c++) {
            final k = konumdanKare(c, r, beyazAltta: beyaz);
            gorulen.add(k);
            expect(kareKonumu(k, beyazAltta: beyaz), (sutun: c, satir: r));
          }
        }
        expect(gorulen.length, 64);
      }
    });

    testWidgets('donuk tahtada siyah taslar altta', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: TemaliSatrancTahtasi(
                controller: fcb.ChessBoardController(),
                tema: SatrancTemasi.devMavi,
                beyazAltta: false),
          ),
        ),
      ));
      final tahta = tester.getRect(find.byType(TemaliSatrancTahtasi));
      final e1 = tester.getCenter(find.byWidgetPredicate(
          (w) => w is fcb.BoardPiece && w.squareName == 'e1'));
      final e8 = tester.getCenter(find.byWidgetPredicate(
          (w) => w is fcb.BoardPiece && w.squareName == 'e8'));
      expect(e8.dy, greaterThan(tahta.center.dy), reason: 'siyah sah altta');
      expect(e1.dy, lessThan(tahta.center.dy));
      // Donuk tahtada e-dosyasi soldan dorduncu (h g f e).
      expect(((e8.dx - tahta.left) / (tahta.width / 8)).floor(), 3);
    });
  });

  group('mat sonucu cocugun rengine gore', () {
    // Aptal mati: beyaz mat oldu.
    const beyazMat =
        'rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3';
    // Coban mati: siyah mat oldu.
    const siyahMat =
        'r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4';

    test('cocuk siyahken beyazi mat etti: galibiyet', () {
      final g = chess_lib.Chess.fromFEN(beyazMat);
      expect(satrancSonucu(g, chess_lib.Color.BLACK), GameResult.win);
      expect(satrancSonucu(g, chess_lib.Color.WHITE), GameResult.loss);
    });

    test('cocuk siyahken mat oldu: kayip', () {
      final g = chess_lib.Chess.fromFEN(siyahMat);
      expect(g.in_checkmate, isTrue);
      expect(satrancSonucu(g, chess_lib.Color.BLACK), GameResult.loss);
      expect(satrancSonucu(g, chess_lib.Color.WHITE), GameResult.win);
    });

    test('pat iki renk icin de berabere, baslangic devam ediyor', () {
      final pat = chess_lib.Chess.fromFEN('7k/5Q2/6K1/8/8/8/8/8 b - - 0 1');
      expect(satrancSonucu(pat, chess_lib.Color.WHITE), GameResult.draw);
      expect(satrancSonucu(pat, chess_lib.Color.BLACK), GameResult.draw);
      expect(satrancSonucu(chess_lib.Chess(), chess_lib.Color.BLACK),
          GameResult.ongoing);
    });
  });

  group('rakip iki renkte de oynuyor', () {
    test('kolay ve dikkatli rakip beyaz ve siyah icin gecerli hamle uretiyor',
        () {
      final r = Random(11);
      final rakip = SatrancRakip(r);
      for (var oyunNo = 0; oyunNo < 6; oyunNo++) {
        final g = chess_lib.Chess();
        // Bilgisayar beyaz da siyah da olabiliyor: iki tarafi da oynatiyoruz.
        for (var i = 0; i < 120 && !g.game_over; i++) {
          final h = oyunNo.isEven
              ? rakip.kolayHamle(g)
              : rakip.dikkatliHamle(g, gurultu: 60);
          expect(h, isNotNull);
          final yasal = g.moves().cast<String>();
          expect(yasal, contains(h),
              reason: '${g.turn} icin yasadisi hamle $h (${g.fen})');
          expect(g.move(h), isTrue);
        }
      }
    });

    test('siyah taraf terfiyi oynayabiliyor', () {
      // Siyah piyon a2, a1'e cikinca terfi.
      final g = chess_lib.Chess.fromFEN('7k/8/8/8/8/8/p7/4K3 b - - 0 1');
      final h = SatrancRakip(Random(1)).dikkatliHamle(g, gurultu: 0);
      expect(h, 'a1=Q+');
    });
  });

  test('renk secimi: dort dil, rastgele iki rengi de veriyor', () {
    for (final r in SatrancRenkSecimi.values) {
      for (final dil in ['tr', 'en', 'de', 'es']) {
        expect(r.adi(dil), isNotEmpty);
      }
    }
    expect(SatrancRenkSecimi.beyaz.coz(), chess_lib.Color.WHITE);
    expect(SatrancRenkSecimi.siyah.coz(), chess_lib.Color.BLACK);
    final rnd = Random(3);
    final renkler = {
      for (var i = 0; i < 40; i++) SatrancRenkSecimi.rastgele.coz(rnd)
    };
    expect(renkler.length, 2);
  });

  group('ekran', () {
    setUpAll(() async {
      SoundService.configure(sound: false);
      SharedPreferences.setMockInitialValues({});
      await Supabase.initialize(
          url: 'http://127.0.0.1:1', anonKey: 'test', debug: false);
      if (!getIt.isRegistered<AuthServiceSupabase>()) {
        await setupServiceLocator();
      }
    });

    Future<ChessBoardSahibi> ac(WidgetTester tester, SatrancRenkSecimi renk,
        {String? fen}) async {
      SharedPreferences.setMockInitialValues({'language_code': 'tr'});
      final settings = SettingsProvider();
      await settings.setLocale(const Locale('tr'));
      tester.view.physicalSize = const Size(1600, 2800); // Ahem yazitipi genis
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
        value: settings,
        child: MaterialApp(
          home: ChessGameScreen(
            initialDifficulty: ChessDifficulty.beginner,
            baslangicRengi: renk,
            baslangicFen: fen,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Başlat'));
      await tester.pump();
      return ChessBoardSahibi(tester);
    }

    testWidgets('cocuk siyahsa bilgisayar ilk hamleyi tahta gorundukten sonra '
        'yapiyor', (tester) async {
      final t = await ac(tester, SatrancRenkSecimi.siyah);
      await tester.pump(const Duration(milliseconds: 50));
      // Tahta cizildi, ama henuz hamle yok (bekleme suresi).
      expect(find.byType(TemaliSatrancTahtasi), findsOneWidget);
      expect(t.oyun.history, isEmpty);
      expect(t.tahta.beyazAltta, isFalse);
      // Bekleme + kolay rakibin dusunme suresi.
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(t.oyun.history.length, 1);
      expect(t.oyun.turn, chess_lib.Color.BLACK);
      expect(t.tahta.enableUserMoves, isTrue,
          reason: 'Sira cocukta (siyah), tahta acik olmali.');
      // Koordinatlar donuk: alt satirda once h.
      final h = tester.getCenter(find.text('h'));
      final a = tester.getCenter(find.text('a'));
      expect(h.dx, lessThan(a.dx));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('cocuk beyazsa bilgisayar beklemede', (tester) async {
      final t = await ac(tester, SatrancRenkSecimi.beyaz);
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(t.oyun.history, isEmpty);
      expect(t.tahta.beyazAltta, isTrue);
      expect(t.tahta.enableUserMoves, isTrue);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('siyah cocuk mat edince "kazandin" paneli', (tester) async {
      await ac(tester, SatrancRenkSecimi.siyah,
          fen: 'rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3');
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(find.textContaining('kazandın'), findsOneWidget);
      expect(find.textContaining('Mat oldun'), findsNothing);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('siyah cocuk dokunarak kendi tasini secip oynuyor',
        (tester) async {
      final t = await ac(tester, SatrancRenkSecimi.siyah,
          // Beyaz e4 oynamis, sira siyahta: bilgisayar beklemiyor.
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1');
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(t.oyun.history, isEmpty, reason: 'Sira cocukta.');
      final tahta = tester.getRect(find.byType(TemaliSatrancTahtasi));
      final s = tahta.width / 8;
      Offset merkez(String kare) {
        final k = kareKonumu(kare, beyazAltta: false);
        return tahta.topLeft + Offset((k.sutun + .5) * s, (k.satir + .5) * s);
      }

      // e7 piyonu: donuk tahtada alttan ikinci sira.
      await tester.tapAt(merkez('e7'));
      await tester.pump();
      await tester.tapAt(merkez('e5'));
      await tester.pump();
      expect(t.oyun.get('e5')?.color, chess_lib.Color.BLACK);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      // Bilgisayar (beyaz) karsilik verdi, sira yine cocukta.
      expect(t.oyun.turn, chess_lib.Color.BLACK);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
    });
  });
}

/// Ekrandaki tahtaya ve oyuna erisim.
class ChessBoardSahibi {
  ChessBoardSahibi(this.tester);
  final WidgetTester tester;
  TemaliSatrancTahtasi get tahta =>
      tester.widget<TemaliSatrancTahtasi>(find.byType(TemaliSatrancTahtasi));
  chess_lib.Chess get oyun => tahta.controller.game;
}
