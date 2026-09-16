import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/screens/widgets/kod_tezgahi.dart';
import 'package:devkom_app/providers/settings_provider.dart';

/// Uygulama ici kod tezgahinin GUVENLIK kurallari.
///
/// Tezgah, cocugun yazdigi HTML'i gomulu bir tarayicida calistiriyor.
/// Bu, uygulamanin en genis saldiri yuzeyi: cocugun (ya da bir yerden
/// kopyaladigi metnin) yazdigi sey dogrudan calisiyor. Kurallar
/// yorumda degil burada duruyor.
void main() {
  test('onizleme belgesi disariya kapali', () {
    final belge = onizlemeBelgesi('<h1>Merhaba</h1>');

    // Cocugun yazdigi govde gercekten iceride.
    expect(belge.contains('<h1>Merhaba</h1>'), isTrue);

    // Icerik Guvenligi Politikasi: hicbir sey uzaktan cekilemez.
    expect(belge.contains('Content-Security-Policy'), isTrue);
    expect(belge.contains("default-src 'none'"), isTrue,
        reason: 'Varsayilan kapali olmazsa yazilan HTML uzaktan resim, '
            'yazi tipi ya da stil cekebilir.');
    expect(belge.contains('img-src data:'), isTrue,
        reason: 'Resim yalnizca gomulu (data:) olabilmeli.');

    // script-src ACIKCA verilmiyor; default-src none onu da kapatiyor.
    expect(belge.contains("script-src 'unsafe-inline'"), isFalse);
  });

  test('tezgah betik calistirmiyor ve hicbir yere gitmiyor', () {
    final kod = File('lib/courses/screens/widgets/kod_tezgahi.dart')
        .readAsLinesSync()
        .where((s) => !s.trimLeft().startsWith('//') &&
            !s.trimLeft().startsWith('///'))
        .join('\n');

    expect(kod.contains('JavaScriptMode.disabled'), isTrue,
        reason: 'HTML/CSS dersinin JavaScript\'e ihtiyaci yok; acik '
            'olmasi cocugun sayfada betik calistirmasina izin verir.');
    expect(kod.contains('JavaScriptMode.unrestricted'), isFalse);

    expect(kod.contains('NavigationDecision.prevent'), isTrue,
        reason: 'Cocugun yazdigi bir <a href> uygulamanin disina '
            'cikarmamali; ebeveyn kapisi gomulu sayfayi korumuyor.');
    expect(kod.contains('NavigationDecision.navigate'), isFalse);

    expect(kod.contains('runJavaScript'), isFalse);

    // Sayfa YERELDEN geliyor: hicbir adres yuklenmiyor.
    expect(kod.contains('loadHtmlString'), isTrue);
    expect(kod.contains('loadRequest'), isFalse);
  });

  testWidgets('kod kaydediliyor ve geri yukleniyor', (tester) async {
    SharedPreferences.setMockInitialValues({
      KodTezgahi.anahtar('x1'): '<p>eski kod</p>',
    });
    final settings = SettingsProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settings,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: KodTezgahi(
                adimId: 'x1',
                baslangicKodu: '<h1>iskelet</h1>',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    // Kayitli kod iskeletin yerini almali: cocuk dersten cikip
    // donunce yazdigini kaybetmemeli.
    expect(find.text('<p>eski kod</p>'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
