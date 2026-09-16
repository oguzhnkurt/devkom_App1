// Yazarken takılma: süsleme animasyonları klavye açıkken duruyor mu?
//
// KULLANICI ŞUNU BİLDİRDİ: "özellikle üretilmiş ismi düzenlerken donuyor".
//
// SEBEP: iki animasyon hiç durmuyordu.
//  * Devi sürekli nefes alıyor (`Mascot`) — takma ad düzenleme alt
//    sayfası açıldığında altta kalan profil ekranında çalışmaya devam
//    ediyor, çünkü alt sayfa opak bir rota değil; Flutter'ın ticker'ları
//    otomatik durdurma davranışı burada devreye girmiyor.
//  * Karşılama panelindeki blob animasyonu (`_PanelDrift`) saniyede 60
//    kez panel boyunda bir CustomPaint çiziyor.
//
// Her tuşa basışta metin alanı yeniden çiziliyor; aynı anda dönen bir
// animasyon varken bu, yazmanın takılması olarak hissediliyor. İkisi de
// artık klavye açıkken duruyor — nefes almanın durduğunu kimse fark
// etmiyor, takılmayı herkes ediyor.
//
// Ayrıca ikisi de kendi `RepaintBoundary`'sinde: sürekli çizilen bir
// şey, üstündeki metnin ve gölgelerin de her karede yeniden
// rasterlenmesine yol açmamalı.
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/auth/onboarding_flow_screen.dart';
import 'package:devkom_app/widgets/mascot.dart';

Widget _withInsets(double bottom, Widget child) => MediaQuery(
      data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: bottom)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: child),
      ),
    );

void main() {
  testWidgets('Devi klavye kapaliyken nefes aliyor', (tester) async {
    await tester.pumpWidget(_withInsets(0, const Mascot(size: 80)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(SchedulerBinding.instance.transientCallbackCount, greaterThan(0),
        reason: 'klavye yokken animasyon calismali');
  });

  testWidgets('Devi klavye acikken duruyor', (tester) async {
    await tester.pumpWidget(_withInsets(320, const Mascot(size: 80)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(SchedulerBinding.instance.transientCallbackCount, 0,
        reason: 'klavye acikken sus animasyonu calismamali');
  });

  testWidgets('Klavye kapaninca Devi tekrar basliyor', (tester) async {
    await tester.pumpWidget(_withInsets(320, const Mascot(size: 80)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(SchedulerBinding.instance.transientCallbackCount, 0);

    await tester.pumpWidget(_withInsets(0, const Mascot(size: 80)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(SchedulerBinding.instance.transientCallbackCount, greaterThan(0),
        reason: 'klavye kapaninca animasyon geri gelmeli');
  });

  testWidgets('Devi kendi katmaninda ciziliyor', (tester) async {
    await tester.pumpWidget(_withInsets(0, const Mascot(size: 80)));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(RepaintBoundary), findsWidgets,
        reason: 'surekli cizilen animasyon kendi katmaninda olmali');
  });

  testWidgets('Karsilama ekraninda klavye acikken hicbir sus animasyonu '
      'calismiyor', (tester) async {
    // GERCEK EKRAN. Karsilama ekraninda ayni anda donen UC animasyon
    // vardi: panel bloblari, ustteki suzulen simge ve Devi'nin nefesi.
    // Ucu de tam ekran boyunda bir katmani her karede yeniden
    // cizdiriyordu; cocuk takma adini yazarken tus basina bir de metin
    // alani yeniden ciziliyor ve yazmak takiliyordu.
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final settings = SettingsProvider();

    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    Widget app(double keyboard) => ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
          child: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              viewInsets: EdgeInsets.only(bottom: keyboard),
            ),
            child: const MaterialApp(
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: OnboardingFlowScreen(),
            ),
          ),
        );

    await tester.pumpWidget(app(0));
    await tester.pump(const Duration(milliseconds: 300));
    expect(SchedulerBinding.instance.transientCallbackCount, greaterThan(0),
        reason: 'klavye yokken ekran canli olmali');

    // Klavye acilinca once TEK SEFERLIK animasyonlar calisiyor
    // (AnimatedContainer, gecisler). Onlarin bitmesini bekliyoruz;
    // aradigimiz sey SUREKLI donenler.
    await tester.pumpWidget(app(336));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(SchedulerBinding.instance.transientCallbackCount, 0,
        reason: 'klavye acikken surekli donen sus animasyonu kalmamali');
  });
}
