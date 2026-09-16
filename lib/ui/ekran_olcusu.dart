import 'package:flutter/widgets.dart';

/// Ekran yuksekligine gore aralik/dolgu olcegi.
///
/// Neden var: ders ve oyun ekranlari 20-24 piksellik sabit araliklarla
/// yazilmisti. iPhone 15 Pro Max'te bu rahat duruyor; iPhone SE'de
/// (568 pt) ayni icerik ekrana sigmiyor ve cocuk "Devam" tusunu ya da
/// yonergeyi gormek icin kaydirmak zorunda kaliyor. Ayni tasarimi iki
/// boyda birden calistirmanin en ucuz yolu araliklari kucultmek:
/// hicbir sey kaybolmuyor, yalnizca nefes payi daraliyor.
///
/// Esikler cihaz listesinden degil, mantikli yerlerden:
///   < 600 pt  -> iPhone SE (1./2./3. nesil), kucuk Android
///   < 700 pt  -> iPhone 8/SE3, iPhone 13 mini
class EkranOlcusu {
  EkranOlcusu._();

  static double _yukseklik(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// 0.7 (cok kisa) — 0.85 (kisa) — 1.0 (normal)
  static double olcek(BuildContext context) {
    final h = _yukseklik(context);
    if (h < 600) return 0.7;
    if (h < 700) return 0.85;
    return 1.0;
  }

  /// Dikey araligi ekrana gore kucultur.
  static double bosluk(BuildContext context, double normal) =>
      normal * olcek(context);

  /// Ekran cok kisa mi? (iPhone SE ve benzeri)
  static bool kisa(BuildContext context) => _yukseklik(context) < 700;
}
