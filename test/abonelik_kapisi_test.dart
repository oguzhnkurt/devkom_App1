// Zorunlu abonelik kapisi (hard paywall, 1.0.18).
//
// Karar (30 Eki 2026): ucretsiz kullanim yok; tanitimdan sonra satin alma
// ekrani. Bu testler kurallari kilitliyor:
//  * ana ekran (iki dal da) kapinin arkasinda;
//  * suresiz `is_pro` tek basina kapiyi acmiyor (iptal edilen deneme de
//    true kaliyordu), sureli hediye Pro aciyor;
//  * zorunlu modda geri ile kapanmiyor, cikis teklifinden sonra kapat
//    tusu gizleniyor, Hesap baglantisi var.
import 'dart:io';

import 'package:devkom_app/models/user_model.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/auth/abonelik_kapisi.dart';
import 'package:devkom_app/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserModel _u({bool isPro = false, DateTime? bitis}) => UserModel(
      uid: 'u1',
      email: '',
      displayName: 'Test',
      role: UserRole.student,
      createdAt: DateTime(2026),
      isPro: isPro,
      proExpiryDate: bitis,
    );

void main() {
  test('ana ekranin iki dali da AbonelikKapisi arkasinda', () {
    final s = File('lib/screens/auth/auth_wrapper.dart').readAsStringSync();
    expect(s, contains('AbonelikKapisi(child: RoleBasedHomeScreen())'));
    expect(s, contains('AbonelikKapisi(child: UnifiedHomeScreen())'));
    expect(RegExp(r'return const RoleBasedHomeScreen\(\)').hasMatch(s),
        isFalse);
    expect(RegExp(r'return const UnifiedHomeScreen\(\)').hasMatch(s),
        isFalse);
  });

  group('sureli hediye Pro', () {
    final simdi = DateTime(2026, 10, 30);
    test('suresiz is_pro kapiyi acmaz', () {
      expect(sureliHediyeVar(_u(isPro: true), simdi),
          isFalse);
    });
    test('gelecekte bitis tarihi olan Pro acar', () {
      expect(
          sureliHediyeVar(
              _u(isPro: true, bitis: DateTime(2027)), simdi),
          isTrue);
    });
    test('suresi gecmis Pro acmaz', () {
      expect(
          sureliHediyeVar(
              _u(isPro: true, bitis: DateTime(2026, 1, 1)), simdi),
          isFalse);
    });
    test('kullanici yok', () {
      expect(sureliHediyeVar(null, simdi), isFalse);
    });
  });

  test('Adapty kaynakli kontrol false yazmiyor (hediye Pro silinmesin)', () {
    final s =
        File('lib/services/subscription_service.dart').readAsStringSync();
    final i = s.indexOf('Future<bool?> aboneMi(');
    expect(i, greaterThan(0));
    final govde = s.substring(i, s.indexOf('Future<AdaptyPaywall?>', i));
    expect(govde, contains('if (aktif) await _syncProStatusToSupabase'));
    expect(govde, isNot(contains('isPro: aktif')));
  });

  test('zorunlu modda satin alma ebeveyn kapisinin arkasinda', () {
    final s =
        File('lib/screens/subscription_screen.dart').readAsStringSync();
    final i = s.indexOf('Future<void> _purchase() async {');
    final govde = s.substring(i, s.indexOf('purchaseProduct', i));
    expect(govde, contains('if (widget.zorunlu)'));
    expect(govde, contains('ParentGate.verify'));
  });

  testWidgets('zorunlu modda geri ile kapanmiyor, Hesap baglantisi var',
      (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'en'});
    final settings = SettingsProvider();
    await settings.setLocale(const Locale('en'));
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settings,
        child: const MaterialApp(home: SubscriptionScreen(zorunlu: true)),
      ),
    );
    await tester.pump(const Duration(seconds: 13));

    final pop = tester.widget<PopScope>(
        find.byWidgetPredicate((w) => w is PopScope).first);
    expect(pop.canPop, isFalse);
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('normal modda Hesap baglantisi yok', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'en'});
    final settings = SettingsProvider();
    await settings.setLocale(const Locale('en'));
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settings,
        child: const MaterialApp(home: SubscriptionScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 13));
    expect(find.text('Account'), findsNothing);
  });
}
