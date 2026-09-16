import 'package:flutter/material.dart';

/// Uygulamanin hareket dili.
///
/// Ekranlarin her birinde elle yazilmis `Duration(milliseconds: 300)` ve
/// `Curves.easeInOut` dagilmis durumdaydi; ayni jest bir yerde 150 ms, baska
/// yerde 500 ms suruyordu ve uygulama toplu bakildiginda tutarsiz
/// hissettiriyordu. Sureler ve egriler Material 3'un token setinden
/// aliniyor, tek yerde duruyor.
///
/// Temel kural: **iceri giren yavaslar, disari cikan hizlanir.**
class Motion {
  const Motion._();

  // --- Sureler (M3 duration tokens) ---------------------------------------

  /// Ripple, secim kutusu.
  static const Duration short1 = Duration(milliseconds: 50);

  /// Buton basma geri donusu.
  static const Duration short2 = Duration(milliseconds: 100);

  /// Ikon / secim degisimi.
  static const Duration short3 = Duration(milliseconds: 150);

  /// Cip secimi, ipucu balonu, kucuk vurgular.
  static const Duration short4 = Duration(milliseconds: 200);

  static const Duration medium1 = Duration(milliseconds: 250);

  /// En sik kullanilan: bilesen gecisleri, ilerleme cubugu dolusu.
  static const Duration medium2 = Duration(milliseconds: 300);

  static const Duration medium3 = Duration(milliseconds: 350);
  static const Duration medium4 = Duration(milliseconds: 400);

  static const Duration long1 = Duration(milliseconds: 450);
  static const Duration long2 = Duration(milliseconds: 500);

  /// XP sayaci gibi anlatan animasyonlar.
  static const Duration long4 = Duration(milliseconds: 600);

  /// Ders bitisi kutlamasi gibi tam ekran anlar.
  static const Duration extraLong2 = Duration(milliseconds: 800);

  // --- Egriler (M3 easing tokens) -----------------------------------------

  /// Varsayilan bilesen gecisi.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Ekrana GIREN her sey.
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Ekrandan CIKAN her sey.
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Geri yaylanma isteyen anlar: dogru cevap rozeti, yerine oturan jeton.
  static const Curve overshoot = Curves.easeOutBack;

  /// Kullanici sistem ayarlarinda hareketi azaltmayi sectiyse suslu
  /// animasyonlari kisaltiyoruz. Islevsel gecisler kaliyor ama 100 ms'yi
  /// gecmiyor; hareket duyarliligi olan cocuklar icin bu bir erisilebilirlik
  /// gerekliligi, tercih degil.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  static Duration adapt(BuildContext context, Duration d) =>
      reduced(context) ? const Duration(milliseconds: 80) : d;

  /// [reduced] ile ayni bilgi, ama BuildContext olmadan.
  ///
  /// `initState` icinde MediaQuery'ye bakmak yasak (kalitim bagimliligi
  /// orada kurulamaz); animasyonu baslatip baslatmayacagimiza ise tam
  /// orada karar vermemiz gerekiyor. Bu yuzden ayni bayragi platformdan
  /// dogrudan okuyoruz.
  static bool get reducedRaw => WidgetsBinding
      .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
}
