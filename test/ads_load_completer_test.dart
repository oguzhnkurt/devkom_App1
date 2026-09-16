import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reklam yükleme geri çağrısı beklenmeli.
///
/// `RewardedAd.load()` / `InterstitialAd.load()` fonksiyonlarının
/// döndürdüğü Future, reklam **yüklenince** değil yükleme **isteği
/// gönderilince** tamamlanıyor. Sonuç `onAdLoaded` / `onAdFailedToLoad`
/// ile sonradan geliyor.
///
/// İlk sürüm `await ...load(...)` deyip hemen ardından değişkene
/// bakıyordu; o an her zaman null oluyordu. Sonuç: **ödüllü video hiç
/// gösterilemiyordu** — "Reklam izle"ye basan kullanıcı her seferinde
/// "Şu an gösterilecek video yok" görüyordu. Geçiş reklamı da aynı
/// sebeple hiç yüklenmiyordu.
///
/// Bu, kaynağı okuyarak yakalanabilen bir hata: yükleme sonucu bir
/// `Completer` ile beklenmeli.
void main() {
  final kaynak = File('lib/services/ads_service.dart').readAsStringSync();

  /// Gerçek uygulamanın gövdesi.
  ///
  /// DİKKAT: aynı imza `abstract class AdsPlatform` içinde de geçiyor.
  /// İlk geçişe bakan bir arama soyut bildirimi buluyordu ve test kod
  /// doğruyken bile kalıyordu — bu testin ilk sürümünün hatası buydu.
  /// Arama `_RealAdsPlatform`'dan başlıyor.
  String govde(String imza) {
    final sinif = kaynak.indexOf('class _RealAdsPlatform');
    expect(sinif, isNot(-1));
    final i = kaynak.indexOf(imza, sinif);
    expect(i, isNot(-1), reason: '$imza gerçek uygulamada bulunamadı');
    final j = kaynak.indexOf('\n  }', i);
    return kaynak.substring(i, j == -1 ? kaynak.length : j);
  }

  test('showRewarded yukleme sonucunu bekliyor', () {
    final g = govde('Future<bool?> showRewarded(String unitId)');
    expect(g.contains('Completer<RewardedAd?>'), isTrue,
        reason: 'yükleme geri çağrısı beklenmiyor');
    expect(g.contains('.timeout('), isTrue,
        reason: 'ağ kötüyse çocuk boş ekranda bekler');
    expect(
      RegExp(r'onAdLoaded:\s*\(loaded\)\s*=>\s*ad\s*=\s*loaded').hasMatch(g),
      isFalse,
      reason: 'eski, hiçbir zaman çalışmayan kalıp geri gelmiş',
    );
  });

  test('loadInterstitial yukleme sonucunu bekliyor', () {
    final g = govde('Future<InterstitialAd?> loadInterstitial(String unitId)');
    expect(g.contains('Completer<InterstitialAd?>'), isTrue);
    expect(g.contains('.timeout('), isTrue);
  });

  test('dart:async import edilmis', () {
    expect(kaynak.contains("import 'dart:async';"), isTrue);
  });
}
