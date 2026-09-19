// Maskot widget testlerinde DONMAMALI.
//
// NEDEN BU TEST VAR
// -----------------
// `Mascot` açılışta kutlama görselini önceden ön belleğe alıyor:
// `assets/maskot/devi_kutlama.webp`. O dosya **hareketli** bir WebP —
// 90 kare. Widget testlerinin sahte zamanlı (fake-async) motoru
// hareketli görsellerin karelerini çözmüyor. Korumasız bırakılırsa iki
// şeyden biri oluyor:
//
//   * `precacheImage` hiç dönmüyor ve test 10 dakika sonra
//     `TimeoutException` ile düşüyor,
//   * ya da bir sonraki `pump`,
//     `MultiFrameImageStreamCompleter._handleAppFrame` içindeki
//     `_nextFrame != null` savını düşürüyor.
//
// 19 Eylül 2026'da mağaza görsellerini üreten araç
// (`test/appstore_shots_test.dart`) tam bu yüzden maskotlu ilk
// ekranında 10 dakika donmuş, ardından gelen testler de "Reentrant
// call to runAsync() denied" ile düşmüştü: 3 test hatası, iki mağaza
// görseli üretilemedi.
//
// Koruma `Mascot._kutlamayiHazirla` içinde: test motorunda
// (`WidgetsBinding.instance` bir `WidgetsFlutterBinding` değilken) ön
// belleğe alma hiç başlamıyor. Koruma kaldırılırsa bu test düşer.
//
// Zaman aşımı bilerek kısa: donma hâlinde 10 dakika beklenmesin.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/widgets/mascot.dart';

Widget _sar(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  for (final mood in MascotMood.values) {
    testWidgets(
      'maskot ${mood.name} halinde cizilip donmuyor',
      (tester) async {
        await tester.pumpWidget(_sar(Mascot(mood: mood)));
        // Birkaç kare: hareketli görsel ön belleğe alınmış olsaydı
        // sav tam burada düşerdi.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(seconds: 1));

        expect(tester.takeException(), isNull);
        expect(find.byType(Mascot), findsOneWidget);
      },
      timeout: const Timeout(Duration(seconds: 45)),
    );
  }

  testWidgets(
    'maskot bagimlilik degisimlerinde takilmiyor',
    (tester) async {
      // `didChangeDependencies` her MediaQuery değişiminde çalışıyor;
      // ön belleğe alma orada tetikleniyordu. Klavye açılıp kapanıyor.
      await tester.pumpWidget(_sar(const Mascot(mood: MascotMood.cheering)));
      await tester.pump(const Duration(milliseconds: 200));

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.reset);
      await tester.pump(const Duration(milliseconds: 200));

      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );
}
