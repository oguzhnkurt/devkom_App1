// UCRETSIZ TANISMA SURESI (6 Kasim 2026, kullanici karari)
//
// Ucretsiz deneme kaldirildi. Yeni kullanici uygulamada 4 dakika (on planda)
// serbest; sure dolunca odeme ekrani kapatilamaz bicimde geliyor. Ders/oyun
// ortasinda kesilmiyor: ana ekrana donmesi bekleniyor, en gec 6. dakikada.
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/auth/abonelik_kapisi.dart';
import 'package:devkom_app/screens/subscription_screen.dart';
import 'package:devkom_app/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _AboneDegil extends SubscriptionService {
  @override
  Future<bool?> aboneMi({String? userId}) async => false;
}

class _Saat {
  DateTime t = DateTime(2026, 11, 6, 12);
  DateTime call() => t;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final kanal in const [
      'com.llfbandit.app_links/events',
      'com.llfbandit.app_links/messages',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(kanal), (_) async => null);
    }
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
  });

  Future<(_Saat, AuthProvider)> kur(WidgetTester tester,
      {Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr', ...prefs});
    final s = SettingsProvider();
    await s.setLocale(const Locale('tr'));
    final auth = AuthProvider();
    final saat = _Saat();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: s),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ],
      child: MaterialApp(
        home: AbonelikKapisi(
          servis: _AboneDegil(),
          saat: saat.call,
          child: Builder(
            builder: (c) => Scaffold(
              body: Column(children: [
                const Text('ANA EKRAN'),
                TextButton(
                  onPressed: () => Navigator.push(
                      c,
                      MaterialPageRoute(
                          builder: (_) =>
                              const Scaffold(body: Text('DERS')))),
                  child: const Text('dersi ac'),
                ),
              ]),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    return (saat, auth);
  }

  Future<void> ilerle(WidgetTester tester, _Saat saat, Duration d) async {
    // 2 saniyelik tiklerle gercek akisa benzet.
    var kalan = d.inSeconds;
    while (kalan > 0) {
      saat.t = saat.t.add(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      kalan -= 2;
    }
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('ilk acilista uygulama acik, 4 dakika sonra odeme ekrani',
      (tester) async {
    final (saat, _) = await kur(tester);
    expect(find.text('ANA EKRAN'), findsOneWidget);
    expect(find.byType(SubscriptionScreen), findsNothing);

    await ilerle(tester, saat, const Duration(minutes: 3, seconds: 50));
    expect(find.text('ANA EKRAN'), findsOneWidget);

    await ilerle(tester, saat, const Duration(seconds: 20));
    expect(find.byType(SubscriptionScreen), findsOneWidget);
    final ekran =
        tester.widget<SubscriptionScreen>(find.byType(SubscriptionScreen));
    expect(ekran.zorunlu, isTrue);
    final p = await SharedPreferences.getInstance();
    expect(p.getInt(AbonelikKapisi.sureAnahtari),
        greaterThanOrEqualTo(AbonelikKapisi.ucretsizSure.inSeconds));
    await tester.pump(const Duration(seconds: 13)); // urun yukleme zamanlayicisi
  });

  testWidgets('derste sure dolarsa ders bitene kadar bekler, en gec 6. dk',
      (tester) async {
    final (saat, _) = await kur(tester);
    await tester.tap(find.text('dersi ac'));
    await tester.pumpAndSettle();
    expect(find.text('DERS'), findsOneWidget);

    await ilerle(tester, saat, const Duration(minutes: 5));
    expect(find.text('DERS'), findsOneWidget,
        reason: 'Sure doldu ama cocuk derste: kesilmemeli.');
    expect(find.byType(SubscriptionScreen), findsNothing);

    await ilerle(tester, saat, const Duration(minutes: 1, seconds: 4));
    expect(find.byType(SubscriptionScreen), findsOneWidget);
    expect(find.text('DERS'), findsNothing);
    await tester.pump(const Duration(seconds: 13));
  });

  testWidgets('sure daha once dolduysa acilista dogrudan odeme ekrani',
      (tester) async {
    await kur(tester, prefs: {AbonelikKapisi.sureAnahtari: 240});
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SubscriptionScreen), findsOneWidget);
    expect(find.text('ANA EKRAN'), findsNothing);
    await tester.pump(const Duration(seconds: 13));
  });

  testWidgets('arka planda gecen sure sayilmiyor', (tester) async {
    final (saat, _) = await kur(tester);
    await ilerle(tester, saat, const Duration(minutes: 2));
    for (final d in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(d);
    }
    saat.t = saat.t.add(const Duration(hours: 1));
    await tester.pump(const Duration(seconds: 4));
    for (final d in const [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(d);
    }
    await ilerle(tester, saat, const Duration(minutes: 1));
    expect(find.text('ANA EKRAN'), findsOneWidget,
        reason: 'On planda 3 dakika gecti; arka plandaki 1 saat sayilmamali.');
    // Supabase on plana donuste otomatik yenileme zamanlayicisi kuruyor;
    // testten once tekrar arka plana alip durduruyoruz.
    for (final d in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(d);
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
