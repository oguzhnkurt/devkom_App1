// Karşılama akışının ilk görevi: iki bloğu birleştirme.
//
// NEDEN AYRI BİR TEST
// -------------------
// Bu, çocuğun uygulamada gördüğü İLK etkileşim. Bozulursa akış hemen
// orada duruyor ve kimse ileri gidemiyor. Görev bir kez yeniden yazıldı
// (elde çizilmiş kutular yerine gerçek Scratch yapboz blokları) ve o
// sırada sürükle-bırak mekaniği de değişti — `Draggable`ın tutma
// noktası, yuvanın ölçüsü, blokların iç içe geçmesi.
//
// Karşılama akışının bütününü test eden dosya (nickname_button_test)
// Material düğmeleri çizdiği için bazı ortamlarda gölgelendirici
// hatasına takılıyor; burada yalnızca görev widget'ı var, o yüzden her
// yerde koşuyor.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/widgets/first_task.dart';

void main() {
  testWidgets('blok yuvaya oturunca gorev cozuluyor', (tester) async {
    int? tries;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: FirstTask(onSolved: (t) => tries = t)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    final drag = find.byType(Draggable<String>);
    final target = find.byType(DragTarget<String>);
    expect(drag, findsOneWidget, reason: 'surukleneek blok ekranda olmali');
    expect(target, findsOneWidget, reason: 'bos yuva ekranda olmali');

    await tester.drag(drag, tester.getCenter(target) - tester.getCenter(drag));
    await tester.pump(const Duration(milliseconds: 1200));

    expect(tries, 1, reason: 'ilk denemede cozulmus sayilmali');
  });

  testWidgets('yanlis yere birakmak hata gostermiyor', (tester) async {
    // Kural: yanlis birakma HATA DEGIL. Ekranda kirmizi bir sey, "yanlis"
    // yazisi ya da uyari cikmamali; blok yerine donmeli, o kadar.
    var solved = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: FirstTask(onSolved: (_) => solved = true)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.drag(find.byType(Draggable<String>), const Offset(0, 260));
    await tester.pump(const Duration(milliseconds: 600));

    expect(solved, isFalse);
    expect(find.textContaining('anlış'), findsNothing);
    expect(find.textContaining('rong'), findsNothing);
    expect(find.byIcon(Icons.error), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
  });
}
