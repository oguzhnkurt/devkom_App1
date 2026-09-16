import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Uygulamada reklam varken magaza metninin bunu SOYLEMESINI zorlayan
/// testler.
///
/// NEDEN
/// -----
/// Reklam kodu eklendi ama `docs/MAGAZA_METNI.md` eski hâlinde kalirsa
/// App Store'da ucretsiz surumun reklamli oldugu hic yazmiyor. Bu hem
/// Kural 2.3.1'e giriyor hem de kullanicinin ilk indirisinde
/// karsilastigi surpriz oluyor. Ayni sekilde aciklamadaki "hicbir dis
/// baglanti acilmiyor" cumlesi reklamla birlikte artik dogru degil:
/// ebeveyn kapisi uygulamanin KENDI baglantilarini koruyor, reklama
/// dokunan cocugu degil.
void main() {
  final adsService = File('lib/services/ads_service.dart');
  final storeText = File('docs/MAGAZA_METNI.md');

  test('reklam katmani varsa magaza metni reklamdan bahsediyor', () {
    if (!adsService.existsSync()) return;

    final text = storeText.readAsStringSync().toLowerCase();

    expect(text.contains('reklam'), isTrue,
        reason: 'Turkce aciklama reklamdan bahsetmeli');
    expect(text.contains('ads') || text.contains('advertis'), isTrue,
        reason: 'Ingilizce aciklama reklamdan bahsetmeli');
  });

  test('aciklama artik mutlak "hicbir dis baglanti" iddiasi tasimiyor', () {
    if (!adsService.existsSync()) return;

    final text = storeText.readAsStringSync();

    const yasakli = [
      'hiçbir satın alma ya da dış bağlantı açılmıyor',
      'No\npurchase and no external link is reachable',
      'no purchase and no external link is reachable',
    ];

    for (final cumle in yasakli) {
      expect(text.toLowerCase().contains(cumle.toLowerCase()), isFalse,
          reason:
              'Reklam varken bu cumle yanlis: bir reklama dokunan cocuk '
              'ebeveyn kapisindan gecmeden disari cikabiliyor. Cumleyi '
              '"uygulamanin kendi satin almalari ve dis baglantilari" '
              'diye daralt.');
    }
  });

  test('paywall reklamsizlik sozu veriyorsa servis Pro kontrolu yapiyor', () {
    if (!adsService.existsSync()) return;

    final paywall =
        File('lib/screens/subscription_screen.dart').readAsStringSync();
    if (!paywall.contains('Reklamsız')) return;

    final service = adsService.readAsStringSync();

    // Uc giris noktasinin ucu de Pro bayragina bakmali.
    expect(service.contains('if (_isProMember)'), isTrue,
        reason: 'showRewarded Pro kontrolu ile baslamali');
    expect(
        RegExp(r'_isProMember').allMatches(service).length, greaterThan(4),
        reason: 'Pro bayragi her giris noktasinda kontrol edilmeli');
  });
}
