// DevAI sohbet ekranı.
//
// Zemin düz bir mor geçişti, asistanın yüzü yabancı bir robot ikonuydu,
// öneri kutucuklarının ne olduğu yazmıyordu ve gönder tuşu boş kutuda
// da renkliydi — basınca kırmızı bir doğrulama hatası çıkıyordu.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/utils/app_localizations.dart';
import 'package:devkom_app/screens/devchat_screen.dart';
import 'package:devkom_app/widgets/mascot.dart';

Future<void> _ciz(WidgetTester tester, String dil) async {
  SharedPreferences.setMockInitialValues({'language_code': dil});
  final settings = SettingsProvider();
  await settings.setLocale(Locale(dil));

  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        locale: Locale(dil),
        supportedLocales: const [
          Locale('tr'),
          Locale('en'),
          Locale('de'),
          Locale('es')
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const DevAiChatScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  final src = File('lib/screens/devchat_screen.dart').readAsStringSync();

  testWidgets('asistanın yüzü uygulamanın maskotu', (tester) async {
    addTearDown(tester.view.reset);
    await _ciz(tester, 'tr');
    expect(tester.takeException(), isNull);
    // Baslikta ve her asistan balonunun yaninda Devi var.
    expect(find.byType(Mascot), findsWidgets);
    expect(find.byIcon(Icons.smart_toy), findsNothing,
        reason: 'Yabancı robot ikonu geri gelmiş.');
  });

  testWidgets('önerilerin ne olduğu yazıyor', (tester) async {
    addTearDown(tester.view.reset);
    await _ciz(tester, 'tr');
    expect(find.text('Şunu sorabilirsin'), findsOneWidget);
  });

  testWidgets('boş kutuda gönder tuşu pasif', (tester) async {
    addTearDown(tester.view.reset);
    await _ciz(tester, 'tr');
    final tus = tester.widget<IconButton>(
        find.ancestor(of: find.byIcon(Icons.send), matching: find.byType(IconButton)));
    expect(tus.onPressed, isNull,
        reason: 'Boş mesajda tuş basılabilir — çocuğa hata gösteriliyor.');

    await tester.enterText(find.byType(TextField), 'merhaba');
    await tester.pump(const Duration(milliseconds: 300));
    final tus2 = tester.widget<IconButton>(
        find.ancestor(of: find.byIcon(Icons.send), matching: find.byType(IconButton)));
    expect(tus2.onPressed, isNotNull);
  });

  testWidgets('dört dilde de açılıyor', (tester) async {
    addTearDown(tester.view.reset);
    for (final dil in const ['en', 'de', 'es']) {
      await _ciz(tester, dil);
      expect(tester.takeException(), isNull, reason: '$dil dilinde hata');
    }
  });

  test('zaman etiketi dört dilde', () {
    // Balonun altindaki saat tamamen Turkceydi.
    for (final yazi in const [
      "tr: 'Şimdi'",
      "en: 'Just now'",
      "de: 'Gerade eben'",
      "es: 'Ahora mismo'",
    ]) {
      expect(src.contains(yazi), isTrue, reason: 'eksik: $yazi');
    }
    expect(src.contains("return 'Şimdi';"), isFalse);
  });

  test('zemin akıntıyı kullanıyor', () {
    expect(src.contains('KodAkintisi('), isTrue,
        reason: 'Sohbet zemini yine düz bir renk geçişi.');
  });
}
