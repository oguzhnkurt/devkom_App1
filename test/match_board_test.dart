import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/widgets/learning/match_board.dart';

/// Eslestirme tahtasinin ETKILESIMI.
///
/// Bu testler ekran goruntusune bakarak yakalanamayan seyi olcuyor:
/// dokunus ve surukleme gercekten eslesmeye donusuyor mu. Onceki
/// surumde surukleme hicbir tepki vermiyordu ve bu, analiz de testler
/// de temiz oldugu icin hicbir yerde gorunmuyordu — sadece elle
/// denerken fark ediliyordu. Artik surukleme burada sinaniyor.
void main() {
  const pairs = [
    MatchPair(id: 'a', left: 'Robot', right: 'Robot'),
    MatchPair(id: 'b', left: 'Sensor', right: 'Sensör'),
    MatchPair(id: 'c', left: 'Loop', right: 'Döngü'),
  ];

  Future<void> pumpBoard(
    WidgetTester tester, {
    void Function(MatchPair)? onCorrect,
    void Function(MatchPair, MatchPair)? onWrong,
    VoidCallback? onCompleted,
    List<String> rightOrder = const ['c', 'a', 'b'],
    bool enableDrag = true,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: MatchBoard(
            pairs: pairs,
            rightOrder: rightOrder,
            enableDrag: enableDrag,
            onCorrect: onCorrect,
            onWrong: onWrong,
            onCompleted: onCompleted,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// Sag sutundaki kutuyu bulur. 'Robot' iki sutunda da geciyor, bu
  /// yuzden konuma gore ayirt ediyoruz.
  Finder rightTile(WidgetTester tester, String label) {
    final all = find.text(label);
    final width = tester.view.physicalSize.width /
        tester.view.devicePixelRatio;
    for (var i = 0; i < all.evaluate().length; i++) {
      final f = all.at(i);
      if (tester.getCenter(f).dx > width / 2) return f;
    }
    return all.last;
  }

  Finder leftTile(WidgetTester tester, String label) {
    final all = find.text(label);
    final width = tester.view.physicalSize.width /
        tester.view.devicePixelRatio;
    for (var i = 0; i < all.evaluate().length; i++) {
      final f = all.at(i);
      if (tester.getCenter(f).dx < width / 2) return f;
    }
    return all.first;
  }

  group('dokun-dokun', () {
    testWidgets('dogru cift eslesir', (tester) async {
      MatchPair? correct;
      await pumpBoard(tester, onCorrect: (p) => correct = p);

      await tester.tap(leftTile(tester, 'Robot'));
      await tester.pumpAndSettle();
      await tester.tap(rightTile(tester, 'Robot'));
      await tester.pumpAndSettle();

      expect(correct?.id, 'a');
    });

    testWidgets('yanlis cift haber verir ama eslesmez', (tester) async {
      MatchPair? wrongLeft;
      var correctCalls = 0;
      await pumpBoard(
        tester,
        onCorrect: (_) => correctCalls++,
        onWrong: (l, r) => wrongLeft = l,
      );

      await tester.tap(leftTile(tester, 'Robot'));
      await tester.pumpAndSettle();
      await tester.tap(rightTile(tester, 'Döngü'));
      await tester.pump();

      expect(wrongLeft?.id, 'a');
      expect(correctCalls, 0);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('sag kutuya once dokunmak bir sey yapmaz', (tester) async {
      var calls = 0;
      await pumpBoard(tester,
          onCorrect: (_) => calls++, onWrong: (_, __) => calls++);
      await tester.tap(rightTile(tester, 'Robot'));
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('tum ciftler bitince tamamlandi bildirilir', (tester) async {
      var done = false;
      await pumpBoard(tester, onCompleted: () => done = true);

      for (final p in pairs) {
        await tester.tap(leftTile(tester, p.left));
        await tester.pumpAndSettle();
        await tester.tap(rightTile(tester, p.right));
        await tester.pumpAndSettle();
      }
      expect(done, isTrue);
    });

    testWidgets('her cift kendi rengini ve numarasini alir', (tester) async {
      // Eslesen ciftleri birlestiren cizgiler kaldirildi; eslesmeyi
      // artik ortak renk ve ortak numara anlatiyor. Ikinci cift birinci
      // ciftle ayni numarayi almamali, yoksa hangi kutunun hangisiyle
      // esli oldugu yine belirsiz kalir.
      await pumpBoard(tester);

      await tester.tap(leftTile(tester, 'Loop'));
      await tester.pumpAndSettle();
      await tester.tap(rightTile(tester, 'Döngü'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsNWidgets(2));

      await tester.tap(leftTile(tester, 'Robot'));
      await tester.pumpAndSettle();
      await tester.tap(rightTile(tester, 'Robot'));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsNWidgets(2));
      expect(find.text('1'), findsNWidgets(2));
    });

    testWidgets('eslesen kutu ekranda KALIR', (tester) async {
      // Kaldirmak listeyi yeniden diziyor ve cocugun dokunmak uzere
      // oldugu kutu yerinden oynuyor.
      await pumpBoard(tester);
      await tester.tap(leftTile(tester, 'Loop'));
      await tester.pumpAndSettle();
      await tester.tap(rightTile(tester, 'Döngü'));
      await tester.pumpAndSettle();

      expect(find.text('Loop'), findsOneWidget);
      expect(find.text('Döngü'), findsOneWidget);
      // Eslesme ortak renk VE ortak numara ile isaretleniyor; ilk
      // eslesen cift 1 numarayi aliyor, iki kutuda da.
      expect(find.text('1'), findsNWidgets(2));
    });

    testWidgets('eslesen kutuya tekrar dokunmak bir sey yapmaz',
        (tester) async {
      var calls = 0;
      await pumpBoard(tester, onCorrect: (_) => calls++);
      await tester.tap(leftTile(tester, 'Loop'));
      await tester.pumpAndSettle();
      await tester.tap(rightTile(tester, 'Döngü'));
      await tester.pumpAndSettle();
      expect(calls, 1);

      await tester.tap(leftTile(tester, 'Loop'));
      await tester.pumpAndSettle();
      await tester.tap(rightTile(tester, 'Döngü'));
      await tester.pumpAndSettle();
      expect(calls, 1);
    });
  });

  group('surukleme', () {
    testWidgets('sol kutudan dogru kutuya surukleyince eslesir',
        (tester) async {
      MatchPair? correct;
      await pumpBoard(tester, onCorrect: (p) => correct = p);

      final from = tester.getCenter(leftTile(tester, 'Robot'));
      final to = tester.getCenter(rightTile(tester, 'Robot'));

      final gesture = await tester.startGesture(from);
      // Once yatay bir adim: jest arenasinda yatay surukleme kazansin.
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      await gesture.moveTo(to);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(correct?.id, 'a', reason: 'surukleme eslesmeyi tetiklemeli');
    });

    testWidgets('bosluga birakmak deneme sayilmaz', (tester) async {
      var calls = 0;
      await pumpBoard(
        tester,
        onCorrect: (_) => calls++,
        onWrong: (_, __) => calls++,
      );

      final from = tester.getCenter(leftTile(tester, 'Robot'));
      final gesture = await tester.startGesture(from);
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      await gesture.moveTo(const Offset(200, 4));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(calls, 0);
    });

    testWidgets('yanlis kutuya surukleyince yanlis bildirilir', (tester) async {
      MatchPair? wrongRight;
      await pumpBoard(tester, onWrong: (_, r) => wrongRight = r);

      final from = tester.getCenter(leftTile(tester, 'Robot'));
      final to = tester.getCenter(rightTile(tester, 'Sensör'));

      final gesture = await tester.startGesture(from);
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      await gesture.moveTo(to);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(wrongRight?.id, 'b');
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('surukleme kapaliyken dokunma calismaya devam eder',
        (tester) async {
      MatchPair? correct;
      await pumpBoard(tester, enableDrag: false, onCorrect: (p) => correct = p);
      await tester.tap(leftTile(tester, 'Robot'));
      await tester.pumpAndSettle();
      await tester.tap(rightTile(tester, 'Robot'));
      await tester.pumpAndSettle();
      expect(correct?.id, 'a');
    });
  });

  group('erisilebilirlik', () {
    testWidgets('kutular kelimesini ve durumunu bildirir', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBoard(tester);

      // Quizlet'in gercek degerlendirmelerinde en sert erisilebilirlik
      // sikayeti "ekran okuyucu bana sadece 'Button' diyor" idi. Kutu
      // kendi kelimesini ve eslesip eslesmedigini soylemeli.
      expect(
        tester.getSemantics(leftTile(tester, 'Loop')).label,
        contains('Loop'),
      );

      await tester.tap(leftTile(tester, 'Loop'));
      await tester.pumpAndSettle();
      await tester.tap(rightTile(tester, 'Döngü'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(leftTile(tester, 'Loop')).value,
        contains('eşleşti'),
      );
      handle.dispose();
    });
  });
}
