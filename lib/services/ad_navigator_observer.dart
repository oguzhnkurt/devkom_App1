import 'package:flutter/widgets.dart';

import 'ads_service.dart';

/// Geçiş reklamını **ekran değişiminde** gösteren gözlemci.
///
/// Ders ya da oyun bittiğinde [AdsService.markDue] yalnızca bir bayrak
/// kaldırıyor. Reklam, kullanıcı o ekrandan çıkarken burada gösteriliyor:
/// kutlama ekranının üstüne binmiyor ve çocuk "devam" düğmesine basarken
/// reklama denk gelmiyor.
///
/// Bayrak kalkmadıysa bu sınıf hiçbir şey yapmıyor; yani normal gezinme
/// sırasında maliyeti bir `if`.
class AdNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (!AdsService.instance.interstitialPending) return;
    // Pop animasyonu bitsin, reklam yeni ekranın üstünde açılsın.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdsService.instance.showInterstitialIfDue();
    });
  }
}
