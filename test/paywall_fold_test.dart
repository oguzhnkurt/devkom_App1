// PLANLAR KAYDIRMADAN GORUNMELI.
//
// Kullanicinin sikayeti buydu: fiyati gormek icin sayfayi asagi
// kaydirmak gerekiyordu. Fiyati saklamak hem satisi dusuruyor hem de
// App Store'un "teklif acikca gorunsun" beklentisiyle ters.
//
// Bu test gercek ekrani telefon olcusunde cizip PLANLARIN BASLADIGI
// NOKTA ile sabit alt cubugun arasinda kalan yeri OLCUYOR. Adapty
// testte urun veremedigi icin oraya "planlara ulasilamiyor" karti
// geliyor; bizim olctugumuz sey o kartin ustu, yani planlarin
// baslayacagi y konumu — kartin kendisi degil.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sahte_magaza.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/subscription_screen.dart';
import 'package:devkom_app/theme.dart';

Future<void> _fontlar() async {
  final l = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    l.addFont(Future.value(
        File('assets/fonts/Nunito-$w.ttf').readAsBytesSync().buffer.asByteData()));
  }
  await l.load();
}

void main() {
  // Gercek yazi tipi: test yazi tipi (Ahem) her harfi kare ciziyor ve
  // olculer gercekte oldugundan buyuk cikiyor.
  setUpAll(_fontlar);
  for (final lang in ['tr', 'en', 'de', 'es', 'fr', 'ru', 'ja', 'ar']) {
   for (final zorunlu in [true, false]) {
    testWidgets('$lang (zorunlu: $zorunlu): planlar kaydirmadan tamamen gorunuyor', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': lang});
      final settings = SettingsProvider();
      // 4 dil disinda ceviri tablosu varliktan (gercek IO) yukleniyor.
      await tester.runAsync(() => settings.setLocale(Locale(lang)));

      // iPhone 13/14/15 mantiksal olcusu.
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
          child: MaterialApp(
              theme: AppTheme.lightTheme(),
              home: SubscriptionScreen(zorunlu: zorunlu, servis: SahteMagaza())),
        ),
      );
      // Adapty cagrisi gercek async; sahte zaman onu ilerletmiyor.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Planlarin basladigi nokta: ya "Planini sec" basligi ya da
      // urun cekilemediginde onun yerine gelen kart.
      final plansAnchor = find.byKey(const ValueKey('paywall-plans'));
      expect(plansAnchor, findsOneWidget,
          reason: 'plan bölümünün başlangıcı işaretlenmemiş');

      final plansBottom = tester.getBottomLeft(plansAnchor).dy;
      final ctaTop = tester.getTopLeft(find.byKey(const ValueKey('pro-cta'))).dy;
      // Alt cubugun ust kenari dugmenin ~10 px ustunde.
      expect(plansBottom, lessThanOrEqualTo(ctaTop - 10),
          reason: '$lang: plan kartlari alt cubugun altinda kaliyor '
              '(plan alti $plansBottom, buton ustu $ctaTop) — fiyati gormek '
              'icin kaydirmak gerekir');
      await tester.pump(const Duration(seconds: 13));
    });
   }
  }
}
