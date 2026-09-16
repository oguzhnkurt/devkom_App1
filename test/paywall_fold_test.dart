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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/subscription_screen.dart';
import 'package:devkom_app/ui/press_button.dart';

/// Plan seridi + "Planini sec" basligi icin gereken yer.
///
/// Sayi, _buildPlanChip'in KENDI olculerinden turetildi:
///   dolgu 12+12 = 24, rozet satiri 18, boslular 6+4 = 10,
///   donem yazisi ~16, fiyat ~22          -> ~90
///   "Planini sec" basligi ~22 + 12 bosluk -> ~34
///   nefes payi                            -> 10
///
/// DIKKAT: cip buyurse burasi da buyumeli. Adapty testte urun
/// vermedigi icin cipin gercek yuksekligi olculemiyor; bu yuzden sayi
/// elle turetildi ve simulatorde StoreKit fiyatlariyla dogrulanmali.
const double _neededForPlans = 90 + 34 + 10;

void main() {
  for (final lang in ['tr', 'en', 'de', 'es']) {
    testWidgets('$lang: planlara ekranda yer kalıyor', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': lang});
      final settings = SettingsProvider();
      await settings.setLocale(Locale(lang));

      // iPhone 13/14/15 mantiksal olcusu.
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
          child: const MaterialApp(home: SubscriptionScreen()),
        ),
      );
      // Adapty cagrisi gercek async; sahte zaman onu ilerletmiyor.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      });
      await tester.pump(const Duration(milliseconds: 300));

      // Planlarin basladigi nokta: ya "Planini sec" basligi ya da
      // urun cekilemediginde onun yerine gelen kart.
      final plansAnchor = find.byKey(const ValueKey('paywall-plans'));
      expect(plansAnchor, findsOneWidget,
          reason: 'plan bölümünün başlangıcı işaretlenmemiş');

      final plansTop = tester.getTopLeft(plansAnchor).dy;
      final ctaTop = tester.getTopLeft(find.byType(PressButton)).dy;
      final room = ctaTop - plansTop;

      expect(room, greaterThanOrEqualTo(_neededForPlans),
          reason: '$lang: planlar için $room piksel kalıyor, '
              '$_neededForPlans gerekiyor — üçüncü plan kartı ekranın '
              'altında kalır ve fiyatı görmek için kaydırmak gerekir');
    });
  }
}
