import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/ui/sigdir.dart';

/// Kutu: sabit yukseklikte bir alan, icinde Sigdir.
Widget kutu({required double yukseklik, required Widget child}) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            height: yukseklik,
            child: Sigdir(child: child),
          ),
        ),
      ),
    );

Widget liste(int adet, {void Function(int)? onTap}) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < adet; i++)
          GestureDetector(
            onTap: () => onTap?.call(i),
            child: Container(
              key: ValueKey('kart$i'),
              height: 100,
              color: Colors.blue,
              alignment: Alignment.center,
              child: Text('kart $i'),
            ),
          ),
      ],
    );

void main() {
  testWidgets('sigan icerige dokunulmuyor', (tester) async {
    // 2 x 100 = 200, kutu 400: olcek 1 kalmali.
    await tester.pumpWidget(kutu(yukseklik: 400, child: liste(2)));
    expect(tester.getSize(find.byKey(const ValueKey('kart0'))).height, 100);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sigmayan icerik kucultulerek tamami gorunuyor',
      (tester) async {
    // 5 x 100 = 500, kutu 300: olcek 0.6.
    await tester.pumpWidget(kutu(yukseklik: 300, child: liste(5)));
    expect(tester.takeException(), isNull);

    // Cocuk kendi olceginde 500/0.6 degil, 500 yuksekliginde yerlesiyor
    // (kutu 300 / 0.6 = 500) ve 0.6 ile cizildigi icin 300'e oturuyor.
    expect(tester.getSize(find.byType(Column)).height, closeTo(500, 0.5));

    // Asil mesele: SON kart da ekranin icinde. Kaydirma yok, hepsi
    // gorunur olmali.
    final kutuUst = tester.getTopLeft(find.byType(Sigdir)).dy;
    final kutuAlt = tester.getBottomLeft(find.byType(Sigdir)).dy;
    final sonKart = tester.getRect(find.byKey(const ValueKey('kart4')));
    expect(sonKart.bottom, lessThanOrEqualTo(kutuAlt + 0.5));
    expect(tester.getRect(find.byKey(const ValueKey('kart0'))).top,
        greaterThanOrEqualTo(kutuUst - 0.5));
  });

  testWidgets('kucultulmus icerikte dokunus dogru yere gidiyor',
      (tester) async {
    int? dokunulan;
    await tester.pumpWidget(
      kutu(yukseklik: 300, child: liste(5, onTap: (i) => dokunulan = i)),
    );
    // Donusum hit test'e uygulanmazsa dokunus eski, buyuk yerlesime
    // gider ve yanlis kart secilir.
    await tester.tap(find.byKey(const ValueKey('kart4')));
    await tester.pump();
    expect(dokunulan, 4);

    await tester.tap(find.byKey(const ValueKey('kart0')));
    await tester.pump();
    expect(dokunulan, 0);
  });

  testWidgets('taban olcegin altina inilmiyor', (tester) async {
    // 20 x 100 = 2000, kutu 100 -> olcek 0.05 olurdu; taban 0.55.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 100,
              child: Sigdir(enAz: 0.55, child: liste(20)),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull,
        reason: 'Tabana dayanan icerik Flutter tasma uyarisi vermemeli.');
    // Taban uygulandigi icin cocuk DOGAL yuksekliginde yerlesiyor
    // (20 x 100). Tasan kisim kirpiliyor; kutu 100'de kaliyor.
    expect(tester.getSize(find.byType(Column)).height, 2000);
    expect(tester.getSize(find.byType(Sigdir)).height, 100);
  });

  testWidgets('olculemeyen cocukta yerlesim bozulmuyor', (tester) async {
    // Kendi icinde kaydirilan bir liste dogal yuksekligini bildirmiyor.
    await tester.pumpWidget(
      kutu(
        yukseklik: 200,
        child: ListView(
          children: const [SizedBox(height: 600)],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ListView)).height, 200);
  });

  testWidgets('tekrar tekrar cizilince katman hatasi vermiyor',
      (tester) async {
    // Kucultme bir Transform (ve gerekirse Clip) katmani aciyor. O
    // katman duz bir alanda tutulursa cerceve onu atiyor ve bir sonraki
    // karede "Failed assertion: '!_debugDisposed'" patliyor; simulatorde
    // acilis ekrani bu hatayi saniyede onlarca kez basmisti. LayerHandle
    // katmani canli tutuyor.
    var adet = 5;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: StatefulBuilder(
                builder: (context, setState) => Column(
                  children: [
                    Expanded(child: Sigdir(child: liste(adet))),
                    TextButton(
                      onPressed: () => setState(() => adet = adet == 5 ? 8 : 5),
                      child: const Text('degistir'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('degistir'));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$i. cizimde patladi');
    }
  });

  test('katmanlar LayerHandle ile tutuluyor', () {
    final kod = File('lib/ui/sigdir.dart')
        .readAsLinesSync()
        .where((s) => !s.trimLeft().startsWith('//'))
        .join('\n');
    expect(kod.contains('LayerHandle<TransformLayer>'), isTrue);
    expect(kod.contains('LayerHandle<ClipRectLayer>'), isTrue);
    expect(RegExp(r'^\s*TransformLayer\?\s', multiLine: true).hasMatch(kod),
        isFalse,
        reason: 'Duz alanda tutulan katman cerceve tarafindan atiliyor.');
  });
}
