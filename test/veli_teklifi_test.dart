// Ilk dersten sonra veliye tek seferlik Pro sayfasi.
import 'dart:io';

import 'package:devkom_app/services/veli_teklifi_servisi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final s = VeliTeklifiServisi.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    s.sifirla();
  });
  tearDown(s.sifirla);

  test('ilk basarida bayrak kalkiyor', () async {
    expect(s.bekliyor, isFalse);
    await s.basariKaydet();
    expect(s.bekliyor, isTrue);
  });

  test('daha once gosterildiyse bir daha bayrak kalkmiyor', () async {
    SharedPreferences.setMockInitialValues({'veli_teklifi_gosterildi': true});
    await s.basariKaydet();
    expect(s.bekliyor, isFalse);
  });

  testWidgets('sayfa veliye konusuyor, fiyat ya da gun sayisi uydurmuyor',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: VeliTeklifiSayfasi(lang: 'en')),
    ));
    expect(find.text('First lesson done!'), findsOneWidget);
    expect(find.byKey(const ValueKey('veli_teklifi_incele')), findsOneWidget);
    expect(find.byKey(const ValueKey('veli_teklifi_sonra')), findsOneWidget);
    // Fiyat ve deneme suresi yalnizca magazadan gelir; burada sayi yok.
    final metinler = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' ');
    expect(RegExp(r'\d').hasMatch(metinler), isFalse);
  });

  testWidgets('dort dilde metin var', (tester) async {
    for (final lang in ['tr', 'en', 'de', 'es']) {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: VeliTeklifiSayfasi(lang: lang)),
      ));
      expect(find.byType(FilledButton), findsOneWidget);
    }
  });

  test('gozlemci once degerlendirmeye, sonra veli sayfasina bakiyor', () {
    // Kaynak duzeni: ayni geciste hem puan kutusu hem veli sayfasi
    // acilmamali.
    final kaynak = File('lib/services/ad_navigator_observer.dart')
        .readAsStringSync();
    final puan = kaynak.indexOf('DegerlendirmeServisi.instance.bekliyor');
    final veli = kaynak.indexOf('VeliTeklifiServisi.instance.bekliyor');
    final reklam = kaynak.indexOf('interstitialPending');
    expect(puan, greaterThan(0));
    expect(veli, greaterThan(puan));
    expect(reklam, greaterThan(veli));
  });

  test('abonelik ekrani paywall goruntulenmesini Adapty\'ye bildiriyor', () {
    final ekran =
        File('lib/screens/subscription_screen.dart').readAsStringSync();
    expect(ekran.contains('_service.logShowPaywall()'), isTrue);
    final servis =
        File('lib/services/subscription_service.dart').readAsStringSync();
    expect(servis.contains('Adapty().logShowPaywall(paywall: paywall)'),
        isTrue);
  });
}
