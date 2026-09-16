// Regresyon: tanitim akisindaki "rastgele ad" dugmeleri.
//
// Dugme bir zamanlar sessizce calismiyordu. Sebep kodun kendisinde
// degil, dugmenin okudugu `_lang` alanindaydi: o bir getter'di ve
// `context.watch` ile SettingsProvider'i dinliyordu. `watch` yalnizca
// build sirasinda cagrilabilir; bir onPressed icinden cagrilinca
// provider assertion atiyor ve islem hic baslamiyordu. Ayni kusur
// _finish() icinde de vardi: takma ad, ogrenci profili ve "onboarding
// gorundu" isareti try/catch'e dusup hic kaydedilmiyordu.
//
// Akis o zamandan beri degisti: artik maskot secimiyle basliyor ve
// ADI SORULAN IKI SEY var — once maskotun adi, sonra cocugun takma
// adi. Ikisinin de kendi zar dugmesi var. Bu test akisi bastan sona
// yuruyup zar dugmesi olan HER sayfada dugmeye basiyor; ikisinden
// biri sessizce bozulursa test kalir.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/auth/onboarding_flow_screen.dart';

/// Birkac KARE ilerlet.
///
/// `pump(Duration(seconds: 2))` saati iki saniye ileri alir ama TEK bir
/// kare cizer. Sayfa gecisi bir AnimationController ile calisiyor ve o
/// denetleyicinin ilk tiki BIR SONRAKI karede geliyor; tek karelik bir
/// pump'ta gecis hic baslamiyor ve ekranda hala onceki sayfa duruyor.
///
/// Bu, uygulamada bir kusur DEGIL: gercekte her 16 ms'de bir kare
/// ciziliyor ve gecisin ilk karesinde eski sayfanin durmasi zaten
/// dogru davranis (yenisi bir kare gorunup kaybolsaydi, kullanicinin
/// bildirdigi "araya bir sayfa giriyor" kusuru olurdu). Testin kare
/// saymasi gerekiyor.
///
/// `pumpAndSettle` KULLANILAMAZ: ust paneldeki yumusak sekiller
/// surekli donen bir animasyon, agac hicbir zaman durulmuyor.
Future<void> kareler(WidgetTester tester,
    {int adet = 12, int ms = 100}) async {
  for (var i = 0; i < adet; i++) {
    await tester.pump(Duration(milliseconds: ms));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('zar dugmeleri adi gercekten degistiriyor', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
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
    await kareler(tester);

    Finder forward() => find.byWidgetPredicate((w) =>
        w is Icon && w.icon == Icons.arrow_forward_rounded && w.size == 22);

    // Zar dugmesi olan sayfalarin ACILIS degerleri, sirayla.
    final acilisDegerleri = <String>[];

    // Akista sonlu sayida sayfa var; dongu kacarsa test asilmasin diye
    // ust sinir koyuyoruz.
    for (var adim = 0; adim < 30; adim++) {
      // Ilk gorev: iki blogu birlestir. Gorev bitmeden ileri tusu pasif.
      final draggable = find.byType(Draggable<String>);
      if (draggable.evaluate().isNotEmpty) {
        final target = find.byType(DragTarget<String>);
        await tester.drag(
          draggable.first,
          tester.getCenter(target.first) - tester.getCenter(draggable.first),
        );
        await kareler(tester);
        continue;
      }

      // Ad sorulan sayfa. Acilis degeri sayfaya gore degisiyor
      // (asagida denetleniyor); burada aranan sey zar dugmesinin alani
      // gercekten degistirmesi.
      final zar = find.byIcon(Icons.casino_rounded);
      final alan = find.byType(TextField);
      if (zar.evaluate().isNotEmpty && alan.evaluate().isNotEmpty) {
        final once = tester.widget<TextField>(alan.first).controller!.text;
        acilisDegerleri.add(once);

        // Uretec rastgele; ayni adi ust uste vermesi mumkun. Bes
        // denemede hic degismiyorsa dugme gercekten calismiyordur.
        var sonra = once;
        for (var deneme = 0; deneme < 5 && sonra == once; deneme++) {
          await tester.tap(zar.first);
          await kareler(tester);
          expect(tester.takeException(), isNull);
          sonra = tester.widget<TextField>(alan.first).controller!.text;
        }
        expect(sonra, isNot(once), reason: 'zar dugmesi yeni bir ad onermeli');
        expect(sonra, isNotEmpty);
        if (acilisDegerleri.length == 2) break;
      }

      if (forward().evaluate().isEmpty) break;
      await tester.tap(forward());
      await kareler(tester);
    }

    expect(acilisDegerleri.length, 2,
        reason: 'akista iki zar dugmesi bekleniyordu (maskot adi + takma ad), '
            'bulunan: ${acilisDegerleri.length}');

    // Maskotun ad alani BILEREK bos aciliyor: altindaki ipucu zaten
    // karakterin kendi adini gosteriyor, hicbir sey yapmayan cocuk o
    // adi korumus oluyor. Takma ad alani ise dolu aciliyor, cunku
    // orada bos birakmak bir secenek degil.
    expect(acilisDegerleri[0], isEmpty,
        reason: 'maskot adi alani onerilen bir adla acilmis — ipucu '
            'olarak duran karakter adiyla celisiyor');
    expect(acilisDegerleri[1], isNotEmpty,
        reason: 'takma ad alani bos aciliyor');
  });
}
