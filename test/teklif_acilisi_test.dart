import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/screens/teklif_acilisi.dart';

/// Cikis teklifinin acilis gosterisi.
///
/// Ornek alinan ekran kaydinda "80% OFF FOREVER", "Your personal
/// one-time offer", "Limited annual offer" ve "You save $240 today"
/// yaziyordu. Akis alindi, iddialar ALINMADI: yuzde magazanin fiyatindan
/// hesaplaniyor, "sonsuza kadar" ve "tek seferlik" diyemeyiz (fiyat
/// degisebilir, teklif her cikista aciliyor).
void main() {
  group('iddialar', () {
    late String kod;
    setUpAll(() {
      // Yalnizca KOD satirlari: dosyanin basindaki aciklama bu kelimeleri
      // neden kullanmadigimizi anlatiyor ve iclerinde geciyor.
      kod = File('lib/screens/teklif_acilisi.dart')
          .readAsLinesSync()
          .where((s) => !s.trimLeft().startsWith('//'))
          .join('\n');
    });

    test('sabit yuzde ya da "sonsuza kadar" yok', () {
      for (final yasak in const [
        '80%',
        'FOREVER',
        'forever',
        'sonsuza',
        'für immer',
        'para siempre',
      ]) {
        expect(kod.contains(yasak), isFalse, reason: 'Kodda "$yasak" var.');
      }
      // Yuzde disaridan geliyor, widget uydurmuyor.
      expect(kod.contains('final int yuzde;'), isTrue);
    });

    test('"tek seferlik" ya da "sinirli" demiyor', () {
      for (final yasak in const [
        'one-time',
        'tek seferlik',
        'Limited',
        'Sınırlı',
        'sınırlı',
      ]) {
        expect(kod.contains(yasak), isFalse, reason: 'Kodda "$yasak" var.');
      }
    });

    test('yuzde magazanin fiyatindan hesaplaniyor', () {
      final ekran =
          File('lib/screens/subscription_screen.dart').readAsStringSync();
      expect(ekran.contains('TeklifAcilisi.goster('), isTrue);
      expect(ekran.contains('discounted.price.amount / yearly.price.amount'),
          isTrue,
          reason: 'Rozetteki yuzde gercek fiyattan hesaplanmiyor.');
    });
  });

  Future<void> ac(WidgetTester tester, TeklifAcilisi ekran,
      {Size boyut = const Size(375, 667)}) async {
    tester.view.physicalSize = boyut * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      // Hareket azaltilmis: gosteri atlanir, dogrudan son hal cizilir.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: ekran,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  const indirimli = TeklifAcilisi(
    lang: 'tr',
    yuzde: 25,
    indirimMi: true,
    teklifFiyati: '₺599,99',
    aylikKarsilik: '₺50,00',
    normalFiyat: '₺799,99',
    normalEtiket: 'Normal fiyat',
    fark: '₺200,00',
    denemeGun: 7,
  );

  testWidgets('kucuk telefonda tasmadan son hali ciziyor', (tester) async {
    await ac(tester, indirimli);
    expect(tester.takeException(), isNull);
    // Rozette ve secili kartin kosesinde.
    expect(find.text('%25'), findsWidgets);
    expect(find.text('İNDİRİM'), findsOneWidget);
    expect(find.text('₺599,99'), findsOneWidget);
    expect(find.text('₺799,99'), findsOneWidget);
    expect(find.text('7 gün ücretsiz başla'), findsOneWidget);
  });

  testWidgets('vazgecmek gorunur ve calisiyor', (tester) async {
    bool? sonuc;
    tester.view.physicalSize = const Size(375, 667) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async =>
                sonuc = await TeklifAcilisi.goster(context, indirimli),
            child: const Text('ac'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('ac'));
    await tester.pumpAndSettle();
    final vazgec = find.text('Hayır, teşekkürler');
    expect(vazgec, findsOneWidget);
    await tester.ensureVisible(vazgec);
    await tester.tap(vazgec);
    await tester.pumpAndSettle();
    expect(sonuc, isFalse);
  });

  testWidgets('indirim yoksa "indirim" demiyor', (tester) async {
    await ac(
      tester,
      const TeklifAcilisi(
        lang: 'tr',
        yuzde: 37,
        indirimMi: false,
        teklifFiyati: '₺799,99',
        aylikKarsilik: '₺66,67',
        normalFiyat: '₺1.271,88',
        normalEtiket: 'Aylık plan',
        fark: '₺471,89',
      ),
    );
    expect(find.text('İNDİRİM'), findsNothing);
    expect(find.text('TASARRUF'), findsOneWidget);
    // Deneme yoksa deneme vaadi de yok.
    expect(find.textContaining('ücretsiz'), findsNothing);
  });

  testWidgets('dort dilde ciziliyor', (tester) async {
    for (final dil in const ['en', 'de', 'es']) {
      await ac(
        tester,
        TeklifAcilisi(
          lang: dil,
          yuzde: 14,
          indirimMi: true,
          teklifFiyati: r'$29.99',
          aylikKarsilik: r'$2.50',
          normalFiyat: r'$34.99',
          normalEtiket: 'Regular',
          fark: r'$5.00',
        ),
      );
      expect(tester.takeException(), isNull, reason: '$dil tasti');
      expect(find.textContaining('Hayır'), findsNothing,
          reason: '$dil ekraninda Turkce kaldi');
    }
  });
}
